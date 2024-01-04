*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Reminder
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/musers.py
Variables         /ebs/TDD/varfiles/hl_musers.py


*** Variables ***

@{emptylist}


*** Test Cases ***


JD-TC-GetRemindersWithFilter-1

    [Documentation]    Provider create a reminder for his provider consumer.

    ${resp}=  Consumer Login  ${CUSERNAME14}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${prov_id1}  ${decrypted_data['id']}
    
    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id1}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[0]}'
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

    clear_customer    ${PUSERNAME190}
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME14}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME14}   firstName=${fname}  lastName=${lname} 
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${pcid18}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${pcid18}  ${resp.json()[0]['id']}
    END

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  
    ${sTime1}=  db.get_time_by_timezone  ${tz}  
    ${eTime1}=  db.add_timezone_time  ${tz}  3  15
    ${msg}=  FakerLibrary.word

    ${resp}=  Create Reminder    ${prov_id1}  ${pcid18}  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${recurringtype[4]}  ${list}  ${DAY1}  ${DAY1}  ${EMPTY}  ${sTime1}  ${eTime1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${rem_id}  ${resp.content}


    ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Reminder Notification
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=  Consumer Login  ${CUSERNAME14}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep  2s
    ${resp}=  Get Consumer Communications
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}             ${prov_id1}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME190}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Reminders With Filter  completed-eq=${bool[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Reminders With Filter  completed-eq=${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['id']}                                   ${rem_id1}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['startDate']}                ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['terminator']['endDate']}    ${DAY2}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['timeSlots'][0]['sTime']}    ${sTime1}
    Should Be Equal As Strings  ${resp.json()[0]['schedule']['timeSlots'][0]['eTime']}    ${eTime1}
    Should Be Equal As Strings  ${resp.json()[0]['provider']['id']}                       ${prov_id1}
    Should Be Equal As Strings  ${resp.json()[0]['providerConsumer']['id']}               ${pcid18}
    Should Be Equal As Strings  ${resp.json()[0]['message']}                              ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['reminderSource']['Email']}              ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['reminderSource']['Sms']}                ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['reminderSource']['PushNotification']}   ${bool[1]}
