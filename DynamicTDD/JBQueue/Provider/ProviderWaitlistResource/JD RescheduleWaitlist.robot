*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Waitlist, Queue
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/hl_providers.py
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
*** Variables ***

${self}     0
${digits}       0123456789
@{dom_list}
@{provider_list}
@{multiloc_providers}

*** Keywords ***
Multiloc and Billable Providers

    ${multilocdoms}=  get_mutilocation_domains
    Log  ${multilocdoms}
    ${domlen}=  Get Length   ${multilocdoms}
    ${resp}=   Get File    /ebs/TDD/varfiles/providers.py
    ${len}=   Split to lines  ${resp}
    ${length}=  Get Length   ${len}

    FOR   ${i}  IN RANGE   ${domlen}
        ${dom}=  Convert To String   ${multilocdoms[${i}]['domain']}
        Append To List   ${dom_list}  ${dom}
    END
    Log   ${dom_list}
     
    FOR   ${a}  IN RANGE   ${length-1}    
        ${resp}=  Encrypted Provider Login  ${PUSERNAME${a}}  ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        ${domain}=   Set Variable    ${decrypted_data['sector']}
        ${subdomain}=    Set Variable      ${decrypted_data['subSector']}
        Log  ${dom_list}
        ${status} 	${value} = 	Run Keyword And Ignore Error  List Should Contain Value  ${dom_list}  ${domain}
        Log Many  ${status} 	${value}
        Run Keyword If  '${status}' == 'PASS'   Append To List   ${multiloc_providers}  ${PUSERNAME${a}}
        ${resp2}=   Get Sub Domain Settings    ${domain}    ${subdomain}
        Log   ${resp2.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        Set Test Variable  ${check}    ${resp2.json()['serviceBillable']} 
        Run Keyword If     '${check}' == 'True'   Append To List   ${provider_list}  ${PUSERNAME${a}}
        # Run Keyword If    '${status}' == 'PASS' and '${check}' == 'True'   Append To List  ${multiloc_billable_providers}  ${PUSERNAME${a}}
    END
    # RETURN  ${provider_list}  ${multiloc_providers}  ${multiloc_billable_providers}
    RETURN  ${provider_list}  ${multiloc_providers}

*** Test Cases ***

JD-TC-Reschedule Waitlist-1
    [Documentation]  Provider takes checkin for a consumer and reschedules it to another day.
    ...  ${SPACE} Check Communication messages also
    
    # ${resp}=  Consumer Login  ${CUSERNAME12}  ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # Set Test Variable  ${jdconID}   ${resp.json()['id']}
    # Set Test Variable  ${fname}   ${resp.json()['firstName']}
    # Set Test Variable  ${lname}   ${resp.json()['lastName']}
    # Set Test Variable  ${uname}   ${resp.json()['userName']}

    # ${resp}=  Consumer Logout
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME32}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}  

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bsname}  ${resp.json()['businessName']}
    Set Test Variable  ${pid}  ${resp.json()['id']}
    Set Test Variable  ${uniqueId}  ${resp.json()['uniqueId']}

    clear_customer   ${PUSERNAME32}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
	
    ${SERVICE1}=    generate_service_name
    ${s_id}=  Create Sample Service  ${SERVICE1}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${duration}   ${resp.json()[0]['serviceDuration']}

    ${lid}=  Create Sample Location  
    clear_queue   ${PUSERNAME32}

    ${resp}=  Get Queues
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME12}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}   ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${DAY3}=  db.add_timezone_date  ${tz}  4
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${queue_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${capacity}=  FakerLibrary.Random Int  min=5  max=10
    ${resp}=  Create Queue    ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${lid}  ${s_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${q_id}   name=${queue_name}  queueState=${Qstate[0]}

    # ${now}=   db.get_time_by_timezone   ${tz}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${s_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wl_json}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wl_json[0]}

    ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Reschedule Consumer Checkin   ${wid}  ${DAY3}  ${q_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${date2}=  Convert Date  ${DAY3}  result_format=%d-%m-%Y

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY3}  waitlistStatus=${wl_status[0]}  
    ...   waitlistedBy=${waitlistedby[1]}   personsAhead=0   #checkInTime=${sTime1}  
    ...   consLastVisitedDate=${date2}${SPACE}${sTime1}  serviceTime=${sTime1}
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}
    # Set Test Variable   ${servicetime}   ${resp.json()['serviceTime']}

    sleep  05s

    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get YnwConf Appointment Messages
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${date}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y

    sleep  03s
    
    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200


    ${account_id}=  get_acc_id  ${PUSERNAME32}
    Set Suite Variable  ${account_id}
    ${resp}=  Send Otp For Login    ${CUSERNAME12}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Verify Otp For Login   ${CUSERNAME12}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}
    
    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME12}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        0
    # Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${apptid1}
    # Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${defcheckInML_msg1}
    # Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     ${jdconID} 

    # Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}        0
    # Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}         ${apptid1}
    # Should Be Equal As Strings  ${resp.json()[1]['msg']}                ${defreshedule_checkin_msg}
    # Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}     ${jdconID}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Reschedule Waitlist-2
    [Documentation]  Provider takes checkin for a consumer and reschedules it to a future date when there is already a checkin there.
    ...   ${SPACE}Also check Provider and Consumer messages.

    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME32}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_customer   ${PUSERNAME32}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
	
    ${SERVICE1}=    generate_service_name
    ${s_id}=  Create Sample Service  ${SERVICE1}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${duration}   ${resp.json()[0]['serviceDuration']}

    ${lid}=  Create Sample Location  
    clear_queue   ${PUSERNAME32}

    ${resp}=  Get Queues
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME12}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME13}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}   ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${DAY3}=  db.add_timezone_date  ${tz}  4
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${queue_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${capacity}=  FakerLibrary.Random Int  min=5  max=10
    ${resp}=  Create Queue    ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${lid}  ${s_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${q_id}   name=${queue_name}  queueState=${Qstate[0]}

    ${now}=   db.get_time_by_timezone   ${tz}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${s_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wl_json}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wl_json[0]}

    ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  
    ...   waitlistedBy=${waitlistedby[1]}   personsAhead=0   #checkInTime=${sTime1}  
    ...   consLastVisitedDate=${date1}${SPACE}${sTime1} 
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid1}  ${s_id}  ${q_id}  ${DAY3}  ${desc}  ${bool[1]}  ${cid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wl_json}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wl_json[0]}

    ${date2}=  Convert Date  ${DAY3}  result_format=%d-%m-%Y

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200                
    Verify Response  ${resp}  date=${DAY3}  waitlistStatus=${wl_status[0]}  
    ...   waitlistedBy=${waitlistedby[1]}   personsAhead=0   #checkInTime=${sTime1}  
    ...   consLastVisitedDate=${date2}${SPACE}${sTime1}   serviceTime=${sTime1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid1}

    ${wait_time}=  Evaluate  ${duration}/1
    ${wait_time}=  rounded   ${wait_time}
    ${wait_time}=  Convert To Integer   ${wait_time}
    ${hrs}  ${mins}=   Convert_hour_mins   ${wait_time}

    ${sTime2}=  db.add_timezone_time  ${tz}  ${hrs}  ${mins}
    
    ${resp}=  Reschedule Consumer Checkin   ${wid}  ${DAY3}  ${q_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${date2}=  Convert Date  ${DAY3}  result_format=%d-%m-%Y

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY3}  waitlistStatus=${wl_status[0]}  
    ...   waitlistedBy=${waitlistedby[1]}   personsAhead=1   #checkInTime=${sTime1}  
    ...   consLastVisitedDate=${date2}${SPACE}${sTime1}  appxWaitingTime=${wait_time}  
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}

    sleep  05s
    
    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME12}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-Reschedule Waitlist-3
    [Documentation]  Provider takes checkin for a consumer and reschedules it to another queue
    ...   ${SPACE}and checks messages
  
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME32}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bsname}  ${resp.json()['businessName']}
    Set Test Variable  ${pid}  ${resp.json()['id']}
    Set Test Variable  ${uniqueId}  ${resp.json()['uniqueId']}

    clear_customer   ${PUSERNAME32}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
	
    ${SERVICE1}=    generate_service_name
    ${s_id}=  Create Sample Service  ${SERVICE1}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${duration}   ${resp.json()[0]['serviceDuration']}

    ${lid}=  Create Sample Location  
    clear_queue   ${PUSERNAME32}

    ${resp}=  Get Queues
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME12}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME12}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta1}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta1}
    ${queue_name1}=  FakerLibrary.bs
    ${parallel1}=  FakerLibrary.Random Int  min=1  max=1
    ${capacity1}=  FakerLibrary.Random Int  min=5  max=10
    ${resp}=  Create Queue    ${queue_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel1}  ${capacity1}  ${lid}  ${s_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id1}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${q_id1}   name=${queue_name1}  queueState=${Qstate[0]}

    ${now}=   db.get_time_by_timezone   ${tz}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${s_id}  ${q_id1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wl_json}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wl_json[0]}

    ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  
    ...   waitlistedBy=${waitlistedby[1]}   personsAhead=0   #checkInTime=${sTime1}  
    ...   consLastVisitedDate=${date1}${SPACE}${sTime1} 
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}
    # Set Test Variable   ${waitingtime}   ${resp.json()['appxWaitingTime']}
    # ${waitingtime}=   Convert To String  ${waitingtime}

    ${sTime2}=  add_two   ${eTime1}  ${delta1}
    ${delta2}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime2}=  add_two   ${sTime2}  ${delta2}
    ${queue_name2}=  FakerLibrary.bs
    ${parallel2}=  FakerLibrary.Random Int  min=1  max=1
    ${capacity2}=  FakerLibrary.Random Int  min=5  max=10
    ${resp}=  Create Queue    ${queue_name2}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel2}  ${capacity2}  ${lid}  ${s_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id2}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${q_id2}   name=${queue_name2}  queueState=${Qstate[0]}

    ${resp}=  Reschedule Consumer Checkin   ${wid}  ${DAY1}  ${q_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  
    ...   waitlistedBy=${waitlistedby[1]}   personsAhead=0   #checkInTime=${sTime1}  
    ...   consLastVisitedDate=${date1}${SPACE}${sTime2}  
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}
    # Set Test Variable   ${servicetime}   ${resp.json()['serviceTime']}

    # ${resp}=  Get bsconf Messages
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}   200
    # ${defcheckInML_msg}=  Set Variable   ${resp.json()['checkInML_push']} 
    # ${defreshedule_checkin_msg}=  Set Variable   ${resp.json()['reshedule_provider_notify_checkin']} 
    
    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME12}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-Reschedule Waitlist-4
    [Documentation]  Provider takes checkin for a consumer and reschedules it to another day after prepayment.

    # ${billable_providers}   ${multilocPro}=    Multiloc and Billable Providers   min=30   max=40
    ${billable_providers}   ${multilocPro}=    Multiloc and Billable Providers 
    Log   ${billable_providers}
    Log   ${multilocPro}
    Set Suite Variable   ${billable_providers}
    Set Suite Variable   ${multilocPro}
    
    ${resp}=  Encrypted Provider Login  ${billable_providers[2]}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bsname}  ${resp.json()['businessName']}
    Set Test Variable  ${pid}  ${resp.json()['id']}
    Set Test Variable  ${uniqueId}  ${resp.json()['uniqueId']}

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Appointment 
        Should Be Equal As Strings  ${resp.status_code}  200
    END

   ${resp}=   Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp1}=  Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment    ${toggle[0]}
    Run Keyword If  '${resp1}' != '${None}'   Log  ${resp1.content}
    Run Keyword If  '${resp1}' != '${None}'   Should Be Equal As Strings  ${resp1.status_code}  200

    # ${resp}=  SetMerchantId  ${pid}  ${merchantid}

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}  

    IF  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}
        ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
    END 

    # ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[1]}
    # Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    
    IF  ${resp.json()['enableJaldeeFinance']}==${bool[0]}
        ${resp1}=    Enable Disable Jaldee Finance   ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableJaldeeFinance']}  ${bool[1]}

    clear_location   ${billable_providers[2]}
    clear_service    ${billable_providers[2]}
    clear_customer   ${billable_providers[2]}
    clear_provider_msgs  ${billable_providers[2]}
    clear_consumer_msgs  ${CUSERNAME12}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
	
    ${SERVICE1}=    generate_service_name
    ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    Set Suite Variable   ${min_pre}
    ${s_id}=  Create Sample Service    ${SERVICE1}  maxBookingsAllowed=10   isPrePayment=${bool[1]}   minPrePaymentAmount=${min_pre} 

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${duration}   ${resp.json()[0]['serviceDuration']}

    ${lid}=  Create Sample Location  
    clear_queue   ${billable_providers[2]}

    ${resp}=  Get Queues
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME12}    firstName=${bsname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${DAY3}=  db.add_timezone_date  ${tz}  4
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${queue_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${capacity}=  FakerLibrary.Random Int  min=5  max=10
    ${resp}=  Create Queue    ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${lid}  ${s_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${q_id}   name=${queue_name}  queueState=${Qstate[0]}

    ${now}=   db.get_time_by_timezone   ${tz}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${s_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wl_json}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid4}  ${wl_json[0]}

    ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y

    ${resp}=  Get Waitlist By Id  ${wid4} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  
    ...   waitlistedBy=${waitlistedby[1]}   personsAhead=0   #checkInTime=${sTime1}  
    ...   consLastVisitedDate=${date1}${SPACE}${sTime1}  
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}
    # Set Test Variable   ${waitingtime}   ${resp.json()['appxWaitingTime']}

    ${resp}=  Send Otp For Login    ${CUSERNAME12}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Verify Otp For Login   ${CUSERNAME12}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}
    

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME12}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    ${resp}=  Get consumer Waitlist By Id   ${wid4}  ${pid}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  
    ...   partySize=1    waitlistedBy=${waitlistedby[1]}  
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${s_id}
    # Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${jdconID}
    # Should Be Equal As Strings  ${resp.json()['consumer']['jaldeeId']}  ${jdconID}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${cid}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${q_id}
    
    ${resp}=  Make payment Consumer Mock  ${pid}  ${min_pre}  ${purpose[0]}  ${wid4}  ${s_id}  ${bool[0]}   ${bool[1]}  ${jdconID}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${payref}   ${resp.json()['paymentRefId']}

    sleep   2s
    ${resp}=  Get Bill By consumer  ${wid4}  ${pid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Payment Details  paymentRefId-eq=${payref}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${wid4}
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  ${min_pre}.0
    # Should Be Equal As Strings  ${resp.json()[0]['custId']}  ${jdconID}  
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[0]}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${pid}

    ${resp}=  Get Payment Details By UUId  ${wid4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${wid4}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[0]}  
    Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${pay_mode_selfpay}
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  ${min_pre}.0 
    # Should Be Equal As Strings  ${resp.json()[0]['custId']}  ${jdconID}   
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}  ${payment_modes[5]}  
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${pid}   
    Should Be Equal As Strings  ${resp.json()[0]['paymentGateway']}  RAZORPAY  

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${billable_providers[2]}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Reschedule Consumer Checkin   ${wid4}  ${DAY3}  ${q_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${date2}=  Convert Date  ${DAY3}  result_format=%d-%m-%Y

    ${resp}=  Get Waitlist By Id  ${wid4} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY3}  waitlistStatus=${wl_status[0]}  
    ...   waitlistedBy=${waitlistedby[1]}   personsAhead=0   #checkInTime=${sTime1}  
    ...   consLastVisitedDate=${date2}${SPACE}${sTime1}  serviceTime=${sTime1}
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}

    # ${resp}=  Get bsconf Messages
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}   200
    # ${defcheckInML_msg}=  Set Variable   ${resp.json()['checkInML_push']} 
    # ${defreshedule_checkin_msg}=  Set Variable   ${resp.json()['reshedule_provider_notify_checkin']} 

    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME12}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-Reschedule Waitlist-5
    [Documentation]  Provider takes checkin for a consumer and reschedules it to another day after bill payment.

    # ${billable_providers}   ${multilocPro}=    Multiloc and Billable Providers
    Log   ${billable_providers}
    Log   ${multilocPro}
    # Set Suite Variable   ${billable_providers}
    # Set Suite Variable   ${multilocPro}
    
    ${resp}=  Encrypted Provider Login  ${billable_providers[2]}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Account Settings 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bsname}  ${resp.json()['businessName']}
    Set Test Variable  ${pid}  ${resp.json()['id']}
    Set Test Variable  ${uniqueId}  ${resp.json()['uniqueId']}

    ${resp}=  SetMerchantId  ${pid}  ${merchantid}

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}  

    IF  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}
        ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
    END 

    # ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[1]}
    # Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    
    IF  ${resp.json()['enableJaldeeFinance']}==${bool[0]}
        ${resp1}=    Enable Disable Jaldee Finance   ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableJaldeeFinance']}  ${bool[1]}


    clear_customer   ${billable_providers[2]}
    clear_provider_msgs  ${billable_providers[2]}
    clear_consumer_msgs  ${CUSERNAME13}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
	
    ${SERVICE1}=    generate_service_name
    ${s_id}=  Create Sample Service  ${SERVICE1}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${duration}   ${resp.json()[0]['serviceDuration']}
    Set Test Variable   ${servicecharge}   ${resp.json()[0]['totalAmount']}

    ${lid}=  Create Sample Location  
    clear_queue   ${billable_providers[2]}

    ${resp}=  Get Queues
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${f_Name}=  generate_firstname
    ${l_Name}=  FakerLibrary.last_name

    ${resp}=  AddCustomer   ${CUSERNAME13}    firstName=${f_Name}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}

    ${resp} =   GetCustomer   phoneNo-eq=${CUSERNAME13}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${j_cid}   ${resp.json()[0]['jaldeeConsumer']}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${DAY3}=  db.add_timezone_date  ${tz}  4
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${queue_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${capacity}=  FakerLibrary.Random Int  min=5  max=10
    ${resp}=  Create Queue    ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${lid}  ${s_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${q_id}   name=${queue_name}  queueState=${Qstate[0]}

    ${now}=   db.get_time_by_timezone   ${tz}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${s_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wl_json}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wl_json[0]}

    ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  
    ...   waitlistedBy=${waitlistedby[1]}   personsAhead=0   #checkInTime=${sTime1}  
    ...   consLastVisitedDate=${date1}${SPACE}${sTime1} 
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}
    # Set Test Variable   ${waitingtime}   ${resp.json()['appxWaitingTime']}

    ${resp}=  Send Otp For Login    ${CUSERNAME13}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Verify Otp For Login   ${CUSERNAME13}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}
    
    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME13}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get consumer Waitlist By Id   ${wid}  ${pid}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  
    ...   partySize=1  waitlistedBy=${waitlistedby[1]}  personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${s_id}
    # Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${jdconID}
    # Should Be Equal As Strings  ${resp.json()['consumer']['jaldeeId']}  ${jdconID}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${cid}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${q_id}
    
    ${resp}=  Make payment Consumer Mock  ${pid}  ${servicecharge}  ${purpose[0]}  ${wid}  ${s_id}  ${bool[0]}   ${bool[1]}  ${j_cid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Test Variable   ${payref}   ${resp.json()['paymentRefId']}

    ${resp}=  Get Bill By consumer  ${wid}  ${pid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Payment Details  paymentRefId-eq=${payref}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  ${servicecharge}
    # Should Be Equal As Strings  ${resp.json()[0]['custId']}  ${jdconID}  
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[0]}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${pid}

    ${resp}=  Get Payment Details By UUId  ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[0]}  
    Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${pay_mode_selfpay}
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  ${servicecharge}
    # Should Be Equal As Strings  ${resp.json()[0]['custId']}  ${jdconID}   
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}  ${payment_modes[5]}  
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${pid}   
    Should Be Equal As Strings  ${resp.json()[0]['paymentGateway']}  RAZORPAY  

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${billable_providers[2]}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Reschedule Consumer Checkin   ${wid}  ${DAY3}  ${q_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${date2}=  Convert Date  ${DAY3}  result_format=%d-%m-%Y

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY3}  waitlistStatus=${wl_status[0]}  
    ...   waitlistedBy=${waitlistedby[1]}   personsAhead=0   #checkInTime=${sTime1}  
    ...   consLastVisitedDate=${date2}${SPACE}${sTime1}  serviceTime=${sTime1}
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}

    # ${resp}=  Get bsconf Messages
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}   200
    # ${defcheckInML_msg}=  Set Variable   ${resp.json()['checkInML_push']} 
    # ${defreshedule_checkin_msg}=  Set Variable   ${resp.json()['reshedule_provider_notify_checkin']} 

    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME13}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Reschedule Waitlist-6
    [Documentation]  Provider takes checkin for a consumer using token and reschedules it to a future date
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME32}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bsname}  ${resp.json()['businessName']}
    Set Test Variable  ${pid}  ${resp.json()['id']}
    Set Test Variable  ${uniqueId}  ${resp.json()['uniqueId']}

    ${resp}=  Get Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    # ${resp1}=   Run Keyword If  ${resp.json()['showTokenId']}==${bool[0]}   Enable Disable Token Id  ${bool[1]}
    # Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    # Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200
    
    ${resp}=    Enable Disable Token Id  ${bool[1]}    
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  showTokenId=${bool[1]}
    
    clear_customer   ${PUSERNAME32}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
	
    ${SERVICE1}=    generate_service_name
    ${s_id}=  Create Sample Service  ${SERVICE1}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${duration}   ${resp.json()[0]['serviceDuration']}

    ${lid}=  Create Sample Location  
    clear_queue   ${PUSERNAME32}

    ${resp}=  Get Queues
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME12} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${DAY3}=  db.add_timezone_date  ${tz}  4
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${queue_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${capacity}=  FakerLibrary.Random Int  min=5  max=10
    ${resp}=  Create Queue    ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${lid}  ${s_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${q_id}   name=${queue_name}  queueState=${Qstate[0]}

    ${now}=   db.get_time_by_timezone   ${tz}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${s_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wl_json}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wl_json[0]}

    ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  
    ...   waitlistedBy=${waitlistedby[1]}   personsAhead=0   #checkInTime=${sTime1}  
    ...   consLastVisitedDate=${date1}${SPACE}${sTime1}  
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}
    # Set Test Variable   ${waitingtime}   ${resp.json()['appxWaitingTime']}


    ${resp}=  Reschedule Consumer Checkin   ${wid}  ${DAY3}  ${q_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${date2}=  Convert Date  ${DAY3}  result_format=%d-%m-%Y

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY3}  waitlistStatus=${wl_status[0]}  
    ...   waitlistedBy=${waitlistedby[1]}   personsAhead=0   #checkInTime=${sTime1}  
    ...   consLastVisitedDate=${date2}${SPACE}${sTime1}  
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}

    # ${resp}=  Get bsconf Messages
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}   200
    # ${defcheckInML_msg}=  Set Variable   ${resp.json()['checkInML_push']} 
    # ${defreshedule_checkin_msg}=  Set Variable   ${resp.json()['reshedule_provider_notify_checkin']} 
    
    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME12}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200



JD-TC-Reschedule Waitlist-7
    [Documentation]  Provider takes checkin for a consumer using token and reschedules it to a future date when there is already a checkin there

    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME32}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bsname}  ${resp.json()['businessName']}
    Set Test Variable  ${pid}  ${resp.json()['id']}
    Set Test Variable  ${uniqueId}  ${resp.json()['uniqueId']}

    ${resp}=  Get Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp1}=   Run Keyword If  ${resp.json()['showTokenId']}==${bool[0]}   Enable Disable Token Id  ${bool[1]}
    # Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    # Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200
    
    ${resp}=    Enable Disable Token Id  ${bool[1]}    
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist Settings
    Log  ${resp.json()}
    Verify Response  ${resp}  showTokenId=${bool[1]}

    clear_customer   ${PUSERNAME32}


    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
	
    ${SERVICE1}=    generate_service_name
    ${s_id}=  Create Sample Service  ${SERVICE1}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${duration}   ${resp.json()[0]['serviceDuration']}

    ${lid}=  Create Sample Location  
    clear_queue   ${PUSERNAME32}

    ${resp}=  Get Queues
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME12} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME13}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}   ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${DAY3}=  db.add_timezone_date  ${tz}  4
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${queue_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${capacity}=  FakerLibrary.Random Int  min=5  max=10
    ${resp}=  Create Queue    ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${lid}  ${s_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${q_id}   name=${queue_name}  queueState=${Qstate[0]}

    ${now}=   db.get_time_by_timezone   ${tz}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${s_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wl_json}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wl_json[0]}

    ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  
    ...   waitlistedBy=${waitlistedby[1]}   personsAhead=0   #checkInTime=${sTime1}  
    ...   consLastVisitedDate=${date1}${SPACE}${sTime1} 
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}
    Set Test Variable   ${waitingtime}   ${resp.json()['appxWaitingTime']}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid1}  ${s_id}  ${q_id}  ${DAY3}  ${desc}  ${bool[1]}  ${cid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wl_json}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wl_json[0]}

    ${date2}=  Convert Date  ${DAY3}  result_format=%d-%m-%Y

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200                
    Verify Response  ${resp}  date=${DAY3}  waitlistStatus=${wl_status[0]}  
    ...   waitlistedBy=${waitlistedby[1]}   personsAhead=0   ##checkInTime=${sTime1}  
    ...   consLastVisitedDate=${date2}${SPACE}${sTime1}   serviceTime=${sTime1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid1}


    ${resp}=  Reschedule Consumer Checkin   ${wid}  ${DAY3}  ${q_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${wait_time}=  Evaluate  ${duration}/1
    ${wait_time}=  rounded   ${wait_time}
    ${wait_time}=  Convert To Integer   ${wait_time}
    ${hrs}  ${mins}=   Convert_hour_mins   ${wait_time}

    # ${sTime2}=  db.add_timezone_time  ${tz}  ${hrs}  ${mins}
    ${sTime2}=  add_two   ${sTime1}  ${mins}

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY3}  waitlistStatus=${wl_status[0]}  
    ...   waitlistedBy=${waitlistedby[1]}   personsAhead=1   ##checkInTime=${sTime1}  
    ...   consLastVisitedDate=${date2}${SPACE}${sTime1}  appxWaitingTime=${wait_time}  
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}

    # ${resp}=  Get bsconf Messages
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}   200
    # ${defcheckInML_msg}=  Set Variable   ${resp.json()['checkInML_push']} 
    # ${defreshedule_checkin_msg}=  Set Variable   ${resp.json()['reshedule_provider_notify_checkin']} 
    
    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME12}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-Reschedule Waitlist-8
    [Documentation]  Provider takes future checkin for a consumer and reschedules it to today.
    ...  ${SPACE} Check Communication messages als
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME32}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bsname}  ${resp.json()['businessName']}
    Set Test Variable  ${pid}  ${resp.json()['id']}
    Set Test Variable  ${uniqueId}  ${resp.json()['uniqueId']}

    ${resp}=  Get Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp1}=   Run Keyword If  ${resp.json()['showTokenId']}==${bool[1]}   Enable Disable Token Id  ${bool[0]}
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${resp}=  Get Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  showTokenId=${bool[0]}

    clear_customer   ${PUSERNAME32}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
	
    ${SERVICE1}=    generate_service_name
    ${s_id}=  Create Sample Service  ${SERVICE1}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${duration}   ${resp.json()[0]['serviceDuration']}

    ${lid}=  Create Sample Location  
    clear_queue   ${PUSERNAME32}

    ${resp}=  Get Queues
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME12} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${DAY3}=  db.add_timezone_date  ${tz}  4
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${queue_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${capacity}=  FakerLibrary.Random Int  min=5  max=10
    ${resp}=  Create Queue    ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${lid}  ${s_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${q_id}   name=${queue_name}  queueState=${Qstate[0]}

    ${now}=   db.get_time_by_timezone   ${tz}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${s_id}  ${q_id}  ${DAY3}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wl_json}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wl_json[0]}

    ${date2}=  Convert Date  ${DAY3}  result_format=%d-%m-%Y

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY3}  waitlistStatus=${wl_status[0]}  
    ...   waitlistedBy=${waitlistedby[1]}   personsAhead=0   #checkInTime=${sTime1}  
    ...   consLastVisitedDate=${date2}${SPACE}${sTime1}  
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}
    # Set Test Variable   ${waitingtime}   ${resp.json()['appxWaitingTime']}

    ${resp}=  Reschedule Consumer Checkin   ${wid}  ${DAY1}  ${q_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  
    ...   waitlistedBy=${waitlistedby[1]}   personsAhead=0   #checkInTime=${sTime1}  
    ...   consLastVisitedDate=${date1}${SPACE}${sTime1} 
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}

    # ${resp}=  Get bsconf Messages
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}   200
    
    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME12}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-Reschedule Waitlist-9
    [Documentation]  Provider takes checkin for a consumer and reschedules it to another queue for a different location
    ...   ${SPACE}and checks messages
    
    Log   ${multilocPro}
    
    ${resp}=  Encrypted Provider Login  ${multilocPro[2]}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bsname}  ${resp.json()['businessName']}
    Set Test Variable  ${pid}  ${resp.json()['id']}
    Set Test Variable  ${uniqueId}  ${resp.json()['uniqueId']}

    clear_customer   ${multilocPro[2]}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
	
    ${SERVICE1}=    generate_service_name
    ${s_id}=  Create Sample Service  ${SERVICE1}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${duration}   ${resp.json()[0]['serviceDuration']}

    ${lid}=  Create Sample Location  
    ${lid1}=  Create Sample Location
    clear_queue   ${multilocPro[2]}

    ${resp}=  Get Queues
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME12} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta1}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta1}
    ${queue_name1}=  FakerLibrary.bs
    ${parallel1}=  FakerLibrary.Random Int  min=1  max=1
    ${capacity1}=  FakerLibrary.Random Int  min=5  max=10
    ${resp}=  Create Queue    ${queue_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel1}  ${capacity1}  ${lid}  ${s_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id1}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${q_id1}   name=${queue_name1}  queueState=${Qstate[0]}

    ${now}=   db.get_time_by_timezone   ${tz}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${s_id}  ${q_id1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wl_json}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wl_json[0]}

    ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  
    ...   waitlistedBy=${waitlistedby[1]}   personsAhead=0   #checkInTime=${sTime1}  
    ...   consLastVisitedDate=${date1}${SPACE}${sTime1}  
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}
    # Set Test Variable   ${waitingtime}   ${resp.json()['appxWaitingTime']}
    # ${waitingtime}=   Convert To String  ${waitingtime}

    ${sTime2}=  add_two   ${eTime1}  ${delta1}
    ${delta2}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime2}=  add_two   ${sTime2}  ${delta2}
    ${queue_name2}=  FakerLibrary.bs
    ${parallel2}=  FakerLibrary.Random Int  min=1  max=1
    ${capacity2}=  FakerLibrary.Random Int  min=5  max=10
    ${resp}=  Create Queue    ${queue_name2}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel2}  ${capacity2}  ${lid1}  ${s_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id2}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${q_id2}   name=${queue_name2}  queueState=${Qstate[0]}

    ${resp}=  Reschedule Consumer Checkin   ${wid}  ${DAY1}  ${q_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  
    ...   waitlistedBy=${waitlistedby[1]}   personsAhead=0   #checkInTime=${sTime1}  
    ...   consLastVisitedDate=${date1}${SPACE}${sTime2}  
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}
    # Set Test Variable   ${servicetime}   ${resp.json()['serviceTime']}

    # ${resp}=  Get bsconf Messages
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}   200
    # ${defcheckInML_msg}=  Set Variable   ${resp.json()['checkInML_push']} 
    # ${defreshedule_checkin_msg}=  Set Variable   ${resp.json()['reshedule_provider_notify_checkin']} 
    
    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME12}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-Reschedule Waitlist-10
    [Documentation]  Provider takes checkin for a consumer and reschedules it to another queue with token
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME32}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bsname}  ${resp.json()['businessName']}
    Set Test Variable  ${pid}  ${resp.json()['id']}
    Set Test Variable  ${uniqueId}  ${resp.json()['uniqueId']}

    clear_customer   ${PUSERNAME32}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
	
    ${SERVICE1}=    generate_service_name
    ${s_id}=  Create Sample Service  ${SERVICE1}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${duration}   ${resp.json()[0]['serviceDuration']}

    ${lid}=  Create Sample Location  
    clear_queue   ${PUSERNAME32}

    ${resp}=  Get Queues
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME12} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta1}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta1}
    ${queue_name1}=  FakerLibrary.bs
    ${parallel1}=  FakerLibrary.Random Int  min=1  max=1
    ${capacity1}=  FakerLibrary.Random Int  min=5  max=10
    ${resp}=  Create Queue    ${queue_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel1}  ${capacity1}  ${lid}  ${s_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id1}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${q_id1}   name=${queue_name1}  queueState=${Qstate[0]}

    ${now}=   db.get_time_by_timezone   ${tz}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${s_id}  ${q_id1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wl_json}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wl_json[0]}

    ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  
    ...   waitlistedBy=${waitlistedby[1]}   personsAhead=0   #checkInTime=${sTime1}  
    ...   consLastVisitedDate=${date1}${SPACE}${sTime1} 
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}                 ${q_id1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}
    # Set Test Variable   ${waitingtime}   ${resp.json()['appxWaitingTime']}

    ${resp}=  Get Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp1}=   Run Keyword If  ${resp.json()['showTokenId']}==${bool[0]}   Enable Disable Token Id  ${bool[1]}
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${resp}=  Get Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  showTokenId=${bool[1]}

    ${sTime2}=  add_two   ${eTime1}  ${delta1}
    ${delta2}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime2}=  add_two   ${sTime2}  ${delta2}
    ${queue_name2}=  FakerLibrary.bs
    ${parallel2}=  FakerLibrary.Random Int  min=1  max=1
    ${capacity2}=  FakerLibrary.Random Int  min=5  max=10
    ${resp}=  Create Queue    ${queue_name2}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel2}  ${capacity2}  ${lid}  ${s_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id2}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${q_id2}   name=${queue_name2}  queueState=${Qstate[0]}

    ${resp}=  Reschedule Consumer Checkin   ${wid}  ${DAY1}  ${q_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  
    ...   waitlistedBy=${waitlistedby[1]}   personsAhead=0   #checkInTime=${sTime1}  
    ...   consLastVisitedDate=${date1}${SPACE}${sTime2} 
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}                 ${q_id2}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}


JD-TC-Reschedule Waitlist-11
    [Documentation]  Provider takes checkin for a consumer and reschedules it it to a future date when future checkin is disable
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME32}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bsname}  ${resp.json()['businessName']}
    Set Test Variable  ${pid}  ${resp.json()['id']}
    Set Test Variable  ${uniqueId}  ${resp.json()['uniqueId']}

    clear_location   ${PUSERNAME32}
    clear_service    ${PUSERNAME32}
    clear_customer   ${PUSERNAME32}
    clear_consumer_msgs  ${CUSERNAME12}
    clear_provider_msgs  ${PUSERNAME32}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
	
    ${SERVICE1}=    generate_service_name
    ${s_id}=  Create Sample Service  ${SERVICE1}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${duration}   ${resp.json()[0]['serviceDuration']}

    ${lid}=  Create Sample Location  
    clear_queue   ${PUSERNAME32}

    ${resp}=  Get Queues
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME12} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${d}=  FakerLibrary.Random Int  min=1  max=6
    ${DAY3}=  db.add_timezone_date  ${tz}  ${d} 
    ${date2}=  Convert Date  ${DAY3}  result_format=%d-%m-%Y 
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${queue_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${capacity}=  FakerLibrary.Random Int  min=5  max=10
    ${resp}=  Create Queue    ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${lid}  ${s_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${q_id}   name=${queue_name}  queueState=${Qstate[0]}

    ${now}=   db.get_time_by_timezone   ${tz}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${s_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wl_json}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wl_json[0]}

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  
    ...   waitlistedBy=${waitlistedby[1]}   personsAhead=0   #checkInTime=${sTime1}  
    ...   consLastVisitedDate=${date1}${SPACE}${sTime1} 
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}

    ${resp}=  Get Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Disable Future Checkin
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['futureDateWaitlist']}  ${bool[0]}

    ${resp}=  Reschedule Consumer Checkin   ${wid}  ${DAY3}  ${q_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY3}  waitlistStatus=${wl_status[0]}  
    ...   waitlistedBy=${waitlistedby[1]}   personsAhead=0   #checkInTime=${sTime1}  
    ...   consLastVisitedDate=${date2}${SPACE}${sTime1}  serviceTime=${sTime1}
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}


JD-TC-Reschedule Waitlist-12
    [Documentation]  Consumer takes checkin for a provider and provider reschedules it to another day.
    ...  ${SPACE} Check Communication messages also

    ${resp}=  Encrypted Provider Login  ${PUSERNAME32}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bsname}  ${resp.json()['businessName']}
    Set Test Variable  ${pid}  ${resp.json()['id']}
    Set Test Variable  ${uniqueId}  ${resp.json()['uniqueId']}

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    # ${resp1}=   Run Keyword If  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
    # Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    # Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    # ${resp}=   Get jaldeeIntegration Settings
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}  
    # Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
	
    ${SERVICE1}=    generate_service_name
    ${s_id}=  Create Sample Service  ${SERVICE1}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${duration}   ${resp.json()[0]['serviceDuration']}

    ${lid}=  Create Sample Location  
    clear_queue   ${PUSERNAME32}

    ${resp}=  Get Queues
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${DAY3}=  db.add_timezone_date  ${tz}  4
    ${date2}=  Convert Date  ${DAY3}  result_format=%d-%m-%Y
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${queue_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${capacity}=  FakerLibrary.Random Int  min=5  max=10
    ${resp}=  Create Queue    ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${lid}  ${s_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${q_id}   name=${queue_name}  queueState=${Qstate[0]}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME12}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers   ${cid}  ${pid}  ${q_id}  ${DAY1}  ${s_id}  ${cnote}  ${bool[0]}  ${self}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${pid}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME32}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME12}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()[0]['id']}

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[0]}  
    ...   waitlistedBy=${waitlistedby[0]}   personsAhead=0   #checkInTime=${sTime1}  
    ...   consLastVisitedDate=${date1}${SPACE}${sTime1} 
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}      ${jdconID}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}

    ${resp}=  Reschedule Consumer Checkin   ${wid1}  ${DAY3}  ${q_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY3}  waitlistStatus=${wl_status[0]}  
    ...   waitlistedBy=${waitlistedby[0]}   personsAhead=0   #checkInTime=${sTime1}  
    ...   consLastVisitedDate=${date2}${SPACE}${sTime1}  serviceTime=${sTime1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}      ${jdconID}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}


JD-TC-Reschedule Waitlist-UH1
    [Documentation]  Provider takes checkin for a consumer and reschedules it to another queue with another service
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME82}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bsname}  ${resp.json()['businessName']}
    Set Test Variable  ${pid}  ${resp.json()['id']}
    Set Test Variable  ${uniqueId}  ${resp.json()['uniqueId']}

    ${resp}=  Get Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp1}=   Run Keyword If  ${resp.json()['futureDateWaitlist']}==${bool[0]}   Enable Future Checkin  
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${resp}=  Get Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    reset_queue_metric  ${pid}
    clear_location   ${PUSERNAME82}
    clear_service    ${PUSERNAME82}
    clear_customer   ${PUSERNAME82}
    clear_provider_msgs  ${PUSERNAME82}
    clear_consumer_msgs  ${CUSERNAME12}
    
    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
	
    ${SERVICE1}=    generate_service_name
    ${s_id}=  Create Sample Service  ${SERVICE1}

    ${SERVICE2}=    FakerLibrary.Word
    ${s_id1}=  Create Sample Service  ${SERVICE2}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${duration}   ${resp.json()[0]['serviceDuration']}

    ${lid}=  Create Sample Location  
    clear_queue   ${PUSERNAME82}

    ${resp}=  Get Queues
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME12} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta1}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta1}
    ${queue_name1}=  FakerLibrary.bs
    ${parallel1}=  FakerLibrary.Random Int  min=1  max=1
    ${capacity1}=  FakerLibrary.Random Int  min=5  max=10
    ${resp}=  Create Queue    ${queue_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel1}  ${capacity1}  ${lid}  ${s_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id1}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${q_id1}   name=${queue_name1}  queueState=${Qstate[0]}

    ${now}=   db.get_time_by_timezone   ${tz}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${s_id}  ${q_id1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wl_json}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wl_json[0]}

    ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  
    ...   waitlistedBy=${waitlistedby[1]}   personsAhead=0   #checkInTime=${sTime1}  
    ...   consLastVisitedDate=${date1}${SPACE}${sTime1} 
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}
    # Set Test Variable   ${waitingtime}   ${resp.json()['appxWaitingTime']}

    ${sTime2}=  add_two   ${eTime1}  ${delta1}
    ${delta2}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime2}=  add_two   ${sTime2}  ${delta2}
    ${queue_name2}=  FakerLibrary.bs
    ${parallel2}=  FakerLibrary.Random Int  min=1  max=1
    ${capacity2}=  FakerLibrary.Random Int  min=5  max=10
    ${resp}=  Create Queue    ${queue_name2}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel2}  ${capacity2}  ${lid}  ${s_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id2}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${q_id2}   name=${queue_name2}  queueState=${Qstate[0]}

    ${resp}=  Reschedule Consumer Checkin   ${wid}  ${DAY1}  ${q_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422

    ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  
    ...   waitlistedBy=${waitlistedby[1]}   personsAhead=0   #checkInTime=${sTime1}  
    ...   consLastVisitedDate=${date1}${SPACE}${sTime1} 
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}
    # Set Test Variable   ${waitingtime}   ${resp.json()['appxWaitingTime']}


JD-TC-Reschedule Waitlist-UH2
    [Documentation]  Provider takes checkin for a consumer and reschedules it to another day after queue end date
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME32}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bsname}  ${resp.json()['businessName']}
    Set Test Variable  ${pid}  ${resp.json()['id']}
    Set Test Variable  ${uniqueId}  ${resp.json()['uniqueId']}

    clear_location   ${PUSERNAME32}
    clear_service    ${PUSERNAME32}
    clear_customer   ${PUSERNAME32}
    clear_consumer_msgs  ${CUSERNAME12}
    clear_provider_msgs  ${PUSERNAME32}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
	
    ${SERVICE1}=    generate_service_name
    ${s_id}=  Create Sample Service  ${SERVICE1}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${duration}   ${resp.json()[0]['serviceDuration']}

    ${lid}=  Create Sample Location  
    clear_queue   ${PUSERNAME32}

    ${resp}=  Get Queues
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME12} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${DAY3}=  db.add_timezone_date  ${tz}  14
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${queue_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${capacity}=  FakerLibrary.Random Int  min=5  max=10
    ${resp}=  Create Queue    ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${lid}  ${s_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${q_id}   name=${queue_name}  queueState=${Qstate[0]}

    ${now}=   db.get_time_by_timezone   ${tz}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${s_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wl_json}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wl_json[0]}

    ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  
    ...   waitlistedBy=${waitlistedby[1]}   personsAhead=0   #checkInTime=${sTime1}  
    ...   consLastVisitedDate=${date1}${SPACE}${sTime1} 
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}
    # Set Test Variable   ${waitingtime}   ${resp.json()['appxWaitingTime']}

    ${resp}=  Reschedule Consumer Checkin   ${wid}  ${DAY3}  ${q_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"      "${HOLIDAY_NON_WORKING_DAY}"

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  
    ...   waitlistedBy=${waitlistedby[1]}   personsAhead=0   #checkInTime=${sTime1}  
    ...   consLastVisitedDate=${date1}${SPACE}${sTime1} 
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}


JD-TC-Reschedule Waitlist-UH3
    [Documentation]  Provider takes checkin for a consumer and reschedules it to another day before queue start date
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME32}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bsname}  ${resp.json()['businessName']}
    Set Test Variable  ${pid}  ${resp.json()['id']}
    Set Test Variable  ${uniqueId}  ${resp.json()['uniqueId']}

    clear_location   ${PUSERNAME32}
    clear_service    ${PUSERNAME32}
    clear_customer   ${PUSERNAME32}
    clear_consumer_msgs  ${CUSERNAME12}
    clear_provider_msgs  ${PUSERNAME32}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
	
    ${SERVICE1}=    generate_service_name
    ${s_id}=  Create Sample Service  ${SERVICE1}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${duration}   ${resp.json()[0]['serviceDuration']}

    ${lid}=  Create Sample Location  
    clear_queue   ${PUSERNAME32}

    ${resp}=  Get Queues
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME12} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}

    ${DAY1}=  db.add_timezone_date  ${tz}  2
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${DAY3}=  db.add_timezone_date  ${tz}  1
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${queue_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${capacity}=  FakerLibrary.Random Int  min=5  max=10
    ${resp}=  Create Queue    ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${lid}  ${s_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${q_id}   name=${queue_name}  queueState=${Qstate[0]}

    ${now}=   db.get_time_by_timezone   ${tz}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${s_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wl_json}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wl_json[0]}

    ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[0]}  
    ...   waitlistedBy=${waitlistedby[1]}   personsAhead=0   #checkInTime=${sTime1}  
    ...   consLastVisitedDate=${date1}${SPACE}${sTime1} 
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}
    # Set Test Variable   ${waitingtime}   ${resp.json()['appxWaitingTime']}

    ${resp}=  Reschedule Consumer Checkin   ${wid}  ${DAY3}  ${q_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"      "${HOLIDAY_NON_WORKING_DAY}"

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[0]}  
    ...   waitlistedBy=${waitlistedby[1]}   personsAhead=0   #checkInTime=${sTime1}  
    ...   consLastVisitedDate=${date1}${SPACE}${sTime1} 
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}

JD-TC-Reschedule Waitlist-UH4
    [Documentation]  Provider takes checkin for a consumer and reschedules it to a past date
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME32}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bsname}  ${resp.json()['businessName']}
    Set Test Variable  ${pid}  ${resp.json()['id']}
    Set Test Variable  ${uniqueId}  ${resp.json()['uniqueId']}

    clear_location   ${PUSERNAME32}
    clear_service    ${PUSERNAME32}
    clear_customer   ${PUSERNAME32}
    clear_consumer_msgs  ${CUSERNAME12}
    clear_provider_msgs  ${PUSERNAME32}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
	
    ${SERVICE1}=    generate_service_name
    ${s_id}=  Create Sample Service  ${SERVICE1}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${duration}   ${resp.json()[0]['serviceDuration']}

    ${lid}=  Create Sample Location  
    clear_queue   ${PUSERNAME32}

    ${resp}=  Get Queues
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME12} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${DAY3}=  db.subtract_timezone_date  ${tz}  2
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${queue_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${capacity}=  FakerLibrary.Random Int  min=5  max=10
    ${resp}=  Create Queue    ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${lid}  ${s_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${q_id}   name=${queue_name}  queueState=${Qstate[0]}

    ${now}=   db.get_time_by_timezone   ${tz}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${s_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wl_json}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wl_json[0]}

    ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  
    ...   waitlistedBy=${waitlistedby[1]}   personsAhead=0   #checkInTime=${sTime1}  
    ...   consLastVisitedDate=${date1}${SPACE}${sTime1} 
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}
    # Set Test Variable   ${waitingtime}   ${resp.json()['appxWaitingTime']}

    ${resp}=  Reschedule Consumer Checkin   ${wid}  ${DAY3}  ${q_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"      "${WAITLIST_DATE_INCORRECT}"

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  
    ...   waitlistedBy=${waitlistedby[1]}   personsAhead=0   #checkInTime=${sTime1}  
    ...   consLastVisitedDate=${date1}${SPACE}${sTime1} 
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}


JD-TC-Reschedule Waitlist-UH5
    [Documentation]  Provider takes checkin for a consumer and reschedules it after changing waitlist status to completed
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME32}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bsname}  ${resp.json()['businessName']}
    Set Test Variable  ${pid}  ${resp.json()['id']}
    Set Test Variable  ${uniqueId}  ${resp.json()['uniqueId']}

    clear_location   ${PUSERNAME32}
    clear_service    ${PUSERNAME32}
    clear_customer   ${PUSERNAME32}
    clear_consumer_msgs  ${CUSERNAME12}
    clear_provider_msgs  ${PUSERNAME32}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
	
    ${SERVICE1}=    generate_service_name
    ${s_id}=  Create Sample Service  ${SERVICE1}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${duration}   ${resp.json()[0]['serviceDuration']}

    ${lid}=  Create Sample Location  
    clear_queue   ${PUSERNAME32}

    ${resp}=  Get Queues
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME12} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${DAY3}=  db.add_timezone_date  ${tz}  4
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${queue_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${capacity}=  FakerLibrary.Random Int  min=5  max=10
    ${resp}=  Create Queue    ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${lid}  ${s_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${q_id}   name=${queue_name}  queueState=${Qstate[0]}

    ${now}=   db.get_time_by_timezone   ${tz}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${s_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wl_json}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wl_json[0]}

    ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  
    ...   waitlistedBy=${waitlistedby[1]}   personsAhead=0   #checkInTime=${sTime1}  
    ...   consLastVisitedDate=${date1}${SPACE}${sTime1} 
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}
    # Set Test Variable   ${waitingtime}   ${resp.json()['appxWaitingTime']}

    ${resp}=  Waitlist Action  ${waitlist_actions[1]}   ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}      waitlistStatus=${wl_status[2]}

    ${resp}=  Waitlist Action  ${waitlist_actions[4]}   ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}      waitlistStatus=${wl_status[5]}

    ${CANNOT_RESCHEDULE_WL}=   Replace String  ${CANNOT_RESCHEDULE_WL}  {}  ${wl_status[5]}

    ${resp}=  Reschedule Consumer Checkin   ${wid}  ${DAY3}  ${q_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  404
    Should Be Equal As Strings  "${resp.json()}"    "${CANNOT_RESCHEDULE_WL}"


JD-TC-Reschedule Waitlist-UH6
    [Documentation]  Provider takes checkin for a consumer and reschedules it with the same details twic
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME32}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bsname}  ${resp.json()['businessName']}
    Set Test Variable  ${pid}  ${resp.json()['id']}
    Set Test Variable  ${uniqueId}  ${resp.json()['uniqueId']}

    clear_location   ${PUSERNAME32}
    clear_service    ${PUSERNAME32}
    clear_customer   ${PUSERNAME32}
    clear_consumer_msgs  ${CUSERNAME12}
    clear_provider_msgs  ${PUSERNAME32}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
	
    ${SERVICE1}=    generate_service_name
    ${s_id}=  Create Sample Service  ${SERVICE1}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${duration}   ${resp.json()[0]['serviceDuration']}

    ${lid}=  Create Sample Location  
    clear_queue   ${PUSERNAME32}

    ${resp}=  Get Queues
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME12} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${DAY3}=  db.add_timezone_date  ${tz}  2
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${queue_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${capacity}=  FakerLibrary.Random Int  min=5  max=10
    ${resp}=  Create Queue    ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${lid}  ${s_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${q_id}   name=${queue_name}  queueState=${Qstate[0]}

    ${now}=   db.get_time_by_timezone   ${tz}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${s_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wl_json}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wl_json[0]}

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  
    ...   waitlistedBy=${waitlistedby[1]}   personsAhead=0   #checkInTime=${sTime1}  
    ...   consLastVisitedDate=${date1}${SPACE}${sTime1} 
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}
    # Set Test Variable   ${waitingtime}   ${resp.json()['appxWaitingTime']}

    ${resp}=  Reschedule Consumer Checkin   ${wid}  ${DAY3}  ${q_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${date2}=  Convert Date  ${DAY3}  result_format=%d-%m-%Y

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY3}  waitlistStatus=${wl_status[0]}  
    ...   waitlistedBy=${waitlistedby[1]}   personsAhead=0   #checkInTime=${sTime1}  
    ...   consLastVisitedDate=${date2}${SPACE}${sTime1}  serviceTime=${sTime1}
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}

    ${resp}=  Reschedule Consumer Checkin   ${wid}  ${DAY3}  ${q_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"      "${WAITLIST_CUSTOMER_ALREADY_IN}"


JD-TC-Reschedule Waitlist-UH7
    [Documentation]  Provider takes checkin for a consumer and reschedules it to another provider's queue

    ${resp}=  Encrypted Provider Login  ${PUSERNAME33}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bsname}  ${resp.json()['businessName']}
    Set Test Variable  ${pid}  ${resp.json()['id']}
    Set Test Variable  ${uniqueId}  ${resp.json()['uniqueId']}

    clear_location   ${PUSERNAME33}
    clear_service    ${PUSERNAME33}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
	
    ${SERVICE1}=    generate_service_name
    ${s_id}=  Create Sample Service  ${SERVICE1}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${duration}   ${resp.json()[0]['serviceDuration']}

    ${lid}=  Create Sample Location  
    clear_queue   ${PUSERNAME33}

    ${resp}=  Get Queues
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta1}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta1}
    ${queue_name1}=  FakerLibrary.bs
    ${parallel1}=  FakerLibrary.Random Int  min=1  max=1
    ${capacity1}=  FakerLibrary.Random Int  min=5  max=10
    ${resp}=  Create Queue    ${queue_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel1}  ${capacity1}  ${lid}  ${s_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id1}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${q_id1}   name=${queue_name1}  queueState=${Qstate[0]}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME32}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bsname}  ${resp.json()['businessName']}
    Set Test Variable  ${pid}  ${resp.json()['id']}
    Set Test Variable  ${uniqueId}  ${resp.json()['uniqueId']}

    clear_location   ${PUSERNAME32}
    clear_service    ${PUSERNAME32}
    clear_customer   ${PUSERNAME32}
    clear_consumer_msgs  ${CUSERNAME12}
    clear_provider_msgs  ${PUSERNAME32}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
	
    ${SERVICE1}=    generate_service_name
    ${s_id}=  Create Sample Service  ${SERVICE1}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${duration}   ${resp.json()[0]['serviceDuration']}

    ${lid}=  Create Sample Location  
    clear_queue   ${PUSERNAME32}

    ${resp}=  Get Queues
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME12} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${DAY3}=  db.add_timezone_date  ${tz}  2
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${queue_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${capacity}=  FakerLibrary.Random Int  min=5  max=10
    ${resp}=  Create Queue    ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${lid}  ${s_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${q_id}   name=${queue_name}  queueState=${Qstate[0]}

    ${now}=   db.get_time_by_timezone   ${tz}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${s_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wl_json}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wl_json[0]}

    ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  
    ...   waitlistedBy=${waitlistedby[1]}   personsAhead=0   #checkInTime=${sTime1}  
    ...   consLastVisitedDate=${date1}${SPACE}${sTime1} 
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}
    # Set Test Variable   ${waitingtime}   ${resp.json()['appxWaitingTime']}

    ${resp}=  Reschedule Consumer Checkin   ${wid}  ${DAY1}  ${q_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"      "${NO_PERMISSION}"


JD-TC-Reschedule Waitlist-UH9
    [Documentation]  Provider takes checkin for a consumer and reschedules it with current checkin details
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME32}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bsname}  ${resp.json()['businessName']}
    Set Test Variable  ${pid}  ${resp.json()['id']}
    Set Test Variable  ${uniqueId}  ${resp.json()['uniqueId']}

    clear_location   ${PUSERNAME32}
    clear_service    ${PUSERNAME32}
    clear_customer   ${PUSERNAME32}
    clear_consumer_msgs  ${CUSERNAME12}
    clear_provider_msgs  ${PUSERNAME32}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
	
    ${SERVICE1}=    generate_service_name
    ${s_id}=  Create Sample Service  ${SERVICE1}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${duration}   ${resp.json()[0]['serviceDuration']}

    ${lid}=  Create Sample Location  
    clear_queue   ${PUSERNAME32}

    ${resp}=  Get Queues
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME12} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${DAY3}=  db.add_timezone_date  ${tz}  2
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${queue_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${capacity}=  FakerLibrary.Random Int  min=5  max=10
    ${resp}=  Create Queue    ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${lid}  ${s_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${q_id}   name=${queue_name}  queueState=${Qstate[0]}

    ${now}=   db.get_time_by_timezone   ${tz}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${s_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wl_json}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wl_json[0]}

    ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  
    ...   waitlistedBy=${waitlistedby[1]}   personsAhead=0   #checkInTime=${sTime1}  
    ...   consLastVisitedDate=${date1}${SPACE}${sTime1} 
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}
    # Set Test Variable   ${waitingtime}   ${resp.json()['appxWaitingTime']}

    ${resp}=  Reschedule Consumer Checkin   ${wid}  ${DAY1}  ${q_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"      "${WAITLIST_CUSTOMER_ALREADY_IN}"


JD-TC-Reschedule Waitlist-UH10
    [Documentation]  Provider takes checkin for a consumer and reschedules it to non existant queue
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME32}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bsname}  ${resp.json()['businessName']}
    Set Test Variable  ${pid}  ${resp.json()['id']}
    Set Test Variable  ${uniqueId}  ${resp.json()['uniqueId']}

    clear_location   ${PUSERNAME32}
    clear_service    ${PUSERNAME32}
    clear_customer   ${PUSERNAME32}
    clear_consumer_msgs  ${CUSERNAME12}
    clear_provider_msgs  ${PUSERNAME32}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
	
    ${SERVICE1}=    generate_service_name
    ${s_id}=  Create Sample Service  ${SERVICE1}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${duration}   ${resp.json()[0]['serviceDuration']}

    ${lid}=  Create Sample Location  
    clear_queue   ${PUSERNAME32}

    ${resp}=  Get Queues
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME12} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${DAY3}=  db.add_timezone_date  ${tz}  2
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${queue_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${capacity}=  FakerLibrary.Random Int  min=5  max=10
    ${resp}=  Create Queue    ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${lid}  ${s_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${q_id}   name=${queue_name}  queueState=${Qstate[0]}

    ${now}=   db.get_time_by_timezone   ${tz}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${s_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wl_json}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wl_json[0]}

    ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  
    ...   waitlistedBy=${waitlistedby[1]}   personsAhead=0   #checkInTime=${sTime1}  
    ...   consLastVisitedDate=${date1}${SPACE}${sTime1} 
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}
    # Set Test Variable   ${waitingtime}   ${resp.json()['appxWaitingTime']}

    ${invalid_qid}=  FakerLibrary.Numerify  %%%

    ${resp}=  Reschedule Consumer Checkin   ${wid}  ${DAY1}  ${invalid_qid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"      "${QUEUE_NOT_FOUND}"


JD-TC-Reschedule Waitlist-UH11
    [Documentation]  Provider takes checkin for a consumer and reschedules it to non working day
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME32}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bsname}  ${resp.json()['businessName']}
    Set Test Variable  ${pid}  ${resp.json()['id']}
    Set Test Variable  ${uniqueId}  ${resp.json()['uniqueId']}

    clear_location   ${PUSERNAME32}
    clear_service    ${PUSERNAME32}
    clear_customer   ${PUSERNAME32}
    clear_consumer_msgs  ${CUSERNAME12}
    clear_provider_msgs  ${PUSERNAME32}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
	
    ${SERVICE1}=    generate_service_name
    ${s_id}=  Create Sample Service  ${SERVICE1}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${duration}   ${resp.json()[0]['serviceDuration']}

    ${lid}=  Create Sample Location  
    clear_queue   ${PUSERNAME32}

    ${resp}=  Get Queues
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME12} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${d}=  FakerLibrary.Random Int  min=1  max=6
    ${DAY3}=  db.add_timezone_date  ${tz}  ${d} 
    ${weekday}=   get_weekday_by_date  ${DAY3}
    ${weekday}=   Convert To String  ${weekday}
    ${list}=  Create List  1  2  3  4  5  6  7
    Remove Values From List  ${list}  ${weekday}
    Log  ${list}
    ${date2}=  Convert Date  ${DAY3}  result_format=%d-%m-%Y 
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${queue_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${capacity}=  FakerLibrary.Random Int  min=5  max=10
    ${resp}=  Create Queue    ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${lid}  ${s_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${q_id}   name=${queue_name}  queueState=${Qstate[0]}

    ${now}=   db.get_time_by_timezone   ${tz}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${s_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wl_json}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wl_json[0]}

    ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  
    ...   waitlistedBy=${waitlistedby[1]}   personsAhead=0   #checkInTime=${sTime1}  
    ...   consLastVisitedDate=${date1}${SPACE}${sTime1} 
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}
    # Set Test Variable   ${waitingtime}   ${resp.json()['appxWaitingTime']}

    ${resp}=  Reschedule Consumer Checkin   ${wid}  ${DAY3}  ${q_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"      "${HOLIDAY_NON_WORKING_DAY}"


JD-TC-Reschedule Waitlist-UH12
    [Documentation]  Provider takes checkin for a consumer and reschedules it to holiday
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME32}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bsname}  ${resp.json()['businessName']}
    Set Test Variable  ${pid}  ${resp.json()['id']}
    Set Test Variable  ${uniqueId}  ${resp.json()['uniqueId']}

    clear_location   ${PUSERNAME32}
    clear_service    ${PUSERNAME32}
    clear_customer   ${PUSERNAME32}
    clear_consumer_msgs  ${CUSERNAME12}
    clear_provider_msgs  ${PUSERNAME32}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
	
    ${SERVICE1}=    generate_service_name
    ${s_id}=  Create Sample Service  ${SERVICE1}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${duration}   ${resp.json()[0]['serviceDuration']}

    ${lid}=  Create Sample Location  
    clear_queue   ${PUSERNAME32}

    ${resp}=  Get Queues
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME12} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${d}=  FakerLibrary.Random Int  min=1  max=6
    ${DAY3}=  db.add_timezone_date  ${tz}  ${d} 
    ${date2}=  Convert Date  ${DAY3}  result_format=%d-%m-%Y 
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${queue_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${capacity}=  FakerLibrary.Random Int  min=5  max=10
    ${resp}=  Create Queue    ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${lid}  ${s_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${q_id}   name=${queue_name}  queueState=${Qstate[0]}

    ${now}=   db.get_time_by_timezone   ${tz}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${s_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wl_json}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wl_json[0]}

    ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  
    ...   waitlistedBy=${waitlistedby[1]}   personsAhead=0   #checkInTime=${sTime1}  
    ...   consLastVisitedDate=${date1}${SPACE}${sTime1} 
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}
    # Set Test Variable   ${waitingtime}   ${resp.json()['appxWaitingTime']}

    ${holidayname}=   FakerLibrary.word
    # ${rand}=  FakerLibrary.Random Int  min=1  max=10
    # ${holiday_date}=  db.add_timezone_date  ${tz}  ${rand}
    ${list}=  Create List   1  2  3  4  5  6  7
    ${desc}=    FakerLibrary.word
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${DAY3}  ${DAY3}  ${EMPTY}  ${sTime1}  ${eTime1}  ${desc}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${hId}    ${resp.json()['holidayId']}

    ${resp}=   Get Holiday By Id  ${hId}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200

    ${resp}=  Reschedule Consumer Checkin   ${wid}  ${DAY3}  ${q_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"      "${HOLIDAY_NON_WORKING_DAY}"


JD-TC-Reschedule Waitlist-UH13
    [Documentation]  Provider reschedules an invalid waitlist id
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME32}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bsname}  ${resp.json()['businessName']}
    Set Test Variable  ${pid}  ${resp.json()['id']}
    Set Test Variable  ${uniqueId}  ${resp.json()['uniqueId']}

    clear_location   ${PUSERNAME32}
    clear_service    ${PUSERNAME32}
    clear_customer   ${PUSERNAME32}
    clear_consumer_msgs  ${CUSERNAME12}
    clear_provider_msgs  ${PUSERNAME32}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
	
    ${SERVICE1}=    generate_service_name
    ${s_id}=  Create Sample Service  ${SERVICE1}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${duration}   ${resp.json()[0]['serviceDuration']}

    ${lid}=  Create Sample Location  
    clear_queue   ${PUSERNAME32}

    ${resp}=  Get Queues
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME12} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${d}=  FakerLibrary.Random Int  min=1  max=6
    ${DAY3}=  db.add_timezone_date  ${tz}  ${d} 
    ${date2}=  Convert Date  ${DAY3}  result_format=%d-%m-%Y 
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${queue_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${capacity}=  FakerLibrary.Random Int  min=5  max=10
    ${resp}=  Create Queue    ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${lid}  ${s_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${q_id}   name=${queue_name}  queueState=${Qstate[0]}

    ${inval_wid}=  FakerLibrary.Numerify  %%%

    ${resp}=  Reschedule Consumer Checkin   ${inval_wid}  ${DAY3}  ${q_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  404
    Should Be Equal As Strings  "${resp.json()}"   "${INVALID_WTLST_ID}"


JD-TC-Reschedule Waitlist-UH14
    [Documentation]  Provider reschedules another provider's checkin

    ${resp}=  Encrypted Provider Login  ${PUSERNAME33}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bsname}  ${resp.json()['businessName']}
    Set Test Variable  ${pid}  ${resp.json()['id']}
    Set Test Variable  ${uniqueId}  ${resp.json()['uniqueId']}

    clear_location   ${PUSERNAME33}
    clear_service    ${PUSERNAME33}
    clear_customer   ${PUSERNAME33}
    clear_consumer_msgs  ${CUSERNAME12}
    clear_provider_msgs  ${PUSERNAME32}
    
    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
	
    ${SERVICE2}=    FakerLibrary.Word
    ${s_id1}=  Create Sample Service  ${SERVICE2}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${duration}   ${resp.json()[0]['serviceDuration']}

    ${lid1}=  Create Sample Location  
    clear_queue   ${PUSERNAME33}

    ${resp}=  Get Queues
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME12} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta1}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta1}
    ${queue_name1}=  FakerLibrary.bs
    ${parallel1}=  FakerLibrary.Random Int  min=1  max=1
    ${capacity1}=  FakerLibrary.Random Int  min=5  max=10
    ${resp}=  Create Queue    ${queue_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel1}  ${capacity1}  ${lid1}  ${s_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id1}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${q_id1}   name=${queue_name1}  queueState=${Qstate[0]}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${s_id1}  ${q_id1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wl_json}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wl_json[0]}

    ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  
    ...   waitlistedBy=${waitlistedby[1]}   personsAhead=0   #checkInTime=${sTime1}  
    ...   consLastVisitedDate=${date1}${SPACE}${sTime1} 
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME32}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bsname}  ${resp.json()['businessName']}
    Set Test Variable  ${pid}  ${resp.json()['id']}
    Set Test Variable  ${uniqueId}  ${resp.json()['uniqueId']}

    clear_location   ${PUSERNAME32}
    clear_service    ${PUSERNAME32}
    clear_customer   ${PUSERNAME32}
    clear_consumer_msgs  ${CUSERNAME12}
    clear_provider_msgs  ${PUSERNAME32}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
	
    ${SERVICE1}=    generate_service_name
    ${s_id}=  Create Sample Service  ${SERVICE1}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${duration}   ${resp.json()[0]['serviceDuration']}

    ${lid}=  Create Sample Location  
    clear_queue   ${PUSERNAME32}

    ${resp}=  Get Queues
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME12} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${DAY3}=  db.add_timezone_date  ${tz}  2
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${queue_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${capacity}=  FakerLibrary.Random Int  min=5  max=10
    ${resp}=  Create Queue    ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${lid}  ${s_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${q_id}   name=${queue_name}  queueState=${Qstate[0]}

    ${resp}=  Reschedule Consumer Checkin   ${wid}  ${DAY1}  ${q_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"      "${NO_PERMISSION}"


JD-TC-Reschedule Waitlist-UH15
    [Documentation]  Provider reschedules without login
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME32}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bsname}  ${resp.json()['businessName']}
    Set Test Variable  ${pid}  ${resp.json()['id']}
    Set Test Variable  ${uniqueId}  ${resp.json()['uniqueId']}

    clear_location   ${PUSERNAME32}
    clear_service    ${PUSERNAME32}
    clear_customer   ${PUSERNAME32}
    clear_consumer_msgs  ${CUSERNAME12}
    clear_provider_msgs  ${PUSERNAME32}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
	
    ${SERVICE1}=    generate_service_name
    ${s_id}=  Create Sample Service  ${SERVICE1}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${duration}   ${resp.json()[0]['serviceDuration']}

    ${lid}=  Create Sample Location  
    clear_queue   ${PUSERNAME32}

    ${resp}=  Get Queues
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME12} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${d}=  FakerLibrary.Random Int  min=1  max=6
    ${DAY3}=  db.add_timezone_date  ${tz}  ${d} 
    ${date2}=  Convert Date  ${DAY3}  result_format=%d-%m-%Y 
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${queue_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${capacity}=  FakerLibrary.Random Int  min=5  max=10
    ${resp}=  Create Queue    ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${lid}  ${s_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${q_id}   name=${queue_name}  queueState=${Qstate[0]}

    ${now}=   db.get_time_by_timezone   ${tz}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${s_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wl_json}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wl_json[0]}

    ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  
    ...   waitlistedBy=${waitlistedby[1]}   personsAhead=0   #checkInTime=${sTime1}  
    ...   consLastVisitedDate=${date1}${SPACE}${sTime1} 
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}
    
    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  Reschedule Consumer Checkin   ${wid}  ${DAY3}  ${q_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"      "${SESSION_EXPIRED}"


JD-TC-Reschedule Waitlist-UH16
    [Documentation]  Reschedules with consumer login
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME32}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bsname}  ${resp.json()['businessName']}
    Set Test Variable  ${pid}  ${resp.json()['id']}
    Set Test Variable  ${uniqueId}  ${resp.json()['uniqueId']}

    clear_location   ${PUSERNAME32}
    clear_service    ${PUSERNAME32}
    clear_customer   ${PUSERNAME32}
    clear_consumer_msgs  ${CUSERNAME12}
    clear_provider_msgs  ${PUSERNAME32}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
	
    ${SERVICE1}=    generate_service_name
    ${s_id}=  Create Sample Service  ${SERVICE1}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${duration}   ${resp.json()[0]['serviceDuration']}

    ${lid}=  Create Sample Location  
    clear_queue   ${PUSERNAME32}

    ${resp}=  Get Queues
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME12} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${d}=  FakerLibrary.Random Int  min=1  max=6
    ${DAY3}=  db.add_timezone_date  ${tz}  ${d} 
    ${date2}=  Convert Date  ${DAY3}  result_format=%d-%m-%Y 
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${queue_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${capacity}=  FakerLibrary.Random Int  min=5  max=10
    ${resp}=  Create Queue    ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${lid}  ${s_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${q_id}   name=${queue_name}  queueState=${Qstate[0]}

    ${now}=   db.get_time_by_timezone   ${tz}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${s_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wl_json}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wl_json[0]}

    ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  
    ...   waitlistedBy=${waitlistedby[1]}   personsAhead=0   #checkInTime=${sTime1}  
    ...   consLastVisitedDate=${date1}${SPACE}${sTime1} 
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}
    
    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME12}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Reschedule Consumer Checkin   ${wid}  ${DAY3}  ${q_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"      "${LOGIN_NO_ACCESS_FOR_URL}"


JD-TC-Reschedule Waitlist-UH17
    [Documentation]  Reschedules without waitlist id
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME32}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bsname}  ${resp.json()['businessName']}
    Set Test Variable  ${pid}  ${resp.json()['id']}
    Set Test Variable  ${uniqueId}  ${resp.json()['uniqueId']}

    clear_location   ${PUSERNAME32}
    clear_service    ${PUSERNAME32}
    clear_customer   ${PUSERNAME32}
    clear_consumer_msgs  ${CUSERNAME12}
    clear_provider_msgs  ${PUSERNAME32}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
	
    ${SERVICE1}=    generate_service_name
    ${s_id}=  Create Sample Service  ${SERVICE1}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${duration}   ${resp.json()[0]['serviceDuration']}

    ${lid}=  Create Sample Location  
    clear_queue   ${PUSERNAME32}

    ${resp}=  Get Queues
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME12} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${d}=  FakerLibrary.Random Int  min=1  max=6
    ${DAY3}=  db.add_timezone_date  ${tz}  ${d} 
    ${date2}=  Convert Date  ${DAY3}  result_format=%d-%m-%Y 
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${queue_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${capacity}=  FakerLibrary.Random Int  min=5  max=10
    ${resp}=  Create Queue    ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${lid}  ${s_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${q_id}   name=${queue_name}  queueState=${Qstate[0]}

    ${now}=   db.get_time_by_timezone   ${tz}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${s_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wl_json}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wl_json[0]}

    ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  
    ...   waitlistedBy=${waitlistedby[1]}   personsAhead=0   #checkInTime=${sTime1}  
    ...   consLastVisitedDate=${date1}${SPACE}${sTime1} 
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}

    ${resp}=  Reschedule Consumer Checkin   ${EMPTY}  ${DAY3}  ${q_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  404
    Should Be Equal As Strings  "${resp.json()}"   "${INVALID_WTLST_ID}"


JD-TC-Reschedule Waitlist-UH18
    [Documentation]  Reschedules without queue
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME32}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bsname}  ${resp.json()['businessName']}
    Set Test Variable  ${pid}  ${resp.json()['id']}
    Set Test Variable  ${uniqueId}  ${resp.json()['uniqueId']}

    clear_location   ${PUSERNAME32}
    clear_service    ${PUSERNAME32}
    clear_customer   ${PUSERNAME32}
    clear_consumer_msgs  ${CUSERNAME12}
    clear_provider_msgs  ${PUSERNAME32}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
	
    ${SERVICE1}=    generate_service_name
    ${s_id}=  Create Sample Service  ${SERVICE1}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${duration}   ${resp.json()[0]['serviceDuration']}

    ${lid}=  Create Sample Location  
    clear_queue   ${PUSERNAME32}

    ${resp}=  Get Queues
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME12} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${d}=  FakerLibrary.Random Int  min=1  max=6
    ${DAY3}=  db.add_timezone_date  ${tz}  ${d} 
    ${date2}=  Convert Date  ${DAY3}  result_format=%d-%m-%Y 
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${queue_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${capacity}=  FakerLibrary.Random Int  min=5  max=10
    ${resp}=  Create Queue    ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${lid}  ${s_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${q_id}   name=${queue_name}  queueState=${Qstate[0]}

    ${now}=   db.get_time_by_timezone   ${tz}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${s_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wl_json}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wl_json[0]}

    ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  
    ...   waitlistedBy=${waitlistedby[1]}   personsAhead=0   #checkInTime=${sTime1}  
    ...   consLastVisitedDate=${date1}${SPACE}${sTime1} 
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}

    ${resp}=  Reschedule Consumer Checkin   ${wid}  ${DAY3}  ${EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  404
    Should Be Equal As Strings  "${resp.json()}"   "${NECESSARY_FIELD_MISSING}"


JD-TC-Reschedule Waitlist-UH19
    [Documentation]  Reschedules without date
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME32}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bsname}  ${resp.json()['businessName']}
    Set Test Variable  ${pid}  ${resp.json()['id']}
    Set Test Variable  ${uniqueId}  ${resp.json()['uniqueId']}

    clear_location   ${PUSERNAME32}
    clear_service    ${PUSERNAME32}
    clear_customer   ${PUSERNAME32}
    clear_consumer_msgs  ${CUSERNAME12}
    clear_provider_msgs  ${PUSERNAME32}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
	
    ${SERVICE1}=    generate_service_name
    ${s_id}=  Create Sample Service  ${SERVICE1}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${duration}   ${resp.json()[0]['serviceDuration']}

    ${lid}=  Create Sample Location  
    clear_queue   ${PUSERNAME32}

    ${resp}=  Get Queues
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME12} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${d}=  FakerLibrary.Random Int  min=1  max=6
    ${DAY3}=  db.add_timezone_date  ${tz}  ${d} 
    ${date2}=  Convert Date  ${DAY3}  result_format=%d-%m-%Y 
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${queue_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${capacity}=  FakerLibrary.Random Int  min=5  max=10
    ${resp}=  Create Queue    ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${lid}  ${s_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${q_id}   name=${queue_name}  queueState=${Qstate[0]}

    ${now}=   db.get_time_by_timezone   ${tz}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${s_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wl_json}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wl_json[0]}

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  
    ...   waitlistedBy=${waitlistedby[1]}   personsAhead=0   #checkInTime=${sTime1}  
    ...   consLastVisitedDate=${date1}${SPACE}${sTime1} 
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}

    ${resp}=  Reschedule Consumer Checkin   ${wid}  ${EMPTY}  ${q_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  404
    Should Be Equal As Strings  "${resp.json()}"   "${NECESSARY_FIELD_MISSING}"


# JD-TC-Reschedule Waitlist-UH20
#     [Documentation]  Provider takes checkin for a consumer and reschedules it after waitlist fails.

#     ${resp}=  Consumer Login  ${CUSERNAME12}  ${PASSWORD}
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Set Test Variable  ${jdconID}   ${resp.json()['id']}
#     Set Test Variable  ${fname}   ${resp.json()['firstName']}
#     Set Test Variable  ${lname}   ${resp.json()['lastName']}
#     Set Test Variable  ${uname}   ${resp.json()['userName']}

#     ${resp}=  Consumer Logout
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
    
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME32}  ${PASSWORD}
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=   Get License UsageInfo 
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Get Business Profile
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${bsname}  ${resp.json()['businessName']}
#     Set Test Variable  ${pid}  ${resp.json()['id']}
#     Set Test Variable  ${uniqueId}  ${resp.json()['uniqueId']}

#     clear_location   ${PUSERNAME32}
#     clear_service    ${PUSERNAME32}
#     clear_customer   ${PUSERNAME32}
#     clear_consumer_msgs  ${CUSERNAME12}
#     clear_provider_msgs  ${PUSERNAME32}

#     ${resp}=   Get Service
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=    Get Locations
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
	
#     ${SERVICE1}=    generate_service_name
#     ${min_pre}=   Random Int   min=10   max=50
#     ${servicecharge}=   Random Int  min=100  max=200
#     ${s_id}=  Create Sample Service with Prepayment   ${SERVICE1}  ${min_pre}  ${servicecharge}

#     ${resp}=   Get Service
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable   ${duration}   ${resp.json()[0]['serviceDuration']}

#     ${lid}=  Create Sample Location  
#     clear_queue   ${PUSERNAME32}

#     ${resp}=  Get Queues
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  AddCustomer  ${CUSERNAME12} 
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${cid}   ${resp.json()}

#     ${DAY1}=  db.get_date_by_timezone  ${tz}
#     ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y
#     ${DAY2}=  db.add_timezone_date  ${tz}  10      
#     ${d}=  FakerLibrary.Random Int  min=1  max=6
#     ${DAY3}=  db.add_timezone_date  ${tz}  ${d} 
#     ${date2}=  Convert Date  ${DAY3}  result_format=%d-%m-%Y 
#     ${list}=  Create List  1  2  3  4  5  6  7
#     ${sTime1}=  db.get_time_by_timezone  ${tz}
#     ${delta}=  FakerLibrary.Random Int  min=10  max=60
#     ${eTime1}=  add_two   ${sTime1}  ${delta}
#     ${queue_name}=  FakerLibrary.bs
#     ${parallel}=  FakerLibrary.Random Int  min=1  max=1
#     ${capacity}=  FakerLibrary.Random Int  min=5  max=10
#     ${resp}=  Create Queue    ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${lid}  ${s_id}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${q_id}  ${resp.json()}

#     ${resp}=  Get Queue ById  ${q_id}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Response  ${resp}  id=${q_id}   name=${queue_name}  queueState=${Qstate[0]}

#     ${now}=   db.get_time_by_timezone   ${tz}

#     ${desc}=   FakerLibrary.word
#     ${resp}=  Add To Waitlist  ${cid}  ${s_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${json}=  evaluate    json.loads('''${resp.content}''')    json
#     ${wl_json}=  Get Dictionary Values  ${resp.json()}
#     Set Test Variable  ${wid}  ${wl_json[0]}

#     ${resp}=  Get Waitlist By Id  ${wid} 
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  
#     ...   waitlistedBy=${waitlistedby[1]}   personsAhead=0   #checkInTime=${sTime1}  
#     ...   consLastVisitedDate=${date1}${SPACE}${sTime1} 
#     Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
#     Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
#     Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}

#     ${desc}=   FakerLibrary.word
#     ${resp}=  Add To Waitlist  ${cid}  ${s_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${json}=  evaluate    json.loads('''${resp.content}''')    json
#     ${wl_json}=  Get Dictionary Values  ${resp.json()}
#     Set Test Variable  ${wid1}  ${wl_json[0]}

#     ${resp}=  Get Waitlist By Id  ${wid1} 
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  
#     ...   waitlistedBy=${waitlistedby[1]}   personsAhead=0   #checkInTime=${sTime1}  
#     ...   consLastVisitedDate=${date1}${SPACE}${sTime1} 
#     Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
#     Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
#     Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}

#     ${resp}=  Get Waitlist By Id  ${wid} 
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[7]}  
#     ...   waitlistedBy=${waitlistedby[1]}   personsAhead=0   #checkInTime=${sTime1}  
#     ...   consLastVisitedDate=${date1}${SPACE}${sTime1} 
#     Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
#     Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
#     Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}

#     ${resp}=  Reschedule Consumer Checkin   ${wid}  ${DAY3}  ${q_id}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  422


JD-TC-Reschedule Waitlist-UH21
    [Documentation]  Provider takes checkin for a consumer and reschedules it to a disabled queue
    ...   ${SPACE}and checks messages
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME32}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bsname}  ${resp.json()['businessName']}
    Set Test Variable  ${pid}  ${resp.json()['id']}
    Set Test Variable  ${uniqueId}  ${resp.json()['uniqueId']}

    clear_location   ${PUSERNAME32}
    clear_service    ${PUSERNAME32}
    clear_customer   ${PUSERNAME32}
    clear_consumer_msgs  ${CUSERNAME12}
    clear_provider_msgs  ${PUSERNAME32}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
	
    ${SERVICE1}=    generate_service_name
    ${s_id}=  Create Sample Service  ${SERVICE1}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${duration}   ${resp.json()[0]['serviceDuration']}

    ${lid}=  Create Sample Location  
    clear_queue   ${PUSERNAME32}

    ${resp}=  Get Queues
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME12} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta1}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta1}
    ${queue_name1}=  FakerLibrary.bs
    ${parallel1}=  FakerLibrary.Random Int  min=1  max=1
    ${capacity1}=  FakerLibrary.Random Int  min=5  max=10
    ${resp}=  Create Queue    ${queue_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel1}  ${capacity1}  ${lid}  ${s_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id1}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${q_id1}   name=${queue_name1}  queueState=${Qstate[0]}

    ${now}=   db.get_time_by_timezone   ${tz}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${s_id}  ${q_id1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wl_json}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wl_json[0]}

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  
    ...   waitlistedBy=${waitlistedby[1]}   personsAhead=0   #checkInTime=${sTime1}  
    ...   consLastVisitedDate=${date1}${SPACE}${sTime1} 
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}
    # Set Test Variable   ${waitingtime}   ${resp.json()['appxWaitingTime']}

    ${sTime2}=  add_two   ${eTime1}  ${delta1}
    ${delta2}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime2}=  add_two   ${sTime2}  ${delta2}
    ${queue_name2}=  FakerLibrary.bs
    ${parallel2}=  FakerLibrary.Random Int  min=1  max=1
    ${capacity2}=  FakerLibrary.Random Int  min=5  max=10
    ${resp}=  Create Queue    ${queue_name2}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel2}  ${capacity2}  ${lid}  ${s_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id2}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${q_id2}   name=${queue_name2}  queueState=${Qstate[0]}

    ${resp}=  Disable Queue  ${q_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Queue ById  ${q_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${q_id2}   name=${queue_name2}  queueState=${Qstate[1]}

    ${resp}=  Reschedule Consumer Checkin   ${wid}  ${DAY1}  ${q_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"      "${QUEUE_DISABLED}"


JD-TC-Reschedule Waitlist-UH22
    [Documentation]  Provider takes future checkin for a consumer and reschedules it to today when today checkin is disable
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME32}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bsname}  ${resp.json()['businessName']}
    Set Test Variable  ${pid}  ${resp.json()['id']}
    Set Test Variable  ${uniqueId}  ${resp.json()['uniqueId']}

    clear_location   ${PUSERNAME32}
    clear_service    ${PUSERNAME32}
    clear_customer   ${PUSERNAME32}
    clear_consumer_msgs  ${CUSERNAME12}
    clear_provider_msgs  ${PUSERNAME32}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
	
    ${SERVICE1}=    generate_service_name
    ${s_id}=  Create Sample Service  ${SERVICE1}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${duration}   ${resp.json()[0]['serviceDuration']}

    ${lid}=  Create Sample Location  
    clear_queue   ${PUSERNAME32}

    ${resp}=  Get Queues
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME12} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${d}=  FakerLibrary.Random Int  min=1  max=6
    ${DAY3}=  db.add_timezone_date  ${tz}  ${d} 
    ${date2}=  Convert Date  ${DAY3}  result_format=%d-%m-%Y 
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${queue_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${capacity}=  FakerLibrary.Random Int  min=5  max=10
    ${resp}=  Create Queue    ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${lid}  ${s_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${q_id}   name=${queue_name}  queueState=${Qstate[0]}

    ${now}=   db.get_time_by_timezone   ${tz}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${s_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wl_json}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wl_json[0]}

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  
    ...   waitlistedBy=${waitlistedby[1]}   personsAhead=0   #checkInTime=${sTime1}  
    ...   consLastVisitedDate=${date1}${SPACE}${sTime1} 
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}

    ${resp}=  Get Account Settings  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Waitlist Status    ${toggle[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Settings  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    waitlist=${bool[0]}

    ${resp}=  Reschedule Consumer Checkin   ${wid}  ${DAY3}  ${q_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422


JD-TC-Reschedule Waitlist-UH23
    [Documentation]  Provider takes checkin for a consumer and reschedules it after cancelling waitlist
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME32}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Waitlist Status    ${toggle[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Settings  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    waitlist=${bool[1]}

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bsname}  ${resp.json()['businessName']}
    Set Test Variable  ${pid}  ${resp.json()['id']}
    Set Test Variable  ${uniqueId}  ${resp.json()['uniqueId']}

    clear_location   ${PUSERNAME32}
    clear_service    ${PUSERNAME32}
    clear_customer   ${PUSERNAME32}
    clear_consumer_msgs  ${CUSERNAME12}
    clear_provider_msgs  ${PUSERNAME32}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
	
    ${SERVICE1}=    generate_service_name
    ${s_id}=  Create Sample Service  ${SERVICE1}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${duration}   ${resp.json()[0]['serviceDuration']}

    ${lid}=  Create Sample Location  
    clear_queue   ${PUSERNAME32}

    ${resp}=  Get Queues
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME12} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${DAY3}=  db.add_timezone_date  ${tz}  4
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${queue_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${capacity}=  FakerLibrary.Random Int  min=5  max=10
    ${resp}=  Create Queue    ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${lid}  ${s_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${q_id}   name=${queue_name}  queueState=${Qstate[0]}

    ${now}=   db.get_time_by_timezone   ${tz}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${s_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wl_json}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wl_json[0]}

    ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  
    ...   waitlistedBy=${waitlistedby[1]}   personsAhead=0   #checkInTime=${sTime1}  
    ...   consLastVisitedDate=${date1}${SPACE}${sTime1} 
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}
    # Set Test Variable   ${waitingtime}   ${resp.json()['appxWaitingTime']}

    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Waitlist Action Cancel  ${wid}  ${waitlist_cancl_reasn[1]}   ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}      waitlistStatus=${wl_status[4]}

    ${CANNOT_RESCHEDULE_WL}=   Replace String  ${CANNOT_RESCHEDULE_WL}  {}  ${wl_status[4]}

    ${resp}=  Reschedule Consumer Checkin   ${wid}  ${DAY3}  ${q_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  404
    Should Be Equal As Strings  "${resp.json()}"      "${CANNOT_RESCHEDULE_WL}"

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[4]}  
    ...   waitlistedBy=${waitlistedby[1]}  #checkInTime=${sTime1}  
    ...   consLastVisitedDate=${date1}${SPACE}${sTime1} 
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}


JD-TC-Reschedule Waitlist-UH24
    [Documentation]  Provider takes checkin for a consumer and reschedules it after changing waitlist status to started
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME32}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bsname}  ${resp.json()['businessName']}
    Set Test Variable  ${pid}  ${resp.json()['id']}
    Set Test Variable  ${uniqueId}  ${resp.json()['uniqueId']}

    clear_location   ${PUSERNAME32}
    clear_service    ${PUSERNAME32}
    clear_customer   ${PUSERNAME32}
    clear_consumer_msgs  ${CUSERNAME12}
    clear_provider_msgs  ${PUSERNAME32}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
	
    ${SERVICE1}=    generate_service_name
    ${s_id}=  Create Sample Service  ${SERVICE1}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${duration}   ${resp.json()[0]['serviceDuration']}

    ${lid}=  Create Sample Location  
    clear_queue   ${PUSERNAME32}

    ${resp}=  Get Queues
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME12} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${DAY3}=  db.add_timezone_date  ${tz}  4
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${queue_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${capacity}=  FakerLibrary.Random Int  min=5  max=10
    ${resp}=  Create Queue    ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${lid}  ${s_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${q_id}   name=${queue_name}  queueState=${Qstate[0]}

    ${now}=   db.get_time_by_timezone   ${tz}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${s_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wl_json}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wl_json[0]}

    ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  
    ...   waitlistedBy=${waitlistedby[1]}   personsAhead=0   #checkInTime=${sTime1}  
    ...   consLastVisitedDate=${date1}${SPACE}${sTime1} 
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}
    # Set Test Variable   ${waitingtime}   ${resp.json()['appxWaitingTime']}

    ${resp}=  Waitlist Action  ${waitlist_actions[1]}   ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}      waitlistStatus=${wl_status[2]}

    ${CANNOT_RESCHEDULE_WL}=   Replace String  ${CANNOT_RESCHEDULE_WL}  {}  ${wl_status[2]}

    ${resp}=  Reschedule Consumer Checkin   ${wid}  ${DAY3}  ${q_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  404
    Should Be Equal As Strings  "${resp.json()}"      "${CANNOT_RESCHEDULE_WL}"

    # ${date2}=  Convert Date  ${DAY3}  result_format=%d-%m-%Y

    # ${resp}=  Get Waitlist By Id  ${wid} 
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  
    # ...   waitlistedBy=${waitlistedby[1]}   #personsAhead=0   #checkInTime=${sTime1}  
    # ...   consLastVisitedDate=${date1}${SPACE}${sTime1} 
    # Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    # Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}

    # ${resp}=  Get bsconf Messages
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}   200
    # ${defcheckInML_msg}=  Set Variable   ${resp.json()['checkInML_push']} 
    # ${defreshedule_checkin_msg}=  Set Variable   ${resp.json()['reshedule_provider_notify_checkin']} 
    
    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME12}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-Reschedule Waitlist-UH25
    [Documentation]  Provider takes today checkin and future checkin for a consumer and reschedules the future checkin to today.
    ...  ${SPACE} Check Communication messages als
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME32}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bsname}  ${resp.json()['businessName']}
    Set Test Variable  ${pid}  ${resp.json()['id']}
    Set Test Variable  ${uniqueId}  ${resp.json()['uniqueId']}

    ${resp}=  Get Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp1}=   Run Keyword If  ${resp.json()['showTokenId']}==${bool[1]}   Enable Disable Token Id  ${bool[0]}
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${resp}=  Get Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  showTokenId=${bool[0]}

    clear_location   ${PUSERNAME32}
    clear_service    ${PUSERNAME32}
    clear_customer   ${PUSERNAME32}
    clear_consumer_msgs  ${CUSERNAME12}
    clear_provider_msgs  ${PUSERNAME32}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
	
    ${SERVICE1}=    generate_service_name
    ${s_id}=  Create Sample Service  ${SERVICE1}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${duration}   ${resp.json()[0]['serviceDuration']}

    ${lid}=  Create Sample Location  
    clear_queue   ${PUSERNAME32}

    ${resp}=  Get Queues
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME12} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${DAY3}=  db.add_timezone_date  ${tz}  4
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${queue_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${capacity}=  FakerLibrary.Random Int  min=5  max=10
    ${resp}=  Create Queue    ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${lid}  ${s_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${q_id}   name=${queue_name}  queueState=${Qstate[0]}

    ${now}=   db.get_time_by_timezone   ${tz}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${s_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wl_json}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wl_json[0]}

    ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  
    ...   waitlistedBy=${waitlistedby[1]}   personsAhead=0   #checkInTime=${sTime1}  
    ...   consLastVisitedDate=${date1}${SPACE}${sTime1} 
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}
    # Set Test Variable   ${waitingtime}   ${resp.json()['appxWaitingTime']}


    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${s_id}  ${q_id}  ${DAY3}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wl_json}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wl_json[0]}

    ${date2}=  Convert Date  ${DAY3}  result_format=%d-%m-%Y

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY3}  waitlistStatus=${wl_status[0]}  
    ...   waitlistedBy=${waitlistedby[1]}   personsAhead=0   #checkInTime=${sTime1}  
    ...   consLastVisitedDate=${date2}${SPACE}${sTime1} 
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}
    # Set Test Variable   ${waitingtime}   ${resp.json()['appxWaitingTime']}

    ${resp}=  Reschedule Consumer Checkin   ${wid}  ${DAY1}  ${q_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"      "${WAITLIST_CUSTOMER_ALREADY_IN}"


JD-TC-Reschedule Waitlist-UH26
    [Documentation]  Provider reschedules waitlist after consumer takes and cancels check-in.
    ...  ${SPACE} Check Communication messages also


    ${resp}=  Encrypted Provider Login  ${PUSERNAME32}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bsname}  ${resp.json()['businessName']}
    Set Test Variable  ${pid}  ${resp.json()['id']}
    Set Test Variable  ${uniqueId}  ${resp.json()['uniqueId']}

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    # ${resp1}=   Run Keyword If  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
    # Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    # Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    # ${resp}=   Get jaldeeIntegration Settings
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}  
    # Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    clear_location   ${PUSERNAME32}
    clear_service    ${PUSERNAME32}
    clear_customer   ${PUSERNAME32}
    clear_consumer_msgs  ${CUSERNAME12}
    clear_provider_msgs  ${PUSERNAME32}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
	
    ${SERVICE1}=    generate_service_name
    ${s_id}=  Create Sample Service  ${SERVICE1}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${duration}   ${resp.json()[0]['serviceDuration']}

    ${lid}=  Create Sample Location  
    clear_queue   ${PUSERNAME32}

    ${resp}=  Get Queues
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${DAY3}=  db.add_timezone_date  ${tz}  4
    ${date2}=  Convert Date  ${DAY3}  result_format=%d-%m-%Y
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${queue_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${capacity}=  FakerLibrary.Random Int  min=5  max=10
    ${resp}=  Create Queue    ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${lid}  ${s_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${q_id}   name=${queue_name}  queueState=${Qstate[0]}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME12}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}
    Set Test Variable  ${uname}   ${resp.json()['userName']}

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${q_id}  ${DAY1}  ${s_id}  ${cnote}  ${bool[0]}  ${self}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${pid}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[0]}   waitlistedBy=CONSUMER
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${s_id}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${jdconID}           
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['firstName']}  ${fname}  
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${q_id}

    ${resp}=  Cancel Waitlist   ${wid1}   ${pid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${pid}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[4]}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME32}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[4]}  

    ${CANNOT_RESCHEDULE_WL}=   Replace String  ${CANNOT_RESCHEDULE_WL}  {}  ${wl_status[4]}

    ${resp}=  Reschedule Consumer Checkin   ${wid1}  ${DAY3}  ${q_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  404
    Should Be Equal As Strings  "${resp.json()}"      "${CANNOT_RESCHEDULE_WL}"



JD-TC-Reschedule Waitlist-UH27
    [Documentation]  Provider reschedules waitlist after provider takes checkin and consumer cancels it.
    ...  ${SPACE} Check Communication messages also
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME32}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bsname}  ${resp.json()['businessName']}
    Set Test Variable  ${pid}  ${resp.json()['id']}
    Set Test Variable  ${uniqueId}  ${resp.json()['uniqueId']}

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    IF  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}
        ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}  
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    clear_location   ${PUSERNAME32}
    clear_service    ${PUSERNAME32}
    clear_customer   ${PUSERNAME32}
    clear_consumer_msgs  ${CUSERNAME12}
    clear_provider_msgs  ${PUSERNAME32}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
	
    ${SERVICE1}=    generate_service_name
    ${s_id}=  Create Sample Service  ${SERVICE1}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${duration}   ${resp.json()[0]['serviceDuration']}

    ${lid}=  Create Sample Location  
    clear_queue   ${PUSERNAME32}

    ${resp}=  Get Queues
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${date1}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${DAY3}=  db.add_timezone_date  ${tz}  4
    ${date2}=  Convert Date  ${DAY3}  result_format=%d-%m-%Y
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${queue_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    ${capacity}=  FakerLibrary.Random Int  min=5  max=10
    ${resp}=  Create Queue    ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${lid}  ${s_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${q_id}   name=${queue_name}  queueState=${Qstate[0]}

    ${resp}=  AddCustomer  ${CUSERNAME12} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${s_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wl_json}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wl_json[0]}

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  
    ...   waitlistedBy=${waitlistedby[1]}   personsAhead=0   #checkInTime=${sTime1}  
    ...   consLastVisitedDate=${date1}${SPACE}${sTime1} 
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME12}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get consumer Waitlist By Id   ${wid}  ${pid}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}   waitlistedBy=${waitlistedby[1]} 
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${s_id}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${jdconID}           
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['firstName']}  ${fname}  
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${q_id}

    ${resp}=  Cancel Waitlist   ${wid}   ${pid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get consumer Waitlist By Id   ${wid}  ${pid}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[4]}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME32}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[4]}

    ${CANNOT_RESCHEDULE_WL}=   Replace String  ${CANNOT_RESCHEDULE_WL}  {}  ${wl_status[4]}  
    
    ${resp}=  Reschedule Consumer Checkin   ${wid}  ${DAY3}  ${q_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  404
    Should Be Equal As Strings  "${resp.json()}"      "${CANNOT_RESCHEDULE_WL}"

    

    


    
    

    






