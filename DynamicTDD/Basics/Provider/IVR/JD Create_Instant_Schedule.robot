*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Run Keywords  Delete All Sessions
Force Tags        Provider Schedule
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           RequestsLibrary
Library           OperatingSystem
Library           /ebs/TDD/excelfuncs.py
Library		      /ebs/TDD/Imageupload.py
Resource          /ebs/TDD/SuperAdminKeywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/hl_providers.py


*** Test Cases ***


JD-TC-Create_Instant_Schedule-1

    [Documentation]  Create Instant Schedule


    clear_queue      ${PUSERNAME153}
    # clear_location   ${PUSERNAME153}
    clear_service    ${PUSERNAME153}
    clear_customer   ${PUSERNAME153}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME153}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    Set Suite Variable  ${user_name}  ${decrypted_data['userName']}
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}
    # Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}

    ${lid}=  Create Sample Location  
    Set Suite Variable  ${lid}
    
    ${ser_name}=   FakerLibrary.word
    Set Suite Variable    ${ser_name}
    ${resp}=   Create Sample Service  ${ser_name}
    Set Suite Variable    ${s_id}    ${resp} 

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${list}=  Create List  7
    ${list2}=  Create List  
    Set Suite Variable  ${list2}  
    ${sTime1}=  db.add_timezone_time  ${tz}  0  3
    Set Suite Variable    ${sTime1}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    Set Suite Variable    ${eTime1}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable    ${list}
    Set Suite Variable    ${DAY1}
    Set Suite Variable    ${DAY2}
    Set Suite Variable    ${sTime1}
    Set Suite Variable    ${eTime1}
    Set Suite Variable    ${schedule_name}

    ${resp}=  Create Provider Schedule  ${schedule_name}  ${recurringtype[4]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${JCstatus[0]}  ${user_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=    Get Scheduled Using Id    ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Create_Instant_Schedule-UH1

    [Documentation]  Create Instant Schedule where schedule name is empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME181}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${sTime2}=  db.add_timezone_time  ${tz}  3  5
    # ${delta}=  FakerLibrary.Random Int  min=10  max=60
    # ${eTime2}=  add_two   ${sTime2}  ${delta}

    ${resp}=  Create Provider Schedule  ${empty}  ${recurringtype[4]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${JCstatus[0]}  ${user_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422  
    Should Be Equal As Strings  "${resp.json()}"   "${NECESSARY_FIELD_MISSING}" 


JD-TC-Create_Instant_Schedule-UH3

    [Documentation]  Create Instant Schedule where list is empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME182}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${sTime4}=  db.add_timezone_time  ${tz}  7  10
    Set Suite Variable    ${sTime4}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime4}=  add_two   ${sTime4}  ${delta}
    Set Suite Variable    ${eTime4}
    ${list2}=  Create List  
    ${schedule_name}=  FakerLibrary.bs

    ${resp}=  Create Provider Schedule  ${schedule_name}  ${recurringtype[4]}  ${list2}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${JCstatus[0]}  ${user_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}    ${DAY_CANNOT_BE_EMPTY}
    

JD-TC-Create_Instant_Schedule-UH4

    [Documentation]  Create Instant Schedule where start date is empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME183}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${sTime4}=  db.add_timezone_time  ${tz}  7  10
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime4}=  add_two   ${sTime4}  ${delta}
    ${list2}=  Create List  
    ${schedule_name}=  FakerLibrary.bs

    ${resp}=  Create Provider Schedule  ${schedule_name}  ${recurringtype[4]}  ${list2}  ${empty}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${JCstatus[0]}  ${user_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}    ${DAY_CANNOT_BE_EMPTY} 

JD-TC-Create_Instant_Schedule-UH5

    [Documentation]  Create Instant Schedule where start date is past date

    ${resp}=  Encrypted Provider Login  ${PUSERNAME184}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${sTime4}=  db.add_timezone_time  ${tz}  7  10
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime4}=  add_two   ${sTime4}  ${delta}
    ${list2}=  Create List  
    ${DAY11}=  db.add_timezone_date  ${tz}  -10 
    ${schedule_name}=  FakerLibrary.bs

    ${resp}=  Create Provider Schedule  ${schedule_name}  ${recurringtype[4]}  ${list2}  ${DAY11}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${JCstatus[0]}  ${user_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}    ${APPT_START_DATE_PAST} 
    

JD-TC-Create_Instant_Schedule-UH6

    [Documentation]  Create Instant Schedule where end date is empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME185}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${sTime4}=  db.add_timezone_time  ${tz}  7  10
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime4}=  add_two   ${sTime4}  ${delta}
    ${list2}=  Create List  
    ${schedule_name}=  FakerLibrary.bs

    ${resp}=  Create Provider Schedule  ${schedule_name}  ${recurringtype[4]}  ${list2}  ${DAY1}  ${empty}  ${EMPTY}  ${sTime1}  ${eTime1}  ${JCstatus[0]}  ${user_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}    ${END_DATE_REQUIRED}

JD-TC-Create_Instant_Schedule-UH7

    [Documentation]  Create Instant Schedule where end date is past date

    ${resp}=  Encrypted Provider Login  ${PUSERNAME186}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${sTime4}=  db.add_timezone_time  ${tz}  7  10
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime4}=  add_two   ${sTime4}  ${delta}
    ${list2}=  Create List  
    ${DAY22}=  db.add_timezone_date  ${tz}  -10 
    ${schedule_name}=  FakerLibrary.bs

    ${resp}=  Create Provider Schedule  ${schedule_name}  ${recurringtype[4]}  ${list2}  ${DAY1}  ${DAY22}  ${EMPTY}  ${sTime1}  ${eTime1}  ${JCstatus[0]}  ${user_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}    ${APPT_START_END_DATE_MISMATCH}

JD-TC-Create_Instant_Schedule-UH8

    [Documentation]  Create Instant Schedule where start time is empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME153}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${sTime4}=  db.add_timezone_time  ${tz}  7  10
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime4}=  add_two   ${sTime4}  ${delta}
    ${list2}=  Create List  
    ${schedule_name}=  FakerLibrary.bs

    ${resp}=  Create Provider Schedule  ${schedule_name}  ${recurringtype[4]}  ${list2}  ${DAY1}  ${DAY2}  ${EMPTY}  ${empty}  ${eTime4}  ${JCstatus[0]}  ${user_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}    ${TIME_SLOT_NEEDED}

JD-TC-Create_Instant_Schedule-UH9

    [Documentation]  Create Instant Schedule where end time is empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME153}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${sTime4}=  db.add_timezone_time  ${tz}  7  10
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime4}=  add_two   ${sTime4}  ${delta}
    ${list2}=  Create List  
    ${DAY22}=  db.add_timezone_date  ${tz}  -10 
    ${schedule_name}=  FakerLibrary.bs

    ${resp}=  Create Provider Schedule  ${schedule_name}  ${recurringtype[4]}  ${list2}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime4}  ${empty}  ${JCstatus[0]}  ${user_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}    ${TIME_SLOT_NEEDED} 

JD-TC-Create_Instant_Schedule-UH10

    [Documentation]  Create Instant Schedule where Schedule state is disabled

    ${resp}=  Encrypted Provider Login  ${PUSERNAME187}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${sTime4}=  db.add_timezone_time  ${tz}  7  10
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime4}=  add_two   ${sTime4}  ${delta}
    ${list2}=  Create List  
    Set Suite Variable    ${list2}
    ${DAY22}=  db.add_timezone_date  ${tz}  -10 
    ${schedule_name}=  FakerLibrary.bs

    ${resp}=  Create Provider Schedule  ${schedule_name}  ${recurringtype[4]}  ${list2}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${JCstatus[1]}  ${user_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422

JD-TC-Create_Instant_Schedule-UH12

    [Documentation]  Create Instant Schedule where provider id is empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME187}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${schedule_name}=  FakerLibrary.bs

    ${resp}=  Create Provider Schedule  ${schedule_name}  ${recurringtype[4]}  ${list2}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${JCstatus[0]}  ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422

JD-TC-Create_Instant_Schedule-UH13

    [Documentation]  Create Instant Schedule with consumer login

    ${resp}=  Consumer Login  ${CUSERNAME6}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${schedule_name}=  FakerLibrary.bs

    ${resp}=  Create Provider Schedule  ${schedule_name}  ${recurringtype[4]}  ${list2}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime4}  ${eTime4}  ${JCstatus[0]}  ${user_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings    ${resp.json()}    ${NoAccess}

*** Comments ***

JD-TC-Create_Instant_Schedule-UH11

    [Documentation]  Create Instant Schedule where Schedule state is empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME153}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${schedule_name}=  FakerLibrary.bs
    

    ${resp}=  Create Provider Schedule  ${schedule_name}  ${recurringtype[4]}  ${list2}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime4}  ${eTime4}  ${list2}  ${user_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422 


JD-TC-Create_Instant_Schedule-UH2

    [Documentation]  Create Instant Schedule where recurring type is empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME153}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${sTime3}=  db.add_timezone_time  ${tz}  5  7
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime3}=  add_two   ${sTime3}  ${delta}
    ${schedule_name}=  FakerLibrary.bs

    ${resp}=  Create Provider Schedule  ${schedule_name}  ${list2}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime3}  ${eTime3}  ${JCstatus[0]}  ${user_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   422
