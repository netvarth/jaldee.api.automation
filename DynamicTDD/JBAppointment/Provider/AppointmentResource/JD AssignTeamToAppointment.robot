*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Team
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Library         /ebs/TDD/CustomKeywords.py
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables       /ebs/TDD/varfiles/providers.py
Variables       /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/hl_providers.py


*** Variables ***

${digits}       0123456789
${P_PASSWORD}        Netvarth008
${C_PASSWORD}        Netvarth009
@{service_names}


***Test Cases***

JD-TC-AssignTeamToAppointment-1

    [Documentation]  Assingn team to appointment.
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME7}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp2}=   Get Business Profile
    Log  ${resp2.json()}
    Should Be Equal As Strings    ${resp2.status_code}    200
    Set Suite Variable  ${sub_domain_id}  ${resp2.json()['serviceSubSector']['id']}

    # clear_queue      ${HLPUSERNAME7}
    # clear_service    ${HLPUSERNAME7}
    clear_customer   ${HLPUSERNAME7}

    ${pid}=  get_acc_id  ${HLPUSERNAME7}

    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[1]}
        ${resp}=   Enable Disable Department  ${toggle[1]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']}
    Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
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

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
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
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Suite Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

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
    Should Be Equal As Strings  ${resp.json()[0]['apptStatus']}  ${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()[0]['teamId']}          ${t_id1}

    ${resp}=  Encrypted Provider Login  ${USERNAME2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointments Today   team-eq=id::${t_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Should Be Equal As Strings  ${resp.json()[0]['uid']}         ${apptid1}
    Should Be Equal As Strings  ${resp.json()[0]['apptStatus']}  ${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()[0]['teamId']}          ${t_id1}

JD-TC-AssignTeamToAppointment-2

    [Documentation]  Assign team to an account level appointment and check wheather assigned to a user who is not in the team.

    ${resp}=  Encrypted Provider Login  ${USERNAME3}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointments Today    provider-eq=${u_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}        []

JD-TC-AssignTeamToAppointment-3

    [Documentation]  Assign team to an account level appointment then assign the same appointment to another team.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME7}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${USERNAME4}=  Evaluate  ${HLPUSERNAME7}+1445575081
    # ${firstname}=  FakerLibrary.name
    # ${lastname}=  FakerLibrary.last_name
    # ${dob}=  FakerLibrary.Date
    # # ${pin}=  get_pincode
    #  # ${resp}=  Get LocationsByPincode     ${pin}
    #  FOR    ${i}    IN RANGE    3
    #     ${pin}=  get_pincode
    #     ${kwstatus}  ${resp} =  Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
    #     IF    '${kwstatus}' == 'FAIL'
    #             Continue For Loop
    #     ELSE IF    '${kwstatus}' == 'PASS'
    #             Exit For Loop
    #     END
    #  END
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200 

    # ${whpnum}=  Evaluate  ${HLPUSERNAME7}+77481
    # ${tlgnum}=  Evaluate  ${HLPUSERNAME7}+65877

    # ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${USERNAME4}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${USERNAME4}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${whpnum}  ${countryCodes[0]}  ${tlgnum}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${u_id4}  ${resp.json()}

    # ${resp}=  Get User
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${USERNAME4}  ${u_id4} =  Create and Configure Sample User
    Set Suite Variable  ${u_id4}
    
    ${team_name1}=  FakerLibrary.name
    ${desc1}=   FakerLibrary.sentence

    ${resp}=  Create Team For User  ${team_name1}  ${EMPTY}  ${desc1} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${t_id2}  ${resp.json()}

    ${user_ids}=  Create List  ${u_id3}  ${u_id4}

    ${resp}=   Assign Team To User  ${user_ids}  ${t_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Assign Team To Appointment  ${apptid1}  ${t_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${USERNAME3}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointments Today   team-eq=id::${t_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Should Be Equal As Strings  ${resp.json()[0]['uid']}         ${apptid1}
    Should Be Equal As Strings  ${resp.json()[0]['apptStatus']}  ${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()[0]['teamId']}          ${t_id2}

    # ${resp}=  SendProviderResetMail   ${USERNAME4}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # @{resp}=  ResetProviderPassword  ${USERNAME4}  ${PASSWORD}  2
    # Should Be Equal As Strings  ${resp[0].status_code}  200
    # Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${USERNAME4}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointments Today   team-eq=id::${t_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Should Be Equal As Strings  ${resp.json()[0]['uid']}         ${apptid1}
    Should Be Equal As Strings  ${resp.json()[0]['apptStatus']}  ${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()[0]['teamId']}          ${t_id2}
    
    ${resp}=  Encrypted Provider Login  ${USERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointments Today  provider-eq=${u_id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}        []

    ${resp}=  Encrypted Provider Login  ${USERNAME2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointments Today   provider-eq=${u_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}        []

JD-TC-AssignTeamToAppointment-4

    [Documentation]  Assign team to an account level appointment of multiple consumers.
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME7}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=   add_timezone_time  ${tz}  1  00  
    ${eTime1}=    add_timezone_time  ${tz}  2  00   
    # ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    # ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  AddCustomer  ${CUSERNAME9}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Suite Variable  ${apptid2}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId1}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Assign Team To Appointment  ${apptid2}  ${t_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  SendProviderResetMail   ${USERNAME1}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # @{resp}=  ResetProviderPassword  ${USERNAME1}  ${PASSWORD}  2
    # Should Be Equal As Strings  ${resp[0].status_code}  200
    # Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${USERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointments Today   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['uid']}' == '${apptid1}'  
            Should Be Equal As Strings  ${resp.json()[${i}]['teamId']}    ${t_id2}      
            
        ELSE IF   '${resp.json()[${i}]['uid']}' == '${apptid2}'     
            Should Be Equal As Strings  ${resp.json()[${i}]['teamId']}    ${t_id1}      
           
        END
    END

    ${resp}=  Encrypted Provider Login  ${USERNAME2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointments Today  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['uid']}' == '${apptid1}'  
            Should Be Equal As Strings  ${resp.json()[${i}]['teamId']}    ${t_id2}      
            
        ELSE IF   '${resp.json()[${i}]['uid']}' == '${apptid2}'     
            Should Be Equal As Strings  ${resp.json()[${i}]['teamId']}    ${t_id1}      
           
        END
    END
 
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

