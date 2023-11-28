
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
@{EMPTY_List} 
${digits}       0123456789 
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

JD-TC-Update_Notification_Settings_of_User-1
    [Documentation]   Getting notification settings of USER Without Updating notification settings
    
    ${iscorp_subdomains}=  get_iscorp_subdomains  1
     Log  ${iscorp_subdomains}
     Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
     Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
     Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
     ${firstname_A}=  FakerLibrary.first_name
     ${lastname_A}=  FakerLibrary.last_name
     ${MUSERNAME_E1}=  Evaluate  ${MUSERNAME}+6610166
     ${highest_package}=  get_highest_license_pkg
     Set Suite Variable  ${EMAIL_id0}   ${P_Email}${MUSERNAME_E1}.${test_mail}
     ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${EMAIL_id0}  ${domains}  ${sub_domains}  ${MUSERNAME_E1}    ${highest_package[0]}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Activation  ${EMAIL_id0}  0
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Set Credential  ${EMAIL_id0}  ${PASSWORD}  0
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Append To File  ${EXECDIR}/TDD/numbers.txt  ${MUSERNAME_E1}${\n}
     Set Suite Variable  ${MUSERNAME_E1}
     ${id}=  get_id  ${MUSERNAME_E1}
     Set Suite Variable  ${id}
    
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
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}181.${test_mail}  ${views}
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
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${sTime}=  db.subtract_timezone_time  ${tz}  3  00
    Set Suite Variable  ${BsTime30}  ${sTime}
    ${eTime}=  add_timezone_time  ${tz}  2  30  
    Set Suite Variable  ${BeTime30}  ${eTime}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 

    ${resp}=  Update Business Profile With Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep   02s

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

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
    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[0]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    

    ${resp}=  Toggle Department Enable
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  02s
    ${resp}=  Get Departments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    
    ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+9047771
    clear_users  ${PUSERNAME_U1}
    Set Suite Variable  ${PUSERNAME_U1}
    Set Suite Variable  ${PUser1_EMAIL}   ${P_Email}${PUSERNAME_U1}.${test_mail}
    ${firstname1}=  FakerLibrary.name
    Set Suite Variable  ${firstname1}
    ${lastname1}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname1}
    ${dob1}=  FakerLibrary.Date
    Set Suite Variable  ${dob1}
    ${pin1}=  get_pincode
     ${user_dis_name}=  FakerLibrary.last_name
     Set Suite Variable  ${user_dis_name}
     ${employee_id}=  FakerLibrary.last_name
     Set Suite Variable  ${employee_id}

    ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin1}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}  bProfilePermitted  ${boolean[1]}  displayOrder  1  userDisplayName  ${user_dis_name}  employeeId  ${employee_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id1}  ${resp.json()}


    ${resp}=  Get specializations Sub Domain  ${domains}  ${sub_domains}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${spec}=  get_specs  ${resp.json()}
    Log  ${spec}

    ${resp}=  Get Spoke Languages
    Should Be Equal As Strings    ${resp.status_code}   200 
    ${Languages}=  get_Languagespoken  ${resp.json()}
    Log  ${Languages}

    ${bs_des}=  FakerLibrary.word
    ${resp}=  User Profile Updation  ${bs}  ${bs_des}  ${spec}  ${Languages}  ${sub_domain_id}  ${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${u_p_id1}  ${resp.json()['profileId']}

    ${resp}=  Get User Profile  ${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    

    ${number2}=  Random Int  min=2500  max=3500
    ${PUSERNAME_U2}=  Evaluate  ${PUSERNAME}+${number2}
    clear_users  ${PUSERNAME_U2}
    Set Suite Variable  ${PUSERNAME_U2}
    Set Suite Variable  ${PUser2_EMAIL}   ${P_Email}${PUSERNAME_U2}.${test_mail}
    ${firstname2}=  FakerLibrary.name
    Set Suite Variable  ${firstname2}
    ${lastname2}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname2}
    ${dob2}=  FakerLibrary.Date
    Set Suite Variable  ${dob2}
    ${pin1}=  get_pincode 

    ${resp}=  Create User  ${firstname2}  ${lastname2}  ${dob2}  ${Genderlist[0]}  ${PUser2_EMAIL}   ${userType[0]}  ${pin1}  ${countryCodes[0]}  ${PUSERNAME_U2}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id2}  ${resp.json()}

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${p2_id}   ${resp.json()[0]['id']}
    # Set Suite Variable   ${u_id1}   ${resp.json()[1]['id']}
    # Set Suite Variable   ${p0_id}   ${resp.json()[2]['id']}

    Set Suite Variable  ${countryCode_CC0}    ${countryCodes[0]}

    ${resp}=  Get Notification Settings of User  ${u_id1}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    comment   WAITLISTADD
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${EventType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['email'][0]}  ${PUser1_EMAIL}
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['number']}           ${PUSERNAME_U1} 
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['number']}       ${PUSERNAME_U1} 
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[0]['sms'][0]}  ${PUSERNAME_U1}
    # Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]}  ${PUSERNAME_U1}

    comment   WAITLIST-CANCEL
    Should Be Equal As Strings  ${resp.json()[1]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['eventType']}  ${EventType[1]}
    Should Be Equal As Strings  ${resp.json()[1]['email'][0]}  ${PUser1_EMAIL}
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['number']}           ${PUSERNAME_U1} 
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['number']}       ${PUSERNAME_U1} 
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[1]['sms'][0]}  ${PUSERNAME_U1}
    # Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]}  ${PUSERNAME_U1}
    
    comment   APPOINTMENTADD
    Should Be Equal As Strings  ${resp.json()[2]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[2]['eventType']}  ${EventType[7]}
    Should Be Equal As Strings  ${resp.json()[2]['email'][0]}  ${PUser1_EMAIL}
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['number']}           ${PUSERNAME_U1} 
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['number']}       ${PUSERNAME_U1} 
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[2]['sms'][0]}  ${PUSERNAME_U1}
    # Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]}  ${PUSERNAME_U1}
    
    comment   APPOINTMENT-CANCEL
    Should Be Equal As Strings  ${resp.json()[3]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[3]['eventType']}  ${EventType[8]}
    Should Be Equal As Strings  ${resp.json()[3]['email'][0]}  ${PUser1_EMAIL}
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['number']}           ${PUSERNAME_U1} 
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['number']}       ${PUSERNAME_U1} 
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[3]['sms'][0]}  ${PUSERNAME_U1}
    # Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]}  ${PUSERNAME_U1}
    

JD-TC-Update_Notification_Settings_of_User-3
    [Documentation]   Update Provider Notification Settings of WAITLISTADD and Getting Notification Settings of USER
    
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Notification Settings of User  ${u_id1}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    comment   WAITLISTADD-initial
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${EventType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['email'][0]}  ${PUser1_EMAIL}
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['number']}           ${PUSERNAME_U1} 
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['number']}       ${PUSERNAME_U1} 
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[0]['sms'][0]}  ${PUSERNAME_U1}
    # Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]}  ${PUSERNAME_U1}
    
    ${PUSERNAME_U12}=  Evaluate  ${PUSERNAME}+99912
    clear_users  ${PUSERNAME_U12}
    Set Suite Variable  ${PUSERNAME_U12}  
    # Set Suite Variable  @{PUSERNAME_U12_list}   ${PUSERNAME_U12}
    ${MSG_Ph1}=  Create Dictionary   number=${PUSERNAME_U12}   countryCode=${countryCode_CC0}
    Set Suite Variable  @{PUSERNAME_U12_list}    ${MSG_Ph1}

    Set Suite Variable  ${PUser12_EMAIL}   ${P_Email}${PUSERNAME_U12}.${test_mail}
    Set Suite Variable  @{PUser12_EMAIL_list}   ${PUser12_EMAIL}

    ${PushMSG}=  Create Dictionary   number=${PUSERNAME_U1}   countryCode=${countryCode_CC0}
    Set Suite Variable  @{PushMSG_Num_list}   ${PushMSG}

    # ${countryCode_CC1}    Random Element    ${CC_countryCode}
    # Set Suite Variable  ${countryCode_CC1}
    # ${MSG_Ph1}=  Create Dictionary   number=${PUSERNAME_U2}   countryCode=${countryCode_CC0}
    # Set Suite Variable  @{SMS_Num_list2}    ${MSG_Ph1}
    # Set Suite Variable  ${USERPH1}   ${PUSERPH0}
    # Set Suite Variable  ${PUser_EMAIL2}   ${P_Email}${PUSERNAME_U2}.${test_mail}
    # Set Suite Variable  @{PUser_EMAIL_list2}   ${PUser_EMAIL2}
    # ${PushMSG}=  Create Dictionary   number=${USERPH1}   countryCode=${countryCode_CC0}
    # Set Suite Variable  @{PushMSG_Num_list2}    ${PushMSG} 

    
    # Set Suite Variable  @{PUser12_EMAIL_list}   ${PUser12_EMAIL}
    # Set Test Variable  @{PushMSG_Num_list}   ${PUSERNAME_U1}
    

    ${resp}=  Update Notification Settings of User  ${u_id1}  ${NotificationResourceType[0]}  ${EventType[0]}  ${PUSERNAME_U12_list}  ${PUser12_EMAIL_list}  ${PushMSG_Num_list}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Notification Settings of User  ${u_id1}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    comment   WAITLISTADD-updated
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${EventType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['email'][0]}  ${PUser12_EMAIL}
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['number']}           ${PUSERNAME_U12} 
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['number']}       ${PUSERNAME_U1} 
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[0]['sms'][0]}  ${PUSERNAME_U12}
    # Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]}  ${PUSERNAME_U1}



JD-TC-Update_Notification_Settings_of_User-4
    [Documentation]   Update Provider Notification Settings of WAITLIST-CANCEL and Getting Notification Settings of USER

    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Notification Settings of User  ${u_id1}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    comment   WAITLIST-CANCEL-initial
    Should Be Equal As Strings  ${resp.json()[1]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['eventType']}  ${EventType[1]}
    Should Be Equal As Strings  ${resp.json()[1]['email'][0]}  ${PUser1_EMAIL}
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['number']}           ${PUSERNAME_U1} 
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['number']}       ${PUSERNAME_U1} 
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[1]['sms'][0]}  ${PUSERNAME_U1}
    # Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]}  ${PUSERNAME_U1}
   
    ${PUSERNAME_U13}=  Evaluate  ${PUSERNAME}+99913
    clear_users  ${PUSERNAME_U13}
    Set Suite Variable  ${PUSERNAME_U13}  
    # Set Suite Variable  @{PUSERNAME_U13_list}   ${PUSERNAME_U13}
    # Set Test Variable  @{PushMSG_Num_list}   ${PUSERNAME_U1}
    Set Suite Variable  ${PUser13_EMAIL}   ${P_Email}${PUSERNAME_U13}.${test_mail}
    Set Suite Variable  @{PUser13_EMAIL_list}   ${PUser13_EMAIL}

    ${MSG_Ph1}=  Create Dictionary   number=${PUSERNAME_U13}   countryCode=${countryCode_CC0}
    Set Suite Variable  @{PUSERNAME_U13_list}    ${MSG_Ph1}

    ${PushMSG}=  Create Dictionary   number=${PUSERNAME_U1}   countryCode=${countryCode_CC0}
    Set Suite Variable  @{PushMSG_Num_list}   ${PushMSG}

    ${resp}=  Update Notification Settings of User  ${u_id1}  ${NotificationResourceType[0]}  ${EventType[1]}  ${PUSERNAME_U13_list}  ${PUser13_EMAIL_list}  ${PushMSG_Num_list}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Notification Settings of User  ${u_id1}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    comment   WAITLIST-CANCEL-updated
    Should Be Equal As Strings  ${resp.json()[1]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['eventType']}  ${EventType[1]}
    Should Be Equal As Strings  ${resp.json()[1]['email'][0]}  ${PUser13_EMAIL}
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['number']}           ${PUSERNAME_U13} 
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['number']}       ${PUSERNAME_U1} 
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[1]['sms'][0]}  ${PUSERNAME_U13}
    # Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]}  ${PUSERNAME_U1}


JD-TC-Update_Notification_Settings_of_User-5
    [Documentation]   Update Provider Notification Settings of APPOINTMENTADD and Getting Notification Settings of USER

    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Notification Settings of User  ${u_id1}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    comment   APPOINTMENTADD-initial
    Should Be Equal As Strings  ${resp.json()[2]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[2]['eventType']}  ${EventType[7]}
    Should Be Equal As Strings  ${resp.json()[2]['email'][0]}  ${PUser1_EMAIL}
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['number']}           ${PUSERNAME_U1} 
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['number']}       ${PUSERNAME_U1} 
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[2]['sms'][0]}  ${PUSERNAME_U1}
    # Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]}  ${PUSERNAME_U1}
    
    ${PUSERNAME_U14}=  Evaluate  ${PUSERNAME}+99914
    clear_users  ${PUSERNAME_U14}
    Set Suite Variable  ${PUSERNAME_U14}  
    # Set Suite Variable  @{PUSERNAME_U14_list}   ${PUSERNAME_U14}

    Set Suite Variable  ${PUser14_EMAIL}   ${P_Email}${PUSERNAME_U14}.${test_mail}
    Set Suite Variable  @{PUser14_EMAIL_list}   ${PUser14_EMAIL}

    # Set Test Variable  @{PushMSG_Num_list}   ${PUSERNAME_U1}
    ${MSG_Ph1}=  Create Dictionary   number=${PUSERNAME_U14}   countryCode=${countryCode_CC0}
    Set Suite Variable  @{PUSERNAME_U14_list}    ${MSG_Ph1}

    ${PushMSG}=  Create Dictionary   number=${PUSERNAME_U1}   countryCode=${countryCode_CC0}
    Set Suite Variable  @{PushMSG_Num_list}   ${PushMSG}


    ${resp}=  Update Notification Settings of User  ${u_id1}  ${NotificationResourceType[1]}  ${EventType[7]}  ${PUSERNAME_U14_list}  ${PUser14_EMAIL_list}  ${PushMSG_Num_list}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Notification Settings of User  ${u_id1}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    comment   APPOINTMENTADD-updated
    Should Be Equal As Strings  ${resp.json()[2]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[2]['eventType']}  ${EventType[7]}
    Should Be Equal As Strings  ${resp.json()[2]['email'][0]}  ${PUser14_EMAIL}
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['number']}           ${PUSERNAME_U14} 
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['number']}       ${PUSERNAME_U1} 
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[2]['sms'][0]}  ${PUSERNAME_U14}
    # Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]}  ${PUSERNAME_U1}


JD-TC-Update_Notification_Settings_of_User-6
    [Documentation]   Update Provider Notification Settings of APPOINTMENT-CANCEL and Getting Notification Settings of USER

    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Notification Settings of User  ${u_id1}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    comment   APPOINTMENT-CANCEL-initial
    Should Be Equal As Strings  ${resp.json()[3]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[3]['eventType']}  ${EventType[8]}
    Should Be Equal As Strings  ${resp.json()[3]['email'][0]}  ${PUser1_EMAIL}
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['number']}           ${PUSERNAME_U1} 
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['number']}       ${PUSERNAME_U1} 
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[3]['sms'][0]}  ${PUSERNAME_U1}
    # Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]}  ${PUSERNAME_U1}
   
    ${PUSERNAME_U15}=  Evaluate  ${PUSERNAME}+99915
    clear_users  ${PUSERNAME_U15}
    Set Suite Variable  ${PUSERNAME_U15}  
    # Set Suite Variable  @{PUSERNAME_U15_list}   ${PUSERNAME_U15}

    
    Set Suite Variable  ${PUser15_EMAIL}   ${P_Email}${PUSERNAME_U15}.${test_mail}
    Set Suite Variable  @{PUser15_EMAIL_list}   ${PUser15_EMAIL}

    # Set Test Variable  @{PushMSG_Num_list}   ${PUSERNAME_U1}
    ${MSG_Ph1}=  Create Dictionary   number=${PUSERNAME_U15}   countryCode=${countryCode_CC0}
    Set Suite Variable  @{PUSERNAME_U15_list}    ${MSG_Ph1}

    ${PushMSG}=  Create Dictionary   number=${PUSERNAME_U1}   countryCode=${countryCode_CC0}
    Set Suite Variable  @{PushMSG_Num_list}   ${PushMSG}

    ${resp}=  Update Notification Settings of User  ${u_id1}  ${NotificationResourceType[1]}  ${EventType[8]}  ${PUSERNAME_U15_list}  ${PUser15_EMAIL_list}  ${PushMSG_Num_list}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Notification Settings of User  ${u_id1}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    comment   APPOINTMENT-CANCEL-updated
    Should Be Equal As Strings  ${resp.json()[3]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[3]['eventType']}  ${EventType[8]}
    Should Be Equal As Strings  ${resp.json()[3]['email'][0]}  ${PUser15_EMAIL}
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['number']}           ${PUSERNAME_U15} 
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['number']}       ${PUSERNAME_U1} 
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[3]['sms'][0]}  ${PUSERNAME_U15}
    # Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]}  ${PUSERNAME_U1}


JD-TC-Update_Notification_Settings_of_User-7
    [Documentation]   Updated all notification settings of one USER u_id1, then Get notification settings of another USER u_id2
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Notification Settings of User  ${p2_id}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    comment   WAITLISTADD
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${EventType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['email'][0]}  ${PUser2_EMAIL}
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['number']}           ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['number']}       ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[0]['sms'][0]}  ${PUSERNAME_U2}
    # Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]}  ${PUSERNAME_U2}
   
    comment   WAITLIST-CANCEL
    Should Be Equal As Strings  ${resp.json()[1]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['eventType']}  ${EventType[1]}
    Should Be Equal As Strings  ${resp.json()[1]['email'][0]}  ${PUser2_EMAIL}
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['number']}           ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['number']}       ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[1]['sms'][0]}  ${PUSERNAME_U2}
    # Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]}  ${PUSERNAME_U2}
   

    comment   APPOINTMENTADD
    Should Be Equal As Strings  ${resp.json()[2]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[2]['eventType']}  ${EventType[7]}
    Should Be Equal As Strings  ${resp.json()[2]['email'][0]}  ${PUser2_EMAIL}
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['number']}           ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['number']}       ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[2]['sms'][0]}  ${PUSERNAME_U2}
    # Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]}  ${PUSERNAME_U2}
    

    comment   APPOINTMENT-CANCEL
    Should Be Equal As Strings  ${resp.json()[3]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[3]['eventType']}  ${EventType[8]}
    Should Be Equal As Strings  ${resp.json()[3]['email'][0]}  ${PUser2_EMAIL}
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['number']}           ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['number']}       ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[3]['sms'][0]}  ${PUSERNAME_U2}
    # Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]}  ${PUSERNAME_U2}
  
JD-TC-Update_Notification_Settings_of_User-8
    [Documentation]   Update Provider Notification Settings and Verify push notifications during WAITLISTADD and WAITLIST-CANCEL
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${P_Sector}   ${resp.json()['sector']}
    ${p_id}=  get_acc_id  ${MUSERNAME_E1}

    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    ${sTime1}=  db.subtract_timezone_time  ${tz}  0  15
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  2  00  
    Set Suite Variable   ${eTime1}
    
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

    ${resp}=  Get User Profile  ${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    

    ${resp}=  Create Service For User  ${SERVICE1}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  ${EMPTY}  ${totalamt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id1}  ${resp.json()}

    ${resp}=  Create Service For User  ${SERVICE2}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  ${EMPTY}  ${totalamt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id2}  ${resp.json()}

    ${queue_name}=  FakerLibrary.name
    ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${u_id1}  ${s_id1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id}  ${resp.json()}

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cid}=  get_id  ${CUSERNAME1}
    
    ${msg}=  FakerLibrary.word
    # ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${CUR_DAY}=  db.add_timezone_date  ${tz}  7   
    ${resp}=  Add To Waitlist Consumer For User  ${p_id}  ${que_id}  ${CUR_DAY}  ${s_id1}  ${msg}  ${bool[0]}  ${u_id1}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid}  ${wid[0]} 

    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pcid1}  ${resp.json()[0]['id']}

    ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get consumer Waitlist By Id   ${cwid}  ${p_id}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[0]}  paymentStatus=${paymentStatus[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=CONSUMER  personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${s_id1}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid}           
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcid1}  
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${que_id}
    sleep  02s

    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${msg1}=   FakerLibrary.word
    ${resp}=  Waitlist Action Cancel  ${cwid}  ${waitlist_cancl_reasn[0]}  ${msg1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  02s
    

    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  

    ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    

    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    

JD-TC-Update_Notification_Settings_of_User-9
    [Documentation]   Update Provider Notification Settings and Verify push notifications during APPOINTMENTADD and APPOINTMENT-CANCEL
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${P_Sector}   ${resp.json()['sector']}
    ${p_id}=  get_acc_id  ${MUSERNAME_E1}
       

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  2  00  
    Set Suite Variable   ${eTime1}
      
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
    

    ${resp}=  Appointment Status   ${toggle[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Accountsettings  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    waitlist=${bool[1]}   appointment=${bool[1]}   

    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime1}
    ${delta}=  FakerLibrary.Random Int  min=60  max=120
    Set Suite Variable  ${delta}
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    Set Suite Variable   ${eTime1}

    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${bool1}=  Random Element  ${bool}
    ${noOfOccurance}=  Random Int  min=5  max=15
    ${resp}=  Create Appointment Schedule For User  ${u_id1}  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${noOfOccurance}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${service_duration[0]}  ${bool1}   ${s_id1}  ${s_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}
    
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pcid1}  ${resp.json()[0]['id']}

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cid}=  get_id  ${CUSERNAME1}
    
    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${p_id}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Test Variable   ${slot1}   ${slots[${j}]}
    
    ${cid1}=  get_id  ${CUSERNAME1}
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}  
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For User    ${p_id}  ${s_id1}  ${sch_id}  ${DAY1}  ${cnote}  ${u_id1}   ${apptfor}
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
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['id']}   ${pcid1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['appmtTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}


    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   

    ${reason}=  Random Element  ${cancelReason}
    ${msg}=   FakerLibrary.word
    ${resp}=    Provider Cancel Appointment  ${apptid1}  ${reason}  ${msg}  ${DAY1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
JD-TC-Update_Notification_Settings_of_User-10
    [Documentation]   Update Notification Settings of USER for APPOINTMENTADD using PushMsg number of another user (two users are from same provider)
    
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings   ${resp.json()[0]['id']}   ${p2_id}
    Should Be Equal As Strings   ${resp.json()[0]['mobileNo']}   ${PUSERNAME_U2}

    Should Be Equal As Strings   ${resp.json()[1]['id']}   ${u_id1}
    Should Be Equal As Strings   ${resp.json()[1]['mobileNo']}   ${PUSERNAME_U1}


    ${resp}=  Get Notification Settings of User  ${u_id1}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    comment   APPOINTMENTADD-initial
    Should Be Equal As Strings  ${resp.json()[2]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[2]['eventType']}  ${EventType[7]}
    Should Be Equal As Strings  ${resp.json()[2]['email'][0]}  ${PUser14_EMAIL}
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['number']}           ${PUSERNAME_U14} 
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['number']}       ${PUSERNAME_U1} 
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[2]['sms'][0]}  ${PUSERNAME_U14}
    # Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]}  ${PUSERNAME_U1}
  
    # Set Test Variable  @{PushMSG_Num_list}   ${PUSERNAME_U2}

    ${PushMSG}=  Create Dictionary   number=${PUSERNAME_U2}   countryCode=${countryCode_CC0}
    Set Suite Variable  @{PushMSG_Num_list}   ${PushMSG}

    ${resp}=  Update Notification Settings of User  ${u_id1}  ${NotificationResourceType[1]}  ${EventType[7]}  ${PUSERNAME_U14_list}  ${PUser14_EMAIL_list}  ${PushMSG_Num_list}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Notification Settings of User  ${u_id1}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    comment   APPOINTMENTADD-updated
    Should Be Equal As Strings  ${resp.json()[2]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[2]['eventType']}  ${EventType[7]}
    Should Be Equal As Strings  ${resp.json()[2]['email'][0]}  ${PUser14_EMAIL}
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['number']}           ${PUSERNAME_U14} 
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['number']}       ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[2]['sms'][0]}  ${PUSERNAME_U14}
    # Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]}  ${PUSERNAME_U2}
    

JD-TC-Update_Notification_Settings_of_User-11
    [Documentation]   Update Notification Settings of USER for WAITLISTADD using pushMSG number as EMPTY
    
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Notification Settings of User  ${u_id1}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    comment   WAITLISTADD-initial
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${EventType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['email'][0]}  ${PUser12_EMAIL}
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['number']}           ${PUSERNAME_U12} 
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['number']}       ${PUSERNAME_U1} 
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[0]['sms'][0]}  ${PUSERNAME_U12}
    # Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]}  ${PUSERNAME_U1}
    
    ${resp}=  Update Notification Settings of User  ${u_id1}  ${NotificationResourceType[0]}  ${EventType[0]}  ${PUSERNAME_U12_list}  ${PUser12_EMAIL_list}  ${EMPTY_List}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Notification Settings of User  ${u_id1}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    comment   WAITLISTADD-updated
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${EventType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['email'][0]}  ${PUser12_EMAIL}
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['number']}           ${PUSERNAME_U12} 
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg']}  ${EMPTY_List}
    # Should Be Equal As Strings  ${resp.json()[0]['sms'][0]}  ${PUSERNAME_U12}
    # Should Be Equal As Strings  ${resp.json()[0]['pushMsg']}  ${EMPTY_List}
    
JD-TC-Update_Notification_Settings_of_User-12
    [Documentation]   Update Notification Settings of USER for APPOINTMENT-CANCEL using SMS number as EMPTY
    
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Notification Settings of User  ${u_id1}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    comment   APPOINTMENT-CANCEL-initial
    Should Be Equal As Strings  ${resp.json()[3]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[3]['eventType']}  ${EventType[8]}
    Should Be Equal As Strings  ${resp.json()[3]['email'][0]}  ${PUser15_EMAIL}
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['number']}           ${PUSERNAME_U15} 
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['number']}       ${PUSERNAME_U1} 
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[3]['sms'][0]}  ${PUSERNAME_U15}
    # Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]}  ${PUSERNAME_U1}
    # Should Be Equal As Strings  ${resp.json()[3]['pushMessage']}  ${bool[1]}
   
 
    # Set Test Variable  @{PushMSG_Num_list}   ${PUSERNAME_U1}
    ${PushMSG}=  Create Dictionary   number=${PUSERNAME_U1}   countryCode=${countryCode_CC0}
    Set Suite Variable  @{PushMSG_Num_list}   ${PushMSG}

    ${resp}=  Update Notification Settings of User  ${u_id1}  ${NotificationResourceType[1]}  ${EventType[8]}  ${EMPTY_List}  ${PUser15_EMAIL_list}  ${PushMSG_Num_list}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Notification Settings of User  ${u_id1}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    comment   APPOINTMENT-CANCEL-updated
    Should Be Equal As Strings  ${resp.json()[3]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[3]['eventType']}  ${EventType[8]}
    Should Be Equal As Strings  ${resp.json()[3]['email'][0]}   ${PUser15_EMAIL}
    Should Be Equal As Strings  ${resp.json()[3]['sms']}        ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['number']}       ${PUSERNAME_U1} 
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[3]['sms']}  ${EMPTY_List}
    # Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]}  ${PUSERNAME_U1}
   
JD-TC-Update_Notification_Settings_of_User-13
    [Documentation]   Update Notification Settings of USER for WAITLIST-CANCEL using EMAIL_id as EMPTY
    
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Notification Settings of User  ${u_id1}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    comment   WAITLIST-CANCEL-initial
    Should Be Equal As Strings  ${resp.json()[1]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['eventType']}  ${EventType[1]}
    Should Be Equal As Strings  ${resp.json()[1]['email'][0]}  ${PUser13_EMAIL}
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['number']}           ${PUSERNAME_U13} 
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['number']}       ${PUSERNAME_U1} 
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[1]['sms'][0]}  ${PUSERNAME_U13}
    # Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]}  ${PUSERNAME_U1}
   
    # Set Test Variable  @{PushMSG_Num_list}   ${PUSERNAME_U1}
    ${PushMSG}=  Create Dictionary   number=${PUSERNAME_U1}   countryCode=${countryCode_CC0}
    Set Suite Variable  @{PushMSG_Num_list}   ${PushMSG}
    Set Suite Variable  @{PUser_EMAIL_EMPTY}   ${EMPTY}

    ${resp}=  Update Notification Settings of User  ${u_id1}  ${NotificationResourceType[0]}  ${EventType[1]}  ${PUSERNAME_U13_list}  ${EMPTY_List}  ${PushMSG_Num_list}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Notification Settings of User  ${u_id1}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    comment   WAITLIST-CANCEL-updated
    Should Be Equal As Strings  ${resp.json()[1]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['eventType']}  ${EventType[1]}
    Should Be Equal As Strings  ${resp.json()[1]['email']}  ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['number']}           ${PUSERNAME_U13} 
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['number']}       ${PUSERNAME_U1} 
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[1]['sms'][0]}  ${PUSERNAME_U13}
    # Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]}  ${PUSERNAME_U1}
    

JD-TC-Update_Notification_Settings_of_User-14
    [Documentation]   Update and verify Notification Settings using provider_id for WAITLISTADD 
    
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${MUSERNAME_U2}=  Evaluate  ${PUSERNAME}+7149539
    Set Suite Variable  ${MUSERNAME_U2}  
    ${MSG_Ph1}=  Create Dictionary   number=${MUSERNAME_U2}   countryCode=${countryCode_CC0}
    ${MSG_Ph2}=  Create Dictionary   number=${PUSERNAME_U1}   countryCode=${countryCode_CC0}
    ${SMS_Num_list12}=  create List  ${MSG_Ph1}  ${MSG_Ph2}
    Set Suite Variable  @{SMS_Num_list12}

    ${PushMSG1}=  Create Dictionary   number=${MUSERNAME_E1}   countryCode=${countryCode_CC0}
    ${PushMSG2}=  Create Dictionary   number=${PUSERNAME_U1}   countryCode=${countryCode_CC0}
    ${PushMSG_Num_list12}=  create List  ${PushMSG1}  ${PushMSG2}
    Set Suite Variable  @{PushMSG_Num_list12}

    Set Suite Variable  ${B1User_EMAIL12}   ${P_Email}${MUSERNAME_U2}.${test_mail}
    Set Suite Variable  ${B2User_EMAIL12}   ${P_Email}${PUSERNAME_U1}.${test_mail}
    ${BUser_EMAIL_list12}=  create List  ${B1User_EMAIL12}  ${B2User_EMAIL12}
    Set Suite Variable  @{BUser_EMAIL_list12} 

    ${resp}=  Get Notification Settings of User   0  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    comment   WAITLISTADD
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${EventType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['email'][0]}  ${EMAIL_id0}
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['number']}           ${MUSERNAME_E1} 
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['number']}       ${MUSERNAME_E1} 
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[0]['sms'][0]}  ${MUSERNAME_E1}
    # Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]}  ${MUSERNAME_E1}
  
    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[0]}  ${EventType[0]}  ${SMS_Num_list12}  ${BUser_EMAIL_list12}  ${PushMSG_Num_list12}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Notification Settings of User   0  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${EventType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['email'][0]}  ${B1User_EMAIL12}
    Should Be Equal As Strings  ${resp.json()[0]['email'][1]}  ${B2User_EMAIL12}
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['number']}           ${MUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[0]['sms'][1]['number']}           ${PUSERNAME_U1} 
    Should Be Equal As Strings  ${resp.json()[0]['sms'][1]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['number']}       ${MUSERNAME_E1} 
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][1]['number']}       ${PUSERNAME_U1} 
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][1]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[0]['sms'][0]}  ${MUSERNAME_U2}
    # Should Be Equal As Strings  ${resp.json()[0]['sms'][1]}  ${PUSERNAME_U1}
    # Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]}  ${MUSERNAME_E1}
    # Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][1]}  ${PUSERNAME_U1}


JD-TC-Update_Notification_Settings_of_User-15
    [Documentation]   Update and verify Notification Settings using provider_id for WAITLIST-CANCEL
    
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  Get Notification Settings of User   0  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    comment   WAITLIST-CANCEL
    Should Be Equal As Strings  ${resp.json()[1]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['eventType']}  ${EventType[1]}
    Should Be Equal As Strings  ${resp.json()[1]['email'][0]}  ${EMAIL_id0}
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['number']}           ${MUSERNAME_E1} 
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['number']}       ${MUSERNAME_E1} 
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[1]['sms'][0]}  ${MUSERNAME_E1}
    # Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]}  ${MUSERNAME_E1}
   
    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[0]}  ${EventType[1]}  ${SMS_Num_list12}  ${BUser_EMAIL_list12}  ${PushMSG_Num_list12}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Notification Settings of User   0  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['eventType']}  ${EventType[1]}
    Should Be Equal As Strings  ${resp.json()[1]['email'][0]}  ${B1User_EMAIL12}
    Should Be Equal As Strings  ${resp.json()[1]['email'][1]}  ${B2User_EMAIL12}
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['number']}           ${MUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[1]['sms'][1]['number']}           ${PUSERNAME_U1} 
    Should Be Equal As Strings  ${resp.json()[1]['sms'][1]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['number']}       ${MUSERNAME_E1} 
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][1]['number']}       ${PUSERNAME_U1} 
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][1]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[1]['sms'][0]}  ${MUSERNAME_U2}
    # Should Be Equal As Strings  ${resp.json()[1]['sms'][1]}  ${PUSERNAME_U1}
    # Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]}  ${MUSERNAME_E1}
    # Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][1]}  ${PUSERNAME_U1}


JD-TC-Update_Notification_Settings_of_User-16
    [Documentation]   Update and verify Notification Settings using provider_id for APPOINTMENTADD
    
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Notification Settings of User   0  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    comment   APPOINTMENTADD
    Should Be Equal As Strings  ${resp.json()[2]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[2]['eventType']}  ${EventType[7]}
    Should Be Equal As Strings  ${resp.json()[2]['email'][0]}  ${EMAIL_id0}
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['number']}           ${MUSERNAME_E1} 
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['number']}       ${MUSERNAME_E1} 
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[2]['sms'][0]}  ${MUSERNAME_E1}
    # Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]}  ${MUSERNAME_E1}
  
    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[1]}  ${EventType[7]}  ${SMS_Num_list12}  ${BUser_EMAIL_list12}  ${PushMSG_Num_list12}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Notification Settings of User   0  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[2]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[2]['eventType']}  ${EventType[7]}
    Should Be Equal As Strings  ${resp.json()[2]['email'][0]}  ${B1User_EMAIL12}
    Should Be Equal As Strings  ${resp.json()[2]['email'][1]}  ${B2User_EMAIL12}
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['number']}           ${MUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[2]['sms'][1]['number']}           ${PUSERNAME_U1} 
    Should Be Equal As Strings  ${resp.json()[2]['sms'][1]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['number']}       ${MUSERNAME_E1} 
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][1]['number']}       ${PUSERNAME_U1} 
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][1]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[2]['sms'][0]}  ${MUSERNAME_U2}
    # Should Be Equal As Strings  ${resp.json()[2]['sms'][1]}  ${PUSERNAME_U1}
    # Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]}  ${MUSERNAME_E1}
    # Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][1]}  ${PUSERNAME_U1}


JD-TC-Update_Notification_Settings_of_User-17
    [Documentation]   Update and verify Notification Settings using provider_id for APPOINTMENT-CANCEL
    
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Notification Settings of User   0  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    comment   APPOINTMENT-CANCEL
    Should Be Equal As Strings  ${resp.json()[3]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[3]['eventType']}  ${EventType[8]}
    Should Be Equal As Strings  ${resp.json()[3]['email'][0]}  ${EMAIL_id0}
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['number']}           ${MUSERNAME_E1} 
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['number']}       ${MUSERNAME_E1} 
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[3]['sms'][0]}  ${MUSERNAME_E1}
    # Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]}  ${MUSERNAME_E1}
  
    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[1]}  ${EventType[8]}  ${SMS_Num_list12}  ${BUser_EMAIL_list12}  ${PushMSG_Num_list12}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Notification Settings of User   0  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[3]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[3]['eventType']}  ${EventType[8]}
    Should Be Equal As Strings  ${resp.json()[3]['email'][0]}  ${B1User_EMAIL12}
    Should Be Equal As Strings  ${resp.json()[3]['email'][1]}  ${B2User_EMAIL12}
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['number']}           ${MUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[3]['sms'][1]['number']}           ${PUSERNAME_U1} 
    Should Be Equal As Strings  ${resp.json()[3]['sms'][1]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['number']}       ${MUSERNAME_E1} 
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][1]['number']}       ${PUSERNAME_U1} 
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][1]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[3]['sms'][0]}  ${MUSERNAME_U2}
    # Should Be Equal As Strings  ${resp.json()[3]['sms'][1]}  ${PUSERNAME_U1}
    # Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]}  ${MUSERNAME_E1}
    # Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][1]}  ${PUSERNAME_U1}


JD-TC-Update_Notification_Settings_of_User-18
    [Documentation]   Update and verify Notification Settings using provider_id for notification settings related to DONATION
    
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Notification Settings of User   0  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    comment   DONATION
    Should Be Equal As Strings  ${resp.json()[4]['resourceType']}  ${NotificationResourceType[3]}
    Should Be Equal As Strings  ${resp.json()[4]['eventType']}  ${EventType[10]}
    Should Be Equal As Strings  ${resp.json()[4]['email'][0]}  ${EMAIL_id0}
    Should Be Equal As Strings  ${resp.json()[4]['sms'][0]['number']}           ${MUSERNAME_E1} 
    Should Be Equal As Strings  ${resp.json()[4]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]['number']}       ${MUSERNAME_E1} 
    Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[4]['sms'][0]}  ${MUSERNAME_E1}
    # Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]}  ${MUSERNAME_E1}

   
    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[3]}  ${EventType[10]}  ${SMS_Num_list12}  ${BUser_EMAIL_list12}  ${PushMSG_Num_list12}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Notification Settings of User   0  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[4]['resourceType']}  ${NotificationResourceType[3]}
    Should Be Equal As Strings  ${resp.json()[4]['eventType']}  ${EventType[10]}
    Should Be Equal As Strings  ${resp.json()[4]['email'][0]}  ${B1User_EMAIL12}
    Should Be Equal As Strings  ${resp.json()[4]['email'][1]}  ${B2User_EMAIL12}
    Should Be Equal As Strings  ${resp.json()[4]['sms'][0]['number']}           ${MUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[4]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[4]['sms'][1]['number']}           ${PUSERNAME_U1} 
    Should Be Equal As Strings  ${resp.json()[4]['sms'][1]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]['number']}       ${MUSERNAME_E1} 
    Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][1]['number']}       ${PUSERNAME_U1} 
    Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][1]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[4]['sms'][0]}  ${MUSERNAME_U2}
    # Should Be Equal As Strings  ${resp.json()[4]['sms'][1]}  ${PUSERNAME_U1}
    # Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]}  ${MUSERNAME_E1}
    # Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][1]}  ${PUSERNAME_U1}


JD-TC-Update_Notification_Settings_of_User-19
    [Documentation]   Update and verify Notification Settings using provider_id for notification settings related to LICENSE
    
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Notification Settings of User   0  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    comment   LICENCE
    Should Be Equal As Strings  ${resp.json()[5]['resourceType']}  ${NotificationResourceType[2]}
    Should Be Equal As Strings  ${resp.json()[5]['eventType']}  ${EventType[9]}
    Should Be Equal As Strings  ${resp.json()[5]['email'][0]}  ${EMAIL_id0}
    Should Be Equal As Strings  ${resp.json()[5]['sms'][0]['number']}           ${MUSERNAME_E1} 
    Should Be Equal As Strings  ${resp.json()[5]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]['number']}       ${MUSERNAME_E1} 
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[5]['sms'][0]}  ${MUSERNAME_E1}
    # Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]}  ${MUSERNAME_E1}

   
    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[2]}  ${EventType[9]}  ${SMS_Num_list12}  ${BUser_EMAIL_list12}  ${PushMSG_Num_list12}   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Notification Settings of User   0  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[5]['resourceType']}  ${NotificationResourceType[2]}
    Should Be Equal As Strings  ${resp.json()[5]['eventType']}  ${EventType[9]}
    Should Be Equal As Strings  ${resp.json()[5]['email'][0]}  ${B1User_EMAIL12}
    Should Be Equal As Strings  ${resp.json()[5]['email'][1]}  ${B2User_EMAIL12}
    Should Be Equal As Strings  ${resp.json()[5]['sms'][0]['number']}           ${MUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[5]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[5]['sms'][1]['number']}           ${PUSERNAME_U1} 
    Should Be Equal As Strings  ${resp.json()[5]['sms'][1]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]['number']}       ${MUSERNAME_E1} 
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][1]['number']}       ${PUSERNAME_U1} 
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][1]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[5]['sms'][0]}  ${MUSERNAME_U2}
    # Should Be Equal As Strings  ${resp.json()[5]['sms'][1]}  ${PUSERNAME_U1}
    # Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]}  ${MUSERNAME_E1}
    # Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][1]}  ${PUSERNAME_U1}

JD-TC-Update_Notification_Settings_of_User-20
    [Documentation]   Use user_id of provider to Update Notification Settings of USER (User level)
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Set Test Variable  @{PushMSG_Num_list}   ${PUSERNAME_U1}
    ${PushMSG}=  Create Dictionary   number=${PUSERNAME_U1}   countryCode=${countryCode_CC0}
    Set Suite Variable  @{PushMSG_Num_list}   ${PushMSG}

    ${PUSERNAME_U15}=  Evaluate  ${PUSERNAME}+5541112
    clear_users  ${PUSERNAME_U15}
    Set Suite Variable  ${PUSERNAME_U15}  

    ${PUSERNAME_U25}=  Evaluate  ${PUSERNAME}+6651112
    clear_users  ${PUSERNAME_U25}
    Set Suite Variable  ${PUSERNAME_U25}  
    # Set Suite Variable  @{PUSERNAME_SMS_list}   ${PUSERNAME_U15}  ${PUSERNAME_U25}
    
    # Set Suite Variable  ${PUser15_EMAIL}   ${P_Email}${PUSERNAME_U15}.${test_mail}
    # Set Suite Variable  ${PUser25_EMAIL}   ${P_Email}${PUSERNAME_U25}.${test_mail}
    # Set Suite Variable  @{PUser_EMAIL2_list}   ${PUser15_EMAIL}  ${PUser25_EMAIL}
    # Set Suite Variable  @{PushMSG_Num2_list}   ${PUSERNAME_U1}  ${PUSERNAME_U2}
    ${MSG_Ph1}=  Create Dictionary   number=${PUSERNAME_U15}   countryCode=${countryCode_CC0}
    ${MSG_Ph2}=  Create Dictionary   number=${PUSERNAME_U25}   countryCode=${countryCode_CC0}
    ${PUSERNAME_SMS_list}=  create List  ${MSG_Ph1}  ${MSG_Ph2}
    Set Suite Variable  @{PUSERNAME_SMS_list}

    ${PushMSG1}=  Create Dictionary   number=${PUSERNAME_U1}   countryCode=${countryCode_CC0}
    ${PushMSG2}=  Create Dictionary   number=${PUSERNAME_U2}   countryCode=${countryCode_CC0}
    ${PushMSG_Num2_list}=  create List  ${PushMSG1}  ${PushMSG2}
    Set Suite Variable  @{PushMSG_Num2_list}

    Set Suite Variable  ${PUser15_EMAIL}   ${P_Email}${PUSERNAME_U15}.${test_mail}
    Set Suite Variable  ${PUser25_EMAIL}   ${P_Email}${PUSERNAME_U25}.${test_mail}
    ${PUser_EMAIL2_list}=  create List  ${PUser15_EMAIL}  ${PUser25_EMAIL}
    Set Suite Variable  @{PUser_EMAIL2_list} 

    ${resp}=  Update Notification Settings of User  ${p0_id}  ${NotificationResourceType[0]}  ${EventType[0]}  ${PUSERNAME_SMS_list}  ${PUser_EMAIL2_list}  ${PushMSG_Num2_list}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Notification Settings of User  ${p0_id}  ${NotificationResourceType[0]}  ${EventType[1]}  ${PUSERNAME_SMS_list}  ${PUser_EMAIL2_list}  ${PushMSG_Num2_list}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Notification Settings of User  ${p0_id}  ${NotificationResourceType[1]}  ${EventType[7]}  ${PUSERNAME_SMS_list}  ${PUser_EMAIL2_list}  ${PushMSG_Num2_list}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Notification Settings of User  ${p0_id}  ${NotificationResourceType[1]}  ${EventType[8]}  ${PUSERNAME_SMS_list}  ${PUser_EMAIL2_list}  ${PushMSG_Num2_list}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Notification Settings of User  ${p0_id}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Not Contain  ${resp.json()}  ${NotificationResourceType[2]}
    Should Not Contain  ${resp.json()}  ${EventType[9]}

    comment   WAITLISTADD
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${EventType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['email'][0]}  ${PUser15_EMAIL}
    Should Be Equal As Strings  ${resp.json()[0]['email'][1]}  ${PUser25_EMAIL}
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['number']}           ${PUSERNAME_U15} 
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[0]['sms'][1]['number']}           ${PUSERNAME_U25} 
    Should Be Equal As Strings  ${resp.json()[0]['sms'][1]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['number']}       ${PUSERNAME_U1} 
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][1]['number']}       ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][1]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[0]['sms'][0]}  ${PUSERNAME_U15}
    # Should Be Equal As Strings  ${resp.json()[0]['sms'][1]}  ${PUSERNAME_U25}
    # Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]}  ${PUSERNAME_U1}
    # Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][1]}  ${PUSERNAME_U2}
  
    comment   WAITLIST-CANCEL
    Should Be Equal As Strings  ${resp.json()[1]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['eventType']}  ${EventType[1]}
    Should Be Equal As Strings  ${resp.json()[1]['email'][0]}  ${PUser15_EMAIL}
    Should Be Equal As Strings  ${resp.json()[1]['email'][1]}  ${PUser25_EMAIL}
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['number']}           ${PUSERNAME_U15} 
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[1]['sms'][1]['number']}           ${PUSERNAME_U25} 
    Should Be Equal As Strings  ${resp.json()[1]['sms'][1]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['number']}       ${PUSERNAME_U1} 
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][1]['number']}       ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][1]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[1]['sms'][0]}  ${PUSERNAME_U15}
    # Should Be Equal As Strings  ${resp.json()[1]['sms'][1]}  ${PUSERNAME_U25}
    # Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]}  ${PUSERNAME_U1}
    # Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][1]}  ${PUSERNAME_U2}
  
    
    comment   APPOINTMENTADD
    Should Be Equal As Strings  ${resp.json()[2]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[2]['eventType']}  ${EventType[7]}
    Should Be Equal As Strings  ${resp.json()[2]['email'][0]}  ${PUser15_EMAIL}
    Should Be Equal As Strings  ${resp.json()[2]['email'][1]}  ${PUser25_EMAIL}
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['number']}           ${PUSERNAME_U15} 
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[2]['sms'][1]['number']}           ${PUSERNAME_U25} 
    Should Be Equal As Strings  ${resp.json()[2]['sms'][1]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['number']}       ${PUSERNAME_U1} 
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][1]['number']}       ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][1]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[2]['sms'][0]}  ${PUSERNAME_U15}
    # Should Be Equal As Strings  ${resp.json()[2]['sms'][1]}  ${PUSERNAME_U25}
    # Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]}  ${PUSERNAME_U1}
    # Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][1]}  ${PUSERNAME_U2}
    
    comment   APPOINTMENT-CANCEL
    Should Be Equal As Strings  ${resp.json()[3]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[3]['eventType']}  ${EventType[8]}
    Should Be Equal As Strings  ${resp.json()[3]['email'][0]}  ${PUser15_EMAIL}
    Should Be Equal As Strings  ${resp.json()[3]['email'][1]}  ${PUser25_EMAIL}
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['number']}           ${PUSERNAME_U15} 
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[3]['sms'][1]['number']}           ${PUSERNAME_U25} 
    Should Be Equal As Strings  ${resp.json()[3]['sms'][1]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['number']}       ${PUSERNAME_U1} 
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][1]['number']}       ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][1]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[3]['sms'][0]}  ${PUSERNAME_U15}
    # Should Be Equal As Strings  ${resp.json()[3]['sms'][1]}  ${PUSERNAME_U25}
    # Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]}  ${PUSERNAME_U1}
    # Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][1]}  ${PUSERNAME_U2}


JD-TC-Update_Notification_Settings_of_User-UH1
    [Documentation]   Update notification settings without login 
    ${resp}=  Update Notification Settings of User  ${u_id1}  ${NotificationResourceType[0]}  ${EventType[0]}  ${PUSERNAME_U13_list}  ${PUser13_EMAIL_list}  ${EMPTY_List}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

    # Set Test Variable  @{PushMSG_Num_list}   ${PUSERNAME_U1}
    ${PushMSG}=  Create Dictionary   number=${PUSERNAME_U1}   countryCode=${countryCode_CC0}
    Set Suite Variable  @{PushMSG_Num_list}   ${PushMSG}
    ${resp}=  Update Notification Settings of User  ${u_id1}  ${NotificationResourceType[0]}  ${EventType[1]}  ${EMPTY_List}  ${PUser13_EMAIL_list}  ${PushMSG_Num_list}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

    ${resp}=  Update Notification Settings of User  ${u_id1}  ${NotificationResourceType[1]}  ${EventType[7]}  ${PUSERNAME_U13_list}  ${EMPTY_List}  ${PushMSG_Num_list}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

    ${resp}=  Update Notification Settings of User  ${u_id1}  ${NotificationResourceType[1]}  ${EventType[8]}  ${EMPTY_List}  ${EMPTY_List}  ${EMPTY_List}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"


JD-TC-Update_Notification_Settings_of_User-UH2
    [Documentation]   Consumer Get Notification Settings of USER
    ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}    200
    # Set Test Variable  @{PushMSG_Num_list}   ${PUSERNAME_U1}
    ${PushMSG}=  Create Dictionary   number=${PUSERNAME_U1}   countryCode=${countryCode_CC0}
    Set Suite Variable  @{PushMSG_Num_list}   ${PushMSG}

    ${resp}=  Update Notification Settings of User  ${u_id1}  ${NotificationResourceType[0]}  ${EventType[0]}  ${PUSERNAME_U13_list}  ${PUser13_EMAIL_list}  ${PushMSG_Num_list}
    Log  ${resp.json()} 
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"


JD-TC-Update_Notification_Settings_of_User-UH3
    [Documentation]  invalid provider

    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Set Test Variable  @{PushMSG_Num_list}   ${PUSERNAME_U1}
    ${PushMSG}=  Create Dictionary   number=${PUSERNAME_U1}   countryCode=${countryCode_CC0}
    Set Suite Variable  @{PushMSG_Num_list}   ${PushMSG}

    ${Invalid_id}=  Random Int  min=100000  max=200000
    ${resp}=  Update Notification Settings of User  ${Invalid_id}  ${NotificationResourceType[0]}  ${EventType[0]}  ${PUSERNAME_U13_list}  ${PUser13_EMAIL_list}  ${PushMSG_Num_list} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  404
    Should Be Equal As Strings  "${resp.json()}"  "${USER_NOT_FOUND}"

JD-TC-Update_Notification_Settings_of_User-UH4
    [Documentation]  Get Notification Settings of USER using Disabled USER_id
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Set Test Variable  @{PushMSG_Num_list}   ${PUSERNAME_U1}
    ${PushMSG}=  Create Dictionary   number=${PUSERNAME_U1}   countryCode=${countryCode_CC0}
    Set Suite Variable  @{PushMSG_Num_list}   ${PushMSG}

    ${resp}=  EnableDisable User  ${u_id1}  ${toggle[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   02s

    ${resp}=  Update Notification Settings of User  ${u_id1}  ${NotificationResourceType[0]}  ${EventType[0]}  ${PUSERNAME_U13_list}  ${PUser13_EMAIL_list}  ${PushMSG_Num_list}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  EnableDisable User  ${u_id1}  ${toggle[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   02s

JD-TC-Update_Notification_Settings_of_User-UH5
    [Documentation]   Update notification settings of USER using user_id of another provider
    
    ${iscorp_subdomains}=  get_iscorp_subdomains  1
     Log  ${iscorp_subdomains}
     Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
     Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
     Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
     ${firstname_A}=  FakerLibrary.first_name
     ${lastname_A}=  FakerLibrary.last_name
     ${MUSERNAME_E2}=  Evaluate  ${PUSERNAME}+6710176
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
    
    # ${number1}=  Random Int  min=1500  max=2000
    ${PUSERNAME_U20}=  Evaluate  ${PUSERNAME}+499459
    clear_users  ${PUSERNAME_U20}
    Set Suite Variable  ${PUSERNAME_U20}
    ${firstname1}=  FakerLibrary.name
    Set Suite Variable  ${firstname1}
    ${lastname1}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname1}
    ${dob1}=  FakerLibrary.Date
    Set Suite Variable  ${dob1}
    ${pin1}=  get_pincode

    ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U20}.${test_mail}   ${userType[0]}  ${pin1}  ${countryCodes[0]}  ${PUSERNAME_U20}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u40_id1}  ${resp.json()}

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${u_id140}   ${resp.json()[0]['id']}
    Set Suite Variable   ${p0_id40}   ${resp.json()[1]['id']}

    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Set Test Variable  @{PushMSG_Num_list}   ${PUSERNAME_U1}
    ${PushMSG}=  Create Dictionary   number=${PUSERNAME_U1}   countryCode=${countryCode_CC0}
    Set Suite Variable  @{PushMSG_Num_list}   ${PushMSG}
   
    ${resp}=  Update Notification Settings of User  ${u_id140}  ${NotificationResourceType[0]}  ${EventType[0]}  ${PUSERNAME_U13_list}  ${PUser13_EMAIL_list}  ${PushMSG_Num_list}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   "${resp.json()}"   "${NO_PERMISSION}"


JD-TC-Update_Notification_Settings_of_User-UH6
    [Documentation]   Updated all notification settings of one USER using a phone number which is not a registered number of any provider in that account
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Notification Settings of User  ${p2_id}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    comment   WAITLISTADD
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${EventType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['email'][0]}  ${PUser2_EMAIL}
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['number']}           ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['number']}       ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[0]['sms'][0]}  ${PUSERNAME_U2}
    # Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]}  ${PUSERNAME_U2}
    

    ${INVALID_NUM1}=  Evaluate  ${PUSERNAME_U2}+3
    ${PushMSG1}=  Create Dictionary   number=${PUSERNAME_U1}   countryCode=${countryCode_CC0}
    ${PushMSG2}=  Create Dictionary   number=${INVALID_NUM1}    countryCode=${countryCode_CC0}
    ${PushMSG_Num_list}=  create List  ${PushMSG1}  ${PushMSG2}
    Set Suite Variable  @{PushMSG_Num_list}

    ${resp}=  Update Notification Settings of User  ${p2_id}  ${NotificationResourceType[0]}  ${EventType[0]}  ${PUSERNAME_U14_list}  ${PUser14_EMAIL_list}  ${PushMSG_Num_list}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    ${LOGIN_Number_NOT_FOUND}=  Format String       ${LOGIN_NOT_FOUND}   ${countryCode_CC0}${INVALID_NUM1}
    Should Be Equal As Strings   ${resp.json()}   ${LOGIN_Number_NOT_FOUND}

    ${INVALID_NUM2}=  Evaluate  ${PUSERNAME_U2}+6
    ${PushMSG3}=  Create Dictionary   number=${INVALID_NUM2}    countryCode=${countryCode_CC0}
    ${PushMSG_Num_list}=  create List  ${PushMSG1}  ${PushMSG3}  ${PushMSG2}
    Set Suite Variable  @{PushMSG_Num_list}

    ${resp}=  Update Notification Settings of User  ${p2_id}  ${NotificationResourceType[0]}  ${EventType[0]}  ${PUSERNAME_U14_list}  ${PUser14_EMAIL_list}  ${PushMSG_Num_list}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    ${LOGIN_Number_NOT_FOUND}=  Format String       ${LOGIN_NOT_FOUND}   ${countryCode_CC0}${INVALID_NUM2}
    Should Be Equal As Strings   ${resp.json()}   ${LOGIN_Number_NOT_FOUND}
    
    ${resp}=  Get Notification Settings of User  ${p2_id}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    comment   WAITLISTADD-updated
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${EventType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['email'][0]}  ${PUser2_EMAIL}
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['number']}           ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['number']}       ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[0]['sms'][0]}  ${PUSERNAME_U2}
    # Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]}  ${PUSERNAME_U2}

    





    