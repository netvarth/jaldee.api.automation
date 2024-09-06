*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Task AuditLog
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 

*** Variables ***

@{emptylist} 


*** Test Cases ***

JD-TC-GetAuditlogsForTask-1

    [Documentation]  Create a task and get auditlog.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME70}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${p_id}=  get_acc_id  ${PUSERNAME70}
    Set Suite Variable   ${p_id}
    ${id}=  get_id  ${PUSERNAME70}
    Set Suite Variable  ${id}
   

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        Set Suite Variable  ${locId}
        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Suite Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
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
    Set Suite Variable  ${task_id1}  ${task_id[0]}
    Set Suite Variable  ${task_uid1}  ${task_id[1]}

    ${resp}=   Get Task By Id   ${task_uid1}
    Log   ${resp.content}
    Log   ${resp.json}
    Should Be Equal As Strings    ${p_id}       ${resp.json()}[accountId]
    Should Be Equal As Strings    []       ${resp.json()}[notes]
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Task Audit Logs   ${task_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}             200
    Should Be Equal As Strings  ${resp.json()[0]['action']}              ADD
    Should Be Equal As Strings  ${resp.json()[0]['category']}           TASK
    Should Be Equal As Strings  ${resp.json()[0]['subCategory']}             CREATE_TASK
    Should Be Equal As Strings  ${resp.json()[0]['userType']}           ${userType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['localUserId']}   ${id}

   
   

JD-TC-GetAuditlogsForTask-2

    [Documentation]  Create a task for a provider and get auditlog with account filter.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME70}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Task Audit Logs   ${task_id1}  account-eq=${p_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}             200
    Should Be Equal As Strings  ${resp.json()[0]['action']}              ADD
    Should Be Equal As Strings  ${resp.json()[0]['category']}           TASK
    Should Be Equal As Strings  ${resp.json()[0]['subCategory']}             CREATE_TASK
    Should Be Equal As Strings  ${resp.json()[0]['userType']}           ${userType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['localUserId']}   ${id}

   


JD-TC-GetAuditlogsForTask-3

    [Documentation]  Create a task for a provider and get auditlog with task filter.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME70}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Task Audit Logs   ${task_id1}  task-eq=${task_uid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}             200
     Should Be Equal As Strings  ${resp.json()[0]['action']}              ADD
    Should Be Equal As Strings  ${resp.json()[0]['category']}           TASK
    Should Be Equal As Strings  ${resp.json()[0]['subCategory']}             CREATE_TASK
    Should Be Equal As Strings  ${resp.json()[0]['userType']}           ${userType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['localUserId']}   ${id}

   

JD-TC-GetAuditlogsForTask-4

    [Documentation]  update the task and get auditlog.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME70}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 

    ${resp}=    Get Task Status
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${status_id1}    ${resp.json()[0]['id']}
    Set Test Variable  ${status_name1}  ${resp.json()[0]['name']}

    ${resp}=    Get Task Priority
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${priority_id1}    ${resp.json()[0]['id']}
    Set Test Variable  ${priority_name1}  ${resp.json()[0]['name']}

    ${status}=  Create Dictionary   id=${status_id1}
    Set Suite Variable  ${status}
    ${priority}=  Create Dictionary   id=${priority_id1}
    Set Suite Variable  ${priority}

    ${actualPotential}=   Random Int   min=50   max=100
    Set Suite Variable  ${actualPotential}
    ${actualResult}=   Random Int   min=50   max=100
    Set Suite Variable  ${actualResult}

    ${resp}=    Update Task   ${task_uid1}  ${title}  ${desc}  ${category_id1}  ${type_id1}   ${locId}  status=${status}  priority=${priority}    actualPotential=${actualPotential}    actualResult=${actualResult}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Task By Id   ${task_uid1}
    Log   ${resp.content}
    Log   ${resp.json}
    Should Be Equal As Strings    ${p_id}       ${resp.json()}[accountId]
    Should Be Equal As Strings    []       ${resp.json()}[notes]
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Task Audit Logs   ${task_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}             200
    Should Be Equal As Strings  ${resp.json()[0]['action']}              ADD
    Should Be Equal As Strings  ${resp.json()[0]['category']}           TASK
    Should Be Equal As Strings  ${resp.json()[0]['subCategory']}             CREATE_TASK
    Should Be Equal As Strings  ${resp.json()[0]['userType']}           ${userType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['localUserId']}   ${id}
    
    Should Be Equal As Strings  ${resp.json()[1]['action']}              EDIT
    Should Be Equal As Strings  ${resp.json()[1]['category']}           TASK
    Should Be Equal As Strings  ${resp.json()[1]['subCategory']}             UPDATE_TASK
    Should Be Equal As Strings  ${resp.json()[1]['userType']}           ${userType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['localUserId']}   ${id}

   

JD-TC-GetAuditlogsForTask-5

    [Documentation]  Create a task for a provider and get auditlog with location filter.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME70}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${DAY1}=  db.get_date_by_timezone  ${tz}

    ${resp}=   Get Task Audit Logs   ${task_id1}  auditlog-eq=subCategory::PROGRESS_UPDATION
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}             200

    Should Be Equal As Strings  ${resp.json()[0]['action']}              ADD
    Should Be Equal As Strings  ${resp.json()[0]['category']}           TASK
    Should Be Equal As Strings  ${resp.json()[0]['subCategory']}             CREATE_TASK
    Should Be Equal As Strings  ${resp.json()[0]['userType']}           ${userType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['localUserId']}   ${id}
    
    Should Be Equal As Strings  ${resp.json()[1]['action']}              EDIT
    Should Be Equal As Strings  ${resp.json()[1]['category']}           TASK
    Should Be Equal As Strings  ${resp.json()[1]['subCategory']}             UPDATE_TASK
    Should Be Equal As Strings  ${resp.json()[1]['userType']}           ${userType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['localUserId']}   ${id}




JD-TC-GetAuditlogsForTask-6

    [Documentation]  Create a task for a provider and get auditlog with action ADD filter.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME70}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Task Audit Logs   ${task_id1}  auditlog-eq=action::ADD
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}             200
    Should Be Equal As Strings  ${resp.json()[0]['action']}              ADD
    Should Be Equal As Strings  ${resp.json()[0]['category']}           TASK
    Should Be Equal As Strings  ${resp.json()[0]['subCategory']}             CREATE_TASK
    Should Be Equal As Strings  ${resp.json()[0]['userType']}           ${userType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['localUserId']}   ${id}

JD-TC-GetAuditlogsForTask-7

    [Documentation]  Create a task for a provider and get auditlog with catogory task filter.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME70}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Task Audit Logs   ${task_id1}  auditlog-eq=category::TASK
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}             200
    Should Be Equal As Strings  ${resp.json()[0]['action']}              ADD
    Should Be Equal As Strings  ${resp.json()[0]['category']}           TASK
    Should Be Equal As Strings  ${resp.json()[0]['subCategory']}             CREATE_TASK
    Should Be Equal As Strings  ${resp.json()[0]['userType']}           ${userType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['localUserId']}   ${id}

JD-TC-GetAuditlogsForTask-8

    [Documentation]  Create a task for a provider and get auditlog with localuserid filter.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME70}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Task Audit Logs   ${task_id1}  auditlog-eq=localUserId::${id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}             200
    Should Be Equal As Strings  ${resp.json()[0]['action']}              ADD
    Should Be Equal As Strings  ${resp.json()[0]['category']}           TASK
    Should Be Equal As Strings  ${resp.json()[0]['subCategory']}             CREATE_TASK
    Should Be Equal As Strings  ${resp.json()[0]['userType']}           ${userType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['localUserId']}   ${id}


   

JD-TC-GetAuditlogsForTask-UH1

    [Documentation]   get task auditlog with consumer login.

    ${resp}=   ConsumerLogin  ${CUSERNAME8}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Task Audit Logs   ${task_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   ${resp.json()}    ${LOGIN_NO_ACCESS_FOR_URL}


JD-TC-GetAuditlogsForTask-UH2

    [Documentation]   get task auditlog without login.

    ${resp}=   Get Task Audit Logs   ${task_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.json()}   ${SESSION_EXPIRED}

