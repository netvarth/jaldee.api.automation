
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
${count}       ${5}

#${progressValue}  58%



*** Test Cases ***



JD-TC-GetTaskProgress-1

    [Documentation]   add and get  task  progress for a  branch 


    ${resp}=  Encrypted Provider Login  ${PUSERNAME10}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${p_id}=  get_acc_id  ${PUSERNAME10}

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
    ${progressValue}=  roundoff  ${Value}
    ${resp}=    Add Task Progress For User    ${task_uid1}   ${progressValue}     ${note}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  01s
    ${resp}=   Get Task Progress   ${task_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['action']}              EDIT 
    Should Be Equal As Strings  ${resp.json()[0]['category']}           TASK
    Should Be Equal As Strings  ${resp.json()[0]['taskProgress']}       ${progressValue}
    

JD-TC-GetTaskProgress-2

    [Documentation]  add  and get task progress by user
   
    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Suite Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Suite Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    ${firstname_A}=  FakerLibrary.first_name
    Set Suite Variable  ${firstname_A}
    ${lastname_A}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname_A}
    ${PUSERNAME_E}=  Evaluate  ${PUSERNAME}+578599
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${PUSERNAME_E}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_E}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_E}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_E}${\n}
    Append To File  ${EXECDIR}/data/TDD_Logs/providernumbers.txt  ${SUITE NAME} - ${TEST NAME} - ${PUSERNAME_E}${\n}
    Set Suite Variable  ${PUSERNAME_E}
    ${id}=  get_id  ${PUSERNAME_E}
    Set Suite Variable  ${id}

    ${locId}=  Create Sample Location
    Set Suite Variable   ${locId}

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
    ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+33608
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

    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 

    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${task_uid1}   ${resp.json()['uid']} 
    Set Suite Variable  ${task_id1}    ${resp.json()['id']} 
   
    ${note}=    FakerLibrary.sentence 
    
    ${Value}=   Evaluate    random.uniform(0.0,80)
    ${progressValue}=  roundoff  ${Value}
    ${resp}=    Add Task Progress For User    ${task_uid1}   ${progressValue}     ${note}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  01s
    ${resp}=   Get Task Progress   ${task_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['action']}              EDIT 
    Should Be Equal As Strings  ${resp.json()[0]['category']}           TASK
    Should Be Equal As Strings  ${resp.json()[0]['taskProgress']}       ${progressValue}


JD-TC-GetTaskProgress-3

    [Documentation]  Create  same task for  different user and add  same task progress and Get task progress  by users

     ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Location ById   ${locId}
    Log  ${resp.content}

    ${resp}=   Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    

    ${usr_id}=  Create List
    Set Suite Variable   ${usr_id}

    ${PUsrNm}=  Create List 
    Set Suite Variable  ${PUsrNm}

    FOR   ${a}  IN RANGE   ${count}

        ${userid}=  Create Sample User
        Set Test Variable  ${userid${a}}  ${userid}

        ${resp}=  Get User By Id        ${userid${a}}
        Log   ${resp.json()}
        Should Be Equal As Strings      ${resp.status_code}  200
        Set Suite Variable      ${PUSERNAME_${a}}     ${resp.json()['mobileNo']}

        Append To List   ${usr_id}  ${userid${a}}
        Append To List   ${PUsrNm}  ${PUSERNAME_${a}}
    END

    Log  ${PUsrNm}

     
    ${resp}=  SendProviderResetMail   ${PUsrNm[0]}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${PUsrNm[0]}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUsrNm[0]}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 

    ${resp}=    Create Task         ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable  ${task_uid0}   ${resp.json()['uid']} 
    Set Suite Variable  ${task_id0}    ${resp.json()['id']} 

    ${note}=    FakerLibrary.sentence 
    
    ${Value}=   Evaluate    random.uniform(0.0,80)
    ${progressValue}=  roundoff  ${Value}
    ${resp}=    Add Task Progress For User    ${task_uid0}   ${progressValue}     ${note}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  01s
    ${resp}=   Get Task Progress   ${task_id0}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['action']}              EDIT 
    Should Be Equal As Strings  ${resp.json()[0]['category']}           TASK
    Should Be Equal As Strings  ${resp.json()[0]['taskProgress']}       ${progressValue}

    ${resp}=    ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=  SendProviderResetMail   ${PUsrNm[1]}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${PUsrNm[1]}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUsrNm[1]}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

   
    ${resp}=    Create Task         ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable  ${task_uid0}   ${resp.json()['uid']} 
    Set Suite Variable  ${task_id0}    ${resp.json()['id']} 
   

  
    ${resp}=    Add Task Progress For User    ${task_uid0}   ${progressValue}     ${note}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  01s
    ${resp}=   Get Task Progress   ${task_id0}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['action']}              EDIT 
    Should Be Equal As Strings  ${resp.json()[0]['category']}           TASK
    Should Be Equal As Strings  ${resp.json()[0]['taskProgress']}       ${progressValue}
   

JD-TC-GetTaskProgress-4

    [Documentation]  Create  same task for different user and add task progress  and get progress by branch

     ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Get Location ById   ${locId}
    Log  ${resp.content}


    ${PUSERNAME_U2}=  Evaluate  ${PUSERNAME}+33005479
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


    ${resp}=  SendProviderResetMail   ${PUSERNAME_U2}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${PUSERNAME_U2}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200


    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    
   

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


    ${note}=    FakerLibrary.sentence 
    
    ${Value}=   Evaluate    random.uniform(0.0,80)
    ${progressValue}=  roundoff  ${Value}
    ${resp}=    Add Task Progress For User    ${task_uid3}   ${progressValue}     ${note}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=    ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200

     ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Get Location ById   ${locId}
    Log  ${resp.content}

    ${PUSERNAME_U4}=  Evaluate  ${PUSERNAME}+330624
    clear_users  ${PUSERNAME_U4}
    Set Suite Variable  ${PUSERNAME_U4}
    ${firstname2}=  FakerLibrary.name
    Set Suite Variable  ${firstname2}
    ${lastname2}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname2}
    
    ${whpnum}=  Evaluate  ${PUSERNAME}+346086
    ${tlgnum}=  Evaluate  ${PUSERNAME}+346764

    ${resp}=  Create User  ${firstname2}  ${lastname2}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U4}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERNAME_U4}  ${dep_id}  ${EMPTY}  ${bool[0]}  ${countryCodes[1]}  ${whpnum}  ${countryCodes[1]}  ${tlgnum}
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

    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${task_id}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${task_uid3}   ${task_id[1]}
    Set Suite Variable  ${task_id3}   ${task_id[0]}
   

    ${note}=    FakerLibrary.sentence 
    
    ${Value}=   Evaluate    random.uniform(0.0,80)
    ${progressValue}=  roundoff  ${Value}
    ${resp}=    Add Task Progress For User    ${task_uid3}   ${progressValue}     ${note}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=    ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Task Progress   ${task_id3}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['action']}              EDIT 
    Should Be Equal As Strings  ${resp.json()[0]['category']}           TASK
    Should Be Equal As Strings  ${resp.json()[0]['taskProgress']}       ${progressValue}
 

JD-TC-GetTaskProgress-5

    [Documentation]    assingee to another user same branch and add & get  progress by first user(task creating user)


    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

   
    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${task_id}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${task_uid4}  ${task_id[1]}
    Set Suite Variable  ${task_id4}  ${task_id[0]}

    ${resp}=    Change Assignee    ${task_uid4}   ${u_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${note}=    FakerLibrary.sentence 
    
    ${Value}=   Evaluate    random.uniform(0.0,80)
    ${progressValue}=  roundoff  ${Value}
   
    ${resp}=    Add Task Progress For User    ${task_uid4}   ${progressValue}     ${note}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep  01s
    ${resp}=  Get Task Progress  ${task_id4}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['action']}              EDIT 
    Should Be Equal As Strings  ${resp.json()[0]['category']}           TASK
    Should Be Equal As Strings  ${resp.json()[0]['taskProgress']}       ${progressValue}

JD-TC-GetTaskProgress-6

    [Documentation]  Create task for branch and   assingee to another user add  and get task progress by user

     ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Location ById   ${locId}
    Log  ${resp.content}


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
    ${progressValue}=  roundoff  ${Value}
   
    ${resp}=    Add Task Progress For User    ${task_uid6}   ${progressValue}     ${note}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Task Progress  ${task_id6}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['action']}              EDIT 
    Should Be Equal As Strings  ${resp.json()[0]['category']}           TASK
    Should Be Equal As Strings  ${resp.json()[0]['taskProgress']}       ${progressValue}

JD-TC-GetTaskProgress-7

    [Documentation]   add task progress  for branch and  and assingee to another user and get task progress by user

     ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Location ById   ${locId}
    Log  ${resp.content}


    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${task_id}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${task_uid12}  ${task_id[1]}
    Set Suite Variable  ${task_id12}  ${task_id[0]}

    ${note}=    FakerLibrary.sentence 
    ${Value}=   Evaluate    random.uniform(0.0,80)
    ${progressValue}=  roundoff  ${Value}
   
    ${resp}=    Add Task Progress For User    ${task_uid12}   ${progressValue}     ${note}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Change Assignee    ${task_uid12}   ${u_id6}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U4}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Task Progress  ${task_id12}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['action']}              EDIT 
    Should Be Equal As Strings  ${resp.json()[0]['category']}           TASK
    Should Be Equal As Strings  ${resp.json()[0]['taskProgress']}       ${progressValue}

JD-TC-GetTaskProgress-8

    [Documentation]   add  progress for one user and assingee to another user same branch   and get  progress by another user 
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Location ById   ${locId}
    Log  ${resp.content}

    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${task_id}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${task_uid5}  ${task_id[1]}
    Set Suite Variable  ${task_id5}  ${task_id[0]}

      ${note}=    FakerLibrary.sentence 
    ${Value}=   Evaluate    random.uniform(0.0,80)
    ${progressValue}=  roundoff  ${Value}
   
    ${resp}=    Add Task Progress For User    ${task_uid5}   ${progressValue}     ${note}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200



    ${resp}=    Change Assignee    ${task_uid5}   ${u_id6}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U4}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    
    ${resp}=  Get Task Progress  ${task_id5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['action']}              EDIT 
    Should Be Equal As Strings  ${resp.json()[0]['category']}           TASK
    Should Be Equal As Strings  ${resp.json()[0]['taskProgress']}       ${progressValue}

JD-TC-GetTaskProgress-UH1

    [Documentation]  add task progress  and get task progrss by another  branch

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Location ById   ${locId}
    Log  ${resp.content}


    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${task_id}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${task_uid11}  ${task_id[1]}
    Set Test Variable  ${task_id11}  ${task_id[0]}

    ${note}=    FakerLibrary.sentence 
    
    ${Value}=   Evaluate    random.uniform(0.0,80)
    ${progressValue}=  roundoff  ${Value}
    ${resp}=    Add Task Progress For User    ${task_uid11}   ${progressValue}     ${note}
    Log  ${resp.content}
    ${resp}=    ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME10}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${p_id}=  get_acc_id  ${PUSERNAME10}
    ${resp}=   Get Task Progress   ${task_id11}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}    ${NO_PERMISSION}

    
JD-TC-GetTaskProgress-UH2

    [Documentation]     With Consumer login


    ${resp}=   ConsumerLogin  ${CUSERNAME8}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

  
    ${resp}=   Get Task Progress  ${task_id5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   ${resp.json()}    ${LOGIN_NO_ACCESS_FOR_URL}

JD-TC-GetTaskProgress-UH3

    [Documentation]  Without login

    ${resp}=   Get Task Progress   ${task_id5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
  
    Should Be Equal As Strings  ${resp.json()}   ${SESSION_EXPIRED}


  
   
   

















   


   

    
