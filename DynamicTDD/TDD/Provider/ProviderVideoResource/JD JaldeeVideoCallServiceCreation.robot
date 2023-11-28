*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Video Call
Library           Collections
Library           String
Library           json
Library           DateTime
Library           requests
Library           FakerLibrary
Library           /ebs/TDD/db.py
Library           /ebs/TDD/excelfuncs.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/providers.py



# Update Virtual Calling Mode
#     [Arguments]  ${callingMode1}  ${ModeId1}   ${ModeStatus1}   ${instructions1}   ${callingMode2}  ${ModeId2}   ${ModeStatus2}   ${instructions2}
#     ${VirtualcallingMode1}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${instructions1}
#     ${VirtualcallingMode2}=  Create Dictionary   callingMode=${callingMode2}   value=${ModeId2}   status=${ModeStatus2}    instructions=${instructions2}
#     ${vcm}=  Create List  ${VirtualcallingMode1}   ${VirtualcallingMode2}
#     ${data}=  Create Dictionary   virtualCallingModes=${vcm}
#     ${data}=    json.dumps    ${data}
#     Check And Create YNW Session
#     ${resp}=  PUT On Session  ynw  /provider/account/settings/virtualCallingModes   data=${data}  expected_status=any
#     Log  ${resp.content}
#     [Return]  ${resp}


*** Variables ***

${jaldee_videocall_link}    https://zoom.us/j/{}?pwd=THVLcTBZa2lESFZQbU9DQTQrWUxWZz09
@{emptylist}


*** Test Cases ***


JD-TC-GetVideoCallMinutes-1

    [Documentation]  Get and verify Virtual service calling modes for video call.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME15}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Virtual Calling Mode
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes']}   []

    ${video_call_id1}=  Format String  ${jaldee_videocall_link}  ${PUSERNAME15}
 
    ${instructions1}=   FakerLibrary.sentence
  
    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${CallingModes[9]}   value=${video_call_id1}   status=ACTIVE    instructions=${instructions1}
    ${vcm1}=  Create List  ${VirtualcallingMode1}  

    ${resp}=  Update Virtual Calling Mode   ${vcm1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Virtual Calling Mode
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[9]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${video_call_id1}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${instructions1}


JD-TC-GetVideoCallMinutes-2

    [Documentation]  Get and verify Virtual service calling modes for video call without giving status.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME16}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Virtual Calling Mode
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes']}   []

    ${video_call_id1}=  Format String  ${jaldee_videocall_link}  ${PUSERNAME16}
   
    ${instructions1}=   FakerLibrary.sentence
    
    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${CallingModes[9]}   value=${video_call_id1}   instructions=${instructions1}
    ${vcm1}=  Create List  ${VirtualcallingMode1}  

    ${resp}=  Update Virtual Calling Mode   ${vcm1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}    ${VIRTUAL_CALLING_MODES_STATUS_INVALID}


JD-TC-GetVideoCallMinutes-3

    [Documentation]  Get and verify Virtual service calling modes for video call with inactive status.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME17}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Virtual Calling Mode
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes']}   []

    ${video_call_id1}=  Format String  ${jaldee_videocall_link}  ${PUSERNAME17}
  
    ${instructions1}=   FakerLibrary.sentence
   
    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${CallingModes[9]}   value=${video_call_id1}   status=INACTIVE    instructions=${instructions1}
    ${vcm1}=  Create List  ${VirtualcallingMode1}  

    ${resp}=  Update Virtual Calling Mode   ${vcm1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Virtual Calling Mode
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[9]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${video_call_id1}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          INACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${instructions1}


JD-TC-GetVideoCallMinutes-4

    [Documentation]  update virtual calling mode as video call without giving link.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME18}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Virtual Calling Mode
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes']}   []

    ${instructions1}=   FakerLibrary.sentence
  
    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${CallingModes[9]}   value=${EMPTY}   status=ACTIVE    instructions=${instructions1}
    ${vcm1}=  Create List  ${VirtualcallingMode1}  

    ${resp}=  Update Virtual Calling Mode   ${vcm1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

JD-TC-GetVideoCallMinutes-5

    [Documentation]  Create a virtual service for jaldee video call without adding video call addon 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME19}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Video Call Minutes 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}   "00 Hour 00 Minutes and 00 Seconds "

    ${video_call_id1}=  Format String  ${jaldee_videocall_link}  ${PUSERNAME19}
 
    ${instructions1}=   FakerLibrary.sentence
  
    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${CallingModes[9]}   value=${video_call_id1}   status=ACTIVE    instructions=${instructions1}
    ${vcm1}=  Create List  ${VirtualcallingMode1}  

    ${resp}=  Update Virtual Calling Mode   ${vcm1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Virtual Calling Mode
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[9]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${video_call_id1}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${instructions1}

    ${puserid1}=  Evaluate  ${PUSERNAME}+101089
    ${video_call_pid1}=  Format String  ${jaldee_videocall_link}  ${puserid1}
    Set Test Variable  ${callingMode1}     ${CallingModes[9]}
    Set Test Variable  ${ModeId1}          ${video_call_pid1}
    Set Test Variable  ${ModeStatus1}      ACTIVE
    ${Desc1}=    FakerLibrary.sentence
    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Desc1}
    ${virtualCallingModes}=  Create List  ${VirtualcallingMode1}

    ${ser_durtn}=   Random Int   min=2   max=10
    ${min_pre}=   Random Int   min=10   max=50
    ${Total}=   Random Int   min=100   max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    ${Total}=  Convert To Number  ${Total}  1
    ${SERVICE1}=    FakerLibrary.word
    ${description}=    FakerLibrary.word
    Set Test Variable  ${vstype}  ${vservicetype[1]}
    ${resp}=  Create virtual Service  ${SERVICE1}   ${description}   ${ser_durtn}   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre}  ${Total}  ${bool[1]}   ${bool[0]}   ${vstype}  ${virtualCallingModes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}    ${JALDEE_VIDEO_INSUFFICIENT}


JD-TC-GetVideoCallMinutes-6

    [Documentation]  Create a virtual service for jaldee video call

    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Video Call Minutes 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}   "00 Hour 00 Minutes and 00 Seconds "

    ${up_addons}=   Get upgradable addons
    Log  ${up_addons.json()}
    Should Be Equal As Strings    ${up_addons.status_code}   200
    Set Suite Variable  ${addons}  ${up_addons.json()}  

    ${addon_list}=  addons_all_license_applicable  ${addons}
    Log  ${addon_list}
    ${resp}=  Add addon  ${addon_list[3][0]['addon_id']}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Video Call Minutes 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}   "04 Hour 00 Minutes and 00 Seconds "

    ${video_call_id1}=  Format String  ${jaldee_videocall_link}  ${PUSERNAME20}
 
    ${instructions1}=   FakerLibrary.sentence
  
    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${CallingModes[9]}   value=${video_call_id1}   status=ACTIVE    instructions=${instructions1}
    ${vcm1}=  Create List  ${VirtualcallingMode1}  

    ${resp}=  Update Virtual Calling Mode   ${vcm1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Virtual Calling Mode
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[9]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${video_call_id1}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${instructions1}

    ${desc1}=    FakerLibrary.sentence
    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${CallingModes[9]}   value=${video_call_id1}   status=ACTIVE  instructions=${desc1}
    ${virtualCallingModes}=  Create List  ${VirtualcallingMode1}
    
    ${ser_durtn}=   Random Int   min=2   max=10
    ${min_pre}=   Random Int   min=10   max=50
    ${Total}=   Random Int   min=100   max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    ${Total}=  Convert To Number  ${Total}  1
    ${SERVICE1}=    FakerLibrary.word
    ${description}=    FakerLibrary.word
    Set Test Variable  ${vstype}  ${vservicetype[1]}
    ${resp}=  Create virtual Service  ${SERVICE1}   ${description}   ${ser_durtn}   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre}  ${Total}  ${bool[1]}   ${bool[0]}   ${vstype}  ${virtualCallingModes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${vser_id1}  ${resp.json()} 
    
    ${resp}=   Get Service By Id  ${vser_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[9]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${video_call_id1}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${desc1}


JD-TC-GetVideoCallMinutes-7

    [Documentation]  Create a virtual service for jaldee video call and take a waitlist for this service.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME21}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${prov_id1}  ${decrypted_data['id']}
    # Set Test Variable  ${prov_id1}  ${resp.json()['id']}

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[0]}'
        ${resp1}=   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    ELSE IF    '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[1]}'
        ${resp1}=   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}

    ${resp}=  Get Video Call Minutes 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}   "00 Hour 00 Minutes and 00 Seconds "

    ${up_addons}=   Get upgradable addons
    Log  ${up_addons.json()}
    Should Be Equal As Strings    ${up_addons.status_code}   200
    Set Suite Variable  ${addons}  ${up_addons.json()}  

    ${addon_list}=  addons_all_license_applicable  ${addons}
    Log  ${addon_list}
    ${resp}=  Add addon  ${addon_list[3][0]['addon_id']}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Video Call Minutes 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}   "04 Hour 00 Minutes and 00 Seconds "

    ${video_call_id1}=  Format String  ${jaldee_videocall_link}  ${PUSERNAME21}
 
    ${instructions1}=   FakerLibrary.sentence
  
    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${CallingModes[9]}   value=${video_call_id1}   status=ACTIVE    instructions=${instructions1}
    ${vcm1}=  Create List  ${VirtualcallingMode1}  

    ${resp}=  Update Virtual Calling Mode   ${vcm1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Virtual Calling Mode
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[9]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${video_call_id1}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${instructions1}

    ${desc1}=    FakerLibrary.sentence
    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${CallingModes[9]}   value=${video_call_id1}   status=ACTIVE  instructions=${desc1}
    ${virtualCallingModes}=  Create List  ${VirtualcallingMode1}
    
    ${ser_durtn}=   Random Int   min=2   max=10
    ${min_pre}=   Random Int   min=10   max=50
    ${Total}=   Random Int   min=100   max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    ${Total}=  Convert To Number  ${Total}  1
    ${SERVICE1}=    FakerLibrary.word
    ${description}=    FakerLibrary.word
    Set Test Variable  ${vstype}  ${vservicetype[1]}
    ${resp}=  Create virtual Service  ${SERVICE1}   ${description}   ${ser_durtn}   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre}  ${Total}  ${bool[1]}   ${bool[0]}   ${vstype}  ${virtualCallingModes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${vser_id1}  ${resp.json()} 
    
    ${resp}=   Get Service By Id  ${vser_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[9]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${video_call_id1}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${desc1}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        Set Test Variable  ${locId}
        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ELSE
        Set Test Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  30  
    ${eTime1}=  add_timezone_time  ${tz}  1  00  
    ${p1queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${locId}  ${vser_id1} 
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${queue1}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME20}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME20}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid1}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid1}  ${resp.json()[0]['id']}
    END

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME20}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${virtualService1}=  Create Dictionary   ${CallingModes[9]}=${video_call_id1}
    ${desc}=   FakerLibrary.word
    ${resp}=  Provider Add To WL With Virtual Service  ${pcid1}  ${vser_id1}  ${queue1}  ${DAY}  ${desc}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService1}   ${pcid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['waitlistStatus']}     ${wl_status[0]}
    Should Be Equal As Strings  ${resp.json()['videoCallButton']}    ${Qstate[0]}

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME20}   ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${account_id1}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['service']['virtualCallingModes'][0]['callingMode']}     ${CallingModes[9]}
   
JD-TC-GetVideoCallMinutes-8

    [Documentation]  Create a virtual service for jaldee video call and take a waitlist for this service.
    ...     then send message to consumer

    ${resp}=  Encrypted Provider Login  ${PUSERNAME22}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[0]}'
        ${resp1}=   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    ELSE IF    '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[1]}'
        ${resp1}=   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}


    ${resp}=  Get Video Call Minutes 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}   "00 Hour 00 Minutes and 00 Seconds "

    ${up_addons}=   Get upgradable addons
    Log  ${up_addons.json()}
    Should Be Equal As Strings    ${up_addons.status_code}   200
    Set Suite Variable  ${addons}  ${up_addons.json()}  

    ${addon_list}=  addons_all_license_applicable  ${addons}
    Log  ${addon_list}
    ${resp}=  Add addon  ${addon_list[3][0]['addon_id']}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Video Call Minutes 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}   "04 Hour 00 Minutes and 00 Seconds "

    ${video_call_id1}=  Format String  ${jaldee_videocall_link}  ${PUSERNAME22}
 
    ${instructions1}=   FakerLibrary.sentence
  
    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${CallingModes[9]}   value=${video_call_id1}   status=ACTIVE    instructions=${instructions1}
    ${vcm1}=  Create List  ${VirtualcallingMode1}  

    ${resp}=  Update Virtual Calling Mode   ${vcm1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Virtual Calling Mode
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[9]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${video_call_id1}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${instructions1}

    ${desc1}=    FakerLibrary.sentence
    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${CallingModes[9]}   value=${video_call_id1}   status=ACTIVE  instructions=${desc1}
    ${virtualCallingModes}=  Create List  ${VirtualcallingMode1}
    
    ${ser_durtn}=   Random Int   min=2   max=10
    ${min_pre}=   Random Int   min=10   max=50
    ${Total}=   Random Int   min=100   max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    ${Total}=  Convert To Number  ${Total}  1
    ${SERVICE1}=    FakerLibrary.word
    ${description}=    FakerLibrary.word
    Set Test Variable  ${vstype}  ${vservicetype[1]}
    ${resp}=  Create virtual Service  ${SERVICE1}   ${description}   ${ser_durtn}   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre}  ${Total}  ${bool[1]}   ${bool[0]}   ${vstype}  ${virtualCallingModes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${vser_id1}  ${resp.json()} 
    
    ${resp}=   Get Service By Id  ${vser_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[9]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${video_call_id1}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${desc1}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        Set Test Variable  ${locId}
        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ELSE
        Set Test Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  30  
    ${eTime1}=  add_timezone_time  ${tz}  1  00  
    ${p1queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${locId}  ${vser_id1} 
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${queue1}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME21}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME21}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid1}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid1}  ${resp.json()[0]['id']}
    END

    ${virtualService1}=  Create Dictionary   ${CallingModes[9]}=${video_call_id1}
    ${desc}=   FakerLibrary.word
    ${resp}=  Provider Add To WL With Virtual Service  ${pcid1}  ${vser_id1}  ${queue1}  ${DAY}  ${desc}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService1}   ${pcid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['waitlistStatus']}     ${wl_status[0]}
    Should Be Equal As Strings  ${resp.json()['videoCallButton']}    ${Qstate[0]}

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME22}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${msg}=  Fakerlibrary.sentence
    ${caption}=  Fakerlibrary.sentence

    ${resp}=  Imageupload.providerWLCom   ${cookie}   ${wid1}  ${msg}  ${messageType[0]}  ${caption}  ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME21}   ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-GetVideoCallMinutes-9

    [Documentation]  Create a virtual service for jaldee video call and take a waitlist for this service
    ...       then create a video call meeting request by provider.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${prov_id1}  ${decrypted_data['id']}
    # Set Test Variable  ${prov_id1}  ${resp.json()['id']}

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[0]}'
        ${resp1}=   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    ELSE IF    '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[1]}'
        ${resp1}=   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}

    ${resp}=  Get Video Call Minutes 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}   "00 Hour 00 Minutes and 00 Seconds "

    ${up_addons}=   Get upgradable addons
    Log  ${up_addons.json()}
    Should Be Equal As Strings    ${up_addons.status_code}   200
    Set Suite Variable  ${addons}  ${up_addons.json()}  

    ${addon_list}=  addons_all_license_applicable  ${addons}
    Log  ${addon_list}
    ${resp}=  Add addon  ${addon_list[3][0]['addon_id']}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Video Call Minutes 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}   "04 Hour 00 Minutes and 00 Seconds "

    ${video_call_id1}=  Format String  ${jaldee_videocall_link}  ${PUSERNAME24}
 
    ${instructions1}=   FakerLibrary.sentence
  
    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${CallingModes[9]}   value=${video_call_id1}   status=ACTIVE    instructions=${instructions1}
    ${vcm1}=  Create List  ${VirtualcallingMode1}  

    ${resp}=  Update Virtual Calling Mode   ${vcm1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Virtual Calling Mode
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[9]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${video_call_id1}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${instructions1}

    ${desc1}=    FakerLibrary.sentence
    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${CallingModes[9]}   value=${video_call_id1}   status=ACTIVE  instructions=${desc1}
    ${virtualCallingModes}=  Create List  ${VirtualcallingMode1}
    
    ${ser_durtn}=   Random Int   min=2   max=10
    ${min_pre}=   Random Int   min=10   max=50
    ${Total}=   Random Int   min=100   max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    ${Total}=  Convert To Number  ${Total}  1
    ${SERVICE1}=    FakerLibrary.word
    ${description}=    FakerLibrary.word
    Set Test Variable  ${vstype}  ${vservicetype[1]}
    ${resp}=  Create virtual Service  ${SERVICE1}   ${description}   ${ser_durtn}   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre}  ${Total}  ${bool[1]}   ${bool[0]}   ${vstype}  ${virtualCallingModes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${vser_id1}  ${resp.json()} 
    
    ${resp}=   Get Service By Id  ${vser_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[9]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${video_call_id1}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${desc1}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        Set Test Variable  ${locId}
        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ELSE
        Set Test Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  30  
    ${eTime1}=  add_timezone_time  ${tz}  1  00  
    ${p1queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${locId}  ${vser_id1} 
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${queue1}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME12}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME12}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid1}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid1}  ${resp.json()[0]['id']}
    END

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME12}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${virtualService1}=  Create Dictionary   ${CallingModes[9]}=${video_call_id1}
    ${desc}=   FakerLibrary.word
    ${resp}=  Provider Add To WL With Virtual Service  ${pcid1}  ${vser_id1}  ${queue1}  ${DAY}  ${desc}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService1}   ${pcid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['waitlistStatus']}     ${wl_status[0]}
    Should Be Equal As Strings  ${resp.json()['videoCallButton']}    ${Qstate[0]}

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME12}   ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${account_id1}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['service']['virtualCallingModes'][0]['callingMode']}     ${CallingModes[9]}
    Should Be Equal As Strings  ${resp.json()['waitlistStatus']}     ${wl_status[0]}

    ${resp}=  ConsumerLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Create Waitlist Meeting Request   ${wid1}   ${CallingModes[9]}   ${waitlistedby[1]}  ${waitlistedby[0]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist Meeting Request    ${wid1}    ${CallingModes[9]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME12}   ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${account_id1}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-GetVideoCallMinutes-10

    [Documentation]  Create a virtual service for jaldee video call and take a waitlist for this service
    ...       then create a video call meeting request by provider, then get the link status of the video call.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME25}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${prov_id1}  ${decrypted_data['id']}
    # Set Test Variable  ${prov_id1}  ${resp.json()['id']}

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[0]}'
        ${resp1}=   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    ELSE IF    '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[1]}'
        ${resp1}=   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}

    ${resp}=  Get Video Call Minutes 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}   "00 Hour 00 Minutes and 00 Seconds "

    ${up_addons}=   Get upgradable addons
    Log  ${up_addons.json()}
    Should Be Equal As Strings    ${up_addons.status_code}   200
    Set Suite Variable  ${addons}  ${up_addons.json()}  

    ${addon_list}=  addons_all_license_applicable  ${addons}
    Log  ${addon_list}
    ${resp}=  Add addon  ${addon_list[3][0]['addon_id']}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Video Call Minutes 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}   "04 Hour 00 Minutes and 00 Seconds "

    ${video_call_id1}=  Format String  ${jaldee_videocall_link}  ${PUSERNAME25}
 
    ${instructions1}=   FakerLibrary.sentence
  
    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${CallingModes[9]}   value=${video_call_id1}   status=ACTIVE    instructions=${instructions1}
    ${vcm1}=  Create List  ${VirtualcallingMode1}  

    ${resp}=  Update Virtual Calling Mode   ${vcm1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Virtual Calling Mode
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[9]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${video_call_id1}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${instructions1}

    ${desc1}=    FakerLibrary.sentence
    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${CallingModes[9]}   value=${video_call_id1}   status=ACTIVE  instructions=${desc1}
    ${virtualCallingModes}=  Create List  ${VirtualcallingMode1}
    
    ${ser_durtn}=   Random Int   min=2   max=10
    ${min_pre}=   Random Int   min=10   max=50
    ${Total}=   Random Int   min=100   max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    ${Total}=  Convert To Number  ${Total}  1
    ${SERVICE1}=    FakerLibrary.word
    ${description}=    FakerLibrary.word
    Set Test Variable  ${vstype}  ${vservicetype[1]}
    ${resp}=  Create virtual Service  ${SERVICE1}   ${description}   ${ser_durtn}   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre}  ${Total}  ${bool[1]}   ${bool[0]}   ${vstype}  ${virtualCallingModes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${vser_id1}  ${resp.json()} 
    
    ${resp}=   Get Service By Id  ${vser_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[9]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${video_call_id1}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${desc1}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        Set Test Variable  ${locId}
        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ELSE
        Set Test Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  30  
    ${eTime1}=  add_timezone_time  ${tz}  1  00  
    ${p1queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${locId}  ${vser_id1} 
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${queue1}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME13}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME13}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid1}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid1}  ${resp.json()[0]['id']}
    END

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME13}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${virtualService1}=  Create Dictionary   ${CallingModes[9]}=${video_call_id1}
    ${desc}=   FakerLibrary.word
    ${resp}=  Provider Add To WL With Virtual Service  ${pcid1}  ${vser_id1}  ${queue1}  ${DAY}  ${desc}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService1}   ${pcid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['waitlistStatus']}     ${wl_status[0]}
    Should Be Equal As Strings  ${resp.json()['videoCallButton']}    ${Qstate[0]}

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME13}   ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${account_id1}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['service']['virtualCallingModes'][0]['callingMode']}     ${CallingModes[9]}
    Should Be Equal As Strings  ${resp.json()['waitlistStatus']}     ${wl_status[0]}

    ${resp}=  ConsumerLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME25}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Create Waitlist Meeting Request   ${wid1}   ${CallingModes[9]}   ${waitlistedby[1]}  ${waitlistedby[0]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist Meeting Request    ${wid1}    ${CallingModes[9]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Create video Call Meeting Link  ${pcid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{words} =  Split String    ${resp.json()['providerMeetingUrl']}       / 
    ${meeting_id}=   Set Variable   ${words[4]} 

    ${resp}=  Get video Link Status    ${meeting_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['linkStatus']}     ${Qstate[0]}


JD-TC-GetVideoCallMinutes-11

    [Documentation]  Create a virtual service for jaldee video call and take a waitlist for this service
    ...       then create a video call meeting request by provider, then get the status of the video call.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${prov_id1}  ${decrypted_data['id']}
    # Set Test Variable  ${prov_id1}  ${resp.json()['id']}

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[0]}'
        ${resp1}=   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    ELSE IF    '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[1]}'
        ${resp1}=   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}

    ${resp}=  Get Video Call Minutes 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}   "00 Hour 00 Minutes and 00 Seconds "

    ${up_addons}=   Get upgradable addons
    Log  ${up_addons.json()}
    Should Be Equal As Strings    ${up_addons.status_code}   200
    Set Suite Variable  ${addons}  ${up_addons.json()}  

    ${addon_list}=  addons_all_license_applicable  ${addons}
    Log  ${addon_list}
    ${resp}=  Add addon  ${addon_list[3][0]['addon_id']}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Video Call Minutes 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}   "04 Hour 00 Minutes and 00 Seconds "

    ${video_call_id1}=  Format String  ${jaldee_videocall_link}  ${PUSERNAME26}
 
    ${instructions1}=   FakerLibrary.sentence
  
    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${CallingModes[9]}   value=${video_call_id1}   status=ACTIVE    instructions=${instructions1}
    ${vcm1}=  Create List  ${VirtualcallingMode1}  

    ${resp}=  Update Virtual Calling Mode   ${vcm1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Virtual Calling Mode
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[9]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${video_call_id1}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${instructions1}

    ${desc1}=    FakerLibrary.sentence
    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${CallingModes[9]}   value=${video_call_id1}   status=ACTIVE  instructions=${desc1}
    ${virtualCallingModes}=  Create List  ${VirtualcallingMode1}
    
    ${ser_durtn}=   Random Int   min=2   max=10
    ${min_pre}=   Random Int   min=10   max=50
    ${Total}=   Random Int   min=100   max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    ${Total}=  Convert To Number  ${Total}  1
    ${SERVICE1}=    FakerLibrary.word
    ${description}=    FakerLibrary.word
    Set Test Variable  ${vstype}  ${vservicetype[1]}
    ${resp}=  Create virtual Service  ${SERVICE1}   ${description}   ${ser_durtn}   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre}  ${Total}  ${bool[1]}   ${bool[0]}   ${vstype}  ${virtualCallingModes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${vser_id1}  ${resp.json()} 
    
    ${resp}=   Get Service By Id  ${vser_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[9]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${video_call_id1}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${desc1}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        Set Test Variable  ${locId}
        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ELSE
        Set Test Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  30  
    ${eTime1}=  add_timezone_time  ${tz}  1  00  
    ${p1queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${locId}  ${vser_id1} 
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${queue1}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME14}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME14}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid1}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid1}  ${resp.json()[0]['id']}
    END

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME14}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${virtualService1}=  Create Dictionary   ${CallingModes[9]}=${video_call_id1}
    ${desc}=   FakerLibrary.word
    ${resp}=  Provider Add To WL With Virtual Service  ${pcid1}  ${vser_id1}  ${queue1}  ${DAY}  ${desc}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService1}   ${pcid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['waitlistStatus']}     ${wl_status[0]}
    Should Be Equal As Strings  ${resp.json()['videoCallButton']}    ${Qstate[0]}

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME14}   ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${account_id1}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['service']['virtualCallingModes'][0]['callingMode']}     ${CallingModes[9]}
    Should Be Equal As Strings  ${resp.json()['waitlistStatus']}     ${wl_status[0]}

    ${resp}=  ConsumerLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Create Waitlist Meeting Request   ${wid1}   ${CallingModes[9]}   ${waitlistedby[1]}  ${waitlistedby[0]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist Meeting Request    ${wid1}    ${CallingModes[9]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Create video Call Meeting Link  ${pcid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{words} =  Split String    ${resp.json()['providerMeetingUrl']}       / 
    ${meeting_id}=   Set Variable   ${words[4]} 

    ${resp}=  Get video Status    ${meeting_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['linkStatus']}     ${Qstate[0]}
    Should Be Equal As Strings  ${resp.json()['meetingStatus']}     ${cupnpaymentStatus[1]}


JD-TC-GetVideoCallMinutes-12

    [Documentation]  Create a virtual service for jaldee video call and take a waitlist for this service
    ...       then create a video call meeting request by provider, then start the video call.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME27}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${prov_id1}  ${decrypted_data['id']}
    # Set Test Variable  ${prov_id1}  ${resp.json()['id']}

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[0]}'
        ${resp1}=   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    ELSE IF    '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[1]}'
        ${resp1}=   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}

    ${resp}=  Get Video Call Minutes 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}   "00 Hour 00 Minutes and 00 Seconds "

    ${up_addons}=   Get upgradable addons
    Log  ${up_addons.json()}
    Should Be Equal As Strings    ${up_addons.status_code}   200
    Set Suite Variable  ${addons}  ${up_addons.json()}  

    ${addon_list}=  addons_all_license_applicable  ${addons}
    Log  ${addon_list}
    ${resp}=  Add addon  ${addon_list[3][0]['addon_id']}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Video Call Minutes 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}   "04 Hour 00 Minutes and 00 Seconds "

    ${video_call_id1}=  Format String  ${jaldee_videocall_link}  ${PUSERNAME27}
 
    ${instructions1}=   FakerLibrary.sentence
  
    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${CallingModes[9]}   value=${video_call_id1}   status=ACTIVE    instructions=${instructions1}
    ${vcm1}=  Create List  ${VirtualcallingMode1}  

    ${resp}=  Update Virtual Calling Mode   ${vcm1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Virtual Calling Mode
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[9]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${video_call_id1}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${instructions1}

    ${desc1}=    FakerLibrary.sentence
    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${CallingModes[9]}   value=${video_call_id1}   status=ACTIVE  instructions=${desc1}
    ${virtualCallingModes}=  Create List  ${VirtualcallingMode1}
    
    ${ser_durtn}=   Random Int   min=2   max=10
    ${min_pre}=   Random Int   min=10   max=50
    ${Total}=   Random Int   min=100   max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    ${Total}=  Convert To Number  ${Total}  1
    ${SERVICE1}=    FakerLibrary.word
    ${description}=    FakerLibrary.word
    Set Test Variable  ${vstype}  ${vservicetype[1]}
    ${resp}=  Create virtual Service  ${SERVICE1}   ${description}   ${ser_durtn}   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre}  ${Total}  ${bool[1]}   ${bool[0]}   ${vstype}  ${virtualCallingModes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${vser_id1}  ${resp.json()} 
    
    ${resp}=   Get Service By Id  ${vser_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[9]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${video_call_id1}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${desc1}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        Set Test Variable  ${locId}
        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ELSE
        Set Test Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}  
    ${eTime1}=  add_timezone_time  ${tz}  1  00  
    ${p1queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${locId}  ${vser_id1} 
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${queue1}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME15}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME15}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid1}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid1}  ${resp.json()[0]['id']}
    END

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME15}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${virtualService1}=  Create Dictionary   ${CallingModes[9]}=${video_call_id1}
    ${desc}=   FakerLibrary.word
    ${resp}=  Provider Add To WL With Virtual Service  ${pcid1}  ${vser_id1}  ${queue1}  ${DAY}  ${desc}  ${bool[1]}  ${waitlistMode[2]}  ${virtualService1}   ${pcid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['waitlistStatus']}     ${wl_status[0]}
    Should Be Equal As Strings  ${resp.json()['videoCallButton']}    ${Qstate[0]}

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME15}   ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${account_id1}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['service']['virtualCallingModes'][0]['callingMode']}     ${CallingModes[9]}
    Should Be Equal As Strings  ${resp.json()['waitlistStatus']}     ${wl_status[0]}

    ${resp}=  ConsumerLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME27}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Create Waitlist Meeting Request   ${wid1}   ${CallingModes[9]}   ${waitlistedby[1]}  ${waitlistedby[0]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist Meeting Request    ${wid1}    ${CallingModes[9]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Create video Call Meeting Link  ${pcid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{words} =  Split String    ${resp.json()['providerMeetingUrl']}       / 
    ${meeting_id}=   Set Variable   ${words[4]} 

    ${resp}=  Get video Status    ${meeting_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['linkStatus']}     ${Qstate[0]}
    Should Be Equal As Strings  ${resp.json()['meetingStatus']}     ${cupnpaymentStatus[1]}

    ${resp}=  Provider Video Call ready  ${wid1}  ${boolean[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  

    ${resp}=  Waitlist Action  ${waitlist_actions[1]}   ${wid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Video Call Minutes 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

*** comment ***



JD-TC-GetVideoCallMinutes-1

    [Documentation]  Update virtual calling mode with one calling mode as inactive.

JD-TC-GetVideoCallMinutes-1

    [Documentation]  Update virtual calling mode with one calling mode as inactive, then try to take booking with inactive calling mode.


