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

JD-TC-CreateProviderReminder-1

    [Documentation]  Create a provider reminder with all details.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME250}  ${PASSWORD}
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
    Set Test Variable  ${rem_id}  ${resp.content}

JD-TC-CreateProviderReminder-2

    [Documentation]  Create a provider reminder with two time slots.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME251}  ${PASSWORD}
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
    ${sTime2}=  add_timezone_time  ${tz}  1  15  
    ${eTime2}=  add_timezone_time  ${tz}  1  15
    ${msg}=  FakerLibrary.word
    ${rem_name}=  generate_firstname
    ${prov_detail}=  Create Dictionary   id=${pro_id}
    ${prov_details}=  Create List  ${prov_detail}
    ${remindersource}=  Create Dictionary    Sms=${bool[1]}   Email=${bool[1]}  PushNotification=${bool[1]}  Whatsapp=${bool[1]}
    ${time1}=  Create Dictionary  sTime=${sTime2}  eTime=${eTime2}

    ${resp}=  Create Provider Reminder    ${rem_name}  ${prov_details}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}   ${sTime1}  ${eTime1}  ${msg}   ${remindersource}  ${time1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${rem_id}  ${resp.content}

JD-TC-CreateProviderReminder-3

    [Documentation]  Create a provider reminder for email only.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME252}  ${PASSWORD}
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
    ${remindersource}=  Create Dictionary     Email=${bool[1]} 

    ${resp}=  Create Provider Reminder    ${rem_name}  ${prov_details}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}   ${sTime1}  ${eTime1}  ${msg}   ${remindersource}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${rem_id}  ${resp.content}

JD-TC-CreateProviderReminder-4

    [Documentation]  Create a provider reminder for PushNotification only.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME253}  ${PASSWORD}
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
    ${remindersource}=  Create Dictionary    PushNotification=${bool[1]}  
    
    ${resp}=  Create Provider Reminder    ${rem_name}  ${prov_details}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}   ${sTime1}  ${eTime1}  ${msg}   ${remindersource}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${rem_id}  ${resp.content}

JD-TC-CreateProviderReminder-5

    [Documentation]  Create a provider reminder for Whatsapp only.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME254}  ${PASSWORD}
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
    ${remindersource}=  Create Dictionary     Whatsapp=${bool[1]}
    
    ${resp}=  Create Provider Reminder    ${rem_name}  ${prov_details}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}   ${sTime1}  ${eTime1}  ${msg}   ${remindersource}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${rem_id}  ${resp.content}

JD-TC-CreateProviderReminder-6

    [Documentation]  Create a provider reminder for sms only.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME252}  ${PASSWORD}
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
    ${remindersource}=  Create Dictionary     Sms=${bool[1]} 

    ${resp}=  Create Provider Reminder    ${rem_name}  ${prov_details}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}   ${sTime1}  ${eTime1}  ${msg}   ${remindersource}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${rem_id}  ${resp.content}

JD-TC-CreateProviderReminder-7

    [Documentation]  Create a provider reminder with same start date and end date.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME255}  ${PASSWORD}
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
    ${DAY2}=   db.get_date_by_timezone  ${tz}
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
    Set Test Variable  ${rem_id}  ${resp.content}

JD-TC-CreateProviderReminder-8

    [Documentation]  Create two provider reminders with same name.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME258}  ${PASSWORD}
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
    Set Test Variable  ${rem_id}  ${resp.content}

    ${DAY3}=  db.add_timezone_date  ${tz}  1   
    ${DAY4}=  db.add_timezone_date  ${tz}  2     
    ${msg1}=  FakerLibrary.word
    
    ${resp}=  Create Provider Reminder    ${rem_name}  ${prov_details}  ${recurringtype[1]}  ${list}  ${DAY3}  ${DAY4}   ${sTime1}  ${eTime1}  ${msg1}   ${remindersource}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${rem_id1}  ${resp.content}

JD-TC-CreateProviderReminder-9

    [Documentation]  Create a provider reminder for two other users and a provider consumer..

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME7}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

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
    
    # ${resp}=    Send Otp For Login    ${NewCustomer}    ${account_id}
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}   200

    # ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    # ${resp}=    Verify Otp For Login   ${NewCustomer}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}   200
    # Set Test Variable  ${token}  ${resp.json()['token']}

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

JD-TC-CreateProviderReminder-UH1

    [Documentation]  Create a provider reminder without reminder name.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME256}  ${PASSWORD}
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
    ${DAY2}=   db.add_timezone_date  ${tz}  10  
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  3  15  
    ${eTime1}=  add_timezone_time  ${tz}  3  15  
    ${msg}=  FakerLibrary.word
    ${prov_detail}=  Create Dictionary   id=${pro_id}
    ${prov_details}=  Create List  ${prov_detail}
    ${remindersource}=  Create Dictionary    Sms=${bool[1]}   Email=${bool[1]}  PushNotification=${bool[1]}  Whatsapp=${bool[1]}

    ${resp}=  Create Provider Reminder    ${EMPTY}  ${prov_details}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}   ${sTime1}  ${eTime1}  ${msg}   ${remindersource}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${INVALID_REMINDER_NAME}

JD-TC-CreateProviderReminder-UH2

    [Documentation]   Create a provider reminder without reminder description.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME257}  ${PASSWORD}
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
    ${rem_name}=  generate_firstname
    ${prov_detail}=  Create Dictionary   id=${pro_id}
    ${prov_details}=  Create List  ${prov_detail}
    ${remindersource}=  Create Dictionary    Sms=${bool[1]}   Email=${bool[1]}  PushNotification=${bool[1]}  Whatsapp=${bool[1]}

    ${resp}=  Create Provider Reminder    ${rem_name}  ${prov_details}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}   ${sTime1}  ${eTime1}  ${EMPTY}   ${remindersource}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${INVALID_MESSAGE}

JD-TC-CreateProviderReminder-UH3

    [Documentation]   Create a provider reminder without start date

    ${resp}=  Encrypted Provider Login  ${PUSERNAME257}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable      ${pro_id}  ${decrypted_data['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${tz}  ${resp.json()['baseLocation']['timezone']}

    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  3  15  
    ${eTime1}=  add_timezone_time  ${tz}  3  15  
    ${rem_name}=  generate_firstname
    ${prov_detail}=  Create Dictionary   id=${pro_id}
    ${prov_details}=  Create List  ${prov_detail}
    ${remindersource}=  Create Dictionary    Sms=${bool[1]}   Email=${bool[1]}  PushNotification=${bool[1]}  Whatsapp=${bool[1]}

    ${resp}=  Create Provider Reminder    ${rem_name}  ${prov_details}  ${recurringtype[1]}  ${list}  ${EMPTY}  ${DAY2}   ${sTime1}  ${eTime1}  ${EMPTY}   ${remindersource}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${INVALID_MESSAGE}

JD-TC-CreateProviderReminder-UH4

    [Documentation]   Create a provider reminder without end date

    ${resp}=  Encrypted Provider Login  ${PUSERNAME257}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable      ${pro_id}  ${decrypted_data['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${tz}  ${resp.json()['baseLocation']['timezone']}

    ${DAY1}=  db.add_timezone_date  ${tz}  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  3  15  
    ${eTime1}=  add_timezone_time  ${tz}  3  15  
    ${rem_name}=  generate_firstname
    ${prov_detail}=  Create Dictionary   id=${pro_id}
    ${prov_details}=  Create List  ${prov_detail}
    ${remindersource}=  Create Dictionary    Sms=${bool[1]}   Email=${bool[1]}  PushNotification=${bool[1]}  Whatsapp=${bool[1]}

    ${resp}=  Create Provider Reminder    ${rem_name}  ${prov_details}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}   ${sTime1}  ${eTime1}  ${EMPTY}   ${remindersource}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${INVALID_MESSAGE}

JD-TC-CreateProviderReminder-UH5

    [Documentation]   Create a provider reminder without time.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME257}  ${PASSWORD}
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
    ${rem_name}=  generate_firstname
    ${prov_detail}=  Create Dictionary   id=${pro_id}
    ${prov_details}=  Create List  ${prov_detail}
    ${remindersource}=  Create Dictionary    Sms=${bool[1]}   Email=${bool[1]}  PushNotification=${bool[1]}  Whatsapp=${bool[1]}

    ${resp}=  Create Provider Reminder    ${rem_name}  ${prov_details}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}   ${EMPTY}  ${EMPTY}  ${EMPTY}   ${remindersource}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${INVALID_MESSAGE}

JD-TC-CreateProviderReminder-UH6

    [Documentation]  Create a provider reminder without provider details.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME258}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

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
    ${prov_detail}=  Create Dictionary   id=${EMPTY}
    ${prov_details}=  Create List  ${prov_detail}
    ${remindersource}=  Create Dictionary    Sms=${bool[1]}   Email=${bool[1]}  PushNotification=${bool[1]}  Whatsapp=${bool[1]}

    ${resp}=  Create Provider Reminder    ${rem_name}  ${prov_details}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}   ${sTime1}  ${eTime1}  ${msg}   ${remindersource}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${rem_id}  ${resp.content}

JD-TC-CreateProviderReminder-UH7

    [Documentation]  Create a provider reminder without reminder source.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME258}  ${PASSWORD}
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
    ${remindersource}=  Create Dictionary    
    ${resp}=  Create Provider Reminder    ${rem_name}  ${prov_details}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}   ${sTime1}  ${eTime1}  ${msg}   ${remindersource}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${INVALID_REMINDER}

JD-TC-CreateProviderReminder-UH8

    [Documentation]  Create a provider reminder without login.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME258}  ${PASSWORD}
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

    ${resp}=   ProviderLogout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Create Provider Reminder    ${rem_name}  ${prov_details}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}   ${sTime1}  ${eTime1}  ${msg}   ${remindersource}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings    ${resp.json()}   ${SESSION_EXPIRED}
