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
${One_person_ahead}   1 

*** Test Cases ***

JD-TC-UpdateConsumerNotificationSettings-1
    [Documentation]   Provider updating consumer notification settings with EventType as Early
    ${resp}=  Encrypted Provider Login  ${PUSERNAME44}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_consumer_notification_settings  ${PUSERNAME44}
    ${msg}=  FakerLibrary.text
    Set Suite Variable  ${msg}
    Append To File  ${EXECDIR}/TDD/TDD_Output/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${person_ahead}=   Random Int  min=2   max=5
    Set Suite Variable  ${person_ahead}
    ${resp}=  Create Consumer Notification Settings  ${NotificationResourceType[0]}  ${EventType[4]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${msg}  ${person_ahead}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${msg1}=  FakerLibrary.text 
    ${person_ahead1}=   Random Int  min=3   max=7
    ${resp}=  Update Consumer Notification Settings  ${NotificationResourceType[0]}  ${EventType[4]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${msg1}  ${person_ahead1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${EventType[4]}
    Should Be Equal As Strings  ${resp.json()[0]['email']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[0]['sms']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[0]['pushNotification']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['commonMessage']}  ${msg1}
    Should Be Equal As Strings  ${resp.json()[0]['personsAhead']}  ${person_ahead1}

JD-TC-UpdateConsumerNotificationSettings-2
    [Documentation]   Provider setting consumer notification settings without commonMessage and update that settings with common msg
    ${resp}=  Encrypted Provider Login  ${PUSERNAME15}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_consumer_notification_settings  ${PUSERNAME15}
    ${person_ahead}=   Random Int  min=2   max=5
    ${resp}=  Create Consumer Notification Settings  ${NotificationResourceType[1]}  ${EventType[1]}  ${bool[0]}  ${bool[1]}  ${bool[0]}  ${EMPTY}  ${person_ahead}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${msg1}=  FakerLibrary.text 
    ${person_ahead1}=   Random Int  min=3   max=7
    ${resp}=  Update Consumer Notification Settings  ${NotificationResourceType[1]}  ${EventType[1]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${msg1}  ${person_ahead1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${NotificationResourceType[1]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${EventType[1]}
    Should Be Equal As Strings  ${resp.json()[0]['email']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[0]['sms']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[0]['pushNotification']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['commonMessage']}  ${msg1}
    Should Be Equal As Strings  ${resp.json()[0]['personsAhead']}  ${person_ahead}

# JD-TC-UpdateConsumerNotificationSettings-3
#     [Documentation]   Provider setting consumer notification settings with EventType as Early, without PersonAhead and update it
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME14}  ${PASSWORD}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     clear_consumer_notification_settings  ${PUSERNAME14}
#     ${msg6}=  FakerLibrary.text
#     Set Suite Variable  ${msg6}
#     ${resp}=  Create Consumer Notification Settings  ${NotificationResourceType[0]}  ${EventType[4]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${msg6}  ${EMPTY}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200 
#     # Should Be Equal As Strings  "${resp.json()}"   "${EARLY_NOTIFICATION}"
#     ${resp}=  Get Consumer Notification Settings
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200 
#     Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${NotificationResourceType[0]}
#     Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${EventType[4]}
#     Should Be Equal As Strings  ${resp.json()[0]['email']}  ${bool[1]}
#     Should Be Equal As Strings  ${resp.json()[0]['sms']}  ${bool[1]}
#     Should Be Equal As Strings  ${resp.json()[0]['pushNotification']}  ${bool[1]}
#     Should Be Equal As Strings  ${resp.json()[0]['commonMessage']}  ${msg6}
#     Should Not Contain  ${resp.json()}   personsAhead
    
#     sleep   2s
#     ${msg1}=  FakerLibrary.text 
#     ${person_ahead1}=   Random Int  min=2   max=5
#     ${resp}=  Update Consumer Notification Settings  ${NotificationResourceType[0]}  ${EventType[4]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${msg1}  ${person_ahead1}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=  Get Consumer Notification Settings
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200  
#     Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${NotificationResourceType[0]}
#     Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${EventType[4]}
#     Should Be Equal As Strings  ${resp.json()[0]['email']}  ${bool[1]}
#     Should Be Equal As Strings  ${resp.json()[0]['sms']}  ${bool[1]}
#     Should Be Equal As Strings  ${resp.json()[0]['pushNotification']}  ${bool[1]}
#     Should Be Equal As Strings  ${resp.json()[0]['commonMessage']}  ${msg1}
#     Should Be Equal As Strings  ${resp.json()[0]['personsAhead']}  ${person_ahead1}



JD-TC-UpdateConsumerNotificationSettings-UH1
    [Documentation]   Provider trying to update not existing notification settings(Resourcetype not exist)
    ${resp}=  Encrypted Provider Login  ${PUSERNAME44}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${msg1}=  FakerLibrary.text
    Set Suite Variable  ${msg1}
    ${person_ahead1}=   Random Int  min=0   max=5
    Set Suite Variable  ${person_ahead1}
    ${resp}=  Update Consumer Notification Settings  ${NotificationResourceType[1]}  ${EventType[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${msg1}  ${person_ahead1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${NOTIFICATION_SETTINGS_NOT_FOUND}"

JD-TC-UpdateConsumerNotificationSettings-UH2
    [Documentation]   Provider trying to update not existing notification settings(Resource type exist but eventtype is wrong)
    ${resp}=  Encrypted Provider Login  ${PUSERNAME44}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${msg1}=  FakerLibrary.text
    Set Suite Variable  ${msg1}
    ${person_ahead1}=   Random Int  min=0   max=5
    Set Suite Variable  ${person_ahead1}
    ${resp}=  Update Consumer Notification Settings  ${NotificationResourceType[0]}  ${EventType[1]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${msg1}  ${person_ahead1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${NOTIFICATION_SETTINGS_NOT_FOUND}"

JD-TC-UpdateConsumerNotificationSettings -UH3
    [Documentation]   Provider updating consumer notification settings without login  
    ${resp}=  Update Consumer Notification Settings  ${NotificationResourceType[1]}  ${EventType[1]}  ${bool[0]}  ${bool[1]}  ${bool[0]}  ${EMPTY}  ${person_ahead}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}"
 
JD-TC-UpdateConsumerNotificationSettings -UH4
    [Documentation]   Consumer updating consumer notification settings
    ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Update Consumer Notification Settings  ${NotificationResourceType[1]}  ${EventType[1]}  ${bool[0]}  ${bool[1]}  ${bool[0]}  ${EMPTY}  ${person_ahead}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings  "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-UpdateConsumerNotificationSettings-UH5
    [Documentation]   Provider updating consumer notification settings with EventType as Early and PersonAhead below 2
    ${resp}=  Encrypted Provider Login  ${PUSERNAME45}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_consumer_notification_settings  ${PUSERNAME45}
    ${msg}=  FakerLibrary.text
    Set Suite Variable  ${msg}
    ${person_ahead}=   Random Int  min=3   max=5
    Set Suite Variable  ${person_ahead}
    ${resp}=  Create Consumer Notification Settings  ${NotificationResourceType[0]}  ${EventType[4]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${msg}  ${person_ahead}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${msg1}=  FakerLibrary.text 
    
    ${resp}=  Update Consumer Notification Settings  ${NotificationResourceType[0]}  ${EventType[4]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${msg1}  ${One_person_ahead}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${EARLY_NOTIFICATION_POSITION}"
    ${resp}=  Update Consumer Notification Settings  ${NotificationResourceType[0]}  ${EventType[4]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${msg1}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${EARLY_NOTIFICATION}"


JD-TC-UpdateConsumerNotificationSettings-UH6
    [Documentation]   Provider updating consumer notification settings with EventType as Early and PersonAhead as EMPTY
    ${resp}=  Encrypted Provider Login  ${PUSERNAME45}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_consumer_notification_settings  ${PUSERNAME45}
    ${msg}=  FakerLibrary.text
    Set Suite Variable  ${msg}
    ${person_ahead}=   Random Int  min=3   max=5
    Set Suite Variable  ${person_ahead}
    ${resp}=  Create Consumer Notification Settings  ${NotificationResourceType[0]}  ${EventType[4]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${msg}  ${person_ahead}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${msg1}=  FakerLibrary.text 
    
    ${resp}=  Update Consumer Notification Settings  ${NotificationResourceType[0]}  ${EventType[4]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${msg1}  ${One_person_ahead}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${EARLY_NOTIFICATION_POSITION}"
    ${resp}=  Update Consumer Notification Settings  ${NotificationResourceType[0]}  ${EventType[4]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${msg1}  ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}  ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}  ${EventType[4]}
    Should Be Equal As Strings  ${resp.json()[0]['email']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['sms']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['pushNotification']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['commonMessage']}  ${msg1}
    Should Not Contain  ${resp.json()}   personsAhead

    



