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

JD-TC-GetTaskMaster-1

    [Documentation]  Create a task master for a branch and verify the details by get task master by id.

    ${resp}=  Encrypted Provider Login  ${MUSERNAME37}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${provider_id}  ${resp.json()['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}

     ${p_id}=  get_acc_id  ${MUSERNAME37}
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

    ${resp}=   Get Task Priority
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${Priority_id}    ${resp.json()[0]['id']}
    Set Test Variable  ${Priority_name1}  ${resp.json()[0]['name']}

    ${resp}=    Get Task Status
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}  Get Length  ${resp.json()}
    FOR   ${i}  IN RANGE   ${len}
        IF   '${resp.json()[${i}]['name']}' == 'New'

            Set Test Variable  ${new_status_id}    ${resp.json()[${i}]['id']}
            Set Test Variable  ${new_status_name}  ${resp.json()[${i}]['name']}

        END
    END

    ${templateName} =   FakerLibrary.user name
    Set Suite Variable  ${templateName}
    ${resp}=  taskTemplate  ${account_id}  ${templateName}  ${new_status_id}  origin_from=0   is_subtask=0  category_id=${category_id1}  priority_id=${Priority_id}  type_id=${type_id1}  creator_provider_id=${provider_id}  is_available=1  
    
    ${resp}=  Get Task Master With Filter
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${id1}    ${resp.json()[0]['id']}

    ${templateName1}=  FakerLibrary.user name
    Set Suite Variable  ${templateName1}
    ${resp}=  taskTemplate  ${account_id}  ${templateName1}  ${new_status_id}  origin_from=${id1}   is_subtask=1  category_id=${category_id1}  priority_id=${Priority_id}  type_id=${type_id1}  creator_provider_id=${provider_id}  is_available=1  

    ${resp}=  Get Task Master With Filter
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${id2}    ${resp.json()[0]['id']}

    ${resp}=  Get Task Master With Filter  id-eq=${id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=  Get Task Master With Filter  id-eq=${id2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
   
JD-TC-GetTaskMaster-2

    [Documentation]  Get task master with tittle 
    
    ${resp}=  Encrypted Provider Login  ${MUSERNAME37}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Task Master With Filter   title-eq=${templateName}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List    ${resp}    0   templateName=${templateName}

JD-TC-GetTaskMaster-3

    [Documentation]  Get task master with tittle 

    ${resp}=  Encrypted Provider Login  ${MUSERNAME37}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Task Master With Filter   templateName-eq=${templateName1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List    ${resp}    0   templateName=${templateName1}

   
JD-TC-GetTaskMaster-4

    [Documentation]  Get task master by id for a user.

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME4}   ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${provider_id2}  ${resp.json()['id']}

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
    Set Suite Variable  ${account_id2}  ${resp2.json()['id']}
    
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

    ${resp}=  categorytype  ${account_id2}
    ${resp}=  tasktype      ${account_id2}
    ${resp}=    Get Task Category Type
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${category_id2}    ${resp.json()[0]['id']}
    Set Test Variable  ${category_name1}  ${resp.json()[0]['name']}

    ${resp}=    Get Task Type
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${type_id2}    ${resp.json()[0]['id']}
    Set Test Variable  ${type_name2}  ${resp.json()[0]['name']}
    
    ${resp}=   Get Task Priority
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${Priority_id1}    ${resp.json()[0]['id']}
    Set Test Variable  ${Priority_name1}  ${resp.json()[0]['name']}

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
    ${pid7}=  get_acc_id  ${PUSERPH0} 
    Set Suite variable     ${pid7}

    ${templateName3}=  FakerLibrary.user name
    Set Suite Variable    ${templateName3}

    ${resp}=  taskTemplate  ${pid7}  ${templateName3}  ${new_status_id}  origin_from=0   is_subtask=0  category_id=${category_id2}  priority_id=${Priority_id1}  type_id=${type_id2}  creator_provider_id=${lid}  is_available=1  

     ${resp}=  Get Task Master With Filter
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${id3}    ${resp.json()[0]['id']}

    ${resp}=  Get Task Master With Filter  id-eq=${id3}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List    ${resp}    0   templateName=${templateName3}  id=${id3}

JD-TC-GetTaskMaster-5

    [Documentation]  Get task master by Category id for a user.
    
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=    Get Task Category Type
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${category_id2}    ${resp.json()[0]['id']}
    Set Test Variable  ${category_name1}  ${resp.json()[0]['name']}

    ${resp}=    Get Task Type
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${type_id2}    ${resp.json()[0]['id']}
    Set Test Variable  ${type_name1}  ${resp.json()[0]['name']}

    ${resp}=  taskTemplate  ${pid7}  ${templateName3}  ${new_status_id}  origin_from=0   is_subtask=0  category_id=${category_id2}  priority_id=${Priority_id1}  type_id=${type_id2}  creator_provider_id=${lid}  is_available=1  

    ${resp}=  Get Task Master With Filter
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${id3}    ${resp.json()[0]['id']}
    
    ${resp}=  Get Task Master With Filter  category-eq=${category_id2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List    ${resp}    0   templateName=${templateName3}  id=${id3}
