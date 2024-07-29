*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Appointment
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 

*** Variables ***

${SERVICE6111}         Raigan


*** Keywords ***


*** Test Cases ***

Appointment Details
    [Documentation]                 Provider takes appointment details
    ${resp}=                        Consumer Login  ${CUSERNAME8}  ${PASSWORD}
    Log                             ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}    200
    Set Suite Variable              ${jdconID}   ${resp.json()['id']}
    Set Suite Variable              ${fname}   ${resp.json()['firstName']}
    Set Suite Variable              ${lname}   ${resp.json()['lastName']}

    ${resp}=                        Consumer Logout
    Log                             ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}    200
    
    ${resp}=                      Encrypted Provider Login  ${PUSERNAME77}  ${PASSWORD}
    Log                             ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}    200
    
    ${resp}=                        Get Service
    Log                             ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=                        Get Locations
    Log                             ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=                        Get Appointment Settings
    Log                             ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Run Keyword If                  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    clear_service                   ${PUSERNAME77}
    clear_location                  ${PUSERNAME77}
    clear_customer                  ${PUSERNAME77}

    ${resp}=                        Get Service
    Log                             ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=                        Get Locations
    Log                             ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=                        Get jaldeeIntegration Settings
    Log                             ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=                        Get Business Profile
    Log                             ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable               ${pid}  ${resp.json()['id']} 

    ${resp}=                        Get Appointment Settings
    Log                             ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Should Be Equal As Strings      ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings      ${resp.json()['enableToday']}   ${bool[1]}  

    ${lid}=                         Create Sample Location  
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    clear_appt_schedule             ${PUSERNAME77}
    
    ${DAY1}=                        db.get_date_by_timezone  ${tz}
    ${DAY2}=                        db.add_timezone_date  ${tz}  10        
    ${list}=                        Create List  1  2  3  4  5  6  7
    ${sTime1}=                      db.get_time_by_timezone  ${tz}
    ${delta}=                       FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=                      add_two   ${sTime1}  ${delta}
    ${s_id}=                        Create Sample Service  ${SERVICE6111}
    ${schedule_name}=               FakerLibrary.bs
    ${parallel}=                    FakerLibrary.Random Int  min=1  max=10
    ${maxval}=                      Convert To Integer   ${delta/2}
    ${duration}=                    FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=                       Random Element  ${bool}
    ${resp}=                        Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log                             ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable               ${sch_id}  ${resp.json()}

    ${resp}=                        Get Appointment Schedule ById  ${sch_id}
    Log                             ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Verify Response                 ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=                        Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log                             ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Verify Response                 ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable               ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=                        AddCustomer  ${CUSERNAME8}  firstName=${fname}   lastName=${lname}
    Log                             ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable               ${cid}   ${resp.json()}
    
    ${apptfor1}=                    Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=                     Create List  ${apptfor1}
    
    ${cnote}=                       FakerLibrary.word
    ${resp}=                        Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log                             ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${apptid}=                      Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable               ${apptid1}  ${apptid[0]}

*** Comments ***
#Get appointment details url commented from dev side

    ${resp}=  Get Appointment Details with apptid   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


