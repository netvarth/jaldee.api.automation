***Settings***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        User
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/hl_providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

***Test Cases***

JD-TC-UpdateTeam-1
     [Documentation]  Update team at account level
     ${resp}=  Encrypted Provider Login  ${HLPUSERNAME9}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${team_name1}=  FakerLibrary.name
     Set Suite Variable  ${team_name1}
     ${team_size1}=  Random Int  min=10  max=50
     Set Suite Variable  ${team_size1}
     ${desc}=   FakerLibrary.sentence
     Set Suite Variable  ${desc}
     ${resp}=  Create Team For User  ${team_name1}  ${team_size1}  ${desc}
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Set Suite Variable  ${t_id1}  ${resp.json()}

     ${team_name_a1}=  FakerLibrary.name
     Set Suite Variable  ${team_name_a1}
     ${team_size_a}=  Random Int  min=10  max=50
     Set Suite Variable  ${team_size_a}
     ${desc_a}=   FakerLibrary.sentence
     Set Suite Variable  ${desc_a}

     ${resp}=  Update Team For User  ${t_id1}  ${team_name_a1}  ${team_size_a}  ${desc_a}
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${resp}=  Get Team By Id  ${t_id1}
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Verify Response  ${resp}  id=${t_id1}  name=${team_name_a1}  size=0  description=${desc_a}  status=${status[0]}  users=[]

JD-TC-UpdateTeam-2
     [Documentation]  Update team by user login with user type PROVIDER with admin privilage TRUE
     ${resp}=  Encrypted Provider Login  ${HLPUSERNAME9}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

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
     ${resp2}=   Get Business Profile
    Log  ${resp2.json()}
    Should Be Equal As Strings    ${resp2.status_code}    200
    Set Suite Variable  ${sub_domain_id}  ${resp2.json()['serviceSubSector']['id']}
     ${u_id}=  Create Sample User  admin=${bool[1]}
     Set Suite Variable  ${u_id}
    ${resp}=  SendProviderResetMail   ${PUSERNAME_U1}
    Should Be Equal As Strings  ${resp.status_code}  200
    @{resp}=  ResetProviderPassword  ${PUSERNAME_U1}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
     ${team_name2}=  FakerLibrary.name
     ${desc2}=   FakerLibrary.sentence
     ${resp}=  Create Team For User  ${team_name2}  ${empty}  ${desc2}
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Set Suite Variable  ${t_id2}  ${resp.json()}

     ${team_name_a}=  FakerLibrary.name
     Set Suite Variable  ${team_name_a}
     ${desc_a}=   FakerLibrary.sentence
     Set Suite Variable  ${desc_a}

     ${resp}=  Update Team For User  ${t_id2}  ${team_name_a}  ${empty}  ${desc_a}
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${resp}=  Get Team By Id  ${t_id2}
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Verify Response  ${resp}  id=${t_id2}  name=${team_name_a}  size=0  description=${desc_a}  status=${status[0]}  users=[]

JD-TC-UpdateTeam-3
     [Documentation]  Update team by user login with user type ADMIN
     ${resp}=  Encrypted Provider Login  ${HLPUSERNAME9}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${PUSERNAME_U5}=  Evaluate  ${PUSERNAME}+330064
    clear_users  ${PUSERNAME_U5}
    ${firstname3}=  FakerLibrary.name
    ${lastname3}=  FakerLibrary.last_name
    ${address3}=  get_address
    ${dob3}=  FakerLibrary.Date
    # ${pin3}=  get_pincode
     # ${resp}=  Get LocationsByPincode     ${pin3}
     FOR    ${i}    IN RANGE    3
        ${pin3}=  get_pincode
        ${kwstatus}  ${resp} =  Run Keyword And Ignore Error  Get LocationsByPincode  ${pin3}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
     END
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${city3}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Test Variable  ${state3}  ${resp.json()[0]['PostOffice'][0]['State']}      
    Set Test Variable  ${pin3}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    
 
    ${resp}=  Create User  ${firstname3}  ${lastname3}  ${dob3}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U5}.${test_mail}   ${userType[2]}  ${pin3}  ${countryCodes[0]}  ${PUSERNAME_U5}  ${dep_id}  ${sub_domain_id}  ${bool[0]}   ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id3}  ${resp.json()}

    ${resp}=  SendProviderResetMail   ${PUSERNAME_U5}
    Should Be Equal As Strings  ${resp.status_code}  200
    @{resp}=  ResetProviderPassword  ${PUSERNAME_U5}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
     ${team_name2}=  FakerLibrary.name
     ${desc2}=   FakerLibrary.sentence
     ${resp}=  Create Team For User  ${team_name2}  ${empty}  ${desc2}
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Set Suite Variable  ${t_id4}  ${resp.json()}

     ${team_name_a}=  FakerLibrary.name
     Set Suite Variable  ${team_name_a}
     ${desc_a}=   FakerLibrary.sentence
     Set Suite Variable  ${desc_a}

     ${resp}=  Update Team For User  ${t_id4}  ${team_name_a}  ${empty}  ${desc_a}
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${resp}=  Get Team By Id  ${t_id4}
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Verify Response  ${resp}  id=${t_id4}  name=${team_name_a}  size=0  description=${desc_a}  status=${status[0]}  users=[]

JD-TC-UpdateTeam-UH1
     [Documentation]  Create team by user login with user type PROVIDER with admin privilage FALSE
     ${resp}=  Encrypted Provider Login  ${HLPUSERNAME9}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${PUSERNAME_U5}=  Evaluate  ${PUSERNAME}+330098
    clear_users  ${PUSERNAME_U5}
    ${firstname3}=  FakerLibrary.name
    ${lastname3}=  FakerLibrary.last_name
    ${address3}=  get_address
    ${dob3}=  FakerLibrary.Date
    # ${pin3}=  get_pincode
     # ${resp}=  Get LocationsByPincode     ${pin3}
     FOR    ${i}    IN RANGE    3
        ${pin3}=  get_pincode
        ${kwstatus}  ${resp} =  Run Keyword And Ignore Error  Get LocationsByPincode  ${pin3}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
     END
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${city3}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Test Variable  ${state3}  ${resp.json()[0]['PostOffice'][0]['State']}      
    Set Test Variable  ${pin3}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    
 
    ${resp}=  Create User  ${firstname3}  ${lastname3}  ${dob3}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U5}.${test_mail}   ${userType[0]}  ${pin3}  ${countryCodes[0]}  ${PUSERNAME_U5}  ${dep_id}  ${sub_domain_id}  ${bool[0]}   ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id3}  ${resp.json()}

    ${resp}=  SendProviderResetMail   ${PUSERNAME_U5}
    Should Be Equal As Strings  ${resp.status_code}  200
    @{resp}=  ResetProviderPassword  ${PUSERNAME_U5}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=  Update Team For User  ${t_id4}  ${team_name_a}  ${empty}  ${desc_a}
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    422
     Should Be Equal As Strings  "${resp.json()}"  "${CANNOT_UPDATE_TEAM}"

JD-TC-UpdateTeam-UH2
     [Documentation]  Update a team with existing team name
     ${resp}=  Encrypted Provider Login  ${HLPUSERNAME9}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Update Team For User  ${t_id4}  ${team_name_a1}  ${empty}  ${desc_a}
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    422
     Should Be Equal As Strings  "${resp.json()}"  "${TEAM_NAME_EXITS}"

JD-TC-UpdateTeam-UH4
     [Documentation]  Update a team with empty team name
     ${resp}=  Encrypted Provider Login  ${HLPUSERNAME9}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${desc2}=   FakerLibrary.sentence
     ${resp}=  Update Team For User  ${t_id4}  ${empty}  ${empty}  ${desc_a}
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    422
     Should Be Equal As Strings  "${resp.json()}"  "${TEAM_NAME_REQ}"

JD-TC-UpdateTeam -UH5
     [Documentation]   Update team without login      
     ${resp}=  Update Team For User  ${t_id4}  ${empty}  ${empty}  ${desc_a}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  419
     Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}"
 
JD-TC-UpdateTeam -UH6
    [Documentation]   Consumer get a user
    ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Update Team For User  ${t_id4}  ${empty}  ${empty}  ${desc_a}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-UpdateTeam-UH7
     [Documentation]  Upadte a team with invalid team id
     ${resp}=  Encrypted Provider Login  ${HLPUSERNAME9}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${desc2}=   FakerLibrary.sentence
     ${resp}=  Update Team For User  000  ${empty}  ${empty}  ${desc_a}
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    422
     Should Be Equal As Strings  "${resp.json()}"  "${TEAM_NAME_REQ}"
