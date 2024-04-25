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

   

*** Test Cases ***

JD-TC-ProviderNotificationSettings-1
    [Documentation]  Clear Provider Notification Settings using New Provider SignUp

    ${PUSERPH0}=  Evaluate  ${PUSERNAME}+5711527
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
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERPH0}${\n}

    ${resp}=  Account Set Credential  ${EMAIL_id0}  ${PASSWORD}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    Set Suite Variable  ${countryCode_CC0}    ${countryCodes[0]}
    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
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

    # [Setup]  clear_Provider_Notification_Settings  ${PUSERPH0}
    clear_Provider_Notification_Settings  ${PUSERPH0}

    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()}   ${EMPTY_List}


JD-TC-ProviderNotificationSettings-2
    [Documentation]  Clear Provider Notification Settings of one provider, and verify notification settings of another provider

    ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    clear_Provider_Notification_Settings  ${PUSERNAME2}

    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()}   ${EMPTY_List}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME4}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Provider Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Not Be Equal As Strings  ${resp.json()}   ${EMPTY_List}


# JD-TC-ProviderNotification-1
#     ${PUSERPH}=  Evaluate  ${PUSERNAME2}+8000
#     ${PUSEREM}=  Set Variable  ${P_EMAIL}de.${test_mail}
#     [Documentation]  Enable Notification  Settings For WAITLISTADD 
#     ${TORF}=  Evaluate  random.choice($TORF)  random
#     [Setup]  clear_Provider_Notification  ${PUSERNAME2}   
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
#     Log  ${resp.json()}
#     Log  ${resp.status_code}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Suite Variable  ${pid}  ${resp.json()['id']}
#     ${resp}=  Create Provider Notification Settings  ${resourceType[0]}  ${eventType[0]}  ${phonenum}  ${email}   ${TORF}  ${pid}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=  Get Notification Details
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${resourceType[0]}
#     Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${eventType[0]}
#     Should Be Equal As Strings  ${resp.json()[0]['sms'][0]}  ${phonenum}  
#     Should Be Equal As Strings  ${resp.json()[0]['email'][0]}  ${email} 
#     Should Be Equal As Strings  ${resp.json()[0]['pushMessage']}  ${TORF} 



# JD-TC-ProviderNotification-2
#     [Documentation]  Enable Notification  Settings For WAITLISTCANCEL  
#     ${TORF}=  Evaluate  random.choice($TORF)  random
#     [Setup]  clear_Provider_Notification  ${PUSERNAME2}   
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
#     Log  ${resp.json()}
#     Log  ${resp.status_code}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=  Create Provider Notification Settings  ${resourceType[0]}  ${eventType[1]}  ${phonenum}  ${email}   ${TORF}  ${pid}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=  Get Notification Details
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${resourceType[0]}
#     Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${eventType[1]}
#     Should Be Equal As Strings  ${resp.json()[0]['sms'][0]}  ${phonenum}  
#     Should Be Equal As Strings  ${resp.json()[0]['email'][0]}  ${email} 
#     Should Be Equal As Strings  ${resp.json()[0]['pushMessage']}  ${TORF}

# JD-TC-ProviderNotification-3
#     [Documentation]  Enable Provider Notification-1  Settings For WAITLISTADD Without PhoneNumber 
#     ${TORF}=  Evaluate  random.choice($TORF)  random
#     [Setup]  clear_Provider_Notification  ${PUSERNAME2}   
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
#     Log  ${resp.json()}
#     Log  ${resp.status_code}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=  Create Provider Notification Settings  ${resourceType[0]}  ${eventType[0]}  ${EMPTY}  ${email}  ${TORF}  ${pid}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=  Get Notification Details
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${resourceType[0]}
#     Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${eventType[0]}
#     Should Be Equal As Strings  ${resp.json()[0]['sms']}  []    
#     Should Be Equal As Strings  ${resp.json()[0]['email'][0]}  ${email} 
#     Should Be Equal As Strings  ${resp.json()[0]['pushMessage']}  ${TORF}

# JD-TC-ProviderNotification-4
#     [Documentation]  Enable Notification  Settings For WAITLISTADD Without Email 
#     ${TORF}=  Evaluate  random.choice($TORF)  random
#     [Setup]  clear_Provider_Notification  ${PUSERNAME2}   
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
#     Log  ${resp.json()}
#     Log  ${resp.status_code}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=  Create Provider Notification Settings  ${resourceType[0]}  ${eventType[0]}  ${phonenum}  ${EMPTY}  ${TORF}  ${pid}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=  Get Notification Details
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${resourceType[0]}
#     Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${eventType[0]}
#     Should Be Equal As Strings  ${resp.json()[0]['sms'][0]}  ${phonenum}    
#     Should Be Equal As Strings  ${resp.json()[0]['email']}  [] 
#     Should Be Equal As Strings  ${resp.json()[0]['pushMessage']}  ${TORF}    


# JD-TC-ProviderNotification-5
#     [Documentation]  Enable Notification  Settings For WAITLISTCANCEL Without PhoneNumber
#     ${TORF}=  Evaluate  random.choice($TORF)  random 
#     [Setup]  clear_Provider_Notification  ${PUSERNAME2}   
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
#     Log  ${resp.json()}
#     Log  ${resp.status_code}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=  Create Provider Notification Settings  ${resourceType[0]}  ${eventType[1]}  ${EMPTY}  ${email}   ${TORF}  ${pid}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=  Get Notification Details
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${resourceType[0]}
#     Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${eventType[1]}
#     Should Be Equal As Strings  ${resp.json()[0]['sms']}  []    
#     Should Be Equal As Strings  ${resp.json()[0]['email'][0]}  ${email} 
#     Should Be Equal As Strings  ${resp.json()[0]['pushMessage']}  ${TORF}


# JD-TC-ProviderNotification-6
#     [Documentation]  Enable Notification  Settings For WAITLISTCANCEL Without Email 
#     ${TORF}=  Evaluate  random.choice($TORF)  random
#     [Setup]  clear_Provider_Notification  ${PUSERNAME2}   
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
#     Log  ${resp.json()}
#     Log  ${resp.status_code}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=  Create Provider Notification Settings  ${resourceType[0]}  ${eventType[1]}  ${phonenum}  ${EMPTY}  ${TORF}  ${pid} 
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=  Get Notification Details
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${resourceType[0]}
#     Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${eventType[1]}
#     Should Be Equal As Strings  ${resp.json()[0]['sms'][0]}  ${phonenum}    
#     Should Be Equal As Strings  ${resp.json()[0]['email']}  []
#     Should Be Equal As Strings  ${resp.json()[0]['pushMessage']}  ${TORF}

# JD-TC-ProviderNotification-7
#     [Documentation]  Enable Notification  Settings For WAITLISTADD Without  Phone number and Email 
#     ${TORF}=  Evaluate  random.choice($TORF)  random
#     [Setup]  clear_Provider_Notification  ${PUSERNAME2}   
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
#     Log  ${resp.json()}
#     Log  ${resp.status_code}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=  Create Provider Notification Settings  ${resourceType[0]}  ${eventType[0]}  ${EMPTY}  ${EMPTY}  ${TORF}  ${pid}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=  Get Notification Details
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${resourceType[0]}
#     Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${eventType[0]}
#     Should Be Equal As Strings  ${resp.json()[0]['sms']}  []    
#     Should Be Equal As Strings  ${resp.json()[0]['email']}  []
#     Should Be Equal As Strings  ${resp.json()[0]['pushMessage']}  ${TORF}

# JD-TC-ProviderNotification-8
#     [Documentation]  Enable Notification  Settings For WAITLISTCANCEL Without  Phone number and Email 
#     ${TORF}=  Evaluate  random.choice($TORF)  random
#     [Setup]  clear_Provider_Notification  ${PUSERNAME2}   
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
#     Log  ${resp.json()}
#     Log  ${resp.status_code}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=  Create Provider Notification Settings  ${resourceType[0]}  ${eventType[1]}  ${EMPTY}  ${EMPTY}  ${TORF}  ${pid}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=  Get Notification Details
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${resourceType[0]}
#     Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${eventType[1]}
#     Should Be Equal As Strings  ${resp.json()[0]['sms']}  []    
#     Should Be Equal As Strings  ${resp.json()[0]['email']}  []
#     Should Be Equal As Strings  ${resp.json()[0]['pushMessage']}  ${TORF}
       
# JD-TC-ProviderNotification-9
#      [Documentation]  Enable Notification  Settings For WAITLISTADD Without Login
#      ${resp}=  Create Provider Notification Settings  ${resourceType[0]}  ${eventType[0]}  ${phonenum}  ${email}  ${TORF}  ${pid}
#      Log  ${resp.json()}
#      Should Be Equal As Strings  ${resp.status_code}  419
#      Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

# JD-TC-ProviderNotification-10
#      [Documentation]  Enable Notification  Settings For WAITLISTCANCEL Without Login
#      ${resp}=  Create Provider Notification Settings  ${resourceType[0]}  ${eventType[1]}  ${phonenum}  ${email}  ${TORF}  ${pid}
#      Log  ${resp.json()}
#      Should Be Equal As Strings  ${resp.status_code}  419
#      Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

# JD-TC-ProviderNotification-11
#     [Documentation]  Enable Notification  Settings For WAITLISTADD  Two PhoneNumber
#     ${TORF}=  Evaluate  random.choice($TORF)  random
#     [Setup]  clear_Provider_Notification  ${PUSERNAME2}   
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
#     Log  ${resp.json()}
#     Log  ${resp.status_code}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${sms}=  Create List  ${phonenum}  ${phonenum2} 
#     ${email}=  create List  ${email} 
#     ${resp}=  Provider Notification-2  ${resourceType[0]}  ${eventType[0]}  ${sms}  ${email}  ${TORF}  ${pid}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200 
#     ${resp}=  Get Notification Details
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${resourceType[0]}
#     Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${eventType[0]}
#     Should Be Equal As Strings  ${resp.json()[0]['sms']}  ${sms}    
#     Should Be Equal As Strings  ${resp.json()[0]['email']}  ${email} 
#     Should Be Equal As Strings  ${resp.json()[0]['pushMessage']}  ${TORF}   
    
# JD-TC-ProviderNotification-12
#     [Documentation]  Enable Notification  Settings For WAITLISTADD  Two Email
#     ${TORF}=  Evaluate  random.choice($TORF)  random
#     [Setup]  clear_Provider_Notification  ${PUSERNAME2}   
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
#     Log  ${resp.json()}
#     Log  ${resp.status_code}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${sms}=  Create List  ${phonenum} 
#     ${email}=  create List  ${email}  ${email2}
#     ${resp}=  Provider Notification-2  ${resourceType[0]}  ${eventType[0]}  ${sms}  ${email}  ${TORF}  ${pid}    
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200 
#     ${resp}=  Get Notification Details
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${resourceType[0]}
#     Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${eventType[0]}
#     Should Be Equal As Strings  ${resp.json()[0]['sms']}  ${sms}    
#     Should Be Equal As Strings  ${resp.json()[0]['email']}  ${email}   
#     Should Be Equal As Strings  ${resp.json()[0]['pushMessage']}  ${TORF} 

# JD-TC-ProviderNotification-13
#     [Documentation]  Enable Notification  Settings For WAITLISTADD  Two PhoneNumber and Two Email
#     ${TORF}=  Evaluate  random.choice($TORF)  random
#     [Setup]  clear_Provider_Notification  ${PUSERNAME2}   
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
#     Log  ${resp.json()}
#     Log  ${resp.status_code}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${sms}=  Create List  ${phonenum}  ${phonenum2} 
#     ${email}=  create List  ${email}  ${email2}
#     ${resp}=  Provider Notification-2  ${resourceType[0]}  ${eventType[1]}  ${sms}  ${email}  ${TORF}  ${pid}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200 
#     ${resp}=  Get Notification Details
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${resourceType[0]}
#     Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${eventType[1]}
#     Should Be Equal As Strings  ${resp.json()[0]['sms']}  ${sms}  
#     Should Be Equal As Strings  ${resp.json()[0]['email']}  ${email}   
#     Should Be Equal As Strings  ${resp.json()[0]['pushMessage']}  ${TORF} 

# JD-TC-ProviderNotification-14
#     [Documentation]  Enable Notification  Settings For WAITLISTCANCEL  Two PhoneNumber
#     ${TORF}=  Evaluate  random.choice($TORF)  random
#     [Setup]  clear_Provider_Notification  ${PUSERNAME2}   
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
#     Log  ${resp.json()}
#     Log  ${resp.status_code}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${sms}=  Create List  ${phonenum}  ${phonenum2} 
#     ${email}=  create List  ${email}
#     ${resp}=  Provider Notification-2  ${resourceType[0]}  ${eventType[1]}  ${sms}  ${email}  ${TORF}  ${pid}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200 
#     ${resp}=  Get Notification Details
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${resourceType[0]}
#     Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${eventType[1]}
#     Should Be Equal As Strings  ${resp.json()[0]['sms']}  ${sms}    
#     Should Be Equal As Strings  ${resp.json()[0]['email']}  ${email}  
#     Should Be Equal As Strings  ${resp.json()[0]['pushMessage']}  ${TORF}   
    
# JD-TC-ProviderNotification-15
#     [Documentation]  Enable Notification  Settings For WAITLISTCANCEL  Two Email
#     ${TORF}=  Evaluate  random.choice($TORF)  random
#     [Setup]  clear_Provider_Notification  ${PUSERNAME2}   
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
#     Log  ${resp.json()}
#     Log  ${resp.status_code}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${sms}=  Create List  ${phonenum} 
#     ${email}=  create List  ${email}  ${email2}
#     ${resp}=  Provider Notification-2  ${resourceType[0]}  ${eventType[1]}  ${sms}  ${email}  ${TORF}  ${pid}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200 
#     ${resp}=  Get Notification Details
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${resourceType[0]}
#     Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${eventType[1]}
#     Should Be Equal As Strings  ${resp.json()[0]['sms']}  ${sms}    
#     Should Be Equal As Strings  ${resp.json()[0]['email']}  ${email}   
#     Should Be Equal As Strings  ${resp.json()[0]['pushMessage']}  ${TORF} 

# JD-TC-ProviderNotification-16
#     [Documentation]  Enable Notification  Settings For WAITLISTCANCEL  Two PhoneNumber and Two Email
#     ${TORF}=  Evaluate  random.choice($TORF)  random
#     [Setup]  clear_Provider_Notification  ${PUSERNAME2}   
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
#     Log  ${resp.json()}
#     Log  ${resp.status_code}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${sms}=  Create List  ${phonenum}  ${phonenum2} 
#     ${email}=  create List  ${email}  ${email2}
#     ${resp}=  Provider Notification-2  ${resourceType[0]}  ${eventType[1]}  ${sms}  ${email}  ${TORF}  ${pid}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200 
#     ${resp}=  Get Notification Details
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${resourceType[0]}
#     Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${eventType[1]}
#     Should Be Equal As Strings  ${resp.json()[0]['sms']}  ${sms}   
#     Should Be Equal As Strings  ${resp.json()[0]['email']}  ${email}   
#     Should Be Equal As Strings  ${resp.json()[0]['pushMessage']}  ${TORF}

# JD-TC-ProviderNotification-UH-1
#     [Documentation]  Enable Notification  Settings For WAITLISTADD  Two PhoneNumber But they are Same
#     ${TORF}=  Evaluate  random.choice($TORF)  random
#     [Setup]  clear_Provider_Notification  ${PUSERNAME2}   
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
#     Log  ${resp.json()}
#     Log  ${resp.status_code}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${sms}=  Create List  ${phonenum}  ${phonenum} 
#     ${email}=  create List  ${email}
#     ${resp}=  Provider Notification-2  ${resourceType[0]}  ${eventType[1]}  ${sms}  ${email}  ${TORF}  ${pid}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  422
#     Should Be Equal As Strings  "${resp.json()}"  "${DUPLICATE_PHONE_NO}"
# JD-TC-ProviderNotification-UH-2
#     [Documentation]  Enable Notification  Settings For WAITLISTADD  Two Email But they are Same
#     ${TORF}=  Evaluate  random.choice($TORF)  random
#     [Setup]  clear_Provider_Notification  ${PUSERNAME2}   
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
#     Log  ${resp.json()}
#     Log  ${resp.status_code}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${sms}=  Create List  ${phonenum} 
#     ${email}=  create List  ${email}  ${email}
#     ${resp}=  Provider Notification-2  ${resourceType[0]}  ${eventType[0]}  ${sms}  ${email}  ${TORF}  ${pid}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  422 
#     Should Be Equal As Strings  "${resp.json()}"  "${DUPLICATE_EMAIL}"       

# JD-TC-ProviderNotification-UH-3
#     [Documentation]  Enable Notification  Settings For WAITLISTCANCEL  Two PhoneNumber But they are Same
#     ${TORF}=  Evaluate  random.choice($TORF)  random
#     [Setup]  clear_Provider_Notification  ${PUSERNAME2}   
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
#     Log  ${resp.json()}
#     Log  ${resp.status_code}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${sms}=  Create List  ${phonenum}  ${phonenum} 
#     ${email}=  create List  ${email}
#     ${resp}=  Provider Notification-2  ${resourceType[0]}  ${eventType[1]}  ${sms}  ${email}  ${TORF}  ${pid}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  422
#     Should Be Equal As Strings  "${resp.json()}"  "${DUPLICATE_PHONE_NO}"


# JD-TC-ProviderNotification-UH-4
#     [Documentation]  Enable Notification  Settings For WAITLISTCANCEL  Two Email But they are Same
#     ${TORF}=  Evaluate  random.choice($TORF)  random
#     [Setup]  clear_Provider_Notification  ${PUSERNAME2}   
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
#     Log  ${resp.json()}
#     Log  ${resp.status_code}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${sms}=  Create List  ${phonenum} 
#     ${email}=  create List  ${email}  ${email}
#     ${resp}=  Provider Notification-2  ${resourceType[0]}  ${eventType[1]}  ${sms}  ${email}  ${TORF}  ${pid}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  422
#     Should Be Equal As Strings  "${resp.json()}"  "${DUPLICATE_EMAIL}"

# JD-TC-GetProviderNotification-UH-5
#     ${PUSERPH}=  Evaluate  ${PUSERNAME4}+7000
#     ${PUSEREM}=  Set Variable  ${P_EMAIL}de.${test_mail}
#     [Documentation]  Get Notification  Settings For WAITLISTADD with consumer Login 
#     ${resp}=  Consumer Login  ${CUSERNAME0}  ${PASSWORD}
#     Log  ${resp.json()}
#     Log  ${resp.status_code}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=  Provider Notification-2  ${resourceType[0]}  ${eventType[0]}  ${PUSERPH}  ${PUSEREM}   ${TORF}  ${pid}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  401
#     Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"
#     ${resp}=  Get Notification Details
#     Log  ${resp.json()} 

# JD-TC-GetProviderNotification-UH-6
#     ${PUSERPH}=  Evaluate  ${PUSERNAME4}+7000
#     ${PUSEREM}=  Set Variable  ${P_EMAIL}de.${test_mail}
#     [Documentation]  Get Notification  Settings For WAITLISTCANCEL with consumer Login 
#     ${resp}=  Consumer Login  ${CUSERNAME0}  ${PASSWORD}
#     Log  ${resp.json()}
#     Log  ${resp.status_code}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=  Create Provider Notification Settings  ${resourceType[0]}  ${eventType[1]}  ${PUSERPH}  ${PUSEREM}   ${TORF}  ${pid}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  401
#     Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"
#     ${resp}=  Get Notification Details
#     Log  ${resp.json()}

                       
   


     








