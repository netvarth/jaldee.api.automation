
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
Variables         /ebs/TDD/varfiles/musers.py




*** Variables ***
${digits}       0123456789
@{EMPTY_Notification_List} 
@{person_ahead}   0  1  2  3  4  5  6
${self}         0
@{service_duration}   5   20
${parallel}     1
${SERVICE1}   SERVICE1
${SERVICE2}   SERVICE2
${SERVICE3}   SERVICE3
${SERVICE4}   SERVICE4
${SERVICE5}   SERVICE5
${SERVICE6}   SERVICE6



*** Test Cases ***

JD-TC-Update_Notification_Settings_of_ConsumerByUser-1
    [Documentation]   Getting Notification Settings of Consumer By USER Without Updating notification settings
    
    ${iscorp_subdomains}=  get_iscorp_subdomains  1
     Log  ${iscorp_subdomains}
     Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
     Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
     Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
     ${firstname_A}=  FakerLibrary.first_name
     Set Suite Variable  ${firstname_A}
     ${lastname_A}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname_A}
     ${MUSERNAME_E1}=  Evaluate  ${MUSERNAME}+7710177
     ${highest_package}=  get_highest_license_pkg
     ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${MUSERNAME_E1}    ${highest_package[0]}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Activation  ${MUSERNAME_E1}  0
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Set Credential  ${MUSERNAME_E1}  ${PASSWORD}  0
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Append To File  ${EXECDIR}/TDD/numbers.txt  ${MUSERNAME_E1}${\n}
     Set Suite Variable  ${MUSERNAME_E1}
     ${id}=  get_id  ${MUSERNAME_E1}
     Set Suite Variable  ${id}
     ${bs}=  FakerLibrary.bs
     Set Suite Variable  ${bs}


    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${ph1}=  Evaluate  ${MUSERNAME_E1}+1000000000
    ${ph2}=  Evaluate  ${MUSERNAME_E1}+2000000000
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}181.ynwtest@netvarth.com  ${views}
    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
    # ${city}=   FakerLibrary.state
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ${bool}
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    
    ${sTime}=  subtract_timezone_time  ${tz}  0  10
    Set Suite Variable  ${BsTime30}  ${sTime}
    ${eTime}=  add_timezone_time  ${tz}  1  30  
    Set Suite Variable  ${BeTime30}  ${eTime}
    ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep   02s

    
    ${fields}=   Get subDomain level Fields  ${domains}  ${sub_domains}
    Log  ${fields.json()}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_domains}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${domains}  ${sub_domains}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200


    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['enabledWaitlist']}==${bool[0]}
        ${resp}=  Enable Waitlist
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    sleep   01s

    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[0]} 
    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    

     ${resp}=  Toggle Department Enable
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     sleep  2s
     ${resp}=  Get Departments
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    
    ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+576087
    clear_users  ${PUSERNAME_U1}
    Set Suite Variable  ${PUSERNAME_U1}
    ${firstname1}=  FakerLibrary.name
    Set Suite Variable  ${firstname1}
    ${lastname1}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname1}
    ${dob1}=  FakerLibrary.Date
    Set Suite Variable  ${dob1}
    ${pin1}=  get_pincode
    
    ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.ynwtest@netvarth.com   ${userType[0]}  ${pin1}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${countryCodes[0]}  ${PUSERNAME_U1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id1}  ${resp.json()}

    ${number2}=  Random Int  min=2500  max=3500
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

     ${resp}=  Create User  ${firstname2}  ${lastname2}  ${dob2}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U2}.ynwtest@netvarth.com   ${userType[0]}  ${pin2}  ${countryCodes[0]}  ${PUSERNAME_U2}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${PUSERNAME_U2}  ${countryCodes[0]}  ${PUSERNAME_U2}
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
    

JD-TC-Update_Notification_Settings_of_ConsumerByUser-2
    [Documentation]   Update Early Notification and Getting Notification Settings of Consumer By USER
    
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
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

    


JD-TC-Update_Notification_Settings_of_ConsumerByUser-3
    [Documentation]   Update Prefinal Notification and Getting Notification Settings of Consumer By USER
    
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
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




JD-TC-Update_Notification_Settings_of_ConsumerByUser-4
    [Documentation]   Update Final Notification and Getting Notification Settings of Consumer By USER
    
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
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




JD-TC-Update_Notification_Settings_of_ConsumerByUser-5
    [Documentation]   Update Final Notification and Getting Notification Settings of Consumer By USER
    
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
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



JD-TC-Update_Notification_Settings_of_ConsumerByUser-6
    [Documentation]   Update AppointmentAdd and Getting Notification Settings of Consumer By USER
    
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
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
    Should Be Equal As Strings  ${resp.json()[7]['commonMessage']}  ${msg1}


JD-TC-Update_Notification_Settings_of_ConsumerByUser-7
    [Documentation]   Update Final Notification and Getting Notification Settings of Consumer By USER
    
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
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



JD-TC-Update_Notification_Settings_of_ConsumerByUser-8
    [Documentation]   Update prefinal Notification and Getting Notification Settings of Consumer By USER
    
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
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


JD-TC-Update_Notification_Settings_of_ConsumerByUser-9
    [Documentation]   Updated all notification settings of consumer By USER u_id1, then Get notification settings of consumer By another USER u_id2
    
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${p2_id}   ${resp.json()[2]['id']}
    # Set Suite Variable   ${p1_id}   ${resp.json()[1]['id']}
    # Set Suite Variable   ${p0_id}   ${resp.json()[0]['id']}

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
    


JD-TC-Update_Notification_Settings_of_ConsumerByUser-10
    [Documentation]   Update Notification Settings and Verify push notifications of WAITLIST-CANCEL
    clear_Consumermsg   ${CUSERNAME20}
    clear_Providermsg   ${MUSERNAME_E1}
    ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cons_fname}   ${resp.json()['firstName']}
    Set Test Variable  ${cons_lname}   ${resp.json()['lastName']}
    ${cid}=  get_id  ${CUSERNAME20}

    ${family_fname1}=  FakerLibrary.first_name
    ${family_lname1}=  FakerLibrary.last_name
    ${dob1}=  FakerLibrary.Date
    ${gender1}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMember   ${family_fname1}  ${family_lname1}  ${dob1}  ${gender1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${f_id1}   ${resp.json()}
    Set Suite Variable  ${uname_f_id1}   ${family_fname1} ${family_lname1}
   
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${P_Sector}   ${resp.json()['sector']}
    ${p_id}=  get_acc_id  ${MUSERNAME_E1}
    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${bname}   ${resp.json()['businessName']}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    ${sTime1}=  subtract_timezone_time  ${tz}  0  05
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  0  30  
    Set Suite Variable   ${eTime1}
    Set Test Variable  ${qTime}   ${sTime1}-${eTime1}
    
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']}
    ${description}=  FakerLibrary.sentence
    Set Suite Variable  ${description}
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    Set Suite Variable  ${dur}
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    Set Suite Variable  ${amt}
    ${totalamt}=  Convert To Number  ${amt}  1
    Set Suite Variable  ${totalamt}
    
    ${resp}=  Create Service For User  ${SERVICE1}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  ${EMPTY}  ${totalamt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${p1_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id1}  ${resp.json()}

    ${resp}=  Create Service For User  ${SERVICE2}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  ${EMPTY}  ${totalamt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${p1_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id2}  ${resp.json()}

    ${queue_name}=  FakerLibrary.name
    ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  10  ${lid}  ${p1_id}  ${s_id1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id}  ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME20}   firstName=${cons_fname}   lastName=${cons_lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pcid1}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME20}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid1}  ${resp.json()[0]['id']}
    Set Suite Variable  ${uname_c20}   ${resp.json()[0]['firstName']} ${resp.json()[0]['lastName']}

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${msg}=  FakerLibrary.word
    # ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${CUR_DAY}=  db.add_timezone_date  ${tz}  2   
    ${date}=  Convert Date  ${CUR_DAY}  result_format=%d-%m-%Y
    ${resp}=  Add To Waitlist Consumer For User  ${p_id}  ${que_id}  ${CUR_DAY}  ${s_id1}  ${msg}  ${bool[0]}  ${p1_id}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid0}  ${wid[0]} 
    ${resp}=  Get consumer Waitlist By Id   ${cwid0}  ${p_id}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE1}
    Set Suite Variable  ${estTime0}  ${resp.json()['serviceTime']}

    ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Add To Waitlist Consumer For User  ${p_id}  ${que_id}  ${CUR_DAY}  ${s_id1}  ${msg}  ${bool[0]}  ${p1_id}  ${f_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid1}  ${wid[0]} 
    ${resp}=  Get consumer Waitlist By Id   ${cwid1}  ${p_id}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE1}
    Set Suite Variable  ${estTime1}  ${resp.json()['serviceTime']}
    
    ${resp}=  Get consumer Waitlist By Id   ${cwid0}  ${p_id}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[0]}  paymentStatus=${paymentStatus[0]}  partySize=1  waitlistedBy=CONSUMER  personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${s_id1}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}           
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${cid1}  
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${que_id}


    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Waitlist EncodedId    ${cwid0}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${W_uuid0}   ${resp.json()}
    
    Set Suite Variable  ${W_encId0}  ${resp.json()}

    ${resp}=   Get Waitlist EncodedId    ${cwid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${W_uuid1}   ${resp.json()}
    
    Set Suite Variable  ${W_encId1}  ${resp.json()}

    ${resp}=  Get Appointment Messages
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${WaitlistNotify_msg}=  Set Variable   ${resp.json()['confirmationMessages']['Consumer_APP']} 
    ${defconsumerCancel_msg}=  Set Variable   ${resp.json()['cancellationMessages']['SP_APP']}
    
    ${bookingid}=  Format String  ${bookinglink}  ${W_encId0}  ${W_encId0}
    ${WaitlistNotify_msg0}=  Replace String  ${WaitlistNotify_msg}  [consumer]   ${uname_c20}
    ${WaitlistNotify_msg0}=  Replace String  ${WaitlistNotify_msg0}  [bookingId]   ${W_encId0}

     
    ${bookingid1}=  Format String  ${bookinglink}  ${W_encId1}  ${W_encId1}
    ${WaitlistNotify_msg1}=  Replace String  ${WaitlistNotify_msg}  [consumer]   ${uname_f_id1}
    ${WaitlistNotify_msg1}=  Replace String  ${WaitlistNotify_msg1}  [bookingId]   ${W_encId1}

    ${resp}=  Waitlist Action Cancel  ${cwid0}  ${waitlist_cancl_reasn[0]}  ${None}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  02s

    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Get User communications   ${p1_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        ${p1_id}
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${cwid0}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     ${cid}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['name']}   ${uname_c20}

    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}        ${p1_id}
    Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}         ${cwid1}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}     ${cid}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['name']}   ${uname_c20}


    ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${uname1}  ${resp.json()['userName']}
    ${DAY}=  Convert Date  ${CUR_DAY}  result_format=%a, %d %b %Y
   
    ${defaultmsg}=  Replace String  ${defconsumerCancel_msg}  [consumer]   ${uname_c20}
    ${defconsumerCancel_msg0}=  Replace String  ${defaultmsg}  [bookingId]   ${W_encId0}

    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  2  waitlistId=${cwid0}  service=${SERVICE1} on ${DAY}  accountId=${p_id}  msg=${defconsumerCancel_msg0}${SPACE}
    Should Be Equal As Strings  ${resp.json()[2]['owner']['id']}   ${p1_id}
    Should Be Equal As Strings  ${resp.json()[2]['receiver']['id']}   ${cid}
    
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        ${p1_id}
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${cwid0}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${WaitlistNotify_msg0}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     ${cid}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['name']}   ${uname_c20}

    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}        ${p1_id}
    Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}         ${cwid1}
    Should Be Equal As Strings  ${resp.json()[1]['msg']}                ${WaitlistNotify_msg1}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}     ${cid}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['name']}   ${uname_c20}


JD-TC-Update_Notification_Settings_of_ConsumerByUser-11
    [Documentation]   Update Notification Settings and Verify push notifications of APPOINTMENT-CANCEL
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${P_Sector}   ${resp.json()['sector']}
    ${p_id}=  get_acc_id  ${MUSERNAME_E1}
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME20}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pcid}  ${resp.json()[1]['id']}
     
    ${resp}=  ListFamilyMemberByProvider  ${pcid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${fid}  ${resp.json()[0]['id']}

    clear_consumer_msgs  ${CUSERNAME20}
    clear_provider_msgs  ${MUSERNAME_E1}
   
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']}
    ${description}=  FakerLibrary.sentence
    Set Suite Variable  ${description}


    ${resp}=  Appointment Status   ${toggle[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Accountsettings  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    waitlist=${bool[1]}   appointment=${bool[1]}   
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    ${sTime1}=  subtract_timezone_time  ${tz}  3  30
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  1  00  
    Set Suite Variable   ${eTime1}

    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${bool1}=  Random Element  ${bool}
    ${noOfOccurance}=  Random Int  min=5  max=15
    ${resp}=  Create Appointment Schedule For User  ${p1_id}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${noOfOccurance}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${service_duration[0]}  ${bool1}   ${s_id1}  ${s_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cid}=  get_id  ${CUSERNAME20} 
    

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${p_id}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${num_slots}=  Get Length  ${slots}
    ${p}=  Random Int  max=${num_slots-1}
    Set Test Variable   ${slot1}   ${slots[${p}]}

    ${q}=  Random Int  max=${num_slots-2}
    Set Test Variable   ${slot2}   ${slots[${q}]}

    ${cid1}=  get_id  ${CUSERNAME20}
    ${appt_for1}=  Create Dictionary  id=${self}   apptTime=${slot1}  
    ${apptfor1}=   Create List  ${appt_for1}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For User    ${p_id}  ${s_id1}  ${sch_id}  ${DAY1}  ${cnote}  ${p1_id}   ${apptfor1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid1}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${p_id}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${cid}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id1}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${appt_status[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['id']}   ${pcid}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['appmtTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}


    ${appt_for2}=  Create Dictionary  id=${f_id1}   apptTime=${slot2}  
    ${apptfor2}=   Create List  ${appt_for2}
    ${resp}=   Take Appointment For User    ${p_id}  ${s_id1}  ${sch_id}  ${DAY1}  ${cnote}  ${p1_id}   ${apptfor2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid2}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${p_id}  ${apptid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid2}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${cid}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id1}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${appt_status[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['id']}   ${f_id}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot2}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['appmtTime']}   ${slot2}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}



    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId1}=  Set Variable   ${resp.json()}
    Set Suite Variable  ${encId1}  ${encId1}


    ${resp}=  Get Appointment EncodedID   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId2}=  Set Variable   ${resp.json()}
    Set Suite Variable  ${encId2}  ${encId2}


    ${resp}=  Get Appointment Messages
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${confirmAppt_push}=  Set Variable   ${resp.json()['confirmationMessages']['SP_APP']} 
    ${defconsumerCancel_msg}=  Set Variable   ${resp.json()['cancellationMessages']['SP_APP']}
   
    ${reason}=  Random Element  ${cancelReason}
    ${msg}=   FakerLibrary.word
    ${resp}=    Provider Cancel Appointment  ${apptid1}  ${reason}  ${None}  ${DAY1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  3s

    ${date}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y
    ${converted_slot1}=  convert_slot_12hr  ${slot1} 
    log    ${converted_slot1}
    ${converted_slot2}=  convert_slot_12hr  ${slot2} 
    log    ${converted_slot2}
    ${defconfirm_msg1}=  Replace String  ${confirmAppt_push}  [username]   ${uname_c20} 
    ${defconfirm_msg1}=  Replace String  ${defconfirm_msg1}  [service]   ${SERVICE1}
    ${defconfirm_msg1}=  Replace String  ${defconfirm_msg1}  [date]   ${date}
    ${defconfirm_msg1}=  Replace String  ${defconfirm_msg1}  [time]   ${converted_slot1}
    ${defconfirm_msg1}=  Replace String  ${defconfirm_msg1}  [providerName]   ${bname}

    ${defconfirm_msg2}=  Replace String  ${confirmAppt_push}  [username]   ${uname_f_id1} 
    ${defconfirm_msg2}=  Replace String  ${defconfirm_msg2}  [service]   ${SERVICE1}
    ${defconfirm_msg2}=  Replace String  ${defconfirm_msg2}  [date]   ${date}
    ${defconfirm_msg2}=  Replace String  ${defconfirm_msg2}  [time]   ${converted_slot2}
    ${defconfirm_msg2}=  Replace String  ${defconfirm_msg2}  [providerName]   ${bname}


    ${defcancel_msg}=  Replace String  ${defconsumerCancel_msg}  [username]   ${uname_c20} 
    ${defcancel_msg}=  Replace String  ${defcancel_msg}  [provider name]   ${bname}
    ${defcancel_msg}=  Replace String  ${defcancel_msg}  [time]   ${SPACE}${converted_slot1}
    ${defcancel_msg}=  Replace String  ${defcancel_msg}  [date]   ${date}
    ${defcancel_msg}=  Replace String  ${defcancel_msg}  [service]   ${SERVICE1}
    

    ${bookingid1}=  Format String  ${bookinglink}  ${encId1}  ${encId1}
    ${defconfirm_msg1}=  Replace String  ${confirmAppt_push}  [consumer]   ${uname_c20}
    ${defconfirm_msg1}=  Replace String  ${defconfirm_msg1}  [bookingId]   ${encId1}

    ${bookingid2}=  Format String  ${bookinglink}  ${encId2}  ${encId2}
    ${defconfirm_msg2}=  Replace String  ${confirmAppt_push}  [consumer]   ${uname_f_id1}
    ${defconfirm_msg2}=  Replace String  ${defconfirm_msg2}  [bookingId]   ${encId2}

    ${defaultmsg}=  Replace String  ${defconsumerCancel_msg}  [consumer]   ${uname_c20}
    ${defconsumerCancel_msg0}=  Replace String  ${defaultmsg}  [bookingId]   ${encId1}


    
    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        ${p1_id}
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${apptid1}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${defconfirm_msg1}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     ${cid}

    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}        ${p1_id}
    Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}         ${apptid2}
    Should Be Equal As Strings  ${resp.json()[1]['msg']}                ${defconfirm_msg2}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}     ${cid}

    Should Be Equal As Strings  ${resp.json()[2]['owner']['id']}        ${p1_id}
    Should Be Equal As Strings  ${resp.json()[2]['waitlistId']}         ${apptid1}
    Should Be Equal As Strings  ${resp.json()[2]['msg']}                ${defconsumerCancel_msg0}${SPACE}
    Should Be Equal As Strings  ${resp.json()[2]['receiver']['id']}     ${cid}



    ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    

    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        ${p1_id}
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${apptid1}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${defconfirm_msg1}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     ${cid}

    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}        ${p1_id}
    Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}         ${apptid2}
    Should Be Equal As Strings  ${resp.json()[1]['msg']}                ${defconfirm_msg2}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}     ${cid}

    Should Be Equal As Strings  ${resp.json()[2]['owner']['id']}        ${p1_id}
    Should Be Equal As Strings  ${resp.json()[2]['waitlistId']}         ${apptid1}
    Should Be Equal As Strings  ${resp.json()[2]['msg']}                ${defconsumerCancel_msg0}${SPACE}
    Should Be Equal As Strings  ${resp.json()[2]['receiver']['id']}     ${cid}



JD-TC-Update_Notification_Settings_of_ConsumerByUser -UH1
    [Documentation]   Update notification settings of Consumer By USER without login 
    ${msg1}=  FakerLibrary.text 
    ${person_ahead1}=   Random Int  min=3   max=7
    ${resp}=  Update Notification Settings of Consumer By User  ${p1_id}  ${NotificationResourceType[1]}  ${EventType[5]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${msg1}  ${person_ahead1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"



JD-TC-Update_Notification_Settings_of_ConsumerByUser -UH2
    [Documentation]   Use provider_id (admin user) to Update Notification Settings of Consumer By User 
    
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Notification Settings of Consumer By User  ${p0_id}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  "${resp.json()}"  "${ALERT_USER_NOT_FOUND}"
    Set Test Variable   ${person_ahead1}    ${resp.json()[5]['personsAhead']} 

    ${msg1}=  FakerLibrary.text 
   # ${person_ahead3}=   Random Int  min=3   max=7
    ${resp}=  Update Notification Settings of Consumer By User  ${p0_id}  ${NotificationResourceType[1]}  ${EventType[5]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${msg1}  ${person_ahead1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  "${resp.json()}"  "${ALERT_USER_NOT_FOUND}"
    sleep  3s
    ${resp}=  Get Notification Settings of Consumer By User  ${p0_id}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    comment   PREFINAL NOTIFICATION-APPOINTMENT
    Should Be Equal As Strings  ${resp.json()[5]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[5]['eventType']}  ${EventType[5]}
    Should Be Equal As Strings  ${resp.json()[5]['email']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[5]['sms']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[5]['pushNotification']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[5]['personsAhead']}    ${person_ahead1}


JD-TC-Update_Notification_Settings_of_ConsumerByUser -UH3
    [Documentation]   Consumer try to Update notification settings
    ${resp}=   Consumer Login  ${CUSERNAME20}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}    200
    ${msg1}=  FakerLibrary.text 
    ${person_ahead1}=   Random Int  min=3   max=7
    ${resp}=  Update Notification Settings of Consumer By User  ${p1_id}  ${NotificationResourceType[1]}  ${EventType[5]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${msg1}  ${person_ahead1}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"



JD-TC-Update_Notification_Settings_of_ConsumerByUser -UH4
	[Documentation]  invalid provider

    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Invalid_id}=  Random Int  min=100000  max=200000
    ${msg1}=  FakerLibrary.text 
    ${person_ahead1}=   Random Int  min=3   max=7
    ${resp}=  Update Notification Settings of Consumer By User  ${Invalid_id}  ${NotificationResourceType[1]}  ${EventType[5]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${msg1}  ${person_ahead1}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  "${resp.json()}"  "${USER_NOT_FOUND}"



JD-TC-Update_Notification_Settings_of_ConsumerByUser -UH5
    [Documentation]  Update Notification Settings of Consumer By User using Disabled USER_id
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  EnableDisable User  ${p1_id}  ${toggle[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${USER_CANNOT_BE_DISABLED}"
    	 

JD-TC-Update_Notification_Settings_of_ConsumerByUser-UH6
    [Documentation]   Update notification settings of Consumer By USER, using user_id of another provider
    
    ${iscorp_subdomains}=  get_iscorp_subdomains  1
     Log  ${iscorp_subdomains}
     Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
     Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
     Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
     ${firstname_A}=  FakerLibrary.first_name
     Set Suite Variable  ${firstname_A}
     ${lastname_A}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname_A}
     ${MUSERNAME_E2}=  Evaluate  ${PUSERNAME}+6718176
     ${highest_package}=  get_highest_license_pkg
     ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${MUSERNAME_E2}    ${highest_package[0]}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Activation  ${MUSERNAME_E2}  0
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Set Credential  ${MUSERNAME_E2}  ${PASSWORD}  0
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Encrypted Provider Login  ${MUSERNAME_E2}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Append To File  ${EXECDIR}/TDD/numbers.txt  ${MUSERNAME_E2}${\n}
     Set Suite Variable  ${MUSERNAME_E2}
     ${id}=  get_id  ${MUSERNAME_E2}
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


    ${PUSERNAME_U2}=  Evaluate  ${PUSERNAME}+578949
    clear_users  ${PUSERNAME_U2}
    Set Suite Variable  ${PUSERNAME_U2}
    ${firstname1}=  FakerLibrary.name
    Set Suite Variable  ${firstname1}
    ${lastname1}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname1}
    ${dob1}=  FakerLibrary.Date
    Set Suite Variable  ${dob1}
    ${pin1}=  get_pincode
   
    ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U2}.ynwtest@netvarth.com   ${userType[0]}  ${pin1}  ${countryCodes[0]}  ${PUSERNAME_U2}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${PUSERNAME_U2}  ${countryCodes[0]}  ${PUSERNAME_U2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u40_id1}  ${resp.json()}

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${p1_id40}   ${resp.json()[0]['id']}
    Set Suite Variable   ${p0_id40}   ${resp.json()[1]['id']}


    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${msg1}=  FakerLibrary.text 
    ${person_ahead1}=   Random Int  min=3   max=7
    ${resp}=  Update Notification Settings of Consumer By User  ${p1_id40}  ${NotificationResourceType[1]}  ${EventType[5]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${msg1}  ${person_ahead1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   "${resp.json()}"   "${USER_NOT_FOUND}"



