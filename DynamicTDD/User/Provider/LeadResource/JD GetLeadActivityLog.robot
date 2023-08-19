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
Variables         /ebs/TDD/varfiles/hl_musers.py

*** Variables ***

@{emptylist} 

*** Test Cases ***

JD-TC-GetLeadActivityLog-1
    [Documentation]    Create a lead to a branch and get the lead Activity log.

    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Suite Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Suite Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    ${firstname_A}=  FakerLibrary.first_name
    Set Suite Variable  ${firstname_A}
    ${lastname_A}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname_A}
    ${MUSERNAME_E}=  Evaluate  ${MUSERNAME}+550356
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
    ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+3366578
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

    ${whpnum}=  Evaluate  ${PUSERNAME}+346250
    ${tlgnum}=  Evaluate  ${PUSERNAME}+346350

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
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${p_id}=  get_acc_id  ${MUSERNAME_E}
    ${locId}=  Create Sample Location

    ${resp}=  categorytype  ${p_id}
    ${resp}=  tasktype      ${p_id}
    ${resp}=    Get Lead Category Type
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${category_id1}    ${resp.json()[0]['id']}
    Set Test Variable  ${category_name1}  ${resp.json()[0]['name']}

    ${resp}=    Get Lead Type
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${type_id1}    ${resp.json()[0]['id']}
    Set Test Variable  ${type_name1}  ${resp.json()[0]['name']}
    ${resp}=  categorytype  ${p_id}
    ${resp}=  tasktype      ${p_id}
    ${resp}=    Get Lead Status
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${status_id}    ${resp.json()[0]['id']}
    Set Suite Variable  ${status_id1}    ${resp.json()[1]['id']}
    Set Suite Variable  ${status_id2}    ${resp.json()[2]['id']}
    Set Suite Variable  ${status_id3}    ${resp.json()[3]['id']}
    Set Suite Variable  ${status_id4}    ${resp.json()[4]['id']}
    Set Suite Variable  ${status_id5}    ${resp.json()[5]['id']}
    Set Test Variable  ${status_name1}  ${resp.json()[0]['name']}

    ${resp}=    Get Lead Priority
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${priority_id}    ${resp.json()[0]['id']}
    Set Suite Variable  ${priority_id1}    ${resp.json()[1]['id']}
    Set Suite Variable  ${priority_id2}    ${resp.json()[2]['id']}
    Set Suite Variable  ${priority_id3}    ${resp.json()[3]['id']}
    Set Suite Variable  ${priority_name2}  ${resp.json()[0]['name']}

    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 
    ${targetPotential}=    FakerLibrary.Building Number
    ${resp}=  AddCustomer  ${CUSERNAME9}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME9}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable  ${pcons_id9}  ${resp.json()[0]['id']}
    Set Test Variable  ${jaldeeId}  ${resp.json()[0]['jaldeeId']}

    ${resp}=    Create Lead    ${title}    ${desc}    ${targetPotential}      ${locId}    ${pcons_id9}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${leid}        ${resp.json()['id']}
    Set Suite Variable   ${leUid}        ${resp.json()['uid']}

    ${resp}=    Get Lead Activity Log    ${leUid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['localUserId']}   ${id}
    Should Be Equal As Strings  ${resp.json()[0]['action']}    ADD
    Should Be Equal As Strings  ${resp.json()[0]['category']}    LEAD
    Should Be Equal As Strings  ${resp.json()[0]['subCategory']}    CREATE_LEAD
    Should Be Equal As Strings  ${resp.json()[0]['subject']}    Lead Created


JD-TC-GetLeadActivityLog-2
    [Documentation]    Create a lead to a branch and change the lead status to in progres then get the lead Activity log.

    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Change Lead Status    ${leUid}     ${status_id2}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Lead Activity Log    ${leUid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[1]['localUserId']}   ${id}
    Should Be Equal As Strings  ${resp.json()[1]['action']}    EDIT
    Should Be Equal As Strings  ${resp.json()[1]['category']}    LEAD
    Should Be Equal As Strings  ${resp.json()[1]['subCategory']}    UPDATE_LEAD_STATUS
    Should Be Equal As Strings  ${resp.json()[1]['subject']}    Lead Status Updated

JD-TC-GetLeadActivityLog-3
    [Documentation]    Create a lead to a branch and change the lead status to Success then get the lead Activity log.

    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Change Lead Status    ${leUid}     ${status_id4}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Lead Activity Log    ${leUid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[2]['localUserId']}   ${id}
    Should Be Equal As Strings  ${resp.json()[2]['action']}    EDIT
    Should Be Equal As Strings  ${resp.json()[2]['category']}    LEAD
    Should Be Equal As Strings  ${resp.json()[2]['subCategory']}    UPDATE_LEAD_STATUS
    Should Be Equal As Strings  ${resp.json()[2]['subject']}    Lead Status Updated

JD-TC-GetLeadActivityLog-4
    [Documentation]    Create a lead to a branch and change the lead status to Failed then get the lead Activity log.

    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Change Lead Status    ${leUid}     ${status_id3}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Lead Activity Log    ${leUid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[3]['localUserId']}   ${id}
    Should Be Equal As Strings  ${resp.json()[3]['action']}    EDIT
    Should Be Equal As Strings  ${resp.json()[3]['category']}    LEAD
    Should Be Equal As Strings  ${resp.json()[3]['subCategory']}    UPDATE_LEAD_STATUS
    Should Be Equal As Strings  ${resp.json()[3]['subject']}    Lead Status Updated

JD-TC-GetLeadActivityLog-5
    [Documentation]    Create a lead to a branch and update the lead status then get the lead Activity log.

    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
    ELSE
        Set Suite Variable  ${lid}  ${resp.json()[0]['id']}
    END

    ${title3}=  FakerLibrary.user name
    ${desc1}=   FakerLibrary.word 
    ${targetPotential}=    FakerLibrary.Building Number

    ${resp}=    Update Lead    ${leUid}    ${title3}    ${desc1}    ${status_id2}      ${priority_id}    ${lid}    ${pcons_id9}    ${id} 
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Lead Activity Log    ${leUid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[4]['localUserId']}   ${id}
    Should Be Equal As Strings  ${resp.json()[4]['action']}    EDIT
    Should Be Equal As Strings  ${resp.json()[4]['category']}    LEAD
    Should Be Equal As Strings  ${resp.json()[4]['subCategory']}    	UPDATE_LEAD 
    Should Be Equal As Strings  ${resp.json()[4]['subject']}    Lead Updated

JD-TC-GetLeadActivityLog-6
    [Documentation]    Create a lead to a branch and change the lead priority then get the lead Activity log.

    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Change Lead Priority    ${leUid}     ${priority_id2}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Leads With Filter   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['priority']['id']}    ${priority_id2}

    ${resp}=    Get Lead Activity Log    ${leUid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[5]['localUserId']}   ${id}
    Should Be Equal As Strings  ${resp.json()[5]['action']}    EDIT
    Should Be Equal As Strings  ${resp.json()[5]['category']}    LEAD
    Should Be Equal As Strings  ${resp.json()[5]['subCategory']}    	UPDATE_LEAD_PRIORITY 
    Should Be Equal As Strings  ${resp.json()[5]['subject']}    Lead Priority Updated

JD-TC-GetLeadActivityLog-7
    [Documentation]    Create a lead to a branch and change the lead Manager then get the lead Activity log.

    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Change Lead Manager    ${leUid}    ${u_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.json()}     ${bool[1]}

    ${resp}=    Get Lead Activity Log    ${leUid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[6]['localUserId']}   ${id}
    Should Be Equal As Strings  ${resp.json()[6]['action']}    EDIT
    Should Be Equal As Strings  ${resp.json()[6]['category']}    LEAD
    Should Be Equal As Strings  ${resp.json()[6]['subCategory']}    	UPDATE_LEAD_MANAGER
    Should Be Equal As Strings  ${resp.json()[6]['subject']}    Lead Manager Updated

JD-TC-GetLeadActivityLog-8

    [Documentation]    Create a lead to a branch and Add a Waitlist Token then get the lead Activity log.
    
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Toggle Department Enable
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Departments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}

    ${resp}=  Create Sample Location
    Set Test Variable    ${loc_id4}   ${resp}
    ${resp}=   Get Location ById  ${loc_id4}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ${ser_name3}=    FakerLibrary.name
    Set Test Variable     ${ser_name3}
    # ${resp}=  Create Sample Service   ${ser_name3}
    # Set Test Variable    ${ser_id4}   ${resp} 

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable    ${ser_id4}   ${resp.json()[0]['id']}

    ${resp}=  Enable Waitlist
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   01s

    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${q_name3}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${sone}=   db.get_time_by_timezone  ${tz}
    ${eone}=   add_timezone_time  ${tz}  3  00  
    
    ${parallel}=   FakerLibrary.Random Int  min=1   max=10 
    ${capacity}=   FakerLibrary.Random Int  min=1   max=10 
    ${resp}=  Create Queue    ${q_name3}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${sone}  ${eone}   ${parallel}   ${capacity}    ${loc_id4}  ${ser_id4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${q_id}   ${resp.json()}

    ${DAY4}=  db.add_timezone_date  ${tz}  4  
    ${desc}=   FakerLibrary.word
    ${lead}=  Create Dictionary   id=${leid}
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id4}  ${q_id}  ${DAY4}  ${desc}  ${bool[1]}  ${cid}   lead=${lead}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
      
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}

    ${resp}=    Add Lead Token   ${leUid}    ${wid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.json()}    ${bool[1]}

    ${resp}=    Get Leads With Filter    id-eq=${leid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['waitlists'][0]['waitlistUid']}    ${wid}
    Should Be Equal As Strings  ${resp.json()[0]['waitlists'][0]['createdBy']}    ${id}
    Should Be Equal As Strings  ${resp.json()[0]['waitlists'][0]['waitlistStatus']}    ${bool[1]}

    ${resp}=    Get Lead Activity Log    ${leUid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[7]['localUserId']}   ${id}
    Should Be Equal As Strings  ${resp.json()[7]['action']}    EDIT
    Should Be Equal As Strings  ${resp.json()[7]['category']}    LEAD
    Should Be Equal As Strings  ${resp.json()[7]['subCategory']}    	UPDATE_LEAD_WAITLISTS
    Should Be Equal As Strings  ${resp.json()[7]['subject']}    Lead Waitlist Added

JD-TC-GetLeadActivityLog-9

    [Documentation]    Create a lead to a branch and add notes then get the lead Activity log.

    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${note}=    FakerLibrary.sentence
    Set Suite Variable   ${note}
    ${resp}=    Add Lead Notes    ${leUid}    ${note}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Leads With Filter   uid-eq=${leUid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['notes'][0]['note']}    ${note}

    ${resp}=    Get Lead Activity Log    ${leUid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[8]['localUserId']}   ${id}
    Should Be Equal As Strings  ${resp.json()[8]['action']}    EDIT
    Should Be Equal As Strings  ${resp.json()[8]['category']}    LEAD
    Should Be Equal As Strings  ${resp.json()[8]['subCategory']}    	UPDATE_LEAD_NOTES
    Should Be Equal As Strings  ${resp.json()[8]['subject']}    Lead Note Added

JD-TC-GetLeadActivityLog-10

    [Documentation]    Create a lead to a branch and change the location then get the lead Activity log.

    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Create Sample Location
    Set Suite Variable    ${lid1}   ${resp}

    ${resp}=    Transfer Lead Location    ${leUid}    ${lid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Leads With Filter   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}    ${lid1}

    ${resp}=    Get Lead Activity Log    ${leUid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[9]['localUserId']}   ${id}
    Should Be Equal As Strings  ${resp.json()[9]['action']}    EDIT
    Should Be Equal As Strings  ${resp.json()[9]['category']}    LEAD
    Should Be Equal As Strings  ${resp.json()[9]['subCategory']}    	UPDATE_LEAD_LOCATION
    Should Be Equal As Strings  ${resp.json()[9]['subject']}    Lead Location Updated

JD-TC-GetLeadActivityLog-11

    [Documentation]    Create a lead for a user  then get the lead Activity log.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${id1}=  get_id  ${PUSERNAME_U1}

    ${title1}=  FakerLibrary.user name
    ${desc1}=   FakerLibrary.word 
    ${targetPotential}=    FakerLibrary.Building Number
    ${resp}=  AddCustomer  ${CUSERNAME10}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid1}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME10}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable  ${pcons_id10}  ${resp.json()[0]['id']}
    Set Test Variable  ${jaldeeId}  ${resp.json()[0]['jaldeeId']}

    ${resp}=    Create Lead    ${title1}    ${desc1}    ${targetPotential}      ${lid}    ${pcons_id10}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${leid1}        ${resp.json()['id']}
    Set Suite Variable   ${leUid1}        ${resp.json()['uid']}

    ${resp}=    Get Lead Activity Log    ${leUid1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['localUserId']}   ${id1}
    Should Be Equal As Strings  ${resp.json()[0]['action']}    ADD
    Should Be Equal As Strings  ${resp.json()[0]['category']}    LEAD
    Should Be Equal As Strings  ${resp.json()[0]['subCategory']}    	CREATE_LEAD
    Should Be Equal As Strings  ${resp.json()[0]['subject']}    Lead Created


JD-TC-GetLeadActivityLog-UH1

    [Documentation]  GetLeadActivityLog without login.

    ${resp}=    Get Lead Activity Log    ${leUid1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

JD-TC-GetLeadActivityLog-UH2

    [Documentation]  GetLeadActivityLog with consumer login.

    ${resp}=  Consumer Login  ${CUSERNAME17}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Lead Activity Log    ${leUid1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings  "${resp.json()}"   "${NoAccess}"

*** comment ***


JD-TC-GetLeadActivityLog-8
    [Documentation]    Create a lead to a branch and change the lead Assignee then get the lead Activity log.

    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Leads With Filter    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['assignee']['id']}          ${id}
    
    ${resp}=    Change Lead Assignee   ${leUid}  ${u_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Leads With Filter    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['assignee']['id']}          ${u_id}

    ${resp}=    Get Lead Activity Log    ${leUid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[7]['localUserId']}   ${id}
    Should Be Equal As Strings  ${resp.json()[7]['action']}    EDIT
    Should Be Equal As Strings  ${resp.json()[7]['category']}    LEAD
    Should Be Equal As Strings  ${resp.json()[7]['subCategory']}    	UPDATE_LEAD_ASSIGNEE
    Should Be Equal As Strings  ${resp.json()[7]['subject']}    Lead Assignee Updated


JD-TC-GetLeadActivityLog-12

    [Documentation]    Create a lead for a user and change the location ,change the lead Assignee  then get the lead Activity log.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${id1}=  get_id  ${PUSERNAME_U1}

    # ${resp}=  Create Sample Location
    # Set Test Variable    ${lid2}   ${resp}

    ${resp}=    Transfer Lead Location    ${leUid1}    ${lid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Leads With Filter   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}    ${lid1}

    ${resp}=    Change Lead Assignee   ${leUid1}  ${id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Leads With Filter    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['assignee']['id']}          ${id}

    ${resp}=    Get Lead Activity Log    ${leUid1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[1]['localUserId']}   ${id1}
    Should Be Equal As Strings  ${resp.json()[1]['action']}    EDIT
    Should Be Equal As Strings  ${resp.json()[1]['category']}    LEAD
    Should Be Equal As Strings  ${resp.json()[1]['subCategory']}    	UPDATE_LEAD_LOCATION
    Should Be Equal As Strings  ${resp.json()[1]['subject']}    Lead Location Updated

    Should Be Equal As Strings  ${resp.json()[2]['action']}    EDIT
    Should Be Equal As Strings  ${resp.json()[2]['category']}    LEAD
    Should Be Equal As Strings  ${resp.json()[2]['subCategory']}    	UPDATE_LEAD_ASSIGNEE
    Should Be Equal As Strings  ${resp.json()[2]['subject']}    Lead Assignee Updated
