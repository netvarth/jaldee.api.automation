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

JD-TC-UpdateTaskForUser-1

    [Documentation]  Create a task for a branch and update the task with same details.

    ${resp}=  Encrypted Provider Login  ${MUSERNAME10}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${p_id}=  get_acc_id  ${MUSERNAME10}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId10}=  Create Sample Location
        ${resp}=   Get Location ById  ${locId10}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ELSE
        Set Suite Variable  ${locId10}  ${resp.json()[0]['id']}
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
    
    ${resp}=    Get Task Status
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${status_id1}    ${resp.json()[0]['id']}
    Set Test Variable  ${status_name1}  ${resp.json()[0]['name']}

    Set Suite Variable  ${status_id2}    ${resp.json()[1]['id']}
    Set Test Variable  ${status_name2}  ${resp.json()[1]['name']}

    Set Suite Variable  ${status_id3}    ${resp.json()[4]['id']}
    Set Test Variable  ${status_name3}  ${resp.json()[4]['name']}

    ${resp}=    Get Task Priority
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${priority_id1}    ${resp.json()[0]['id']}
    Set Test Variable  ${priority_name1}  ${resp.json()[0]['name']}


    ${status}=  Create Dictionary   id=${status_id1}
    Set Suite Variable  ${status}
    ${status1}=  Create Dictionary   id=${status_id2}
    Set Suite Variable  ${status1}
    ${status2}=  Create Dictionary   id=${status_id3}
    Set Suite Variable  ${status2}
    ${priority}=  Create Dictionary   id=${priority_id1}
    Set Suite Variable  ${priority}


    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 

    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId10}    status=${status}  priority=${priority}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${task_id}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${task_uid1}  ${task_id[1]}
    Set Test Variable  ${task_id1}  ${task_id[0]}
 
    
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
    Should Be Equal As Strings  ${resp.json()['location']['id']}      ${locId10}
   
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

    ${actualPotential}=   Random Int   min=50   max=100
    Set Suite Variable  ${actualPotential}
    ${actualResult}=   Random Int   min=50   max=100
    Set Suite Variable  ${actualResult}

    ${resp}=    Update Task   ${task_uid1}  ${title}  ${desc}  ${category_id1}  ${type_id1}   ${locId10}  status=${status}  priority=${priority}    actualPotential=${actualPotential}    actualResult=${actualResult}
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
    Should Be Equal As Strings  ${resp.json()['location']['id']}      ${locId10}
    Should Be Equal As Strings  ${resp.json()['status']['id']}        ${status_id1} 
    Should Be Equal As Strings  ${resp.json()['priority']['id']}      ${priority_id1}


JD-TC-UpdateTaskForUser-2

    [Documentation]  Create a task for a user and update the task with branch default location.

     ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Suite Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Suite Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    ${firstname_A}=  FakerLibrary.first_name
    Set Suite Variable  ${firstname_A}
    ${lastname_A}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname_A}
    ${MUSERNAME_E}=  Evaluate  ${MUSERNAME}+550648
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${MUSERNAME_E}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${MUSERNAME_E}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${MUSERNAME_E}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${MUSERNAME_E}${\n}
    Append To File  ${EXECDIR}/data/TDD_Logs/providernumbers.txt  ${SUITE NAME} - ${TEST NAME} - ${MUSERNAME_E}${\n}
    Set Suite Variable  ${MUSERNAME_E}
    ${p_id}=  get_acc_id  ${MUSERNAME_E}
    Set Suite Variable    ${p_id}
    ${id}=  get_id  ${MUSERNAME_E}

    ${lid}=  Create Sample Location
    Set Suite Variable  ${lid}
    
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    
    ${lid1}=  Create Sample Location
    Set Suite Variable  ${lid1}

    ${resp}=   Get Location ById  ${lid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz1}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    
    ${lid2}=  Create Sample Location
    Set Suite Variable  ${lid2}
    
    ${resp}=   Get Location ById  ${lid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz2}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    
    ${lid3}=  Create Sample Location
    Set Suite Variable  ${lid3}
    
    ${resp}=   Get Location ById  ${lid3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz3}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    


   
    ${bs}=  FakerLibrary.bs
    Set Suite Variable  ${bs}
    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    
    sleep  2s
    ${resp}=  Get Departments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+3366458
    clear_users  ${PUSERNAME_U1}
    Set Suite Variable  ${PUSERNAME_U1}
    ${firstname}=  FakerLibrary.name
    Set Suite Variable  ${firstname}
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname}
    ${dob}=  FakerLibrary.Date
    Set Suite Variable  ${dob}
     FOR    ${i}    IN RANGE    3
        ${pin}=  get_pincode
        ${kwstatus}  ${resp} =  Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
     END
     Should Be Equal As Strings    ${resp.status_code}    200 
     Set Suite Variable  ${pin}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${city}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Suite Variable  ${state}  ${resp.json()[0]['PostOffice'][0]['State']}      
    Set Suite Variable  ${pin}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    

    ${whpnum}=  Evaluate  ${PUSERNAME}+346245
    ${tlgnum}=  Evaluate  ${PUSERNAME}+346345

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERNAME_U1}  ${dep_id}  ${EMPTY}  ${bool[1]}  ${countryCodes[1]}  ${whpnum}  ${countryCodes[1]}  ${tlgnum}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id}  ${resp.json()}

    ${resp}=  Get User By Id  ${u_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SendProviderResetMail   ${PUSERNAME_U1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${PUSERNAME_U1}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${locId}=  Create Sample Location

    ${resp}=   Get Location ById  ${locId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}


    ${title}=  FakerLibrary.user name
    Set Suite Variable  ${title}
    ${desc}=   FakerLibrary.word 
    Set Suite Variable   ${desc}
    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId}   status=${status}  priority=${priority}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${task_id}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${task_uid2}  ${task_id[1]}
    Set Suite Variable  ${task_id2}  ${task_id[0]}
 

    ${resp}=    Update Task   ${task_uid2}  ${title}  ${desc}  ${category_id1}  ${type_id1}   ${lid}   status=${status}  priority=${priority}    actualPotential=${actualPotential}    actualResult=${actualResult}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    

    ${resp}=   Get Task By Id   ${task_uid2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['id']}                  ${task_id2}
    Should Be Equal As Strings  ${resp.json()['taskUid']}             ${task_uid2}
    Should Be Equal As Strings  ${resp.json()['accountId']}           ${p_id}
    Should Be Equal As Strings  ${resp.json()['title']}               ${title}
    Should Be Equal As Strings  ${resp.json()['description']}         ${desc}
    Should Be Equal As Strings  ${resp.json()['category']['id']}      ${category_id1} 
    Should Be Equal As Strings  ${resp.json()['type']['id']}          ${type_id1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}      ${lid}
   


JD-TC-UpdateTaskForUser-3

    [Documentation]  Create a task for a user and update the task with different location.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

  
  
    ${l_id1}=  Create Sample Location
    Set Suite Variable   ${l_id1}

    ${resp}=    Update Task   ${task_uid2}  ${title}  ${desc}  ${category_id1}  ${type_id1}   ${l_id1}  status=${status}  priority=${priority}    actualPotential=${actualPotential}    actualResult=${actualResult}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Task By Id   ${task_uid2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['id']}                  ${task_id2}
    Should Be Equal As Strings  ${resp.json()['taskUid']}             ${task_uid2}
    Should Be Equal As Strings  ${resp.json()['accountId']}           ${p_id}
    Should Be Equal As Strings  ${resp.json()['title']}               ${title}
    Should Be Equal As Strings  ${resp.json()['description']}         ${desc}
    Should Be Equal As Strings  ${resp.json()['category']['id']}      ${category_id1} 
    Should Be Equal As Strings  ${resp.json()['type']['id']}          ${type_id1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}      ${l_id1}
    Should Be Equal As Strings  ${resp.json()['status']['id']}        ${status_id1} 
    Should Be Equal As Strings  ${resp.json()['priority']['id']}      ${priority_id1}


JD-TC-UpdateTaskForUser-4

    [Documentation]  Create a task for a user and update the task with another title.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

  
    ${title11}=  FakerLibrary.user name
    Set Suite Variable   ${title11}

    ${resp}=    Update Task   ${task_uid2}  ${title11}  ${desc}  ${category_id1}  ${type_id1}   ${l_id1}  status=${status}  priority=${priority}    actualPotential=${actualPotential}    actualResult=${actualResult}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Task By Id   ${task_uid2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

   
    Should Be Equal As Strings  ${resp.json()['id']}                  ${task_id2}
    Should Be Equal As Strings  ${resp.json()['taskUid']}             ${task_uid2}
    Should Be Equal As Strings  ${resp.json()['accountId']}           ${p_id}
    Should Be Equal As Strings  ${resp.json()['title']}               ${title11}
    Should Be Equal As Strings  ${resp.json()['description']}         ${desc}
    Should Be Equal As Strings  ${resp.json()['category']['id']}      ${category_id1} 
    Should Be Equal As Strings  ${resp.json()['type']['id']}          ${type_id1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}      ${l_id1}
    Should Be Equal As Strings  ${resp.json()['status']['id']}        ${status_id1} 
    Should Be Equal As Strings  ${resp.json()['priority']['id']}      ${priority_id1}


JD-TC-UpdateTaskForUser-5

    [Documentation]  Create a task for a user and update the task with another description.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

  
    ${desc11}=  FakerLibrary.word
    Set Suite Variable   ${desc11}

    ${resp}=    Update Task   ${task_uid2}  ${title11}  ${desc11}  ${category_id1}  ${type_id1}   ${l_id1}  status=${status}  priority=${priority}    actualPotential=${actualPotential}    actualResult=${actualResult}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Task By Id   ${task_uid2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['id']}                  ${task_id2}
    Should Be Equal As Strings  ${resp.json()['taskUid']}             ${task_uid2}
    Should Be Equal As Strings  ${resp.json()['accountId']}           ${p_id}
    Should Be Equal As Strings  ${resp.json()['title']}               ${title11}
    Should Be Equal As Strings  ${resp.json()['description']}         ${desc11}
    Should Be Equal As Strings  ${resp.json()['category']['id']}      ${category_id1} 
    Should Be Equal As Strings  ${resp.json()['type']['id']}          ${type_id1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}      ${l_id1}
    Should Be Equal As Strings  ${resp.json()['status']['id']}        ${status_id1} 
    Should Be Equal As Strings  ${resp.json()['priority']['id']}      ${priority_id1}


JD-TC-UpdateTaskForUser-6

    [Documentation]  Create a task for a user and update the task with another category.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  categorytype  ${p_id}
    ${resp}=  tasktype      ${p_id}
    ${resp}=    Get Task Category Type
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cat_id1}    ${resp.json()[0]['id']}
    Set Test Variable  ${category_name1}  ${resp.json()[0]['name']}

    ${resp}=    Get Task Type
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${type_id1}    ${resp.json()[0]['id']}
    Set Test Variable  ${type_name1}  ${resp.json()[0]['name']}

    ${resp}=    Update Task   ${task_uid2}  ${title11}  ${desc11}  ${cat_id1}  ${type_id1}   ${l_id1}  status=${status}  priority=${priority}    actualPotential=${actualPotential}    actualResult=${actualResult}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Task By Id   ${task_uid2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['id']}                  ${task_id2}
    Should Be Equal As Strings  ${resp.json()['taskUid']}             ${task_uid2}
    Should Be Equal As Strings  ${resp.json()['accountId']}           ${p_id}
    Should Be Equal As Strings  ${resp.json()['title']}               ${title11}
    Should Be Equal As Strings  ${resp.json()['description']}         ${desc11}
    Should Be Equal As Strings  ${resp.json()['category']['id']}      ${cat_id1} 
    Should Be Equal As Strings  ${resp.json()['type']['id']}          ${type_id1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}      ${l_id1}
    Should Be Equal As Strings  ${resp.json()['status']['id']}        ${status_id1} 
    Should Be Equal As Strings  ${resp.json()['priority']['id']}      ${priority_id1}


JD-TC-UpdateTaskForUser-7

    [Documentation]  Create a task for a user and update the task with another task type.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Task Type
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${type_id11}    ${resp.json()[0]['id']}
    Set Test Variable  ${type_name11}  ${resp.json()[0]['name']}

    ${resp}=    Update Task   ${task_uid2}  ${title11}  ${desc11}  ${cat_id1}  ${type_id11}   ${l_id1}  status=${status}  priority=${priority}    actualPotential=${actualPotential}    actualResult=${actualResult}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Task By Id   ${task_uid2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['id']}                  ${task_id2}
    Should Be Equal As Strings  ${resp.json()['taskUid']}             ${task_uid2}
    Should Be Equal As Strings  ${resp.json()['accountId']}           ${p_id}
    Should Be Equal As Strings  ${resp.json()['title']}               ${title11}
    Should Be Equal As Strings  ${resp.json()['description']}         ${desc11}
    Should Be Equal As Strings  ${resp.json()['category']['id']}      ${cat_id1} 
    Should Be Equal As Strings  ${resp.json()['type']['id']}          ${type_id11}
    Should Be Equal As Strings  ${resp.json()['location']['id']}      ${l_id1}
    Should Be Equal As Strings  ${resp.json()['status']['id']}        ${status_id1} 
    Should Be Equal As Strings  ${resp.json()['priority']['id']}      ${priority_id1}


JD-TC-UpdateTaskForUser-8

    [Documentation]  Create a task for a user and update the task with another status and priority.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=    Get Task Status
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${status_id11}    ${resp.json()[2]['id']}
    # Set Test Variable  ${status_name11}  ${resp.json()[2]['name']}

    ${resp}=    Get Task Priority
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${priority_id11}    ${resp.json()[2]['id']}
    Set Test Variable  ${priority_name11}  ${resp.json()[2]['name']}

    # ${status}=  Create Dictionary   id=${status_id11}
    # Set Suite Variable  ${status}
    ${priority}=  Create Dictionary   id=${priority_id11}
    Set Suite Variable  ${priority}

    ${resp}=    Update Task   ${task_uid2}  ${title11}  ${desc11}  ${cat_id1}  ${type_id11}   ${l_id1}    status=${status}    priority=${priority}    actualPotential=${actualPotential}    actualResult=${actualResult}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Task By Id   ${task_uid2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['id']}                  ${task_id2}
    Should Be Equal As Strings  ${resp.json()['taskUid']}             ${task_uid2}
    Should Be Equal As Strings  ${resp.json()['accountId']}           ${p_id}
    Should Be Equal As Strings  ${resp.json()['title']}               ${title11}
    Should Be Equal As Strings  ${resp.json()['description']}         ${desc11}
    Should Be Equal As Strings  ${resp.json()['category']['id']}      ${cat_id1} 
    Should Be Equal As Strings  ${resp.json()['type']['id']}          ${type_id11}
    Should Be Equal As Strings  ${resp.json()['location']['id']}      ${l_id1}
    Should Be Equal As Strings  ${resp.json()['status']['id']}        ${status_id1} 
    Should Be Equal As Strings  ${resp.json()['priority']['id']}      ${priority_id11}


JD-TC-UpdateTaskForUser-9

    [Documentation]    Update task without title.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Update Task   ${task_uid2}  ${EMPTY}  ${desc11}  ${cat_id1}  ${type_id11}   ${l_id1}   status=${status}   priority=${priority}    actualPotential=${actualPotential}    actualResult=${actualResult}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Task By Id   ${task_uid2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['id']}                  ${task_id2}
    Should Be Equal As Strings  ${resp.json()['taskUid']}             ${task_uid2}
    Should Be Equal As Strings  ${resp.json()['accountId']}           ${p_id}
    Should Be Equal As Strings  ${resp.json()['title']}               ${EMPTY}
    Should Be Equal As Strings  ${resp.json()['description']}         ${desc11}
    Should Be Equal As Strings  ${resp.json()['category']['id']}      ${cat_id1} 
    Should Be Equal As Strings  ${resp.json()['type']['id']}          ${type_id11}
    Should Be Equal As Strings  ${resp.json()['location']['id']}      ${l_id1}
    Should Be Equal As Strings  ${resp.json()['status']['id']}        ${status_id1} 
    Should Be Equal As Strings  ${resp.json()['priority']['id']}      ${priority_id11}


JD-TC-UpdateTaskForUser-10

    [Documentation]    Update task without description.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Update Task   ${task_uid2}  ${title11}  ${EMPTY}  ${cat_id1}  ${type_id11}   ${l_id1}    status=${status}    priority=${priority}    actualPotential=${actualPotential}    actualResult=${actualResult}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Task By Id   ${task_uid2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['id']}                  ${task_id2}
    Should Be Equal As Strings  ${resp.json()['taskUid']}             ${task_uid2}
    Should Be Equal As Strings  ${resp.json()['accountId']}           ${p_id}
    Should Be Equal As Strings  ${resp.json()['title']}               ${title11}
    Should Be Equal As Strings  ${resp.json()['description']}         ${EMPTY}
    Should Be Equal As Strings  ${resp.json()['category']['id']}      ${cat_id1} 
    Should Be Equal As Strings  ${resp.json()['type']['id']}          ${type_id11}
    Should Be Equal As Strings  ${resp.json()['location']['id']}      ${l_id1}
    Should Be Equal As Strings  ${resp.json()['status']['id']}        ${status_id1} 
    Should Be Equal As Strings  ${resp.json()['priority']['id']}      ${priority_id11}


JD-TC-UpdateTaskForUser-UH8

    [Documentation]  Create a task for a user and update the task by branch.  

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${title10}=  FakerLibrary.user name
    Set Suite Variable  ${title10}
    ${desc10}=   FakerLibrary.word 
    Set Suite Variable   ${desc10}
    ${resp}=    Create Task   ${title10}  ${desc10}   ${userType[0]}  ${category_id1}  ${type_id1}    ${l_id1}   status=${status}  priority=${priority}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${task_id}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${task_uid10}  ${task_id[1]}
    Set Suite Variable  ${task_id10}  ${task_id[0]}

    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Update Task    ${task_uid10}    ${title10}  ${desc10}   ${category_id1}  ${type_id1}    ${l_id1}   status=${status}  priority=${priority}    actualPotential=${actualPotential}    actualResult=${actualResult}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Task By Id   ${task_uid10}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['id']}                  ${task_id10}
    Should Be Equal As Strings  ${resp.json()['taskUid']}             ${task_uid10}
    Should Be Equal As Strings  ${resp.json()['accountId']}           ${p_id}
    Should Be Equal As Strings  ${resp.json()['title']}               ${title10}
    Should Be Equal As Strings  ${resp.json()['description']}         ${desc10}
    Should Be Equal As Strings  ${resp.json()['category']['id']}      ${category_id1} 
    Should Be Equal As Strings  ${resp.json()['type']['id']}          ${type_id1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}      ${l_id1}
    Should Be Equal As Strings  ${resp.json()['status']['id']}        ${status_id1} 
    Should Be Equal As Strings  ${resp.json()['priority']['id']}      ${priority_id11}


JD-TC-UpdateTaskForUser-UH9

    [Documentation]  Create a task for a user and update the task by another user of same branch.

    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${PUSERNAME_U2}=  Evaluate  ${PUSERNAME}+33986
    clear_users  ${PUSERNAME_U1}
    Set Suite Variable  ${PUSERNAME_U2}
    ${firstname1}=  FakerLibrary.name
    Set Suite Variable  ${firstname1}
    ${lastname1}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname1}
    
    ${whpnum}=  Evaluate  ${PUSERNAME}+3462087
    ${tlgnum}=  Evaluate  ${PUSERNAME}+346341

    ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U2}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERNAME_U2}  ${dep_id}  ${EMPTY}  ${bool[1]}  ${countryCodes[1]}  ${whpnum}  ${countryCodes[1]}  ${tlgnum}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id1}  ${resp.json()}

    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SendProviderResetMail   ${PUSERNAME_U2}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${PUSERNAME_U2}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200


    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${locId}=  Create Sample Location

    ${resp}=   Get Location ById  ${locId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}


    ${title}=  FakerLibrary.user name
    Set Suite Variable  ${title}
    ${desc}=   FakerLibrary.word 
    Set Suite Variable   ${desc}
    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId}   status=${status}  priority=${priority}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${task_id}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${task_uid3}  ${task_id[1]}
    Set Suite Variable  ${task_id3}  ${task_id[0]}
   

    ${PUSERNAME_U4}=  Evaluate  ${PUSERNAME}+33669
    clear_users  ${PUSERNAME_U4}
    Set Suite Variable  ${PUSERNAME_U4}
    ${firstname2}=  FakerLibrary.name
    Set Suite Variable  ${firstname2}
    ${lastname2}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname2}
    
    ${whpnum}=  Evaluate  ${PUSERNAME}+346205
    ${tlgnum}=  Evaluate  ${PUSERNAME}+346391

    ${resp}=  Create User  ${firstname2}  ${lastname2}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U4}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERNAME_U4}  ${dep_id}  ${EMPTY}  ${bool[1]}  ${countryCodes[1]}  ${whpnum}  ${countryCodes[1]}  ${tlgnum}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id6}  ${resp.json()}

    ${resp}=  Get User By Id  ${u_id6}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SendProviderResetMail   ${PUSERNAME_U4}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${PUSERNAME_U4}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200


    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U4}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Update Task   ${task_uid3}   ${title}  ${desc}     ${category_id1}  ${type_id1}   ${locId}   status=${status}  priority=${priority}    actualPotential=${actualPotential}    actualResult=${actualResult}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Task By Id   ${task_uid3}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['id']}                  ${task_id3}
    Should Be Equal As Strings  ${resp.json()['taskUid']}             ${task_uid3}
    Should Be Equal As Strings  ${resp.json()['accountId']}           ${p_id}
    Should Be Equal As Strings  ${resp.json()['title']}               ${title}
    Should Be Equal As Strings  ${resp.json()['description']}         ${desc}
    Should Be Equal As Strings  ${resp.json()['category']['id']}      ${category_id1} 
    Should Be Equal As Strings  ${resp.json()['type']['id']}          ${type_id1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}      ${locId}
    Should Be Equal As Strings  ${resp.json()['status']['id']}        ${status_id1} 
    Should Be Equal As Strings  ${resp.json()['priority']['id']}      ${priority_id11}

    

   


JD-TC-UpdateTaskForUser-UH7

    [Documentation]  Create a task for a user and update the task by another user of another branch.

    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Suite Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Suite Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    ${firstname_A}=  FakerLibrary.first_name
    Set Suite Variable  ${firstname_A}
    ${lastname_A}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname_A}
    ${MUSERNAME_A}=  Evaluate  ${MUSERNAME}+550296
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${MUSERNAME_A}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${MUSERNAME_A}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${MUSERNAME_A}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_A}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${MUSERNAME_A}${\n}
    Set Suite Variable  ${MUSERNAME_A}
    ${p_id}=  get_acc_id  ${MUSERNAME_A}
    Set Suite Variable    ${p_id}
    ${id}=  get_id  ${MUSERNAME_A}
    Set Suite Variable   ${id}
    ${lid}=  Create Sample Location
    Set Suite Variable  ${lid}
    
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    
    ${lid1}=  Create Sample Location
    Set Suite Variable  ${lid1}

    ${resp}=   Get Location ById  ${lid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz1}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    
    ${lid2}=  Create Sample Location
    Set Suite Variable  ${lid2}
    
    ${resp}=   Get Location ById  ${lid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz2}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    
    ${lid3}=  Create Sample Location
    Set Suite Variable  ${lid3}
    
    ${resp}=   Get Location ById  ${lid3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz3}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    


   
    ${bs}=  FakerLibrary.bs
    Set Suite Variable  ${bs}
    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    
    sleep  2s
    ${resp}=  Get Departments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    ${PUSERNAME_U3}=  Evaluate  ${PUSERNAME}+3366423
    clear_users  ${PUSERNAME_U3}
    Set Suite Variable  ${PUSERNAME_U3}
    ${firstname}=  FakerLibrary.name
    Set Suite Variable  ${firstname}
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname}
    ${dob}=  FakerLibrary.Date
    Set Suite Variable  ${dob}
     FOR    ${i}    IN RANGE    3
        ${pin}=  get_pincode
        ${kwstatus}  ${resp} =  Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
     END
     Should Be Equal As Strings    ${resp.status_code}    200 
     Set Suite Variable  ${pin}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${city}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Suite Variable  ${state}  ${resp.json()[0]['PostOffice'][0]['State']}      
    Set Suite Variable  ${pin}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    

    ${whpnum}=  Evaluate  ${PUSERNAME}+346296
    ${tlgnum}=  Evaluate  ${PUSERNAME}+346392

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U3}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERNAME_U3}  ${dep_id}  ${EMPTY}  ${bool[1]}  ${countryCodes[1]}  ${whpnum}  ${countryCodes[1]}  ${tlgnum}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id3}  ${resp.json()}

    ${resp}=  Get User By Id  ${u_id3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SendProviderResetMail   ${PUSERNAME_U3}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${PUSERNAME_U3}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U3}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${locId}=  Create Sample Location

    ${resp}=   Get Location ById  ${locId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}


    ${title}=  FakerLibrary.user name
    Set Suite Variable  ${title}
    ${desc}=   FakerLibrary.word 
    Set Suite Variable   ${desc}
    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId}   status=${status}  priority=${priority}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${task_id}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${task_uid5}  ${task_id[1]}
    Set Suite Variable  ${task_id5}  ${task_id[0]}

    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200



    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Update Task   ${task_uid5}   ${title}  ${desc}     ${category_id1}  ${type_id1}   ${locId}   status=${status}  priority=${priority}    actualPotential=${actualPotential}    actualResult=${actualResult}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422 
    Should Be Equal As Strings   ${resp.json()}    ${NO_PERMISSION}

JD-TC-UpdateTaskForUser-14

    [Documentation]  Create a task for a branch then change assignee  to user and try to update the task by branch login.


    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${p_id}=  get_acc_id  ${MUSERNAME_E}
     ${locId}=  Create Sample Location

    ${resp}=   Get Location ById  ${locId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}


    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 

    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId}  status=${status}  priority=${priority}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${task_id}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${task_uid1}  ${task_id[1]}
    Set Test Variable  ${task_id1}  ${task_id[0]}


    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=    Change Assignee    ${task_uid1}    ${u_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Task By Id   ${task_uid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['status']['id']}        ${status_id1}
    Set Suite Variable   ${status11}   ${resp.json()['status']['id']}
    
    ${resp}=    Update Task   ${task_uid1}  ${title}  ${desc}  ${category_id1}  ${type_id1}   ${locId}    status=${status1}     priority=${priority}    actualPotential=${actualPotential}    actualResult=${actualResult}
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
    Should Be Equal As Strings  ${resp.json()['type']['id']}         ${type_id1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}       ${locId}
    Should Be Equal As Strings  ${resp.json()['status']['id']}        ${status11} 
    Should Be Equal As Strings  ${resp.json()['priority']['id']}      ${priority_id11}

    
JD-TC-UpdateTaskForUser-15

    [Documentation]  Create a task for a user then change assignee  to branch and try to update the task by user login.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U3}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${locId}=  Create Sample Location

    ${resp}=   Get Location ById  ${locId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}


    ${title}=  FakerLibrary.user name
    Set Suite Variable  ${title}
    ${desc}=   FakerLibrary.word 
    Set Suite Variable   ${desc}
    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId}   status=${status}  priority=${priority}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${task_id}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${task_uid5}  ${task_id[1]}
    Set Suite Variable  ${task_id5}  ${task_id[0]}
    
     ${resp}=  Get User By Id  ${u_id3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=    Change Assignee    ${task_uid5}    ${id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Update Task   ${task_uid5}  ${title}  ${desc}  ${category_id1}  ${type_id1}   ${locId}    status=${status1}    priority=${priority}    actualPotential=${actualPotential}    actualResult=${actualResult}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Task By Id   ${task_uid5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['id']}                  ${task_id5}
    Should Be Equal As Strings  ${resp.json()['taskUid']}             ${task_uid5}
    Should Be Equal As Strings  ${resp.json()['accountId']}           ${p_id}
    Should Be Equal As Strings  ${resp.json()['title']}               ${title}
    Should Be Equal As Strings  ${resp.json()['description']}         ${desc} 
    Should Be Equal As Strings  ${resp.json()['category']['id']}      ${category_id1} 
    Should Be Equal As Strings  ${resp.json()['type']['id']}         ${type_id1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}       ${locId}
    Should Be Equal As Strings  ${resp.json()['status']['id']}        ${status11} 
   

JD-TC-UpdateTaskForUser-UH10

    [Documentation]   update the task after change the task status to closed.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U3}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${locId}=  Create Sample Location

    ${title1}=  FakerLibrary.user name
    Set Suite Variable  ${title1}
    ${desc}=   FakerLibrary.word 
    Set Suite Variable   ${desc}
    ${resp}=    Create Task   ${title1}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId}   status=${status}  priority=${priority}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${task_id}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${task_uid16}  ${task_id[1]}
    Set Suite Variable  ${task_id16}  ${task_id[0]}

    ${resp}=    Change User Task Status Closed  ${task_uid16}  
    Log      ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=   Get Task By Id   ${task_uid16}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${status12}   ${resp.json()['status']['id']}

    ${resp}=    Update Task   ${task_uid16}  ${title}  ${desc}  ${category_id1}  ${type_id1}   ${locId}    status=${status2}    priority=${priority}    actualPotential=${actualPotential}    actualResult=${actualResult}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422    
    Should Be Equal As Strings   ${resp.json()}    ${TASK_ALREADY_COMPLETED}
    

JD-TC-UpdateTaskForUser-UH1

    [Documentation]    Update task without location.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Update Task   ${task_uid3}  ${title11}  ${desc11}  ${cat_id1}  ${type_id11}   ${EMPTY}  status=${status}  priority=${priority}    actualPotential=${actualPotential}    actualResult=${actualResult}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}    ${LOCATION_REQUIRED}

    
JD-TC-UpdateTaskForUser-UH2

    [Documentation]    Update task invalid location id

     ${resp}=  Encrypted Provider Login  ${PUSERNAME_U2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Update Task   ${task_uid3}  ${title11}  ${desc11}     ${cat_id1}  ${type_id11}   00  status=${status}  priority=${priority}    actualPotential=${actualPotential}    actualResult=${actualResult}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}    ${LOCATION_REQUIRED}

JD-TC-UpdateTaskForUser-UH3

    [Documentation]  update task without status.
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${p_id1}=  get_acc_id   ${PUSERNAME_U2} 
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

    ${resp}=    Create Task   ${title1}  ${desc1}    ${userType[0]}   ${category_id2}  ${type_id2}   ${locId1}   status=${status}  priority=${priority}
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

    ${resp}=    Update Task   ${task_uid2}  ${title1}  ${desc1}  ${category_id2}  ${type_id2}   ${locId1}    actualPotential=${actualPotential}    actualResult=${actualResult}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}    ${STATUS_REQUIRED}

JD-TC-UpdateTaskForUser-UH4

    [Documentation]  update task without priority.

     ${resp}=  Encrypted Provider Login  ${PUSERNAME_U2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Task Status
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${status_id1}    ${resp.json()[0]['id']}
    Set Test Variable  ${status_name1}  ${resp.json()[0]['name']}

    ${status}=  Create Dictionary   id=${status_id1}

    ${resp}=    Update Task   ${task_uid2}  ${title1}  ${desc1}  ${category_id2}  ${type_id2}   ${locId1}   status=${status}     actualPotential=${actualPotential}    actualResult=${actualResult}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}    ${PRIORITY_REQUIRED}


JD-TC-UpdateTaskForUser-UH5

    [Documentation]    Update task without login.

    ${resp}=    Update Task   ${task_uid5}  ${title11}  ${desc11}  ${cat_id1}  ${type_id11}   ${l_id1}  status=${status}  priority=${priority}    actualPotential=${actualPotential}    actualResult=${actualResult}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.json()}   ${SESSION_EXPIRED}


JD-TC-UpdateTaskForUser-UH6

    [Documentation]    Update task with consumer login.

    ${resp}=   ConsumerLogin  ${CUSERNAME8}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Update Task   ${task_uid5}  ${title11}  ${desc11}  ${cat_id1}  ${type_id11}   ${l_id1}  status=${status}  priority=${priority}    actualPotential=${actualPotential}    actualResult=${actualResult}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   ${resp.json()}    ${LOGIN_NO_ACCESS_FOR_URL}

