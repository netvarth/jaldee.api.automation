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

JD-TC-ChangeLeadManager-1

    [Documentation]  Create a lead and verify the default manager.

    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Suite Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Suite Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
    ${firstname_A}=  FakerLibrary.first_name
    Set Suite Variable  ${firstname_A}
    ${lastname_A}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname_A}
    ${MUSERNAME_E}=  Evaluate  ${MUSERNAME}+550277
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
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${MUSERNAME_E}${\n}
    Set Suite Variable  ${MUSERNAME_E}

    ${lid2}=  Create Sample Location
    Set Suite Variable  ${lid2}
   
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
    ${PUSERNAME_U4}=  Evaluate  ${PUSERNAME}+3366478
    clear_users  ${PUSERNAME_U4}
    Set Suite Variable  ${PUSERNAME_U4}
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

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U4}.ynwtest@netvarth.com   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERNAME_U4}  ${dep_id}  ${EMPTY}  ${bool[0]}  ${countryCodes[1]}  ${whpnum}  ${countryCodes[1]}  ${tlgnum}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id}  ${resp.json()}

    ${resp}=  Get User By Id  ${u_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SendProviderResetMail   ${PUSERNAME_U4}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${PUSERNAME_U4}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id1}  ${resp.json()['id']}

    ${resp}=   enquiryStatus  ${account_id1}
    ${resp}=   leadStatus     ${account_id1}
    ${resp}=   categorytype   ${account_id1}
    ${resp}=   tasktype       ${account_id1}

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

    ${resp}=  AddCustomer  ${CUSERNAME3}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME3}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable  ${pcons_id3}  ${resp.json()[0]['id']}
    Set Test Variable  ${jaldeeId}  ${resp.json()[0]['jaldeeId']}

    ${resp}=    Create Lead    ${title}    ${desc}    ${targetPotential}      ${locId}    ${pcons_id3}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${leUid1}        ${resp.json()['uid']}

    ${resp}=    Get Leads With Filter    manager-eq=${account_id1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()}    []

JD-TC-ChangeLeadManager-2

    [Documentation]  Create a lead to a user and change the manager then verify.

    
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${PUSERNAME_U2}=  Evaluate  ${PUSERNAME}+3366466
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

    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${PUSERNAME_U3}=  Evaluate  ${PUSERNAME}+3369464
    clear_users  ${PUSERNAME_U3}
    Set Suite Variable  ${PUSERNAME_U3}
    clear_users  ${PUSERNAME_U3}
    Set Suite Variable  ${PUSERNAME_U3}
    ${firstname1}=  FakerLibrary.name
    Set Suite Variable  ${firstname}
    ${lastname1}=  FakerLibrary.last_name
    
    ${whpnum}=  Evaluate  ${PUSERNAME}+346865
    ${tlgnum}=  Evaluate  ${PUSERNAME}+346385

    ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U3}.ynwtest@netvarth.com   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERNAME_U3}  ${dep_id}  ${EMPTY}  ${bool[0]}  ${countryCodes[1]}  ${whpnum}  ${countryCodes[1]}  ${tlgnum}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id2}  ${resp.json()}

    ${resp}=  Get User By Id  ${u_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SendProviderResetMail   ${PUSERNAME_U3}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${PUSERNAME_U3}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U4}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${locId}=  Create Sample Location

    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 
    ${targetPotential}=    FakerLibrary.Building Number
    ${manager}=    Create Dictionary   id=${u_id}

    ${resp}=    Create Lead    ${title}    ${desc}    ${targetPotential}      ${locId}    ${pcons_id3}   manager=${manager}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${leid}        ${resp.json()['id']}
    Set Suite Variable   ${leUid2}        ${resp.json()['uid']}

    ${resp}=    Get Leads With Filter    manager-eq=${account_id1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Change Lead Manager    ${leUid2}    ${u_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.json()}     ${bool[1]}

    sleep  02s
    ${resp}=    Get Leads With Filter    id-eq=${leid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['manager']['id']}          ${u_id1}


JD-TC-ChangeLeadManager-3

    [Documentation]  Change lead manager multiple times.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Change Lead Manager    ${leUid2}    ${u_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.json()}     ${bool[1]}

    ${resp}=    Change Lead Manager    ${leUid2}    ${u_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.json()}     ${bool[1]}

    ${resp}=    Change Lead Manager    ${leUid2}    ${u_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.json()}     ${bool[1]}
    sleep  02s
    ${resp}=    Get Leads With Filter    uid-eq=${leUid2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['manager']['id']}    ${u_id1}

JD-TC-ChangeLeadManager-UH1

    [Documentation]  Change lead manager with another branch's user id

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME21}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Toggle Department Enable
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${u_id4}=    Create Sample User    

    ${resp}=    Provider Logout
    Log  ${resp.content}  
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Change Lead Manager    ${leUid2}    ${u_id4}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.json()}     ${INVALID_MANAGER_ID}

    # ${resp}=    Get Leads With Filter    manager-eq=${u_id1}
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings  ${resp.json()[0]['manager']['id']}    ${u_id1}


JD-TC-ChangeLeadManager-UH2

    [Documentation]  Change lead manager with already assigned user id.

    ${resp}=  Encrypted Provider Login   ${PUSERNAME_U4}   ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Change Lead Manager    ${leUid2}    ${u_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.json()}    ${ALREADY_UPDATED}





JD-TC-ChangeLeadManager-4

    [Documentation]  Change lead manager after update the lead with an manager.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

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

    ${p_id1}=  get_acc_id  ${MUSERNAME_E}
    Set Suite Variable    ${p_id1}

    ${resp}=  categorytype  ${p_id1}
    ${resp}=  tasktype      ${p_id1}
    ${resp}=    Get Lead Category Type
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${Category_id}    ${resp.json()[1]['id']}
    Set Suite Variable  ${Category_id1}    ${resp.json()[1]['id']}
    Set Suite Variable  ${Category_id2}    ${resp.json()[2]['id']}
    # Set Suite Variable  ${priority_id3}    ${resp.json()[3]['id']}
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
    Set Suite Variable  ${status_id}    ${resp.json()[0]['id']}
    Set Suite Variable  ${status_id1}    ${resp.json()[1]['id']}
    Set Suite Variable  ${status_id2}    ${resp.json()[2]['id']}
    Set Suite Variable  ${status_id3}    ${resp.json()[3]['id']}
    Set Suite Variable  ${status_id4}    ${resp.json()[4]['id']}
    Set Suite Variable  ${status_id5}    ${resp.json()[5]['id']}
    Set Suite Variable  ${status_name2}  ${resp.json()[0]['name']}

    ${resp}=    Get Lead Priority
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${priority_id}    ${resp.json()[0]['id']}
    Set Suite Variable  ${priority_id1}    ${resp.json()[1]['id']}
    Set Suite Variable  ${priority_id2}    ${resp.json()[2]['id']}
    Set Suite Variable  ${priority_id3}    ${resp.json()[3]['id']}
    Set Suite Variable  ${priority_name2}  ${resp.json()[0]['name']}

    ${manager}=    Create Dictionary    id=${u_id1}

    ${resp}=    Update Lead    ${leUid2}    ${title1}    ${desc1}    ${status_id1}      ${priority_id}    ${lid2}    ${pcons_id3}    ${u_id}    manager=${manager}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Change Lead Manager    ${leUid2}    ${u_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.json()}     ${bool[1]}




JD-TC-ChangeLeadManager-5

    [Documentation]  update the lead with a assignee and change the manager with that assignee id.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Update Lead    ${leUid2}    ${title1}    ${desc1}    ${status_id1}      ${priority_id}    ${lid2}    ${pcons_id3}    ${u_id2}    
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Change Lead Manager    ${leUid2}    ${u_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.json()}     ${bool[1]}

JD-TC-ChangeLeadManager-UH3

    [Documentation]  Change lead manager without login.

    ${resp}=    Change Lead Manager    ${leUid2}    ${u_id1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"


JD-TC-ChangeLeadManager-UH4

    [Documentation]  Change lead manager with consumer login.

    ${resp}=  Consumer Login  ${CUSERNAME17}  ${PASSWORD}
    Log   ${resp.content}
    ${resp}=    Change Lead Manager    ${leUid2}    ${u_id1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings  "${resp.json()}"   "${NoAccess}"

JD-TC-ChangeLeadManager-UH5

    [Documentation]  Change lead manager after canceled the lead.


    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${p_id}=  get_acc_id  ${MUSERNAME_E}

    ${resp}=  categorytype  ${p_id}
    ${resp}=  tasktype      ${p_id}
    ${resp}=    Get Lead Status
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${status_id1}    ${resp.json()[3]['id']}
    Set Suite Variable  ${status_name1}  ${resp.json()[3]['name']}

    

    # ${locId}=  Create Sample Location
    ${title}=  FakerLibrary.user name
    ${title1}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 
    ${targetPotential}=    FakerLibrary.Building Number
    ${status}=  Create Dictionary   id=${status_id1}
    Set Suite Variable    ${status}

    ${resp}=    Create Lead    ${title}    ${desc}    ${targetPotential}      ${locId}    ${pcons_id3}   status=${status}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${leid5}        ${resp.json()['id']}
    Set Suite Variable   ${leUid5}        ${resp.json()['uid']}

    ${resp}=    Change Lead Manager    ${leUid5}    ${u_id}
    Log  ${resp.content}

*** comment ***
JD-TC-ChangeLeadManager-

    [Documentation]  Change lead manager after closed the lead.

    ${resp}=  Encrypted Provider Login  ${MUSERNAME80}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200