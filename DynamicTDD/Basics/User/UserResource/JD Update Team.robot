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
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
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

     ${resp}=  Get Waitlist Settings
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200
     IF  ${resp.json()['filterByDept']}==${bool[0]}
          ${resp}=  Enable Disable Department  ${toggle[0]}
          Log  ${resp.content}
          Should Be Equal As Strings  ${resp.status_code}  200
     END

     ${resp}=  Get Departments
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}

     ${resp2}=   Get Business Profile
     Log  ${resp2.json()}
     Should Be Equal As Strings    ${resp2.status_code}    200
     Set Suite Variable  ${sub_domain_id}  ${resp2.json()['serviceSubSector']['id']}

     ${PUSERNAME_U1}  ${u_id} =  Create and Configure Sample User   admin=${bool[1]}   deptId=${dep_id}
     Set Suite Variable  ${u_id}

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

     ${resp}=  Create User  ${firstname3}  ${lastname3}  ${countryCodes[0]}  ${PUSERNAME_U5}   ${userType[0]}    admin=${bool[1]}  deptId=${dep_id}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${u_id3}  ${resp.json()}

     ${resp}=   Configure Sample User    ${u_id3}   ${PUSERNAME_U5}

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

     ${resp}=  Create User  ${firstname3}  ${lastname3}  ${countryCodes[0]}  ${PUSERNAME_U5}   ${userType[0]}  deptId=${dep_id}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${u_id3}  ${resp.json()}

     ${resp}=   Configure Sample User    ${u_id3}   ${PUSERNAME_U5}

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

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME9}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    #............provider consumer creation..........
    
    clear_customer   ${HLPUSERNAME9}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${acc_id1}  ${resp.json()['id']}

    ${PH_Number}=  FakerLibrary.Numerify  %#####
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Test Variable  ${PCPHONENO}  555${PH_Number}

    ${fname}=  generate_firstname
    ${lastname}=  FakerLibrary.last_name
    ${resp}=  AddCustomer  ${PCPHONENO}    firstName=${fname}   lastName=${lastname}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${PCPHONENO}    ${acc_id1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}
    
    ${resp}=    ProviderConsumer Login with token   ${PCPHONENO}    ${acc_id1}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

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
