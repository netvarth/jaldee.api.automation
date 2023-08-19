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

JD-TC-AddNotes-1

    [Documentation]  Create a task for a provider and add notes to task.

    ${resp}=   ProviderLogin  ${PUSERNAME58}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${p_id}=  get_acc_id  ${PUSERNAME58}
    Set Suite Variable   ${p_id}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
    ELSE
        Set Suite Variable  ${locId}  ${resp.json()[0]['id']}
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
    Should Be Equal As Strings    ${p_id}       ${resp.json()}[accountId]
    Should Be Equal As Strings    []       ${resp.json()}[notes]
    Should Be Equal As Strings  ${resp.status_code}  200

    ${notes}=   FakerLibrary.sentence 
    Set Suite Variable   ${notes}
    ${resp}=   Add Notes To Task    ${task_uid1}   ${notes}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Task By Id   ${task_uid1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${p_id}       ${resp.json()['accountId']}
    Should Be Equal As Strings    ${notes}      ${resp.json()['notes'][0]['note']}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-AddNotes-2

    [Documentation]  Create a task for a consumer and add notes to task.

    ${resp}=   ProviderLogin  ${PUSERNAME58}  ${PASSWORD} 
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
    Should Be Equal As Strings    ${p_id}       ${resp.json()['accountId']}
    Should Be Equal As Strings    ${notes}      ${resp.json()['notes'][0]['note']}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${notes}=   FakerLibrary.sentence 
    ${resp}=   Add Notes To Task    ${task_uid2}   ${notes}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Task By Id   ${task_uid2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${p_id}       ${resp.json()['accountId']}
    Should Be Equal As Strings    ${notes}      ${resp.json()['notes'][0]['note']}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-AddNotes-3

    [Documentation]  Add same notes to a task multiple times.

    ${resp}=   ProviderLogin  ${PUSERNAME60}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${p_id}=  get_acc_id  ${PUSERNAME60}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
    ELSE
        Set Test Variable  ${locId}  ${resp.json()[0]['id']}
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
    Should Be Equal As Strings    ${p_id}       ${resp.json()['accountId']}
    Should Be Equal As Strings    ${notes}      ${resp.json()['notes'][0]['note']}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Add Notes To Task    ${task_uid3}   ${notes}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Task By Id   ${task_uid3}
    Log   ${resp.content}
    Should Be Equal As Strings    ${p_id}       ${resp.json()['accountId']}
    Should Be Equal As Strings    ${notes}      ${resp.json()['notes'][0]['note']}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-AddNotes-4

    [Documentation]  Add different notes to a task multiple times.

    ${resp}=   ProviderLogin  ${PUSERNAME60}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${p_id1}=  get_acc_id  ${PUSERNAME60}

    ${notes1}=   FakerLibrary.sentence 
    ${resp}=   Add Notes To Task    ${task_uid3}   ${notes1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Task By Id   ${task_uid3}
    Log   ${resp.content}
    Should Be Equal As Strings    ${p_id1}       ${resp.json()['accountId']}
    Should Be Equal As Strings    ${notes1}      ${resp.json()['notes'][2]['note']}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-AddNotes-5

    [Documentation]  Add numbers as notes to a task.

    ${resp}=   ProviderLogin  ${PUSERNAME58}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Task By Id   ${task_uid1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${p_id}       ${resp.json()['accountId']}
    Should Be Equal As Strings    ${notes}      ${resp.json()['notes'][0]['note']}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${notes7}=   Random Int   min=10   max=50
    ${resp}=   Add Notes To Task    ${task_uid1}   ${notes7}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Task By Id   ${task_uid1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${p_id}       ${resp.json()['accountId']}
    Should Be Equal As Strings    ${notes7}      ${resp.json()['notes'][1]['note']}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-AddNotes-UH1

    [Documentation]  Add notes to a task without giving notes.

    ${resp}=   ProviderLogin  ${PUSERNAME58}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Add Notes To Task    ${task_uid1}   ${EMPTY}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${REMARK_REQUIRED}



JD-TC-AddNotes-UH2

    [Documentation]  Add notes to a task with consumer login.

    ${resp}=   ConsumerLogin  ${CUSERNAME8}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${notes}=   FakerLibrary.sentence 
    ${resp}=   Add Notes To Task    ${task_uid1}   ${notes}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   ${resp.json()}    ${LOGIN_NO_ACCESS_FOR_URL}

JD-TC-AddNotes-UH3

    [Documentation]  Add notes to a task without login.

    ${notes}=   FakerLibrary.sentence 
    ${resp}=   Add Notes To Task    ${task_uid1}   ${notes}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-AddNotes-UH4

    [Documentation]  Add notes to a task with another providers task id.

    ${resp}=   ProviderLogin  ${PUSERNAME90}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${notes}=   FakerLibrary.sentence 
    ${resp}=   Add Notes To Task    ${task_uid1}   ${notes}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${NO_PERMISSION}

