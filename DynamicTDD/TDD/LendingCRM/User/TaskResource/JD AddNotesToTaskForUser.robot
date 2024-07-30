*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Task
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/hl_providers.py

*** Variables ***

@{emptylist} 


*** Test Cases ***

JD-TC-AddNotesToTaskForUser-1

    [Documentation]  Create a task for a branch and add notes to task.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME58}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${p_id}=  get_acc_id  ${PUSERNAME58}
    Set Suite Variable   ${p_id}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ELSE
        Set Suite Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END
    
    ${resp}=  categorytype  ${p_id}
    ${resp}=  tasktype      ${p_id}
    ${resp}=    Get Task Category Type
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${category_id1}    ${resp.json()[0]['id']}
    Set Test Variable  ${category_name1}  ${resp.json()[0]['name']}

    ${resp}=    Get Task Type
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${type_id1}    ${resp.json()[0]['id']}
    Set Test Variable  ${type_name1}  ${resp.json()[0]['name']}

    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 

    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${task_id}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${task_id1}  ${task_id[0]}
    Set Suite Variable  ${task_uid1}  ${task_id[1]}

    ${resp}=   Get Task By Id   ${task_uid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${p_id}       ${resp.json()}[accountId]
    Should Be Equal As Strings    []       ${resp.json()}[notes]
    

    ${notes}=   FakerLibrary.sentence 
    Set Suite Variable   ${notes}
    ${resp}=   Add Notes To Task    ${task_uid1}   ${notes}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Task By Id   ${task_uid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${p_id}       ${resp.json()['accountId']}
    Should Be Equal As Strings    ${notes}      ${resp.json()['notes'][0]['note']}
    

JD-TC-AddNotesToTaskForUser-2

    [Documentation]  Create a task for a consumer and add notes to task.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME58}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 

    ${resp}=    Create Task   ${title}  ${desc}   ${userType[3]}  ${category_id1}  ${type_id1}   ${locId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${task_id}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${task_id2}  ${task_id[0]}
    Set Test Variable  ${task_uid2}  ${task_id[1]}

    ${resp}=   Get Task By Id   ${task_uid1}
    Log   ${resp.content}
    Log   ${resp.json}
    Should Be Equal As Strings    ${p_id}       ${resp.json()['accountId']}
    Should Be Equal As Strings    ${notes}      ${resp.json()['notes'][0]['note']}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${notes}=   FakerLibrary.sentence 
    ${resp}=   Add Notes To Task    ${task_uid2}   ${notes}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Task By Id   ${task_uid2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${p_id}       ${resp.json()['accountId']}
    Should Be Equal As Strings    ${notes}      ${resp.json()['notes'][0]['note']}
    
JD-TC-AddNotesToTaskForUser-3

    [Documentation]  Add same notes to a task multiple times.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME60}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${p_id}=  get_acc_id  ${PUSERNAME60}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ELSE
        Set Suite Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END
    
    ${resp}=  categorytype  ${p_id}
    ${resp}=  tasktype      ${p_id}
    ${resp}=    Get Task Category Type
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${category_id1}    ${resp.json()[0]['id']}
    Set Test Variable  ${category_name1}  ${resp.json()[0]['name']}

    ${resp}=    Get Task Type
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${type_id1}    ${resp.json()[0]['id']}
    Set Test Variable  ${type_name1}  ${resp.json()[0]['name']}

    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 

    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${task_id}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${task_id3}  ${task_id[0]}
    Set Suite Variable  ${task_uid3}  ${task_id[1]}

    ${notes}=   FakerLibrary.sentence 
    ${resp}=   Add Notes To Task    ${task_uid3}   ${notes}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Task By Id   ${task_uid3}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${p_id}       ${resp.json()['accountId']}
    Should Be Equal As Strings    ${notes}      ${resp.json()['notes'][0]['note']}
    
    ${resp}=   Add Notes To Task    ${task_uid3}   ${notes}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Task By Id   ${task_uid3}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${p_id}       ${resp.json()['accountId']}
    Should Be Equal As Strings    ${notes}      ${resp.json()['notes'][0]['note']}
   

JD-TC-AddNotesToTaskForUser-4

    [Documentation]  Add different notes to a task multiple times.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME60}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${p_id1}=  get_acc_id  ${PUSERNAME60}

    ${notes1}=   FakerLibrary.sentence 
    ${resp}=   Add Notes To Task    ${task_uid3}   ${notes1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Task By Id   ${task_uid3}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${p_id1}       ${resp.json()['accountId']}
    Should Be Equal As Strings    ${notes1}      ${resp.json()['notes'][2]['note']}
   


JD-TC-AddNotesToTaskForUser-5

    [Documentation]  Add numbers as notes to a task.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME58}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Task By Id   ${task_uid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${p_id}       ${resp.json()['accountId']}
    Should Be Equal As Strings    ${notes}      ${resp.json()['notes'][0]['note']}
   

    ${notes7}=   Random Int   min=10   max=50
    ${resp}=   Add Notes To Task    ${task_uid1}   ${notes7}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Task By Id   ${task_uid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${p_id}       ${resp.json()['accountId']}
    Should Be Equal As Strings    ${notes7}      ${resp.json()['notes'][1]['note']}
  
JD-TC-AddNotesToTaskForUser-6

    [Documentation]  Create a task for a branch and user try to add notes for that task after assign the task to user.

    clear_service   ${HLPUSERNAME4}
    clear_location  ${HLPUSERNAME4}
    clear_appt_schedule   ${HLPUSERNAME4}

    ${resp}=   Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${p_id1}=  get_acc_id  ${HLPUSERNAME4}
    Set Suite Variable   ${p_id1}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId1}=  Create Sample Location
        Set Suite Variable  ${locId1}
        ${resp}=   Get Location ById  ${locId1}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ELSE
        Set Suite Variable  ${locId1}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END
    
    ${resp}=  categorytype  ${p_id1}
    ${resp}=  tasktype      ${p_id1}
    
    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 

    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${task_id}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${task_id1}  ${task_id[0]}
    Set Suite Variable  ${task_uid4}  ${task_id[1]}

    ${resp}=   Get Task By Id   ${task_uid4}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${p_id1}       ${resp.json()}[accountId]
    Should Be Equal As Strings    []       ${resp.json()}[notes]
    

    ${resp}=   Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    sleep  2s
    ${dep_name1}=  FakerLibrary.bs
    ${dep_code1}=   Random Int  min=100   max=999
    ${dep_desc1}=   FakerLibrary.word  
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${u_id}=  Create Sample User

    ${resp}=  Get User By Id  ${u_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${PUSERNAME_U1}  ${resp.json()['mobileNo']}

    ${resp}=   Change Assignee    ${task_uid4}    ${u_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Reset LoginId  ${u_id}  ${PUSERNAME_U1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Forgot Password   loginId=${PUSERNAME_U1}  password=${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${PUSERNAME_U1}  ${OtpPurpose['ProviderResetPassword']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key} =   db.Verify Accnt   ${PUSERNAME_U1}    ${OtpPurpose['ProviderResetPassword']}
    Set Suite Variable   ${key}

    ${resp}=    Forgot Password     otp=${key}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    #... linking user to the provider 1 and get linked lists

    ${resp}=    Connect with other login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # --------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${notes}=   FakerLibrary.sentence 
    Set Suite Variable   ${notes}
    ${resp}=   Add Notes To Task    ${task_uid4}   ${notes}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Task By Id   ${task_uid4}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${p_id1}       ${resp.json()['accountId']}
    Should Be Equal As Strings    ${notes}      ${resp.json()['notes'][0]['note']}
   
JD-TC-AddNotesToTaskForUser-UH1

    [Documentation]  Add notes to a task without giving notes.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME58}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Add Notes To Task    ${task_uid1}   ${EMPTY}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${REMARK_REQUIRED}



JD-TC-AddNotesToTaskForUser-UH2

    [Documentation]  Add notes to a task with consumer login.

    ${resp}=   ConsumerLogin  ${CUSERNAME8}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${notes}=   FakerLibrary.sentence 
    ${resp}=   Add Notes To Task    ${task_uid1}   ${notes}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   ${resp.json()}    ${LOGIN_NO_ACCESS_FOR_URL}

JD-TC-AddNotesToTaskForUser-UH3

    [Documentation]  Add notes to a task without login.

    ${notes}=   FakerLibrary.sentence 
    ${resp}=   Add Notes To Task    ${task_uid1}   ${notes}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-AddNotesToTaskForUser-UH4

    [Documentation]  Add notes to a task with another providers task id.

    ${resp}=   Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${notes}=   FakerLibrary.sentence 
    ${resp}=   Add Notes To Task    ${task_uid1}   ${notes}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${NO_PERMISSION}


JD-TC-AddNotesToTaskForUser-UH5

    [Documentation]  Create a task for a branch and user try to add notes for that task.

    ${resp}=   Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 

    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${task_id}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${task_id1}  ${task_id[0]}
    Set Suite Variable  ${task_uid5}  ${task_id[1]}

    ${resp}=   Get Task By Id   ${task_uid5}
    Log   ${resp.content}
    Should Be Equal As Strings    ${p_id1}       ${resp.json()}[accountId]
    Should Be Equal As Strings    []       ${resp.json()}[notes]
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${NO_PERMISSION_UPDATE_TASK}=   Replace String  ${NO_PERMISSION_TO_UPDATE_TASK}  {}  activity

    ${notes}=   FakerLibrary.sentence 
    Set Suite Variable   ${notes}
    ${resp}=   Add Notes To Task    ${task_uid5}   ${notes}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  403
    Should Be Equal As Strings  ${resp.json()}   ${NO_PERMISSION_UPDATE_TASK}

   
JD-TC-AddNotesToTaskForUser-UH6

    [Documentation]  Create a task for a user and branch try to add notes for that task.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable          ${locId1}  ${resp.json()[0]['id']}

    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 

    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${task_id}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${task_id1}  ${task_id[0]}
    Set Suite Variable  ${task_uid7}  ${task_id[1]}

    ${resp}=   Get Task By Id   ${task_uid7}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${p_id1}       ${resp.json()}[accountId]
    Should Be Equal As Strings    []       ${resp.json()}[notes]
   
    ${resp}=   Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}


    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${notes}=   FakerLibrary.sentence 
    Set Suite Variable   ${notes}
    ${resp}=   Add Notes To Task    ${task_uid7}   ${notes}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Task By Id   ${task_uid7}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${notes}      ${resp.json()['notes'][0]['note']}


JD-TC-AddNotesToTaskForUser-UH7

    [Documentation]  Create a task for a user try to add notes for that task after closing the task.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Change User Task Status Closed   ${task_uid5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Add Notes To Task    ${task_uid5}   ${notes}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200



