*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Appointment  
Library           FakerLibrary
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           random
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/hl_providers.py

*** Variables ***

${SERVICE1}  manicure 
${SERVICE2}  pedicure

*** Test Cases ***

JD-TC-Get Appointment schedules-1

    [Documentation]  Get appointment schedule by id

    ${resp}=  Encrypted Provider Login  ${PUSERNAME192}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    # clear_service   ${PUSERNAME192}
    # clear_location  ${PUSERNAME192}
    clear_service   ${PUSERNAME192}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    clear_appt_schedule   ${PUSERNAME192}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedules
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    # ${lid}=  Create Sample Location
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedules  id-eq=${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  id=${sch_id}   name=${schedule_name}

JD-TC-Get Appointment schedules-2

    [Documentation]  Get appointment schedule by location

    ${resp}=  Encrypted Provider Login  ${PUSERNAME192}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    # clear_service   ${PUSERNAME192}
    # clear_location  ${PUSERNAME192}
    clear_service   ${PUSERNAME192}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    clear_appt_schedule   ${PUSERNAME192}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedules
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    # ${lid}=  Create Sample Location
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedules  location-eq=${lid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  id=${sch_id}   name=${schedule_name}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}  ${lid}

JD-TC-Get Appointment schedules-3

    [Documentation]  Get appointment schedule by state

    ${resp}=  Encrypted Provider Login  ${PUSERNAME192}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    # clear_service   ${PUSERNAME192}
    # clear_location  ${PUSERNAME192}
    clear_service   ${PUSERNAME192}
   
    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    clear_appt_schedule   ${PUSERNAME192}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedules
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    # ${lid}=  Create Sample Location
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedules  state-eq=${Qstate[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  id=${sch_id}   name=${schedule_name}   apptState=${Qstate[0]}

JD-TC-Get Appointment schedules-4

    [Documentation]  Get appointment schedule by provider

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME9}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}

    ${domain}=   Set Variable    ${decrypted_data['sector']}
    ${subdomain}=    Set Variable      ${decrypted_data['subSector']}
    # ${subdomain}=    Set Variable      ${resp.json()['subSector']}
    
    ${resp2}=   Get Business Profile
    Log  ${resp2.json()}
    Should Be Equal As Strings    ${resp2.status_code}    200
    # Set Suite Variable  ${sub_domain_id}  ${resp2.json()['serviceSubSector']['id']}

    ${resp}=  Get Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    
    sleep  2s
    ${dep_name1}=  FakerLibrary.bs
    ${dep_code1}=   Random Int  min=100   max=999
    ${dep_desc1}=   FakerLibrary.word  
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id}  ${resp.json()}

    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF   not '${resp.content}' == '${emptylist}'
        ${len}=  Get Length  ${resp.json()}
        FOR   ${i}  IN RANGE   0   ${len}
            Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
            IF   not '${user_phone}' == '${HLPUSERNAME9}'
                clear_users  ${user_phone}
            END
        END
    END

    ${PUSERPH0}=  Evaluate  ${PUSERNAME}+345
    clear_users  ${PUSERPH0}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    # ${pin}=  get_pincode

    # ${resp}=  Get LocationsByPincode     ${pin}
    FOR    ${i}    IN RANGE    3
        ${pin}=  get_pincode
        ${kwstatus}  ${resp} = 	Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
    END
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${city}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Test Variable  ${state}  ${resp.json()[0]['PostOffice'][0]['State']}      
    Set Test Variable  ${pin1}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    


    ${whpnum}=  Evaluate  ${PUSERPH0}+576245
    ${tlgnum}=  Evaluate  ${PUSERPH0}+576345

    ${resp}=  Create User  ${firstname}  ${lastname}     ${countryCodes[0]}  ${PUSERPH0}    ${userType[0]}   dob=${dob}  gender=${Genderlist[0]}  email=${P_Email}${PUSERPH0}.${test_mail}   pincode=${pin}    deptId=${dep_id}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id}  ${resp.json()}
    
    ${resp}=  Get User By Id  ${u_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    # ${lid}=  Create Sample Location
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}

    ${s_id}=  Create Sample Service For User  ${SERVICE1}  ${dep_id}  ${u_id}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule   ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}  provider=${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedules  provider-eq=${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  id=${sch_id}   name=${schedule_name}   apptState=${Qstate[0]}

JD-TC-Get Appointment schedules-5

    [Documentation]  Get appointment schedule by batch

    ${resp}=  Encrypted Provider Login  ${PUSERNAME192}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    # clear_service   ${PUSERNAME192}
    # clear_location  ${PUSERNAME192}
    clear_service   ${PUSERNAME192}
   
    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    clear_appt_schedule   ${PUSERNAME192}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedules
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    # ${lid}=  Create Sample Location
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedules  batch-eq=${bool1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  id=${sch_id}   name=${schedule_name}   batchEnable=${bool1}

JD-TC-Get Appointment schedules-6
    [Documentation]  Get appointment schedule by name

    ${resp}=  Encrypted Provider Login  ${PUSERNAME192}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    # clear_service   ${PUSERNAME192}
    # clear_location  ${PUSERNAME192}
    clear_service   ${PUSERNAME192}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    clear_appt_schedule   ${PUSERNAME192}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedules
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    # ${lid}=  Create Sample Location
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedules  name-eq=${schedule_name}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  id=${sch_id}   name=${schedule_name}

JD-TC-Get Appointment schedules-7
    [Documentation]  Get appointment schedule without filter

    ${resp}=  Encrypted Provider Login  ${PUSERNAME192}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    # clear_service   ${PUSERNAME192}
    # clear_location  ${PUSERNAME192}
    clear_service   ${PUSERNAME192}
   
    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    clear_appt_schedule   ${PUSERNAME192}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedules
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    # ${lid}=  Create Sample Location
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedules
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  id=${sch_id}   name=${schedule_name}

JD-TC-Get Appointment schedules-UH1
    [Documentation]  Get appointment schedule without login
    
    ${resp}=  Get Appointment Schedules
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}"

JD-TC-Get Appointment schedules-UH2

    [Documentation]  Get appointment schedule with consumer login

    ${resp}=  Encrypted Provider Login  ${PUSERNAME192}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']} 

    ${resp}=  AddCustomer  ${CUSERNAME37}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${CUSERNAME37}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${CUSERNAME37}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME37}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Appointment Schedules   something-eq=something
    Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"
    
JD-TC-Get Appointment schedules-UH3
    [Documentation]  Get appointment schedule with invalid filter

    ${resp}=  Encrypted Provider Login  ${PUSERNAME192}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedules   something-eq=something
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  400
    Should Be Equal As Strings  "${resp.json()}"   "${FILTER_ERROR}"

