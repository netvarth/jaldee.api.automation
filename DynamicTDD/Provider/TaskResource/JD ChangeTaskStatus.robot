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


JD-TC-ChangeTaskStatus-1

    [Documentation]  Change  task  status to Assigned

    ${resp}=   ProviderLogin  ${PUSERNAME43}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${p_id}=  get_acc_id  ${PUSERNAME43}
    Set Suite Variable  ${p_id}

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

    ${resp}=    Get Task Status
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${status_id1}    ${resp.json()[0]['id']}
    Set Suite Variable  ${status_name1}  ${resp.json()[0]['name']}
    Set Suite Variable  ${status_id2}    ${resp.json()[1]['id']}
    Set Suite Variable  ${status_name2}  ${resp.json()[1]['name']}
    Set Suite Variable  ${status_id3}    ${resp.json()[2]['id']}
    Set Suite Variable  ${status_name3}  ${resp.json()[2]['name']}
    Set Suite Variable  ${status_id4}    ${resp.json()[3]['id']}
    Set Suite Variable  ${status_name4}  ${resp.json()[3]['name']}
    Set Suite Variable  ${status_id5}    ${resp.json()[4]['id']}
    Set Suite Variable  ${status_name5}  ${resp.json()[4]['name']}
    


    ${resp}=    Get Task Priority
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${priority_id1}    ${resp.json()[0]['id']}
    Set Test Variable  ${priority_name1}  ${resp.json()[0]['name']}

    ${title}=  FakerLibrary.user name
    Set Suite Variable   ${title}
    ${desc}=   FakerLibrary.word 
    Set Suite Variable   ${desc}
    ${status}=  Create Dictionary   id=${status_id1}
    
    ${priority}=  Create Dictionary   id=${priority_id1}
    Set Suite Variable   ${priority}
    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId}  status=${status}  priority=${priority}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${task_id}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${task_id2}  ${task_id[0]}
    Set Suite Variable  ${task_uid2}  ${task_id[1]}

    ${resp}=   Get Task By Id   ${task_uid2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}                   ${task_id2}
    Should Be Equal As Strings  ${resp.json()['taskUid']}              ${task_uid2} 
    Should Be Equal As Strings  ${resp.json()['accountId']}            ${p_id}
    Should Be Equal As Strings  ${resp.json()['title']}                ${title}
    Should Be Equal As Strings  ${resp.json()['status']['name']}       ${status_name1}
    Should Be Equal As Strings  ${resp.json()['status']['id']}         ${status_id1}

    ${resp}=    Change Task Status   ${task_uid2}  ${status_id2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Task By Id   ${task_uid2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}                   ${task_id2}
    Should Be Equal As Strings  ${resp.json()['taskUid']}              ${task_uid2} 
    Should Be Equal As Strings  ${resp.json()['accountId']}            ${p_id}
    Should Be Equal As Strings  ${resp.json()['title']}                ${title}
    Should Be Equal As Strings  ${resp.json()['status']['name']}       ${status_name2}
    Should Be Equal As Strings  ${resp.json()['status']['id']}         ${status_id2}


JD-TC-ChangeTaskStatus-2

    [Documentation]  Change  task  status to  In Progress

    ${resp}=   ProviderLogin  ${PUSERNAME43}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${status}=  Create Dictionary   id=${status_id2}
  
    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId}  status=${status}  priority=${priority}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${task_id}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${task_id2}  ${task_id[0]}
    Set Test Variable  ${task_uid2}  ${task_id[1]}

    ${resp}=   Get Task By Id   ${task_uid2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}                   ${task_id2}
    Should Be Equal As Strings  ${resp.json()['taskUid']}              ${task_uid2} 
    Should Be Equal As Strings  ${resp.json()['accountId']}            ${p_id}
    Should Be Equal As Strings  ${resp.json()['title']}                ${title}
    Should Be Equal As Strings  ${resp.json()['status']['name']}       ${status_name2}
    Should Be Equal As Strings  ${resp.json()['status']['id']}         ${status_id2}
 
     
    ${resp}=    Change Task Status   ${task_uid2}  ${status_id3}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Task By Id   ${task_uid2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}                   ${task_id2}
    Should Be Equal As Strings  ${resp.json()['taskUid']}              ${task_uid2} 
    Should Be Equal As Strings  ${resp.json()['accountId']}            ${p_id}
    Should Be Equal As Strings  ${resp.json()['title']}                ${title}
    Should Be Equal As Strings  ${resp.json()['status']['name']}       ${status_name3}
    Should Be Equal As Strings  ${resp.json()['status']['id']}         ${status_id3}


JD-TC-ChangeTaskStatus-3

    [Documentation]  Change  task  status to  Canceled

    ${resp}=   ProviderLogin  ${PUSERNAME43}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${status}=  Create Dictionary   id=${status_id3}
  
    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId}  status=${status}  priority=${priority}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${task_id}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${task_id2}  ${task_id[0]}
    Set Test Variable  ${task_uid2}  ${task_id[1]}

    ${resp}=   Get Task By Id   ${task_uid2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}                   ${task_id2}
    Should Be Equal As Strings  ${resp.json()['taskUid']}              ${task_uid2} 
    Should Be Equal As Strings  ${resp.json()['accountId']}            ${p_id}
    Should Be Equal As Strings  ${resp.json()['title']}                ${title}
    Should Be Equal As Strings  ${resp.json()['status']['name']}       ${status_name3}
    Should Be Equal As Strings  ${resp.json()['status']['id']}         ${status_id3}

     
    ${resp}=    Change Task Status   ${task_uid2}  ${status_id4}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Task By Id   ${task_uid2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}                   ${task_id2}
    Should Be Equal As Strings  ${resp.json()['taskUid']}              ${task_uid2} 
    Should Be Equal As Strings  ${resp.json()['accountId']}            ${p_id}
    Should Be Equal As Strings  ${resp.json()['title']}                ${title}
    Should Be Equal As Strings  ${resp.json()['status']['name']}       ${status_name4}
    Should Be Equal As Strings  ${resp.json()['status']['id']}         ${status_id4}



JD-TC-ChangeTaskStatus-4

    [Documentation]  Change  task  status to  completed

    ${resp}=   ProviderLogin  ${PUSERNAME43}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${status}=  Create Dictionary   id=${status_id3}
  
    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId}  status=${status}  priority=${priority}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${task_id}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${task_id2}  ${task_id[0]}
    Set Test Variable  ${task_uid2}  ${task_id[1]}

    ${resp}=   Get Task By Id   ${task_uid2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}                    200
    Should Be Equal As Strings  ${resp.json()['id']}                   ${task_id2}
    Should Be Equal As Strings  ${resp.json()['taskUid']}              ${task_uid2} 
    Should Be Equal As Strings  ${resp.json()['accountId']}            ${p_id}
    Should Be Equal As Strings  ${resp.json()['title']}                ${title}
    Should Be Equal As Strings  ${resp.json()['status']['name']}       ${status_name3}
    Should Be Equal As Strings  ${resp.json()['status']['id']}         ${status_id3}

    ${resp}=    Change Task Status   ${task_uid2}  ${status_id5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Task By Id   ${task_uid2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}                   ${task_id2}
    Should Be Equal As Strings  ${resp.json()['taskUid']}              ${task_uid2} 
    Should Be Equal As Strings  ${resp.json()['accountId']}            ${p_id}
    Should Be Equal As Strings  ${resp.json()['title']}                ${title}
    Should Be Equal As Strings  ${resp.json()['status']['name']}       ${status_name5}
    Should Be Equal As Strings  ${resp.json()['status']['id']}         ${status_id5}
    Should Be Equal As Strings  ${resp.json()['notes']}                []


JD-TC-ChangeTaskStatus-UH5

    [Documentation]  Change  task  status  cancelled to  completed

    ${resp}=   ProviderLogin  ${PUSERNAME43}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${status}=  Create Dictionary   id=${status_id4}
  
    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId}  status=${status}  priority=${priority}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${task_id}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${task_id2}  ${task_id[0]}
    Set Test Variable  ${task_uid2}  ${task_id[1]}

    ${resp}=   Get Task By Id   ${task_uid2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}                   ${task_id2}
    Should Be Equal As Strings  ${resp.json()['taskUid']}              ${task_uid2} 
    Should Be Equal As Strings  ${resp.json()['accountId']}            ${p_id}
    Should Be Equal As Strings  ${resp.json()['title']}                ${title}
    Should Be Equal As Strings  ${resp.json()['status']['name']}       ${status_name4}
    Should Be Equal As Strings  ${resp.json()['status']['id']}         ${status_id4}


    ${resp}=    Change Task Status   ${task_uid2}  ${status_id5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   422

    ${resp}=   Get Task By Id   ${task_uid2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}                  ${task_id2}
    Should Be Equal As Strings  ${resp.json()['taskUid']}             ${task_uid2} 
    Should Be Equal As Strings  ${resp.json()['accountId']}           ${p_id}
    Should Be Equal As Strings  ${resp.json()['title']}               ${title}
    Should Be Equal As Strings  ${resp.json()['status']['name']}      ${status_name5}
    Should Be Equal As Strings  ${resp.json()['status']['id']}        ${status_id5}

JD-TC-ChangeTaskStatus-UH1

    [Documentation]  Change  task  status to  Done already done status

    ${resp}=   ProviderLogin  ${PUSERNAME43}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${status}=  Create Dictionary   id=${status_id5}
  
    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId}  status=${status}  priority=${priority}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${task_id}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${task_id2}  ${task_id[0]}
    Set Test Variable  ${task_uid2}  ${task_id[1]}

    ${resp}=   Get Task By Id   ${task_uid2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}                   ${task_id2}
    Should Be Equal As Strings  ${resp.json()['taskUid']}              ${task_uid2} 
    Should Be Equal As Strings  ${resp.json()['accountId']}            ${p_id}
    Should Be Equal As Strings  ${resp.json()['title']}                ${title}
    Should Be Equal As Strings  ${resp.json()['status']['name']}       ${status_name5}
    Should Be Equal As Strings  ${resp.json()['status']['id']}         ${status_id5}


    ${resp}=    Change Task Status   ${task_uid2}  ${status_id5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${ALREADY_UPDATED}" 


JD-TC-ChangeTaskStatus-UH2

    [Documentation]  Change  task  status to   cancell already cancelled

    ${resp}=   ProviderLogin  ${PUSERNAME43}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${status}=  Create Dictionary   id=${status_id4}
  
    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId}  status=${status}  priority=${priority}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${task_id}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${task_id2}  ${task_id[0]}
    Set Test Variable  ${task_uid2}  ${task_id[1]}

    ${resp}=   Get Task By Id   ${task_uid2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}                   ${task_id2}
    Should Be Equal As Strings  ${resp.json()['taskUid']}              ${task_uid2} 
    Should Be Equal As Strings  ${resp.json()['accountId']}            ${p_id}
    Should Be Equal As Strings  ${resp.json()['title']}                ${title}
    Should Be Equal As Strings  ${resp.json()['status']['name']}       ${status_name4}
    Should Be Equal As Strings  ${resp.json()['status']['id']}         ${status_id4}

     
    ${resp}=    Change Task Status   ${task_uid2}  ${status_id4}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${ALREADY_UPDATED}"  

JD-TC-ChangeTaskStatus-UH3

    [Documentation]  Change  task  status  without login
    
    ${resp}=    Change Task Status   ${task_uid2}  ${status_id5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   419
    Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}"  


JD-TC-ChangeTaskStatus-UH4

    [Documentation]  Change  task  status  with consumer login 

    ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
      
    ${resp}=    Change Task Status   ${task_uid2}  ${status_id5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   401
    Should Be Equal As Strings  "${resp.json()}"   "${NoAccess}"  





