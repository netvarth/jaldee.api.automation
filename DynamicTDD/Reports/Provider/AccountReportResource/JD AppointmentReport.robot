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
@{Statuses}    NEW    INPROGRESS   CANCELED    FALIED    PDFUPLOADED     SEEN
@{EMPTY_List}

@{dom_list}
@{provider_list}
@{multiloc_providers}
@{multiloc_billable_providers}

*** Test Cases ***

JD-TC-Appointment_Report-1

    [Documentation]  Generate current_day Appointment_report of a provider 

    ${resp}=  ProviderLogin  ${PUSERNAME30}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${pid}=  get_acc_id  ${PUSERNAME30}
    Set Suite Variable  ${pid}
    Set Test Variable   ${lic_id}   ${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}
    Set Test Variable   ${lic_name}   ${resp.json()['accountLicenseDetails']['accountLicense']['name']}


    # ${highest_package}=  get_highest_license_pkg
    # Log  ${highest_package}
    # Set Suite variable  ${lic2}  ${highest_package[0]}

    # ${resp}=   Change License Package  ${highest_package[0]}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}   200

    ${highest_package}=  get_highest_license_pkg
    Log  ${highest_package}
    Set Suite variable  ${lic2}  ${highest_package[0]}

    ${resp}=   Run Keyword If  '${lic_id}' != '${lic2}'  Change License Package  ${highest_package[0]}
    Run Keyword If   '${resp}' != '${None}'  Log  ${resp.json()}
    Run Keyword If   '${resp}' != '${None}'  Should Be Equal As Strings  ${resp.status_code}  200


    ${duration}=   Random Int  min=2  max=10
    Set Suite Variable   ${duration}
    
    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}   ${duration}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${Empty}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  View Waitlist Settings
    # Verify Response  ${resp}  calculationMode=${calc_mode[1]}  trnArndTime=${duration}  futureDateWaitlist=${bool[1]}  showTokenId=${bool[1]}  onlineCheckIns=${bool[1]}  maxPartySize=1
    
    clear_queue     ${PUSERNAME30}
    clear_service   ${PUSERNAME30}
    clear_appt_schedule   ${PUSERNAME30}

    
    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}
    ${DAY2}=  add_date  55
    Set Suite Variable  ${DAY2}
    ${description}=     FakerLibrary.sentence
    Set Suite Variable   ${description}
    ${firstname1}=  FakerLibrary.first_name
    Set Test Variable  ${firstname1}
    set Suite Variable  ${email}  ${firstname1}${CUSERNAME6}${C_Email}.ynwtest@netvarth.com

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


    ${sTime1}=  add_time  0  00
    ${eTime1}=  add_time   4  30
    ${p1queue1}=    FakerLibrary.word

    ${resp}=  Get Locations
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_l1}  ${resp.json()[0]['id']}


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

    ${resp}=  Consumer Login  ${CUSERNAME6}  ${PASSWORD}
    Log  ${resp.content}
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
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
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
   
    ${TODAY}=  get_date
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

    ${resp}=  ProviderLogin  ${PUSERNAME30}  ${PASSWORD}
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

    ${resp}=  Consumer Login  ${CUSERNAME6}  ${PASSWORD}
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


    ${Add_DAY1}=  add_date  1
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


    ${Add_DAY2}=  add_date  2
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

    ${Add_DAY3}=  add_date  3
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

    ${Add_DAY4}=  add_date  4
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


    ${Add_DAY5}=  add_date  5
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

    ${Add_DAY6}=  add_date  6
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


    ${Add_DAY7}=  add_date  7
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


    ${Add_DAY8}=  add_date  8
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


    ${Add_DAY15}=  add_date  15
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


    ${Add_DAY20}=  add_date  20
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


    ${Add_DAY25}=  add_date  25
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


    ${Add_DAY30}=  add_date  30
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


    ${Add_DAY31}=  add_date  31
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


    ${Add_DAY36}=  add_date  36
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


    ${Add_DAY40}=  add_date  40
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


    ${Add_DAY45}=  add_date  45
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


    ${Add_DAY50}=  add_date  50
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
    
    ${resp}=  ProviderLogin  ${PUSERNAME30}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    # Set Suite Variable  ${C6_name}   ${cid6_fname} ${cid6_lname}
    # Set Suite Variable  ${fid1_name}   ${family_fname} ${family_lname}
    # Set Suite Variable  ${fid2_name}   ${fid2_fname} ${fid2_lname}

    sleep  4s
    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${reportType}              APPOINTMENT
    Set Test Variable  ${reportDateCategory}      TODAY

    ${filter}=  Create Dictionary   apptForId-eq=${EMPTY}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${token_id1}   ${resp.json()}
    sleep  1s
    ${resp}=  Get Report Status By Token Id  ${token_id1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}  0

    ${filter3}=  Create Dictionary   apptForId-eq=${jid_c6},${jid_c6_f1},${jid_c6_f2}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${token_id2}   ${resp.json()}
    # sleep  05s
    ${resp}=  Get Report Status By Token Id  ${token_id2}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}  10
    # Verify Response  ${resp}  reportType=${Report_Types[1]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    # Set Suite Variable  ${RqId_c6_1}      ${resp.json()['reportRequestId']}
    # # Should Be Equal As Strings  ${jid_c6},${jid_c6_f1},${jid_c6_f2}   ${resp.json()['reportContent']['reportHeader']['Customer id']}
    # Should Be Equal As Strings  Today       ${resp.json()['reportContent']['reportHeader']['Time Period']}
    # Should Be Equal As Strings  Appointment Report         ${resp.json()['reportContent']['reportName']}
    # Should Be Equal As Strings  10                    ${resp.json()['reportContent']['count']}
    # Should Be Equal As Strings  ${TODAY}               ${resp.json()['reportContent']['date']}
    # Should Be Equal As Strings  ${TODAY_Slot1}               ${resp.json()['reportContent']['data'][0]['1']}  # Date
    # Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][0]['2']}  # CustomerId
    # Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][0]['3']}  # CustomerName
    # Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][0]['5']}  # Service
    # Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][0]['6']}  # Service
    # Should Be Equal As Strings  Completed   ${resp.json()['reportContent']['data'][0]['8']}  # Status
    # Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][0]['9']}  # Mode
    # Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][0]['10']}  # PaymentStatus
    # Set Suite Variable  ${conf_id101}     ${resp.json()['reportContent']['data'][0]['7']}  # ConfirmationId

    # Should Be Equal As Strings  ${TODAY_Slot2}               ${resp.json()['reportContent']['data'][1]['1']}  # Date
    # Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][1]['2']}  # CustomerId
    # Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][1]['3']}  # CustomerName
    # Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][1]['5']}  # Service
    # Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][1]['6']}  # Service
    # Should Be Equal As Strings  Cancelled   ${resp.json()['reportContent']['data'][1]['8']}  # Status
    # Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][1]['9']}  # Mode
    # Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][1]['10']}  # PaymentStatus
    # Set Suite Variable  ${conf_id102}     ${resp.json()['reportContent']['data'][1]['7']}  # ConfirmationId

    # Should Be Equal As Strings  ${TODAY_Slot3}               ${resp.json()['reportContent']['data'][2]['1']}  # Date
    # Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][2]['2']}  # CustomerId
    # Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][2]['3']}  # CustomerName
    # Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][2]['5']}  # Service
    # Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][2]['6']}  # Service
    # Should Be Equal As Strings  Cancelled   ${resp.json()['reportContent']['data'][2]['8']}  # Status
    # Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][2]['9']}  # Mode
    # Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][2]['10']}  # PaymentStatus
    # Set Suite Variable  ${conf_id103}     ${resp.json()['reportContent']['data'][2]['7']}  # ConfirmationId

    # Should Be Equal As Strings  ${TODAY_Slot4}               ${resp.json()['reportContent']['data'][3]['1']}  # Date
    # Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][3]['2']}  # CustomerId
    # Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][3]['3']}  # CustomerName
    # Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][3]['5']}  # Service
    # Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][3]['6']}  # Service
    # Should Be Equal As Strings  Completed   ${resp.json()['reportContent']['data'][3]['8']}  # Status
    # Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][3]['9']}  # Mode
    # Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][3]['10']}  # PaymentStatus
    # Set Suite Variable  ${conf_id104}     ${resp.json()['reportContent']['data'][3]['7']}  # ConfirmationId

    # Should Be Equal As Strings  ${TODAY_Slot5}               ${resp.json()['reportContent']['data'][4]['1']}  # Date
    # Should Be Equal As Strings  ${jid_c6_f2}             ${resp.json()['reportContent']['data'][4]['2']}  # CustomerId
    # Should Be Equal As Strings  ${fid2_name}          ${resp.json()['reportContent']['data'][4]['3']}  # CustomerName
    # Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][4]['5']}  # Service
    # Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][4]['6']}  # Service
    # Should Be Equal As Strings  Rejected   ${resp.json()['reportContent']['data'][4]['8']}  # Status
    # Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][4]['9']}  # Mode
    # Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][4]['10']}  # PaymentStatus
    # Set Suite Variable  ${conf_id105}     ${resp.json()['reportContent']['data'][4]['7']}  # ConfirmationId

    # Should Be Equal As Strings  ${TODAY_Slot6}               ${resp.json()['reportContent']['data'][5]['1']}  # Date
    # Should Be Equal As Strings  ${jid_c6_f2}             ${resp.json()['reportContent']['data'][5]['2']}  # CustomerId
    # Should Be Equal As Strings  ${fid2_name}          ${resp.json()['reportContent']['data'][5]['3']}  # CustomerName
    # Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][5]['5']}  # Service
    # Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][5]['6']}  # Service
    # Should Be Equal As Strings  Rejected   ${resp.json()['reportContent']['data'][5]['8']}  # Status
    # Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][5]['9']}  # Mode
    # Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][5]['10']}  # PaymentStatus
    # Set Suite Variable  ${conf_id106}     ${resp.json()['reportContent']['data'][5]['7']}  # ConfirmationId

    # Should Be Equal As Strings  ${TODAY_Slot7}               ${resp.json()['reportContent']['data'][6]['1']}  # Date
    # Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][6]['2']}  # CustomerId
    # Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][6]['3']}  # CustomerName
    # Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][6]['5']}  # Service
    # Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][6]['6']}  # Service
    # Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][6]['8']}  # Status
    # Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][6]['9']}  # Mode
    # Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][6]['10']}  # PaymentStatus
    # Set Suite Variable  ${conf_id107}     ${resp.json()['reportContent']['data'][6]['7']}  # ConfirmationId

    # Should Be Equal As Strings  ${TODAY_Slot8}               ${resp.json()['reportContent']['data'][7]['1']}  # Date
    # Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][7]['2']}  # CustomerId
    # Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][7]['3']}  # CustomerName
    # Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][7]['5']}  # Service
    # Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][7]['6']}  # Service
    # Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][7]['8']}  # Status
    # Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][7]['9']}  # Mode
    # Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][7]['10']}  # PaymentStatus
    # Set Suite Variable  ${conf_id108}     ${resp.json()['reportContent']['data'][7]['7']}  # ConfirmationId

    # Should Be Equal As Strings  ${TODAY_Slot9}               ${resp.json()['reportContent']['data'][8]['1']}  # Date
    # Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][8]['2']}  # CustomerId
    # Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][8]['3']}  # CustomerName
    # Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][8]['5']}  # Service
    # Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][8]['6']}  # Service
    # Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][8]['8']}  # Status
    # Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][8]['9']}  # Mode
    # Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][8]['10']}  # PaymentStatus
    # Set Suite Variable  ${conf_id109}     ${resp.json()['reportContent']['data'][8]['7']}  # ConfirmationId

    # Should Be Equal As Strings  ${TODAY_Slot10}               ${resp.json()['reportContent']['data'][9]['1']}  # Date
    # Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][9]['2']}  # CustomerId
    # Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][9]['3']}  # CustomerName
    # Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][9]['5']}  # Service
    # Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][9]['6']}  # Service
    # Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][9]['8']}  # Status
    # Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][9]['9']}  # Mode
    # Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][9]['10']}  # PaymentStatus
    # Set Suite Variable  ${conf_id110}     ${resp.json()['reportContent']['data'][9]['7']}  # ConfirmationId

    ${resp}=  Get Report By Status       ${Statuses[3]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Appointment_Report-2
    [Documentation]  Generate Next_Week Appointment_report of a provider
    ${resp}=  ProviderLogin  ${PUSERNAME30}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${reportType}             APPOINTMENT

    Set Test Variable  ${reportDateCategory1}    NEXT_WEEK
    ${filter}=  Create Dictionary   apptForId-eq=${jid_c6_f2}    
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


    Set Test Variable  ${reportDateCategory1}    NEXT_WEEK
    ${filter}=  Create Dictionary   apptForId-eq=${jid_c6},${jid_c6_f2},${jid_c6_f1}    
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}
    # sleep  05s
    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # Should Be Equal As Strings  ${resp.json()['reportContent']['count']}  10
    # Should Not Contain    ${resp.json()}  ${Current_Date}
    # Verify Response  ${resp}  reportType=${Report_Types[1]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    # Set Suite Variable  ${RqId_c6_2}      ${resp.json()['reportRequestId']}
    # # Should Be Equal As Strings  ${jid_c6},${jid_c6_f2},${jid_c6_f1}   ${resp.json()['reportContent']['reportHeader']['Customer id']}
    # Should Be Equal As Strings  Next 7 days       ${resp.json()['reportContent']['reportHeader']['Time Period']}
    # Should Be Equal As Strings  Appointment Report         ${resp.json()['reportContent']['reportName']}
    # Should Be Equal As Strings  14                    ${resp.json()['reportContent']['count']}
    # Should Be Equal As Strings  ${Add_DAY1}               ${resp.json()['reportContent']['from']}
    # Should Be Equal As Strings  ${Add_DAY7}               ${resp.json()['reportContent']['to']}
    
    # Should Be Equal As Strings  Appointment Date      ${resp.json()['reportContent']['columns']['1']}  # Date
    # Should Be Equal As Strings  Customer ID           ${resp.json()['reportContent']['columns']['2']}  # CustomerId
    # Should Be Equal As Strings  Customer Name         ${resp.json()['reportContent']['columns']['3']}  # CustomerName
    # Should Be Equal As Strings  Customer Phone        ${resp.json()['reportContent']['columns']['4']}  # CustomerPhone
    # Should Be Equal As Strings  Schedule              ${resp.json()['reportContent']['columns']['5']}  # QueueName
    # Should Be Equal As Strings  Service               ${resp.json()['reportContent']['columns']['6']}  # ServiceName
    # Should Be Equal As Strings  Confirmation Number   ${resp.json()['reportContent']['columns']['7']}  # ConfirmationId
    # Should Be Equal As Strings  Status                ${resp.json()['reportContent']['columns']['8']}  # Status
    # Should Be Equal As Strings  Mode                  ${resp.json()['reportContent']['columns']['9']}  # Mode
    # Should Be Equal As Strings  Payment Status        ${resp.json()['reportContent']['columns']['10']}  # PaymentStatus 
    # Should Be Equal As Strings  Amount Paid           ${resp.json()['reportContent']['columns']['11']}  # AmountPaid

    
    # Should Be Equal As Strings  ${Date1_Slot2}               ${resp.json()['reportContent']['data'][0]['1']}  # Date
    # Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][0]['2']}  # CustomerId
    # Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][0]['3']}  # CustomerName
    # Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][0]['5']}  # Service
    # Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][0]['6']}  # Service
    # Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][0]['8']}  # Status
    # Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][0]['9']}  # Mode
    # Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][0]['10']}  # PaymentStatus
    # Set Suite Variable  ${conf_id201}     ${resp.json()['reportContent']['data'][0]['7']}  # ConfirmationId

    # Should Be Equal As Strings  ${Date1_Slot3}               ${resp.json()['reportContent']['data'][1]['1']}  # Date
    # Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][1]['2']}  # CustomerId
    # Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][1]['3']}  # CustomerName
    # Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][1]['5']}  # Service
    # Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][1]['6']}  # Service
    # Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][1]['8']}  # Status
    # Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][1]['9']}  # Mode
    # Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][1]['10']}  # PaymentStatus
    # Set Suite Variable  ${conf_id202}     ${resp.json()['reportContent']['data'][1]['7']}  # ConfirmationId

    # Should Be Equal As Strings  ${Date2_Slot3}               ${resp.json()['reportContent']['data'][2]['1']}  # Date
    # Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][2]['2']}  # CustomerId
    # Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][2]['3']}  # CustomerName
    # Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][2]['5']}  # Service
    # Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][2]['6']}  # Service
    # Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][2]['8']}  # Status
    # Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][2]['9']}  # Mode
    # Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][2]['10']}  # PaymentStatus
    # Set Suite Variable  ${conf_id203}     ${resp.json()['reportContent']['data'][2]['7']}  # ConfirmationId

    # Should Be Equal As Strings  ${Date2_Slot4}               ${resp.json()['reportContent']['data'][3]['1']}  # Date
    # Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][3]['2']}  # CustomerId
    # Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][3]['3']}  # CustomerName
    # Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][3]['5']}  # Service
    # Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][3]['6']}  # Service
    # Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][3]['8']}  # Status
    # Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][3]['9']}  # Mode
    # Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][3]['10']}  # PaymentStatus
    # Set Suite Variable  ${conf_id204}     ${resp.json()['reportContent']['data'][3]['7']}  # ConfirmationId

    # Should Be Equal As Strings  ${Date3_Slot4}               ${resp.json()['reportContent']['data'][4]['1']}  # Date
    # Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][4]['2']}  # CustomerId
    # Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][4]['3']}  # CustomerName
    # Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][4]['5']}  # Service
    # Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][4]['6']}  # Service
    # Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][4]['8']}  # Status
    # Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][4]['9']}  # Mode
    # Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][4]['10']}  # PaymentStatus
    # Set Suite Variable  ${conf_id205}     ${resp.json()['reportContent']['data'][4]['7']}  # ConfirmationId

    # Should Be Equal As Strings  ${Date3_Slot5}               ${resp.json()['reportContent']['data'][5]['1']}  # Date
    # Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][5]['2']}  # CustomerId
    # Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][5]['3']}  # CustomerName
    # Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][5]['5']}  # Service
    # Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][5]['6']}  # Service
    # Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][5]['8']}  # Status
    # Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][5]['9']}  # Mode
    # Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][5]['10']}  # PaymentStatus
    # Set Suite Variable  ${conf_id206}     ${resp.json()['reportContent']['data'][5]['7']}  # ConfirmationId

    # Should Be Equal As Strings  ${Date4_Slot5}               ${resp.json()['reportContent']['data'][6]['1']}  # Date
    # Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][6]['2']}  # CustomerId
    # Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][6]['3']}  # CustomerName
    # Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][6]['5']}  # Service
    # Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][6]['6']}  # Service
    # Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][6]['8']}  # Status
    # Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][6]['9']}  # Mode
    # Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][6]['10']}  # PaymentStatus
    # Set Suite Variable  ${conf_id207}     ${resp.json()['reportContent']['data'][6]['7']}  # ConfirmationId

    # Should Be Equal As Strings  ${Date4_Slot6}               ${resp.json()['reportContent']['data'][7]['1']}  # Date
    # Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][7]['2']}  # CustomerId
    # Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][7]['3']}  # CustomerName
    # Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][7]['5']}  # Service
    # Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][7]['6']}  # Service
    # Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][7]['8']}  # Status
    # Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][7]['9']}  # Mode
    # Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][7]['10']}  # PaymentStatus
    # Set Suite Variable  ${conf_id208}     ${resp.json()['reportContent']['data'][7]['7']}  # ConfirmationId

    # Should Be Equal As Strings  ${Date5_Slot6}               ${resp.json()['reportContent']['data'][8]['1']}  # Date
    # Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][8]['2']}  # CustomerId
    # Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][8]['3']}  # CustomerName
    # Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][8]['5']}  # Service
    # Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][8]['6']}  # Service
    # Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][8]['8']}  # Status
    # Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][8]['9']}  # Mode
    # Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][8]['10']}  # PaymentStatus
    # Set Suite Variable  ${conf_id209}     ${resp.json()['reportContent']['data'][8]['7']}  # ConfirmationId

    # Should Be Equal As Strings  ${Date5_Slot7}               ${resp.json()['reportContent']['data'][9]['1']}  # Date
    # Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][9]['2']}  # CustomerId
    # Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][9]['3']}  # CustomerName
    # Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][9]['5']}  # Service
    # Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][9]['6']}  # Service
    # Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][9]['8']}  # Status
    # Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][9]['9']}  # Mode
    # Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][9]['10']}  # PaymentStatus
    # Set Suite Variable  ${conf_id210}     ${resp.json()['reportContent']['data'][9]['7']}  # ConfirmationId

    # Should Be Equal As Strings  ${Date6_Slot7}               ${resp.json()['reportContent']['data'][10]['1']}  # Date
    # Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][10]['2']}  # CustomerId
    # Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][10]['3']}  # CustomerName
    # Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][10]['5']}  # Service
    # Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][10]['6']}  # Service
    # Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][10]['8']}  # Status
    # Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][10]['9']}  # Mode
    # Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][10]['10']}  # PaymentStatus
    # Set Suite Variable  ${conf_id211}     ${resp.json()['reportContent']['data'][10]['7']}  # ConfirmationId

    # Should Be Equal As Strings  ${Date6_Slot8}               ${resp.json()['reportContent']['data'][11]['1']}  # Date
    # Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][11]['2']}  # CustomerId
    # Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][11]['3']}  # CustomerName
    # Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][11]['5']}  # Service
    # Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][11]['6']}  # Service
    # Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][11]['8']}  # Status
    # Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][11]['9']}  # Mode
    # Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][11]['10']}  # PaymentStatus
    # Set Suite Variable  ${conf_id212}     ${resp.json()['reportContent']['data'][11]['7']}  # ConfirmationId

    # Should Be Equal As Strings  ${Date7_Slot8}               ${resp.json()['reportContent']['data'][12]['1']}  # Date
    # Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][12]['2']}  # CustomerId
    # Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][12]['3']}  # CustomerName
    # Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][12]['5']}  # Service
    # Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][12]['6']}  # Service
    # Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][12]['8']}  # Status
    # Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][12]['9']}  # Mode
    # Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][12]['10']}  # PaymentStatus
    # Set Suite Variable  ${conf_id213}     ${resp.json()['reportContent']['data'][12]['7']}  # ConfirmationId

    # Should Be Equal As Strings  ${Date7_Slot9}               ${resp.json()['reportContent']['data'][13]['1']}  # Date
    # Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][13]['2']}  # CustomerId
    # Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][13]['3']}  # CustomerName
    # Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][13]['5']}  # Service
    # Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][13]['6']}  # Service
    # Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][13]['8']}  # Status
    # Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][13]['9']}  # Mode
    # Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][13]['10']}  # PaymentStatus
    # Set Suite Variable  ${conf_id214}     ${resp.json()['reportContent']['data'][13]['7']}  # ConfirmationId

    Set Test Variable  ${reportDateCategory2}     LAST_WEEK
    ${filter}=  Create Dictionary   apptForId-eq=${jid_c6}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory2}  ${filter}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Report By Status       ${Statuses[1]}  ${Statuses[3]}  ${Statuses[4]}  ${Statuses[5]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    

JD-TC-Appointment_Report-3
    [Documentation]  Generate NEXT_THIRTY_DAYS Appointment_report of a provider
    ${resp}=  ProviderLogin  ${PUSERNAME30}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${reportType}             APPOINTMENT
    # Set Test Variable  ${reportDateCategory1}    NEXT_WEEK
 
    Set Test Variable  ${reportDateCategory1}    NEXT_THIRTY_DAYS
    ${filter}=  Create Dictionary   apptForId-eq=${jid_c6},${jid_c6_f1},${jid_c6_f2}    
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}
    # sleep  06s
    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Not Contain    ${resp.json()}  ${Current_Date}
    # Should Not Contain    ${resp.json()}  ${Date31}
    # Should Not Contain    ${resp.json()}  ${Date36}
    # Should Not Contain    ${resp.json()}  ${Date40}
    # Should Not Contain    ${resp.json()}  ${Date45}
    # Should Not Contain    ${resp.json()}  ${Date50}
    # Verify Response  ${resp}  reportType=${Report_Types[1]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    # Set Suite Variable  ${RqId_c6_2}      ${resp.json()['reportRequestId']}
    # # Should Be Equal As Strings  ${jid_c6},${jid_c6_f1},${jid_c6_f2}   ${resp.json()['reportContent']['reportHeader']['Customer id']}
    # Should Be Equal As Strings  Next 30 days       ${resp.json()['reportContent']['reportHeader']['Time Period']}
    # Should Be Equal As Strings  Appointment Report         ${resp.json()['reportContent']['reportName']}
    # Should Be Equal As Strings  24                    ${resp.json()['reportContent']['count']}
    # Should Be Equal As Strings  ${Add_DAY1}               ${resp.json()['reportContent']['from']}
    # Should Be Equal As Strings  ${Add_DAY30}               ${resp.json()['reportContent']['to']}
    # Should Be Equal As Strings  ${Date1_Slot2}               ${resp.json()['reportContent']['data'][0]['1']}  # Date
    # Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][0]['2']}  # CustomerId
    # Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][0]['3']}  # CustomerName
    # Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][0]['5']}  # Service
    # Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][0]['6']}  # Service
    # Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][0]['8']}  # Status
    # Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][0]['9']}  # Mode
    # Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][0]['10']}  # PaymentStatus
    # Set Suite Variable  ${conf_id301}     ${resp.json()['reportContent']['data'][0]['7']}  # ConfirmationId

    # Should Be Equal As Strings  ${Date1_Slot3}               ${resp.json()['reportContent']['data'][1]['1']}  # Date
    # Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][1]['2']}  # CustomerId
    # Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][1]['3']}  # CustomerName
    # Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][1]['5']}  # Service
    # Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][1]['6']}  # Service
    # Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][1]['8']}  # Status
    # Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][1]['9']}  # Mode
    # Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][1]['10']}  # PaymentStatus
    # Set Suite Variable  ${conf_id302}     ${resp.json()['reportContent']['data'][1]['7']}  # ConfirmationId

    # Should Be Equal As Strings  ${Date2_Slot3}               ${resp.json()['reportContent']['data'][2]['1']}  # Date
    # Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][2]['2']}  # CustomerId
    # Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][2]['3']}  # CustomerName
    # Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][2]['5']}  # Service
    # Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][2]['6']}  # Service
    # Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][2]['8']}  # Status
    # Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][2]['9']}  # Mode
    # Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][2]['10']}  # PaymentStatus
    # Set Suite Variable  ${conf_id303}     ${resp.json()['reportContent']['data'][2]['7']}  # ConfirmationId

    # Should Be Equal As Strings  ${Date2_Slot4}               ${resp.json()['reportContent']['data'][3]['1']}  # Date
    # Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][3]['2']}  # CustomerId
    # Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][3]['3']}  # CustomerName
    # Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][3]['5']}  # Service
    # Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][3]['6']}  # Service
    # Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][3]['8']}  # Status
    # Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][3]['9']}  # Mode
    # Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][3]['10']}  # PaymentStatus
    # Set Suite Variable  ${conf_id304}     ${resp.json()['reportContent']['data'][3]['7']}  # ConfirmationId

    # Should Be Equal As Strings  ${Date3_Slot4}               ${resp.json()['reportContent']['data'][4]['1']}  # Date
    # Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][4]['2']}  # CustomerId
    # Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][4]['3']}  # CustomerName
    # Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][4]['5']}  # Service
    # Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][4]['6']}  # Service
    # Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][4]['8']}  # Status
    # Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][4]['9']}  # Mode
    # Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][4]['10']}  # PaymentStatus
    # Set Suite Variable  ${conf_id305}     ${resp.json()['reportContent']['data'][4]['7']}  # ConfirmationId

    # Should Be Equal As Strings  ${Date3_Slot5}               ${resp.json()['reportContent']['data'][5]['1']}  # Date
    # Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][5]['2']}  # CustomerId
    # Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][5]['3']}  # CustomerName
    # Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][5]['5']}  # Service
    # Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][5]['6']}  # Service
    # Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][5]['8']}  # Status
    # Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][5]['9']}  # Mode
    # Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][5]['10']}  # PaymentStatus
    # Set Suite Variable  ${conf_id306}     ${resp.json()['reportContent']['data'][5]['7']}  # ConfirmationId

    # Should Be Equal As Strings  ${Date4_Slot5}               ${resp.json()['reportContent']['data'][6]['1']}  # Date
    # Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][6]['2']}  # CustomerId
    # Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][6]['3']}  # CustomerName
    # Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][6]['5']}  # Service
    # Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][6]['6']}  # Service
    # Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][6]['8']}  # Status
    # Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][6]['9']}  # Mode
    # Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][6]['10']}  # PaymentStatus
    # Set Suite Variable  ${conf_id307}     ${resp.json()['reportContent']['data'][6]['7']}  # ConfirmationId

    # Should Be Equal As Strings  ${Date4_Slot6}               ${resp.json()['reportContent']['data'][7]['1']}  # Date
    # Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][7]['2']}  # CustomerId
    # Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][7]['3']}  # CustomerName
    # Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][7]['5']}  # Service
    # Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][7]['6']}  # Service
    # Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][7]['8']}  # Status
    # Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][7]['9']}  # Mode
    # Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][7]['10']}  # PaymentStatus
    # Set Suite Variable  ${conf_id308}     ${resp.json()['reportContent']['data'][7]['7']}  # ConfirmationId

    # Should Be Equal As Strings  ${Date5_Slot6}               ${resp.json()['reportContent']['data'][8]['1']}  # Date
    # Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][8]['2']}  # CustomerId
    # Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][8]['3']}  # CustomerName
    # Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][8]['5']}  # Service
    # Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][8]['6']}  # Service
    # Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][8]['8']}  # Status
    # Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][8]['9']}  # Mode
    # Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][8]['10']}  # PaymentStatus
    # Set Suite Variable  ${conf_id309}     ${resp.json()['reportContent']['data'][8]['7']}  # ConfirmationId

    # Should Be Equal As Strings  ${Date5_Slot7}               ${resp.json()['reportContent']['data'][9]['1']}  # Date
    # Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][9]['2']}  # CustomerId
    # Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][9]['3']}  # CustomerName
    # Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][9]['5']}  # Service
    # Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][9]['6']}  # Service
    # Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][9]['8']}  # Status
    # Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][9]['9']}  # Mode
    # Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][9]['10']}  # PaymentStatus
    # Set Suite Variable  ${conf_id310}     ${resp.json()['reportContent']['data'][9]['7']}  # ConfirmationId

    # Should Be Equal As Strings  ${Date6_Slot7}               ${resp.json()['reportContent']['data'][10]['1']}  # Date
    # Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][10]['2']}  # CustomerId
    # Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][10]['3']}  # CustomerName
    # Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][10]['5']}  # Service
    # Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][10]['6']}  # Service
    # Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][10]['8']}  # Status
    # Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][10]['9']}  # Mode
    # Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][10]['10']}  # PaymentStatus
    # Set Suite Variable  ${conf_id311}     ${resp.json()['reportContent']['data'][10]['7']}  # ConfirmationId

    # Should Be Equal As Strings  ${Date6_Slot8}               ${resp.json()['reportContent']['data'][11]['1']}  # Date
    # Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][11]['2']}  # CustomerId
    # Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][11]['3']}  # CustomerName
    # Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][11]['5']}  # Service
    # Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][11]['6']}  # Service
    # Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][11]['8']}  # Status
    # Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][11]['9']}  # Mode
    # Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][11]['10']}  # PaymentStatus
    # Set Suite Variable  ${conf_id312}     ${resp.json()['reportContent']['data'][11]['7']}  # ConfirmationId

    # Should Be Equal As Strings  ${Date7_Slot8}               ${resp.json()['reportContent']['data'][12]['1']}  # Date
    # Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][12]['2']}  # CustomerId
    # Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][12]['3']}  # CustomerName
    # Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][12]['5']}  # Service
    # Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][12]['6']}  # Service
    # Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][12]['8']}  # Status
    # Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][12]['9']}  # Mode
    # Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][12]['10']}  # PaymentStatus
    # Set Suite Variable  ${conf_id313}     ${resp.json()['reportContent']['data'][12]['7']}  # ConfirmationId

    # Should Be Equal As Strings  ${Date7_Slot9}               ${resp.json()['reportContent']['data'][13]['1']}  # Date
    # Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][13]['2']}  # CustomerId
    # Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][13]['3']}  # CustomerName
    # Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][13]['5']}  # Service
    # Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][13]['6']}  # Service
    # Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][13]['8']}  # Status
    # Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][13]['9']}  # Mode
    # Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][13]['10']}  # PaymentStatus
    # Set Suite Variable  ${conf_id314}     ${resp.json()['reportContent']['data'][13]['7']}  # ConfirmationId
    
    # Should Be Equal As Strings  ${Date8_Slot9}               ${resp.json()['reportContent']['data'][14]['1']}  # Date
    # Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][14]['2']}  # CustomerId
    # Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][14]['3']}  # CustomerName
    # Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][14]['5']}  # Service
    # Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][14]['6']}  # Service
    # Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][14]['8']}  # Status
    # Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][14]['9']}  # Mode
    # Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][14]['10']}  # PaymentStatus
    # Set Suite Variable  ${conf_id315}     ${resp.json()['reportContent']['data'][14]['7']}  # ConfirmationId

    # Should Be Equal As Strings  ${Date8_Slot10}               ${resp.json()['reportContent']['data'][15]['1']}  # Date
    # Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][15]['2']}  # CustomerId
    # Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][15]['3']}  # CustomerName
    # Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][15]['5']}  # Service
    # Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][15]['6']}  # Service
    # Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][15]['8']}  # Status
    # Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][15]['9']}  # Mode
    # Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][15]['10']}  # PaymentStatus
    # Set Suite Variable  ${conf_id316}     ${resp.json()['reportContent']['data'][15]['7']}  # ConfirmationId


    # Should Be Equal As Strings  ${Date15_Slot10}               ${resp.json()['reportContent']['data'][16]['1']}  # Date
    # Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][16]['2']}  # CustomerId
    # Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][16]['3']}  # CustomerName
    # Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][16]['5']}  # Service
    # Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][16]['6']}  # Service
    # Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][16]['8']}  # Status
    # Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][16]['9']}  # Mode
    # Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][16]['10']}  # PaymentStatus
    # Set Suite Variable  ${conf_id317}     ${resp.json()['reportContent']['data'][16]['7']}  # ConfirmationId


    # Should Be Equal As Strings  ${Date15_Slot1}               ${resp.json()['reportContent']['data'][17]['1']}  # Date
    # Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][17]['2']}  # CustomerId
    # Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][17]['3']}  # CustomerName
    # Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][17]['5']}  # Service
    # Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][17]['6']}  # Service
    # Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][17]['8']}  # Status
    # Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][17]['9']}  # Mode
    # Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][17]['10']}  # PaymentStatus
    # Set Suite Variable  ${conf_id318}     ${resp.json()['reportContent']['data'][17]['7']}  # ConfirmationId


    # Should Be Equal As Strings  ${Date20_Slot11}               ${resp.json()['reportContent']['data'][18]['1']}  # Date
    # Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][18]['2']}  # CustomerId
    # Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][18]['3']}  # CustomerName
    # Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][18]['5']}  # Service
    # Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][18]['6']}  # Service
    # Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][18]['8']}  # Status
    # Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][18]['9']}  # Mode
    # Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][18]['10']}  # PaymentStatus
    # Set Suite Variable  ${conf_id319}     ${resp.json()['reportContent']['data'][18]['7']}  # ConfirmationId


    # Should Be Equal As Strings  ${Date20_Slot12}               ${resp.json()['reportContent']['data'][19]['1']}  # Date
    # Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][19]['2']}  # CustomerId
    # Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][19]['3']}  # CustomerName
    # Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][19]['5']}  # Service
    # Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][19]['6']}  # Service
    # Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][19]['8']}  # Status
    # Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][19]['9']}  # Mode
    # Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][19]['10']}  # PaymentStatus
    # Set Suite Variable  ${conf_id320}     ${resp.json()['reportContent']['data'][19]['7']}  # ConfirmationId


    # Should Be Equal As Strings  ${Date25_Slot12}               ${resp.json()['reportContent']['data'][20]['1']}  # Date
    # Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][20]['2']}  # CustomerId
    # Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][20]['3']}  # CustomerName
    # Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][20]['5']}  # Service
    # Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][20]['6']}  # Service
    # Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][20]['8']}  # Status
    # Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][20]['9']}  # Mode
    # Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][20]['10']}  # PaymentStatus
    # Set Suite Variable  ${conf_id321}     ${resp.json()['reportContent']['data'][20]['7']}  # ConfirmationId


    # Should Be Equal As Strings  ${Date25_Slot13}               ${resp.json()['reportContent']['data'][21]['1']}  # Date
    # Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][21]['2']}  # CustomerId
    # Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][21]['3']}  # CustomerName
    # Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][21]['5']}  # Service
    # Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][21]['6']}  # Service
    # Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][21]['8']}  # Status
    # Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][21]['9']}  # Mode
    # Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][21]['10']}  # PaymentStatus
    # Set Suite Variable  ${conf_id322}     ${resp.json()['reportContent']['data'][21]['7']}  # ConfirmationId


    # Should Be Equal As Strings  ${Date30_Slot13}               ${resp.json()['reportContent']['data'][22]['1']}  # Date
    # Should Be Equal As Strings  ${jid_c6}              ${resp.json()['reportContent']['data'][22]['2']}  # CustomerId
    # Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][22]['3']}  # CustomerName
    # Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][22]['5']}  # Service
    # Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][22]['6']}  # Service
    # Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][22]['8']}  # Status
    # Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][22]['9']}  # Mode
    # Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][22]['10']}  # PaymentStatus
    # Set Suite Variable  ${conf_id323}     ${resp.json()['reportContent']['data'][22]['7']}  # ConfirmationId


    # Should Be Equal As Strings  ${Date30_Slot14}               ${resp.json()['reportContent']['data'][23]['1']}  # Date
    # Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][23]['2']}  # CustomerId
    # Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][23]['3']}  # CustomerName
    # Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][23]['5']}  # Service
    # Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][23]['6']}  # Service
    # Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][23]['8']}  # Status
    # Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][23]['9']}  # Mode
    # Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][23]['10']}  # PaymentStatus
    # Set Suite Variable  ${conf_id324}     ${resp.json()['reportContent']['data'][23]['7']}  # ConfirmationId


    Set Test Variable  ${reportDateCategory2}     LAST_THIRTY_DAYS
    ${filter}=  Create Dictionary   apptForId-eq=${jid_c6}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory2}  ${filter}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

# *** comment ***

JD-TC-Appointment_Report-4
    [Documentation]  Generate NEXT_WEEK Appointment_report of a provider using Schedule_Id
    ${resp}=  ProviderLogin  ${PUSERNAME30}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${reportType}             APPOINTMENT
    Set Test Variable  ${reportDateCategory1}    NEXT_WEEK

    ${sch_id1}=  Convert To String  ${sch_id} 
    ${filter}=  Create Dictionary   schedule-eq=${sch_id1}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}
    sleep  02s
    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Not Contain    ${resp.json()}  ${TODAY}
    Verify Response  ${resp}  reportType=${Report_Types[1]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    Set Suite Variable  ${RqId_c6_2}      ${resp.json()['reportRequestId']}
    Should Be Equal As Strings  ${schedule_name}   ${resp.json()['reportContent']['reportHeader']['Schedule']}
    Should Be Equal As Strings  Next 7 days       ${resp.json()['reportContent']['reportHeader']['Time Period']}
    Should Be Equal As Strings  Appointment Report         ${resp.json()['reportContent']['reportName']}
    Should Be Equal As Strings  14                    ${resp.json()['reportContent']['count']}
    Should Be Equal As Strings  ${Add_DAY1}               ${resp.json()['reportContent']['from']}
    Should Be Equal As Strings  ${Add_DAY7}               ${resp.json()['reportContent']['to']}
    Should Be Equal As Strings  ${Date1_Slot2}               ${resp.json()['reportContent']['data'][0]['1']}  # Date
    Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][0]['2']}  # CustomerId
    Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][0]['3']}  # CustomerName
    Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][0]['5']}  # Service
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][0]['6']}  # Service
    Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][0]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][0]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][0]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_id201}     ${resp.json()['reportContent']['data'][0]['7']}  # ConfirmationId

    Should Be Equal As Strings  ${Date1_Slot3}               ${resp.json()['reportContent']['data'][1]['1']}  # Date
    Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][1]['2']}  # CustomerId
    Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][1]['3']}  # CustomerName
    Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][1]['5']}  # Service
    Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][1]['6']}  # Service
    Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][1]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][1]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][1]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_id202}     ${resp.json()['reportContent']['data'][1]['7']}  # ConfirmationId

    Should Be Equal As Strings  ${Date2_Slot3}               ${resp.json()['reportContent']['data'][2]['1']}  # Date
    Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][2]['2']}  # CustomerId
    Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][2]['3']}  # CustomerName
    Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][2]['5']}  # Service
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][2]['6']}  # Service
    Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][2]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][2]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][2]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_id203}     ${resp.json()['reportContent']['data'][2]['7']}  # ConfirmationId

    Should Be Equal As Strings  ${Date2_Slot4}               ${resp.json()['reportContent']['data'][3]['1']}  # Date
    Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][3]['2']}  # CustomerId
    Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][3]['3']}  # CustomerName
    Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][3]['5']}  # Service
    Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][3]['6']}  # Service
    Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][3]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][3]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][3]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_id204}     ${resp.json()['reportContent']['data'][3]['7']}  # ConfirmationId

    Should Be Equal As Strings  ${Date3_Slot4}               ${resp.json()['reportContent']['data'][4]['1']}  # Date
    Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][4]['2']}  # CustomerId
    Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][4]['3']}  # CustomerName
    Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][4]['5']}  # Service
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][4]['6']}  # Service
    Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][4]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][4]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][4]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_id205}     ${resp.json()['reportContent']['data'][4]['7']}  # ConfirmationId

    Should Be Equal As Strings  ${Date3_Slot5}               ${resp.json()['reportContent']['data'][5]['1']}  # Date
    Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][5]['2']}  # CustomerId
    Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][5]['3']}  # CustomerName
    Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][5]['5']}  # Service
    Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][5]['6']}  # Service
    Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][5]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][5]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][5]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_id206}     ${resp.json()['reportContent']['data'][5]['7']}  # ConfirmationId

    Should Be Equal As Strings  ${Date4_Slot5}               ${resp.json()['reportContent']['data'][6]['1']}  # Date
    Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][6]['2']}  # CustomerId
    Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][6]['3']}  # CustomerName
    Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][6]['5']}  # Service
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][6]['6']}  # Service
    Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][6]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][6]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][6]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_id207}     ${resp.json()['reportContent']['data'][6]['7']}  # ConfirmationId

    Should Be Equal As Strings  ${Date4_Slot6}               ${resp.json()['reportContent']['data'][7]['1']}  # Date
    Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][7]['2']}  # CustomerId
    Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][7]['3']}  # CustomerName
    Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][7]['5']}  # Service
    Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][7]['6']}  # Service
    Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][7]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][7]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][7]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_id208}     ${resp.json()['reportContent']['data'][7]['7']}  # ConfirmationId

    Should Be Equal As Strings  ${Date5_Slot6}               ${resp.json()['reportContent']['data'][8]['1']}  # Date
    Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][8]['2']}  # CustomerId
    Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][8]['3']}  # CustomerName
    Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][8]['5']}  # Service
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][8]['6']}  # Service
    Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][8]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][8]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][8]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_id209}     ${resp.json()['reportContent']['data'][8]['7']}  # ConfirmationId

    Should Be Equal As Strings  ${Date5_Slot7}               ${resp.json()['reportContent']['data'][9]['1']}  # Date
    Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][9]['2']}  # CustomerId
    Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][9]['3']}  # CustomerName
    Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][9]['5']}  # Service
    Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][9]['6']}  # Service
    Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][9]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][9]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][9]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_id210}     ${resp.json()['reportContent']['data'][9]['7']}  # ConfirmationId

    Should Be Equal As Strings  ${Date6_Slot7}               ${resp.json()['reportContent']['data'][10]['1']}  # Date
    Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][10]['2']}  # CustomerId
    Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][10]['3']}  # CustomerName
    Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][10]['5']}  # Service
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][10]['6']}  # Service
    Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][10]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][10]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][10]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_id211}     ${resp.json()['reportContent']['data'][10]['7']}  # ConfirmationId

    Should Be Equal As Strings  ${Date6_Slot8}               ${resp.json()['reportContent']['data'][11]['1']}  # Date
    Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][11]['2']}  # CustomerId
    Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][11]['3']}  # CustomerName
    Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][11]['5']}  # Service
    Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][11]['6']}  # Service
    Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][11]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][11]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][11]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_id212}     ${resp.json()['reportContent']['data'][11]['7']}  # ConfirmationId

    Should Be Equal As Strings  ${Date7_Slot8}               ${resp.json()['reportContent']['data'][12]['1']}  # Date
    Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][12]['2']}  # CustomerId
    Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][12]['3']}  # CustomerName
    Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][12]['5']}  # Service
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][12]['6']}  # Service
    Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][12]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][12]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][12]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_id213}     ${resp.json()['reportContent']['data'][12]['7']}  # ConfirmationId

    Should Be Equal As Strings  ${Date7_Slot9}               ${resp.json()['reportContent']['data'][13]['1']}  # Date
    Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][13]['2']}  # CustomerId
    Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][13]['3']}  # CustomerName
    Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][13]['5']}  # Service
    Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][13]['6']}  # Service
    Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][13]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][13]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][13]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_id214}     ${resp.json()['reportContent']['data'][13]['7']}  # ConfirmationId





JD-TC-Appointment_Report-5
    [Documentation]  Generate NEXT_THIRTY_DAYS Appointment_report of a provider using Service_Id
    ${resp}=  ProviderLogin  ${PUSERNAME30}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${reportType}             APPOINTMENT
    Set Test Variable  ${reportDateCategory1}    NEXT_THIRTY_DAYS
    ${filter}=  Create Dictionary   service-eq=${p1_s1},${v1_s1}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}
    sleep  02s
    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Not Contain    ${resp.json()}  ${TODAY}
    # Should Not Contain    ${resp.json()}  ${Date31}
    # Should Not Contain    ${resp.json()}  ${Date36}
    # Should Not Contain    ${resp.json()}  ${Date40}
    # Should Not Contain    ${resp.json()}  ${Date45}
    # Should Not Contain    ${resp.json()}  ${Date50}
    Verify Response  ${resp}  reportType=${Report_Types[1]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    Set Suite Variable  ${RqId_c6_2}      ${resp.json()['reportRequestId']}
    Should Be Equal As Strings  ${P1SERVICE1}, ${V1SERVICE1}   ${resp.json()['reportContent']['reportHeader']['Service']}
    Should Be Equal As Strings  Next 30 days       ${resp.json()['reportContent']['reportHeader']['Time Period']}
    Should Be Equal As Strings  Appointment Report         ${resp.json()['reportContent']['reportName']}
    Should Be Equal As Strings  24                    ${resp.json()['reportContent']['count']}
    Should Be Equal As Strings  ${Add_DAY1}               ${resp.json()['reportContent']['from']}
    Should Be Equal As Strings  ${Add_DAY30}               ${resp.json()['reportContent']['to']}
    Should Be Equal As Strings  ${Date1_Slot2}               ${resp.json()['reportContent']['data'][0]['1']}  # Date
    Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][0]['2']}  # CustomerId
    Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][0]['3']}  # CustomerName
    Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][0]['5']}  # Service
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][0]['6']}  # Service
    Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][0]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][0]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][0]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_id301}     ${resp.json()['reportContent']['data'][0]['7']}  # ConfirmationId

    Should Be Equal As Strings  ${Date1_Slot3}               ${resp.json()['reportContent']['data'][1]['1']}  # Date
    Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][1]['2']}  # CustomerId
    Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][1]['3']}  # CustomerName
    Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][1]['5']}  # Service
    Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][1]['6']}  # Service
    Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][1]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][1]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][1]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_id302}     ${resp.json()['reportContent']['data'][1]['7']}  # ConfirmationId

    Should Be Equal As Strings  ${Date2_Slot3}               ${resp.json()['reportContent']['data'][2]['1']}  # Date
    Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][2]['2']}  # CustomerId
    Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][2]['3']}  # CustomerName
    Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][2]['5']}  # Service
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][2]['6']}  # Service
    Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][2]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][2]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][2]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_id303}     ${resp.json()['reportContent']['data'][2]['7']}  # ConfirmationId

    Should Be Equal As Strings  ${Date2_Slot4}               ${resp.json()['reportContent']['data'][3]['1']}  # Date
    Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][3]['2']}  # CustomerId
    Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][3]['3']}  # CustomerName
    Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][3]['5']}  # Service
    Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][3]['6']}  # Service
    Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][3]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][3]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][3]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_id304}     ${resp.json()['reportContent']['data'][3]['7']}  # ConfirmationId

    Should Be Equal As Strings  ${Date3_Slot4}               ${resp.json()['reportContent']['data'][4]['1']}  # Date
    Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][4]['2']}  # CustomerId
    Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][4]['3']}  # CustomerName
    Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][4]['5']}  # Service
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][4]['6']}  # Service
    Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][4]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][4]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][4]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_id305}     ${resp.json()['reportContent']['data'][4]['7']}  # ConfirmationId

    Should Be Equal As Strings  ${Date3_Slot5}               ${resp.json()['reportContent']['data'][5]['1']}  # Date
    Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][5]['2']}  # CustomerId
    Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][5]['3']}  # CustomerName
    Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][5]['5']}  # Service
    Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][5]['6']}  # Service
    Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][5]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][5]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][5]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_id306}     ${resp.json()['reportContent']['data'][5]['7']}  # ConfirmationId

    Should Be Equal As Strings  ${Date4_Slot5}               ${resp.json()['reportContent']['data'][6]['1']}  # Date
    Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][6]['2']}  # CustomerId
    Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][6]['3']}  # CustomerName
    Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][6]['5']}  # Service
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][6]['6']}  # Service
    Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][6]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][6]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][6]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_id307}     ${resp.json()['reportContent']['data'][6]['7']}  # ConfirmationId

    Should Be Equal As Strings  ${Date4_Slot6}               ${resp.json()['reportContent']['data'][7]['1']}  # Date
    Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][7]['2']}  # CustomerId
    Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][7]['3']}  # CustomerName
    Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][7]['5']}  # Service
    Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][7]['6']}  # Service
    Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][7]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][7]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][7]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_id308}     ${resp.json()['reportContent']['data'][7]['7']}  # ConfirmationId

    Should Be Equal As Strings  ${Date5_Slot6}               ${resp.json()['reportContent']['data'][8]['1']}  # Date
    Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][8]['2']}  # CustomerId
    Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][8]['3']}  # CustomerName
    Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][8]['5']}  # Service
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][8]['6']}  # Service
    Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][8]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][8]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][8]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_id309}     ${resp.json()['reportContent']['data'][8]['7']}  # ConfirmationId

    Should Be Equal As Strings  ${Date5_Slot7}               ${resp.json()['reportContent']['data'][9]['1']}  # Date
    Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][9]['2']}  # CustomerId
    Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][9]['3']}  # CustomerName
    Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][9]['5']}  # Service
    Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][9]['6']}  # Service
    Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][9]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][9]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][9]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_id310}     ${resp.json()['reportContent']['data'][9]['7']}  # ConfirmationId

    Should Be Equal As Strings  ${Date6_Slot7}               ${resp.json()['reportContent']['data'][10]['1']}  # Date
    Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][10]['2']}  # CustomerId
    Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][10]['3']}  # CustomerName
    Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][10]['5']}  # Service
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][10]['6']}  # Service
    Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][10]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][10]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][10]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_id311}     ${resp.json()['reportContent']['data'][10]['7']}  # ConfirmationId

    Should Be Equal As Strings  ${Date6_Slot8}               ${resp.json()['reportContent']['data'][11]['1']}  # Date
    Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][11]['2']}  # CustomerId
    Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][11]['3']}  # CustomerName
    Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][11]['5']}  # Service
    Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][11]['6']}  # Service
    Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][11]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][11]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][11]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_id312}     ${resp.json()['reportContent']['data'][11]['7']}  # ConfirmationId

    Should Be Equal As Strings  ${Date7_Slot8}               ${resp.json()['reportContent']['data'][12]['1']}  # Date
    Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][12]['2']}  # CustomerId
    Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][12]['3']}  # CustomerName
    Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][12]['5']}  # Service
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][12]['6']}  # Service
    Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][12]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][12]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][12]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_id313}     ${resp.json()['reportContent']['data'][12]['7']}  # ConfirmationId

    Should Be Equal As Strings  ${Date7_Slot9}               ${resp.json()['reportContent']['data'][13]['1']}  # Date
    Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][13]['2']}  # CustomerId
    Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][13]['3']}  # CustomerName
    Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][13]['5']}  # Service
    Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][13]['6']}  # Service
    Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][13]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][13]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][13]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_id314}     ${resp.json()['reportContent']['data'][13]['7']}  # ConfirmationId

    Should Be Equal As Strings  ${Date8_Slot9}               ${resp.json()['reportContent']['data'][14]['1']}  # Date
    Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][14]['2']}  # CustomerId
    Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][14]['3']}  # CustomerName
    Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][14]['5']}  # Service
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][14]['6']}  # Service
    Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][14]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][14]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][14]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_id315}     ${resp.json()['reportContent']['data'][14]['7']}  # ConfirmationId


    Should Be Equal As Strings  ${Date8_Slot10}               ${resp.json()['reportContent']['data'][15]['1']}  # Date
    Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][15]['2']}  # CustomerId
    Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][15]['3']}  # CustomerName
    Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][15]['5']}  # Service
    Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][15]['6']}  # Service
    Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][15]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][15]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][15]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_id316}     ${resp.json()['reportContent']['data'][15]['7']}  # ConfirmationId


    Should Be Equal As Strings  ${Date15_Slot10}               ${resp.json()['reportContent']['data'][16]['1']}  # Date
    Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][16]['2']}  # CustomerId
    Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][16]['3']}  # CustomerName
    Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][16]['5']}  # Service
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][16]['6']}  # Service
    Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][16]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][16]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][16]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_id317}     ${resp.json()['reportContent']['data'][16]['7']}  # ConfirmationId


    Should Be Equal As Strings  ${Date15_Slot1}               ${resp.json()['reportContent']['data'][17]['1']}  # Date
    Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][17]['2']}  # CustomerId
    Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][17]['3']}  # CustomerName
    Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][17]['5']}  # Service
    Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][17]['6']}  # Service
    Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][17]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][17]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][17]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_id318}     ${resp.json()['reportContent']['data'][17]['7']}  # ConfirmationId


    Should Be Equal As Strings  ${Date20_Slot11}               ${resp.json()['reportContent']['data'][18]['1']}  # Date
    Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][18]['2']}  # CustomerId
    Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][18]['3']}  # CustomerName
    Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][18]['5']}  # Service
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][18]['6']}  # Service
    Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][18]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][18]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][18]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_id319}     ${resp.json()['reportContent']['data'][18]['7']}  # ConfirmationId


    Should Be Equal As Strings  ${Date20_Slot12}               ${resp.json()['reportContent']['data'][19]['1']}  # Date
    Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][19]['2']}  # CustomerId
    Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][19]['3']}  # CustomerName
    Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][19]['5']}  # Service
    Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][19]['6']}  # Service
    Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][19]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][19]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][19]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_id320}     ${resp.json()['reportContent']['data'][19]['7']}  # ConfirmationId


    Should Be Equal As Strings  ${Date25_Slot12}               ${resp.json()['reportContent']['data'][20]['1']}  # Date
    Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][20]['2']}  # CustomerId
    Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][20]['3']}  # CustomerName
    Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][20]['5']}  # Service
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][20]['6']}  # Service
    Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][20]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][20]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][20]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_id321}     ${resp.json()['reportContent']['data'][20]['7']}  # ConfirmationId


    Should Be Equal As Strings  ${Date25_Slot13}               ${resp.json()['reportContent']['data'][21]['1']}  # Date
    Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][21]['2']}  # CustomerId
    Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][21]['3']}  # CustomerName
    Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][21]['5']}  # Service
    Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][21]['6']}  # Service
    Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][21]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][21]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][21]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_id322}     ${resp.json()['reportContent']['data'][21]['7']}  # ConfirmationId


    Should Be Equal As Strings  ${Date30_Slot13}               ${resp.json()['reportContent']['data'][22]['1']}  # Date
    Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][22]['2']}  # CustomerId
    Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][22]['3']}  # CustomerName
    Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][22]['5']}  # Service
    Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][22]['6']}  # Service
    Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][22]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][22]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][22]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_id323}     ${resp.json()['reportContent']['data'][22]['7']}  # ConfirmationId


    Should Be Equal As Strings  ${Date30_Slot14}               ${resp.json()['reportContent']['data'][23]['1']}  # Date
    Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][23]['2']}  # CustomerId
    Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][23]['3']}  # CustomerName
    Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][23]['5']}  # Service
    Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][23]['6']}  # Service
    Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][23]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][23]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][23]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_id324}     ${resp.json()['reportContent']['data'][23]['7']}  # ConfirmationId



JD-TC-Appointment_Report-UH1
    [Documentation]  Generate Appointment_report without login
    
    # ${pcid23}=  get_id  ${CUSERNAME23}
    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${reportType}             APPOINTMENT
    Set Test Variable  ${reportDateCategory}     TODAY
    ${filter}=  Create Dictionary   apptForId-eq=${jid_c6}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}

    
JD-TC-Appointment_Report-UH2
    [Documentation]  Generate Appointment_report of a provider using CONSUMER_login
    ${resp}=  Consumer Login  ${CUSERNAME23}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    

    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${reportType}             APPOINTMENT
    Set Test Variable  ${reportDateCategory1}    NEXT_WEEK
    ${filter}=  Create Dictionary   apptForId-eq=${jid_c6}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   ${resp.json()}   ${LOGIN_NO_ACCESS_FOR_URL}

    
JD-TC-Appointment_Report-UH3
    [Documentation]  Generate Appointment_report of a provider using provider_own_consumerId as EMPTY
    ${resp}=  ProviderLogin  ${PUSERNAME30}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${pcid23}=  get_id  ${CUSERNAME23}
    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${reportType}             APPOINTMENT
    Set Test Variable  ${reportDateCategory1}    NEXT_WEEK
    ${filter}=  Create Dictionary   apptForId-eq=${EMPTY}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Set Test Variable  ${reportDateCategory2}      LAST_WEEK
    ${filter}=  Create Dictionary   apptForId-eq=${EMPTY}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory2}  ${filter}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # -------------check

JD-TC-Appointment_Report-UH4
    [Documentation]  Generate Appointment_report of a provider when DATE_RANGE is EMPTY
    
    ${resp}=  ProviderLogin  ${PUSERNAME30}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${reportType}             APPOINTMENT
    Set Test Variable  ${reportDateCategory1}    DATE_RANGE
    ${filter}=  Create Dictionary   apptForId-eq=${jid_c6}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${ENTER_DATE}


JD-TC-Appointment_Report-UH5
    [Documentation]  Generate Appointment_report of a provider when DATE_RANGE is invalid format
    
    ${resp}=  ProviderLogin  ${PUSERNAME30}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${reportType}             APPOINTMENT
    Set Test Variable  ${reportDateCategory1}    DATE_RANGE
    ${filter}=  Create Dictionary   apptForId-eq=${jid_c6}   date-ge=${EMPTY}   date-le=${EMPTY}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${INVALID_DATE}

    ${date_dd_mm_yyyy} =	Convert Date	${TODAY}	result_format=%d-%m-%Y

    ${filter}=  Create Dictionary   apptForId-eq=${jid_c6}   date-ge=${date_dd_mm_yyyy}   date-le=${date_dd_mm_yyyy}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${INVALID_DATE}

    ${filter}=  Create Dictionary   apptForId-eq=${jid_c6}   date-ge=${date_dd_mm_yyyy}   date-le=${TODAY}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${INVALID_DATE}


JD-TC-Appointment_Report-UH6
    [Documentation]  Generate Appointment_report of a provider when start and end of DATE_RANGE is Future
    
    ${resp}=  ProviderLogin  ${PUSERNAME30}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${reportType}             APPOINTMENT
    Set Test Variable  ${reportDateCategory1}    DATE_RANGE
    ${filter}=  Create Dictionary   apptForId-eq=${jid_c6}   date-ge=${Add_DAY1}   date-le=${Add_DAY36}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${INVALID_DATE_RANGE}


JD-TC-Appointment_Report-UH7
    [Documentation]  Generate Appointment_report of a provider when DATE_RANGE is From current_date to Future_date
    
    ${resp}=  ProviderLogin  ${PUSERNAME30}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${reportType}             APPOINTMENT
    Set Test Variable  ${reportDateCategory1}    DATE_RANGE
    ${filter}=  Create Dictionary   apptForId-eq=${jid_c6}   date-ge=${TODAY}   date-le=${Add_DAY36}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}    ${INVALID_DATE_RANGE}


JD-TC-Appointment_Report-UH8
    [Documentation]  Generate Appointment_report of a provider when DATE_RANGE is From Past_date to Future_date
    
    ${resp}=  ProviderLogin  ${PUSERNAME30}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${reportType}             APPOINTMENT
    Set Test Variable  ${reportDateCategory1}    DATE_RANGE
    ${YESTERDAY}=  subtract_date  1
    Set Suite Variable  ${YESTERDAY}
    ${filter}=  Create Dictionary   apptForId-eq=${jid_c6}   date-ge=${YESTERDAY}   date-le=${Add_DAY1}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${INVALID_DATE_RANGE}


JD-TC-Appointment_Report-UH9
    [Documentation]  Generate Appointment_report of a provider when DATE_RANGE is greater than 90_days
    
    ${resp}=  ProviderLogin  ${PUSERNAME30}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${reportType}             APPOINTMENT
    Set Test Variable  ${reportDateCategory1}    DATE_RANGE
    ${Add_DAY91}=  add_date  92
    Set Suite Variable  ${Add_DAY91}
    ${filter}=  Create Dictionary   apptForId-eq=${jid_c6}   date-ge=${TODAY}   date-le=${Add_DAY91}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${INVALID_DATE_RANGE}

    ${Sub_Date92}=  subtract_date  92
    Set Suite Variable  ${Sub_Date92}
    ${filter}=  Create Dictionary   apptForId-eq=${jid_c6}   date-ge=${Sub_Date92}   date-le=${YESTERDAY}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${MAX_DATE_RANGE}


JD-TC-Appointment_Report-UH10
    [Documentation]  Generate Appointment_report for a provider when start_date is greater than end_date of DATE_RANGE 
    
    ${resp}=  ProviderLogin  ${PUSERNAME30}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${reportType}             APPOINTMENT
    Set Test Variable  ${reportDateCategory1}    DATE_RANGE
    ${filter}=  Create Dictionary   apptForId-eq=${jid_c6}   date-ge=${TODAY}   date-le=${YESTERDAY}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${DATE_MISMATCH}

    ${Sub_Date10}=  subtract_date  10
    Set Suite Variable  ${Sub_Date10}

    ${Sub_Date20}=  subtract_date  20
    Set Suite Variable  ${Sub_Date20}

    ${filter}=  Create Dictionary   apptForId-eq=${jid_c6}   date-ge=${Sub_Date10}   date-le=${Sub_Date20}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${DATE_MISMATCH}


JD-TC-Appointment_Report-UH11
    [Documentation]  Generate Appointment_report of a provider when start_date is FUTURE and end_date is PAST for DATE_RANGE
    
    ${resp}=  ProviderLogin  ${PUSERNAME30}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${reportType}             APPOINTMENT
    Set Test Variable  ${reportDateCategory1}     DATE_RANGE
    ${filter}=  Create Dictionary   apptForId-eq=${jid_c6}   date-ge=${Add_DAY1}   date-le=${YESTERDAY}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${INVALID_DATE_RANGE}


JD-TC-Appointment_Report-UH12
    [Documentation]  Generate Appointment_report of a provider when start_date is FUTURE and end_date is Current_Day for DATE_RANGE
    
    ${resp}=  ProviderLogin  ${PUSERNAME30}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${reportType}             APPOINTMENT
    Set Test Variable  ${reportDateCategory1}     DATE_RANGE
    ${filter}=  Create Dictionary   apptForId-eq=${jid_c6}   date-ge=${Add_DAY1}   date-le=${TODAY}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${INVALID_DATE_RANGE}



JD-TC-Appointment_Report-UH13
    [Documentation]  Generate Appointment_report of a provider when start_date is greater than end_date, and DATE_RANGE is FUTURE
    
    ${resp}=  ProviderLogin  ${PUSERNAME30}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${reportType}             APPOINTMENT
    Set Test Variable  ${reportDateCategory1}     DATE_RANGE
    ${filter}=  Create Dictionary   apptForId-eq=${jid_c6}   date-ge=${Add_DAY36}   date-le=${Add_DAY1}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${INVALID_DATE_RANGE}




# JD-TC-Appointment_Report-6
#     [Documentation]  Generate NEXT_THIRTY_DAYS Appointment_report of a provider DISABLED Service_Id
#     ${resp}=  ProviderLogin  ${PUSERNAME30}  ${PASSWORD}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${RESP}=  Disable service  ${p1_s1} 
#     Should Be Equal As Strings  ${resp.status_code}  200
    
#     Set Test Variable  ${status-eq}              SUCCESS
#     Set Test Variable  ${reportType}             APPOINTMENT
#     Set Test Variable  ${reportDateCategory1}    NEXT_THIRTY_DAYS
#     ${filter}=  Create Dictionary   service-eq=${p1_s1},${v1_s1}   
#     ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Not Contain    ${resp.json()}  ${TODAY}
#     Should Not Contain    ${resp.json()}  ${Date31}
#     Should Not Contain    ${resp.json()}  ${Date36}
#     Should Not Contain    ${resp.json()}  ${Date40}
#     Should Not Contain    ${resp.json()}  ${Date45}
#     Should Not Contain    ${resp.json()}  ${Date50}
#     Verify Response  ${resp}  reportType=${Report_Types[1]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
#     Set Suite Variable  ${RqId_c6_2}      ${resp.json()['reportRequestId']}
#     Should Be Equal As Strings  ${P1SERVICE1}, ${V1SERVICE1}   ${resp.json()['reportContent']['reportHeader']['Service']}
#     Should Be Equal As Strings  Next 30 days       ${resp.json()['reportContent']['reportHeader']['Time Period']}
#     Should Be Equal As Strings  Appointment Report         ${resp.json()['reportContent']['reportName']}
#     Should Be Equal As Strings  24                    ${resp.json()['reportContent']['count']}
#     Should Be Equal As Strings  ${Add_DAY1}               ${resp.json()['reportContent']['from']}
#     Should Be Equal As Strings  ${Add_DAY30}               ${resp.json()['reportContent']['to']}
#     Should Be Equal As Strings  ${Date1}               ${resp.json()['reportContent']['data'][0]['1']}  # Date
#     Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][0]['2']}  # CustomerId
#     Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][0]['3']}  # CustomerName
#     Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][0]['5']}  # Service
#     Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][0]['6']}  # Service
#     Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][0]['8']}  # Status
#     Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][0]['9']}  # Mode
#     Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][0]['10']}  # PaymentStatus
#     Set Suite Variable  ${conf_id301}     ${resp.json()['reportContent']['data'][0]['7']}  # ConfirmationId

#     Should Be Equal As Strings  ${Date1}               ${resp.json()['reportContent']['data'][1]['1']}  # Date
#     Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][1]['2']}  # CustomerId
#     Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][1]['3']}  # CustomerName
#     Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][1]['5']}  # Service
#     Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][1]['6']}  # Service
#     Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][1]['8']}  # Status
#     Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][1]['9']}  # Mode
#     Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][1]['10']}  # PaymentStatus
#     Set Suite Variable  ${conf_id302}     ${resp.json()['reportContent']['data'][1]['7']}  # ConfirmationId

#     Should Be Equal As Strings  ${Date2}               ${resp.json()['reportContent']['data'][2]['1']}  # Date
#     Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][2]['2']}  # CustomerId
#     Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][2]['3']}  # CustomerName
#     Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][2]['5']}  # Service
#     Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][2]['6']}  # Service
#     Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][2]['8']}  # Status
#     Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][2]['9']}  # Mode
#     Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][2]['10']}  # PaymentStatus
#     Set Suite Variable  ${conf_id303}     ${resp.json()['reportContent']['data'][2]['7']}  # ConfirmationId

#     Should Be Equal As Strings  ${Date2}               ${resp.json()['reportContent']['data'][3]['1']}  # Date
#     Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][3]['2']}  # CustomerId
#     Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][3]['3']}  # CustomerName
#     Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][3]['5']}  # Service
#     Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][3]['6']}  # Service
#     Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][3]['8']}  # Status
#     Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][3]['9']}  # Mode
#     Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][3]['10']}  # PaymentStatus
#     Set Suite Variable  ${conf_id304}     ${resp.json()['reportContent']['data'][3]['7']}  # ConfirmationId

#     Should Be Equal As Strings  ${Date3}               ${resp.json()['reportContent']['data'][4]['1']}  # Date
#     Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][4]['2']}  # CustomerId
#     Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][4]['3']}  # CustomerName
#     Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][4]['5']}  # Service
#     Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][4]['6']}  # Service
#     Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][4]['8']}  # Status
#     Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][4]['9']}  # Mode
#     Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][4]['10']}  # PaymentStatus
#     Set Suite Variable  ${conf_id305}     ${resp.json()['reportContent']['data'][4]['7']}  # ConfirmationId

#     Should Be Equal As Strings  ${Date3}               ${resp.json()['reportContent']['data'][5]['1']}  # Date
#     Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][5]['2']}  # CustomerId
#     Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][5]['3']}  # CustomerName
#     Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][5]['5']}  # Service
#     Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][5]['6']}  # Service
#     Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][5]['8']}  # Status
#     Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][5]['9']}  # Mode
#     Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][5]['10']}  # PaymentStatus
#     Set Suite Variable  ${conf_id306}     ${resp.json()['reportContent']['data'][5]['7']}  # ConfirmationId

#     Should Be Equal As Strings  ${Date4}               ${resp.json()['reportContent']['data'][6]['1']}  # Date
#     Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][6]['2']}  # CustomerId
#     Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][6]['3']}  # CustomerName
#     Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][6]['5']}  # Service
#     Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][6]['6']}  # Service
#     Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][6]['8']}  # Status
#     Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][6]['9']}  # Mode
#     Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][6]['10']}  # PaymentStatus
#     Set Suite Variable  ${conf_id307}     ${resp.json()['reportContent']['data'][6]['7']}  # ConfirmationId

#     Should Be Equal As Strings  ${Date4}               ${resp.json()['reportContent']['data'][7]['1']}  # Date
#     Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][7]['2']}  # CustomerId
#     Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][7]['3']}  # CustomerName
#     Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][7]['5']}  # Service
#     Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][7]['6']}  # Service
#     Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][7]['8']}  # Status
#     Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][7]['9']}  # Mode
#     Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][7]['10']}  # PaymentStatus
#     Set Suite Variable  ${conf_id308}     ${resp.json()['reportContent']['data'][7]['7']}  # ConfirmationId

#     Should Be Equal As Strings  ${Date5}               ${resp.json()['reportContent']['data'][8]['1']}  # Date
#     Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][8]['2']}  # CustomerId
#     Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][8]['3']}  # CustomerName
#     Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][8]['5']}  # Service
#     Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][8]['6']}  # Service
#     Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][8]['8']}  # Status
#     Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][8]['9']}  # Mode
#     Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][8]['10']}  # PaymentStatus
#     Set Suite Variable  ${conf_id309}     ${resp.json()['reportContent']['data'][8]['7']}  # ConfirmationId

#     Should Be Equal As Strings  ${Date5}               ${resp.json()['reportContent']['data'][9]['1']}  # Date
#     Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][9]['2']}  # CustomerId
#     Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][9]['3']}  # CustomerName
#     Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][9]['5']}  # Service
#     Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][9]['6']}  # Service
#     Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][9]['8']}  # Status
#     Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][9]['9']}  # Mode
#     Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][9]['10']}  # PaymentStatus
#     Set Suite Variable  ${conf_id310}     ${resp.json()['reportContent']['data'][9]['7']}  # ConfirmationId

#     Should Be Equal As Strings  ${Date6}               ${resp.json()['reportContent']['data'][10]['1']}  # Date
#     Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][10]['2']}  # CustomerId
#     Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][10]['3']}  # CustomerName
#     Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][10]['5']}  # Service
#     Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][10]['6']}  # Service
#     Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][10]['8']}  # Status
#     Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][10]['9']}  # Mode
#     Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][10]['10']}  # PaymentStatus
#     Set Suite Variable  ${conf_id311}     ${resp.json()['reportContent']['data'][10]['7']}  # ConfirmationId

#     Should Be Equal As Strings  ${Date6}               ${resp.json()['reportContent']['data'][11]['1']}  # Date
#     Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][11]['2']}  # CustomerId
#     Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][11]['3']}  # CustomerName
#     Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][11]['5']}  # Service
#     Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][11]['6']}  # Service
#     Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][11]['8']}  # Status
#     Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][11]['9']}  # Mode
#     Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][11]['10']}  # PaymentStatus
#     Set Suite Variable  ${conf_id312}     ${resp.json()['reportContent']['data'][11]['7']}  # ConfirmationId

#     Should Be Equal As Strings  ${Date7}               ${resp.json()['reportContent']['data'][12]['1']}  # Date
#     Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][12]['2']}  # CustomerId
#     Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][12]['3']}  # CustomerName
#     Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][12]['5']}  # Service
#     Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][12]['6']}  # Service
#     Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][12]['8']}  # Status
#     Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][12]['9']}  # Mode
#     Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][12]['10']}  # PaymentStatus
#     Set Suite Variable  ${conf_id313}     ${resp.json()['reportContent']['data'][12]['7']}  # ConfirmationId

#     Should Be Equal As Strings  ${Date7}               ${resp.json()['reportContent']['data'][13]['1']}  # Date
#     Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][13]['2']}  # CustomerId
#     Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][13]['3']}  # CustomerName
#     Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][13]['5']}  # Service
#     Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][13]['6']}  # Service
#     Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][13]['8']}  # Status
#     Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][13]['9']}  # Mode
#     Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][13]['10']}  # PaymentStatus
#     Set Suite Variable  ${conf_id314}     ${resp.json()['reportContent']['data'][13]['7']}  # ConfirmationId

#     Should Be Equal As Strings  ${Date8}               ${resp.json()['reportContent']['data'][14]['1']}  # Date
#     Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][14]['2']}  # CustomerId
#     Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][14]['3']}  # CustomerName
#     Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][14]['5']}  # Service
#     Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][14]['6']}  # Service
#     Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][14]['8']}  # Status
#     Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][14]['9']}  # Mode
#     Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][14]['10']}  # PaymentStatus
#     Set Suite Variable  ${conf_id315}     ${resp.json()['reportContent']['data'][14]['7']}  # ConfirmationId


#     Should Be Equal As Strings  ${Date8}               ${resp.json()['reportContent']['data'][15]['1']}  # Date
#     Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][15]['2']}  # CustomerId
#     Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][15]['3']}  # CustomerName
#     Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][15]['5']}  # Service
#     Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][15]['6']}  # Service
#     Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][15]['8']}  # Status
#     Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][15]['9']}  # Mode
#     Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][15]['10']}  # PaymentStatus
#     Set Suite Variable  ${conf_id316}     ${resp.json()['reportContent']['data'][15]['7']}  # ConfirmationId


#     Should Be Equal As Strings  ${Date15}               ${resp.json()['reportContent']['data'][16]['1']}  # Date
#     Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][16]['2']}  # CustomerId
#     Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][16]['3']}  # CustomerName
#     Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][16]['5']}  # Service
#     Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][16]['6']}  # Service
#     Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][16]['8']}  # Status
#     Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][16]['9']}  # Mode
#     Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][16]['10']}  # PaymentStatus
#     Set Suite Variable  ${conf_id317}     ${resp.json()['reportContent']['data'][16]['7']}  # ConfirmationId


#     Should Be Equal As Strings  ${Date15}               ${resp.json()['reportContent']['data'][17]['1']}  # Date
#     Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][17]['2']}  # CustomerId
#     Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][17]['3']}  # CustomerName
#     Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][17]['5']}  # Service
#     Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][17]['6']}  # Service
#     Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][17]['8']}  # Status
#     Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][17]['9']}  # Mode
#     Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][17]['10']}  # PaymentStatus
#     Set Suite Variable  ${conf_id318}     ${resp.json()['reportContent']['data'][17]['7']}  # ConfirmationId


#     Should Be Equal As Strings  ${Date20}               ${resp.json()['reportContent']['data'][18]['1']}  # Date
#     Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][18]['2']}  # CustomerId
#     Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][18]['3']}  # CustomerName
#     Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][18]['5']}  # Service
#     Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][18]['6']}  # Service
#     Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][18]['8']}  # Status
#     Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][18]['9']}  # Mode
#     Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][18]['10']}  # PaymentStatus
#     Set Suite Variable  ${conf_id319}     ${resp.json()['reportContent']['data'][18]['7']}  # ConfirmationId


#     Should Be Equal As Strings  ${Date20}               ${resp.json()['reportContent']['data'][19]['1']}  # Date
#     Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][19]['2']}  # CustomerId
#     Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][19]['3']}  # CustomerName
#     Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][19]['5']}  # Service
#     Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][19]['6']}  # Service
#     Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][19]['8']}  # Status
#     Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][19]['9']}  # Mode
#     Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][19]['10']}  # PaymentStatus
#     Set Suite Variable  ${conf_id320}     ${resp.json()['reportContent']['data'][19]['7']}  # ConfirmationId


#     Should Be Equal As Strings  ${Date25}               ${resp.json()['reportContent']['data'][20]['1']}  # Date
#     Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][20]['2']}  # CustomerId
#     Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][20]['3']}  # CustomerName
#     Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][20]['5']}  # Service
#     Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][20]['6']}  # Service
#     Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][20]['8']}  # Status
#     Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][20]['9']}  # Mode
#     Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][20]['10']}  # PaymentStatus
#     Set Suite Variable  ${conf_id321}     ${resp.json()['reportContent']['data'][20]['7']}  # ConfirmationId


#     Should Be Equal As Strings  ${Date25}               ${resp.json()['reportContent']['data'][21]['1']}  # Date
#     Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][21]['2']}  # CustomerId
#     Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][21]['3']}  # CustomerName
#     Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][21]['5']}  # Service
#     Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][21]['6']}  # Service
#     Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][21]['8']}  # Status
#     Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][21]['9']}  # Mode
#     Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][21]['10']}  # PaymentStatus
#     Set Suite Variable  ${conf_id322}     ${resp.json()['reportContent']['data'][21]['7']}  # ConfirmationId


#     Should Be Equal As Strings  ${Date30}               ${resp.json()['reportContent']['data'][22]['1']}  # Date
#     Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][22]['2']}  # CustomerId
#     Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][22]['3']}  # CustomerName
#     Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][22]['5']}  # Service
#     Should Be Equal As Strings  ${P1SERVICE1}        ${resp.json()['reportContent']['data'][22]['6']}  # Service
#     Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][22]['8']}  # Status
#     Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][22]['9']}  # Mode
#     Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][22]['10']}  # PaymentStatus
#     Set Suite Variable  ${conf_id323}     ${resp.json()['reportContent']['data'][22]['7']}  # ConfirmationId


#     Should Be Equal As Strings  ${Date30}               ${resp.json()['reportContent']['data'][23]['1']}  # Date
#     Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][23]['2']}  # CustomerId
#     Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][23]['3']}  # CustomerName
#     Should Be Equal As Strings  ${schedule_name}        ${resp.json()['reportContent']['data'][23]['5']}  # Service
#     Should Be Equal As Strings  ${V1SERVICE1}        ${resp.json()['reportContent']['data'][23]['6']}  # Service
#     Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][23]['8']}  # Status
#     Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][23]['9']}  # Mode
#     Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][23]['10']}  # PaymentStatus
#     Set Suite Variable  ${conf_id324}     ${resp.json()['reportContent']['data'][23]['7']}  # ConfirmationId

#     ${resp}=  Enable service  ${p1_s1} 
#     Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-Appointment_Report-7
    [Documentation]  Generate NEXT_WEEK Appointment_report of a provider using Disabled Schedule_Id
    ${resp}=  ProviderLogin  ${PUSERNAME30}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${P1SERVICE3}=    FakerLibrary.word
    Set Suite Variable   ${P1SERVICE3}
    ${desc}=   FakerLibrary.sentence  
    ${DAY}=  get_date
    ${list}=  Create List  1  2  3  4  5  6  7

    ${resp}=  Create Service  ${P1SERVICE3}  ${desc}   ${service_duration[0]}  ${status[0]}    ${btype}  ${bool[1]}  ${notifytype[2]}  ${min_pre}  ${Total}  ${bool[0]}  ${bool[0]}
    Log  ${resp.content}
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
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id2}  ${resp.json()}
    Set Suite Variable  ${schedule_name2}

    ${resp}=  Consumer Login  ${CUSERNAME6}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id2}   ${pid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${num_slots}=  Get Length  ${slots}
    Set Test Variable   ${slot1}   ${slots[${num_slots-1}]}
    Set Test Variable   ${slot2}   ${slots[${num_slots-2}]}
    ${converted7_slot1}=  slot_12hr  ${slot1}
    Set Suite Variable  ${TODAY_sch2_Slot1}    ${Current_Date} [${converted7_slot1}]
    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot1}   firstName=${family_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${p1_s3}  ${sch_id2}  ${TODAY}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid71}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid71}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${jid_c6_f1}   ${resp.json()['appmtFor'][0]['memberJaldeeId']}
    ${converted7_slot2}=  slot_12hr  ${slot2}
    Set Suite Variable  ${TODAY_sch2_Slot2}    ${Current_Date} [${converted7_slot2}]
    ${apptfor1}=  Create Dictionary  id=0   apptTime=${slot2}   firstName=${cid6_fname}
    ${apptfor}=   Create List  ${apptfor1}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${p1_s3}  ${sch_id2}  ${TODAY}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid72}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid72}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${jid_c6}   ${resp.json()['appmtFor'][0]['memberJaldeeId']}


    ${resp}=  ProviderLogin  ${PUSERNAME30}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById  ${sch_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id2}   name=${schedule_name2}  apptState=${Qstate[0]}

    ${resp}=  Appointment Action   ${apptStatus[6]}   ${apptid71}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${reason}=  Random Element  ${cancelReason}
    ${cancel_msg}=   FakerLibrary.word
    ${resp}=    Provider Cancel Appointment  ${apptid72}  ${reason}  ${cancel_msg}  ${TODAY}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Disable Appointment Schedule  ${sch_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep  02s
    ${resp}=  Get Appointment Schedule ById  ${sch_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id2}   name=${schedule_name2}  apptState=${Qstate[1]}

    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${reportType}             APPOINTMENT
    Set Test Variable  ${reportDateCategory1}    TODAY

    ${sch_id21}=  Convert To String  ${sch_id2}
    ${filter}=  Create Dictionary   schedule-eq=${sch_id21}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}
    sleep  02s
    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  reportType=${Report_Types[1]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    Set Suite Variable  ${RqId_c6_7}      ${resp.json()['reportRequestId']}
    Should Be Equal As Strings  ${schedule_name2}   ${resp.json()['reportContent']['reportHeader']['Schedule']}
    Should Be Equal As Strings  Today       ${resp.json()['reportContent']['reportHeader']['Time Period']}
    Should Be Equal As Strings  Appointment Report         ${resp.json()['reportContent']['reportName']}
    Should Be Equal As Strings  2                    ${resp.json()['reportContent']['count']}
    Should Be Equal As Strings  ${TODAY}               ${resp.json()['reportContent']['date']}
    Should Be Equal As Strings  ${TODAY_sch2_Slot1}          ${resp.json()['reportContent']['data'][0]['1']}  # Date
    Should Be Equal As Strings  ${jid_c6_f1}             ${resp.json()['reportContent']['data'][0]['2']}  # CustomerId
    Should Be Equal As Strings  ${fid1_name}          ${resp.json()['reportContent']['data'][0]['3']}  # CustomerName
    Should Be Equal As Strings  ${schedule_name2}        ${resp.json()['reportContent']['data'][0]['5']}  # Service
    Should Be Equal As Strings  ${P1SERVICE3}        ${resp.json()['reportContent']['data'][0]['6']}  # Service
    Should Be Equal As Strings  Completed   ${resp.json()['reportContent']['data'][0]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][0]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][0]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_id101}     ${resp.json()['reportContent']['data'][0]['7']}  # ConfirmationId

    Should Be Equal As Strings  ${TODAY_sch2_Slot2}       ${resp.json()['reportContent']['data'][1]['1']}  # Date
    Should Be Equal As Strings  ${jid_c6}             ${resp.json()['reportContent']['data'][1]['2']}  # CustomerId
    Should Be Equal As Strings  ${C6_name}          ${resp.json()['reportContent']['data'][1]['3']}  # CustomerName
    Should Be Equal As Strings  ${schedule_name2}        ${resp.json()['reportContent']['data'][1]['5']}  # Service
    Should Be Equal As Strings  ${P1SERVICE3}        ${resp.json()['reportContent']['data'][1]['6']}  # Service
    Should Be Equal As Strings  Cancelled   ${resp.json()['reportContent']['data'][1]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][1]['9']}  # Mode
    Should Be Equal As Strings  Not paid  ${resp.json()['reportContent']['data'][1]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_id102}     ${resp.json()['reportContent']['data'][1]['7']}  # ConfirmationId

    ${resp}=   Enable Appointment Schedule   ${sch_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200



JD-TC-Appointment_Report-8
	[Documentation]   Appointment Report before completing prepayment of a Physical service 
    ${resp}=  Provider Login  ${MUSERNAME16}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${P_Sector}   ${resp.json()['sector']}
     Set Test Variable   ${lic_id}   ${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}
    Set Test Variable   ${lic_name}   ${resp.json()['accountLicenseDetails']['accountLicense']['name']}

    ${pid_B15}=  get_acc_id  ${MUSERNAME16}
    Set Suite variable  ${pid_B15}

    clear_Department    ${MUSERNAME16}
    clear_service       ${MUSERNAME16}
    clear_location      ${MUSERNAME16}

    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}   ${duration}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${Empty}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  View Waitlist Settings
    Verify Response  ${resp}  calculationMode=${calc_mode[1]}  trnArndTime=${duration}  futureDateWaitlist=${bool[1]}  showTokenId=${bool[1]}  onlineCheckIns=${bool[1]}
    
    

    # ${highest_package}=  get_highest_license_pkg
    # Log  ${highest_package}
    # Set Suite variable  ${lic2}  ${highest_package[0]}

    # ${resp}=   Change License Package  ${highest_package[0]}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}   200

    ${highest_package}=  get_highest_license_pkg
    Log  ${highest_package}
    Set Suite variable  ${lic2}  ${highest_package[0]}

    ${resp}=   Run Keyword If  '${lic_id}' != '${lic2}'  Change License Package  ${highest_package[0]}
    Run Keyword If   '${resp}' != '${None}'  Log  ${resp.json()}
    Run Keyword If   '${resp}' != '${None}'  Should Be Equal As Strings  ${resp.status_code}  200

    ${highest_package}=  get_highest_license_pkg
    Log  ${highest_package}
    Set Suite variable  ${lic2}  ${highest_package[0]}
    # ${resp}=   Change License Package  ${highest_package[0]}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}

    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[3]}  ${GST_num} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  Enable Tax
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    # ${resp}=  Toggle Department Enable
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    
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
    ${PUSERNAME_U32}=  Evaluate  ${MUSERNAME16}+${number}
    clear_users  ${PUSERNAME_U32}
    Set Suite Variable  ${PUSERNAME_U32}
    ${firstname}=  FakerLibrary.name
    Set Suite Variable  ${firstname}
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname}
    ${dob}=  FakerLibrary.Date
    Set Suite Variable  ${dob}
    ${pin}=  get_pincode
   
    ${resp}=  Get User
    Log  ${resp.content}
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
 

    
    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U32}.ynwtest@netvarth.com   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U32}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${PUSERNAME_U32}  ${countryCodes[0]}  ${PUSERNAME_U32}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id32}  ${resp.json()}
    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${p1_id32}   ${resp.json()[0]['id']}
    Set Suite Variable   ${p0_id32}   ${resp.json()[1]['id']}
    
        # ${resp}=  Enable Disable Virtual Service  Enable
        # Log  ${resp.content}
        # Should Be Equal As Strings  ${resp.status_code}  200

    ${ZOOM_id0}=  Format String  ${ZOOM_url}  ${MUSERNAME16}
    Set Suite Variable   ${ZOOM_id0}

    ${instructions1}=   FakerLibrary.sentence
    ${instructions2}=   FakerLibrary.sentence

    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${CallingModes[0]}   value=${ZOOM_id0}   status=ACTIVE    instructions=${instructions1} 
    ${VirtualcallingMode2}=   Create Dictionary   callingMode=${CallingModes[1]}   value=${MUSERNAME16}   status=ACTIVE    instructions=${instructions2} 
    ${vcm1}=  Create List  ${VirtualcallingMode1}   ${VirtualcallingMode2}

    ${resp}=  Update Virtual Calling Mode   ${vcm1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Virtual Calling Mode
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[0]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${ZOOM_id0}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${instructions1}

    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['callingMode']}     ${CallingModes[1]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['value']}           ${MUSERNAME16}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['instructions']}    ${instructions2}

    ${PUSERPH_id0}=  Evaluate  ${MUSERNAME16}+10101
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
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${VS_id1}  ${resp.json()} 
    ${resp}=   Get Service By Id  ${VS_id1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.content}
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
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${NS_id1}  ${resp.json()}

    
    ${resp}=  Get Accountsettings  
    Log  ${resp.content}
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

    ${schedule_name01}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name01}
    ${bool1}=  Random Element  ${bool}
    ${noOfOccurance}=  Random Int  min=5  max=15
    ${resp}=  Create Appointment Schedule For User  ${u_id32}  ${schedule_name01}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${noOfOccurance}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${service_duration[0]}  ${bool1}   ${VS_id1}   ${NS_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id01}  ${resp.json()}
    

    # ${resp}=  AddCustomer  ${CUSERNAME1}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # # Set Suite Variable  ${cid01}  ${resp.json()}

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${cid01}  ${resp.json()[0]['id']}
    # Set Suite Variable  ${jid_c01}  ${resp.json()[0]['jaldeeId']}

    ${resp}=  ProviderLogout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${uname}  ${resp.json()['userName']}
    ${JC_id01}=  get_id  ${CUSERNAME5} 
    

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id01}   ${pid_B15}
    Log  ${resp.content}
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

    
    # ${pcid1}=  get_id  ${CUSERNAME5}
    ${converted_slot8}=  slot_12hr  ${slot1}
    Set Suite Variable  ${TODAY_sch01_Slot1}    ${Current_Date} [${converted_slot8}]
    ${appt_for1}=  Create Dictionary  id=${self}   apptTime=${slot1}  
    ${apptfor1}=   Create List  ${appt_for1}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For User    ${pid_B15}  ${NS_id1}  ${sch_id01}  ${DAY1}  ${cnote}  ${u_id32}   ${apptfor1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid01}  ${apptid[0]}
    # sleep  02s 

    ${resp}=   Get consumer Appointment By Id   ${pid_B15}  ${apptid01}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid01}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${JC_id01}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${NS_id1}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id01}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${appt_status[0]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['appmtTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}


    ${resp}=  Provider Login  ${MUSERNAME16}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME5}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid01}  ${resp.json()[0]['id']}
    Set Suite Variable  ${jid_c01}  ${resp.json()[0]['jaldeeId']}

    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${reportType}              APPOINTMENT
    Set Test Variable  ${reportDateCategory1}      TODAY

    ${jid1_c01}=  Convert To String  ${jid_c01} 
    ${filter1}=  Create Dictionary   apptForId-eq=${jid1_c01}
           
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}
    sleep  02s
    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  reportType=${Report_Types[1]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    Set Suite Variable  ${ReportId_c17_1}      ${resp.json()['reportRequestId']}
    # Should Be Equal As Strings  ${jid_c01}   ${resp.json()['reportContent']['reportHeader']['Customer id']}
    Should Be Equal As Strings  Today       ${resp.json()['reportContent']['reportHeader']['Time Period']}
    Should Be Equal As Strings  Appointment Report         ${resp.json()['reportContent']['reportName']}
    Should Be Equal As Strings  0                    ${resp.json()['reportContent']['count']}
    Should Be Equal As Strings  ${TODAY}               ${resp.json()['reportContent']['date']}
    Should Be Equal As Strings  ${EMPTY_List}               ${resp.json()['reportContent']['data']}  # Data
        

JD-TC-Verify-1-Appointment_Report-8
    [Documentation]  Appointment Report after completing prepayment of a Physical service
    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid1}=  get_id  ${CUSERNAME5}
    Set Suite Variable   ${cid1}
    # sleep  02s
    ${resp}=  Make payment Consumer Mock  ${pid_B15}  ${min2_pre1}  ${purpose[0]}  ${apptid01}  ${NS_id1}  ${bool[0]}   ${bool[1]}  ${cid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${resp}=  Make payment Consumer Mock  ${min2_pre1}  ${bool[1]}  ${apptid01}  ${pid}  ${purpose[0]}  ${cid01}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${mer}   ${resp.json()['merchantId']}  
    # Set Suite Variable   ${payref}   ${resp.json()['paymentRefId']}
    sleep  02s
    ${resp}=  Get Payment Details  account-eq=${pid_B15}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['amount']}   ${pre2_float1}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}   ${pid_B15}
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}   ${payment_modes[5]}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}   ${apptid01}
    # Should Be Equal As Strings  ${resp.json()[0]['paymentRefId']}   ${payref} 
    Should Be Equal As Strings  ${resp.json()[0]['paymentPurpose']}   ${purpose[0]}

    ${resp}=  ConsumerLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   ProviderLogin   ${MUSERNAME16}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${apptid01}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
        
    ${resp}=  Get Bill By consumer  ${apptid01}  ${pid_B15}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${apptid01}  netTotal=${totalamt2}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${totalamt2}  billPaymentStatus=${paymentStatus[1]}  totalAmountPaid=${pre2_float1}  amountDue=${balamount2}

    ${resp}=  Provider Login  ${MUSERNAME16}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${reportType}             APPOINTMENT
    Set Test Variable  ${reportDateCategory1}    TODAY

    ${jid1_c01}=  Convert To String  ${jid_c01}
    ${filter}=  Create Dictionary   apptForId-eq=${jid1_c01}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}
    sleep  02s
    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  reportType=${Report_Types[1]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    Set Suite Variable  ${ReportId_c01_2}      ${resp.json()['reportRequestId']}
    # Should Be Equal As Strings  ${jid_c01}   ${resp.json()['reportContent']['reportHeader']['Customer id']}
    Should Be Equal As Strings  Today       ${resp.json()['reportContent']['reportHeader']['Time Period']}
    Should Be Equal As Strings  Appointment Report         ${resp.json()['reportContent']['reportName']}
    Should Be Equal As Strings  1                    ${resp.json()['reportContent']['count']}
        
    Should Be Equal As Strings  ${TODAY}               ${resp.json()['reportContent']['date']}
    Should Be Equal As Strings  ${TODAY_sch01_Slot1}      ${resp.json()['reportContent']['data'][0]['1']}  # Date
    Should Be Equal As Strings  ${jid_c01}             ${resp.json()['reportContent']['data'][0]['2']}  # CustomerId
    Should Be Equal As Strings  ${schedule_name01}        ${resp.json()['reportContent']['data'][0]['5']}  # Service
    Should Be Equal As Strings  ${SERVICE3}        ${resp.json()['reportContent']['data'][0]['6']}  # Service
    Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][0]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][0]['9']}  # Mode
    Should Be Equal As Strings  Partially paid   ${resp.json()['reportContent']['data'][0]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_id01-2}     ${resp.json()['reportContent']['data'][0]['7']}  # ConfirmationId


JD-TC-Verify-2-Appointment_Report-8
    [Documentation]  Appointment Report When cancel Appointment after completing prepayment of a Physical service 
    ${resp}=  Provider Login  ${MUSERNAME16}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
        
    ${reason}=  Random Element  ${cancelReason}
    ${msg}=   FakerLibrary.word
    ${resp}=    Provider Cancel Appointment  ${apptid01}  ${reason}  ${msg}  ${DAY1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  02s
        # ${resp}=  Get Appointment Status   ${apptid01}
        # Log  ${resp.content}
        # Should Be Equal As Strings  ${resp.status_code}  200
        # Should Be Equal As Strings  ${resp.json()[1]['appointmentStatus']}   ${apptStatus[4]}

    ${resp}=  Get Bill By UUId  ${apptid01}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${apptid01}
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}  ${paymentStatus[3]} 

    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${reportType}             APPOINTMENT
    Set Test Variable  ${reportDateCategory1}    TODAY
    ${filter}=  Create Dictionary   apptForId-eq=${jid_c01}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}
    sleep  02s
    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  reportType=${Report_Types[1]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    Set Suite Variable  ${ReportId_c17_3}      ${resp.json()['reportRequestId']}
    # Should Be Equal As Strings  ${jid_c01}   ${resp.json()['reportContent']['reportHeader']['Customer id']}
    Should Be Equal As Strings  Today       ${resp.json()['reportContent']['reportHeader']['Time Period']}
    Should Be Equal As Strings  Appointment Report         ${resp.json()['reportContent']['reportName']}
    Should Be Equal As Strings  1                    ${resp.json()['reportContent']['count']}
    Should Be Equal As Strings  ${TODAY}               ${resp.json()['reportContent']['date']}
    Should Be Equal As Strings  ${TODAY_sch01_Slot1}      ${resp.json()['reportContent']['data'][0]['1']}  # Date
    Should Be Equal As Strings  ${jid_c01}             ${resp.json()['reportContent']['data'][0]['2']}  # CustomerId
    Should Be Equal As Strings  ${schedule_name01}        ${resp.json()['reportContent']['data'][0]['5']}  # Service
    Should Be Equal As Strings  ${SERVICE3}        ${resp.json()['reportContent']['data'][0]['6']}  # Service
    Should Be Equal As Strings  Cancelled   ${resp.json()['reportContent']['data'][0]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][0]['9']}  # Mode
    Should Be Equal As Strings  Refund  ${resp.json()['reportContent']['data'][0]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_id01-2}     ${resp.json()['reportContent']['data'][0]['7']}  # ConfirmationId



JD-TC-Appointment_Report-9
    [Documentation]  Appointment Report before completing prepayment of a Virtual service (Login as Root User)

    ${iscorp_subdomains}=  get_iscorp_subdomains_with_maxpartysize  1
     Log  ${iscorp_subdomains}
     Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
     Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
     Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
     ${firstname_A}=  FakerLibrary.first_name
     Set Suite Variable  ${firstname_A}
     ${lastname_A}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname_A}
     ${MUSERNAME_E}=  Evaluate  ${MUSERNAME}+970065
     ${highest_package}=  get_highest_license_pkg
     ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${MUSERNAME_E}    ${highest_package[0]}
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Activation  ${MUSERNAME_E}  0
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Set Credential  ${MUSERNAME_E}  ${PASSWORD}  0
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Provider Login  ${MUSERNAME_E}  ${PASSWORD}
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${Bid_MUSERNAME_E}=  get_acc_id  ${MUSERNAME_E}
     Set Suite variable  ${Bid_MUSERNAME_E}
     Append To File  ${EXECDIR}/TDD/numbers.txt  ${MUSERNAME_E}${\n}
     Set Suite Variable  ${MUSERNAME_E}
     ${resp}=  Get Business Profile
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response  ${resp}  status=INCOMPLETE
     ${DAY1}=  get_date
     Set Suite Variable  ${DAY1}  ${DAY1}
     ${list}=  Create List  1  2  3  4  5  6  7
     Set Suite Variable  ${list}  ${list}
     ${ph1}=  Evaluate  ${MUSERNAME_E}+1000000000
     ${ph2}=  Evaluate  ${MUSERNAME_E}+2000000000
     ${views}=  Random Element    ${Views}
     ${name1}=  FakerLibrary.name
     ${name2}=  FakerLibrary.name
     ${name3}=  FakerLibrary.name
     ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
     ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
     ${emails1}=  Emails  ${name3}  Email  ${P_Email}183.ynwtest@netvarth.com  ${views}
     ${bs}=  FakerLibrary.bs
     ${city}=   get_place
     ${latti}=  get_latitude
     ${longi}=  get_longitude
     ${companySuffix}=  FakerLibrary.companySuffix
     ${postcode}=  FakerLibrary.postcode
     ${address}=  get_address
     ${parking}   Random Element   ${parkingType}
     ${24hours}    Random Element    ${bool}
     ${desc}=   FakerLibrary.sentence
     ${url}=   FakerLibrary.url
     ${sTime}=  add_time  0  15
     Set Suite Variable   ${sTime}
     ${eTime}=  add_time   0  45
     Set Suite Variable   ${eTime}
     ${resp}=  Update Business Profile With Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${fields}=   Get subDomain level Fields  ${domains}  ${sub_domains}
     Log  ${fields.json()}
     Should Be Equal As Strings    ${fields.status_code}   200

     ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

     ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_domains}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=  Get specializations Sub Domain  ${domains}  ${sub_domains}
     Should Be Equal As Strings    ${resp.status_code}   200

     ${spec}=  get_Specializations  ${resp.json()}
     ${resp}=  Update Specialization  ${spec}
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}   200


     ${resp}=  Update Waitlist Settings  ${calc_mode[0]}   ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
     Should Be Equal As Strings  ${resp.status_code}  200
     
     ${resp}=  Enable Waitlist
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     sleep   01s
     ${resp}=  Get jaldeeIntegration Settings
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[0]} 

     ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=  Get jaldeeIntegration Settings
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

     ${resp}=  View Waitlist Settings
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment


    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp1}=   Run Keyword If  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200


    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]} 

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']} 

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}  

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']}

     ${id}=  get_id  ${MUSERNAME_E}
     Set Suite Variable  ${id}
     ${bs}=  FakerLibrary.bs
     Set Suite Variable  ${bs}

    #  ${resp}=  Toggle Department Enable
    #  Log  ${resp.content}
    #  Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END

     sleep  2s
     ${resp}=  Get Departments
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
     ${firstname}=  FakerLibrary.name
     Set Suite Variable  ${firstname}
     ${lastname}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname}
     ${dob}=  FakerLibrary.Date
     Set Suite Variable  ${dob}
     ${pin}=  get_pincode

    ${number}=  Random Int  min=78989  max=99999
    ${PUSERNAME_U1}=  Evaluate  ${MUSERNAME_E}+${number}
    clear_users  ${PUSERNAME_U1}
    Set Suite Variable  ${PUSERNAME_U1}
    # ${number}=  Random Int  min=48989  max=69999
    # ${PUSERNAME_U2}=  Evaluate  ${MUSERNAME_E}+${number}
    ${firstname}=  FakerLibrary.name
    Set Suite Variable  ${firstname}
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname}
    ${dob}=  FakerLibrary.Date
    Set Suite Variable  ${dob}
    ${pin}=  get_pincode
   
    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

   
    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.ynwtest@netvarth.com   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${countryCodes[0]}  ${PUSERNAME_U1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id1}  ${resp.json()}
    
    ${firstname2}=  FakerLibrary.name
     Set Suite Variable  ${firstname2}
     ${lastname2}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname2}
     ${dob2}=  FakerLibrary.Date
     Set Suite Variable  ${dob2}
     ${pin2}=  get_pincode


    ${PUSERNAME_U2}=  Evaluate  ${MUSERNAME_E}+521503
    clear_users  ${PUSERNAME_U2}
    Set Suite Variable  ${PUSERNAME_U2}
    ${firstname}=  FakerLibrary.name
    Set Suite Variable  ${firstname}
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname}
    ${dob}=  FakerLibrary.Date
    Set Suite Variable  ${dob}
    ${pin}=  get_pincode
   

    ${resp}=  Create User  ${firstname2}  ${lastname2}  ${dob2}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U2}.ynwtest@netvarth.com   ${userType[0]}  ${pin2}  ${countryCodes[0]}  ${PUSERNAME_U2}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${PUSERNAME_U2}  ${countryCodes[0]}  ${PUSERNAME_U2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id2}  ${resp.json()}

    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${U2_id3}   ${resp.json()[0]['id']}
    Set Suite Variable   ${U1_id2}   ${resp.json()[1]['id']}
    Set Suite Variable   ${p0_id1}   ${resp.json()[2]['id']}

    ${resp}=  SendProviderResetMail   ${PUSERNAME_U1}
    Should Be Equal As Strings  ${resp.status_code}  200
    @{resp}=  ResetProviderPassword  ${PUSERNAME_U1}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200
    ${resp}=  ProviderLogin  ${PUSERNAME_U1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SendProviderResetMail   ${PUSERNAME_U2}
    Should Be Equal As Strings  ${resp.status_code}  200
    @{resp}=  ResetProviderPassword  ${PUSERNAME_U2}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200
    ${resp}=  ProviderLogin  ${PUSERNAME_U2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ------------------------------------------------------------------------------------------
    ${resp}=  Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}

    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[3]}  ${GST_num} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  Enable Tax
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${ZOOM_id0}=  Format String  ${ZOOM_url}  ${MUSERNAME_E}
    Set Suite Variable   ${ZOOM_id0}

    ${instructions1}=   FakerLibrary.sentence
    ${instructions2}=   FakerLibrary.sentence

    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${CallingModes[0]}   value=${ZOOM_id0}   status=ACTIVE    instructions=${instructions1} 
    ${VirtualcallingMode2}=   Create Dictionary   callingMode=${CallingModes[1]}   value=${MUSERNAME_E}   status=ACTIVE    instructions=${instructions2} 
    ${vcm1}=  Create List  ${VirtualcallingMode1}   ${VirtualcallingMode2}

    ${resp}=  Update Virtual Calling Mode   ${vcm1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Virtual Calling Mode
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[0]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${ZOOM_id0}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${instructions1}

    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['callingMode']}     ${CallingModes[1]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['value']}           ${MUSERNAME_E}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['instructions']}    ${instructions2}

    ${PUSERPH_id0}=  Evaluate  ${MUSERNAME_E}+10101
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
    ${resp}=  Create Virtual Service For User  ${SERVICE4}   ${description}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre1_V1}  ${totalamt_V1}  ${bool[1]}   ${bool[0]}   ${vstype}   ${virtualCallingModes}  ${dep_id}  ${u_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${VS_id1}  ${resp.json()} 
    ${resp}=   Get Service By Id  ${VS_id1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.content}
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

    ${resp}=  Create Service For User  ${SERVICE3}  ${description}   10  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  ${min2_pre1}  ${totalamt2}  ${bool[1]}  ${bool[0]}  ${dep_id}  ${u_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${NS_id1}  ${resp.json()}

    
    ${resp}=  Get Accountsettings  
    Log  ${resp.content}
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

    ${schedule_name01}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name01}
    ${bool1}=  Random Element  ${bool}
    ${noOfOccurance}=  Random Int  min=5  max=15
    ${resp}=  Create Appointment Schedule For User  ${u_id1}  ${schedule_name01}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${noOfOccurance}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${service_duration[0]}  ${bool1}   ${VS_id1}   ${NS_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id01}  ${resp.json()}
    
    # ------------------------------------------------------------------------------------------
    ${resp}=  Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  AddCustomer  ${CUSERNAME3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${cid01}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid03}  ${resp.json()[0]['id']}
    Set Suite Variable  ${jid_c03}  ${resp.json()[0]['jaldeeId']}


    ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
    Log  ${resp.content}
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
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${fid03_name}   ${fname_fid03} ${lname_fid03} 
    Set Suite Variable  ${fid_c03}   ${resp.json()}

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id01}   ${Bid_MUSERNAME_E}
    Log  ${resp.content}
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
    ${converted_slot18}=  slot_12hr  ${slot15_3}
    
    Set Suite Variable  ${TODAY_sch01_Slot3}    ${Current_Date} [${converted_slot18}]
    ${cnote}=   FakerLibrary.name
    ${apptfor1}=  Create Dictionary  id=${fid_c03}   apptTime=${slot15_3}   firstName=${fname_fid03}
    ${apptfor}=   Create List  ${apptfor1}
    ${resp}=   Take Virtual Service Appointment For User   ${Bid_MUSERNAME_E}  ${VS_id1}  ${sch_id01}  ${DAY1}  ${cnote}  ${CallingModes[0]}  ${ZOOM_Pid2}   ${u_id1}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid03}  ${apptid[0]}
    

    ${resp}=   Get consumer Appointment By Id   ${Bid_MUSERNAME_E}  ${apptid03}
    Log  ${resp.content}
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
    Set Suite Variable  ${jid_cf03}    ${resp.json()['appmtFor'][0]['memberJaldeeId']}   

    ${resp}=  Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${reportType}              APPOINTMENT
    Set Test Variable  ${reportDateCategory1}      TODAY
    

    # ${filter1}=  Create Dictionary   apptForId-eq=${fid_c03}
    ${filter1}=  Create Dictionary   apptForId-eq=${jid_cf03}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}
    sleep  02s
    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  reportType=${Report_Types[1]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    Set Suite Variable  ${ReportId_c17_1}      ${resp.json()['reportRequestId']}
    # Should Be Equal As Strings  ${jid_cf03}   ${resp.json()['reportContent']['reportHeader']['Customer id']}
    Should Be Equal As Strings  Today       ${resp.json()['reportContent']['reportHeader']['Time Period']}
    Should Be Equal As Strings  Appointment Report         ${resp.json()['reportContent']['reportName']}
    Should Be Equal As Strings  0                    ${resp.json()['reportContent']['count']}
    Should Be Equal As Strings  ${TODAY}               ${resp.json()['reportContent']['date']}
    Should Be Equal As Strings  ${EMPTY_List}               ${resp.json()['reportContent']['data']}  # Data
        

JD-TC-Verify-1-Appointment_Report-9
    [Documentation]  Appointment Report before completing prepayment of a Virtual service (Login as Normal user)

    ${resp}=  Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${reportType}              APPOINTMENT
    Set Test Variable  ${reportDateCategory1}      TODAY
    

    # ${filter1}=  Create Dictionary   apptForId-eq=${fid_c03}
    ${filter1}=  Create Dictionary   apptForId-eq=${jid_cf03}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}
    sleep  02s
    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  reportType=${Report_Types[1]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    Set Suite Variable  ${ReportId_c17_1}      ${resp.json()['reportRequestId']}
    # Should Be Equal As Strings  ${jid_cf03}   ${resp.json()['reportContent']['reportHeader']['Customer id']}
    Should Be Equal As Strings  Today       ${resp.json()['reportContent']['reportHeader']['Time Period']}
    Should Be Equal As Strings  Appointment Report         ${resp.json()['reportContent']['reportName']}
    Should Be Equal As Strings  0                    ${resp.json()['reportContent']['count']}
    Should Be Equal As Strings  ${TODAY}               ${resp.json()['reportContent']['date']}
    Should Be Equal As Strings  ${EMPTY_List}               ${resp.json()['reportContent']['data']}  # Data
        

JD-TC-Verify-2-Appointment_Report-9
    [Documentation]  Appointment Report after completing prepayment of a Virtual service (Login as Root user)
    ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${jcid03}  ${resp.json()['id']}
    sleep  02s
    ${resp}=  Make payment Consumer Mock  ${Bid_MUSERNAME_E}  ${min_pre1_V1}  ${purpose[0]}  ${apptid03}  ${VS_id1}  ${bool[0]}   ${bool[1]}  ${jcid03}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${resp}=  Make payment Consumer Mock  ${min_pre1_V1}  ${bool[1]}  ${apptid03}  ${Bid_MUSERNAME_E}  ${purpose[0]}  ${cid03}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${mer}   ${resp.json()['merchantId']}  
    Set Suite Variable   ${payref}   ${resp.json()['paymentRefId']}
    sleep  02s
    ${resp}=  Get Payment Details  account-eq=${Bid_MUSERNAME_E}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['amount']}   ${pre_float1_V1}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}   ${Bid_MUSERNAME_E}
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}   ${payment_modes[5]}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}   ${apptid03}
    Should Be Equal As Strings  ${resp.json()[0]['paymentRefId']}   ${payref} 
    Should Be Equal As Strings  ${resp.json()[0]['paymentPurpose']}   ${purpose[0]}

    ${resp}=  ConsumerLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   ProviderLogin   ${MUSERNAME_E}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${apptid03}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By consumer  ${apptid03}  ${Bid_MUSERNAME_E}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${apptid03}  netTotal=${totalamt_V1}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${totalamt_V1}  billPaymentStatus=${paymentStatus[1]}  totalAmountPaid=${pre_float1_V1}  amountDue=${balamount_V1}

    ${resp}=  Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  02s

    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${reportType}              APPOINTMENT
    Set Test Variable  ${reportDateCategory1}      TODAY

    ${jid1_cf03}=  Convert To String  ${jid_cf03} 
    ${filter}=  Create Dictionary   apptForId-eq=${jid1_cf03}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}
    sleep  02s
    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  reportType=${Report_Types[1]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    Set Suite Variable  ${ReportId_c17_2}      ${resp.json()['reportRequestId']}
    # Should Be Equal As Strings  ${jid_cf03}   ${resp.json()['reportContent']['reportHeader']['Customer id']}
    Should Be Equal As Strings  Today       ${resp.json()['reportContent']['reportHeader']['Time Period']}
    Should Be Equal As Strings  Appointment Report         ${resp.json()['reportContent']['reportName']}
    Should Be Equal As Strings  1                    ${resp.json()['reportContent']['count']}
    Should Be Equal As Strings  ${TODAY}               ${resp.json()['reportContent']['date']}
    Should Be Equal As Strings  ${TODAY_sch01_Slot3}      ${resp.json()['reportContent']['data'][0]['1']}  # Date
    Should Be Equal As Strings  ${jid_cf03}             ${resp.json()['reportContent']['data'][0]['2']}  # CustomerId
    Should Be Equal As Strings  ${schedule_name01}        ${resp.json()['reportContent']['data'][0]['5']}  # Service
    Should Be Equal As Strings  ${SERVICE4}        ${resp.json()['reportContent']['data'][0]['6']}  # Service
    Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][0]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][0]['9']}  # Mode
    Should Be Equal As Strings  Partially paid  ${resp.json()['reportContent']['data'][0]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_id01-2}     ${resp.json()['reportContent']['data'][0]['7']}  # ConfirmationId



JD-TC-Verify-3-Appointment_Report-9
    [Documentation]  Appointment Report after completing prepayment of a Virtual service (Login as Normal user)
    ${resp}=  Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  02s

    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${reportType}              APPOINTMENT
    Set Test Variable  ${reportDateCategory1}      TODAY
    ${filter}=  Create Dictionary   apptForId-eq=${jid_cf03}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}
    sleep  02s
    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  reportType=${Report_Types[1]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    Set Suite Variable  ${ReportId_c17_2}      ${resp.json()['reportRequestId']}
    # Should Be Equal As Strings  ${jid_cf03}   ${resp.json()['reportContent']['reportHeader']['Customer id']}
    Should Be Equal As Strings  Today       ${resp.json()['reportContent']['reportHeader']['Time Period']}
    Should Be Equal As Strings  Appointment Report         ${resp.json()['reportContent']['reportName']}
    Should Be Equal As Strings  1                    ${resp.json()['reportContent']['count']}
    Should Be Equal As Strings  ${TODAY}               ${resp.json()['reportContent']['date']}
    Should Be Equal As Strings  ${TODAY_sch01_Slot3}      ${resp.json()['reportContent']['data'][0]['1']}  # Date
    Should Be Equal As Strings  ${jid_cf03}             ${resp.json()['reportContent']['data'][0]['2']}  # CustomerId
    Should Be Equal As Strings  ${schedule_name01}        ${resp.json()['reportContent']['data'][0]['5']}  # Service
    Should Be Equal As Strings  ${SERVICE4}        ${resp.json()['reportContent']['data'][0]['6']}  # Service
    Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][0]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][0]['9']}  # Mode
    Should Be Equal As Strings  Partially paid  ${resp.json()['reportContent']['data'][0]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_id01-2}     ${resp.json()['reportContent']['data'][0]['7']}  # ConfirmationId



JD-TC-Verify-4-Appointment_Report-9
    [Documentation]  Appointment report When cancel Appointment after completing prepayment of a Virtual service (Login as Root user)
    
    ${resp}=  Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
        
    ${reason}=  Random Element  ${cancelReason}
    ${msg}=   FakerLibrary.word
    ${resp}=    Provider Cancel Appointment  ${apptid03}  ${reason}  ${msg}  ${DAY1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  02s
        
    ${resp}=  Get Bill By UUId  ${apptid03}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${apptid03}
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}  ${paymentStatus[3]}


    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${reportType}             APPOINTMENT
    Set Test Variable  ${reportDateCategory1}    TODAY
    ${filter}=  Create Dictionary   apptForId-eq=${jid_cf03}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}
    sleep  02s
    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  reportType=${Report_Types[1]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    Set Suite Variable  ${ReportId_c17_3}      ${resp.json()['reportRequestId']}
    # Should Be Equal As Strings  ${jid_cf03}   ${resp.json()['reportContent']['reportHeader']['Customer id']}
    Should Be Equal As Strings  Today       ${resp.json()['reportContent']['reportHeader']['Time Period']}
    Should Be Equal As Strings  Appointment Report         ${resp.json()['reportContent']['reportName']}
    Should Be Equal As Strings  1                    ${resp.json()['reportContent']['count']}
    Should Be Equal As Strings  ${TODAY}               ${resp.json()['reportContent']['date']}
    Should Be Equal As Strings  ${TODAY_sch01_Slot3}      ${resp.json()['reportContent']['data'][0]['1']}  # Date
    Should Be Equal As Strings  ${jid_cf03}             ${resp.json()['reportContent']['data'][0]['2']}  # CustomerId
    Should Be Equal As Strings  ${schedule_name01}        ${resp.json()['reportContent']['data'][0]['5']}  # Service
    Should Be Equal As Strings  ${SERVICE4}        ${resp.json()['reportContent']['data'][0]['6']}  # Service
    Should Be Equal As Strings  Cancelled   ${resp.json()['reportContent']['data'][0]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][0]['9']}  # Mode
    Should Be Equal As Strings  Refund  ${resp.json()['reportContent']['data'][0]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_id01-2}     ${resp.json()['reportContent']['data'][0]['7']}  # ConfirmationId


JD-TC-Verify-5-Appointment_Report-9
    [Documentation]  Appointment report When cancel Appointment after completing prepayment of a Virtual service (Login as Normal user)
    
    ${resp}=  Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${reportType}             APPOINTMENT
    Set Test Variable  ${reportDateCategory1}    TODAY
    ${filter}=  Create Dictionary   apptForId-eq=${jid_cf03}   
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}
    sleep  02s
    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  reportType=${Report_Types[1]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    Set Suite Variable  ${ReportId_c17_3}      ${resp.json()['reportRequestId']}
    # Should Be Equal As Strings  ${jid_cf03}   ${resp.json()['reportContent']['reportHeader']['Customer id']}
    Should Be Equal As Strings  Today       ${resp.json()['reportContent']['reportHeader']['Time Period']}
    Should Be Equal As Strings  Appointment Report         ${resp.json()['reportContent']['reportName']}
    Should Be Equal As Strings  1                    ${resp.json()['reportContent']['count']}
    Should Be Equal As Strings  ${TODAY}               ${resp.json()['reportContent']['date']}
    Should Be Equal As Strings  ${TODAY_sch01_Slot3}      ${resp.json()['reportContent']['data'][0]['1']}  # Date
    Should Be Equal As Strings  ${jid_cf03}             ${resp.json()['reportContent']['data'][0]['2']}  # CustomerId
    Should Be Equal As Strings  ${schedule_name01}        ${resp.json()['reportContent']['data'][0]['5']}  # Service
    Should Be Equal As Strings  ${SERVICE4}        ${resp.json()['reportContent']['data'][0]['6']}  # Service
    Should Be Equal As Strings  Cancelled   ${resp.json()['reportContent']['data'][0]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][0]['9']}  # Mode
    Should Be Equal As Strings  Refund  ${resp.json()['reportContent']['data'][0]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_id01-2}     ${resp.json()['reportContent']['data'][0]['7']}  # ConfirmationId


JD-TC-Verify-6-Appointment_Report-9
    [Documentation]  Generate Appointment report When Login user has Admin privilege
     ${resp}=  Provider Login  ${MUSERNAME_E}  ${PASSWORD}
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200
     
    ${PUSERNAME_U3}=  Evaluate  ${MUSERNAME_E}+4205003
    clear_users  ${PUSERNAME_U3}
    Set Suite Variable  ${PUSERNAME_U3}
    ${firstname3}=  FakerLibrary.name
    Set Suite Variable  ${firstname3}
    ${lastname3}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname3}
    ${dob3}=  FakerLibrary.Date
    Set Suite Variable  ${dob3}
    ${pin3}=  get_pincode
   

    ${resp}=  Create User  ${firstname3}  ${lastname3}  ${dob3}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U3}.ynwtest@netvarth.com   ${userType[0]}  ${pin3}  ${countryCodes[0]}  ${PUSERNAME_U3}  ${dep_id}  ${sub_domain_id}  ${bool[1]}  ${countryCodes[0]}  ${PUSERNAME_U3}  ${countryCodes[0]}  ${PUSERNAME_U3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id3}  ${resp.json()}

    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${U3_id4}   ${resp.json()[0]['id']}

    ${resp}=  SendProviderResetMail   ${PUSERNAME_U3}
    Should Be Equal As Strings  ${resp.status_code}  200
    @{resp}=  ResetProviderPassword  ${PUSERNAME_U3}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200
    ${resp}=  ProviderLogin  ${PUSERNAME_U3}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SendProviderResetMail   ${PUSERNAME_U3}
    Should Be Equal As Strings  ${resp.status_code}  200
    @{resp}=  ResetProviderPassword  ${PUSERNAME_U3}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200
    ${resp}=  ProviderLogin  ${PUSERNAME_U3}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ------------------------------------------------------------------------------------------
    
    ${resp}=  Provider Login  ${PUSERNAME_U3}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${reportType}              APPOINTMENT
    Set Test Variable  ${reportDateCategory1}      TODAY
    
    # ${filter1}=  Create Dictionary   apptForId-eq=${fid_c03}
    ${filter1}=  Create Dictionary   apptForId-eq=${jid_cf03}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    sleep  03s
    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  reportType=${Report_Types[1]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    Set Suite Variable  ${ReportId_c17_3}      ${resp.json()['reportRequestId']}
    Should Be Equal As Strings  Today       ${resp.json()['reportContent']['reportHeader']['Time Period']}
    Should Be Equal As Strings  Appointment Report         ${resp.json()['reportContent']['reportName']}
    Should Be Equal As Strings  1                    ${resp.json()['reportContent']['count']}
    Should Be Equal As Strings  ${TODAY}               ${resp.json()['reportContent']['date']}
    Should Be Equal As Strings  ${TODAY_sch01_Slot3}      ${resp.json()['reportContent']['data'][0]['1']}  # Date
    Should Be Equal As Strings  ${jid_cf03}             ${resp.json()['reportContent']['data'][0]['2']}  # CustomerId
    Should Be Equal As Strings  ${schedule_name01}        ${resp.json()['reportContent']['data'][0]['5']}  # Service
    Should Be Equal As Strings  ${SERVICE4}        ${resp.json()['reportContent']['data'][0]['6']}  # Service
    Should Be Equal As Strings  Cancelled   ${resp.json()['reportContent']['data'][0]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][0]['9']}  # Mode
    Should Be Equal As Strings  Refund  ${resp.json()['reportContent']['data'][0]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_id01-2}     ${resp.json()['reportContent']['data'][0]['7']}  # ConfirmationId



JD-TC-Appointment_Report-UH14
    [Documentation]  Try to generate Appointment Report by another user of same provider (Login user doesn't have Admin privilege)

    ${resp}=  Provider Login  ${PUSERNAME_U2}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    Set Test Variable  ${status-eq}              SUCCESS
    Set Test Variable  ${reportType}              APPOINTMENT
    Set Test Variable  ${reportDateCategory1}      TODAY
    

    # ${filter1}=  Create Dictionary   apptForId-eq=${fid_c03}
    ${filter1}=  Create Dictionary   apptForId-eq=${jid_cf03}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}
    sleep  02s
    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  reportType=${Report_Types[1]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
    Set Suite Variable  ${ReportId_c17_1}      ${resp.json()['reportRequestId']}
    # Should Be Equal As Strings  ${jid_cf03}   ${resp.json()['reportContent']['reportHeader']['Customer id']}
    Should Be Equal As Strings  Today       ${resp.json()['reportContent']['reportHeader']['Time Period']}
    Should Be Equal As Strings  Appointment Report         ${resp.json()['reportContent']['reportName']}
    Should Be Equal As Strings  1                    ${resp.json()['reportContent']['count']}
    Should Be Equal As Strings  ${TODAY}               ${resp.json()['reportContent']['date']}
    # Should Be Equal As Strings  ${EMPTY_List}               ${resp.json()['reportContent']['data']}  # Data

    Should Be Equal As Strings  ${TODAY_sch01_Slot3}      ${resp.json()['reportContent']['data'][0]['1']}  # Date
    Should Be Equal As Strings  ${jid_cf03}             ${resp.json()['reportContent']['data'][0]['2']}  # CustomerId
    Should Be Equal As Strings  ${schedule_name01}        ${resp.json()['reportContent']['data'][0]['5']}  # Service
    Should Be Equal As Strings  ${SERVICE4}        ${resp.json()['reportContent']['data'][0]['6']}  # Service
    Should Be Equal As Strings  Cancelled   ${resp.json()['reportContent']['data'][0]['8']}  # Status
    Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][0]['9']}  # Mode
    Should Be Equal As Strings  Refund  ${resp.json()['reportContent']['data'][0]['10']}  # PaymentStatus
    Set Suite Variable  ${conf_id01-2}     ${resp.json()['reportContent']['data'][0]['7']}  # ConfirmationId

        
        

# JD-TC-Appointment_Report-9
#     [Documentation]  Appointment Report before completing prepayment of a Virtual service
#     ${resp}=  Provider Login  ${MUSERNAME16}  ${PASSWORD}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=  AddCustomer  ${CUSERNAME3}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     # Set Suite Variable  ${cid01}  ${resp.json()}

#     ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME3}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Suite Variable  ${cid03}  ${resp.json()[0]['id']}
#     Set Suite Variable  ${jid_c03}  ${resp.json()[0]['jaldeeId']}


#     ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${uname}  ${resp.json()['userName']}
#     ${JC_id03}=  get_id  ${CUSERNAME3} 
    
#     ${fname_fid03}=  FakerLibrary.first_name
#     Set Suite Variable  ${fname_fid03}
#     ${lname_fid03}=  FakerLibrary.last_name
#     Set Suite Variable  ${lname_fid03}
#     ${dob}=  FakerLibrary.Date
#     ${gender}    Random Element    ${Genderlist}
#     ${resp}=  AddFamilyMember   ${fname_fid03}  ${lname_fid03}  ${dob}  ${gender}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200 
#     Set Suite Variable  ${fid03_name}   ${fname_fid03} ${lname_fid03} 
#     Set Suite Variable  ${fid_c03}   ${resp.json()}

#     ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id01}   ${pid_B15}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
#     @{slots}=  Create List
#     FOR   ${i}  IN RANGE   0   ${no_of_slots}
#         Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
#     END
#     ${num_slots}=  Get Length  ${slots}
#     ${p}=  Random Int  max=${num_slots-1}
#     Set Suite Variable   ${slot15_1}   ${slots[${p}]}

#     ${q}=  Random Int  max=${num_slots-2}
#     Set Test Variable   ${slot15_3}   ${slots[${q}]}
#     ${converted_slot18}=  slot_12hr  ${slot15_3}
    
#     Set Suite Variable  ${TODAY_sch01_Slot3}    ${Current_Date} [${converted_slot15_3}]
#     ${cnote}=   FakerLibrary.name
#     ${apptfor1}=  Create Dictionary  id=${fid_c03}   apptTime=${slot15_3}   firstName=${fname_fid03}
#     ${apptfor}=   Create List  ${apptfor1}
#     ${resp}=   Take Virtual Service Appointment For User   ${pid_B15}  ${VS_id1}  ${sch_id01}  ${DAY1}  ${cnote}  ${CallingModes[0]}  ${ZOOM_Pid2}   ${u_id32}   ${apptfor}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
          
#     ${apptid}=  Get Dictionary Values  ${resp.json()}
#     Set Suite Variable  ${apptid03}  ${apptid[0]}
    

#     ${resp}=   Get consumer Appointment By Id   ${pid_B15}  ${apptid03}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200 
#     Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid03}
#     Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${JC_id03}
#     Should Be Equal As Strings  ${resp.json()['service']['id']}   ${VS_id1}
#     Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id01}
#     Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${appt_status[0]}
#     Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot15_3}
#     Should Be Equal As Strings  ${resp.json()['appmtDate']}   ${DAY1}
#     Should Be Equal As Strings  ${resp.json()['appmtTime']}   ${slot15_3}
#     Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}
#     Set Suite Variable  ${jid_cf03}    ${resp.json()['appmtFor'][0]['memberJaldeeId']}   

#     ${resp}=  Provider Login  ${MUSERNAME16}  ${PASSWORD}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     Set Test Variable  ${status-eq}              SUCCESS
#     Set Test Variable  ${reportType}              APPOINTMENT
#     Set Test Variable  ${reportDateCategory1}      TODAY
    

#     # ${filter1}=  Create Dictionary   apptForId-eq=${fid_c03}
#     ${filter1}=  Create Dictionary   apptForId-eq=${jid_cf03}
#     ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter1}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Response  ${resp}  reportType=${Report_Types[1]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
#     Set Suite Variable  ${ReportId_c17_1}      ${resp.json()['reportRequestId']}
#     Should Be Equal As Strings  ${jid_cf03}   ${resp.json()['reportContent']['reportHeader']['Customer id']}
#     Should Be Equal As Strings  Today       ${resp.json()['reportContent']['reportHeader']['Time Period']}
#     Should Be Equal As Strings  Appointment Report         ${resp.json()['reportContent']['reportName']}
#     Should Be Equal As Strings  0                    ${resp.json()['reportContent']['count']}
#     Should Be Equal As Strings  ${TODAY}               ${resp.json()['reportContent']['date']}
#     Should Be Equal As Strings  ${EMPTY_List}               ${resp.json()['reportContent']['data']}  # Data
        


# JD-TC-Verify-1-Appointment_Report-9
#     [Documentation]  Appointment Report after completing prepayment of a Virtual service
#     ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200


#     # ${resp}=  Make payment Consumer  ${min_pre1_V1}  ${payment_modes[2]}  ${apptid03}  ${pid_B15}  ${purpose[0]}  ${cid03}
#     # Log  ${resp.content}
#     # Should Be Equal As Strings  ${resp.status_code}  200
#     # Should Contain  ${resp.json()['response']}  <td><input name=\"amount\" value=${pre_float2_V1} /></td>
#     # Should Contain  ${resp.json()['response']}  <td><input name=\"email\" id=\"email\" value=${CUSEREMAIL3} /></td>
#     # Should Contain  ${resp.json()['response']}  <td>Phone: </td>\n   <td><input name=\"phone\" value=${CUSERNAME3} ></td>

#     ${resp}=  Make payment Consumer Mock  ${min_pre1_V1}  ${bool[1]}  ${apptid03}  ${pid_B15}  ${purpose[0]}  ${cid03}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Suite Variable   ${mer}   ${resp.json()['merchantId']}  
#     Set Suite Variable   ${payref}   ${resp.json()['paymentRefId']}
#     sleep  02s
#     ${resp}=  Get Payment Details  account-eq=${pid_B15}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings  ${resp.json()[0]['amount']}   ${pre_float1_V1}
#     Should Be Equal As Strings  ${resp.json()[0]['accountId']}   ${pid_B15}
#     Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}   ${payment_modes[5]}
#     Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}   ${apptid03}
#     Should Be Equal As Strings  ${resp.json()[0]['paymentRefId']}   ${payref} 
#     Should Be Equal As Strings  ${resp.json()[0]['paymentPurpose']}   ${purpose[0]}

#     ${resp}=  Get Bill By consumer  ${apptid03}  ${pid_B15}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Response  ${resp}  uuid=${apptid03}  netTotal=${totalamt_V1}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${totalamt_V1}  billPaymentStatus=${paymentStatus[1]}  totalAmountPaid=${pre_float1_V1}  amountDue=${balamount_V1}

#     ${resp}=  Provider Login  ${MUSERNAME16}  ${PASSWORD}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     sleep  02s

#     Set Test Variable  ${status-eq}              SUCCESS
#     Set Test Variable  ${reportType}              APPOINTMENT
#     Set Test Variable  ${reportDateCategory1}      TODAY
#     ${filter}=  Create Dictionary   apptForId-eq=${jid_cf03}   
#     ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     Verify Response  ${resp}  reportType=${Report_Types[1]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
#     Set Suite Variable  ${ReportId_c17_2}      ${resp.json()['reportRequestId']}
#     Should Be Equal As Strings  ${jid_cf03}   ${resp.json()['reportContent']['reportHeader']['Customer id']}
#     Should Be Equal As Strings  Today       ${resp.json()['reportContent']['reportHeader']['Time Period']}
#     Should Be Equal As Strings  Appointment Report         ${resp.json()['reportContent']['reportName']}
#     Should Be Equal As Strings  1                    ${resp.json()['reportContent']['count']}
#     Should Be Equal As Strings  ${TODAY}               ${resp.json()['reportContent']['date']}
#     Should Be Equal As Strings  ${TODAY_sch01_Slot3}      ${resp.json()['reportContent']['data'][0]['1']}  # Date
#     Should Be Equal As Strings  ${jid_cf03}             ${resp.json()['reportContent']['data'][0]['2']}  # CustomerId
#     Should Be Equal As Strings  ${schedule_name01}        ${resp.json()['reportContent']['data'][0]['5']}  # Service
#     Should Be Equal As Strings  ${SERVICE4}        ${resp.json()['reportContent']['data'][0]['6']}  # Service
#     Should Be Equal As Strings  Confirmed   ${resp.json()['reportContent']['data'][0]['8']}  # Status
#     Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][0]['9']}  # Mode
#     Should Be Equal As Strings  Partially paid  ${resp.json()['reportContent']['data'][0]['10']}  # PaymentStatus
#     Set Suite Variable  ${conf_id01-2}     ${resp.json()['reportContent']['data'][0]['7']}  # ConfirmationId


# JD-TC-Verify-2-Appointment_Report-9
#     [Documentation]  Appointment report When cancel Appointment after completing prepayment of a Virtual service 
    
#     ${resp}=  Provider Login  ${MUSERNAME16}  ${PASSWORD}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
        
#     ${reason}=  Random Element  ${cancelReason}
#     ${msg}=   FakerLibrary.word
#     ${resp}=    Provider Cancel Appointment  ${apptid03}  ${reason}  ${msg}  ${DAY1}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     sleep  02s
        
#     ${resp}=  Get Bill By UUId  ${apptid03}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings  ${resp.json()['uuid']}  ${apptid03}
#     Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}  ${paymentStatus[3]}


#     Set Test Variable  ${status-eq}              SUCCESS
#     Set Test Variable  ${reportType}             APPOINTMENT
#     Set Test Variable  ${reportDateCategory1}    TODAY
#     ${filter}=  Create Dictionary   apptForId-eq=${jid_cf03}   
#     ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory1}  ${filter}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     Verify Response  ${resp}  reportType=${Report_Types[1]}   reportResponseType=${ReportResponseType[0]}   status=${Report_Status[0]}
#     Set Suite Variable  ${ReportId_c17_3}      ${resp.json()['reportRequestId']}
#     Should Be Equal As Strings  ${jid_cf03}   ${resp.json()['reportContent']['reportHeader']['Customer id']}
#     Should Be Equal As Strings  Today       ${resp.json()['reportContent']['reportHeader']['Time Period']}
#     Should Be Equal As Strings  Appointment Report         ${resp.json()['reportContent']['reportName']}
#     Should Be Equal As Strings  1                    ${resp.json()['reportContent']['count']}
#     Should Be Equal As Strings  ${TODAY}               ${resp.json()['reportContent']['date']}
#     Should Be Equal As Strings  ${TODAY_sch01_Slot3}      ${resp.json()['reportContent']['data'][0]['1']}  # Date
#     Should Be Equal As Strings  ${jid_cf03}             ${resp.json()['reportContent']['data'][0]['2']}  # CustomerId
#     Should Be Equal As Strings  ${schedule_name01}        ${resp.json()['reportContent']['data'][0]['5']}  # Service
#     Should Be Equal As Strings  ${SERVICE4}        ${resp.json()['reportContent']['data'][0]['6']}  # Service
#     Should Be Equal As Strings  Cancelled   ${resp.json()['reportContent']['data'][0]['8']}  # Status
#     Should Be Equal As Strings  ${Checkin_mode[0]}   ${resp.json()['reportContent']['data'][0]['9']}  # Mode
#     Should Be Equal As Strings  Refund  ${resp.json()['reportContent']['data'][0]['10']}  # PaymentStatus
#     Set Suite Variable  ${conf_id01-2}     ${resp.json()['reportContent']['data'][0]['7']}  # ConfirmationId



