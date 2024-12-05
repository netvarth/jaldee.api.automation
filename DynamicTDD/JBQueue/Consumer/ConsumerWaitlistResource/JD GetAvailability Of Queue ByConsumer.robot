*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Queue
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/CustomKeywords.py
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
# Variables         /ebs/TDD/varfiles/consumermail.py 

*** Variables ***
${service_duration}   5  
${SERVICE2}     conselling
@{service_names}


*** Test Cases ***
JD-TC-Get Next Available Dates-1

    [Documentation]  Get next available 30 days queues

    ${PUSERNAME_P}=  Evaluate  ${PUSERNAME}+91235
    Set Suite Variable  ${PUSERNAME_P}
    ${firstname}  ${lastname}  ${PhoneNumber}  ${PUSERNAME_P}=  Provider Signup  PhoneNumber=${PUSERNAME_P}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_P}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pid}  ${decrypted_data['id']}
    Set Test Variable   ${domain}  ${decrypted_data['sector']}
    Set Test Variable   ${subdomain}  ${decrypted_data['subSector']}
    Set Suite Variable    ${username}    ${decrypted_data['userName']}

    Set Test Variable  ${email_id}  ${P_Email}${PUSERNAME_P}.${test_mail}

    ${resp}=  Update Email   ${p_id}   ${firstname}  ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Waitlist Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enabledWaitlist']}==${bool[0]}   
        ${resp}=   Enable Waitlist
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=  Get Waitlist Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enabledWaitlist']}   ${bool[1]}
    sleep   01s
    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['onlinePresence']}==${bool[0]}
        ${resp}=  Set jaldeeIntegration Settings    ${bool[1]}  ${EMPTY}  ${EMPTY}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}  

    ${loc_list}=  Create List
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${loc_length}=  Get Length  ${resp.json()}
    FOR   ${i}  IN RANGE   ${loc_length}
        Append To List   ${loc_list}  ${resp.json()[${i}]['place']}
    END 
    

    ${DAY}=  db.get_date_by_timezone  ${tz}   
    Set Suite Variable  ${DAY} 
    ${tomorrow}=  db.add_timezone_date  ${tz}  1     
    Set Suite Variable  ${tomorrow} 
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}

    FOR  ${i}  IN RANGE   5
        ${city}=   FakerLibrary.state
        ${keywordstatus} 	${value} = 	Run Keyword And Ignore Error   List Should Not Contain Value  ${loc_list}  ${city}
        Log Many  ${keywordstatus} 	${value}
        Continue For Loop If  '${keywordstatus}' == 'FAIL'
        Run Keyword If  '${keywordstatus}' == 'PASS'  Append To List   ${loc_list}  ${city}
        Exit For Loop IF   '${keywordstatus}' == 'PASS'
    END
    
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz1}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz1}
    # ${sTime}=  db.get_time_by_timezone   ${tz}
    ${sTime}=  db.get_time_by_timezone  ${tz1}
    ${eTime}=  add_timezone_time  ${tz1}  0  30
    ${parking}    Random Element     ${parkingType} 
    ${24hours}    Random Element    ['True','False']
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${postcode}  ${address}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${loc_result} = 	Convert To Integer 	 ${resp.json()}
    Set Suite Variable  ${p1_l1}   ${loc_result}

    
    FOR  ${i}  IN RANGE   5
        ${city}=   FakerLibrary.state
        ${keywordstatus} 	${value} = 	Run Keyword And Ignore Error   List Should Not Contain Value  ${loc_list}  ${city}
        Log Many  ${keywordstatus} 	${value}
        Continue For Loop If  '${keywordstatus}' == 'FAIL'
        Run Keyword If  '${keywordstatus}' == 'PASS'  Append To List   ${loc_list}  ${city}
        Exit For Loop IF   '${keywordstatus}' == 'PASS'
    END

    # # ${city}=   get_place
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz2}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz2}
    ${sTime1}=  add_timezone_time  ${tz2}  0  30
    ${eTime1}=  add_timezone_time  ${tz2}  1  00
    ${parking}    Random Element     ${parkingType} 
    ${24hours}    Random Element    ['True','False']
    ${url}=   FakerLibrary.url
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}   ${postcode}  ${address}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${loc_result} = 	Convert To Integer 	 ${resp.json()}
    Set Suite Variable  ${p1_l2}   ${loc_result}

    ${name_list}=  Create List
    ${resp}=  Get Service
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${srv_length}=  Get Length  ${resp.json()}
    FOR   ${i}  IN RANGE   ${srv_length}
        Run Keyword If  '${srv_length}' != '0'  Append To List   ${name_list}  ${resp.json()[${i}]['name']}
    END
    
    FOR  ${i}  IN RANGE   5
        ${P1SERVICE1}=  FakerLibrary.Word
        ${keywordstatus} 	${value} = 	Run Keyword And Ignore Error   List Should Not Contain Value  ${name_list}  ${P1SERVICE1}
        Log Many  ${keywordstatus} 	${value}
        Continue For Loop If  '${keywordstatus}' == 'FAIL'
        Run Keyword If  '${keywordstatus}' == 'PASS'  Append To List   ${name_list}  ${P1SERVICE1}
        Exit For Loop IF   '${keywordstatus}' == 'PASS'
    END
    Set Suite Variable  ${P1SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration}  ${bool[0]}    ${servicecharge}    ${bool[0]}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_s1}  ${resp.json()} 

    FOR  ${i}  IN RANGE   5
        ${P1SERVICE2}=  FakerLibrary.Word
        ${keywordstatus} 	${value} = 	Run Keyword And Ignore Error   List Should Not Contain Value  ${name_list}  ${P1SERVICE2}
        Log Many  ${keywordstatus} 	${value}
        Continue For Loop If  '${keywordstatus}' == 'FAIL'
        Run Keyword If  '${keywordstatus}' == 'PASS'  Append To List   ${name_list}  ${P1SERVICE2}
        Exit For Loop IF   '${keywordstatus}' == 'PASS'
    END
    # ${P1SERVICE2}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${P1SERVICE2}
    Set Suite Variable  ${P1SERVICE2}
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE2}  ${desc}   ${service_duration}  ${bool[0]}    ${servicecharge}    ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_s2}  ${resp.json()} 

    FOR  ${i}  IN RANGE   5
        ${P1SERVICE3}=  FakerLibrary.Word
        ${keywordstatus} 	${value} = 	Run Keyword And Ignore Error   List Should Not Contain Value  ${name_list}  ${P1SERVICE3}
        Log Many  ${keywordstatus} 	${value}
        Continue For Loop If  '${keywordstatus}' == 'FAIL'
        Run Keyword If  '${keywordstatus}' == 'PASS'  Append To List   ${name_list}  ${P1SERVICE3}
        Exit For Loop IF   '${keywordstatus}' == 'PASS'
    END
    # ${P1SERVICE3}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${P1SERVICE3}
    Set Suite Variable   ${P1SERVICE3}
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE3}  ${desc}   ${service_duration}  ${bool[0]}    ${servicecharge}    ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_s3}  ${resp.json()}

    ${sTime1}=  add_timezone_time  ${tz1}  1  00
    ${eTime1}=  add_timezone_time  ${tz1}  1  30
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

    ${fname}=  generate_firstname
    ${lname}=  FakerLibrary.last_name
   
    ${resp}=  AddCustomer  ${CUSERNAME9}   firstName=${fname}   lastName=${lname}  countryCode=${countryCodes[1]}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${cid}  ${resp.json()}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${CUSERNAME9}    ${accId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${CUSERNAME9}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME9}    ${accId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Availability Of Queue By Consumer  ${p1_l1}  ${p1_s1}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  30
    FOR  ${i}  IN RANGE   ${len}
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
    
    ${sTime2}=  add_timezone_time  ${tz2}  1  30
    ${eTime2}=  add_timezone_time  ${tz2}  2  00
    ${p1queue2}=    FakerLibrary.word
    Set Suite Variable   ${p1queue2}
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Queue  ${p1queue2}  ${recurringtype[1]}  ${list}  ${tomorrow}  ${EMPTY}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel}  ${capacity}  ${p1_l2}   ${p1_s2} 
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_q2}  ${resp.json()} 

    ${fname}=  generate_firstname
    ${lname}=  FakerLibrary.last_name
   
    ${resp}=  AddCustomer  ${CUSERNAME8}   firstName=${fname}   lastName=${lname}  countryCode=${countryCodes[1]}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${cid}  ${resp.json()}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${CUSERNAME8}    ${accId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${CUSERNAME8}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token2}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME8}    ${accId}  ${token2} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Availability Of Queue By Consumer  ${p1_l2}  ${p1_s2}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['serviceTime']}     ${sTime2}
    Should Be Equal As Strings  ${resp.json()[0]['queueStartTime']}  ${sTime2} 
    Should Be Equal As Strings  ${resp.json()[0]['queueEndTime']}    ${eTime2}
    Should Be Equal As Strings  ${resp.json()[0]['isAvailable']}     ${bool[1]}    
    Should Be Equal As Strings  ${resp.json()[0]['queueId']}         ${p1_q2}

JD-TC-Get Next Available Dates-3

	[Documentation]  without login

    ${resp}=  Availability Of Queue By Consumer    ${p1_l2}   ${p1_s2}   ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
        Should Be Equal As Strings  ${resp.json()[${i}]['isAvailable']}     ${bool[1]}    
        Should Be Equal As Strings  ${resp.json()[${i}]['queueId']}         ${p1_q2}
 
    END
 
JD-TC-Get Next Available Dates-4

    [Documentation]  Get next available queues using Queue have specific end date

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_P}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 
    
    ${endday}=  db.add_timezone_date  5  ${tz2}   
    Set Suite Variable  ${endday} 
    ${sTime3}=  add_timezone_time  ${tz2}  2  00
    Set Suite Variable   ${sTime3}
    ${eTime3}=  add_timezone_time  ${tz2}  2  30
    Set Suite Variable   ${eTime3}
    ${p1queue3}=    FakerLibrary.word
    Set Suite Variable   ${p1queue3}
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Queue  ${p1queue3}  ${recurringtype[1]}  ${list}  ${DAY}  ${endday}  ${EMPTY}  ${sTime3}  ${eTime3}  ${parallel}  ${capacity}  ${p1_l2}  ${p1_s3} 
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_q3}  ${resp.json()}

    ${resp}=    Send Otp For Login    ${CUSERNAME8}    ${accId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${CUSERNAME8}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token2}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME8}    ${accId}  ${token2} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Availability Of Queue By Consumer  ${p1_l2}  ${p1_s3}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
        Should Be Equal As Strings  ${resp.json()[${i}]['serviceTime']}     ${sTime3}
        Should Be Equal As Strings  ${resp.json()[${i}]['queueStartTime']}  ${sTime3} 
        Should Be Equal As Strings  ${resp.json()[${i}]['queueEndTime']}    ${eTime3}
        Should Be Equal As Strings  ${resp.json()[${i}]['isAvailable']}     ${bool[1]}    
        Should Be Equal As Strings  ${resp.json()[${i}]['queueId']}         ${p1_q3} 
    END


JD-TC-Get Next Available Dates-5

    [Documentation]  Get next available queues create a holiday

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_P}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
 
    ${sTime4}=  add_timezone_time  ${tz1}  2  30  
    ${eTime4}=  add_timezone_time  ${tz1}  3  00
    ${p1queue4}=    FakerLibrary.word
    Set Suite Variable   ${p1queue4}
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Queue  ${p1queue4}  ${recurringtype[1]}  ${list}  ${DAY}  ${endday}  ${EMPTY}  ${sTime4}  ${eTime4}  ${parallel}  ${capacity}  ${p1_l1}   ${p1_s3} 
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_q4}  ${resp.json()}

    ${holiday}=  db.add_timezone_date  ${tz1}  4   
    Set Suite Variable  ${holiday} 
    ${holidayname}=   FakerLibrary.word
    ${sTime5}=  add_timezone_time  ${tz1}  2  30  
    ${desc}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    # ${resp}=  Create Holiday  ${holiday}  ${holidayname}  ${sTime5}  ${eTime4}
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${holiday}  ${holiday}  ${EMPTY}  ${sTime5}  ${eTime4}  ${desc}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${hId}    ${resp.json()['holidayId']}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME8}    ${accId}  ${token2} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Availability Of Queue By Consumer  ${p1_l1}  ${p1_s3}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_P}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Delete Holiday  ${hId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

JD-TC-Get Next Available Dates-6

	[Documentation]   Get available queue with same service in diffrent queue
 
    # clear_queue  ${PUSERNAME_P}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_P}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${sTime6}=  add_timezone_time  ${tz1}  3  30
    Set Suite Variable  ${sTime6}
    ${eTime6}=  add_timezone_time  ${tz1}  4  30
    Set Suite Variable  ${eTime6}
    ${p1queue6}=    FakerLibrary.word
    Set Suite Variable   ${p1queue6}
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Queue  ${p1queue6}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime6}  ${eTime6}  ${parallel}  ${capacity}  ${p1_l1}  ${p1_s1} 
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_q6}  ${resp.json()}

    ${sTime7}=  add_timezone_time  ${tz1}  4  30
    Set Suite Variable  ${sTime7}
    ${eTime7}=  add_timezone_time  ${tz1}  5  30
    Set Suite Variable  ${eTime7}
    ${p1queue7}=    FakerLibrary.word
    Set Suite Variable   ${p1queue7}
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Queue  ${p1queue7}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime7}  ${eTime7}  ${parallel}  ${capacity}  ${p1_l1}  ${p1_s1} 
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_q7}  ${resp.json()}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME8}    ${accId}  ${token2} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Queue By Location and service  ${p1_l1}  ${p1_s1}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
     
    ${len2}=  Get Length  ${resp.json()}
    Set Suite Variable  ${len2}

    ${resp}=  Availability Of Queue By Consumer  ${p1_l1}  ${p1_s1}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-Get Next Available Dates-7

	[Documentation]  same service in diffrent location

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_P}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
 
    ${sTime8}=  add_timezone_time  ${tz1}  2  30  
    Set Suite Variable   ${sTime8}
    ${eTime8}=  add_timezone_time  ${tz1}  3  00
    Set Suite Variable   ${eTime8}
    ${p1queue8}=    FakerLibrary.word
    Set Suite Variable   ${p1queue8}
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Queue  ${p1queue8}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime8}  ${eTime8}  ${parallel}  ${capacity}  ${p1_l1}  ${p1_s1} 
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_q8}  ${resp.json()}
    ${sTime9}=  add_timezone_time  ${tz2}  3  00
    ${eTime9}=  add_timezone_time  ${tz2}  3  30
    ${p1queue9}=    FakerLibrary.word
    Set Suite Variable   ${p1queue9}
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Queue  ${p1queue9}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime9}  ${eTime9}  ${parallel}  ${capacity}  ${p1_l2}  ${p1_s1} 
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_q9}  ${resp.json()}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME8}    ${accId}  ${token2} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  Get Queue By Location and service  ${p1_l1}  ${p1_s1}  ${accId} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${len1}=  Get Length  ${resp.json()}  
    Set Suite Variable   ${len1}

    ${resp}=  Availability Of Queue By Consumer  ${p1_l1}  ${p1_s1}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-Get Next Available Dates-8

	[Documentation]  Avalable queue in a branch user

    ${PUSERNAME_L}=  Evaluate  ${PUSERNAME}+4053143333

    ${firstname_B}  ${lastname_B}  ${PhoneNumber}  ${PUSERNAME_L}=  Provider Signup  PhoneNumber=${PUSERNAME_L}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_L}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pid}  ${decrypted_data['id']}
    Set Test Variable   ${domain}  ${decrypted_data['sector']}
    Set Test Variable   ${sub_domain_id}  ${decrypted_data['subSector']}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_L}${\n}
    Set Suite Variable  ${PUSERNAME_L}
    
    ${accid1}=  get_acc_id  ${PUSERNAME_L} 
    Set Suite Variable    ${accid1}

    Set Test Variable  ${email_id}  ${P_Email}${PUSERNAME_L}.${test_mail}

    ${resp}=  Update Email   ${p_id}   ${firstname_B}  ${lastname_B}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Waitlist Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enabledWaitlist']}==${bool[0]}   
        ${resp}=   Enable Waitlist
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=  Get Waitlist Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enabledWaitlist']}   ${bool[1]}
    sleep   01s
    
    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['onlinePresence']}==${bool[0]}
        ${resp}=  Set jaldeeIntegration Settings    ${bool[1]}  ${EMPTY}  ${EMPTY}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    ${resp}=  Get Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Enable Disable Department  ${toggle[0]}
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
    Set Suite Variable    ${dep_desc}
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id1}  ${resp.json()}

    ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+3466735
    clear_users  ${PUSERNAME_U1}
    ${firstname2}=  FakerLibrary.name
    ${lastname2}=  FakerLibrary.last_name
    ${dob2}=  FakerLibrary.Date
    ${pin2}=  get_pincode

    ${whpnum}=  Evaluate  ${PUSERNAME_U1}+335245
    ${tlgnum}=  Evaluate  ${PUSERNAME_U1}+335345

    ${resp}=  Create User  ${firstname2}  ${lastname2}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${userType[0]}  deptId=${dep_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id}  ${resp.json()}

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime_1}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime_1}
    ${eTime_1}=  add_timezone_time  ${tz}  4  15  
    Set Suite Variable   ${eTime_1}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${ulid}   ${resp.json()[0]['id']}
    Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
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

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME8}    ${accId}  ${token2} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

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

    
JD-TC-Get Next Available Dates-9

	[Documentation]  create a vacation

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_L}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Queues
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${start_time}=  add_timezone_time  ${tz}  0  15  
    Set Test Variable   ${start_time}
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    Set Test Variable    ${end_time}
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Test Variable    ${CUR_DAY}
    ${desc}=    FakerLibrary.name
    Set Test Variable      ${desc}
    ${list}=  Create List  1  2  3  4  5  6  7
   
    ${resp}=  Create Vacation    ${desc}  ${u_id}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${CUR_DAY}  0  ${start_time}  ${end_time} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${v1_id}  ${resp.json()}
    sleep  2s

    ${resp}=  Get Vacation    ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${v1_id}  ${resp.json()[0]['id']}
  
    ${resp}=  Get Queues
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME8}    ${accId}  ${token2} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Availability Of Queue By Consumer  ${ulid}  ${us_id}  ${accid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_L}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Delete Vacation  ${v1_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-Get Next Available Dates-UH2

	[Documentation]  INPUT Disable SERVICE id
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_P}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
 
    ${RESP}=  Disable service  ${p1_s1} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME8}    ${accId}  ${token2} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Availability Of Queue By Consumer  ${p1_l1}  ${p1_s1}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${INVALID_SERVICE}"

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_P}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Enable service  ${p1_s1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout

JD-TC-Get Next Available Dates-UH3

	[Documentation]  INPUT Disable Location id
  
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_P}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${RESP}=  Disable Location  ${p1_l1} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME8}    ${accId}  ${token2} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${p1_q3}  ${resp.json()}

    ${resp}=  Availability Of Queue By Consumer  ${p1_l1}  ${p1_s1}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422 
    Should Be Equal As Strings  "${resp.json()}"  "${LOCATION_DISABLED}"  

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_P}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${RESP}=  Enable Location  ${p1_l1} 
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Get Next Available Dates-UH4

	[Documentation]  Queue have no service
  
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_P}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${sTime}=  add_timezone_time  ${tz}  3  30  
    ${eTime}=  add_timezone_time  ${tz}  6  00  
    ${p1queue}=    FakerLibrary.word
    Set Suite Variable   ${p1queue}
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Queue  ${p1queue}  ${recurringtype[1]}  ${list}  ${DAY}  ${endday}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${p1_l1}   ${p1_s3} 
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_q}  ${resp.json()} 

    ${RESP}=  Enable Disable Queue  ${p1_q}  ${toggleButton[1]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME8}    ${accId}  ${token2} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Availability Of Queue By Consumer  ${p1_l1}  ${p1_s3}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()}   []  

JD-TC-Get Next Available Dates-UH5

	[Documentation]  Location have no queue
  
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_P}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # clear_location      ${PUSERNAME_P}

    ${sTime}=  db.get_time_by_timezone  ${tz}
    ${eTime}=  add_timezone_time  ${tz}  4  30  
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${parking}    Random Element     ${parkingType} 
    ${24hours}    Random Element    ['True','False']
    ${url}=   FakerLibrary.url
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${postcode}  ${address}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${loc_result} = 	Convert To Integer 	 ${resp.json()}
    Set Suite Variable  ${p1_l3}   ${loc_result}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME8}    ${accId}  ${token2} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Availability Of Queue By Consumer  ${p1_l3}  ${p1_s3}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()}   []  

JD-TC-Get Next Available Dates-UH6

	[Documentation]  provider disable queue and then enable it then check the availabily

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_P}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${s_Time}=  add_timezone_time  ${tz}  2  30  
    Set Suite Variable   ${s_Time}
    ${e_Time}=  add_timezone_time  ${tz}  5  00  
    Set Suite Variable   ${e_Time}  
    ${p1queue}=    FakerLibrary.word
    Set Suite Variable   ${p1queue}
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Queue  ${p1queue}  ${recurringtype[1]}  ${list}  ${DAY}  ${endday}  ${EMPTY}  ${s_Time}  ${e_Time}  ${parallel}  ${capacity}  ${p1_l3}   ${p1_s3} 
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_q0}  ${resp.json()} 

    ${resp}=  Enable Disable Queue  ${p1_q0}  ${toggleButton[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   02s

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME8}    ${accId}  ${token2} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Availability Of Queue By Consumer  ${p1_l3}  ${p1_s3}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()}   []  

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_P}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${resp}=  Enable Disable Queue  ${p1_q0}  ${toggleButton[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   02s
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME8}    ${accId}  ${token2} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Availability Of Queue By Consumer  ${p1_l3}  ${p1_s3}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${len}=  Get Length  ${resp.json()} 
    FOR  ${i}  IN RANGE   ${len}
        
        
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

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME8}    ${accId}  ${token2} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Availability Of Queue By Consumer  ${p1_l3}  ${p1_s3}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()}   [] 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_P}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Get Waitlist Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enabledWaitlist']}==${bool[0]}   
        ${resp}=   Enable Waitlist
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=  Get Waitlist Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enabledWaitlist']}   ${bool[1]}
    sleep   01s


JD-TC-Get Next Available Dates-UH8

	[Documentation]  Get availabile queue  using another provider service and location

    ${resp}=  Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${prov1_id}=  get_acc_id  ${PUSERNAME30} 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME34}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # clear_service   ${PUSERNAME34}
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${plid}   ${resp.json()[0]['id']}

    ${P1SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${P1SERVICE1}
    Set Test Variable  ${P1SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration}  ${bool[0]}    ${servicecharge}    ${bool[0]}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p_s1}  ${resp.json()} 

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME8}    ${accId}  ${token2} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Availability Of Queue By Consumer  ${plid}  ${p_s1}  ${prov1_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   404
    Should Be Equal As Strings  "${resp.json()}"   "${LOCATION_NOT_FOUND}"

JD-TC-Get Next Available Dates-UH9

	[Documentation]  Invalid location and service id

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME8}    ${accId}  ${token2} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Availability Of Queue By Consumer  00  00  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   404
    Should Be Equal As Strings  "${resp.json()}"   "${LOCATION_NOT_FOUND}"

JD-TC-Get Next Available Dates-UH10

	[Documentation]  provider disable online chekin and try to take waitlist

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_P}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Disable Online Checkin
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   02s

    ${resp}=  Get Waitlist Settings
    Log  ${resp.json()}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME8}    ${accId}  ${token2} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${CR_day}=  db.add_timezone_date  ${tz}   0

    ${resp}=  Availability Of Queue By Consumer  ${p1_l3}  ${p1_s3}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()[0]['serviceTime']}     ${s_Time}
    Should Be Equal As Strings  ${resp.json()[0]['queueStartTime']}  ${s_Time} 
    Should Be Equal As Strings  ${resp.json()[0]['queueEndTime']}    ${e_Time}
    Should Be Equal As Strings  ${resp.json()[0]['isAvailable']}     ${bool[1]}    
    Should Be Equal As Strings  ${resp.json()[0]['queueId']}         ${p1_q0}

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${cid}  ${accId}  ${p1_q0}  ${CR_day}  ${p1_s3}  ${cnote}  ${bool[0]}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${ONLINE_CHECKIN_OFF}"
    

JD-TC-Get Next Available Dates-UH12

	[Documentation]  provider disable future chekin

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_P}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Disable Future Checkin
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   02s
    ${resp}=  Get Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME8}    ${accId}  ${token2} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Availability Of Queue By Consumer  ${p1_l3}  ${p1_s3}  ${accId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()}   []


