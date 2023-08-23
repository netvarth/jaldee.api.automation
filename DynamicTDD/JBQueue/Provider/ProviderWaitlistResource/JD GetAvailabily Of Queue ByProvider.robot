*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Queue
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py 

*** Variables ***
${service_duration}   5   
${ser_durtn}=   Random Int  min=2   max=10

*** Test Cases ***
JD-TC-Get Next Available Dates-1
    [Documentation]  Get next available 30 days queues
    ${f_name}=  FakerLibrary.first_name
    ${l_name}=  FakerLibrary.last_name
    ${resp}=    get_mutilocation_domains
    Log   ${resp}
    Set Test Variable   ${sector}        ${resp[0]['domain']}
    Set Test Variable   ${sub_sector}    ${resp[0]['subdomains'][0]}
    ${PUSERNAME_P}=  Evaluate  ${PUSERNAME}+91436
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME_P}${\n}   
    ${pkg_id}=   get_highest_license_pkg
    ${resp}=   Account SignUp  ${f_name}  ${l_name}  ${None}   ${sector}   ${sub_sector}  ${PUSERNAME_P}  ${pkg_id[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_P}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_P}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${PUSERNAME_P}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_P}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 
    
    ${accId}=  get_acc_id  ${PUSERNAME_P}
    Set Suite Variable  ${accId}  ${accId}

    
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    @{Views}=  Create List  self  all  customersOnly
    ${ph1}=  Evaluate  ${PUSERNAME_P}+1000000000
    ${ph2}=  Evaluate  ${PUSERNAME_P}+2000000000
    ${views}=  Evaluate  random.choice($Views)  random
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}101.${test_mail}  ${views}
    ${bs}=  FakerLibrary.bs
    ${city}=   FakerLibrary.state
    ${companySuffix}=  FakerLibrary.companySuffix
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
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${sTime}=  db.add_timezone_time  ${tz}  0  15
    Set Suite Variable   ${sTime}
    ${eTime}=  db.add_timezone_time  ${tz}   0  45
    Set Suite Variable   ${eTime}
    ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep   01s

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fields}=   Get subDomain level Fields  ${sector}  ${sub_sector}
    Log  ${fields.json()}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_sector}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${sector}  ${sub_sector}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    

    ${resp}=  Enable Waitlist
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   01s
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[0]}   
    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[0]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}   
    

    ${DAY}=  db.add_timezone_date  ${tz}  0   
    Set Suite Variable  ${DAY} 
    ${tomorrow}=  db.add_timezone_date  ${tz}  1   
    Set Suite Variable  ${tomorrow} 
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    
    
    # ${city}=   get_place
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${sTime}=  db.get_time_by_timezone  ${tz}
    ${eTime}=  db.add_timezone_time  ${tz}  0  30
    ${parking}    Random Element     ${parkingType} 
    ${24hours}    Random Element    ['True','False']
    ${url}=   FakerLibrary.url
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${url}  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${stime}  ${etime}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${loc_result} = 	Convert To Integer 	 ${resp.json()}
    Set Suite Variable  ${p1_l1}   ${loc_result}

    
    # ${city}=   FakerLibrary.state
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz2}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz2}
    ${sTime1}=  db.add_timezone_time  ${tz2}  0  30
    ${eTime1}=  db.add_timezone_time  ${tz2}  1  00
    ${parking}    Random Element     ${parkingType} 
    ${24hours}    Random Element    ['True','False']
    ${url}=   FakerLibrary.url
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${url}  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${stime}  ${etime}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${loc_result} = 	Convert To Integer 	 ${resp.json()}
    Set Suite Variable  ${p1_l2}   ${loc_result}

    ${P1SERVICE1}=    FakerLibrary.word
    Set Suite Variable  ${P1SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_s1}  ${resp.json()} 

    ${P1SERVICE2}=    FakerLibrary.word
    Set Suite Variable  ${P1SERVICE2}
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE2}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_s2}  ${resp.json()} 

    ${P1SERVICE3}=    FakerLibrary.word
    Set Suite Variable   ${P1SERVICE3}
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE3}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_s3}  ${resp.json()}

    ${sTime1}=  db.add_timezone_time  ${tz}  1  00
    ${eTime1}=  db.add_timezone_time  ${tz}  1  30
    ${p1queue1}=    FakerLibrary.word
    Set Suite Variable   ${p1queue1}
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${p1_l1}  ${p1_s1} 
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_q1}  ${resp.json()}

    ${accId}=  get_acc_id  ${PUSERNAME_P}
    Set Suite Variable  ${accId}  ${accId}


    ${resp}=  Availability Of Queue By Consumer  ${p1_l1}  ${p1_s1}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  30
    FOR  ${i}  IN RANGE   ${len}
        ${DAY}=  db.add_timezone_date  ${tz}   ${i} 
        Should Be Equal As Strings  ${resp.json()[${i}]['date']}            ${DAY}
        Should Be Equal As Strings  ${resp.json()[${i}]['serviceTime']}     ${sTime1}
        Should Be Equal As Strings  ${resp.json()[${i}]['queueStartTime']}  ${sTime1} 
        Should Be Equal As Strings  ${resp.json()[${i}]['queueEndTime']}    ${eTime1}
        Should Be Equal As Strings  ${resp.json()[${i}]['isAvailable']}     ${bool[1]}    
        Should Be Equal As Strings  ${resp.json()[${i}]['queueId']}         ${p1_q1} 
    END
        

JD-TC-Get Next Available Dates-2
    [Documentation]  Get next available queues using Queue have start date is tomarrow
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_P}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 
    
    ${sTime2}=  db.add_timezone_time  ${tz2}  1  30
    ${eTime2}=  db.add_timezone_time  ${tz2}  2  00
    ${p1queue2}=    FakerLibrary.word
    Set Suite Variable   ${p1queue2}
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Queue  ${p1queue2}  ${recurringtype[1]}  ${list}  ${tomorrow}  ${EMPTY}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel}  ${capacity}  ${p1_l2}   ${p1_s2} 
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_q2}  ${resp.json()} 


    ${resp}=  Availability Of Queue By Consumer  ${p1_l2}  ${p1_s2}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
        ${DAY}=  db.add_timezone_date  ${tz2}   1
        Run Keyword IF  '${resp.json()[${i}]['date']}' == '${DAY}' 
            ...     Run Keywords 
            ...     Should Be Equal As Strings  ${resp.json()[${i}]['date']}                 ${DAY}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['serviceTime']}     ${sTime2}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['queueStartTime']}  ${sTime2} 
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['queueEndTime']}    ${eTime2}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['isAvailable']}     ${bool[1]}    
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['queueId']}         ${p1_q2}
 
    END
        
JD-TC-Get Next Available Dates-3
    [Documentation]  Get next available queues using Queue have specific end date
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_P}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 
    
    ${endday}=  db.add_timezone_date  ${tz2}  5   
    Set Suite Variable  ${endday} 
    ${sTime3}=  db.add_timezone_time  ${tz2}  2  00
    Set Suite Variable   ${sTime3}
    ${eTime3}=  db.add_timezone_time  ${tz2}  2  30
    Set Suite Variable   ${eTime3}
    ${p1queue3}=    FakerLibrary.word
    Set Suite Variable   ${p1queue3}
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Queue  ${p1queue3}  ${recurringtype[1]}  ${list}  ${DAY}  ${endday}  ${EMPTY}  ${sTime3}  ${eTime3}  ${parallel}  ${capacity}  ${p1_l2}  ${p1_s3} 
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_q3}  ${resp.json()}


    ${resp}=  Availability Of Queue By Consumer  ${p1_l2}  ${p1_s3}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
        ${DAY}=  db.add_timezone_date  ${tz2}   ${i} 
        Should Be Equal As Strings  ${resp.json()[${i}]['date']}            ${DAY}
        Should Be Equal As Strings  ${resp.json()[${i}]['serviceTime']}     ${sTime3}
        Should Be Equal As Strings  ${resp.json()[${i}]['queueStartTime']}  ${sTime3} 
        Should Be Equal As Strings  ${resp.json()[${i}]['queueEndTime']}    ${eTime3}
        Should Be Equal As Strings  ${resp.json()[${i}]['isAvailable']}     ${bool[1]}    
        Should Be Equal As Strings  ${resp.json()[${i}]['queueId']}         ${p1_q3} 
    END

JD-TC-Get Next Available Dates-4
    [Documentation]  Get next available queues with  create a holiday
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_P}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
 
    ${sTime4}=  db.add_timezone_time  ${tz}  2  30
    ${eTime4}=  db.add_timezone_time  ${tz}  3  00
    ${p1queue4}=    FakerLibrary.word
    Set Suite Variable   ${p1queue4}
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Queue  ${p1queue4}  ${recurringtype[1]}  ${list}  ${DAY}  ${endday}  ${EMPTY}  ${sTime4}  ${eTime4}  ${parallel}  ${capacity}  ${p1_l1}   ${p1_s3} 
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_q4}  ${resp.json()}

    ${holiday}=  db.add_timezone_date  ${tz}  4   
    Set Suite Variable  ${holiday} 
    ${holidayname}=   FakerLibrary.word
    ${sTime5}=  db.add_timezone_time  ${tz}  2  30
    ${list}=  Create List   1  2  3  4  5  6  7
    ${desc}=    FakerLibrary.word
    # ${resp}=  Create Holiday  ${holiday}  ${holidayname}  ${sTime5}  ${eTime4}
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${holiday}  ${holiday}  ${EMPTY}  ${sTime5}  ${eTime4}  ${desc}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${hId}    ${resp.json()['holidayId']}
    

    ${resp}=  Availability Of Queue By Consumer  ${p1_l1}  ${p1_s3}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
        ${DAY}=  db.add_timezone_date  ${tz}   ${i} 
        Run Keyword IF  '${resp.json()[${i}]['isAvailable']}' != '${bool[0]}'   
                ...     Run Keywords 
                ...     Should Be Equal As Strings  ${resp.json()[${i}]['date']}                 ${DAY}
                ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['serviceTime']}     ${sTime4}
                ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['queueStartTime']}  ${sTime4} 
                ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['queueEndTime']}    ${eTime4}
                # ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['isAvailable']}     ${bool[1]}    
                ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['queueId']}         ${p1_q4}

                ...     ELSE    
                ...     Run Keywords
                ...     Should Be Equal As Strings  ${resp.json()[${i}]['date']}                 ${DAY}
                ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['reason']}          Holiday
                ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['isAvailable']}     ${bool[0]}    
                ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['queueId']}         ${p1_q4} 
    END

    ${resp}=   Delete Holiday  ${hId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
   
JD-TC-Get Next Available Dates-5
	[Documentation]  same service in diffrent queue
    clear_queue  ${PUSERNAME_P}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_P}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${sTime6}=  db.add_timezone_time  ${tz}  3  30
    Set Suite Variable  ${sTime6}
    ${eTime6}=  db.add_timezone_time  ${tz}  4  30
    Set Suite Variable  ${eTime6}
    ${p1queue6}=    FakerLibrary.word
    Set Suite Variable   ${p1queue6}
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Queue  ${p1queue6}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime6}  ${eTime6}  ${parallel}  ${capacity}  ${p1_l1}  ${p1_s1} 
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_q6}  ${resp.json()}

    ${sTime7}=  db.add_timezone_time  ${tz}  4  30
    Set Suite Variable  ${sTime7}
    ${eTime7}=  db.add_timezone_time  ${tz}  5  30
    Set Suite Variable  ${eTime7}
    ${p1queue7}=    FakerLibrary.word
    Set Suite Variable   ${p1queue7}
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Queue  ${p1queue7}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime7}  ${eTime7}  ${parallel}  ${capacity}  ${p1_l1}  ${p1_s1} 
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_q7}  ${resp.json()}

    ${resp}=  Consumer Login  ${CUSERNAME8}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Queue By Location and service  ${p1_l1}  ${p1_s1}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len2}=  Get Length  ${resp.json()}
    # Set Suite Variable   ${len2}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_P}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
 

    ${resp}=  Availability Of Queue By Consumer  ${p1_l1}  ${p1_s1}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len0}=  Get Length  ${resp.json()}
    # Set Suite Variable   ${len0}

    ${flag}=  Set Variable  ${0}
    ${j}=  Set Variable  ${0}
    FOR  ${i}  IN RANGE   ${len0}
        # ${DAY}=  db.add_timezone_date  ${tz}   ${i}  
        ${flag}=  Evaluate  ${flag}+1
        # ${resp}=   verify6  ${resp}  ${value}  ${len1}  
        Run Keyword IF  '${resp.json()[${i}]['queueId']}' == '${p1_q6}'  
                ...     Run Keywords 
                ...     Should Be Equal As Strings  ${resp.json()[${i}]['date']}                 ${DAY}
                ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['serviceTime']}     ${sTime6}
                ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['queueStartTime']}  ${sTime6} 
                ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['queueEndTime']}    ${eTime6}
                ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['isAvailable']}     ${bool[1]}    
                ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['queueId']}         ${p1_q6}

                ...     ELSE IF     '${resp.json()[${i}]['queueId']}' == '${p1_q7}'   
                ...     Run Keywords
                ...     Should Be Equal As Strings  ${resp.json()[${i}]['date']}                 ${DAY}
                ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['serviceTime']}     ${sTime7}
                ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['queueStartTime']}  ${sTime7} 
                ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['queueEndTime']}    ${eTime7}
                ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['isAvailable']}     ${bool[1]}    
                ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['queueId']}         ${p1_q7} 

        ${j}=  Run Keyword If  '${flag}' >= '${len2}'  Evaluate  ${j}+1
        ...     ELSE  Set Variable  ${j}
        ${DAY}=  Run Keyword If  '${flag}' >= '${len2}'  db.add_timezone_date  ${tz}   ${j}
        ...     ELSE  Set Variable  ${DAY}
        ${flag}=  Run Keyword If  '${flag}' >= '${len2}'  Set Variable  ${0}
        ...     ELSE  Set Variable  ${flag}
   
    END

  
JD-TC-Get Next Available Dates-6
	[Documentation]  same service in diffrent location
    # clear_queue  ${PUSERNAME_P}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_P}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
 
    ${sTime8}=  db.add_timezone_time  ${tz}  2  30
    Set Suite Variable   ${sTime8}
    ${eTime8}=  db.add_timezone_time  ${tz}  3  00
    Set Suite Variable   ${eTime8}
    ${p1queue8}=    FakerLibrary.word
    Set Suite Variable   ${p1queue8}
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Queue  ${p1queue8}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime8}  ${eTime8}  ${parallel}  ${capacity}  ${p1_l1}  ${p1_s1} 
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_q8}  ${resp.json()}

    ${sTime9}=  db.add_timezone_time  ${tz2}  3  00
    ${eTime9}=  db.add_timezone_time  ${tz2}  3  30
    ${p1queue9}=    FakerLibrary.word
    Set Suite Variable   ${p1queue9}
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Queue  ${p1queue9}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime9}  ${eTime9}  ${parallel}  ${capacity}  ${p1_l2}  ${p1_s1} 
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_q9}  ${resp.json()}

    ${resp}=  Consumer Login  ${CUSERNAME8}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Queue By Location and service  ${p1_l1}  ${p1_s1}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${len1}=  Get Length  ${resp.json()}  
    # Set Suite Variable   ${len1}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_P}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
 
    ${resp}=  Availability Of Queue By Consumer  ${p1_l1}  ${p1_s1}   ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    # Set Suite Variable   ${len}
    ${flag}=  Set Variable  ${0}
    ${j}=  Set Variable  ${0}
    FOR  ${i}  IN RANGE   ${len}
        # ${DAY}=  db.add_timezone_date  ${tz}   ${i}  
        ${flag}=  Evaluate  ${flag}+1
        # ${resp}=   verify6  ${resp}  ${value}  ${len1}  
        Run Keyword IF  '${resp.json()[${i}]['queueId']}' == '${p1_q6}'  
                ...     Run Keywords 
                ...     Should Be Equal As Strings  ${resp.json()[${i}]['date']}                 ${DAY}
                ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['serviceTime']}     ${sTime6}
                ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['queueStartTime']}  ${sTime6} 
                ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['queueEndTime']}    ${eTime6}
                ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['isAvailable']}     ${bool[1]}    
                ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['queueId']}         ${p1_q6}

                ...     ELSE IF     '${resp.json()[${i}]['queueId']}' == '${p1_q7}'   
                ...     Run Keywords
                ...     Should Be Equal As Strings  ${resp.json()[${i}]['date']}                 ${DAY}
                ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['serviceTime']}     ${sTime7}
                ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['queueStartTime']}  ${sTime7} 
                ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['queueEndTime']}    ${eTime7}
                ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['isAvailable']}     ${bool[1]}    
                ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['queueId']}         ${p1_q7} 

                ...     ELSE IF     '${resp.json()[${i}]['queueId']}' == '${p1_q9}'   
                ...     Run Keywords
                ...     Should Be Equal As Strings  ${resp.json()[${i}]['date']}                 ${DAY}
                ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['serviceTime']}     ${sTime8}
                ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['queueStartTime']}  ${sTime8} 
                ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['queueEndTime']}    ${eTime8}
                ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['isAvailable']}     ${bool[1]}    
                ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['queueId']}

        ${j}=  Run Keyword If  '${flag}' >= '${len1}'  Evaluate  ${j}+1
        ...     ELSE  Set Variable  ${j}
        ${DAY}=  Run Keyword If  '${flag}' >= '${len1}'  db.add_timezone_date  ${tz}   ${j}
        ...     ELSE  Set Variable  ${DAY}
        ${flag}=  Run Keyword If  '${flag}' >= '${len1}'  Set Variable  ${0}
        ...     ELSE  Set Variable  ${flag}
   
    END

JD-TC-Get Next Available Dates-7
	[Documentation]  Avalable queue in a branch user
    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Suite Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Suite Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
    ${firstname_B}=  FakerLibrary.first_name
    ${lastname_B}=  FakerLibrary.last_name
    ${MUSERNAME_L}=  Evaluate  ${MUSERNAME}+4053143334
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname_B}  ${lastname_B}  ${None}  ${domains}  ${sub_domains}  ${MUSERNAME_L}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${MUSERNAME_L}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${MUSERNAME_L}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_L}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${MUSERNAME_L}${\n}
    Set Suite Variable  ${MUSERNAME_L}
    
    ${accid1}=  get_acc_id  ${MUSERNAME_L} 
    Set Suite Variable    ${accid1}

    
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${ph1}=  Evaluate  ${MUSERNAME_L}+1000000000
    ${ph2}=  Evaluate  ${MUSERNAME_L}+2000000000
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}183.${test_mail}  ${views}
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
    # ${DAY2}=  db.get_date_by_timezone  ${tz}
    # Set Suite Variable  ${DAY2}  ${DAY2}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${sTime}=  db.add_timezone_time  ${tz}  0  15
    Set Suite Variable   ${sTime}
    ${eTime}=  db.add_timezone_time  ${tz}   0  45
    Set Suite Variable   ${eTime}
    ${resp}=  Update Business Profile with schedule   ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

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

    ${resp}=  Enable Waitlist
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   01s
    
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[0]}   
    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[0]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${ulid}   ${resp.json()[0]['id']}
    Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    
    sleep  2s
    ${resp}=  Get Departments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}

    ${dep_name1}=  FakerLibrary.bs
    ${dep_code1}=   Random Int  min=100   max=999
    ${dep_desc}=   FakerLibrary.word  
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id1}  ${resp.json()}

    ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+346673
    clear_users  ${PUSERNAME_U1}
    ${firstname2}=  FakerLibrary.name
    ${lastname2}=  FakerLibrary.last_name
    ${dob2}=  FakerLibrary.Date
    ${pin}=  get_pincode
    
    ${resp}=  Create User  ${firstname2}  ${lastname2}  ${dob2}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${countryCodes[0]}  ${PUSERNAME_U1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id}  ${resp.json()}
    
    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${p1_id}   ${resp.json()[0]['id']}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime_1}=  db.add_timezone_time  ${tz}  0  15
    Set Suite Variable   ${sTime_1}
    ${eTime_1}=  db.add_timezone_time  ${tz}  4  15
    Set Suite Variable   ${eTime_1}


    ${SERVICE1}=    FakerLibrary.word
    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=05  max=10
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    Set Suite Variable  ${amt}
    ${resp}=  Create Service For User  ${SERVICE1}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${us_id}  ${resp.json()}
    ${queue_name}=  FakerLibrary.bs
    Set Suite Variable  ${queue_name}
    ${resp}=  Create Queue For User  ${queue_name}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime_1}  ${eTime_1}  1  5  ${ulid}  ${u_id}  ${us_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${uq_id}  ${resp.json()}

    ${resp}=  Availability Of Queue By Consumer  ${ulid}  ${us_id}  ${accid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()} 
    FOR  ${i}  IN RANGE   ${len}
        ${DAY1}=  db.add_timezone_date  ${tz}   ${i} 
        Should Be Equal As Strings  ${resp.json()[${i}]['date']}            ${DAY1}
        Should Be Equal As Strings  ${resp.json()[${i}]['serviceTime']}     ${sTime_1}
        Should Be Equal As Strings  ${resp.json()[${i}]['queueStartTime']}  ${sTime_1} 
        Should Be Equal As Strings  ${resp.json()[${i}]['queueEndTime']}    ${eTime_1}
        Should Be Equal As Strings  ${resp.json()[${i}]['isAvailable']}     ${bool[1]}    
        Should Be Equal As Strings  ${resp.json()[${i}]['queueId']}         ${uq_id} 
    END


JD-TC-Get Next Available Dates-8 
	[Documentation]  create a vacation
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_L}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${ulid}   ${resp.json()[0]['id']}
    Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    
    ${start_time}=  db.add_timezone_time  ${tz}  0  15
    Set Suite Variable   ${start_time}
    ${end_time}=    db.add_timezone_time  ${tz}   3  00 
    Set Suite Variable    ${end_time}
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable    ${CUR_DAY}
    ${desc}=    FakerLibrary.name
    Set Test Variable      ${desc}
    ${list}=  Create List  1  2  3  4  5  6  7
   
    ${resp}=  Create Vacation    ${desc}  ${p1_id}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${CUR_DAY}  0  ${start_time}  ${end_time} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${v1_id}  ${resp.json()}
    sleep  2s    
    
   #  ${resp}=    Get Service
   # Log   ${resp.json()}
   # Should Be Equal As Strings  ${resp.status_code}  200
   # Set Suite Variable   ${us_id}   ${resp.json()[0]['id']}


    ${resp}=   Get Vacation  ${p1_id}
    Log  ${resp.json()}
    Set Suite Variable  ${v_id}  ${resp.json()[0]['id']}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}   0  id=${v_id}    description=${desc}       
    
    ${resp}=  Availability Of Queue By Consumer  ${ulid}  ${us_id}    ${accid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()} 
    ${len}=   Evaluate   ${len}-1  
    Verify Response List   ${resp}   0  date=${CUR_DAY}  serviceTime=${start_time}  queueStartTime=${sTime_1}  queueEndTime=${eTime_1}  isAvailable=${bool[1]}  queueId=${uq_id} 
    FOR  ${i}  IN RANGE   ${len}
        ${DAY1}=  db.add_timezone_date  ${tz}   1
        Run Keyword IF  '${resp.json()[${i}]['date']}' == '${DAY1}' 
            ...     Run Keywords 
            ...     Should Be Equal As Strings  ${resp.json()[${i}]['date']}                 ${DAY1}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['serviceTime']}     ${sTime_1}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['queueStartTime']}  ${sTime_1} 
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['queueEndTime']}    ${eTime_1}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['isAvailable']}     ${bool[1]}    
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['queueId']}         ${uq_id}
 
    END

    ${resp}=  Delete Vacation  ${v_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-Get Next Available Dates-UH1
	[Documentation]  provider Disable department
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_L}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${PUSERNAME_U2}=  Evaluate  ${PUSERNAME}+3467635
    clear_users  ${PUSERNAME_U2}
    ${firstname3}=  FakerLibrary.name
    ${lastname3}=  FakerLibrary.last_name
    ${dob3}=  FakerLibrary.Date
    ${pin}=  get_pincode
    
    ${resp}=  Create User  ${firstname3}  ${lastname3}  ${dob3}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U2}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U2}  ${dep_id1}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${PUSERNAME_U2}  ${countryCodes[0]}  ${PUSERNAME_U2}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id1}  ${resp.json()}

    ${SERVICE2}=    FakerLibrary.word
    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=05  max=10
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service For User  ${SERVICE2}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id1}  ${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${us_id1}  ${resp.json()}

    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10
    ${sTime_2}=  db.add_timezone_time  ${tz}  0  30
    Set Test Variable   ${sTime_2}
    ${eTime_2}=  db.add_timezone_time  ${tz}  4  15
    Set Test Variable   ${eTime_2}

    ${queue_name1}=  FakerLibrary.bs
    Set Test Variable  ${queue_name1}
    ${resp}=  Create Queue For User  ${queue_name1}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime_2}  ${eTime_2}  1  5  ${ulid}  ${u_id1}  ${us_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${uq_id1}  ${resp.json()}

    ${resp}=  Availability Of Queue By Consumer  ${ulid}  ${us_id1}  ${accid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}   0  date=${DAY1}  serviceTime=${sTime_2}  queueStartTime=${sTime_2}  queueEndTime=${eTime_2}  isAvailable=${bool[1]}  queueId=${uq_id1} 
    
    ${resp}=  Disable Department  ${dep_id1} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Availability Of Queue By Consumer  ${ulid}  ${us_id1}  ${accid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${INVALID_SERVICE}"

    ${resp}=  Enable Department  ${dep_id1} 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Enable service   ${us_id1} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Availability Of Queue By Consumer  ${ulid}  ${us_id1}  ${accid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}   0  date=${DAY1}  serviceTime=${sTime_2}  queueStartTime=${sTime_2}  queueEndTime=${eTime_2}  isAvailable=${bool[1]}  queueId=${uq_id1} 

JD-TC-Get Next Available Dates-UH2
	[Documentation]  INPUT Disable SERVICE id
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_P}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
 
    ${RESP}=  Disable service  ${p1_s1} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Availability Of Queue By Consumer  ${p1_l1}  ${p1_s1}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${INVALID_SERVICE}"

    ${resp}=  Enable service  ${p1_s1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Get Next Available Dates-UH3
	[Documentation]  INPUT Disable Location id
  
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_P}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${RESP}=  Disable Location  ${p1_l1} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Availability Of Queue By Consumer  ${p1_l1}  ${p1_s1}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422 
    Should Be Equal As Strings  "${resp.json()}"  "${LOCATION_DISABLED}"  

    ${RESP}=  Enable Location  ${p1_l1} 
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Get Next Available Dates-UH4
	[Documentation]  queue have no service
  
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_P}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${sTime}=  db.add_timezone_time  ${tz}  7  30
    ${eTime}=  db.add_timezone_time  ${tz}  8  00
    ${p1queue}=    FakerLibrary.word
    Set Suite Variable   ${p1queue}
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Queue  ${p1queue}  ${recurringtype[1]}  ${list}  ${DAY}  ${endday}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${p1_l1}   ${p1_s3} 
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_q}  ${resp.json()} 

    ${RESP}=  Disable Queue  ${p1_q} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Availability Of Queue By Consumer  ${p1_l1}  ${p1_s3}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()}   []  

JD-TC-Get Next Available Dates-UH5
	[Documentation]  location have no queue
  
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_P}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    # ${city}=   FakerLibrary.state
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz3}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz3}
    ${parking}    Random Element     ${parkingType} 
    ${24hours}    Random Element    ['True','False']
    ${url}=   FakerLibrary.url
    ${sTime}=  db.get_time_by_timezone  ${tz3}
    ${eTime}=  db.add_timezone_time  ${tz3}  4  30
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${url}  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${stime}  ${etime}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${loc_result} = 	Convert To Integer 	 ${resp.json()}
    Set Suite Variable  ${p1_l3}   ${loc_result}

    ${resp}=  Availability Of Queue By Consumer  ${p1_l3}  ${p1_s3}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()}   []  


JD-TC-Get Next Available Dates-UH6
	[Documentation]  provider disable queue
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_P}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${s_Time}=  db.add_timezone_time  ${tz3}  2  30
    Set Suite Variable   ${s_Time}
    ${e_Time}=  db.add_timezone_time  ${tz3}  5  00
    Set Suite Variable    ${e_Time}
    ${p1queue}=    FakerLibrary.word
    Set Suite Variable   ${p1queue}
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Queue  ${p1queue}  ${recurringtype[1]}  ${list}  ${DAY}  ${endday}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${p1_l3}   ${p1_s3} 
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_q0}  ${resp.json()} 

    ${resp}=  Disable Queue  ${p1_q0}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   02s
   
    ${resp}=  Availability Of Queue By Consumer  ${p1_l3}  ${p1_s3}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()}   []  

    ${resp}=  Enable Queue  ${p1_q0}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   02s

    ${resp}=  Availability Of Queue By Consumer  ${p1_l3}  ${p1_s3}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${len}=  Get Length  ${resp.json()} 
    FOR  ${i}  IN RANGE   ${len}
        ${DAY}=  db.add_timezone_date  ${tz}   ${i} 
        Should Be Equal As Strings  ${resp.json()[${i}]['date']}            ${DAY}
        Should Be Equal As Strings  ${resp.json()[${i}]['serviceTime']}     ${s_Time}
        Should Be Equal As Strings  ${resp.json()[${i}]['queueStartTime']}  ${s_Time} 
        Should Be Equal As Strings  ${resp.json()[${i}]['queueEndTime']}    ${e_Time}
        Should Be Equal As Strings  ${resp.json()[${i}]['isAvailable']}     ${bool[1]}    
        Should Be Equal As Strings  ${resp.json()[${i}]['queueId']}         ${p1_q0} 
    END
    

JD-TC-Get Next Available Dates-UH7
	[Documentation]  provider disable waitlist
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_P}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Disable Waitlist
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   02s

    ${resp}=  Availability Of Queue By Consumer  ${p1_l3}  ${p1_s3}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()}   [] 

    ${resp}=  Enable Waitlist
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   01s


JD-TC-Get Next Available Dates-UH8
	[Documentation]  get availability using another provider service and location
    ${resp}=  Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${plid}   ${resp.json()[0]['id']}
    ${resp}=    Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p_s1}   ${resp.json()[0]['id']}

    # ${P1SERVICE1}=    FakerLibrary.word
    # Set Test Variable  ${P1SERVICE1}
    # ${desc}=   FakerLibrary.sentence
    # ${servicecharge}=   Random Int  min=100  max=500
    # ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${p_s1}  ${resp.json()} 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_P}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Availability Of Queue By Consumer  ${plid}    ${p_s1}    ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   404
    Should Be Equal As Strings  ${resp.json()}   ${LOCATION_NOT_FOUND}

JD-TC-Get Next Available Dates-UH9
	[Documentation]  Invalid location and service id

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_P}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Availability Of Queue By Consumer  00  00  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   404
    Should Be Equal As Strings  "${resp.json()}"   "${LOCATION_NOT_FOUND}"

JD-TC-Get Next Available Dates-UH10
	[Documentation]  provider disable online chekin and try to take a waitlist
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_P}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Disable Online Checkin
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   02s

    ${resp}=  Availability Of Queue By Consumer  ${p1_l3}  ${p1_s3}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${CR_day}=  db.add_timezone_date  ${tz3}   0
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
        ${DAY}=  db.add_timezone_date  ${tz3}   1
        Run Keyword IF  '${resp.json()[${i}]['date']}' == '${DAY}' 
            ...     Run Keywords 
            ...     Should Be Equal As Strings  ${resp.json()[${i}]['date']}                 ${DAY}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['serviceTime']}     ${s_Time}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['queueStartTime']}  ${s_Time} 
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['queueEndTime']}    ${e_Time}
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['isAvailable']}     ${bool[1]}    
            ...     AND  Should Be Equal As Strings  ${resp.json()[${i}]['queueId']}         ${p1_q0}
 
    END

    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${p1_s3}  ${p1_q0}  ${CR_day}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    

JD-TC-Get Next Available Dates-UH11
	[Documentation]  without login - Bypassed URL
    ${resp}=  Availability Of Queue By Consumer  ${p1_l3}  ${p1_s3}  ${accId}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  


JD-TC-Get Next Available Dates-UH12
	[Documentation]  provider disable future chekin
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_P}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Disable Future Checkin
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # sleep   02s
    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Availability Of Queue By Consumer  ${p1_l3}  ${p1_s3}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
   



