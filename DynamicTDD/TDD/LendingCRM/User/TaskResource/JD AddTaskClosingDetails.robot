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

JD-TC-ChangeTaskStatusTOClosed-1

    [Documentation]     add closing details to a task.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME65}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${p_id}=  get_acc_id  ${PUSERNAME65}
    Set Suite Variable  ${p_id}

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
    Set Test Variable  ${task_id1}  ${task_id[0]}
    Set Suite Variable  ${task_uid1}  ${task_id[1]}

    ${resp}=    Change User Task Status Closed  ${task_uid1}  
    Log      ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=   Get Task By Id   ${task_uid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${closingNote}=   FakerLibrary.sentence
    ${actualResult}=    FakerLibrary.Random Number
    ${Actual}=   Evaluate    random.uniform(0.0,80)
    ${actualPotential}=  twodigitfloat  ${Actual}

    ${resp}=    Change User Task Closing Details  ${task_uid1}   ${actualResult}   ${actualPotential}   ${closingNote}
    Log      ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=   Get Task By Id   ${task_uid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-ChangeTaskStatusTOClosed-2

    [Documentation]     try to add closing details without closing the task.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME65}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 

    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${task_id}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${task_id1}  ${task_id[0]}
    Set Test Variable  ${task_uid1}  ${task_id[1]}

    ${closingNote}=   FakerLibrary.sentence
    ${actualResult}=    FakerLibrary.Random Number
    ${Actual}=   Evaluate    random.uniform(0.0,80)
    ${actualPotential}=  twodigitfloat  ${Actual}

    ${resp}=    Change User Task Closing Details  ${task_uid1}   ${actualResult}   ${actualPotential}   ${closingNote}
    Log      ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     422
    