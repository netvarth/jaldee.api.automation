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

   




*** Test Case ***

JD-TC-UpdateProviderNotificationSettings-1
    [Documentation]  Getting Provider Notification  Settings without Update Provider Notification Settings

    ${PUSERPH0}=  Evaluate  ${PUSERNAME}+5794518
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

    ${resp}=   ProviderLogin  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    Set Suite Variable  ${countryCode_CC0}    ${countryCodes[0]}
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${EventType[0]}  
    Should Be Equal As Strings  ${resp.json()[0]['email'][0]}  ${EMAIL_id0}
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['number']}           ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['countryCode']}  ${countryCode_CC0} 
    # Should Be Equal As Strings  ${resp.json()[0]['sms'][0]}  ${PUSERPH0}
    # Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]}  ${PUSERPH0} 

    Should Be Equal As Strings  ${resp.json()[1]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['eventType']}  ${EventType[1]}  
    Should Be Equal As Strings  ${resp.json()[1]['email'][0]}  ${EMAIL_id0} 
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['number']}           ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[1]['sms'][0]}  ${PUSERPH0}
    # Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]}  ${PUSERPH0}

    Should Be Equal As Strings  ${resp.json()[2]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[2]['eventType']}  ${EventType[7]}  
    Should Be Equal As Strings  ${resp.json()[2]['email'][0]}  ${EMAIL_id0}
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['number']}           ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[2]['sms'][0]}  ${PUSERPH0} 
    # Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]}  ${PUSERPH0}

    Should Be Equal As Strings  ${resp.json()[3]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[3]['eventType']}  ${EventType[8]}  
    Should Be Equal As Strings  ${resp.json()[3]['email'][0]}  ${EMAIL_id0}
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['number']}           ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[3]['sms'][0]}  ${PUSERPH0} 
    # Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]}  ${PUSERPH0}

    Should Be Equal As Strings  ${resp.json()[4]['resourceType']}  ${NotificationResourceType[3]}
    Should Be Equal As Strings  ${resp.json()[4]['eventType']}     ${EventType[10]}
    Should Be Equal As Strings  ${resp.json()[4]['email'][0]}      ${EMAIL_id0}
    Should Be Equal As Strings  ${resp.json()[4]['sms'][0]['number']}           ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[4]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]['countryCode']}  ${countryCode_CC0} 
    # Should Be Equal As Strings  ${resp.json()[4]['sms'][0]}        ${PUSERPH0}
    # Should Be Equal As Strings  ${resp.json()[4]['pushMsg'][0]}    ${PUSERPH0}
    
    Should Be Equal As Strings  ${resp.json()[5]['resourceType']}  ${NotificationResourceType[2]}
    Should Be Equal As Strings  ${resp.json()[5]['eventType']}     ${EventType[9]}
    Should Be Equal As Strings  ${resp.json()[5]['email'][0]}      ${EMAIL_id0}
    Should Be Equal As Strings  ${resp.json()[5]['sms'][0]['number']}           ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[5]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]['countryCode']}  ${countryCode_CC0} 
    # Should Be Equal As Strings  ${resp.json()[5]['sms'][0]}        ${PUSERPH0}
    # Should Be Equal As Strings  ${resp.json()[5]['pushMsg'][0]}    ${PUSERPH0}


JD-TC-UpdateProviderNotificationSettings-2
    [Documentation]  Update Provider Notification  Settings For WAITLISTADD using SMS number as EMPTY 
   
    ${resp}=   ProviderLogin  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${pid0}  ${resp.json()['id']}

    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${EventType[0]}  
    Should Be Equal As Strings  ${resp.json()[0]['email'][0]}  ${EMAIL_id0}
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['number']}           ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[0]['sms'][0]}  ${PUSERPH0} 
    # Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]}  ${PUSERPH0}



    ${PUSERNAME_U2}=  Evaluate  ${PUSERNAME}+7149539
    Set Suite Variable  ${PUSERNAME_U2}  
    # Set Suite Variable  @{SMS_Num_list2}   ${PUSERNAME_U2}

    

    # Set Suite Variable  @{PushMSG_Num_list2}   ${PUSERPH0}

   
    ${MSG_Ph1}=  Create Dictionary   number=${PUSERNAME_U2}   countryCode=${countryCode_CC0}
    Set Suite Variable  @{SMS_Num_list2}    ${MSG_Ph1}  
    ${PushMSG}=  Create Dictionary   number=${PUSERPH0}   countryCode=${countryCode_CC0}
    Set Suite Variable  @{PushMSG_Num_list2}    ${PushMSG} 
    Set Suite Variable  ${PUser_EMAIL2}   ${P_Email}${PUSERNAME_U2}.${test_mail}
    Set Suite Variable  @{PUser_EMAIL_list2}   ${PUser_EMAIL2}

    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[0]}  ${EventType[0]}  ${EMPTY_List}  ${PUser_EMAIL_list2}  ${PushMSG_Num_list2}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${EventType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['email'][0]}   ${PUser_EMAIL2}
    Should Be Equal As Strings  ${resp.json()[0]['sms']}        ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[0]['sms']}  ${EMPTY_List}   
    # Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]}  ${PUSERPH0}
     
     


JD-TC-UpdateProviderNotificationSettings-3
     
    [Documentation]  Update Provider Notification  Settings For WAITLISTADD using Email id as EMPTY
    ${resp}=   ProviderLogin  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    

    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${EventType[0]} 
    Should Be Equal As Strings  ${resp.json()[0]['email'][0]}   ${PUser_EMAIL2}
    Should Be Equal As Strings  ${resp.json()[0]['sms']}        ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[0]['sms']}  ${EMPTY_List}  
    # Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]}  ${PUSERPH0}



    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[0]}  ${EventType[0]}  ${SMS_Num_list2}  ${EMPTY_List}  ${PushMSG_Num_list2}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${EventType[0]} 
    Should Be Equal As Strings  ${resp.json()[0]['email']}  ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['number']}           ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[0]['sms'][0]}  ${PUSERNAME_U2}  
    # Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]}  ${PUSERPH0}
     

JD-TC-UpdateProviderNotificationSettings-4
    [Documentation]  Update Provider Notification  Settings For WAITLISTADD using PushMsg number as EMPTY 
    ${resp}=   ProviderLogin  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    

    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${EventType[0]}  
    Should Be Equal As Strings  ${resp.json()[0]['email']}  ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['number']}           ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['countryCode']}  ${countryCode_CC0} 
    # Should Be Equal As Strings  ${resp.json()[0]['sms'][0]}  ${PUSERNAME_U2}
    # Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]}  ${PUSERPH0}


   
    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[0]}  ${EventType[0]}  ${SMS_Num_list2}  ${PUser_EMAIL_list2}  ${EMPTY_List}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${EventType[0]}  
    Should Be Equal As Strings  ${resp.json()[0]['email'][0]}  ${PUser_EMAIL2}
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['number']}           ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg']}                    ${EMPTY_List} 
    # Should Be Equal As Strings  ${resp.json()[0]['sms'][0]}  ${PUSERNAME_U2}
    # Should Be Equal As Strings  ${resp.json()[0]['pushMsg']}  ${EMPTY_List}
     




JD-TC-UpdateProviderNotificationSettings-5
    [Documentation]  Update Provider Notification  Settings For WAITLISTADD  using SMS,Email,PushMsg details as EMPTY
    ${resp}=   ProviderLogin  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    

    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${EventType[0]} 
    Should Be Equal As Strings  ${resp.json()[0]['email'][0]}  ${PUser_EMAIL2}
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['number']}           ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg']}                    ${EMPTY_List}
    # Should Be Equal As Strings  ${resp.json()[0]['sms'][0]}  ${PUSERNAME_U2}  
    # Should Be Equal As Strings  ${resp.json()[0]['pushMsg']}  ${EMPTY_List}



   
    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[0]}  ${EventType[0]}  ${EMPTY_List}  ${EMPTY_List}  ${EMPTY_List}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${EventType[0]}  
    Should Be Equal As Strings  ${resp.json()[0]['email']}  ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()[0]['sms']}  ${EMPTY_List} 
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg']}  ${EMPTY_List}
    # Should Be Equal As Strings  ${resp.json()[0]['sms']}  ${EMPTY_List} 
    # Should Be Equal As Strings  ${resp.json()[0]['pushMsg']}  ${EMPTY_List}






JD-TC-UpdateProviderNotificationSettings-6
    [Documentation]  Update Provider Notification  Settings For WAITLISTADD when previous "SMS,EMAIL and PushMsg" details were EMPTY 
    ${resp}=   ProviderLogin  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    

    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${EventType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['email']}  ${EMPTY_List} 
    Should Be Equal As Strings  ${resp.json()[0]['sms']}  ${EMPTY_List} 
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg']}  ${EMPTY_List}
    # Should Be Equal As Strings  ${resp.json()[0]['sms']}  ${EMPTY_List} 
    # Should Be Equal As Strings  ${resp.json()[0]['pushMsg']}  ${EMPTY_List}


   
    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[0]}  ${EventType[0]}  ${SMS_Num_list2}  ${PUser_EMAIL_list2}  ${PushMSG_Num_list2}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${EventType[0]}  
    Should Be Equal As Strings  ${resp.json()[0]['email'][0]}  ${PUser_EMAIL2}
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['number']}           ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[0]['sms'][0]}  ${PUSERNAME_U2} 
    # Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]}  ${PUSERPH0}




# ###################################################################################




JD-TC-UpdateProviderNotificationSettings-7
    [Documentation]  Update Provider Notification  Settings For WAITLISTCANCEL using SMS number as EMPTY 
   
    ${resp}=   ProviderLogin  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    

    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[1]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['eventType']}  ${EventType[1]} 
    Should Be Equal As Strings  ${resp.json()[1]['email'][0]}  ${EMAIL_id0}
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['number']}           ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[1]['sms'][0]}  ${PUSERPH0}  
    # Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]}  ${PUSERPH0}



    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[0]}  ${EventType[1]}  ${EMPTY_List}  ${PUser_EMAIL_list2}  ${PushMSG_Num_list2}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[1]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['eventType']}  ${EventType[1]} 
    Should Be Equal As Strings  ${resp.json()[1]['email'][0]}   ${PUser_EMAIL2}
    Should Be Equal As Strings  ${resp.json()[1]['sms']}        ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[1]['sms']}  ${EMPTY_List}  
    # Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]}  ${PUSERPH0}
     
     


JD-TC-UpdateProviderNotificationSettings-8
     
    [Documentation]  Update Provider Notification  Settings For WAITLISTCANCEL using Email id as EMPTY
    ${resp}=   ProviderLogin  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    

    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[1]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['eventType']}  ${EventType[1]}  
    Should Be Equal As Strings  ${resp.json()[1]['email'][0]}   ${PUser_EMAIL2}
    Should Be Equal As Strings  ${resp.json()[1]['sms']}        ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['countryCode']}  ${countryCode_CC0} 
    # Should Be Equal As Strings  ${resp.json()[1]['sms']}  ${EMPTY_List}
    # Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]}  ${PUSERPH0}



    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[0]}  ${EventType[1]}  ${SMS_Num_list2}  ${EMPTY_List}  ${PushMSG_Num_list2}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[1]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['eventType']}  ${EventType[1]}  
    Should Be Equal As Strings  ${resp.json()[1]['email']}  ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['number']}           ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[1]['sms'][0]}  ${PUSERNAME_U2} 
    # Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]}  ${PUSERPH0}
     

JD-TC-UpdateProviderNotificationSettings-9
    [Documentation]  Update Provider Notification  Settings For WAITLISTCANCEL using PushMsg number as EMPTY 
    ${resp}=   ProviderLogin  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    

    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[1]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['eventType']}  ${EventType[1]} 
    Should Be Equal As Strings  ${resp.json()[1]['email']}  ${EMPTY_List} 
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['number']}           ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[1]['sms'][0]}  ${PUSERNAME_U2} 
    # Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]}  ${PUSERPH0}

 
    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[0]}  ${EventType[1]}  ${SMS_Num_list2}  ${PUser_EMAIL_list2}  ${EMPTY_List}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[1]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['eventType']}  ${EventType[1]}  
    Should Be Equal As Strings  ${resp.json()[1]['email'][0]}  ${PUser_EMAIL2}
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['number']}           ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg']}                    ${EMPTY_List}
    # Should Be Equal As Strings  ${resp.json()[1]['sms'][0]}  ${PUSERNAME_U2} 
    # Should Be Equal As Strings  ${resp.json()[1]['pushMsg']}  ${EMPTY_List}
     




JD-TC-UpdateProviderNotificationSettings-10
    [Documentation]  Update Provider Notification  Settings For WAITLISTCANCEL  using SMS,Email,PushMsg details as EMPTY
    ${resp}=   ProviderLogin  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    

    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[1]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['eventType']}  ${EventType[1]}  
    Should Be Equal As Strings  ${resp.json()[1]['email'][0]}  ${PUser_EMAIL2}
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['number']}           ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg']}                    ${EMPTY_List}
    # Should Be Equal As Strings  ${resp.json()[1]['sms'][0]}  ${PUSERNAME_U2} 
    # Should Be Equal As Strings  ${resp.json()[1]['pushMsg']}  ${EMPTY_List}

 
    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[0]}  ${EventType[1]}  ${EMPTY_List}  ${EMPTY_List}  ${EMPTY_List}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[1]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['eventType']}  ${EventType[1]}  
    Should Be Equal As Strings  ${resp.json()[1]['email']}  ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()[1]['sms']}  ${EMPTY_List} 
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg']}  ${EMPTY_List}
    # Should Be Equal As Strings  ${resp.json()[1]['sms']}  ${EMPTY_List} 
    # Should Be Equal As Strings  ${resp.json()[1]['pushMsg']}  ${EMPTY_List}






JD-TC-UpdateProviderNotificationSettings-11
    [Documentation]  Update Provider Notification  Settings For WAITLISTCANCEL when previous "SMS,EMAIL and PushMsg" details were EMPTY 
    ${resp}=   ProviderLogin  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    

    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[1]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['eventType']}  ${EventType[1]} 
    Should Be Equal As Strings  ${resp.json()[1]['email']}  ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()[1]['sms']}  ${EMPTY_List} 
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg']}  ${EMPTY_List}
    # Should Be Equal As Strings  ${resp.json()[1]['sms']}  ${EMPTY_List}  
    # Should Be Equal As Strings  ${resp.json()[1]['pushMsg']}  ${EMPTY_List}

   
    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[0]}  ${EventType[1]}  ${SMS_Num_list2}  ${PUser_EMAIL_list2}  ${PushMSG_Num_list2}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[1]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['eventType']}  ${EventType[1]} 
    Should Be Equal As Strings  ${resp.json()[1]['email'][0]}  ${PUser_EMAIL2}
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['number']}           ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['countryCode']}  ${countryCode_CC0} 
    # Should Be Equal As Strings  ${resp.json()[1]['sms'][0]}  ${PUSERNAME_U2} 
    # Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]}  ${PUSERPH0}




# ###################################################################################




JD-TC-UpdateProviderNotificationSettings-12
    [Documentation]  Update Provider Notification  Settings For APPOINTMENTADD using SMS number as EMPTY  
   
    ${resp}=   ProviderLogin  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    

    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[2]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[2]['eventType']}  ${EventType[7]}  
    Should Be Equal As Strings  ${resp.json()[2]['email'][0]}  ${EMAIL_id0} 
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['number']}           ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[2]['sms'][0]}  ${PUSERPH0}
    # Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]}  ${PUSERPH0}

   
    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[1]}  ${EventType[7]}  ${EMPTY_List}  ${PUser_EMAIL_list2}  ${PushMSG_Num_list2}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[2]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[2]['eventType']}  ${EventType[7]}
    Should Be Equal As Strings  ${resp.json()[2]['email'][0]}   ${PUser_EMAIL2} 
    Should Be Equal As Strings  ${resp.json()[2]['sms']}        ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[2]['sms']}  ${EMPTY_List}  
    # Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]}  ${PUSERPH0}
     
     


JD-TC-UpdateProviderNotificationSettings-13
     
    [Documentation]  Update Provider Notification  Settings For APPOINTMENTADD using Email id as EMPTY
    ${resp}=   ProviderLogin  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    

    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[2]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[2]['eventType']}  ${EventType[7]}
    Should Be Equal As Strings  ${resp.json()[2]['email'][0]}   ${PUser_EMAIL2}
    Should Be Equal As Strings  ${resp.json()[2]['sms']}        ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[2]['sms']}  ${EMPTY_List}   
    # Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]}  ${PUSERPH0}


    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[1]}  ${EventType[7]}  ${SMS_Num_list2}  ${EMPTY_List}  ${PushMSG_Num_list2}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[2]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[2]['eventType']}  ${EventType[7]} 
    Should Be Equal As Strings  ${resp.json()[2]['email']}  ${EMPTY_List} 
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['number']}           ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[2]['sms'][0]}  ${PUSERNAME_U2} 
    # Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]}  ${PUSERPH0}
     

JD-TC-UpdateProviderNotificationSettings-14
    [Documentation]  Update Provider Notification  Settings For APPOINTMENTADD using PushMsg number as EMPTY 
    ${resp}=   ProviderLogin  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    

    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[2]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[2]['eventType']}  ${EventType[7]}  
    Should Be Equal As Strings  ${resp.json()[2]['email']}  ${EMPTY_List} 
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['number']}           ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[2]['sms'][0]}  ${PUSERNAME_U2}
    # Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]}  ${PUSERPH0}

   
    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[1]}  ${EventType[7]}  ${SMS_Num_list2}  ${PUser_EMAIL_list2}  ${EMPTY_List}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[2]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[2]['eventType']}  ${EventType[7]}  
    Should Be Equal As Strings  ${resp.json()[2]['email'][0]}  ${PUser_EMAIL2} 
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['number']}           ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg']}                    ${EMPTY_List}
    # Should Be Equal As Strings  ${resp.json()[2]['sms'][0]}  ${PUSERNAME_U2}
    # Should Be Equal As Strings  ${resp.json()[2]['pushMsg']}  ${EMPTY_List}
     




JD-TC-UpdateProviderNotificationSettings-15
    [Documentation]  Update Provider Notification  Settings For APPOINTMENTADD  using SMS,Email,PushMsg details as EMPTY
    ${resp}=   ProviderLogin  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    

    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[2]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[2]['eventType']}  ${EventType[7]}  
    Should Be Equal As Strings  ${resp.json()[2]['email'][0]}  ${PUser_EMAIL2}
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['number']}           ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg']}                    ${EMPTY_List}
    # Should Be Equal As Strings  ${resp.json()[2]['sms'][0]}  ${PUSERNAME_U2} 
    # Should Be Equal As Strings  ${resp.json()[2]['pushMsg']}  ${EMPTY_List}


   
    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[1]}  ${EventType[7]}  ${EMPTY_List}  ${EMPTY_List}  ${EMPTY_List}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[2]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[2]['eventType']}  ${EventType[7]}  
    Should Be Equal As Strings  ${resp.json()[2]['email']}  ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()[2]['sms']}  ${EMPTY_List} 
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg']}  ${EMPTY_List}
    # Should Be Equal As Strings  ${resp.json()[2]['sms']}  ${EMPTY_List} 
    # Should Be Equal As Strings  ${resp.json()[2]['pushMsg']}  ${EMPTY_List}






JD-TC-UpdateProviderNotificationSettings-16
    [Documentation]  Update Provider Notification  Settings For APPOINTMENTADD when previous "SMS,EMAIL and PushMsg" details were EMPTY 
    ${resp}=   ProviderLogin  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    

    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[2]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[2]['eventType']}  ${EventType[7]}
    Should Be Equal As Strings  ${resp.json()[2]['email']}  ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()[2]['sms']}  ${EMPTY_List}  
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg']}  ${EMPTY_List}


   
    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[1]}  ${EventType[7]}  ${SMS_Num_list2}  ${PUser_EMAIL_list2}  ${PushMSG_Num_list2}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[2]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[2]['eventType']}  ${EventType[7]} 
    Should Be Equal As Strings  ${resp.json()[2]['email'][0]}  ${PUser_EMAIL2}
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['number']}           ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['countryCode']}  ${countryCode_CC0} 
    # Should Be Equal As Strings  ${resp.json()[2]['sms'][0]}  ${PUSERNAME_U2} 
    # Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]}  ${PUSERPH0}





# ####################################################################################



JD-TC-UpdateProviderNotificationSettings-17
    [Documentation]  Update Provider Notification  Settings For APPOINTMENTCANCEL using SMS number as EMPTY  
   
    ${resp}=   ProviderLogin  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    

    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[3]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[3]['eventType']}  ${EventType[8]}  
    Should Be Equal As Strings  ${resp.json()[3]['email'][0]}  ${EMAIL_id0}
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['number']}           ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['countryCode']}  ${countryCode_CC0} 
    # Should Be Equal As Strings  ${resp.json()[3]['sms'][0]}  ${PUSERPH0}
    # Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]}  ${PUSERPH0}

   
    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[1]}  ${EventType[8]}  ${EMPTY_List}  ${PUser_EMAIL_list2}  ${PushMSG_Num_list2}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[3]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[3]['eventType']}  ${EventType[8]}
    Should Be Equal As Strings  ${resp.json()[3]['email'][0]}   ${PUser_EMAIL2}
    Should Be Equal As Strings  ${resp.json()[3]['sms']}        ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[3]['sms']}  ${EMPTY_List}   
    # Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]}  ${PUSERPH0}
     
     


JD-TC-UpdateProviderNotificationSettings-18
     
    [Documentation]  Update Provider Notification  Settings For APPOINTMENTCANCEL using Email id as EMPTY
    ${resp}=   ProviderLogin  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    

    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[3]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[3]['eventType']}  ${EventType[8]} 
    Should Be Equal As Strings  ${resp.json()[3]['email'][0]}   ${PUser_EMAIL2}
    Should Be Equal As Strings  ${resp.json()[3]['sms']}        ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[3]['sms']}  ${EMPTY_List}  
    # Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]}  ${PUSERPH0}


   
    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[1]}  ${EventType[8]}  ${SMS_Num_list2}  ${EMPTY_List}  ${PushMSG_Num_list2}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[3]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[3]['eventType']}  ${EventType[8]}  
    Should Be Equal As Strings  ${resp.json()[3]['email']}  ${EMPTY_List} 
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['number']}           ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[3]['sms'][0]}  ${PUSERNAME_U2}
    # Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]}  ${PUSERPH0}
     

JD-TC-UpdateProviderNotificationSettings-19
    [Documentation]  Update Provider Notification  Settings For APPOINTMENTCANCEL using PushMsg number as EMPTY 
    ${resp}=   ProviderLogin  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    

    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[3]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[3]['eventType']}  ${EventType[8]}  
    Should Be Equal As Strings  ${resp.json()[3]['email']}  ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['number']}           ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[3]['sms'][0]}  ${PUSERNAME_U2} 
    # Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]}  ${PUSERPH0}


   
    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[1]}  ${EventType[8]}  ${SMS_Num_list2}  ${PUser_EMAIL_list2}  ${EMPTY_List}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[3]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[3]['eventType']}  ${EventType[8]} 
    Should Be Equal As Strings  ${resp.json()[3]['email'][0]}  ${PUser_EMAIL2}
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['number']}           ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg']}                    ${EMPTY_List}
    # Should Be Equal As Strings  ${resp.json()[3]['sms'][0]}  ${PUSERNAME_U2}  
    # Should Be Equal As Strings  ${resp.json()[3]['pushMsg']}  ${EMPTY_List}
    


JD-TC-UpdateProviderNotificationSettings-20
    [Documentation]  Update Provider Notification  Settings For APPOINTMENTCANCEL  using SMS,Email,PushMsg details as EMPTY
    ${resp}=   ProviderLogin  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    

    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[3]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[3]['eventType']}  ${EventType[8]}  
    Should Be Equal As Strings  ${resp.json()[3]['email'][0]}  ${PUser_EMAIL2} 
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['number']}           ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg']}                    ${EMPTY_List}
    # Should Be Equal As Strings  ${resp.json()[3]['sms'][0]}  ${PUSERNAME_U2}
    # Should Be Equal As Strings  ${resp.json()[3]['pushMsg']}  ${EMPTY_List}


   
    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[1]}  ${EventType[8]}  ${EMPTY_List}  ${EMPTY_List}  ${EMPTY_List}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[3]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[3]['eventType']}  ${EventType[8]} 
    Should Be Equal As Strings  ${resp.json()[3]['email']}  ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()[3]['sms']}  ${EMPTY_List}  
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg']}  ${EMPTY_List}
    # Should Be Equal As Strings  ${resp.json()[3]['sms']}  ${EMPTY_List}  
    # Should Be Equal As Strings  ${resp.json()[3]['pushMsg']}  ${EMPTY_List}






JD-TC-UpdateProviderNotificationSettings-21
    [Documentation]  Update Provider Notification  Settings For APPOINTMENTCANCEL when previous "SMS,EMAIL and PushMsg" details were EMPTY 
    ${resp}=   ProviderLogin  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
   

    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[3]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[3]['eventType']}  ${EventType[8]}  
    Should Be Equal As Strings  ${resp.json()[3]['email']}  ${EMPTY_List}
    Should Be Equal As Strings  ${resp.json()[3]['sms']}  ${EMPTY_List}  
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg']}  ${EMPTY_List}
    # Should Be Equal As Strings  ${resp.json()[3]['sms']}  ${EMPTY_List} 
    # Should Be Equal As Strings  ${resp.json()[3]['pushMsg']}  ${EMPTY_List}


   
    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[1]}  ${EventType[8]}  ${SMS_Num_list2}  ${PUser_EMAIL_list2}  ${PushMSG_Num_list2}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[3]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[3]['eventType']}  ${EventType[8]}  
    Should Be Equal As Strings  ${resp.json()[3]['email'][0]}  ${PUser_EMAIL2}
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['number']}           ${PUSERNAME_U2} 
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[3]['sms'][0]}  ${PUSERNAME_U2} 
    # Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]}  ${PUSERPH0}




# ###################################################################


JD-TC-UpdateProviderNotificationSettings-22
    [Documentation]  Update Provider Notification  Settings For 'WAITLISTADD', when we have TWO 'SMS' Numbers and REMOVE ONE Number 
    ${resp}=   ProviderLogin  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${Phone_Num1}=  Evaluate  ${PUSERNAME}+3349578
    Set Suite Variable  ${Phone_Num1} 
    ${MSG_Ph1}=  Create Dictionary   number=${Phone_Num1}   countryCode=${countryCode_CC0}
    Set Suite Variable  @{SMS_OneNum_list}   ${MSG_Ph1}
    ${Phone_Num2}=  Evaluate  ${PUSERNAME}+2249578
    Set Suite Variable  ${Phone_Num2}
    ${MSG_Ph2}=  Create Dictionary   number=${Phone_Num2}   countryCode=${countryCode_CC0}
    ${SMS_TwoNum_list}=  create List  ${MSG_Ph1}  ${MSG_Ph2}
    Set Suite Variable  @{SMS_TwoNum_list}

    Set Suite Variable  ${EMAIL1}   ${P_Email}${Phone_Num1}.${test_mail}
    Set Suite Variable  ${EMAIL2}   ${P_Email}${Phone_Num2}.${test_mail}
    ${TwoEMAIL_list}=  create List  ${EMAIL1}  ${EMAIL2}
    Set Suite Variable  @{TwoEMAIL_list}
    Set Suite Variable  @{OneEMAIL_list}   ${EMAIL1}

    ${PUSH_MSG_Ph1}=  Create Dictionary   number=${PUSERPH0}   countryCode=${countryCode_CC0}
    Set Suite Variable  @{PushMSG_Num_list}   ${PUSH_MSG_Ph1}


    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[0]}  ${EventType[0]}  ${SMS_TwoNum_list}  ${TwoEMAIL_list}  ${PushMSG_Num_list}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${EventType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['email'][0]}  ${EMAIL1}
    Should Be Equal As Strings  ${resp.json()[0]['email'][1]}  ${EMAIL2}
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['number']}           ${Phone_Num1} 
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[0]['sms'][1]['number']}           ${Phone_Num2} 
    Should Be Equal As Strings  ${resp.json()[0]['sms'][1]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['countryCode']}  ${countryCode_CC0} 
    # Should Be Equal As Strings  ${resp.json()[0]['sms'][0]}  ${Phone_Num1}
    # Should Be Equal As Strings  ${resp.json()[0]['sms'][1]}  ${Phone_Num2}
    # Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]}  ${PUSERPH0}


    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[0]}  ${EventType[0]}  ${SMS_OneNum_list}  ${OneEMAIL_list}  ${PushMSG_Num_list}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${EventType[0]} 
    Should Be Equal As Strings  ${resp.json()[0]['email'][0]}  ${EMAIL1}
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['number']}           ${Phone_Num1} 
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[0]['sms'][0]}  ${Phone_Num1}
    # Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]}  ${PUSERPH0}


JD-TC-UpdateProviderNotificationSettings-23
    [Documentation]  Update Provider Notification  Settings For 'WAITLISTCANCEL', when we have TWO 'SMS' Numbers and REMOVE ONE Number 
    ${resp}=   ProviderLogin  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
  

    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[0]}  ${EventType[1]}  ${SMS_TwoNum_list}  ${TwoEMAIL_list}  ${PushMSG_Num_list}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[1]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['eventType']}  ${EventType[1]} 
    Should Be Equal As Strings  ${resp.json()[1]['email'][0]}  ${EMAIL1}
    Should Be Equal As Strings  ${resp.json()[1]['email'][1]}  ${EMAIL2}
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['number']}           ${Phone_Num1} 
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[1]['sms'][1]['number']}           ${Phone_Num2} 
    Should Be Equal As Strings  ${resp.json()[1]['sms'][1]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[1]['sms'][0]}  ${Phone_Num1}
    # Should Be Equal As Strings  ${resp.json()[1]['sms'][1]}  ${Phone_Num2}  
    # Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]}  ${PUSERPH0}


    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[0]}  ${EventType[1]}  ${SMS_OneNum_list}  ${OneEMAIL_list}  ${PushMSG_Num_list}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[1]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['eventType']}  ${EventType[1]}
    Should Be Equal As Strings  ${resp.json()[1]['email'][0]}  ${EMAIL1}
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['number']}           ${Phone_Num1} 
    Should Be Equal As Strings  ${resp.json()[1]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[1]['sms'][0]}  ${Phone_Num1} 
    # Should Be Equal As Strings  ${resp.json()[1]['pushMsg'][0]}  ${PUSERPH0}



JD-TC-UpdateProviderNotificationSettings-24
    [Documentation]  Update Provider Notification  Settings For 'APPOINTMENTADD', when we have TWO 'SMS' Numbers and REMOVE ONE Number 
    ${resp}=   ProviderLogin  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
  

    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[1]}  ${EventType[7]}  ${SMS_TwoNum_list}  ${TwoEMAIL_list}  ${PushMSG_Num_list}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[2]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[2]['eventType']}  ${EventType[7]}
    Should Be Equal As Strings  ${resp.json()[2]['email'][0]}  ${EMAIL1}
    Should Be Equal As Strings  ${resp.json()[2]['email'][1]}  ${EMAIL2} 
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['number']}           ${Phone_Num1} 
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[2]['sms'][1]['number']}           ${Phone_Num2} 
    Should Be Equal As Strings  ${resp.json()[2]['sms'][1]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[2]['sms'][0]}  ${Phone_Num1}
    # Should Be Equal As Strings  ${resp.json()[2]['sms'][1]}  ${Phone_Num2}  
    # Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]}  ${PUSERPH0}

    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[1]}  ${EventType[7]}  ${SMS_OneNum_list}  ${OneEMAIL_list}  ${PushMSG_Num_list}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[2]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[2]['eventType']}  ${EventType[7]} 
    Should Be Equal As Strings  ${resp.json()[2]['email'][0]}  ${EMAIL1}
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['number']}           ${Phone_Num1} 
    Should Be Equal As Strings  ${resp.json()[2]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[2]['sms'][0]}  ${Phone_Num1}
    # Should Be Equal As Strings  ${resp.json()[2]['pushMsg'][0]}  ${PUSERPH0}


JD-TC-UpdateProviderNotificationSettings-25
    [Documentation]  Update Provider Notification  Settings For 'APPOINTMENTCANCEL', when we have TWO 'SMS' Numbers and REMOVE ONE Number 
    ${resp}=   ProviderLogin  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
  

   
    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[1]}  ${EventType[8]}  ${SMS_TwoNum_list}  ${TwoEMAIL_list}  ${PushMSG_Num_list}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[3]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[3]['eventType']}  ${EventType[8]}  
    Should Be Equal As Strings  ${resp.json()[3]['email'][0]}  ${EMAIL1}
    Should Be Equal As Strings  ${resp.json()[3]['email'][1]}  ${EMAIL2}
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['number']}           ${Phone_Num1} 
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[3]['sms'][1]['number']}           ${Phone_Num2} 
    Should Be Equal As Strings  ${resp.json()[3]['sms'][1]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[3]['sms'][0]}  ${Phone_Num1}
    # Should Be Equal As Strings  ${resp.json()[3]['sms'][1]}  ${Phone_Num2} 
    # Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]}  ${PUSERPH0}


    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[1]}  ${EventType[8]}  ${SMS_OneNum_list}  ${OneEMAIL_list}  ${PushMSG_Num_list}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[3]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[3]['eventType']}  ${EventType[8]}
    Should Be Equal As Strings  ${resp.json()[3]['email'][0]}  ${EMAIL1}
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['number']}           ${Phone_Num1} 
    Should Be Equal As Strings  ${resp.json()[3]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[3]['sms'][0]}  ${Phone_Num1} 
    # Should Be Equal As Strings  ${resp.json()[3]['pushMsg'][0]}  ${PUSERPH0}


JD-TC-UpdateProviderNotificationSettings-UH1
    [Documentation]  Update Provider Notification  Settings For 'WAITLISTADD', when we have TWO 'PushMsg' Numbers (one number is valid, another numbr is invalid) 
    ${resp}=   ProviderLogin  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${PushMSG_Ph1}=  Create Dictionary   number=${PUSERPH0}   countryCode=${countryCode_CC0}
    ${PushMSG_Ph2}=  Create Dictionary   number=${Phone_Num1}   countryCode=${countryCode_CC0}
    ${PushMSG_TwoNum_list1}=  create List  ${PushMSG_Ph1}  ${PushMSG_Ph2}
    Set Suite Variable  @{PushMSG_TwoNum_list1}

    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[0]}  ${EventType[0]}  ${SMS_TwoNum_list}  ${TwoEMAIL_list}  ${PushMSG_TwoNum_list1}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    ${LOGIN_Number_NOT_is_INVALID}=  Format String    ${LOGIN_NOT_FOUND}    ${countryCode_CC0}${Phone_Num1}
    Should Be Equal As Strings   "${resp.json()}"   "${LOGIN_Number_NOT_is_INVALID}"
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${EventType[0]}  
    Should Be Equal As Strings  ${resp.json()[0]['email'][0]}  ${EMAIL1} 
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['number']}           ${Phone_Num1} 
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[0]['sms'][0]}  ${Phone_Num1}
    # Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]}  ${PUSERPH0}





JD-TC-UpdateProviderNotificationSettings-UH2
    [Documentation]  Update Provider Notification  Settings For 'WAITLISTADD', when we have TWO 'PushMsg' Numbers (Two numbers are invalid)  
    ${resp}=   ProviderLogin  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${PushMSG_Ph1}=  Create Dictionary   number=${Phone_Num1}   countryCode=${countryCode_CC0}
    ${PushMSG_Ph2}=  Create Dictionary   number=${Phone_Num2}   countryCode=${countryCode_CC0}
    ${PushMSG_TwoNum_list2}=  create List  ${PushMSG_Ph2}  ${PushMSG_Ph1}
    Set Suite Variable  @{PushMSG_TwoNum_list2}

    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[0]}  ${EventType[0]}  ${SMS_TwoNum_list}  ${TwoEMAIL_list}  ${PushMSG_TwoNum_list2}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    ${LOGIN_Number_NOT_is_INVALID}=  Format String    ${LOGIN_NOT_FOUND}    ${countryCode_CC0}${Phone_Num2}
    Should Be Equal As Strings   "${resp.json()}"   "${LOGIN_Number_NOT_is_INVALID}"


    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${EventType[0]} 
    Should Be Equal As Strings  ${resp.json()[0]['email'][0]}  ${EMAIL1} 
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['number']}           ${Phone_Num1} 
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[0]['sms'][0]}  ${Phone_Num1} 
    # Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]}  ${PUSERPH0}






JD-TC-UpdateProviderNotificationSettings-UH3
    [Documentation]  Update Provider Notification  Settings For 'WAITLISTADD', when we have TWO 'PushMsg' Numbers (Two numbers are Duplicate entry of valid number)
    ${resp}=   ProviderLogin  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${PushMSG_Ph1}=  Create Dictionary   number=${PUSERPH0}   countryCode=${countryCode_CC0}
    ${PushMSG_Ph2}=  Create Dictionary   number=${PUSERPH0}   countryCode=${countryCode_CC0}
    ${PushMSG_TwoNum_list3}=  create List  ${PushMSG_Ph1}  ${PushMSG_Ph2}
    Set Suite Variable  @{PushMSG_TwoNum_list3}
   
    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[0]}  ${EventType[0]}  ${SMS_TwoNum_list}  ${TwoEMAIL_list}  ${PushMSG_TwoNum_list3}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${DUPLICATE_PUSH_MSG_PHONE_NO}"
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${EventType[0]} 
    Should Be Equal As Strings  ${resp.json()[0]['email'][0]}  ${EMAIL1}
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['number']}           ${Phone_Num1} 
    Should Be Equal As Strings  ${resp.json()[0]['sms'][0]['countryCode']}      ${countryCode_CC0}
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['number']}       ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]['countryCode']}  ${countryCode_CC0}
    # Should Be Equal As Strings  ${resp.json()[0]['sms'][0]}  ${Phone_Num1} 
    # Should Be Equal As Strings  ${resp.json()[0]['pushMsg'][0]}  ${PUSERPH0}




JD-TC-UpdateProviderNotificationSettings-UH4
    [Documentation]  Update Provider Notification  Settings For 'WAITLISTADD', when we have TWO same 'Email id' 
    ${resp}=   ProviderLogin  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${TwoEMAIL_list4}=  create List  ${EMAIL1}  ${EMAIL1}
    

    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[0]}  ${EventType[0]}  ${SMS_TwoNum_list}  ${TwoEMAIL_list4}  ${PushMSG_Num_list}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${DUPLICATE_EMAIL}"
    



JD-TC-UpdateProviderNotificationSettings-UH5
    [Documentation]  Update Provider Notification  Settings For 'WAITLISTADD', when we have TWO same 'SMS' Numbers 
    ${resp}=   ProviderLogin  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${MSG_Ph1}=  Create Dictionary   number=${Phone_Num1}   countryCode=${countryCode_CC0}
    ${MSG_Ph2}=  Create Dictionary   number=${Phone_Num1}   countryCode=${countryCode_CC0}
    ${SMS_TwoNum_list5}=  create List  ${MSG_Ph1}  ${MSG_Ph2}
    Set Suite Variable  @{SMS_TwoNum_list5}
   
    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[0]}  ${EventType[0]}  ${SMS_TwoNum_list5}  ${TwoEMAIL_list}  ${PushMSG_Num_list}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${DUPLICATE_PHONE_NO}"
    


JD-TC-UpdateProviderNotificationSettings-UH6
    [Documentation]  Update Provider Notification  Settings,  Without Login
    
    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[0]}  ${EventType[0]}  ${SMS_TwoNum_list}  ${TwoEMAIL_list}  ${PushMSG_Num_list}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[0]}  ${EventType[1]}  ${SMS_TwoNum_list}  ${TwoEMAIL_list}  ${PushMSG_Num_list}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[1]}  ${EventType[7]}  ${SMS_TwoNum_list}  ${TwoEMAIL_list}  ${PushMSG_Num_list}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[1]}  ${EventType[8]}  ${SMS_TwoNum_list}  ${TwoEMAIL_list}  ${PushMSG_Num_list}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"



JD-TC-UpdateProviderNotificationSettings-UH7
    [Documentation]  Update Provider Notification  Settings, with consumer login
    ${resp}=  Consumer Login  ${CUSERNAME0}  ${PASSWORD}
    Log  ${resp.json()}
    Log  ${resp.status_code}
    Should Be Equal As Strings  ${resp.status_code}  200

   
    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[1]}  ${EventType[8]}  ${SMS_TwoNum_list}  ${TwoEMAIL_list}  ${PushMSG_Num_list}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"


JD-TC-UpdateProviderNotificationSettings-UH8
    [Documentation]  Update Provider PUSH MESSAGE Related Notification Settings using provider number which is not registered of that account 
    ${resp}=   ProviderLogin  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${Num1}=  Evaluate  ${PUSERPH0}+9578
    ${PUSH_MSG_Ph1}=  Create Dictionary   number=${Num1}   countryCode=${countryCode_CC0}
    ${PUSH_MSG_Ph1_list}=  create List  ${PUSH_MSG_Ph1}
    ${PUSH_Msg_PH_NO_NOT_EXIST}=   Replace String  ${PUSH_PH_NO_NOT_EXIST}  {}  ${countryCode_CC0}${Num1}
    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[2]}  ${EventType[9]}  ${SMS_Num_list2}  ${PUser_EMAIL_list2}  ${PUSH_MSG_Ph1_list}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${PUSH_Msg_PH_NO_NOT_EXIST}

    ${PUSH_MSG_Ph2}=  Create Dictionary   number=${PUSERPH0}   countryCode=${countryCodes[2]}
    ${PUSH_MSG_Ph2_list}=  create List  ${PUSH_MSG_Ph2}
    ${PUSH_Msg_PH_NO_NOT_EXIST}=   Replace String  ${INVALID_PHONE_CODE}  {}  ${countryCodes[2]}${PUSERPH0}
    # ${PUSH_Msg_PH_NO_NOT_EXIST}=   Replace String  ${PUSH_PH_NO_NOT_EXIST}  {}  ${countryCodes[2]}${PUSERPH0}
    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[2]}  ${EventType[9]}  ${SMS_Num_list2}  ${PUser_EMAIL_list2}  ${PUSH_MSG_Ph2_list}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${PUSH_Msg_PH_NO_NOT_EXIST}

JD-TC-UpdateProviderNotificationSettings-UH9
    [Documentation]  Update Provider PUSH MESSAGE Related Notification Settings using Country code as EMPTY. 
    ${resp}=   ProviderLogin  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${Num1}=  Evaluate  ${PUSERPH0}+9578
    ${PUSH_MSG_Ph2}=  Create Dictionary   number=${Num1}   countryCode=${EMPTY}
    ${PUSH_MSG_Ph2_list}=  create List  ${PUSH_MSG_Ph2}
    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[2]}  ${EventType[9]}  ${SMS_Num_list2}  ${PUser_EMAIL_list2}  ${PUSH_MSG_Ph2_list}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${PHONE_CODE_RQD}


JD-TC-UpdateProviderNotificationSettings-UH10
    [Documentation]  Update Provider PUSH MESSAGE Related Notification Settings using Phone Number as EMPTY. 
    ${resp}=   ProviderLogin  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${Num1}=  Evaluate  ${PUSERPH0}+9578
    ${PUSH_MSG_Ph2}=  Create Dictionary   number=${EMPTY}   countryCode=${countryCodes[2]}
    ${PUSH_MSG_Ph2_list}=  create List  ${PUSH_MSG_Ph2}
    ${resp}=  Update Provider Notification Settings  ${NotificationResourceType[2]}  ${EventType[9]}  ${SMS_Num_list2}  ${PUser_EMAIL_list2}  ${PUSH_MSG_Ph2_list}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${PHONE_CODE_RQD}

    

