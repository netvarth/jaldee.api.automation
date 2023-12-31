*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Appointment ScheduleCount
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
${SERVICE1}     Consultation
${SERVICE2}     AvailableNow
${SERVICE3}     NEWYEAR
${SERVICE4}     MYBIRTHDAY 
${prefix}       serviceBatch
${suffix}       serving
${Apptstat}     ENABLED  DISABLED
${start}        110

*** Test Cases ***  
JD-TC-Get Appointment Schedule Count-1
    [Documentation]   Get Appointment Schedule Count a valid Provider

    ${resp}=   Get File    /ebs/TDD/varfiles/providers.py
    ${len}=   Split to lines  ${resp}
    ${length}=  Get Length   ${len}
    ${licId}  ${licname}=  get_highest_license_pkg
    FOR   ${a}  IN RANGE   ${start}  ${length}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME${a}}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable   ${pkgId}  ${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    ${domain}=   Set Variable    ${decrypted_data['sector']}
    ${subdomain}=    Set Variable      ${decrypted_data['subSector']}
    # ${domain}=   Set Variable    ${resp.json()['sector']}
    # ${subdomain}=    Set Variable      ${resp.json()['subSector']}
    ${resp2}=   Get Domain Settings    ${domain}  
    Should Be Equal As Strings    ${resp.status_code}    200
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${check}  ${resp2.json()['multipleLocation']}
    Run Keyword If  "${check}"=="True" and "${pkgId}"=="${licId}"  Exit For Loop
    END
    Set Suite Variable  ${a}
    clear_service   ${PUSERNAME${a}}
    clear_location  ${PUSERNAME${a}}
    
    ${lid}=  Create Sample Location
    Set Suite Variable  ${lid}
    clear_appt_schedule   ${PUSERNAME${a}}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appointment Schedules
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${s_id}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable   ${s_id}
    ${s_id2}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable   ${s_id2}
    ${s_id3}=  Create Sample Service  ${SERVICE3}
    Set Suite Variable   ${s_id3}
    ${s_id4}=  Create Sample Service  ${SERVICE4}
    Set Suite Variable   ${s_id4}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${eTime1}=  add_timezone_time  ${tz}  0  30  
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable   ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    Set Suite Variable   ${parallel}
    ${duration}=   Random Int  min=2  max=10
    Set Suite Variable   ${duration} 
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool[1]}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id1}   name=${schedule_name}  parallelServing=${parallel}   batchEnable=${bool[1]}

    ${sTime1}=  add_timezone_time  ${tz}  1  35
    ${delta}=  FakerLibrary.Random Int  min=10  max=25
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name2}=  FakerLibrary.bs
    Set Suite Variable   ${schedule_name2}
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${resp}=  Create Appointment Schedule  ${schedule_name2}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool[1]}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id2}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id2}   name=${schedule_name2}  parallelServing=${parallel}   batchEnable=${bool[1]}

    ${sTime1}=  add_timezone_time  ${tz}  2  05  
    ${delta}=  FakerLibrary.Random Int  min=10  max=25
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name3}=  FakerLibrary.bs
    Set Suite Variable   ${schedule_name3}
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${resp}=  Create Appointment Schedule  ${schedule_name3}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool[1]}  ${s_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id3}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id3}   name=${schedule_name3}  parallelServing=${parallel}   batchEnable=${bool[1]}

    ${sTime1}=  add_timezone_time  ${tz}  2  35
    ${delta}=  FakerLibrary.Random Int  min=10  max=25
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name4}=  FakerLibrary.bs
    Set Suite Variable   ${schedule_name4}
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${resp}=  Create Appointment Schedule  ${schedule_name4}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool[1]}  ${s_id4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id4}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id4}   name=${schedule_name4}  parallelServing=${parallel}   batchEnable=${bool[1]}

    ${resp}=    Get Appointment Schedule Count
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}      4

    ${resp}=  Get Appointment Schedules
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${sch_id4}
    Should Be Equal As Strings  ${resp.json()[1]['id']}   ${sch_id3}
    Should Be Equal As Strings  ${resp.json()[2]['id']}   ${sch_id2}
    Should Be Equal As Strings  ${resp.json()[3]['id']}   ${sch_id1}  

JD-TC-Get Appointment Schedule Count-2
    [Documentation]   Get Appointment Schedule Count of Schedule Id

    ${resp}=  Encrypted Provider Login  ${PUSERNAME${a}}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Appointment Schedule Count       id-eq=${sch_id4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}      1

JD-TC-Get Appointment Schedule Count-3
    [Documentation]   Get Appointment Schedule Count of schedule Name

    ${resp}=  Encrypted Provider Login  ${PUSERNAME${a}}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Appointment Schedule Count       name-eq=${schedule_name4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}      1

JD-TC-Get Appointment Schedule Count-4
    [Documentation]   Another Provider Login

    ${resp}=  Encrypted Provider Login  ${PUSERNAME201}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Appointment Schedule Count
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()}     0

JD-TC-Get Appointment Schedule Count-UH1
    [Documentation]   Get Appointment Schedule Count of apptState

    ${resp}=  Encrypted Provider Login  ${PUSERNAME${a}}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Appointment Schedule Count       apptState-eq=${Apptstat[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  400
    Should Be Equal As Strings  "${resp.json()}"      "${FILTER_ERROR}"

JD-TC-Get Appointment Schedule Count-UH2
    [Documentation]   Get Appointment Schedule Count of parallelServing

    ${resp}=  Encrypted Provider Login  ${PUSERNAME${a}}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Appointment Schedule Count       parallelServing=${parallel}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  400
    Should Be Equal As Strings  "${resp.json()}"      "${FILTER_ERROR}"

JD-TC-Get Appointment Schedule Count-UH3
    [Documentation]   Without Provider Login

    ${resp}=    Get Appointment Schedule Count       name-eq=${schedule_name4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}"

JD-TC-Get Appointment Schedule Count-UH4
    [Documentation]   With Consumer Login
    ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Appointment Schedule Count       name-eq=${schedule_name4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"

