*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Lead
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

JD-TC-GetLeadWithFilter-1

    
    [Documentation]   Create Lead to user.

    ${resp}=  Consumer Login  ${CUSERNAME27}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}
    Set Test Variable  ${uname}   ${resp.json()['userName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    
    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Suite Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Suite Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    ${firstname_A}=  FakerLibrary.first_name
    Set Suite Variable  ${firstname_A}
    ${lastname_A}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname_A}
    ${MUSERNAME_E}=  Evaluate  ${MUSERNAME}+560265
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
    Set Suite Variable  ${id}  ${resp.json()['id']}

    Append To File  ${EXECDIR}/TDD/numbers.txt  ${MUSERNAME_E}${\n}
    Append To File  ${EXECDIR}/TDD/TDD_Logs/providernumbers.txt  ${SUITE NAME} - ${TEST NAME} - ${MUSERNAME_E}${\n}
    Set Suite Variable  ${MUSERNAME_E}

    ${p_id}=  get_acc_id  ${MUSERNAME_E}

    ${resp}=   enquiryStatus  ${p_id}
    ${resp}=   leadStatus     ${p_id}
    ${resp}=   categorytype   ${p_id}
    ${resp}=   tasktype       ${p_id}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        Set Suite Variable  ${lid}

        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${lidname}  ${resp.json()['place']}
        
    ELSE
        Set Suite Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${lidname}  ${resp.json()[0]['place']}
    END

    ${lid1}=  Create Sample Location
    Set Suite Variable  ${lid1}

    ${resp}=   Get Location ById  ${lid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']} 

    ${resp}=   Get Location ById  ${lid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${lidname1}  ${resp.json()['place']}
    
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
    ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+3466465
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

    ${whpnum}=  Evaluate  ${PUSERNAME}+346247
    ${tlgnum}=  Evaluate  ${PUSERNAME}+346347

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERNAME_U1}  ${dep_id}  ${EMPTY}  ${bool[0]}  ${countryCodes[1]}  ${whpnum}  ${countryCodes[1]}  ${tlgnum}
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

    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${PUSERNAME_U2}=  Evaluate  ${PUSERNAME}+3566463
    clear_users  ${PUSERNAME_U2}
    Set Suite Variable  ${PUSERNAME_U2}
    clear_users  ${PUSERNAME_U2}
    Set Suite Variable  ${PUSERNAME_U2}
    ${firstname1}=  FakerLibrary.name
    Set Suite Variable  ${firstname}
    ${lastname1}=  FakerLibrary.last_name
    
    ${whpnum}=  Evaluate  ${PUSERNAME}+346860
    ${tlgnum}=  Evaluate  ${PUSERNAME}+346387

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

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${p_id}=  get_acc_id  ${PUSERNAME_U1}

    # ${locId}=  Create Sample Location

    ${resp}=  categorytype  ${p_id}
    ${resp}=  tasktype      ${p_id}
    ${resp}=    Get Lead Category Type
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${category_id1}    ${resp.json()[0]['id']}
    Set Suite Variable  ${category_name1}  ${resp.json()[0]['name']}

    ${resp}=    Get Lead Type
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${type_id1}    ${resp.json()[0]['id']}
    Set Suite Variable  ${type_name1}  ${resp.json()[0]['name']}
    ${resp}=  categorytype  ${p_id}
    ${resp}=  tasktype      ${p_id}
    ${resp}=    Get Lead Status
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${status_id1}    ${resp.json()[0]['id']}
    Set Suite Variable  ${status_name1}  ${resp.json()[0]['name']}

    ${resp}=    Get Lead Priority
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${priority_id1}    ${resp.json()[0]['id']}
    Set Suite Variable  ${priority_name1}  ${resp.json()[0]['name']}

    ${title}=  FakerLibrary.user name
    Set Suite Variable    ${title}
    ${desc}=   FakerLibrary.word 
    Set Suite Variable    ${desc}
    ${targetPotential}=    FakerLibrary.Building Number
    Set Suite Variable    ${targetPotential}
    ${status}=  Create Dictionary   id=${status_id1}
    Set Suite Variable    ${status}
    ${priority}=  Create Dictionary   id=${priority_id1}
    Set Suite Variable    ${priority}
    ${CategoryType}=  Create Dictionary   id=${category_id1}
    Set Suite Variable    ${CategoryType}
    ${Type}=  Create Dictionary   id=${type_id1}
    Set Suite Variable    ${Type}

    ${resp}=  AddCustomer  ${CUSERNAME3}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME3}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable  ${pcons_id3}  ${resp.json()[0]['id']}
    Set Suite Variable  ${jaldeeId}  ${resp.json()[0]['jaldeeId']}

     ${resp}=    Create Lead    ${title}    ${desc}    ${targetPotential}      ${lid}    ${pcons_id3}    status=${status}   priority=${priority}   category=${CategoryType}    type=${Type}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${leid}        ${resp.json()['id']}
    Set Suite Variable   ${leUid}        ${resp.json()['uid']}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${p_id1}=  get_acc_id  ${PUSERNAME_U2}
    Set Suite Variable    ${p_id1}
    # ${locId1}=  Create Sample Location

    ${resp}=  categorytype  ${p_id1}
    ${resp}=  tasktype      ${p_id1}
    ${resp}=    Get Lead Category Type
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${category_id2}    ${resp.json()[0]['id']}
    Set Suite Variable  ${category_name2}  ${resp.json()[0]['name']}

    ${resp}=    Get Lead Type
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${type_id2}    ${resp.json()[0]['id']}
    Set Suite Variable  ${type_name2}  ${resp.json()[0]['name']}
    ${resp}=  categorytype  ${p_id1}
    ${resp}=  tasktype      ${p_id1}
    ${resp}=    Get Lead Status
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${status_id2}    ${resp.json()[0]['id']}
    Set Suite Variable  ${status_name2}  ${resp.json()[0]['name']}

    ${resp}=    Get Lead Priority
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${priority_id2}    ${resp.json()[0]['id']}
    Set Suite Variable  ${priority_name2}  ${resp.json()[0]['name']}

    ${title1}=  FakerLibrary.user name
    Set Suite Variable    ${title1}
    ${desc1}=   FakerLibrary.word 
    Set Suite Variable    ${desc1}
    ${targetPotential1}=    FakerLibrary.Building Number
    Set Suite Variable    ${targetPotential1}
    ${status2}=  Create Dictionary   id=${status_id2}
    Set Suite Variable    ${status2}
    ${priority2}=  Create Dictionary   id=${priority_id2}
    Set Suite Variable    ${priority2}
    ${CategoryType2}=  Create Dictionary   id=${category_id2}
    Set Suite Variable    ${CategoryType2}
    ${Type2}=  Create Dictionary   id=${type_id2}
    Set Suite Variable    ${Type2}
    ${assignee1}=  Create Dictionary    id=${u_id1}
    Set Suite Variable    ${assignee1}
    ${manager1}=  Create Dictionary    id=${id}
    Set Suite Variable    ${manager1}
    ${resp}=  AddCustomer  ${CUSERNAME4}   firstName=${fname}  lastName=${lname}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME4}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable  ${pcons_id4}  ${resp.json()[0]['id']}
    Set Suite Variable  ${jaldeeId}  ${resp.json()[0]['jaldeeId']}

    ${resp}=    Create Lead    ${title1}    ${desc1}    ${targetPotential1}      ${lid1}    ${pcons_id4}    status=${status2}   priority=${priority2}   category=${CategoryType2}    type=${Type2}    assignee=${assignee1}    manager=${manager1}
    # assignee=${u_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${leid1}        ${resp.json()['id']}
    Set Suite Variable   ${leUid1}        ${resp.json()['uid']}

JD-TC-GetLeadWithFilter-2
    [Documentation]   Create Lead to a valid provider Filter by id.
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Leads With Filter    id-eq=${leid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Verify Response List    ${resp}    0   id=${leid}
    

JD-TC-GetLeadWithFilter-3
    [Documentation]   Create Lead to a valid provider Filter by uid.
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Leads With Filter    uid-eq=${leUid1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Verify Response List    ${resp}    0   uid=${leUid1}

JD-TC-GetLeadWithFilter-4
    [Documentation]   Create Lead to a valid provider Filter by title.
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Leads With Filter    title-eq=${title1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Verify Response List    ${resp}    0   title=${title1}

JD-TC-GetLeadWithFilter-5
    [Documentation]   Create Lead to a valid provider Filter by description.
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Leads With Filter    description-eq=${desc1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Verify Response List    ${resp}    0   description=${desc1}

JD-TC-GetLeadWithFilter-6
    [Documentation]   Create Lead to a valid provider Filter by assignee.
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Leads With Filter    assignee-eq=${u_id1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['assignee']['id']}          ${u_id1}
 

    ${resp}=    Get Leads With Filter    assigneeLastName-eq=${lastname}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings  ${resp.json()['assignee']['id']}          ${u_id1}
    Verify Response List    ${resp}    0   uid=${leUid}
    Verify Response List    ${resp}    0   id=${leid} 

JD-TC-GetLeadWithFilter-7
    [Documentation]   Create Lead to a valid provider Filter by targetPotential.
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Leads With Filter    targetPotential-eq=${targetPotential}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Verify Response List    ${resp}    0   targetPotential=${targetPotential}
    Verify Response List    ${resp}    0   uid=${leUid} 

JD-TC-GetLeadWithFilter-8
    [Documentation]   Create Lead to a valid provider Filter by category And categoryName.
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Leads With Filter    category-eq=${category_id1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['category']['id']}          ${category_id1}
    # Verify Response List    ${resp}    0   uid=${leUid} 

     

JD-TC-GetLeadWithFilter-9
    [Documentation]   Create Lead to a valid provider Filter by manager.
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Leads With Filter    manager-eq=${id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['manager']['id']}          ${id}   
    # Verify Response List    ${resp}    0   uid=${leUid} 

JD-TC-GetLeadWithFilter-10
    [Documentation]   Create Lead to a valid provider Filter by managerFirstName.
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Leads With Filter    managerFirstName-eq=${firstname_A}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Verify Response List    ${resp}    0   managerFirstName=${firstname_A}
    Verify Response List    ${resp}    0   uid=${leUid1} 

JD-TC-GetLeadWithFilter-11
    [Documentation]   Create Lead to a valid provider Filter by managerLastName.
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Leads With Filter    managerLastName-eq=${lastname_A}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Verify Response List    ${resp}    0   managerLastName=${lastname_A}
    Verify Response List    ${resp}    0   uid=${leUid1} 



JD-TC-GetLeadWithFilter-15
    [Documentation]   Create Lead to a valid provider Filter by customer.
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Leads With Filter    customer-eq=${pcons_id3}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Verify Response List    ${resp}    0   customer=${lastname_A}
    # Verify Response List    ${resp}    0   uid=${leUid}

JD-TC-GetLeadWithFilter-16
    [Documentation]   Create Lead to a valid provider Filter by customerFirstName.
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Leads With Filter    customerFirstName-eq=${fname}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Verify Response List    ${resp}    0   customerFirstName=${lastname_A}
    # Verify Response List    ${resp}    0   uid=${leUid}

JD-TC-GetLeadWithFilter-17
    [Documentation]   Create Lead to a valid provider Filter by customerLastName.
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Leads With Filter    customerLastName-eq=${lname}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Verify Response List    ${resp}    0   customerLastName=${lastname_A}
    # Verify Response List    ${resp}    0   uid=${leUid}

JD-TC-GetLeadWithFilter-18
    [Documentation]   Create Lead to a valid provider Filter by assigneeFirstName.
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Leads With Filter    assigneeFirstName-eq=${firstname}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings  ${resp.json()['assignee']['id']}           ${u_id1}
    Verify Response List    ${resp}    0   uid=${leUid}
    Verify Response List    ${resp}    0   id=${leid}

JD-TC-GetLeadWithFilter-19
    [Documentation]   Create Lead to a valid provider Filter by location.
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Leads With Filter    location-eq=${lid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}          ${lid}

JD-TC-GetLeadWithFilter-20
    [Documentation]   Create Lead to a valid provider Filter by locationName.
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Location ById  ${lid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${lidname}  ${resp.json()['place']}

    ${resp}=    Get Leads With Filter    locationName-eq=${lidname}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
     Should Be Equal As Strings  ${resp.json()[0]['location']['name']}          ${lidname}
    Verify Response List    ${resp}    0   uid=${leUid} 

JD-TC-GetLeadWithFilter-21
    [Documentation]   Create Lead to a valid provider Filter by type.
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Leads With Filter    type-eq=${type_id1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['type']['id']}          ${type_id1}
    # Verify Response List    ${resp}    0   type=${Type}
    # Verify Response List    ${resp}    0   uid=${leUid} 

JD-TC-GetLeadWithFilter-22
    [Documentation]   Create Lead to a valid provider Filter by typeName.
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Leads With Filter    typeName-eq=${type_name1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Verify Response List    ${resp}    0   typeName=${type_name1}
    Should Be Equal As Strings  ${resp.json()[0]['type']['name']}          ${type_name1} 

JD-TC-GetLeadWithFilter-23
    [Documentation]   Create Lead to a valid provider Filter by priority.
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Leads With Filter    priority-eq=${priority_id1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['priority']['id']}          ${priority_id1}
    

JD-TC-GetLeadWithFilter-24
    [Documentation]   Create Lead to a valid provider Filter by priorityName.
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Leads With Filter    priorityName-eq=${priority_name1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['priority']['name']}          ${priority_name1}

JD-TC-GetLeadWithFilter-25
    [Documentation]   Create Lead to a valid provider Filter by status.
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Leads With Filter    status-eq=${status_id2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['status']['id']}          ${status_id2}
    # Verify Response List    ${resp}    0   uid=${leUid} 
JD-TC-GetLeadWithFilter-26
    [Documentation]   Create Lead to a valid provider Filter by categoryName.
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=    Get Leads With Filter    categoryName-eq=${category_name1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['category']['name']}          ${category_name1}  

*** comment ***
JD-TC-GetLeadWithFilter-12
    [Documentation]   Create Lead to a valid provider Filter by generatedBy.
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Leads With Filter    generatedBy-eq=${p_id1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Verify Response List    ${resp}    0   generatedBy=${p_id1}
    Verify Response List    ${resp}    0   uid=${leUid}

JD-TC-GetLeadWithFilter-13
    [Documentation]   Create Lead to a valid provider Filter by generatedByFirstName.
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Leads With Filter    generatedByFirstName-eq=${firstname}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Verify Response List    ${resp}    0   generatedByFirstName=${firstname}
    Verify Response List    ${resp}    0   uid=${leUid}

JD-TC-GetLeadWithFilter-14
    [Documentation]   Create Lead to a valid provider Filter by generatedByLastName.
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Leads With Filter    generatedByLastName-eq=${lastname}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Verify Response List    ${resp}    0   generatedByLastName=${lastname}
    Verify Response List    ${resp}    0   uid=${leUid} 