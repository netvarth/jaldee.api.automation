*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Queue
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/CustomKeywords.py
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/hl_providers.py
*** Variables ***

@{service_names}
@{appointment}            Enable  Disable
${start}    10

${maxQueue}   30

*** Test Cases ***

JD-TC-GetQueueAvaliability-1

    [Documentation]    Get Queue Avaliability - difference between start and end date is 90 ( the max number of queue is 30 )

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME37}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${accountId}=    get_acc_id       ${HLPUSERNAME37}
    Set Suite Variable  ${accountId}
    # clear_service   ${HLPUSERNAME37}
    # clear_location  ${HLPUSERNAME37}
    # clear_queue  ${HLPUSERNAME37}

    # ${lid2}=  Create Sample Location
    # ${resp}=   Get Location ById  ${lid2}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${lid2}

    # Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Suite Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    ${lid2}=  Create Sample Location
    ${resp}=   Get Location ById  ${lid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${lid2}

    ${SERVICE1}=    generate_unique_service_name  ${service_names} 
    Append To List  ${service_names}  ${SERVICE1}
    Set Suite Variable  ${SERVICE1}

    ${SERVICE2}=     generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE2}
    Set Suite Variable  ${SERVICE2}

    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${s_id1}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable  ${s_id}
    Set Suite Variable  ${s_id1}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  90        
    Set Suite Variable  ${DAY2}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  0  30  
    Set Suite Variable   ${eTime1}
    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${q_id}  ${resp.json()}

    ${DAY11}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY11}
    ${DAY22}=  db.add_timezone_date  ${tz}  20       
    Set Suite Variable  ${DAY22}
    ${sTime11}=  add_timezone_time  ${tz}  0  35 
    Set Suite Variable   ${sTime1}
    ${eTime11}=  add_timezone_time  ${tz}  0  50  
    Set Suite Variable   ${eTime1}
    ${queue_name2}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name2}  ${recurringtype[1]}  ${list}  ${DAY11}  ${DAY22}  ${EMPTY}  ${sTime11}  ${eTime11}  1  5  ${lid2}  ${s_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${q_id2}  ${resp.json()}

    ${resp}=  Get Queue ById    ${q_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}  ${queue_name} 
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}  1
    Should Be Equal As Strings  ${resp.json()['capacity']}  5
    Should Be Equal As Strings  ${resp.json()['queueState']}  ${Qstate[0]}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}

    ${resp}=  Get Queue ById    ${q_id2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}  ${queue_name2} 
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid2}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['startDate']}  ${DAY11}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['terminator']['endDate']}  ${DAY22}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}  ${sTime11}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}  ${eTime11}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}  1
    Should Be Equal As Strings  ${resp.json()['capacity']}  5
    Should Be Equal As Strings  ${resp.json()['queueState']}  ${Qstate[0]}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id1}

    ${resp}=    GET Queue Availability By Location AND Service  ${lid}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${count}=   Get Length  ${resp.json()}
    Should Be Equal As Strings      ${count}     ${maxQueue}


JD-TC-GetQueueAvaliability-2

    [Documentation]    Get Queue Avaliability - difference between start and end date is 10

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME37}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    GET Queue Availability By Location AND Service  ${lid2}  ${s_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-GetQueueAvaliability-3

    [Documentation]    Get Queue Avaliability - where location id and service is different queues

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME37}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    GET Queue Availability By Location AND Service  ${lid}  ${s_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Empty  ${resp.json()}

JD-TC-GetQueueAvaliability-4

    [Documentation]    Get Queue Avaliability - where queue is disabled

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME37}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Enable Disable Queue  ${qid}   ${toggleButton[1]} 
    Log     ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    GET Queue Availability By Location AND Service  ${lid}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Empty  ${resp.json()}

    ${resp}=  Enable Disable Queue  ${qid}   ${toggleButton[0]} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-GetQueueAvaliability-UH1

    [Documentation]    Get Queue Avaliability - where location id is invalid

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME37}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${inv}=     FakerLibrary.Random Int     

    ${resp}=    GET Queue Availability By Location AND Service  ${inv}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  404
    Should Be Equal As Strings  ${resp.json()}  ${LOCATION_NOT_FOUND}

JD-TC-GetQueueAvaliability-UH2

    [Documentation]    Get Queue Avaliability - where service id is invalid

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME37}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${inv}=     FakerLibrary.Random Int     

    ${resp}=    GET Queue Availability By Location AND Service  ${lid}  ${inv}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  404
    Should Be Equal As Strings  ${resp.json()}  ${INVALID_SERVICE}

JD-TC-GetQueueAvaliability-UH3

    [Documentation]    Get Queue Avaliability - where location is disabled

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME37}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
 
    ${resp}=    Disable Location    ${lid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    GET Queue Availability By Location AND Service  ${lid2}  ${s_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}  ${LOCATION_DISABLED}

    ${resp}=    Enable Location    ${lid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-GetQueueAvaliability-UH4

    [Documentation]    Get Queue Avaliability - where service is disabled

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME37}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
 
    ${resp}=    Disable service   ${s_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    GET Queue Availability By Location AND Service  ${lid2}  ${s_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}  ${INVALID_SERVICE}

    ${resp}=    Enable service    ${s_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-GetQueueAvaliability-UH5

    [Documentation]    Get Queue Avaliability - without login

    ${resp}=    GET Queue Availability By Location AND Service  ${lid2}  ${s_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.json()}  ${SESSION_EXPIRED}

JD-TC-GetQueueAvaliability-UH6

    [Documentation]    Get Queue Avaliability - with Provider consumer login

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${account_id}=  get_acc_id  ${HLPUSERNAME4}

    ${PH_Number}=  FakerLibrary.Numerify  %#####
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${PCPHONENO}  555${PH_Number}

    ${fname}=  generate_firstname
    ${lname}=  FakerLibrary.last_name
    Set Test Variable  ${pc_emailid1}  ${fname}${C_Email}.${test_mail}

    ${resp}=  AddCustomer  ${PCPHONENO}    firstName=${fname}   lastName=${lname}  countryCode=${countryCodes[1]}  email=${pc_emailid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Send Otp For Login    ${PCPHONENO}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}
   
    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${PCPHONENO}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    GET Queue Availability By Location AND Service  ${lid2}  ${s_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  ${resp.json()}  ${NoAccess}


JD-TC-GetQueueAvaliability-UH7

    [Documentation]    Get Queue Avaliability - with another provider login

    ${resp}=  Encrypted Provider Login  ${PUSERNAME188}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    GET Queue Availability By Location AND Service  ${lid2}  ${s_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  404
    Should Be Equal As Strings  ${resp.json()}  ${LOCATION_NOT_FOUND}
