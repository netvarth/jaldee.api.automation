
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
Variables         /ebs/TDD/varfiles/hl_musers.py

*** Variables ***

@{emptylist} 
#${progressValue}  58%



*** Test Cases ***



JD-TC-AddTaskProgressForUser-1

    [Documentation]  Create a task for a  branch and get a provider task.


    ${resp}=  Encrypted Provider Login  ${MUSERNAME10}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${p_id}=  get_acc_id  ${MUSERNAME10}

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
    Set Test Variable  ${task_uid1}  ${task_id[1]}
    Set Test Variable  ${task_id1}  ${task_id[0]}
    ${note}=    FakerLibrary.sentence 
    
    ${Value}=   Evaluate    random.uniform(0.0,80)
    ${progressValue}=  twodigitfloat  ${Value}
    ${resp}=    Add Task Progress For User    ${task_uid1}   ${progressValue}     ${note}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=   Get Task By Id   ${task_uid1}
    Log   ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}                   ${task_id1}
    Should Be Equal As Strings  ${resp.json()['taskUid']}              ${task_uid1} 
    Should Be Equal As Strings  ${resp.json()['accountId']}             ${p_id}
    Should Be Equal As Strings  ${resp.json()['title']}                ${title}
    Should Be Equal As Strings  ${resp.json()['description']}          ${desc}
    Should Be Equal As Strings  ${resp.json()['category']['id']}         ${category_id1} 
    Should Be Equal As Strings  ${resp.json()['type']['id']}             ${type_id1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}         ${locId}
    Should Be Equal As Strings  ${resp.json()['progressNotes'][0]['note']}               ${note}
    Should Be Equal As Numbers  ${resp.json()['progressNotes'][0]['progress']}       ${progressValue}
  
JD-TC-AddTaskProgressForUser-2

    [Documentation]  Create a task for a user and add task progress by user
   
    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Suite Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Suite Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    ${firstname_A}=  FakerLibrary.first_name
    Set Suite Variable  ${firstname_A}
    ${lastname_A}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname_A}
    ${MUSERNAME_E}=  Evaluate  ${MUSERNAME}+501785
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
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${MUSERNAME_E}${\n}
    Set Suite Variable  ${MUSERNAME_E}
    ${id}=  get_id  ${MUSERNAME_E}
    Set Suite Variable  ${id}
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

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[2]}  ${pin}  ${countryCodes[1]}  ${PUSERNAME_U1}  ${dep_id}  ${EMPTY}  ${bool[0]}  ${countryCodes[1]}  ${whpnum}  ${countryCodes[1]}  ${tlgnum}
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
    ${p_id}=  get_acc_id  ${PUSERNAME_U1}



    ${locId}=  Create Sample Location

    ${resp}=   Get Location ById  ${locId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}


    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 

    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${task_uid1}   ${resp.json()['uid']} 
    Set Suite Variable  ${task_id1}    ${resp.json()['id']} 
   

    ${note}=    FakerLibrary.sentence 
    
    ${Value}=   Evaluate    random.uniform(0.0,80)
    ${progressValue}=  twodigitfloat  ${Value}
    ${resp}=    Add Task Progress For User    ${task_uid1}   ${progressValue}     ${note}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=   Get Task By Id   ${task_uid1}
    Log   ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}                   ${task_id1}
    Should Be Equal As Strings  ${resp.json()['taskUid']}              ${task_uid1} 
    Should Be Equal As Strings  ${resp.json()['accountId']}             ${p_id}
    Should Be Equal As Strings  ${resp.json()['title']}                ${title}
    Should Be Equal As Strings  ${resp.json()['description']}          ${desc}
    Should Be Equal As Strings  ${resp.json()['category']['id']}         ${category_id1} 
    Should Be Equal As Strings  ${resp.json()['type']['id']}             ${type_id1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}         ${locId}
    Should Be Equal As Strings  ${resp.json()['progressNotes'][0]['note']}               ${note}
    Should Be Equal As Numbers  ${resp.json()['progressNotes'][0]['progress']}       ${progressValue}
  
  

JD-TC-AddTaskProgressForUser-UH1

    [Documentation]  Create task for branch and add task progress by user

    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${locId}=  Create Sample Location
    ${p_id1}=  get_acc_id    ${MUSERNAME_E}
    

    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 

    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${task_uid}   ${resp.json()['uid']} 
    Set Suite Variable  ${task_id}    ${resp.json()['id']} 
    

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${p_id}=  get_acc_id  ${PUSERNAME_U1}
    
  

    ${note}=    FakerLibrary.sentence 
    
    ${Value}=   Evaluate    random.uniform(0.0,80)
    ${progressValue}=  twodigitfloat  ${Value}
    ${resp}=    Add Task Progress For User    ${task_uid}   ${progressValue}     ${note}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()}    ${bool[1]}

   
 
JD-TC-AddTaskProgressForUser-UH2

    [Documentation]  Create task for user and add task progress by branch

     
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${p_id}=  get_acc_id  ${PUSERNAME_U1}



    ${locId}=  Create Sample Location

    ${resp}=   Get Location ById  ${locId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}


    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 

    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${task_uid2}   ${resp.json()['uid']} 
    Set Suite Variable  ${task_id2}    ${resp.json()['id']} 
    
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${note}=    FakerLibrary.sentence 
    
    ${Value}=   Evaluate    random.uniform(0.0,80)
    ${progressValue}=  twodigitfloat  ${Value}
    ${resp}=    Add Task Progress For User    ${task_uid2}   ${progressValue}     ${note}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()}    ${bool[1]}

JD-TC-AddTaskProgressForUser-UH3

    [Documentation]  Create task for user and add task progress by another user same branch

     ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${PUSERNAME_U2}=  Evaluate  ${PUSERNAME}+3366234
    clear_users  ${PUSERNAME_U1}
    Set Suite Variable  ${PUSERNAME_U2}
    ${firstname1}=  FakerLibrary.name
    Set Suite Variable  ${firstname1}
    ${lastname1}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname1}
    
    ${whpnum}=  Evaluate  ${PUSERNAME}+346297
    ${tlgnum}=  Evaluate  ${PUSERNAME}+346341

    ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U2}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERNAME_U2}  ${dep_id}  ${EMPTY}  ${bool[0]}  ${countryCodes[1]}  ${whpnum}  ${countryCodes[1]}  ${tlgnum}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id1}  ${resp.json()}

    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${PUSERNAME_U4}=  Evaluate  ${PUSERNAME}+3366902
    clear_users  ${PUSERNAME_U4}
    Set Suite Variable  ${PUSERNAME_U4}
    ${firstname2}=  FakerLibrary.name
    Set Suite Variable  ${firstname2}
    ${lastname2}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname2}
    
    ${whpnum}=  Evaluate  ${PUSERNAME}+346205
    ${tlgnum}=  Evaluate  ${PUSERNAME}+346391

    ${resp}=  Create User  ${firstname2}  ${lastname2}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U4}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERNAME_U4}  ${dep_id}  ${EMPTY}  ${bool[0]}  ${countryCodes[1]}  ${whpnum}  ${countryCodes[1]}  ${tlgnum}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id6}  ${resp.json()}

    ${resp}=  Get User By Id  ${u_id6}
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

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${locId}  ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    # ${locId}=  Create Sample Location


    ${title}=  FakerLibrary.user name
    Set Suite Variable  ${title}
    ${desc}=   FakerLibrary.word 
    Set Suite Variable   ${desc}
    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${task_id}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${task_uid3}  ${task_id[1]}
    Set Suite Variable  ${task_id3}  ${task_id[0]}
   
    ${resp}=  SendProviderResetMail   ${PUSERNAME_U4}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${PUSERNAME_U4}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200


    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U4}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${NO_PERMISSION_UPDATE_TASK}=   Replace String  ${NO_PERMISSION_TO_UPDATE_TASK}  {}  activity
    
    ${note}=    FakerLibrary.sentence 
    
    ${Value}=   Evaluate    random.uniform(0.0,80)
    ${progressValue}=  twodigitfloat  ${Value}
    ${resp}=    Add Task Progress For User    ${task_uid3}   ${progressValue}     ${note}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  403
    Should Be Equal As Strings   ${resp.json()}     ${NO_PERMISSION_UPDATE_TASK}

    


   
JD-TC-AddTaskProgressForUser-UH4

    [Documentation]  Create task for user and add task progress by another  branch

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${locId}=  Create Sample Location
    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${locId}  ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}

    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${task_id}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${task_uid4}  ${task_id[1]}
    Set Suite Variable  ${task_id4}  ${task_id[0]}
     
    ${resp}=  Encrypted Provider Login  ${MUSERNAME10}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${p_id}=  get_acc_id  ${MUSERNAME10}

    ${note}=    FakerLibrary.sentence 
    
    ${Value}=   Evaluate    random.uniform(0.0,80)
    ${progressValue}=  twodigitfloat  ${Value}
    ${resp}=    Add Task Progress For User    ${task_uid4}   ${progressValue}     ${note}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}    ${NO_PERMISSION}

    


 
JD-TC-AddTaskProgressForUser-UH5

    [Documentation]  Without login

    ${note}=    FakerLibrary.sentence 
    
    ${Value}=   Evaluate    random.uniform(0.0,80)
    ${progressValue}=  twodigitfloat  ${Value}
   
    ${resp}=    Add Task Progress For User    ${task_uid4}   ${progressValue}     ${note}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-AddTaskProgressForUser-3

    [Documentation]   create task for one user and assingee to another user same branch and add progress by first user(task creating user)


    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${locId}=  Create Sample Location
    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${locId}  ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}

    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${task_id}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${task_uid4}  ${task_id[1]}
    Set Suite Variable  ${task_id4}  ${task_id[0]}

    ${resp}=    Change Assignee    ${task_uid4}   ${u_id6}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${note}=    FakerLibrary.sentence 
    
    ${Value}=   Evaluate    random.uniform(0.0,80)
    ${progressValue}=  twodigitfloat  ${Value}
   
    ${resp}=    Add Task Progress For User    ${task_uid4}   ${progressValue}     ${note}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-AddTaskProgressForUser-4

    [Documentation]   create task for one user and assingee to another user same branch and add progress by another user 
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${locId}=  Create Sample Location
    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${locId}  ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}

    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${task_id}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${task_uid5}  ${task_id[1]}
    Set Suite Variable  ${task_id5}  ${task_id[0]}


    ${resp}=    Change Assignee    ${task_uid5}   ${u_id6}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U4}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${note}=    FakerLibrary.sentence 
    ${Value}=   Evaluate    random.uniform(0.0,80)
    ${progressValue}=  twodigitfloat  ${Value}
   
    ${resp}=    Add Task Progress For User    ${task_uid5}   ${progressValue}     ${note}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Task By Id   ${task_uid5}
    Log   ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}                   ${task_id5}
    Should Be Equal As Strings  ${resp.json()['taskUid']}              ${task_uid5} 
    Should Be Equal As Strings  ${resp.json()['title']}                ${title}
    Should Be Equal As Strings  ${resp.json()['description']}          ${desc}
    Should Be Equal As Strings  ${resp.json()['category']['id']}         ${category_id1} 
    Should Be Equal As Strings  ${resp.json()['type']['id']}             ${type_id1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}         ${locId}
    Should Be Equal As Strings  ${resp.json()['progressNotes'][0]['note']}               ${note}
    Should Be Equal As Numbers  ${resp.json()['progressNotes'][0]['progress']}       ${progressValue}

JD-TC-AddTaskProgressForUser-5

    [Documentation]      empty note passing

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U4}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    #   ${locId}=  Create Sample Location
    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${locId}  ${resp.json()[0]['id']}
   
    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${task_id}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${task_uid7}  ${task_id[1]}
    Set Suite Variable  ${task_id7}  ${task_id[0]}

    #${note}=    FakerLibrary.sentence 
    ${Value}=   Evaluate    random.uniform(0.0,80)
    ${progressValue}=  twodigitfloat  ${Value}
   
    ${resp}=    Add Task Progress For User    ${task_uid7}   ${progressValue}   ${empty}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Task By Id   ${task_uid7}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}                   ${task_id7}
    Should Be Equal As Strings  ${resp.json()['taskUid']}              ${task_uid7} 
    Should Be Equal As Strings  ${resp.json()['title']}                ${title}
    Should Be Equal As Strings  ${resp.json()['description']}          ${desc}
    Should Be Equal As Strings  ${resp.json()['category']['id']}         ${category_id1} 
    Should Be Equal As Strings  ${resp.json()['type']['id']}             ${type_id1}
    Should Be Equal As Numbers  ${resp.json()['progress']}       ${progressValue}
    


  

JD-TC-AddTaskProgressForUser-UH6

    [Documentation]     With Consumer login


    ${resp}=   ConsumerLogin  ${CUSERNAME8}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${note}=    FakerLibrary.sentence 
    ${Value}=   Evaluate    random.uniform(0.0,80)
    ${progressValue}=  twodigitfloat  ${Value}
   
    ${resp}=    Add Task Progress For User    ${task_uid4}   ${progressValue}     ${note}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   ${resp.json()}    ${LOGIN_NO_ACCESS_FOR_URL}




JD-TC-AddTaskProgressForUser-UH7

    [Documentation]  Create task for branch and  and assingee to another user add task progress by user

     ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${locId}=  Create Sample Location
    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${locId}  ${resp.json()[0]['id']}
   # Set Suite Variable  ${locId}

    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${task_id}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${task_uid6}  ${task_id[1]}
    Set Suite Variable  ${task_id6}  ${task_id[0]}


    ${resp}=    Change Assignee    ${task_uid6}   ${u_id6}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U4}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${note}=    FakerLibrary.sentence 
    ${Value}=   Evaluate    random.uniform(0.0,80)
    ${progressValue}=  twodigitfloat  ${Value}
   
    ${resp}=    Add Task Progress For User    ${task_uid6}   ${progressValue}     ${note}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=   Get Task By Id   ${task_uid6}
    Log   ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}                   ${task_id6}
    Should Be Equal As Strings  ${resp.json()['taskUid']}              ${task_uid6} 
    Should Be Equal As Strings  ${resp.json()['title']}                ${title}
    Should Be Equal As Strings  ${resp.json()['description']}          ${desc}
    Should Be Equal As Strings  ${resp.json()['category']['id']}         ${category_id1} 
    Should Be Equal As Strings  ${resp.json()['type']['id']}             ${type_id1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}         ${locId}
    Should Be Equal As Strings  ${resp.json()['progressNotes'][0]['note']}               ${note}
    Should Be Equal As Numbers  ${resp.json()['progressNotes'][0]['progress']}       ${progressValue}
  
















   


   

    
