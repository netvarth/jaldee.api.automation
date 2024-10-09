*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Team
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/hl_providers.py


*** Variables ***

${digits}       0123456789
${P_PASSWORD}        Netvarth008
${C_PASSWORD}        Netvarth009


*** Keywords ***

Unassign Team From Appointment
    [Arguments]  ${appt_id}  ${team_id}  
    Check And Create YNW Session
    ${data}=  Create Dictionary  uid=${appt_id}  teamId=${team_id} 
    ${data}=  json.dumps  ${data}
    ${resp}=  PUT On Session  ynw  /provider/appointment/unassignTeam   data=${data}  expected_status=any
    RETURN  ${resp}


***Test Cases***

JD-TC-UnassignTeamFromAppointment-1

    [Documentation]  Unassign team from appointment.
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME7}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_queue      ${HLPUSERNAME7}
    clear_service    ${HLPUSERNAME7}
    clear_customer   ${HLPUSERNAME7}

    ${pid}=  get_acc_id  ${HLPUSERNAME7}

    ${lid}=  Create Sample Location  
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${tz}  ${resp.json()['timezone']}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${SERVICE1}=    generate_service_name
    ${s_id}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable   ${s_id}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  AddCustomer  ${CUSERNAME8}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Suite Variable  ${apptid1}  ${apptid[0]}

    ${USERNAME1}  ${u_id1} =  Create and Configure Sample User
    Set Suite Variable  ${USERNAME1}
    Set Suite Variable  ${u_id1}

    ${USERNAME2}  ${u_id2} =  Create and Configure Sample User
    Set Suite Variable  ${USERNAME2}
    Set Suite Variable  ${u_id2}

    ${USERNAME3}  ${u_id3} =  Create and Configure Sample User
    Set Suite Variable  ${USERNAME3}
    Set Suite Variable  ${u_id3}

    ${team_name}=  FakerLibrary.name
    ${team_size}=  Random Int  min=10  max=50
    ${desc}=   FakerLibrary.sentence

    ${resp}=  Create Team For User  ${team_name}  ${team_size}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${t_id1}  ${resp.json()}

    ${user_ids}=  Create List  ${u_id1}  ${u_id2}

    ${resp}=   Assign Team To User  ${user_ids}  ${t_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Assign Team To Appointment  ${apptid1}  ${t_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${USERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointments Today  team-eq=id::${t_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['uid']}         ${apptid1}
    Should Be Equal As Strings  ${resp.json()[0]['teamId']}          ${t_id1}

    ${resp}=  Encrypted Provider Login  ${USERNAME2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointments Today   team-eq=id::${t_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['uid']}         ${apptid1}
    Should Be Equal As Strings  ${resp.json()[0]['teamId']}          ${t_id1}

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME7}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Unassign Team From Appointment  ${apptid1}  ${t_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointments Today  team-eq=id::${t_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}       []

JD-TC-AssignTeamToAppointment-UH1

    [Documentation]  Assign same appointment to the same team multiple times.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME7}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Assign Team To Appointment  ${apptid1}  ${t_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}       ${TEAM_ALREADY_ASSIGNED}


JD-TC-AssignTeamToAppointment-UH2

    [Documentation]  Assign a appointment to a team which has no users.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME7}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${team_name}=  FakerLibrary.name
    ${team_size}=  Random Int  min=10  max=50
    ${desc}=   FakerLibrary.sentence

    ${resp}=  Create Team For User  ${team_name}  ${team_size}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${t_id1}  ${resp.json()}
    
    ${resp}=   Assign Team To Appointment  ${apptid1}  ${t_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}       ${TEAM_HAS_NO_USERS}


JD-TC-AssignTeamToAppointment-UH3

    [Documentation]  Try to assign another branch's appointment to the team.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME15}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${team_name}=  FakerLibrary.name
    ${team_size}=  Random Int  min=10  max=50
    ${desc}=   FakerLibrary.sentence

    ${resp}=  Create Team For User  ${team_name}  ${team_size}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${t_id1}  ${resp.json()}
    
    ${resp}=   Assign Team To Appointment  ${apptid1}  ${t_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}       ${TEAM_HAS_NO_USERS}

