*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Run Keywords     Delete All Sessions
...               AND           Remove File  cookies.txt
Force Tags        Appointment
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/consumermail.py

*** Variables ***
${SERVICE1}  manicure 
${SERVICE2}  pedicure
${self}     0
${digits}       0123456789
${jpgfile}     /ebs/TDD/uploadimage.jpg
${pngfile}     /ebs/TDD/upload.png
${pdffile}     /ebs/TDD/sample.pdf
${bookinglink}   <a href='http://localhost:8080/jaldee/status/{}' target='_blank' class='link'>{}</a>

*** Test Cases ***

JD-TC-AppointmentCommunication-1

    [Documentation]  Send appointment comunication message to consumer without attachment
    # ${weekday}=  get_timezone_weekday  ${tz}
    ${resp}=  Consumer Login  ${CUSERNAME26}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}
    Set Test Variable  ${uname}   ${resp.json()['userName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME188}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${p_id}  ${resp.json()['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${bsname}  ${resp.json()['businessName']}
    
    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    ${resp1}=   Run Keyword If  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    clear_service   ${PUSERNAME188}
    clear_location  ${PUSERNAME188}
    clear_appt_schedule   ${PUSERNAME188}
    clear_consumer_msgs  ${CUSERNAME26}
    clear_provider_msgs  ${PUSERNAME188}
    clear_customer   ${PUSERNAME188}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}    
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${lid}=  Create Sample Location
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  AddCustomer  ${CUSERNAME26}   firstName=${fname}  lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid1}  appmtDate=${DAY1}   appmtTime=${slot1}  appointmentEncId=${encId}  apptStatus=${apptStatus[2]}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    # Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname}
    # Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    sleep  01s

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME188}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    @{fileswithcaption}=  Create List   ${EMPTY}
    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Imageupload.PAppmntComm   ${cookie}  ${apptid1}  ${msg}  ${messageType[0]}  ${EMPTY}  ${EMPTY}  ${EMPTY}  
    Log  ${resp}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Messages
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${confirmAppt_push}=  Set Variable   ${resp.json()['confirmationMessages']['SP_APP']} 

    ${bookingid}=  Format String  ${bookinglink}  ${encId}  ${encId}
    ${defconfirm_msg}=  Replace String  ${confirmAppt_push}  [consumer]   ${uname}
    ${defconfirm_msg}=  Replace String  ${defconfirm_msg}  [bookingId]   ${encId}

    # ${date}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y
    # ${converted_slot}=  convert_slot_12hr  ${slot1} 
    # log    ${converted_slot}
    # ${defconfirm_msg}=  Replace String  ${confirmAppt_push}  [username]   ${uname} 
    # ${defconfirm_msg}=  Replace String  ${defconfirm_msg}  [service]   ${SERVICE1}
    # ${defconfirm_msg}=  Replace String  ${defconfirm_msg}  [date]   ${date}
    # ${defconfirm_msg}=  Replace String  ${defconfirm_msg}  [time]   ${converted_slot}
    # ${defconfirm_msg}=  Replace String  ${defconfirm_msg}  [providerName]   ${bsname}

    
    
    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${apptid1}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${defconfirm_msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     ${jdconID}

    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}         ${apptid1}
    Should Be Equal As Strings  ${resp.json()[1]['msg']}                ${msg}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}     ${jdconID}
    Should Not Contain   ${resp.json()[1]}   attachements

    ${resp}=  Consumer Login  ${CUSERNAME26}   ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${apptid1}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${defconfirm_msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     ${jdconID} 

    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}         ${apptid1}
    Should Be Equal As Strings  ${resp.json()[1]['msg']}                ${msg}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}     ${jdconID} 
    Should Not Contain   ${resp.json()[0]}   attachements

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200 

# *** Test Cases ***
# *** Comments ***

JD-TC-AppointmentCommunication-2
    [Documentation]  Send appointment comunication message to consumer with attachment
    ${resp}=  Consumer Login  ${CUSERNAME26}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}
    Set Test Variable  ${uname}   ${resp.json()['userName']}
    

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME188}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${p_id}  ${resp.json()['id']}
    
    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    ${resp1}=   Run Keyword If  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    clear_service   ${PUSERNAME188}
    clear_location  ${PUSERNAME188}
    clear_appt_schedule   ${PUSERNAME188}
    clear_consumer_msgs  ${CUSERNAME26}
    clear_provider_msgs  ${PUSERNAME188}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   

    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}    
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${lid}=  Create Sample Location
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME26}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()[0]['id']}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid1}  appmtDate=${DAY1}   appmtTime=${slot1}  appointmentEncId=${encId}  apptStatus=${apptStatus[2]}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    # Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname}
    # Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep  01s

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME188}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${caption1}=  Fakerlibrary.sentence
    ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
    @{fileswithcaption}=  Create List   ${filecap_dict1}
    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Imageupload.PAppmntComm   ${cookie}  ${apptid1}  ${msg}  ${messageType[0]}  ${caption1}  ${EMPTY}  ${jpgfile}  
    Log  ${resp}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${date}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y
    # ${converted_slot}=  convert_slot_12hr  ${slot1} 
    # log    ${converted_slot}
    # ${defconfirm_msg}=  Replace String  ${confirmAppt_push}  [username]   ${uname} 
    # ${defconfirm_msg}=  Replace String  ${defconfirm_msg}  [service]   ${SERVICE1}
    # ${defconfirm_msg}=  Replace String  ${defconfirm_msg}  [date]   ${date}
    # ${defconfirm_msg}=  Replace String  ${defconfirm_msg}  [time]   ${converted_slot}
    # ${defconfirm_msg}=  Replace String  ${defconfirm_msg}  [providerName]   ${bsname}

    ${resp}=  Get Appointment Messages
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${confirmAppt_push}=  Set Variable   ${resp.json()['confirmationMessages']['SP_APP']} 

    ${bookingid}=  Format String  ${bookinglink}  ${encId}  ${encId}
    ${defconfirm_msg}=  Replace String  ${confirmAppt_push}  [consumer]   ${uname}
    ${defconfirm_msg}=  Replace String  ${defconfirm_msg}  [bookingId]   ${encId}
    
    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${apptid1}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${defconfirm_msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     ${jdconID}

    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}         ${apptid1}
    Should Be Equal As Strings  ${resp.json()[1]['msg']}                ${msg}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}     ${jdconID}
    Should Contain 	${resp.json()[1]}   attachements
    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][0]}   s3path
    Should Contain  ${resp.json()[1]['attachements'][0]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][0]}   thumbPath
    Should Contain  ${resp.json()[1]['attachements'][0]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[1]['attachements'][0]['caption']}     ${caption1}

    ${resp}=  Consumer Login  ${CUSERNAME26}   ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${apptid1}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${defconfirm_msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     ${jdconID} 

    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}         ${apptid1}
    Should Be Equal As Strings  ${resp.json()[1]['msg']}                ${msg}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}     ${jdconID}
    Should Contain 	${resp.json()[1]}   attachements
    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][0]}   s3path
    Should Contain  ${resp.json()[1]['attachements'][0]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][0]}   thumbPath
    Should Contain  ${resp.json()[1]['attachements'][0]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[1]['attachements'][0]['caption']}     ${caption1} 

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200 

# *** Comments ***

JD-TC-AppointmentCommunication-3
    [Documentation]  Send appointment comunication message to consumer with multiple files using file types jpeg, png and pdf
    ${resp}=  Consumer Login  ${CUSERNAME26}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}
    Set Test Variable  ${uname}   ${resp.json()['userName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME188}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${p_id}  ${resp.json()['id']}
    
    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    ${resp1}=   Run Keyword If  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    clear_service   ${PUSERNAME188}
    clear_location  ${PUSERNAME188}
    clear_appt_schedule   ${PUSERNAME188}
    clear_consumer_msgs  ${CUSERNAME26}
    clear_provider_msgs  ${PUSERNAME188}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}    
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${lid}=  Create Sample Location
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME26}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()[0]['id']}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid1}  appmtDate=${DAY1}   appmtTime=${slot1}  appointmentEncId=${encId}  apptStatus=${apptStatus[2]}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    # Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname}
    # Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME188}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${caption1}=  Fakerlibrary.sentence
    ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
    ${caption2}=  Fakerlibrary.sentence
    ${filecap_dict2}=  Create Dictionary   file=${pngfile}   caption=${caption2}
    ${caption3}=  Fakerlibrary.sentence
    ${filecap_dict3}=  Create Dictionary   file=${pdffile}   caption=${caption3}
    @{fileswithcaption}=  Create List   ${filecap_dict1}   ${filecap_dict2}  ${filecap_dict3}

    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Imageupload.PAppmntCommMultiFile   ${cookie}  ${apptid1}  ${msg}  ${messageType[0]}  ${EMPTY}  @{fileswithcaption}
    Log  ${resp}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Messages
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${confirmAppt_push}=  Set Variable   ${resp.json()['confirmationMessages']['SP_APP']} 

    ${bookingid}=  Format String  ${bookinglink}  ${encId}  ${encId}
    ${defconfirm_msg}=  Replace String  ${confirmAppt_push}  [consumer]   ${uname}
    ${defconfirm_msg}=  Replace String  ${defconfirm_msg}  [bookingId]   ${encId}

    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${apptid1}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${defconfirm_msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     ${jdconID}

    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}         ${apptid1}
    Should Be Equal As Strings  ${resp.json()[1]['msg']}                ${msg}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}     ${jdconID}

    Should Contain 	${resp.json()[1]}   attachements
    ${attachment-len}=  Get Length  ${resp.json()[1]['attachements']}
    Should Be Equal As Strings  ${attachment-len}  3

    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][0]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][0]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption1}

    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .pdf
    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption2}

    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption3}

    ${resp}=  Consumer Login  ${CUSERNAME26}   ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${apptid1}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${defconfirm_msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     ${jdconID}

    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}         ${apptid1}
    Should Be Equal As Strings  ${resp.json()[1]['msg']}                ${msg}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}     ${jdconID} 

    ${attachment-len}=  Get Length  ${resp.json()[1]['attachements']}
    Should Be Equal As Strings  ${attachment-len}  3
    
    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][0]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][0]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption1}

    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .pdf
    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption2}

    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][2]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][2]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption3}

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200 

JD-TC-AppointmentCommunication-4
    [Documentation]  Send appointment comunication message to consumer with attachment but without caption
    ${resp}=  Consumer Login  ${CUSERNAME26}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}
    Set Test Variable  ${uname}   ${resp.json()['userName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME188}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${p_id}  ${resp.json()['id']}
    
    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    ${resp1}=   Run Keyword If  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    clear_service   ${PUSERNAME188}
    clear_location  ${PUSERNAME188}
    clear_appt_schedule   ${PUSERNAME188}
    clear_consumer_msgs  ${CUSERNAME26}
    clear_provider_msgs  ${PUSERNAME188}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}    
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${lid}=  Create Sample Location
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME26}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()[0]['id']}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid1}  appmtDate=${DAY1}   appmtTime=${slot1}  appointmentEncId=${encId}  apptStatus=${apptStatus[2]}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    # Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname}
    # Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME188}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    # ${caption1}=  Fakerlibrary.sentence
    ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${EMPTY}
    @{fileswithcaption}=  Create List   ${filecap_dict1}
    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Imageupload.PAppmntComm   ${cookie}  ${apptid1}  ${msg}  ${messageType[0]}  ${EMPTY}  ${EMPTY}  ${jpgfile}  
    Log  ${resp}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Messages
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${confirmAppt_push}=  Set Variable   ${resp.json()['confirmationMessages']['SP_APP']} 

    ${bookingid}=  Format String  ${bookinglink}  ${encId}  ${encId}
    ${defconfirm_msg}=  Replace String  ${confirmAppt_push}  [consumer]   ${uname}
    ${defconfirm_msg}=  Replace String  ${defconfirm_msg}  [bookingId]   ${encId}

    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${apptid1}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${defconfirm_msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     ${jdconID}

    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}         ${apptid1}
    Should Be Equal As Strings  ${resp.json()[1]['msg']}                ${msg}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}     ${jdconID}

    Should Contain 	${resp.json()[1]}   attachements
    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][0]}   s3path
    Should Contain  ${resp.json()[1]['attachements'][0]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][0]}   thumbPath
    Should Contain  ${resp.json()[1]['attachements'][0]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[1]['attachements'][0]['caption']}     ${None}

    ${resp}=  Consumer Login  ${CUSERNAME26}   ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${apptid1}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${defconfirm_msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     ${jdconID}

    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}         ${apptid1}
    Should Be Equal As Strings  ${resp.json()[1]['msg']}                ${msg}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}     ${jdconID} 

    Should Contain 	${resp.json()[1]}   attachements
    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][0]}   s3path
    Should Contain  ${resp.json()[1]['attachements'][0]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][0]}   thumbPath
    Should Contain  ${resp.json()[1]['attachements'][0]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[1]['attachements'][0]['caption']}     ${None}

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-AppointmentCommunication-5
    [Documentation]  Send appointment comunication message to consumer after staring appointment
    ${resp}=  Consumer Login  ${CUSERNAME26}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}
    Set Test Variable  ${uname}   ${resp.json()['userName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME188}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${p_id}  ${resp.json()['id']}
    
    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    ${resp1}=   Run Keyword If  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    clear_service   ${PUSERNAME188}
    clear_location  ${PUSERNAME188}
    clear_appt_schedule   ${PUSERNAME188}
    clear_consumer_msgs  ${CUSERNAME26}
    clear_provider_msgs  ${PUSERNAME188}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}    
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${lid}=  Create Sample Location
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME26}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()[0]['id']}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid1}  appmtDate=${DAY1}   appmtTime=${slot1}  appointmentEncId=${encId}  apptStatus=${apptStatus[2]}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    # Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname}
    # Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${resp}=  Appointment Action   ${apptStatus[3]}   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep  01s

    ${resp}=  Get Appointment Status   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[0]['appointmentStatus']}   ${apptStatus[3]}
    Should Contain  "${resp.json()}"  ${apptStatus[3]}

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME188}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Appointment Messages
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${confirmAppt_push}=  Set Variable   ${resp.json()['confirmationMessages']['SP_APP']} 

    ${bookingid}=  Format String  ${bookinglink}  ${encId}  ${encId}
    ${defconfirm_msg}=  Replace String  ${confirmAppt_push}  [consumer]   ${uname}
    ${defconfirm_msg}=  Replace String  ${defconfirm_msg}  [bookingId]   ${encId}

    ${caption1}=  Fakerlibrary.sentence
    ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
    @{fileswithcaption}=  Create List   ${filecap_dict1}
    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Imageupload.PAppmntComm   ${cookie}  ${apptid1}  ${msg}  ${messageType[0]}  ${caption1}  ${EMPTY}  ${jpgfile}  
    Log  ${resp}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${apptid1}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${defconfirm_msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     ${jdconID}

    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}         ${apptid1}
    Should Be Equal As Strings  ${resp.json()[1]['msg']}                ${msg}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}     ${jdconID}

    Should Contain 	${resp.json()[1]}   attachements
    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][0]}   s3path
    Should Contain  ${resp.json()[1]['attachements'][0]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][0]}   thumbPath
    Should Contain  ${resp.json()[1]['attachements'][0]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[1]['attachements'][0]['caption']}     ${caption1}

    ${resp}=  Consumer Login  ${CUSERNAME26}   ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${apptid1}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${defconfirm_msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     ${jdconID}

    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}         ${apptid1}
    Should Be Equal As Strings  ${resp.json()[1]['msg']}                ${msg}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}     ${jdconID} 

    Should Contain 	${resp.json()[1]}   attachements
    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][0]}   s3path
    Should Contain  ${resp.json()[1]['attachements'][0]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][0]}   thumbPath
    Should Contain  ${resp.json()[1]['attachements'][0]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[1]['attachements'][0]['caption']}     ${caption1}

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-AppointmentCommunication-6
    [Documentation]  Send appointment comunication message to consumer after completing appointment
    ${resp}=  Consumer Login  ${CUSERNAME26}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}
    Set Test Variable  ${uname}   ${resp.json()['userName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME188}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${p_id}  ${resp.json()['id']}
    
    ${resp}=   Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${buss_name}  ${resp.json()['businessName']}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    ${resp1}=   Run Keyword If  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    clear_service   ${PUSERNAME188}
    clear_location  ${PUSERNAME188}
    clear_appt_schedule   ${PUSERNAME188}
    clear_consumer_msgs  ${CUSERNAME26}
    clear_provider_msgs  ${PUSERNAME188}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}    
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${lid}=  Create Sample Location
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME26}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()[0]['id']}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid1}  appmtDate=${DAY1}   appmtTime=${slot1}  appointmentEncId=${encId}  apptStatus=${apptStatus[2]}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    # Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname}
    # Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${resp}=  Appointment Action   ${apptStatus[3]}   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Status   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[1]['appointmentStatus']}   ${apptStatus[3]}
    Should Contain  "${resp.json()}"  ${apptStatus[3]}
    
    ${resp}=  Appointment Action   ${apptStatus[6]}   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Status   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[1]['appointmentStatus']}   ${apptStatus[3]}
    # Should Be Equal As Strings  ${resp.json()[2]['appointmentStatus']}   ${apptStatus[6]}
    Should Contain  "${resp.json()}"  ${apptStatus[3]}
    Should Contain  "${resp.json()}"  ${apptStatus[6]}

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME188}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${caption1}=  Fakerlibrary.sentence
    ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
    @{fileswithcaption}=  Create List   ${filecap_dict1}
    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Imageupload.PAppmntComm   ${cookie}  ${apptid1}  ${msg}  ${messageType[0]}  ${caption1}  ${EMPTY}  ${jpgfile}  
    Log  ${resp}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Messages
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${confirmAppt_push}=  Set Variable   ${resp.json()['confirmationMessages']['SP_APP']} 

    ${bookingid}=  Format String  ${bookinglink}  ${encId}  ${encId}
    ${defconfirm_msg}=  Replace String  ${confirmAppt_push}  [consumer]   ${uname}
    ${defconfirm_msg}=  Replace String  ${defconfirm_msg}  [bookingId]   ${encId}

    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${apptid1}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${defconfirm_msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     ${jdconID}

    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}         ${apptid1}
    Should Be Equal As Strings  ${resp.json()[1]['msg']}                ${msg}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}     ${jdconID}

    Should Contain 	${resp.json()[1]}   attachements
    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][0]}   s3path
    Should Contain  ${resp.json()[1]['attachements'][0]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][0]}   thumbPath
    Should Contain  ${resp.json()[1]['attachements'][0]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[1]['attachements'][0]['caption']}     ${caption1}

    ${resp}=  Consumer Login  ${CUSERNAME26}   ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${apptid1}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${defconfirm_msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     ${jdconID}

    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}         ${apptid1}
    Should Be Equal As Strings  ${resp.json()[1]['msg']}                ${msg}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}     ${jdconID} 

    Should Contain 	${resp.json()[1]}   attachements
    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][0]}   s3path
    Should Contain  ${resp.json()[1]['attachements'][0]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][0]}   thumbPath
    Should Contain  ${resp.json()[1]['attachements'][0]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[1]['attachements'][0]['caption']}     ${caption1}

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-AppointmentCommunication-7
    [Documentation]  Send appointment comunication message to consumer after cancelling appointment
    ${resp}=  Consumer Login  ${CUSERNAME26}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}
    Set Test Variable  ${uname}   ${resp.json()['userName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME188}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${p_id}  ${resp.json()['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bname}   ${resp.json()['businessName']}
    
    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    ${resp1}=   Run Keyword If  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    clear_service   ${PUSERNAME188}
    clear_location  ${PUSERNAME188}
    clear_appt_schedule   ${PUSERNAME188}
    clear_consumer_msgs  ${CUSERNAME26}
    clear_provider_msgs  ${PUSERNAME188}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}    
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${lid}=  Create Sample Location
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME26}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()[0]['id']}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid1}  appmtDate=${DAY1}   appmtTime=${slot1}  appointmentEncId=${encId}  apptStatus=${apptStatus[2]}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${reason}=  Random Element  ${cancelReason}
    ${cancel_msg}=   FakerLibrary.word
    ${resp}=    Provider Cancel Appointment  ${apptid1}  ${reason}  ${cancel_msg}  ${DAY1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Status   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[1]['appointmentStatus']}   ${apptStatus[4]}
    Should Contain  "${resp.json()}"  ${apptStatus[4]}

    sleep  01s

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME188}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${caption1}=  Fakerlibrary.sentence
    ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
    @{fileswithcaption}=  Create List   ${filecap_dict1}
    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Imageupload.PAppmntComm   ${cookie}  ${apptid1}  ${msg}  ${messageType[0]}  ${caption1}  ${EMPTY}  ${jpgfile}  
    Log  ${resp}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Messages
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${confirmAppt_push}=  Set Variable   ${resp.json()['confirmationMessages']['SP_APP']} 
    ${defconsumerCancel_msg}=  Set Variable   ${resp.json()['cancellationMessages']['Consumer_APP']}
    
    ${provider_msg}=   Set Variable  Message from [providerName] : [message] 
    ${provider_msg}=   Replace String  ${provider_msg}  [providerName]   ${buss_name}
    ${provider_msg}=   Replace String  ${provider_msg}  [message]        ${cancel_msg}

    ${bookingid}=  Format String  ${bookinglink}  ${encId}  ${encId}
    ${defconfirm_msg}=  Replace String  ${confirmAppt_push}  [consumer]   ${uname}
    ${defconfirm_msg}=  Replace String  ${defconfirm_msg}  [bookingId]   ${encId}

    ${defcancel_msg}=  Replace String  ${defconsumerCancel_msg}  [consumer]   ${uname}
    ${defcancel_msg}=  Replace String  ${defcancel_msg}  [bookingId]   ${encId}
    ${defcancel_msg}=  Replace String  ${defcancel_msg}  [providerMessage]   ${provider_msg}

    # ${date}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y
    # ${converted_slot}=  convert_slot_12hr  ${slot1} 
    # log    ${converted_slot}

    # ${defconfirm_msg}=  Replace String  ${defconfirm_msg}  [username]   ${uname} 
    # ${defconfirm_msg}=  Replace String  ${defconfirm_msg}  [service]   ${SERVICE1}
    # ${defconfirm_msg}=  Replace String  ${defconfirm_msg}  [date]   ${date}
    # ${defconfirm_msg}=  Replace String  ${defconfirm_msg}  [time]   ${converted_slot}
    # ${defconfirm_msg}=  Replace String  ${defconfirm_msg}  [providerName]   ${bsname}

    # ${defcancel_msg}=  Replace String  ${defconsumerCancel_msg}  [username]   ${uname} 
    # ${defcancel_msg}=  Replace String  ${defcancel_msg}  [time]   ${SPACE}${converted_slot}
    # ${defcancel_msg}=  Replace String  ${defcancel_msg}  [date]   ${date}
    # ${defcancel_msg}=  Replace String  ${defcancel_msg}  [service]   ${SERVICE1}
    # ${defcancel_msg}=  Replace String  ${defcancel_msg}  [provider name]   ${bname}

    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${apptid1}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${defconfirm_msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     ${jdconID}

    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}         ${apptid1}
    Should Be Equal As Strings  ${resp.json()[1]['msg']}                ${defcancel_msg}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}     ${jdconID}

    Should Be Equal As Strings  ${resp.json()[2]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[2]['waitlistId']}         ${apptid1}
    Should Be Equal As Strings  ${resp.json()[2]['msg']}                ${msg}
    Should Be Equal As Strings  ${resp.json()[2]['receiver']['id']}     ${jdconID}

    Should Contain 	${resp.json()[2]}   attachements
    Dictionary Should Contain Key  ${resp.json()[2]['attachements'][0]}   s3path
    Should Contain  ${resp.json()[2]['attachements'][0]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[2]['attachements'][0]}   thumbPath
    Should Contain  ${resp.json()[2]['attachements'][0]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[2]['attachements'][0]['caption']}     ${caption1}

    ${resp}=  Consumer Login  ${CUSERNAME26}   ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${apptid1}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${defconfirm_msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     ${jdconID}

    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}         ${apptid1}
    Should Be Equal As Strings  ${resp.json()[1]['msg']}                ${defcancel_msg}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}     ${jdconID} 

    Should Be Equal As Strings  ${resp.json()[2]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[2]['waitlistId']}         ${apptid1}
    Should Be Equal As Strings  ${resp.json()[2]['msg']}                ${msg}
    Should Be Equal As Strings  ${resp.json()[2]['receiver']['id']}     ${jdconID}

    Should Contain 	${resp.json()[2]}   attachements
    Dictionary Should Contain Key  ${resp.json()[2]['attachements'][0]}   s3path
    Should Contain  ${resp.json()[2]['attachements'][0]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[2]['attachements'][0]}   thumbPath
    Should Contain  ${resp.json()[2]['attachements'][0]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[2]['attachements'][0]['caption']}     ${caption1}

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-AppointmentCommunication-8
    [Documentation]  Send appointment comunication message to consumer after rejecting appointment
    ${resp}=  Consumer Login  ${CUSERNAME26}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}
    Set Test Variable  ${uname}   ${resp.json()['userName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME188}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${p_id}  ${resp.json()['id']}
    
    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    ${resp1}=   Run Keyword If  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    clear_service   ${PUSERNAME188}
    clear_location  ${PUSERNAME188}
    clear_appt_schedule   ${PUSERNAME188}
    clear_consumer_msgs  ${CUSERNAME26}
    clear_provider_msgs  ${PUSERNAME188}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}    
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${lid}=  Create Sample Location
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME26}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()[0]['id']}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}
    Set Suite Variable  ${apptid1}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid1}  appmtDate=${DAY1}   appmtTime=${slot1}  appointmentEncId=${encId}  apptStatus=${apptStatus[2]}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    # Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname}
    # Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${reason}=  Random Element  ${cancelReason}
    ${reject_msg}=   FakerLibrary.word
    ${resp}=    Reject Appointment  ${apptid1}  ${reason}  ${reject_msg}  ${DAY1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep  2s
    ${resp}=  Get Appointment Status   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[1]['appointmentStatus']}   ${apptStatus[5]}
    Should Contain  "${resp.json()}"  ${apptStatus[5]}

    sleep  01s

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME188}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${caption1}=  Fakerlibrary.sentence
    ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
    @{fileswithcaption}=  Create List   ${filecap_dict1}
    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Imageupload.PAppmntComm   ${cookie}  ${apptid1}  ${msg}  ${messageType[0]}  ${caption1}  ${EMPTY}  ${jpgfile}  
    Log  ${resp}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  Get Appointment Messages
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${confirmAppt_push}=  Set Variable   ${resp.json()['confirmationMessages']['SP_APP']} 
    # ${defconsumerCancel_msg}=  Set Variable   ${resp.json()['cancellationMessages']['SP_APP']}

    ${bookingid}=  Format String  ${bookinglink}  ${encId}  ${encId}
    ${defconfirm_msg}=  Replace String  ${confirmAppt_push}  [consumer]   ${uname}
    ${defconfirm_msg}=  Replace String  ${defconfirm_msg}  [bookingId]   ${encId}

    # ${defcancel_msg}=  Replace String  ${defconsumerCancel_msg}  [consumer]   ${uname}
    # ${defcancel_msg}=  Replace String  ${defconfirm_msg}  [bookingId]   ${bookingid}
    
    sleep  2s
    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${len}=  Get Length  ${resp.content}

    Run Keyword IF  '${len}' == '3'
    ...    Run Keywords
    ...    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        0
    ...    AND  Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${apptid1}
    ...    AND  Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${defconfirm_msg}
    ...    AND  Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     ${jdconID}

    ...    AND  Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}        0
    ...    AND  Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}         ${apptid1}
    ...    AND  Should Be Equal As Strings  ${resp.json()[1]['msg']}                ${reject_msg}
    ...    AND  Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}     ${jdconID}

    ...    AND  Should Be Equal As Strings  ${resp.json()[2]['owner']['id']}        0
    ...    AND  Should Be Equal As Strings  ${resp.json()[2]['waitlistId']}         ${apptid1}
    ...    AND  Should Be Equal As Strings  ${resp.json()[2]['msg']}                ${msg}
    ...    AND  Should Be Equal As Strings  ${resp.json()[2]['receiver']['id']}     ${jdconID}
    ...    AND  Should Contain 	${resp.json()[2]}   attachements
    ...    AND  Dictionary Should Contain Key  ${resp.json()[2]['attachements'][0]}   s3path
    ...    AND  Should Contain  ${resp.json()[2]['attachements'][0]['s3path']}   .jpg
    ...    AND  Dictionary Should Contain Key  ${resp.json()[2]['attachements'][0]}   thumbPath
    ...    AND  Should Contain  ${resp.json()[2]['attachements'][0]['s3path']}   .jpg
    ...    AND  Should Be Equal As Strings  ${resp.json()[2]['attachements'][0]['caption']}     ${caption1}

    ...    ELSE IF  '${len}' == '2'
    ...    Run Keywords
    ...    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        0
    ...    AND  Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${apptid1}
    ...    AND  Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${defconfirm_msg}
    ...    AND  Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     ${jdconID}

    ...    AND  Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}        0
    ...    AND  Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}         ${apptid1}
    ...    AND  Should Be Equal As Strings  ${resp.json()[1]['msg']}                ${msg}
    ...    AND  Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}     ${jdconID}
    ...    AND  Should Contain 	${resp.json()[1]}   attachements
    ...    AND  Dictionary Should Contain Key  ${resp.json()[1]['attachements'][0]}   s3path
    ...    AND  Should Contain  ${resp.json()[1]['attachements'][0]['s3path']}   .jpg
    ...    AND  Dictionary Should Contain Key  ${resp.json()[1]['attachements'][0]}   thumbPath
    ...    AND  Should Contain  ${resp.json()[1]['attachements'][0]['s3path']}   .jpg
    ...    AND  Should Be Equal As Strings  ${resp.json()[1]['attachements'][0]['caption']}   ${caption1}
    

    ${resp}=  Consumer Login  ${CUSERNAME26}   ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep   2s
    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.content}

    Run Keyword IF  '${len}' == '3'
    ...    Run Keywords
    ...    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        0
    ...    AND  Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${apptid1}
    ...    AND  Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${defconfirm_msg}
    ...    AND  Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     ${jdconID}

    ...    AND  Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}        0
    ...    AND  Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}         ${apptid1}
    ...    AND  Should Be Equal As Strings  ${resp.json()[1]['msg']}                ${reject_msg}
    ...    AND  Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}     ${jdconID} 

    ...    AND  Should Be Equal As Strings  ${resp.json()[2]['owner']['id']}        0
    ...    AND  Should Be Equal As Strings  ${resp.json()[2]['waitlistId']}         ${apptid1}
    ...    AND  Should Be Equal As Strings  ${resp.json()[2]['msg']}                ${msg}
    ...    AND  Should Be Equal As Strings  ${resp.json()[2]['receiver']['id']}     ${jdconID}
    ...    AND  Should Contain 	${resp.json()[2]}   attachements
    ...    AND  Dictionary Should Contain Key  ${resp.json()[2]['attachements'][0]}   s3path
    ...    AND  Should Contain  ${resp.json()[2]['attachements'][0]['s3path']}   .jpg
    ...    AND  Dictionary Should Contain Key  ${resp.json()[2]['attachements'][0]}   thumbPath
    ...    AND  Should Contain  ${resp.json()[2]['attachements'][0]['s3path']}   .jpg
    ...    AND  Should Be Equal As Strings  ${resp.json()[2]['attachements'][0]['caption']}   ${caption1}
    
    ...    ELSE IF  '${len}' == '2'
    ...    Run Keywords
    ...    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        0
    ...    AND  Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${apptid1}
    ...    AND  Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${defconfirm_msg}
    ...    AND  Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     ${jdconID}

    ...    AND  Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}        0
    ...    AND  Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}         ${apptid1}
    ...    AND  Should Be Equal As Strings  ${resp.json()[1]['msg']}                ${msg}
    ...    AND  Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}     ${jdconID}
    ...    AND  Should Contain 	${resp.json()[1]}   attachements
    ...    AND  Dictionary Should Contain Key  ${resp.json()[1]['attachements'][0]}   s3path
    ...    AND  Should Contain  ${resp.json()[1]['attachements'][0]['s3path']}   .jpg
    ...    AND  Dictionary Should Contain Key  ${resp.json()[1]['attachements'][0]}   thumbPath
    ...    AND  Should Contain  ${resp.json()[1]['attachements'][0]['s3path']}   .jpg
    ...    AND  Should Be Equal As Strings  ${resp.json()[1]['attachements'][0]['caption']}   ${caption1}

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-AppointmentCommunication-9

    [Documentation]  take appt by consumer and reject appt by provider and send to replay message by provider by consumer
   #   Not able to reply to the message send by a rejected consumer
    
    ${multilocdoms}=  get_mutilocation_domains
    Log  ${multilocdoms}
    Set Suite Variable  ${dom}  ${multilocdoms[0]['domain']}
    Set Suite Variable  ${sub_dom}  ${multilocdoms[0]['subdomains'][0]}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_D}=  Evaluate  ${PUSERNAME}+5566068
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_D}    ${highest_package[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_D}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_D}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_D}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_D}${\n}
    Set Suite Variable  ${PUSERNAME_D}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_D}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${list}=  Create List  1  2  3  4  5  6  7
    ${ph1}=  Evaluate  ${PUSERNAME_D}+15566198
    ${ph2}=  Evaluate  ${PUSERNAME_D}+25566198
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}183.${test_mail}  ${views}
    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
    # ${city}=   FakerLibrary.state
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ${bool}
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fields}=   Get subDomain level Fields  ${dom}  ${sub_dom}
    Log  ${fields.json()}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_dom}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${dom}  ${sub_dom}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Enable Appointment
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   01s
    
    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[0]}  ${boolean[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}

    clear_service   ${PUSERNAME_D}
    clear_location  ${PUSERNAME_D}    
    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${pid}=  get_acc_id  ${PUSERNAME_D}
    Set Suite Variable   ${pid}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  add_timezone_time  ${tz}  0  15  
    # ${delta}=  FakerLibrary.Random Int  min=10  max=60
    # ${eTime1}=  add_two   ${sTime1}  ${delta}
    # ${lid}=  Create Sample Location
    # Set Suite Variable   ${lid}
    ${lid}=  Create Sample Location
    Set Suite Variable   ${lid}
    
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    clear_appt_schedule   ${PUSERNAME_D}
    ${SERVICE1}=   FakerLibrary.name
    ${s_id}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable   ${s_id}
    ${SERVICE2}=   FakerLibrary.name
    ${s_id2}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable   ${s_id2}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}  ${s_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${sTime2}=  add_timezone_time  ${tz}  1  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime2}=  add_two   ${sTime2}  ${delta}   

    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id2}  ${resp.json()} 

    ${resp}=  Get Appointment Schedule ById  ${sch_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id2}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME9}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${f_Name}  ${resp.json()['firstName']}
    Set Suite Variable  ${l_Name}  ${resp.json()['lastName']}
    Set Suite Variable  ${ph_no}  ${resp.json()['primaryPhoneNumber']}

    ${resp}=  Get Appointment Schedules Consumer  ${pid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id}   ${pid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
        END
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Suite Variable   ${slot1}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cid}=  get_id  ${CUSERNAME9}   
    Set Suite Variable   ${cid}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid1}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['uid']}                                           ${apptid1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                                ${cid}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}          ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}           ${lname}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['primaryMobileNo']}    ${ph_no}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                                 ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}                                ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}                                    ${appt_status[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}                      ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}                       ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}                       ${slot1}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}                                     ${DAY1}
    Should Be Equal As Strings  ${resp.json()['appmtTime']}                                     ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}                                ${lid}
   
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_D}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment EncodedID    ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}
    Set Test Variable   ${encId}   

    ${reason}=  Random Element  ${cancelReason}
    ${msg}=   FakerLibrary.word
    ${resp}=    Reject Appointment  ${apptid1}  ${reason}  ${msg}  ${DAY1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep   3s
    ${resp}=  Get Appointment Status   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[1]['appointmentStatus']}   ${apptStatus[5]}
    Should Contain  "${resp.json()}"  ${apptStatus[5]}

    ${resp}=  Get Appointment Messages
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${confirmAppt_push}=  Set Variable   ${resp.json()['confirmationMessages']['SP_APP']}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME9}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${caption1}=  Fakerlibrary.sentence
    ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
    @{fileswithcaption}=  Create List   ${filecap_dict1}
    
    ${msg1}=  Fakerlibrary.sentence
    ${resp}=  Imageupload.CAppmntcomm   ${cookie}   ${apptid1}  ${pid}  ${msg1}  ${messageType[0]}  ${caption1}  ${EMPTY}  ${jpgfile}  
    Log  ${resp}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${date}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y
    # ${converted_slot}=  convert_slot_12hr  ${slot1} 
    # log    ${converted_slot}
    # ${defconfirm_msg}=  Replace String  ${confirmAppt_push}  [username]   ${uname} 
    # ${defconfirm_msg}=  Replace String  ${defconfirm_msg}  [service]   ${SERVICE1}
    # ${defconfirm_msg}=  Replace String  ${defconfirm_msg}  [date]   ${date}
    # ${defconfirm_msg}=  Replace String  ${defconfirm_msg}  [time]   ${converted_slot}
    # ${defconfirm_msg}=  Replace String  ${defconfirm_msg}  [providerName]   ${bsname}

     

    # ${bookingid}=  Format String  ${bookinglink}  ${encId}  ${encId}
    # ${defconfirm_msg}=  Replace String  ${confirmAppt_push}  [consumer]   ${uname}
    # ${defconfirm_msg}=  Replace String  ${defconfirm_msg}  [bookingId]   ${encId}

    ${resp}=  Consumer Login  ${CUSERNAME9}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep  2s
    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}

    Run Keyword IF  '${len}' == '3'
    ...    Run Keywords
    
    ...    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        0
    ...    AND  Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${apptid1}
    ... 
    ...    AND  Should Be Equal As Strings  ${resp.json()[0]['accountId']}          ${pid}

    ...    AND  Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}        0
    ...    AND  Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}         ${apptid1}
    ...    AND  Should Be Equal As Strings  ${resp.json()[1]['msg']}                ${msg}
    ...    AND  Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}     ${cid}
    ...    AND  Should Be Equal As Strings  ${resp.json()[1]['accountId']}          ${pid}

    ...    AND  Should Be Equal As Strings  ${resp.json()[2]['owner']['id']}        ${cid}
    ...    AND  Should Be Equal As Strings  ${resp.json()[2]['waitlistId']}         ${apptid1}
    ...    AND  Should Be Equal As Strings  ${resp.json()[2]['msg']}                ${msg1}
    ...    AND  Should Be Equal As Strings  ${resp.json()[2]['receiver']['id']}     0
    ...    AND  Should Be Equal As Strings  ${resp.json()[2]['accountId']}          ${pid}
    ...    AND  Should Contain 	${resp.json()[2]}   attachements
    ...    AND  Dictionary Should Contain Key  ${resp.json()[2]['attachements'][0]}   s3path
    ...    AND  Should Contain  ${resp.json()[2]['attachements'][0]['s3path']}   .jpg
    ...    AND  Dictionary Should Contain Key  ${resp.json()[2]['attachements'][0]}   thumbPath
    ...    AND  Should Contain  ${resp.json()[2]['attachements'][0]['s3path']}   .jpg
    ...    AND  Should Be Equal As Strings  ${resp.json()[2]['attachements'][0]['caption']}   ${caption1}

    ...    ELSE IF  '${len}' == '2'
    ...    Run Keywords

    ...    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        0
    ...    AND  Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${apptid1}
  
    ...    AND  Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     ${cid}
    ...    AND  Should Be Equal As Strings  ${resp.json()[0]['accountId']}          ${pid}

    ...    AND  Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}        ${cid}
    ...    AND  Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}         ${apptid1}
    ...    AND  Should Be Equal As Strings  ${resp.json()[1]['msg']}                ${msg1}
    ...    AND  Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}     0
    ...    AND  Should Be Equal As Strings  ${resp.json()[1]['accountId']}          ${pid}
    ...    AND  Should Contain 	${resp.json()[1]}   attachements
    ...    AND  Dictionary Should Contain Key  ${resp.json()[1]['attachements'][0]}   s3path
    ...    AND  Should Contain  ${resp.json()[1]['attachements'][0]['s3path']}   .jpg
    ...    AND  Dictionary Should Contain Key  ${resp.json()[1]['attachements'][0]}   thumbPath
    ...    AND  Should Contain  ${resp.json()[1]['attachements'][0]['s3path']}   .jpg
    ...    AND  Should Be Equal As Strings  ${resp.json()[1]['attachements'][0]['caption']}   ${caption1}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_D}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    
    sleep  01s

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME_D}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${caption1}=  Fakerlibrary.sentence
    ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
    @{fileswithcaption}=  Create List   ${filecap_dict1}
    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Imageupload.PAppmntComm   ${cookie}  ${apptid1}  ${msg}  ${messageType[0]}  ${caption1}  ${EMPTY}  ${jpgfile}  
    Log  ${resp}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${apptid1}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     ${cid}

    
    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME9}   ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep   2s
    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.content}

    Run Keyword IF  '${len}' == '1'
    ...    Run Keywords
    ...    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        0
    ...    AND  Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${apptid1}
   
    ...    AND  Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     ${cid}

    ...  


    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200


# JD-TC-AppointmentCommunication-UH1
#     [Documentation]  Send appointment comunication message to consumer without login

#     ${caption1}=  Fakerlibrary.sentence
#     ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
#     @{fileswithcaption}=  Create List   ${filecap_dict1}
#     ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
#     ${resp}=  Imageupload.PAppmntComm   ${cookie}  ${apptid1}  ${msg}  ${messageType[0]}  ${caption1}  ${EMPTY}  ${jpgfile}  
#     Log  ${resp}
#     Should Be Equal As Strings  ${resp.status_code}  419
#     Should Be Equal As Strings  ${resp.json()}  ${SESSION_EXPIRED}  

JD-TC-AppointmentCommunication-UH2
    [Documentation]  Send appointment comunication message to consumer by another provider
    
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME183}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${caption1}=  Fakerlibrary.sentence
    ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
    @{fileswithcaption}=  Create List   ${filecap_dict1}
    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Imageupload.PAppmntComm   ${cookie}  ${apptid1}  ${msg}  ${messageType[0]}  ${caption1}  ${EMPTY}  ${jpgfile}  
    Log  ${resp}
    Should Be Equal As Strings  ${resp.status_code}  403
    Should Be Equal As Strings  ${resp.json()}  ${NO_PERMISSION}

JD-TC-AppointmentCommunication-UH3
    [Documentation]  Send appointment comunication message using invalid appointment id
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME188}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${caption1}=  Fakerlibrary.sentence
    ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
    @{fileswithcaption}=  Create List   ${filecap_dict1}
    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Imageupload.PAppmntComm   ${cookie}  000000abcd  ${msg}  ${messageType[0]}  ${caption1}  ${EMPTY}  ${jpgfile}  
    Log  ${resp}
    Should Be Equal As Strings  ${resp.status_code}  404
    Should Be Equal As Strings  ${resp.json()}  ${INVALID_APPOINTMENT}

JD-TC-AppointmentCommunication-UH4
    [Documentation]  Send appointment comunication message by consumer login

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME26}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${caption1}=  Fakerlibrary.sentence
    ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
    @{fileswithcaption}=  Create List   ${filecap_dict1}
    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Imageupload.PAppmntComm   ${cookie}  ${apptid1}  ${msg}  ${messageType[0]}  ${caption1}  ${EMPTY}  ${jpgfile}  
    Log  ${resp}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  ${resp.json()}  ${LOGIN_NO_ACCESS_FOR_URL}

