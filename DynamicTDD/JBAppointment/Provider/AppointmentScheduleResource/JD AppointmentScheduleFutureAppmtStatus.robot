*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        FutureAppmt Status
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py


*** Variables ***
${SERVICE1}     Scannings111 
${SERVICE2}     Scanning
${self}         0
${prefix}       serviceBatch
${suffix}       serving

*** Test Cases ***  
JD-TC-Appointment Schedule FutureAppmt Status-1
    [Documentation]   Future Appointment schedule Status is True
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME52}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_service   ${PUSERNAME52}
    clear_location  ${PUSERNAME52} 

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}    ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['futureAppt']}    ${bool[1]} 
    
    ${lid}=  Create Sample Location
    ${s_id}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable   ${s_id}

    clear_appt_schedule   ${PUSERNAME52}
    ${DAY1}=  db.add_timezone_date  ${tz}  4  
    Set Suite Variable   ${DAY1}    
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable   ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool[1]}  ${s_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  todayAppt=${bool[1]}   futureAppt=${bool[1]}

    ${resp}=    Enable Future Appointment By Schedule Id    ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}      ${bool[1]}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  todayAppt=${bool[1]}  futureAppt=${bool[1]}
   
JD-TC-Appointment Schedule FutureAppmt Status-2
    [Documentation]   Set Future Appointment Schedule status is False
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME52}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Disable Future Appointment By Schedule Ids    ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}      ${bool[1]}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  todayAppt=${bool[1]}   futureAppt=${bool[0]}

JD-TC-Appointment Schedule FutureAppmt Status-UH1
    [Documentation]   Future Appmt is Disable and trying Future Appointment Schedule status is False,
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME52}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Disable Future Appointment
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()}      ${bool[1]}

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}    ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['futureAppt']}    ${bool[0]} 

    ${resp}=    Enable Future Appointment By Schedule Id    ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${SAME_DAY_APPT_ALREADY_OFF}"

JD-TC-Appointment Schedule FutureAppmt Status-UH2
    [Documentation]   Another Provider Login and Another Schedule
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME52}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Disable Future Appointment By Schedule Ids   0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  404
    Should Be Equal As Strings  "${resp.json()}"      "${APPT_SCHEDULE_NOT_FOUND}"

JD-TC-Appointment Schedule FutureAppmt Status-UH3
    [Documentation]   With Provider Another Login
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME13}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Enable Future Appointment By Schedule Id    ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"      "${NO_PERMISSION}"

JD-TC-Appointment Schedule FutureAppmt Status-UH4
    [Documentation]   With Consumer Login
    
    ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Enable Future Appointment By Schedule Id    ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-Appointment Schedule FutureAppmt Status-UH5
    [Documentation]   Without Provider Login

    ${resp}=    Enable Future Appointment By Schedule Id    ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"      "${SESSION_EXPIRED}"

