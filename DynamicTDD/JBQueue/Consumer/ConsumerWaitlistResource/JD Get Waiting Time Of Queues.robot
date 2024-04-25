*** Settings ***
# Suite Teardown  Run Keywords  Delete All Sessions  resetsystem_time
Suite Teardown    Delete All Sessions
Test Teardown   Delete All Sessions
Force Tags      Waitlist
Library         Collections
Library         String
Library         json
Library           FakerLibrary
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py

*** Variables ***
@{service_duration}  5  10  15   
${self}         0
${parallel}     1

*** Test Cases ***

JD-TC-Get Waiting time of queue-1
	[Documentation]  create queue with current time as start time and   end time is after one hour
    Comment  waitlist the maximum number of consumer into the queue 
    Comment  call "get waiting times of queues" url during the queue time 
    
    ${multilocdoms}=  get_mutilocation_domains
    Log  ${multilocdoms}
    Set Suite Variable  ${dom}  ${multilocdoms[0]['domain']}
    Set Suite Variable  ${sub_dom}  ${multilocdoms[0]['subdomains'][0]}
*** Comments ***
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_W}=  Evaluate  ${PUSERNAME}+5566012
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_W}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_W}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_W}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_W}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pid}  ${decrypted_data['id']}
    # Set Test Variable  ${pid}  ${resp.json()['id']}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_W}${\n}
    Set Suite Variable  ${PUSERNAME_W}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_W}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${pid_12}=  get_acc_id  ${PUSERNAME_W}
    ${cid4}=  get_id  ${CUSERNAME4}
    
    ${list}=  Create List  1  2  3  4  5  6  7
    ${ph1}=  Evaluate  ${PUSERNAME_W}+15566122
    ${ph2}=  Evaluate  ${PUSERNAME_W}+25566122
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}${PUSERNAME_W}.${test_mail}  ${views}
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
    ${24hours}    Random Element    ${bool}
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fields}=   Get subDomain level Fields  ${dom}  ${sub_dom}
    Log  ${fields.json()}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_dom}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${dom}  ${sub_dom}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    Set Test Variable  ${email_id}  ${P_Email}${PUSERNAME_W}.${test_mail}

    ${resp}=  Update Email   ${p_id}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Enable Appointment
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Waitlist
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   01s
    
    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[0]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}


    # ${resp}=  Encrypted Provider Login  ${PUSERNAME_W}  ${PASSWORD}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Business Profile
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${pkg_id}=   get_highest_license_pkg
    # ${resp}=  Change License Package  ${pkgid[0]}
    # Should Be Equal As Strings    ${resp.status_code}   200

    ${pid}=  get_acc_id  ${PUSERNAME_W}
    Set Suite Variable  ${pid} 
    ${DAY}=  db.get_date_by_timezone  ${tz}    
    Set Suite Variable  ${DAY} 
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}

    # ${sTime}=  db.get_time_by_timezone   ${tz}
    ${sTime}=  db.get_time_by_timezone  ${tz}
    ${eTime}=  add_timezone_time  ${tz}  0  30  
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${parking}    Random Element     ${parkingType} 
    ${24hours}    Random Element    ['True','False']
    ${url}=   FakerLibrary.url
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${url}  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_l1}  ${resp.json()}
    
    ${P1SERVICE1}=    FakerLibrary.word
    Set Suite Variable  ${P1SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration[0]}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_s1}  ${resp.json()}

    ${P1SERVICE2}=    FakerLibrary.word
    Set Suite Variable  ${P1SERVICE2}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE2}  ${desc}   ${service_duration[0]}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_s2}  ${resp.json()}

    ${P1SERVICE3}=    FakerLibrary.word
    Set Suite Variable   ${P1SERVICE3}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE3}  ${desc}   ${service_duration[2]}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_s3}  ${resp.json()}

    ${P1SERVICE4}=    FakerLibrary.word
    Set Suite Variable   ${P1SERVICE4}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE4}  ${desc}   ${service_duration[1]}  ${status[0]}   ${btype}    ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_s4}  ${resp.json()}

    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}  
    ${eTime1}=  add_timezone_time  ${tz}  1  00  
    ${p1queue1}=    FakerLibrary.word
    Set Suite Variable   ${p1queue1}
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  1  ${capacity}  ${p1_l1}  ${p1_s1}  ${p1_s2}  ${p1_s3}  ${p1_s4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_q1}  ${resp.json()}
    

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()[0]['id']}

    ${resp}=    Update Waitlist Settings  ${calc_mode[3]}  0  ${bool[1]}  ${bool[0]}  ${bool[1]}   ${bool[0]}   ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  View Waitlist Settings
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  calculationMode=${calc_mode[3]}  trnArndTime=0  futureDateWaitlist=${bool[1]}  maxPartySize=1

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${p1_s1}  ${p1_q1}  ${DAY}  ${cnote}  ${bool[1]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${p1_s2}  ${p1_q1}  ${DAY}  ${cnote}  ${bool[1]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${service_duration1[0]}=  Convert To Number  ${service_duration[0]}  1
    ${service_duration1[1]}=  Convert To Number  ${service_duration[1]}  1
    ${service_duration1[2]}=  Convert To Number  ${service_duration[2]}  1


    ${wait_time}=  Evaluate  ((${service_duration1[0]}+${service_duration1[0]}+${service_duration1[2]}+${service_duration1[1]})/4)/1
    ${wait_time}=  rounded   ${wait_time}
    ${wait_time}=  Convert To Integer   ${wait_time}
    ${wait_time1}=  Evaluate  ${wait_time}+${wait_time}
    ${wait_time2}=  Evaluate  ${wait_time1}+${wait_time}
    ${wait_time3}=  Evaluate  ${wait_time2}+${wait_time}
    ${wait_time4}=  Evaluate  ${wait_time3}+${wait_time}
    ${wait_time5}=  Evaluate  ${wait_time4}+${wait_time}
    ${wait_time6}=  Evaluate  ${wait_time5}+${wait_time}
    ${wait_time7}=  Evaluate  ${wait_time6}+${wait_time}
    ${wait_time8}=  Evaluate  ${wait_time7}+${wait_time}


    ${resp}=  Get Waiting Time Of queues  ${p1_l1}   ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['queueId']}  ${p1_q1}
    Should Be Equal As Strings  ${resp.json()[0]['date']}  ${DAY}
    Should Be Equal As Strings  ${resp.json()[0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()[0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()[0]['waitingTime']}  ${wait_time1}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()[0]['id']}

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid1}  ${p1_s1}  ${p1_q1}  ${DAY}  ${cnote}  ${bool[1]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid1}  ${p1_s2}  ${p1_q1}  ${DAY}  ${cnote}  ${bool[1]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}  ${resp.json()[0]['id']}

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid2}  ${p1_s1}  ${p1_q1}  ${DAY}  ${cnote}  ${bool[1]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid2}  ${p1_s2}  ${p1_q1}  ${DAY}  ${cnote}  ${bool[1]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME0}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid3}  ${resp.json()[0]['id']}

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid3}  ${p1_s1}  ${p1_q1}  ${DAY}  ${cnote}  ${bool[1]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ConsumerLogin  ${CUSERNAME0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waiting Time Of queues  ${p1_l1}   ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['queueId']}  ${p1_q1}
    Should Be Equal As Strings  ${resp.json()[0]['date']}  ${DAY}
    Should Be Equal As Strings  ${resp.json()[0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()[0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()[0]['waitingTime']}  ${wait_time6}

    ${resp}=  ConsumerLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_W}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid5}  ${resp.json()[0]['id']}

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid5}  ${p1_s2}  ${p1_q1}  ${DAY}  ${cnote}  ${bool[1]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid3}  ${p1_s2}  ${p1_q1}  ${DAY}  ${cnote}  ${bool[1]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${SERVICE_TIME_MORE_THAN_BUS_HOURS}"

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${DAY1}=  db.add_timezone_date  ${tz}  1  
    # Set Suite Variable  ${DAY1}
    ${resp}=  ConsumerLogin  ${CUSERNAME2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waiting Time Of queues  ${p1_l1}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['queueId']}  ${p1_q1}
    Should Be Equal As Strings  ${resp.json()[0]['date']}  ${DAY}
    Should Be Equal As Strings  ${resp.json()[0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()[0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()[0]['waitingTime']}  ${wait_time7}

JD-TC-Get Waiting time of queue-2
	[Documentation]  call url when queue is full
    clear_queue  ${PUSERNAME_W}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_W}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${sTime2}=  db.get_time_by_timezone   ${tz}  
    ${sTime2}=  db.get_time_by_timezone  ${tz1}  
    ${eTime2}=  add_timezone_time   1  05  ${tz1}
    Log    ${sTime2}
    Log    ${eTime2}
    ${p1queue2}=    FakerLibrary.word
    Set Suite Variable   ${p1queue2}
    ${resp}=  Create Queue  ${p1queue2}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime2}  ${eTime2}  1  3  ${p1_l1}  ${p1_s1}  ${p1_s2}  ${p1_s3}  ${p1_s4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_q2}  ${resp.json()}
    
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME0}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()[0]['id']}
    
    ${resp}=  Update Waitlist Settings  ${calc_mode[3]}  0   ${bool[1]}  ${bool[0]}  ${bool[1]}  ${bool[0]}   ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${p1_s1}  ${p1_q2}  ${DAY}  ${cnote}  ${bool[1]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200    
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid0}  ${wid[0]}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${p1_s2}  ${p1_q2}  ${DAY}  ${cnote}  ${bool[1]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid1}  ${wid[0]}

    ${resp}=  Waitlist Action  STARTED  ${wid0}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep  4s

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${p1_s3}  ${p1_q2}  ${DAY}  ${cnote}  ${bool[1]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid2}  ${wid[0]}
    
    ${service_duration1[0]}=  Convert To Number  ${service_duration[0]}  1
    ${service_duration1[1]}=  Convert To Number  ${service_duration[1]}  1
    ${service_duration1[2]}=  Convert To Number  ${service_duration[2]}  1

    ${wait_time}=  Evaluate  ((${service_duration1[0]}+${service_duration1[0]}+${service_duration1[2]}+${service_duration1[1]})/4)/1
    ${wait_time}=  rounded   ${wait_time}
    ${wait_time}=  Convert To Integer   ${wait_time}
    ${wait_time1}=  Evaluate  ${wait_time}+${wait_time}

    ${resp}=  Get Waitlist Today  queue-eq=${p1_q2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()[1]['ynwUuid']}  ${wid1}
    Should Be Equal As Strings  ${resp.json()[1]['appxWaitingTime']}  0
    Should Be Equal As Strings  ${resp.json()[2]['ynwUuid']}  ${wid2}
    Should Be Equal As Strings  ${resp.json()[2]['appxWaitingTime']}  ${wait_time}
    
    ${resp}=  Get Waiting Time Of queues  ${p1_l1}   ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['queueId']}  ${p1_q2}
    Should Be Equal As Strings  ${resp.json()[0]['date']}  ${DAY}
    Should Be Equal As Strings  ${resp.json()[0]['sTime']}  ${sTime2}
    Should Be Equal As Strings  ${resp.json()[0]['eTime']}  ${eTime2}
    Should Be Equal As Strings  ${resp.json()[0]['waitingTime']}  ${wait_time1}

JD-TC-Get Waiting time of queue-3
	[Documentation]  call url when today queue is full and tommorrow waiting time
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_W}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200  

    ${DAY1}=  db.add_timezone_date  ${tz1}  1 
    Set Suite Variable  ${DAY1}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()[0]['id']}

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${p1_s1}  ${p1_q2}  ${DAY1}  ${cnote}  ${bool[1]}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}

    ${resp}=  Get Waitlist Future  queue-eq=${p1_q2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()[0]['appxWaitingTime']}  0

    ${resp}=  Get Waiting Time Of queues  ${p1_l1}   ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['queueId']}  ${p1_q2}
    Should Be Equal As Strings  ${resp.json()[0]['date']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['waitingTime']}  8


JD-TC-Get Waiting time of queue-4
	[Documentation]  create queue and waitlist consumer for coming 2 days
    clear_queue  ${PUSERNAME_W}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_W}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.add_timezone_date  ${tz1}  1   
    ${DAY2}=  db.add_timezone_date  ${tz1}  2 
    ${DAY3}=  db.add_timezone_date  ${tz1}  3   
    Set Suite Variable  ${DAY3}
    Set Suite Variable  ${DAY2}
    ${sTime3}=  add_timezone_time  ${tz1}  2  30  
    ${eTime3}=  add_timezone_time  ${tz1}  3  0  
    ${p1queue3}=    FakerLibrary.word
    Set Suite Variable   ${p1queue3}
    ${resp}=  Create Queue  ${p1queue3}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime3}  ${eTime3}  1  1  ${p1_l1}  ${p1_s1}  ${p1_s2}  ${p1_s3}  ${p1_s4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_q3}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()[0]['id']}

    ${resp}=  Update Waitlist Settings  ${calc_mode[3]}  0  ${bool[1]}  ${bool[0]}  ${bool[1]}  ${bool[0]}   ${EMPTY}
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${p1_s1}  ${p1_q3}  ${DAY}  ${cnote}  ${bool[1]}  ${self}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid1}  ${wid[0]}

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${p1_s2}  ${p1_q3}  ${DAY1}  ${cnote}  ${bool[1]}  ${self}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid2}  ${wid[0]}

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${p1_s2}  ${p1_q3}  ${DAY2}  ${cnote}  ${bool[1]}  ${self}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid3}  ${wid[0]}

    ${resp}=  Get Waiting Time Of queues  ${p1_l1}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['queueId']}  ${p1_q3}
    Should Be Equal As Strings  ${resp.json()[0]['date']}  ${DAY3}
    Should Be Equal As Strings  ${resp.json()[0]['sTime']}  ${sTime3}
    Should Be Equal As Strings  ${resp.json()[0]['eTime']}  ${eTime3}
    Should Be Equal As Strings  ${resp.json()[0]['waitingTime']}  0 
     
JD-TC-Get Waiting time of queue-5
	[Documentation]  one consumer is cancel from the queue  ${p1_q3} and call url
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_W}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cnote}=   FakerLibrary.word
    ${resp}=  Waitlist Action Cancel  ${wid2}  ${waitlist_cancl_reasn[4]}  ${cnote}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waiting Time Of queues  ${p1_l1}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['queueId']}  ${p1_q3}
    Should Be Equal As Strings  ${resp.json()[0]['date']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['waitingTime']}  0

    ${resp}=  Waitlist Action Cancel  ${wid1}  ${waitlist_cancl_reasn[4]}  ${cnote}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Waitlist Action Cancel  ${wid3}  ${waitlist_cancl_reasn[4]}  ${cnote}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Get Waiting time of queue-6
    [Documentation]  saturday and sunday are working days in a queue
    Comment  queue f or upcoming saturday and sunday are filled
    Comment  calling url 
    clear_queue  ${PUSERNAME_W}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_W}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${pid}=  get_acc_id  ${PUSERNAME_W}
    ${cid}=  get_id  ${CUSERNAME0}
    ${d1}=  get_timezone_weekday  ${tz1}     
    ${sTime3}=  add_timezone_time   3  35  ${tz1}
    ${eTime3}=  add_timezone_time   4  0  ${tz1}
    ${list1}=  Create List  1  7
    ${p1queue4}=    FakerLibrary.word
    Set Suite Variable   ${p1queue4}
    ${resp}=  Create Queue  ${p1queue4}  ${recurringtype[1]}  ${list1}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime3}  ${eTime3}  1  1  ${p1_l1}  ${p1_s1}  ${p1_s2}  ${p1_s3}  ${p1_s4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_q4}  ${resp.json()}
    Run Keyword If  "${d1}" == "2"  Add Waitlist MonToFri  ${p1_s3}  ${p1_q4}    
    Run Keyword If  "${d1}" == "3"  Add Waitlist MonToFri  ${p1_s3}  ${p1_q4} 
    Run Keyword If  "${d1}" == "4"  Add Waitlist MonToFri  ${p1_s3}  ${p1_q4}    
    Run Keyword If  "${d1}" == "5"  Add Waitlist MonToFri  ${p1_s3}  ${p1_q4} 
    Run Keyword If  "${d1}" == "6"  Add Waitlist MonToFri  ${p1_s3}  ${p1_q4}    
    Run Keyword If  "${d1}" == "7"  Add Waitlist Saturday  ${p1_s3}  ${p1_q4}    
    Run Keyword If  "${d1}" == "1"  Add Waitlist Sunday  ${p1_s4}  ${p1_q4} 

    ${resp}=  Get Waiting Time Of queues  ${p1_l1}   ${pid}
    Should Be Equal As Strings  ${resp.status_code}  200   
    Should Be Equal As Strings  ${resp.json()[0]['queueId']}  ${p1_q4}
    Should Be Equal As Strings  ${resp.json()[0]['message']}  ${QUEUE_NOT_AVAILABLE_FOR_A_WEEEK}
    Should Be Equal As Strings  ${resp.json()[0]['waitingTime']}  0


JD-TC-Get Waiting time of queue-7
	[Documentation]  queue is not availble  for next seven days
    clear_queue  ${PUSERNAME_W}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_W}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${pid}=  get_acc_id  ${PUSERNAME_W}
    ${DAY}=  db.get_date_by_timezone  ${tz1}
    ${DAY1}=  db.add_timezone_date  ${tz1}  1  
    ${DAY2}=  db.add_timezone_date  ${tz1}  2 
    ${DAY3}=  db.add_timezone_date  ${tz1}  3   
    ${DAY4}=  db.add_timezone_date  ${tz1}  4  
    ${DAY5}=  db.add_timezone_date  ${tz1}  5 
    ${DAY6}=  db.add_timezone_date  ${tz1}  6  
    ${DAY7}=  db.add_timezone_date  ${tz1}  7 
    Set Suite Variable  ${DAY3}                                 
    ${sTime3}=  add_timezone_time  ${tz1}  4  5
    ${eTime3}=  add_timezone_time  ${tz1}  5  30
    ${p1queue5}=    FakerLibrary.word
    Set Suite Variable   ${p1queue5}
    ${resp}=  Create Queue  ${p1queue5}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime3}  ${eTime3}  1  1  ${p1_l1}  ${p1_s1}  ${p1_s2}  ${p1_s3}  ${p1_s4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_q5}  ${resp.json()}
    ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  10  ${bool[1]}  ${bool[0]}  ${bool[1]}  ${bool[0]}   ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200    
    # ${cid}=  get_id  ${CUSERNAME1}
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()[0]['id']}

    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}  10  ${bool[1]}  ${bool[0]}  ${bool[1]}  ${bool[0]}   ${EMPTY}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${p1_s1}  ${p1_q5}  ${DAY}  ${cnote}  ${bool[1]}  ${self}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${p1_s2}  ${p1_q5}  ${DAY1}  ${cnote}  ${bool[1]}  ${self}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${p1_s2}  ${p1_q5}  ${DAY2}  ${cnote}  ${bool[1]}  ${self}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${p1_s1}  ${p1_q5}  ${DAY3}  ${cnote}  ${bool[1]}  ${self}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${p1_s2}  ${p1_q5}  ${DAY4}  ${cnote}  ${bool[1]}  ${self}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${p1_s2}  ${p1_q5}  ${DAY5}  ${cnote}  ${bool[1]}  ${self}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${p1_s2}  ${p1_q5}  ${DAY6}  ${cnote}  ${bool[1]}  ${self}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${p1_s2}  ${p1_q5}  ${DAY7}  ${cnote}  ${bool[1]}  ${self}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${resp}=  Get Waiting Time Of queues  ${p1_l1}   ${pid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['queueId']}  ${p1_q5}
    Should Be Equal As Strings  ${resp.json()[0]['message']}  ${QUEUE_NOT_AVAILABLE_FOR_A_WEEEK}
    Should Be Equal As Strings  ${resp.json()[0]['waitingTime']}  0
     

JD-TC-Get Waiting time of queue-8
    [Documentation]  initil  7 day queue and update to saturday and sunday queue
    Comment  saturday and sunday are working days in a queue
    Comment  queue for upcoming saturday and sunday are filled
    Comment  calling url   
    clear_queue  ${PUSERNAME_W}  
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_W}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime3}=  add_timezone_time   0  5  ${tz1}
    ${eTime3}=  add_timezone_time  ${tz1}  0  30
    ${p1queue6}=    FakerLibrary.word
    Set Suite Variable   ${p1queue6}
    ${resp}=  Create Queue  ${p1queue6}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime3}  ${eTime3}  1  1  ${p1_l1}  ${p1_s1}  ${p1_s2}  ${p1_s3}  ${p1_s4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200    
    Set Suite Variable  ${p1_q6}  ${resp.json()}

    ${cid}=  get_id  ${CUSERNAME0}
    ${d1}=  get_timezone_weekday  ${tz1}     
    ${list1}=  Create List  1  7
    ${resp}=  Update Queue  ${p1_q6}  ${p1queue6}  ${recurringtype[1]}  ${list1}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime3}  ${eTime3}  1  1  ${EMPTY}  ${p1_s1}  ${p1_s2}  ${p1_s4}  
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}  5  ${bool[1]}  ${bool[0]}  ${bool[1]}  ${bool[0]}  ${EMPTY}
    Should Be Equal As Strings    ${resp.status_code}    200
    Run Keyword If  "${d1}" == "2"  Add Waitlist MonToFri  ${p1_s4}  ${p1_q6}    
    Run Keyword If  "${d1}" == "3"  Add Waitlist MonToFri  ${p1_s4}  ${p1_q6} 
    Run Keyword If  "${d1}" == "4"  Add Waitlist MonToFri  ${p1_s4}  ${p1_q6}    
    Run Keyword If  "${d1}" == "5"  Add Waitlist MonToFri  ${p1_s4}  ${p1_q6} 
    Run Keyword If  "${d1}" == "6"  Add Waitlist MonToFri  ${p1_s4}  ${p1_q6}    
    Run Keyword If  "${d1}" == "7"  Add Waitlist Saturday  ${p1_s4}  ${p1_q6}    
    Run Keyword If  "${d1}" == "1"  Add Waitlist Sunday  ${p1_s4}  ${p1_q6}

    ${resp}=  Get Waiting Time Of queues  ${p1_l1}   ${pid} 
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()[0]['queueId']}  ${p1_q6}
    Should Be Equal As Strings  ${resp.json()[0]['message']}  ${QUEUE_NOT_AVAILABLE_FOR_A_WEEEK}
    Should Be Equal As Strings  ${resp.json()[0]['waitingTime']}  0 

JD-TC-Get Waiting time of queue-9
	[Documentation]  consumer try to call  get waiting time of queue
    ${resp}=  Consumer Login  ${CUSERNAME0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Waiting Time Of queues  ${p1_l1}   ${pid}
    Should Be Equal As Strings  ${resp.status_code}  200
   

JD-TC-Get Waiting time of queue-UH1
	[Documentation]  get waiting time of queue calling without calling      
    ${resp}=  Get Waiting Time Of queues  ${p1_l1}   ${pid}
    
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

*** Keywords ***
Add Waitlist MonToFri
    [Arguments]  ${s}  ${q}
    ${pid}=  get_acc_id  ${PUSERNAME_W}
    # ${cid}=  get_id  ${CUSERNAME0}
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME0}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()[0]['id']}

    ${d1}=  get_timezone_weekday  ${tz1}     
    ${d}=  Evaluate  7-${d1}      
    ${Date}=  db.add_timezone_date  ${tz1}  ${d}
    ${Date1}=  db.add_timezone_date  ${tz1}  ${d+1}  
    ${cnote}=   FakerLibrary.word   
    ${resp}=  Add To Waitlist  ${cid}  ${s}  ${q}  ${Date}  ${cnote}  ${bool[1]}  ${self}  
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${s}  ${q}  ${Date1}  ${cnote}  ${bool[1]}  ${self}
    Should Be Equal As Strings  ${resp.status_code}  200 

Add Waitlist Saturday
    [Arguments]  ${s}  ${q}
    ${pid}=  get_acc_id  ${PUSERNAME_W}
    # ${cid}=  get_id  ${CUSERNAME0}
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME0}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()[0]['id']}

    ${d1}=  get_timezone_weekday  ${tz1}     
    ${d}=  Evaluate  7-${d1}      
    ${Date}=  db.add_timezone_date  ${tz1}  ${d}
    ${Date1}=  db.add_timezone_date  ${tz1}  ${d+1}
    ${Date2}=  db.add_timezone_date  ${tz1}  7
    ${Date3}=  db.add_timezone_date  ${tz1}  8
    ${Date4}=  db.get_date_by_timezone  ${tz1}
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${s}  ${q}  ${Date}  ${cnote}  ${bool[1]}  ${self}   
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${cnote}=   FakerLibrary.word
    ${resp}=   Add To Waitlist  ${cid}  ${s}  ${q}  ${Date1}  ${cnote}  ${bool[1]}  ${self}   
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${cnote}=   FakerLibrary.word
    ${resp}=   Add To Waitlist  ${cid}  ${s}  ${q}  ${Date2}  ${cnote}  ${bool[1]}  ${self} 
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${cnote}=   FakerLibrary.word
    ${resp}=   Add To Waitlist  ${cid}  ${s}  ${q}  ${Date3}  ${cnote}  ${bool[1]}  ${self} 
    Should Be Equal As Strings  ${resp.status_code}  200

Add Waitlist Sunday
    [Arguments]  ${s}  ${q} 
    ${pid}=  get_acc_id  ${PUSERNAME_W}
    # ${cid}=  get_id  ${CUSERNAME0}
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME0}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()[0]['id']}

    ${d1}=  get_timezone_weekday  ${tz}     
    ${d}=  Evaluate  7-${d1}      
    ${Date}=  db.add_timezone_date  ${tz}  ${d}  
    ${Date1}=  db.add_timezone_date  ${tz}  ${d+1}  
    ${Date4}=  db.get_date_by_timezone  ${tz} 

    ${cnote}=   FakerLibrary.word
    ${resp}=   Add To Waitlist  ${cid}  ${s}  ${q}  ${Date4}  ${cnote}  ${bool[1]}  ${self}  
    Should Be Equal As Strings  ${resp.status_code}  200  
    
    ${cnote}=   FakerLibrary.word
    ${resp}=   Add To Waitlist  ${cid}  ${s}  ${q}  ${Date}  ${cnote}  ${bool[1]}  ${self}   
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${cnote}=   FakerLibrary.word
    ${resp}=   Add To Waitlist  ${cid}  ${s}  ${q}  ${Date1}  ${cnote}  ${bool[1]}  ${self} 
    Should Be Equal As Strings  ${resp.status_code}  200    
      

