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
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/hl_providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

***Test Cases***

JD-TC-CreateTeam-1

     [Documentation]  Create team at account level

     ${resp}=  Encrypted Provider Login  ${HLPUSERNAME6}  ${PASSWORD}
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

     ${resp}=  Get Team By Id  ${t_id1}
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Verify Response  ${resp}  id=${t_id1}  name=${team_name1}  size=0  description=${desc}  status=${status[0]}  users=[]

JD-TC-CreateTeam-2

     [Documentation]  Create multiple team at account level

     ${resp}=  Encrypted Provider Login  ${HLPUSERNAME8}  ${PASSWORD}
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
     Verify Response List  ${resp}  0  id=${t_id2}  name=${team_name2}  size=0  description=${desc2}  status=${status[0]}  users=[]
     Verify Response List  ${resp}  1  id=${t_id3}  name=${team_name3}  size=0  description=${desc3}  status=${status[0]}  users=[]

JD-TC-CreateTeam-3

     [Documentation]  Create team by user login with user type PROVIDER with admin privilage TRUE

     ${resp}=  Encrypted Provider Login  ${HLPUSERNAME8}  ${PASSWORD}
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

     ${resp}=  Get User
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200
     IF   not '${resp.content}' == '${emptylist}'
          ${len}=  Get Length  ${resp.json()}
          FOR   ${i}  IN RANGE   0   ${len}
               Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
               IF   not '${user_phone}' == '${HLPUSERNAME8}'
                    clear_users  ${user_phone}
               END
          END
     END

     ${resp2}=   Get Business Profile
     Log  ${resp2.json()}
     Should Be Equal As Strings    ${resp2.status_code}    200
     Set Suite Variable  ${sub_domain_id}  ${resp2.json()['serviceSubSector']['id']}

     ${PUSERNAME_U1}  ${u_id}=  Create and Configure Sample User  admin=${bool[1]}   deptId=${dep_id}
     Set Suite Variable  ${u_id}

     ${resp}=  Get User By Id  ${u_id}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${PUSERNAME_U1}  ${resp.json()['mobileNo']}

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

     ${resp}=  Encrypted Provider Login  ${HLPUSERNAME8}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${PUSERNAME_U5}  ${u_id3}=  Create and Configure Sample User  userType=${userType[2]}  deptId=${dep_id}

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

     ${resp}=  Encrypted Provider Login  ${HLPUSERNAME8}  ${PASSWORD}
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

     ${resp}=  Encrypted Provider Login  ${HLPUSERNAME8}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${PUSERNAME_U5}  ${u_id3}=  Create and Configure Sample User   userType=${userType[0]}  deptId=${dep_id}

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

     ${resp}=  Encrypted Provider Login  ${HLPUSERNAME8}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${resp}=  Create Team For User  ${team_name1}  ${EMPTY}  ${desc}
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     # Should Be Equal As Strings    ${resp.status_code}    422
     # Should Be Equal As Strings  "${resp.json()}"  "${TEAM_NAME_EXITS}"

JD-TC-CreateTeam-UH3

     [Documentation]  Create a team with empty team name

     ${resp}=  Encrypted Provider Login  ${HLPUSERNAME8}  ${PASSWORD}
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

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME8}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    #............provider consumer creation..........
    
    clear_customer   ${HLPUSERNAME8}

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

    ${resp}=  Create Team For User  ${team_name1}  ${EMPTY}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"