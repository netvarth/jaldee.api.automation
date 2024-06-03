***Settings***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        User
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/hl_providers.py

*** Variables ***
${SERVICE1}  Makeup1  
${SERVICE2}  Hairmakeup1 
${SERVICE3}  Facial1
${SERVICE4}  Bridal makeup1 
${SERVICE5}  Hair remove1
${SERVICE6}  Bleach1
${SERVICE7}  Hair cut1
@{emptylist} 

***Test Cases***

JD-TC-UpdateQueueByUserLogin-1

     [Documentation]  Create a queue for user and Update that queue

     ${resp}=   Encrypted Provider Login  ${HLPUSERNAME3}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${p_id1}=  get_acc_id  ${HLPUSERNAME3}
    Set Suite Variable   ${p_id1}

    # ${resp}=    Get Locations
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # IF   '${resp.content}' == '${emptylist}'
    #     ${locId1}=  Create Sample Location
    #     Set Suite Variable  ${locId1}
    #     ${resp}=   Get Location ById  ${locId1}
    #     Log  ${resp.content}
    #     Should Be Equal As Strings  ${resp.status_code}  200
    #     Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    # ELSE
    #     Set Suite Variable  ${locId1}  ${resp.json()[0]['id']}
    #     Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    # END

    ${resp}=   Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    sleep  2s
    ${dep_name1}=  FakerLibrary.bs
    ${dep_code1}=   Random Int  min=100   max=999
    ${dep_desc1}=   FakerLibrary.word  
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${u_id}=  Create Sample User
    Set Suite Variable  ${u_id}

    ${resp}=  Get User By Id      ${u_id}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${PUSERNAME_U1}     ${resp.json()['mobileNo']}
    Set Suite Variable      ${dep_id}     ${resp.json()['deptId']} 

    ${resp}=  SendProviderResetMail   ${PUSERNAME_U1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${PUSERNAME_U1}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable     ${lid}  ${resp.json()[0]['id']}
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        Set Suite Variable  ${lid}
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ELSE
        Set Suite Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END


    # ${lid}=  Create Sample Location
    # Set Suite Variable  ${lid}
    ${description}=  FakerLibrary.sentence
    Set Suite Variable  ${description}
    ${dur}=  FakerLibrary.Random Int  min=05  max=10
    Set Suite Variable  ${dur}
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    Set Suite Variable  ${amt}
    ${resp}=  Create Service For User  ${SERVICE1}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  ${EMPTY}  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id}  ${resp.json()}
    ${resp}=  Create Service For User  ${SERVICE3}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  ${EMPTY}  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id3}  ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  0  30  
    Set Suite Variable   ${eTime1}
    ${queue_name}=  FakerLibrary.bs
    Set Suite Variable  ${queue_name}
    ${resp}=  Create Queue For User  ${queue_name}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${u_id}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${q_id}  ${resp.json()}
    ${resp}=  Get Queue ById  ${q_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}  ${queue_name} 
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}  Weekly
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}  1
    Should Be Equal As Strings  ${resp.json()['capacity']}  5
    Should Be Equal As Strings  ${resp.json()['provider']['id']}  ${u_id}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}
    ${queue_name1}=  FakerLibrary.bs
    Set Suite Variable  ${queue_name1}
    ${resp}=  Update Queue For User    ${q_id}  ${queue_name1}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${u_id}   ${s_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Queue ById  ${q_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}  ${queue_name1} 
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}  Weekly
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}  1
    Should Be Equal As Strings  ${resp.json()['capacity']}  5
    Should Be Equal As Strings  ${resp.json()['provider']['id']}  ${u_id}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id3}

JD-TC-UpdateQueueByUserLogin-2
     [Documentation]  Update  a  user queue with more service
     ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Create Service For User  ${SERVICE5}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  ${EMPTY}  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id}
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${s_id5}  ${resp.json()}
     ${resp}=  Create Service For User  ${SERVICE6}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  ${EMPTY}  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id}
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${s_id6}  ${resp.json()}
     ${sTime3}=  add_timezone_time  ${tz}  0  50
     ${eTime3}=  add_timezone_time  ${tz}  1  15  
     ${queue_name}=  FakerLibrary.bs
     ${resp}=  Create Queue For User  ${queue_name}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime3}  ${eTime3}  1  5  ${lid}  ${u_id}  ${s_id5}
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${q_id5}  ${resp.json()}
     ${resp}=  Get Queue ById  ${q_id5}
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()['name']}  ${queue_name} 
     Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
     Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}  Weekly
     Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}  ${sTime3}
     Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}  ${eTime3}
     Should Be Equal As Strings  ${resp.json()['parallelServing']}  1
     Should Be Equal As Strings  ${resp.json()['capacity']}  5
     Should Be Equal As Strings  ${resp.json()['provider']['id']}  ${u_id}
     Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id5}
     ${resp}=  Update Queue For User    ${q_id5}  ${queue_name}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime3}  ${eTime3}  1  5  ${lid}  ${u_id}   ${s_id5}   ${s_id6}   
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=  Get Queue ById  ${q_id5}
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()['name']}  ${queue_name} 
     Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
     Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}  Weekly
     Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}  ${sTime3}
     Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}  ${eTime3}
     Should Be Equal As Strings  ${resp.json()['parallelServing']}  1
     Should Be Equal As Strings  ${resp.json()['capacity']}  5
     Should Be Equal As Strings  ${resp.json()['provider']['id']}  ${u_id}
     Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id5}
     Should Be Equal As Strings  ${resp.json()['services'][1]['id']}  ${s_id6}


JD-TC-UpdateQueueByUserLogin-UH1
    [Documentation]    Create a queue and update that queue with  same details of another user queue

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME3}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${u_id1}=  Create Sample User
    Set Suite Variable  ${u_id1}

    ${resp}=  Get User By Id        ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${PUSERNAME_U2}     ${resp.json()['mobileNo']}
    
    ${resp}=  SendProviderResetMail   ${PUSERNAME_U2}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${PUSERNAME_U2}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Create Service For User  ${SERVICE2}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  ${EMPTY}  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id2}  ${resp.json()}
    ${resp}=  Create Queue For User  ${queue_name}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${u_id1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id1}  ${resp.json()}
    ${resp}=  Get Queue ById  ${q_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}  ${queue_name} 
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}  Weekly
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}  1
    Should Be Equal As Strings  ${resp.json()['capacity']}  5
    Should Be Equal As Strings  ${resp.json()['provider']['id']}  ${u_id1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id2}

    ${resp}=  Update Queue For User    ${q_id1}  ${queue_name1}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${u_id1}   ${s_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${QUEUE_EXISTS}"

JD-TC-UpdateQueueByUserLogin-UH2

     [Documentation]  Create a queue for a user with branch's service id

     ${resp}=  Encrypted Provider Login  ${HLPUSERNAME3}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${desc}=   FakerLibrary.sentence
     Set Suite Variable    ${desc}
     ${total_amount}=    Random Int   min=100  max=500
     ${min_prepayment}=  Random Int   min=1    max=50
     ${ser_duratn}=      Random Int   min=10   max=30
     Set Suite Variable   ${ser_duratn}
     ${resp}=  Create Service Department  ${SERVICE4}  ${desc}   ${ser_duratn}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${min_prepayment}  ${total_amount}  ${bool[1]}  ${bool[0]}  ${dep_id}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${s_id_B}  ${resp.json()}
     ${PUSERNAME_U3}=  Evaluate  ${PUSERNAME}+3246747
     clear_users  ${PUSERNAME_U3}
     ${firstname1}=  FakerLibrary.name
     ${lastname1}=  FakerLibrary.last_name
     ${dob1}=  FakerLibrary.Date
     ${pin1}=  get_pincode
   
     ${u_id4}=  Create Sample User
     Set Suite Variable  ${u_id4}

     ${resp}=  Get User By Id        ${u_id4}
     Log   ${resp.json()}
     Should Be Equal As Strings      ${resp.status_code}  200
     Set Suite Variable      ${PUSERNAME_U4}     ${resp.json()['mobileNo']}
     
     ${resp}=  SendProviderResetMail   ${PUSERNAME_U4}
     Should Be Equal As Strings  ${resp.status_code}  200

     @{resp}=  ResetProviderPassword  ${PUSERNAME_U4}  ${PASSWORD}  2
     Should Be Equal As Strings  ${resp[0].status_code}  200
     Should Be Equal As Strings  ${resp[1].status_code}  200

     ${resp}=  Encrypted Provider Login  ${PUSERNAME_U4}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=  Create Service For User  ${SERVICE4}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  ${EMPTY}  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id4}
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${s_id4}  ${resp.json()}
     ${resp}=  Create Queue For User  ${queue_name}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${u_id4}  ${s_id4}
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${q_id4}  ${resp.json()}
     ${resp}=  Get Queue ById  ${q_id4}
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()['name']}  ${queue_name} 
     Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
     Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}  Weekly
     Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
     Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
     Should Be Equal As Strings  ${resp.json()['parallelServing']}  1
     Should Be Equal As Strings  ${resp.json()['capacity']}  5
     Should Be Equal As Strings  ${resp.json()['provider']['id']}  ${u_id4}
     Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id4}

     ${queue_name}=  FakerLibrary.bs
     Set Suite Variable  ${queue_name}
     ${resp}=  Update Queue For User    ${q_id4}  ${queue_name}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${u_id4}   ${s_id_B}
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  422
     Should Be Equal As Strings  "${resp.json()}"  "${INVALID_SERVICE}"


JD-TC-UpdateQueueByUserLogin -UH3
     [Documentation]   Provider Update a queue for  a User without login      
     ${resp}=  Update Queue For User    ${q_id}  ${queue_name1}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${u_id}   ${s_id3}
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  419
     Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}"
 
JD-TC-UpdateQueueByUserLogin -UH4
    [Documentation]   Consumer create a queue for user
    ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Update Queue For User    ${q_id}  ${queue_name1}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${u_id}   ${s_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"

  