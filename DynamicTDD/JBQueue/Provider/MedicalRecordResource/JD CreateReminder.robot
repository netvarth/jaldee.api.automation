*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Reminder
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/musers.py
Variables         /ebs/TDD/varfiles/hl_musers.py


*** Variables ***

@{emptylist}


*** Test Cases ***

JD-TC-CreateReminder-1

    [Documentation]    Provider create a reminder for his provider consumer.

    ${resp}=  Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${prov_id1}  ${resp.json()['id']}

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

    ${DAY1}=  get_date
    ${DAY2}=  add_date  10    
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time  
    ${eTime1}=  add_time  3  15
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

    ${resp}=  Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${prov_cons_no}=  Evaluate  ${PUSERNAME0}+302312

    ${resp}=  AddCustomer  ${prov_cons_no}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pcid}   ${resp.json()}

    ${DAY1}=  get_date
    ${DAY2}=  add_date  10    
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time  
    ${eTime1}=  add_time  3  15
    ${msg}=  FakerLibrary.word

    ${resp}=  Create Reminder    ${prov_id1}  ${pcid}  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${rem_id}  ${resp.content}

JD-TC-CreateReminder-3

    [Documentation]    Provider create a reminder for one day.

    ${resp}=  Provider Login  ${PUSERNAME132}  ${PASSWORD}
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

    ${DAY1}=  get_date  
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time  
    ${eTime1}=  add_time  3  15
    ${msg}=  FakerLibrary.word

    ${resp}=  Create Reminder    ${prov_id1}  ${pcid18}  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY1}  ${EMPTY}  ${sTime1}  ${eTime1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${rem_id}  ${resp.content}

JD-TC-CreateReminder-4

    [Documentation]    Provider create a reminder without mentioning the end date.

    ${resp}=  Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY2}=  add_date  10    
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time  
    ${eTime1}=  add_time  3  15
    ${msg}=  FakerLibrary.word

    ${resp}=  Create Reminder    ${prov_id1}  ${pcid18}  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${EMPTY}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${rem_id}  ${resp.content}

JD-TC-CreateReminder-5

    [Documentation]    Provider create a reminder for his provider consumers family member.

    ${resp}=  Provider Login  ${PUSERNAME132}  ${PASSWORD}
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
    
    ${DAY1}=  get_date
    ${DAY2}=  add_date  10    
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time  
    ${eTime1}=  add_time  3  15
    ${msg}=  FakerLibrary.word

    ${resp}=  Create Reminder    ${prov_id1}  ${mem_id0}  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${rem_id}  ${resp.content}

JD-TC-CreateReminder-6

    [Documentation]    Provider create a reminder for a jaldee consumers family member.

    ${resp}=  Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-CreateReminder-7

    [Documentation]    Provider create a reminder with more than one number of occurance.

    ${resp}=  Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY1}=  get_date
    ${DAY2}=  add_date  10    
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time  
    ${eTime1}=  add_time  3  15
    ${msg}=  FakerLibrary.word
    ${noo}=   Random Int  min=2   max=5 

    ${resp}=  Create Reminder    ${prov_id1}  ${pcid18}  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${noo}  ${sTime1}  ${eTime1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${rem_id}  ${resp.content}

JD-TC-CreateReminder-8

    [Documentation]    Provider create a reminder for more than one provider consumer with same schedule.

    ${resp}=  Provider Login  ${PUSERNAME132}  ${PASSWORD}
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

    ${DAY1}=  get_date
    ${DAY2}=  add_date  10    
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time  
    ${eTime1}=  add_time  3  15
    ${msg}=  FakerLibrary.word
    
    ${resp}=  Create Reminder    ${prov_id1}  ${pcid19}  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${rem_id1}  ${resp.content}

JD-TC-CreateReminder-9

    [Documentation]    Provider create a reminder for more than one provider consumer with different schedule.

    ${resp}=  Provider Login  ${PUSERNAME132}  ${PASSWORD}
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

    ${DAY1}=  add_date   3
    ${DAY2}=  add_date  11   
    ${list}=  Create List  1  2  3  4
    ${sTime1}=  add_time  1  15
    ${eTime1}=  add_time  4  15
    ${msg}=  FakerLibrary.word
    
    ${resp}=  Create Reminder    ${prov_id1}  ${pcid19}  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${rem_id1}  ${resp.content}

JD-TC-CreateReminder-10

    [Documentation]    Provider create a reminder with same start and end dates.

    ${resp}=  Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY1}=  add_date  1
    ${DAY2}=  add_date  1
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time  
    ${eTime1}=  add_time  3  15
    ${msg}=  FakerLibrary.word

    ${resp}=  Create Reminder    ${prov_id1}  ${pcid19}  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${rem_id1}  ${resp.content}

JD-TC-CreateReminder-11

    [Documentation]    Provider create a reminder with same start and end time.

    ${resp}=  Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY1}=  add_date  1
    ${DAY2}=  add_date  4
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time  
    ${eTime1}=  db.get_time
    ${msg}=  FakerLibrary.word

    ${resp}=  Create Reminder    ${prov_id1}  ${pcid19}  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${rem_id1}  ${resp.content}

JD-TC-CreateReminder-UH1

    [Documentation]    Provider create a reminder for another providers provider consumer.

    ${resp}=  Provider Login  ${PUSERNAME133}  ${PASSWORD}
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

    ${resp}=  Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${DAY1}=  get_date
    ${DAY2}=  add_date  10    
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time  
    ${eTime1}=  add_time  3  15
    ${msg}=  FakerLibrary.word

    ${resp}=  Create Reminder    ${prov_id1}  ${pcid14}  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"   "${NO_PERMISSION}"

JD-TC-CreateReminder-UH2

    [Documentation]    Provider create a reminder with another providers id.

    ${resp}=  Provider Login  ${PUSERNAME133}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY1}=  get_date
    ${DAY2}=  add_date  10    
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time  
    ${eTime1}=  add_time  3  15
    ${msg}=  FakerLibrary.word

    ${resp}=  Create Reminder    ${prov_id1}  ${pcid14}  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"   "${NO_PERMISSION}"

JD-TC-CreateReminder-UH3

    [Documentation]    Provider create a reminder without mentioning the end date.

    ${resp}=  Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY1}=  get_date   
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time  
    ${eTime1}=  add_time  3  15
    ${msg}=  FakerLibrary.word

    ${resp}=  Create Reminder    ${prov_id1}  ${pcid18}  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${REM_END_DATE_REQUIRED}"

JD-TC-CreateReminder-UH4

    [Documentation]    Provider create a reminder without mentioning the start time.

    ${resp}=  Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY1}=  get_date
    ${DAY2}=  add_date  10    
    ${list}=  Create List  1  2  3  4  5  6  7
    ${eTime1}=  add_time  3  15
    ${msg}=  FakerLibrary.word

    ${resp}=  Create Reminder    ${prov_id1}  ${pcid18}  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${EMPTY}  ${eTime1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${rem_id}  ${resp.content}

JD-TC-CreateReminder-UH5

    [Documentation]    Provider create a reminder without mentioning the end time.

    ${resp}=  Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY1}=  get_date
    ${DAY2}=  add_date  10    
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time  
    ${msg}=  FakerLibrary.word

    ${resp}=  Create Reminder    ${prov_id1}  ${pcid18}  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${EMPTY} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${rem_id}  ${resp.content}

JD-TC-CreateReminder-UH6

    [Documentation]    Provider create a reminder without any msg.

    ${resp}=  Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY1}=  get_date
    ${DAY2}=  add_date  10    
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time  
    ${eTime1}=  add_time  3  15
    
    ${resp}=  Create Reminder    ${prov_id1}  ${pcid18}  ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${INVALID_MESSAGE}"

JD-TC-CreateReminder-UH7

    [Documentation]    Provider create a reminder without login.

    ${DAY1}=  get_date
    ${DAY2}=  add_date  10    
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time  
    ${eTime1}=  add_time  3  15
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

    ${DAY1}=  get_date
    ${DAY2}=  add_date  10    
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time  
    ${eTime1}=  add_time  3  15
    ${msg}=  FakerLibrary.word
    
    ${resp}=  Create Reminder    ${prov_id1}  ${pcid19}  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  ${resp.content}  "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-CreateReminder-UH9

    [Documentation]    create a reminder with invalid provider id.

    ${resp}=  Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY1}=  get_date
    ${DAY2}=  add_date  10    
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time  
    ${eTime1}=  add_time  3  15
    ${msg}=  FakerLibrary.word
    ${invalid_prov}=   Random Int  min=0000   max=0000
    
    ${resp}=  Create Reminder    ${invalid_prov}  ${pcid19}  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.content}  "${PROVIDER_NOT_EXIST}"

JD-TC-CreateReminder-UH10

    [Documentation]    create a reminder with invalid provider consumer id.

    ${resp}=  Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY1}=  get_date
    ${DAY2}=  add_date  10    
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time  
    ${eTime1}=  add_time  3  15
    ${msg}=  FakerLibrary.word
    ${invalid_provcons}=   Random Int  min=0000   max=0000
    
    ${resp}=  Create Reminder    ${prov_id1}  ${invalid_provcons}  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.content}  "${PROVIDER_CONSUMER_NOT_FOUND}"

JD-TC-CreateReminder-UH11

    [Documentation]    create a reminder without provider id.

    ${resp}=  Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY1}=  get_date
    ${DAY2}=  add_date  10    
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time  
    ${eTime1}=  add_time  3  15
    ${msg}=  FakerLibrary.word
    
    ${resp}=  Create Reminder    ${EMPTY}  ${pcid19}  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419

JD-TC-CreateReminder-UH12

    [Documentation]    create a reminder without provider consumer id.

    ${resp}=  Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY1}=  get_date
    ${DAY2}=  add_date  10    
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time  
    ${eTime1}=  add_time  3  15
    ${msg}=  FakerLibrary.word
    
    ${resp}=  Create Reminder    ${prov_id1}  ${EMPTY}  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419

JD-TC-CreateReminder-UH13

    [Documentation]    Provider create a reminder with start date as the past date.

    ${resp}=  Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY1}=  subtract_date  1
    ${DAY2}=  add_date  10    
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time  
    ${eTime1}=  add_time  3  15
    ${msg}=  FakerLibrary.word

    ${resp}=  Create Reminder    ${prov_id1}  ${pcid19}  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${REMINDER_START_DATE_PAST}"

JD-TC-CreateReminder-UH14

    [Documentation]    Provider create a reminder with start date as the past date.

    ${resp}=  Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY1}=  get_date
    ${DAY2}=  subtract_date  1    
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time  
    ${eTime1}=  add_time  3  15
    ${msg}=  FakerLibrary.word

    ${resp}=  Create Reminder    ${prov_id1}  ${pcid19}  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${REMINDER_END_DATE_PAST}"

JD-TC-CreateReminder-UH15

    [Documentation]    Provider create a reminder with start date as the past date.

    ${resp}=  Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY1}=  add_date  9
    ${DAY2}=  add_date  4
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time  
    ${eTime1}=  add_time  3  15
    ${msg}=  FakerLibrary.word

    ${resp}=  Create Reminder    ${prov_id1}  ${pcid19}  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${INVALID_START_END_DATE}"

*** comment ***
JD-TC-CreateReminder-22

    [Documentation]    create a reminder after deactivate the provider consumer account.


JD-TC-CreateReminder-23

    [Documentation]    create a reminder after delete the consumer.


JD-TC-CreateReminder-24

    [Documentation]    create a reminder after updating consumer's phone number.


 
 
 
 
 
 
 
  

  
  
  

  

  

  