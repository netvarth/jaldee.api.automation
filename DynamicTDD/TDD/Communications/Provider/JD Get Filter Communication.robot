*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Communications
Library           Collections
Library           String
Library           json
Library           /ebs/TDD/db.py
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/consumermail.py


*** Variables ***
${digits}       0123456789
@{EMPTY_List} 
@{person_ahead}   0  1  2  3  4  5  6
${self}         0
@{service_duration}   5   20
${parallel}     1
${SERVICE1}   SERVICE1
${SERVICE2}   SERVICE2
${jpgfile}     /ebs/TDD/uploadimage.jpg
${pngfile}     /ebs/TDD/upload.png
${pdffile}     /ebs/TDD/sample.pdf

*** Test Cases ***
JD-TC-Get Filter Communication-1
    [Documentation]   Getting Filter Communication provider with consumer
    
    ${id}=  get_id  ${CUSERNAME2} 
    Set Suite Variable  ${id}  ${id}
    ${account_id1}=  get_acc_id  ${PUSERNAME8}
    clear_Providermsg  ${PUSERNAME8}
    ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${c_id}=  get_id  ${CUSERNAME1}
    clear_Consumermsg  ${CUSERNAME1}
    ${msg}=  FakerLibrary.text
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${caption}=  Fakerlibrary.sentence
    # ${resp}=  General Communication with Provider   ${msg}   ${account_id1}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME1}   ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}   ${account_id1}  ${msg}  ${messageType[0]}  ${caption}   ${EMPTY}   
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME2}   ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}   ${account_id1}  ${msg}  ${messageType[0]}  ${caption}   ${EMPTY}   
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME2}   ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}   ${account_id1}  ${msg}  ${messageType[0]}  ${caption}   ${EMPTY}   
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME8}   ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Imageupload.GeneralCommunicationWithConsumer   ${cookie}   ${c_id}  ${msg}  ${messageType[0]}  ${caption}   ${EMPTY}  
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login  ${PUSERNAME8}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Filter Comm
    Log   ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200
    Verify Response List   ${resp}  0   threadId=${c_id}   unreadCount=1    latestMsg=${msg}
    Verify Response List   ${resp}  1   threadId=${id}   unreadCount=2    latestMsg=${msg}

JD-TC-Get Filter Communication-2

    [Documentation]  Get Provider unread message count after get Filter communication by provider
    ${account_id1}=  get_acc_id  ${PUSERNAME8}
    clear_Providermsg  ${PUSERNAME8}

    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${c_id}=  get_id  ${CUSERNAME2}
    clear_Consumermsg  ${CUSERNAME2}
    # clear_Providermsg  ${PUSERNAME8}
    ${c_id1}=  get_id  ${CUSERNAME1}
    clear_Consumermsg  ${CUSERNAME1}

    ${msg}=  FakerLibrary.text
    Set Suite Variable  ${msg}
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${caption}=  Fakerlibrary.sentence
    Set Suite Variable  ${caption}
    
    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME1}   ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}   ${account_id1}  ${msg}  ${messageType[0]}  ${caption}   ${EMPTY}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME2}   ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}   ${account_id1}  ${msg}  ${messageType[0]}  ${caption}   ${EMPTY}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME1}   ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}   ${account_id1}  ${msg}  ${messageType[0]}  ${caption}   ${EMPTY}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Encrypted Provider Login  ${PUSERNAME8}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${p_id6}  ${decrypted_data['id']}

    # Set Test Variable  ${p_id6}  ${resp.json()['id']}
    # ${account_id1}=  get_acc_id  ${PUSERNAME8}
    ${resp}=  Get provider Unread message Count
    Log   ${resp.content} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  3

    ${resp}=  Get provider communications
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  accountId=${account_id1}  msg=${msg}
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}    ${c_id1}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}   0
    Set Test Variable  ${msgId1}  ${resp.json()[0]['messageId']}

    Verify Response List  ${resp}  1  accountId=${account_id1}  msg=${msg}
    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}    ${c_id}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}   0
    Set Test Variable  ${msgId2}  ${resp.json()[1]['messageId']}

    Verify Response List  ${resp}  2  accountId=${account_id1}  msg=${msg}
    Should Be Equal As Strings  ${resp.json()[2]['owner']['id']}    ${c_id1}
    Should Be Equal As Strings  ${resp.json()[2]['receiver']['id']}   0
    Set Test Variable  ${msgId3}  ${resp.json()[2]['messageId']}

    ${resp}=  Reading Consumer Communications  ${c_id1}  ${msgId3}   0 
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get provider Unread message Count
    Log   ${resp.content} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2

    ${resp}=   Reading Consumer Communications  ${c_id}  ${msgId2}   0 
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get provider Unread message Count
    Log   ${resp.content} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

    ${resp}=  Get Filter Comm
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}  0   threadId=${c_id1}   unreadCount=1    latestMsg=${msg}
    Verify Response List   ${resp}  1   threadId=${c_id}   unreadCount=0    latestMsg=${msg}

JD-TC-Get Filter Communication-3
    [Documentation]   filter communication with read all unread msg
    ${account_id1}=  get_acc_id  ${PUSERNAME8}
    clear_Providermsg  ${PUSERNAME8}
    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${c_id}=  get_id  ${CUSERNAME2}
    clear_Consumermsg  ${CUSERNAME2}
    clear_Providermsg  ${PUSERNAME8}
    ${c_id1}=  get_id  ${CUSERNAME1}
    clear_Consumermsg  ${CUSERNAME1}
    ${c_id2}=  get_id  ${CUSERNAME3}
    clear_Consumermsg  ${CUSERNAME3}
    ${msg}=  FakerLibrary.text
    Set Suite Variable  ${msg}
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${caption}=  Fakerlibrary.sentence
    Set Suite Variable  ${caption}
    # ${resp}=  General Communication with Provider   ${msg8}   ${account_id1}
    # Should Be Equal As Strings  ${resp.status_code}  200 
    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME1}   ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}   ${account_id1}  ${msg}  ${messageType[0]}  ${caption}   ${EMPTY}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME2}   ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}   ${account_id1}  ${msg}  ${messageType[0]}  ${caption}   ${EMPTY}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME1}   ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}   ${account_id1}  ${msg}  ${messageType[0]}  ${caption}   ${EMPTY}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME3}   ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}   ${account_id1}  ${msg}  ${messageType[0]}  ${caption}   ${EMPTY}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Encrypted Provider Login  ${PUSERNAME8}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${p_id6}  ${decrypted_data['id']}

    # Set Test Variable  ${p_id6}  ${resp.json()['id']}
    # ${account_id1}=  get_acc_id  ${PUSERNAME8}
    ${resp}=  Get provider Unread message Count
    Log   ${resp.content} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  4

    ${resp}=  Get provider communications
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  accountId=${account_id1}  msg=${msg}
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}    ${c_id1}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}   0
    Set Test Variable  ${msgId1}  ${resp.json()[0]['messageId']}

    Verify Response List  ${resp}  1  accountId=${account_id1}  msg=${msg}
    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}    ${c_id}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}   0
    Set Test Variable  ${msgId2}  ${resp.json()[1]['messageId']}

    Verify Response List  ${resp}  2  accountId=${account_id1}  msg=${msg}
    Should Be Equal As Strings  ${resp.json()[2]['owner']['id']}    ${c_id1}
    Should Be Equal As Strings  ${resp.json()[2]['receiver']['id']}   0
    Set Test Variable  ${msgId3}  ${resp.json()[2]['messageId']}

    Verify Response List  ${resp}  3  accountId=${account_id1}  msg=${msg}
    Should Be Equal As Strings  ${resp.json()[3]['owner']['id']}    ${c_id2}
    Should Be Equal As Strings  ${resp.json()[3]['receiver']['id']}   0
    Set Test Variable  ${msgId4}  ${resp.json()[3]['messageId']}

    ${resp}=  Reading Consumer Communications  ${c_id1}  ${msgId3}-${msgId1}   0 
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get provider Unread message Count
    Log   ${resp.content} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  2

    ${resp}=   Reading Consumer Communications  ${c_id}  ${msgId2}   0 
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get provider Unread message Count
    Log   ${resp.content} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

    ${resp}=   Reading Consumer Communications  ${c_id2}  ${msgId4}   0 
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get provider Unread message Count
    Log   ${resp.content} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  0
    
    ${resp}=  Get Filter Comm
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List   ${resp}  0   threadId=${c_id1}   unreadCount=0    latestMsg=${msg}
    Verify Response List   ${resp}  1   threadId=${c_id}   unreadCount=0    latestMsg=${msg}
    Verify Response List   ${resp}  2   threadId=${c_id2}   unreadCount=0    latestMsg=${msg}


JD-TC-Get Filter Communication-4
    [Documentation]   filter communication for mass communication

    ${resp}=  Consumer Login  ${CUSERNAME36}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}
    Set Test Variable  ${uname}   ${resp.json()['userName']}

    ${resp}=  Consumer Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME8}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${p_id}  ${decrypted_data['id']}

    # Set Test Variable  ${p_id}  ${resp.json()['id']}

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    IF   ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}
        ${resp1}=   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
        Log  ${resp1.json()}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}  
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    clear_service   ${PUSERNAME8}
    clear_location  ${PUSERNAME8}
    clear_customer   ${PUSERNAME8}
    clear_Consumermsg  ${PUSERNAME8}
    clear_Providermsg  ${PUSERNAME8}

    ${resp}=   Get Service
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get provider communications
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${lid}=  Create Sample Location
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    clear_appt_schedule   ${PUSERNAME8}

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
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}   ${sTime1}   ${eTime1}       ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}

    ${resp}=  AddCustomer  ${CUSERNAME36}  firstName=${fname}   lastName=${lname}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}

    ${mem_fname}=   FakerLibrary.first_name
    ${mem_lname}=   FakerLibrary.last_name
    ${dob}=      FakerLibrary.date
    ${resp}=  AddFamilyMemberByProvider  ${cid}  ${mem_fname}  ${mem_lname}  ${dob}  ${Genderlist[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mem_id}  ${resp.json()}

    ${resp}=  ListFamilyMemberByProvider  ${cid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor2}=  Create Dictionary  id=${mem_id}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}  ${apptfor2}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer   ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${Keys}=  Get Dictionary Keys  ${resp.json()}   sort_keys=False 
    ${apptid11}=  Get From Dictionary  ${resp.json()}  ${mem_fname}
    Set Suite Variable   ${apptid11}
    ${apptid12}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${cookie}   ${resp}=    Imageupload.spLogin     ${PUSERNAME8}     ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200
    ${caption1}=  Fakerlibrary.Sentence
    ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
    ${caption2}=  Fakerlibrary.Sentence
    ${filecap_dict2}=  Create Dictionary   file=${pngfile}   caption=${caption2}
    ${caption3}=  Fakerlibrary.Sentence
    ${filecap_dict3}=  Create Dictionary   file=${pdffile}   caption=${caption3}
    @{fileswithcaption}=  Create List   ${filecap_dict1}   ${filecap_dict2}  ${filecap_dict3}
    ${msg}=  Fakerlibrary.Sentence
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}

    ${resp}=  Consumer Mass Communication for Appt  ${cookie}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${msg}    ${fileswithcaption}      ${apptid11}   ${apptid12} 
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep   03s


    ${resp}=  Get Appointment Messages
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${MassCom}=  Set Variable   ${resp.json()['checkinMessages']['massCommunication']['Consumer_APP']} 

    ${msg1}=  Replace String  ${MassCom}  [consumer]   ${mem_fname}${SPACE}${mem_lname}
    ${msg1}=  Replace String  ${msg1}  [type]   booking
    ${msg1}=  Replace String  ${msg1}  [message]   ${msg}

    sleep  2s
    ${resp}=  Get provider communications
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()[2]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[2]['waitlistId']}         ${apptid11}
    Should Be Equal As Strings  ${resp.json()[2]['msg']}                ${msg1}
    Should Be Equal As Strings  ${resp.json()[2]['receiver']['id']}     ${jdconID}
    
    Should Contain 	${resp.json()[2]}   attachements
    ${attachment-len}=  Get Length  ${resp.json()[2]['attachements']}
    Should Be Equal As Strings  ${attachment-len}  3

    Dictionary Should Contain Key  ${resp.json()[2]['attachements'][0]}   s3path
    Dictionary Should Contain Key  ${resp.json()[2]['attachements'][0]}   thumbPath
    

    Dictionary Should Contain Key  ${resp.json()[2]['attachements'][1]}   s3path
    Dictionary Should Contain Key  ${resp.json()[2]['attachements'][1]}   thumbPath
    

    Dictionary Should Contain Key  ${resp.json()[2]['attachements'][1]}   s3path
    Dictionary Should Contain Key  ${resp.json()[2]['attachements'][1]}   thumbPath

    ${resp}=  Get Filter Comm
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Get Unread Message Count-UH1
    [Documentation]   Get Filter Communication without login
    ${resp}=  Get Filter Comm
    Should Be Equal As Strings  ${resp.status_code}  419          
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

JD-TC-Get Unread Message Count-UH2
    [Documentation]  consumer login to access the get Filter Communication 
    ${resp}=   ConsumerLogin  ${CUSERNAME2}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Filter Comm
    Should Be Equal As Strings  ${resp.status_code}  401  
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}" 