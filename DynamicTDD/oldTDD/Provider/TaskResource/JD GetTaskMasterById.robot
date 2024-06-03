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
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/hl_providers.py


*** Variables ***

@{emptylist} 


*** Test Cases ***

JD-TC-GetTaskMasterByid-1

    [Documentation]  Create a task master for a branch and get by id

    ${resp}=  Encrypted Provider Login  ${PUSERNAME46}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
*** Comments ***
    ${p_id}=  get_acc_id  ${PUSERNAME46}

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
    Set Test Variable  ${id}  ${resp.json()['id']}

    ${resp}=   Get Task Master By Id   ${id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}            ${id}
    Should Be Equal As Strings  ${resp.json()['account']}       ${p_id}
    Should Be Equal As Strings  ${resp.json()['title']}            ${title}
    Should Be Equal As Strings  ${resp.json()['priority']['id']}      ${Priority_id}
    Should Be Equal As Strings  ${resp.json()['category']['id']}          ${category_id1} 
    Should Be Equal As Strings  ${resp.json()['templateName']}        ${templateName}
    
JD-TC-GetTaskMasterByid-2

    [Documentation]  Create a task master for a user and get by id

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}   ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid}=  get_acc_id  ${HLPUSERNAME4} 
    Set Suite variable     ${pid}
    ${accoid}=  get_id  ${HLPUSERNAME4} 
    Set Suite Variable   ${accoid}
  

    ${highest_package}=  get_highest_license_pkg
    Log  ${highest_package}
    Set Suite variable  ${lic2}  ${highest_package[0]}

  
    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_service   ${HLPUSERNAME4} 
    clear_appt_schedule   ${PUSERNAME4}
    
    ${resp2}=   Get Business Profile
    Log  ${resp2.json()}
    Should Be Equal As Strings    ${resp2.status_code}    200
    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    
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

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']}

    ${title4}=  FakerLibrary.user name
   
    ${templateName1}=   FakerLibrary.user name
    ${resp}=   Create Task Master  ${templateName1}    ${title4}     ${category_id1}   ${type_id1}    ${Priority_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${id2}  ${resp.json()['id']}

    ${resp}=   Get Task Master By Id   ${id2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}           200
    Should Be Equal As Strings  ${resp.json()['id']}            ${id2}
    Should Be Equal As Strings  ${resp.json()['account']}       ${p_id}
    Should Be Equal As Strings  ${resp.json()['title']}            ${title4}
    Should Be Equal As Strings  ${resp.json()['priority']['id']}      ${Priority_id}
    Should Be Equal As Strings  ${resp.json()['category']['id']}          ${category_id1} 
    Should Be Equal As Strings  ${resp.json()['templateName']}        ${templateName1}
    
JD-TC-GetTaskMasterByid-3

    [Documentation]  Create another  task master for a user and get by id
   
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${title4}=  FakerLibrary.user name
    ${templateName1}=   FakerLibrary.user name
    ${resp}=   Create Task Master  ${templateName1}    ${title4}     ${category_id1}   ${type_id1}    ${Priority_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${id2}  ${resp.json()['id']}

    ${resp}=   Get Task Master By Id   ${id2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}           200
    Should Be Equal As Strings  ${resp.json()['id']}            ${id2}
    Should Be Equal As Strings  ${resp.json()['account']}       ${p_id}
    Should Be Equal As Strings  ${resp.json()['title']}            ${title4}
    Should Be Equal As Strings  ${resp.json()['priority']['id']}      ${Priority_id}
    Should Be Equal As Strings  ${resp.json()['category']['id']}          ${category_id1} 
    Should Be Equal As Strings  ${resp.json()['templateName']}        ${templateName1}
    
    ${title}=  FakerLibrary.user name
    Set Suite Variable    ${title}
    ${templateName}=   FakerLibrary.user name
    ${resp}=   Create Task Master  ${templateName}    ${title}     ${category_id1}   ${type_id1}    ${Priority_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${id3}  ${resp.json()['id']}

    ${resp}=   Get Task Master By Id   ${id3}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}           200
    Should Be Equal As Strings  ${resp.json()['id']}            ${id3}
    Should Be Equal As Strings  ${resp.json()['title']}            ${title}
    Should Be Equal As Strings  ${resp.json()['priority']['id']}      ${Priority_id}
    Should Be Equal As Strings  ${resp.json()['category']['id']}          ${category_id1} 
    Should Be Equal As Strings  ${resp.json()['templateName']}        ${templateName}
    

JD-TC-GetTaskMasterByid-4

    [Documentation]  Create  task master for a user and  assignee to another user and get by id by another user
   
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}   ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    sleep  2s
    ${dep_name1}=  FakerLibrary.bs
    ${dep_code1}=   Random Int  min=100   max=999
    ${dep_desc1}=   FakerLibrary.word  
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    

    ${u_id1}=  Create Sample User

    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${PUSERNAME_U1}  ${resp.json()['mobileNo']}

    ${resp}=  SendProviderResetMail   ${PUSERNAME_U1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${PUSERNAME_U1}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${title4}=  FakerLibrary.user name
    ${templateName1}=   FakerLibrary.user name
   

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Create Task Master  ${templateName1}    ${title4}     ${category_id1}   ${type_id1}    ${Priority_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${id2}  ${resp.json()['id']}

    ${INVALID_TASK}=   Replace String  ${INVALID_TASK_UID}  {}  activity

     
    ${resp}=    Change Assignee    ${id2}   ${u_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${INVALID_TASK}


   


JD-TC-GetTaskMasterByid-UH1

    [Documentation]  Create a task master without login.
    
    ${resp}=   Get Task Master By Id   ${id2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-CreateTaskMaster-UH2

    [Documentation]  Create a task master by consumer.

    ${resp}=   ConsumerLogin  ${CUSERNAME8}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Task Master By Id   ${id2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   ${resp.json()}    ${LOGIN_NO_ACCESS_FOR_URL}

JD-TC-GetTaskMasterByid-UH3

    [Documentation]  Create  task master for a user and get by id by another branch user
    
     
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${title4}=  FakerLibrary.user name
    ${templateName1}=   FakerLibrary.user name
   

    ${resp}=   Create Task Master  ${templateName1}    ${title4}     ${category_id1}   ${type_id1}    ${Priority_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${id4}  ${resp.json()['id']}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

     ${resp}=  Encrypted Provider Login   ${HLPUSERNAME5}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    sleep  2s
    ${dep_name1}=  FakerLibrary.bs
    ${dep_code1}=   Random Int  min=100   max=999
    ${dep_desc1}=   FakerLibrary.word  
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    

    ${u_id4}=  Create Sample User

    ${resp}=  Get User By Id  ${u_id4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${PUSERNAME_U4}  ${resp.json()['mobileNo']}

    ${resp}=  SendProviderResetMail   ${PUSERNAME_U4}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${PUSERNAME_U4}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${title4}=  FakerLibrary.user name
    ${templateName1}=   FakerLibrary.user name
   

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U4}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=   Get Task Master By Id   ${id4}
    Log   ${resp.content}
    
JD-TC-GetTaskMasterByid-5(UH)

    [Documentation]  Create  task master for a user and get by id by another branch
    
     

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${title4}=  FakerLibrary.user name
    ${templateName1}=   FakerLibrary.user name
   

    ${resp}=   Create Task Master  ${templateName1}    ${title4}     ${category_id1}   ${type_id1}    ${Priority_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${id4}  ${resp.json()['id']}
    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    

    ${resp}=  Encrypted Provider Login   ${HLPUSERNAME5}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=   Get Task Master By Id   ${id4}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}           200
  