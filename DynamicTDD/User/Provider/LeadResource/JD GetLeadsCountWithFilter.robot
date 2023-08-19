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
JD-TC-GetLeadCount

    
    [Documentation]   Create Lead to user.

    ${resp}=  Consumer Login  ${CUSERNAME28}  ${PASSWORD}
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
    ${MUSERNAME_E}=  Evaluate  ${MUSERNAME}+580268
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
    ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+3386466
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

    ${whpnum}=  Evaluate  ${PUSERNAME}+346248
    ${tlgnum}=  Evaluate  ${PUSERNAME}+346348

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.ynwtest@netvarth.com   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERNAME_U1}  ${dep_id}  ${EMPTY}  ${bool[0]}  ${countryCodes[1]}  ${whpnum}  ${countryCodes[1]}  ${tlgnum}
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

    ${PUSERNAME_U2}=  Evaluate  ${PUSERNAME}+3386464
    clear_users  ${PUSERNAME_U2}
    Set Suite Variable  ${PUSERNAME_U2}
    clear_users  ${PUSERNAME_U2}
    Set Suite Variable  ${PUSERNAME_U2}
    ${firstname1}=  FakerLibrary.name
    Set Suite Variable  ${firstname}
    ${lastname1}=  FakerLibrary.last_name
    
    ${whpnum}=  Evaluate  ${PUSERNAME}+346862
    ${tlgnum}=  Evaluate  ${PUSERNAME}+346389

    ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U2}.ynwtest@netvarth.com   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERNAME_U2}  ${dep_id}  ${EMPTY}  ${bool[0]}  ${countryCodes[1]}  ${whpnum}  ${countryCodes[1]}  ${tlgnum}
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
    Set Suite Variable  ${status_id1}    ${resp.json()[5]['id']}
    Set Suite Variable  ${status_name1}  ${resp.json()[5]['name']}

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

    ${resp}=    Create Lead    ${title}    ${desc}    ${targetPotential}      ${lid}    ${pcons_id3}    status=${status}      category=${CategoryType}    type=${Type}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${leid1}        ${resp.json()['id']}
    Set Suite Variable   ${leUid1}        ${resp.json()['uid']}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${p_id1}=  get_acc_id  ${PUSERNAME_U2}
    Set Suite Variable    ${p_id1}

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
    ${title2}=  FakerLibrary.user name
    Set Suite Variable    ${title2}
    ${desc1}=   FakerLibrary.word 
    Set Suite Variable    ${desc1}
    ${desc2}=   FakerLibrary.word 
    Set Suite Variable    ${desc2}
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
    ${assignee2}=  Create Dictionary    id=${u_id}
    Set Suite Variable    ${assignee2}
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

    ${resp}=    Create Lead    ${title1}    ${desc1}    ${targetPotential1}      ${lid1}    ${pcons_id4}    status=${status2}   priority=${priority2}   category=${CategoryType2}    type=${Type2}    assignee=${assignee2}    manager=${manager1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${leid2}        ${resp.json()['id']}
    Set Suite Variable   ${leUid2}        ${resp.json()['uid']}

    ${resp}=    Create Lead    ${title2}    ${desc2}    ${targetPotential1}      ${lid1}    ${pcons_id3}    status=${status2}   priority=${priority2}   category=${CategoryType2}    type=${Type2}    assignee=${assignee1}    manager=${manager1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${leid3}        ${resp.json()['id']}
    Set Suite Variable   ${leUid3}        ${resp.json()['uid']}

JD-TC-GetLeadCount-1

    [Documentation]   Create one lead to a branch and get the lead count.

    ${resp}=   Encrypted Provider Login  ${MUSERNAME54}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${p_id}=  get_acc_id  ${MUSERNAME54}

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

    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 
    ${targetPotential}=    FakerLibrary.Building Number

    ${resp}=  AddCustomer  ${CUSERNAME6}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME6}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${pcons_id6}  ${resp.json()[0]['id']}
    Set Test Variable  ${jaldeeId}  ${resp.json()[0]['jaldeeId']}

    ${resp}=    Create Lead    ${title}    ${desc}    ${targetPotential}      ${locId}    ${pcons_id6}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${leid4}        ${resp.json()['id']}
    Set Suite Variable   ${leUid4}        ${resp.json()['uid']}

    ${resp}=    Get Lead Count
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

JD-TC-GetLeadCount-2

    [Documentation]   Create multiple leads to a branch and get the lead count.

    ${resp}=   Encrypted Provider Login  ${MUSERNAME55}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${p_id}=  get_acc_id  ${MUSERNAME55}

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

    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 
    ${targetPotential}=    FakerLibrary.Building Number

    ${resp}=  AddCustomer  ${CUSERNAME6}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME6}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${pcons_id6}  ${resp.json()[0]['id']}
    Set Test Variable  ${jaldeeId}  ${resp.json()[0]['jaldeeId']}

    ${resp}=    Create Lead    ${title}    ${desc}    ${targetPotential}      ${locId}    ${pcons_id6}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${leid5}        ${resp.json()['id']}
    Set Suite Variable   ${leUid5}        ${resp.json()['uid']}

    ${title1}=  FakerLibrary.user name
    ${desc1}=   FakerLibrary.word 
    ${targetPotential1}=    FakerLibrary.Building Number
    ${actualPotential1}=    FakerLibrary.Building Number
    Set Suite Variable   ${actualPotential1}
    ${resp}=    Create Lead    ${title1}    ${desc1}    ${targetPotential1}      ${locId}    ${pcons_id6}    actualPotential=${actualPotential1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${leid6}        ${resp.json()['id']}
    Set Suite Variable   ${leUid6}        ${resp.json()['uid']}

    ${resp}=    Get Lead Count
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2


JD-TC-GetLeadCount-3

    [Documentation]   Create leads to a user and get the lead count.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead Count  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  3



JD-TC-GetLeadCount-4

    [Documentation]   Create multiple leads to different users and get the lead count.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME_U2}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead Count  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2

JD-TC-GetLeadCount-5

    [Documentation]   get the lead count with id filter.

    ${resp}=   Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead Count  id-eq=${leid2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1


JD-TC-GetLeadCount-6

    [Documentation]   get the lead count with uid filter.

    ${resp}=   Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=    Get Lead Count  uid-eq=${leUid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

JD-TC-GetLeadCount-7

    [Documentation]   get the lead count with title filter.

    ${resp}=   Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=    Get Lead Count  title-eq=${title}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2

JD-TC-GetLeadCount-8

    [Documentation]   get the lead count with description filter.

    ${resp}=   Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=    Get Lead Count  description-eq=${desc2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

JD-TC-GetLeadCount-9

    [Documentation]   get the lead count with targetPotential filter.

    ${resp}=   Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=    Get Lead Count  targetPotential-eq=${targetPotential}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2

JD-TC-GetLeadCount-10

    [Documentation]   get the lead count with actualPotential filter.

    ${resp}=   Encrypted Provider Login  ${MUSERNAME55}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=    Get Lead Count  actualPotential-eq=${actualPotential1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

JD-TC-GetLeadCount-11

    [Documentation]   get the lead count with assignee filter.

    ${resp}=   Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=    Get Lead Count  assignee-eq=${u_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  3

JD-TC-GetLeadCount-12

    [Documentation]   get the lead count with assigneeFirstName filter.

    ${resp}=   Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=    Get Lead Count  assigneeFirstName-eq=${firstname}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  3

JD-TC-GetLeadCount-13

    [Documentation]   get the lead count with assigneeLastName filter.

    ${resp}=   Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=    Get Lead Count  assigneeLastName-eq=${lastname}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  3

JD-TC-GetLeadCount-14

    [Documentation]   get the lead count with manager filter.

    ${resp}=   Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=    Get Lead Count  manager-eq=${id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2

JD-TC-GetLeadCount-15

    [Documentation]   get the lead count with managerFirstName filter.

    ${resp}=   Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=    Get Lead Count  managerFirstName-eq=${firstname_A}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2    

JD-TC-GetLeadCount-16

    [Documentation]   get the lead count with managerLastName filter.

    ${resp}=   Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=    Get Lead Count  managerLastName-eq=${lastname_A}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2  



JD-TC-GetLeadCount-17

    [Documentation]   get the lead count with customer filter.

    ${resp}=   Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=    Get Lead Count  customer-eq=${pcons_id4}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

JD-TC-GetLeadCount-18

    [Documentation]   get the lead count with customerFirstName filter.

    ${resp}=   Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=    Get Lead Count  customerFirstName-eq=${fname}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

JD-TC-GetLeadCount-19

    [Documentation]   get the lead count with customerLastName filter.

    ${resp}=   Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=    Get Lead Count  customerLastName-eq=${lname}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

JD-TC-GetLeadCount-20

    [Documentation]   get the lead count with location filter.

    ${resp}=   Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=    Get Lead Count  location-eq=${lid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2

JD-TC-GetLeadCount-21

    [Documentation]   get the lead count with locationName filter.

    ${resp}=   Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=    Get Lead Count  locationName-eq=${lidname}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2

JD-TC-GetLeadCount-22

    [Documentation]   get the lead count with category filter.

    ${resp}=   Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=    Get Lead Count  category-eq=${category_id2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  4

JD-TC-GetLeadCount-23

    [Documentation]   get the lead count with categoryName filter.

    ${resp}=   Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=    Get Lead Count  categoryName-eq=${category_name1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  4

JD-TC-GetLeadCount-24

    [Documentation]   get the lead count with type filter.

    ${resp}=   Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=    Get Lead Count  type-eq=${type_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  4

JD-TC-GetLeadCount-25

    [Documentation]   get the lead count with typeName filter.

    ${resp}=   Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=    Get Lead Count  typeName-eq=${type_name1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  4

JD-TC-GetLeadCount-26

    [Documentation]   get the lead count with priority filter.

    ${resp}=   Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=    Get Lead Count  priority-eq=${priority_id2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  4

JD-TC-GetLeadCount-27

    [Documentation]   get the lead count with priorityName filter.

    ${resp}=   Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=    Get Lead Count  priorityName-eq=${priority_name2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  4

JD-TC-GetLeadCount-28

    [Documentation]   get the lead count with status filter.

    ${resp}=   Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=    Get Lead Count  status-eq=${status_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2

JD-TC-GetLeadCount-29

    [Documentation]   get the lead count with statusName filter.

    ${resp}=   Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=    Get Lead Count  statusName-eq=${status_name1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2

JD-TC-GetLeadCount-UH1

    [Documentation]   get the lead count without login.

    ${resp}=    Get Lead Count  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"


JD-TC-GetLeadCount-UH2

    [Documentation]   get the lead count with consumer login.

    ${resp}=  Consumer Login  ${CUSERNAME17}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=    Get Lead Count  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"   "${NoAccess}"


*** comment ***
JD-TC-GetLeadCount-

    [Documentation]   get the lead count after change the lead status to closed.

    ${resp}=   Encrypted Provider Login  ${MUSERNAME53}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-GetLeadCount-30

    [Documentation]   get the lead count with generatedBy filter.

    ${resp}=   Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=    Get Lead Count  generatedBy-eq=${p_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2  

JD-TC-GetLeadCount-31

    [Documentation]   get the lead count with generatedByFirstName filter.

    ${resp}=   Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=    Get Lead Count  generatedByFirstName-eq=${firstname}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1  

JD-TC-GetLeadCount-32

    [Documentation]   get the lead count with generatedByLastName filter.

    ${resp}=   Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=    Get Lead Count  generatedByLastName-eq=${lastname}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1