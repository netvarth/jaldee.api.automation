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

JD-TC-RemoveTaskAssignee-1

    [Documentation]  Create a task for a  branch then change assignee and then remove that assignee.

    ${resp}=  Provider Login  ${HLMUSERNAME21}   ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid}=  get_acc_id  ${HLMUSERNAME21} 
    Set Suite variable     ${pid}

    ${highest_package}=  get_highest_license_pkg
    Log  ${highest_package}
    Set Suite variable  ${lic2}  ${highest_package[0]}

  
    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_service   ${HLMUSERNAME21} 
    clear_appt_schedule   ${MUSERNAME21}
    clear_Department    ${MUSERNAME21}

    ${lid}=  Create Sample Location
    Set Suite Variable  ${lid}
   
    
    
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
    ${PUSERPH2}=  Evaluate  ${PUSERNAME}+${ran int}
    clear_users  ${PUSERPH2}
    Set Suite Variable  ${PUSERPH2}
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


    clear_service   ${PUSERPH2}
    clear_appt_schedule   ${PUSERPH2}

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

    ${title}=   FakerLibrary.user name
    Set Suite Variable    ${title}

    ${desc}=    FakerLibrary.word 
    Set Suite Variable  ${desc}
  


    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${task_uid1}   ${resp.json()['uid']}
    Set Test Variable   ${task_id1}  ${resp.json()['id']}


    ${resp}=    Get Task By Id  ${task_uid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}                   ${task_id1}
    Should Be Equal As Strings  ${resp.json()['taskUid']}             ${task_uid1}
    Should Be Equal As Strings  ${resp.json()['accountId']}           ${p_id}
    Should Be Equal As Strings  ${resp.json()['title']}               ${title}
    Should Be Equal As Strings  ${resp.json()['description']}         ${desc}
    Should Be Equal As Strings  ${resp.json()['category']['id']}      ${category_id1}
    Should Be Equal As Strings  ${resp.json()['type']['id']}          ${type_id1}



    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERPH2}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERPH2}  ${dep_id}  ${EMPTY}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id2}  ${resp.json()}

    ${resp}=  Get User By Id  ${u_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['subdomain']}
   
    

    ${resp}=  Provider Login  ${HLMUSERNAME21}   ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
  
    ${resp}=    Change Assignee    ${task_uid1}    ${u_id2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    
    ${resp}=    Remove Task Assignee   ${task_uid1}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    


    



    

JD-TC-RemoveTaskAssignee-3

    [Documentation]  Create a task for a user then change assignee and then remove that assignee.

    ${resp}=  Provider Login  ${HLMUSERNAME4}   ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid}=  get_acc_id  ${HLMUSERNAME4} 
    Set Suite variable     ${pid}
    ${id1}=  get_id  ${HLMUSERNAME4}
    Set Test Variable  ${id1} 
    

    ${highest_package}=  get_highest_license_pkg
    Log  ${highest_package}
    Set Suite variable  ${lic2}  ${highest_package[0]}

  
    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_service   ${HLMUSERNAME4} 
    clear_appt_schedule   ${MUSERNAME4}
    clear_Department    ${MUSERNAME4}
    
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
    clear_Department    ${PUSERPH0}

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
    Set Suite Variable  ${u_id0}  ${resp.json()}

    ${resp}=  Get User By Id  ${u_id0}
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
    Set Suite Variable  ${task_uid3}   ${resp.json()['uid']}
    Set Test Variable  ${task_id3}  ${resp.json()['id']}


    ${resp}=    Get Task By Id  ${task_uid3}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}                   ${task_id3}
    Should Be Equal As Strings  ${resp.json()['taskUid']}             ${task_uid3}
    Should Be Equal As Strings  ${resp.json()['accountId']}           ${p_id}
    Should Be Equal As Strings  ${resp.json()['title']}               ${title}
    Should Be Equal As Strings  ${resp.json()['description']}         ${desc}
    Should Be Equal As Strings  ${resp.json()['category']['id']}      ${category_id1}
    Should Be Equal As Strings  ${resp.json()['type']['id']}          ${type_id1}
    
    ${resp}=    Change Assignee    ${task_uid3}   ${id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Login  ${HLMUSERNAME4}   ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    
    
    ${resp}=    Remove Task Assignee   ${task_uid3}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    


JD-TC-RemoveTaskAssignee-4

    [Documentation]  remove the assignee of another users task of same branch.

    ${resp}=  Provider Login  ${HLMUSERNAME4}   ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid}=  get_acc_id  ${HLMUSERNAME4} 
    Set Suite variable     ${pid}
    ${id}=  get_id  ${HLMUSERNAME4}
    Set Test Variable  ${id} 
    
     FOR  ${p}  IN RANGE  5
        ${ran int}=    Generate Random String    length=4    chars=[NUMBERS]
        ${ran int}=    Convert To Integer    ${ran int}
        ${ran int}=    Convert To Integer    ${ran int}
        ${ran int}=    Convert To String  ${ran int}
        ${Status}=   Run Keyword And Return Status   Should Match Regexp	${ran int}	\\d{4}
        Exit For Loop IF  ${Status}  
    END
    ${ran int}=    Convert To Integer    ${ran int}
    ${PUSERPH1}=  Evaluate  ${PUSERNAME}+${ran int}
    clear_users  ${PUSERPH1}
    Set Suite Variable  ${PUSERPH1}
    ${firstname1}=  FakerLibrary.name
    ${lastname3}=  FakerLibrary.last_name
    ${address}=  get_address


    clear_service   ${PUSERPH1}
    clear_appt_schedule   ${PUSERPH1}

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


    ${resp}=  Create User  ${firstname1}  ${lastname3}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERPH1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERPH1}  ${dep_id}  ${EMPTY}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id1}  ${resp.json()}

    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['subdomain']}
   
   
    ${resp}=  SendProviderResetMail   ${PUSERPH1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${PUSERPH1}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  ProviderLogin  ${PUSERPH1}  ${PASSWORD}
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
    Set Suite Variable  ${task_uid3}   ${resp.json()['uid']}
    Set Test Variable  ${task_id3}  ${resp.json()['id']}
    
     ${resp}=    Change Assignee    ${task_uid3}   ${u_id0}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogin  ${PUSERPH0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=    Remove Task Assignee   ${task_uid3}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
JD-TC-RemoveTaskAssignee-UH1

    [Documentation]  Create a task for a  branch and remove the assignee without assign.

     ${resp}=   Provider Login  ${MUSERNAME58}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${p_id}=  get_acc_id  ${MUSERNAME58}
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
    Set Test Variable  ${task_id2}  ${task_id[0]}
    Set Suite Variable  ${task_uid2}  ${task_id[1]}

    ${resp}=   Get Task By Id   ${task_uid2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${p_id}       ${resp.json()}[accountId]
    Should Be Equal As Strings    []       ${resp.json()}[notes]

    ${resp}=    Remove Task Assignee   ${task_uid2}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}    ${ASSIGNEE_NOT_FOUND}


    
 

JD-TC-RemoveTaskAssignee-UH2

    [Documentation]  remove the assignee without login.

    ${resp}=    Remove Task Assignee   ${task_uid3}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.json()}   ${SESSION_EXPIRED}

    
   
JD-TC-RemoveTaskAssignee-UH3

    [Documentation]  remove the assignee by consumer login.

    ${resp}=   ConsumerLogin  ${CUSERNAME8}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Remove Task Assignee   ${task_uid3}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   ${resp.json()}    ${LOGIN_NO_ACCESS_FOR_URL}



JD-TC-RemoveTaskAssignee-UH4

    [Documentation]  try to remove the assignee which is already removed.

    ${resp}=  ProviderLogin  ${PUSERPH1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${task_uid5}   ${resp.json()['uid']}
    Set Test Variable  ${task_id5}  ${resp.json()['id']}
    
    ${resp}=    Change Assignee    ${task_uid5}   ${u_id0}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    Remove Task Assignee   ${task_uid5}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
      
    ${resp}=    Remove Task Assignee   ${task_uid5}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}    ${ASSIGNEE_NOT_FOUND}


JD-TC-RemoveTaskAssignee-UH5

    [Documentation]  remove the assignee with invalid task id. 

    ${resp}=  ProviderLogin  ${PUSERPH1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${task_uid6}   ${resp.json()['uid']}
    Set Test Variable  ${task_id6}  ${resp.json()['id']}

    ${resp}=    Change Assignee    ${task_uid6}   ${u_id0}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogin  ${PUSERPH0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    
     ${resp}=    Remove Task Assignee   ${task_uid1}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   422
    Should Be Equal As Strings   ${resp.json()}     ${NO_PERMISSION}

  
JD-TC-RemoveTaskAssignee-UH6

    [Documentation]  remove the assignee with another branch task id.

    ${resp}=  ProviderLogin  ${PUSERPH1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${task_uid7}   ${resp.json()['uid']}
    Set Test Variable  ${task_id7}  ${resp.json()['id']}

    ${resp}=    Change Assignee    ${task_uid7}   ${u_id0}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   ProviderLogin  ${MUSERNAME40}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Remove Task Assignee   ${task_uid7}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   422
    Should Be Equal As Strings   ${resp.json()}    ${NO_PERMISSION}


JD-TC-RemoveTaskAssignee-10

    [Documentation]  remove the assignee of a subtask.

    ${resp}=  ProviderLogin  ${PUSERPH1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  

    ${resp}=    Create SubTask   ${task_uid7}  ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${lid}
    Log      ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${task_uid8}   ${resp.json()['uid']}
    Set Test Variable  ${task_id8}  ${resp.json()['id']}

    
    ${resp}=    Change Assignee    ${task_uid8}   ${u_id0}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Remove Task Assignee   ${task_uid8}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    

JD-TC-RemoveTaskAssignee-11

    [Documentation]  remove the assignee after closing the task.

    ${resp}=  ProviderLogin  ${PUSERPH1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${task_uid9}   ${resp.json()['uid']}
    Set Test Variable  ${task_id9}  ${resp.json()['id']}

    ${resp}=    Change User Task Status Closed  ${task_uid9}  
    Log      ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=    Remove Task Assignee   ${task_uid9}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}    ${ASSIGNEE_NOT_FOUND}



  

JD-TC-RemoveTaskAssignee-12

    [Documentation]  remove the assignee after change the status to done.

    ${resp}=  ProviderLogin  ${PUSERPH1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

  

     ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${task_uid10}   ${resp.json()['uid']}
    Set Test Variable  ${task_id10}  ${resp.json()['id']}

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
    

     ${status}=  Create Dictionary   id=${status_id3}
  
    ${resp}=    Change Task Status   ${task_uid10}  ${status_id3}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=    Remove Task Assignee   ${task_uid10}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}    ${ASSIGNEE_NOT_FOUND}





