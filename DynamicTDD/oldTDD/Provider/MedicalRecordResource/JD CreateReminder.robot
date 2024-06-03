*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Reminder
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/hl_providers.py


*** Variables ***

@{emptylist}


*** Test Cases ***

JD-TC-CreateReminder-1

    [Documentation]    Provider create a reminder for his provider consumer.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${prov_id1}  ${decrypted_data['id']}
    # Set Suite Variable  ${prov_id1}  ${resp.json()['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id1}  ${resp.json()['id']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME18}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME18}  
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${pcid18}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${pcid18}  ${resp.json()[0]['id']}
    END

    ${resp}=  Create Sample Location  
    Set Suite Variable    ${lid}    ${resp}  

    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}  
    ${eTime1}=  add_timezone_time  ${tz}  3  15  
    ${msg}=  FakerLibrary.word

    ${resp}=  Create Reminder    ${prov_id1}  ${pcid18}  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${rem_id}  ${resp.content}

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Communications
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

JD-TC-CreateReminder-2

    [Documentation]    Provider create a reminder for his provider consumer but not a jaldee consumer.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${prov_cons_no}=  Evaluate  ${PUSERNAME0}+302312

    ${resp}=  AddCustomer  ${prov_cons_no}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pcid}   ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}  
    ${eTime1}=  add_timezone_time  ${tz}  3  15  
    ${msg}=  FakerLibrary.word

    ${resp}=  Create Reminder    ${prov_id1}  ${pcid}  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${rem_id}  ${resp.content}

JD-TC-CreateReminder-3

    [Documentation]    Provider create a reminder for one day.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    clear_customer   ${PUSERNAME132}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME18}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME18}  
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid18}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid18}  ${resp.json()[0]['id']}
    END

    ${DAY1}=  db.get_date_by_timezone  ${tz}  
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}  
    ${eTime1}=  add_timezone_time  ${tz}  3  15  
    ${msg}=  FakerLibrary.word

    ${resp}=  Create Reminder    ${prov_id1}  ${pcid18}  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY1}  ${EMPTY}  ${sTime1}  ${eTime1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${rem_id}  ${resp.content}

JD-TC-CreateReminder-4

    [Documentation]    Provider create a reminder without mentioning the start date.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}  
    ${eTime1}=  add_timezone_time  ${tz}  3  15  
    ${msg}=  FakerLibrary.word

    ${resp}=  Create Reminder    ${prov_id1}  ${pcid18}  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${EMPTY}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${Invalid_Date_reminders}"

JD-TC-CreateReminder-5

    [Documentation]    Provider create a reminder for his provider consumers family member.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${firstname1}=  FakerLibrary.first_name
    ${lastname1}=  FakerLibrary.last_name
    ${dob1}=  FakerLibrary.Date
    ${gender1}=  Random Element    ${Genderlist}
    ${Familymember_ph}=  Evaluate  ${PUSERNAME0}+300000

    ${resp}=  AddFamilyMemberByProviderWithPhoneNo  ${pcid18}  ${firstname1}  ${lastname1}  ${dob1}  ${gender1}  ${Familymember_ph}
    Log  ${resp.json()}
    Set Suite Variable  ${mem_id0}  ${resp.json()}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}  
    ${eTime1}=  add_timezone_time  ${tz}  3  15  
    ${msg}=  FakerLibrary.word

    ${resp}=  Create Reminder    ${prov_id1}  ${mem_id0}  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${rem_id}  ${resp.content}

JD-TC-CreateReminder-6

    [Documentation]    Provider create a reminder for a jaldee consumers family member.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-CreateReminder-7

    [Documentation]    Provider create a reminder with more than one number of occurance.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}  
    ${eTime1}=  add_timezone_time  ${tz}  3  15  
    ${msg}=  FakerLibrary.word
    ${noo}=   Random Int  min=2   max=5 

    ${resp}=  Create Reminder    ${prov_id1}  ${pcid18}  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${noo}  ${sTime1}  ${eTime1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${rem_id}  ${resp.content}

JD-TC-CreateReminder-8

    [Documentation]    Provider create a reminder for more than one provider consumer with same schedule.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME19}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME19}  
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${pcid19}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${pcid19}  ${resp.json()[0]['id']}
    END

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}  
    ${eTime1}=  add_timezone_time  ${tz}  3  15  
    ${msg}=  FakerLibrary.word
    
    ${resp}=  Create Reminder    ${prov_id1}  ${pcid19}  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${rem_id1}  ${resp.content}

JD-TC-CreateReminder-9

    [Documentation]    Provider create a reminder for more than one provider consumer with different schedule.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME20}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME20}  
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${pcid20}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${pcid20}  ${resp.json()[0]['id']}
    END

    ${DAY1}=  db.add_timezone_date  ${tz}   3
    ${DAY2}=  db.add_timezone_date  ${tz}  11   
    ${list}=  Create List  1  2  3  4
    ${sTime1}=  add_timezone_time  ${tz}  1  15  
    ${eTime1}=  add_timezone_time  ${tz}  4  15  
    ${msg}=  FakerLibrary.word
    
    ${resp}=  Create Reminder    ${prov_id1}  ${pcid19}  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${rem_id1}  ${resp.content}

JD-TC-CreateReminder-10

    [Documentation]    Provider create a reminder with same start and end dates.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY1}=  db.add_timezone_date  ${tz}  1  
    ${DAY2}=  db.add_timezone_date  ${tz}  1  
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}  
    ${eTime1}=  add_timezone_time  ${tz}  3  15  
    ${msg}=  FakerLibrary.word

    ${resp}=  Create Reminder    ${prov_id1}  ${pcid19}  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${rem_id1}  ${resp.content}

JD-TC-CreateReminder-11

    [Documentation]    Provider create a reminder with same start and end time.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY1}=  db.add_timezone_date  ${tz}  1  
    ${DAY2}=  db.add_timezone_date  ${tz}  4  
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}  
    ${eTime1}=  db.get_time_by_timezone  ${tz}
    ${msg}=  FakerLibrary.word

    ${resp}=  Create Reminder    ${prov_id1}  ${pcid19}  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${rem_id1}  ${resp.content}

JD-TC-CreateReminder-UH1

    [Documentation]    Provider create a reminder for another providers provider consumer.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME133}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME14}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME14}  
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${pcid14}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${pcid14}  ${resp.json()[0]['id']}
    END

    ${resp}=  ProviderLogout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}  
    ${eTime1}=  add_timezone_time  ${tz}  3  15  
    ${msg}=  FakerLibrary.word

    ${resp}=  Create Reminder    ${prov_id1}  ${pcid14}  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"   "${NO_PERMISSION}"

JD-TC-CreateReminder-UH2

    [Documentation]    Provider create a reminder with another providers id.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME133}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}  
    ${eTime1}=  add_timezone_time  ${tz}  3  15  
    ${msg}=  FakerLibrary.word

    ${resp}=  Create Reminder    ${prov_id1}  ${pcid14}  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"   "${NO_PERMISSION}"

JD-TC-CreateReminder-UH3

    [Documentation]    Provider create a reminder without mentioning the end date.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY1}=  db.get_date_by_timezone  ${tz}   
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}  
    ${eTime1}=  add_timezone_time  ${tz}  3  15  
    ${msg}=  FakerLibrary.word

    ${resp}=  Create Reminder    ${prov_id1}  ${pcid18}  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${REM_END_DATE_REQUIRED}"

JD-TC-CreateReminder-UH4

    [Documentation]    Provider create a reminder without mentioning the start time.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    ${eTime1}=  add_timezone_time  ${tz}  3  15  
    ${msg}=  FakerLibrary.word

    ${resp}=  Create Reminder    ${prov_id1}  ${pcid18}  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${EMPTY}  ${eTime1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${rem_id}  ${resp.content}

JD-TC-CreateReminder-UH5

    [Documentation]    Provider create a reminder without mentioning the end time.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}  
    ${msg}=  FakerLibrary.word

    ${resp}=  Create Reminder    ${prov_id1}  ${pcid18}  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${EMPTY} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${rem_id}  ${resp.content}

JD-TC-CreateReminder-UH6

    [Documentation]    Provider create a reminder without any msg.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}  
    ${eTime1}=  add_timezone_time  ${tz}  3  15  
    
    ${resp}=  Create Reminder    ${prov_id1}  ${pcid18}  ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${INVALID_MESSAGE}"

JD-TC-CreateReminder-UH7

    [Documentation]    Provider create a reminder without login.

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}  
    ${eTime1}=  add_timezone_time  ${tz}  3  15  
    ${msg}=  FakerLibrary.word
    
    ${resp}=  Create Reminder    ${prov_id1}  ${pcid19}  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.content}  "${SESSION_EXPIRED}"

JD-TC-CreateReminder-UH8

    [Documentation]    Consumer try to create a reminder.

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}  
    ${eTime1}=  add_timezone_time  ${tz}  3  15  
    ${msg}=  FakerLibrary.word
    
    ${resp}=  Create Reminder    ${prov_id1}  ${pcid19}  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  ${resp.content}  "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-CreateReminder-UH9

    [Documentation]    create a reminder with invalid provider id.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}  
    ${eTime1}=  add_timezone_time  ${tz}  3  15  
    ${msg}=  FakerLibrary.word
    ${invalid_prov}=   Random Int  min=0000   max=0000
    
    ${resp}=  Create Reminder    ${invalid_prov}  ${pcid19}  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.content}  "${PROVIDER_NOT_EXIST}"

JD-TC-CreateReminder-UH10

    [Documentation]    create a reminder with invalid provider consumer id.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}  
    ${eTime1}=  add_timezone_time  ${tz}  3  15  
    ${msg}=  FakerLibrary.word
    ${invalid_provcons}=   Random Int  min=0000   max=0000
    
    ${resp}=  Create Reminder    ${prov_id1}  ${invalid_provcons}  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.content}  "${PROVIDER_CONSUMER_NOT_FOUND}"

JD-TC-CreateReminder-UH11

    [Documentation]    create a reminder without provider id.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}  
    ${eTime1}=  add_timezone_time  ${tz}  3  15  
    ${msg}=  FakerLibrary.word
    
    ${resp}=  Create Reminder    ${EMPTY}  ${pcid19}  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419

JD-TC-CreateReminder-UH12

    [Documentation]    create a reminder without provider consumer id.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}  
    ${eTime1}=  add_timezone_time  ${tz}  3  15  
    ${msg}=  FakerLibrary.word
    
    ${resp}=  Create Reminder    ${prov_id1}  ${EMPTY}  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419

JD-TC-CreateReminder-UH13

    [Documentation]    Provider create a reminder with start date as the past date and end date in future date.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY1}=  db.subtract_timezone_date  ${tz}   1
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}  
    ${eTime1}=  add_timezone_time  ${tz}  3  15  
    ${msg}=  FakerLibrary.word

    ${resp}=  Create Reminder    ${prov_id1}  ${pcid19}  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${REMINDER_START_DATE_PAST}"

JD-TC-CreateReminder-UH14

    [Documentation]    Provider create a reminder with start date as the today date and end date as past date.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.subtract_timezone_date  ${tz}   1    
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}  
    ${eTime1}=  add_timezone_time  ${tz}  3  15  
    ${msg}=  FakerLibrary.word

    ${resp}=  Create Reminder    ${prov_id1}  ${pcid19}  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${REMINDER_END_DATE_PAST}"

JD-TC-CreateReminder-UH15

    [Documentation]    Provider create a reminder with start date as the future date.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY1}=  db.add_timezone_date  ${tz}  9
    ${DAY2}=  db.add_timezone_date  ${tz}  4  
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}  
    ${eTime1}=  add_timezone_time  ${tz}  3  15  
    ${msg}=  FakerLibrary.word

    ${resp}=  Create Reminder    ${prov_id1}  ${pcid19}  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${INVALID_START_END_DATE}"


JD-TC-CreateReminder-22

    [Documentation]    create a reminder after deactivate the provider consumer account.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${firstName}=  FakerLibrary.name
    Set Suite Variable    ${firstName}
    ${lastName}=  FakerLibrary.last_name
    Set Suite Variable    ${lastName}
    ${primaryMobileNo}    Generate random string    10    123456789
    ${primaryMobileNo}    Convert To Integer  ${primaryMobileNo}
    Set Suite Variable    ${primaryMobileNo}
    ${email}=    FakerLibrary.Email
    Set Suite Variable    ${email}

    ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${accountId1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   12
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    Customer Logout 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email}    ${primaryMobileNo}     ${accountId1}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200    
   
    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId1}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid1}    ${resp.json()['providerConsumer']}

    ${resp}=    SPConsumer Deactivation
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}  
    ${eTime1}=  add_timezone_time  ${tz}  3  15  
    ${msg}=  FakerLibrary.word

    ${resp}=  Create Reminder    ${prov_id1}  ${cid1}  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${CUSTOMER_IS_INACTIVE}"

JD-TC-CreateReminder-24

    [Documentation]    create a reminder after updating consumer's phone number.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${alt_Number}    Generate random string    5    0123456789
    ${alt_Number}    Convert To Integer  ${alt_Number}
    ${PO_Number}=  Get Random Valid Phone Number
    Log  ${PO_Number}
    ${country_code}=  Set Variable  ${PO_Number.country_code}
    ${CUSERNAME_0}=  Set Variable  ${PO_Number.national_number}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${address}=  FakerLibrary.Address
    ${alternativeNo}=  Evaluate  ${CUSERNAME_0}+${alt_Number}
    Set Test Variable  ${email}  ${C_Email}${CUSERNAME_0}.${test_mail}
    ${alt_Number2}    Generate random string    10   7412369852


   ${resp}=    Send Otp For Login    ${CUSERNAME_0}    ${accountId1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${CUSERNAME_0}   12
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${tokens}  ${resp.json()['token']}

    ${resp}=    Customer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email}    ${CUSERNAME_0}     ${accountId1}  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200    

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME_0}    ${accountId1}  ${tokens} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid2}    ${resp.json()['providerConsumer']}


    ${resp}=  Update ProviderConsumer   ${cid2}  firstName=${firstname}  lastName=${lastname}    dob=${dob}  
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Send Verify Login Consumer   ${alt_Number2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Verify Login Consumer   ${alt_Number2}  5
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

   ${resp}=    Send Otp For Login    ${alt_Number2}    ${accountId1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${alt_Number2}   12
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${tokenfornew}  ${resp.json()['token']}


    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${alt_Number2}    ${accountId1}  ${tokenfornew}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid3}    ${resp.json()['providerConsumer']}


    ${resp}=   Get ProviderConsumer   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['phoneNo']}  ${alt_Number2}

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}  
    ${eTime1}=  add_timezone_time  ${tz}  3  15  
    ${msg}=  FakerLibrary.word
    ${resp}=  Create Reminder    ${prov_id1}  ${cid3}  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

*** Comments ***


JD-TC-CreateReminder-23

    [Documentation]    create a reminder after delete the consumer.









 
 
 
 
 
 
 
  

  
  
  

  

  

  