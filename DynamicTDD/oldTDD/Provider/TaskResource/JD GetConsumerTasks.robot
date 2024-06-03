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


*** Variables ***

@{emptylist} 


*** Test Cases ***

JD-TC-GetConsumerTasks-1

    [Documentation]  Create a task for a consumer  and get a consumer task.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME90}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${p_id}=  get_acc_id  ${PUSERNAME90}
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
    Set Suite Variable  ${type_name1}  ${resp.json()[0]['name']}

    ${title}=  FakerLibrary.user name
    Set Suite Variable   ${title}

    ${desc}=   FakerLibrary.word 
    Set Suite Variable  ${desc}


    ${resp}=    Create Task   ${title}  ${desc}   ${userType[3]}  ${category_id1}  ${type_id1}   ${locId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${task_id}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${task_id1}  ${task_id[0]}
    Set Suite Variable  ${task_uid1}  ${task_id[1]}

    ${resp}=    Get Consumer Tasks
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}                   ${task_id1}
    Should Be Equal As Strings  ${resp.json()[0]['taskUid']}             ${task_uid1}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}             ${p_id}
    Should Be Equal As Strings  ${resp.json()[0]['title']}                ${title}
    Should Be Equal As Strings  ${resp.json()[0]['description']}          ${desc}
    Should Be Equal As Strings  ${resp.json()[0]['category']['id']}         ${category_id1} 
    Should Be Equal As Strings  ${resp.json()[0]['type']['id']}             ${type_id1}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}         ${locId}
   

JD-TC-GetConsumerTasks-2

    [Documentation]  Create a another task for a consumer and get a consumer tasks

    ${resp}=   Encrypted Provider Login  ${PUSERNAME90}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Task Category Type
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${category_id2}    ${resp.json()[1]['id']}
    Set Test Variable  ${category_name2}  ${resp.json()[1]['name']}

    ${resp}=    Get Task Type
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${type_id2}    ${resp.json()[1]['id']}
    Set Test Variable  ${type_name2}  ${resp.json()[1]['name']}

    
    ${title2}=  FakerLibrary.user name
    Set Suite Variable  ${title2}
    ${desc2}=   FakerLibrary.word 
    Set Suite Variable   ${desc2}

    ${resp}=    Create Task   ${title2}  ${desc2}   ${userType[3]}  ${category_id2}  ${type_id2}   ${locId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${task_id21}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${task_uid2}  ${task_id21[1]}
    Set Suite Variable  ${task_id2}  ${task_id21[0]}


    ${resp}=    Get Consumer Tasks
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}                  ${task_id2} 
    Should Be Equal As Strings  ${resp.json()[0]['taskUid']}             ${task_uid2} 
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}             ${p_id}
    Should Be Equal As Strings  ${resp.json()[0]['title']}                ${title2}
    Should Be Equal As Strings  ${resp.json()[0]['description']}          ${desc2}
    Should Be Equal As Strings  ${resp.json()[0]['category']['id']}         ${category_id2} 
    Should Be Equal As Strings  ${resp.json()[0]['type']['id']}             ${type_id2}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}         ${locId}


    Should Be Equal As Strings  ${resp.json()[1]['id']}                   ${task_id1}  
    Should Be Equal As Strings  ${resp.json()[1]['taskUid']}            ${task_uid1}
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}             ${p_id}
    Should Be Equal As Strings  ${resp.json()[1]['title']}                ${title}
    Should Be Equal As Strings  ${resp.json()[1]['description']}          ${desc}
    Should Be Equal As Strings  ${resp.json()[1]['category']['id']}         ${category_id1} 
    Should Be Equal As Strings  ${resp.json()[1]['type']['id']}             ${type_id1}
    Should Be Equal As Strings  ${resp.json()[1]['location']['id']}         ${locId}


JD-TC-GetConsumerTasks-3

    [Documentation]  Create a  task for a provider and  check get a consumer tasks

    ${resp}=   Encrypted Provider Login  ${PUSERNAME90}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Task Category Type
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${category_id3}    ${resp.json()[1]['id']}
    Set Test Variable  ${category_name2}  ${resp.json()[1]['name']}

    ${resp}=    Get Task Type
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${type_id2}    ${resp.json()[1]['id']}
    Set Test Variable  ${type_name2}  ${resp.json()[1]['name']}

    
    ${title3}=  FakerLibrary.user name
    ${desc3}=   FakerLibrary.word 

    ${resp}=    Create Task   ${title2}  ${desc2}   ${userType[0]}  ${category_id2}  ${type_id2}   ${locId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${task_id22}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${task_uid3}  ${task_id22[1]}
    Set Test Variable  ${task_id3}  ${task_id22[0]}


    ${resp}=    Get Consumer Tasks
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Not Contain    ${resp.json()}                 ${task_uid3} 
    Should Not Contain    ${resp.json()}                   ${task_id3} 

   
    Should Be Equal As Strings  ${resp.json()[0]['id']}                 ${task_id2}
    Should Be Equal As Strings  ${resp.json()[0]['taskUid']}               ${task_uid2} 
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}             ${p_id}
    Should Be Equal As Strings  ${resp.json()[0]['title']}                ${title2}
    Should Be Equal As Strings  ${resp.json()[0]['description']}          ${desc2}
    Should Be Equal As Strings  ${resp.json()[0]['category']['id']}         ${category_id2} 
    Should Be Equal As Strings  ${resp.json()[0]['type']['id']}             ${type_id2}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}         ${locId}


    Should Be Equal As Strings  ${resp.json()[1]['id']}                  ${task_id1}
    Should Be Equal As Strings  ${resp.json()[1]['taskUid']}            ${task_uid1}
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}             ${p_id}
    Should Be Equal As Strings  ${resp.json()[1]['title']}                ${title}
    Should Be Equal As Strings  ${resp.json()[1]['description']}          ${desc}
    Should Be Equal As Strings  ${resp.json()[1]['category']['id']}         ${category_id1} 
    Should Be Equal As Strings  ${resp.json()[1]['type']['id']}             ${type_id1}
    Should Be Equal As Strings  ${resp.json()[1]['location']['id']}         ${locId}


JD-TC-GetConsumerTasks-UH1

    [Documentation]   get a consumer tasks  without provider login
     
    ${resp}=    Get Consumer Tasks
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  	419 
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}


   

JD-TC-GetConsumerTasks-UH2

    [Documentation]   get a consumer tasks  with consumer login

    ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
      
    ${resp}=    Get Consumer Tasks
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   401
    Should Be Equal As Strings   ${resp.json()}     ${NoAccess}

   

JD-TC-GetConsumerTasks-4

    [Documentation]   get a consumer tasks  without creating task

    ${resp}=   Encrypted Provider Login  ${PUSERNAME75}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

     
    ${resp}=    Get Consumer Tasks
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  	200
    Should Be Equal As Strings   ${resp.json()}    []



   
   

   
   
 