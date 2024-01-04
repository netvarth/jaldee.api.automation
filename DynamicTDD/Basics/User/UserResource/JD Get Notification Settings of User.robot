
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
@{EMPTY_List} 
@{person_ahead}   0  1  2  3  4  5  6
@{CC_countryCode}   +91  
   


*** Test Cases ***

JD-TC-GetNotificationSettings_of_User-1
    [Documentation]   Getting notification settings of provider (Branch) before creating USER
    
    ${iscorp_subdomains}=  get_iscorp_subdomains  1
     Log  ${iscorp_subdomains}
     Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
     Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
     Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
     ${firstname_A}=  FakerLibrary.first_name
     Set Suite Variable  ${firstname_A}
     ${lastname_A}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname_A}
     ${MUSERNAME_E1}=  Evaluate  ${MUSERNAME}+8810188
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

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${prov_id1}  ${decrypted_data['id']}

    #  Set Suite Variable   ${prov_id1}    ${resp.json()['id']}
     Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${MUSERNAME_E1}${\n}
     Set Suite Variable  ${MUSERNAME_E1}
    sleep  03s
    Set Suite Variable  ${countryCode_CC0}    ${countryCodes[0]}
    ${resp1}=  Get Provider Notification Settings
    Log  ${resp1.json()}
    Should Be Equal As Strings    ${resp1.status_code}    200
    Set Suite Variable  ${Response1}   ${resp1.json()}
    comment   WAITLISTADD
    Should Be Equal As Strings  ${resp1.json()[0]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp1.json()[0]['eventType']}  ${EventType[0]}
    Should Be Equal As Strings  ${resp1.json()[0]['email'][0]}  ${EMAIL_id0}
    Should Be Equal As Strings  ${resp1.json()[0]['sms'][0]['number']}           ${MUSERNAME_E1} 
    Should Be Equal As Strings  ${resp1.json()[0]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp1.json()[0]['pushMsg'][0]['number']}       ${MUSERNAME_E1} 
    Should Be Equal As Strings  ${resp1.json()[0]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}

    comment   WAITLIST-CANCEL
    Should Be Equal As Strings  ${resp1.json()[1]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp1.json()[1]['eventType']}  ${EventType[1]}
    Should Be Equal As Strings  ${resp1.json()[1]['email'][0]}  ${EMAIL_id0}
    Should Be Equal As Strings  ${resp1.json()[1]['sms'][0]['number']}           ${MUSERNAME_E1} 
    Should Be Equal As Strings  ${resp1.json()[1]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp1.json()[1]['pushMsg'][0]['number']}       ${MUSERNAME_E1} 
    Should Be Equal As Strings  ${resp1.json()[1]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
   
    comment   APPOINTMENTADD
    Should Be Equal As Strings  ${resp1.json()[2]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp1.json()[2]['eventType']}  ${EventType[7]}
    Should Be Equal As Strings  ${resp1.json()[2]['email'][0]}  ${EMAIL_id0}
    Should Be Equal As Strings  ${resp1.json()[2]['sms'][0]['number']}           ${MUSERNAME_E1} 
    Should Be Equal As Strings  ${resp1.json()[2]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp1.json()[2]['pushMsg'][0]['number']}       ${MUSERNAME_E1} 
    Should Be Equal As Strings  ${resp1.json()[2]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
   
    comment   APPOINTMENT-CANCEL
    Should Be Equal As Strings  ${resp1.json()[3]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp1.json()[3]['eventType']}  ${EventType[8]}
    Should Be Equal As Strings  ${resp1.json()[3]['email'][0]}  ${EMAIL_id0}
    Should Be Equal As Strings  ${resp1.json()[3]['sms'][0]['number']}           ${MUSERNAME_E1} 
    Should Be Equal As Strings  ${resp1.json()[3]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp1.json()[3]['pushMsg'][0]['number']}       ${MUSERNAME_E1} 
    Should Be Equal As Strings  ${resp1.json()[3]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
   
    comment   DONATION
    Should Be Equal As Strings  ${resp1.json()[4]['resourceType']}  ${NotificationResourceType[3]}
    Should Be Equal As Strings  ${resp1.json()[4]['eventType']}  ${EventType[10]}
    Should Be Equal As Strings  ${resp1.json()[4]['email'][0]}  ${EMAIL_id0}
    Should Be Equal As Strings  ${resp1.json()[4]['sms'][0]['number']}           ${MUSERNAME_E1} 
    Should Be Equal As Strings  ${resp1.json()[4]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp1.json()[4]['pushMsg'][0]['number']}       ${MUSERNAME_E1} 
    Should Be Equal As Strings  ${resp1.json()[4]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}

    comment   LICENCE
    Should Be Equal As Strings  ${resp1.json()[5]['resourceType']}  ${NotificationResourceType[2]}
    Should Be Equal As Strings  ${resp1.json()[5]['eventType']}  ${EventType[9]}
    Should Be Equal As Strings  ${resp1.json()[5]['email'][0]}  ${EMAIL_id0}
    Should Be Equal As Strings  ${resp1.json()[5]['sms'][0]['number']}           ${MUSERNAME_E1} 
    Should Be Equal As Strings  ${resp1.json()[5]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp1.json()[5]['pushMsg'][0]['number']}       ${MUSERNAME_E1} 
    Should Be Equal As Strings  ${resp1.json()[5]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}



JD-TC-GetNotificationSettings_of_User-2
    [Documentation]   Getting notification settings of USER Without Updating notification settings

     ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${id}=  get_id  ${MUSERNAME_E1}
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
     
    ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+354709
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
    Set Suite Variable  ${pin1}

    ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}   ${PUser1_EMAIL}   ${userType[0]}  ${pin1}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id1}  ${resp.json()}


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
    ${pin2}=  get_pincode
    Set Suite Variable  ${pin2}

    ${resp}=  Create User  ${firstname2}  ${lastname2}  ${dob2}  ${Genderlist[0]}   ${PUser2_EMAIL}   ${userType[0]}  ${pin2}  ${countryCodes[0]}  ${PUSERNAME_U2}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id2}  ${resp.json()}

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${p2_id}   ${resp.json()[0]['id']}
    Set Suite Variable   ${p1_id}   ${resp.json()[1]['id']}
    Set Suite Variable   ${p0_id}   ${resp.json()[2]['id']}
    sleep  03s

    ${resp2}=  Get Provider Notification Settings
    Log  ${resp2.json()}
    Should Be Equal As Strings    ${resp2.status_code}    200
    Log  ${Response1}
    Should Be Equal As Strings  ${resp2.json()}  ${Response1}


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

    comment   WAITLIST-CANCEL
    Should Be Equal As Strings  ${resp.json()[1]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['eventType']}  ${EventType[1]}
    Should Be Equal As Strings  ${resp.json()[1]['email'][0]}  ${PUser1_EMAIL}
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['number']}           ${PUSERNAME_U1} 
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['number']}       ${PUSERNAME_U1} 
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
   
    comment   APPOINTMENTADD
    Should Be Equal As Strings  ${resp.json()[2]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[2]['eventType']}  ${EventType[7]}
    Should Be Equal As Strings  ${resp.json()[2]['email'][0]}  ${PUser1_EMAIL}
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['number']}           ${PUSERNAME_U1} 
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['number']}       ${PUSERNAME_U1} 
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
   
    comment   APPOINTMENT-CANCEL
    Should Be Equal As Strings  ${resp.json()[3]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[3]['eventType']}  ${EventType[8]}
    Should Be Equal As Strings  ${resp.json()[3]['email'][0]}  ${PUser1_EMAIL}
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['number']}           ${PUSERNAME_U1} 
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['number']}       ${PUSERNAME_U1} 
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
 

JD-TC-GetNotificationSettings_of_User-3
    [Documentation]   Get Notification Settings of Provider Without Updating notification settings(after creating user,Verify notification settings related to LICENSE)
    
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

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
  
    comment   WAITLIST-CANCEL
    Should Be Equal As Strings  ${resp.json()[1]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['eventType']}  ${EventType[1]}
    Should Be Equal As Strings  ${resp.json()[1]['email'][0]}  ${EMAIL_id0}
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['number']}           ${MUSERNAME_E1} 
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['number']}       ${MUSERNAME_E1} 
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}

    comment   APPOINTMENTADD
    Should Be Equal As Strings  ${resp.json()[2]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[2]['eventType']}  ${EventType[7]}
    Should Be Equal As Strings  ${resp.json()[2]['email'][0]}  ${EMAIL_id0}
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['number']}           ${MUSERNAME_E1} 
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['number']}       ${MUSERNAME_E1} 
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}

    comment   APPOINTMENT-CANCEL
    Should Be Equal As Strings  ${resp.json()[3]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[3]['eventType']}  ${EventType[8]}
    Should Be Equal As Strings  ${resp.json()[3]['email'][0]}  ${EMAIL_id0}
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['number']}           ${MUSERNAME_E1} 
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['number']}       ${MUSERNAME_E1} 
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}

    comment   DONATION
    Should Be Equal As Strings  ${resp.json()[4]['resourceType']}  ${NotificationResourceType[3]}
    Should Be Equal As Strings  ${resp.json()[4]['eventType']}  ${EventType[10]}
    Should Be Equal As Strings  ${resp.json()[4]['email'][0]}  ${EMAIL_id0}
    Should Be Equal As Strings  ${resp.json()[4]['sms'][0]['number']}           ${MUSERNAME_E1} 
    Should Be Equal As Strings  ${resp.json()[4]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]['number']}       ${MUSERNAME_E1} 
    Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}

    comment   LICENCE
    Should Be Equal As Strings  ${resp.json()[5]['resourceType']}  ${NotificationResourceType[2]}
    Should Be Equal As Strings  ${resp.json()[5]['eventType']}  ${EventType[9]}
    Should Be Equal As Strings  ${resp.json()[5]['email'][0]}  ${EMAIL_id0}
    Should Be Equal As Strings  ${resp.json()[5]['sms'][0]['number']}           ${MUSERNAME_E1} 
    Should Be Equal As Strings  ${resp.json()[5]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]['number']}       ${MUSERNAME_E1} 
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}



JD-TC-GetNotificationSettings_of_User-4
    [Documentation]   Update Notification Settings of USER for WAITLISTADD and then Get Notification Settings of USER
    
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
   
    ${number12}=  Random Int  min=3500  max=5000
    ${PUSERNAME_U12}=  Evaluate  ${PUSERNAME}+${number12}
    clear_users  ${PUSERNAME_U12}
    Set Suite Variable  ${PUSERNAME_U12}  
    Set Suite Variable  ${PUser12_EMAIL}   ${P_Email}${PUSERNAME_U12}.${test_mail}
    Set Suite Variable  @{PUser12_EMAIL_list}   ${PUser12_EMAIL}

    # ----------------------------------------------------------------------------
    ${countryCode_CC1}    Random Element    ${CC_countryCode}
    Set Suite Variable  ${countryCode_CC1}
    ${MSG_Ph1}=  Create Dictionary   number=${PUSERNAME_U12}   countryCode=${countryCode_CC1}
    Set Suite Variable  @{PUSERNAME_U12_list}    ${MSG_Ph1}  

    ${PushMSG}=  Create Dictionary   number=${PUSERNAME_U1}   countryCode=${countryCode_CC1}
    Set Suite Variable  @{PushMSG_Num_list}    ${PushMSG} 
    # ----------------------------------------------------------------------------

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
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['countryCode']}      ${countryCode_CC1}
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['number']}       ${PUSERNAME_U1} 
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['countryCode']}  ${countryCode_CC1}



JD-TC-GetNotificationSettings_of_User-5
    [Documentation]   Update Notification Settings of USER for WAITLIST-CANCEL and then Get Notification Settings of USER
    
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
    

    ${number13}=  Random Int  min=3500  max=5000
    ${PUSERNAME_U13}=  Evaluate  ${PUSERNAME}+${number13}
    clear_users  ${PUSERNAME_U13}
    Set Suite Variable  ${PUSERNAME_U13}  
    # Set Suite Variable  @{PUSERNAME_U13_list}   ${PUSERNAME_U13}

    Set Suite Variable  ${PUser13_EMAIL}   ${P_Email}${PUSERNAME_U13}.${test_mail}
    Set Suite Variable  @{PUser13_EMAIL_list}   ${PUser13_EMAIL}

    # Set Test Variable  @{PushMSG_Num_list}   ${PUSERNAME_U1}
    ${MSG_Ph1}=  Create Dictionary   number=${PUSERNAME_U13}   countryCode=${countryCode_CC1}
    Set Suite Variable  @{PUSERNAME_U13_list}    ${MSG_Ph1}  

    ${PushMSG}=  Create Dictionary   number=${PUSERNAME_U1}   countryCode=${countryCode_CC1}
    Set Suite Variable  @{PushMSG_Num_list}    ${PushMSG} 

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
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['countryCode']}      ${countryCode_CC1}
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['number']}       ${PUSERNAME_U1} 
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['countryCode']}  ${countryCode_CC1}
   

JD-TC-GetNotificationSettings_of_User-6
    [Documentation]   Update Notification Settings of USER for APPOINTMENTADD and then Get Notification Settings of USER
    
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
    

    ${number14}=  Random Int  min=3500  max=5000
    ${PUSERNAME_U14}=  Evaluate  ${PUSERNAME}+${number14}
    clear_users  ${PUSERNAME_U14}
    Set Suite Variable  ${PUSERNAME_U14}  
    # Set Suite Variable  @{PUSERNAME_U14_list}   ${PUSERNAME_U14}

    Set Suite Variable  ${PUser14_EMAIL}   ${P_Email}${PUSERNAME_U14}.${test_mail}
    Set Suite Variable  @{PUser14_EMAIL_list}   ${PUser14_EMAIL}

    # Set Test Variable  @{PushMSG_Num_list}   ${PUSERNAME_U1}
    ${MSG_Ph1}=  Create Dictionary   number=${PUSERNAME_U14}   countryCode=${countryCode_CC1}
    Set Suite Variable  @{PUSERNAME_U14_list}    ${MSG_Ph1}  

    ${PushMSG}=  Create Dictionary   number=${PUSERNAME_U1}   countryCode=${countryCode_CC1}
    Set Suite Variable  @{PushMSG_Num_list}    ${PushMSG}

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
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['countryCode']}      ${countryCode_CC1}
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['number']}       ${PUSERNAME_U1} 
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['countryCode']}  ${countryCode_CC1}



JD-TC-GetNotificationSettings_of_User-7
    [Documentation]   Update Notification Settings of USER for APPOINTMENT-CANCEL and then Get Notification Settings of USER
    
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
   
    ${number15}=  Random Int  min=3500  max=5000
    ${PUSERNAME_U15}=  Evaluate  ${PUSERNAME}+${number15}
    clear_users  ${PUSERNAME_U15}
    Set Suite Variable  ${PUSERNAME_U15}  
    # Set Suite Variable  @{PUSERNAME_U15_list}   ${PUSERNAME_U15}

    Set Suite Variable  ${PUser15_EMAIL}   ${P_Email}${PUSERNAME_U15}.${test_mail}
    Set Suite Variable  @{PUser15_EMAIL_list}   ${PUser15_EMAIL}
    # Set Test Variable  @{PushMSG_Num_list}   ${PUSERNAME_U1}
    ${MSG_Ph1}=  Create Dictionary   number=${PUSERNAME_U15}   countryCode=${countryCode_CC1}
    Set Suite Variable  @{PUSERNAME_U15_list}    ${MSG_Ph1}  

    ${PushMSG}=  Create Dictionary   number=${PUSERNAME_U1}   countryCode=${countryCode_CC1}
    Set Suite Variable  @{PushMSG_Num_list}    ${PushMSG}

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
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['countryCode']}      ${countryCode_CC1}
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['number']}       ${PUSERNAME_U1} 
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['countryCode']}  ${countryCode_CC1}


JD-TC-GetNotificationSettings_of_User-8
    [Documentation]   Updated all notification settings of one USER u_id1, then Get notification settings of another USER u_id2
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Notification Settings of User  ${u_id2}   
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

    comment   WAITLIST-CANCEL
    Should Be Equal As Strings  ${resp.json()[1]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['eventType']}  ${EventType[1]}
    Should Be Equal As Strings  ${resp.json()[1]['email'][0]}  ${PUser2_EMAIL}
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['number']}           ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['number']}       ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}

    comment   APPOINTMENTADD
    Should Be Equal As Strings  ${resp.json()[2]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[2]['eventType']}  ${EventType[7]}
    Should Be Equal As Strings  ${resp.json()[2]['email'][0]}  ${PUser2_EMAIL}
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['number']}           ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['number']}       ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}

    comment   APPOINTMENT-CANCEL
    Should Be Equal As Strings  ${resp.json()[3]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[3]['eventType']}  ${EventType[8]}
    Should Be Equal As Strings  ${resp.json()[3]['email'][0]}  ${PUser2_EMAIL}
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['number']}           ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['number']}       ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}


JD-TC-GetNotificationSettings_of_User-9
    [Documentation]   Update Notification Settings of USER for APPOINTMENTADD using PushMsg number of another user (two users are from same provider)
    
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # Should Be Equal As Strings   ${resp.json()[0]['id']}   ${u_id2}
    # Should Be Equal As Strings   ${resp.json()[0]['mobileNo']}   ${PUSERNAME_U2}

    # Should Be Equal As Strings   ${resp.json()[1]['id']}   ${u_id1}
    # Should Be Equal As Strings   ${resp.json()[1]['mobileNo']}   ${PUSERNAME_U1}

    # Variable Should Exist   ${resp.json()['id']}   ${u_id2}
    # Variable Should Exist   ${resp.json()['mobileNo']}   ${PUSERNAME_U2}

    # Variable Should Exist   ${resp.json()['id']}   ${u_id1}
    # Variable Should Exist   ${resp.json()['mobileNo']}   ${PUSERNAME_U1}

    Should Contain    ${resp.json()}  ${u_id1}
    Should Contain    ${resp.json()}  ${PUSERNAME_U1}

    Should Contain    ${resp.json()}  ${u_id2}
    Should Contain    ${resp.json()}  ${PUSERNAME_U2}

    ${resp}=  Get Notification Settings of User  ${u_id1}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    comment   APPOINTMENTADD-initial
    Should Be Equal As Strings  ${resp.json()[2]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[2]['eventType']}  ${EventType[7]}
    Should Be Equal As Strings  ${resp.json()[2]['email'][0]}  ${PUser14_EMAIL}
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['number']}           ${PUSERNAME_U14} 
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['countryCode']}      ${countryCode_CC1}
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['number']}       ${PUSERNAME_U1} 
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['countryCode']}  ${countryCode_CC1}
   
    # Set Test Variable  @{PushMSG_Num_list}   ${PUSERNAME_U2}
    ${PushMSG}=  Create Dictionary   number=${PUSERNAME_U2}   countryCode=${countryCode_CC1}
    Set Test Variable  @{PushMSG_Num_list}    ${PushMSG}

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
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['countryCode']}      ${countryCode_CC1}
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['number']}       ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['countryCode']}  ${countryCode_CC1}

   
JD-TC-GetNotificationSettings_of_User-10
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
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['countryCode']}      ${countryCode_CC1}
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['number']}       ${PUSERNAME_U1} 
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['countryCode']}  ${countryCode_CC1}


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
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['countryCode']}      ${countryCode_CC1}
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg']}                    ${EMPTY_List}

    # Should Be Equal As Strings  ${resp.json()[0]['sms'][0]}  ${PUSERNAME_U12}
    # Should Be Equal As Strings  ${resp.json()[0]['pushMsg']}  ${EMPTY_List}
   

JD-TC-GetNotificationSettings_of_User-11
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
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['countryCode']}      ${countryCode_CC1}
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['number']}       ${PUSERNAME_U1} 
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['countryCode']}  ${countryCode_CC1}
   
    # Set Test Variable  @{PushMSG_Num_list}   ${PUSERNAME_U1}
    ${PushMSG}=  Create Dictionary   number=${PUSERNAME_U1}   countryCode=${countryCode_CC1}
    Set Test Variable  @{PushMSG_Num_list}    ${PushMSG}

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
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['countryCode']}  ${countryCode_CC1}

    # Should Be Equal As Strings  ${resp.json()[3]['sms']}  ${EMPTY_List}
    # Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]}  ${PUSERNAME_U1}
    

JD-TC-GetNotificationSettings_of_User-12
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
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['countryCode']}      ${countryCode_CC1}
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['number']}       ${PUSERNAME_U1} 
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['countryCode']}  ${countryCode_CC1}
    
    # Set Test Variable  @{PushMSG_Num_list}   ${PUSERNAME_U1}
    ${PushMSG}=  Create Dictionary   number=${PUSERNAME_U1}   countryCode=${countryCode_CC1}
    Set Test Variable  @{PushMSG_Num_list}    ${PushMSG}
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
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['countryCode']}      ${countryCode_CC1}
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['number']}       ${PUSERNAME_U1} 
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['countryCode']}  ${countryCode_CC1}

  
JD-TC-GetNotificationSettings_of_User-13
    [Documentation]   Getting notification settings of PROVIDER  (After updating all notification settings of any user)
    
     ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     
    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${p2_id}   ${resp.json()[0]['id']}
    Set Suite Variable   ${p1_id}   ${resp.json()[1]['id']}
    Set Suite Variable   ${p0_id}   ${resp.json()[2]['id']}

    ${resp3}=  Get Notification Settings of User   0  
    Log  ${resp3.json()}
    Should Be Equal As Strings  ${resp3.status_code}  200
    Log  ${Response1}
    Should Be Equal As Strings  ${resp3.json()}  ${Response1}
    comment   WAITLISTADD
    Should Be Equal As Strings  ${resp3.json()[0]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp3.json()[0]['eventType']}  ${EventType[0]}
    Should Be Equal As Strings  ${resp3.json()[0]['email'][0]}  ${EMAIL_id0}
    Should Be Equal As Strings  ${resp3.json()[0]['sms'][0]['number']}           ${MUSERNAME_E1} 
    Should Be Equal As Strings  ${resp3.json()[0]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp3.json()[0]['pushMsg'][0]['number']}       ${MUSERNAME_E1} 
    Should Be Equal As Strings  ${resp3.json()[0]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    
    comment   WAITLIST-CANCEL
    Should Be Equal As Strings  ${resp3.json()[1]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp3.json()[1]['eventType']}  ${EventType[1]}
    Should Be Equal As Strings  ${resp3.json()[1]['email'][0]}  ${EMAIL_id0}
    Should Be Equal As Strings  ${resp3.json()[1]['sms'][0]['number']}           ${MUSERNAME_E1} 
    Should Be Equal As Strings  ${resp3.json()[1]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp3.json()[1]['pushMsg'][0]['number']}       ${MUSERNAME_E1} 
    Should Be Equal As Strings  ${resp3.json()[1]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
   
    comment   APPOINTMENTADD
    Should Be Equal As Strings  ${resp3.json()[2]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp3.json()[2]['eventType']}  ${EventType[7]}
    Should Be Equal As Strings  ${resp3.json()[2]['email'][0]}  ${EMAIL_id0}
    Should Be Equal As Strings  ${resp3.json()[2]['sms'][0]['number']}           ${MUSERNAME_E1} 
    Should Be Equal As Strings  ${resp3.json()[2]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp3.json()[2]['pushMsg'][0]['number']}       ${MUSERNAME_E1} 
    Should Be Equal As Strings  ${resp3.json()[2]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    
    comment   APPOINTMENT-CANCEL
    Should Be Equal As Strings  ${resp3.json()[3]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp3.json()[3]['eventType']}  ${EventType[8]}
    Should Be Equal As Strings  ${resp3.json()[3]['email'][0]}  ${EMAIL_id0}
    Should Be Equal As Strings  ${resp3.json()[3]['sms'][0]['number']}           ${MUSERNAME_E1} 
    Should Be Equal As Strings  ${resp3.json()[3]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp3.json()[3]['pushMsg'][0]['number']}       ${MUSERNAME_E1} 
    Should Be Equal As Strings  ${resp3.json()[3]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
   
    comment   DONATION
    Should Be Equal As Strings  ${resp3.json()[4]['resourceType']}  ${NotificationResourceType[3]}
    Should Be Equal As Strings  ${resp3.json()[4]['eventType']}  ${EventType[10]}
    Should Be Equal As Strings  ${resp3.json()[4]['email'][0]}  ${EMAIL_id0}
    Should Be Equal As Strings  ${resp3.json()[4]['sms'][0]['number']}           ${MUSERNAME_E1} 
    Should Be Equal As Strings  ${resp3.json()[4]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp3.json()[4]['pushMsg'][0]['number']}       ${MUSERNAME_E1} 
    Should Be Equal As Strings  ${resp3.json()[4]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}

    comment   LICENCE
    Should Be Equal As Strings  ${resp3.json()[5]['resourceType']}  ${NotificationResourceType[2]}
    Should Be Equal As Strings  ${resp3.json()[5]['eventType']}  ${EventType[9]}
    Should Be Equal As Strings  ${resp3.json()[5]['email'][0]}  ${EMAIL_id0}
    Should Be Equal As Strings  ${resp3.json()[5]['sms'][0]['number']}           ${MUSERNAME_E1} 
    Should Be Equal As Strings  ${resp3.json()[5]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp3.json()[5]['pushMsg'][0]['number']}       ${MUSERNAME_E1} 
    Should Be Equal As Strings  ${resp3.json()[5]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}

   
JD-TC-GetNotificationSettings_of_User-14
    [Documentation]   Use provider id to Get Notification Settings of User (provider is also a user)
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Notification Settings of User  ${prov_id1}   
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
    
    comment   WAITLIST-CANCEL
    Should Be Equal As Strings  ${resp.json()[1]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['eventType']}  ${EventType[1]}
    Should Be Equal As Strings  ${resp.json()[1]['email'][0]}  ${EMAIL_id0}
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['number']}           ${MUSERNAME_E1} 
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['number']}       ${MUSERNAME_E1} 
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    
    comment   APPOINTMENTADD
    Should Be Equal As Strings  ${resp.json()[2]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[2]['eventType']}  ${EventType[7]}
    Should Be Equal As Strings  ${resp.json()[2]['email'][0]}  ${EMAIL_id0}
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['number']}           ${MUSERNAME_E1} 
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['number']}       ${MUSERNAME_E1} 
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
  
    comment   APPOINTMENT-CANCEL
    Should Be Equal As Strings  ${resp.json()[3]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[3]['eventType']}  ${EventType[8]}
    Should Be Equal As Strings  ${resp.json()[3]['email'][0]}  ${EMAIL_id0}
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['number']}           ${MUSERNAME_E1} 
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['number']}       ${MUSERNAME_E1} 
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}


JD-TC-GetNotificationSettings_of_User-15
    [Documentation]   GetNotificationSettings_of_User after Update Notification Settings of provider in "account level"
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${PUSERNAME_U15}=  Evaluate  ${PUSERNAME}+9191112
    clear_users  ${PUSERNAME_U15}
    Set Suite Variable  ${PUSERNAME_U15}  

    ${PUSERNAME_U25}=  Evaluate  ${PUSERNAME}+8181112
    clear_users  ${PUSERNAME_U25}
    Set Suite Variable  ${PUSERNAME_U25}  
    # Set Suite Variable  @{PUSERNAME_SMS_list}   ${PUSERNAME_U15}  ${PUSERNAME_U25}
    ${MSG_Ph1}=  Create Dictionary   number=${PUSERNAME_U15}   countryCode=${countryCode_CC1}
    ${MSG_Ph2}=  Create Dictionary   number=${PUSERNAME_U25}   countryCode=${countryCode_CC1}
    ${PUSERNAME_SMS_list}=  create List    ${MSG_Ph1}   ${MSG_Ph2}
    Set Suite Variable  @{PUSERNAME_SMS_list}

    Set Suite Variable  ${PUser15_EMAIL}   ${P_Email}${PUSERNAME_U15}.${test_mail}
    Set Suite Variable  ${PUser25_EMAIL}   ${P_Email}${PUSERNAME_U25}.${test_mail}
    Set Suite Variable  @{PUser_EMAIL2_list}   ${PUser15_EMAIL}  ${PUser25_EMAIL}
    # Set Suite Variable  @{PushMSG_Num2_list}   ${PUSERNAME_U1}  ${PUSERNAME_U2}
    ${PushMSG1}=  Create Dictionary   number=${PUSERNAME_U1}   countryCode=${countryCode_CC1}
    ${PushMSG2}=  Create Dictionary   number=${PUSERNAME_U2}   countryCode=${countryCode_CC1}
    ${PushMSG_Num2_list}=  create List    ${PushMSG1}   ${PushMSG2}
    Set Suite Variable  @{PushMSG_Num2_list}


    ${resp}=  Update Notification Settings of User  0  ${NotificationResourceType[0]}  ${EventType[0]}  ${PUSERNAME_SMS_list}  ${PUser_EMAIL2_list}  ${PushMSG_Num2_list}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Notification Settings of User  0  ${NotificationResourceType[0]}  ${EventType[1]}  ${PUSERNAME_SMS_list}  ${PUser_EMAIL2_list}  ${PushMSG_Num2_list}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Notification Settings of User  0  ${NotificationResourceType[1]}  ${EventType[7]}  ${PUSERNAME_SMS_list}  ${PUser_EMAIL2_list}  ${PushMSG_Num2_list}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Notification Settings of User  0  ${NotificationResourceType[1]}  ${EventType[8]}  ${PUSERNAME_SMS_list}  ${PUser_EMAIL2_list}  ${PushMSG_Num2_list}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Notification Settings of User  0  ${NotificationResourceType[3]}  ${EventType[10]}  ${PUSERNAME_SMS_list}  ${PUser_EMAIL2_list}  ${PushMSG_Num2_list}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Notification Settings of User  0  ${NotificationResourceType[2]}  ${EventType[9]}  ${PUSERNAME_SMS_list}  ${PUser_EMAIL2_list}  ${PushMSG_Num2_list}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp_R1}=  Get Notification Settings of User  0   
    Log  ${resp_R1.json()}
    Should Be Equal As Strings  ${resp_R1.status_code}  200
    
    ${resp_R2}=  Get Provider Notification Settings
    Log  ${resp_R1.json()}
    Should Be Equal As Strings  ${resp_R1.status_code}  200

    Should Be Equal As Strings  ${resp_R1.json()[0]}  ${resp_R2.json()[0]}
    Should Be Equal As Strings  ${resp_R1.json()[1]}  ${resp_R2.json()[1]}
    Should Be Equal As Strings  ${resp_R1.json()[2]}  ${resp_R2.json()[2]}
    Should Be Equal As Strings  ${resp_R1.json()[3]}  ${resp_R2.json()[3]}
    Should Be Equal As Strings  ${resp_R1.json()[4]}  ${resp_R2.json()[4]}


    ${resp_R3}=  Get Notification Settings of User  ${p0_id}   
    Log  ${resp_R3.json()}
    Should Be Equal As Strings  ${resp_R3.status_code}  200
    Should Not Contain  ${resp_R3.json()}  ${NotificationResourceType[2]}
    Should Not Contain  ${resp_R3.json()}  ${EventType[9]}
    Should Not Be Equal As Strings  ${resp_R1.json()[0]}  ${resp_R3.json()[0]}
    Should Not Be Equal As Strings  ${resp_R1.json()[1]}  ${resp_R3.json()[1]}
    Should Not Be Equal As Strings  ${resp_R1.json()[2]}  ${resp_R3.json()[2]}
    Should Not Be Equal As Strings  ${resp_R1.json()[3]}  ${resp_R3.json()[3]}
    Should Not Be Equal As Strings  ${resp_R2.json()[0]}  ${resp_R3.json()[0]}
    Should Not Be Equal As Strings  ${resp_R2.json()[1]}  ${resp_R3.json()[1]}
    Should Not Be Equal As Strings  ${resp_R2.json()[2]}  ${resp_R3.json()[2]}
    Should Not Be Equal As Strings  ${resp_R2.json()[3]}  ${resp_R3.json()[3]}


JD-TC-GetNotificationSettings_of_User-16
    [Documentation]   GetNotificationSettings_of_User after Update Notification Settings of provider in "User level"
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

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


    ${resp_R1}=  Get Notification Settings of User  0   
    Log  ${resp_R1.json()}
    Should Be Equal As Strings  ${resp_R1.status_code}  200

    ${resp_R2}=  Get Provider Notification Settings
    Log  ${resp_R1.json()}
    Should Be Equal As Strings  ${resp_R1.status_code}  200


    Should Be Equal As Strings  ${resp_R1.json()[0]}  ${resp_R2.json()[0]}
    Should Be Equal As Strings  ${resp_R1.json()[1]}  ${resp_R2.json()[1]}
    Should Be Equal As Strings  ${resp_R1.json()[2]}  ${resp_R2.json()[2]}
    Should Be Equal As Strings  ${resp_R1.json()[3]}  ${resp_R2.json()[3]}
    Should Be Equal As Strings  ${resp_R1.json()[4]}  ${resp_R2.json()[4]}

    ${resp_R3}=  Get Notification Settings of User  ${p0_id}   
    Log  ${resp_R3.json()}
    Should Be Equal As Strings  ${resp_R3.status_code}  200
    Should Not Contain  ${resp_R3.json()}  ${NotificationResourceType[2]}
    Should Not Contain  ${resp_R3.json()}  ${EventType[9]}
    Should Be Equal As Strings  ${resp_R1.json()[0]['resourceType']}  ${resp_R3.json()[0]['resourceType']}
    Should Be Equal As Strings  ${resp_R1.json()[0]['eventType']}     ${resp_R3.json()[0]['eventType']}
    Should Be Equal As Strings  ${resp_R1.json()[0]['email']}         ${resp_R3.json()[0]['email']}
    # Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['number']}       ${PUSERNAME_U2} 
    # Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['countryCode']}  ${countryCodes[1]}

    Should Be Equal As Strings  ${resp_R1.json()[0]['pushMsg']}       ${resp_R3.json()[0]['pushMsg']}
    
    Should Be Equal As Strings  ${resp_R1.json()[1]['resourceType']}  ${resp_R3.json()[1]['resourceType']}
    Should Be Equal As Strings  ${resp_R1.json()[1]['eventType']}     ${resp_R3.json()[1]['eventType']}
    Should Be Equal As Strings  ${resp_R1.json()[1]['email']}         ${resp_R3.json()[1]['email']}
    # Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['number']}       ${PUSERNAME_U2} 
    # Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['countryCode']}  ${countryCodes[1]}

    Should Be Equal As Strings  ${resp_R1.json()[1]['pushMsg']}       ${resp_R3.json()[1]['pushMsg']}

    Should Be Equal As Strings  ${resp_R1.json()[2]['resourceType']}  ${resp_R3.json()[2]['resourceType']}
    Should Be Equal As Strings  ${resp_R1.json()[2]['eventType']}     ${resp_R3.json()[2]['eventType']}
    Should Be Equal As Strings  ${resp_R1.json()[2]['email']}         ${resp_R3.json()[2]['email']}
    # Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['number']}       ${PUSERNAME_U2} 
    # Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['countryCode']}  ${countryCodes[1]}

    Should Be Equal As Strings  ${resp_R1.json()[2]['pushMsg']}       ${resp_R3.json()[2]['pushMsg']}

    Should Be Equal As Strings  ${resp_R1.json()[3]['resourceType']}  ${resp_R3.json()[3]['resourceType']}
    Should Be Equal As Strings  ${resp_R1.json()[3]['eventType']}     ${resp_R3.json()[3]['eventType']}
    Should Be Equal As Strings  ${resp_R1.json()[3]['email']}         ${resp_R3.json()[3]['email']}
    # Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['number']}       ${PUSERNAME_U2} 
    # Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['countryCode']}  ${countryCodes[1]}

    Should Be Equal As Strings  ${resp_R1.json()[3]['pushMsg']}       ${resp_R3.json()[3]['pushMsg']}

    Should Be Equal As Strings  ${resp_R2.json()[0]['resourceType']}  ${resp_R3.json()[0]['resourceType']}
    Should Be Equal As Strings  ${resp_R2.json()[0]['eventType']}     ${resp_R3.json()[0]['eventType']}
    Should Be Equal As Strings  ${resp_R2.json()[0]['email']}         ${resp_R3.json()[0]['email']}
    # Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['number']}       ${PUSERNAME_U2} 
    # Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['countryCode']}  ${countryCodes[1]}

    Should Be Equal As Strings  ${resp_R2.json()[0]['pushMsg']}       ${resp_R3.json()[0]['pushMsg']}

    Should Be Equal As Strings  ${resp_R2.json()[1]['resourceType']}  ${resp_R3.json()[1]['resourceType']}
    Should Be Equal As Strings  ${resp_R2.json()[1]['eventType']}     ${resp_R3.json()[1]['eventType']}
    Should Be Equal As Strings  ${resp_R2.json()[1]['email']}         ${resp_R3.json()[1]['email']}
    # Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['number']}       ${PUSERNAME_U2} 
    # Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['countryCode']}  ${countryCodes[1]}

    Should Be Equal As Strings  ${resp_R2.json()[1]['pushMsg']}       ${resp_R3.json()[1]['pushMsg']}

    Should Be Equal As Strings  ${resp_R2.json()[2]['resourceType']}  ${resp_R3.json()[2]['resourceType']}
    Should Be Equal As Strings  ${resp_R2.json()[2]['eventType']}     ${resp_R3.json()[2]['eventType']}
    Should Be Equal As Strings  ${resp_R2.json()[2]['email']}         ${resp_R3.json()[2]['email']}
    # Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['number']}       ${PUSERNAME_U2} 
    # Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['countryCode']}  ${countryCodes[1]}

    Should Be Equal As Strings  ${resp_R2.json()[2]['pushMsg']}       ${resp_R3.json()[2]['pushMsg']}

    Should Be Equal As Strings  ${resp_R2.json()[3]['resourceType']}  ${resp_R3.json()[3]['resourceType']}
    Should Be Equal As Strings  ${resp_R2.json()[3]['eventType']}     ${resp_R3.json()[3]['eventType']}
    Should Be Equal As Strings  ${resp_R2.json()[3]['email']}         ${resp_R3.json()[3]['email']}
    # Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['number']}       ${PUSERNAME_U2} 
    # Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['countryCode']}  ${countryCodes[1]}

    Should Be Equal As Strings  ${resp_R2.json()[3]['pushMsg']}       ${resp_R3.json()[3]['pushMsg']}

JD-TC-GetNotificationSettings_of_User-UH1
    [Documentation]   Get notification settings without login 
    ${resp}=  Get Notification Settings of User  ${p1_id}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

    ${resp}=  Get Notification Settings of User  ${p2_id}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

JD-TC-GetNotificationSettings_of_User-UH3
    [Documentation]   Consumer get notification settings
    ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Get Notification Settings of User  ${p1_id}   
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings  "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-GetNotificationSettings_of_User-UH4
    [Documentation]  invalid provider

    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Invalid_id}=  Random Int  min=100000  max=200000
    ${resp}=  Get Notification Settings of User  ${Invalid_id}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}   ${EMPTY_List}

JD-TC-GetNotificationSettings_of_User-UH5
    [Documentation]  Get Notification Settings of USER using Disabled USER_id
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${EMPTY_List2}=  Create List  @{EMPTY}
    
    ${resp}=  EnableDisable User  ${p1_id}  ${toggle[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   05s

    ${resp}=  Get Notification Settings of User  ${p1_id}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    comment   WAITLISTADD
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${EventType[0]}
    

    comment   WAITLIST-CANCEL
    Should Be Equal As Strings  ${resp.json()[1]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['eventType']}  ${EventType[1]}


    comment   APPOINTMENTADD
    Should Be Equal As Strings  ${resp.json()[2]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[2]['eventType']}  ${EventType[7]}


    comment   APPOINTMENT-CANCEL
    Should Be Equal As Strings  ${resp.json()[3]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[3]['eventType']}  ${EventType[8]}
    
    
    ${resp}=  EnableDisable User  ${p1_id}  ${toggle[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   02s

JD-TC-GetNotificationSettings_of_User-UH6
    [Documentation]   Get notification settings of USER using user_id of another provider
    
    ${iscorp_subdomains}=  get_iscorp_subdomains  1
     Log  ${iscorp_subdomains}
     Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
     Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
     Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
     ${firstname_A}=  FakerLibrary.first_name
     Set Suite Variable  ${firstname_A}
     ${lastname_A}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname_A}
     ${MUSERNAME_E2}=  Evaluate  ${PUSERNAME}+7810187
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
     Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${MUSERNAME_E2}${\n}
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
     
    
    # ${number1}=  Random Int  min=1000  max=2000
    ${PUSERNAME_U20}=  Evaluate  ${PUSERNAME}+476089
    clear_users  ${PUSERNAME_U20}
    Set Suite Variable  ${PUSERNAME_U20}
    ${firstname1}=  FakerLibrary.name
    Set Suite Variable  ${firstname1}
    ${lastname1}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname1}
    ${dob1}=  FakerLibrary.Date
    Set Suite Variable  ${dob1}
    ${pin}=  get_pincode

    ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U20}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U20}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
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


    ${resp}=  Get Notification Settings of User  ${p1_id40}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()}   ${EMPTY_List}


JD-TC-GetNotificationSettings_of_User-UH7
    [Documentation]   Updated all notification settings of one USER u_id1, then Get notification settings of another USER u_id2
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Notification Settings of User  ${u_id2}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    comment   WAITLISTADD
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${EventType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['email'][0]}  ${PUser2_EMAIL}
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['number']}           ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['countryCode']}      ${countryCode_CC1}
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['number']}       ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['countryCode']}  ${countryCode_CC1}
  

    ${PushMSG_Num3}=  Evaluate  ${PUSERNAME_U2}+3
    ${PushMSG}=  Create Dictionary   number=${PushMSG_Num3}   countryCode=${countryCode_CC1}
    Set Suite Variable  @{PushMSG_Num_list}    ${PushMSG}

    ${resp}=  Update Notification Settings of User  ${u_id2}  ${NotificationResourceType[0]}  ${EventType[0]}  ${PUSERNAME_U14_list}  ${PUser14_EMAIL_list}  ${PushMSG_Num_list}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    ${LOGIN_Number_NOT_is_INVALID}=  Format String    ${LOGIN_NOT_FOUND1}   ${countryCode_CC1}${PushMSG_Num3}
    Should Be Equal As Strings  "${resp.json()}"   "${LOGIN_Number_NOT_is_INVALID}"

    ${resp}=  Get Notification Settings of User  ${u_id2}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    comment   WAITLISTADD-updated
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${EventType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['email'][0]}  ${PUser2_EMAIL}
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['number']}           ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['countryCode']}      ${countryCode_CC1}
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['number']}       ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['countryCode']}  ${countryCode_CC1}

    



