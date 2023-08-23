*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Run Keywords  Delete All Sessions
Force Tags        Questionnaire
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
Variables         /ebs/TDD/varfiles/musers.py
Variables         /ebs/TDD/varfiles/hl_musers.py


*** Test Cases ***


JD-TC-Create_Provider_Schedule-1

    [Documentation]  Create Provider Schedule

    ${resp}=  Provider Login  ${PUSERNAME14}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${user_id}    ${resp.json()['id']}
    Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}

    ${lid}=  Create Sample Location  
    Set Suite Variable  ${lid}
    
    ${ser_name}=   FakerLibrary.word
    Set Suite Variable    ${ser_name}
    ${resp}=   Create Sample Service  ${ser_name}
    Set Suite Variable    ${s_id}    ${resp} 

    ${DAY1}=  get_date
    ${DAY2}=  add_date  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_time  0  15
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${resp}=  Create Provider Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${JCstatus[0]}  ${user_id}
    Log  ${resp.json()}
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=    Get Scheduled Using Id    ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}                                      ${schedule_name}
    Should Be Equal As Strings  ${resp.json()['scheduleTime']['recurringType']}             ${recurringtype[1]}  
    Should Be Equal As Strings  ${resp.json()['scheduleTime']['repeatIntervals']}           ${list}
    Should Be Equal As Strings  ${resp.json()['scheduleTime']['startDate']}                 ${DAY1}
    Should Be Equal As Strings  ${resp.json()['scheduleTime']['terminator']['endDate']}     ${DAY2}
    Should Be Equal As Strings  ${resp.json()['scheduleTime']['timeSlots'][0]['sTime']}     ${sTime1}
    Should Be Equal As Strings  ${resp.json()['scheduleTime']['timeSlots'][0]['eTime']}     ${eTime1}
    Should Be Equal As Strings  ${resp.json()['scheduleState']}                             ${JCstatus[0]}
    Should Be Equal As Strings  ${resp.json()['providerId']}                                ${user_id}


JD-TC-Create_Provider_Schedule-2

    [Documentation]   Create a schedule with same details of another provider
    ${resp}=  Provider Login  ${PUSERNAME143}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${user_id}    ${resp.json()['id']}
    Set Test Variable    ${user_name}    ${resp.json()['userName']}

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}

    ${lid}=  Create Sample Location  
    Set Suite Variable  ${lid}
    
    ${ser_name}=   FakerLibrary.word
    Set Suite Variable    ${ser_name}
    ${resp}=   Create Sample Service  ${ser_name}
    Set Suite Variable    ${s_id}    ${resp} 

    ${DAY1}=  get_date
    ${DAY2}=  add_date  11     
    ${DAY3}=  add_date  13 
    ${DAY4}=  add_date  14     
    ${DAY5}=  add_date  16 
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_time  0  15
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${schedule_name1}=  FakerLibrary.bs
    ${resp}=  Create Provider Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY2}  ${DAY3}  ${EMPTY}  ${sTime1}  ${eTime1}  ${JCstatus[0]}  ${user_id}
    Log  ${resp.json()}
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=    Get Scheduled Using Id    ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}                                      ${schedule_name}
    Should Be Equal As Strings  ${resp.json()['scheduleTime']['recurringType']}             ${recurringtype[1]}  
    Should Be Equal As Strings  ${resp.json()['scheduleTime']['repeatIntervals']}           ${list}
    Should Be Equal As Strings  ${resp.json()['scheduleTime']['startDate']}                 ${DAY2}
    Should Be Equal As Strings  ${resp.json()['scheduleTime']['terminator']['endDate']}     ${DAY3}
    Should Be Equal As Strings  ${resp.json()['scheduleTime']['timeSlots'][0]['sTime']}     ${sTime1}
    Should Be Equal As Strings  ${resp.json()['scheduleTime']['timeSlots'][0]['eTime']}     ${eTime1}
    Should Be Equal As Strings  ${resp.json()['scheduleState']}                             ${JCstatus[0]}
    Should Be Equal As Strings  ${resp.json()['providerId']}                                ${user_id}
    
    ${resp}=  Create Provider Schedule  ${schedule_name1}  ${recurringtype[1]}  ${list}  ${DAY4}  ${DAY5}  ${EMPTY}  ${sTime1}  ${eTime1}  ${JCstatus[1]}  ${user_id}
    Log  ${resp.json()}
   Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=    Get Scheduled Using Id    ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}                                      ${schedule_name1}
    Should Be Equal As Strings  ${resp.json()['scheduleTime']['recurringType']}             ${recurringtype[1]}  
    Should Be Equal As Strings  ${resp.json()['scheduleTime']['repeatIntervals']}           ${list}
    Should Be Equal As Strings  ${resp.json()['scheduleTime']['startDate']}                 ${DAY4}
    Should Be Equal As Strings  ${resp.json()['scheduleTime']['terminator']['endDate']}     ${DAY5}
    Should Be Equal As Strings  ${resp.json()['scheduleTime']['timeSlots'][0]['sTime']}     ${sTime1}
    Should Be Equal As Strings  ${resp.json()['scheduleTime']['timeSlots'][0]['eTime']}     ${eTime1}
    Should Be Equal As Strings  ${resp.json()['scheduleState']}                             ${JCstatus[0]}
    Should Be Equal As Strings  ${resp.json()['providerId']}                                ${user_id}
    

JD-TC-Create_Provider_Schedule-3

    [Documentation]   Create 2 schedules with same time on different days
    ${resp}=  Provider Login  ${PUSERNAME143}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${user_id}    ${resp.json()['id']}
    Set Test Variable    ${user_name}    ${resp.json()['userName']}

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}

    ${lid}=  Create Sample Location  
    Set Suite Variable  ${lid}
    
    ${ser_name}=   FakerLibrary.word
    Set Suite Variable    ${ser_name}
    ${resp}=   Create Sample Service  ${ser_name}
    Set Suite Variable    ${s_id}    ${resp} 

    ${DAY1}=  get_date
    ${DAY2}=  add_date  23     
    ${DAY3}=  add_date  24 
    ${DAY4}=  add_date  25     
    ${DAY5}=  add_date  26 
    ${list}=  Create List  1  2  
    ${list1}=  Create List  3  4 
    ${sTime1}=  add_time  0  15
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${schedule_name1}=  FakerLibrary.bs
    ${resp}=  Create Provider Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY2}  ${DAY3}  ${EMPTY}  ${sTime1}  ${eTime1}  ${JCstatus[0]}  ${user_id}
    Log  ${resp.json()}
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=    Get Scheduled Using Id    ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}                                      ${schedule_name}
    Should Be Equal As Strings  ${resp.json()['scheduleTime']['recurringType']}             ${recurringtype[1]}  
    Should Be Equal As Strings  ${resp.json()['scheduleTime']['repeatIntervals']}           ${list}
    Should Be Equal As Strings  ${resp.json()['scheduleTime']['startDate']}                 ${DAY2}
    Should Be Equal As Strings  ${resp.json()['scheduleTime']['terminator']['endDate']}     ${DAY3}
    Should Be Equal As Strings  ${resp.json()['scheduleTime']['timeSlots'][0]['sTime']}     ${sTime1}
    Should Be Equal As Strings  ${resp.json()['scheduleTime']['timeSlots'][0]['eTime']}     ${eTime1}
    Should Be Equal As Strings  ${resp.json()['scheduleState']}                             ${JCstatus[0]}
    Should Be Equal As Strings  ${resp.json()['providerId']}                                ${user_id}

    ${resp}=  Create Provider Schedule  ${schedule_name1}  ${recurringtype[1]}  ${list1}  ${DAY4}  ${DAY5}  ${EMPTY}  ${sTime1}  ${eTime1}  ${JCstatus[1]}  ${user_id}
    Log  ${resp.json()}
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=    Get Scheduled Using Id    ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}                                      ${schedule_name1}
    Should Be Equal As Strings  ${resp.json()['scheduleTime']['recurringType']}             ${recurringtype[1]}  
    Should Be Equal As Strings  ${resp.json()['scheduleTime']['repeatIntervals']}           ${list1}
    Should Be Equal As Strings  ${resp.json()['scheduleTime']['startDate']}                 ${DAY4}
    Should Be Equal As Strings  ${resp.json()['scheduleTime']['terminator']['endDate']}     ${DAY5}
    Should Be Equal As Strings  ${resp.json()['scheduleTime']['timeSlots'][0]['sTime']}     ${sTime1}
    Should Be Equal As Strings  ${resp.json()['scheduleTime']['timeSlots'][0]['eTime']}     ${eTime1}
   Should Be Equal As Strings   ${resp.json()['scheduleState']}                              ${JCstatus[0]}
    Should Be Equal As Strings  ${resp.json()['providerId']}                                ${user_id}
    
    Set Suite Variable  ${sch_id}  ${resp.json()}

JD-TC-Create_Provider_Schedule-4

    [Documentation]  Create one schedule and disabled that schedule.

    ${resp}=  Provider Login  ${PUSERNAME14}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${user_id}    ${resp.json()['id']}
    Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}

    ${lid}=  Create Sample Location  
    Set Suite Variable  ${lid}
    
    ${ser_name}=   FakerLibrary.word
    Set Suite Variable    ${ser_name}
    ${resp}=   Create Sample Service  ${ser_name}
    Set Suite Variable    ${s_id}    ${resp} 

    ${DAY1}=  add_date  27     
    ${DAY2}=  add_date  29      
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_time  0  15
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${resp}=  Create Provider Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${JCstatus[0]}  ${user_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=    Get Scheduled Using Id    ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}                                      ${schedule_name}
    Should Be Equal As Strings  ${resp.json()['scheduleTime']['recurringType']}             ${recurringtype[1]}  
    Should Be Equal As Strings  ${resp.json()['scheduleTime']['repeatIntervals']}           ${list}
    Should Be Equal As Strings  ${resp.json()['scheduleTime']['startDate']}                 ${DAY1}
    Should Be Equal As Strings  ${resp.json()['scheduleTime']['terminator']['endDate']}     ${DAY2}
    Should Be Equal As Strings  ${resp.json()['scheduleTime']['timeSlots'][0]['sTime']}     ${sTime1}
    Should Be Equal As Strings  ${resp.json()['scheduleTime']['timeSlots'][0]['eTime']}     ${eTime1}
    Should Be Equal As Strings  ${resp.json()['scheduleState']}                             ${JCstatus[0]}
    Should Be Equal As Strings  ${resp.json()['providerId']}                                ${user_id}

    ${resp}=    Enable And Disable A Schedule    ${JCstatus[1]}    ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Scheduled Using Id    ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}                                      ${schedule_name}
    Should Be Equal As Strings  ${resp.json()['scheduleTime']['recurringType']}             ${recurringtype[1]}  
    Should Be Equal As Strings  ${resp.json()['scheduleTime']['repeatIntervals']}           ${list}
    Should Be Equal As Strings  ${resp.json()['scheduleTime']['startDate']}                 ${DAY1}
    Should Be Equal As Strings  ${resp.json()['scheduleTime']['terminator']['endDate']}     ${DAY2}
    Should Be Equal As Strings  ${resp.json()['scheduleTime']['timeSlots'][0]['sTime']}     ${sTime1}
    Should Be Equal As Strings  ${resp.json()['scheduleTime']['timeSlots'][0]['eTime']}     ${eTime1}
    Should Be Equal As Strings  ${resp.json()['scheduleState']}                             ${JCstatus[1]}
    Should Be Equal As Strings  ${resp.json()['providerId']}                                ${user_id}


JD-TC-Create_Provider_Schedule-UH1

    [Documentation]  Schedule Conflict

    ${resp}=  Provider Login  ${PUSERNAME14}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${user_id}    ${resp.json()['id']}
    Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}

    ${lid}=  Create Sample Location  
    Set Suite Variable  ${lid}
    
    ${ser_name}=   FakerLibrary.word
    Set Suite Variable    ${ser_name}
    ${resp}=   Create Sample Service  ${ser_name}
    Set Suite Variable    ${s_id}    ${resp} 

    ${DAY1}=  get_date
    ${DAY2}=  add_date  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_time  0  15
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${resp}=  Create Provider Schedule  ${schedule_name}  ${recurringtype[4]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${JCstatus[0]}  ${user_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.content}    "${QUEUE_SCHEDULE_OVERLAPS_CREATE}"

JD-TC-Create_Provider_Schedule-UH2

    [Documentation]   Given same Schedule name
    ${resp}=  Provider Login  ${PUSERNAME14}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${user_id}    ${resp.json()['id']}
    Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}

    ${lid}=  Create Sample Location  
    Set Suite Variable  ${lid}
    
    ${DAY1}=  get_date
    ${DAY2}=  add_date  17    
    ${DAY3}=  add_date  19
    ${DAY4}=  add_date  20    
    ${DAY5}=  add_date  22 
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_time  0  15
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${resp}=  Create Provider Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY2}  ${DAY3}  ${EMPTY}  ${sTime1}  ${eTime1}  ${JCstatus[0]}  ${user_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}
    ${resp}=  Create Provider Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY4}  ${DAY5}  ${EMPTY}  ${sTime1}  ${eTime1}  ${JCstatus[1]}  ${user_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.content}  "${APPT_SCHEDULE_NAME_ALREADY_EXISTS}"
    Set Suite Variable  ${sch_id}  ${resp.json()}

JD-TC-Create_Provider_Schedule-UH3

    [Documentation]   Create a schedule with eTime is less than sTime
    ${resp}=  Provider Login  ${PUSERNAME14}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${user_id}    ${resp.json()['id']}
    Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    
    ${ser_name}=   FakerLibrary.word
    Set Suite Variable    ${ser_name}
    ${resp}=   Create Sample Service  ${ser_name}
    Set Suite Variable    ${s_id}    ${resp} 

    ${DAY1}=  get_date
    ${DAY2}=  add_date  17    
    ${DAY3}=  add_date  19
    ${DAY4}=  add_date  20    
    ${DAY5}=  add_date  22 
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime9}=  add_time  5  15
    ${eTime9}=  add_time   4  30
    ${schedule_name}=  FakerLibrary.bs
    ${resp}=  Create Provider Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY2}  ${DAY3}  ${EMPTY}  ${sTime9}  ${eTime9}  ${JCstatus[0]}  ${user_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${APPT_START_END_TIME_MISMATCH}"
    Set Suite Variable  ${sch_id}  ${resp.json()}

JD-TC-Create_Provider_Schedule-UH4

    [Documentation]   create schedule with start date, a past date
    ${resp}=  Provider Login  ${PUSERNAME14}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${user_id}    ${resp.json()['id']}
    Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    
    ${ser_name}=   FakerLibrary.word
    Set Suite Variable    ${ser_name}
    ${resp}=   Create Sample Service  ${ser_name}
    Set Suite Variable    ${s_id}    ${resp} 

    ${DAY1}=  subtract_date  5
    ${DAY2}=  add_date  10   
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_time  0  15
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${resp}=  Create Provider Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${JCstatus[0]}  ${user_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${APPT_START_DATE_PAST}"

JD-TC-Create_Provider_Schedule-UH5

    [Documentation]   create schedule with start date and end date, as past dates
    ${resp}=  Provider Login  ${PUSERNAME14}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${user_id}    ${resp.json()['id']}
    Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    
    ${ser_name}=   FakerLibrary.word
    Set Suite Variable    ${ser_name}
    ${resp}=   Create Sample Service  ${ser_name}
    Set Suite Variable    ${s_id}    ${resp} 

    ${DAY1}=  subtract_date  10
    ${DAY2}=  subtract_date  1   
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_time  0  15
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${resp}=  Create Provider Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${JCstatus[0]}  ${user_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${APPT_START_DATE_PAST}"

JD-TC-Create_Provider_Schedule-UH6

    [Documentation]  Create Provider Schedule with empty Provider id

    ${resp}=  Provider Login  ${PUSERNAME14}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${user_id}    ${resp.json()['id']}
    Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}

    ${lid}=  Create Sample Location  
    Set Suite Variable  ${lid}
    
    ${ser_name}=   FakerLibrary.word
    Set Suite Variable    ${ser_name}
    ${resp}=   Create Sample Service  ${ser_name}
    Set Suite Variable    ${s_id}    ${resp} 

    ${DAY1}=  get_date
    ${DAY2}=  add_date  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_time  0  15
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${resp}=  Create Provider Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${JCstatus[0]}  ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${INVALID_PROVIDER_ID}"
    


JD-TC-Create_Provider_Schedule-UH7

    [Documentation]  Create Provider Schedule with empty start date

    ${resp}=  Provider Login  ${PUSERNAME14}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${user_id}    ${resp.json()['id']}
    Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}

    ${lid}=  Create Sample Location  
    Set Suite Variable  ${lid}
    
    ${ser_name}=   FakerLibrary.word
    Set Suite Variable    ${ser_name}
    ${resp}=   Create Sample Service  ${ser_name}
    Set Suite Variable    ${s_id}    ${resp} 

    ${DAY1}=  add_date  40
    ${DAY2}=  add_date  42    
    ${list}=  Create List  1  
    ${sTime1}=  add_time  0  15
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${resp}=  Create Provider Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${empty}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${JCstatus[0]}  ${user_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Set Suite Variable  ${sch_id}  ${resp.json()}

JD-TC-Create_Provider_Schedule-UH8

    [Documentation]  Create Provider Schedule with empty end date

    ${resp}=  Provider Login  ${PUSERNAME14}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${user_id}    ${resp.json()['id']}
    Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}

    ${lid}=  Create Sample Location  
    Set Suite Variable  ${lid}
    
    ${ser_name}=   FakerLibrary.word
    Set Suite Variable    ${ser_name}
    ${resp}=   Create Sample Service  ${ser_name}
    Set Suite Variable    ${s_id}    ${resp} 

    ${DAY1}=  add_date  31
    ${DAY2}=  add_date  33      
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_time  0  15
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${resp}=  Create Provider Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${empty}  ${EMPTY}  ${sTime1}  ${eTime1}  ${JCstatus[0]}  ${user_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${END_DATE_REQUIRED}"
    Set Suite Variable  ${sch_id}  ${resp.json()}

JD-TC-Create_Provider_Schedule-UH9

    [Documentation]  Create Provider Schedule with empty start time

    ${resp}=  Provider Login  ${PUSERNAME14}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${user_id}    ${resp.json()['id']}
    Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}


    ${DAY1}=  get_date
    ${DAY2}=  add_date  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_time  0  15
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${resp}=  Create Provider Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${empty}  ${eTime1}  ${JCstatus[0]}  ${user_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Set Suite Variable  ${sch_id}  ${resp.json()}

JD-TC-Create_Provider_Schedule-UH10

    [Documentation]  Create Provider Schedule with empty end time

    ${resp}=  Provider Login  ${PUSERNAME14}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${user_id}    ${resp.json()['id']}
    Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}

 
    ${DAY1}=  get_date
    ${DAY2}=  add_date  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_time  0  15
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${resp}=  Create Provider Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${empty}  ${JCstatus[0]}  ${user_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    
   

JD-TC-Create_Provider_Schedule-UH11

    [Documentation]  Create Provider Schedule with empty schedule name

    ${resp}=  Provider Login  ${PUSERNAME14}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${user_id}    ${resp.json()['id']}
    Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}

 
    ${DAY1}=  get_date
    ${DAY2}=  add_date  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_time  0  15
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${resp}=  Create Provider Schedule  ${empty}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${empty}  ${JCstatus[0]}  ${user_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${NECESSARY_FIELD_MISSING}"


JD-TC-Create_Provider_Schedule-UH12

    [Documentation]  date format is incorrect

    ${resp}=  Provider Login  ${PUSERNAME14}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${user_id}    ${resp.json()['id']}
    Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}

 
    ${DAY1}=  get_date
    ${DAY2}=  add_date  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    ${date}=    Convert Date   ${DAY1}    result_format=%d %b %Y 
    ${sTime1}=  add_time  0  15
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${resp}=  Create Provider Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${date}  ${DAY2}  ${EMPTY}  ${sTime1}  ${empty}  ${JCstatus[0]}  ${user_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${INVAID_DATE_FORMAT}"

JD-TC-Create_Provider_Schedule-UH13

    [Documentation]  Create Provider Schedule with empty start date and end date

    ${resp}=  Provider Login  ${PUSERNAME14}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${user_id}    ${resp.json()['id']}
    Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}

    ${lid}=  Create Sample Location  
    Set Suite Variable  ${lid}
    
    ${ser_name}=   FakerLibrary.word
    Set Suite Variable    ${ser_name}
    ${resp}=   Create Sample Service  ${ser_name}
    Set Suite Variable    ${s_id}    ${resp} 

    ${DAY1}=  add_date  45
    ${DAY2}=  add_date  46    
    ${list}=  Create List  1  
    ${sTime1}=  add_time  0  15
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${resp}=  Create Provider Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${empty}  ${empty}  ${EMPTY}  ${sTime1}  ${eTime1}  ${JCstatus[0]}  ${user_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Set Suite Variable  ${sch_id}  ${resp.json()}


***comment***

JD-TC-Create_Provider_Schedule-UH13

    [Documentation]  Create Provider Schedule with empty recurring type

    ${resp}=  Provider Login  ${PUSERNAME14}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${user_id}    ${resp.json()['id']}
    Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}

 
    ${DAY1}=  get_date
    ${DAY2}=  add_date  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_time  0  15
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${resp}=  Create Provider Schedule  ${schedule_name}  ${empty}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${empty}  ${JCstatus[0]}  ${user_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Set Suite Variable  ${sch_id}  ${resp.json()}

JD-TC-Create_Provider_Schedule-UH14

    [Documentation]  Repeat intervals of schedule is empty

    ${resp}=  Provider Login  ${PUSERNAME14}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${user_id}    ${resp.json()['id']}
    Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}

 
    ${DAY1}=  get_date
    ${DAY2}=  add_date  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    ${date}=    Convert Date   ${DAY1}    result_format=%d %b %Y 
    ${sTime1}=  add_time  0  15
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${resp}=  Create Provider Schedule  ${schedule_name}  ${recurringtype[1]}  ${empty}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${empty}  ${JCstatus[0]}  ${user_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Set Suite Variable  ${sch_id}  ${resp.json()}

JD-TC-Create_Provider_Schedule-UH15

    [Documentation]  Create Provider Schedule with empty schedule state

    ${resp}=  Provider Login  ${PUSERNAME14}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${user_id}    ${resp.json()['id']}
    Set Suite Variable    ${user_name}    ${resp.json()['userName']}

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}

    ${lid}=  Create Sample Location  
    Set Suite Variable  ${lid}
    
    ${ser_name}=   FakerLibrary.word
    Set Suite Variable    ${ser_name}
    ${resp}=   Create Sample Service  ${ser_name}
    Set Suite Variable    ${s_id}    ${resp} 

    ${DAY1}=  get_date
    ${DAY2}=  add_date  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_time  0  15
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${resp}=  Create Provider Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${empty}  ${user_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Set Suite Variable  ${sch_id}  ${resp.json()}






  