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
Variables         /ebs/TDD/varfiles/consumermail.py
Variables         /ebs/TDD/varfiles/hl_providers.py

*** Variables ***

${SERVICE1}     Radio Repdca111
${SERVICE2}     Radio Repdca123
${SERVICE3}     Radio Repdca222

*** Test Cases ***

JD-TC-CreateStatusBoardAppoinment-1

    [Documentation]    Create a StatusBoard for Appointment using service id

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME45}  ${PASSWORD} 
    Should Be Equal As Strings  ${resp.status_code}  200

    # clear_service   ${HLPUSERNAME45}
    # clear_location  ${HLPUSERNAME45}
    clear_Addon  ${HLPUSERNAME45}

    ${s_id1}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable  ${s_id1}
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

    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid1}  ${duration}  ${bool1}   ${s_id1}
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
    Set Suite Variable   ${s_name}
    ${s_desc}=  FakerLibrary.Sentence
    ${serr}=  Create Dictionary  id=${s_id1}
    ${ser}=  Create List   ${serr} 
    ${dep}=  Create List   
    ${appt_sh}=   Create Dictionary  id=${sch_id}
    ${appt_shd}=    Create List   ${appt_sh}
    ${app_status}=    Create List   ${apptStatus[2]}
    ${resp}=  Create Appointment QueueSet for Provider   ${s_name[0]}  ${s_name[1]}   ${s_desc}   ${fieldList}   ${ser}     ${EMPTY}   ${EMPTY}    ${appt_shd}    ${app_status}         ${statusboard_type[0]}   ${service_list}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sba_id1}  ${resp.json()}

    ${Positions}=  FakerLibrary.Words  	nb=3
    ${matric_list}=  Create Metric For Status Board  ${Positions[0]}  ${sba_id1}  
    Log  ${matric_list}
    ${Data}=  FakerLibrary.Words  	nb=3
    Set Suite Variable  ${Data12}  ${Data}

    ${resp}=   Create Status Board Appointment    ${Data[0]}  ${Data[1]}  ${Data[2]}  ${matric_list}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sb_id}  ${resp.json()}

    ${resp}=  Get Appoinment StatusBoard By Id   ${sb_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}  ${sb_id}
    Should Be Equal As Strings  ${resp.json()['name']}  ${Data[0]}
    Should Be Equal As Strings  ${resp.json()['displayName']}  ${Data[1]}
    Should Be Equal As Strings  ${resp.json()['layout']}  ${Data[2]}
    Should Be Equal As Strings  ${resp.json()['metric'][0]['sbId']}  ${sba_id1}  
    Should Be Equal As Strings  ${resp.json()['metric'][0]['position']}  ${Positions[0]} 
    Should Be Equal As Strings  ${resp.json()['metric'][0]['queueSet']['name']}   ${s_name[0]} 
    Should Be Equal As Strings  ${resp.json()['metric'][0]['queueSet']['displayName']}   ${s_name[1]}  
    Should Be Equal As Strings  ${resp.json()['metric'][0]['queueSet']['queueSetFor'][0]['type']}   ${statusboard_type[0]}
    Should Be Equal As Strings  ${resp.json()['metric'][0]['queueSet']['qBoardConditions']['services'][0]['id']}    ${s_id1} 
    Should Be Equal As Strings  ${resp.json()['metric'][0]['queueSet']['qBoardConditions']['apptSchedule'][0]['id']}    ${sch_id}
    Should Be Equal As Strings  ${resp.json()['metric'][0]['queueSet']['queryString']}    service-eq=${s_id1}&schedule-eq=${sch_id}&apptStatus-eq=Arrived&label-eq=::

JD-TC-CreateStatusBoardAppoinment-2

    [Documentation]  Create a another StatusBoard  for a appoinment queueset that has a status board 

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME46}  ${PASSWORD} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${Addon_id}=  get_statusboard_addonId
    ${resp}=  Add addon  ${Addon_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200  
    ${Positions}=  FakerLibrary.Words  	nb=3
    ${matric_list}=  Create Metric For Status Board  ${Positions[0]}  ${sba_id1}  
    Log  ${matric_list}
    Set Suite Variable   ${matric_list}
    ${Data}=  FakerLibrary.Words  	nb=3
    Set Suite Variable  ${Data11}   ${Data}

    ${resp}=   Create Status Board Appointment     ${Data[0]}  ${Data[1]}  ${Data[2]}  ${matric_list}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sb_id}  ${resp.json()}

    ${resp}=  Get Appoinment StatusBoard By Id  ${sb_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}  ${sb_id}
    Should Be Equal As Strings  ${resp.json()['name']}  ${Data[0]}
    Should Be Equal As Strings  ${resp.json()['displayName']}  ${Data[1]}
    Should Be Equal As Strings  ${resp.json()['layout']}  ${Data[2]}
    Should Be Equal As Strings  ${resp.json()['metric'][0]['sbId']}  ${sba_id1}  
    Should Be Equal As Strings  ${resp.json()['metric'][0]['position']}  ${Positions[0]} 
    Should Be Equal As Strings  ${resp.json()['metric'][0]['queueSet']['name']}   ${s_name[0]} 
    Should Be Equal As Strings  ${resp.json()['metric'][0]['queueSet']['displayName']}   ${s_name[1]}  
    Should Be Equal As Strings  ${resp.json()['metric'][0]['queueSet']['queueSetFor'][0]['type']}   ${statusboard_type[0]}
    Should Be Equal As Strings  ${resp.json()['metric'][0]['queueSet']['qBoardConditions']['services'][0]['id']}    ${s_id1}
    Should Be Equal As Strings  ${resp.json()['metric'][0]['queueSet']['qBoardConditions']['apptSchedule'][0]['id']}    ${sch_id}
    Should Be Equal As Strings  ${resp.json()['metric'][0]['queueSet']['queryString']}    service-eq=${s_id1}&schedule-eq=${sch_id}&apptStatus-eq=Arrived&label-eq=::

JD-TC-CreateStatusBoardAppoinment-UH1

    [Documentation]   Provider create a appoinment StatusBoard without login  

    ${Data}=  FakerLibrary.Words  	nb=3
    ${resp}=  Create Status Board Appointment  ${Data[0]}  ${Data[1]}  ${Data[2]}  ${matric_list}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}"

JD-TC-CreateStatusBoardAppoinment -UH2

    [Documentation]   Consumer create a Appoinment StatusBoard

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME45}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${pid}=  get_acc_id  ${HLPUSERNAME45}

    ${resp}=  AddCustomer  ${CUSERNAME21}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${CUSERNAME21}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${CUSERNAME21}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME21}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${Data}=  FakerLibrary.Words  	nb=3
    ${resp}=  Create Status Board Appointment  ${Data[0]}  ${Data[1]}  ${Data[2]}  ${matric_list}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-CreateStatusBoardAppoinment-UH3

    [Documentation]  Create a Appoinment StatusBoard which is already created

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME45}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Create Status Board Appointment  ${Data12[0]}  ${Data12[1]}  ${Data12[2]}  ${matric_list}
    Should Be Equal As Strings  ${resp.status_code}  422
    Log  ${resp.json()}
    Should Be Equal As Strings  "${resp.json()}"  "${STATUS_BOARD_DIMENSION_NAME_ALREADY_EXIST}"

JD-TC-CreateStatusBoardAppoinment-UH4

    [Documentation]  Create a StatusBoard with invalid appoinment queue set id

    ${resp}=  Encrypted Provider Login  ${PUSERNAME162}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    # clear_service   ${PUSERNAME162}
    # clear_location  ${PUSERNAME162}
    clear_Statusboard  ${PUSERNAME162}
    clear_Addon  ${PUSERNAME162}
    ${s_id1}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable  ${s_id1}
    ${Addon_id}=  get_statusboard_addonId
    ${resp}=  Add addon  ${Addon_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${Positions}=  FakerLibrary.Words  	nb=3
    ${invalid_id}=   Random Int   min=-10   max=-1
    ${matric_list}=  Create Metric For Status Board  ${Positions[0]}  ${invalid_id}
    Log  ${matric_list}
    ${Data}=  FakerLibrary.Words  	nb=3
    ${resp}=  Create Status Board Appointment  ${Data[0]}  ${Data[1]}  ${Data[2]}  ${matric_list}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${QUEUE_SET_NOT_EXIST}"

# JD-TC-CreateStatusBoardAppoinment-UH5

#     [Documentation]  Create a Appoinment StatusBoard with empty metric list
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME171}  ${PASSWORD}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     # clear_service   ${PUSERNAME171}
#     # clear_location  ${PUSERNAME171}
#     clear_Statusboard  ${PUSERNAME171}
#     clear_Addon  ${PUSERNAME171}
#     ${Addon_id}=  get_statusboard_addonId
#     ${resp}=  Add addon  ${Addon_id}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}   200  
#     ${matric_list}=  Create Metric For Status Board  ${EMPTY}
#     ${Data}=  FakerLibrary.Words  	nb=3
#     ${resp}=  Create Status Board waitlist  ${Data[0]}  ${Data[1]}  ${Data[2]}  ${matric_list}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  422
#     Should Be Equal As Strings  "${resp.json()}"  "${STATUS_BOARD_METRIC_NOT_EMPTY}"


JD-TC-CreateStatusBoardAppoinment-UH6

    ${required_lic}    Random Element     ['Basic','Premium','Team','Enterprise','jaldee_lite']

    ${PUSERNAMEA}=  Provider with license  ${required_lic}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAMEA}  ${PASSWORD} 
    Should Be Equal As Strings  ${resp.status_code}  200
    # clear_service   ${PUSERNAMEA}
    # clear_location  ${PUSERNAMEA}
    clear_Addon  ${PUSERNAMEA}

    ${resp}=   Get Active License
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${lic1}  ${resp.json()['accountLicense']['licPkgOrAddonId']}

    ${s_id1}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable  ${s_id1}
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

    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid1}  ${duration}  ${bool1}   ${s_id1}
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

    # ${dept1}=   Create Dictionary  departmentId=${depid1}
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
    
    ${resp}=   Create Status Board Appointment    ${EMPTY}  ${Data[1]}  ${Data[2]}  ${matric_list}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${STATUS_BOARD_NAME_NOT_EMPTY}"

JD-TC-CreateStatusBoardAppoinment-UH7

    [Documentation]    Create a StatusBoard with empty status board layout
    
    ${required_lic}    Random Element    ['Basic','Premium','Team','Enterprise','jaldee_lite']

    ${PUSERNAMEA}=  Provider with license  ${required_lic}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAMEA}  ${PASSWORD} 
    Should Be Equal As Strings  ${resp.status_code}  200
    # clear_service   ${PUSERNAMEA}
    # clear_location  ${PUSERNAMEA}
    clear_Addon  ${PUSERNAMEA}
    ${s_id1}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable  ${s_id1}
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

    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid1}  ${duration}  ${bool1}   ${s_id1}
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
    # ${dep}=  Create List   
    ${appt_sh}=   Create Dictionary  id=${sch_id}
    ${appt_shd}=    Create List   ${appt_sh}
    ${app_status}=    Create List   ${apptStatus[2]}
    ${resp}=  Create Appointment QueueSet for Provider   ${s_name[0]}  ${s_name[1]}   ${s_desc}   ${fieldList}     ${ser}     ${EMPTY}   ${EMPTY}    ${appt_shd}    ${app_status}         ${statusboard_type[0]}   ${service_list}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sba_id1}  ${resp.json()}

    ${Positions}=  FakerLibrary.Words  	nb=3
    ${matric_list}=  Create Metric For Status Board  ${Positions[0]}  ${sba_id1}  
    Log  ${matric_list}
    ${Data}=  FakerLibrary.Words  	nb=3
    
    ${resp}=   Create Status Board Appointment    ${Data[0]}  ${Data[1]}  ${EMPTY}  ${matric_list}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${STATUS_BOARD_LAYOUT_NOT_EMPTY}"

JD-TC-CreateStatusBoardAppoinment-UH8

    [Documentation]  Create a StatusBoard with empty status board display name
    
    ${required_lic}    Random Element    ['Basic','Premium','Team','Enterprise','jaldee_lite']

    ${PUSERNAMEA}=  Provider with license  ${required_lic}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAMEA}  ${PASSWORD} 
    Should Be Equal As Strings  ${resp.status_code}  200
    # clear_service   ${PUSERNAMEA}
    # clear_location  ${PUSERNAMEA}
    clear_Addon  ${PUSERNAMEA}
    ${s_id1}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable  ${s_id1}
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

    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid1}  ${duration}  ${bool1}   ${s_id1}
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
    # ${dep}=  Create List   
    ${appt_sh}=   Create Dictionary  id=${sch_id}
    ${appt_shd}=    Create List   ${appt_sh}
    ${app_status}=    Create List   ${apptStatus[2]}
    ${resp}=  Create Appointment QueueSet for Provider   ${s_name[0]}  ${s_name[1]}   ${s_desc}   ${fieldList}     ${ser}     ${EMPTY}   ${EMPTY}    ${appt_shd}    ${app_status}         ${statusboard_type[0]}   ${service_list}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sba_id1}  ${resp.json()}

    ${Positions}=  FakerLibrary.Words  	nb=3
    ${matric_list}=  Create Metric For Status Board  ${Positions[0]}  ${sba_id1}  
    Log  ${matric_list}
    ${Data}=  FakerLibrary.Words  	nb=3
    ${resp}=  Create Status Board waitlist  ${Data[0]}  ${EMPTY}  ${Data[1]}  ${matric_list}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${STATUS_BOARD_DISPLAY_NAME_NOT_EMPTY}"



    