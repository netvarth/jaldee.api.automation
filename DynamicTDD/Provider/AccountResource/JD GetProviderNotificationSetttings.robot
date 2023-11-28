*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        service
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py



*** Variables ***
@{EMPTY_List}
@{CC_countryCode}   +91   91 

*** Test Case ***

JD-TC-GetProviderNotificationSettings-1
    [Documentation]  Getting Provider Notification  Settings without Update Provider Notification Settings

    ${PUSERPH0}=  Evaluate  ${PUSERNAME}+5785527
    Set Suite Variable   ${PUSERPH0}
    ${licid}  ${licname}=  get_highest_license_pkg
    Log  ${licid}
    Log  ${licname}
    ${domresp}=  Get BusinessDomainsConf
    Log   ${domresp.json()}
    Should Be Equal As Strings  ${domresp.status_code}  200

    ${dlen0}=  Get Length  ${domresp.json()}
    ${dlen}=  Evaluate  ${dlen0}-1
    ${dval}=   Random Int   min=0   max=${dlen}

    ${sdlen0}=  Get Length  ${domresp.json()[${dval}]['subDomains']}
    ${sdlen}=  Evaluate  ${sdlen0}-1
    ${sdval}=   Random Int   min=0   max=${sdlen}

    Set Suite Variable  ${d1}  ${domresp.json()[${dval}]['domain']}
    Set Suite Variable  ${sd1}  ${domresp.json()[${dval}]['subDomains'][${sdval}]['subDomain']}
    Set Suite Variable  ${EMAIL_id0}   ${P_Email}${PUSERPH0}.${test_mail}
    Log  ${d1}
    Log  ${sd1}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}=    Random Element    ${Genderlist}
    
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${EMAIL_id0}  ${d1}  ${sd1}  ${PUSERPH0}  ${licid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Account Activation  ${EMAIL_id0}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()}    true
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERPH0}${\n}

    ${resp}=  Account Set Credential  ${EMAIL_id0}  ${PASSWORD}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    Set Suite Variable  ${countryCode_CC0}    ${countryCodes[0]}
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}               ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}                  ${EventType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['number']}           ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['countryCode']}      ${countryCode_CC0} 
    Should Be Equal As Strings  ${resp.json()[0]['email'][0]}                   ${EMAIL_id0} 
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}

    Should Be Equal As Strings  ${resp.json()[1]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['eventType']}  ${EventType[1]}
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['number']}           ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['countryCode']}      ${countryCode_CC0} 
    Should Be Equal As Strings  ${resp.json()[1]['email'][0]}                   ${EMAIL_id0} 
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}

    Should Be Equal As Strings  ${resp.json()[2]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[2]['eventType']}  ${EventType[7]}
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['number']}           ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['countryCode']}      ${countryCode_CC0} 
    Should Be Equal As Strings  ${resp.json()[2]['email'][0]}                   ${EMAIL_id0} 
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}

    Should Be Equal As Strings  ${resp.json()[3]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[3]['eventType']}  ${EventType[8]}
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['number']}           ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['countryCode']}      ${countryCode_CC0} 
    Should Be Equal As Strings  ${resp.json()[3]['email'][0]}                   ${EMAIL_id0} 
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}

    Should Be Equal As Strings  ${resp.json()[4]['resourceType']}  ${NotificationResourceType[3]}
    Should Be Equal As Strings  ${resp.json()[4]['eventType']}     ${EventType[10]}
    Should Be Equal As Strings  ${resp.json()[4]['sms'][0]['number']}           ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[4]['sms'][0]['countryCode']}      ${countryCode_CC0} 
    Should Be Equal As Strings  ${resp.json()[4]['email'][0]}                   ${EMAIL_id0} 
    Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    
    Should Be Equal As Strings  ${resp.json()[5]['resourceType']}  ${NotificationResourceType[2]}
    Should Be Equal As Strings  ${resp.json()[5]['eventType']}     ${EventType[9]}
    Should Be Equal As Strings  ${resp.json()[5]['sms'][0]['number']}           ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[5]['sms'][0]['countryCode']}      ${countryCode_CC0} 
    Should Be Equal As Strings  ${resp.json()[5]['email'][0]}                   ${EMAIL_id0} 
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}


JD-TC-GetProviderNotificationSettings-2
    [Documentation]  Verify Updated Provider Notification  Settings For WAITLISTADD using SMS number as EMPTY 
   
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    # Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pid0}  ${resp.json()['id']}
    # Set Suite Variable  ${pid0}  ${resp.json()['id']}

    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${EventType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['number']}           ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['countryCode']}      ${countryCode_CC0} 
    Should Be Equal As Strings  ${resp.json()[0]['email'][0]}                   ${EMAIL_id0} 
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}

    ${PUSERNAME_U2}=  Evaluate  ${PUSERNAME}+7149539
    Set Suite Variable  ${PUSERNAME_U2}
    # ${countryCode_CC1}    Random Element    ${countryCodes}
    # Set Suite Variable  ${countryCode_CC1}  
    # Set Suite Variable  ${countryCode_CC1}   ${countryCodes[1]}
    ${countryCode_CC1}    Random Element    ${CC_countryCode}
    Set Suite Variable  ${countryCode_CC1}
    ${MSG_Ph1}=  Create Dictionary   number=${PUSERNAME_U2}   countryCode=${countryCode_CC1}
    Set Suite Variable  @{SMS_Num_list2}    ${MSG_Ph1}  

    # ${USERPH1}=  Convert To String   ${PUSERPH0}
    Set Suite Variable  ${USERPH1}   ${PUSERPH0}
    Set Suite Variable  ${PUser_EMAIL2}   ${P_Email}${PUSERNAME_U2}.${test_mail}
    Set Suite Variable  @{PUser_EMAIL_list2}   ${PUser_EMAIL2}
    ${PushMSG}=  Create Dictionary   number=${USERPH1}   countryCode=${countryCode_CC1}
    Set Suite Variable  @{PushMSG_Num_list2}    ${PushMSG} 

    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[0]}  ${EventType[0]}  ${EMPTY_List}  ${PUser_EMAIL_list2}  ${PushMSG_Num_list2}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${EventType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['sms']}  ${EMPTY_List}  
    Should Be Equal As Strings  ${resp.json()[0]['email'][0]}  ${PUser_EMAIL2} 
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['countryCode']}  ${countryCode_CC1}
     

JD-TC-GetProviderNotificationSettings-3
     
    [Documentation]  Verify Updated Provider Notification  Settings For WAITLISTADD using Email id as EMPTY
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    # Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pid0}  ${resp.json()['id']}
    # Set Suite Variable  ${pid0}  ${resp.json()['id']}

    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${EventType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['sms']}  ${EMPTY_List}  
    Should Be Equal As Strings  ${resp.json()[0]['email'][0]}  ${PUser_EMAIL2} 
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['countryCode']}  ${countryCode_CC1}

    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[0]}  ${EventType[0]}  ${SMS_Num_list2}  ${EMPTY_List}  ${PushMSG_Num_list2}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${EventType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['number']}           ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['countryCode']}      ${countryCode_CC1}  
    Should Be Equal As Strings  ${resp.json()[0]['email']}  ${EMPTY_List} 
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['countryCode']}  ${countryCode_CC1}
     

JD-TC-GetProviderNotificationSettings-4
    [Documentation]  Verify Updated Provider Notification  Settings For WAITLISTADD using PushMsg number as EMPTY 
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    # Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pid0}  ${resp.json()['id']}
    # Set Suite Variable  ${pid0}  ${resp.json()['id']}

    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${EventType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['number']}           ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['countryCode']}      ${countryCode_CC1}  
    Should Be Equal As Strings  ${resp.json()[0]['email']}  ${EMPTY_List} 
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['countryCode']}  ${countryCode_CC1}


    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[0]}  ${EventType[0]}  ${SMS_Num_list2}  ${PUser_EMAIL_list2}  ${EMPTY_List}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${EventType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['number']}           ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['countryCode']}      ${countryCode_CC1}  
    Should Be Equal As Strings  ${resp.json()[0]['email'][0]}     ${PUser_EMAIL2} 
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg']}   ${EMPTY_List} 



JD-TC-GetProviderNotificationSettings-5
    [Documentation]  Verify Updated Provider Notification  Settings For WAITLISTADD  using SMS,Email,PushMsg details as EMPTY
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    # Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pid0}  ${resp.json()['id']}
    # Set Suite Variable  ${pid0}  ${resp.json()['id']}

    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${EventType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['number']}           ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['countryCode']}      ${countryCode_CC1}  
    Should Be Equal As Strings  ${resp.json()[0]['email'][0]}     ${PUser_EMAIL2} 
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg']}   ${EMPTY_List}

   
    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[0]}  ${EventType[0]}  ${EMPTY_List}  ${EMPTY_List}  ${EMPTY_List}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${EventType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['sms']}  ${EMPTY_List}  
    Should Be Equal As Strings  ${resp.json()[0]['email']}  ${EMPTY_List} 
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg']}  ${EMPTY_List}


JD-TC-GetProviderNotificationSettings-6
    [Documentation]  Verify Updated Provider Notification  Settings For WAITLISTADD when previous "SMS,EMAIL and PushMsg" details were EMPTY 
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    # Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pid0}  ${resp.json()['id']}
    # Set Suite Variable  ${pid0}  ${resp.json()['id']}

    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${EventType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['sms']}  ${EMPTY_List}  
    Should Be Equal As Strings  ${resp.json()[0]['email']}  ${EMPTY_List} 
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg']}  ${EMPTY_List}

    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[0]}  ${EventType[0]}  ${SMS_Num_list2}  ${PUser_EMAIL_list2}  ${PushMSG_Num_list2}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${EventType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['number']}           ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['countryCode']}      ${countryCode_CC1} 
    Should Be Equal As Strings  ${resp.json()[0]['email'][0]}                   ${PUser_EMAIL2} 
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['countryCode']}  ${countryCode_CC1}

    # Should Be Equal As Strings  ${resp.json()[0]['sms'][0]}  ${PUSERNAME_U2}  
    # Should Be Equal As Strings  ${resp.json()[0]['email'][0]}  ${PUser_EMAIL2} 
    # Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]}  ${PUSERPH0}



JD-TC-GetProviderNotificationSettings-7
    [Documentation]  Verify Updated Provider Notification  Settings For WAITLISTCANCEL using SMS number as EMPTY 
   
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    # Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pid0}  ${resp.json()['id']}
    # Set Suite Variable  ${pid0}  ${resp.json()['id']}

    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[1]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['eventType']}  ${EventType[1]}
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['number']}           ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['countryCode']}      ${countryCode_CC0} 
    Should Be Equal As Strings  ${resp.json()[1]['email'][0]}                   ${EMAIL_id0} 
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}

    # Should Be Equal As Strings  ${resp.json()[1]['sms'][0]}  ${PUSERPH0}  
    # Should Be Equal As Strings  ${resp.json()[1]['email'][0]}  ${EMAIL_id0} 
    # Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]}  ${PUSERPH0}
    ${MSG_Ph1}=  Create Dictionary   number=${PUSERNAME_U2}   countryCode=${countryCode_CC1}
    Set Suite Variable  @{SMS_Num_list2}    ${MSG_Ph1}  
    ${PushMSG}=  Create Dictionary   number=${USERPH1}   countryCode=${countryCode_CC1}
    Set Suite Variable  @{PushMSG_Num_list2}    ${PushMSG} 


    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[0]}  ${EventType[1]}  ${EMPTY_List}  ${PUser_EMAIL_list2}  ${PushMSG_Num_list2}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[1]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['eventType']}  ${EventType[1]}
    Should Be Equal As Strings  ${resp.json()[1]['sms']}                        ${EMPTY_List} 
    Should Be Equal As Strings  ${resp.json()[1]['email'][0]}                   ${PUser_EMAIL2} 
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['countryCode']}  ${countryCode_CC1}

    # Should Be Equal As Strings  ${resp.json()[1]['sms']}  ${EMPTY_List}  
    # Should Be Equal As Strings  ${resp.json()[1]['email'][0]}  ${PUser_EMAIL2} 
    # Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]}  ${PUSERPH0}
     
     


JD-TC-GetProviderNotificationSettings-8
     
    [Documentation]  Verify Updated Provider Notification  Settings For WAITLISTCANCEL using Email id as EMPTY
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    # Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pid0}  ${resp.json()['id']}
    # Set Suite Variable  ${pid0}  ${resp.json()['id']}

    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[1]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['eventType']}  ${EventType[1]}
    Should Be Equal As Strings  ${resp.json()[1]['sms']}                        ${EMPTY_List} 
    Should Be Equal As Strings  ${resp.json()[1]['email'][0]}                   ${PUser_EMAIL2} 
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['countryCode']}  ${countryCode_CC1}

    # Should Be Equal As Strings  ${resp.json()[1]['sms']}  ${EMPTY_List}  
    # Should Be Equal As Strings  ${resp.json()[1]['email'][0]}  ${PUser_EMAIL2} 
    # Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]}  ${PUSERPH0}



    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[0]}  ${EventType[1]}  ${SMS_Num_list2}  ${EMPTY_List}  ${PushMSG_Num_list2}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[1]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['eventType']}  ${EventType[1]}
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['number']}           ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['countryCode']}      ${countryCode_CC1} 
    Should Be Equal As Strings  ${resp.json()[1]['email']}                      ${EMPTY_List} 
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['countryCode']}  ${countryCode_CC1}

    # Should Be Equal As Strings  ${resp.json()[1]['sms'][0]}  ${PUSERNAME_U2}  
    # Should Be Equal As Strings  ${resp.json()[1]['email']}  ${EMPTY_List} 
    # Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]}  ${PUSERPH0}
     

JD-TC-GetProviderNotificationSettings-9
    [Documentation]  Verify Updated Provider Notification  Settings For WAITLISTCANCEL using PushMsg number as EMPTY 
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    # Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pid0}  ${resp.json()['id']}
    # Set Suite Variable  ${pid0}  ${resp.json()['id']}

    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[1]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['eventType']}  ${EventType[1]}
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['number']}           ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['countryCode']}      ${countryCode_CC1} 
    Should Be Equal As Strings  ${resp.json()[1]['email']}                      ${EMPTY_List} 
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['countryCode']}  ${countryCode_CC1}

    # Should Be Equal As Strings  ${resp.json()[1]['sms'][0]}  ${PUSERNAME_U2}  
    # Should Be Equal As Strings  ${resp.json()[1]['email']}  ${EMPTY_List} 
    # Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]}  ${PUSERPH0}

 
    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[0]}  ${EventType[1]}  ${SMS_Num_list2}  ${PUser_EMAIL_list2}  ${EMPTY_List}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[1]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['eventType']}  ${EventType[1]}
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['number']}           ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['countryCode']}      ${countryCode_CC1}
    Should Be Equal As Strings  ${resp.json()[1]['email'][0]}                   ${PUser_EMAIL2} 
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg']}                    ${EMPTY_List}

    # Should Be Equal As Strings  ${resp.json()[1]['sms'][0]}  ${PUSERNAME_U2}  
    # Should Be Equal As Strings  ${resp.json()[1]['email'][0]}  ${PUser_EMAIL2} 
    # Should Be Equal As Strings  ${resp.json()[1]['pushMsg']}  ${EMPTY_List}
     




JD-TC-GetProviderNotificationSettings-10
    [Documentation]  Verify Updated Provider Notification  Settings For WAITLISTCANCEL  using SMS,Email,PushMsg details as EMPTY
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    # Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pid0}  ${resp.json()['id']}
    # Set Suite Variable  ${pid0}  ${resp.json()['id']}

    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[1]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['eventType']}  ${EventType[1]}
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['number']}           ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['countryCode']}      ${countryCode_CC1} 
    Should Be Equal As Strings  ${resp.json()[1]['email'][0]}                   ${PUser_EMAIL2} 
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg']}                    ${EMPTY_List}

    # Should Be Equal As Strings  ${resp.json()[1]['sms'][0]}  ${PUSERNAME_U2}  
    # Should Be Equal As Strings  ${resp.json()[1]['email'][0]}  ${PUser_EMAIL2} 
    # Should Be Equal As Strings  ${resp.json()[1]['pushMsg']}  ${EMPTY_List}

 
    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[0]}  ${EventType[1]}  ${EMPTY_List}  ${EMPTY_List}  ${EMPTY_List}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[1]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['eventType']}  ${EventType[1]}
    Should Be Equal As Strings  ${resp.json()[1]['sms']}  ${EMPTY_List}  
    Should Be Equal As Strings  ${resp.json()[1]['email']}  ${EMPTY_List} 
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg']}  ${EMPTY_List}






JD-TC-GetProviderNotificationSettings-11
    [Documentation]  Verify Updated Provider Notification  Settings For WAITLISTCANCEL when previous "SMS,EMAIL and PushMsg" details were EMPTY 
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    # Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pid0}  ${resp.json()['id']}
    # Set Suite Variable  ${pid0}  ${resp.json()['id']}

    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[1]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['eventType']}  ${EventType[1]}
    Should Be Equal As Strings  ${resp.json()[1]['sms']}  ${EMPTY_List}  
    Should Be Equal As Strings  ${resp.json()[1]['email']}  ${EMPTY_List} 
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg']}  ${EMPTY_List}

   
    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[0]}  ${EventType[1]}  ${SMS_Num_list2}  ${PUser_EMAIL_list2}  ${PushMSG_Num_list2}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[1]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['eventType']}  ${EventType[1]}
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['number']}           ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['countryCode']}      ${countryCode_CC1}
    Should Be Equal As Strings  ${resp.json()[1]['email'][0]}                   ${PUser_EMAIL2} 
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['countryCode']}  ${countryCode_CC1}

    # Should Be Equal As Strings  ${resp.json()[1]['sms'][0]}  ${PUSERNAME_U2}  
    # Should Be Equal As Strings  ${resp.json()[1]['email'][0]}  ${PUser_EMAIL2} 
    # Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]}  ${PUSERPH0}




# ###################################################################################




JD-TC-GetProviderNotificationSettings-12
    [Documentation]  Verify Updated Provider Notification  Settings For APPOINTMENTADD using SMS number as EMPTY  
   
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    # Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pid0}  ${resp.json()['id']}
    # Set Suite Variable  ${pid0}  ${resp.json()['id']}

    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[2]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[2]['eventType']}  ${EventType[7]}
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['number']}           ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['countryCode']}      ${countryCode_CC0} 
    Should Be Equal As Strings  ${resp.json()[2]['email'][0]}                   ${EMAIL_id0} 
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}

    # Should Be Equal As Strings  ${resp.json()[2]['sms'][0]}  ${PUSERPH0}  
    # Should Be Equal As Strings  ${resp.json()[2]['email'][0]}  ${EMAIL_id0} 
    # Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]}  ${PUSERPH0}

   
    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[1]}  ${EventType[7]}  ${EMPTY_List}  ${PUser_EMAIL_list2}  ${PushMSG_Num_list2}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[2]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[2]['eventType']}  ${EventType[7]}
    Should Be Equal As Strings  ${resp.json()[2]['sms']}                        ${EMPTY_List} 
    Should Be Equal As Strings  ${resp.json()[2]['email'][0]}                   ${PUser_EMAIL2} 
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['countryCode']}  ${countryCode_CC1}

    # Should Be Equal As Strings  ${resp.json()[2]['sms']}  ${EMPTY_List}  
    # Should Be Equal As Strings  ${resp.json()[2]['email'][0]}  ${PUser_EMAIL2} 
    # Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]}  ${PUSERPH0}
     
     


JD-TC-GetProviderNotificationSettings-13
     
    [Documentation]  Verify Updated Provider Notification  Settings For APPOINTMENTADD using Email id as EMPTY
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    # Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pid0}  ${resp.json()['id']}
    # Set Suite Variable  ${pid0}  ${resp.json()['id']}

    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[2]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[2]['eventType']}  ${EventType[7]}
    Should Be Equal As Strings  ${resp.json()[2]['sms']}                        ${EMPTY_List} 
    Should Be Equal As Strings  ${resp.json()[2]['email'][0]}                   ${PUser_EMAIL2} 
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['countryCode']}  ${countryCode_CC1}

    # Should Be Equal As Strings  ${resp.json()[2]['sms']}  ${EMPTY_List}  
    # Should Be Equal As Strings  ${resp.json()[2]['email'][0]}  ${PUser_EMAIL2} 
    # Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]}  ${PUSERPH0}


    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[1]}  ${EventType[7]}  ${SMS_Num_list2}  ${EMPTY_List}  ${PushMSG_Num_list2}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[2]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[2]['eventType']}  ${EventType[7]}
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['number']}           ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['countryCode']}      ${countryCode_CC1} 
    Should Be Equal As Strings  ${resp.json()[2]['email']}                      ${EMPTY_List} 
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['countryCode']}  ${countryCode_CC1}

    # Should Be Equal As Strings  ${resp.json()[2]['sms'][0]}  ${PUSERNAME_U2}  
    # Should Be Equal As Strings  ${resp.json()[2]['email']}  ${EMPTY_List} 
    # Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]}  ${PUSERPH0}
     

JD-TC-GetProviderNotificationSettings-14
    [Documentation]  Verify Updated Provider Notification  Settings For APPOINTMENTADD using PushMsg number as EMPTY 
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    # Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pid0}  ${resp.json()['id']}
    # Set Suite Variable  ${pid0}  ${resp.json()['id']}

    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[2]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[2]['eventType']}  ${EventType[7]}
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['number']}           ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['countryCode']}      ${countryCode_CC1} 
    Should Be Equal As Strings  ${resp.json()[2]['email']}                      ${EMPTY_List} 
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['countryCode']}  ${countryCode_CC1}

    # Should Be Equal As Strings  ${resp.json()[2]['sms'][0]}  ${PUSERNAME_U2}  
    # Should Be Equal As Strings  ${resp.json()[2]['email']}  ${EMPTY_List} 
    # Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]}  ${PUSERPH0}

   
    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[1]}  ${EventType[7]}  ${SMS_Num_list2}  ${PUser_EMAIL_list2}  ${EMPTY_List}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[2]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[2]['eventType']}  ${EventType[7]}
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['number']}           ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['countryCode']}      ${countryCode_CC1} 
    Should Be Equal As Strings  ${resp.json()[2]['email'][0]}                   ${PUser_EMAIL2} 
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg']}                    ${EMPTY_List}

    # Should Be Equal As Strings  ${resp.json()[2]['sms'][0]}  ${PUSERNAME_U2}  
    # Should Be Equal As Strings  ${resp.json()[2]['email'][0]}  ${PUser_EMAIL2} 
    # Should Be Equal As Strings  ${resp.json()[2]['pushMsg']}  ${EMPTY_List}
     




JD-TC-GetProviderNotificationSettings-15
    [Documentation]  Verify Updated Provider Notification  Settings For APPOINTMENTADD  using SMS,Email,PushMsg details as EMPTY
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    # Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pid0}  ${resp.json()['id']}
    # Set Suite Variable  ${pid0}  ${resp.json()['id']}

    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[2]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[2]['eventType']}  ${EventType[7]}
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['number']}           ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['countryCode']}      ${countryCode_CC1} 
    Should Be Equal As Strings  ${resp.json()[2]['email'][0]}                   ${PUser_EMAIL2} 
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg']}                    ${EMPTY_List}

    # Should Be Equal As Strings  ${resp.json()[2]['sms'][0]}  ${PUSERNAME_U2}  
    # Should Be Equal As Strings  ${resp.json()[2]['email'][0]}  ${PUser_EMAIL2} 
    # Should Be Equal As Strings  ${resp.json()[2]['pushMsg']}  ${EMPTY_List}


   
    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[1]}  ${EventType[7]}  ${EMPTY_List}  ${EMPTY_List}  ${EMPTY_List}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[2]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[2]['eventType']}  ${EventType[7]}
    Should Be Equal As Strings  ${resp.json()[2]['sms']}  ${EMPTY_List}  
    Should Be Equal As Strings  ${resp.json()[2]['email']}  ${EMPTY_List} 
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg']}  ${EMPTY_List}



JD-TC-GetProviderNotificationSettings-16
    [Documentation]  Verify Updated Provider Notification  Settings For APPOINTMENTADD when previous "SMS,EMAIL and PushMsg" details were EMPTY 
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    # Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pid0}  ${resp.json()['id']}
    # Set Suite Variable  ${pid0}  ${resp.json()['id']}

    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[2]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[2]['eventType']}  ${EventType[7]}
    Should Be Equal As Strings  ${resp.json()[2]['sms']}  ${EMPTY_List}  
    Should Be Equal As Strings  ${resp.json()[2]['email']}  ${EMPTY_List} 
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg']}  ${EMPTY_List}


   
    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[1]}  ${EventType[7]}  ${SMS_Num_list2}  ${PUser_EMAIL_list2}  ${PushMSG_Num_list2}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[2]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[2]['eventType']}  ${EventType[7]}
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['number']}           ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['countryCode']}      ${countryCode_CC1} 
    Should Be Equal As Strings  ${resp.json()[2]['email'][0]}                   ${PUser_EMAIL2} 
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['countryCode']}  ${countryCode_CC1}

    # Should Be Equal As Strings  ${resp.json()[2]['sms'][0]}  ${PUSERNAME_U2}  
    # Should Be Equal As Strings  ${resp.json()[2]['email'][0]}  ${PUser_EMAIL2} 
    # Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]}  ${PUSERPH0}





# ####################################################################################



JD-TC-GetProviderNotificationSettings-17
    [Documentation]  Verify Updated Provider Notification  Settings For APPOINTMENTCANCEL using SMS number as EMPTY  
   
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    # Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pid0}  ${resp.json()['id']}
    # Set Suite Variable  ${pid0}  ${resp.json()['id']}

    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[3]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[3]['eventType']}  ${EventType[8]}
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['number']}           ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['countryCode']}      ${countryCode_CC0} 
    Should Be Equal As Strings  ${resp.json()[3]['email'][0]}                   ${EMAIL_id0} 
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}

    # Should Be Equal As Strings  ${resp.json()[3]['sms'][0]}  ${PUSERPH0}  
    # Should Be Equal As Strings  ${resp.json()[3]['email'][0]}  ${EMAIL_id0} 
    # Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]}  ${PUSERPH0}

   
    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[1]}  ${EventType[8]}  ${EMPTY_List}  ${PUser_EMAIL_list2}  ${PushMSG_Num_list2}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[3]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[3]['eventType']}  ${EventType[8]}
    Should Be Equal As Strings  ${resp.json()[3]['sms']}                        ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()[3]['email'][0]}                   ${PUser_EMAIL2} 
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['countryCode']}  ${countryCode_CC1}

    # Should Be Equal As Strings  ${resp.json()[3]['sms']}  ${EMPTY_List}  
    # Should Be Equal As Strings  ${resp.json()[3]['email'][0]}  ${PUser_EMAIL2} 
    # Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]}  ${PUSERPH0}
     
     


JD-TC-GetProviderNotificationSettings-18
     
    [Documentation]  Verify Updated Provider Notification  Settings For APPOINTMENTCANCEL using Email id as EMPTY
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    # Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pid0}  ${resp.json()['id']}
    # Set Suite Variable  ${pid0}  ${resp.json()['id']}

    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[3]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[3]['eventType']}  ${EventType[8]}
    Should Be Equal As Strings  ${resp.json()[3]['sms']}                        ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()[3]['email'][0]}                   ${PUser_EMAIL2} 
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['countryCode']}  ${countryCode_CC1}

    # Should Be Equal As Strings  ${resp.json()[3]['sms']}  ${EMPTY_List}  
    # Should Be Equal As Strings  ${resp.json()[3]['email'][0]}  ${PUser_EMAIL2} 
    # Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]}  ${PUSERPH0}


   
    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[1]}  ${EventType[8]}  ${SMS_Num_list2}  ${EMPTY_List}  ${PushMSG_Num_list2}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[3]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[3]['eventType']}  ${EventType[8]}
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['number']}           ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['countryCode']}      ${countryCode_CC1}
    Should Be Equal As Strings  ${resp.json()[3]['email']}                      ${EMPTY_List} 
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['countryCode']}  ${countryCode_CC1}

    # Should Be Equal As Strings  ${resp.json()[3]['sms'][0]}  ${PUSERNAME_U2}  
    # Should Be Equal As Strings  ${resp.json()[3]['email']}  ${EMPTY_List} 
    # Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]}  ${PUSERPH0}
     

JD-TC-GetProviderNotificationSettings-19
    [Documentation]  Verify Updated Provider Notification  Settings For APPOINTMENTCANCEL using PushMsg number as EMPTY 
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    # Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pid0}  ${resp.json()['id']}
    # Set Suite Variable  ${pid0}  ${resp.json()['id']}

    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[3]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[3]['eventType']}  ${EventType[8]}
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['number']}           ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['countryCode']}      ${countryCode_CC1} 
    Should Be Equal As Strings  ${resp.json()[3]['email']}                      ${EMPTY_List} 
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['countryCode']}  ${countryCode_CC1}

    # Should Be Equal As Strings  ${resp.json()[3]['sms'][0]}  ${PUSERNAME_U2}  
    # Should Be Equal As Strings  ${resp.json()[3]['email']}  ${EMPTY_List} 
    # Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]}  ${PUSERPH0}


   
    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[1]}  ${EventType[8]}  ${SMS_Num_list2}  ${PUser_EMAIL_list2}  ${EMPTY_List}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[3]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[3]['eventType']}  ${EventType[8]}
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['number']}           ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['countryCode']}      ${countryCode_CC1} 
    Should Be Equal As Strings  ${resp.json()[3]['email'][0]}                   ${PUser_EMAIL2} 
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg']}                    ${EMPTY_List}

    # Should Be Equal As Strings  ${resp.json()[3]['sms'][0]}  ${PUSERNAME_U2}  
    # Should Be Equal As Strings  ${resp.json()[3]['email'][0]}  ${PUser_EMAIL2} 
    # Should Be Equal As Strings  ${resp.json()[3]['pushMsg']}  ${EMPTY_List}
    


JD-TC-GetProviderNotificationSettings-20
    [Documentation]  Verify Updated Provider Notification  Settings For APPOINTMENTCANCEL  using SMS,Email,PushMsg details as EMPTY
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    # Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pid0}  ${resp.json()['id']}
    # Set Suite Variable  ${pid0}  ${resp.json()['id']}

    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[3]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[3]['eventType']}  ${EventType[8]}
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['number']}           ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['countryCode']}      ${countryCode_CC1} 
    Should Be Equal As Strings  ${resp.json()[3]['email'][0]}                   ${PUser_EMAIL2} 
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg']}                    ${EMPTY_List}

    # Should Be Equal As Strings  ${resp.json()[3]['sms'][0]}  ${PUSERNAME_U2}  
    # Should Be Equal As Strings  ${resp.json()[3]['email'][0]}  ${PUser_EMAIL2} 
    # Should Be Equal As Strings  ${resp.json()[3]['pushMsg']}  ${EMPTY_List}


   
    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[1]}  ${EventType[8]}  ${EMPTY_List}  ${EMPTY_List}  ${EMPTY_List}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[3]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[3]['eventType']}  ${EventType[8]}
    Should Be Equal As Strings  ${resp.json()[3]['sms']}  ${EMPTY_List}  
    Should Be Equal As Strings  ${resp.json()[3]['email']}  ${EMPTY_List} 
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg']}  ${EMPTY_List}



JD-TC-GetProviderNotificationSettings-21
    [Documentation]  Verify Updated Provider Notification  Settings For APPOINTMENTCANCEL when previous "SMS,EMAIL and PushMsg" details were EMPTY 
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    # Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pid0}  ${resp.json()['id']}
    # Set Suite Variable  ${pid0}  ${resp.json()['id']}

    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[3]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[3]['eventType']}  ${EventType[8]}
    Should Be Equal As Strings  ${resp.json()[3]['sms']}  ${EMPTY_List}  
    Should Be Equal As Strings  ${resp.json()[3]['email']}  ${EMPTY_List} 
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg']}  ${EMPTY_List}


   
    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[1]}  ${EventType[8]}  ${SMS_Num_list2}  ${PUser_EMAIL_list2}  ${PushMSG_Num_list2}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[3]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[3]['eventType']}  ${EventType[8]}
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['number']}           ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['countryCode']}      ${countryCode_CC1} 
    Should Be Equal As Strings  ${resp.json()[3]['email'][0]}                   ${PUser_EMAIL2} 
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['countryCode']}  ${countryCode_CC1}

    # Should Be Equal As Strings  ${resp.json()[3]['sms'][0]}  ${PUSERNAME_U2}  
    # Should Be Equal As Strings  ${resp.json()[3]['email'][0]}  ${PUser_EMAIL2} 
    # Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]}  ${PUSERPH0}




# ###################################################################


JD-TC-GetProviderNotificationSettings-22
    [Documentation]  Verify Updated Provider Notification  Settings For 'WAITLISTADD', when we have TWO 'SMS' Numbers and REMOVE ONE Number 
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${Phone_Num1}=  Evaluate  ${PUSERNAME}+3349578
    Set Suite Variable  ${Phone_Num1}
    ${Ph1}=  Create Dictionary   number=${Phone_Num1}   countryCode=${countryCode_CC1}
    ${Phone_Num2}=  Evaluate  ${PUSERNAME}+2249578
    Set Suite Variable  ${Phone_Num2}
    ${Ph2}=  Create Dictionary   number=${Phone_Num2}   countryCode=${countryCode_CC1}
    ${SMS_TwoNum_list}=  create List  ${Ph1}  ${Ph2}
    Set Suite Variable  @{SMS_TwoNum_list}
    Set Suite Variable  @{SMS_OneNum_list}   ${Ph1}


    Set Suite Variable  ${EMAIL1}   ${P_Email}${Phone_Num1}.${test_mail}
    Set Suite Variable  ${EMAIL2}   ${P_Email}${Phone_Num2}.${test_mail}
    ${TwoEMAIL_list}=  create List  ${EMAIL1}  ${EMAIL2}
    Set Suite Variable  @{TwoEMAIL_list}
    Set Suite Variable  @{OneEMAIL_list}   ${EMAIL1}
    ${PushMSG1}=  Create Dictionary   number=${PUSERPH0}   countryCode=${countryCode_CC1}
    Set Suite Variable  @{PushMSG_Num_list}   ${PushMSG1}
    # ${PushMSG_Num_list}=  create List  ${PUSERPH0}



    # ${PUSERNAME_U2}=  Evaluate  ${PUSERNAME}+7149539
    # Set Suite Variable  ${PUSERNAME_U2}
    # ${MSG_Ph1}=  Create Dictionary   number=${PUSERNAME_U2}   countryCode=${countryCodes[0]}
    # Set Suite Variable  @{SMS_Num_list2}    ${MSG_Ph1}  

    # Set Suite Variable  ${USERPH1}   ${PUSERPH0}
    # Set Suite Variable  ${PUser_EMAIL2}   ${P_Email}${PUSERNAME_U2}.${test_mail}
    # Set Suite Variable  @{PUser_EMAIL_list2}   ${PUser_EMAIL2}
    # ${PushMSG}=  Create Dictionary   number=${USERPH1}   countryCode=${countryCodes[0]}
    # Set Suite Variable  @{PushMSG_Num_list2}    ${PushMSG}

   
    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[0]}  ${EventType[0]}  ${SMS_TwoNum_list}  ${TwoEMAIL_list}  ${PushMSG_Num_list}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${EventType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['number']}           ${Phone_Num1} 
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['countryCode']}      ${countryCode_CC1} 
    Should Be Equal As Strings  ${resp.json()[0]['sms'][1]['number']}           ${Phone_Num2} 
    Should Be Equal As Strings  ${resp.json()[0]['sms'][1]['countryCode']}      ${countryCode_CC1}
    Should Be Equal As Strings  ${resp.json()[0]['email'][0]}                   ${EMAIL1} 
    Should Be Equal As Strings  ${resp.json()[0]['email'][1]}                   ${EMAIL2}
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['countryCode']}  ${countryCode_CC1}

    # Should Be Equal As Strings  ${resp.json()[0]['sms'][0]}  ${Phone_Num1}
    # Should Be Equal As Strings  ${resp.json()[0]['sms'][1]}  ${Phone_Num2}  
    # Should Be Equal As Strings  ${resp.json()[0]['email'][0]}  ${EMAIL1}
    # Should Be Equal As Strings  ${resp.json()[0]['email'][1]}  ${EMAIL2} 
    # Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]}  ${PUSERPH0}


    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[0]}  ${EventType[0]}  ${SMS_OneNum_list}  ${OneEMAIL_list}  ${PushMSG_Num_list}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${EventType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['number']}           ${Phone_Num1} 
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['countryCode']}      ${countryCode_CC1}
    Should Be Equal As Strings  ${resp.json()[0]['email'][0]}                   ${EMAIL1} 
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['countryCode']}  ${countryCode_CC1}

    # Should Be Equal As Strings  ${resp.json()[0]['sms'][0]}  ${Phone_Num1} 
    # Should Be Equal As Strings  ${resp.json()[0]['email'][0]}  ${EMAIL1}
    # Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]}  ${PUSERPH0}


JD-TC-GetProviderNotificationSettings-23
    [Documentation]  Verify Updated Provider Notification  Settings For 'WAITLISTCANCEL', when we have TWO 'SMS' Numbers and REMOVE ONE Number 
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
  

    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[0]}  ${EventType[1]}  ${SMS_TwoNum_list}  ${TwoEMAIL_list}  ${PushMSG_Num_list}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[1]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['eventType']}  ${EventType[1]}
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['number']}           ${Phone_Num1} 
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['countryCode']}      ${countryCode_CC1} 
    Should Be Equal As Strings  ${resp.json()[1]['sms'][1]['number']}           ${Phone_Num2} 
    Should Be Equal As Strings  ${resp.json()[1]['sms'][1]['countryCode']}      ${countryCode_CC1}
    Should Be Equal As Strings  ${resp.json()[1]['email'][0]}                   ${EMAIL1}
    Should Be Equal As Strings  ${resp.json()[1]['email'][1]}                   ${EMAIL2}  
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['countryCode']}  ${countryCode_CC1}

    # Should Be Equal As Strings  ${resp.json()[1]['sms'][0]}  ${Phone_Num1}
    # Should Be Equal As Strings  ${resp.json()[1]['sms'][1]}  ${Phone_Num2}  
    # Should Be Equal As Strings  ${resp.json()[1]['email'][0]}  ${EMAIL1}
    # Should Be Equal As Strings  ${resp.json()[1]['email'][1]}  ${EMAIL2} 
    # Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]}  ${PUSERPH0}


    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[0]}  ${EventType[1]}  ${SMS_OneNum_list}  ${OneEMAIL_list}  ${PushMSG_Num_list}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[1]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['eventType']}  ${EventType[1]}
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['number']}           ${Phone_Num1} 
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['countryCode']}      ${countryCode_CC1}
    Should Be Equal As Strings  ${resp.json()[1]['email'][0]}                   ${EMAIL1} 
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['countryCode']}  ${countryCode_CC1}

    # Should Be Equal As Strings  ${resp.json()[1]['sms'][0]}  ${Phone_Num1} 
    # Should Be Equal As Strings  ${resp.json()[1]['email'][0]}  ${EMAIL1}
    # Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]}  ${PUSERPH0}



JD-TC-GetProviderNotificationSettings-24
    [Documentation]  Verify Updated Provider Notification  Settings For 'APPOINTMENTADD', when we have TWO 'SMS' Numbers and REMOVE ONE Number 
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
  

    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[1]}  ${EventType[7]}  ${SMS_TwoNum_list}  ${TwoEMAIL_list}  ${PushMSG_Num_list}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[2]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[2]['eventType']}  ${EventType[7]}
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['number']}           ${Phone_Num1} 
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['countryCode']}      ${countryCode_CC1} 
    Should Be Equal As Strings  ${resp.json()[2]['sms'][1]['number']}           ${Phone_Num2} 
    Should Be Equal As Strings  ${resp.json()[2]['sms'][1]['countryCode']}      ${countryCode_CC1}
    Should Be Equal As Strings  ${resp.json()[2]['email'][0]}                   ${EMAIL1} 
    Should Be Equal As Strings  ${resp.json()[2]['email'][1]}                   ${EMAIL2}
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['countryCode']}  ${countryCode_CC1}

    # Should Be Equal As Strings  ${resp.json()[2]['sms'][0]}  ${Phone_Num1}
    # Should Be Equal As Strings  ${resp.json()[2]['sms'][1]}  ${Phone_Num2}  
    # Should Be Equal As Strings  ${resp.json()[2]['email'][0]}  ${EMAIL1}
    # Should Be Equal As Strings  ${resp.json()[2]['email'][1]}  ${EMAIL2} 
    # Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]}  ${PUSERPH0}

    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[1]}  ${EventType[7]}  ${SMS_OneNum_list}  ${OneEMAIL_list}  ${PushMSG_Num_list}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[2]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[2]['eventType']}  ${EventType[7]}
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['number']}           ${Phone_Num1} 
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['countryCode']}      ${countryCode_CC1} 
    Should Be Equal As Strings  ${resp.json()[2]['email'][0]}                   ${EMAIL1} 
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['countryCode']}  ${countryCode_CC1}

    # Should Be Equal As Strings  ${resp.json()[2]['sms'][0]}  ${Phone_Num1} 
    # Should Be Equal As Strings  ${resp.json()[2]['email'][0]}  ${EMAIL1}
    # Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]}  ${PUSERPH0}


JD-TC-GetProviderNotificationSettings-25
    [Documentation]  Verify Updated Provider Notification  Settings For 'APPOINTMENTCANCEL', when we have TWO 'SMS' Numbers and REMOVE ONE Number 
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
  

   
    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[1]}  ${EventType[8]}  ${SMS_TwoNum_list}  ${TwoEMAIL_list}  ${PushMSG_Num_list}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[3]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[3]['eventType']}  ${EventType[8]}
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['number']}           ${Phone_Num1} 
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['countryCode']}      ${countryCode_CC1}
    Should Be Equal As Strings  ${resp.json()[3]['sms'][1]['number']}           ${Phone_Num2} 
    Should Be Equal As Strings  ${resp.json()[3]['sms'][1]['countryCode']}      ${countryCode_CC1}
    Should Be Equal As Strings  ${resp.json()[3]['email'][0]}                   ${EMAIL1}
    Should Be Equal As Strings  ${resp.json()[3]['email'][1]}                   ${EMAIL2} 
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['countryCode']}  ${countryCode_CC1}

    # Should Be Equal As Strings  ${resp.json()[3]['sms'][0]}  ${Phone_Num1}
    # Should Be Equal As Strings  ${resp.json()[3]['sms'][1]}  ${Phone_Num2}  
    # Should Be Equal As Strings  ${resp.json()[3]['email'][0]}  ${EMAIL1}
    # Should Be Equal As Strings  ${resp.json()[3]['email'][1]}  ${EMAIL2} 
    # Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]}  ${PUSERPH0}


    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[1]}  ${EventType[8]}  ${SMS_OneNum_list}  ${OneEMAIL_list}  ${PushMSG_Num_list}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[3]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[3]['eventType']}  ${EventType[8]}
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['number']}           ${Phone_Num1} 
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['countryCode']}      ${countryCode_CC1} 
    Should Be Equal As Strings  ${resp.json()[3]['email'][0]}                   ${EMAIL1} 
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['countryCode']}  ${countryCode_CC1}

    # Should Be Equal As Strings  ${resp.json()[3]['sms'][0]}  ${Phone_Num1} 
    # Should Be Equal As Strings  ${resp.json()[3]['email'][0]}  ${EMAIL1}
    # Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]}  ${PUSERPH0}



# ################################################################



JD-TC-GetProviderNotificationSettings-26
    [Documentation]  Update Provider LICENSE Related Notification  Settings using SMS number as EMPTY 
   
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    # Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pid0}  ${resp.json()['id']}
    # Set Suite Variable  ${pid0}  ${resp.json()['id']}

    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[5]['resourceType']}  ${NotificationResourceType[2]}
    Should Be Equal As Strings  ${resp.json()[5]['eventType']}  ${EventType[9]}
    Should Be Equal As Strings  ${resp.json()[5]['sms'][0]['number']}           ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[5]['sms'][0]['countryCode']}      ${countryCode_CC0} 
    Should Be Equal As Strings  ${resp.json()[5]['email'][0]}                   ${EMAIL_id0} 
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}

    # Should Be Equal As Strings  ${resp.json()[5]['sms'][0]}  ${PUSERPH0}  
    # Should Be Equal As Strings  ${resp.json()[5]['email'][0]}  ${EMAIL_id0} 
    # Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]}  ${PUSERPH0}


    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[2]}  ${EventType[9]}  ${EMPTY_List}  ${PUser_EMAIL_list2}  ${PushMSG_Num_list2}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[5]['resourceType']}  ${NotificationResourceType[2]}
    Should Be Equal As Strings  ${resp.json()[5]['eventType']}  ${EventType[9]}
    Should Be Equal As Strings  ${resp.json()[5]['sms']}                        ${EMPTY_List} 
    Should Be Equal As Strings  ${resp.json()[5]['email'][0]}                   ${PUser_EMAIL2} 
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]['countryCode']}  ${countryCode_CC1}

    # Should Be Equal As Strings  ${resp.json()[5]['sms']}  ${EMPTY_List}  
    # Should Be Equal As Strings  ${resp.json()[5]['email'][0]}  ${PUser_EMAIL2} 
    # Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]}  ${PUSERPH0}
     

JD-TC-GetProviderNotificationSettings-27
     
    [Documentation]  Update Provider LICENSE Related Notification  Settings using Email id as EMPTY
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    # Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pid0}  ${resp.json()['id']}
    # Set Suite Variable  ${pid0}  ${resp.json()['id']}

    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[5]['resourceType']}  ${NotificationResourceType[2]}
    Should Be Equal As Strings  ${resp.json()[5]['eventType']}  ${EventType[9]}
    Should Be Equal As Strings  ${resp.json()[5]['sms']}                        ${EMPTY_List} 
    Should Be Equal As Strings  ${resp.json()[5]['email'][0]}                   ${PUser_EMAIL2} 
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]['countryCode']}  ${countryCode_CC1}

    # Should Be Equal As Strings  ${resp.json()[5]['sms']}  ${EMPTY_List}  
    # Should Be Equal As Strings  ${resp.json()[5]['email'][0]}  ${PUser_EMAIL2} 
    # Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]}  ${PUSERPH0}


    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[2]}  ${EventType[9]}  ${SMS_Num_list2}  ${EMPTY_List}  ${PushMSG_Num_list2}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[5]['resourceType']}  ${NotificationResourceType[2]}
    Should Be Equal As Strings  ${resp.json()[5]['eventType']}  ${EventType[9]}
    Should Be Equal As Strings  ${resp.json()[5]['sms'][0]['number']}           ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[5]['sms'][0]['countryCode']}      ${countryCode_CC1} 
    Should Be Equal As Strings  ${resp.json()[5]['email']}                      ${EMPTY_List} 
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]['countryCode']}  ${countryCode_CC1}

    # Should Be Equal As Strings  ${resp.json()[5]['sms'][0]}  ${PUSERNAME_U2}  
    # Should Be Equal As Strings  ${resp.json()[5]['email']}  ${EMPTY_List} 
    # Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]}  ${PUSERPH0}
     

JD-TC-GetProviderNotificationSettings-28
    [Documentation]  Update Provider LICENSE Related Notification  Settings using PushMsg number as EMPTY 
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    # Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pid0}  ${resp.json()['id']}
    # Set Suite Variable  ${pid0}  ${resp.json()['id']}

    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[5]['resourceType']}  ${NotificationResourceType[2]}
    Should Be Equal As Strings  ${resp.json()[5]['eventType']}  ${EventType[9]}
    Should Be Equal As Strings  ${resp.json()[5]['sms'][0]['number']}           ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[5]['sms'][0]['countryCode']}      ${countryCode_CC1} 
    Should Be Equal As Strings  ${resp.json()[5]['email']}                      ${EMPTY_List} 
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]['countryCode']}  ${countryCode_CC1}

    # Should Be Equal As Strings  ${resp.json()[5]['sms'][0]}  ${PUSERNAME_U2}  
    # Should Be Equal As Strings  ${resp.json()[5]['email']}  ${EMPTY_List} 
    # Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]}  ${PUSERPH0}

   
    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[2]}  ${EventType[9]}  ${SMS_Num_list2}  ${PUser_EMAIL_list2}  ${EMPTY_List}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[5]['resourceType']}  ${NotificationResourceType[2]}
    Should Be Equal As Strings  ${resp.json()[5]['eventType']}  ${EventType[9]}
    Should Be Equal As Strings  ${resp.json()[5]['sms'][0]['number']}           ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[5]['sms'][0]['countryCode']}      ${countryCode_CC1} 
    Should Be Equal As Strings  ${resp.json()[5]['email'][0]}                   ${PUser_EMAIL2} 
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg']}                    ${EMPTY_List}

    # Should Be Equal As Strings  ${resp.json()[5]['sms'][0]}  ${PUSERNAME_U2}  
    # Should Be Equal As Strings  ${resp.json()[5]['email'][0]}  ${PUser_EMAIL2} 
    # Should Be Equal As Strings  ${resp.json()[5]['pushMsg']}  ${EMPTY_List}
     

JD-TC-GetProviderNotificationSettings-29
    [Documentation]  Update Provider LICENSE Related Notification  Settings using SMS,Email,PushMsg details as EMPTY
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    # Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pid0}  ${resp.json()['id']}
    # Set Suite Variable  ${pid0}  ${resp.json()['id']}

    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[5]['resourceType']}  ${NotificationResourceType[2]}
    Should Be Equal As Strings  ${resp.json()[5]['eventType']}  ${EventType[9]}
    Should Be Equal As Strings  ${resp.json()[5]['sms'][0]['number']}           ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[5]['sms'][0]['countryCode']}      ${countryCode_CC1} 
    Should Be Equal As Strings  ${resp.json()[5]['email'][0]}                   ${PUser_EMAIL2} 
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg']}                    ${EMPTY_List}

    # Should Be Equal As Strings  ${resp.json()[5]['sms'][0]}  ${PUSERNAME_U2}  
    # Should Be Equal As Strings  ${resp.json()[5]['email'][0]}  ${PUser_EMAIL2} 
    # Should Be Equal As Strings  ${resp.json()[5]['pushMsg']}  ${EMPTY_List}

   
    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[2]}  ${EventType[9]}  ${EMPTY_List}  ${EMPTY_List}  ${EMPTY_List}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[5]['resourceType']}  ${NotificationResourceType[2]}
    Should Be Equal As Strings  ${resp.json()[5]['eventType']}  ${EventType[9]}
    Should Be Equal As Strings  ${resp.json()[5]['sms']}  ${EMPTY_List}  
    Should Be Equal As Strings  ${resp.json()[5]['email']}  ${EMPTY_List} 
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg']}  ${EMPTY_List}


JD-TC-GetProviderNotificationSettings-30
    [Documentation]  Update Provider LICENSE Related Notification  Settings when previous "SMS,EMAIL and PushMsg" details were EMPTY 
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    # Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pid0}  ${resp.json()['id']}
    # Set Suite Variable  ${pid0}  ${resp.json()['id']}

    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[5]['resourceType']}  ${NotificationResourceType[2]}
    Should Be Equal As Strings  ${resp.json()[5]['eventType']}  ${EventType[9]}
    Should Be Equal As Strings  ${resp.json()[5]['sms']}  ${EMPTY_List}  
    Should Be Equal As Strings  ${resp.json()[5]['email']}  ${EMPTY_List} 
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg']}  ${EMPTY_List}

   
    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[2]}  ${EventType[9]}  ${SMS_Num_list2}  ${PUser_EMAIL_list2}  ${PushMSG_Num_list2}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[5]['resourceType']}  ${NotificationResourceType[2]}
    Should Be Equal As Strings  ${resp.json()[5]['eventType']}  ${EventType[9]}
    Should Be Equal As Strings  ${resp.json()[5]['sms'][0]['number']}           ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[5]['sms'][0]['countryCode']}      ${countryCode_CC1}
    Should Be Equal As Strings  ${resp.json()[5]['email'][0]}                   ${PUser_EMAIL2} 
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]['countryCode']}  ${countryCode_CC1}

    # Should Be Equal As Strings  ${resp.json()[5]['sms'][0]}  ${PUSERNAME_U2}  
    # Should Be Equal As Strings  ${resp.json()[5]['email'][0]}  ${PUser_EMAIL2} 
    # Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]}  ${PUSERPH0}


JD-TC-GetProviderNotificationSettings-31
    [Documentation]  Update Provider LICENSE Related Notification  Settings, when we have TWO 'SMS' Numbers and REMOVE ONE Number 
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    # ${Phone_Num1}=  Evaluate  ${PUSERNAME}+3349578
    # Set Suite Variable  ${Phone_Num1} 
    # ${Phone_Num2}=  Evaluate  ${PUSERNAME}+2249578
    # Set Suite Variable  ${Phone_Num2} 
    # ${SMS_TwoNum_list}=  create List  ${Phone_Num1}  ${Phone_Num2}
    # Set Suite Variable  @{SMS_TwoNum_list}
    # Set Suite Variable  @{SMS_OneNum_list}   ${Phone_Num1}


    # Set Suite Variable  ${EMAIL1}   ${P_Email}${Phone_Num1}.${test_mail}
    # Set Suite Variable  ${EMAIL2}   ${P_Email}${Phone_Num2}.${test_mail}
    # ${TwoEMAIL_list}=  create List  ${EMAIL1}  ${EMAIL2}
    # Set Suite Variable  @{TwoEMAIL_list}
    # Set Suite Variable  @{OneEMAIL_list}   ${EMAIL1}

    # Set Suite Variable  @{PushMSG_Num_list}   ${PUSERPH0}
    # ${PushMSG_Num_list}=  create List  ${PUSERPH0}

   
    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[2]}  ${EventType[9]}  ${SMS_TwoNum_list}  ${TwoEMAIL_list}  ${PushMSG_Num_list}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[5]['resourceType']}  ${NotificationResourceType[2]}
    Should Be Equal As Strings  ${resp.json()[5]['eventType']}  ${EventType[9]}
    Should Be Equal As Strings  ${resp.json()[5]['sms'][0]['number']}           ${Phone_Num1} 
    Should Be Equal As Strings  ${resp.json()[5]['sms'][0]['countryCode']}      ${countryCode_CC1} 
    Should Be Equal As Strings  ${resp.json()[5]['sms'][1]['number']}           ${Phone_Num2} 
    Should Be Equal As Strings  ${resp.json()[5]['sms'][1]['countryCode']}      ${countryCode_CC1} 
    Should Be Equal As Strings  ${resp.json()[5]['email'][0]}                   ${EMAIL1}
    Should Be Equal As Strings  ${resp.json()[5]['email'][1]}                   ${EMAIL2}  
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]['countryCode']}  ${countryCode_CC1}

    # Should Be Equal As Strings  ${resp.json()[5]['sms'][0]}  ${Phone_Num1}
    # Should Be Equal As Strings  ${resp.json()[5]['sms'][1]}  ${Phone_Num2}  
    # Should Be Equal As Strings  ${resp.json()[5]['email'][0]}  ${EMAIL1}
    # Should Be Equal As Strings  ${resp.json()[5]['email'][1]}  ${EMAIL2} 
    # Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]}  ${PUSERPH0}


    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[2]}  ${EventType[9]}  ${SMS_OneNum_list}  ${OneEMAIL_list}  ${PushMSG_Num_list}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[5]['resourceType']}  ${NotificationResourceType[2]}
    Should Be Equal As Strings  ${resp.json()[5]['eventType']}  ${EventType[9]}
    Should Be Equal As Strings  ${resp.json()[5]['sms'][0]['number']}           ${Phone_Num1} 
    Should Be Equal As Strings  ${resp.json()[5]['sms'][0]['countryCode']}      ${countryCode_CC1} 
    Should Be Equal As Strings  ${resp.json()[5]['email'][0]}                   ${EMAIL1} 
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]['countryCode']}  ${countryCode_CC1}

    # Should Be Equal As Strings  ${resp.json()[5]['sms'][0]}  ${Phone_Num1} 
    # Should Be Equal As Strings  ${resp.json()[5]['email'][0]}  ${EMAIL1}
    # Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]}  ${PUSERPH0}


JD-TC-GetProviderNotificationSettings-32
    [Documentation]  Update Provider DONATION Related Notification  Settings using SMS number as EMPTY 
   
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    # Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pid0}  ${resp.json()['id']}
    # Set Suite Variable  ${pid0}  ${resp.json()['id']}

    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[4]['resourceType']}  ${NotificationResourceType[3]}
    Should Be Equal As Strings  ${resp.json()[4]['eventType']}  ${EventType[10]}
    Should Be Equal As Strings  ${resp.json()[4]['sms'][0]['number']}           ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[4]['sms'][0]['countryCode']}      ${countryCode_CC0} 
    Should Be Equal As Strings  ${resp.json()[4]['email'][0]}                   ${EMAIL_id0} 
    Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}

    # Should Be Equal As Strings  ${resp.json()[4]['sms'][0]}  ${PUSERPH0}  
    # Should Be Equal As Strings  ${resp.json()[4]['email'][0]}  ${EMAIL_id0} 
    # Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]}  ${PUSERPH0}


    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[3]}  ${EventType[10]}  ${EMPTY_List}  ${PUser_EMAIL_list2}  ${PushMSG_Num_list2}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[4]['resourceType']}  ${NotificationResourceType[3]}
    Should Be Equal As Strings  ${resp.json()[4]['eventType']}  ${EventType[10]}
    Should Be Equal As Strings  ${resp.json()[4]['sms']}                        ${EMPTY_List} 
    Should Be Equal As Strings  ${resp.json()[4]['email'][0]}                   ${PUser_EMAIL2} 
    Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]['countryCode']}  ${countryCode_CC1}

    # Should Be Equal As Strings  ${resp.json()[4]['sms']}  ${EMPTY_List}  
    # Should Be Equal As Strings  ${resp.json()[4]['email'][0]}  ${PUser_EMAIL2} 
    # Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]}  ${PUSERPH0}
     

JD-TC-GetProviderNotificationSettings-33
     
    [Documentation]  Update Provider DONATION Related Notification  Settings using Email id as EMPTY
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    # Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pid0}  ${resp.json()['id']}
    # Set Suite Variable  ${pid0}  ${resp.json()['id']}

    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[4]['resourceType']}  ${NotificationResourceType[3]}
    Should Be Equal As Strings  ${resp.json()[4]['eventType']}  ${EventType[10]}
    Should Be Equal As Strings  ${resp.json()[4]['sms']}                        ${EMPTY_List} 
    Should Be Equal As Strings  ${resp.json()[4]['email'][0]}                   ${PUser_EMAIL2} 
    Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]['countryCode']}  ${countryCode_CC1}

    # Should Be Equal As Strings  ${resp.json()[4]['sms']}  ${EMPTY_List}  
    # Should Be Equal As Strings  ${resp.json()[4]['email'][0]}  ${PUser_EMAIL2} 
    # Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]}  ${PUSERPH0}


    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[3]}  ${EventType[10]}  ${SMS_Num_list2}  ${EMPTY_List}  ${PushMSG_Num_list2}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[4]['resourceType']}  ${NotificationResourceType[3]}
    Should Be Equal As Strings  ${resp.json()[4]['eventType']}  ${EventType[10]}
    Should Be Equal As Strings  ${resp.json()[4]['sms'][0]['number']}           ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[4]['sms'][0]['countryCode']}      ${countryCode_CC1} 
    Should Be Equal As Strings  ${resp.json()[4]['email']}                      ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]['countryCode']}  ${countryCode_CC1}

    # Should Be Equal As Strings  ${resp.json()[4]['sms'][0]}  ${PUSERNAME_U2}  
    # Should Be Equal As Strings  ${resp.json()[4]['email']}  ${EMPTY_List} 
    # Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]}  ${PUSERPH0}
     

JD-TC-GetProviderNotificationSettings-34
    [Documentation]  Update Provider DONATION Related Notification  Settings using PushMsg number as EMPTY 
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    # Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pid0}  ${resp.json()['id']}
    # Set Suite Variable  ${pid0}  ${resp.json()['id']}

    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[4]['resourceType']}  ${NotificationResourceType[3]}
    Should Be Equal As Strings  ${resp.json()[4]['eventType']}  ${EventType[10]}
    Should Be Equal As Strings  ${resp.json()[4]['sms'][0]['number']}           ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[4]['sms'][0]['countryCode']}      ${countryCode_CC1} 
    Should Be Equal As Strings  ${resp.json()[4]['email']}                      ${EMPTY_List}  
    Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]['countryCode']}  ${countryCode_CC1}

    # Should Be Equal As Strings  ${resp.json()[4]['sms'][0]}  ${PUSERNAME_U2}  
    # Should Be Equal As Strings  ${resp.json()[4]['email']}  ${EMPTY_List} 
    # Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]}  ${PUSERPH0}

   
    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[3]}  ${EventType[10]}  ${SMS_Num_list2}  ${PUser_EMAIL_list2}  ${EMPTY_List}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[4]['resourceType']}  ${NotificationResourceType[3]}
    Should Be Equal As Strings  ${resp.json()[4]['eventType']}  ${EventType[10]}
    Should Be Equal As Strings  ${resp.json()[4]['sms'][0]['number']}           ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[4]['sms'][0]['countryCode']}      ${countryCode_CC1} 
    Should Be Equal As Strings  ${resp.json()[4]['email'][0]}                   ${PUser_EMAIL2} 
    Should Be Equal As Strings  ${resp.json()[4]['pushMsg']}                    ${EMPTY_List}

    # Should Be Equal As Strings  ${resp.json()[4]['sms'][0]}  ${PUSERNAME_U2}  
    # Should Be Equal As Strings  ${resp.json()[4]['email'][0]}  ${PUser_EMAIL2} 
    # Should Be Equal As Strings  ${resp.json()[4]['pushMsg']}  ${EMPTY_List}
     

JD-TC-GetProviderNotificationSettings-35
    [Documentation]  Update Provider DONATION Related Notification  Settings using SMS,Email,PushMsg details as EMPTY
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    # Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pid0}  ${resp.json()['id']}
    # Set Suite Variable  ${pid0}  ${resp.json()['id']}

    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[4]['resourceType']}  ${NotificationResourceType[3]}
    Should Be Equal As Strings  ${resp.json()[4]['eventType']}  ${EventType[10]}
    Should Be Equal As Strings  ${resp.json()[4]['sms'][0]['number']}           ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[4]['sms'][0]['countryCode']}      ${countryCode_CC1} 
    Should Be Equal As Strings  ${resp.json()[4]['email'][0]}                   ${PUser_EMAIL2} 
    Should Be Equal As Strings  ${resp.json()[4]['pushMsg']}                    ${EMPTY_List}

    # Should Be Equal As Strings  ${resp.json()[4]['sms'][0]}  ${PUSERNAME_U2}  
    # Should Be Equal As Strings  ${resp.json()[4]['email'][0]}  ${PUser_EMAIL2} 
    # Should Be Equal As Strings  ${resp.json()[4]['pushMsg']}  ${EMPTY_List}

   
    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[3]}  ${EventType[10]}  ${EMPTY_List}  ${EMPTY_List}  ${EMPTY_List}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[4]['resourceType']}  ${NotificationResourceType[3]}
    Should Be Equal As Strings  ${resp.json()[4]['eventType']}  ${EventType[10]}
    Should Be Equal As Strings  ${resp.json()[4]['sms']}  ${EMPTY_List}  
    Should Be Equal As Strings  ${resp.json()[4]['email']}  ${EMPTY_List} 
    Should Be Equal As Strings  ${resp.json()[4]['pushMsg']}  ${EMPTY_List}


JD-TC-GetProviderNotificationSettings-36
    [Documentation]  Update Provider DONATION Related Notification  Settings when previous "SMS,EMAIL and PushMsg" details were EMPTY 
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    # Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pid0}  ${resp.json()['id']}
    # Set Suite Variable  ${pid0}  ${resp.json()['id']}

    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[4]['resourceType']}  ${NotificationResourceType[3]}
    Should Be Equal As Strings  ${resp.json()[4]['eventType']}  ${EventType[10]}
    Should Be Equal As Strings  ${resp.json()[4]['sms']}  ${EMPTY_List}  
    Should Be Equal As Strings  ${resp.json()[4]['email']}  ${EMPTY_List} 
    Should Be Equal As Strings  ${resp.json()[4]['pushMsg']}  ${EMPTY_List}

   
    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[3]}  ${EventType[10]}  ${SMS_Num_list2}  ${PUser_EMAIL_list2}  ${PushMSG_Num_list2}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[4]['resourceType']}  ${NotificationResourceType[3]}
    Should Be Equal As Strings  ${resp.json()[4]['eventType']}  ${EventType[10]}
    Should Be Equal As Strings  ${resp.json()[4]['sms'][0]['number']}           ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[4]['sms'][0]['countryCode']}      ${countryCode_CC1} 
    Should Be Equal As Strings  ${resp.json()[4]['email'][0]}                   ${PUser_EMAIL2} 
    Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]['countryCode']}  ${countryCode_CC1}

    # Should Be Equal As Strings  ${resp.json()[4]['sms'][0]}  ${PUSERNAME_U2}  
    # Should Be Equal As Strings  ${resp.json()[4]['email'][0]}  ${PUser_EMAIL2} 
    # Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]}  ${PUSERPH0}


JD-TC-GetProviderNotificationSettings-UH1
    [Documentation]  Get Provider Notification  Settings,  Without Login
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"



JD-TC-GetProviderNotificationSettings-UH2
    [Documentation]  Get Provider Notification  Settings, with consumer login
    ${resp}=  Consumer Login  ${CUSERNAME0}  ${PASSWORD}
    Log  ${resp.json()}
    Log  ${resp.status_code}
    Should Be Equal As Strings  ${resp.status_code}  200

   
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"

