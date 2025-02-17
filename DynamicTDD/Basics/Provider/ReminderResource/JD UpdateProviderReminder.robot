*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Reminder
Library           Collections
Library           String
Library           json
Library           random
Library           FakerLibrary
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

    [Documentation]  Create a provider reminder with all details then update the reminder name.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME200}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable      ${pro_id}  ${decrypted_data['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
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

    ${rem_name1}=  FakerLibrary.last_name
    ${resp}=  Update Provider Reminder    ${rem_id1}   reminderName=${rem_name1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Provider Reminder By Id   ${rem_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['reminderName']}      ${rem_name1}