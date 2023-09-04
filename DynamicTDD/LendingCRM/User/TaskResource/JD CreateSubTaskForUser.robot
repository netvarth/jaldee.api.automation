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
${count}       ${5}


*** Test Cases ***

JD-TC-CreatesubTaskForUser-1

    [Documentation]  Create subTask for branch

 
    ${resp}=   Encrypted Provider Login  ${MUSERNAME58}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${p_id}=  get_acc_id  ${MUSERNAME58}
    Set Suite Variable   ${p_id}

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
    Set Test Variable  ${task_id1}  ${task_id[0]}
    Set Suite Variable  ${task_uid1}  ${task_id[1]}

    ${resp}=   Get Task By Id   ${task_uid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${p_id}       ${resp.json()}[accountId]
    Should Be Equal As Strings    []       ${resp.json()}[notes]
    
    ${resp}=    Create SubTask   ${task_uid1}  ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${task_id}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${task_id2}  ${task_id[0]}
    Set Test Variable  ${task_uid2}  ${task_id[1]}
    ${resp}=   Get Task By Id   ${task_uid2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${p_id}       ${resp.json()}[accountId]
    Should Be Equal As Strings    []       ${resp.json()}[notes]
    Should Be Equal As Strings  ${resp.json()['title']}               ${title}
    Should Be Equal As Strings  ${resp.json()['description']}         ${desc}
    Should Be Equal As Strings  ${resp.json()['category']['id']}      ${category_id1}
    Should Be Equal As Strings  ${resp.json()['originUid']}      ${task_uid1}
    Should Be Equal As Strings  ${resp.json()['id']}                  ${task_id2}
    Should Be Equal As Strings  ${resp.json()['taskUid']}             ${task_uid2}
 

JD-TC-CreatesubTaskForUser-2

    [Documentation]  Create multiple  subTask for branch same details

     ${resp}=   Encrypted Provider Login  ${MUSERNAME59}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${p_id1}=  get_acc_id  ${MUSERNAME59}
    Set Suite Variable   ${p_id1}

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
    Set Suite Variable  ${category_id1}    ${resp.json()[0]['id']}
    Set Test Variable  ${category_name1}  ${resp.json()[0]['name']}

    ${resp}=    Get Task Type
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${type_id1}    ${resp.json()[0]['id']}
    Set Test Variable  ${type_name1}  ${resp.json()[0]['name']}

    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 

    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${task_id}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${task_id2}  ${task_id[0]}
    Set Suite Variable  ${task_uid2}  ${task_id[1]}

    ${resp}=   Get Task By Id   ${task_uid2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${p_id1}       ${resp.json()}[accountId]
    Should Be Equal As Strings    []       ${resp.json()}[notes]
    Should Be Equal As Strings  ${resp.json()['title']}               ${title}
    Should Be Equal As Strings  ${resp.json()['description']}         ${desc}
    Should Be Equal As Strings  ${resp.json()['category']['id']}      ${category_id1}

    
    ${resp}=    Create SubTask   ${task_uid2}  ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${task_id}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${task_id3}  ${task_id[0]}
    Set Test Variable  ${task_uid3}  ${task_id[1]}

    ${resp}=   Get Task By Id   ${task_uid3}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${p_id1}       ${resp.json()}[accountId]
    Should Be Equal As Strings    []       ${resp.json()}[notes]
    Should Be Equal As Strings  ${resp.json()['title']}               ${title}
    Should Be Equal As Strings  ${resp.json()['description']}         ${desc}
    Should Be Equal As Strings  ${resp.json()['category']['id']}      ${category_id1}
    Should Be Equal As Strings  ${resp.json()['id']}                  ${task_id3}
    Should Be Equal As Strings  ${resp.json()['taskUid']}             ${task_uid3}
 


    ${resp}=    Create SubTask   ${task_uid2}  ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${task_id}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${task_id4}  ${task_id[0]}
    Set Test Variable  ${task_uid4}  ${task_id[1]}
    
    ${resp}=   Get Task By Id   ${task_uid4}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${p_id1}       ${resp.json()}[accountId]
    Should Be Equal As Strings    []       ${resp.json()}[notes]
    Should Be Equal As Strings  ${resp.json()['title']}               ${title}
    Should Be Equal As Strings  ${resp.json()['description']}         ${desc}
    Should Be Equal As Strings  ${resp.json()['category']['id']}      ${category_id1}
    Should Be Equal As Strings  ${resp.json()['id']}                  ${task_id4}
    Should Be Equal As Strings  ${resp.json()['taskUid']}             ${task_uid4}
    Should Be Equal As Strings  ${resp.json()['originUid']}      ${task_uid2}
   
 
   



JD-TC-CreatesubTaskForUser-3

    [Documentation]  Create multiple  subTask for branch different details

     ${resp}=   Encrypted Provider Login  ${MUSERNAME60}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${p_id3}=  get_acc_id  ${MUSERNAME60}
    Set Suite Variable   ${p_id3}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
    ELSE
        Set Suite Variable  ${locId3}  ${resp.json()[0]['id']}
    END
    
    ${resp}=  categorytype  ${p_id3}
    ${resp}=  tasktype      ${p_id3}
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

    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${task_id}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${task_id3}  ${task_id[0]}
    Set Suite Variable  ${task_uid3}  ${task_id[1]}

    ${resp}=   Get Task By Id   ${task_uid3}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}                  ${task_id3}
    Should Be Equal As Strings  ${resp.json()['taskUid']}             ${task_uid3}
    Should Be Equal As Strings    ${p_id3}       ${resp.json()}[accountId]
    Should Be Equal As Strings    []       ${resp.json()}[notes]
    Should Be Equal As Strings  ${resp.json()['title']}               ${title}
    Should Be Equal As Strings  ${resp.json()['description']}         ${desc}
    Should Be Equal As Strings  ${resp.json()['category']['id']}      ${category_id1}

    ${title1}=  FakerLibrary.user name
    ${desc1}=   FakerLibrary.word 

    ${resp}=    Create SubTask   ${task_uid3}  ${title1}  ${desc1}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${task_id}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${task_id11}  ${task_id[0]}
    Set Suite Variable  ${task_uid11}  ${task_id[1]}

    ${resp}=   Get Task By Id   ${task_uid11}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}                  ${task_id11}
    Should Be Equal As Strings  ${resp.json()['taskUid']}             ${task_uid11}
    Should Be Equal As Strings    ${p_id3}       ${resp.json()}[accountId]
    Should Be Equal As Strings    []       ${resp.json()}[notes]
    Should Be Equal As Strings  ${resp.json()['title']}               ${title1}
    Should Be Equal As Strings  ${resp.json()['description']}         ${desc1}
    Should Be Equal As Strings  ${resp.json()['category']['id']}      ${category_id1}
    Should Be Equal As Strings  ${resp.json()['originUid']}      ${task_uid3}
   

    ${title3}=  FakerLibrary.user name
    ${desc3}=   FakerLibrary.word 

    ${resp}=    Create SubTask   ${task_uid3}  ${title3}  ${desc3}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${task_id}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${task_id6}  ${task_id[0]}
    Set Suite Variable  ${task_uid6}  ${task_id[1]}

    ${resp}=   Get Task By Id   ${task_uid6}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}                  ${task_id6}
    Should Be Equal As Strings  ${resp.json()['taskUid']}             ${task_uid6}
    Should Be Equal As Strings    ${p_id3}       ${resp.json()}[accountId]
    Should Be Equal As Strings    []       ${resp.json()}[notes]
    Should Be Equal As Strings  ${resp.json()['title']}               ${title3}
    Should Be Equal As Strings  ${resp.json()['description']}         ${desc3}
    Should Be Equal As Strings  ${resp.json()['category']['id']}      ${category_id1}
    Should Be Equal As Strings  ${resp.json()['originUid']}      ${task_uid3}
   

    
    ${title4}=  FakerLibrary.user name
    ${desc4}=   FakerLibrary.word 

    ${resp}=    Create SubTask   ${task_uid3}  ${title4}  ${desc4}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId3}
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
    Should Be Equal As Strings    ${p_id3}       ${resp.json()}[accountId]
    Should Be Equal As Strings    []       ${resp.json()}[notes]
    Should Be Equal As Strings  ${resp.json()['title']}               ${title4}
    Should Be Equal As Strings  ${resp.json()['description']}         ${desc4}
    Should Be Equal As Strings  ${resp.json()['category']['id']}      ${category_id1}
    Should Be Equal As Strings  ${resp.json()['originUid']}      ${task_uid3}

JD-TC-CreatesubTaskForUser-4

    [Documentation]   Create  subTask for  user



    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME4}   ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid}=  get_acc_id  ${HLMUSERNAME4} 
    Set Suite variable     ${pid}

    ${highest_package}=  get_highest_license_pkg
    Log  ${highest_package}
    Set Suite variable  ${lic2}  ${highest_package[0]}

  
    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_service   ${HLMUSERNAME4} 
    clear_appt_schedule   ${MUSERNAME4}
    reset_user_metric  ${pid}
    
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
    Verify Response  ${resp}  id=${u_id}  firstName=${firstname}  lastName=${lastname}   mobileNo=${PUSERPH0}  dob=${dob}  gender=${Genderlist[0]}  userType=${userType[0]}  status=ACTIVE  email=${P_Email}${PUSERPH0}.${test_mail}   deptId=${dep_id} 

   
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
    Should Be Equal As Strings  ${resp.json()['originUid']}      ${task_uid2}
   
JD-TC-CreatesubTaskForUser-5

    [Documentation]  Create    multiple subTask for  user

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']}

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
    Should Be Equal As Strings  ${resp.json()['originUid']}      ${task_uid2}
    Should Be Equal As Strings    ${p_id}       ${resp.json()}[accountId]
    Should Be Equal As Strings    []       ${resp.json()}[notes]
    Should Be Equal As Strings  ${resp.json()['title']}               ${title4}
    Should Be Equal As Strings  ${resp.json()['description']}         ${desc4}
    Should Be Equal As Strings  ${resp.json()['category']['id']}      ${category_id1}
    
    ${title5}=  FakerLibrary.user name
    ${desc5}=   FakerLibrary.word 

    ${resp}=    Create SubTask   ${task_uid2}  ${title5}  ${desc5}   ${userType[0]}  ${category_id1}  ${type_id1}   ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${task_id}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${task_id6}  ${task_id[0]}
    Set Suite Variable  ${task_uid6}  ${task_id[1]}

    ${resp}=   Get Task By Id   ${task_uid6}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}                  ${task_id6}
    Should Be Equal As Strings  ${resp.json()['taskUid']}             ${task_uid6}
    Should Be Equal As Strings  ${resp.json()['originUid']}      ${task_uid2}
    Should Be Equal As Strings    ${p_id}       ${resp.json()}[accountId]
    Should Be Equal As Strings    []       ${resp.json()}[notes]
    Should Be Equal As Strings  ${resp.json()['title']}               ${title5}
    Should Be Equal As Strings  ${resp.json()['description']}         ${desc5}
    Should Be Equal As Strings  ${resp.json()['category']['id']}      ${category_id1}

JD-TC-CreatesubTaskForUser-UH6

    [Documentation]  Create  task for branch and create   subTask for  user

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME4}   ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid}=  get_acc_id  ${HLMUSERNAME4} 
    Set Suite variable     ${pid}

    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${task_uid7}   ${resp.json()['uid']}
    Set Test Variable  ${task_id7}  ${resp.json()['id']}

      ${resp}=   Get Task By Id   ${task_uid7}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}                  ${task_id7}
    Should Be Equal As Strings  ${resp.json()['taskUid']}             ${task_uid7}
    Should Be Equal As Strings    ${p_id}       ${resp.json()}[accountId]
    Should Be Equal As Strings    []       ${resp.json()}[notes]
    Should Be Equal As Strings  ${resp.json()['title']}               ${title}
    Should Be Equal As Strings  ${resp.json()['description']}         ${desc}
    Should Be Equal As Strings  ${resp.json()['category']['id']}      ${category_id1}

   

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${NO_PERMISSION_ADD_SUBTASK}=   Replace String  ${NO_PERMISSION_ADD_SUBTASK}  {}  activity

    ${title5}=  FakerLibrary.user name
    ${desc5}=   FakerLibrary.word 

    ${resp}=    Create SubTask   ${task_uid7}  ${title5}  ${desc5}   ${userType[0]}  ${category_id1}  ${type_id1}   ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422  
    Should Be Equal As Strings   ${resp.json()}    ${NO_PERMISSION_ADD_SUBTASK}
  
JD-TC-CreatesubTaskForUser-UH7

    [Documentation]  Create  task for user and create   subTask for  another user
    
    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME4}   ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
   
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
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  get_address

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERPH1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERPH1}  ${dep_id}  ${EMPTY}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
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

    ${resp}=  Encrypted Provider Login  ${PUSERPH1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']}

    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 

    ${resp}=    Create Task         ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    ${task_id}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${task_id12}  ${task_id[0]}
    Set Suite Variable  ${task_uid12}  ${task_id[1]}

    ${resp}=    ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200
    
     ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${NO_PERMISSION_ADD_SUBTASK}=   Replace String  ${NO_PERMISSION_ADD_SUBTASK}  {}  activity

    ${title5}=  FakerLibrary.user name
    ${desc5}=   FakerLibrary.word 

    ${resp}=    Create SubTask   ${task_uid12}  ${title5}  ${desc5}   ${userType[0]}  ${category_id1}  ${type_id1}   ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422  
    Should Be Equal As Strings   ${resp.json()}    ${NO_PERMISSION_ADD_SUBTASK}
  
JD-TC-CreatesubTaskForUser-9

    
    [Documentation]  Create  task for user and  assignee to another user create   subTask for  another user
    
    ${resp}=  Encrypted Provider Login  ${PUSERPH1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']}
 
    ${resp}=    Change Assignee    ${task_uid12}    ${u_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${title5}=  FakerLibrary.user name
    ${desc5}=   FakerLibrary.word 

    ${resp}=    Create SubTask   ${task_uid12}  ${title5}  ${desc5}   ${userType[0]}  ${category_id1}  ${type_id1}   ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${task_id}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${task_id14}  ${task_id[0]}
    Set Suite Variable  ${task_uid14}  ${task_id[1]}

    ${resp}=   Get Task By Id   ${task_uid14}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}                  ${task_id14}
    Should Be Equal As Strings  ${resp.json()['taskUid']}             ${task_uid14}
    Should Be Equal As Strings    ${p_id}       ${resp.json()}[accountId]
    Should Be Equal As Strings    []       ${resp.json()}[notes]
    Should Be Equal As Strings  ${resp.json()['title']}               ${title5}
    Should Be Equal As Strings  ${resp.json()['description']}         ${desc5}
    Should Be Equal As Strings  ${resp.json()['category']['id']}      ${category_id1}
    Should Be Equal As Strings  ${resp.json()['originUid']}      ${task_uid12}

JD-TC-CreatesubTaskForUser-UH1

    [Documentation]  create task and clossed task status and create subtask

    ${resp}=  Encrypted Provider Login  ${PUSERPH1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']}

    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 

    ${resp}=    Create Task         ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    ${task_id}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${task_id15}  ${task_id[0]}
    Set Suite Variable  ${task_uid15}  ${task_id[1]}

    ${resp}=    Change User Task Status Closed  ${task_uid15}  
    Log      ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${title5}=  FakerLibrary.user name
    ${desc5}=   FakerLibrary.word 

    ${resp}=    Create SubTask   ${task_uid15}  ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}    ${TASK_ALREADY_COMPLETED}
  
JD-TC-CreatesubTaskForUser-UH2

    [Documentation]  without login

    ${resp}=    Create SubTask   ${task_uid15}  ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${lid}
    Log      ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-CreatesubTaskForUser-UH3

    [Documentation]    By consumer Login
    
    ${resp}=   ConsumerLogin  ${CUSERNAME8}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Create SubTask   ${task_uid15}  ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${lid}
    Log      ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   ${resp.json()}    ${LOGIN_NO_ACCESS_FOR_URL}

JD-TC-CreatesubTaskForUser-UH4
    [Documentation]    create task by usr and subtask create by another branch
     
    ${resp}=  Encrypted Provider Login  ${PUSERPH1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']}

    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 

    ${resp}=    Create Task         ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    ${task_id}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${task_id19}  ${task_id[0]}
    Set Suite Variable  ${task_uid19}  ${task_id[1]}


    ${resp}=   Encrypted Provider Login  ${MUSERNAME58}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid1}   ${resp.json()[0]['id']}

    ${NO_PERMISSION_ADD_SUBTASK}=   Replace String  ${NO_PERMISSION_ADD_SUBTASK}  {}  activity

    ${title1}=  FakerLibrary.user name
    ${desc1}=   FakerLibrary.word 
    ${resp}=    Create SubTask   ${task_uid19}  ${title1}  ${desc1}   ${userType[0]}  ${category_id1}  ${type_id1}   ${lid1}
    Log      ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422  
    Should Be Equal As Strings   ${resp.json()}    ${NO_PERMISSION_ADD_SUBTASK}
   
JD-TC-CreatesubTaskForUser-UH5
    [Documentation]    create task by branch and subtask create by another branch user
   
    
    ${resp}=   Encrypted Provider Login  ${MUSERNAME58}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid1}   ${resp.json()[0]['id']}
    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 

    ${resp}=    Create Task         ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}  ${lid1}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    ${task_id}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${task_id20}  ${task_id[0]}
    Set Suite Variable  ${task_uid20}  ${task_id[1]}

    ${resp}=  Encrypted Provider Login  ${PUSERPH1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']}

   ${NO_PERMISSION_ADD_SUBTASK}=   Replace String  ${NO_PERMISSION_ADD_SUBTASK}  {}  activity
    
    ${title5}=  FakerLibrary.user name
    ${desc5}=   FakerLibrary.word 
    ${resp}=    Create SubTask   ${task_uid20}  ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${lid}
    Log      ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422  
    Should Be Equal As Strings   ${resp.json()}    ${NO_PERMISSION_ADD_SUBTASK}
  
JD-TC-CreatesubTaskForUser-10
   
    [Documentation]  Create  task for user and  assignee to another user create   subTask by first user task created user
    
     ${resp}=  Encrypted Provider Login  ${PUSERPH1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']}
    
    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 

    ${resp}=    Create Task         ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    ${task_id}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${task_id17}  ${task_id[0]}
    Set Suite Variable  ${task_uid17}  ${task_id[1]}
    
    ${resp}=    Change Assignee    ${task_uid17}    ${u_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${title5}=  FakerLibrary.user name
    ${desc5}=   FakerLibrary.word 

    ${resp}=    Create SubTask   ${task_uid17}  ${title5}  ${desc5}   ${userType[0]}  ${category_id1}  ${type_id1}   ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${task_id}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${task_id18}  ${task_id[0]}
    Set Suite Variable  ${task_uid18}  ${task_id[1]}

    ${resp}=   Get Task By Id   ${task_uid18}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}                  ${task_id18}
    Should Be Equal As Strings  ${resp.json()['taskUid']}             ${task_uid18}
    Should Be Equal As Strings    ${p_id}       ${resp.json()}[accountId]
    Should Be Equal As Strings    []       ${resp.json()}[notes]
    Should Be Equal As Strings  ${resp.json()['title']}               ${title5}
    Should Be Equal As Strings  ${resp.json()['description']}         ${desc5}
    Should Be Equal As Strings  ${resp.json()['category']['id']}      ${category_id1}
    Should Be Equal As Strings  ${resp.json()['originUid']}      ${task_uid17}
