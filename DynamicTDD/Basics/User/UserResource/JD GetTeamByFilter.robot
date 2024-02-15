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
