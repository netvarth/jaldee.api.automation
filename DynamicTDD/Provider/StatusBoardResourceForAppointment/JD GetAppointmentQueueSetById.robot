*** Settings ***

Suite Teardown  Delete All Sessions
Test Teardown   Delete All Sessions
Force Tags      QueueSet
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

*** Keywords ***
check corp
    [Arguments]   ${domlen}   ${subdomlen}  ${iscorpval}
    FOR  ${i}  IN RANGE  ${subdomlen}
        Set Suite Variable  ${sd}  ${domresp.json()[${domlen}]['subDomains'][${i}]['subDomain']} 
        ${is_corp}=  check_is_corp  ${sd}
        Log  ${is_corp}
        Exit For Loop If  '${is_corp}' == '${iscorpval}'
    END
    [Return]   ${is_corp}

*** Test Cases ***
JD-TC-GetAppointmentQueueSetById-1

    [Documentation]    Create a Appointment QueueSet for Service and appointment schedule for provider
    ${domresp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${domresp.status_code}  200
    Set Suite Variable  ${domresp}
    ${domlen}=  Get Length  ${domresp.json()}
    ${len}=  Evaluate  ${domlen}-1
    FOR  ${i}  IN RANGE  ${len}
        Set Suite Variable  ${d1}  ${domresp.json()[${len}]['domain']}  
        ${sublen}=    Get Length  ${domresp.json()[${len}]['subDomains']}
        # Set Suite Variable  ${sd}  ${domresp.json()[${len}]['subDomains'][0]['subDomain']} 
        ${corp}=  check corp  ${len}   ${sublen}   False
        Exit For Loop If  '${corp}' == 'False'
        ${len}=  Evaluate  ${len}-1
    END 
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_M}=  Evaluate  ${PUSERNAME}+9634
    ${pkg_id}=   get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd}  ${PUSERNAME_M}   ${pkg_id[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_M}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_M}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_M}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERNAME_M}${\n}
    Set Suite Variable  ${PUSERNAME_M}  

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${result}=  Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment
    Log   ${result.json()}
    Should Be Equal As Strings  ${result.status_code}  200


    ${s_id1}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable  ${s_id1}
    ${lid1}=  Create Sample Location  

    ${resp}=   Get Location ById  ${lid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

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

    # ${resp}=  Toggle Department Enable
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${dep_name1}=  FakerLibrary.bs
    # Set Suite Variable   ${dep_name1}
    # ${dep_code1}=   Random Int  min=100   max=999
    # Set Suite Variable   ${dep_code1}
    # ${dep_desc}=   FakerLibrary.word  
    # Set Suite Variable    ${dep_desc}
    # ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc}   ${s_id1}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${depid1}  ${resp.json()}

    ${Addon_id}=  get_statusboard_addonId
    ${resp}=  Add addon  ${Addon_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200  

    ${order1}=   Random Int   min=0   max=1
    ${Values}=  FakerLibrary.Words  	nb=3

    ${fieldList}=  Create Fieldlist For QueueSet  ${Values[0]}  ${Values[1]}  ${Values[2]}  ${bool[0]}  ${order1}
    Log  ${fieldList}
    ${s_name11}=  FakerLibrary.Words  nb=2
    Set Suite Variable  ${s_name11}
    ${s_desc11}=  FakerLibrary.Sentence
    Set Suite Variable   ${s_desc11} 
   
    ${service_list11}=  Create list  ${s_id1}
    Set Suite Variable   ${service_list11}  
    
    # ${department_list11}=  Create List  ${depid1}
    # Set Suite Variable   ${department_list11}   

    
    ${ss}=   Create Dictionary  id=${s_id1} 
    ${ser}=  Create List  ${ss}
    # ${dept1}=   Create Dictionary  departmentId=${depid1}
    # ${dep}=  Create List   ${dept1}
    ${appt_sh}=   Create Dictionary  id=${sch_id}
    ${appt_shd}=    Create List   ${appt_sh}
    ${app_status}=    Create List   ${apptStatus[2]}
    ${resp}=  Create Appointment QueueSet for Provider   ${s_name11[0]}  ${s_name11[1]}   ${s_desc11}   ${fieldList}   ${ser}     ${EMPTY}   ${EMPTY}    ${appt_shd}    ${app_status}       ${statusboard_type[0]}   ${service_list11}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sba_id1}  ${resp.json()}
  
    ${resp}=  Get AppointmentQueueSet By Id   ${sba_id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}  ${sba_id1}
    Should Be Equal As Strings  ${resp.json()['name']}  ${s_name11[0]}
    Should Be Equal As Strings  ${resp.json()['displayName']}  ${s_name11[1]}
    Should Be Equal As Strings  ${resp.json()['description']}  ${s_desc11}
    Should Be Equal As Strings  ${resp.json()['fieldList'][0]['name']}  ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()['fieldList'][0]['label']}  ${bool[0]}   
    Should Be Equal As Strings  ${resp.json()['fieldList'][0]['order']}  ${order1}   
    Should Be Equal As Strings  ${resp.json()['fieldList'][0]['displayName']}  ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()['fieldList'][0]['defaultValue']}  ${Values[2]}  
    Should Be Equal As Strings  ${resp.json()['queueSetFor'][0]['type']}   ${statusboard_type[0]}
    # Should Be Equal As Strings  ${resp.json()['queueSetFor'][1]['type']}   ${statusboard_type[2]}
    # Should Be Equal As Strings  ${resp.json()['qBoardConditions']['departments'][0]['departmentId']}   ${depid1}  
    Should Be Equal As Strings  ${resp.json()['qBoardConditions']['services'][0]['id']}   ${s_id1}
    Should Be Equal As Strings  ${resp.json()['qBoardConditions']['apptSchedule'][0]['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['queryString']}  service-eq=${s_id1}&schedule-eq=${sch_id}&apptStatus-eq=Arrived&label-eq=::

JD-TC-GetAppointmentQueueSetById-2

    [Documentation]    Create a Appointment QueueSet for Service ,department and appointment schedule for branch
    ${domresp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${domlen}=  Get Length  ${domresp.json()}
    ${len}=  Evaluate  ${domlen}-1
    FOR  ${i}  IN RANGE  ${len}
        Set Suite Variable  ${d1}  ${domresp.json()[${len}]['domain']}  
        ${sublen}=    Get Length  ${domresp.json()[${len}]['subDomains']}
        # Set Suite Variable  ${sd}  ${domresp.json()[${len}]['subDomains'][0]['subDomain']} 
        ${corp}=  check corp  ${len}   ${sublen}   True
        Exit For Loop If  '${corp}' == 'True'
        ${len}=  Evaluate  ${len}-1
    END 
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${MUSERNAME_M}=  Evaluate  ${MUSERNAME}+9638
    ${pkg_id}=   get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd}  ${MUSERNAME_M}   ${pkg_id[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${MUSERNAME_M}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${MUSERNAME_M}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_M}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${MUSERNAME_M}${\n}
    Set Suite Variable  ${MUSERNAME_M}  

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${result}=  Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment
    Log   ${result.json()}
    Should Be Equal As Strings  ${result.status_code}  200


    ${s_id1}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable  ${s_id1}
    ${lid1}=  Create Sample Location  

    ${resp}=   Get Location ById  ${lid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

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

    ${resp}=  Toggle Department Enable
    Should Be Equal As Strings  ${resp.status_code}  200
    ${dep_name1}=  FakerLibrary.bs
    Set Suite Variable   ${dep_name1}
    ${dep_code1}=   Random Int  min=100   max=999
    Set Suite Variable   ${dep_code1}
    ${dep_desc}=   FakerLibrary.word  
    Set Suite Variable    ${dep_desc}
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc}   ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${depid1}  ${resp.json()}

    ${Addon_id}=  get_statusboard_addonId
    ${resp}=  Add addon  ${Addon_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200  

    ${order1}=   Random Int   min=0   max=1
    ${Values}=  FakerLibrary.Words  	nb=3

    ${fieldList}=  Create Fieldlist For QueueSet  ${Values[0]}  ${Values[1]}  ${Values[2]}  ${bool[0]}  ${order1}
    Log  ${fieldList}
    ${s_name11}=  FakerLibrary.Words  nb=2
    Set Suite Variable  ${s_name11}
    ${s_desc11}=  FakerLibrary.Sentence
    Set Suite Variable   ${s_desc11} 
   
    ${service_list11}=  Create list  ${s_id1}
    Set Suite Variable   ${service_list11}  
    
    ${department_list11}=  Create List  ${depid1}
    Set Suite Variable   ${department_list11}   

    
    ${ss}=   Create Dictionary  id=${s_id1} 
    ${ser}=  Create List  ${ss}
    ${dept1}=   Create Dictionary  departmentId=${depid1}
    ${dep}=  Create List   ${dept1}
    ${appt_sh}=   Create Dictionary  id=${sch_id}
    ${appt_shd}=    Create List   ${appt_sh}
    ${app_status}=    Create List   ${apptStatus[2]}
    ${resp}=  Create Appointment QueueSet for Branch   ${s_name11[0]}  ${s_name11[1]}   ${s_desc11}   ${fieldList}   ${dep}   ${ser}     ${EMPTY}   ${EMPTY}    ${appt_shd}    ${app_status}       ${statusboard_type[0]}   ${service_list11}      ${statusboard_type[2]}   ${department_list11}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sba_id2}  ${resp.json()}
  
    ${resp}=  Get AppointmentQueueSet By Id   ${sba_id2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}  ${sba_id2}
    Should Be Equal As Strings  ${resp.json()['name']}  ${s_name11[0]}
    Should Be Equal As Strings  ${resp.json()['displayName']}  ${s_name11[1]}
    Should Be Equal As Strings  ${resp.json()['description']}  ${s_desc11}
    Should Be Equal As Strings  ${resp.json()['fieldList'][0]['name']}  ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()['fieldList'][0]['label']}  ${bool[0]}   
    Should Be Equal As Strings  ${resp.json()['fieldList'][0]['order']}  ${order1}   
    Should Be Equal As Strings  ${resp.json()['fieldList'][0]['displayName']}  ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()['fieldList'][0]['defaultValue']}  ${Values[2]}  
    Should Be Equal As Strings  ${resp.json()['queueSetFor'][0]['type']}   ${statusboard_type[0]}
    Should Be Equal As Strings  ${resp.json()['queueSetFor'][1]['type']}   ${statusboard_type[2]}
    Should Be Equal As Strings  ${resp.json()['qBoardConditions']['departments'][0]['departmentId']}   ${depid1}  
    Should Be Equal As Strings  ${resp.json()['qBoardConditions']['services'][0]['id']}   ${s_id1}
    Should Be Equal As Strings  ${resp.json()['qBoardConditions']['apptSchedule'][0]['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['queryString']}   department-eq=${depid1}&service-eq=${s_id1}&schedule-eq=${sch_id}&apptStatus-eq=Arrived&label-eq=::

JD-TC-GetAppointmentQueueSetById-UH1

    [Documentation]  Provider get a Appointment QueueSet without login
    ${resp}=  Get AppointmentQueueSet By Id   ${sba_id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}"

JD-TC-GetAppointmentQueueSetById-UH2

    [Documentation]   Consumer get a WaitlistQueueSet
    ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Get AppointmentQueueSet By Id   ${sba_id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"


JD-TC-GetAppointmentQueueSetById-UH3

    [Documentation]  Get a Waitlist QueueSet by id which is not exist
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_M}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${invalid_id}=   Random Int   min=-10   max=0
    ${resp}=  Get AppointmentQueueSet By Id   ${invalid_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${QUEUE_SET_NOT_EXIST}"


JD-TC-GetAppointmentQueueSetById-UH4

    [Documentation]  Get a QueueSet by id of another provider
    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get AppointmentQueueSet By Id   ${sba_id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${QUEUE_SET_NOT_EXIST}"
