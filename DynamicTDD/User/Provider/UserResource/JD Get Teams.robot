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
Variables         /ebs/TDD/varfiles/hl_musers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

***Test Cases***

JD-TC-GetTeams-1
     [Documentation]  Get teams at account level
     ${resp}=  Provider Login  ${HLMUSERNAME8}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${team_name1}=  FakerLibrary.name
     Set Suite Variable  ${team_name1}
     ${desc}=   FakerLibrary.sentence
     Set Suite Variable  ${desc}
     ${resp}=  Create Team For User  ${team_name1}  ${EMPTY}  ${desc}
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Set Suite Variable  ${t_id1}  ${resp.json()}

     ${team_name2}=  FakerLibrary.name
     Set Suite Variable  ${team_name2}
     ${resp}=  Create Team For User  ${team_name2}  ${EMPTY}  ${desc}
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Set Suite Variable  ${t_id2}  ${resp.json()}
     ${team_name3}=  FakerLibrary.name
     Set Suite Variable  ${team_name3}
     ${resp}=  Create Team For User  ${team_name3}  1  ${desc}
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Set Suite Variable  ${t_id3}  ${resp.json()}

     ${resp}=  Get Teams
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Verify Response List  ${resp}  0  id=${t_id1}  name=${team_name1}  size=0  description=${desc}  status=${status[0]}  users=[]
     Verify Response List  ${resp}  1  id=${t_id2}  name=${team_name2}  size=0  description=${desc}  status=${status[0]}  users=[]
     Verify Response List  ${resp}  2  id=${t_id3}  name=${team_name3}  size=0  description=${desc}  status=${status[0]}  users=[]

JD-TC-GetTeams-2
     [Documentation]  Get team by id by user who has usertype PROVIDER and admin privilage TRUE
     ${resp}=  Provider Login  ${HLMUSERNAME8}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${resp}=  View Waitlist Settings
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${resp}=  Run Keyword If  ${resp.json()['filterByDept']}==${bool[0]}   Toggle Department Enable
     Run Keyword If  '${resp}' != '${None}'   Log   ${resp.json()}
     Run Keyword If  '${resp}' != '${None}'   Should Be Equal As Strings  ${resp.status_code}  200

     sleep  2s
     ${resp}=  Get Departments
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
     ${resp2}=   Get Business Profile
     Log  ${resp2.json()}
     Should Be Equal As Strings    ${resp2.status_code}    200
     Set Suite Variable  ${sub_domain_id}  ${resp2.json()['serviceSubSector']['id']}
     ${u_id}=  Create Sample User
     Set Suite Variable  ${u_id}
     ${resp}=  Get User By Id  ${u_id}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${PUSERNAME_U1}  ${resp.json()['mobileNo']}
     ${resp}=  SendProviderResetMail   ${PUSERNAME_U1}
     Should Be Equal As Strings  ${resp.status_code}  200
     @{resp}=  ResetProviderPassword  ${PUSERNAME_U1}  ${PASSWORD}  2
     Should Be Equal As Strings  ${resp[0].status_code}  200
     Should Be Equal As Strings  ${resp[1].status_code}  200
     ${resp}=  ProviderLogin  ${PUSERNAME_U1}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=  Get Teams
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Verify Response List  ${resp}  0  id=${t_id1}  name=${team_name1}  size=0  description=${desc}  status=${status[0]}  users=[]
     Verify Response List  ${resp}  1  id=${t_id2}  name=${team_name2}  size=0  description=${desc}  status=${status[0]}  users=[]
     Verify Response List  ${resp}  2  id=${t_id3}  name=${team_name3}  size=0  description=${desc}  status=${status[0]}  users=[]

JD-TC-GetTeams-3
     [Documentation]  Get team by id by  user login with user type ADMIN
     ${resp}=  Provider Login  ${HLMUSERNAME8}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${PUSERNAME_U5}=  Evaluate  ${PUSERNAME}+330063
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
 
    ${resp}=  Create User  ${firstname3}  ${lastname3}  ${dob3}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U5}.ynwtest@netvarth.com   ${userType[2]}  ${pin3}  ${countryCodes[0]}  ${PUSERNAME_U5}  ${dep_id}  ${sub_domain_id}  ${bool[0]}   ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id3}  ${resp.json()}

    ${resp}=  SendProviderResetMail   ${PUSERNAME_U5}
    Should Be Equal As Strings  ${resp.status_code}  200
    @{resp}=  ResetProviderPassword  ${PUSERNAME_U5}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200
    ${resp}=  ProviderLogin  ${PUSERNAME_U5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Teams
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Verify Response List  ${resp}  0  id=${t_id1}  name=${team_name1}  size=0  description=${desc}  status=${status[0]}  users=[]
     Verify Response List  ${resp}  1  id=${t_id2}  name=${team_name2}  size=0  description=${desc}  status=${status[0]}  users=[]
     Verify Response List  ${resp}  2  id=${t_id3}  name=${team_name3}  size=0  description=${desc}  status=${status[0]}  users=[]

JD-TC-GetTeams-4
     [Documentation]  Get team by id by user who has usertype PROVIDER and admin privilage FALSE
     ${resp}=  Provider Login  ${HLMUSERNAME8}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${PUSERNAME_U5}=  Evaluate  ${PUSERNAME}+330097
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
 
    ${resp}=  Create User  ${firstname3}  ${lastname3}  ${dob3}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U5}.ynwtest@netvarth.com   ${userType[0]}  ${pin3}  ${countryCodes[0]}  ${PUSERNAME_U5}  ${dep_id}  ${sub_domain_id}  ${bool[0]}   ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id3}  ${resp.json()}

    ${resp}=  SendProviderResetMail   ${PUSERNAME_U5}
    Should Be Equal As Strings  ${resp.status_code}  200
    @{resp}=  ResetProviderPassword  ${PUSERNAME_U5}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200
    ${resp}=  ProviderLogin  ${PUSERNAME_U5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=  Get Teams
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Verify Response List  ${resp}  0  id=${t_id1}  name=${team_name1}  size=0  description=${desc}  status=${status[0]}  users=[]
     Verify Response List  ${resp}  1  id=${t_id2}  name=${team_name2}  size=0  description=${desc}  status=${status[0]}  users=[]
     Verify Response List  ${resp}  2  id=${t_id3}  name=${team_name3}  size=0  description=${desc}  status=${status[0]}  users=[]


JD-TC-GetTeams -UH2
     [Documentation]   create team without login      
     ${resp}=  Get Teams
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  419
     Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}"
 
JD-TC-GetTeams -UH3
    [Documentation]   Consumer get a user
    ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Get Teams
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"

