*** Settings ***
Suite Teardown    Run Keywords   Delete All Sessions  resetsystem_time
Test Teardown     Run Keywords   Delete All Sessions  resetsystem_time
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
Variables         /ebs/TDD/varfiles/musers.py
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




*** Test Cases ***

JD-TC-Appointment_Report-1
    [Documentation]  Generate LAST_WEEK Appointment_report using "consumer and family_member_id" together for filtering

    ${resp}=  ProviderLogin  ${PUSERNAME140}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${pid}=  get_acc_id  ${PUSERNAME140}
    Set Suite Variable  ${pid}

    ${duration}=   Random Int  min=2  max=10
    Set Suite Variable   ${duration}
    
    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}   ${duration}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${Empty}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  View Waitlist Settings
    Verify Response  ${resp}  calculationMode=${calc_mode[1]}  trnArndTime=${duration}  futureDateWaitlist=${bool[1]}  showTokenId=${bool[1]}  onlineCheckIns=${bool[1]}  maxPartySize=1
    
    clear_queue     ${PUSERNAME140}
    clear_service   ${PUSERNAME140}
    clear_appt_schedule   ${PUSERNAME140}
    
    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}
    ${DAY2}=  add_date  55
    Set Suite Variable  ${DAY2}
    ${description}=     FakerLibrary.sentence
    Set Suite Variable   ${description}
    ${firstname1}=  FakerLibrary.first_name
    Set Test Variable  ${firstname1}
    set Suite Variable  ${email}  ${firstname1}${CUSERNAME6}${C_Email}.${test_mail}
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
    ${DAY}=  get_date
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
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${v1_s1}  ${resp.json()} 

    ${resp}=   Get Service By Id  ${v1_s1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Verify Response  ${resp}  name=${V1SERVICE1}  description=${description}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}   totalAmount=${Total}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}  serviceType=virtualService   virtualServiceType=${vstype}

    ${sTime1}=  add_time  0  00
    ${eTime1}=  add_time   2  30
    ${p1queue1}=    FakerLibrary.word

    ${resp}=  Get Locations
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_l1}  ${resp.json()[0]['id']}

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

    ${resp}=  Consumer Login  ${CUSERNAME6}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${cid6_fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${cid6_lname}   ${resp.json()['lastName']}
    Set Suite Variable  ${C6_name}   ${cid6_fname} ${cid6_lname}
    
    ${cid}=  get_id  ${CUSERNAME6}
    Set Suite Variable  ${cid}
    ${family_fname}=  FakerLibrary.first_name
    Set Suite Variable  ${family_fname}
    ${family_lname}=  FakerLibrary.last_name
    Set Suite Variable  ${family_lname}
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
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
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
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
    
    ${TODAY}=  get_date
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
    Set Suite Variable  ${encId01}   ${resp.json()['appointmentEncId']}

    ${apptfor1}=  Create Dictionary  id=0   apptTime=${slot2}   firstName=${cid6_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${p1_s1}  ${sch_id}  ${TODAY}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid02}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid02}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${jid_c6}   ${resp.json()['appmtFor'][0]['memberJaldeeId']}
    Set Suite Variable  ${encId02}   ${resp.json()['appointmentEncId']}

    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot3}   firstName=${family_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${v1_s1}  ${sch_id}  ${TODAY}  ${cnote}  ${CallingModes[0]}  ${ZOOM_Pid2}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid03}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid03}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${encId03}   ${resp.json()['appointmentEncId']}

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
    Set Suite Variable  ${encId04}   ${resp.json()['appointmentEncId']}

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
    Set Suite Variable  ${encId05}   ${resp.json()['appointmentEncId']}

    ${apptfor1}=  Create Dictionary  id=${cidfor2}   apptTime=${slot6}   firstName=${fid2_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${v1_s1}  ${sch_id}  ${TODAY}  ${cnote}  ${CallingModes[0]}  ${ZOOM_Pid2}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid06}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid06}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${encId06}   ${resp.json()['appointmentEncId']}

    ${resp}=  ProviderLogin  ${PUSERNAME140}  ${PASSWORD}
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

    ${resp}=  Consumer Login  ${CUSERNAME6}  ${PASSWORD}
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

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid07}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${encId07}   ${resp.json()['appointmentEncId']}

    ${apptfor1}=  Create Dictionary  id=0   apptTime=${slot8}   firstName=${cid6_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${p1_s1}  ${sch_id}  ${TODAY}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid08}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid08}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${encId08}   ${resp.json()['appointmentEncId']}

    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot9}   firstName=${family_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${v1_s1}  ${sch_id}  ${TODAY}  ${cnote}  ${CallingModes[0]}  ${ZOOM_Pid2}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid09}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid09}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${encId09}   ${resp.json()['appointmentEncId']}

    ${apptfor1}=  Create Dictionary  id=0   apptTime=${slot10}   firstName=${cid6_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${v1_s1}  ${sch_id}  ${TODAY}  ${cnote}  ${CallingModes[0]}  ${ZOOM_Pid2}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid010}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid010}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${encId010}   ${resp.json()['appointmentEncId']}
    # -----------------------------------------------------


    ${Add_DAY1}=  add_date  1
    Set Suite Variable  ${Add_DAY1}
    ${Add_Date1} =	Convert Date	${Add_DAY1}	result_format=%d/%m/%Y
    Set Suite Variable  ${Add_Date1}
    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot2}   firstName=${family_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Appointment For Provider   ${pid}  ${p1_s1}  ${sch_id}  ${Add_DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid111}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid111}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${encId111}   ${resp.json()['appointmentEncId']}

    ${apptfor1}=  Create Dictionary  id=0   apptTime=${slot3}   firstName=${cid6_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${v1_s1}  ${sch_id}  ${Add_DAY1}  ${cnote}  ${CallingModes[0]}  ${ZOOM_Pid2}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid112}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid112}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${encId112}   ${resp.json()['appointmentEncId']}
    # -----------------------------------------------------


    ${Add_DAY2}=  add_date  2
    Set Suite Variable  ${Add_DAY2}
    ${Add_Date2} =	Convert Date	${Add_DAY2}	result_format=%d/%m/%Y
    Set Suite Variable  ${Add_Date2}
    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot3}   firstName=${family_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Appointment For Provider   ${pid}  ${p1_s1}  ${sch_id}  ${Add_DAY2}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid113}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid113}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${encId113}   ${resp.json()['appointmentEncId']}

    ${apptfor1}=  Create Dictionary  id=0   apptTime=${slot4}   firstName=${cid6_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${v1_s1}  ${sch_id}  ${Add_DAY2}  ${cnote}  ${CallingModes[0]}  ${ZOOM_Pid2}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid114}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid114}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${encId114}   ${resp.json()['appointmentEncId']}
    # -----------------------------------------------------

    ${Add_DAY3}=  add_date  3
    Set Suite Variable  ${Add_DAY3}
    ${Add_Date3} =	Convert Date	${Add_DAY3}	result_format=%d/%m/%Y
    Set Suite Variable  ${Add_Date3}
    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot4}   firstName=${family_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Appointment For Provider   ${pid}  ${p1_s1}  ${sch_id}  ${Add_DAY3}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid115}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid115}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${encId115}   ${resp.json()['appointmentEncId']}

    ${apptfor1}=  Create Dictionary  id=0   apptTime=${slot5}   firstName=${cid6_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${v1_s1}  ${sch_id}  ${Add_DAY3}  ${cnote}  ${CallingModes[0]}  ${ZOOM_Pid2}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid116}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid116}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${encId116}   ${resp.json()['appointmentEncId']}
    # -----------------------------------------------------

    ${Add_DAY4}=  add_date  4
    Set Suite Variable  ${Add_DAY4}
    ${Add_Date4} =	Convert Date	${Add_DAY4}	result_format=%d/%m/%Y
    Set Suite Variable  ${Add_Date4}
    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot5}   firstName=${family_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Appointment For Provider   ${pid}  ${p1_s1}  ${sch_id}  ${Add_DAY4}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid117}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid117}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${encId117}   ${resp.json()['appointmentEncId']}

    ${apptfor1}=  Create Dictionary  id=0   apptTime=${slot6}   firstName=${cid6_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${v1_s1}  ${sch_id}  ${Add_DAY4}  ${cnote}  ${CallingModes[0]}  ${ZOOM_Pid2}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid118}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid118}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${encId118}   ${resp.json()['appointmentEncId']}
    # -----------------------------------------------------


    ${Add_DAY5}=  add_date  5
    Set Suite Variable  ${Add_DAY5}
    ${Add_Date5} =	Convert Date	${Add_DAY5}	result_format=%d/%m/%Y
    Set Suite Variable  ${Add_Date5}
    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot6}   firstName=${family_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Appointment For Provider   ${pid}  ${p1_s1}  ${sch_id}  ${Add_DAY5}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid119}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid119}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${encId119}   ${resp.json()['appointmentEncId']}

    ${apptfor1}=  Create Dictionary  id=0   apptTime=${slot7}   firstName=${cid6_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${v1_s1}  ${sch_id}  ${Add_DAY5}  ${cnote}  ${CallingModes[0]}  ${ZOOM_Pid2}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid120}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid120}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${encId120}   ${resp.json()['appointmentEncId']}
    # -----------------------------------------------------

    ${Add_DAY6}=  add_date  6
    Set Suite Variable  ${Add_DAY6}
    ${Add_Date6} =	Convert Date	${Add_DAY6}	result_format=%d/%m/%Y
    Set Suite Variable  ${Add_Date6}
    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot7}   firstName=${family_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Appointment For Provider   ${pid}  ${p1_s1}  ${sch_id}  ${Add_DAY6}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid121}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid121}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${encId121}   ${resp.json()['appointmentEncId']}

    ${apptfor1}=  Create Dictionary  id=0   apptTime=${slot8}   firstName=${cid6_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${v1_s1}  ${sch_id}  ${Add_DAY6}  ${cnote}  ${CallingModes[0]}  ${ZOOM_Pid2}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid122}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid122}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${encId122}   ${resp.json()['appointmentEncId']}
    # -----------------------------------------------------


    ${Add_DAY7}=  add_date  7
    Set Suite Variable  ${Add_DAY7}
    ${Add_Date7} =	Convert Date	${Add_DAY7}	result_format=%d/%m/%Y
    Set Suite Variable  ${Add_Date7}
    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot8}   firstName=${family_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Appointment For Provider   ${pid}  ${p1_s1}  ${sch_id}  ${Add_DAY7}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid123}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid123}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${encId123}   ${resp.json()['appointmentEncId']}

    ${apptfor1}=  Create Dictionary  id=0   apptTime=${slot9}   firstName=${cid6_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${v1_s1}  ${sch_id}  ${Add_DAY7}  ${cnote}  ${CallingModes[0]}  ${ZOOM_Pid2}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid124}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid124}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${encId124}   ${resp.json()['appointmentEncId']}
    # -----------------------------------------------------


    ${Add_DAY8}=  add_date  8
    Set Suite Variable  ${Add_DAY8}
    ${Add_Date8} =	Convert Date	${Add_DAY8}	result_format=%d/%m/%Y
    Set Suite Variable  ${Add_Date8}
    ${apptfor1}=  Create Dictionary  id=0   apptTime=${slot9}   firstName=${cid6_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Appointment For Provider   ${pid}  ${p1_s1}  ${sch_id}  ${Add_DAY8}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid225}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid225}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${encId225}   ${resp.json()['appointmentEncId']}

    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot10}   firstName=${family_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${v1_s1}  ${sch_id}  ${Add_DAY8}  ${cnote}  ${CallingModes[0]}  ${ZOOM_Pid2}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid226}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid226}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${encId226}   ${resp.json()['appointmentEncId']}
    # -----------------------------------------------------


    ${Add_DAY15}=  add_date  15
    Set Suite Variable  ${Add_DAY15}
    ${Add_Date15} =	Convert Date	${Add_DAY15}	result_format=%d/%m/%Y
    Set Suite Variable  ${Add_Date15}
    ${apptfor1}=  Create Dictionary  id=0   apptTime=${slot10}   firstName=${cid6_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Appointment For Provider   ${pid}  ${p1_s1}  ${sch_id}  ${Add_DAY15}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid227}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid227}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${encId227}   ${resp.json()['appointmentEncId']}

    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot1}   firstName=${family_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${v1_s1}  ${sch_id}  ${Add_DAY15}  ${cnote}  ${CallingModes[0]}  ${ZOOM_Pid2}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid228}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid228}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${encId228}   ${resp.json()['appointmentEncId']}
    # -----------------------------------------------------


    ${Add_DAY20}=  add_date  20
    Set Suite Variable  ${Add_DAY20}
    ${Add_Date20} =	Convert Date	${Add_DAY20}	result_format=%d/%m/%Y
    Set Suite Variable  ${Add_Date20}
    ${apptfor1}=  Create Dictionary  id=0   apptTime=${slot11}   firstName=${cid6_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Appointment For Provider   ${pid}  ${p1_s1}  ${sch_id}  ${Add_DAY20}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid229}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid229}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${encId229}   ${resp.json()['appointmentEncId']}

    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot12}   firstName=${family_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${v1_s1}  ${sch_id}  ${Add_DAY20}  ${cnote}  ${CallingModes[0]}  ${ZOOM_Pid2}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid230}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid230}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${encId230}   ${resp.json()['appointmentEncId']}
    # -----------------------------------------------------


    ${Add_DAY25}=  add_date  25
    Set Suite Variable  ${Add_DAY25}
    ${Add_Date25} =	Convert Date	${Add_DAY25}	result_format=%d/%m/%Y
    Set Suite Variable  ${Add_Date25}
    ${apptfor1}=  Create Dictionary  id=0   apptTime=${slot12}   firstName=${cid6_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Appointment For Provider   ${pid}  ${p1_s1}  ${sch_id}  ${Add_DAY25}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid231}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid231}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${encId231}   ${resp.json()['appointmentEncId']}

    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot13}   firstName=${family_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${v1_s1}  ${sch_id}  ${Add_DAY25}  ${cnote}  ${CallingModes[0]}  ${ZOOM_Pid2}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid232}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid232}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${encId232}   ${resp.json()['appointmentEncId']}
    # -----------------------------------------------------


    ${Add_DAY30}=  add_date  30
    Set Suite Variable  ${Add_DAY30}
    ${Add_Date30} =	Convert Date	${Add_DAY30}	result_format=%d/%m/%Y
    Set Suite Variable  ${Add_Date30}
    ${apptfor1}=  Create Dictionary  id=0   apptTime=${slot13}   firstName=${cid6_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Appointment For Provider   ${pid}  ${p1_s1}  ${sch_id}  ${Add_DAY30}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid233}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid233}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${encId233}   ${resp.json()['appointmentEncId']}

    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot14}   firstName=${family_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${v1_s1}  ${sch_id}  ${Add_DAY30}  ${cnote}  ${CallingModes[0]}  ${ZOOM_Pid2}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid234}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid234}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${encId234}   ${resp.json()['appointmentEncId']}
    # -----------------------------------------------------


    ${Add_DAY31}=  add_date  31
    Set Suite Variable  ${Add_DAY31}
    ${Add_Date31} =	Convert Date	${Add_DAY31}	result_format=%d/%m/%Y
    Set Suite Variable  ${Add_Date31}
    ${apptfor1}=  Create Dictionary  id=0   apptTime=${slot14}   firstName=${cid6_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Appointment For Provider   ${pid}  ${p1_s1}  ${sch_id}  ${Add_DAY31}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid235}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid235}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${encId235}   ${resp.json()['appointmentEncId']}

    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot15}   firstName=${family_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${v1_s1}  ${sch_id}  ${Add_DAY31}  ${cnote}  ${CallingModes[0]}  ${ZOOM_Pid2}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid236}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid236}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${encId236}   ${resp.json()['appointmentEncId']}
    # -----------------------------------------------------


    ${Add_DAY36}=  add_date  36
    Set Suite Variable  ${Add_DAY36}
    ${Add_Date36} =	Convert Date	${Add_DAY36}	result_format=%d/%m/%Y
    Set Suite Variable  ${Add_Date36}
    ${apptfor1}=  Create Dictionary  id=0   apptTime=${slot15}   firstName=${cid6_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Appointment For Provider   ${pid}  ${p1_s1}  ${sch_id}  ${Add_DAY36}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid237}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid237}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${encId237}   ${resp.json()['appointmentEncId']}

    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot16}   firstName=${family_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${v1_s1}  ${sch_id}  ${Add_DAY36}  ${cnote}  ${CallingModes[0]}  ${ZOOM_Pid2}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid238}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid238}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${encId238}   ${resp.json()['appointmentEncId']}
    # -----------------------------------------------------


    ${Add_DAY40}=  add_date  40
    Set Suite Variable  ${Add_DAY40}
    ${Add_Date40} =	Convert Date	${Add_DAY40}	result_format=%d/%m/%Y
    Set Suite Variable  ${Add_Date40}
    ${apptfor1}=  Create Dictionary  id=0   apptTime=${slot16}   firstName=${cid6_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Appointment For Provider   ${pid}  ${p1_s1}  ${sch_id}  ${Add_DAY40}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid239}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid239}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${encId239}   ${resp.json()['appointmentEncId']}

    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot17}   firstName=${family_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${v1_s1}  ${sch_id}  ${Add_DAY40}  ${cnote}  ${CallingModes[0]}  ${ZOOM_Pid2}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid240}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid240}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${encId240}   ${resp.json()['appointmentEncId']}
    # -----------------------------------------------------


    ${Add_DAY45}=  add_date  45
    Set Suite Variable  ${Add_DAY45}
    ${Add_Date45} =	Convert Date	${Add_DAY45}	result_format=%d/%m/%Y
    Set Suite Variable  ${Add_Date45}
    ${apptfor1}=  Create Dictionary  id=0   apptTime=${slot17}   firstName=${cid6_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Appointment For Provider   ${pid}  ${p1_s1}  ${sch_id}  ${Add_DAY45}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid241}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid241}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${encId241}   ${resp.json()['appointmentEncId']}

    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot18}   firstName=${family_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${v1_s1}  ${sch_id}  ${Add_DAY45}  ${cnote}  ${CallingModes[0]}  ${ZOOM_Pid2}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid242}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid242}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${encId242}   ${resp.json()['appointmentEncId']}
    # -----------------------------------------------------


    ${Add_DAY50}=  add_date  50
    Set Suite Variable  ${Add_DAY50}
    ${Add_Date50} =	Convert Date	${Add_DAY50}	result_format=%d/%m/%Y
    Set Suite Variable  ${Add_Date50}
    ${apptfor1}=  Create Dictionary  id=0   apptTime=${slot18}   firstName=${cid6_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Appointment For Provider   ${pid}  ${p1_s1}  ${sch_id}  ${Add_DAY50}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid243}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid243}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${encId243}   ${resp.json()['appointmentEncId']}

    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot1}   firstName=${family_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Virtual Service Appointment For Provider   ${pid}  ${v1_s1}  ${sch_id}  ${Add_DAY50}  ${cnote}  ${CallingModes[0]}  ${ZOOM_Pid2}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid244}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid244}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${encId244}   ${resp.json()['appointmentEncId']}
    # -----------------------------------------------------

    ${resp}=  ProviderLogin  ${PUSERNAME140}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    # Set Suite Variable  ${C6_name}   ${cid6_fname} ${cid6_lname}
    # Set Suite Variable  ${fid1_name}   ${family_fname} ${family_lname}
    # Set Suite Variable  ${fid2_name}   ${fid2_fname} ${fid2_lname}

    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${reportType}              APPOINTMENT
    Set Test Variable  ${reportDateCategory}      TODAY

    ${filter}=  Create Dictionary   apptForId-eq=${EMPTY}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${token_id2}   ${resp.json()}

    ${resp}=  Get Report Status By Token Id  ${token_id2}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${filter3}=  Create Dictionary   apptForId-eq=${jid_c6},${jid_c6_f1},${jid_c6_f2}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${token_id2}   ${resp.json()}

    ${resp}=  Get Report Status By Token Id  ${token_id2}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  reportType=${Report_Types[1]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    Set Suite Variable  ${RqId_c6_1}      ${resp.json()['reportRequestId']}
    Should Be Equal As Strings  ${jid_c6},${jid_c6_f1},${jid_c6_f2}   ${resp.json()['reportContent']['reportHeader']['Customer ID']}
    Should Be Equal As Strings  Today       ${resp.json()['reportContent']['reportHeader']['Time Period']}
    Should Be Equal As Strings  Appointment Report         ${resp.json()['reportContent']['reportName']}
    Should Be Equal As Strings  10                    ${resp.json()['reportContent']['count']}
    Should Be Equal As Strings  ${TODAY}               ${resp.json()['reportContent']['date']}

    ${len}=  Get Length  ${resp.json()['reportContent']['data']}
    Should Be Equal As Integers  ${len}  ${resp.json()['reportContent']['count']}

    FOR  ${i}  IN RANGE   ${len}

        Log   ${resp.json()['reportContent']['data'][${i}]['7']}
        Run Keyword IF  '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId01}'  # ConfirmationId
        ...    Run Keywords
        ...    Should Be Equal As Strings  ${Current_Date}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[6]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id101}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId02}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Current_Date}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[4]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id102}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId03}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Current_Date}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[4]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id103}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId04}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Current_Date}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[6]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id104}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId05}'   # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Current_Date}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6_f2}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${fid2_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[5]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id105}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId06}'   # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Current_Date}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6_f2}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${fid2_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[5]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id106}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId07}'   # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Current_Date}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id107}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId08}'   # ConfirmationId
        ...    Run Keywords
    
        ...    Should Be Equal As Strings  ${Current_Date}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id108}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId09}'
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Current_Date}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id109}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId010}'   # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Current_Date}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id110}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

    END        


    ${LAST_WEEK1_DAY1}=  subtract_date  6
    Set Suite Variable  ${LAST_WEEK1_DAY1} 
    ${LAST_WEEK1_DAY7}=  get_date
    Set Suite Variable  ${LAST_WEEK1_DAY7}

    change_system_date   1

    ${resp}=  ProviderLogin  ${PUSERNAME140}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${reportType}              APPOINTMENT
    Set Test Variable  ${reportDateCategory}      LAST_WEEK

    ${filter}=  Create Dictionary   apptForId-eq=${EMPTY}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${filter3}=  Create Dictionary   apptForId-eq=${jid_c6},${jid_c6_f1},${jid_c6_f2}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  reportType=${Report_Types[1]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    Set Suite Variable  ${RqId_c6_1}      ${resp.json()['reportRequestId']}
    Should Be Equal As Strings  ${jid_c6},${jid_c6_f1},${jid_c6_f2}   ${resp.json()['reportContent']['reportHeader']['Customer id']}
    Should Be Equal As Strings  Last 7 days       ${resp.json()['reportContent']['reportHeader']['Time Period']}
    Should Be Equal As Strings  Appointment Report         ${resp.json()['reportContent']['reportName']}
    Should Be Equal As Strings  10                    ${resp.json()['reportContent']['count']}
    Should Be Equal As Strings  ${LAST_WEEK1_DAY1}               ${resp.json()['reportContent']['from']}
    Should Be Equal As Strings  ${LAST_WEEK1_DAY7}               ${resp.json()['reportContent']['to']}

    ${len}=  Get Length  ${resp.json()['reportContent']['data']}
    Should Be Equal As Integers  ${len}  ${resp.json()['reportContent']['count']}
    FOR  ${i}  IN RANGE   ${len}

        Log   ${resp.json()['reportContent']['data'][${i}]['7']}
        Run Keyword IF  '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId01}'  # ConfirmationId
        ...    Run Keywords
        ...    Should Be Equal As Strings  ${Current_Date}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[6]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id101}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId02}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Current_Date}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        # ...    AND  Should Be Equal As Strings  ${apptStatus[4]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id102}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId03}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Current_Date}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        # ...    AND  Should Be Equal As Strings  ${apptStatus[4]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id103}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId04}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Current_Date}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[6]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id104}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId05}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Current_Date}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6_f2}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${fid2_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[5]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id105}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId06}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Current_Date}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6_f2}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${fid2_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[5]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id106}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId07}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Current_Date}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id107}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId08}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Current_Date}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id108}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId09}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Current_Date}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id109}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId010}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Current_Date}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id110}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

    END

    resetsystem_time

*** comment ***
JD-TC-Appointment_Report-2
    [Documentation]  Generate LAST_WEEK Appointment_report using "consumer or family_member_id" individually for filtering
    resetsystem_time

    change_system_date   1
    ${resp}=  ProviderLogin  ${PUSERNAME140}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${reportType}             APPOINTMENT
    Set Test Variable  ${reportDateCategory1}    LAST_WEEK
    ${filter1}=  Create Dictionary   apptForId-eq=${jid_c6}  
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  reportType=${Report_Types[1]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    Set Suite Variable  ${RqId_c6_1}      ${resp.json()['reportRequestId']}
    Should Be Equal As Strings  ${jid_c6}   ${resp.json()['reportContent']['reportHeader']['Customer id']}
    Should Be Equal As Strings  Last 7 days       ${resp.json()['reportContent']['reportHeader']['Time Period']}
    Should Be Equal As Strings  Appointment Report         ${resp.json()['reportContent']['reportName']}
    Should Be Equal As Strings  4                    ${resp.json()['reportContent']['count']}
    Should Be Equal As Strings  ${LAST_WEEK1_DAY1}               ${resp.json()['reportContent']['from']}
    Should Be Equal As Strings  ${LAST_WEEK1_DAY7}               ${resp.json()['reportContent']['to']}

    ${len}=  Get Length  ${resp.json()['reportContent']['data']}
    Should Be Equal As Integers  ${len}  ${resp.json()['reportContent']['count']}
    FOR  ${i}  IN RANGE   ${len}

        Log   ${resp.json()['reportContent']['data'][${i}]['7']}
        Run Keyword IF  '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId02}'  # ConfirmationId
        ...    Run Keywords
    
        ...    Should Be Equal As Strings  ${Current_Date}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        # ...    AND  Should Be Equal As Strings  ${apptStatus[4]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id102}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId04}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Current_Date}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[6]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id104}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId08}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Current_Date}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id108}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId010}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Current_Date}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id110}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

    END

    
    ${filter2}=  Create Dictionary   apptForId-eq=${jid_c6_f1}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  reportType=${Report_Types[1]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    Set Suite Variable  ${RqId_c6_1}      ${resp.json()['reportRequestId']}
    Should Be Equal As Strings  ${jid_c6_f1}   ${resp.json()['reportContent']['reportHeader']['Customer id']}
    Should Be Equal As Strings  Last 7 days       ${resp.json()['reportContent']['reportHeader']['Time Period']}
    Should Be Equal As Strings  Appointment Report         ${resp.json()['reportContent']['reportName']}
    Should Be Equal As Strings  4                    ${resp.json()['reportContent']['count']}
    Should Be Equal As Strings  ${LAST_WEEK1_DAY1}               ${resp.json()['reportContent']['from']}
    Should Be Equal As Strings  ${LAST_WEEK1_DAY7}               ${resp.json()['reportContent']['to']}
    
    ${len}=  Get Length  ${resp.json()['reportContent']['data']}
    Should Be Equal As Integers  ${len}  ${resp.json()['reportContent']['count']}
    FOR  ${i}  IN RANGE   ${len}

        Log   ${resp.json()['reportContent']['data'][${i}]['7']}
        Run Keyword IF  '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId01}'  # ConfirmationId
        ...    Run Keywords
    
        ...    Should Be Equal As Strings  ${Current_Date}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[6]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id101}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        
        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId03}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Current_Date}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        # ...    AND  Should Be Equal As Strings  ${apptStatus[4]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id103}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        
        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId07}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Current_Date}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id107}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        
        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId09}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Current_Date}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id109}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

    END



    ${filter3}=  Create Dictionary   apptForId-eq=${jid_c6_f2}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  reportType=${Report_Types[1]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    Set Suite Variable  ${RqId_c6_1}      ${resp.json()['reportRequestId']}
    Should Be Equal As Strings  ${jid_c6_f2}   ${resp.json()['reportContent']['reportHeader']['Customer id']}
    Should Be Equal As Strings  Last 7 days       ${resp.json()['reportContent']['reportHeader']['Time Period']}
    Should Be Equal As Strings  Appointment Report         ${resp.json()['reportContent']['reportName']}
    Should Be Equal As Strings  2                    ${resp.json()['reportContent']['count']}
    Should Be Equal As Strings  ${LAST_WEEK1_DAY1}               ${resp.json()['reportContent']['from']}
    Should Be Equal As Strings  ${LAST_WEEK1_DAY7}               ${resp.json()['reportContent']['to']}
    
    ${len}=  Get Length  ${resp.json()['reportContent']['data']}
    Should Be Equal As Integers  ${len}  ${resp.json()['reportContent']['count']}
    FOR  ${i}  IN RANGE   ${len}

        Log   ${resp.json()['reportContent']['data'][${i}]['7']}
        Run Keyword IF  '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId05}'  # ConfirmationId
        ...    Run Keywords
    
        ...    Should Be Equal As Strings  ${Current_Date}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6_f2}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${fid2_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[5]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id105}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId06}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Current_Date}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6_f2}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${fid2_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[5]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id106}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

    END

    
    resetsystem_time
    

JD-TC-Appointment_Report-3
    [Documentation]  Generate LAST_THIRTY_DAYS Appointment_report of a provider
    resetsystem_time

    change_system_date   31
    ${resp}=  ProviderLogin  ${PUSERNAME140}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${reportType}             APPOINTMENT

    Set Test Variable  ${reportDateCategory1}    LAST_THIRTY_DAYS
    ${filter}=  Create Dictionary   apptForId-eq=${jid_c6},${jid_c6_f1},${jid_c6_f2}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  reportType=${Report_Types[1]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    Set Suite Variable  ${RqId_c6_2}      ${resp.json()['reportRequestId']}
    Should Be Equal As Strings  ${jid_c6},${jid_c6_f1},${jid_c6_f2}    ${resp.json()['reportContent']['reportHeader']['Customer id']}
    Should Be Equal As Strings  Last 30 days       ${resp.json()['reportContent']['reportHeader']['Time Period']}
    Should Be Equal As Strings  Appointment Report         ${resp.json()['reportContent']['reportName']}
    Should Be Equal As Strings  24                    ${resp.json()['reportContent']['count']}
    Should Be Equal As Strings  ${Add_DAY1}               ${resp.json()['reportContent']['from']}
    Should Be Equal As Strings  ${Add_DAY30}               ${resp.json()['reportContent']['to']}

    ${len}=  Get Length  ${resp.json()['reportContent']['data']}
    Should Be Equal As Integers  ${len}  ${resp.json()['reportContent']['count']}
    FOR  ${i}  IN RANGE   ${len}

        Log   ${resp.json()['reportContent']['data'][${i}]['7']}
        Run Keyword IF  '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId111}'  # ConfirmationId
        ...    Run Keywords
    
        ...    Should Be Equal As Strings  ${Add_Date1}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date    
        ...    AND  Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id301}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId112}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date1}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id302}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId113}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date2}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id303}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId114}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date2}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id304}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId115}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date3}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id305}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId116}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date3}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id306}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId117}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date4}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id307}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId118}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date4}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id308}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId119}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date5}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id309}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId120}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date5}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id310}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId121}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date6}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id311}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId122}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date6}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id312}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId123}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date7}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id313}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId124}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date7}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id314}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId225}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date8}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id315}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId


        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId226}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date8}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id316}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId


        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId227}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date15}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id317}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId


        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId228}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date15}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id318}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId


        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId229}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date20}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id319}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId


        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId230}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date20}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id320}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId


        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId231}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date25}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id321}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId


        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId232}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date25}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id322}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId


        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId233}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date30}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id323}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId


        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId234}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date30}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id324}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId
    
    END

    resetsystem_time



JD-TC-Appointment_Report-4
    [Documentation]  Generate LAST_WEEK Appointment_report of a provider using Schedule_Id
    resetsystem_time

    change_system_date   8
    ${resp}=  ProviderLogin  ${PUSERNAME140}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${reportType}             APPOINTMENT
    Set Test Variable  ${reportDateCategory1}    LAST_WEEK
    ${filter}=  Create Dictionary   schedule-eq=${sch_id}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Not Contain    ${resp.json()}  ${TODAY}
    Verify Response  ${resp}  reportType=${Report_Types[1]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    Set Suite Variable  ${RqId_c6_2}      ${resp.json()['reportRequestId']}
    Should Be Equal As Strings  ${schedule_name}   ${resp.json()['reportContent']['reportHeader']['Schedule']}
    Should Be Equal As Strings  Last 7 days       ${resp.json()['reportContent']['reportHeader']['Time Period']}
    Should Be Equal As Strings  Appointment Report         ${resp.json()['reportContent']['reportName']}
    Should Be Equal As Strings  14                    ${resp.json()['reportContent']['count']}
    Should Be Equal As Strings  ${Add_DAY1}               ${resp.json()['reportContent']['from']}
    Should Be Equal As Strings  ${Add_DAY7}               ${resp.json()['reportContent']['to']}

    ${len}=  Get Length  ${resp.json()['reportContent']['data']}
    Should Be Equal As Integers  ${len}  ${resp.json()['reportContent']['count']}
    FOR  ${i}  IN RANGE   ${len}

        Log   ${resp.json()['reportContent']['data'][${i}]['7']}
        Run Keyword IF  '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId111}'  # ConfirmationId
        ...    Run Keywords
    
        ...    Should Be Equal As Strings  ${Add_Date1}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id201}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId112}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date1}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id202}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId113}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date2}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id203}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId114}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date2}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id204}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId115}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date3}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id205}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId116}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date3}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id206}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId117}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date4}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id207}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId118}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date4}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id208}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId119}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date5}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id209}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId120}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date5}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id210}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId121}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date6}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id211}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId122}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date6}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        ...    AND  Set Suite Variable  ${conf_id212}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId123}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date7}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id213}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId124}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date7}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id214}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

    END

    resetsystem_time


JD-TC-Appointment_Report-5
    [Documentation]  Generate LAST_THIRTY_DAYS Appointment_report of a provider using Service_Id
    resetsystem_time

    change_system_date   31
    ${resp}=  ProviderLogin  ${PUSERNAME140}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${reportType}             APPOINTMENT
    Set Test Variable  ${reportDateCategory1}    LAST_THIRTY_DAYS
    ${filter}=  Create Dictionary   service-eq=${p1_s1},${v1_s1}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  reportType=${Report_Types[1]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    Set Suite Variable  ${RqId_c6_2}      ${resp.json()['reportRequestId']}
    Should Be Equal As Strings  ${P1SERVICE1}, ${V1SERVICE1}   ${resp.json()['reportContent']['reportHeader']['Service']}
    Should Be Equal As Strings  Last 30 days       ${resp.json()['reportContent']['reportHeader']['Time Period']}
    Should Be Equal As Strings  Appointment Report         ${resp.json()['reportContent']['reportName']}
    Should Be Equal As Strings  24                    ${resp.json()['reportContent']['count']}
    Should Be Equal As Strings  ${Add_DAY1}               ${resp.json()['reportContent']['from']}
    Should Be Equal As Strings  ${Add_DAY30}               ${resp.json()['reportContent']['to']}

    ${len}=  Get Length  ${resp.json()['reportContent']['data']}
    Should Be Equal As Integers  ${len}  ${resp.json()['reportContent']['count']}
    FOR  ${i}  IN RANGE   ${len}

        Log   ${resp.json()['reportContent']['data'][${i}]['7']}
        Run Keyword IF  '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId111}'  # ConfirmationId
        ...    Run Keywords
    
        ...    Should Be Equal As Strings  ${Add_Date1}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
            # ...    AND  Set Suite Variable  ${conf_id301}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId112}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date1}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
            # ...    AND  Set Suite Variable  ${conf_id302}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId113}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date2}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
            # ...    AND  Set Suite Variable  ${conf_id303}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId114}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date2}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
            # ...    AND  Set Suite Variable  ${conf_id304}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId115}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date3}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
            # ...    AND  Set Suite Variable  ${conf_id305}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId116}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date3}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
            # ...    AND  Set Suite Variable  ${conf_id306}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId117}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date4}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
            # ...    AND  Set Suite Variable  ${conf_id307}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId118}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date4}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
            # ...    AND  Set Suite Variable  ${conf_id308}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId119}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date5}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
            # ...    AND  Set Suite Variable  ${conf_id309}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId120}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date5}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
            # ...    AND  Set Suite Variable  ${conf_id310}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId121}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date6}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
            # ...    AND  Set Suite Variable  ${conf_id311}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId122}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date6}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
            # ...    AND  Set Suite Variable  ${conf_id312}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId123}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date7}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
            # ...    AND  Set Suite Variable  ${conf_id313}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId124}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date7}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
            # ...    AND  Set Suite Variable  ${conf_id314}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId225}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date8}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
            # ...    AND  Set Suite Variable  ${conf_id315}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId


        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId226}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date8}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
            # ...    AND  Set Suite Variable  ${conf_id316}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId


        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId227}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date15}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
            # ...    AND  Set Suite Variable  ${conf_id317}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId


        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId228}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date15}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
            # ...    AND  Set Suite Variable  ${conf_id318}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId


        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId229}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date20}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
            # ...    AND  Set Suite Variable  ${conf_id319}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId


        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId230}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date20}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
            # ...    AND  Set Suite Variable  ${conf_id320}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId


        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId231}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date25}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
            # ...    AND  Set Suite Variable  ${conf_id321}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId


        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId232}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date25}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
            # ...    AND  Set Suite Variable  ${conf_id322}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId


        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId233}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date30}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
            # ...    AND  Set Suite Variable  ${conf_id323}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId


        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId234}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date30}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id324}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

    END

    resetsystem_time
    

JD-TC-Appointment_Report-6
    [Documentation]  Generate LAST_THIRTY_DAYS Appointment_report of a provider DISABLED Service_Id
    resetsystem_time

    change_system_date   31
    ${resp}=  ProviderLogin  ${PUSERNAME140}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${RESP}=  Disable service  ${p1_s1} 
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${reportType}             APPOINTMENT
    Set Test Variable  ${reportDateCategory1}    LAST_THIRTY_DAYS
    ${filter}=  Create Dictionary   service-eq=${p1_s1},${v1_s1}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Not Contain    ${resp.json()}  ${TODAY}
    # Should Not Contain    ${resp.json()}  ${Add_DAY31}
    # Should Not Contain    ${resp.json()}  ${Add_DAY36}
    # Should Not Contain    ${resp.json()}  ${Add_DAY40}
    # Should Not Contain    ${resp.json()}  ${Add_DAY45}
    # Should Not Contain    ${resp.json()}  ${Add_DAY50}
    Verify Response  ${resp}  reportType=${Report_Types[1]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    Set Suite Variable  ${RqId_c6_2}      ${resp.json()['reportRequestId']}
    Should Be Equal As Strings  ${P1SERVICE1}, ${V1SERVICE1}   ${resp.json()['reportContent']['reportHeader']['Service']}
    Should Be Equal As Strings  Last 30 days       ${resp.json()['reportContent']['reportHeader']['Time Period']}
    Should Be Equal As Strings  Appointment Report         ${resp.json()['reportContent']['reportName']}
    Should Be Equal As Strings  24                    ${resp.json()['reportContent']['count']}
    Should Be Equal As Strings  ${Add_DAY1}               ${resp.json()['reportContent']['from']}
    Should Be Equal As Strings  ${Add_DAY30}               ${resp.json()['reportContent']['to']}

    ${len}=  Get Length  ${resp.json()['reportContent']['data']}
    Should Be Equal As Integers  ${len}  ${resp.json()['reportContent']['count']}
    FOR  ${i}  IN RANGE   ${len}

        Log   ${resp.json()['reportContent']['data'][${i}]['7']}
        Run Keyword IF  '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId111}'  # ConfirmationId
        ...    Run Keywords
    
        ...    Should Be Equal As Strings  ${Add_Date1}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
            # ...    AND  Set Suite Variable  ${conf_id301}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId112}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date1}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
            # ...    AND  Set Suite Variable  ${conf_id302}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId113}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date2}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
            # ...    AND  Set Suite Variable  ${conf_id303}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId114}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date2}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
            # ...    AND  Set Suite Variable  ${conf_id304}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId115}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date3}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
            # ...    AND  Set Suite Variable  ${conf_id305}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId116}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date3}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
            # ...    AND  Set Suite Variable  ${conf_id306}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId117}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date4}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
            # ...    AND  Set Suite Variable  ${conf_id307}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId118}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date4}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
            # ...    AND  Set Suite Variable  ${conf_id308}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId119}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date5}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
            # ...    AND  Set Suite Variable  ${conf_id309}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId120}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date5}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
            # ...    AND  Set Suite Variable  ${conf_id310}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId121}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date6}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
            # ...    AND  Set Suite Variable  ${conf_id311}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId122}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date6}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
            # ...    AND  Set Suite Variable  ${conf_id312}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId123}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date7}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id313}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId124}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date7}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id314}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId225}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date8}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id315}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId


        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId226}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date8}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
            # ...    AND  Set Suite Variable  ${conf_id316}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId


        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId227}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date15}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
            # ...    AND  Set Suite Variable  ${conf_id317}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId


        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId228}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date15}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
            # ...    AND  Set Suite Variable  ${conf_id318}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId


        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId229}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date20}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id319}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId


        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId230}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date20}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
            # ...    AND  Set Suite Variable  ${conf_id320}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId


        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId231}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date25}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
            # ...    AND  Set Suite Variable  ${conf_id321}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId


        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId232}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date25}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
            # ...    AND  Set Suite Variable  ${conf_id322}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId


        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId233}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date30}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
            # ...    AND  Set Suite Variable  ${conf_id323}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId


        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId234}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Add_Date30}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id324}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

    END

    ${resp}=  Enable service  ${p1_s1} 
    Should Be Equal As Strings  ${resp.status_code}  200
    resetsystem_time


JD-TC-Appointment_Report-7
    [Documentation]  Generate LAST_WEEK Appointment_report of a provider using Disabled Schedule_Id
    resetsystem_time

    ${resp}=  ProviderLogin  ${PUSERNAME140}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${P1SERVICE3}=    FakerLibrary.word
    Set Suite Variable   ${P1SERVICE3}
    ${desc}=   FakerLibrary.sentence  
    ${DAY}=  get_date
    ${list}=  Create List  1  2  3  4  5  6  7

    ${resp}=  Create Service  ${P1SERVICE3}  ${desc}   ${service_duration[1]}  ${status[0]}    ${btype}  ${bool[1]}  ${notifytype[2]}  ${min_pre}  ${Total}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_s3}  ${resp.json()}

    ${sTime1}=  add_time  0  00
    ${eTime1}=  add_time   2  30
    ${p1queue2}=    FakerLibrary.word
    ${schedule_name2}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=5
    ${duration}=  FakerLibrary.Random Int  min=3  max=5
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name2}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${p1_l1}  ${duration}  ${bool1}  ${p1_s3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id2}  ${resp.json()}
    Set Suite Variable  ${schedule_name2}

    ${resp}=  Consumer Login  ${CUSERNAME6}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id2}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${num_slots}=  Get Length  ${slots}
    Set Test Variable   ${slot1}   ${slots[${num_slots-1}]}
    Set Test Variable   ${slot2}   ${slots[${num_slots-2}]}

    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot1}   firstName=${family_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${p1_s3}  ${sch_id2}  ${TODAY}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid71}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid71}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${jid_c6_f1}   ${resp.json()['appmtFor'][0]['memberJaldeeId']}
    Set Suite Variable  ${encId71}   ${resp.json()['appointmentEncId']}

    ${apptfor1}=  Create Dictionary  id=0   apptTime=${slot2}   firstName=${cid6_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${p1_s3}  ${sch_id2}  ${TODAY}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid72}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid72}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${jid_c6}   ${resp.json()['appmtFor'][0]['memberJaldeeId']}
    Set Suite Variable  ${encId72}   ${resp.json()['appointmentEncId']}

    ${resp}=  ProviderLogin  ${PUSERNAME140}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id2}   name=${schedule_name2}  apptState=${Qstate[0]}

    ${resp}=  Appointment Action   ${apptStatus[6]}   ${apptid71}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${reason}=  Random Element  ${cancelReason}
    ${cancel_msg}=   FakerLibrary.word
    ${resp}=    Provider Cancel Appointment  ${apptid72}  ${reason}  ${cancel_msg}  ${TODAY}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Disable Appointment Schedule  ${sch_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep  02s
    ${resp}=  Get Appointment Schedule ById  ${sch_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id2}   name=${schedule_name2}  apptState=${Qstate[1]}

    ${LAST_WEEK7_DAY1}=  get_date
    Set Suite Variable  ${LAST_WEEK7_DAY1} 
    ${LAST_WEEK7_DAY7}=  add_date  6
    Set Suite Variable  ${LAST_WEEK7_DAY7}

    change_system_date   7
    ${resp}=  ProviderLogin  ${PUSERNAME140}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${reportType}             APPOINTMENT
    Set Test Variable  ${reportDateCategory1}    LAST_WEEK
    ${filter}=  Create Dictionary   schedule-eq=${sch_id2}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  reportType=${Report_Types[1]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    Set Suite Variable  ${RqId_c6_7}      ${resp.json()['reportRequestId']}
    Should Be Equal As Strings  ${schedule_name2}   ${resp.json()['reportContent']['reportHeader']['Schedule']}
    Should Be Equal As Strings  Last 7 days        ${resp.json()['reportContent']['reportHeader']['Time Period']}
    Should Be Equal As Strings  Appointment Report         ${resp.json()['reportContent']['reportName']}
    Should Be Equal As Strings  2                    ${resp.json()['reportContent']['count']}
    Should Be Equal As Strings  ${LAST_WEEK7_DAY1}               ${resp.json()['reportContent']['from']}
    Should Be Equal As Strings  ${LAST_WEEK7_DAY7}               ${resp.json()['reportContent']['to']}

    ${len}=  Get Length  ${resp.json()['reportContent']['data']}
    Should Be Equal As Integers  ${len}  ${resp.json()['reportContent']['count']}
    FOR  ${i}  IN RANGE   ${len}

        Log   ${resp.json()['reportContent']['data'][${i}]['7']}
        Run Keyword IF  '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId71}'  # ConfirmationId
        ...    Run Keywords
    
        ...    Should Be Equal As Strings  ${Current_Date}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name2}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${P1SERVICE3}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[6]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id101}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

        ...    ELSE IF   '${resp.json()['reportContent']['data'][${i}]['7']}' == '${encId72}'  # ConfirmationId
        ...    Run Keywords

        ...    Should Be Equal As Strings  ${Current_Date}               ${resp.json()['reportContent']['data'][${i}]['1']}  # Date
        ...    AND  Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][${i}]['2']}  # CustomerId
        ...    AND  Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][${i}]['3']}  # CustomerName
        ...    AND  Should Be Equal As Strings  ${schedule_name2}        ${resp.json()['reportContent']['data'][${i}]['5']}  # Service
        ...    AND  Should Be Equal As Strings  ${P1SERVICE3}        ${resp.json()['reportContent']['data'][${i}]['6']}  # Service
        ...    AND  Should Be Equal As Strings  ${apptStatus[4]}   ${resp.json()['reportContent']['data'][${i}]['8']}  # Status
        ...    AND  Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][${i}]['9']}  # Mode
        ...    AND  Should Be Equal As Strings  ${paymentStatusReport[0]}  ${resp.json()['reportContent']['data'][${i}]['10']}  # PaymentStatus
        # ...    AND  Set Suite Variable  ${conf_id102}     ${resp.json()['reportContent']['data'][${i}]['7']}  # ConfirmationId

    END

    ${resp}=   Enable Appointment Schedule   ${sch_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    resetsystem_time


JD-TC-Appointment_Report-8
	[Documentation]   Appointment Report before completing prepayment of a Physical service 
    resetsystem_time
    ${resp}=  Provider Login  ${MUSERNAME15}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${P_Sector}   ${resp.json()['sector']}
    ${pid_B15}=  get_acc_id  ${MUSERNAME15}
    Set Suite variable  ${pid_B15}

    clear_Department    ${MUSERNAME15}
    clear_service       ${MUSERNAME15}
    clear_location      ${MUSERNAME15}

    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}   ${duration}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${Empty}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  View Waitlist Settings
    Verify Response  ${resp}  calculationMode=${calc_mode[1]}  trnArndTime=${duration}  futureDateWaitlist=${bool[1]}  showTokenId=${bool[1]}  onlineCheckIns=${bool[1]}
    
    
    ${highest_package}=  get_highest_license_pkg
    Log  ${highest_package}
    Set Suite variable  ${lic2}  ${highest_package[0]}
    ${resp}=   Change License Package  ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[3]}  ${GST_num} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  Enable Tax
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${ifsc_code}=   db.Generate_ifsc_code
    ${bank_ac}=   db.Generate_random_value  size=11   chars=${digits} 
    ${bank_name}=  FakerLibrary.company
    ${name}=  FakerLibrary.name
    ${branch}=   db.get_place
    ${resp}=   Update Account Payment Settings   ${bool[0]}  ${bool[0]}  ${bool[1]}  ${MUSERNAME15}   ${pan_num}  ${bank_ac}  ${bank_name}  ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}   
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  payuVerify  ${pid_B15}
    Log  ${resp}
    ${resp}=   Update Account Payment Settings   ${bool[1]}  ${bool[0]}  ${bool[1]}  ${MUSERNAME15}   ${pan_num}  ${bank_ac}  ${bank_name}  ${ifsc_code}  ${name}  ${name}  ${branch}  ${businessFilingStatus[1]}  ${accountType[1]}    
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  SetMerchantId  ${pid_B15}  ${merchantid}


    ${resp}=  Toggle Department Enable
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${dep_name1}=  FakerLibrary.bs
    Set Suite Variable   ${dep_name1}
    ${dep_code1}=   Random Int  min=100   max=999
    Set Suite Variable   ${dep_code1}
    ${dep_desc1}=   FakerLibrary.word  
    Set Suite Variable    ${dep_desc1}
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${dep_id}  ${resp.json()}
    
    ${number}=  Random Int  min=100  max=200
    ${PUSERNAME_U32}=  Evaluate  ${MUSERNAME15}+${number}
    clear_users  ${PUSERNAME_U32}
    Set Suite Variable  ${PUSERNAME_U32}
    ${firstname}=  FakerLibrary.name
    Set Suite Variable  ${firstname}
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname}
    ${address}=  get_address
    Set Suite Variable  ${address}
    ${dob}=  FakerLibrary.Date
    Set Suite Variable  ${dob}
    ${location}=  FakerLibrary.city
    Set Suite Variable  ${location}
    ${state}=  FakerLibrary.state
    Set Suite Variable  ${state}
    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    ${length}=  Get Length  ${iscorp_subdomains}
    FOR  ${i}  IN RANGE  ${length}
        Set Test Variable  ${domains}  ${iscorp_subdomains[${i}]['domain']}
        Set Test Variable  ${sub_domains}   ${iscorp_subdomains[${i}]['subdomains']}
        Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[${i}]['subdomainId']}
        Exit For Loop IF  '${iscorp_subdomains[${i}]['subdomains']}' == '${P_Sector}'
    END
 

    
    ${resp}=  Create User  ${firstname}  ${lastname}  ${address}  ${PUSERNAME_U32}  ${dob}    ${Genderlist[0]}  ${userType[0]}  ${P_Email}${PUSERNAME_U32}.${test_mail}  ${location}  ${state}  ${dep_id}  ${sub_domain_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id32}  ${resp.json()}
    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${p1_id32}   ${resp.json()[0]['id']}
    Set Suite Variable   ${p0_id32}   ${resp.json()[1]['id']}
    
        # ${resp}=  Enable Disable Virtual Service  Enable
        # Log  ${resp.json()}
        # Should Be Equal As Strings  ${resp.status_code}  200

    ${ZOOM_id0}=  Format String  ${ZOOM_url}  ${MUSERNAME15}
    Set Suite Variable   ${ZOOM_id0}

    ${instructions1}=   FakerLibrary.sentence
    ${instructions2}=   FakerLibrary.sentence

    ${resp}=  Update Virtual Calling Mode   ${CallingModes[0]}  ${ZOOM_id0}   ACTIVE  ${instructions1}   ${CallingModes[1]}  ${MUSERNAME15}   ACTIVE   ${instructions2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Get Virtual Calling Mode
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[0]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${ZOOM_id0}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${instructions1}

    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['callingMode']}     ${CallingModes[1]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['value']}           ${MUSERNAME15}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['instructions']}    ${instructions2}

    ${PUSERPH_id0}=  Evaluate  ${MUSERNAME15}+10101
    ${ZOOM_Pid0}=  Format String  ${ZOOM_url}  ${PUSERPH_id0}
    Set Suite Variable   ${ZOOM_Pid0}


    Set Test Variable  ${callingMode1}     ${CallingModes[0]}
    Set Test Variable  ${ModeId1}          ${ZOOM_Pid0}
    Set Test Variable  ${ModeStatus1}      ACTIVE
    ${Description1}=    FakerLibrary.sentence
    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Description1}
    ${virtualCallingModes}=  Create List  ${VirtualcallingMode1}
    
        
    ${amt_V1}=   Random Int   min=100   max=500
    ${min_pre_V1}=   Random Int   min=10   max=50
    ${min_pre1_V1}=  Convert To Number  ${min_pre_V1}  1
    ${totalamt_V1}=  Convert To Number  ${amt_V1}  1
    ${balamount_V1}=  Evaluate  ${totalamt_V1}-${min_pre1_V1}
    ${pre_float2_V1}=  twodigitfloat  ${min_pre1_V1}
    ${pre_float1_V1}=  Convert To Number  ${min_pre1_V1}  1
    ${description}=    FakerLibrary.word

    Set Suite Variable  ${amt_V1}
    Set Suite Variable  ${min_pre_V1}
    Set Suite Variable  ${min_pre1_V1}
    Set Suite Variable  ${totalamt_V1}
    Set Suite Variable  ${balamount_V1}
    Set Suite Variable  ${pre_float2_V1}
    Set Suite Variable  ${pre_float1_V1}

    Set Test Variable  ${vstype}  ${vservicetype[1]}
    ${resp}=  Create Virtual Service For User  ${SERVICE4}   ${description}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre1_V1}  ${totalamt_V1}  ${bool[1]}   ${bool[0]}   ${vstype}   ${virtualCallingModes}  ${dep_id}  ${u_id32}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${VS_id1}  ${resp.json()} 
    ${resp}=   Get Service By Id  ${VS_id1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Verify Response  ${resp}  name=${SERVICE4}  description=${description}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre1_V1}  totalAmount=${totalamt_V1}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}  serviceType=virtualService   virtualServiceType=${vstype}
        
    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}
    ${DAY2}=  add_date  10      
    Set Suite Variable  ${DAY2}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    ${sTime1}=  db.get_time
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_time   2  00
    Set Suite Variable   ${eTime1}
    ${lid}=  Create Sample Location
    Set Suite Variable  ${lid}
    ${description2}=  FakerLibrary.sentence
    ${dur2}=  FakerLibrary.Random Int  min=10  max=20
    ${amt2}=  FakerLibrary.Random Int  min=200  max=500
    ${min2_pre1}=  FakerLibrary.Random Int  min=200  max=${amt2}
    Set Suite Variable  ${min2_pre1}
    ${totalamt2}=  Convert To Number  ${amt2}  1
    Set Suite Variable  ${totalamt2}
    ${balamount2}=  Evaluate  ${totalamt2}-${min2_pre1}
    Set Suite Variable  ${balamount2}
    ${pre2_float2}=  twodigitfloat  ${min2_pre1}
    Set Suite Variable  ${pre2_float2}
    ${pre2_float1}=  Convert To Number  ${min2_pre1}  1
    Set Suite Variable  ${pre2_float1}

    ${resp}=  Create Service For User  ${SERVICE3}  ${description}   10  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  ${min2_pre1}  ${totalamt2}  ${bool[1]}  ${bool[0]}  ${dep_id}  ${u_id32}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${NS_id1}  ${resp.json()}

    
    ${resp}=  Get Accountsettings  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    waitlist=${bool[1]}   appointment=${bool[1]}   
    ${DAY1}=  get_date
    # Set Suite Variable  ${DAY1}
    ${DAY2}=  add_date  10      
    # Set Suite Variable  ${DAY2}
    ${list}=  Create List  1  2  3  4  5  6  7
    # Set Suite Variable  ${list}
    ${sTime1}=  subtract_time  0  30
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_time   1  30
    Set Suite Variable   ${eTime1}
    ${TODAY} =	Convert Date	${DAY1}	result_format=%d/%m/%Y
    Set Suite Variable  ${TODAY}
    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}
    ${schedule_name01}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name01}
    ${bool1}=  Random Element  ${bool}
    ${noOfOccurance}=  Random Int  min=5  max=15
    ${resp}=  Create Appointment Schedule For User  ${u_id32}  ${schedule_name01}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${noOfOccurance}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${service_duration[0]}  ${bool1}   ${VS_id1}   ${NS_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id01}  ${resp.json()}
    

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${uname}  ${resp.json()['userName']}
    Set Test Variable  ${cid01}  ${resp.json()['id']}
    ${JC_id01}=  get_id  ${CUSERNAME1} 
    

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id01}   ${pid_B15}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${num_slots}=  Get Length  ${slots}
    ${p}=  Random Int  max=${num_slots-1}
    Set Suite Variable   ${slot1}   ${slots[${p}]}

    ${q}=  Random Int  max=${num_slots-2}
    Set Test Variable   ${slot2}   ${slots[${q}]}

    
    ${pcid1}=  get_id  ${CUSERNAME1}
    ${appt_for1}=  Create Dictionary  id=${pcid1}   apptTime=${slot1}  
    ${apptfor1}=   Create List  ${appt_for1}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For User    ${pid_B15}  ${NS_id1}  ${sch_id01}  ${DAY1}  ${cnote}  ${u_id32}   ${apptfor1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid01}  ${apptid[0]}
    # sleep  02s 

    ${resp}=   Get consumer Appointment By Id   ${pid_B15}  ${apptid01}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid01}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${JC_id01}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${NS_id1}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id01}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${appt_status[0]}
    # Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['id']}   ${cid01}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['appmtTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}
    Set Suite Variable  ${jid_c01}   ${resp.json()['appmtFor'][0]['memberJaldeeId']}
    Set Suite Variable  ${encId01_usr}   ${resp.json()['appointmentEncId']}

    ${resp}=  Provider Login  ${MUSERNAME15}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid01}  ${resp.json()[0]['id']}

    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${reportType}              APPOINTMENT
    Set Test Variable  ${reportDateCategory1}      TODAY
    ${filter1}=  Create Dictionary   apptForId-eq=${jid_c01}
           
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  reportType=${Report_Types[1]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    Set Suite Variable  ${ReportId_c17_1}      ${resp.json()['reportRequestId']}
    Should Be Equal As Strings  ${jid_c01}   ${resp.json()['reportContent']['reportHeader']['Customer id']}
    Should Be Equal As Strings  Today       ${resp.json()['reportContent']['reportHeader']['Time Period']}
    Should Be Equal As Strings  Appointment Report         ${resp.json()['reportContent']['reportName']}
    Should Be Equal As Strings  0                    ${resp.json()['reportContent']['count']}
    Should Be Equal As Strings  ${DAY1}               ${resp.json()['reportContent']['date']}
    Should Be Equal As Strings  ${EMPTY_List}               ${resp.json()['reportContent']['data']}  # Data
        

JD-TC-Verify-1-Appointment_Report-8
    [Documentation]  Appointment Report after completing prepayment of a Physical service
    resetsystem_time
    ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    # ${resp}=  Make payment Consumer  ${min2_pre1}  ${payment_modes[2]}  ${apptid01}  ${pid_B15}  ${purpose[0]}  ${cid01}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Contain  ${resp.json()['response']}  <td><input name=\"amount\" value=${pre2_float2} /></td>
    # Should Contain  ${resp.json()['response']}  <td><input name=\"email\" id=\"email\" value=${CUSEREMAIL1} /></td>
    # Should Contain  ${resp.json()['response']}  <td>Phone: </td>\n   <td><input name=\"phone\" value=${CUSERNAME1} ></td>

    ${resp}=  Make payment Consumer Mock  ${min2_pre1}  ${bool[1]}  ${apptid01}  ${pid_B15}  ${purpose[0]}  ${cid01}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${mer}   ${resp.json()['merchantId']}  
    Set Suite Variable   ${payref}   ${resp.json()['paymentRefId']}
    sleep  02s
    ${resp}=  Get Payment Details  account-eq=${pid_B15}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['amount']}   ${pre2_float1}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}   ${pid_B15}
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}   ${payment_modes[5]}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}   ${apptid01}
    Should Be Equal As Strings  ${resp.json()[0]['paymentRefId']}   ${payref} 
    Should Be Equal As Strings  ${resp.json()[0]['paymentPurpose']}   ${purpose[0]}

        
    ${resp}=  Get Bill By consumer  ${apptid01}  ${pid_B15}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${apptid01}  netTotal=${totalamt2}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${totalamt2}  billPaymentStatus=${paymentStatus[1]}  totalAmountPaid=${pre2_float1}  amountDue=${balamount2}

    ${resp}=  Provider Login  ${MUSERNAME15}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${reportType}             APPOINTMENT
    Set Test Variable  ${reportDateCategory1}    TODAY
    ${filter}=  Create Dictionary   apptForId-eq=${jid_c01}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  reportType=${Report_Types[1]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    Set Suite Variable  ${ReportId_c01_2}      ${resp.json()['reportRequestId']}
    Should Be Equal As Strings  ${jid_c01}   ${resp.json()['reportContent']['reportHeader']['Customer id']}
    Should Be Equal As Strings  Today       ${resp.json()['reportContent']['reportHeader']['Time Period']}
    Should Be Equal As Strings  Appointment Report         ${resp.json()['reportContent']['reportName']}
    Should Be Equal As Strings  1                    ${resp.json()['reportContent']['count']}
        
    Should Be Equal As Strings  ${DAY1}               ${resp.json()['reportContent']['date']}
    Should Be Equal As Strings  ${TODAY}               ${resp.json()['reportContent']['data'][0]['1']}  # Date
    Should Be Equal As Strings  ${jid_c01}             ${resp.json()['reportContent']['data'][0]['2']}  # CustomerId
    Should Be Equal As Strings  ${schedule_name01}        ${resp.json()['reportContent']['data'][0]['5']}  # Service
    Should Be Equal As Strings  ${SERVICE3}        ${resp.json()['reportContent']['data'][0]['6']}  # Service
    Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][0]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][0]['9']}  # Mode
    Should Be Equal As Strings  ${paymentStatusReport[1]}   ${resp.json()['reportContent']['data'][0]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_id01-2}     ${resp.json()['reportContent']['data'][0]['7']}  # ConfirmationId

    ${LAST_WEEK8_DAY1}=  get_date
    Set Suite Variable  ${LAST_WEEK8_DAY1} 
    ${LAST_WEEK8_DAY7}=  add_date  6
    Set Suite Variable  ${LAST_WEEK8_DAY7}


    change_system_date   7
    ${resp}=  Provider Login  ${MUSERNAME15}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    sleep   02s

    Set Test Variable  ${reportDateCategory1}    LAST_WEEK
    ${filter}=  Create Dictionary   apptForId-eq=${jid_c01}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  reportType=${Report_Types[1]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    Set Suite Variable  ${ReportId_c01_2}      ${resp.json()['reportRequestId']}
    Should Be Equal As Strings  ${jid_c01}   ${resp.json()['reportContent']['reportHeader']['Customer id']}
    Should Be Equal As Strings  Last 7 days        ${resp.json()['reportContent']['reportHeader']['Time Period']}
    Should Be Equal As Strings  Appointment Report         ${resp.json()['reportContent']['reportName']}
    Should Be Equal As Strings  1                    ${resp.json()['reportContent']['count']}
        
    Should Be Equal As Strings  ${LAST_WEEK8_DAY1}               ${resp.json()['reportContent']['from']}
    Should Be Equal As Strings  ${LAST_WEEK8_DAY7}               ${resp.json()['reportContent']['to']}
    Should Be Equal As Strings  ${TODAY}               ${resp.json()['reportContent']['data'][0]['1']}  # Date
    Should Be Equal As Strings  ${jid_c01}             ${resp.json()['reportContent']['data'][0]['2']}  # CustomerId
    Should Be Equal As Strings  ${schedule_name01}        ${resp.json()['reportContent']['data'][0]['5']}  # Service
    Should Be Equal As Strings  ${SERVICE3}        ${resp.json()['reportContent']['data'][0]['6']}  # Service
    Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][0]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][0]['9']}  # Mode
    Should Be Equal As Strings  ${paymentStatusReport[1]}   ${resp.json()['reportContent']['data'][0]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_id01-2}     ${resp.json()['reportContent']['data'][0]['7']}  # ConfirmationId

    resetsystem_time


JD-TC-Verify-2-Appointment_Report-8
    [Documentation]  Appointment Report When cancel Appointment after completing prepayment of a Physical service 
    resetsystem_time
    ${resp}=  Provider Login  ${MUSERNAME15}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
        
    ${reason}=  Random Element  ${cancelReason}
    ${msg}=   FakerLibrary.word
    ${resp}=    Provider Cancel Appointment  ${apptid01}  ${reason}  ${msg}  ${DAY1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  05s
        # ${resp}=  Get Appointment Status   ${apptid01}
        # Log   ${resp.json()}
        # Should Be Equal As Strings  ${resp.status_code}  200
        # Should Be Equal As Strings  ${resp.json()[1]['appointmentStatus']}   ${apptStatus[4]}

    ${resp}=  Get Bill By UUId  ${apptid01}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${apptid01}
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}  ${paymentStatus[3]} 

    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${reportType}             APPOINTMENT
    Set Test Variable  ${reportDateCategory1}    TODAY
    ${filter}=  Create Dictionary   apptForId-eq=${jid_c01}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  reportType=${Report_Types[1]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    Set Suite Variable  ${ReportId_c17_3}      ${resp.json()['reportRequestId']}
    Should Be Equal As Strings  ${jid_c01}   ${resp.json()['reportContent']['reportHeader']['Customer id']}
    Should Be Equal As Strings  Today       ${resp.json()['reportContent']['reportHeader']['Time Period']}
    Should Be Equal As Strings  Appointment Report         ${resp.json()['reportContent']['reportName']}
    Should Be Equal As Strings  1                    ${resp.json()['reportContent']['count']}
    Should Be Equal As Strings  ${DAY1}               ${resp.json()['reportContent']['date']}
    Should Be Equal As Strings  ${TODAY}               ${resp.json()['reportContent']['data'][0]['1']}  # Date
    Should Be Equal As Strings  ${jid_c01}             ${resp.json()['reportContent']['data'][0]['2']}  # CustomerId
    Should Be Equal As Strings  ${schedule_name01}        ${resp.json()['reportContent']['data'][0]['5']}  # Service
    Should Be Equal As Strings  ${SERVICE3}        ${resp.json()['reportContent']['data'][0]['6']}  # Service
    Should Be Equal As Strings  ${apptStatus[4]}   ${resp.json()['reportContent']['data'][0]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][0]['9']}  # Mode
    Should Be Equal As Strings  ${paymentStatusReport[3]}  ${resp.json()['reportContent']['data'][0]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_id01-2}     ${resp.json()['reportContent']['data'][0]['7']}  # ConfirmationId

    change_system_date   7
    ${resp}=  Provider Login  ${MUSERNAME15}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Set Test Variable  ${reportDateCategory1}    LAST_WEEK
    ${filter}=  Create Dictionary   apptForId-eq=${jid_c01}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  reportType=${Report_Types[1]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    Set Suite Variable  ${ReportId_c01_2}      ${resp.json()['reportRequestId']}
    Should Be Equal As Strings  ${jid_c01}   ${resp.json()['reportContent']['reportHeader']['Customer id']}
    Should Be Equal As Strings  Last 7 days        ${resp.json()['reportContent']['reportHeader']['Time Period']}
    Should Be Equal As Strings  Appointment Report         ${resp.json()['reportContent']['reportName']}
    Should Be Equal As Strings  1                    ${resp.json()['reportContent']['count']}
        
    Should Be Equal As Strings  ${LAST_WEEK8_DAY1}               ${resp.json()['reportContent']['from']}
    Should Be Equal As Strings  ${LAST_WEEK8_DAY7}               ${resp.json()['reportContent']['to']}
    Should Be Equal As Strings  ${TODAY}               ${resp.json()['reportContent']['data'][0]['1']}  # Date
    Should Be Equal As Strings  ${jid_c01}             ${resp.json()['reportContent']['data'][0]['2']}  # CustomerId
    Should Be Equal As Strings  ${schedule_name01}        ${resp.json()['reportContent']['data'][0]['5']}  # Service
    Should Be Equal As Strings  ${SERVICE3}        ${resp.json()['reportContent']['data'][0]['6']}  # Service
    Should Be Equal As Strings  ${apptStatus[4]}   ${resp.json()['reportContent']['data'][0]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][0]['9']}  # Mode
    Should Be Equal As Strings  ${paymentStatusReport[3]}  ${resp.json()['reportContent']['data'][0]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_id01-2}     ${resp.json()['reportContent']['data'][0]['7']}  # ConfirmationId

    resetsystem_time


JD-TC-Appointment_Report-9
    [Documentation]  Appointment Report before completing prepayment of a Virtual service 
    resetsystem_time
    ${resp}=  Provider Login  ${MUSERNAME15}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  AddCustomer  ${CUSERNAME3}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # # Set Suite Variable  ${cid01}  ${resp.json()}

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME3}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${cid03}  ${resp.json()[0]['id']}
    # Set Suite Variable  ${jid_c03}  ${resp.json()[0]['jaldeeId']}


    ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${uname}  ${resp.json()['userName']}
    ${JC_id03}=  get_id  ${CUSERNAME3} 
    
    ${fname_fid03}=  FakerLibrary.first_name
    Set Suite Variable  ${fname_fid03}
    ${lname_fid03}=  FakerLibrary.last_name
    Set Suite Variable  ${lname_fid03}
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMember   ${fname_fid03}  ${lname_fid03}  ${dob}  ${gender}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${fid03_name}   ${fname_fid03} ${lname_fid03} 
    Set Suite Variable  ${fid_c03}   ${resp.json()}

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id01}   ${pid_B15}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${num_slots}=  Get Length  ${slots}
    ${p}=  Random Int  max=${num_slots-1}
    Set Suite Variable   ${slot15_1}   ${slots[${p}]}

    ${q}=  Random Int  max=${num_slots-2}
    Set Test Variable   ${slot15_3}   ${slots[${q}]}

    
    
    ${cnote}=   FakerLibrary.name
    ${apptfor1}=  Create Dictionary  id=${fid_c03}   apptTime=${slot15_3}   firstName=${fname_fid03}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Virtual Service Appointment For User   ${pid_B15}  ${VS_id1}  ${sch_id01}  ${DAY1}  ${cnote}  ${CallingModes[0]}  ${ZOOM_Pid2}   ${u_id32}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid03}  ${apptid[0]}
    # sleep  02s 

    ${resp}=   Get consumer Appointment By Id   ${pid_B15}  ${apptid03}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid03}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${JC_id03}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${VS_id1}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id01}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${appt_status[0]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot15_3}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['appmtTime']}   ${slot15_3}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}
    Set Suite Variable   ${jid_c03}  ${resp.json()['appmtFor'][0]['memberJaldeeId']}
    Set Suite Variable  ${encId03_usr}   ${resp.json()['appointmentEncId']}

    ${resp}=  Provider Login  ${MUSERNAME15}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid03}  ${resp.json()[0]['id']}

    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${reportType}              APPOINTMENT
    Set Test Variable  ${reportDateCategory1}      TODAY
    # ${filter1}=  Create Dictionary   queue-eq=${que_id32}
    ${filter1}=  Create Dictionary   apptForId-eq=${jid_c03}
           
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  reportType=${Report_Types[1]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    # Verify Response  ${resp}  reportType=${Report_Types[0]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    Set Suite Variable  ${ReportId_c17_1}      ${resp.json()['reportRequestId']}
    Should Be Equal As Strings  ${jid_c03}   ${resp.json()['reportContent']['reportHeader']['Customer id']}
    Should Be Equal As Strings  Today       ${resp.json()['reportContent']['reportHeader']['Time Period']}
    Should Be Equal As Strings  Appointment Report         ${resp.json()['reportContent']['reportName']}
    Should Be Equal As Strings  0                    ${resp.json()['reportContent']['count']}
    Should Be Equal As Strings  ${DAY1}               ${resp.json()['reportContent']['date']}
    Should Be Equal As Strings  ${EMPTY_List}               ${resp.json()['reportContent']['data']}  # Data
        

    
JD-TC-Verify-1-Appointment_Report-9
    [Documentation]  Appointment Report after completing prepayment of a Virtual service
    resetsystem_time
    ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    # ${resp}=  Make payment Consumer  ${min_pre1_V1}  ${payment_modes[2]}  ${apptid03}  ${pid_B15}  ${purpose[0]}  ${cid03}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Contain  ${resp.json()['response']}  <td><input name=\"amount\" value=${pre_float2_V1} /></td>
    # Should Contain  ${resp.json()['response']}  <td><input name=\"email\" id=\"email\" value=${CUSEREMAIL3} /></td>
    # Should Contain  ${resp.json()['response']}  <td>Phone: </td>\n   <td><input name=\"phone\" value=${CUSERNAME3} ></td>

    ${resp}=  Make payment Consumer Mock  ${min_pre1_V1}  ${bool[1]}  ${apptid03}  ${pid_B15}  ${purpose[0]}  ${cid03}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${mer}   ${resp.json()['merchantId']}  
    Set Suite Variable   ${payref}   ${resp.json()['paymentRefId']}
    sleep  02s
    ${resp}=  Get Payment Details  account-eq=${pid_B15}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['amount']}   ${pre_float1_V1}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}   ${pid_B15}
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}   ${payment_modes[5]}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}   ${apptid03}
    Should Be Equal As Strings  ${resp.json()[0]['paymentRefId']}   ${payref} 
    Should Be Equal As Strings  ${resp.json()[0]['paymentPurpose']}   ${purpose[0]}

    ${resp}=  Get Bill By consumer  ${apptid03}  ${pid_B15}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${apptid03}  netTotal=${totalamt_V1}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${totalamt_V1}  billPaymentStatus=${paymentStatus[1]}  totalAmountPaid=${pre_float1_V1}  amountDue=${balamount_V1}

    

    ${resp}=  Provider Login  ${MUSERNAME15}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${reportType}              APPOINTMENT
    Set Test Variable  ${reportDateCategory1}      TODAY
    ${filter}=  Create Dictionary   apptForId-eq=${jid_c03}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  reportType=${Report_Types[1]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    Set Suite Variable  ${ReportId_c17_2}      ${resp.json()['reportRequestId']}
    Should Be Equal As Strings  ${jid_c03}   ${resp.json()['reportContent']['reportHeader']['Customer id']}
    Should Be Equal As Strings  Today       ${resp.json()['reportContent']['reportHeader']['Time Period']}
    Should Be Equal As Strings  Appointment Report         ${resp.json()['reportContent']['reportName']}
    Should Be Equal As Strings  1                    ${resp.json()['reportContent']['count']}
    Should Be Equal As Strings  ${DAY1}               ${resp.json()['reportContent']['date']}
    Should Be Equal As Strings  ${TODAY}               ${resp.json()['reportContent']['data'][0]['1']}  # Date
    Should Be Equal As Strings  ${jid_c03}             ${resp.json()['reportContent']['data'][0]['2']}  # CustomerId
    Should Be Equal As Strings  ${schedule_name01}        ${resp.json()['reportContent']['data'][0]['5']}  # Service
    Should Be Equal As Strings  ${SERVICE4}        ${resp.json()['reportContent']['data'][0]['6']}  # Service
    Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][0]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][0]['9']}  # Mode
    Should Be Equal As Strings  ${paymentStatusReport[1]}  ${resp.json()['reportContent']['data'][0]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_id01-2}     ${resp.json()['reportContent']['data'][0]['7']}  # ConfirmationId

    change_system_date   7
    ${resp}=  Provider Login  ${MUSERNAME15}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Set Test Variable  ${reportDateCategory1}    LAST_WEEK
    ${filter}=  Create Dictionary   apptForId-eq=${jid_c03}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  reportType=${Report_Types[1]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    Set Suite Variable  ${ReportId_c17_2}      ${resp.json()['reportRequestId']}
    Should Be Equal As Strings  ${jid_c03}   ${resp.json()['reportContent']['reportHeader']['Customer id']}
    Should Be Equal As Strings  Last 7 days        ${resp.json()['reportContent']['reportHeader']['Time Period']}
    Should Be Equal As Strings  Appointment Report         ${resp.json()['reportContent']['reportName']}
    Should Be Equal As Strings  1                    ${resp.json()['reportContent']['count']}
        
    Should Be Equal As Strings  ${LAST_WEEK8_DAY1}               ${resp.json()['reportContent']['from']}
    Should Be Equal As Strings  ${LAST_WEEK8_DAY7}               ${resp.json()['reportContent']['to']}
    Should Be Equal As Strings  ${TODAY}               ${resp.json()['reportContent']['data'][0]['1']}  # Date
    Should Be Equal As Strings  ${jid_c03}             ${resp.json()['reportContent']['data'][0]['2']}  # CustomerId
    Should Be Equal As Strings  ${schedule_name01}        ${resp.json()['reportContent']['data'][0]['5']}  # Service
    Should Be Equal As Strings  ${SERVICE4}        ${resp.json()['reportContent']['data'][0]['6']}  # Service
    Should Be Equal As Strings  ${apptStatus[1]}   ${resp.json()['reportContent']['data'][0]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][0]['9']}  # Mode
    Should Be Equal As Strings  ${paymentStatusReport[1]}  ${resp.json()['reportContent']['data'][0]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_id01-2}     ${resp.json()['reportContent']['data'][0]['7']}  # ConfirmationId

    resetsystem_time



JD-TC-Verify-2-Appointment_Report-9
    [Documentation]  Appointment report When cancel Appointment after completing prepayment of a Virtual service 
    resetsystem_time
    ${resp}=  Provider Login  ${MUSERNAME15}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
        
    ${reason}=  Random Element  ${cancelReason}
    ${msg}=   FakerLibrary.word
    ${resp}=    Provider Cancel Appointment  ${apptid03}  ${reason}  ${msg}  ${DAY1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  02s
        
    ${resp}=  Get Bill By UUId  ${apptid03}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${apptid03}
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}  ${paymentStatus[3]}


    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${reportType}             APPOINTMENT
    Set Test Variable  ${reportDateCategory1}    TODAY
    ${filter}=  Create Dictionary   apptForId-eq=${jid_c03}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  reportType=${Report_Types[1]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    Set Suite Variable  ${ReportId_c17_3}      ${resp.json()['reportRequestId']}
    Should Be Equal As Strings  ${jid_c03}   ${resp.json()['reportContent']['reportHeader']['Customer id']}
    Should Be Equal As Strings  Today       ${resp.json()['reportContent']['reportHeader']['Time Period']}
    Should Be Equal As Strings  Appointment Report         ${resp.json()['reportContent']['reportName']}
    Should Be Equal As Strings  1                    ${resp.json()['reportContent']['count']}
    Should Be Equal As Strings  ${DAY1}               ${resp.json()['reportContent']['date']}
    Should Be Equal As Strings  ${TODAY}               ${resp.json()['reportContent']['data'][0]['1']}  # Date
    Should Be Equal As Strings  ${jid_c03}             ${resp.json()['reportContent']['data'][0]['2']}  # CustomerId
    Should Be Equal As Strings  ${schedule_name01}        ${resp.json()['reportContent']['data'][0]['5']}  # Service
    Should Be Equal As Strings  ${SERVICE4}        ${resp.json()['reportContent']['data'][0]['6']}  # Service
    Should Be Equal As Strings  ${apptStatus[4]}   ${resp.json()['reportContent']['data'][0]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][0]['9']}  # Mode
    Should Be Equal As Strings  Refund  ${resp.json()['reportContent']['data'][0]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_id01-2}     ${resp.json()['reportContent']['data'][0]['7']}  # ConfirmationId


    change_system_date   7
    ${resp}=  Provider Login  ${MUSERNAME15}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Set Test Variable  ${reportDateCategory1}    LAST_WEEK
    ${filter}=  Create Dictionary   apptForId-eq=${jid_c03}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  reportType=${Report_Types[1]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    Set Suite Variable  ${ReportId_c17_2}      ${resp.json()['reportRequestId']}
    Should Be Equal As Strings  ${jid_c03}   ${resp.json()['reportContent']['reportHeader']['Customer id']}
    Should Be Equal As Strings  Last 7 days        ${resp.json()['reportContent']['reportHeader']['Time Period']}
    Should Be Equal As Strings  Appointment Report         ${resp.json()['reportContent']['reportName']}
    Should Be Equal As Strings  1                    ${resp.json()['reportContent']['count']}
        
    Should Be Equal As Strings  ${LAST_WEEK8_DAY1}               ${resp.json()['reportContent']['from']}
    Should Be Equal As Strings  ${LAST_WEEK8_DAY7}               ${resp.json()['reportContent']['to']}
    Should Be Equal As Strings  ${TODAY}               ${resp.json()['reportContent']['data'][0]['1']}  # Date
    Should Be Equal As Strings  ${jid_c03}             ${resp.json()['reportContent']['data'][0]['2']}  # CustomerId
    Should Be Equal As Strings  ${schedule_name01}        ${resp.json()['reportContent']['data'][0]['5']}  # Service
    Should Be Equal As Strings  ${SERVICE4}        ${resp.json()['reportContent']['data'][0]['6']}  # Service
    Should Be Equal As Strings  ${apptStatus[4]}   ${resp.json()['reportContent']['data'][0]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][0]['9']}  # Mode
    Should Be Equal As Strings  Refund  ${resp.json()['reportContent']['data'][0]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_id01-2}     ${resp.json()['reportContent']['data'][0]['7']}  # ConfirmationId

    resetsystem_time


  

  