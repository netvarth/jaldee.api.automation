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
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 


*** Variables ***
${Zero_person_ahead}   0
${One_person_ahead}    1
${self}         0
${globaluser}         0



*** Test Cases ***

JD-TC-ConsumerNotificationSettings-1

    [Documentation]   Provider setting consumer notification settings

    ${resp}=  Encrypted Provider Login  ${PUSERNAME105}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${prov_id1}  ${decrypted_data['id']}

    clear_consumer_notification_settings  ${PUSERNAME105}
    clear_service   ${PUSERNAME105}
    clear_multilocation  ${PUSERNAME105}    
    clear_appt_schedule   ${PUSERNAME105}

    ${resp}=   Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    Set Suite Variable  ${businessName}  ${resp.json()['businessName']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[1]}' and '${resp.json()['onlinePresence']}'=='${bool[0]}'
        ${resp1}=   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
        Should Be Equal As Strings  ${resp1.status_code}  200
    ELSE IF    '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[1]}'
        ${resp1}=   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    ${msg}=  FakerLibrary.word
    ${reminder_time}=  Random Int   min=5   max=5

    ${resp}=  Create Consumer Notification Settings  ${NotificationResourceType[0]}  ${EventType[6]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  
                                  ...   ${msg}  ${reminder_time}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  

    ${resp}=  Get Consumer Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()[0]['resourceType']}       ${NotificationResourceType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['eventType']}          ${EventType[6]}
    Should Be Equal As Strings  ${resp.json()[0]['email']}              ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['sms']}                ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['pushNotification']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['commonMessage']}      ${msg}
    # Should Be Equal As Strings  ${resp.json()[0]['time']}               ${reminder_time}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7

    ${SERVICE1}=   FakerLibrary.name
    ${s_id}=  Create Sample Service  ${SERVICE1}

    
    ${q_name}=    FakerLibrary.name
    ${strt_time}=   db.subtract_timezone_time  ${tz}  0  15
    ${end_time}=    add_timezone_time  ${tz}  2  00   
    ${parallel}=   Random Int  min=1   max=1
    ${capacity}=  Random Int   min=10   max=20

    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${lid}  ${s_id}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id1}   ${resp.json()}  
    
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${account_id}  ${que_id1}  ${DAY1}  ${s_id}  ${cnote}  ${bool[0]}  ${self} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid1}  ${wid[0]}

    ${resp}=  Get consumer Waitlist By Id  ${wid1}  ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME8}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${account_id}  ${que_id1}  ${DAY1}  ${s_id}  ${cnote}  ${bool[0]}  ${self} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid2}  ${wid[0]}

    ${resp}=  Get consumer Waitlist By Id  ${wid2}  ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME105}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Waitlist Action  ${waitlist_actions[1]}    ${wid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}      waitlistStatus=${wl_status[2]}
    
    ${resp}=  Consumer Login  ${CUSERNAME8}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Communications
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}  ${globaluser}