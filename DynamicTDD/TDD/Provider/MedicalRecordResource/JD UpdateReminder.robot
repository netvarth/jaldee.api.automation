*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Reminder
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/hl_providers.py


*** Variables ***

@{emptylist}


*** Test Cases ***

JD-TC-UpdateReminder-1

    [Documentation]    Provider create a reminder for his consumer and update it with the same details.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME135}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${prov_id1}  ${decrypted_data['id']}
    # Set Suite Variable  ${prov_id1}  ${resp.json()['id']}

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

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ELSE
        Set Suite Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10    
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.add_timezone_time  ${tz}  0  15
    ${eTime1}=  db.add_timezone_time  ${tz}  3  15
    ${msg}=  FakerLibrary.word

    ${resp}=  Create Reminder    ${prov_id1}  ${pcid18}  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${rem_id}  ${resp.content}

    ${resp}=    Get Reminders 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['id']}                                   ${rem_id}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['startDate']}                ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['terminator']['endDate']}    ${DAY2}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['timeSlots'][0]['sTime']}    ${sTime1}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['timeSlots'][0]['eTime']}    ${eTime1}
    Should Be Equal As Strings  ${resp.json()[0]['provider']['id']}                       ${prov_id1}
    Should Be Equal As Strings  ${resp.json()[0]['providerConsumer']['id']}               ${pcid18}
    Should Be Equal As Strings  ${resp.json()[0]['message']}                              ${msg}

    ${rem_id}=  convert To String  ${rem_id} 
    Set Suite Variable   ${rem_id} 

    ${resp}=  Update Reminder   ${rem_id}  ${prov_id1}  ${pcid18}  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Reminders 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['id']}                                   ${rem_id}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['startDate']}                ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['terminator']['endDate']}    ${DAY2}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['timeSlots'][0]['sTime']}    ${sTime1}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['timeSlots'][0]['eTime']}    ${eTime1}
    Should Be Equal As Strings  ${resp.json()[0]['provider']['id']}                       ${prov_id1}
    Should Be Equal As Strings  ${resp.json()[0]['providerConsumer']['id']}               ${pcid18}
    Should Be Equal As Strings  ${resp.json()[0]['message']}                              ${msg}
    
JD-TC-UpdateReminder-2

    [Documentation]    Provider create a reminder for his consumer and update it for another consumer.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME135}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME11}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME11}  
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${pcid11}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${pcid11}  ${resp.json()[0]['id']}
    END

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10    
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.add_timezone_time  ${tz}  0  15
    ${eTime1}=  db.add_timezone_time  ${tz}  3  15
    ${msg}=  FakerLibrary.word

    ${resp}=  Update Reminder   ${rem_id}  ${prov_id1}  ${pcid11}  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Reminders 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['id']}                                   ${rem_id}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['startDate']}                ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['terminator']['endDate']}    ${DAY2}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['timeSlots'][0]['sTime']}    ${sTime1}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['timeSlots'][0]['eTime']}    ${eTime1}
    Should Be Equal As Strings  ${resp.json()[0]['provider']['id']}                       ${prov_id1}
    Should Be Equal As Strings  ${resp.json()[0]['providerConsumer']['id']}               ${pcid11}
    Should Be Equal As Strings  ${resp.json()[0]['message']}                              ${msg}

JD-TC-UpdateReminder-3

    [Documentation]    Provider create a reminder for his consumer and update it for a short date range.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME135}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY1}=  db.add_timezone_date  ${tz}  2
    ${DAY2}=  db.add_timezone_date  ${tz}  4    
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.add_timezone_time  ${tz}  0  15
    ${eTime1}=  db.add_timezone_time  ${tz}  3  15
    ${msg}=  FakerLibrary.word

    ${resp}=  Update Reminder   ${rem_id}  ${prov_id1}  ${pcid11}  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Reminders 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['id']}                                   ${rem_id}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['startDate']}                ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['terminator']['endDate']}    ${DAY2}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['timeSlots'][0]['sTime']}    ${sTime1}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['timeSlots'][0]['eTime']}    ${eTime1}
    Should Be Equal As Strings  ${resp.json()[0]['provider']['id']}                       ${prov_id1}
    Should Be Equal As Strings  ${resp.json()[0]['providerConsumer']['id']}               ${pcid11}
    Should Be Equal As Strings  ${resp.json()[0]['message']}                              ${msg}
    

JD-TC-UpdateReminder-UH1

    [Documentation]    Provider create a reminder for his consumer and update it without message.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME135}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10    
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.add_timezone_time  ${tz}  0  15
    ${eTime1}=  db.add_timezone_time  ${tz}  3  15
    
    ${resp}=  Update Reminder   ${rem_id}  ${prov_id1}  ${pcid11}  ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${INVALID_MESSAGE}"

# JD-TC-UpdateReminder-UH2

#     [Documentation]    Provider create a reminder for his consumer and update it without reminder id.

#     ${resp}=  Encrypted Provider Login  ${PUSERNAME135}  ${PASSWORD}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${DAY1}=  db.get_date_by_timezone  ${tz}
#     ${DAY2}=  db.add_timezone_date  ${tz}  10    
#     ${list}=  Create List  1  2  3  4  5  6  7
#     ${sTime1}=  db.add_timezone_time  ${tz}  0  15
#     ${eTime1}=  db.add_timezone_time  ${tz}  3  15
#     ${msg}=  FakerLibrary.word

#     ${resp}=  Update Reminder   ${EMPTY}  ${prov_id1}  ${pcid11}  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1} 
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  422
    
    