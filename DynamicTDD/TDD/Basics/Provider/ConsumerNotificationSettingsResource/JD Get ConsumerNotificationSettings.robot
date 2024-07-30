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

*** Test Cases ***

JD-TC-GetGetConsumerNotificationSettings-1
    [Documentation]   Getting consumer notification settings
    ${resp}=  Encrypted Provider Login  ${PUSERNAME14}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_consumer_notification_settings  ${PUSERNAME14}
    ${msg}=  FakerLibrary.text
    Set Suite Variable  ${msg}
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
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

JD-TC-GetConsumerNotificationSettings-2
    [Documentation]   Provider again setting consumer notification settings for another resouce and eventtype, Then getting all notification settings
    ${resp}=  Encrypted Provider Login  ${PUSERNAME14}  ${PASSWORD}
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



JD-TC-GetConsumerNotificationSettings-3
    [Documentation]   Provider setting consumer notification settings with EventType as Early and without PersonAhead
    ${resp}=  Encrypted Provider Login  ${PUSERNAME14}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_consumer_notification_settings  ${PUSERNAME14}
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


JD-TC-GetConsumerNotificationSettings-4
    [Documentation]   Provider get notification settings without creating any early Notification settings
    ${resp}=  Encrypted Provider Login  ${PUSERNAME14}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_consumer_notification_settings  ${PUSERNAME14}  
    ${resp}=  Get Consumer Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 


JD-TC-GetConsumerNotificationSettings -UH1
    [Documentation]   Provider get notification settings without login  
    ${resp}=  Get Consumer Notification Settings
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}"
 
JD-TC-GetConsumerNotificationSettings -UH2
    [Documentation]   Consumer get notification settings
    ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Get Consumer Notification Settings
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings  "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"
