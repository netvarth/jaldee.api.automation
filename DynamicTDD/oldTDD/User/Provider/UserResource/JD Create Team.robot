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
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/hl_providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

***Test Cases***

JD-TC-CreateTeam-1

     [Documentation]  Create team at account level

     ${resp}=  Encrypted Provider Login  ${HLPUSERNAME6}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
    
     # ${pkg_id}=   get_highest_license_pkg
     # ${resp}=  Change License Package  ${pkgid[0]}
     # Should Be Equal As Strings    ${resp.status_code}   200
     
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

     ${resp}=  Get Team By Id  ${t_id1}
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Verify Response  ${resp}  id=${t_id1}  name=${team_name1}  size=0  description=${desc}  status=${status[0]}  users=[]

JD-TC-CreateTeam-2
     [Documentation]  Create multiple team at account level
     ${resp}=  Encrypted Provider Login  ${PUSERNAME60}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${team_name2}=  FakerLibrary.name
     ${desc2}=   FakerLibrary.sentence
     ${resp}=  Create Team For User  ${team_name2}  ${EMPTY}  ${desc2}
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Set Suite Variable  ${t_id2}  ${resp.json()}
     ${team_name3}=  FakerLibrary.name
     ${desc3}=   FakerLibrary.sentence
     ${resp}=  Create Team For User  ${team_name3}  ${EMPTY}  ${desc3} 
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Set Suite Variable  ${t_id3}  ${resp.json()}
     sleep  02s
     ${resp}=  Get Teams
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Verify Response List  ${resp}  0  id=${t_id1}  name=${team_name1}  size=0  description=${desc}  status=${status[0]}  users=[]
     Verify Response List  ${resp}  1  id=${t_id2}  name=${team_name2}  size=0  description=${desc2}  status=${status[0]}  users=[]
     Verify Response List  ${resp}  2  id=${t_id3}  name=${team_name3}  size=0  description=${desc3}  status=${status[0]}  users=[]

JD-TC-CreateTeam-3
     [Documentation]  Create team by user login with user type PROVIDER with admin privilage TRUE
     ${resp}=  Encrypted Provider Login  ${PUSERNAME60}  ${PASSWORD}
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
     ${resp}=  Create Team For User  ${team_name2}  ${EMPTY}  ${desc2}
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Set Suite Variable  ${t_id3}  ${resp.json()}
     ${resp}=  Get Team By Id  ${t_id3}
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Verify Response  ${resp}  id=${t_id3}  name=${team_name2}  size=0  description=${desc2}  status=${status[0]}  users=[]

JD-TC-CreateTeam-4
     [Documentation]  Create team by user login with user type ADMIN
     ${resp}=  Encrypted Provider Login  ${PUSERNAME60}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${PUSERNAME_U5}=  Evaluate  ${PUSERNAME}+330061
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
     ${resp}=  Create Team For User  ${team_name2}  ${EMPTY}  ${desc2}
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Set Suite Variable  ${t_id4}  ${resp.json()}
     ${resp}=  Get Team By Id  ${t_id4}
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Verify Response  ${resp}  id=${t_id4}  name=${team_name2}  size=0  description=${desc2}  status=${status[0]}  users=[]

JD-TC-CreateTeam-5
     [Documentation]  Create a team with empty team desc
     ${resp}=  Encrypted Provider Login  ${PUSERNAME60}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${team_name2}=  FakerLibrary.name
     ${resp}=  Create Team For User  ${team_name2}  ${EMPTY}  ${EMPTY}
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Set Suite Variable  ${t_id4}  ${resp.json()}
     ${resp}=  Get Team By Id  ${t_id4}
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Verify Response  ${resp}  id=${t_id4}  name=${team_name2}  size=0  description=${EMPTY}  status=${status[0]}  users=[]

JD-TC-CreateTeam-UH1
     [Documentation]  Create team by user login with user type PROVIDER with admin privilage FALSE
     ${resp}=  Encrypted Provider Login  ${PUSERNAME60}  ${PASSWORD}
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
     ${team_name2}=  FakerLibrary.name
     ${desc2}=   FakerLibrary.sentence
     ${resp}=  Create Team For User  ${team_name2}  ${EMPTY}  ${desc2}
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    422
     Should Be Equal As Strings  "${resp.json()}"  "${CANNOT_CREATE_TEAM}"

JD-TC-CreateTeam-UH2
     [Documentation]  Create a team with existing team name
     ${resp}=  Encrypted Provider Login  ${PUSERNAME60}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Create Team For User  ${team_name1}  ${EMPTY}  ${desc}
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    422
     Should Be Equal As Strings  "${resp.json()}"  "${TEAM_NAME_EXITS}"

JD-TC-CreateTeam-UH3
     [Documentation]  Create a team with empty team name
     ${resp}=  Encrypted Provider Login  ${PUSERNAME60}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${desc2}=   FakerLibrary.sentence
     ${resp}=  Create Team For User  ${EMPTY}  ${EMPTY}  ${desc2}
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    422
     Should Be Equal As Strings  "${resp.json()}"  "${TEAM_NAME_REQ}"

JD-TC-CreateTeam -UH5
     [Documentation]   create team without login      
     ${resp}=  Create Team For User  ${team_name1}  ${EMPTY}  ${desc}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  419
     Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}"
 
JD-TC-CreateTeam -UH6
    [Documentation]   Consumer get a user
    ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Create Team For User  ${team_name1}  ${EMPTY}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"