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

JD-TC-CreateTaskforUser-1

    [Documentation]  Create a task for a branch.

    ${resp}=  Provider Login  ${MUSERNAME10}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${p_id}=  get_acc_id  ${MUSERNAME10}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId10}=  Create Sample Location
    ELSE
        Set Suite Variable  ${locId10}  ${resp.json()[0]['id']}
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

    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId10}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    

JD-TC-CreateTaskforUser-2

    [Documentation]  Create a task for a user.
   
    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Suite Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Suite Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    ${firstname_A}=  FakerLibrary.first_name
    Set Suite Variable  ${firstname_A}
    ${lastname_A}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname_A}
    ${MUSERNAME_E}=  Evaluate  ${MUSERNAME}+55025788
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${MUSERNAME_E}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${MUSERNAME_E}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${MUSERNAME_E}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${MUSERNAME_E}${\n}
    Set Suite Variable  ${MUSERNAME_E}
    ${id}=  get_id  ${MUSERNAME_E}
    ${lid}=  Create Sample Location
    Set Suite Variable  ${lid}
    ${lid1}=  Create Sample Location
    Set Suite Variable  ${lid1}
    ${lid2}=  Create Sample Location
    Set Suite Variable  ${lid2}
    ${lid3}=  Create Sample Location
    Set Suite Variable  ${lid3}
    


    Set Suite Variable  ${id}
    ${bs}=  FakerLibrary.bs
    Set Suite Variable  ${bs}
    ${resp}=  Toggle Department Enable
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
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

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.ynwtest@netvarth.com   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERNAME_U1}  ${dep_id}  ${EMPTY}  ${bool[1]}  ${countryCodes[1]}  ${whpnum}  ${countryCodes[1]}  ${tlgnum}
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

    ${resp}=  ProviderLogin  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${locId}=  Create Sample Location


    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 

    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-CreateTaskforUser-3

    [Documentation]  Create task for multiple users of a branch.

    ${resp}=  Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${PUSERNAME_U2}=  Evaluate  ${PUSERNAME}+3366458
    clear_users  ${PUSERNAME_U2}
    Set Suite Variable  ${PUSERNAME_U2}
    clear_users  ${PUSERNAME_U2}
    Set Suite Variable  ${PUSERNAME_U2}
    ${firstname1}=  FakerLibrary.name
    Set Suite Variable  ${firstname}
    ${lastname1}=  FakerLibrary.last_name
    
  
    
    ${whpnum}=  Evaluate  ${PUSERNAME}+346860
    ${tlgnum}=  Evaluate  ${PUSERNAME}+346387

    ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U2}.ynwtest@netvarth.com   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERNAME_U2}  ${dep_id}  ${EMPTY}  ${bool[1]}  ${countryCodes[1]}  ${whpnum}  ${countryCodes[1]}  ${tlgnum}
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

    ${resp}=  ProviderLogin  ${PUSERNAME_U2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${locId}=  Create Sample Location


    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 

    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200



JD-TC-CreateTaskforUser-4

    [Documentation]  Create same task for multiple users.

    ${resp}=  ProviderLogin  ${PUSERNAME_U2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${locId}=  Create Sample Location


    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 

    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogin  ${PUSERNAME_U2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200





JD-TC-CreateTaskforUser-5

    [Documentation]  Create task for a user with account level location id.

    ${resp}=  ProviderLogin  ${PUSERNAME_U2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${locId}=  Create Sample Location
    Set Suite Variable   ${locId}



    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 

    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200



JD-TC-CreateTaskforUser-6(UH)

    [Documentation]  Create a task for user with another users location.

    ${resp}=  Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${PUSERNAME_U3}=  Evaluate  ${PUSERNAME}+3366498
    clear_users  ${PUSERNAME_U3}
    Set Suite Variable  ${PUSERNAME_U3}
    clear_users  ${PUSERNAME_U3}
    Set Suite Variable  ${PUSERNAME_U3}
    ${firstname2}=  FakerLibrary.name
    Set Suite Variable  ${firstname}
    ${lastname2}=  FakerLibrary.last_name
    
  
    
    ${whpnum}=  Evaluate  ${PUSERNAME}+346884
    ${tlgnum}=  Evaluate  ${PUSERNAME}+346390

    ${resp}=  Create User  ${firstname2}  ${lastname2}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U3}.ynwtest@netvarth.com   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERNAME_U3}  ${dep_id}  ${EMPTY}  ${bool[1]}  ${countryCodes[1]}  ${whpnum}  ${countryCodes[1]}  ${tlgnum}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id1}  ${resp.json()}

    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SendProviderResetMail   ${PUSERNAME_U3}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${PUSERNAME_U3}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  ProviderLogin  ${PUSERNAME_U3}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${locId1}=  Create Sample Location


    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 

    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200





JD-TC-CreateTaskforUser-7

    [Documentation]  Create task for user with another branch location.
    
     ${resp}=  ProviderLogin  ${PUSERNAME_U2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${locId}=  Create Sample Location
    Set Suite Variable   ${locId}



    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 

    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId10}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422



JD-TC-CreateTaskforUser-8

    [Documentation]  Create multiple tasks for same users of a branch with different location.

    ${resp}=  ProviderLogin  ${PUSERNAME_U2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 

    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${lid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    
    ${title1}=  FakerLibrary.user name
    ${desc2}=   FakerLibrary.word 

    ${resp}=    Create Task   ${title1}  ${desc2}   ${userType[0]}  ${category_id1}  ${type_id1}   ${lid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${title3}=  FakerLibrary.user name
    ${desc4}=   FakerLibrary.word 

    ${resp}=    Create Task   ${title3}  ${desc4}   ${userType[0]}  ${category_id1}  ${type_id1}   ${lid3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200




JD-TC-CreateTaskforUser-9

    [Documentation]  Create multiple tasks for a branch with different location.


    ${resp}=  Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 

    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${lid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    
    ${title1}=  FakerLibrary.user name
    ${desc2}=   FakerLibrary.word 

    ${resp}=    Create Task   ${title1}  ${desc2}   ${userType[0]}  ${category_id1}  ${type_id1}   ${lid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${title3}=  FakerLibrary.user name
    ${desc4}=   FakerLibrary.word 

    ${resp}=    Create Task   ${title3}  ${desc4}   ${userType[0]}  ${category_id1}  ${type_id1}   ${lid3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200




JD-TC-CreateTaskforUser-10

    [Documentation]  Create multiple tasks for same users of a branch with same location.

    ${resp}=  ProviderLogin  ${PUSERNAME_U2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 

    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${lid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    
    ${title1}=  FakerLibrary.user name
    ${desc2}=   FakerLibrary.word 

    ${resp}=    Create Task   ${title1}  ${desc2}   ${userType[0]}  ${category_id1}  ${type_id1}   ${lid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${title3}=  FakerLibrary.user name
    ${desc4}=   FakerLibrary.word 

    ${resp}=    Create Task   ${title3}  ${desc4}   ${userType[0]}  ${category_id1}  ${type_id1}   ${lid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200


  


JD-TC-CreateTaskforUser-11

    [Documentation]  Create multiple tasks for a branch with same location.


    ${resp}=  Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
     ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 

    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${lid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    
    ${title1}=  FakerLibrary.user name
    ${desc2}=   FakerLibrary.word 

    ${resp}=    Create Task   ${title1}  ${desc2}   ${userType[0]}  ${category_id1}  ${type_id1}   ${lid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${title3}=  FakerLibrary.user name
    ${desc4}=   FakerLibrary.word 

    ${resp}=    Create Task   ${title3}  ${desc4}   ${userType[0]}  ${category_id1}  ${type_id1}   ${lid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200




JD-TC-CreateTaskforUser-12

    [Documentation]  Create a task for a branch by giving status and priority.

    ${resp}=  Provider Login  ${HLMUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid}=  get_acc_id  ${MUSERNAME2}
   
   
    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
    ELSE
        Set Suite Variable  ${locId}  ${resp.json()[0]['id']}
    END
    
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

    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 
    ${status}=  Create Dictionary   id=${status_id1}
    ${priority}=  Create Dictionary   id=${priority_id1}

    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId}  status=${status}  priority=${priority}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-CreateTaskforUser-13

    [Documentation]  Create a task for a user by giving status and priority.

    ${resp}=  ProviderLogin  ${PUSERNAME_U2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=    Get Task Status
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${status_id1}    ${resp.json()[0]['id']}
    Set Test Variable  ${status_name1}  ${resp.json()[0]['name']}

    ${resp}=    Get Task Priority
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${priority_id1}    ${resp.json()[0]['id']}
    Set Test Variable  ${priority_name1}  ${resp.json()[0]['name']}
    
    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 
    ${status}=  Create Dictionary   id=${status_id1}
    ${priority}=  Create Dictionary   id=${priority_id1}


    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}    ${lid1}    status=${status}  priority=${priority}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    



JD-TC-CreateTaskforUser-14

    [Documentation]   Create a consumer Task  for a branch.

    ${resp}=  Provider Login  ${HLMUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid}=  get_acc_id  ${HLMUSERNAME2}
   
   
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
    Set Test Variable  ${category_id1}    ${resp.json()[0]['id']}
    Set Test Variable  ${category_name1}  ${resp.json()[0]['name']}

    ${resp}=    Get Task Type
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${type_id1}    ${resp.json()[0]['id']}
    Set Test Variable  ${type_name1}  ${resp.json()[0]['name']}

    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 

    ${resp}=    Create Task   ${title}  ${desc}   ${userType[3]}  ${category_id1}  ${type_id1}   ${locId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-CreateTaskforUser-15

    [Documentation]   Create a consumer Task  for a user.
    
     ${resp}=  ProviderLogin  ${PUSERNAME_U3}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${locId1}=  Create Sample Location


    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 

    ${resp}=    Create Task   ${title}  ${desc}   ${userType[3]}  ${category_id1}  ${type_id1}   ${locId1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200



JD-TC-CreateTaskforUser-16

    [Documentation]  Create a task without title by user.

    ${resp}=  Provider Login  ${HLMUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${desc}=   FakerLibrary.word 

    ${resp}=    Create Task   ${EMPTY}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-CreateTaskforUser-17

    [Documentation]  Create a task without description by user.

    ${resp}=  Provider Login  ${HLMUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid}=  get_acc_id  ${MUSERNAME51}
   
    ${title}=   FakerLibrary.word 

    ${resp}=    Create Task   ${title}  ${EMPTY}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-CreateTaskforUser-UH1

    [Documentation]  Create a task without giving user type by user.

    ${resp}=  Provider Login  ${HLMUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${title}=   FakerLibrary.word 
    ${desc}=   FakerLibrary.word 

    ${resp}=    Create Task   ${title}  ${desc}   ${EMPTY}  ${category_id1}  ${type_id1}   ${locId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}    ${INVALID_USERTYPE}


JD-TC-CreateTaskforUser-UH2

    [Documentation]  Create a task without giving user type by branch.

     ${resp}=   ProviderLogin  ${HLMUSERNAME2}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 

    ${resp}=    Create Task   ${title}  ${desc}   ${EMPTY}  ${category_id1}  ${type_id1}   ${locId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${INVALID_USERTYPE}




JD-TC-CreateTaskforUser-UH3

    [Documentation]  Create a task without location by branch.

    ${resp}=   ProviderLogin  ${HLMUSERNAME2}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 

    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${EMPTY}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${LOCATION_REQUIRED}


JD-TC-CreateTaskforUser-UH4

    [Documentation]  Create a task without location by user login.


     ${resp}=  ProviderLogin  ${PUSERNAME_U3}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${locId1}=  Create Sample Location


    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 

    ${resp}=    Create Task   ${title}  ${desc}   ${userType[3]}  ${category_id1}  ${type_id1}   ${Empty}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${LOCATION_REQUIRED}






JD-TC-CreateTaskforUser-UH5

    [Documentation]  Create a task without category by branch.

    ${resp}=  Provider Login  ${HLMUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid}=  get_acc_id  ${HLMUSERNAME2}
   
    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.Word

    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${EMPTY}  ${type_id1}   ${locId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${CATEGORY_REQUIRED}


JD-TC-CreateTaskforUser-UH6

    [Documentation]  Create a task without category by user.

     ${resp}=  ProviderLogin  ${PUSERNAME_U3}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${locId1}=  Create Sample Location


    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 

    ${resp}=    Create Task   ${title}  ${desc}   ${userType[3]}  ${EMPTY}  ${type_id1}     ${locId1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${CATEGORY_REQUIRED}




JD-TC-CreateTaskforUser-UH7

    [Documentation]  Create a task without task type by branch.

    ${resp}=  Provider Login  ${HLMUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid}=  get_acc_id  ${HLMUSERNAME2}
   
    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.Word

    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${EMPTY}   ${locId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${TYPE_REQUIRED}


JD-TC-CreateTaskforUser-UH8

    [Documentation]  Create a task without task type by user.

     ${resp}=  ProviderLogin  ${PUSERNAME_U3}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${locId1}=  Create Sample Location


    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 

    ${resp}=    Create Task   ${title}  ${desc}   ${userType[3]}  ${category_id1}   ${EMPTY}     ${locId1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${TYPE_REQUIRED}




JD-TC-CreateTaskforUser-UH9

    [Documentation]  Create a task without login.

    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 
    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-CreateTaskforUser-UH10
    [Documentation]  Create a task with consumer login.

    ${resp}=   ConsumerLogin  ${CUSERNAME8}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 

    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   ${resp.json()}    ${LOGIN_NO_ACCESS_FOR_URL}


JD-TC-CreateTaskforUser-UH11

    [Documentation]  Create a task with status as empty by user.

   
    ${resp}=  Provider Login  ${HLMUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid}=  get_acc_id   ${HLMUSERNAME2}
   
    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 
    ${status1}=  Create Dictionary   id=${EMPTY}
    ${priority}=  Create Dictionary   id=${priority_id1}

    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId}  status=${status1}  priority=${priority}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
   


JD-TC-CreateTaskforUser-UH12

    [Documentation]  Create a task with priority as empty by user.

    ${resp}=  ProviderLogin  ${PUSERNAME_U3}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${locId1}=  Create Sample Location

  
    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 
    ${status}=  Create Dictionary   id=${status_id1}
    ${priority1}=  Create Dictionary   id=${EMPTY}

    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId1}  status=${status}  priority=${priority1}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    

JD-TC-CreateTaskforUser-UH13

    [Documentation]  Create a task with status as empty by branch.

    ${resp}=  Provider Login  ${HLMUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid}=  get_acc_id  ${HLMUSERNAME2}
   
    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 
    ${status2}=  Create Dictionary   id=${EMPTY}
    ${priority}=  Create Dictionary   id=${priority_id1}

    ${resp}=    Create Task   ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId}  status=${status2}  priority=${priority}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    

