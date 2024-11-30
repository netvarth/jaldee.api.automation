*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Reminder
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           random
Library           /ebs/TDD/CustomKeywords.py
Library           /ebs/TDD/Imageupload.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/hl_providers.py

*** Test Cases ***

JD-TC-GetProviderReminderById-1

    [Documentation]  Create a provider reminder with all details and verify the details by id..

    ${resp}=  Encrypted Provider Login  ${PUSERNAME160}  ${PASSWORD}
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
    ${rem_name}=  generate_firstname
    ${prov_detail}=  Create Dictionary   id=${pro_id}
    ${prov_details}=  Create List  ${prov_detail}
    ${remindersource}=  Create Dictionary    Sms=${bool[1]}   Email=${bool[1]}  PushNotification=${bool[1]}  Whatsapp=${bool[1]}

    ${resp}=  Create Provider Reminder    ${rem_name}  ${prov_details}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}   ${sTime1}  ${eTime1}  ${msg}   ${remindersource}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${rem_id1}  ${resp.content}

    ${resp}=   Get Provider Reminder By Id   ${rem_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}                                   ${rem_id1}
    Should Be Equal As Strings  ${resp.json()['accountId']}                            ${account_id}
    Should Be Equal As Strings  ${resp.json()['reminderName']}                         ${rem_name}
    Should Be Equal As Strings  ${resp.json()['schedule']['startDate']}                ${DAY1}
    Should Be Equal As Strings  ${resp.json()['schedule']['terminator']['endDate']}    ${DAY2}
    Should Be Equal As Strings  ${resp.json()['schedule']['timeSlots'][0]['sTime']}    ${sTime1}
    Should Be Equal As Strings  ${resp.json()['schedule']['timeSlots'][0]['eTime']}    ${eTime1}  
    Should Be Equal As Strings  ${resp.json()['message']}                              ${msg}
    Should Be Equal As Strings  ${resp.json()['reminderSource']['Email']}              1
    Should Be Equal As Strings  ${resp.json()['reminderSource']['Sms']}                1
    Should Be Equal As Strings  ${resp.json()['reminderSource']['Whatsapp']}           1
    Should Be Equal As Strings  ${resp.json()['reminderSource']['PushNotification']}   1
    Should Be Equal As Strings  ${resp.json()['completed']}                            ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['reminderForProvider']}                  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['users'][0]['id']}                       ${pro_id}
    Should Be Equal As Strings  ${resp.json()['users'][0]['firstName']}                ${fname}
    Should Be Equal As Strings  ${resp.json()['users'][0]['lastName']}                 ${lname}

JD-TC-GetProviderReminderById-2

    [Documentation]  Create a provider reminder for a user..

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable      ${pro_id}  ${decrypted_data['id']}
    
    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}
    Set Test Variable  ${tz}  ${resp.json()['baseLocation']['timezone']}

    ${ufname1}=  FakerLibrary.name
    ${ulname1}=  FakerLibrary.last_name
    ${PO_Number}    Generate random string    7    ${digits} 
    ${p_num}    Convert To Integer  ${PO_Number}
    ${PUSERNAME}=  Evaluate  ${PUSERNAME}+${p_num}
    Set Test Variable  ${USERNAME1}  ${PUSERNAME}

    ${resp}=  Create User  ${ufname1}  ${ulname1}   ${countryCodes[0]}  ${USERNAME1}  ${userType[0]}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id}  ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  3  15  
    ${eTime1}=  add_timezone_time  ${tz}  3  15  
    ${msg}=  FakerLibrary.word
    ${rem_name}=  generate_firstname
    ${prov_detail}=  Create Dictionary   id=${u_id}
    ${prov_details}=  Create List  ${prov_detail}
    ${remindersource}=  Create Dictionary    Sms=${bool[1]}   Email=${bool[1]}  PushNotification=${bool[1]}  Whatsapp=${bool[1]}

    ${resp}=  Create Provider Reminder    ${rem_name}  ${prov_details}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}   ${sTime1}  ${eTime1}  ${msg}   ${remindersource}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${rem_id1}  ${resp.content}

    ${resp}=   Get Provider Reminder By Id   ${rem_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}                                   ${rem_id1}
    Should Be Equal As Strings  ${resp.json()['accountId']}                            ${account_id}
    Should Be Equal As Strings  ${resp.json()['reminderName']}                         ${rem_name}
    Should Be Equal As Strings  ${resp.json()['schedule']['startDate']}                ${DAY1}
    Should Be Equal As Strings  ${resp.json()['schedule']['terminator']['endDate']}    ${DAY2}
    Should Be Equal As Strings  ${resp.json()['schedule']['timeSlots'][0]['sTime']}    ${sTime1}
    Should Be Equal As Strings  ${resp.json()['schedule']['timeSlots'][0]['eTime']}    ${eTime1}  
    Should Be Equal As Strings  ${resp.json()['message']}                              ${msg}
    Should Be Equal As Strings  ${resp.json()['reminderSource']['Email']}              1
    Should Be Equal As Strings  ${resp.json()['reminderSource']['Sms']}                1
    Should Be Equal As Strings  ${resp.json()['reminderSource']['Whatsapp']}           1
    Should Be Equal As Strings  ${resp.json()['reminderSource']['PushNotification']}   1
    Should Be Equal As Strings  ${resp.json()['completed']}                            ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['reminderForProvider']}                  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['users'][0]['id']}                       ${u_id}
    Should Be Equal As Strings  ${resp.json()['users'][0]['firstName']}                ${ufname1}
    Should Be Equal As Strings  ${resp.json()['users'][0]['lastName']}                 ${ulname1}

JD-TC-GetProviderReminderById-3

    [Documentation]  Create a provider reminder for main account and two other users...

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME5}  ${PASSWORD}
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

    ${ufname1}=  FakerLibrary.name
    ${ulname1}=  FakerLibrary.last_name
    ${PO_Number}    Generate random string    7    ${digits} 
    ${p_num}    Convert To Integer  ${PO_Number}
    ${PUSERNAME}=  Evaluate  ${PUSERNAME}+${p_num}
    Set Test Variable  ${USERNAME1}  ${PUSERNAME}

    ${resp}=  Create User  ${ufname1}  ${ulname1}   ${countryCodes[0]}  ${USERNAME1}  ${userType[0]}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id1}  ${resp.json()}

    ${ufname2}=  FakerLibrary.name
    ${ulname2}=  FakerLibrary.last_name
    ${PO_Number}    Generate random string    7    ${digits} 
    ${p_num}    Convert To Integer  ${PO_Number}
    ${PUSERNAME}=  Evaluate  ${PUSERNAME}+${p_num}
    Set Test Variable  ${USERNAME2}  ${PUSERNAME}

    ${resp}=  Create User  ${ufname2}  ${ulname2}   ${countryCodes[0]}  ${USERNAME2}  ${userType[0]}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id2}  ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  3  15  
    ${eTime1}=  add_timezone_time  ${tz}  3  15  
    ${msg}=  FakerLibrary.word
    ${rem_name}=  generate_firstname
    ${prov_detail}=  Create Dictionary   id=${u_id1}
    ${prov_detail1}=  Create Dictionary   id=${u_id2}
    ${prov_detail2}=  Create Dictionary   id=${pro_id}
    ${prov_details}=  Create List  ${prov_detail}  ${prov_detail1}  ${prov_detail2}
    ${remindersource}=  Create Dictionary    Sms=${bool[1]}   Email=${bool[1]}  PushNotification=${bool[1]}  Whatsapp=${bool[1]}

    ${resp}=  Create Provider Reminder    ${rem_name}  ${prov_details}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}   ${sTime1}  ${eTime1}  ${msg}   ${remindersource}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${rem_id1}  ${resp.content}

    ${resp}=   Get Provider Reminder By Id   ${rem_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}                                   ${rem_id1}
    Should Be Equal As Strings  ${resp.json()['accountId']}                            ${account_id}
    Should Be Equal As Strings  ${resp.json()['reminderName']}                         ${rem_name}
    Should Be Equal As Strings  ${resp.json()['schedule']['startDate']}                ${DAY1}
    Should Be Equal As Strings  ${resp.json()['schedule']['terminator']['endDate']}    ${DAY2}
    Should Be Equal As Strings  ${resp.json()['schedule']['timeSlots'][0]['sTime']}    ${sTime1}
    Should Be Equal As Strings  ${resp.json()['schedule']['timeSlots'][0]['eTime']}    ${eTime1}  
    Should Be Equal As Strings  ${resp.json()['message']}                              ${msg}
    Should Be Equal As Strings  ${resp.json()['reminderSource']['Email']}              1
    Should Be Equal As Strings  ${resp.json()['reminderSource']['Sms']}                1
    Should Be Equal As Strings  ${resp.json()['reminderSource']['Whatsapp']}           1
    Should Be Equal As Strings  ${resp.json()['reminderSource']['PushNotification']}   1
    Should Be Equal As Strings  ${resp.json()['completed']}                            ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['reminderForProvider']}                  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['users'][0]['id']}                       ${pro_id}
    Should Be Equal As Strings  ${resp.json()['users'][0]['firstName']}                ${fname}
    Should Be Equal As Strings  ${resp.json()['users'][0]['lastName']}                 ${lname}
    Should Be Equal As Strings  ${resp.json()['users'][1]['id']}                       ${u_id1}
    Should Be Equal As Strings  ${resp.json()['users'][1]['firstName']}                ${ufname1}
    Should Be Equal As Strings  ${resp.json()['users'][1]['lastName']}                 ${ulname1}
    Should Be Equal As Strings  ${resp.json()['users'][2]['id']}                       ${u_id2}
    Should Be Equal As Strings  ${resp.json()['users'][2]['firstName']}                ${ufname2}
    Should Be Equal As Strings  ${resp.json()['users'][2]['lastName']}                 ${ulname2}
    
JD-TC-GetProviderReminderById-4

    [Documentation]  Create a provider reminder with a different provider name.
    #.. In response will get the original providers name.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME161}  ${PASSWORD}
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

    ${diffname1}=  generate_firstname
    ${diflname1}=  FakerLibrary.last_name
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  3  15  
    ${eTime1}=  add_timezone_time  ${tz}  3  15  
    ${msg}=  FakerLibrary.word
    ${rem_name}=  generate_firstname
    ${prov_detail}=  Create Dictionary   id=${pro_id}  firstName=${diffname1}   lastName=${diflname1}
    ${prov_details}=  Create List  ${prov_detail}
    ${remindersource}=  Create Dictionary    Sms=${bool[1]}   Email=${bool[1]}  PushNotification=${bool[1]}  Whatsapp=${bool[1]}

    ${resp}=  Create Provider Reminder    ${rem_name}  ${prov_details}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}   ${sTime1}  ${eTime1}  ${msg}   ${remindersource}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${rem_id1}  ${resp.content}

    ${resp}=   Get Provider Reminder By Id   ${rem_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}                                   ${rem_id1}
    Should Be Equal As Strings  ${resp.json()['accountId']}                            ${account_id}
    Should Be Equal As Strings  ${resp.json()['reminderName']}                         ${rem_name}
    Should Be Equal As Strings  ${resp.json()['schedule']['startDate']}                ${DAY1}
    Should Be Equal As Strings  ${resp.json()['schedule']['terminator']['endDate']}    ${DAY2}
    Should Be Equal As Strings  ${resp.json()['schedule']['timeSlots'][0]['sTime']}    ${sTime1}
    Should Be Equal As Strings  ${resp.json()['schedule']['timeSlots'][0]['eTime']}    ${eTime1}  
    Should Be Equal As Strings  ${resp.json()['message']}                              ${msg}
    Should Be Equal As Strings  ${resp.json()['reminderSource']['Email']}              1
    Should Be Equal As Strings  ${resp.json()['reminderSource']['Sms']}                1
    Should Be Equal As Strings  ${resp.json()['reminderSource']['Whatsapp']}           1
    Should Be Equal As Strings  ${resp.json()['reminderSource']['PushNotification']}   1
    Should Be Equal As Strings  ${resp.json()['completed']}                            ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['reminderForProvider']}                  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['users'][0]['id']}                       ${pro_id}
    Should Be Equal As Strings  ${resp.json()['users'][0]['firstName']}                ${fname}
    Should Be Equal As Strings  ${resp.json()['users'][0]['lastName']}                 ${lname}

JD-TC-GetProviderReminderById-5

    [Documentation]  Create a provider reminder for email only then verify it.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME163}  ${PASSWORD}
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
    ${rem_name}=  generate_firstname
    ${prov_detail}=  Create Dictionary   id=${pro_id}
    ${prov_details}=  Create List  ${prov_detail}
    ${remindersource}=  Create Dictionary     Email=${bool[1]} 

    ${resp}=  Create Provider Reminder    ${rem_name}  ${prov_details}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}   ${sTime1}  ${eTime1}  ${msg}   ${remindersource}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${rem_id1}  ${resp.content}

    ${resp}=   Get Provider Reminder By Id   ${rem_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}                                   ${rem_id1}
    Should Be Equal As Strings  ${resp.json()['accountId']}                            ${account_id}
    Should Be Equal As Strings  ${resp.json()['reminderName']}                         ${rem_name}
    Should Be Equal As Strings  ${resp.json()['schedule']['startDate']}                ${DAY1}
    Should Be Equal As Strings  ${resp.json()['schedule']['terminator']['endDate']}    ${DAY2}
    Should Be Equal As Strings  ${resp.json()['schedule']['timeSlots'][0]['sTime']}    ${sTime1}
    Should Be Equal As Strings  ${resp.json()['schedule']['timeSlots'][0]['eTime']}    ${eTime1}  
    Should Be Equal As Strings  ${resp.json()['message']}                              ${msg}
    Should Be Equal As Strings  ${resp.json()['reminderSource']['Email']}              1
    Should Be Equal As Strings  ${resp.json()['reminderSource']['Sms']}                0
    Should Be Equal As Strings  ${resp.json()['reminderSource']['Whatsapp']}           0
    Should Be Equal As Strings  ${resp.json()['reminderSource']['PushNotification']}   0
    Should Be Equal As Strings  ${resp.json()['completed']}                            ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['reminderForProvider']}                  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['users'][0]['id']}                       ${pro_id}
    Should Be Equal As Strings  ${resp.json()['users'][0]['firstName']}                ${fname}
    Should Be Equal As Strings  ${resp.json()['users'][0]['lastName']}                 ${lname}

JD-TC-GetProviderReminderById-6

    [Documentation]  Create a provider reminder for PushNotification only then verify it..

    ${resp}=  Encrypted Provider Login  ${PUSERNAME164}  ${PASSWORD}
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
    ${rem_name}=  generate_firstname
    ${prov_detail}=  Create Dictionary   id=${pro_id}
    ${prov_details}=  Create List  ${prov_detail}
    ${remindersource}=  Create Dictionary    PushNotification=${bool[1]}  
    
    ${resp}=  Create Provider Reminder    ${rem_name}  ${prov_details}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}   ${sTime1}  ${eTime1}  ${msg}   ${remindersource}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${rem_id1}  ${resp.content}

    ${resp}=   Get Provider Reminder By Id   ${rem_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}                                   ${rem_id1}
    Should Be Equal As Strings  ${resp.json()['accountId']}                            ${account_id}
    Should Be Equal As Strings  ${resp.json()['reminderName']}                         ${rem_name}
    Should Be Equal As Strings  ${resp.json()['schedule']['startDate']}                ${DAY1}
    Should Be Equal As Strings  ${resp.json()['schedule']['terminator']['endDate']}    ${DAY2}
    Should Be Equal As Strings  ${resp.json()['schedule']['timeSlots'][0]['sTime']}    ${sTime1}
    Should Be Equal As Strings  ${resp.json()['schedule']['timeSlots'][0]['eTime']}    ${eTime1}  
    Should Be Equal As Strings  ${resp.json()['message']}                              ${msg}
    Should Be Equal As Strings  ${resp.json()['reminderSource']['Email']}              0
    Should Be Equal As Strings  ${resp.json()['reminderSource']['Sms']}                0
    Should Be Equal As Strings  ${resp.json()['reminderSource']['Whatsapp']}           0
    Should Be Equal As Strings  ${resp.json()['reminderSource']['PushNotification']}   1
    Should Be Equal As Strings  ${resp.json()['completed']}                            ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['reminderForProvider']}                  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['users'][0]['id']}                       ${pro_id}
    Should Be Equal As Strings  ${resp.json()['users'][0]['firstName']}                ${fname}
    Should Be Equal As Strings  ${resp.json()['users'][0]['lastName']}                 ${lname}

JD-TC-GetProviderReminderById-7

    [Documentation]  Create a provider reminder for Whatsapp only then verify it. .

    ${resp}=  Encrypted Provider Login  ${PUSERNAME165}  ${PASSWORD}
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
    ${rem_name}=  generate_firstname
    ${prov_detail}=  Create Dictionary   id=${pro_id}
    ${prov_details}=  Create List  ${prov_detail}
    ${remindersource}=  Create Dictionary     Whatsapp=${bool[1]}
    
    ${resp}=  Create Provider Reminder    ${rem_name}  ${prov_details}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}   ${sTime1}  ${eTime1}  ${msg}   ${remindersource}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${rem_id1}  ${resp.content}

    ${resp}=   Get Provider Reminder By Id   ${rem_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}                                   ${rem_id1}
    Should Be Equal As Strings  ${resp.json()['accountId']}                            ${account_id}
    Should Be Equal As Strings  ${resp.json()['reminderName']}                         ${rem_name}
    Should Be Equal As Strings  ${resp.json()['schedule']['startDate']}                ${DAY1}
    Should Be Equal As Strings  ${resp.json()['schedule']['terminator']['endDate']}    ${DAY2}
    Should Be Equal As Strings  ${resp.json()['schedule']['timeSlots'][0]['sTime']}    ${sTime1}
    Should Be Equal As Strings  ${resp.json()['schedule']['timeSlots'][0]['eTime']}    ${eTime1}  
    Should Be Equal As Strings  ${resp.json()['message']}                              ${msg}
    Should Be Equal As Strings  ${resp.json()['reminderSource']['Email']}              0
    Should Be Equal As Strings  ${resp.json()['reminderSource']['Sms']}                0
    Should Be Equal As Strings  ${resp.json()['reminderSource']['Whatsapp']}           1
    Should Be Equal As Strings  ${resp.json()['reminderSource']['PushNotification']}   0
    Should Be Equal As Strings  ${resp.json()['completed']}                            ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['reminderForProvider']}                  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['users'][0]['id']}                       ${pro_id}
    Should Be Equal As Strings  ${resp.json()['users'][0]['firstName']}                ${fname}
    Should Be Equal As Strings  ${resp.json()['users'][0]['lastName']}                 ${lname}

JD-TC-GetProviderReminderById-8

    [Documentation]  Create a provider reminder for sms only then verify it..

    ${resp}=  Encrypted Provider Login  ${PUSERNAME166}  ${PASSWORD}
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
    ${rem_name}=  generate_firstname
    ${prov_detail}=  Create Dictionary   id=${pro_id}
    ${prov_details}=  Create List  ${prov_detail}
    ${remindersource}=  Create Dictionary     Sms=${bool[1]} 

    ${resp}=  Create Provider Reminder    ${rem_name}  ${prov_details}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}   ${sTime1}  ${eTime1}  ${msg}   ${remindersource}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${rem_id1}  ${resp.content}

    ${resp}=   Get Provider Reminder By Id   ${rem_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}                                   ${rem_id1}
    Should Be Equal As Strings  ${resp.json()['accountId']}                            ${account_id}
    Should Be Equal As Strings  ${resp.json()['reminderName']}                         ${rem_name}
    Should Be Equal As Strings  ${resp.json()['schedule']['startDate']}                ${DAY1}
    Should Be Equal As Strings  ${resp.json()['schedule']['terminator']['endDate']}    ${DAY2}
    Should Be Equal As Strings  ${resp.json()['schedule']['timeSlots'][0]['sTime']}    ${sTime1}
    Should Be Equal As Strings  ${resp.json()['schedule']['timeSlots'][0]['eTime']}    ${eTime1}  
    Should Be Equal As Strings  ${resp.json()['message']}                              ${msg}
    Should Be Equal As Strings  ${resp.json()['reminderSource']['Email']}              0
    Should Be Equal As Strings  ${resp.json()['reminderSource']['Sms']}                1
    Should Be Equal As Strings  ${resp.json()['reminderSource']['Whatsapp']}           0
    Should Be Equal As Strings  ${resp.json()['reminderSource']['PushNotification']}   0
    Should Be Equal As Strings  ${resp.json()['completed']}                            ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['reminderForProvider']}                  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['users'][0]['id']}                       ${pro_id}
    Should Be Equal As Strings  ${resp.json()['users'][0]['firstName']}                ${fname}
    Should Be Equal As Strings  ${resp.json()['users'][0]['lastName']}                 ${lname}

JD-TC-GetProviderReminderById-9

    [Documentation]  Create a provider reminder for two other users and a provider consumer.then verify it by id.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME6}  ${PASSWORD}
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

    ${ufname1}=  FakerLibrary.name
    ${ulname1}=  FakerLibrary.last_name
    ${PO_Number}    Generate random string    7    ${digits} 
    ${p_num}    Convert To Integer  ${PO_Number}
    ${PUSERNAME}=  Evaluate  ${PUSERNAME}+${p_num}
    Set Test Variable  ${USERNAME1}  ${PUSERNAME}

    ${resp}=  Create User  ${ufname1}  ${ulname1}   ${countryCodes[0]}  ${USERNAME1}  ${userType[0]}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id1}  ${resp.json()}

    ${ufname2}=  FakerLibrary.name
    ${ulname2}=  FakerLibrary.last_name
    ${PO_Number}    Generate random string    7    ${digits} 
    ${p_num}    Convert To Integer  ${PO_Number}
    ${PUSERNAME}=  Evaluate  ${PUSERNAME}+${p_num}
    Set Test Variable  ${USERNAME2}  ${PUSERNAME}

    ${resp}=  Create User  ${ufname2}  ${ulname2}   ${countryCodes[0]}  ${USERNAME2}  ${userType[0]}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id2}  ${resp.json()}

    #............provider consumer creation..........

    ${NewCustomer}    Generate random string    10    123456789
    ${NewCustomer}    Convert To Integer  ${NewCustomer}

    ${custf_name}=  FakerLibrary.name    
    ${custl_name}=  FakerLibrary.last_name
    ${resp}=  AddCustomer  ${NewCustomer}    firstName=${custf_name}   lastName=${custl_name}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    Send Otp For Login    ${NewCustomer}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${NewCustomer}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    ${resp}=  GetCustomer  phoneNo-eq=${NewCustomer}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cons_id}  ${resp.json()[0]['id']}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  3  15  
    ${eTime1}=  add_timezone_time  ${tz}  3  15  
    ${msg}=  FakerLibrary.word
    ${rem_name}=  generate_firstname
    ${prov_detail}=  Create Dictionary   id=${u_id1}
    ${prov_detail1}=  Create Dictionary   id=${u_id2}
    ${provcons_detail}=  Create Dictionary   id=${cons_id}
    ${provcons_details}=  Create List  ${provcons_detail}
    ${prov_details}=  Create List  ${prov_detail}  ${prov_detail1}  
    ${remindersource}=  Create Dictionary    Sms=${bool[1]}   Email=${bool[1]}  PushNotification=${bool[1]}  Whatsapp=${bool[1]}

    ${resp}=  Create Provider Reminder    ${rem_name}  ${prov_details}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}   ${sTime1}  ${eTime1}  ${msg}   ${remindersource}
    ...   providerConsumers=${provcons_details}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${rem_id1}  ${resp.content}

    ${resp}=   Get Provider Reminder By Id   ${rem_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}                                   ${rem_id1}
    Should Be Equal As Strings  ${resp.json()['accountId']}                            ${account_id}
    Should Be Equal As Strings  ${resp.json()['reminderName']}                         ${rem_name}
    Should Be Equal As Strings  ${resp.json()['schedule']['startDate']}                ${DAY1}
    Should Be Equal As Strings  ${resp.json()['schedule']['terminator']['endDate']}    ${DAY2}
    Should Be Equal As Strings  ${resp.json()['schedule']['timeSlots'][0]['sTime']}    ${sTime1}
    Should Be Equal As Strings  ${resp.json()['schedule']['timeSlots'][0]['eTime']}    ${eTime1}  
    Should Be Equal As Strings  ${resp.json()['message']}                              ${msg}
    Should Be Equal As Strings  ${resp.json()['reminderSource']['Email']}              1
    Should Be Equal As Strings  ${resp.json()['reminderSource']['Sms']}                1
    Should Be Equal As Strings  ${resp.json()['reminderSource']['Whatsapp']}           1
    Should Be Equal As Strings  ${resp.json()['reminderSource']['PushNotification']}   1
    Should Be Equal As Strings  ${resp.json()['completed']}                            ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['reminderForProvider']}                  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['users'][0]['id']}                       ${u_id1}
    Should Be Equal As Strings  ${resp.json()['users'][0]['firstName']}                ${ufname1}
    Should Be Equal As Strings  ${resp.json()['users'][0]['lastName']}                 ${ulname1}
    Should Be Equal As Strings  ${resp.json()['users'][1]['id']}                       ${u_id2}
    Should Be Equal As Strings  ${resp.json()['users'][1]['firstName']}                ${ufname2}
    Should Be Equal As Strings  ${resp.json()['users'][1]['lastName']}                 ${ulname2}
    Should Be Equal As Strings  ${resp.json()['providerConsumers'][0]['id']}           ${cons_id}
    Should Be Equal As Strings  ${resp.json()['providerConsumers'][0]['firstName']}    ${custf_name}
    Should Be Equal As Strings  ${resp.json()['providerConsumers'][0]['lastName']}     ${custl_name}

JD-TC-GetProviderReminderById-UH1

    [Documentation]  get provider reminder by id without login.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME155}  ${PASSWORD}
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
    ${rem_name}=  generate_firstname
    ${prov_detail}=  Create Dictionary   id=${pro_id}
    ${prov_details}=  Create List  ${prov_detail}
    ${remindersource}=  Create Dictionary    Sms=${bool[1]}   Email=${bool[1]}  PushNotification=${bool[1]}  Whatsapp=${bool[1]}

    ${resp}=  Create Provider Reminder    ${rem_name}  ${prov_details}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}   ${sTime1}  ${eTime1}  ${msg}   ${remindersource}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${rem_id1}  ${resp.content}

    ${resp}=   ProviderLogout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Provider Reminder By Id   ${rem_id1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings    ${resp.json()}   ${SESSION_EXPIRED}
