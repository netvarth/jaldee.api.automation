*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Appointment AddBatchName
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
${prefix}       serviceBatch
${suffix}       serving

*** Test Cases ***  
JD-TC-Add Appointment Batch Name-1
    [Documentation]   Adding Appointment Batch Name
    
    ${resp}=  Provider Login  ${PUSERNAME39}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_service   ${PUSERNAME39}
    clear_location  ${PUSERNAME39}
    
    ${lid}=  Create Sample Location
    ${s_id}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable   ${s_id}
    clear_appt_schedule   ${PUSERNAME39}
    ${DAY1}=  get_date
    Set Suite Variable   ${DAY1}
    ${DAY2}=  add_date  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_time  0  15
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable   ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    Set Suite Variable   ${parallel}
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool[1]}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=   Disable Batch For Appointment    ${sch_id}
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}      ${bool[1]}

    ${resp}=    Add Appmt Batch Name    ${sch_id}   ${prefix}   ${suffix}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}      ${bool[1]}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  parallelServing=${parallel}   batchEnable=${bool[0]}
    Should Be Equal As Strings  ${resp.json()['batchName']['prefix']}    ${prefix}
    Should Be Equal As Strings  ${resp.json()['batchName']['suffix']}    ${suffix}

JD-TC-Add Appointment Batch Name-2
    [Documentation]   Prefix is Empty when Adding Appointment Batch Name
    
    ${resp}=  Provider Login  ${PUSERNAME39}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Add Appmt Batch Name    ${sch_id}   ${Empty}   ${suffix}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}      ${bool[1]}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  parallelServing=${parallel}   batchEnable=${bool[0]}
    Should Be Equal As Strings  ${resp.json()['batchName']['prefix']}    ${Empty}
    Should Be Equal As Strings  ${resp.json()['batchName']['suffix']}    ${suffix}

JD-TC-Add Appointment Batch Name-3
    [Documentation]   Suffix is Empty when Adding Appointment Batch Name
    
    ${resp}=  Provider Login  ${PUSERNAME39}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Add Appmt Batch Name    ${sch_id}   ${prefix}   ${Empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}      ${bool[1]}
    
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  parallelServing=${parallel}   batchEnable=${bool[0]}
    Should Be Equal As Strings  ${resp.json()['batchName']['prefix']}    ${prefix}
    Should Be Equal As Strings  ${resp.json()['batchName']['suffix']}    ${Empty}

JD-TC-Add Appointment Batch Name-UH1
    [Documentation]   SchedulId is Zero when Adding Appointment Batch Name
    
    ${resp}=  Provider Login  ${PUSERNAME39}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Add Appmt Batch Name    0   ${prefix}   ${suffix}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  404
    Should Be Equal As Strings  "${resp.json()}"    "${APPT_SCHEDULE_NOT_FOUND}"
    
JD-TC-Add Appointment Batch Name-UH2
    [Documentation]   Adding Appointment Batch Name with another Provider login
    
    ${resp}=  Provider Login  ${PUSERNAME50}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Add Appmt Batch Name    ${sch_id}   ${prefix}   ${suffix}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"    "${NO_PERMISSION}"

JD-TC-Add Appointment Batch Name-UH3
    [Documentation]   Without Provider login

    ${resp}=    Add Appmt Batch Name    ${sch_id}   ${prefix}   ${suffix}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"    "${SESSION_EXPIRED}"

JD-TC-Add Appointment Batch Name-UH4
    [Documentation]   With Consumer login
    ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Add Appmt Batch Name    ${sch_id}   ${prefix}   ${suffix}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"