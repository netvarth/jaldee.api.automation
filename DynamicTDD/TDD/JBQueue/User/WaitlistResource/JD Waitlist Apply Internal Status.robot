***Settings***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        InternalStatus
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/hl_providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

***Test Cases***

JD-TC-WaitlistApplyInternalSts-1

     [Documentation]  Apply Internal statuses when user has ADMIN=TRUE

     clear_customer   ${HLPUSERNAME21}
     clear_queue      ${HLPUSERNAME21}
     clear_service    ${HLPUSERNAME21}
     clear_location   ${HLPUSERNAME21}

     ${resp}=  Encrypted Provider Login  ${HLPUSERNAME21}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${pid}=  get_acc_id  ${HLPUSERNAME21}
     Set Suite Variable  ${pid}

     ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
     
     # sleep  2s
     # ${resp}=  Get Departments
     # Log   ${resp.json()}
     # Should Be Equal As Strings  ${resp.status_code}  200
     # Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
     
    ${dep_name1}=  FakerLibrary.bs
    ${dep_code1}=   Random Int  min=100   max=999
    ${dep_desc1}=   FakerLibrary.word  
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id}  ${resp.json()}

     ${resp2}=   Get Business Profile
     Log  ${resp2.json()}
     Should Be Equal As Strings    ${resp2.status_code}    200
     Set Suite Variable  ${sub_domain_id}  ${resp2.json()['serviceSubSector']['id']}
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

     ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+30147
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
    
    ${PUSERNAME_U2}=  Evaluate  ${PUSERNAME}+301302
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

    ${SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${ser_duratn}=      Random Int   min=01   max=05
    ${resp}=  Create Service Department  ${SERVICE1}  ${desc}   ${ser_duratn}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  ${dep_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id1}  ${resp.json()}
    ${SERVICE2}=    FakerLibrary.word
    ${resp}=  Create Service Department  ${SERVICE2}  ${desc}   ${ser_duratn}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  ${dep_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id2}  ${resp.json()}
    ${SERVICE3}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${ser_duratn}=      Random Int   min=10   max=30
    ${resp}=  Create Service Department  ${SERVICE3}  ${desc}   ${ser_duratn}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  ${dep_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id3}  ${resp.json()}


    ${user_ids1}=  Create List  ${u_id1}
    Set Suite Variable  ${user_ids1}
    ${user_ids2}=  Create List  ${u_id2}
    Set Suite Variable  ${user_ids2}
    ${service_ids1}=  Create List  ${s_id1}
    Set Suite Variable  ${service_ids1}
    ${service_ids2}=  Create List  ${s_id2}
    Set Suite Variable  ${service_ids2}
    ${empty_list}=  Create List
    Set Suite Variable  ${empty_list}
    ${permission1}=  InternalStatuses_permissions  ${user_ids1}  ${empty_list}
    Set Suite Variable  ${permission1}
    ${permission2}=  InternalStatuses_permissions  ${user_ids2}  ${empty_list}
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
    ${statuses}=  Setting InternalStatuses  ${sts1}  ${sts2}
    ${sts}=  json.dumps  ${statuses}
    Log  ${sts}
    Set Suite Variable  ${sts}
    ${internal_sts}=  MultiUser_InternalStatus  ${sts}  ${pid}

    clear_customer   ${HLPUSERNAME21}

    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}

    
    ${resp}=   Create Sample Location
    Set Suite Variable    ${loc_id1}    ${resp}

    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}  

    ${q_name}=    FakerLibrary.name
    Set Suite Variable    ${q_name}
    ${list}=  Create List   1  2  3  4  5  6  7
    Set Suite Variable    ${list}
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${CUR_DAY}
    ${strt_time}=   db.subtract_timezone_time  ${tz}     3   00
    Set Suite Variable    ${strt_time}
    ${end_time}=    add_timezone_time  ${tz}  3  30   
    Set Suite Variable    ${end_time}   
    ${parallel}=   Random Int  min=1   max=2
    Set Suite Variable   ${parallel}
    ${capacity}=  Random Int   min=10   max=20
    Set Suite Variable   ${capacity}
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${s_id1}  ${s_id2}  ${s_id3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id1}   ${resp.json()}

     ${desc}=   FakerLibrary.word
     ${resp}=  Add To Waitlist  ${cid}  ${s_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${wid}=  Get Dictionary Values  ${resp.json()}
     Set Suite Variable  ${wid}  ${wid[0]}
     ${resp}=   ProviderLogout
     Should Be Equal As Strings    ${resp.status_code}    200

     ${resp}=  Encrypted Provider Login  ${HLPUSERNAME21}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${resp}=  Waitlist Apply Internal Status  ${wid}  ${internal_sts_name1}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${resp}=  Get Waitlist By Id  ${wid} 
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response  ${resp}  internalStatus=${internal_sts_dis_name1}

JD-TC-WaitlistApplyInternalSts-2
     [Documentation]  Apply Internal statuses when user has permission for internal Status
     ${resp}=  SendProviderResetMail   ${PUSERNAME_U1}
     Should Be Equal As Strings  ${resp.status_code}  200
     @{resp}=  ResetProviderPassword  ${PUSERNAME_U1}  ${PASSWORD}  2
     Should Be Equal As Strings  ${resp[0].status_code}  200
     Should Be Equal As Strings  ${resp[1].status_code}  200
     ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=  AddCustomer  ${CUSERNAME2}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${cid}  ${resp.json()}

     ${desc}=   FakerLibrary.word
     ${resp}=  Add To Waitlist By User  ${cid}  ${s_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${u_id1}  ${cid}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${wid1}=  Get Dictionary Values  ${resp.json()}
     Set Suite Variable  ${wid1}  ${wid1[0]}

     ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200
     
     ${resp}=  Waitlist Apply Internal Status  ${wid1}  ${internal_sts_name1}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${resp}=   ProviderLogout
     Should Be Equal As Strings    ${resp.status_code}    200

     ${resp}=  Encrypted Provider Login  ${HLPUSERNAME21}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${resp}=  Get Waitlist By Id  ${wid1} 
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response  ${resp}  internalStatus=${internal_sts_dis_name1}

JD-TC-WaitlistApplyInternalSts-3
     [Documentation]  Apply Internal statuses when user has no permission for internal sts but he is ADMIN=TRUE
     ${resp}=  Encrypted Provider Login  ${HLPUSERNAME21}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${PUSERNAME_U3}=  Evaluate  ${PUSERNAME}+301394
     Set Suite Variable  ${PUSERNAME_U3}
     clear_users  ${PUSERNAME_U3}
     ${resp}=  Create User  ${firstname2}  ${lastname2}  ${dob2}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U3}.${test_mail}   ${userType[0]}  ${pin2}  ${countryCodes[0]}  ${PUSERNAME_U3}  ${dep_id}  ${sub_domain_id}  ${bool[1]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${u_id3}  ${resp.json()}
     ${u_id3}=  Convert To String  ${u_id3}

     ${resp}=  SendProviderResetMail   ${PUSERNAME_U3}
     Should Be Equal As Strings  ${resp.status_code}  200
     @{resp}=  ResetProviderPassword  ${PUSERNAME_U3}  ${PASSWORD}  2
     Should Be Equal As Strings  ${resp[0].status_code}  200
     Should Be Equal As Strings  ${resp[1].status_code}  200
     ${resp}=  Encrypted Provider Login  ${PUSERNAME_U3}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=  AddCustomer  ${CUSERNAME3}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${cid}  ${resp.json()}

     ${desc}=   FakerLibrary.word
     ${resp}=  Add To Waitlist By User  ${cid}  ${s_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${u_id3}  ${cid}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${wid2}=  Get Dictionary Values  ${resp.json()}
     Set Suite Variable  ${wid2}  ${wid2[0]}

     ${resp}=  Waitlist Apply Internal Status  ${wid2}  ${internal_sts_name1}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${resp}=  Get Waitlist By Id  ${wid2} 
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response  ${resp}  internalStatus=${internal_sts_dis_name1}

JD-TC-WaitlistApplyInternalSts-UH1
     [Documentation]  Apply already applied Internal statuses with other user he has permission for that internal Status
     ${resp}=  SendProviderResetMail   ${PUSERNAME_U1}
     Should Be Equal As Strings  ${resp.status_code}  200
     @{resp}=  ResetProviderPassword  ${PUSERNAME_U1}  ${PASSWORD}  2
     Should Be Equal As Strings  ${resp[0].status_code}  200
     Should Be Equal As Strings  ${resp[1].status_code}  200
     ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=  Waitlist Apply Internal Status  ${wid}  ${internal_sts_name1}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    422
     Should Be Equal As Strings  "${resp.json()}"  "${STATUS_ALREADY_APPLIED}"

JD-TC-WaitlistApplyInternalSts-UH2
     [Documentation]  Apply Internal statuses when user has no permission for internal Status
     ${resp}=  Encrypted Provider Login  ${HLPUSERNAME21}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${resp}=  Waitlist Apply Internal Status  ${wid}  ${internal_sts_name2}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    422
     Should Be Equal As Strings  "${resp.json()}"  "${NOT_SERVICE_STATUS}"

JD-TC-WaitlistApplyInternalSts-UH3
     [Documentation]  Apply Internal statuses when user has no permission for internal Status
     ${resp}=  SendProviderResetMail   ${PUSERNAME_U2}
     Should Be Equal As Strings  ${resp.status_code}  200
     @{resp}=  ResetProviderPassword  ${PUSERNAME_U2}  ${PASSWORD}  2
     Should Be Equal As Strings  ${resp[0].status_code}  200
     Should Be Equal As Strings  ${resp[1].status_code}  200
     ${resp}=  Encrypted Provider Login  ${PUSERNAME_U2}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=  Waitlist Apply Internal Status  ${wid}  ${internal_sts_name1}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    422
     Should Be Equal As Strings  "${resp.json()}"  "${NOT_USER_STATUS}"

JD-TC-WaitlistApplyInternalSts-UH4
     [Documentation]  User again apply already applied status
     ${resp}=  Encrypted Provider Login  ${HLPUSERNAME21}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${resp}=  Waitlist Apply Internal Status  ${wid}  ${internal_sts_name1}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    422
     Should Be Equal As Strings  "${resp.json()}"  "${STATUS_ALREADY_APPLIED}"

JD-TC-WaitlistApplyInternalSts-UH5
     [Documentation]  User aaply invalid status
     ${resp}=  Encrypted Provider Login  ${HLPUSERNAME21}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${invalid_sts}=  FakerLibrary.name
     ${resp}=  Waitlist Apply Internal Status  ${wid}  ${invalid_sts}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    422
     Should Be Equal As Strings  "${resp.json()}"  "${NOT_SERVICE_STATUS}"
     
JD-TC-WaitlistApplyInternalSts-4
     [Documentation]  Apply Internal statuses when team has permission
     ${resp}=  Encrypted Provider Login  ${HLPUSERNAME21}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${user_ids}=  Create List  ${u_id1}
     ${resp}=   Assign Team To User  ${user_ids}  ${t_id1}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${user_ids1}=  Create List  ${u_id2}
     Set Suite Variable  ${user_ids1}
     ${permission1}=  InternalStatuses_permissions  ${user_ids1}  ${empty_list}  ${t_id1}
     Set Suite Variable  ${permission1}
     ${permission2}=  InternalStatuses_permissions  ${user_ids2}  ${empty_list}
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
     ${statuses}=  Setting InternalStatuses  ${sts1}  ${sts2}
     ${sts}=  json.dumps  ${statuses}
     Log  ${sts}
     Set Suite Variable  ${sts}
     ${internal_sts}=  MultiUser_InternalStatus  ${sts}  ${pid}

     ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=  AddCustomer  ${CUSERNAME5}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${cid}  ${resp.json()}

     ${desc}=   FakerLibrary.word
     ${resp}=  Add To Waitlist By User  ${cid}  ${s_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${u_id1}  ${cid}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${wid3}=  Get Dictionary Values  ${resp.json()}
     Set Suite Variable  ${wid3}  ${wid3[0]}

     ${resp}=  Waitlist Apply Internal Status  ${wid3}  ${internal_sts_name1}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${resp}=  Encrypted Provider Login  ${HLPUSERNAME21}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${resp}=  Get Waitlist By Id  ${wid3} 
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response  ${resp}  internalStatus=${internal_sts_dis_name1}

     ${resp}=  Encrypted Provider Login  ${HLPUSERNAME21}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Waitlist Apply Internal Status  ${wid3}  ${internal_sts_name1}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    422
     Should Be Equal As Strings  "${resp.json()}"  "${STATUS_ALREADY_APPLIED}"

JD-TC-WaitlistApplyInternalSts -UH6
     [Documentation]   Provider apply internal sts without login      
     ${resp}=  Waitlist Apply Internal Status  ${wid3}  ${internal_sts_name1}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  419
     Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}"
 
JD-TC-WaitlistApplyInternalSts -UH7
    [Documentation]   Consumer apply internal sts
    ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200  
    ${resp}=  Waitlist Apply Internal Status  ${wid3}  ${internal_sts_name1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"
