*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Appointment Report
Library           Collections
Library           String
Library           json
Library           DateTime
Library           requests
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumermail.py
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py


       
*** Variables ***
${SERVICE1}   SERVICE1
${SERVICE2}   SERVICE2
${SERVICE3}   SERVICE3
${SERVICE4}   SERVICE4
${parallel}     1
${digits}       0123456789
${self}         0
@{service_duration}   5   20
${ZOOM_url}    https://zoom.us/j/{}?pwd=THVLcTBZa2lESFZQbU9DQTQrWUxWZz09
@{EMPTY_List}
@{reportNames}     report112   report112#14  Report234@!  report!2  123reort  124Report  @1!Report
@{Statuses}    NEW    INPROGRESS   CANCELED    DONE    PDFUPLOADED     SEEN  FALIED



@{dom_list}
@{provider_list}
@{multiloc_providers}
@{multiloc_billable_providers}

*** Test Cases ***
JD-TC-Get_Report_ByStatus-1
    [Documentation]  Get Appointment report  By report status
    ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${pid}=  get_acc_id  ${PUSERNAME24}
    Set Suite Variable  ${pid}

    ${duration}=   Random Int  min=2  max=10
    Set Suite Variable   ${duration}
    
    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}   ${duration}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${Empty}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  calculationMode=${calc_mode[1]}  trnArndTime=${duration}  futureDateWaitlist=${bool[1]}  showTokenId=${bool[1]}  onlineCheckIns=${bool[1]}  maxPartySize=1
    
    clear_queue     ${PUSERNAME24}
    clear_service   ${PUSERNAME24}
    clear_appt_schedule   ${PUSERNAME24}

    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  55
    Set Suite Variable  ${DAY2}
    ${description}=     FakerLibrary.sentence
    Set Suite Variable   ${description}
    ${firstname1}=  FakerLibrary.first_name
    Set Test Variable  ${firstname1}
    set Suite Variable  ${email}  ${firstname1}${CUSERNAME7}${C_Email}.${test_mail}

    ${P1SERVICE1}=    FakerLibrary.word
    Set Suite Variable   ${P1SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    Set Suite Variable   ${min_pre}
    ${servicecharge}=   Random Int  min=100  max=500
    Set Suite Variable   ${servicecharge}
    ${Total1}=  Convert To Number  ${servicecharge}  1 
    Set Suite Variable   ${Total}   ${Total1}
    ${amt_float}=  twodigitfloat  ${Total}
    Set Suite Variable  ${amt_float}  ${amt_float}  
    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7

    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration[1]}  ${status[0]}    ${btype}  ${bool[1]}  ${notifytype[2]}  ${min_pre}  ${Total}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_s1}  ${resp.json()}

    ${P1SERVICE2}=    FakerLibrary.word
    Set Suite Variable   ${P1SERVICE2}

    ${servicecharge2}=   Random Int  min=100  max=500
    Set Suite Variable   ${servicecharge2}
    Set Suite Variable   ${min_pre2}   ${servicecharge2}
    ${Total2}=  Convert To Number  ${servicecharge2}  1 
    Set Suite Variable   ${Total2}
    ${amt_float2}=  twodigitfloat  ${Total2}
    Set Suite Variable  ${amt_float2} 

    ${resp}=  Create Service  ${P1SERVICE2}  ${desc}   ${service_duration[1]}  ${status[0]}    ${btype}  ${bool[1]}  ${notifytype[2]}  ${min_pre2}  ${Total2}  ${bool[1]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_s2}  ${resp.json()}


    ${ZOOM_id2}=  Format String  ${ZOOM_url}  ${PUSERNAME28}
    Set Suite Variable   ${ZOOM_id2}

    ${PUSERPH_id2}=  Evaluate  ${PUSERNAME}+10784101
    ${ZOOM_Pid2}=  Format String  ${ZOOM_url}  ${PUSERNAME28}
    Set Suite Variable   ${ZOOM_Pid2}

    Set Test Variable  ${callingMode1}     ${CallingModes[0]}
    Set Test Variable  ${ModeId1}          ${ZOOM_Pid2}
    Set Test Variable  ${ModeStatus1}      ACTIVE
    ${Description1}=    FakerLibrary.sentence
    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Description1}
    ${virtualCallingModes}=  Create List  ${VirtualcallingMode1}
    

    ${min_pre}=   Random Int   min=10   max=50
    ${Total}=   Random Int   min=100   max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    ${Total}=  Convert To Number  ${Total}  1
    ${V1SERVICE1}=    FakerLibrary.word
    Set Suite Variable   ${V1SERVICE1}
    ${description}=    FakerLibrary.word
    Set Test Variable  ${vstype}  ${vservicetype[1]}
    ${resp}=  Create virtual Service  ${V1SERVICE1}   ${description}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre}  ${Total}  ${bool[0]}   ${bool[0]}   ${vstype}   ${virtualCallingModes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${v1_s1}  ${resp.json()} 

    ${resp}=   Get Service By Id  ${v1_s1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Verify Response  ${resp}  name=${V1SERVICE1}  description=${description}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}   totalAmount=${Total}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}  serviceType=virtualService   virtualServiceType=${vstype}


    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${eTime1}=  add_timezone_time  ${tz}  2  30  
    ${p1queue1}=    FakerLibrary.word

    ${resp}=  Get Locations
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_l1}  ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}


    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=5
    ${duration}=  FakerLibrary.Random Int  min=3  max=5
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${p1_l1}  ${duration}  ${bool1}  ${p1_s1}  ${p1_s2}   ${v1_s1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}
    Set Suite Variable  ${schedule_name}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${cid6_fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${cid6_lname}   ${resp.json()['lastName']}
    Set Suite Variable  ${C6_name}   ${cid6_fname} ${cid6_lname}
    

    ${cid}=  get_id  ${CUSERNAME7}
    Set Suite Variable  ${cid}
    ${family_fname}=  FakerLibrary.first_name
    Set Suite Variable  ${family_fname}
    ${family_lname}=  FakerLibrary.last_name
    Set Suite Variable  ${family_lname}
    ${dob}=  FakerLibrary.Date
    ${gender}=    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMember   ${family_fname}  ${family_lname}  ${dob}  ${gender}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${fid1_name}   ${family_fname} ${family_lname} 
    Set Suite Variable  ${cidfor}   ${resp.json()}

    ${fid2_fname}=  FakerLibrary.first_name
    Set Suite Variable  ${fid2_fname}
    ${fid2_lname}=  FakerLibrary.last_name
    Set Suite Variable  ${fid2_lname}
    ${resp}=  AddFamilyMember   ${fid2_fname}  ${fid2_lname}  ${dob}  ${gender}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${fid2_name}   ${fid2_fname} ${fid2_lname}
    Set Suite Variable  ${cidfor2}   ${resp.json()}
   
    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    
    # ------------------------------------------------------------------------------
    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
        END
    END
    ${num_slots}=  Get Length  ${slots}
    Set Test Variable   ${slot1}   ${slots[${num_slots-1}]}
    Set Test Variable   ${slot2}   ${slots[${num_slots-2}]}
    Set Test Variable   ${slot3}   ${slots[${num_slots-3}]}
    Set Test Variable   ${slot4}   ${slots[${num_slots-4}]}
    Set Test Variable   ${slot5}   ${slots[${num_slots-5}]}
    Set Test Variable   ${slot6}   ${slots[${num_slots-6}]}
    Set Test Variable   ${slot7}   ${slots[${num_slots-7}]}
    Set Test Variable   ${slot8}   ${slots[${num_slots-8}]}
    Set Test Variable   ${slot9}   ${slots[${num_slots-9}]}
    Set Test Variable   ${slot10}   ${slots[${num_slots-10}]}
    Set Test Variable   ${slot11}   ${slots[${num_slots-11}]}
    Set Test Variable   ${slot12}   ${slots[${num_slots-12}]}
    Set Test Variable   ${slot13}   ${slots[${num_slots-13}]}
    Set Test Variable   ${slot14}   ${slots[${num_slots-14}]}
    Set Test Variable   ${slot15}   ${slots[${num_slots-15}]}
    Set Test Variable   ${slot16}   ${slots[${num_slots-16}]}
    Set Test Variable   ${slot17}   ${slots[${num_slots-17}]}
    Set Test Variable   ${slot18}   ${slots[${num_slots-18}]}
    
    # ------------------------------------------------------------------------------
    
    ${TODAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${TODAY}
    ${Current_Date} =	Convert Date	${TODAY}	result_format=%d/%m/%Y
    Set Suite Variable  ${Current_Date}
    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot1}   firstName=${family_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${p1_s1}  ${sch_id}  ${TODAY}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid01}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid01}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${jid_c6_f1}   ${resp.json()['appmtFor'][0]['memberJaldeeId']}

    ${apptfor1}=  Create Dictionary  id=0   apptTime=${slot2}   firstName=${cid6_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${p1_s1}  ${sch_id}  ${TODAY}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid02}  ${apptid[0]}

    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot3}   firstName=${family_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${v1_s1}  ${sch_id}  ${TODAY}  ${cnote}  ${CallingModes[0]}  ${ZOOM_Pid2}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid03}  ${apptid[0]}

    ${apptfor1}=  Create Dictionary  id=0   apptTime=${slot4}   firstName=${cid6_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${v1_s1}  ${sch_id}  ${TODAY}  ${cnote}  ${CallingModes[0]}  ${ZOOM_Pid2}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid04}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid04}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${jid_c6}   ${resp.json()['appmtFor'][0]['memberJaldeeId']}

    ${apptfor1}=  Create Dictionary  id=${cidfor2}   apptTime=${slot5}   firstName=${fid2_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${p1_s1}  ${sch_id}  ${TODAY}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid05}  ${apptid[0]}


    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid05}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${jid_c6_f2}   ${resp.json()['appmtFor'][0]['memberJaldeeId']}


    ${apptfor1}=  Create Dictionary  id=${cidfor2}   apptTime=${slot6}   firstName=${fid2_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${v1_s1}  ${sch_id}  ${TODAY}  ${cnote}  ${CallingModes[0]}  ${ZOOM_Pid2}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid06}  ${apptid[0]}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Appointment Action   ${apptStatus[6]}   ${apptid01}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${reason}=  Random Element  ${cancelReason}
    ${cancel_msg}=   FakerLibrary.word
    ${resp}=    Provider Cancel Appointment  ${apptid02}  ${reason}  ${cancel_msg}  ${TODAY}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Provider Cancel Appointment  ${apptid03}  ${reason}  ${cancel_msg}  ${TODAY}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Appointment Action   ${apptStatus[6]}   ${apptid04}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # -----------------
    ${reason}=  Random Element  ${cancelReason}
    ${msg}=   FakerLibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=    Reject Appointment  ${apptid05}  ${reason}  ${msg}  ${TODAY}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Reject Appointment  ${apptid06}  ${reason}  ${msg}  ${TODAY}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # -----------------

    sleep  3s
    ${resp}=  Get Appointment Status   ${apptid01}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['appointmentStatus']}   ${apptStatus[6]}

    ${resp}=  Get Appointment Status   ${apptid02}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['appointmentStatus']}   ${apptStatus[4]}

    ${resp}=  Get Appointment Status   ${apptid03}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['appointmentStatus']}   ${apptStatus[4]}

    ${resp}=  Get Appointment Status   ${apptid04}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['appointmentStatus']}   ${apptStatus[6]}

    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot7}   firstName=${family_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${p1_s1}  ${sch_id}  ${TODAY}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid07}  ${apptid[0]}

    ${apptfor1}=  Create Dictionary  id=0   apptTime=${slot8}   firstName=${cid6_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${p1_s1}  ${sch_id}  ${TODAY}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid08}  ${apptid[0]}

    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot9}   firstName=${family_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${v1_s1}  ${sch_id}  ${TODAY}  ${cnote}  ${CallingModes[0]}  ${ZOOM_Pid2}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid09}  ${apptid[0]}

    ${apptfor1}=  Create Dictionary  id=0   apptTime=${slot10}   firstName=${cid6_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${v1_s1}  ${sch_id}  ${TODAY}  ${cnote}  ${CallingModes[0]}  ${ZOOM_Pid2}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid010}  ${apptid[0]}
    # -----------------------------------------------------


    ${Add_DAY1}=  db.add_timezone_date  ${tz}  1  
    Set Suite Variable  ${Add_DAY1}
    ${Date1} =	Convert Date	${Add_DAY1}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date1}
    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot2}   firstName=${family_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Appointment For Provider   ${pid}  ${p1_s1}  ${sch_id}  ${Add_DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid111}  ${apptid[0]}

    ${apptfor1}=  Create Dictionary  id=0   apptTime=${slot3}   firstName=${cid6_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${v1_s1}  ${sch_id}  ${Add_DAY1}  ${cnote}  ${CallingModes[0]}  ${ZOOM_Pid2}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid112}  ${apptid[0]}
    # -----------------------------------------------------


    ${Add_DAY2}=  db.add_timezone_date  ${tz}  2  
    Set Suite Variable  ${Add_DAY2}
    ${Date2} =	Convert Date	${Add_DAY2}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date2}
    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot3}   firstName=${family_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Appointment For Provider   ${pid}  ${p1_s1}  ${sch_id}  ${Add_DAY2}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid113}  ${apptid[0]}

    ${apptfor1}=  Create Dictionary  id=0   apptTime=${slot4}   firstName=${cid6_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${v1_s1}  ${sch_id}  ${Add_DAY2}  ${cnote}  ${CallingModes[0]}  ${ZOOM_Pid2}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid114}  ${apptid[0]}
    # -----------------------------------------------------

    ${Add_DAY3}=  db.add_timezone_date  ${tz}  3  
    Set Suite Variable  ${Add_DAY3}
    ${Date3} =	Convert Date	${Add_DAY3}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date3}
    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot4}   firstName=${family_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Appointment For Provider   ${pid}  ${p1_s1}  ${sch_id}  ${Add_DAY3}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid115}  ${apptid[0]}

    ${apptfor1}=  Create Dictionary  id=0   apptTime=${slot5}   firstName=${cid6_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${v1_s1}  ${sch_id}  ${Add_DAY3}  ${cnote}  ${CallingModes[0]}  ${ZOOM_Pid2}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid116}  ${apptid[0]}
    # -----------------------------------------------------

    ${Add_DAY4}=  db.add_timezone_date  ${tz}  4  
    Set Suite Variable  ${Add_DAY4}
    ${Date4} =	Convert Date	${Add_DAY4}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date4}
    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot5}   firstName=${family_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Appointment For Provider   ${pid}  ${p1_s1}  ${sch_id}  ${Add_DAY4}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid117}  ${apptid[0]}

    ${apptfor1}=  Create Dictionary  id=0   apptTime=${slot6}   firstName=${cid6_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${v1_s1}  ${sch_id}  ${Add_DAY4}  ${cnote}  ${CallingModes[0]}  ${ZOOM_Pid2}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid118}  ${apptid[0]}
    # -----------------------------------------------------


    ${Add_DAY5}=  db.add_timezone_date  ${tz}  5  
    Set Suite Variable  ${Add_DAY5}
    ${Date5} =	Convert Date	${Add_DAY5}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date5}
    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot6}   firstName=${family_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Appointment For Provider   ${pid}  ${p1_s1}  ${sch_id}  ${Add_DAY5}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid119}  ${apptid[0]}

    ${apptfor1}=  Create Dictionary  id=0   apptTime=${slot7}   firstName=${cid6_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${v1_s1}  ${sch_id}  ${Add_DAY5}  ${cnote}  ${CallingModes[0]}  ${ZOOM_Pid2}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid120}  ${apptid[0]}
    # -----------------------------------------------------

    ${Add_DAY6}=  db.add_timezone_date  ${tz}  6  
    Set Suite Variable  ${Add_DAY6}
    ${Date6} =	Convert Date	${Add_DAY6}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date6}
    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot7}   firstName=${family_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Appointment For Provider   ${pid}  ${p1_s1}  ${sch_id}  ${Add_DAY6}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid121}  ${apptid[0]}

    ${apptfor1}=  Create Dictionary  id=0   apptTime=${slot8}   firstName=${cid6_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${v1_s1}  ${sch_id}  ${Add_DAY6}  ${cnote}  ${CallingModes[0]}  ${ZOOM_Pid2}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid122}  ${apptid[0]}
    # -----------------------------------------------------


    ${Add_DAY7}=  db.add_timezone_date  ${tz}  7  
    Set Suite Variable  ${Add_DAY7}
    ${Date7} =	Convert Date	${Add_DAY7}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date7}
    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot8}   firstName=${family_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Appointment For Provider   ${pid}  ${p1_s1}  ${sch_id}  ${Add_DAY7}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid123}  ${apptid[0]}

    ${apptfor1}=  Create Dictionary  id=0   apptTime=${slot9}   firstName=${cid6_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${v1_s1}  ${sch_id}  ${Add_DAY7}  ${cnote}  ${CallingModes[0]}  ${ZOOM_Pid2}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid124}  ${apptid[0]}
    # -----------------------------------------------------


    ${Add_DAY8}=  db.add_timezone_date  ${tz}  8  
    Set Suite Variable  ${Add_DAY8}
    ${Date8} =	Convert Date	${Add_DAY8}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date8}
    ${apptfor1}=  Create Dictionary  id=0   apptTime=${slot9}   firstName=${cid6_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Appointment For Provider   ${pid}  ${p1_s1}  ${sch_id}  ${Add_DAY8}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid225}  ${apptid[0]}

    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot10}   firstName=${family_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${v1_s1}  ${sch_id}  ${Add_DAY8}  ${cnote}  ${CallingModes[0]}  ${ZOOM_Pid2}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid226}  ${apptid[0]}
    # -----------------------------------------------------


    ${Add_DAY15}=  db.add_timezone_date  ${tz}  15  
    Set Suite Variable  ${Add_DAY15}
    ${Date15} =	Convert Date	${Add_DAY15}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date15}
    ${apptfor1}=  Create Dictionary  id=0   apptTime=${slot10}   firstName=${cid6_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Appointment For Provider   ${pid}  ${p1_s1}  ${sch_id}  ${Add_DAY15}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid227}  ${apptid[0]}

    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot1}   firstName=${family_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${v1_s1}  ${sch_id}  ${Add_DAY15}  ${cnote}  ${CallingModes[0]}  ${ZOOM_Pid2}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid228}  ${apptid[0]}
    # -----------------------------------------------------


    ${Add_DAY20}=  db.add_timezone_date  ${tz}  20
    Set Suite Variable  ${Add_DAY20}
    ${Date20} =	Convert Date	${Add_DAY20}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date20}
    ${apptfor1}=  Create Dictionary  id=0   apptTime=${slot11}   firstName=${cid6_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Appointment For Provider   ${pid}  ${p1_s1}  ${sch_id}  ${Add_DAY20}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid229}  ${apptid[0]}

    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot12}   firstName=${family_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${v1_s1}  ${sch_id}  ${Add_DAY20}  ${cnote}  ${CallingModes[0]}  ${ZOOM_Pid2}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid230}  ${apptid[0]}
    # -----------------------------------------------------


    ${Add_DAY25}=  db.add_timezone_date  ${tz}  25 
    Set Suite Variable  ${Add_DAY25}
    ${Date25} =	Convert Date	${Add_DAY25}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date25}
    ${apptfor1}=  Create Dictionary  id=0   apptTime=${slot12}   firstName=${cid6_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Appointment For Provider   ${pid}  ${p1_s1}  ${sch_id}  ${Add_DAY25}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid231}  ${apptid[0]}

    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot13}   firstName=${family_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${v1_s1}  ${sch_id}  ${Add_DAY25}  ${cnote}  ${CallingModes[0]}  ${ZOOM_Pid2}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid232}  ${apptid[0]}
    # -----------------------------------------------------


    ${Add_DAY30}=  db.add_timezone_date  ${tz}  30
    Set Suite Variable  ${Add_DAY30}
    ${Date30} =	Convert Date	${Add_DAY30}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date30}
    ${apptfor1}=  Create Dictionary  id=0   apptTime=${slot13}   firstName=${cid6_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Appointment For Provider   ${pid}  ${p1_s1}  ${sch_id}  ${Add_DAY30}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid233}  ${apptid[0]}

    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot14}   firstName=${family_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${v1_s1}  ${sch_id}  ${Add_DAY30}  ${cnote}  ${CallingModes[0]}  ${ZOOM_Pid2}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid234}  ${apptid[0]}
    # -----------------------------------------------------


    ${Add_DAY31}=  db.add_timezone_date  ${tz}  31
    Set Suite Variable  ${Add_DAY31}
    ${Date31} =	Convert Date	${Add_DAY31}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date31}
    ${apptfor1}=  Create Dictionary  id=0   apptTime=${slot14}   firstName=${cid6_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Appointment For Provider   ${pid}  ${p1_s1}  ${sch_id}  ${Add_DAY31}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid235}  ${apptid[0]}

    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot15}   firstName=${family_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${v1_s1}  ${sch_id}  ${Add_DAY31}  ${cnote}  ${CallingModes[0]}  ${ZOOM_Pid2}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid236}  ${apptid[0]}
    # -----------------------------------------------------


    ${Add_DAY36}=  db.add_timezone_date  ${tz}  36
    Set Suite Variable  ${Add_DAY36}
    ${Date36} =	Convert Date	${Add_DAY36}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date36}
    ${apptfor1}=  Create Dictionary  id=0   apptTime=${slot15}   firstName=${cid6_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Appointment For Provider   ${pid}  ${p1_s1}  ${sch_id}  ${Add_DAY36}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid237}  ${apptid[0]}

    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot16}   firstName=${family_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${v1_s1}  ${sch_id}  ${Add_DAY36}  ${cnote}  ${CallingModes[0]}  ${ZOOM_Pid2}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid238}  ${apptid[0]}
    # -----------------------------------------------------


    ${Add_DAY40}=  db.add_timezone_date  ${tz}  40
    Set Suite Variable  ${Add_DAY40}
    ${Date40} =	Convert Date	${Add_DAY40}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date40}
    ${apptfor1}=  Create Dictionary  id=0   apptTime=${slot16}   firstName=${cid6_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Appointment For Provider   ${pid}  ${p1_s1}  ${sch_id}  ${Add_DAY40}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid239}  ${apptid[0]}

    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot17}   firstName=${family_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${v1_s1}  ${sch_id}  ${Add_DAY40}  ${cnote}  ${CallingModes[0]}  ${ZOOM_Pid2}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid240}  ${apptid[0]}
    # -----------------------------------------------------


    ${Add_DAY45}=  db.add_timezone_date  ${tz}  45
    Set Suite Variable  ${Add_DAY45}
    ${Date45} =	Convert Date	${Add_DAY45}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date45}
    ${apptfor1}=  Create Dictionary  id=0   apptTime=${slot17}   firstName=${cid6_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Appointment For Provider   ${pid}  ${p1_s1}  ${sch_id}  ${Add_DAY45}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid241}  ${apptid[0]}

    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot18}   firstName=${family_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${v1_s1}  ${sch_id}  ${Add_DAY45}  ${cnote}  ${CallingModes[0]}  ${ZOOM_Pid2}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid242}  ${apptid[0]}
    # -----------------------------------------------------


    ${Add_DAY50}=  db.add_timezone_date  ${tz}  50
    Set Suite Variable  ${Add_DAY50}
    ${Date50} =	Convert Date	${Add_DAY50}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date50}
    ${apptfor1}=  Create Dictionary  id=0   apptTime=${slot18}   firstName=${cid6_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Appointment For Provider   ${pid}  ${p1_s1}  ${sch_id}  ${Add_DAY50}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid243}  ${apptid[0]}

    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot1}   firstName=${family_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${v1_s1}  ${sch_id}  ${Add_DAY50}  ${cnote}  ${CallingModes[0]}  ${ZOOM_Pid2}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid244}  ${apptid[0]}
    # -----------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    # Set Suite Variable  ${C6_name}   ${cid6_fname} ${cid6_lname}
    # Set Suite Variable  ${fid1_name}   ${family_fname} ${family_lname}
    # Set Suite Variable  ${fid2_name}   ${fid2_fname} ${fid2_lname}

    sleep  5s

    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${reportType}              APPOINTMENT
    Set Test Variable  ${reportDateCategory}      TODAY

    ${filter}=  Create Dictionary   apptForId-eq=${EMPTY}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  5s
    ${filter3}=  Create Dictionary   apptForId-eq=${jid_c6},${jid_c6_f1},${jid_c6_f2}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${token_id1}   ${resp.json()}

    
    ${resp}=  Get Report By Status      FALIED
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Get_Report_ByStatus-2

    [Documentation]  Generate current_day Appointment_report of a provider By report status

    ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
# *** Comments ***
    ${pid}=  get_acc_id  ${PUSERNAME24}
    Set Suite Variable  ${pid}

    ${highest_package}=  get_highest_license_pkg
    Log  ${highest_package}
    Set Suite variable  ${lic2}  ${highest_package[0]}

    ${resp}=   Change License Package  ${highest_package[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${duration}=   Random Int  min=2  max=10
    Set Suite Variable   ${duration}
    
    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}   ${duration}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${Empty}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  calculationMode=${calc_mode[1]}  trnArndTime=${duration}  futureDateWaitlist=${bool[1]}  showTokenId=${bool[1]}  onlineCheckIns=${bool[1]}  maxPartySize=1
    
    clear_queue     ${PUSERNAME24}
    clear_service   ${PUSERNAME24}
    clear_appt_schedule   ${PUSERNAME24}

    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  55
    Set Suite Variable  ${DAY2}
    ${description}=     FakerLibrary.sentence
    Set Suite Variable   ${description}
    ${firstname1}=  FakerLibrary.first_name
    Set Test Variable  ${firstname1}
    set Suite Variable  ${email}  ${firstname1}${CUSERNAME7}${C_Email}.${test_mail}

    ${P1SERVICE1}=    FakerLibrary.word
    Set Suite Variable   ${P1SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    Set Suite Variable   ${min_pre}
    ${servicecharge}=   Random Int  min=100  max=500
    Set Suite Variable   ${servicecharge}
    ${Total1}=  Convert To Number  ${servicecharge}  1 
    Set Suite Variable   ${Total}   ${Total1}
    ${amt_float}=  twodigitfloat  ${Total}
    Set Suite Variable  ${amt_float}  ${amt_float}  
    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7

    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration[0]}  ${status[0]}    ${btype}  ${bool[1]}  ${notifytype[2]}  ${min_pre}  ${Total}  ${bool[0]}  ${bool[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_s1}  ${resp.json()}

    ${P1SERVICE2}=    FakerLibrary.word
    Set Suite Variable   ${P1SERVICE2}

    ${servicecharge2}=   Random Int  min=100  max=500
    Set Suite Variable   ${servicecharge2}
    Set Suite Variable   ${min_pre2}   ${servicecharge2}
    ${Total2}=  Convert To Number  ${servicecharge2}  1 
    Set Suite Variable   ${Total2}
    ${amt_float2}=  twodigitfloat  ${Total2}
    Set Suite Variable  ${amt_float2} 

    ${resp}=  Create Service  ${P1SERVICE2}  ${desc}   ${service_duration[1]}  ${status[0]}    ${btype}  ${bool[1]}  ${notifytype[2]}  ${min_pre2}  ${Total2}  ${bool[1]}  ${bool[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_s2}  ${resp.json()}


    ${ZOOM_id2}=  Format String  ${ZOOM_url}  ${PUSERNAME28}
    Set Suite Variable   ${ZOOM_id2}

    ${PUSERPH_id2}=  Evaluate  ${PUSERNAME}+10101
    ${ZOOM_Pid2}=  Format String  ${ZOOM_url}  ${PUSERNAME28}
    Set Suite Variable   ${ZOOM_Pid2}

    Set Test Variable  ${callingMode1}     ${CallingModes[0]}
    Set Test Variable  ${ModeId1}          ${ZOOM_Pid2}
    Set Test Variable  ${ModeStatus1}      ACTIVE
    ${Description1}=    FakerLibrary.sentence
    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Description1}
    ${virtualCallingModes}=  Create List  ${VirtualcallingMode1}
    

    ${min_pre}=   Random Int   min=10   max=50
    ${Total}=   Random Int   min=100   max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    ${Total}=  Convert To Number  ${Total}  1
    ${V1SERVICE1}=    FakerLibrary.word
    Set Suite Variable   ${V1SERVICE1}
    ${description}=    FakerLibrary.word
    Set Test Variable  ${vstype}  ${vservicetype[1]}
    ${resp}=  Create virtual Service  ${V1SERVICE1}   ${description}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre}  ${Total}  ${bool[0]}   ${bool[0]}   ${vstype}   ${virtualCallingModes}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${v1_s1}  ${resp.json()} 

    ${resp}=   Get Service By Id  ${v1_s1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.content}
    Verify Response  ${resp}  name=${V1SERVICE1}  description=${description}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}   totalAmount=${Total}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}  serviceType=virtualService   virtualServiceType=${vstype}


    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${eTime1}=  add_timezone_time  ${tz}  4  30  
    ${p1queue1}=    FakerLibrary.word

    ${resp}=  Get Locations
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_l1}  ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}


    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=5
    ${duration}=  FakerLibrary.Random Int  min=3  max=5
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${p1_l1}  ${duration}  ${bool1}  ${p1_s1}  ${p1_s2}   ${v1_s1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}
    Set Suite Variable  ${schedule_name}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${cid6_fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${cid6_lname}   ${resp.json()['lastName']}
    Set Suite Variable  ${C6_name}   ${cid6_fname} ${cid6_lname}
    

    ${cid}=  get_id  ${CUSERNAME7}
    Set Suite Variable  ${cid}
    ${family_fname}=  FakerLibrary.first_name
    Set Suite Variable  ${family_fname}
    ${family_lname}=  FakerLibrary.last_name
    Set Suite Variable  ${family_lname}
    ${dob}=  FakerLibrary.Date
    ${gender}=    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMember   ${family_fname}  ${family_lname}  ${dob}  ${gender}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${fid1_name}   ${family_fname} ${family_lname} 
    Set Suite Variable  ${cidfor}   ${resp.json()}

    ${fid2_fname}=  FakerLibrary.first_name
    Set Suite Variable  ${fid2_fname}
    ${fid2_lname}=  FakerLibrary.last_name
    Set Suite Variable  ${fid2_lname}
    ${resp}=  AddFamilyMember   ${fid2_fname}  ${fid2_lname}  ${dob}  ${gender}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${fid2_name}   ${fid2_fname} ${fid2_lname}
    Set Suite Variable  ${cidfor2}   ${resp.json()}
   
    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id}   ${pid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    
    # ------------------------------------------------------------------------------
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
    Set Test Variable   ${slot1}   ${slots[${num_slots-1}]}
    ${converted_slot1}=  slot_12hr  ${slot1}
    Set Suite Variable  ${converted_slot1}
    Set Test Variable   ${slot2}   ${slots[${num_slots-2}]}
    ${converted_slot2}=  slot_12hr  ${slot2}
    Set Suite Variable  ${converted_slot2}
    Set Test Variable   ${slot3}   ${slots[${num_slots-3}]}
    ${converted_slot3}=  slot_12hr  ${slot3}
    Set Suite Variable  ${converted_slot3}
    Set Test Variable   ${slot4}   ${slots[${num_slots-4}]}
    ${converted_slot4}=  slot_12hr  ${slot4}
    Set Suite Variable  ${converted_slot4}
    Set Test Variable   ${slot5}   ${slots[${num_slots-5}]}
    ${converted_slot5}=  slot_12hr  ${slot5}
    Set Suite Variable  ${converted_slot5}
    Set Test Variable   ${slot6}   ${slots[${num_slots-6}]}
    ${converted_slot6}=  slot_12hr  ${slot6}
    Set Suite Variable  ${converted_slot6}
    Set Test Variable   ${slot7}   ${slots[${num_slots-7}]}
    ${converted_slot7}=  slot_12hr  ${slot7}
    Set Suite Variable  ${converted_slot7}
    Set Test Variable   ${slot8}   ${slots[${num_slots-8}]}
    ${converted_slot8}=  slot_12hr  ${slot8}
    Set Suite Variable  ${converted_slot8}
    Set Test Variable   ${slot9}   ${slots[${num_slots-9}]}
    ${converted_slot9}=  slot_12hr  ${slot9}
    Set Suite Variable  ${converted_slot9}
    Set Test Variable   ${slot10}   ${slots[${num_slots-10}]}
    ${converted_slot10}=  slot_12hr  ${slot10}
    Set Suite Variable  ${converted_slot10}
    Set Test Variable   ${slot11}   ${slots[${num_slots-11}]}
    ${converted_slot11}=  slot_12hr  ${slot11}
    Set Suite Variable  ${converted_slot11}
    Set Test Variable   ${slot12}   ${slots[${num_slots-12}]}
    ${converted_slot12}=  slot_12hr  ${slot12}
    Set Suite Variable  ${converted_slot12}
    Set Test Variable   ${slot13}   ${slots[${num_slots-13}]}
    ${converted_slot13}=  slot_12hr  ${slot13}
    Set Suite Variable  ${converted_slot13}
    Set Test Variable   ${slot14}   ${slots[${num_slots-14}]}
    ${converted_slot14}=  slot_12hr  ${slot14}
    Set Suite Variable  ${converted_slot14}
    Set Test Variable   ${slot15}   ${slots[${num_slots-15}]}
    ${converted_slot15}=  slot_12hr  ${slot15}
    Set Suite Variable  ${converted_slot15}
    Set Test Variable   ${slot16}   ${slots[${num_slots-16}]}
    ${converted_slot16}=  slot_12hr  ${slot16}
    Set Suite Variable  ${converted_slot16}
    Set Test Variable   ${slot17}   ${slots[${num_slots-17}]}
    ${converted_slot17}=  slot_12hr  ${slot17}
    Set Suite Variable  ${converted_slot17}
    Set Test Variable   ${slot18}   ${slots[${num_slots-18}]}
    ${converted_slot18}=  slot_12hr  ${slot18}
    Set Suite Variable  ${converted_slot18}
    
    # ------------------------------------------------------------------------------
   
    ${TODAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${TODAY}
    ${Current_Date} =	Convert Date	${TODAY}	result_format=%d/%m/%Y
    Set Suite Variable  ${Current_Date} 
    Set Suite Variable  ${TODAY_Slot1}   ${Current_Date} [${converted_slot1}]
    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot1}   firstName=${family_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${p1_s1}  ${sch_id}  ${TODAY}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid01}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid01}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${jid_c6_f1}   ${resp.json()['appmtFor'][0]['memberJaldeeId']}

    Set Suite Variable  ${TODAY_Slot2}   ${Current_Date} [${converted_slot2}]
    ${apptfor1}=  Create Dictionary  id=0   apptTime=${slot2}   firstName=${cid6_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${p1_s1}  ${sch_id}  ${TODAY}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid02}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid02}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Set Suite Variable  ${TODAY_Slot3}   ${Current_Date} [${converted_slot3}]
    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot3}   firstName=${family_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${v1_s1}  ${sch_id}  ${TODAY}  ${cnote}  ${CallingModes[0]}  ${ZOOM_Pid2}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid03}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid03}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Set Suite Variable  ${TODAY_Slot4}   ${Current_Date} [${converted_slot4}]
    ${apptfor1}=  Create Dictionary  id=0   apptTime=${slot4}   firstName=${cid6_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${v1_s1}  ${sch_id}  ${TODAY}  ${cnote}  ${CallingModes[0]}  ${ZOOM_Pid2}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid04}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid04}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${jid_c6}   ${resp.json()['appmtFor'][0]['memberJaldeeId']}

    Set Suite Variable  ${TODAY_Slot5}   ${Current_Date} [${converted_slot5}]
    ${apptfor1}=  Create Dictionary  id=${cidfor2}   apptTime=${slot5}   firstName=${fid2_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${p1_s1}  ${sch_id}  ${TODAY}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid05}  ${apptid[0]}


    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid05}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${jid_c6_f2}   ${resp.json()['appmtFor'][0]['memberJaldeeId']}

    Set Suite Variable  ${TODAY_Slot6}   ${Current_Date} [${converted_slot6}]
    ${apptfor1}=  Create Dictionary  id=${cidfor2}   apptTime=${slot6}   firstName=${fid2_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${v1_s1}  ${sch_id}  ${TODAY}  ${cnote}  ${CallingModes[0]}  ${ZOOM_Pid2}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid06}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid06}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Appointment Action   ${apptStatus[6]}   ${apptid01}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${reason}=  Random Element  ${cancelReason}
    ${cancel_msg}=   FakerLibrary.word
    ${resp}=    Provider Cancel Appointment  ${apptid02}  ${reason}  ${cancel_msg}  ${TODAY}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Provider Cancel Appointment  ${apptid03}  ${reason}  ${cancel_msg}  ${TODAY}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Appointment Action   ${apptStatus[6]}   ${apptid04}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    # -----------------
    ${reason}=  Random Element  ${cancelReason}
    ${msg}=   FakerLibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=    Reject Appointment  ${apptid05}  ${reason}  ${msg}  ${TODAY}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Reject Appointment  ${apptid06}  ${reason}  ${msg}  ${TODAY}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # -----------------

    sleep  3s
    ${resp}=  Get Appointment Status   ${apptid01}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['appointmentStatus']}   ${apptStatus[6]}

    ${resp}=  Get Appointment Status   ${apptid02}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['appointmentStatus']}   ${apptStatus[4]}

    ${resp}=  Get Appointment Status   ${apptid03}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['appointmentStatus']}   ${apptStatus[4]}

    ${resp}=  Get Appointment Status   ${apptid04}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['appointmentStatus']}   ${apptStatus[6]}

    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Set Suite Variable  ${TODAY_Slot7}   ${Current_Date} [${converted_slot7}]
    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot7}   firstName=${family_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${p1_s1}  ${sch_id}  ${TODAY}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid07}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid07}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Set Suite Variable  ${TODAY_Slot8}   ${Current_Date} [${converted_slot8}]
    ${apptfor1}=  Create Dictionary  id=0   apptTime=${slot8}   firstName=${cid6_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${p1_s1}  ${sch_id}  ${TODAY}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid08}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid08}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Set Suite Variable  ${TODAY_Slot9}   ${Current_Date} [${converted_slot9}]
    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot9}   firstName=${family_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${v1_s1}  ${sch_id}  ${TODAY}  ${cnote}  ${CallingModes[0]}  ${ZOOM_Pid2}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid09}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid09}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Set Suite Variable  ${TODAY_Slot10}   ${Current_Date} [${converted_slot10}]
    ${apptfor1}=  Create Dictionary  id=0   apptTime=${slot10}   firstName=${cid6_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${v1_s1}  ${sch_id}  ${TODAY}  ${cnote}  ${CallingModes[0]}  ${ZOOM_Pid2}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid010}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid010}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # -----------------------------------------------------


    ${Add_DAY1}=  db.add_timezone_date  ${tz}  1  
    Set Suite Variable  ${Add_DAY1}
    ${Date1} =	Convert Date	${Add_DAY1}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date1_Slot2}   ${Date1} [${converted_slot2}]
    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot2}   firstName=${family_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Appointment For Provider   ${pid}  ${p1_s1}  ${sch_id}  ${Add_DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid111}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid111}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Set Suite Variable  ${Date1_Slot3}   ${Date1} [${converted_slot3}]
    ${apptfor1}=  Create Dictionary  id=0   apptTime=${slot3}   firstName=${cid6_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${v1_s1}  ${sch_id}  ${Add_DAY1}  ${cnote}  ${CallingModes[0]}  ${ZOOM_Pid2}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid112}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid112}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # -----------------------------------------------------


    ${Add_DAY2}=  db.add_timezone_date  ${tz}  2  
    Set Suite Variable  ${Add_DAY2}
    ${Date2} =	Convert Date	${Add_DAY2}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date2_Slot3}   ${Date2} [${converted_slot3}]
    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot3}   firstName=${family_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Appointment For Provider   ${pid}  ${p1_s1}  ${sch_id}  ${Add_DAY2}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid113}  ${apptid[0]}

    Set Suite Variable  ${Date2_Slot4}   ${Date2} [${converted_slot4}]
    ${apptfor1}=  Create Dictionary  id=0   apptTime=${slot4}   firstName=${cid6_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${v1_s1}  ${sch_id}  ${Add_DAY2}  ${cnote}  ${CallingModes[0]}  ${ZOOM_Pid2}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid114}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid114}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # -----------------------------------------------------

    ${Add_DAY3}=  db.add_timezone_date  ${tz}  3  
    Set Suite Variable  ${Add_DAY3}
    ${Date3} =	Convert Date	${Add_DAY3}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date3_Slot4}   ${Date3} [${converted_slot4}]
    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot4}   firstName=${family_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Appointment For Provider   ${pid}  ${p1_s1}  ${sch_id}  ${Add_DAY3}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid115}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid115}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Set Suite Variable  ${Date3_Slot5}   ${Date3} [${converted_slot5}]
    ${apptfor1}=  Create Dictionary  id=0   apptTime=${slot5}   firstName=${cid6_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${v1_s1}  ${sch_id}  ${Add_DAY3}  ${cnote}  ${CallingModes[0]}  ${ZOOM_Pid2}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid116}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid116}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # -----------------------------------------------------

    ${Add_DAY4}=  db.add_timezone_date  ${tz}  4  
    Set Suite Variable  ${Add_DAY4}
    ${Date4} =	Convert Date	${Add_DAY4}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date4_Slot5}   ${Date4} [${converted_slot5}]
    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot5}   firstName=${family_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Appointment For Provider   ${pid}  ${p1_s1}  ${sch_id}  ${Add_DAY4}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid117}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid117}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Set Suite Variable  ${Date4_Slot6}   ${Date4} [${converted_slot6}]
    ${apptfor1}=  Create Dictionary  id=0   apptTime=${slot6}   firstName=${cid6_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${v1_s1}  ${sch_id}  ${Add_DAY4}  ${cnote}  ${CallingModes[0]}  ${ZOOM_Pid2}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid118}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid118}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # -----------------------------------------------------


    ${Add_DAY5}=  db.add_timezone_date  ${tz}  5  
    Set Suite Variable  ${Add_DAY5}
    ${Date5} =	Convert Date	${Add_DAY5}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date5_Slot6}   ${Date5} [${converted_slot6}]
    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot6}   firstName=${family_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Appointment For Provider   ${pid}  ${p1_s1}  ${sch_id}  ${Add_DAY5}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid119}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid119}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Set Suite Variable  ${Date5_Slot7}   ${Date5} [${converted_slot7}]
    ${apptfor1}=  Create Dictionary  id=0   apptTime=${slot7}   firstName=${cid6_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${v1_s1}  ${sch_id}  ${Add_DAY5}  ${cnote}  ${CallingModes[0]}  ${ZOOM_Pid2}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid120}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid120}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # -----------------------------------------------------

    ${Add_DAY6}=  db.add_timezone_date  ${tz}  6  
    Set Suite Variable  ${Add_DAY6}
    ${Date6} =	Convert Date	${Add_DAY6}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date6_Slot7}   ${Date6} [${converted_slot7}]
    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot7}   firstName=${family_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Appointment For Provider   ${pid}  ${p1_s1}  ${sch_id}  ${Add_DAY6}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid121}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid121}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Set Suite Variable  ${Date6_Slot8}   ${Date6} [${converted_slot8}]
    ${apptfor1}=  Create Dictionary  id=0   apptTime=${slot8}   firstName=${cid6_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${v1_s1}  ${sch_id}  ${Add_DAY6}  ${cnote}  ${CallingModes[0]}  ${ZOOM_Pid2}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid122}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid122}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # -----------------------------------------------------


    ${Add_DAY7}=  db.add_timezone_date  ${tz}  7  
    Set Suite Variable  ${Add_DAY7}
    ${Date7} =	Convert Date	${Add_DAY7}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date7_Slot8}   ${Date7} [${converted_slot8}]
    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot8}   firstName=${family_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Appointment For Provider   ${pid}  ${p1_s1}  ${sch_id}  ${Add_DAY7}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid123}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid123}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Set Suite Variable  ${Date7_Slot9}   ${Date7} [${converted_slot9}]
    ${apptfor1}=  Create Dictionary  id=0   apptTime=${slot9}   firstName=${cid6_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${v1_s1}  ${sch_id}  ${Add_DAY7}  ${cnote}  ${CallingModes[0]}  ${ZOOM_Pid2}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid124}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid124}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # -----------------------------------------------------


    ${Add_DAY8}=  db.add_timezone_date  ${tz}  8  
    Set Suite Variable  ${Add_DAY8}
    ${Date8} =	Convert Date	${Add_DAY8}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date8_Slot9}   ${Date8} [${converted_slot9}]
    ${apptfor1}=  Create Dictionary  id=0   apptTime=${slot9}   firstName=${cid6_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Appointment For Provider   ${pid}  ${p1_s1}  ${sch_id}  ${Add_DAY8}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid225}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid225}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Set Suite Variable  ${Date8_Slot10}   ${Date8} [${converted_slot10}]
    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot10}   firstName=${family_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${v1_s1}  ${sch_id}  ${Add_DAY8}  ${cnote}  ${CallingModes[0]}  ${ZOOM_Pid2}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid226}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid226}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # -----------------------------------------------------


    ${Add_DAY15}=  db.add_timezone_date  ${tz}  15  
    Set Suite Variable  ${Add_DAY15}
    ${Date15} =	Convert Date	${Add_DAY15}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date15_Slot10}   ${Date15} [${converted_slot10}]
    ${apptfor1}=  Create Dictionary  id=0   apptTime=${slot10}   firstName=${cid6_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Appointment For Provider   ${pid}  ${p1_s1}  ${sch_id}  ${Add_DAY15}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid227}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid227}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Set Suite Variable  ${Date15_Slot1}   ${Date15} [${converted_slot1}]
    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot1}   firstName=${family_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${v1_s1}  ${sch_id}  ${Add_DAY15}  ${cnote}  ${CallingModes[0]}  ${ZOOM_Pid2}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid228}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid228}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # -----------------------------------------------------


    ${Add_DAY20}=  db.add_timezone_date  ${tz}  20
    Set Suite Variable  ${Add_DAY20}
    ${Date20} =	Convert Date	${Add_DAY20}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date20_Slot11}   ${Date20} [${converted_slot11}]
    ${apptfor1}=  Create Dictionary  id=0   apptTime=${slot11}   firstName=${cid6_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Appointment For Provider   ${pid}  ${p1_s1}  ${sch_id}  ${Add_DAY20}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid229}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid229}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Set Suite Variable  ${Date20_Slot12}   ${Date20} [${converted_slot12}]
    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot12}   firstName=${family_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${v1_s1}  ${sch_id}  ${Add_DAY20}  ${cnote}  ${CallingModes[0]}  ${ZOOM_Pid2}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid230}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid230}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # -----------------------------------------------------


    ${Add_DAY25}=  db.add_timezone_date  ${tz}  25 
    Set Suite Variable  ${Add_DAY25}
    ${Date25} =	Convert Date	${Add_DAY25}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date25_Slot12}   ${Date25} [${converted_slot12}]
    ${apptfor1}=  Create Dictionary  id=0   apptTime=${slot12}   firstName=${cid6_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Appointment For Provider   ${pid}  ${p1_s1}  ${sch_id}  ${Add_DAY25}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid231}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid231}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Set Suite Variable  ${Date25_Slot13}   ${Date25} [${converted_slot13}]
    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot13}   firstName=${family_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${v1_s1}  ${sch_id}  ${Add_DAY25}  ${cnote}  ${CallingModes[0]}  ${ZOOM_Pid2}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid232}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid232}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # -----------------------------------------------------


    ${Add_DAY30}=  db.add_timezone_date  ${tz}  30
    Set Suite Variable  ${Add_DAY30}
    ${Date30} =	Convert Date	${Add_DAY30}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date30_Slot13}   ${Date30} [${converted_slot13}]
    ${apptfor1}=  Create Dictionary  id=0   apptTime=${slot13}   firstName=${cid6_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Appointment For Provider   ${pid}  ${p1_s1}  ${sch_id}  ${Add_DAY30}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid233}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid233}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Set Suite Variable  ${Date30_Slot14}   ${Date30} [${converted_slot14}]
    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot14}   firstName=${family_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${v1_s1}  ${sch_id}  ${Add_DAY30}  ${cnote}  ${CallingModes[0]}  ${ZOOM_Pid2}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid234}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid234}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # -----------------------------------------------------


    ${Add_DAY31}=  db.add_timezone_date  ${tz}  31
    Set Suite Variable  ${Add_DAY31}
    ${Date31} =	Convert Date	${Add_DAY31}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date31_Slot14}   ${Date31} [${converted_slot14}]
    ${apptfor1}=  Create Dictionary  id=0   apptTime=${slot14}   firstName=${cid6_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Appointment For Provider   ${pid}  ${p1_s1}  ${sch_id}  ${Add_DAY31}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid235}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid235}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Set Suite Variable  ${Date31_Slot15}   ${Date31} [${converted_slot15}]
    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot15}   firstName=${family_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${v1_s1}  ${sch_id}  ${Add_DAY31}  ${cnote}  ${CallingModes[0]}  ${ZOOM_Pid2}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid236}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid236}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # -----------------------------------------------------


    ${Add_DAY36}=  db.add_timezone_date  ${tz}  36
    Set Suite Variable  ${Add_DAY36}
    ${Date36} =	Convert Date	${Add_DAY36}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date36_Slot15}   ${Date36} [${converted_slot15}]
    ${apptfor1}=  Create Dictionary  id=0   apptTime=${slot15}   firstName=${cid6_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Appointment For Provider   ${pid}  ${p1_s1}  ${sch_id}  ${Add_DAY36}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid237}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid237}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Set Suite Variable  ${Date36_Slot16}   ${Date36} [${converted_slot16}]
    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot16}   firstName=${family_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${v1_s1}  ${sch_id}  ${Add_DAY36}  ${cnote}  ${CallingModes[0]}  ${ZOOM_Pid2}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid238}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid238}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # -----------------------------------------------------


    ${Add_DAY40}=  db.add_timezone_date  ${tz}  40
    Set Suite Variable  ${Add_DAY40}
    ${Date40} =	Convert Date	${Add_DAY40}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date40_Slot16}   ${Date40} [${converted_slot16}]
    ${apptfor1}=  Create Dictionary  id=0   apptTime=${slot16}   firstName=${cid6_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Appointment For Provider   ${pid}  ${p1_s1}  ${sch_id}  ${Add_DAY40}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid239}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid239}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Set Suite Variable  ${Date40_Slot17}   ${Date40} [${converted_slot17}]
    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot17}   firstName=${family_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${v1_s1}  ${sch_id}  ${Add_DAY40}  ${cnote}  ${CallingModes[0]}  ${ZOOM_Pid2}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid240}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid240}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # -----------------------------------------------------


    ${Add_DAY45}=  db.add_timezone_date  ${tz}  45
    Set Suite Variable  ${Add_DAY45}
    ${Date45} =	Convert Date	${Add_DAY45}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date45_Slot17}   ${Date45} [${converted_slot17}]
    ${apptfor1}=  Create Dictionary  id=0   apptTime=${slot17}   firstName=${cid6_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Appointment For Provider   ${pid}  ${p1_s1}  ${sch_id}  ${Add_DAY45}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid241}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid241}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Set Suite Variable  ${Date45_Slot18}   ${Date45} [${converted_slot18}]
    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot18}   firstName=${family_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${v1_s1}  ${sch_id}  ${Add_DAY45}  ${cnote}  ${CallingModes[0]}  ${ZOOM_Pid2}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid242}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid242}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # -----------------------------------------------------


    ${Add_DAY50}=  db.add_timezone_date  ${tz}  50
    Set Suite Variable  ${Add_DAY50}
    ${Date50} =	Convert Date	${Add_DAY50}	result_format=%d/%m/%Y
    Set Suite Variable  ${Date50_Slot18}   ${Date50} [${converted_slot18}]
    ${apptfor1}=  Create Dictionary  id=0   apptTime=${slot18}   firstName=${cid6_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Appointment For Provider   ${pid}  ${p1_s1}  ${sch_id}  ${Add_DAY50}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid243}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid243}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Set Suite Variable  ${Date50_Slot1}   ${Date50} [${converted_slot1}]
    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot1}   firstName=${family_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${v1_s1}  ${sch_id}  ${Add_DAY50}  ${cnote}  ${CallingModes[0]}  ${ZOOM_Pid2}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid244}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid244}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # -----------------------------------------------------
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    # Set Suite Variable  ${C6_name}   ${cid6_fname} ${cid6_lname}
    # Set Suite Variable  ${fid1_name}   ${family_fname} ${family_lname}
    # Set Suite Variable  ${fid2_name}   ${fid2_fname} ${fid2_lname}

    sleep  4s
    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${reportType}              APPOINTMENT
    Set Test Variable  ${reportDateCategory}      TODAY

    ${filter}=  Create Dictionary   apptForId-eq=${jid_c6},${jid_c6_f1},${jid_c6_f2}  
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${token_id1}   ${resp.json()}
    sleep  4s
    ${resp}=  Get Report Status By Token Id  ${token_id1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Report By Status       ${Statuses[1]}  ${Statuses[3]}  ${Statuses[4]}  ${Statuses[5]}  ${Statuses[6]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

# *** Keywords ***
# Get Report By Status
#     [Arguments]  @{kwargs}
#     Check And Create YNW Session
#     ${len}=   Get Length  ${kwargs}
#     ${data}=  Catenate  SEPARATOR=,  @{kwargs}
#     ${resp}=    GET On Session     ynw   /provider/report/status/cache/${data}   expected_status=any
#     RETURN  ${resp}