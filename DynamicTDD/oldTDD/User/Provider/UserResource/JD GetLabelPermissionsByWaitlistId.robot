***Settings***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        User Labels
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/hl_providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py


***Test Cases***


JD-TC-GetLabelPremissions-1

    [Documentation]  Getting Label Permissions when usertype is PROVIDER.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME8}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${pid}=  get_acc_id  ${HLPUSERNAME8}
    Set Suite Variable   ${pid}

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

    ${resp}=   Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 
    Set Suite Variable  ${loc_id1}  ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}

    ${team_name2}=  FakerLibrary.name
    Set Suite Variable  ${team_name2}
    ${team_size2}=  Random Int  min=10  max=50
    ${desc2}=   FakerLibrary.sentence
    Set Suite Variable  ${desc2}
    ${resp}=  Create Team For User  ${team_name2}  ${team_size2}  ${desc2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${t_id1}  ${resp.json()}  
    ${t_id1}=  Convert To String  ${t_id1}

    ${team_name3}=  FakerLibrary.name
    Set Suite Variable  ${team_name3}
    ${desc3}=   FakerLibrary.sentence
    Set Suite Variable  ${desc3}
    ${resp}=  Create Team For User  ${team_name3}  ${EMPTY}  ${desc3} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${t_id2}  ${resp.json()}
    ${t_id2}=  Convert To String  ${t_id2}

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Set Suite Variable  ${u_id}  ${resp.json()[0]['id']}
    ${u_id}=  Convert To String  ${u_id}
 
#     ${resp}=   Create Sample Location
#     Set Suite Variable    ${loc_id1}    ${resp}  

#     ${resp}=   Get Location ById   ${loc_id1}
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200 
#     Set Suite Variable  ${pin1}  ${resp.json()['pinCode']}

    ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+45007484
    Set Suite Variable  ${PUSERNAME_U1}
    clear_users  ${PUSERNAME_U1}
    ${firstname1}=  FakerLibrary.name
    Set Suite Variable  ${firstname1}
    ${lastname1}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname1}
    ${dob1}=  FakerLibrary.Date
    Set Suite Variable  ${dob1}
    # ${pin1}=  get_pincode
     # ${resp}=  Get LocationsByPincode     ${pin1}
     FOR    ${i}    IN RANGE    3
        ${pin1}=  get_pincode
        ${kwstatus}  ${resp} =  Run Keyword And Ignore Error  Get LocationsByPincode  ${pin1}
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
    ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin1}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id1}  ${resp.json()}
    ${u_id1}=  Convert To String  ${u_id1}

    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${PUSERNAME_U2}=  Evaluate  ${PUSERNAME}+1022540
    Set Suite Variable  ${PUSERNAME_U2}
    clear_users  ${PUSERNAME_U2}
    ${firstname2}=  FakerLibrary.name
    Set Suite Variable  ${firstname2}
    ${lastname2}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname2}
    ${dob2}=  FakerLibrary.Date
    Set Suite Variable  ${dob2}
    # ${pin2}=  get_pincode
     # Set Suite Variable  ${pin2}
     # ${resp}=  Get LocationsByPincode     ${pin2}
     FOR    ${i}    IN RANGE    3
        ${pin2}=  get_pincode
        ${kwstatus}  ${resp} =  Run Keyword And Ignore Error  Get LocationsByPincode  ${pin2}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
     END
     Should Be Equal As Strings    ${resp.status_code}    200 
     Set Suite Variable  ${pin2} 
    Set Suite Variable  ${city2}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Suite Variable  ${state2}  ${resp.json()[0]['PostOffice'][0]['State']}    
    ${resp}=  Create User  ${firstname2}  ${lastname2}  ${dob2}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U2}.${test_mail}   ${userType[0]}  ${pin2}  ${countryCodes[0]}  ${PUSERNAME_U2}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id2}  ${resp.json()}
    ${u_id2}=  Convert To String  ${u_id2}

    ${PUSERNAME_U3}=  Evaluate  ${PUSERNAME}+1022587
    Set Suite Variable  ${PUSERNAME_U3}
    clear_users  ${PUSERNAME_U3}
    ${firstname3}=  FakerLibrary.name
    Set Suite Variable  ${firstname3}
    ${lastname3}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname3}
    ${dob3}=  FakerLibrary.Date
    Set Suite Variable  ${dob3}
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
     Should Be Equal As Strings    ${resp.status_code}    200 
     Set Suite Variable  ${pin3} 
    Set Suite Variable  ${city3}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Suite Variable  ${state3}  ${resp.json()[0]['PostOffice'][0]['State']}    
    ${resp}=  Create User  ${firstname3}  ${lastname3}  ${dob3}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U3}.${test_mail}   ${userType[2]}  ${pin3}  ${countryCodes[0]}  ${PUSERNAME_U3}  ${dep_id}  ${sub_domain_id}  ${bool[1]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id3}  ${resp.json()}
    ${u_id3}=  Convert To String  ${u_id3}

    ${SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${ser_duratn}=      Random Int   min=10   max=30
    ${resp}=  Create Service Department  ${SERVICE1}  ${desc}   ${ser_duratn}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  ${dep_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id1}  ${resp.json()}

    ${SERVICE2}=    FakerLibrary.word
    ${resp}=  Create Service Department  ${SERVICE2}  ${desc}   ${ser_duratn}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  ${dep_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id2}  ${resp.json()}
    
    clear_Label  ${HLPUSERNAME8}
    ${l_id1}=  Create Sample Label
    Set Suite Variable   ${l_id1}

    ${resp}=  Get Label By Id  ${l_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${l_id1}
    ${lbl_name1}=  Set Variable   ${resp.json()['label']}
    Set Suite Variable   ${lbl_name1}
    ${len}=  Get Length  ${resp.json()['valueSet']}
    ${i}=   Random Int   min=0   max=${len-1}
    ${lbl_value1}=   Set Variable   ${resp.json()['valueSet'][${i}]['value']}
    Set Suite Variable   ${lbl_value1}

    ${l_id2}=  Create Sample Label
    Set Suite Variable   ${l_id2}

    ${resp}=  Get Label By Id  ${l_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${l_id2}   
    ${lbl_name2}=  Set Variable   ${resp.json()['label']}
    Set Suite Variable   ${lbl_name2}
    ${len}=  Get Length  ${resp.json()['valueSet']}
    ${i}=   Random Int   min=0   max=${len-1}
    ${lbl_value2}=   Set Variable   ${resp.json()['valueSet'][${i}]['value']}
    Set Suite Variable   ${lbl_value2}

    ${user_ids1}=  Create List  ${u_id1}
    ${user_ids2}=  Create List  ${u_id2}
    
    ${empty_list}=  Create List
    ${permission1}=  Label Permissions  ${user_ids1}  ${empty_list}  ${l_id1}  ${t_id1}  
    ${permission2}=  Label Permissions  ${user_ids2}  ${empty_list}  ${l_id2}  ${t_id2} 

    ${lbl_perms}=  Setting Label Permissions  ${permission1}   ${permission2}
    
    ${depts}=  Create List  
    ${teams}=  Create List
    ${users}=  Create List   ${u_id1}  
    ${internalStatuses}=  Create List   
    ${businessLocations}=  Create List   ${loc_id1}
    ${services}=  Create List    ${s_id1} 
    ${pinCodes}=  Create List  

    ${user_scopes1}=  User Scopes  ${depts}  ${teams}  ${users}   ${boolean[1]}  ${internalStatuses}  ${businessLocations}  ${services}  ${pinCodes}  ${boolean[1]}  ${boolean[1]}   ${boolean[1]}
    Set Suite Variable   ${user_scopes1}

    ${role1}=   FakerLibrary.word
    ${role2}=   FakerLibrary.word
    ${roles}=   Create List  ${role1}  ${role2} 
    ${labels}=  Create List   ${l_id1}
    ${services}=  Create List   
   
    ${role_scopes1}=  Role Scopes  ${depts}  ${roles}  ${teams}  ${labels}   ${boolean[0]}  ${boolean[1]}   ${boolean[1]}  ${pinCodes}  ${services}  ${boolean[1]}  ${internalStatuses}  ${businessLocations}  
    ${role_scope}=   Create List   ${role_scopes1}
    Set Suite Variable   ${role_scope}

    ${user_scopes}=  Setting User Access Scopes  ${boolean[0]}  ${boolean[1]}  ${role_scope}  ${user_scopes1}   
    
    ${combined_json}=  LabelPrmissions_UserAccessScope_Json  ${lbl_perms}  ${user_scopes}
    
    ${lbl_scope_sts}=  MultiUser_InternalStatus  ${combined_json}  ${pid}
    
    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME8}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  AddCustomer  ${CUSERNAME24}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME24}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${CUR_DAY}
    ${q_name}=    FakerLibrary.name
    Set Suite Variable    ${q_name}
    ${list}=  Create List   1  2  3  4  5  6  7
    Set Suite Variable    ${list}
    ${strt_time}=   db.subtract_timezone_time  ${tz}     3   00
    Set Suite Variable    ${strt_time}
    ${end_time}=    add_timezone_time  ${tz}  0  30   
    Set Suite Variable    ${end_time}   
    ${parallel}=   Random Int  min=1   max=2
    Set Suite Variable   ${parallel}
    ${capacity}=  Random Int   min=10   max=20
    Set Suite Variable   ${capacity}
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${s_id1}  ${s_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id1}   ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${s_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid1}  ${wid[0]}
    
    ${label_dict}=  Create Label Dictionary  ${lbl_name1}  ${lbl_value1}
    ${resp}=  Add Label for Multiple Waitlist   ${label_dict}  ${wid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${label_lbl1}=    Create Dictionary  ${lbl_name1}=${lbl_value1}
    Set Suite Variable  ${label_lbl1}

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  ynwUuid=${wid1}  waitlistStatus=${wl_status[1]}  label=${label_lbl1}

    ${resp}=   Assign provider Waitlist   ${wid1}   ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  SendProviderResetMail   ${PUSERNAME_U1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${PUSERNAME_U1}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Waitlist Today   provider-eq=${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}   ${wid1}
    Should Be Equal As Strings  ${resp.json()[0]['waitlistStatus']}    ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[0]['label']}    ${label_lbl1}
    
    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetLabelPremissions-2

    [Documentation]  Getting Label Permissions when usertype is ADMIN.

    ${resp}=  SendProviderResetMail   ${PUSERNAME_U3}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${PUSERNAME_U3}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U3}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Waitlist Today    location-eq=${loc_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}   ${wid1}
    Should Be Equal As Strings  ${resp.json()[0]['waitlistStatus']}    ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[0]['label']}    ${label_lbl1}
    
    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetLabelPremissions-3

    [Documentation]  Getting Label Permissions for the default user without setting label permissions.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME8}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  SendProviderResetMail   ${PUSERNAME_U1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${PUSERNAME_U1}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist Today   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}   ${wid1}
    Should Be Equal As Strings  ${resp.json()[0]['waitlistStatus']}    ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[0]['label']}    ${label_lbl1}
    
JD-TC-GetLabelPremissions-4

    [Documentation]  Getting Label Permissions for the default user with setting label permissions.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME8}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${user_ids1}=  Create List  ${u_id}
    
    ${empty_list}=  Create List
    ${permission1}=  Label Permissions  ${user_ids1}  ${empty_list}  ${l_id1}  ${t_id1}  

    ${lbl_perms}=  Setting Label Permissions  ${permission1}  
    
    ${user_scopes}=  Setting User Access Scopes  ${boolean[0]}  ${boolean[1]}  ${role_scope}  ${user_scopes1}   
    
    ${combined_json}=  LabelPrmissions_UserAccessScope_Json  ${lbl_perms}  ${user_scopes}
    
    ${lbl_scope_sts}=  MultiUser_InternalStatus  ${combined_json}  ${pid}
    
    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME8}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  SendProviderResetMail   ${PUSERNAME_U1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${PUSERNAME_U1}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${label_dict}=  Create Label Dictionary  ${lbl_name1}  ${lbl_value1}
    ${resp}=  Add Label for Multiple Waitlist   ${label_dict}  ${wid1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${label_lbl1}=    Create Dictionary  ${lbl_name1}=${lbl_value1}
    Set Suite Variable  ${label_lbl1}

    ${resp}=  Get Waitlist Today   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}   ${wid1}
    Should Be Equal As Strings  ${resp.json()[0]['waitlistStatus']}    ${wl_status[1]}
    Should Be Equal As Strings  ${resp.json()[0]['label']}    ${label_lbl1}


JD-TC-GetLabelPremissions-5

    [Documentation]  Getting Label Permissions for a team.
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME8}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${PUSERNAME_U4}=  Evaluate  ${PUSERNAME}+450014
    Set Suite Variable  ${PUSERNAME_U4}
    clear_users  ${PUSERNAME_U4}
    ${firstname4}=  FakerLibrary.name
    Set Suite Variable  ${firstname4}
    ${lastname4}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname4}
    ${dob4}=  FakerLibrary.Date
    Set Suite Variable  ${dob4}
    # ${pin4}=  get_pincode
     # ${resp}=  Get LocationsByPincode     ${pin4}
     FOR    ${i}    IN RANGE    3
        ${pin4}=  get_pincode
        ${kwstatus}  ${resp} =  Run Keyword And Ignore Error  Get LocationsByPincode  ${pin4}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
     END
     Should Be Equal As Strings    ${resp.status_code}    200 
     Set Suite Variable  ${pin4} 
    Set Suite Variable  ${city4}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Suite Variable  ${state4}  ${resp.json()[0]['PostOffice'][0]['State']}     
    ${resp}=  Create User  ${firstname4}  ${lastname4}  ${dob4}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U4}.${test_mail}   ${userType[0]}  ${pin4}  ${countryCodes[0]}  ${PUSERNAME_U4}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id4}  ${resp.json()}
    ${u_id4}=  Convert To String  ${u_id4}
    
    ${PUSERNAME_U5}=  Evaluate  ${PUSERNAME}+102200
    Set Suite Variable  ${PUSERNAME_U5}
    clear_users  ${PUSERNAME_U5}
    ${firstname5}=  FakerLibrary.name
    Set Suite Variable  ${firstname5}
    ${lastname5}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname5}
    ${dob5}=  FakerLibrary.Date
    Set Suite Variable  ${dob5}
    # ${pin5}=  get_pincode
     # ${resp}=  Get LocationsByPincode     ${pin5}
     FOR    ${i}    IN RANGE    3
        ${pin5}=  get_pincode
        ${kwstatus}  ${resp} =  Run Keyword And Ignore Error  Get LocationsByPincode  ${pin5}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
     END
     Should Be Equal As Strings    ${resp.status_code}    200 
     Set Suite Variable  ${pin5} 
    Set Suite Variable  ${city5}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Suite Variable  ${state5}  ${resp.json()[0]['PostOffice'][0]['State']}    
    ${resp}=  Create User  ${firstname5}  ${lastname5}  ${dob5}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U5}.${test_mail}   ${userType[0]}  ${pin5}  ${countryCodes[0]}  ${PUSERNAME_U5}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id5}  ${resp.json()}
    ${u_id5}=  Convert To String  ${u_id5}

    ${user_ids}=  Create List  ${u_id4}  ${u_id5}

    ${resp}=   Assign Team To User  ${user_ids}  ${t_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${empty_list}=  Create List
    ${permission1}=  Label Permissions  ${empty_list}  ${empty_list}  ${l_id1}  ${t_id1}  
    
    ${lbl_perms}=  Setting Label Permissions  ${permission1}   
    
    ${depts}=  Create List  
    ${teams}=  Create List
    ${users}=  Create List  
    ${internalStatuses}=  Create List   
    ${businessLocations}=  Create List 
    ${services}=  Create List     
    ${pinCodes}=  Create List  

    ${user_scopes1}=  User Scopes  ${depts}  ${teams}  ${users}   ${boolean[1]}  ${internalStatuses}  ${businessLocations}  ${services}  ${pinCodes}  ${boolean[1]}  ${boolean[1]}   ${boolean[1]}
    Set Suite Variable   ${user_scopes1}

    ${role1}=   FakerLibrary.word
    ${role2}=   FakerLibrary.word
    ${roles}=   Create List  ${role1}  ${role2} 
    ${labels}=  Create List   ${l_id1}
    ${services}=  Create List   
   
    ${role_scopes1}=  Role Scopes  ${depts}  ${roles}  ${teams}  ${labels}   ${boolean[0]}  ${boolean[1]}   ${boolean[1]}  ${pinCodes}  ${services}  ${boolean[1]}  ${internalStatuses}  ${businessLocations}  
    ${role_scope}=   Create List   ${role_scopes1}
    Set Suite Variable   ${role_scope}

    ${user_scopes}=  Setting User Access Scopes  ${boolean[0]}  ${boolean[1]}  ${role_scope}  ${user_scopes1}   
    
    ${combined_json}=  LabelPrmissions_UserAccessScope_Json  ${lbl_perms}  ${user_scopes}
  
    ${lbl_scope_sts}=  MultiUser_InternalStatus  ${combined_json}  ${pid}
    
    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME8}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  AddCustomer  ${CUSERNAME4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid1}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid1}  ${s_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid2}  ${wid[0]}
    
    ${label_dict}=  Create Label Dictionary  ${lbl_name1}  ${lbl_value1}
    ${resp}=  Add Label for Multiple Waitlist   ${label_dict}  ${wid2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Assign Team To Checkin  ${wid2}  ${t_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SendProviderResetMail   ${PUSERNAME_U4}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${PUSERNAME_U4}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U4}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Waitlist By Id  ${wid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  ynwUuid=${wid2}  waitlistStatus=${wl_status[1]}  label=${label_lbl1}
    
    ${resp}=  SendProviderResetMail   ${PUSERNAME_U5}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${PUSERNAME_U5}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U5}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Waitlist By Id  ${wid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  ynwUuid=${wid2}  waitlistStatus=${wl_status[1]}  label=${label_lbl1}

JD-TC-GetLabelPremissions-6

    [Documentation]  Getting Label Permissions when usertype is ASSISTANT.
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME8}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${PUSERNAME_U5}=  Evaluate  ${PUSERNAME}+450780
    Set Suite Variable  ${PUSERNAME_U5}
    clear_users  ${PUSERNAME_U5}
    ${firstname5}=  FakerLibrary.name
    Set Suite Variable  ${firstname5}
    ${lastname5}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname5}
    ${dob5}=  FakerLibrary.Date
    Set Suite Variable  ${dob5}
    # ${pin5}=  get_pincode
     # ${resp}=  Get LocationsByPincode     ${pin5}
     FOR    ${i}    IN RANGE    3
        ${pin5}=  get_pincode
        ${kwstatus}  ${resp} =  Run Keyword And Ignore Error  Get LocationsByPincode  ${pin5}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
     END
     Should Be Equal As Strings    ${resp.status_code}    200 
     Set Suite Variable  ${pin5} 
    Set Suite Variable  ${city5}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Suite Variable  ${state5}  ${resp.json()[0]['PostOffice'][0]['State']}     
    ${resp}=  Create User  ${firstname5}  ${lastname5}  ${dob5}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U5}.${test_mail}   ${userType[1]}  ${pin5}  ${countryCodes[0]}  ${PUSERNAME_U5}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id5}  ${resp.json()}
    ${u_id5}=  Convert To String  ${u_id5}
    
    ${resp}=  SendProviderResetMail   ${PUSERNAME_U5}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${PUSERNAME_U5}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U5}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Waitlist Today    location-eq=${loc_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Variable Should Exist   ${resp.content}   ${wid1}
    Variable Should Exist   ${resp.content}   ${wl_status[1]}
    Variable Should Exist   ${resp.content}   ${label_lbl1}
#     Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}   ${wid1}
#     Should Be Equal As Strings  ${resp.json()[0]['waitlistStatus']}    ${wl_status[1]}
#     Should Be Equal As Strings  ${resp.json()[0]['label']}    ${label_lbl1}
    
    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200

   
JD-TC-GetLabelPremissions-UH1

    [Documentation]  Getting Label Permissions for a user not in the team.

    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=  Get Waitlist Today  provider-eq=${u_id1}  queue-eq=${que_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}   ${wid1}
    
JD-TC-GetLabelPremissions-UH2

    [Documentation]  try to add label in a waitlist without giving any label permissions.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME8}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${pid}=  get_acc_id  ${HLPUSERNAME8}

    ${resp}=  Get Departments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}

    ${resp2}=   Get Business Profile
    Log  ${resp2.json()}
    Should Be Equal As Strings    ${resp2.status_code}    200
    Set Test Variable  ${sub_domain_id}  ${resp2.json()['serviceSubSector']['id']}

    ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+45640332
    clear_users  ${PUSERNAME_U1}
    ${firstname1}=  FakerLibrary.name
    ${lastname1}=  FakerLibrary.last_name
    ${dob1}=  FakerLibrary.Date
    # ${pin1}=  get_pincode
     # ${resp}=  Get LocationsByPincode     ${pin1}
     FOR    ${i}    IN RANGE    3
        ${pin1}=  get_pincode
        ${kwstatus}  ${resp} =  Run Keyword And Ignore Error  Get LocationsByPincode  ${pin1}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
     END
    Should Be Equal As Strings    ${resp.status_code}    200 
    Set Test Variable  ${city1}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Test Variable  ${state1}  ${resp.json()[0]['PostOffice'][0]['State']}     
    ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin1}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id1}  ${resp.json()}
    ${u_id1}=  Convert To String  ${u_id1}
    
    ${PUSERNAME_U2}=  Evaluate  ${PUSERNAME}+5574899
    clear_users  ${PUSERNAME_U2}
    ${firstname2}=  FakerLibrary.name
    ${lastname2}=  FakerLibrary.last_name
    ${dob2}=  FakerLibrary.Date
    # ${pin2}=  get_pincode
     # ${resp}=  Get LocationsByPincode     ${pin2}
     FOR    ${i}    IN RANGE    3
        ${pin2}=  get_pincode
        ${kwstatus}  ${resp} =  Run Keyword And Ignore Error  Get LocationsByPincode  ${pin2}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
     END
    Should Be Equal As Strings    ${resp.status_code}    200 
    Set Test Variable  ${city2}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Test Variable  ${state2}  ${resp.json()[0]['PostOffice'][0]['State']}    
    ${resp}=  Create User  ${firstname2}  ${lastname2}  ${dob2}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U2}.${test_mail}   ${userType[0]}  ${pin2}  ${countryCodes[0]}  ${PUSERNAME_U2}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id2}  ${resp.json()}
    ${u_id2}=  Convert To String  ${u_id2}

    ${PUSERNAME_U3}=  Evaluate  ${PUSERNAME}+45840056
    clear_users  ${PUSERNAME_U3}
    ${firstname3}=  FakerLibrary.name
    ${lastname3}=  FakerLibrary.last_name
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
    Should Be Equal As Strings    ${resp.status_code}    200 
    Set Test Variable  ${city3}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Test Variable  ${state3}  ${resp.json()[0]['PostOffice'][0]['State']}    
    ${resp}=  Create User  ${firstname3}  ${lastname3}  ${dob3}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U3}.${test_mail}   ${userType[0]}  ${pin3}  ${countryCodes[0]}  ${PUSERNAME_U3}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id3}  ${resp.json()}
    ${u_id3}=  Convert To String  ${u_id3}

    ${SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${ser_duratn}=      Random Int   min=10   max=30
    ${resp}=  Create Service Department  ${SERVICE1}  ${desc}   ${ser_duratn}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  ${dep_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id1}  ${resp.json()}

    ${SERVICE2}=    FakerLibrary.word
    ${resp}=  Create Service Department  ${SERVICE2}  ${desc}   ${ser_duratn}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  ${dep_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id2}  ${resp.json()}
    

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

    clear_Label  ${HLPUSERNAME8}
    ${l_id1}=  Create Sample Label

    ${resp}=  Get Label By Id  ${l_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${l_id1}
    ${lbl_name1}=  Set Variable   ${resp.json()['label']}
    ${len}=  Get Length  ${resp.json()['valueSet']}
    ${i}=   Random Int   min=0   max=${len-1}
    ${lbl_value1}=   Set Variable   ${resp.json()['valueSet'][${i}]['value']}

    ${l_id2}=  Create Sample Label

    ${resp}=  Get Label By Id  ${l_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${l_id2}   
    ${lbl_name2}=  Set Variable   ${resp.json()['label']}
    ${len}=  Get Length  ${resp.json()['valueSet']}
    ${i}=   Random Int   min=0   max=${len-1}
    ${lbl_value2}=   Set Variable   ${resp.json()['valueSet'][${i}]['value']}

    ${user_ids1}=  Create List  ${u_id1}
    
    ${empty_list}=  Create List
    ${permission1}=  Label Permissions  ${empty_list}  ${empty_list}  ${l_id1}  ${empty_list}  
    
    ${statuses}=  Setting Label Permissions  ${permission1}  
    ${sts}=  json.dumps  ${statuses}
    Log  ${sts}
    ${lbl_permsns}=  MultiUser_InternalStatus  ${sts}  ${pid}

    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME8}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME20}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=   Create Sample Location
    Set Test Variable    ${loc_id1}    ${resp}  

    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}  
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz} 
    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${strt_time}=   db.subtract_timezone_time  ${tz}     3   00
    ${end_time}=    add_timezone_time  ${tz}  0  30   
    ${parallel}=   Random Int  min=1   max=2
    ${capacity}=  Random Int   min=10   max=20
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${s_id1}  ${s_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id1}   ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid1}  ${s_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}
    
    ${label_dict}=  Create Label Dictionary  ${lbl_name1}  ${lbl_value1}
    ${resp}=  Add Label for Multiple Waitlist   ${label_dict}  ${wid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${label_lbl1}=    Create Dictionary  ${lbl_name1}=${lbl_value1}
    Set Test Variable  ${label_lbl1}

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  ynwUuid=${wid}  waitlistStatus=${wl_status[1]}  label=${label_lbl1}

    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  SendProviderResetMail   ${PUSERNAME_U2}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${PUSERNAME_U2}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Add Label for Multiple Waitlist   ${label_dict}  ${wid}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${CAN_NOT_ADD_REMOVE_LABEL}


JD-TC-GetLabelPremissions-UH3

    [Documentation]  try to add a label for a user who is not in the label permission list.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME8}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+4560042
    clear_users  ${PUSERNAME_U1}
    ${firstname1}=  FakerLibrary.name
    ${lastname1}=  FakerLibrary.last_name
    ${dob1}=  FakerLibrary.Date
    # ${pin1}=  get_pincode
     # ${resp}=  Get LocationsByPincode     ${pin1}
     FOR    ${i}    IN RANGE    3
        ${pin1}=  get_pincode
        ${kwstatus}  ${resp} =  Run Keyword And Ignore Error  Get LocationsByPincode  ${pin1}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
     END
    Should Be Equal As Strings    ${resp.status_code}    200 
    Set Test Variable  ${city1}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Test Variable  ${state1}  ${resp.json()[0]['PostOffice'][0]['State']}     
    ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin1}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id1}  ${resp.json()}
    ${u_id1}=  Convert To String  ${u_id1}
    
    ${PUSERNAME_U2}=  Evaluate  ${PUSERNAME}+45740094
    clear_users  ${PUSERNAME_U2}
    ${firstname2}=  FakerLibrary.name
    ${lastname2}=  FakerLibrary.last_name
    ${dob2}=  FakerLibrary.Date
    # ${pin2}=  get_pincode
     # ${resp}=  Get LocationsByPincode     ${pin2}
     FOR    ${i}    IN RANGE    3
        ${pin2}=  get_pincode
        ${kwstatus}  ${resp} =  Run Keyword And Ignore Error  Get LocationsByPincode  ${pin2}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
     END
    Should Be Equal As Strings    ${resp.status_code}    200 
    Set Test Variable  ${city2}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Test Variable  ${state2}  ${resp.json()[0]['PostOffice'][0]['State']}    
    ${resp}=  Create User  ${firstname2}  ${lastname2}  ${dob2}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U2}.${test_mail}   ${userType[0]}  ${pin2}  ${countryCodes[0]}  ${PUSERNAME_U2}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id2}  ${resp.json()}
    ${u_id2}=  Convert To String  ${u_id2}

    ${PUSERNAME_U3}=  Evaluate  ${PUSERNAME}+457407
    clear_users  ${PUSERNAME_U3}
    ${firstname3}=  FakerLibrary.name
    ${lastname3}=  FakerLibrary.last_name
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
    Should Be Equal As Strings    ${resp.status_code}    200 
    Set Test Variable  ${city3}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Test Variable  ${state3}  ${resp.json()[0]['PostOffice'][0]['State']}    
    ${resp}=  Create User  ${firstname3}  ${lastname3}  ${dob3}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U3}.${test_mail}   ${userType[0]}  ${pin3}  ${countryCodes[0]}  ${PUSERNAME_U3}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id3}  ${resp.json()}
    ${u_id3}=  Convert To String  ${u_id3}

    ${SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${ser_duratn}=      Random Int   min=10   max=30
    ${resp}=  Create Service Department  ${SERVICE1}  ${desc}   ${ser_duratn}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  ${dep_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id1}  ${resp.json()}

    ${SERVICE2}=    FakerLibrary.word
    ${resp}=  Create Service Department  ${SERVICE2}  ${desc}   ${ser_duratn}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  ${dep_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id2}  ${resp.json()}
    

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

    clear_Label  ${HLPUSERNAME8}
    ${l_id1}=  Create Sample Label

    ${resp}=  Get Label By Id  ${l_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${l_id1}
    ${lbl_name1}=  Set Variable   ${resp.json()['label']}
    ${len}=  Get Length  ${resp.json()['valueSet']}
    ${i}=   Random Int   min=0   max=${len-1}
    ${lbl_value1}=   Set Variable   ${resp.json()['valueSet'][${i}]['value']}

    ${l_id2}=  Create Sample Label

    ${resp}=  Get Label By Id  ${l_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${l_id2}   
    ${lbl_name2}=  Set Variable   ${resp.json()['label']}
    ${len}=  Get Length  ${resp.json()['valueSet']}
    ${i}=   Random Int   min=0   max=${len-1}
    ${lbl_value2}=   Set Variable   ${resp.json()['valueSet'][${i}]['value']}

    ${user_ids1}=  Create List  ${u_id1}  ${u_id2}
    
    ${empty_list}=  Create List
    ${permission1}=  Label Permissions  ${user_ids1}  ${empty_list}  ${l_id1}  ${empty_list}  
    
    ${statuses}=  Setting Label Permissions  ${permission1}  
    ${sts}=  json.dumps  ${statuses}
    Log  ${sts}
    ${lbl_permsns}=  MultiUser_InternalStatus  ${sts}  ${pid}

    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME8}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME20}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=   Create Sample Location
    Set Test Variable    ${loc_id1}    ${resp}  

    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}  
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz} 
    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${strt_time}=   db.subtract_timezone_time  ${tz}     3   00
    ${end_time}=    add_timezone_time  ${tz}  0  30   
    ${parallel}=   Random Int  min=1   max=2
    ${capacity}=  Random Int   min=10   max=20
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${s_id1}  ${s_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id1}   ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid1}  ${s_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}
    
    ${label_dict}=  Create Label Dictionary  ${lbl_name1}  ${lbl_value1}
    ${resp}=  Add Label for Multiple Waitlist   ${label_dict}  ${wid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${label_lbl1}=    Create Dictionary  ${lbl_name1}=${lbl_value1}
    Set Test Variable  ${label_lbl1}

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  ynwUuid=${wid}  waitlistStatus=${wl_status[1]}  label=${label_lbl1}

    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  SendProviderResetMail   ${PUSERNAME_U3}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${PUSERNAME_U3}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U3}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Add Label for Multiple Waitlist   ${label_dict}  ${wid}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${CAN_NOT_ADD_REMOVE_LABEL}



JD-TC-GetLabelPremissions-UH4

    [Documentation]  try to add another provider's label having label permissions.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME6}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${pid}=  get_acc_id  ${HLPUSERNAME6}
    
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
    Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}

    ${resp2}=   Get Business Profile
    Log  ${resp2.json()}
    Should Be Equal As Strings    ${resp2.status_code}    200
    Set Test Variable  ${sub_domain_id}  ${resp2.json()['serviceSubSector']['id']}

    ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+45600433
    clear_users  ${PUSERNAME_U1}
    ${firstname1}=  FakerLibrary.name
    ${lastname1}=  FakerLibrary.last_name
    ${dob1}=  FakerLibrary.Date
    # ${pin1}=  get_pincode
     # ${resp}=  Get LocationsByPincode     ${pin1}
     FOR    ${i}    IN RANGE    3
        ${pin1}=  get_pincode
        ${kwstatus}  ${resp} =  Run Keyword And Ignore Error  Get LocationsByPincode  ${pin1}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
     END
    Should Be Equal As Strings    ${resp.status_code}    200 
    Set Test Variable  ${city1}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Test Variable  ${state1}  ${resp.json()[0]['PostOffice'][0]['State']}     
    ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin1}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id1}  ${resp.json()}
    ${u_id1}=  Convert To String  ${u_id1}

    ${SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${ser_duratn}=      Random Int   min=10   max=30
    ${resp}=  Create Service Department  ${SERVICE1}  ${desc}   ${ser_duratn}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  ${dep_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id1}  ${resp.json()}

    ${SERVICE2}=    FakerLibrary.word
    ${resp}=  Create Service Department  ${SERVICE2}  ${desc}   ${ser_duratn}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  ${dep_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id2}  ${resp.json()}
    
    ${resp}=  AddCustomer  ${CUSERNAME2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=   Create Sample Location
    Set Test Variable    ${loc_id1}    ${resp}  

    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}  
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz} 
    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${strt_time}=   db.subtract_timezone_time  ${tz}     3   00
    ${end_time}=    add_timezone_time  ${tz}  0  30   
    ${parallel}=   Random Int  min=1   max=2
    ${capacity}=  Random Int   min=10   max=20
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${s_id1}  ${s_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id1}   ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${s_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}
    
    ${label_dict}=  Create Label Dictionary  ${lbl_name1}  ${lbl_value1}
    ${resp}=  Add Label for Multiple Waitlist   ${label_dict}  ${wid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${LABEL_NOT_EXIST}
 