*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Reminder
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/musers.py
Variables         /ebs/TDD/varfiles/hl_musers.py


*** Variables ***

@{emptylist}


*** Test Cases ***

JD-TC-GetReminders-1

    [Documentation]    Provider create a reminder for his consumer and verify it.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME156}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${prov_id1}  ${decrypted_data['id']}
    # Set Suite Variable  ${prov_id1}  ${resp.json()['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id1}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME18}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME18}  
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${pcid18}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${pcid18}  ${resp.json()[0]['id']}
    END

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    Set Suite Variable  ${DAY2}  
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    Set Suite Variable  ${sTime1}  
    ${eTime1}=  db.add_timezone_time  ${tz}  3  15
    Set Suite Variable  ${eTime1}
    ${msg}=  FakerLibrary.word
    Set Suite Variable  ${msg}

    ${resp}=  Create Reminder    ${prov_id1}  ${pcid18}  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${rem_id1}  ${resp.content}

    ${resp}=    Get Reminders 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['id']}                                   ${rem_id1}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['startDate']}                ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['terminator']['endDate']}    ${DAY2}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['timeSlots'][0]['sTime']}    ${sTime1}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['timeSlots'][0]['eTime']}    ${eTime1}
    Should Be Equal As Strings  ${resp.json()[0]['provider']['id']}                       ${prov_id1}
    Should Be Equal As Strings  ${resp.json()[0]['providerConsumer']['id']}               ${pcid18}
    Should Be Equal As Strings  ${resp.json()[0]['message']}                              ${msg}
    # Should Be Equal As Strings  ${resp.json()[0]['reminderSource']['Email']}              ${bool[1]}
    # Should Be Equal As Strings  ${resp.json()[0]['reminderSource']['Sms']}                ${bool[1]}
    # Should Be Equal As Strings  ${resp.json()[0]['reminderSource']['PushNotification']}   ${bool[1]}

JD-TC-GetReminders-2

    [Documentation]    Provider create more than one reminder for his consumer and verify it(with same schedule).

    ${resp}=  Encrypted Provider Login  ${PUSERNAME156}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Create Reminder    ${prov_id1}  ${pcid18}  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${rem_id2}  ${resp.content}

    ${resp}=    Get Reminders 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[1]['id']}                                   ${rem_id1}
    Should Be Equal As Strings  ${resp.json()[1]['schedule']['startDate']}                ${DAY1}
    Should Be Equal As Strings  ${resp.json()[1]['schedule']['terminator']['endDate']}    ${DAY2}
    Should Be Equal As Strings  ${resp.json()[1]['schedule']['timeSlots'][0]['sTime']}    ${sTime1}
    Should Be Equal As Strings  ${resp.json()[1]['schedule']['timeSlots'][0]['eTime']}    ${eTime1}
    Should Be Equal As Strings  ${resp.json()[1]['provider']['id']}                       ${prov_id1}
    Should Be Equal As Strings  ${resp.json()[1]['providerConsumer']['id']}               ${pcid18}
    Should Be Equal As Strings  ${resp.json()[1]['message']}                              ${msg}
    
    Should Be Equal As Strings  ${resp.json()[0]['id']}                                   ${rem_id2}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['startDate']}                ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['terminator']['endDate']}    ${DAY2}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['timeSlots'][0]['sTime']}    ${sTime1}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['timeSlots'][0]['eTime']}    ${eTime1}
    Should Be Equal As Strings  ${resp.json()[0]['provider']['id']}                       ${prov_id1}
    Should Be Equal As Strings  ${resp.json()[0]['providerConsumer']['id']}               ${pcid18}
    Should Be Equal As Strings  ${resp.json()[0]['message']}                              ${msg}

JD-TC-GetReminders-3

    [Documentation]    Provider create more than one reminder for his consumer and verify it(with different schedule).

    ${resp}=  Encrypted Provider Login  ${PUSERNAME156}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY3}=  db.add_timezone_date  ${tz}   2
    ${DAY4}=  db.add_timezone_date  ${tz}  12    
    ${list1}=  Create List  1  2  3  4 
    ${sTime2}=  db.get_time_by_timezone  ${tz}  
    ${eTime2}=  db.add_timezone_time  ${tz}  1  15
    ${msg1}=  FakerLibrary.word

    Set Suite Variable  ${DAY3}
    Set Suite Variable  ${DAY4}
    Set Suite Variable  ${list1}
    Set Suite Variable  ${sTime2}
    Set Suite Variable  ${eTime2}
    Set Suite Variable  ${msg1}

    ${resp}=  Create Reminder    ${prov_id1}  ${pcid18}  ${msg1}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${recurringtype[1]}  ${list1}  ${DAY3}  ${DAY4}  ${EMPTY}  ${sTime2}  ${eTime2} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${rem_id3}  ${resp.content}

    ${resp}=    Get Reminders 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[2]['id']}                                   ${rem_id1}
    Should Be Equal As Strings  ${resp.json()[2]['schedule']['startDate']}                ${DAY1}
    Should Be Equal As Strings  ${resp.json()[2]['schedule']['terminator']['endDate']}    ${DAY2}
    Should Be Equal As Strings  ${resp.json()[2]['schedule']['timeSlots'][0]['sTime']}    ${sTime1}
    Should Be Equal As Strings  ${resp.json()[2]['schedule']['timeSlots'][0]['eTime']}    ${eTime1}
    Should Be Equal As Strings  ${resp.json()[2]['provider']['id']}                       ${prov_id1}
    Should Be Equal As Strings  ${resp.json()[2]['providerConsumer']['id']}               ${pcid18}
    Should Be Equal As Strings  ${resp.json()[2]['message']}                              ${msg}
   
    Should Be Equal As Strings  ${resp.json()[1]['id']}                                   ${rem_id2}
    Should Be Equal As Strings  ${resp.json()[1]['schedule']['startDate']}                ${DAY1}
    Should Be Equal As Strings  ${resp.json()[1]['schedule']['terminator']['endDate']}    ${DAY2}
    Should Be Equal As Strings  ${resp.json()[1]['schedule']['timeSlots'][0]['sTime']}    ${sTime1}
    Should Be Equal As Strings  ${resp.json()[1]['schedule']['timeSlots'][0]['eTime']}    ${eTime1}
    Should Be Equal As Strings  ${resp.json()[1]['provider']['id']}                       ${prov_id1}
    Should Be Equal As Strings  ${resp.json()[1]['providerConsumer']['id']}               ${pcid18}
    Should Be Equal As Strings  ${resp.json()[1]['message']}                              ${msg}
   
    Should Be Equal As Strings  ${resp.json()[0]['id']}                                   ${rem_id3}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['startDate']}                ${DAY3}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['terminator']['endDate']}    ${DAY4}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['timeSlots'][0]['sTime']}    ${sTime2}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['timeSlots'][0]['eTime']}    ${eTime2}
    Should Be Equal As Strings  ${resp.json()[0]['provider']['id']}                       ${prov_id1}
    Should Be Equal As Strings  ${resp.json()[0]['providerConsumer']['id']}               ${pcid18}
    Should Be Equal As Strings  ${resp.json()[0]['message']}                              ${msg1}
   
JD-TC-GetReminders-4

    [Documentation]    Provider create more than one reminder for his consumers and verify it(with same schedule).

    ${resp}=  Encrypted Provider Login  ${PUSERNAME156}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME13}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME13}  
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${pcid13}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${pcid13}  ${resp.json()[0]['id']}
    END

    ${resp}=  Create Reminder    ${prov_id1}  ${pcid13}  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${rem_id4}  ${resp.content}

    ${resp}=    Get Reminders 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[3]['id']}                                   ${rem_id1}
    Should Be Equal As Strings  ${resp.json()[3]['schedule']['startDate']}                ${DAY1}
    Should Be Equal As Strings  ${resp.json()[3]['schedule']['terminator']['endDate']}    ${DAY2}
    Should Be Equal As Strings  ${resp.json()[3]['schedule']['timeSlots'][0]['sTime']}    ${sTime1}
    Should Be Equal As Strings  ${resp.json()[3]['schedule']['timeSlots'][0]['eTime']}    ${eTime1}
    Should Be Equal As Strings  ${resp.json()[3]['provider']['id']}                       ${prov_id1}
    Should Be Equal As Strings  ${resp.json()[3]['providerConsumer']['id']}               ${pcid18}
    Should Be Equal As Strings  ${resp.json()[3]['message']}                              ${msg}
    
    Should Be Equal As Strings  ${resp.json()[2]['id']}                                   ${rem_id2}
    Should Be Equal As Strings  ${resp.json()[2]['schedule']['startDate']}                ${DAY1}
    Should Be Equal As Strings  ${resp.json()[2]['schedule']['terminator']['endDate']}    ${DAY2}
    Should Be Equal As Strings  ${resp.json()[2]['schedule']['timeSlots'][0]['sTime']}    ${sTime1}
    Should Be Equal As Strings  ${resp.json()[2]['schedule']['timeSlots'][0]['eTime']}    ${eTime1}
    Should Be Equal As Strings  ${resp.json()[2]['provider']['id']}                       ${prov_id1}
    Should Be Equal As Strings  ${resp.json()[2]['providerConsumer']['id']}               ${pcid18}
    Should Be Equal As Strings  ${resp.json()[2]['message']}                              ${msg}
   
    Should Be Equal As Strings  ${resp.json()[1]['id']}                                   ${rem_id3}
    Should Be Equal As Strings  ${resp.json()[1]['schedule']['startDate']}                ${DAY3}
    Should Be Equal As Strings  ${resp.json()[1]['schedule']['terminator']['endDate']}    ${DAY4}
    Should Be Equal As Strings  ${resp.json()[1]['schedule']['timeSlots'][0]['sTime']}    ${sTime2}
    Should Be Equal As Strings  ${resp.json()[1]['schedule']['timeSlots'][0]['eTime']}    ${eTime2}
    Should Be Equal As Strings  ${resp.json()[1]['provider']['id']}                       ${prov_id1}
    Should Be Equal As Strings  ${resp.json()[1]['providerConsumer']['id']}               ${pcid18}
    Should Be Equal As Strings  ${resp.json()[1]['message']}                              ${msg1}
   
    Should Be Equal As Strings  ${resp.json()[0]['id']}                                   ${rem_id4}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['startDate']}                ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['terminator']['endDate']}    ${DAY2}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['timeSlots'][0]['sTime']}    ${sTime1}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['timeSlots'][0]['eTime']}    ${eTime1}
    Should Be Equal As Strings  ${resp.json()[0]['provider']['id']}                       ${prov_id1}
    Should Be Equal As Strings  ${resp.json()[0]['providerConsumer']['id']}               ${pcid13}
    Should Be Equal As Strings  ${resp.json()[0]['message']}                              ${msg}

JD-TC-GetReminders-5

    [Documentation]    Provider create more than one reminder for his consumers and verify it(with different schedule).

    ${resp}=  Encrypted Provider Login  ${PUSERNAME156}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY5}=  db.add_timezone_date  ${tz}   3
    ${DAY6}=  db.add_timezone_date  ${tz}  10   
    ${list2}=  Create List  1  2  3  
    ${sTime3}=  db.add_timezone_time  ${tz}  0  45  
    ${eTime3}=  db.add_timezone_time  ${tz}  2  15
    ${msg2}=  FakerLibrary.word

    Set Suite Variable  ${DAY5}
    Set Suite Variable  ${DAY6}
    Set Suite Variable  ${list2}
    Set Suite Variable  ${sTime3}
    Set Suite Variable  ${eTime3}
    Set Suite Variable  ${msg2}

    ${resp}=  Create Reminder    ${prov_id1}  ${pcid13}  ${msg2}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${recurringtype[1]}  ${list2}  ${DAY5}  ${DAY6}  ${EMPTY}  ${sTime3}  ${eTime3} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${rem_id5}  ${resp.content}

    ${resp}=    Get Reminders 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[4]['id']}                                   ${rem_id1}
    Should Be Equal As Strings  ${resp.json()[4]['schedule']['startDate']}                ${DAY1}
    Should Be Equal As Strings  ${resp.json()[4]['schedule']['terminator']['endDate']}    ${DAY2}
    Should Be Equal As Strings  ${resp.json()[4]['schedule']['timeSlots'][0]['sTime']}    ${sTime1}
    Should Be Equal As Strings  ${resp.json()[4]['schedule']['timeSlots'][0]['eTime']}    ${eTime1}
    Should Be Equal As Strings  ${resp.json()[4]['provider']['id']}                       ${prov_id1}
    Should Be Equal As Strings  ${resp.json()[4]['providerConsumer']['id']}               ${pcid18}
    Should Be Equal As Strings  ${resp.json()[4]['message']}                              ${msg}
    
    Should Be Equal As Strings  ${resp.json()[3]['id']}                                   ${rem_id2}
    Should Be Equal As Strings  ${resp.json()[3]['schedule']['startDate']}                ${DAY1}
    Should Be Equal As Strings  ${resp.json()[3]['schedule']['terminator']['endDate']}    ${DAY2}
    Should Be Equal As Strings  ${resp.json()[3]['schedule']['timeSlots'][0]['sTime']}    ${sTime1}
    Should Be Equal As Strings  ${resp.json()[3]['schedule']['timeSlots'][0]['eTime']}    ${eTime1}
    Should Be Equal As Strings  ${resp.json()[3]['provider']['id']}                       ${prov_id1}
    Should Be Equal As Strings  ${resp.json()[3]['providerConsumer']['id']}               ${pcid18}
    Should Be Equal As Strings  ${resp.json()[3]['message']}                              ${msg}
   
    Should Be Equal As Strings  ${resp.json()[2]['id']}                                   ${rem_id3}
    Should Be Equal As Strings  ${resp.json()[2]['schedule']['startDate']}                ${DAY3}
    Should Be Equal As Strings  ${resp.json()[2]['schedule']['terminator']['endDate']}    ${DAY4}
    Should Be Equal As Strings  ${resp.json()[2]['schedule']['timeSlots'][0]['sTime']}    ${sTime2}
    Should Be Equal As Strings  ${resp.json()[2]['schedule']['timeSlots'][0]['eTime']}    ${eTime2}
    Should Be Equal As Strings  ${resp.json()[2]['provider']['id']}                       ${prov_id1}
    Should Be Equal As Strings  ${resp.json()[2]['providerConsumer']['id']}               ${pcid18}
    Should Be Equal As Strings  ${resp.json()[2]['message']}                              ${msg1}
   
    Should Be Equal As Strings  ${resp.json()[1]['id']}                                   ${rem_id4}
    Should Be Equal As Strings  ${resp.json()[1]['schedule']['startDate']}                ${DAY1}
    Should Be Equal As Strings  ${resp.json()[1]['schedule']['terminator']['endDate']}    ${DAY2}
    Should Be Equal As Strings  ${resp.json()[1]['schedule']['timeSlots'][0]['sTime']}    ${sTime1}
    Should Be Equal As Strings  ${resp.json()[1]['schedule']['timeSlots'][0]['eTime']}    ${eTime1}
    Should Be Equal As Strings  ${resp.json()[1]['provider']['id']}                       ${prov_id1}
    Should Be Equal As Strings  ${resp.json()[1]['providerConsumer']['id']}               ${pcid13}
    Should Be Equal As Strings  ${resp.json()[1]['message']}                              ${msg}

    Should Be Equal As Strings  ${resp.json()[0]['id']}                                   ${rem_id5}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['startDate']}                ${DAY5}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['terminator']['endDate']}    ${DAY6}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['timeSlots'][0]['sTime']}    ${sTime3}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['timeSlots'][0]['eTime']}    ${eTime3}
    Should Be Equal As Strings  ${resp.json()[0]['provider']['id']}                       ${prov_id1}
    Should Be Equal As Strings  ${resp.json()[0]['providerConsumer']['id']}               ${pcid13}
    Should Be Equal As Strings  ${resp.json()[0]['message']}                              ${msg2}

JD-TC-GetReminders-6

    [Documentation]    Get reminder with filter id.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME156}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Reminders   Id-eq=${rem_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['id']}                                   ${rem_id1}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['startDate']}                ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['terminator']['endDate']}    ${DAY2}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['timeSlots'][0]['sTime']}    ${sTime1}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['timeSlots'][0]['eTime']}    ${eTime1}
    Should Be Equal As Strings  ${resp.json()[0]['provider']['id']}                       ${prov_id1}
    Should Be Equal As Strings  ${resp.json()[0]['providerConsumer']['id']}               ${pcid18}
    Should Be Equal As Strings  ${resp.json()[0]['message']}                              ${msg}

JD-TC-GetReminders-7

    [Documentation]    Get reminder with filter id.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME156}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Reminders   startDate-eq=${DAY5}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['id']}                                   ${rem_id5}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['startDate']}                ${DAY5}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['terminator']['endDate']}    ${DAY6}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['timeSlots'][0]['sTime']}    ${sTime3}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['timeSlots'][0]['eTime']}    ${eTime3}
    Should Be Equal As Strings  ${resp.json()[0]['provider']['id']}                       ${prov_id1}
    Should Be Equal As Strings  ${resp.json()[0]['providerConsumer']['id']}               ${pcid13}
    Should Be Equal As Strings  ${resp.json()[0]['message']}                              ${msg2}

JD-TC-GetReminders-UH1

    [Documentation]    Get reminder without login.

    ${resp}=    Get Reminders   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.content}  "${SESSION_EXPIRED}"

JD-TC-GetReminders-UH2

    [Documentation]    Get reminder with consumer login.

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Reminders   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  ${resp.content}  "${LOGIN_NO_ACCESS_FOR_URL}"