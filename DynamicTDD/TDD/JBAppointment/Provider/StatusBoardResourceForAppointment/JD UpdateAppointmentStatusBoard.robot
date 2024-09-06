*** Settings ***

Suite Teardown  Delete All Sessions
Test Teardown   Delete All Sessions
Force Tags      StatusBoard
Library         Collections
Library         String
Library         json
Library         FakerLibrary
Resource        /ebs/TDD/ProviderKeywords.robot
Resource        /ebs/TDD/ConsumerKeywords.robot
Variables       /ebs/TDD/varfiles/providers.py
Variables       /ebs/TDD/varfiles/consumerlist.py 

*** Variables ***
${SERVICE1}     Radio Repdca111
${SERVICE2}     Radio Repdca123
${SERVICE3}     Radio Repdca222

*** Test Cases ***
JD-TC-UpdateAppointmentStatusBoard-1

    [Documentation]    Update a StatusBoard for Appointment using service id
    ${resp}=  Encrypted Provider Login  ${PUSERNAME97}  ${PASSWORD} 
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_service   ${PUSERNAME97}
    clear_location  ${PUSERNAME97}
    clear_Addon  ${PUSERNAME97}
    ${s_id1}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable  ${s_id1}
    ${s_id2}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable  ${s_id2}
    ${lid1}=  Create Sample Location  

    ${resp}=   Get Location ById  ${lid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2} 
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list} 
    ${sTime1}=  add_timezone_time  ${tz}  1  30  
    Set Suite Variable   ${sTime1}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    Set Suite Variable  ${delta}
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    Set Suite Variable   ${eTime1}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}

    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid1}  ${duration}  ${bool1}   ${s_id1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    
    ${Addon_id}=  get_statusboard_addonId
    ${resp}=  Add addon  ${Addon_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200  

    ${order1}=   Random Int   min=0   max=1
    ${Values}=  FakerLibrary.Words  	nb=3

    ${fieldList}=  Create Fieldlist For QueueSet  ${Values[0]}  ${Values[1]}  ${Values[2]}  ${bool[0]}  ${order1}
    Log  ${fieldList}
    Set Suite Variable   ${fieldList}
    ${service_list}=  Create list  ${s_id1}
    Set Suite Variable  ${service_list}  
    ${s_name}=  FakerLibrary.Words  nb=2
    ${s_desc}=  FakerLibrary.Sentence
    ${serr}=  Create Dictionary  id=${s_id1}
    ${ser}=  Create List   ${serr} 
    ${dep}=  Create List   
    ${appt_sh}=   Create Dictionary  id=${sch_id}
    ${appt_shd}=    Create List   ${appt_sh}
    ${app_status}=    Create List   ${apptStatus[2]}
    ${resp}=  Create Appointment QueueSet for Provider   ${s_name[0]}  ${s_name[1]}   ${s_desc}   ${fieldList}    ${ser}     ${EMPTY}   ${EMPTY}    ${appt_shd}    ${app_status}         ${statusboard_type[0]}   ${service_list}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sba_id1}  ${resp.json()}

    ${Positions}=  FakerLibrary.Words  	nb=3
    ${matric_list}=  Create Metric For Status Board  ${Positions[0]}  ${sba_id1}  
    Log  ${matric_list}
    ${Data}=  FakerLibrary.Words  	nb=3
    
    ${resp}=   Create Status Board Appointment    ${Data[0]}  ${Data[1]}  ${Data[2]}  ${matric_list}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sb_id}  ${resp.json()}

    ${service_list}=  Create list  ${s_id2}
    Set Suite Variable  ${service_list}  
    ${s_name1}=  FakerLibrary.Words  nb=2
    ${s_desc1}=  FakerLibrary.Sentence
    ${serr}=  Create Dictionary  id=${s_id2}
    ${ser}=  Create List   ${serr} 
    ${dep}=  Create List   
    ${appt_sh}=   Create Dictionary  id=${sch_id}
    ${appt_shd}=    Create List   ${appt_sh}
    ${app_status}=    Create List   ${apptStatus[2]}

    ${resp}=  Create Appointment QueueSet for Provider   ${s_name1[0]}  ${s_name1[1]}   ${s_desc1}   ${fieldList}   ${ser}     ${EMPTY}   ${EMPTY}    ${appt_shd}    ${app_status}         ${statusboard_type[0]}   ${service_list}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sba_id2}  ${resp.json()}

    ${Positions1}=  FakerLibrary.Words  	nb=3
    ${matric_list1}=  Create Metric For Status Board  ${Positions1[0]}  ${sba_id2}  
    Log  ${matric_list1}
    Set Suite Variable   ${matric_list1}
    ${Data1}=  FakerLibrary.Words  	nb=3
    Set Suite Variable  ${Data1}  
    
    ${resp}=  Update Status Board Appoinment   ${sb_id}  ${Data1[0]}  ${Data1[1]}  ${Data1[2]}  ${matric_list1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appoinment StatusBoard By Id   ${sb_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}  ${sb_id}
    Should Be Equal As Strings  ${resp.json()['name']}  ${Data1[0]}
    Should Be Equal As Strings  ${resp.json()['displayName']}  ${Data1[1]}
    Should Be Equal As Strings  ${resp.json()['layout']}  ${Data1[2]}
    Should Be Equal As Strings  ${resp.json()['metric'][0]['sbId']}  ${sba_id2}  
    Should Be Equal As Strings  ${resp.json()['metric'][0]['position']}  ${Positions1[0]} 
    Should Be Equal As Strings  ${resp.json()['metric'][0]['queueSet']['name']}   ${s_name1[0]} 
    Should Be Equal As Strings  ${resp.json()['metric'][0]['queueSet']['displayName']}   ${s_name1[1]}  
    Should Be Equal As Strings  ${resp.json()['metric'][0]['queueSet']['queueSetFor'][0]['type']}   ${statusboard_type[0]}
    Should Be Equal As Strings  ${resp.json()['metric'][0]['queueSet']['qBoardConditions']['services'][0]['id']}    ${s_id2}
    Should Be Equal As Strings  ${resp.json()['metric'][0]['queueSet']['qBoardConditions']['apptSchedule'][0]['id']}    ${sch_id}
    Should Be Equal As Strings  ${resp.json()['metric'][0]['queueSet']['queryString']}    service-eq=${s_id2}&schedule-eq=${sch_id}&apptStatus-eq=Arrived&label-eq=::

JD-TC-UpdateAppointmentStatusBoard -UH1
    [Documentation]   Provider update a Status Board without login  
    ${resp}=  Update Status Board Appoinment  ${sb_id}  ${Data1[0]}  ${Data1[1]}  ${Data1[2]}  ${matric_list1}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}"
 
JD-TC-UpdateAppointmentStatusBoard -UH2
    [Documentation]   Consumer trying to update a Status Board
    ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Update Status Board Appoinment  ${sb_id}  ${Data1[0]}  ${Data1[1]}  ${Data1[2]}  ${matric_list1}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-UpdateAppointmentStatusBoard-UH3
    [Documentation]  Upadte a Status Board which is not exist
    ${resp}=  Encrypted Provider Login  ${PUSERNAME8}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${invalid_id}=   Random Int   min=-10   max=0
    ${resp}=  Update Status Board Appoinment  ${invalid_id}  ${Data1[0]}  ${Data1[1]}  ${Data1[2]}  ${matric_list1}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${STATUS_BOARD_DIMENSION_NOT_EXIST}"

JD-TC-UpdateAppointmentStatusBoard-UH4
    [Documentation]  Upadte a Status Board by id of another provider
    ${resp}=  Encrypted Provider Login  ${PUSERNAME10}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Update Status Board Appoinment  ${sb_id}  ${Data1[0]}  ${Data1[1]}  ${Data1[2]}  ${matric_list1}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${STATUS_BOARD_DIMENSION_NOT_EXIST}"

JD-TC-UpdateAppointmentStatusBoard-UH5
    [Documentation]  After deletion of a status board, provider trying to Upadte it
    ${resp}=  Encrypted Provider Login  ${PUSERNAME97}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Delete Appointment Status Board By Id    ${sb_id}   
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Status Board Appoinment  ${sb_id}  ${Data1[0]}  ${Data1[1]}  ${Data1[2]}  ${matric_list1}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${STATUS_BOARD_DIMENSION_NOT_EXIST}"