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

JD-TC-CreateTaskWithMultipleAssignee-1

    [Documentation]  Create a task with one assignee for a branch then verify it.

    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Suite Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Suite Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
    ${firstname_A}=  FakerLibrary.first_name
    Set Suite Variable  ${firstname_A}
    ${lastname_A}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname_A}
    ${PUSERNAME_E}=  Evaluate  ${PUSERNAME}+551747
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${PUSERNAME_E}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    202
    ${resp}=  Account Activation  ${PUSERNAME_E}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_E}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${PUSERNAME_E}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_E}${\n}
    Append To File  ${EXECDIR}/data/TDD_Logs/providernumbers.txt  ${SUITE NAME} - ${TEST NAME} - ${PUSERNAME_E}${\n}
    Set Suite Variable  ${PUSERNAME_E}
    ${id}=  get_id  ${PUSERNAME_E}
     Set Suite Variable  ${id}
    ${p_id}=  get_acc_id  ${PUSERNAME_E}

    Set Suite Variable  ${p_id}
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
    ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+3366460
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
    

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Suite Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END
    ${whpnum}=  Evaluate  ${PUSERNAME}+346245
    ${tlgnum}=  Evaluate  ${PUSERNAME}+346345

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[2]}  ${pin}  ${countryCodes[1]}  ${PUSERNAME_U1}  ${dep_id}  ${EMPTY}  ${bool[0]}  ${countryCodes[1]}  ${whpnum}  ${countryCodes[1]}  ${tlgnum}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id}  ${resp.json()}

    ${resp}=  Get User By Id  ${u_id}
    Log   ${resp.json()}
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
   
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=  Get User By Id  ${u_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${PUSERNAME_U3}=  Evaluate  ${PUSERNAME}+3366461
    clear_users  ${PUSERNAME_U3}
    Set Suite Variable  ${PUSERNAME_U3}
   

    ${whpnum}=  Evaluate  ${PUSERNAME}+346973
    ${tlgnum}=  Evaluate  ${PUSERNAME}+346913

  

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U3}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERNAME_U3}  ${dep_id}  ${EMPTY}  ${bool[0]}  ${countryCodes[1]}  ${whpnum}  ${countryCodes[1]}  ${tlgnum}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id3}  ${resp.json()}


    ${resp}=  Get User By Id  ${u_id3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=    Reset LoginId  ${u_id3}  ${PUSERNAME_U3}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Forgot Password   loginId=${PUSERNAME_U3}  password=${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${PUSERNAME_U3}  ${OtpPurpose['ProviderResetPassword']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key} =   db.Verify Accnt   ${PUSERNAME_U3}    ${OtpPurpose['ProviderResetPassword']}
    Set Suite Variable   ${key}

    ${resp}=    Forgot Password     otp=${key}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    #... linking user to the provider 1 and get linked lists

    ${resp}=    Connect with other login  ${PUSERNAME_U3}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${PUSERNAME_U2}=  Evaluate  ${PUSERNAME}+3366461
    clear_users  ${PUSERNAME_U2}
    Set Suite Variable  ${PUSERNAME_U3}
   

    ${whpnum}=  Evaluate  ${PUSERNAME}+346973
    ${tlgnum}=  Evaluate  ${PUSERNAME}+346913

  

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U2}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERNAME_U3}  ${dep_id}  ${EMPTY}  ${bool[0]}  ${countryCodes[1]}  ${whpnum}  ${countryCodes[1]}  ${tlgnum}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id2}  ${resp.json()}


    ${resp}=  Get User By Id  ${u_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=    Reset LoginId  ${u_id2}  ${PUSERNAME_U2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Forgot Password   loginId=${PUSERNAME_U2}  password=${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${PUSERNAME_U2}  ${OtpPurpose['ProviderResetPassword']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key} =   db.Verify Accnt   ${PUSERNAME_U2}    ${OtpPurpose['ProviderResetPassword']}
    Set Suite Variable   ${key}

    ${resp}=    Forgot Password     otp=${key}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    #... linking user to the provider 1 and get linked lists

    ${resp}=    Connect with other login  ${PUSERNAME_U2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # --------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    
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
    Set Suite Variable  ${status_id2}    ${resp.json()[1]['id']}
    Set Test Variable  ${status_name1}  ${resp.json()[0]['name']}

    ${resp}=    Get Task Priority
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${priority_id1}    ${resp.json()[0]['id']}
    Set Test Variable  ${priority_name1}  ${resp.json()[0]['name']}

    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 
    ${status}=  Create Dictionary   id=${status_id1}
    ${priority}=  Create Dictionary   id=${priority_id1}
    ${assignees}=    Create List    ${u_id}
    ${resp}=    Create Task With Multiple Assignee   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId}  status=${status}  priority=${priority}  assignees=${assignees}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${task_id1}  ${resp.json()[0]['id']}
    Set Suite Variable  ${task_uid1}  ${resp.json()[0]['uid']}
    ${resp}=   Get Task By Id   ${task_uid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}                   ${task_id1}
    Should Be Equal As Strings  ${resp.json()['taskUid']}              ${task_uid1} 
    Should Be Equal As Strings  ${resp.json()['assignee']['id']}     ${u_id}

JD-TC-CreateTaskWithMultipleAssignee-2

    [Documentation]  Create a task by user with mutiple assignee then verify it.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${lid}=    Create Sample Location 
    Set Suite Variable  ${lid}
    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 
    ${status}=  Create Dictionary   id=${status_id2}
    ${priority}=  Create Dictionary   id=${priority_id1}
    ${assignees}=    Create List    ${u_id}    ${u_id2}

    ${resp}=    Create Task With Multiple Assignee   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${lid}  status=${status}  priority=${priority}   assignees=${assignees}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${task_id2}  ${resp.json()[0]['id']}
    Set Suite Variable  ${task_uid2}  ${resp.json()[0]['uid']}

    Set Suite Variable  ${task_id3}  ${resp.json()[1]['id']}
    Set Suite Variable  ${task_uid3}  ${resp.json()[1]['uid']}

    ${resp}=   Get Task By Id   ${task_uid2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}                   ${task_id2}
    Should Be Equal As Strings  ${resp.json()['taskUid']}              ${task_uid2} 
    Should Be Equal As Strings  ${resp.json()['assignee']['id']}              ${u_id}       

    ${resp}=   Get Task By Id   ${task_uid3}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}                   ${task_id3}
    Should Be Equal As Strings  ${resp.json()['taskUid']}              ${task_uid3} 
    Should Be Equal As Strings  ${resp.json()['assignee']['id']}              ${u_id2}       


JD-TC-CreateTaskWithMultipleAssignee-3

    [Documentation]  Create a task with assignees containing another branch's user id.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME82}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Toggle Department Enable
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${u_id5}=    Create Sample User    

    ${resp}=    Provider Logout
    Log  ${resp.content}  
    Should Be Equal As Strings    ${resp.status_code}    200   

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U3}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 
    ${status}=  Create Dictionary   id=${status_id2}
    ${priority}=  Create Dictionary   id=${priority_id1}
    ${assignees}=    Create List    ${u_id}        ${u_id2}     ${u_id5}

    ${resp}=    Create Task With Multiple Assignee   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${lid}  status=${status}  priority=${priority}   assignees=${assignees}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${task_id5}  ${resp.json()[0]['id']}
    Set Suite Variable  ${task_uid5}  ${resp.json()[0]['uid']}

    Set Suite Variable  ${task_id6}  ${resp.json()[1]['id']}
    Set Suite Variable  ${task_uid6}  ${resp.json()[1]['uid']}

    Set Suite Variable  ${task_id7}  ${resp.json()[2]['id']}
    Set Suite Variable  ${task_uid7}  ${resp.json()[2]['message']}

    ${resp}=   Get Task By Id   ${task_uid5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}                   ${task_id5}
    Should Be Equal As Strings  ${resp.json()['taskUid']}              ${task_uid5} 
    Should Be Equal As Strings  ${resp.json()['assignee']['id']}              ${u_id} 

    ${resp}=   Get Task By Id   ${task_uid6}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}                   ${task_id6}
    Should Be Equal As Strings  ${resp.json()['taskUid']}              ${task_uid6} 
    Should Be Equal As Strings  ${resp.json()['assignee']['id']}              ${u_id2} 

    ${INVALID_TASK}=   Replace String  ${INVALID_TASK_UID}  {}  activity

    ${resp}=   Get Task By Id   ${task_id7}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}      ${INVALID_TASK}

JD-TC-CreateTaskWithMultipleAssignee-4

    [Documentation]  Create a task with assignees in which one assigenee is already assinged as a manager.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${lid1}=    Create Sample Location 
    Set Suite Variable  ${lid1}
    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 
    ${status}=  Create Dictionary   id=${status_id1}
    ${priority}=  Create Dictionary   id=${priority_id1}
    ${manager}=   Create Dictionary    id=${u_id2}
    ${assignees}=    Create List    ${u_id2}    ${u_id}

    ${resp}=    Create Task With Multiple Assignee   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${lid1}  status=${status}  priority=${priority}    manager=${manager}   assignees=${assignees}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${task_id}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${task_id8}  ${resp.json()[0]['id']}
    Set Suite Variable  ${task_uid8}  ${resp.json()[0]['uid']}

    Set Suite Variable  ${task_id9}  ${resp.json()[1]['id']}
    Set Suite Variable  ${task_uid9}  ${resp.json()[1]['uid']}

    ${resp}=   Get Task By Id   ${task_uid8}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}                   ${task_id8}
    Should Be Equal As Strings  ${resp.json()['taskUid']}              ${task_uid8} 
    Should Be Equal As Strings  ${resp.json()['manager']['id']}              ${u_id2}
    Should Be Equal As Strings  ${resp.json()['assignee']['id']}     ${u_id2}    

    ${resp}=   Get Task By Id   ${task_uid9}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}                   ${task_id9}
    Should Be Equal As Strings  ${resp.json()['taskUid']}              ${task_uid9} 
    Should Be Equal As Strings  ${resp.json()['manager']['id']}              ${u_id2}
    Should Be Equal As Strings  ${resp.json()['assignee']['id']}     ${u_id} 

JD-TC-CreateTaskWithMultipleAssignee-5

    [Documentation]  Create a task with multiple assignees then remove one assignee and verify.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 
    ${status}=  Create Dictionary   id=${status_id1}
    ${priority}=  Create Dictionary   id=${priority_id1}
    ${assignees}=    Create List    ${u_id}    ${u_id2}

    ${resp}=    Create Task With Multiple Assignee   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${lid1}  status=${status}  priority=${priority}       assignees=${assignees}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${task_id}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${task_id12}  ${resp.json()[0]['id']}
    Set Suite Variable  ${task_uid12}  ${resp.json()[0]['uid']}

    Set Suite Variable  ${task_id13}  ${resp.json()[1]['id']}
    Set Suite Variable  ${task_uid13}  ${resp.json()[1]['uid']}

    ${resp}=   Get Task By Id   ${task_uid12}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['assignee']['id']}      ${u_id}


    ${resp}=   Get Task By Id   ${task_uid13}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['assignee']['id']}      ${u_id2}
    Should Be Equal As Strings  ${resp.json()['id']}                   ${task_id13}
    Should Be Equal As Strings  ${resp.json()['taskUid']}              ${task_uid13} 
    Should Be Equal As Strings  ${resp.json()['title']}              ${title}

    ${resp}=    Remove Task Assignee     ${task_uid13}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Task By Id   ${task_uid13}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}                   ${task_id13}
    Should Be Equal As Strings  ${resp.json()['taskUid']}              ${task_uid13} 
    Should Be Equal As Strings  ${resp.json()['title']}              ${title}

JD-TC-CreateTaskWithMultipleAssignee-6

    [Documentation]  Create a task with empty assignee list.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 
    ${status}=  Create Dictionary   id=${status_id1}
    ${priority}=  Create Dictionary   id=${priority_id1}
    ${assignees}=    Create List    

    ${resp}=    Create Task With Multiple Assignee   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${lid1}  status=${status}  priority=${priority}       assignees=${assignees}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${task_id}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${task_id14}  ${resp.json()[0]['id']}
    Set Suite Variable  ${task_uid14}  ${resp.json()[0]['uid']}

    ${resp}=   Get Task By Id   ${task_uid14}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}                   ${task_id14}
    Should Be Equal As Strings  ${resp.json()['taskUid']}              ${task_uid14}

JD-TC-CreateTaskWithMultipleAssignee-UH1

    [Documentation]  Create a task with multiple assignees , then try to change assignee with the existing one.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 
    ${status}=  Create Dictionary   id=${status_id1}
    ${priority}=  Create Dictionary   id=${priority_id1}
    ${assignees}=    Create List    ${u_id}    ${u_id2}

    ${resp}=    Create Task With Multiple Assignee   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${lid1}  status=${status}  priority=${priority}       assignees=${assignees}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${task_id}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${task_id10}  ${resp.json()[0]['id']}
    Set Suite Variable  ${task_uid10}  ${resp.json()[0]['uid']}
    Set Suite Variable  ${task_id11}  ${resp.json()[1]['id']}
    Set Suite Variable  ${task_uid11}  ${resp.json()[1]['uid']}

    ${resp}=   Get Task By Id   ${task_uid10}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['assignee']['id']}      ${u_id}


    ${resp}=   Get Task By Id   ${task_uid11}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['assignee']['id']}      ${u_id2}

    ${resp}=    Change Assignee    ${task_uid10}    ${u_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}    ${ALREADY_UPDATED}


JD-TC-CreateTaskWithMultipleAssignee-UH2

    [Documentation]  Create a task with consumer login.

    ${resp}=   Consumer Login  ${CUSERNAME4}  ${PASSWORD} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 
    ${status}=  Create Dictionary   id=${status_id1}
    ${priority}=  Create Dictionary   id=${priority_id1}
    ${assignees}=    Create List    ${u_id}    ${u_id3}

    ${resp}=    Create Task With Multiple Assignee   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${lid1}  status=${status}  priority=${priority}       assignees=${assignees}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   ${resp.json()}    ${LOGIN_NO_ACCESS_FOR_URL}
    

JD-TC-CreateTaskWithMultipleAssignee-UH3

    [Documentation]  Create a task without login.

    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 
    ${status}=  Create Dictionary   id=${status_id1}
    ${priority}=  Create Dictionary   id=${priority_id1}
    ${assignees}=    Create List    ${u_id}    ${u_id3}

    ${resp}=    Create Task With Multiple Assignee   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${lid1}  status=${status}  priority=${priority}       assignees=${assignees}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.json()}   ${SESSION_EXPIRED}
    



