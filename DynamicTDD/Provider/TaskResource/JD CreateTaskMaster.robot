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


*** Test Cases ***

JD-TC-CreateTaskMaster-1

    [Documentation]  Create a task master for a branch.

    ${resp}=  Provider Login  ${MUSERNAME36}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
*** comment ***
    ${p_id}=  get_acc_id  ${MUSERNAME36}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId10}=  Create Sample Location
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

    ${resp}=   Get Task Priority
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${Priority_id}    ${resp.json()[0]['id']}
    Set Test Variable  ${Priority_name1}  ${resp.json()[0]['name']}


    ${title}=  FakerLibrary.user name
    ${templateName} =   FakerLibrary.user name

    ${resp}=   Create Task Master  ${templateName}   ${title}     ${category_id1}   ${type_id1}    ${Priority_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${id1}  ${resp.json()}

    

   

JD-TC-CreateTaskMaster-2

    [Documentation]  Create a task master and a task, sub task for a branch.

    ${resp}=  Provider Login  ${MUSERNAME36}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${p_id}=  get_acc_id  ${MUSERNAME36}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId10}=  Create Sample Location
    ELSE
        Set Suite Variable  ${locId}  ${resp.json()[0]['id']}
    END

    ${resp}=  categorytype  ${p_id}
    ${resp}=  tasktype      ${p_id}
  
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

    ${resp}=   Get Task Priority
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${Priority_id2}    ${resp.json()[0]['id']}
    Set Test Variable  ${Priority_name2}  ${resp.json()[0]['name']}


    ${title1}=  FakerLibrary.user name
    ${templateName1} =   FakerLibrary.user name

    ${resp}=   Create Task Master  ${templateName1}   ${title1}     ${category_id2}   ${type_id2}    ${Priority_id2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${id2}  ${resp.json()}

    ${title}=  FakerLibrary.user name
    ${desc2}=   FakerLibrary.word 
    ${resp}=    Create Task   ${title}  ${desc2}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${task_id}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${task_id2}  ${task_id[0]}
    Set Suite Variable  ${task_uid2}  ${task_id[1]}


    ${resp}=    Create SubTask   ${task_uid2}  ${title}  ${desc2}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${task_id}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${task_id3}  ${task_id[0]}
    Set Suite Variable  ${task_uid3}  ${task_id[1]}

    

    

JD-TC-CreateTaskMaster-3

    [Documentation]  Create a task master and task with same details for a branch.

    ${resp}=  Provider Login  ${MUSERNAME36}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${p_id}=  get_acc_id  ${MUSERNAME36}

    ${title1}=  FakerLibrary.user name
    ${templateName1} =   FakerLibrary.user name

    ${resp}=   Create Task Master  ${templateName1}   ${title1}     ${category_id2}   ${type_id2}    ${Priority_id2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${id2}  ${resp.json()}
    
    ${desc2}=   FakerLibrary.word 
    ${resp}=    Create Task   ${title1}  ${desc2}   ${userType[0]}  ${category_id2}  ${type_id2}   ${locId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${task_id}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable   ${task_id2}  ${task_id[0]}
    Set Suite Variable  ${task_uid2}  ${task_id[1]}



JD-TC-CreateTaskMaster-4

    [Documentation]  Create a task master and a task, sub task for a user.

    ${resp}=  Provider Login  ${HLMUSERNAME4}   ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid}=  get_acc_id  ${HLMUSERNAME4} 
    Set Suite variable     ${pid}
    ${id}=  get_id  ${HLMUSERNAME4} 
    Set Suite Variable  ${id}
  

    ${highest_package}=  get_highest_license_pkg
    Log  ${highest_package}
    Set Suite variable  ${lic2}  ${highest_package[0]}

  
    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_service   ${HLMUSERNAME4} 
    clear_appt_schedule   ${MUSERNAME4}
    
    ${resp2}=   Get Business Profile
    Log  ${resp2.json()}
    Should Be Equal As Strings    ${resp2.status_code}    200
    
    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Run Keyword If  ${resp.json()['filterByDept']}==${bool[0]}   Toggle Department Enable
    Run Keyword If  '${resp}' != '${None}'   Log   ${resp.json()}
    Run Keyword If  '${resp}' != '${None}'   Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep  2s
    ${dep_name1}=  FakerLibrary.bs
    ${dep_code1}=   Random Int  min=100   max=999
    ${dep_desc1}=   FakerLibrary.word  
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id}  ${resp.json()}

    FOR  ${p}  IN RANGE  5
        ${ran int}=    Generate Random String    length=4    chars=[NUMBERS]
        ${ran int}=    Convert To Integer    ${ran int}
        ${ran int}=    Convert To Integer    ${ran int}
        ${ran int}=    Convert To String  ${ran int}
        ${Status}=   Run Keyword And Return Status   Should Match Regexp	${ran int}	\\d{4}
        Exit For Loop IF  ${Status}  
    END
    ${ran int}=    Convert To Integer    ${ran int}
    ${PUSERPH0}=  Evaluate  ${PUSERNAME}+${ran int}
    clear_users  ${PUSERPH0}
    Set Suite Variable  ${PUSERPH0}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  get_address
    ${dob}=  FakerLibrary.Date
    Set Suite Variable  ${dob}
    ${location}=  FakerLibrary.city
    Set Suite Variable  ${location}
    ${state}=  FakerLibrary.state
    Set Suite Variable   ${state}
    FOR    ${i}    IN RANGE    3
        ${pin}=  get_pincode
        ${kwstatus}  ${resp} =  Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
    END
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${city}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Suite Variable  ${state}  ${resp.json()[0]['PostOffice'][0]['State']}      
    Set Suite Variable  ${pin}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    


    clear_service   ${PUSERPH0}
    clear_appt_schedule   ${PUSERPH0}

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


    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERPH0}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERPH0}  ${dep_id}  ${EMPTY}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id}  ${resp.json()}

    ${resp}=  Get User By Id  ${u_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['subdomain']}
    
   
    ${resp}=  SendProviderResetMail   ${PUSERPH0}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${PUSERPH0}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  ProviderLogin  ${PUSERPH0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']}

    ${title}=  FakerLibrary.user name
    Set Suite Variable    ${title}

    ${desc}=   FakerLibrary.word 
    Set Suite Variable  ${desc}
  

    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${task_uid2}   ${resp.json()['uid']}
    Set Test Variable  ${task_id2}  ${resp.json()['id']}


    ${resp}=    Get Task By Id  ${task_uid2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}                   ${task_id2}
    Should Be Equal As Strings  ${resp.json()['taskUid']}             ${task_uid2}
    Should Be Equal As Strings  ${resp.json()['accountId']}           ${p_id}
    Should Be Equal As Strings  ${resp.json()['title']}               ${title}
    Should Be Equal As Strings  ${resp.json()['description']}         ${desc}
    Should Be Equal As Strings  ${resp.json()['category']['id']}      ${category_id1}
    Should Be Equal As Strings  ${resp.json()['type']['id']}          ${type_id1}

    ${title4}=  FakerLibrary.user name
    ${desc4}=   FakerLibrary.word 

    ${resp}=    Create SubTask   ${task_uid2}  ${title4}  ${desc4}   ${userType[0]}  ${category_id1}  ${type_id1}   ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${task_id}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${task_id5}  ${task_id[0]}
    Set Suite Variable  ${task_uid5}  ${task_id[1]}

    ${resp}=   Get Task By Id   ${task_uid5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}                  ${task_id5}
    Should Be Equal As Strings  ${resp.json()['taskUid']}             ${task_uid5}
    Should Be Equal As Strings    ${p_id}       ${resp.json()}[accountId]
    Should Be Equal As Strings    []       ${resp.json()}[notes]
    Should Be Equal As Strings  ${resp.json()['title']}               ${title4}
    Should Be Equal As Strings  ${resp.json()['description']}         ${desc4}
    Should Be Equal As Strings  ${resp.json()['category']['id']}      ${category_id1}
    Should Be Equal As Strings  ${resp.json()['parentTaskUid']}      ${task_uid2}
    ${templateName1} =   FakerLibrary.user name

    ${resp}=   Create Task Master  ${templateName1}   ${title4}     ${category_id2}   ${type_id1}    ${Priority_id2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${id2}  ${resp.json()}
    
   



JD-TC-CreateTaskMaster-5

    [Documentation]  Create a task master and task with same details for a user.
    
    ${resp}=  ProviderLogin  ${PUSERPH0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']}

    ${title4}=  FakerLibrary.user name
    ${desc4}=   FakerLibrary.word 

    ${resp}=    Create Task   ${title4}  ${desc4}   ${userType[0]}  ${category_id1}  ${type_id1}   ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${task_uid2}   ${resp.json()['uid']}
    Set Test Variable  ${task_id2}  ${resp.json()['id']}
    ${templateName1} =   FakerLibrary.user name

    ${resp}=   Create Task Master  ${templateName1}   ${title4}     ${category_id1}   ${type_id1}    ${Priority_id2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${id2}  ${resp.json()}
    


JD-TC-CreateTaskMaster-6

    [Documentation]  Create a task master  with   description
  

    ${resp}=  ProviderLogin  ${PUSERPH0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${templateName1} =   FakerLibrary.user name

    ${title4}=  FakerLibrary.user name
    ${desc4}=   FakerLibrary.word 
    ${resp}=   Create Task Master  ${templateName1}   ${title4}     ${category_id1}   ${type_id1}    ${Priority_id2}   description=${desc4}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${id2}  ${resp.json()}
    
JD-TC-CreateTaskMaster-7

    [Documentation]  Create a task master  with   all field

    ${resp}=  ProviderLogin  ${PUSERPH0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${templateName1} =   FakerLibrary.user name

    ${title4}=  FakerLibrary.user name
    ${desc4}=   FakerLibrary.word 
    ${targetResult}=     FakerLibrary.user name
    ${targetPotential}=    FakerLibrary.Building Number
 
    ${resp}=   Create Task Master  ${templateName1}   ${title4}     ${category_id1}   ${type_id1}    ${Priority_id2}     description=${desc4}     targetResult=${targetResult}  targetPotential=${targetPotential}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${id2}  ${resp.json()}
    
JD-TC-CreateTaskMaster-8

    [Documentation]  Create  multiple task master  with different details

     ${resp}=  ProviderLogin  ${PUSERPH0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${templateName1} =   FakerLibrary.user name

    ${title4}=  FakerLibrary.user name
    ${desc4}=   FakerLibrary.word 
    ${targetResult}=     FakerLibrary.user name
    ${targetPotential}=    FakerLibrary.Building Number
 
    ${resp}=   Create Task Master  ${templateName1}   ${title4}     ${category_id1}   ${type_id1}    ${Priority_id2}     description=${desc4}     targetResult=${targetResult}  targetPotential=${targetPotential}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${id2}  ${resp.json()}
    ${templateName2} =   FakerLibrary.user name

    
    ${title2}=  FakerLibrary.user name
    ${desc2}=   FakerLibrary.word 
    ${targetResult2}=     FakerLibrary.user name
    ${targetPotential2}=    FakerLibrary.Building Number
 
    ${resp}=   Create Task Master  ${templateName2}   ${title2}     ${category_id1}   ${type_id1}    ${Priority_id2}     description=${desc2}     targetResult=${targetResult2}  targetPotential=${targetPotential2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${id2}  ${resp.json()}
    



  
JD-TC-CreateTaskMaster-UH2

    [Documentation]  Create a task master by consumer.

    ${resp}=   ConsumerLogin  ${CUSERNAME8}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${title4}=  FakerLibrary.user name
    ${templateName1}=   FakerLibrary.user name

    ${resp}=   Create Task Master  ${templateName1}   ${title4}     ${category_id1}   ${type_id1}    ${Priority_id2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   ${resp.json()}    ${LOGIN_NO_ACCESS_FOR_URL}


JD-TC-CreateTaskMaster-UH3

    [Documentation]  Create a task master without login.
    
    ${title4}=  FakerLibrary.user name
    ${templateName1}=   FakerLibrary.user name

    ${resp}=   Create Task Master  ${templateName1}   ${title4}     ${category_id1}   ${type_id1}    ${Priority_id2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-CreateTaskMaster-UH4

    [Documentation]  Create a task master and then change assignee with task master id.

    ${resp}=  ProviderLogin  ${PUSERPH0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']}

    ${title4}=  FakerLibrary.user name
    ${templateName1} =   FakerLibrary.user name

    ${resp}=   Create Task Master  ${templateName1}   ${title4}     ${category_id1}   ${type_id1}    ${Priority_id2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${id3}  ${resp.json()}

    ${INVALID_TASK}=   Replace String  ${INVALID_TASK_UID}  {}  activity

    ${resp}=    Change Assignee    ${id3}     ${id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${INVALID_TASK}

JD-TC-CreateTaskMaster-UH5

    [Documentation]   Create a task master without templateName1

    ${resp}=  ProviderLogin  ${PUSERPH0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${title4}=  FakerLibrary.user name
    
    ${resp}=   Create Task Master  ${empty}   ${title4}     ${category_id1}   ${type_id1}    ${Priority_id2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${TEMPLATE_NAME_REQUIRED}

JD-TC-CreateTaskMaster-UH6

    [Documentation]   Create a task master without tittle
    ${resp}=  ProviderLogin  ${PUSERPH0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${title4}=  FakerLibrary.user name
    
   
    ${title4}=  FakerLibrary.user name
    ${templateName1} =   FakerLibrary.user name

    ${resp}=   Create Task Master  ${templateName1}  ${empty}    ${category_id1}   ${type_id1}    ${Priority_id2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${TITLE_REQUIRED}

  
JD-TC-CreateTaskMaster-UH7

    [Documentation]   Create a task master without categoryID
    ${resp}=  ProviderLogin  ${PUSERPH0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
   
    ${title4}=  FakerLibrary.user name
    ${templateName1} =   FakerLibrary.user name

    ${resp}=   Create Task Master  ${templateName1}   ${title4}   ${empty}   ${type_id1}    ${Priority_id2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${CATEGORY_REQUIRED}

  
    

JD-TC-CreateTaskMaster-UH8

    [Documentation]  Create a multiple   task master   with same details

     ${resp}=  ProviderLogin  ${PUSERPH0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${templateName1} =   FakerLibrary.user name

    ${title4}=  FakerLibrary.user name
    ${desc4}=   FakerLibrary.word 
    ${targetResult}=     FakerLibrary.user name
    ${targetPotential}=    FakerLibrary.Building Number
 
    ${resp}=   Create Task Master  ${templateName1}   ${title4}     ${category_id1}   ${type_id1}    ${Priority_id2}     description=${desc4}     targetResult=${targetResult}  targetPotential=${targetPotential}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${id2}  ${resp.json()}
    ${title3}=  FakerLibrary.user name
    ${desc4}=   FakerLibrary.word 
  
    ${resp}=   Create Task Master  ${templateName1}  ${title4}     ${category_id1}   ${type_id1}    ${Priority_id2}     description=${desc4}     targetResult=${targetResult}  targetPotential=${targetPotential}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}     Template name ${templateName1} already exists






