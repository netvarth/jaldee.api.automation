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
Variables         /ebs/TDD/varfiles/musers.py

*** Variables ***

@{emptylist} 


*** Test Cases ***

JD-TC-UpdateTask-1

    [Documentation]  Create a task for a provider and update the task with same details.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME50}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${p_id}=  get_acc_id  ${PUSERNAME50}
    Set Suite Variable   ${p_id}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${locId} 
        ${resp}=    Get Locations
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${loc_name}  ${resp.json()[0]['place']}
    ELSE
        Set Suite Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${loc_name}  ${resp.json()[0]['place']}
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
    Set Suite Variable  ${title}
    ${desc}=   FakerLibrary.word 
    Set Suite Variable  ${desc}

    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}   ${category_id1}  ${type_id1}   ${locId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${task_id}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${task_id1}  ${task_id[0]}
    Set Suite Variable  ${task_uid1}  ${task_id[1]}

    ${resp}=   Get Task By Id   ${task_uid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['id']}                  ${task_id1}
    Should Be Equal As Strings  ${resp.json()['taskUid']}             ${task_uid1}
    Should Be Equal As Strings  ${resp.json()['accountId']}           ${p_id}
    Should Be Equal As Strings  ${resp.json()['title']}               ${title}
    Should Be Equal As Strings  ${resp.json()['description']}         ${desc}
    Should Be Equal As Strings  ${resp.json()['category']['id']}      ${category_id1} 
    Should Be Equal As Strings  ${resp.json()['type']['id']}          ${type_id1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}      ${locId}
    Should Be Equal As Strings  ${resp.json()['location']['name']}    ${loc_name}

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
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['id']}                  ${task_id1}
    Should Be Equal As Strings  ${resp.json()['taskUid']}             ${task_uid1}
    Should Be Equal As Strings  ${resp.json()['accountId']}           ${p_id}
    Should Be Equal As Strings  ${resp.json()['title']}               ${title}
    Should Be Equal As Strings  ${resp.json()['description']}         ${desc}
    Should Be Equal As Strings  ${resp.json()['category']['id']}      ${category_id1} 
    Should Be Equal As Strings  ${resp.json()['type']['id']}          ${type_id1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}      ${locId}
    Should Be Equal As Strings  ${resp.json()['location']['name']}    ${loc_name}
    Should Be Equal As Strings  ${resp.json()['status']['id']}        ${status_id1} 
    Should Be Equal As Strings  ${resp.json()['priority']['id']}      ${priority_id1}

JD-TC-UpdateTask-2

    [Documentation]  Create a task for a provider and update the task with different location.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME50}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${l_id1}=  Create Sample Location
    Set Suite Variable   ${l_id1}

    ${resp}=    Update Task   ${task_uid1}  ${title}  ${desc}  ${category_id1}  ${type_id1}   ${l_id1}  status=${status}  priority=${priority}    actualPotential=${actualPotential}    actualResult=${actualResult}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Task By Id   ${task_uid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['id']}                  ${task_id1}
    Should Be Equal As Strings  ${resp.json()['taskUid']}             ${task_uid1}
    Should Be Equal As Strings  ${resp.json()['accountId']}           ${p_id}
    Should Be Equal As Strings  ${resp.json()['title']}               ${title}
    Should Be Equal As Strings  ${resp.json()['description']}         ${desc}
    Should Be Equal As Strings  ${resp.json()['category']['id']}      ${category_id1} 
    Should Be Equal As Strings  ${resp.json()['type']['id']}          ${type_id1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}      ${l_id1}
    Should Be Equal As Strings  ${resp.json()['status']['id']}        ${status_id1} 
    Should Be Equal As Strings  ${resp.json()['priority']['id']}      ${priority_id1}


JD-TC-UpdateTask-3

    [Documentation]  Create a task for a provider and update the task with another title.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME50}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${title11}=  FakerLibrary.user name
    Set Suite Variable   ${title11}

    ${resp}=    Update Task   ${task_uid1}  ${title11}  ${desc}  ${category_id1}  ${type_id1}   ${l_id1}  status=${status}  priority=${priority}    actualPotential=${actualPotential}    actualResult=${actualResult}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Task By Id   ${task_uid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['id']}                  ${task_id1}
    Should Be Equal As Strings  ${resp.json()['taskUid']}             ${task_uid1}
    Should Be Equal As Strings  ${resp.json()['accountId']}           ${p_id}
    Should Be Equal As Strings  ${resp.json()['title']}               ${title11}
    Should Be Equal As Strings  ${resp.json()['description']}         ${desc}
    Should Be Equal As Strings  ${resp.json()['category']['id']}      ${category_id1} 
    Should Be Equal As Strings  ${resp.json()['type']['id']}          ${type_id1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}      ${l_id1}
    Should Be Equal As Strings  ${resp.json()['status']['id']}        ${status_id1} 
    Should Be Equal As Strings  ${resp.json()['priority']['id']}      ${priority_id1}


JD-TC-UpdateTask-4

    [Documentation]  Create a task for a provider and update the task with another description.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME50}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${desc11}=  FakerLibrary.word
    Set Suite Variable   ${desc11}

    ${resp}=    Update Task   ${task_uid1}  ${title11}  ${desc11}  ${category_id1}  ${type_id1}   ${l_id1}  status=${status}  priority=${priority}    actualPotential=${actualPotential}    actualResult=${actualResult}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Task By Id   ${task_uid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['id']}                  ${task_id1}
    Should Be Equal As Strings  ${resp.json()['taskUid']}             ${task_uid1}
    Should Be Equal As Strings  ${resp.json()['accountId']}           ${p_id}
    Should Be Equal As Strings  ${resp.json()['title']}               ${title11}
    Should Be Equal As Strings  ${resp.json()['description']}         ${desc11}
    Should Be Equal As Strings  ${resp.json()['category']['id']}      ${category_id1} 
    Should Be Equal As Strings  ${resp.json()['type']['id']}          ${type_id1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}      ${l_id1}
    Should Be Equal As Strings  ${resp.json()['status']['id']}        ${status_id1} 
    Should Be Equal As Strings  ${resp.json()['priority']['id']}      ${priority_id1}


JD-TC-UpdateTask-5

    [Documentation]  Create a task for a provider and update the task with another category.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME50}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Task Category Type
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cat_id1}    ${resp.json()[1]['id']}
    Set Test Variable  ${cat_name1}  ${resp.json()[1]['name']}

    ${resp}=    Update Task   ${task_uid1}  ${title11}  ${desc11}  ${cat_id1}  ${type_id1}   ${l_id1}  status=${status}  priority=${priority}    actualPotential=${actualPotential}    actualResult=${actualResult}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Task By Id   ${task_uid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['id']}                  ${task_id1}
    Should Be Equal As Strings  ${resp.json()['taskUid']}             ${task_uid1}
    Should Be Equal As Strings  ${resp.json()['accountId']}           ${p_id}
    Should Be Equal As Strings  ${resp.json()['title']}               ${title11}
    Should Be Equal As Strings  ${resp.json()['description']}         ${desc11}
    Should Be Equal As Strings  ${resp.json()['category']['id']}      ${cat_id1} 
    Should Be Equal As Strings  ${resp.json()['type']['id']}          ${type_id1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}      ${l_id1}
    Should Be Equal As Strings  ${resp.json()['status']['id']}        ${status_id1} 
    Should Be Equal As Strings  ${resp.json()['priority']['id']}      ${priority_id1}


JD-TC-UpdateTask-6

    [Documentation]  Create a task for a provider and update the task with another task type.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME50}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Task Type
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${type_id11}    ${resp.json()[0]['id']}
    Set Test Variable  ${type_name11}  ${resp.json()[0]['name']}

    ${resp}=    Update Task   ${task_uid1}  ${title11}  ${desc11}  ${cat_id1}  ${type_id11}   ${l_id1}  status=${status}  priority=${priority}    actualPotential=${actualPotential}    actualResult=${actualResult}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Task By Id   ${task_uid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['id']}                  ${task_id1}
    Should Be Equal As Strings  ${resp.json()['taskUid']}             ${task_uid1}
    Should Be Equal As Strings  ${resp.json()['accountId']}           ${p_id}
    Should Be Equal As Strings  ${resp.json()['title']}               ${title11}
    Should Be Equal As Strings  ${resp.json()['description']}         ${desc11}
    Should Be Equal As Strings  ${resp.json()['category']['id']}      ${cat_id1} 
    Should Be Equal As Strings  ${resp.json()['type']['id']}          ${type_id11}
    Should Be Equal As Strings  ${resp.json()['location']['id']}      ${l_id1}
    Should Be Equal As Strings  ${resp.json()['status']['id']}        ${status_id1} 
    Should Be Equal As Strings  ${resp.json()['priority']['id']}      ${priority_id1}


JD-TC-UpdateTask-7

    [Documentation]  Create a task for a provider and update the task with another status and priority.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME50}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Task Status
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${status_id11}    ${resp.json()[2]['id']}
    Set Test Variable  ${status_name11}  ${resp.json()[2]['name']}

    ${resp}=    Get Task Priority
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${priority_id11}    ${resp.json()[2]['id']}
    Set Test Variable  ${priority_name11}  ${resp.json()[2]['name']}

    # ${status}=  Create Dictionary   id=${status_id11}
    # Set Suite Variable  ${status}
    ${priority}=  Create Dictionary   id=${priority_id11}
    Set Suite Variable  ${priority}

    ${resp}=    Update Task   ${task_uid1}  ${title11}  ${desc11}  ${cat_id1}  ${type_id11}   ${l_id1}    status=${status}    priority=${priority}    actualPotential=${actualPotential}    actualResult=${actualResult}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Task By Id   ${task_uid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['id']}                  ${task_id1}
    Should Be Equal As Strings  ${resp.json()['taskUid']}             ${task_uid1}
    Should Be Equal As Strings  ${resp.json()['accountId']}           ${p_id}
    Should Be Equal As Strings  ${resp.json()['title']}               ${title11}
    Should Be Equal As Strings  ${resp.json()['description']}         ${desc11}
    Should Be Equal As Strings  ${resp.json()['category']['id']}      ${cat_id1} 
    Should Be Equal As Strings  ${resp.json()['type']['id']}          ${type_id11}
    Should Be Equal As Strings  ${resp.json()['location']['id']}      ${l_id1}
    Should Be Equal As Strings  ${resp.json()['status']['id']}        ${status_id1} 
    Should Be Equal As Strings  ${resp.json()['priority']['id']}      ${priority_id11}


JD-TC-UpdateTask-8

    [Documentation]    Update task without title.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME50}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Update Task   ${task_uid1}  ${EMPTY}  ${desc11}  ${cat_id1}  ${type_id11}   ${l_id1}    status=${status}    priority=${priority}    actualPotential=${actualPotential}    actualResult=${actualResult}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Task By Id   ${task_uid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['id']}                  ${task_id1}
    Should Be Equal As Strings  ${resp.json()['taskUid']}             ${task_uid1}
    Should Be Equal As Strings  ${resp.json()['accountId']}           ${p_id}
    Should Be Equal As Strings  ${resp.json()['title']}               ${EMPTY}
    Should Be Equal As Strings  ${resp.json()['description']}         ${desc11}
    Should Be Equal As Strings  ${resp.json()['category']['id']}      ${cat_id1} 
    Should Be Equal As Strings  ${resp.json()['type']['id']}          ${type_id11}
    Should Be Equal As Strings  ${resp.json()['location']['id']}      ${l_id1}
    Should Be Equal As Strings  ${resp.json()['status']['id']}        ${status_id1} 
    Should Be Equal As Strings  ${resp.json()['priority']['id']}      ${priority_id11}


JD-TC-UpdateTask-9

    [Documentation]    Update task without description.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME50}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Update Task   ${task_uid1}  ${title11}  ${EMPTY}  ${cat_id1}  ${type_id11}   ${l_id1}    status=${status}    priority=${priority}    actualPotential=${actualPotential}    actualResult=${actualResult}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Task By Id   ${task_uid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['id']}                  ${task_id1}
    Should Be Equal As Strings  ${resp.json()['taskUid']}             ${task_uid1}
    Should Be Equal As Strings  ${resp.json()['accountId']}           ${p_id}
    Should Be Equal As Strings  ${resp.json()['title']}               ${title11}
    Should Be Equal As Strings  ${resp.json()['description']}         ${EMPTY}
    Should Be Equal As Strings  ${resp.json()['category']['id']}      ${cat_id1} 
    Should Be Equal As Strings  ${resp.json()['type']['id']}          ${type_id11}
    Should Be Equal As Strings  ${resp.json()['location']['id']}      ${l_id1}
    Should Be Equal As Strings  ${resp.json()['status']['id']}        ${status_id1} 
    Should Be Equal As Strings  ${resp.json()['priority']['id']}      ${priority_id11}
    

JD-TC-UpdateTask-UH1

    [Documentation]    Update task without location.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME50}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Update Task   ${task_uid1}  ${title11}  ${desc11}  ${cat_id1}  ${type_id11}   ${EMPTY}    priority=${priority}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}    ${LOCATION_REQUIRED}

   
JD-TC-UpdateTask-UH2

    [Documentation]  update task without status.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME88}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${p_id1}=  get_acc_id  ${PUSERNAME88}
    Set Suite Variable  ${p_id1} 

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
        Set Suite Variable  ${locId1}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END
    
    ${resp}=  categorytype  ${p_id1}
    ${resp}=  tasktype      ${p_id1}
    ${resp}=    Get Task Category Type
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${category_id2}    ${resp.json()[0]['id']}
    Set Test Variable  ${category_name2}  ${resp.json()[0]['name']}

    ${resp}=    Get Task Type
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${type_id2}    ${resp.json()[0]['id']}
    Set Test Variable  ${type_name2}  ${resp.json()[0]['name']}

    ${title1}=  FakerLibrary.user name
    Set Suite Variable  ${title1} 
    ${desc1}=   FakerLibrary.word 
    Set Suite Variable  ${desc1} 

    ${resp}=    Create Task   ${title1}  ${desc1}   ${userType[0]}   ${category_id2}  ${type_id2}   ${locId1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${task_id}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${task_id2}  ${task_id[0]}
    Set Suite Variable  ${task_uid2}  ${task_id[1]}

    ${resp}=   Get Task By Id   ${task_uid2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['id']}                  ${task_id2}
    Should Be Equal As Strings  ${resp.json()['taskUid']}             ${task_uid2}
    Should Be Equal As Strings  ${resp.json()['accountId']}           ${p_id1}
    Should Be Equal As Strings  ${resp.json()['title']}               ${title1}
    Should Be Equal As Strings  ${resp.json()['description']}         ${desc1}
    Should Be Equal As Strings  ${resp.json()['category']['id']}      ${category_id2} 
    Should Be Equal As Strings  ${resp.json()['type']['id']}          ${type_id2}
    Should Be Equal As Strings  ${resp.json()['location']['id']}      ${locId1}

    ${resp}=    Update Task   ${task_uid2}  ${title1}  ${desc1}  ${category_id2}  ${type_id2}   ${locId1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}    ${STATUS_REQUIRED}

JD-TC-UpdateTask-UH3

    [Documentation]  update task without priority.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME88}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Task Status
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${status_id1}    ${resp.json()[0]['id']}
    Set Test Variable  ${status_name1}  ${resp.json()[0]['name']}

    ${status}=  Create Dictionary   id=${status_id1}

    ${resp}=    Update Task   ${task_uid2}  ${title1}  ${desc1}  ${category_id2}  ${type_id2}   ${locId1}   status=${status}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}    ${PRIORITY_REQUIRED}


JD-TC-UpdateTask-UH4

    [Documentation]    Update task without login.

    ${resp}=    Update Task   ${task_uid1}  ${title11}  ${desc11}  ${cat_id1}  ${type_id11}   ${l_id1}  status=${status}  priority=${priority}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.json()}   ${SESSION_EXPIRED}


JD-TC-UpdateTask-UH5

    [Documentation]    Update task with consumer login.

    ${resp}=   ConsumerLogin  ${CUSERNAME8}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Update Task   ${task_uid1}  ${title11}  ${desc11}  ${cat_id1}  ${type_id11}   ${l_id1}  status=${status}  priority=${priority}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   ${resp.json()}    ${LOGIN_NO_ACCESS_FOR_URL}

JD-TC-UpdateTask-UH6

    [Documentation]  update task using another providers location id.
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME37}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId1}=  Create Sample Location
    ELSE
        Set Test Variable  ${locId1}  ${resp.json()[0]['id']}
    END
    
    ${resp}=   ProviderLogout   
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Encrypted Provider Login  ${PUSERNAME38}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${p_id}=  get_acc_id  ${PUSERNAME38}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
    ELSE
        Set Test Variable  ${locId}  ${resp.json()[0]['id']}
        Set Test Variable  ${loc_name}  ${resp.json()[0]['place']}
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

    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}   ${category_id1}  ${type_id1}   ${locId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${task_id}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${task_id1}  ${task_id[0]}
    Set Test Variable  ${task_uid1}  ${task_id[1]}

    ${resp}=   Get Task By Id   ${task_uid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['id']}                  ${task_id1}
    Should Be Equal As Strings  ${resp.json()['taskUid']}             ${task_uid1}
    Should Be Equal As Strings  ${resp.json()['accountId']}           ${p_id}
    Should Be Equal As Strings  ${resp.json()['title']}               ${title}
    Should Be Equal As Strings  ${resp.json()['description']}         ${desc}
    Should Be Equal As Strings  ${resp.json()['category']['id']}      ${category_id1} 
    Should Be Equal As Strings  ${resp.json()['type']['id']}          ${type_id1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}      ${locId}
    Should Be Equal As Strings  ${resp.json()['location']['name']}    ${loc_name}

    ${resp}=    Get Task Status
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${status_id1}    ${resp.json()[0]['id']}
    Set Test Variable  ${status_name1}  ${resp.json()[0]['name']}

    ${resp}=    Get Task Priority
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${priority_id1}    ${resp.json()[0]['id']}
    Set Test Variable  ${priority_name1}  ${resp.json()[0]['name']}

    ${status}=  Create Dictionary   id=${status_id1}
    ${priority}=  Create Dictionary   id=${priority_id1}
  
    ${resp}=    Update Task   ${task_uid1}  ${title}  ${desc}  ${category_id1}  ${type_id1}   ${locId1}  status=${status}  priority=${priority}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${INVALID_BUSS_LOC_ID}



 