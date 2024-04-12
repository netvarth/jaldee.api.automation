*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Run Keywords     Delete All Sessions
...               AND           Remove File  cookies.txt
Force Tags        Appointment, mass communication
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

*** Test Cases ***

JD-TC-ConsMassCommunicationForAppt-1
    [Documentation]   Provider setting consumer mass communication for appointment.

    ${resp}=  Consumer Login  ${CUSERNAME11}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID}   ${resp.json()['id']}
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}
    Set Suite Variable  ${uname}   ${resp.json()['userName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME250}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${p_id}  ${decrypted_data['id']}
    # Set Suite Variable  ${p_id}  ${resp.json()['id']}

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

    clear_service   ${PUSERNAME250}
    clear_location  ${PUSERNAME250}
    clear_customer   ${PUSERNAME250}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    IF  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}
        ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}  
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}  

    ${lid}=  Create Sample Location  
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    clear_appt_schedule   ${PUSERNAME250}
    clear_Consumermsg  ${CUSERNAME11}
    clear_Providermsg  ${PUSERNAME250}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
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

    ${resp}=  AddCustomer  ${CUSERNAME11}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Suite Variable  ${apptid1}  ${apptid[0]}

    ${resp}=   Get Appointment EncodedID    ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}
    Set Test Variable   ${encId}


    ${cookie}   ${resp}=    Imageupload.spLogin     ${PUSERNAME250}     ${PASSWORD}
    Log     ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}     200
    ${caption1}=  Fakerlibrary.Sentence
    ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
    ${caption2}=  Fakerlibrary.Sentence
    ${filecap_dict2}=  Create Dictionary   file=${pngfile}   caption=${caption2}
    ${caption3}=  Fakerlibrary.Sentence
    ${filecap_dict3}=  Create Dictionary   file=${pdffile}   caption=${caption3}
    @{fileswithcaption}=  Create List   ${filecap_dict1}   ${filecap_dict2}  ${filecap_dict3}
    ${msg}=  FakerLibrary.text
    Set Suite Variable  ${msg}
    Append To File  ${EXECDIR}/TDD/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Consumer Mass Communication for Appt  ${cookie}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${msg}    ${fileswithcaption}      ${apptid1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

# *** Comments ***
    ${resp}=  Get Appointment Messages
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${MassCom}=  Set Variable   ${resp.json()['checkinMessages']['massCommunication']['Consumer_APP']} 

    ${msg1}=  Replace String  ${MassCom}  [consumer]   ${uname}
    ${msg1}=  Replace String  ${msg1}  [type]   booking
    ${msg1}=  Replace String  ${msg1}  [message]   ${msg}
    Set Suite Variable   ${msg1}
    # ${msg1}=  Replace String   ${MassCommunication_push}  [consumer name]  ${uname}
    # ${msg}=  Replace String  ${msg1}  [message]  ${msg}
    # Log   ${msg}

    sleep   03s

    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}         ${apptid1}
    Variable Should Exist   ${resp.content}  ${msg1}
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

    ${resp}=  Consumer Login  ${CUSERNAME11}   ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}         ${apptid1}
    Variable Should Exist   ${resp.content}  ${msg1}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}     ${jdconID} 
    # Should Be Equal As Strings  ${resp.json()[1]['attachements']}        []
    # Should Not Contain   ${resp.json()[0]}   attachements
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

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-ConsMassCommunicationForAppt-2

    [Documentation]   Provider sending another consumer mass communication for multiple appointments.

    ${resp}=  Consumer Login  ${CUSERNAME36}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}
    Set Test Variable  ${uname}   ${resp.json()['userName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME247}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${p_id}  ${decrypted_data['id']}
    # Set Test Variable  ${p_id}  ${resp.json()['id']}

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    IF  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}
        ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}  
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    clear_service   ${PUSERNAME247}
    clear_location  ${PUSERNAME247}
    clear_customer   ${PUSERNAME247}
    clear_Consumermsg  ${CUSERNAME36}
    clear_Providermsg  ${PUSERNAME247}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${lid}=  Create Sample Location
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    clear_appt_schedule   ${PUSERNAME247}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
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
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}

    ${resp}=  AddCustomer  ${CUSERNAME36}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}

    ${mem_fname}=   FakerLibrary.first_name
    ${mem_lname}=   FakerLibrary.last_name
    ${dob}=      FakerLibrary.date
    ${resp}=  AddFamilyMemberByProvider  ${cid}  ${mem_fname}  ${mem_lname}  ${dob}  ${Genderlist[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mem_id}  ${resp.json()}

    ${resp}=  ListFamilyMemberByProvider  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor2}=  Create Dictionary  id=${mem_id}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}  ${apptfor2}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer   ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${Keys}=  Get Dictionary Keys  ${resp.json()}   sort_keys=False 
    ${apptid11}=  Get From Dictionary  ${resp.json()}  ${mem_fname}
    Set Suite Variable   ${apptid11}
    ${apptid12}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${cookie}   ${resp}=    Imageupload.spLogin     ${PUSERNAME247}     ${PASSWORD}
    Log     ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}     200
    ${caption1}=  Fakerlibrary.Sentence
    ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
    ${caption2}=  Fakerlibrary.Sentence
    ${filecap_dict2}=  Create Dictionary   file=${pngfile}   caption=${caption2}
    ${caption3}=  Fakerlibrary.Sentence
    ${filecap_dict3}=  Create Dictionary   file=${pdffile}   caption=${caption3}
    @{fileswithcaption}=  Create List   ${filecap_dict1}   ${filecap_dict2}  ${filecap_dict3}
    ${msg}=  Fakerlibrary.Sentence
    Append To File  ${EXECDIR}/TDD/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}

    ${resp}=  Consumer Mass Communication for Appt  ${cookie}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${msg}    ${fileswithcaption}      ${apptid11}   ${apptid12} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    

    ${resp}=  Get Appointment Messages
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${MassCom}=  Set Variable   ${resp.json()['checkinMessages']['massCommunication']['Consumer_APP']} 
    # ${MassCom}=  Set Variable   ${resp.json()['confirmationMessages']['Consumer_APP']} 

    ${msg1}=  Replace String  ${MassCom}  [consumer]   ${mem_fname}${SPACE}${mem_lname}
    ${msg1}=  Replace String  ${msg1}  [type]   booking
    ${msg1}=  Replace String  ${msg1}  [message]   ${msg}
    sleep   04s

    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()[2]['owner']['id']}        0
    Variable Should Exist   ${resp.content}  ${msg1}
    Variable Should Exist   ${resp.content}  ${apptid11}
    Should Be Equal As Strings  ${resp.json()[2]['receiver']['id']}     ${jdconID}
    # Should Be Equal As Strings  ${resp.json()[1]['attachements']}        []
    # Should Not Contain   ${resp.json()[0]}   attachements
    Should Contain 	${resp.json()[2]}   attachements
    ${attachment-len}=  Get Length  ${resp.json()[2]['attachements']}
    Should Be Equal As Strings  ${attachment-len}  3

    Dictionary Should Contain Key  ${resp.json()[2]['attachements'][0]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    Dictionary Should Contain Key  ${resp.json()[2]['attachements'][0]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption1}

    Dictionary Should Contain Key  ${resp.json()[2]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .pdf
    Dictionary Should Contain Key  ${resp.json()[2]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption2}

    Dictionary Should Contain Key  ${resp.json()[2]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[2]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption3}

    ${resp}=  Consumer Login  ${CUSERNAME36}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep  3s
    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[2]['owner']['id']}        0
    Variable Should Exist   ${resp.content}  ${apptid11}
    Variable Should Exist   ${resp.content}  ${msg1}
    Should Be Equal As Strings  ${resp.json()[2]['receiver']['id']}     ${jdconID} 
    # Should Be Equal As Strings  ${resp.json()[0]['attachements']}        []
    # Should Not Contain   ${resp.json()[0]}   attachements
    Should Contain 	${resp.json()[2]}   attachements
    ${attachment-len}=  Get Length  ${resp.json()[2]['attachements']}
    Should Be Equal As Strings  ${attachment-len}  3

    Dictionary Should Contain Key  ${resp.json()[2]['attachements'][0]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    Dictionary Should Contain Key  ${resp.json()[2]['attachements'][0]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption1}

    Dictionary Should Contain Key  ${resp.json()[2]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .pdf
    Dictionary Should Contain Key  ${resp.json()[2]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption2}

    Dictionary Should Contain Key  ${resp.json()[2]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[2]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption3}

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-ConsMassCommunicationForAppt-3

    [Documentation]   Provider sending consumer mass communication with all medium set as false.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME250}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Messages
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${MassCom}=  Set Variable   ${resp.json()['checkinMessages']['massCommunication']['Consumer_APP']} 

    ${msg1}=  Replace String  ${MassCom}  [consumer]   ${uname}
    ${msg1}=  Replace String  ${msg1}  [type]   booking
    ${msg1}=  Replace String  ${msg1}  [message]   ${msg}

    # ${msg1}=  Replace String   ${MassCommunication_push}  [consumer name]  ${uname}
    # ${msg}=  Replace String  ${msg1}  [message]  ${msg}
    ${cookie}   ${resp}=    Imageupload.spLogin     ${PUSERNAME250}     ${PASSWORD}
    Log     ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}     200
    ${caption1}=  Fakerlibrary.Sentence
    ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
    ${caption2}=  Fakerlibrary.Sentence
    ${filecap_dict2}=  Create Dictionary   file=${pngfile}   caption=${caption2}
    ${caption3}=  Fakerlibrary.Sentence
    ${filecap_dict3}=  Create Dictionary   file=${pdffile}   caption=${caption3}
    @{fileswithcaption}=  Create List   ${filecap_dict1}   ${filecap_dict2}  ${filecap_dict3}

    ${resp}=  Consumer Mass Communication for Appt  ${cookie}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${msg}    ${fileswithcaption}      ${apptid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep   03s

    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()[2]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[2]['waitlistId']}         ${apptid1}
    Should Be Equal As Strings  ${resp.json()[2]['msg']}                ${msg1}
    Should Be Equal As Strings  ${resp.json()[2]['receiver']['id']}     ${jdconID}
    # Should Be Equal As Strings  ${resp.json()[0]['attachements']}        []
    # Should Not Contain   ${resp.json()[0]}   attachements
    Should Contain 	${resp.json()[2]}   attachements
    ${attachment-len}=  Get Length  ${resp.json()[2]['attachements']}
    Should Be Equal As Strings  ${attachment-len}  3

    Dictionary Should Contain Key  ${resp.json()[2]['attachements'][0]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    Dictionary Should Contain Key  ${resp.json()[2]['attachements'][0]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption1}

    Dictionary Should Contain Key  ${resp.json()[2]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .pdf
    Dictionary Should Contain Key  ${resp.json()[2]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption2}

    Dictionary Should Contain Key  ${resp.json()[2]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[2]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption3}

    ${resp}=  Consumer Login  ${CUSERNAME11}   ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[2]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[2]['waitlistId']}         ${apptid1}
    Should Be Equal As Strings  ${resp.json()[2]['msg']}                ${msg1}
    Should Be Equal As Strings  ${resp.json()[2]['receiver']['id']}     ${jdconID} 
    # Should Be Equal As Strings  ${resp.json()[0]['attachements']}        []
    # Should Not Contain   ${resp.json()[0]}   attachements
    Should Contain 	${resp.json()[2]}   attachements
    ${attachment-len}=  Get Length  ${resp.json()[2]['attachements']}
    Should Be Equal As Strings  ${attachment-len}  3

    Dictionary Should Contain Key  ${resp.json()[2]['attachements'][0]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    Dictionary Should Contain Key  ${resp.json()[2]['attachements'][0]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption1}

    Dictionary Should Contain Key  ${resp.json()[2]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .pdf
    Dictionary Should Contain Key  ${resp.json()[2]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption2}

    Dictionary Should Contain Key  ${resp.json()[2]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[2]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption3}

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-ConsMassCommunicationForAppt-UH1

    [Documentation]   Provider sending consumer mass communication without communication msg.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME250}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${cookie}   ${resp}=    Imageupload.spLogin     ${PUSERNAME250}     ${PASSWORD}
    Log     ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}     200
    ${caption1}=  Fakerlibrary.Sentence
    ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
    ${caption2}=  Fakerlibrary.Sentence
    ${filecap_dict2}=  Create Dictionary   file=${pngfile}   caption=${caption2}
    ${caption3}=  Fakerlibrary.Sentence
    ${filecap_dict3}=  Create Dictionary   file=${pdffile}   caption=${caption3}
    @{fileswithcaption}=  Create List   ${filecap_dict1}   ${filecap_dict2}  ${filecap_dict3}
    ${resp}=  Consumer Mass Communication for Appt  ${cookie}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}    ${fileswithcaption}      ${apptid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   "${resp.json()}"   "${MASS_COMMUNICATION_NOT_EMPTY}"

JD-TC-ConsMassCommunicationForAppt-UH2

    [Documentation]   Provider sending consumer mass communication without appointment id.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME250}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${cookie}   ${resp}=    Imageupload.spLogin     ${PUSERNAME250}     ${PASSWORD}
    Log     ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}     200
    ${caption1}=  Fakerlibrary.Sentence
    ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
    ${caption2}=  Fakerlibrary.Sentence
    ${filecap_dict2}=  Create Dictionary   file=${pngfile}   caption=${caption2}
    ${caption3}=  Fakerlibrary.Sentence
    ${filecap_dict3}=  Create Dictionary   file=${pdffile}   caption=${caption3}
    @{fileswithcaption}=  Create List   ${filecap_dict1}   ${filecap_dict2}  ${filecap_dict3}
    ${resp}=  Consumer Mass Communication for Appt  ${cookie}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${msg}    ${fileswithcaption}      
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   "${resp.json()}"   "${ENTER_UUID}"

JD-TC-ConsMassCommunicationForAppt-UH3

    [Documentation]   Provider sending consumer mass communication using invalid appointment id.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME250}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${invalid_uuid}=   Random Int  min=1000   max=2000

    ${cookie}   ${resp}=    Imageupload.spLogin     ${PUSERNAME250}     ${PASSWORD}
    Log     ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}     200
    ${caption1}=  Fakerlibrary.Sentence
    ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
    ${caption2}=  Fakerlibrary.Sentence
    ${filecap_dict2}=  Create Dictionary   file=${pngfile}   caption=${caption2}
    ${caption3}=  Fakerlibrary.Sentence
    ${filecap_dict3}=  Create Dictionary   file=${pdffile}   caption=${caption3}
    @{fileswithcaption}=  Create List   ${filecap_dict1}   ${filecap_dict2}  ${filecap_dict3}

    ${resp}=  Consumer Mass Communication for Appt  ${cookie}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${msg}    ${fileswithcaption}   ${invalid_uuid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${resp.json()}    {'${invalid_uuid}': 'invalid uuid'}
                                                    
JD-TC-ConsMassCommunicationForAppt-UH4

    [Documentation]   Provider sending consumer mass communication using another provider's appointment id.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME250}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}   ${resp}=    Imageupload.spLogin     ${PUSERNAME250}     ${PASSWORD}
    Log     ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}     200
    ${caption1}=  Fakerlibrary.Sentence
    ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
    ${caption2}=  Fakerlibrary.Sentence
    ${filecap_dict2}=  Create Dictionary   file=${pngfile}   caption=${caption2}
    ${caption3}=  Fakerlibrary.Sentence
    ${filecap_dict3}=  Create Dictionary   file=${pdffile}   caption=${caption3}
    @{fileswithcaption}=  Create List   ${filecap_dict1}   ${filecap_dict2}  ${filecap_dict3}
    sleep  2s
    ${resp}=  Consumer Mass Communication for Appt  ${cookie}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${msg}    ${fileswithcaption}    ${apptid11}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings    ${resp.json()}     ${NO_PERMISSION}

JD-TC-ConsMassCommunicationForAppt-UH5

    [Documentation]   Provider sending consumer mass communication without login.

    ${caption1}=  Fakerlibrary.Sentence
    ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
    ${caption2}=  Fakerlibrary.Sentence
    ${filecap_dict2}=  Create Dictionary   file=${pngfile}   caption=${caption2}
    ${caption3}=  Fakerlibrary.Sentence
    ${filecap_dict3}=  Create Dictionary   file=${pdffile}   caption=${caption3}
    @{fileswithcaption}=  Create List   ${filecap_dict1}   ${filecap_dict2}  ${filecap_dict3}
    ${resp}=  Consumer Mass Communication for Appt  ${EMPTY}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${msg}    ${fileswithcaption}      ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}"
 

JD-TC-ConsMassCommunicationForAppt-UH6

    [Documentation]   Consumer doing mass communication.

    ${resp}=   Consumer Login  ${CUSERNAME31}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}    200


    ${cookie}   ${resp}=    Imageupload.conLogin     ${CUSERNAME31}     ${PASSWORD}
    Log     ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}     200
    ${caption1}=  Fakerlibrary.Sentence
    ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
    ${caption2}=  Fakerlibrary.Sentence
    ${filecap_dict2}=  Create Dictionary   file=${pngfile}   caption=${caption2}
    ${caption3}=  Fakerlibrary.Sentence
    ${filecap_dict3}=  Create Dictionary   file=${pdffile}   caption=${caption3}
    @{fileswithcaption}=  Create List   ${filecap_dict1}   ${filecap_dict2}  ${filecap_dict3}
    ${resp}=  Consumer Mass Communication for Appt  ${cookie}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${msg}    ${fileswithcaption}      ${apptid1}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"
