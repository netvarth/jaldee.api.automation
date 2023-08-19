*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        InternalStatus
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
Variables         /ebs/TDD/varfiles/musers.py
Variables         /ebs/TDD/varfiles/hl_musers.py


*** Variables ***
${SERVICE1}   SERVICE1
${SERVICE2}   SERVICE2
${SERVICE3}   SERVICE3
${SERVICE4}   SERVICE4
${SERVICE5}   SERVICE5
${SERVICE6}   SERVICE6
${digits}       0123456789
${P_PASSWORD}        Netvarth008
${C_PASSWORD}        Netvarth009


***Test Cases***

JD-TC-AppointmentApplyInternalSts-1
    [Documentation]  Apply Internal sts on appointment

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID}   ${resp.json()['id']}
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Provider Login  ${HLMUSERNAME10}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

     ${pid}=  get_acc_id  ${HLMUSERNAME10}
     Set Suite Variable  ${pid}

    ${resp2}=   Get Business Profile
    Log  ${resp2.json()}
    Should Be Equal As Strings    ${resp2.status_code}    200
    Set Suite Variable  ${sub_domain_id}  ${resp2.json()['serviceSubSector']['id']}
  
    clear_service   ${HLMUSERNAME10}
    clear_appt_schedule   ${HLMUSERNAME10}
    clear_customer   ${HLMUSERNAME10}

    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}

    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Run Keyword If  ${resp.json()['filterByDept']}==${bool[0]}   Toggle Department Enable
    Run Keyword If  '${resp}' != '${None}'   Log   ${resp.json()}
    Run Keyword If  '${resp}' != '${None}'   Should Be Equal As Strings  ${resp.status_code}  200

    ${dep_name1}=  FakerLibrary.bs
    Set Suite Variable   ${dep_name1}
    ${dep_code1}=   Random Int  min=100   max=999
    Set Suite Variable   ${dep_code1}
    ${dep_desc1}=   FakerLibrary.word  
    Set Suite Variable    ${dep_desc1}
    Log  ${dep_code1} 
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${depid1}  ${resp.json()}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']}

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}
    ${DAY2}=  add_date  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_time   4  00 
    ${SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${ser_duratn}=      Random Int   min=01   max=05
    ${resp}=  Create Service Department  ${SERVICE1}  ${desc}   ${ser_duratn}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  ${depid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id1}  ${resp.json()}
    ${SERVICE2}=    FakerLibrary.word
    ${resp}=  Create Service Department  ${SERVICE2}  ${desc}   ${ser_duratn}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  ${depid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id2}  ${resp.json()}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Suite Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  AddCustomer  ${CUSERNAME18}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}   ${resp.json()}

    ${service_ids1}=  Create List  ${s_id1}
    Set Suite Variable  ${service_ids1}
    ${service_ids2}=  Create List  ${s_id2}
    Set Suite Variable  ${service_ids2}
    ${empty_list}=  Create List
    Set Suite Variable  ${empty_list}
    ${permission1}=  InternalStatuses_permissions  ${empty_list}  ${empty_list}
    Set Suite Variable  ${permission1}
    ${permission2}=  InternalStatuses_permissions  ${empty_list}  ${empty_list}
    Set Suite Variable  ${permission2}
    ${internal_sts_name1}=  FakerLibrary.name
    Set Suite Variable  ${internal_sts_name1}
    ${internal_sts_dis_name1}=  FakerLibrary.name
    Set Suite Variable  ${internal_sts_dis_name1}
    ${internal_sts_name2}=  FakerLibrary.name
    Set Suite Variable  ${internal_sts_name2}
    ${internal_sts_dis_name2}=  FakerLibrary.name
    Set Suite Variable  ${internal_sts_dis_name2}
    ${sts1}=  Create_InternalStatus  ${internal_sts_name1}  ${internal_sts_dis_name1}   ${service_ids1}  1  ${empty_list}   ${permission1}
    ${sts2}=  Create_InternalStatus  ${internal_sts_name2}  ${internal_sts_dis_name2}   ${service_ids2}  2  ${empty_list}   ${permission2}
    ${int_statuses}=  Setting InternalStatuses  ${sts1}  ${sts2}
    #${sts}=  json.dumps  ${statuses}
    #Log  ${sts}
    #Set Suite Variable  ${sts}

    ${depts}=  Create List   ${depid1}
    ${teams}=  Create List
    ${users}=  Create List
    ${internalStatuses}=  Create List  ${internal_sts_name1}  
    ${businessLocations}=  Create List   ${lid}
    ${services}=  Create List    ${s_id1}  ${s_id2} 
    ${pinCodes}=  Create List  
    ${user_scopes1}=  User Scopes  ${depts}  ${teams}  ${users}   ${boolean[1]}  ${internalStatuses}  ${businessLocations}  ${services}  ${pinCodes}  ${boolean[1]}  ${boolean[1]}   ${boolean[1]}
    ${role1}=   FakerLibrary.word
    ${role2}=   FakerLibrary.word
    ${roles}=   Create List  ${role1}  ${role2} 
    ${labels}=  Create List  
    ${role_scopes1}=  Role Scopes  ${depts}  ${roles}  ${teams}  ${labels}   ${boolean[0]}  ${boolean[1]}   ${boolean[1]}  ${pinCodes}  ${services}  ${boolean[1]}  ${internalStatuses}  ${businessLocations}  
    ${role_scope}=   Create List   ${role_scopes1}
    ${scpe_sts}=  Setting User Access Scopes  ${boolean[0]}  ${boolean[1]}  ${role_scope}  ${user_scopes1}  

    ${combined_json}=  Internal_UserAccessScope_Json  ${int_statuses}  ${scpe_sts}
    ${combined_json}=  json.dumps  ${combined_json}
    Log  ${combined_json}

    ${internal_sts}=  MultiUser_InternalStatus  ${combined_json}  ${pid}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    Set Suite Variable  ${apptfor}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id1}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Suite Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}

     ${resp}=  Provider Login  ${HLMUSERNAME10}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${resp}=  Appointment Apply Internal Status  ${apptid1}  ${internal_sts_name1}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  internalStatus=${internal_sts_dis_name1}

    ${resp}=  Get Appointments Today
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}  0  internalStatus=${internal_sts_dis_name1}

JD-TC-AppointmentApplyInternalSts-UH1
     [Documentation]  Apply Internal statuses when user has no permission for internal Status
     ${resp}=  Provider Login  ${HLMUSERNAME10}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
    ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+301601
    Set Suite Variable  ${PUSERNAME_U1}
    clear_users  ${PUSERNAME_U1}
    ${firstname1}=  FakerLibrary.name
    Set Suite Variable  ${firstname1}
    ${lastname1}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname1}
    ${dob1}=  FakerLibrary.Date
    Set Suite Variable  ${dob1}
#     ${pin1}=  get_pincode
#     Set Suite Variable  ${pin1}
#     ${resp}=  Get LocationsByPincode     ${pin1}
    FOR    ${i}    IN RANGE    3
        ${pin1}=  get_pincode
        ${kwstatus}  ${resp} = 	Run Keyword And Ignore Error  Get LocationsByPincode  ${pin1}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
    END
    Should Be Equal As Strings    ${resp.status_code}    200 
    Set Suite Variable  ${pin1}
    Set Suite Variable  ${city1}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Suite Variable  ${state1}  ${resp.json()[0]['PostOffice'][0]['State']}     
    ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.ynwtest@netvarth.com   ${userType[0]}  ${pin1}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${depid1}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id1}  ${resp.json()}
    ${u_id1}=  Convert To String  ${u_id1}
    ${resp}=  SendProviderResetMail   ${PUSERNAME_U1}
    Should Be Equal As Strings  ${resp.status_code}  200
    @{resp}=  ResetProviderPassword  ${PUSERNAME_U1}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200
    ${resp}=  ProviderLogin  ${PUSERNAME_U1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id2}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Suite Variable  ${apptid2}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId2}=  Set Variable   ${resp.json()}
    Set Suite Variable  ${encId2}

     ${resp}=  Appointment Apply Internal Status  ${apptid2}  ${internal_sts_name2}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    422
     Should Be Equal As Strings  "${resp.json()}"  "${NOT_USER_STATUS}"

JD-TC-AppointmentApplyInternalSts-2
     [Documentation]  Apply Internal statuses when user has permission for internal Status

    ${service_ids1}=  Create List  ${s_id1}
    Set Suite Variable  ${service_ids1}
    ${service_ids2}=  Create List  ${s_id2}
    Set Suite Variable  ${service_ids2}
    ${user_ids1}=  Create List  ${u_id1}
    Set Suite Variable  ${user_ids1}
    ${permission1}=  InternalStatuses_permissions  ${empty_list}  ${empty_list}
    Set Suite Variable  ${permission1}
    ${permission2}=  InternalStatuses_permissions  ${user_ids1}  ${empty_list}
    Set Suite Variable  ${permission2}
    ${internal_sts_name1}=  FakerLibrary.name
    Set Suite Variable  ${internal_sts_name1}
    ${internal_sts_dis_name1}=  FakerLibrary.name
    Set Suite Variable  ${internal_sts_dis_name1}
    ${internal_sts_name2}=  FakerLibrary.name
    Set Suite Variable  ${internal_sts_name2}
    ${internal_sts_dis_name2}=  FakerLibrary.name
    Set Suite Variable  ${internal_sts_dis_name2}
    ${sts1}=  Create_InternalStatus  ${internal_sts_name1}  ${internal_sts_dis_name1}   ${service_ids1}  1  ${empty_list}   ${permission1}
    ${sts2}=  Create_InternalStatus  ${internal_sts_name2}  ${internal_sts_dis_name2}   ${service_ids2}  2  ${empty_list}   ${permission2}
    ${int_statuses}=  Setting InternalStatuses  ${sts1}  ${sts2}
    #${sts}=  json.dumps  ${statuses}
    #Log  ${sts}
    #Set Suite Variable  ${sts}

    ${depts}=  Create List   ${depid1}
    ${teams}=  Create List
    ${users}=  Create List
    ${internalStatuses}=  Create List  ${internal_sts_name1}  
    ${businessLocations}=  Create List   ${lid}
    ${services}=  Create List    ${s_id1}  ${s_id2} 
    ${pinCodes}=  Create List  
    ${user_scopes1}=  User Scopes  ${depts}  ${teams}  ${users}   ${boolean[1]}  ${internalStatuses}  ${businessLocations}  ${services}  ${pinCodes}  ${boolean[1]}  ${boolean[1]}   ${boolean[1]}
    ${role1}=   FakerLibrary.word
    ${role2}=   FakerLibrary.word
    ${roles}=   Create List  ${role1}  ${role2} 
    ${labels}=  Create List  
    ${role_scopes1}=  Role Scopes  ${depts}  ${roles}  ${teams}  ${labels}   ${boolean[0]}  ${boolean[1]}   ${boolean[1]}  ${pinCodes}  ${services}  ${boolean[1]}  ${internalStatuses}  ${businessLocations}  
    ${role_scope}=   Create List   ${role_scopes1}
    ${scpe_sts}=  Setting User Access Scopes  ${boolean[0]}  ${boolean[1]}  ${role_scope}  ${user_scopes1}  

    ${combined_json}=  Internal_UserAccessScope_Json  ${int_statuses}  ${scpe_sts}
    ${combined_json}=  json.dumps  ${combined_json}
    Log  ${combined_json}

    ${internal_sts}=  MultiUser_InternalStatus  ${combined_json}  ${pid}

    ${resp}=  ProviderLogin  ${PUSERNAME_U1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Appointment Apply Internal Status  ${apptid2}  ${internal_sts_name2}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  internalStatus=${internal_sts_dis_name2}

    ${resp}=  Get Appointments Today   appointmentEncId-eq=${encId2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}  0  internalStatus=${internal_sts_dis_name2}

JD-TC-AppointmentApplyInternalSts-UH2
     [Documentation]  Apply Internal statuses when service has no permission for internal Status 

    ${resp}=  ProviderLogin  ${PUSERNAME_U1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Appointment Apply Internal Status  ${apptid2}  ${internal_sts_name1}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    422
     Should Be Equal As Strings  "${resp.json()}"  "${NOT_SERVICE_STATUS}"

JD-TC-AppointmentApplyInternalSts-UH3
     [Documentation]  Trying to apply Internal statuses when one user applied internal sts already

    ${resp}=  ProviderLogin  ${HLMUSERNAME10}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Appointment Apply Internal Status  ${apptid2}  ${internal_sts_name2}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    422

JD-TC-AppointmentApplyInternalSts-3
     [Documentation]  Apply Internal statuses when user has no permission for internal sts but he is ADMIN=TRUE

     ${resp}=  Provider Login  ${HLMUSERNAME10}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
    ${PUSERNAME_U2}=  Evaluate  ${PUSERNAME}+301602
    Set Suite Variable  ${PUSERNAME_U2}
    clear_users  ${PUSERNAME_U2}
    ${firstname1}=  FakerLibrary.name
    Set Suite Variable  ${firstname1}
    ${lastname1}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname1}
    ${dob1}=  FakerLibrary.Date
    Set Suite Variable  ${dob1}
#     ${pin1}=  get_pincode
#     Set Suite Variable  ${pin1}
#     ${resp}=  Get LocationsByPincode     ${pin1}
    FOR    ${i}    IN RANGE    3
        ${pin1}=  get_pincode
        ${kwstatus}  ${resp} = 	Run Keyword And Ignore Error  Get LocationsByPincode  ${pin1}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
    END
    Should Be Equal As Strings    ${resp.status_code}    200 
    Set Suite Variable  ${pin1}
    Set Suite Variable  ${city1}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Suite Variable  ${state1}  ${resp.json()[0]['PostOffice'][0]['State']}     
    ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U2}.ynwtest@netvarth.com   ${userType[0]}  ${pin1}  ${countryCodes[0]}  ${PUSERNAME_U2}  ${depid1}  ${sub_domain_id}  ${bool[1]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id1}  ${resp.json()}
    ${u_id1}=  Convert To String  ${u_id1}
    ${resp}=  SendProviderResetMail   ${PUSERNAME_U2}
    Should Be Equal As Strings  ${resp.status_code}  200
    @{resp}=  ResetProviderPassword  ${PUSERNAME_U2}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200
    ${resp}=  ProviderLogin  ${PUSERNAME_U2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME19}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}   ${resp.json()}

    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    Set Suite Variable  ${apptfor}

    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id2}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Suite Variable  ${apptid3}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId3}=  Set Variable   ${resp.json()}

     ${resp}=  Appointment Apply Internal Status  ${apptid3}  ${internal_sts_name2}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${resp}=  Get Appointment By Id   ${apptid3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  internalStatus=${internal_sts_dis_name2}

    ${resp}=  Get Appointments Today  appointmentEncId-eq=${encId3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}  0  internalStatus=${internal_sts_dis_name2}