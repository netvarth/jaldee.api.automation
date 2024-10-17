*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Reminder
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library         /ebs/TDD/CustomKeywords.py
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
    Set Test Variable  ${tz}  ${resp.json()['baseLocation']['timezone']}

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

JD-TC-GetProviderRemindersWithFilter-2

    [Documentation]  Create three provider reminder with all details and verify the details with filter.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME71}  ${PASSWORD}
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
    Set Test Variable  ${tz}  ${resp.json()['baseLocation']['timezone']}

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

    ${DAY3}=  db.get_date_by_timezone  ${tz}
    ${DAY4}=  db.get_date_by_timezone  ${tz}
    ${list1}=  Create List  1  2
    ${sTime2}=  add_timezone_time  ${tz}  0  15  
    ${eTime2}=  add_timezone_time  ${tz}  0  15  
    ${msg1}=  FakerLibrary.word
    ${rem_name1}=  FakerLibrary.first_name
    ${remindersource1}=  Create Dictionary     Email=${bool[1]}  PushNotification=${bool[1]}  

    ${resp}=  Create Provider Reminder    ${rem_name1}  ${prov_details}  ${recurringtype[1]}  ${list1}  ${DAY3}  ${DAY4}   ${sTime2}  ${eTime2}  ${msg1}   ${remindersource1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${rem_id2}  ${resp.content}

    ${DAY5}=  db.add_timezone_date  ${tz}  1
    ${DAY6}=  db.add_timezone_date  ${tz}  21
    ${list2}=  Create List  1  2  3
    ${sTime3}=  add_timezone_time  ${tz}  0  30  
    ${eTime3}=  add_timezone_time  ${tz}  0  30  
    ${msg2}=  FakerLibrary.word
    ${rem_name2}=  FakerLibrary.first_name
    ${remindersource2}=  Create Dictionary     PushNotification=${bool[1]}  

    ${resp}=  Create Provider Reminder    ${rem_name2}  ${prov_details}  ${recurringtype[1]}  ${list2}  ${DAY5}  ${DAY6}   ${sTime3}  ${eTime3}  ${msg2}   ${remindersource2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${rem_id3}  ${resp.content}

    ${resp}=   Get Provider Reminders With Filter
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}                                   ${rem_id3}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}                            ${account_id}
    Should Be Equal As Strings  ${resp.json()[0]['reminderName']}                         ${rem_name2}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['startDate']}                ${DAY5}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['terminator']['endDate']}    ${DAY6}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['timeSlots'][0]['sTime']}    ${sTime3}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['timeSlots'][0]['eTime']}    ${eTime3}  
    Should Be Equal As Strings  ${resp.json()[0]['message']}                              ${msg2}
    Should Be Equal As Strings  ${resp.json()[0]['reminderSource']['Email']}              0
    Should Be Equal As Strings  ${resp.json()[0]['reminderSource']['Sms']}                0
    Should Be Equal As Strings  ${resp.json()[0]['reminderSource']['Whatsapp']}           0
    Should Be Equal As Strings  ${resp.json()[0]['reminderSource']['PushNotification']}   1
    Should Be Equal As Strings  ${resp.json()[0]['completed']}                            ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[0]['reminderForProvider']}                  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['users'][0]['id']}                       ${pro_id}
    Should Be Equal As Strings  ${resp.json()[0]['users'][0]['firstName']}                ${fname}
    Should Be Equal As Strings  ${resp.json()[0]['users'][0]['lastName']}                 ${lname}

    Should Be Equal As Strings  ${resp.json()[1]['id']}                                   ${rem_id2}
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}                            ${account_id}
    Should Be Equal As Strings  ${resp.json()[1]['reminderName']}                         ${rem_name1}
    Should Be Equal As Strings  ${resp.json()[1]['schedule']['startDate']}                ${DAY3}
    Should Be Equal As Strings  ${resp.json()[1]['schedule']['terminator']['endDate']}    ${DAY4}
    Should Be Equal As Strings  ${resp.json()[1]['schedule']['timeSlots'][0]['sTime']}    ${sTime2}
    Should Be Equal As Strings  ${resp.json()[1]['schedule']['timeSlots'][0]['eTime']}    ${eTime2}  
    Should Be Equal As Strings  ${resp.json()[1]['message']}                              ${msg1}
    Should Be Equal As Strings  ${resp.json()[1]['reminderSource']['Email']}              1
    Should Be Equal As Strings  ${resp.json()[1]['reminderSource']['Sms']}                0
    Should Be Equal As Strings  ${resp.json()[1]['reminderSource']['Whatsapp']}           0
    Should Be Equal As Strings  ${resp.json()[1]['reminderSource']['PushNotification']}   1
    Should Be Equal As Strings  ${resp.json()[1]['completed']}                            ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[1]['reminderForProvider']}                  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[1]['users'][0]['id']}                       ${pro_id}
    Should Be Equal As Strings  ${resp.json()[1]['users'][0]['firstName']}                ${fname}
    Should Be Equal As Strings  ${resp.json()[1]['users'][0]['lastName']}                 ${lname}

    Should Be Equal As Strings  ${resp.json()[2]['id']}                                   ${rem_id1}
    Should Be Equal As Strings  ${resp.json()[2]['accountId']}                            ${account_id}
    Should Be Equal As Strings  ${resp.json()[2]['reminderName']}                         ${rem_name}
    Should Be Equal As Strings  ${resp.json()[2]['schedule']['startDate']}                ${DAY1}
    Should Be Equal As Strings  ${resp.json()[2]['schedule']['terminator']['endDate']}    ${DAY2}
    Should Be Equal As Strings  ${resp.json()[2]['schedule']['timeSlots'][0]['sTime']}    ${sTime1}
    Should Be Equal As Strings  ${resp.json()[2]['schedule']['timeSlots'][0]['eTime']}    ${eTime1}  
    Should Be Equal As Strings  ${resp.json()[2]['message']}                              ${msg}
    Should Be Equal As Strings  ${resp.json()[2]['reminderSource']['Email']}              1
    Should Be Equal As Strings  ${resp.json()[2]['reminderSource']['Sms']}                1
    Should Be Equal As Strings  ${resp.json()[2]['reminderSource']['Whatsapp']}           1
    Should Be Equal As Strings  ${resp.json()[2]['reminderSource']['PushNotification']}   1
    Should Be Equal As Strings  ${resp.json()[2]['completed']}                            ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[2]['reminderForProvider']}                  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[2]['users'][0]['id']}                       ${pro_id}
    Should Be Equal As Strings  ${resp.json()[2]['users'][0]['firstName']}                ${fname}
    Should Be Equal As Strings  ${resp.json()[2]['users'][0]['lastName']}                 ${lname}

JD-TC-GetProviderRemindersWithFilter-3

    [Documentation]  Create three provider reminder with all details and verify the details with remindername filter.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME72}  ${PASSWORD}
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
    Set Test Variable  ${tz}  ${resp.json()['baseLocation']['timezone']}

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

    ${DAY3}=  db.get_date_by_timezone  ${tz}
    ${DAY4}=  db.get_date_by_timezone  ${tz}
    ${list1}=  Create List  1  2
    ${sTime2}=  add_timezone_time  ${tz}  0  15  
    ${eTime2}=  add_timezone_time  ${tz}  0  15  
    ${msg1}=  FakerLibrary.word
    ${remindersource1}=  Create Dictionary     Email=${bool[1]}  PushNotification=${bool[1]}  

    ${resp}=  Create Provider Reminder    ${rem_name}  ${prov_details}  ${recurringtype[1]}  ${list1}  ${DAY3}  ${DAY4}   ${sTime2}  ${eTime2}  ${msg1}   ${remindersource1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${rem_id2}  ${resp.content}

    ${DAY5}=  db.add_timezone_date  ${tz}  1
    ${DAY6}=  db.add_timezone_date  ${tz}  21
    ${list2}=  Create List  1  2  3
    ${sTime3}=  add_timezone_time  ${tz}  0  30  
    ${eTime3}=  add_timezone_time  ${tz}  0  30  
    ${msg2}=  FakerLibrary.word
    ${rem_name2}=  FakerLibrary.first_name
    ${remindersource2}=  Create Dictionary     PushNotification=${bool[1]}  

    ${resp}=  Create Provider Reminder    ${rem_name2}  ${prov_details}  ${recurringtype[1]}  ${list2}  ${DAY5}  ${DAY6}   ${sTime3}  ${eTime3}  ${msg2}   ${remindersource2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${rem_id3}  ${resp.content}

    ${resp}=   Get Provider Reminders With Filter  reminderName-eq=${rem_name}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}                                   ${rem_id2}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}                            ${account_id}
    Should Be Equal As Strings  ${resp.json()[0]['reminderName']}                         ${rem_name}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['startDate']}                ${DAY3}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['terminator']['endDate']}    ${DAY4}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['timeSlots'][0]['sTime']}    ${sTime2}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['timeSlots'][0]['eTime']}    ${eTime2}  
    Should Be Equal As Strings  ${resp.json()[0]['message']}                              ${msg1}
    Should Be Equal As Strings  ${resp.json()[0]['reminderSource']['Email']}              1
    Should Be Equal As Strings  ${resp.json()[0]['reminderSource']['Sms']}                0
    Should Be Equal As Strings  ${resp.json()[0]['reminderSource']['Whatsapp']}           0
    Should Be Equal As Strings  ${resp.json()[0]['reminderSource']['PushNotification']}   1
    Should Be Equal As Strings  ${resp.json()[0]['completed']}                            ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[0]['reminderForProvider']}                  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['users'][0]['id']}                       ${pro_id}
    Should Be Equal As Strings  ${resp.json()[0]['users'][0]['firstName']}                ${fname}
    Should Be Equal As Strings  ${resp.json()[0]['users'][0]['lastName']}                 ${lname}

    Should Be Equal As Strings  ${resp.json()[1]['id']}                                   ${rem_id1}
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}                            ${account_id}
    Should Be Equal As Strings  ${resp.json()[1]['reminderName']}                         ${rem_name}
    Should Be Equal As Strings  ${resp.json()[1]['schedule']['startDate']}                ${DAY1}
    Should Be Equal As Strings  ${resp.json()[1]['schedule']['terminator']['endDate']}    ${DAY2}
    Should Be Equal As Strings  ${resp.json()[1]['schedule']['timeSlots'][0]['sTime']}    ${sTime1}
    Should Be Equal As Strings  ${resp.json()[1]['schedule']['timeSlots'][0]['eTime']}    ${eTime1}  
    Should Be Equal As Strings  ${resp.json()[1]['message']}                              ${msg}
    Should Be Equal As Strings  ${resp.json()[1]['reminderSource']['Email']}              1
    Should Be Equal As Strings  ${resp.json()[1]['reminderSource']['Sms']}                1
    Should Be Equal As Strings  ${resp.json()[1]['reminderSource']['Whatsapp']}           1
    Should Be Equal As Strings  ${resp.json()[1]['reminderSource']['PushNotification']}   1
    Should Be Equal As Strings  ${resp.json()[1]['completed']}                            ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[1]['reminderForProvider']}                  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[1]['users'][0]['id']}                       ${pro_id}
    Should Be Equal As Strings  ${resp.json()[1]['users'][0]['firstName']}                ${fname}
    Should Be Equal As Strings  ${resp.json()[1]['users'][0]['lastName']}                 ${lname}

    