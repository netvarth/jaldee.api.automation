*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        License
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/hl_musers.py

*** Variables ***
@{color}   00FF95   f0f0f0  



*** Test Cases ***

JD-TC-AddOrUpdate UserStyle -1
      [Documentation]  Update License Package with valid data
   ${resp}=  Encrypted Provider Login  ${HLMUSERNAME7}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pro_id}  ${decrypted_data['id']}
    # Set Test Variable  ${pro_id}  ${resp.json()['id']}

    ${pid_B}=  get_acc_id  ${HLMUSERNAME7}
    Set Suite Variable  ${pid_B}


    ${resp2}=   Get Business Profile
    Log  ${resp2.json()}
    Should Be Equal As Strings    ${resp2.status_code}    200
    Set Suite Variable  ${sub_domain_id}  ${resp2.json()['serviceSubSector']['id']}
  
    clear_service   ${HLMUSERNAME7}
    clear_appt_schedule   ${HLMUSERNAME7}
    clear_customer   ${HLMUSERNAME7}

    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    
    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Run Keyword If  ${resp.json()['filterByDept']}==${bool[0]}   Toggle Department Enable
    Run Keyword If  '${resp}' != '${None}'   Log   ${resp.json()}
    Run Keyword If  '${resp}' != '${None}'   Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}

    # ${resp}=  Get Departments
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # IF   '${resp.content}' == '${emptylist}'
        ${dep_name1}=  FakerLibrary.bs
        ${dep_code1}=   Random Int  min=100   max=999
        ${dep_desc1}=   FakerLibrary.word  
        ${resp1}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${dep_id}  ${resp1.json()}
    # ELSE
    #     Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    # END

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END

    ${resp}=  Get Departments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}

    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    IF   not '${resp.content}' == '${emptylist}'
        ${len}=  Get Length  ${resp.json()}
    END
    FOR   ${i}  IN RANGE   0   ${len}
       
        Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
        IF   not '${user_phone}' == '${HLMUSERNAME7}'
            clear_users  ${user_phone}
        END
    END
     
    ${ph1}=  Evaluate  ${HLMUSERNAME7}+1000260000
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    # ${pin}=  get_pincode
     # ${resp}=  Get LocationsByPincode     ${pin}
     FOR    ${i}    IN RANGE    3
        ${pin}=  get_pincode
        ${kwstatus}  ${resp} =  Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
     END
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${whpnum}=  Evaluate  ${HLMUSERNAME7}+336245
    ${tlgnum}=  Evaluate  ${HLMUSERNAME7}+336345

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${ph1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${ph1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${whpnum}  ${countryCodes[0]}  ${tlgnum}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id1}  ${resp.json()}

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddOrUpdate UserStyle  ${u_id1}  ${color[0]}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp1}=  Get StyleConfig   userId-eq=${u_id1}   
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Should Be Equal As Strings  ${resp1.json()[0]['styleType']}  ${styleconfig[1]} 
    Should Be Equal As Strings  ${resp1.json()[0]['configJson'][0]['userid']}  ${u_id1}
    Should Be Equal As Strings  ${resp1.json()[0]['configJson'][0]['color']}   ${color[0]}  
    Should Be Equal As Strings  ${resp1.json()[0]['status']}  ${toggle[0]}


JD-TC-AddOrUpdate dashboardStyle -1
      [Documentation]  Update License Package with valid data
   ${resp}=  Encrypted Provider Login  ${HLMUSERNAME7}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${defaultBookingView}=   FakerLibrary.word

    ${action1}=   FakerLibrary.name
    ${action2}=   FakerLibrary.firstname
    ${action3}=    FakerLibrary.lastName
    ${dashboardActions}=  Create List   ${action1}  ${action2}  ${action3}

    ${resp}=  AddOrUpdate DashboardStyle  ${u_id1}  ${defaultBookingView}   ${dashboardActions}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp1}=  Get StyleConfig   styleType-eq=${styleconfig[0]}  
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Should Be Equal As Strings  ${resp1.json()[0]['styleType']}  ${styleconfig[0]} 
    Should Be Equal As Strings  ${resp1.json()[0]['configJson'][0]['userid']}  ${u_id1}
    Should Be Equal As Strings  ${resp1.json()[0]['configJson'][0]['dashboardActions'][0]}   ${action1}  
    Should Be Equal As Strings  ${resp1.json()[0]['configJson'][0]['dashboardActions'][1]}   ${action2}  
    Should Be Equal As Strings  ${resp1.json()[0]['configJson'][0]['dashboardActions'][2]}   ${action3} 
    Should Be Equal As Strings  ${resp1.json()[0]['configJson'][0]['defaultBookingView']}   ${defaultBookingView}   
    Should Be Equal As Strings  ${resp1.json()[0]['status']}  ${toggle[0]}

    ${resp1}=  Get StyleConfig   userId-eq=${u_id1}    styleType-eq=${styleconfig[1]} 
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Should Be Equal As Strings  ${resp1.json()[0]['styleType']}  ${styleconfig[1]} 
    Should Be Equal As Strings  ${resp1.json()[0]['configJson'][0]['userid']}  ${u_id1}
    Should Be Equal As Strings  ${resp1.json()[0]['configJson'][0]['color']}   ${color[0]}  
    Should Be Equal As Strings  ${resp1.json()[0]['status']}  ${toggle[0]}


