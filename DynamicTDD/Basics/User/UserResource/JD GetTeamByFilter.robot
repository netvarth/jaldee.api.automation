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
Variables         /ebs/TDD/varfiles/musers.py
Variables         /ebs/TDD/varfiles/hl_musers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

*** Keywords ***
Get Team By Filter
    [Arguments]  &{kwargs}
    Check And Create YNW Session
    ${resp}=    GET On Session     ynw   /provider/user/teams   params=${kwargs}  expected_status=any
    RETURN  ${resp}


***Test Cases***

JD-TC-GetTeamByFilter-1

     [Documentation]  Create team at account level and Get Team By Filter- (status-eq).

    #  ${resp}=  Provider Login  ${HLMUSERNAME6}  ${PASSWORD}
    #  Log  ${resp.json()}
    #  Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login    ${HLMUSERNAME6}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    
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

     ${resp}=  Get Team By Filter    status-eq=${status[0]}
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Should Be Equal As Strings    ${resp.json()[0]['id']}   ${t_id1}
     Should Be Equal As Strings    ${resp.json()[0]['name']}   ${team_name1}
     Should Be Equal As Strings    ${resp.json()[0]['description']}   ${desc}
     Should Be Equal As Strings    ${resp.json()[0]['status']}   ${status[0]}

JD-TC-GetTeamByFilter-2

    [Documentation]  Create team at account level and Get Team By Filter- (id-eq).

    ${resp}=  Encrypted Provider Login    ${HLMUSERNAME6}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=  Get Team By Filter    id-eq=${t_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['id']}   ${t_id1}
    Should Be Equal As Strings    ${resp.json()[0]['name']}   ${team_name1}
    Should Be Equal As Strings    ${resp.json()[0]['description']}   ${desc}
    Should Be Equal As Strings    ${resp.json()[0]['status']}   ${status[0]}

JD-TC-GetTeamByFilter-3

    [Documentation]  Create team at account level and Get Team By Filter- (name-eq).

    ${resp}=  Encrypted Provider Login    ${HLMUSERNAME6}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=  Get Team By Filter    name-eq=${team_name1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['id']}   ${t_id1}
    Should Be Equal As Strings    ${resp.json()[0]['name']}   ${team_name1}
    Should Be Equal As Strings    ${resp.json()[0]['description']}   ${desc}
    Should Be Equal As Strings    ${resp.json()[0]['status']}   ${status[0]}

JD-TC-GetTeamByFilter-4

    [Documentation]  Create team at account level and Get Team By Filter- (size-eq).

    ${resp}=  Encrypted Provider Login    ${HLMUSERNAME6}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=  Get Team By Filter    size-eq=-0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()[0]['id']}   ${t_id1}
     Should Be Equal As Strings    ${resp.json()[0]['name']}   ${team_name1}
     Should Be Equal As Strings    ${resp.json()[0]['description']}   ${desc}
     Should Be Equal As Strings    ${resp.json()[0]['status']}   ${status[0]}

JD-TC-GetTeamByFilter-5

    [Documentation]  Create another team at account level and Get Team By Filter- (status-eq).

    ${resp}=  Encrypted Provider Login    ${HLMUSERNAME6}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

     ${team_name2}=  FakerLibrary.name
     Set Suite Variable  ${team_name2}
     ${team_size2}=  Random Int  min=10  max=50
     Set Suite Variable  ${team_size2}
     ${desc}=   FakerLibrary.sentence
     Set Suite Variable  ${desc}
     ${resp}=  Create Team For User  ${team_name2}  ${team_size2}  ${desc}
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Set Suite Variable  ${t_id2}  ${resp.json()}

     ${resp}=  Get Team By Id  ${t_id2}
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Verify Response  ${resp}  id=${t_id2}  name=${team_name2}  size=0  description=${desc}  status=${status[0]}  users=[]

    ${resp}=  Get Team By Filter    status-eq=${status[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['id']}   ${t_id2}

JD-TC-GetTeamByFilter-6

    [Documentation]  User try to create team (admin is true)

    ${resp}=  Encrypted Provider Login    ${HLMUSERNAME6}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id1}  ${resp.json()['id']}
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END

    ${resp}=  Get Departments
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${dep_name1}=  FakerLibrary.bs
        ${dep_code1}=   Random Int  min=100   max=999
        ${dep_desc1}=   FakerLibrary.word  
        ${resp1}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${dep_id}  ${resp1.json()}
    ELSE
        Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    END

    ${u_id}=  Create Sample User   admin=${bool[1]}
    Set Test Variable  ${u_id}

    ${resp}=  Get User By Id  ${u_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${BUSER_U1}  ${resp.json()['mobileNo']}

    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  SendProviderResetMail   ${BUSER_U1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${BUSER_U1}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${BUSER_U1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${team_name2}=  FakerLibrary.name
     Set Suite Variable  ${team_name2}
     ${team_size2}=  Random Int  min=10  max=50
     Set Suite Variable  ${team_size2}
     ${desc}=   FakerLibrary.sentence
     Set Suite Variable  ${desc}
     ${resp}=  Create Team For User  ${team_name2}  ${team_size2}  ${desc}
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Set Suite Variable  ${t_id2}  ${resp.json()}

     ${resp}=  Get Team By Id  ${t_id2}
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Verify Response  ${resp}  id=${t_id2}  name=${team_name2}  size=0  description=${desc}  status=${status[0]}  users=[]

JD-TC-GetTeamByFilter-UH1

    [Documentation]  User try to create team (admin is false)

    ${resp}=  Encrypted Provider Login    ${HLMUSERNAME6}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${u_id}=  Create Sample User   admin=${bool[0]}
    Set Test Variable  ${u_id}

    ${resp}=  Get User By Id  ${u_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${BUSER_U1}  ${resp.json()['mobileNo']}

    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  SendProviderResetMail   ${BUSER_U1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${BUSER_U1}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${BUSER_U1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${team_name2}=  FakerLibrary.name
    Set Suite Variable  ${team_name2}
    ${team_size2}=  Random Int  min=10  max=50
    Set Suite Variable  ${team_size2}
    ${desc}=   FakerLibrary.sentence
    Set Suite Variable  ${desc}
    ${resp}=  Create Team For User  ${team_name2}  ${team_size2}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${CANNOT_CREATE_TEAM}

JD-TC-GetTeamByFilter-UH2

    [Documentation]   Get Team user By Id without login.

    ${resp}=  Get Team By Filter    status-eq=${status[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}    ${SESSION_EXPIRED}

JD-TC-GetTeamByFilter-UH3

    [Documentation]   Get Team user By Id without login.

    ${resp}=   Consumer Login  ${CUSERNAME4}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Team By Filter    status-eq=${status[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings    ${resp.json()}    ${NoAccess}




