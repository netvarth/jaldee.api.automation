*** Settings ***

Suite Teardown  Delete All Sessions
Test Teardown   Delete All Sessions
Force Tags      OnlineCheckin
Library         Collections
Library         String
Library         json
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

*** Test Cases ***

JD-TC-Online CheckIn In Queue-1
    [Documentation]  Enable  Online checkin in queuelevel
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME8}  ${PASSWORD}
    Log   ${resp.json()} 
    Should Be Equal As Strings    ${resp.status_code}    200
    # clear_service   ${HLPUSERNAME8}
    # clear_location  ${HLPUSERNAME8}
    # clear_queue  ${HLPUSERNAME8}

    ${pid}=  get_acc_id  ${HLPUSERNAME8}
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
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    ${SERVICE1}=    generate_unique_service_name  ${service_names} 
    Append To List  ${service_names}  ${SERVICE1}
    Set Suite Variable  ${SERVICE1}

    ${SERVICE2}=     generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE2}
    Set Suite Variable  ${SERVICE2}

    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${s_id1}=  Create Sample Service  ${SERVICE2}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  0  30  
    Set Suite Variable   ${eTime1}
    ${queue_name}=  FakerLibrary.bs

    ${resp}=  Create Queue  ${queue_name}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${s_id}  ${s_id1}
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid}  ${resp.json()}

    ${resp}=  Online Checkin In Queue  ${qid}  True
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Queue ById  ${qid}
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}  ${queue_name} 
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}  Weekly
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}  1
    Should Be Equal As Strings  ${resp.json()['capacity']}  5
    Should Be Equal As Strings  ${resp.json()['queueState']}  ENABLED
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}
    Should Be Equal As Strings  ${resp.json()['services'][1]['id']}  ${s_id1}
    Should Be Equal As Strings  ${resp.json()['onlineCheckIn']}   True
    Should Be Equal As Strings  ${resp.json()['futureWaitlist']}   True

    ${resp}=  Online Checkin In Queue  ${qid}  False
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Queue ById  ${qid}
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}  ${queue_name} 
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}  Weekly
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}  1
    Should Be Equal As Strings  ${resp.json()['capacity']}  5
    Should Be Equal As Strings  ${resp.json()['queueState']}  ENABLED
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}
    Should Be Equal As Strings  ${resp.json()['services'][1]['id']}  ${s_id1}
    Should Be Equal As Strings  ${resp.json()['onlineCheckIn']}   False
    Should Be Equal As Strings  ${resp.json()['futureWaitlist']}   True

JD-TC-Online CheckIn In Queue-2
    [Documentation]  Enable  Online checkin in accountlevel when queue level is false
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME8}  ${PASSWORD}
    Log   ${resp.json()} 
    Should Be Equal As Strings    ${resp.status_code}    200
    # clear_service   ${HLPUSERNAME8}  
    # clear_location  ${HLPUSERNAME8}  
    # clear_queue  ${HLPUSERNAME8}  

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
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    ${SERVICE1}=    generate_unique_service_name  ${service_names} 
    Append To List  ${service_names}  ${SERVICE1}
    Set Suite Variable  ${SERVICE1}

    ${SERVICE2}=     generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE2}
    Set Suite Variable  ${SERVICE2}

    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${s_id1}=  Create Sample Service  ${SERVICE2}
    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${s_id}  ${s_id1}
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid1}  ${resp.json()}

    ${resp}=  Online Checkin In Queue  ${qid1}  False
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Queue ById  ${qid1}
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  onlineCheckIn=False

    ${resp}=  Enable Search Data
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['onlineCheckIns']}==${bool[0]}   
        ${resp}=   Enable Online Checkin
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    # ${resp}=  Enable Online Checkin
    # Log   ${resp.json()} 
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist Settings
    Log   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  onlineCheckIns=True

    ${resp}=  Get Queue ById  ${qid1}
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  onlineCheckIn=False

    ${resp}=  Disable Search Data
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Disable Online Checkin
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Online CheckIn In Queue-3
    [Documentation]  Enable  Online checkin in accountlevel when queue level is true
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME8}  ${PASSWORD}
    Log   ${resp.json()} 
    Should Be Equal As Strings    ${resp.status_code}    200

    # clear_service   ${HLPUSERNAME8}
    # clear_location  ${HLPUSERNAME8}
    # clear_queue  ${HLPUSERNAME8}

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
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    ${resp}=  Get Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Enable Online Checkin
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${SERVICE1}=    generate_unique_service_name  ${service_names} 
    Append To List  ${service_names}  ${SERVICE1}
    Set Suite Variable  ${SERVICE1}

    ${SERVICE2}=     generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE2}
    Set Suite Variable  ${SERVICE2}

    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${s_id1}=  Create Sample Service  ${SERVICE2}
    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${s_id}  ${s_id1}
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid2}  ${resp.json()}

    ${resp}=  Online Checkin In Queue  ${qid2}  True
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Queue ById  ${qid2}
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  onlineCheckIn=True

    ${resp}=  Disable Online Checkin
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Online CheckIn In Queue-UH1
    [Documentation]  Enable  Online checkin in accountlevel when queue level is false
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME8}  ${PASSWORD}
    Log   ${resp.json()} 
    Should Be Equal As Strings    ${resp.status_code}    200
    # clear_service   ${HLPUSERNAME8}
    # clear_location  ${HLPUSERNAME8}
    # clear_queue  ${HLPUSERNAME8}

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
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    ${SERVICE1}=    generate_unique_service_name  ${service_names} 
    Append To List  ${service_names}  ${SERVICE1}
    Set Suite Variable  ${SERVICE1}

    ${SERVICE2}=     generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE2}
    Set Suite Variable  ${SERVICE2}

    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${s_id1}=  Create Sample Service  ${SERVICE2}
    # clear_queue  ${HLPUSERNAME8}
    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${s_id}  ${s_id1}
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid3}  ${resp.json()}

    # ${resp}=  Disable Online Checkin
    # Log   ${resp.json()} 
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist Settings
    Log   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  onlineCheckIns=False

    ${resp}=  Online Checkin In Queue  ${qid3}  True
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${WAITLIST_SAME_DAY_CHECKIN_ALREADY_OFF}"
    ${resp}=  Enable Search Data
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Enable Online Checkin
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Disable Search Data
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Online CheckIn In Queue-UH2
    [Documentation]  Enable Online CheckIn In Queue by consumer
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

    ${resp}=  Online CheckIn In Queue  ${qid}  True
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"	
    
JD-TC-Online CheckIn In Queue-UH3
    [Documentation]  Enable Online CheckIn In Queue without login
    ${resp}=  Online CheckIn In Queue  ${qid}  True
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"
    
JD-TC-Online CheckIn In Queue-UH4
    [Documentation]  Enable Online CheckIn In Queue by another  provider
    ${resp}=  Encrypted Provider Login  ${PUSERNAME23}  ${PASSWORD}
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${pid1}=  get_acc_id  ${PUSERNAME23}
    ${resp}=  Online CheckIn In Queue  ${qid3}  True
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}"	
    
JD-TC-Online CheckIn In Queue-UH5
    [Documentation]  Enable Online CheckIn In Queue using Invalid queue id
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME8}  ${PASSWORD}
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${resp}=  Online CheckIn In Queue  0  True
    Should Be Equal As Strings  ${resp.status_code}  404   
    Should Be Equal As Strings  "${resp.json()}"  "${QUEUE_NOT_FOUND}"

# JD-TC-Verify Online CheckIn In Queue-2
#     [Documentation]  Verification of case 2
#     ${resp}=  Encrypted Provider Login  ${HLPUSERNAME8}    ${PASSWORD}
#     Log   ${resp.json()} 
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=  Get Waitlist Settings
#     Log   ${resp.json()}   
#     Should Be Equal As Strings  ${resp.status_code}  200 
#     # Verify Response  ${resp}  onlineCheckIns=False
    
#     ${resp}=  Get Queue ById  ${qid1}
#     Log   ${resp.json()} 
#     Should Be Equal As Strings  ${resp.status_code}  200
#     # Verify Response  ${resp}  onlineCheckIn=False

#     ${resp}=  Enable Search Data
#     Log   ${resp.json()} 
#     Should Be Equal As Strings  ${resp.status_code}  200

#     # ${resp}=  Enable Online Checkin
#     # Log   ${resp.json()} 
#     # Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Get Waitlist Settings
#     Log   ${resp.json()}   
#     Should Be Equal As Strings  ${resp.status_code}  200 
#     Verify Response  ${resp}  onlineCheckIns=True

#     ${resp}=  Get Queue ById  ${qid1}
#     Log   ${resp.json()} 
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Response  ${resp}  onlineCheckIn=False

#     ${resp}=  Disable Search Data
#     Log   ${resp.json()} 
#     Should Be Equal As Strings  ${resp.status_code}  200

# JD-TC-Verify Online CheckIn In Queue-3
#     [Documentation]  Verification of case 3
#     ${resp}=  Encrypted Provider Login  ${HLPUSERNAME8}  ${PASSWORD}
#     Log   ${resp.json()} 
#     Should Be Equal As Strings    ${resp.status_code}    200
    
#     ${resp}=  Get Waitlist Settings
#     Log   ${resp.json()}   
#     Should Be Equal As Strings  ${resp.status_code}  200 
#     Verify Response  ${resp}  onlineCheckIns=False
#     ${resp}=  Get Queue ById  ${qid2}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Response  ${resp}  onlineCheckIn=False

#     # ${resp}=  Enable Search Data
#     # Should Be Equal As Strings  ${resp.status_code}  200
#     # ${resp}=  Enable Online Checkin
#     # Should Be Equal As Strings  ${resp.status_code}  200
#     # sleep  01s
#     ${resp}=  Get Waitlist Settings
#     Log   ${resp.json()}   
#     Should Be Equal As Strings  ${resp.status_code}  200 
#     Verify Response  ${resp}  onlineCheckIns=True
#     ${resp}=  Get Queue ById  ${qid2}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Response  ${resp}  onlineCheckIn=True
#     ${resp}=  Disable Search Data
#     Should Be Equal As Strings  ${resp.status_code}  200
