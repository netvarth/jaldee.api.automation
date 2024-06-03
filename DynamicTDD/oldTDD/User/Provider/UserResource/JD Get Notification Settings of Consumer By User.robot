*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown    Delete All Sessions
Force Tags        NotificationSettings
Library           Collections
Library           String
Library           json
Library           /ebs/TDD/db.py
Library           FakerLibrary
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py
Variables         /ebs/TDD/varfiles/providers.py




*** Variables ***
${digits}       0123456789
@{EMPTY_Notification_List} 
@{person_ahead}   0  1  2  3  4  5  6


*** Test Cases ***

JD-TC-GetNotificationSettings_of_ConsumerByUser-1
    [Documentation]   Getting Notification Settings of Consumer By USER

    ${iscorp_subdomains}=  get_iscorp_subdomains  1
     Log  ${iscorp_subdomains}
     Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
     Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
     Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
     ${firstname_A}=  FakerLibrary.first_name
     Set Suite Variable  ${firstname_A}
     ${lastname_A}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname_A}
     ${PUSERNAME_E1}=  Evaluate  ${PUSERNAME}+9910199
     ${highest_package}=  get_highest_license_pkg
     ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${PUSERNAME_E1}    ${highest_package[0]}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Activation  ${PUSERNAME_E1}  0
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Set Credential  ${PUSERNAME_E1}  ${PASSWORD}  0
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Encrypted Provider Login  ${PUSERNAME_E1}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_E1}${\n}
     Set Suite Variable  ${PUSERNAME_E1}
     ${id}=  get_id  ${PUSERNAME_E1}
     Set Suite Variable  ${id}
     ${bs}=  FakerLibrary.bs
     Set Suite Variable  ${bs}
     ${resp}=  Toggle Department Enable
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     sleep  2s
     ${resp}=  Get Departments
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}

    ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+606078
    clear_users  ${PUSERNAME_U1}
    Set Suite Variable  ${PUSERNAME_U1}
    ${firstname1}=  FakerLibrary.name
    Set Suite Variable  ${firstname1}
    ${lastname1}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname1}
    ${dob1}=  FakerLibrary.Date
    Set Suite Variable  ${dob1}
    ${pin1}=  get_pincode
    Set Suite Variable  ${pin1}
    
    ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin1}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${sub_domain_id}  ${bool[1]}  ${NULL}  ${NULL}  ${NULL}  ${NULL} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id1}  ${resp.json()}


    ${number2}=  Random Int  min=8100  max=8399
    ${PUSERNAME_U2}=  Evaluate  ${PUSERNAME}+${number2}
    clear_users  ${PUSERNAME_U2}
    Set Suite Variable  ${PUSERNAME_U2}
    ${firstname2}=  FakerLibrary.name
    Set Suite Variable  ${firstname2}
    ${lastname2}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname2}
    ${dob2}=  FakerLibrary.Date
    Set Suite Variable  ${dob2}
    ${pin2}=  get_pincode
    Set Suite Variable  ${pin2}

    ${resp}=  Create User  ${firstname2}  ${lastname2}  ${dob2}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U2}.${test_mail}   ${userType[0]}  ${pin2}  ${countryCodes[0]}  ${PUSERNAME_U2}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id2}  ${resp.json()}

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${p2_id}   ${resp.json()[0]['id']}
    Set Suite Variable   ${p1_id}   ${resp.json()[1]['id']}
    Set Suite Variable   ${p0_id}   ${resp.json()[2]['id']}

    ${resp}=  Get Notification Settings of Consumer By User  ${p1_id}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    comment   WAITLISTADD
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${EventType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['email']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['sms']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['pushNotification']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['personsAhead']}  ${person_ahead[0]}
    # Should Be Equal As Strings  ${resp.json()[3]['commonMessage']}  ${msg}
    
    comment   WAITLISTCANCEL
    Should Be Equal As Strings  ${resp.json()[1]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['eventType']}  ${EventType[1]}
    Should Be Equal As Strings  ${resp.json()[1]['email']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[1]['sms']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[1]['pushNotification']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[1]['personsAhead']}  ${person_ahead[0]}

    comment   EARLY NOTIFICATION-WAITLIST
    Should Be Equal As Strings  ${resp.json()[2]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[2]['eventType']}  ${EventType[4]}
    Should Be Equal As Strings  ${resp.json()[2]['email']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[2]['sms']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[2]['pushNotification']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[2]['personsAhead']}  ${person_ahead[4]}
    
    comment   PREFINAL NOTIFICATION-WAITLIST
    Should Be Equal As Strings  ${resp.json()[3]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[3]['eventType']}  ${EventType[5]}
    Should Be Equal As Strings  ${resp.json()[3]['email']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[3]['sms']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[3]['pushNotification']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[3]['personsAhead']}  ${person_ahead[1]}
    
    comment   FINAL NOTIFICATION-WAITLIST
    Should Be Equal As Strings  ${resp.json()[4]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[4]['eventType']}  ${EventType[6]}
    Should Be Equal As Strings  ${resp.json()[4]['email']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[4]['sms']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[4]['pushNotification']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[4]['personsAhead']}  ${person_ahead[0]}
    
    comment   PREFINAL NOTIFICATION-APPOINTMENT
    Should Be Equal As Strings  ${resp.json()[5]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[5]['eventType']}  ${EventType[5]}
    Should Be Equal As Strings  ${resp.json()[5]['email']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[5]['sms']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[5]['pushNotification']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[5]['personsAhead']}  ${person_ahead[1]}
    
    comment   FINAL NOTIFICATION-APPOINTMENT
    Should Be Equal As Strings  ${resp.json()[6]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[6]['eventType']}  ${EventType[6]}
    Should Be Equal As Strings  ${resp.json()[6]['email']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[6]['sms']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[6]['pushNotification']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[6]['personsAhead']}  ${person_ahead[0]}
    
    comment   APPOINTMENTADD
    Should Be Equal As Strings  ${resp.json()[7]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[7]['eventType']}  ${EventType[7]}
    Should Be Equal As Strings  ${resp.json()[7]['email']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[7]['sms']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[7]['pushNotification']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[7]['personsAhead']}  ${person_ahead[0]}
    


JD-TC-GetNotificationSettings_of_ConsumerByUser-2
    [Documentation]   Update Early Notification and Get Notification Settings of Consumer By USER
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${msg1}=  FakerLibrary.text 
    ${person_ahead1}=   Random Int  min=3   max=7
    ${resp}=  Update Notification Settings of Consumer By User  ${p1_id}  ${NotificationResourceType[0]}  ${EventType[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${msg1}  ${person_ahead1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Notification Settings of Consumer By User  ${p1_id}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    comment   WAITLISTADD
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${EventType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['email']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[0]['sms']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[0]['pushNotification']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['personsAhead']}  ${person_ahead[0]}
    Should Be Equal As Strings  ${resp.json()[0]['commonMessage']}  ${msg1}

    


JD-TC-GetNotificationSettings_of_ConsumerByUser-3
    [Documentation]   Update Prefinal Notification and Get Notification Settings of Consumer By USER
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${msg1}=  FakerLibrary.text 
    ${person_ahead1}=   Random Int  min=3   max=7
    ${resp}=  Update Notification Settings of Consumer By User  ${p1_id}  ${NotificationResourceType[0]}  ${EventType[4]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${msg1}  ${person_ahead1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Notification Settings of Consumer By User  ${p1_id}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    comment   EARLY NOTIFICATION-WAITLIST
    Should Be Equal As Strings  ${resp.json()[2]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[2]['eventType']}  ${EventType[4]}
    Should Be Equal As Strings  ${resp.json()[2]['email']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[2]['sms']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[2]['pushNotification']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[2]['personsAhead']}  ${person_ahead1}
    Should Be Equal As Strings  ${resp.json()[2]['commonMessage']}  ${msg1}




JD-TC-GetNotificationSettings_of_ConsumerByUser-4
    [Documentation]   Update Final Notification and Get Notification Settings of Consumer By USER
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${msg1}=  FakerLibrary.text 
    ${person_ahead1}=   Random Int  min=3   max=7
    ${resp}=  Update Notification Settings of Consumer By User  ${p1_id}  ${NotificationResourceType[0]}  ${EventType[5]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${msg1}  ${person_ahead1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Notification Settings of Consumer By User  ${p1_id}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    comment   PREFINAL NOTIFICATION-WAITLIST
    Should Be Equal As Strings  ${resp.json()[3]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[3]['eventType']}  ${EventType[5]}
    Should Be Equal As Strings  ${resp.json()[3]['email']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[3]['sms']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[3]['pushNotification']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[3]['personsAhead']}  ${person_ahead[1]}
    Should Be Equal As Strings  ${resp.json()[3]['commonMessage']}  ${msg1}




JD-TC-GetNotificationSettings_of_ConsumerByUser-5
    [Documentation]   Update WaitlistAdd and Get Notification Settings of Consumer By USER
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${msg1}=  FakerLibrary.text 
    ${person_ahead1}=   Random Int  min=3   max=7
    ${resp}=  Update Notification Settings of Consumer By User  ${p1_id}  ${NotificationResourceType[0]}  ${EventType[6]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${msg1}  ${person_ahead1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Notification Settings of Consumer By User  ${p1_id}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    comment   FINAL NOTIFICATION-WAITLIST
    Should Be Equal As Strings  ${resp.json()[4]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[4]['eventType']}  ${EventType[6]}
    Should Be Equal As Strings  ${resp.json()[4]['email']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[4]['sms']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[4]['pushNotification']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[4]['personsAhead']}  ${person_ahead[0]}
    Should Be Equal As Strings  ${resp.json()[4]['commonMessage']}  ${msg1}



JD-TC-GetNotificationSettings_of_ConsumerByUser-6
    [Documentation]   Update AppointmentAdd and Get Notification Settings of Consumer By USER
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${msg1}=  FakerLibrary.text 
    ${person_ahead1}=   Random Int  min=3   max=7
    ${resp}=  Update Notification Settings of Consumer By User  ${p1_id}  ${NotificationResourceType[1]}  ${EventType[7]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${msg1}  ${person_ahead1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Notification Settings of Consumer By User  ${p1_id}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    comment   APPOINTMENTADD
    Should Be Equal As Strings  ${resp.json()[7]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[7]['eventType']}  ${EventType[7]}
    Should Be Equal As Strings  ${resp.json()[7]['email']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[7]['sms']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[7]['pushNotification']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[7]['personsAhead']}  ${person_ahead[0]}
   

JD-TC-GetNotificationSettings_of_ConsumerByUser-7
    [Documentation]   Update WaitlistAdd and Get Notification Settings of Consumer By USER
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${msg1}=  FakerLibrary.text 
    ${person_ahead1}=   Random Int  min=3   max=7
    ${resp}=  Update Notification Settings of Consumer By User  ${p1_id}  ${NotificationResourceType[1]}  ${EventType[6]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${msg1}  ${person_ahead1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Notification Settings of Consumer By User  ${p1_id}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    comment   FINAL NOTIFICATION-APPOINTMENT
    Should Be Equal As Strings  ${resp.json()[6]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[6]['eventType']}  ${EventType[6]}
    Should Be Equal As Strings  ${resp.json()[6]['email']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[6]['sms']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[6]['pushNotification']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[6]['personsAhead']}  ${person_ahead[0]}
    Should Be Equal As Strings  ${resp.json()[6]['commonMessage']}  ${msg1}



JD-TC-GetNotificationSettings_of_ConsumerByUser-8
    [Documentation]   Update WaitlistAdd and Get Notification Settings of Consumer By USER
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${msg1}=  FakerLibrary.text 
    ${person_ahead1}=   Random Int  min=3   max=7
    ${resp}=  Update Notification Settings of Consumer By User  ${p1_id}  ${NotificationResourceType[1]}  ${EventType[5]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${msg1}  ${person_ahead1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Notification Settings of Consumer By User  ${p1_id}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    comment   PREFINAL NOTIFICATION-APPOINTMENT
    Should Be Equal As Strings  ${resp.json()[5]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[5]['eventType']}  ${EventType[5]}
    Should Be Equal As Strings  ${resp.json()[5]['email']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[5]['sms']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[5]['pushNotification']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[5]['personsAhead']}  ${person_ahead[1]}
    Should Be Equal As Strings  ${resp.json()[5]['commonMessage']}  ${msg1}


JD-TC-GetNotificationSettings_of_ConsumerByUser-9
    [Documentation]   Updated all notification settings of one USER u_id1, then Get Notification Settings of Consumer By another USER u_id2
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Notification Settings of Consumer By User  ${p2_id}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    comment   WAITLISTADD
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${EventType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['email']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['sms']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['pushNotification']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['personsAhead']}  ${person_ahead[0]}
    
    comment   WAITLISTCANCEL
    Should Be Equal As Strings  ${resp.json()[1]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['eventType']}  ${EventType[1]}
    Should Be Equal As Strings  ${resp.json()[1]['email']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[1]['sms']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[1]['pushNotification']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[1]['personsAhead']}  ${person_ahead[0]}

    comment   EARLY NOTIFICATION-WAITLIST
    Should Be Equal As Strings  ${resp.json()[2]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[2]['eventType']}  ${EventType[4]}
    Should Be Equal As Strings  ${resp.json()[2]['email']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[2]['sms']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[2]['pushNotification']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[2]['personsAhead']}  ${person_ahead[4]}
    
    comment   PREFINAL NOTIFICATION-WAITLIST
    Should Be Equal As Strings  ${resp.json()[3]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[3]['eventType']}  ${EventType[5]}
    Should Be Equal As Strings  ${resp.json()[3]['email']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[3]['sms']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[3]['pushNotification']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[3]['personsAhead']}  ${person_ahead[1]}
   
    comment   FINAL NOTIFICATION-WAITLIST
    Should Be Equal As Strings  ${resp.json()[4]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[4]['eventType']}  ${EventType[6]}
    Should Be Equal As Strings  ${resp.json()[4]['email']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[4]['sms']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[4]['pushNotification']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[4]['personsAhead']}  ${person_ahead[0]}
    
    comment   PREFINAL NOTIFICATION-APPOINTMENT
    Should Be Equal As Strings  ${resp.json()[5]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[5]['eventType']}  ${EventType[5]}
    Should Be Equal As Strings  ${resp.json()[5]['email']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[5]['sms']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[5]['pushNotification']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[5]['personsAhead']}  ${person_ahead[1]}
    
    comment   FINAL NOTIFICATION-APPOINTMENT
    Should Be Equal As Strings  ${resp.json()[6]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[6]['eventType']}  ${EventType[6]}
    Should Be Equal As Strings  ${resp.json()[6]['email']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[6]['sms']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[6]['pushNotification']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[6]['personsAhead']}  ${person_ahead[0]}
    
    comment   APPOINTMENTADD
    Should Be Equal As Strings  ${resp.json()[7]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[7]['eventType']}  ${EventType[7]}
    Should Be Equal As Strings  ${resp.json()[7]['email']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[7]['sms']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[7]['pushNotification']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[7]['personsAhead']}  ${person_ahead[0]}



JD-TC-GetNotificationSettings_of_ConsumerByUser -UH1
    [Documentation]   Get Notification Settings without Provider login 
    ${resp}=  Get Notification Settings of Consumer By User  ${p1_id}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"



JD-TC-GetNotificationSettings_of_ConsumerByUser -10
    [Documentation]   Use provider_id (default provider) to Get Notification Settings
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Notification Settings of Consumer By User  ${p0_id}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Not Be Equal As Strings  ${resp.json()}  ${EMPTY_Notification_List}
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${EventType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['eventType']}  ${EventType[1]}
    Should Be Equal As Strings  ${resp.json()[2]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[2]['eventType']}  ${EventType[4]}
    Should Be Equal As Strings  ${resp.json()[3]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[3]['eventType']}  ${EventType[5]}
    Should Be Equal As Strings  ${resp.json()[4]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[4]['eventType']}  ${EventType[6]}
    Should Be Equal As Strings  ${resp.json()[5]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[5]['eventType']}  ${EventType[5]}
    Should Be Equal As Strings  ${resp.json()[6]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[6]['eventType']}  ${EventType[6]}
    Should Be Equal As Strings  ${resp.json()[7]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[7]['eventType']}  ${EventType[7]}
    Should Be Equal As Strings  ${resp.json()[8]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[8]['eventType']}  ${EventType[8]}
    Should Be Equal As Strings  ${resp.json()[9]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[9]['eventType']}  ${EventType[11]}
    Should Be Equal As Strings  ${resp.json()[10]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[10]['eventType']}  ${EventType[12]}
    Should Be Equal As Strings  ${resp.json()[11]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[11]['eventType']}  ${EventType[13]}
    Should Be Equal As Strings  ${resp.json()[12]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[12]['eventType']}  ${EventType[14]}
    Should Be Equal As Strings  ${resp.json()[13]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[13]['eventType']}  ${EventType[15]}


JD-TC-GetNotificationSettings_of_ConsumerByUser -UH3
    [Documentation]   Consumer try to get Notification Settings
    ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Get Notification Settings of Consumer By User  ${p0_id} 
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings  "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"


JD-TC-GetNotificationSettings_of_ConsumerByUser -UH4
	[Documentation]  invalid provider

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${Invalid_id}=  Random Int  min=100000  max=200000
    ${resp}=  Get Notification Settings of Consumer By User  ${Invalid_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  404
    Should Be Equal As Strings  "${resp.json()}"   "${USER_NOT_FOUND}"  


JD-TC-GetNotificationSettings_of_ConsumerByUser -UH5
    [Documentation]  Get Consumer Notification Settings using Disabled USER_id
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  EnableDisable User  ${p1_id}  ${toggle[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   02s

    ${resp}=  Get Notification Settings of Consumer By User  ${p1_id}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    comment   WAITLISTADD
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${EventType[0]}
    
    comment   WAITLISTCANCEL
    Should Be Equal As Strings  ${resp.json()[1]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['eventType']}  ${EventType[1]}

    comment   EARLY NOTIFICATION-WAITLIST
    Should Be Equal As Strings  ${resp.json()[2]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[2]['eventType']}  ${EventType[4]}
    
    comment   PREFINAL NOTIFICATION-WAITLIST
    Should Be Equal As Strings  ${resp.json()[3]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[3]['eventType']}  ${EventType[5]}
    
    comment   FINAL NOTIFICATION-WAITLIST
    Should Be Equal As Strings  ${resp.json()[4]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[4]['eventType']}  ${EventType[6]}
   
    comment   PREFINAL NOTIFICATION-APPOINTMENT
    Should Be Equal As Strings  ${resp.json()[5]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[5]['eventType']}  ${EventType[5]}
    
    comment   FINAL NOTIFICATION-APPOINTMENT
    Should Be Equal As Strings  ${resp.json()[6]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[6]['eventType']}  ${EventType[6]}
  
    comment   APPOINTMENTADD
    Should Be Equal As Strings  ${resp.json()[7]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[7]['eventType']}  ${EventType[7]}
   
    ${resp}=  EnableDisable User  ${p1_id}  ${toggle[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   02s


JD-TC-GetNotificationSettings_of_ConsumerByUser-UH6
    [Documentation]  Get notification settings using user_id of another provider
    ${iscorp_subdomains}=  get_iscorp_subdomains  1
     Log  ${iscorp_subdomains}
     Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
     Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
     Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
     ${firstname_A}=  FakerLibrary.first_name
     Set Suite Variable  ${firstname_A}
     ${lastname_A}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname_A}
     ${PUSERNAME_E2}=  Evaluate  ${PUSERNAME}+8910198
     ${highest_package}=  get_highest_license_pkg
     ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${PUSERNAME_E2}    ${highest_package[0]}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Activation  ${PUSERNAME_E2}  0
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Set Credential  ${PUSERNAME_E2}  ${PASSWORD}  0
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Encrypted Provider Login  ${PUSERNAME_E2}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_E2}${\n}
     Set Suite Variable  ${PUSERNAME_E2}
     ${id}=  get_id  ${PUSERNAME_E2}
     Set Suite Variable  ${id}
     ${bs}=  FakerLibrary.bs
     Set Suite Variable  ${bs}
     ${resp}=  Toggle Department Enable
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     sleep  2s
     ${resp}=  Get Departments
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}


    ${PUSERNAME_U2}=  Evaluate  ${PUSERNAME}+980025
    clear_users  ${PUSERNAME_U2}
    Set Suite Variable  ${PUSERNAME_U2}
    ${firstname1}=  FakerLibrary.name
    Set Suite Variable  ${firstname1}
    ${lastname1}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname1}
    ${address}=  get_address
    Set Suite Variable  ${address}
    ${dob1}=  FakerLibrary.Date
    Set Suite Variable  ${dob1}
    ${pin}=  get_pincode
    Set Suite Variable  ${pin}

    ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U2}.${test_mail}   ${userType[0]}  ${pin2}  ${countryCodes[0]}  ${PUSERNAME_U2}  ${dep_id}  ${sub_domain_id}  ${bool[1]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u40_id1}  ${resp.json()}

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${p1_id40}   ${resp.json()[0]['id']}
    Set Suite Variable   ${p0_id40}   ${resp.json()[1]['id']}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Notification Settings of Consumer By User  ${p1_id40}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  404
    Should Be Equal As Strings  "${resp.json()}"   "${USER_NOT_FOUND}"


