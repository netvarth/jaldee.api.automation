*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Reminder
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           random
Library           /ebs/TDD/Imageupload.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/hl_providers.py

*** Test Cases ***

JD-TC-GetProviderRemindersWithFilter-1

    [Documentation]  Create a provider reminder with all details and verify the details with filter.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME70}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable      ${pro_id}  ${decrypted_data['id']}
    Set Test Variable      ${fname}   ${decrypted_data['firstName']}
    Set Test Variable      ${lname}   ${decrypted_data['lastName']}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}
    Set Test Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  3  15  
    ${eTime1}=  add_timezone_time  ${tz}  3  15  
    ${msg}=  FakerLibrary.word
    ${rem_name}=  FakerLibrary.first_name
    ${prov_detail}=  Create Dictionary   id=${pro_id}
    ${prov_details}=  Create List  ${prov_detail}
    ${remindersource}=  Create Dictionary    Sms=${bool[1]}   Email=${bool[1]}  PushNotification=${bool[1]}  Whatsapp=${bool[1]}

    ${resp}=  Create Provider Reminder    ${rem_name}  ${prov_details}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}   ${sTime1}  ${eTime1}  ${msg}   ${remindersource}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${rem_id1}  ${resp.content}

    ${resp}=   Get Provider Reminders With Filter
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}                                   ${rem_id1}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}                            ${account_id}
    Should Be Equal As Strings  ${resp.json()[0]['reminderName']}                         ${rem_name}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['startDate']}                ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['terminator']['endDate']}    ${DAY2}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['timeSlots'][0]['sTime']}    ${sTime1}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['timeSlots'][0]['eTime']}    ${eTime1}  
    Should Be Equal As Strings  ${resp.json()[0]['message']}                              ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['reminderSource']['Email']}              1
    Should Be Equal As Strings  ${resp.json()[0]['reminderSource']['Sms']}                1
    Should Be Equal As Strings  ${resp.json()[0]['reminderSource']['Whatsapp']}           1
    Should Be Equal As Strings  ${resp.json()[0]['reminderSource']['PushNotification']}   1
    Should Be Equal As Strings  ${resp.json()[0]['completed']}                            ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[0]['reminderForProvider']}                  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['users'][0]['id']}                       ${pro_id}
    Should Be Equal As Strings  ${resp.json()[0]['users'][0]['firstName']}                ${fname}
    Should Be Equal As Strings  ${resp.json()[0]['users'][0]['lastName']}                 ${lname}
