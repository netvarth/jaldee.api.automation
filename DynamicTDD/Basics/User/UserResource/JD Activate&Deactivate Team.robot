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

JD-TC-Activate&DeactivateTeam-1

     [Documentation]  Deactivate a ACTIVE team at account level

     ${resp}=  Encrypted Provider Login  ${HLPUSERNAME10}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${team_name1}=  FakerLibrary.name
     Set Suite Variable  ${team_name1}
     ${desc}=   FakerLibrary.sentence
     Set Suite Variable  ${desc}
     ${resp}=  Create Team For User  ${team_name1}  ${empty}  ${desc}
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Set Suite Variable  ${t_id1}  ${resp.json()}

     ${resp}=  Activate&Deactivate Team  ${t_id1}  ${status[1]}
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${resp}=  Get Team By Id  ${t_id1}
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Verify Response  ${resp}  id=${t_id1}  name=${team_name1}  size=0  description=${desc}  status=${status[1]}  users=[]

JD-TC-Activate&DeactivateTeam-2

     [Documentation]  Activate a INACTIVE team at account level

     ${resp}=  Encrypted Provider Login  ${HLPUSERNAME10}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Activate&Deactivate Team  ${t_id1}  ${status[0]}
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${resp}=  Get Team By Id  ${t_id1}
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Verify Response  ${resp}  id=${t_id1}  name=${team_name1}  size=0  description=${desc}  status=${status[0]}  users=[]

JD-TC-Activate&DeactivateTeam-3

     [Documentation]  Deactivate  and activate a team by user login with user type PROVIDER with admin privilage TRUE

     ${resp}=  Encrypted Provider Login  ${HLPUSERNAME10}  ${PASSWORD}
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
     Set Suite Variable  ${sub_domain_id}  ${resp2.json()['serviceSubSector']['id']}
     
     ${PUSERNAME_U1}  ${u_id} =  Create and Configure Sample User    deptId=${dep_id}
     Set Suite Variable  ${u_id}

     ${team_name2}=  FakerLibrary.name
     ${desc2}=   FakerLibrary.sentence
     ${resp}=  Create Team For User  ${team_name2}  ${empty}  ${desc2}
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Set Suite Variable  ${t_id3}  ${resp.json()}
     ${resp}=  Activate&Deactivate Team  ${t_id3}  ${status[1]}
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Get Team By Id  ${t_id3}
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Verify Response  ${resp}  id=${t_id3}  name=${team_name2}  size=0  description=${desc2}  status=${status[1]}  users=[]
     ${resp}=  Activate&Deactivate Team  ${t_id3}  ${status[0]}
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Get Team By Id  ${t_id3}
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Verify Response  ${resp}  id=${t_id3}  name=${team_name2}  size=0  description=${desc2}  status=${status[0]}  users=[]

JD-TC-Activate&DeactivateTeam-4

     [Documentation]  Deactivate  and activate a team by user login with user type ADMIN

     ${resp}=  Encrypted Provider Login  ${HLPUSERNAME10}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${PUSERNAME_U5}  ${u_id} =  Create and Configure Sample User    admin=${bool[1]}   deptId=${dep_id}

     ${resp}=  Encrypted Provider Login  ${PUSERNAME_U5}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${team_name2}=  FakerLibrary.name
     ${desc2}=   FakerLibrary.sentence
     ${resp}=  Create Team For User  ${team_name2}  ${empty}  ${desc2}
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Set Suite Variable  ${t_id4}  ${resp.json()}

     ${resp}=  Activate&Deactivate Team  ${t_id4}  ${status[1]}
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${resp}=  Get Team By Id  ${t_id4}
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Verify Response  ${resp}  id=${t_id4}  name=${team_name2}  size=0  description=${desc2}  status=${status[1]}  users=[]
     ${resp}=  Activate&Deactivate Team  ${t_id4}  ${status[0]}
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Get Team By Id  ${t_id4}
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Verify Response  ${resp}  id=${t_id4}  name=${team_name2}  size=0  description=${desc2}  status=${status[0]}  users=[]

JD-TC-Activate&DeactivateTeam-UH1

     [Documentation]  Deactivate  and activate a team by user login with user type PROVIDER with admin privilage FALSE

     ${resp}=  Encrypted Provider Login  ${HLPUSERNAME10}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${PUSERNAME_U5}  ${u_id} =  Create and Configure Sample User    deptId=${dep_id}

     ${resp}=  Encrypted Provider Login  ${PUSERNAME_U5}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=  Activate&Deactivate Team  ${t_id4}  ${status[1]}
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    422
     Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION_TO_ENABLE_DISABLE_TEAM}"
     ${resp}=  Activate&Deactivate Team  ${t_id4}  ${status[0]}
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    422
     Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION_TO_ENABLE_DISABLE_TEAM}"

JD-TC-Activate&DeactivateTeam-UH2

     [Documentation]  Activate a ACTIVE team

     ${resp}=  Encrypted Provider Login  ${HLPUSERNAME10}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Activate&Deactivate Team  ${t_id3}  ${status[0]}
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    422
     Should Be Equal As Strings  "${resp.json()}"  "${TEAM_ALREADY_ENABLED}"

JD-TC-Activate&DeactivateTeam-UH3

     [Documentation]  Deactivate a INACTIVE a team

     ${resp}=  Encrypted Provider Login  ${HLPUSERNAME10}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Activate&Deactivate Team  ${t_id3}  ${status[1]}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Activate&Deactivate Team  ${t_id3}  ${status[1]}
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    422
     Should Be Equal As Strings  "${resp.json()}"  "${TEAM_ALREADY_DISABLED}"

JD-TC-Activate&DeactivateTeam -UH4

     [Documentation]   create team without login  

     ${resp}=  Activate&Deactivate Team  ${t_id3}  ${status[1]}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  419
     Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}"
 
JD-TC-Activate&DeactivateTeam -UH5

    [Documentation]   Consumer get a user

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME10}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    #............provider consumer creation..........
    
    clear_customer   ${HLPUSERNAME10}

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

    ${resp}=  Activate&Deactivate Team  ${t_id3}  ${status[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"

