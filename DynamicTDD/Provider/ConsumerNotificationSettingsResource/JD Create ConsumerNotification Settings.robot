*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown    Delete All Sessions
Force Tags        NotificationSettings
Library           Collections
Library           String
Library           json
Library           /ebs/TDD/db.py
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 


*** Variables ***
${Zero_person_ahead}   0
${One_person_ahead}    1

*** Test Cases ***

JD-TC-ConsumerNotificationSettings-1
    [Documentation]   Provider setting consumer notification settings
    ${resp}=  Encrypted Provider Login  ${PUSERNAME4}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_consumer_notification_settings  ${PUSERNAME4}
    ${msg}=  FakerLibrary.text
    Set Suite Variable  ${msg}
    ${person_ahead}=   Random Int  min=2   max=5
    Set Suite Variable  ${person_ahead}
    ${resp}=  Create Consumer Notification Settings  ${NotificationResourceType[0]}  ${EventType[0]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${msg}  ${person_ahead}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    ${resp}=  Get Consumer Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${EventType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['email']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['sms']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['pushNotification']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['commonMessage']}  ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['personsAhead']}  ${person_ahead}

JD-TC-ConsumerNotificationSettings-2
    [Documentation]   Provider again setting consumer notification settings for another resouce and eventtype
    ${resp}=  Encrypted Provider Login  ${PUSERNAME4}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${msg1}=  FakerLibrary.text
    Set Suite Variable  ${msg1}
    ${person_ahead1}=   Random Int  min=2   max=5
    Set Suite Variable  ${person_ahead1}
    ${resp}=  Create Consumer Notification Settings  ${NotificationResourceType[1]}  ${EventType[1]}  ${bool[0]}  ${bool[1]}  ${bool[0]}  ${msg1}  ${person_ahead1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    ${resp}=  Get Consumer Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${EventType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['email']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['sms']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['pushNotification']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['commonMessage']}  ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['personsAhead']}  ${person_ahead}
    Should Be Equal As Strings  ${resp.json()[1]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[1]['eventType']}  ${EventType[1]}
    Should Be Equal As Strings  ${resp.json()[1]['email']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[1]['sms']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[1]['pushNotification']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[1]['commonMessage']}  ${msg1}
    Should Be Equal As Strings  ${resp.json()[1]['personsAhead']}  ${person_ahead1}

JD-TC-ConsumerNotificationSettings-3
    [Documentation]   Provider setting consumer notification settings without commonMessage
    ${resp}=  Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_consumer_notification_settings  ${PUSERNAME5}
    ${person_ahead}=   Random Int  min=2   max=5
    ${resp}=  Create Consumer Notification Settings  ${NotificationResourceType[1]}  ${EventType[1]}  ${bool[0]}  ${bool[1]}  ${bool[0]}  ${EMPTY}  ${person_ahead}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${EventType[1]}
    Should Be Equal As Strings  ${resp.json()[0]['email']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[0]['sms']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['pushNotification']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[0]['commonMessage']}  ${EMPTY}
    Should Be Equal As Strings  ${resp.json()[0]['personsAhead']}  ${person_ahead}

JD-TC-ConsumerNotificationSettings-UH1
    [Documentation]   Provider setting consumer notification settings for already exist
    ${resp}=  Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${invalid_resourcetype}=  FakerLibrary.word
    ${resp}=  Create Consumer Notification Settings  ${NotificationResourceType[1]}  ${EventType[1]}  ${bool[0]}  ${bool[1]}  ${bool[0]}  ${EMPTY}  ${person_ahead}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${NOTIFICATION_SETTINGS_ALREADY_EXIST}"

JD-TC-ConsumerNotificationSettings -UH2
    [Documentation]   Provider setting consumer notification settings without login  
    ${resp}=  Create Consumer Notification Settings  ${NotificationResourceType[1]}  ${EventType[1]}  ${bool[0]}  ${bool[1]}  ${bool[0]}  ${EMPTY}  ${person_ahead}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}"
 
JD-TC-ConsumerNotificationSettings -UH3
    [Documentation]   Consumer setting consumer notification settings
    ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Create Consumer Notification Settings  ${NotificationResourceType[1]}  ${EventType[1]}  ${bool[0]}  ${bool[1]}  ${bool[0]}  ${EMPTY}  ${person_ahead}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings  "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-ConsumerNotificationSettings-UH4
    [Documentation]   Provider setting consumer notification settings with EventType as Early and PersonAhead is ONE
    ${resp}=  Encrypted Provider Login  ${PUSERNAME6}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_consumer_notification_settings  ${PUSERNAME6}
    ${msg}=  FakerLibrary.text
    Set Suite Variable  ${msg}
    Set Suite Variable  ${person_ahead}
    ${resp}=  Create Consumer Notification Settings  ${NotificationResourceType[0]}  ${EventType[4]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${msg}  ${One_person_ahead}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422 
    Should Be Equal As Strings  "${resp.json()}"   "${EARLY_NOTIFICATION_POSITION}"


JD-TC-ConsumerNotificationSettings-UH5
    [Documentation]   Provider setting consumer notification settings with EventType as Early and PersonAhead is ZERO
    ${resp}=  Encrypted Provider Login  ${PUSERNAME6}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_consumer_notification_settings  ${PUSERNAME6}
    ${msg}=  FakerLibrary.text
    Set Suite Variable  ${msg}
    Set Suite Variable  ${person_ahead}
    ${resp}=  Create Consumer Notification Settings  ${NotificationResourceType[0]}  ${EventType[4]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${msg}  ${Zero_person_ahead}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422 
    Should Be Equal As Strings  "${resp.json()}"   "${EARLY_NOTIFICATION}"


JD-TC-ConsumerNotificationSettings-UH6
    [Documentation]   Provider setting consumer notification settings with EventType as Early and without PersonAhead
    ${resp}=  Encrypted Provider Login  ${PUSERNAME6}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_consumer_notification_settings  ${PUSERNAME6}
    ${msg6}=  FakerLibrary.text
    Set Suite Variable  ${msg6}
    ${resp}=  Create Consumer Notification Settings  ${NotificationResourceType[0]}  ${EventType[4]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${msg6}  ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    # Should Be Equal As Strings  "${resp.json()}"   "${EARLY_NOTIFICATION}"
    ${resp}=  Get Consumer Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${EventType[4]}
    Should Be Equal As Strings  ${resp.json()[0]['email']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['sms']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['pushNotification']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['commonMessage']}  ${msg6}
    Should Not Contain  ${resp.json()}   personsAhead

