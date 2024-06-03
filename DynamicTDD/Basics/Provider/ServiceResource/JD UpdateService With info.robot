*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Service
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Library           Process
Library           OperatingSystem
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/providers.py



*** Variables ***

${SERVICE1}  P2SERVICE11
${SERVICE2}  P2SERVICE22
${SERVICE3}  P2SERVICE33
${SERVICE4}  P2SERVICE44
${SERVICE5}  P2SERVICE55
${SERVICE6}  P2SERVICE66
${SERVICE7}  P2SERVICE77
${SERVICE8}  P2SERVICE88
${SERVICE9}  P2SERVICE99
${SERVICE10}  P2SERVICE110
${SERVICE20}  P2SERVICE220
@{service_duration}  10  20  30  40   50

@{status}   ACTIVE   INACTIVE
@{consumerNoteMandatory}    False   True
@{preInfoEnabled}   False   True   
@{postInfoEnabled}  False   True 
${start}         100
${start1}         20
${start2}         50
${start3}         80
${loc}          TGR 
${queue1}     QUEUE1
${self}     0
@{provider_list}
@{dom_list}
@{multiloc_providers}
@{serviceType}      virtualService     physicalService 
${ZOOM_url}    https://zoom.us/j/{}?pwd=THVLcTBZa2lESFZQbU9DQTQrWUxWZz09





*** Test Cases ***
JD-TC-Update Service With info-1-Service_type

        [Documentation]   update a  Physical_servive to Virtual_service for a valid provider when domain is Billable

        ${resp}=  Encrypted Provider Login  ${PUSERNAME121}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
        
        clear_service      ${resp}
        ${description}=  FakerLibrary.sentence
        ${min_pre}=   Random Int   min=10   max=50
        ${Total}=   Random Int   min=100   max=500
        ${min_pre}=  Convert To Number  ${min_pre}  1
        ${Total}=  Convert To Number  ${Total}  1

        ${ZOOM_id0}=  Format String  ${ZOOM_url}  ${PUSERNAME120}
        Set Suite Variable   ${ZOOM_id0}

        ${PUSERPH_id}=  Evaluate  ${PUSERNAME}+10101
        ${ZOOM_Pid1}=  Format String  ${ZOOM_url}  ${PUSERPH_id}
        Set Test Variable  ${callingMode1}     ${CallingModes[0]}
        Set Test Variable  ${ModeId1}          ${ZOOM_Pid1}
        Set Test Variable  ${ModeStatus1}      ACTIVE
        ${Desc1}=    FakerLibrary.sentence
        ${VirtualcallingMode1}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Desc1}
        ${virtualCallingModes}=  Create List  ${VirtualcallingMode1}
        Set Suite Variable  ${virtualCallingModes}
        # ${vstype}=  Evaluate  random.choice($vservicetype)  random
        Set Suite Variable  ${vstype}  ${vservicetype[1]}

        ${consumerNoteTitle}=  FakerLibrary.sentence    
        ${preInfoTitle}=  FakerLibrary.sentence   
        ${preInfoText}=  FakerLibrary.sentence  
        ${postInfoTitle}=  FakerLibrary.sentence  
        ${postInfoText}=  FakerLibrary.sentence
        ${resp}=  Create Service with info  ${SERVICE1}  ${description}   ${service_duration[2]}  ${bool[1]}    ${notifytype[2]}   ${min_pre}  ${Total}   ${status[0]}  ${btype}  ${bool[1]}  ${bool[0]}   ${serviceType[0]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable   ${id}  ${resp.json()}
        ${resp}=   Get Service By Id  ${id}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  name=${SERVICE1}  description=${description}  serviceDuration=${service_duration[2]}   notification=${bool[1]}   notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre}  totalAmount=${Total}  status=${status[0]}   bType=${btype}  isPrePayment=${bool[1]}
        Verify Response  ${resp}  consumerNoteMandatory=${bool[0]}   consumerNoteTitle=${consumerNoteTitle}   preInfoEnabled=${bool[0]}   preInfoTitle=${preInfoTitle}   preInfoText=${preInfoText}   postInfoEnabled=${bool[0]}   postInfoTitle=${postInfoTitle}   postInfoText=${postInfoText}

        
        ${resp}=  Update Service with info  ${id}  ${SERVICE2}  ${description}   ${service_duration[3]}  ${bool[0]}   ${notifytype[0]}  ${min_pre}  ${Total}  ${status[0]}  ${btype}  ${bool[1]}  ${bool[0]}   ${serviceType[0]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp}=   Get Service By Id  ${id}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  name=${SERVICE2}  description=${description}  serviceDuration=${service_duration[3]}  notification=${bool[0]}  notificationType=${notifytype[0]}  minPrePaymentAmount=${min_pre}  totalAmount=${Total}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}
        Verify Response  ${resp}  consumerNoteMandatory=${bool[0]}   consumerNoteTitle=${consumerNoteTitle}   preInfoEnabled=${bool[0]}   preInfoTitle=${preInfoTitle}   preInfoText=${preInfoText}   postInfoEnabled=${bool[0]}   postInfoTitle=${postInfoTitle}   postInfoText=${postInfoText}



JD-TC-Update Service With info-2-Service_type

        [Documentation]  update a  virtual_service to Physical_service for a valid provider when domain is Billable 
        ${resp}=   Billable
        clear_service      ${resp}
        ${description}=  FakerLibrary.sentence
        ${min_pre}=   Random Int   min=10   max=50
        ${Total}=   Random Int   min=100   max=500
        ${min_pre}=  Convert To Number  ${min_pre}  1
        ${Total}=  Convert To Number  ${Total}  1
        
        ${consumerNoteTitle}=  FakerLibrary.sentence    
        ${preInfoTitle}=  FakerLibrary.sentence   
        ${preInfoText}=  FakerLibrary.sentence  
        ${postInfoTitle}=  FakerLibrary.sentence  
        ${postInfoText}=  FakerLibrary.sentence
        
        ${resp}=  Create Service with info  ${SERVICE1}  ${description}   ${service_duration[2]}  ${bool[1]}    ${notifytype[2]}   ${min_pre}  ${Total}   ${status[0]}  ${btype}  ${bool[1]}  ${bool[0]}   ${serviceType[0]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable   ${sid21}  ${resp.json()}
        ${resp}=   Get Service By Id  ${sid21}
        Verify Response  ${resp}  name=${SERVICE1}  description=${description}  serviceDuration=${service_duration[2]}   notification=${bool[1]}   notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre}  totalAmount=${Total}  status=${status[0]}   bType=${btype}  isPrePayment=${bool[1]}
        Verify Response  ${resp}  consumerNoteMandatory=${bool[0]}   consumerNoteTitle=${consumerNoteTitle}   preInfoEnabled=${bool[0]}   preInfoTitle=${preInfoTitle}   preInfoText=${preInfoText}   postInfoEnabled=${bool[0]}   postInfoTitle=${postInfoTitle}   postInfoText=${postInfoText}

        ${resp}=  Update Service with info  ${sid21}  ${SERVICE20}  ${description}   ${service_duration[3]}  ${bool[0]}   ${notifytype[0]}  ${min_pre}  ${Total}  ${status[0]}  ${btype}  ${bool[1]}  ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp}=   Get Service By Id  ${sid21}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  name=${SERVICE20}  description=${description}  serviceDuration=${service_duration[3]}  notification=${bool[0]}  notificationType=${notifytype[0]}  minPrePaymentAmount=${min_pre}  totalAmount=${Total}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}
        Verify Response  ${resp}  consumerNoteMandatory=${bool[0]}   consumerNoteTitle=${consumerNoteTitle}   preInfoEnabled=${bool[0]}   preInfoTitle=${preInfoTitle}   preInfoText=${preInfoText}   postInfoEnabled=${bool[0]}   postInfoTitle=${postInfoTitle}   postInfoText=${postInfoText}



JD-TC-Update Service With info-3-Service_type

        [Documentation]    UPDATE Service Type in before and after taking checkin 
        ${multilocPro}=  MultiLocation Domain Providers   min=30   max=50
        Log  ${multilocPro}
        Set Suite Variable   ${multilocPro}
        ${len}=  Get Length  ${multilocPro}
        ${resp}=  Encrypted Provider Login  ${multilocPro[1]}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        clear_service       ${multilocPro[1]}
        ${ser_durtn}=   Random Int   min=2   max=10
        ${description}=  FakerLibrary.sentence
        ${Total1}=   Random Int   min=100   max=500
        ${Total1}=  Convert To Number  ${Total1}  1

        ${consumerNoteTitle}=  FakerLibrary.sentence    
        ${preInfoTitle}=  FakerLibrary.sentence   
        ${preInfoText}=  FakerLibrary.sentence  
        ${postInfoTitle}=  FakerLibrary.sentence  
        ${postInfoText}=  FakerLibrary.sentence
        
        ${resp}=  Create Service with info    ${SERVICE10}  ${description}   ${ser_durtn}    ${bool[1]}    ${notifytype[1]}  ${EMPTY}  ${Total1}   ${status[0]}   ${btype}  ${bool[0]}  ${bool[0]}   ${serviceType[0]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        Should Be Equal As Strings  ${resp.status_code}  200  
        Set Suite Variable    ${s_id10}    ${resp.json()} 
        ${resp}=   Get Service By Id   ${s_id10} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings   ${resp.json()['serviceType']}   ${serviceType[0]}
        Verify Response  ${resp}  name=${SERVICE10}  description=${description}  serviceDuration=${ser_durtn}  notification=${bool[1]}  notificationType=${notifytype[1]}  totalAmount=${Total1}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}
        Verify Response  ${resp}  consumerNoteMandatory=${bool[0]}   consumerNoteTitle=${consumerNoteTitle}   preInfoEnabled=${bool[0]}   preInfoTitle=${preInfoTitle}   preInfoText=${preInfoText}   postInfoEnabled=${bool[0]}   postInfoTitle=${postInfoTitle}   postInfoText=${postInfoText}

        ${Description1}=    FakerLibrary.sentence
        ${resp}=  Update Service with info   ${s_id10}  ${SERVICE10}  ${Description1}   ${ser_durtn}    ${bool[1]}    ${notifytype[1]}  ${EMPTY}  ${Total1}   ${status[0]}   ${btype}  ${bool[0]}  ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=   Get Service By Id   ${s_id10} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings   ${resp.json()['serviceType']}   ${serviceType[1]}
        Verify Response  ${resp}  name=${SERVICE10}  description=${Description1}  serviceDuration=${ser_durtn}  notification=${bool[1]}  notificationType=${notifytype[1]}   totalAmount=${Total1}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}
        Verify Response  ${resp}  consumerNoteMandatory=${bool[0]}   consumerNoteTitle=${consumerNoteTitle}   preInfoEnabled=${bool[0]}   preInfoTitle=${preInfoTitle}   preInfoText=${preInfoText}   postInfoEnabled=${bool[0]}   postInfoTitle=${postInfoTitle}   postInfoText=${postInfoText}


        ${companySuffix}=  FakerLibrary.companySuffix
        # ${latti}=  get_latitude
        # ${longi}=  get_longitude
        # ${postcode}=  FakerLibrary.postcode
        # ${address}=  get_address
        ${latti}  ${longi}  ${postcode}  ${address}=  get_lat_long_add_pin
        ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
        Set Suite Variable  ${tz}
        ${description}=  FakerLibrary.sentence
        ${snote}=  FakerLibrary.Word
        ${dis}=  FakerLibrary.Word
        ${list}=  Create List  1  2  3  4  5  6  7
        ${sTime}=  add_timezone_time  ${tz}  0  15  
        ${eTime}=  add_timezone_time  ${tz}  3  00  
        ${DAY}=  db.get_date_by_timezone  ${tz}
        ${resp}=  Create Location  ${loc}  ${longi}  ${latti}  www.${companySuffix}.com  ${postcode}   ${address}  free  True  Weekly  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable   ${lid1}  ${resp.json()} 

        ${capacity}=   Random Int   min=20   max=100
        ${parallel}=   Random Int   min=1   max=2
        ${sTime}=  add_timezone_time  ${tz}  0  30  
        ${eTime}=  add_timezone_time  ${tz}  0  60  
        ${list}=  Create List  1  2  3  4  5  6  7
        ${DAY}=  db.get_date_by_timezone  ${tz}   
        Set Suite Variable  ${DAY}

        ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${lid1}  ${s_id10}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${qid1}  ${resp.json()}

        ${resp}=  AddCustomer  ${CUSERNAME9}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${cid}  ${resp.json()}

        # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME9}
        # Should Be Equal As Strings  ${resp.status_code}  200
        # Set Suite Variable  ${cid}  ${resp.json()[0]['id']}
        
        ${resp}=  Add To Waitlist  ${cid}  ${s_id10}  ${qid1}  ${DAY}  hi  ${bool[1]}  ${cid}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${wid1}  ${wid[0]}
        sleep  02s
          
        ${resp}=  Update Service with info   ${s_id10}  ${SERVICE10}  ${Description1}   ${ser_durtn}    ${bool[1]}    ${notifytype[1]}  ${EMPTY}  ${Total1}   ${status[0]}   ${btype}  ${bool[0]}  ${bool[0]}   ${serviceType[0]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  422
        Should Be Equal As Strings  "${resp.json()}"  "${SERVICETYPE_CAN_NOT_CHANGE_USED_IN_WL}"



JD-TC-Update Service With info-4-Service_type
        [Documentation]     Checking Service Type in before and after taking appointment
        ${resp}=  Encrypted Provider Login  ${multilocPro[2]}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        clear_service       ${multilocPro[2]}

        ${pkg_id}=   get_highest_license_pkg
        Log   ${pkg_id}
        Set Suite Variable     ${pkgId}   ${pkg_id[0]}

        ${resp}=  Change License Package  ${pkgId}
        Should Be Equal As Strings    ${resp.status_code}   200
 
        ${ser_durtn}=   Random Int   min=2   max=10
        ${description}=  FakerLibrary.sentence
        ${Total1}=   Random Int   min=100   max=500
        ${Total1}=  Convert To Number  ${Total1}  1
        # ${resp}=  Create Service with info  ${SERVICE1}  ${description}  ${service_duration[1]}   ${bool[1]}    ${notifytype[2]}  ${EMPTY}  ${EMPTY}   ${status[0]}   ${btype}  ${bool[0]}   ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        ${consumerNoteTitle}=  FakerLibrary.sentence    
        ${preInfoTitle}=  FakerLibrary.sentence   
        ${preInfoText}=  FakerLibrary.sentence  
        ${postInfoTitle}=  FakerLibrary.sentence  
        ${postInfoText}=  FakerLibrary.sentence
        ${resp}=  Create Service with info    ${SERVICE10}  ${description}   ${ser_durtn}    ${bool[1]}    ${notifytype[1]}  ${EMPTY}  ${Total1}   ${status[0]}   ${btype}  ${bool[0]}  ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${EMPTY}   ${EMPTY}   ${postInfoEnabled[0]}   ${EMPTY}   ${EMPTY}
        Should Be Equal As Strings  ${resp.status_code}  200  
        Set Suite Variable    ${s_id1}    ${resp.json()} 
        ${resp}=   Get Service By Id   ${s_id1} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings   ${resp.json()['serviceType']}   ${serviceType[1]}
        Verify Response  ${resp}  name=${SERVICE10}  description=${description}  serviceDuration=${ser_durtn}  notification=${bool[1]}  notificationType=${notifytype[1]}   totalAmount=${Total1}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}
        Verify Response  ${resp}  consumerNoteMandatory=${bool[0]}   consumerNoteTitle=${consumerNoteTitle}   preInfoEnabled=${bool[0]}   preInfoTitle=${EMPTY}   preInfoText=${EMPTY}   postInfoEnabled=${bool[0]}   postInfoTitle=${EMPTY}   postInfoText=${EMPTY}

                                                            
        ${resp}=  Update Service with info   ${s_id1}   ${SERVICE10}  ${description}   ${ser_durtn}    ${bool[1]}    ${notifytype[1]}  ${EMPTY}  ${Total1}   ${status[0]}   ${btype}  ${bool[0]}  ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[1]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[1]}   ${postInfoTitle}   ${postInfoText}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200


        ${resp}=   Get Service By Id   ${s_id1} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings   ${resp.json()['serviceType']}   ${serviceType[1]}
        Verify Response  ${resp}  name=${SERVICE10}  description=${description}  serviceDuration=${ser_durtn}  notification=${bool[1]}  notificationType=${notifytype[1]}  totalAmount=${Total1}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}
        Verify Response  ${resp}  consumerNoteMandatory=${bool[0]}   consumerNoteTitle=${consumerNoteTitle}   preInfoEnabled=${bool[1]}   preInfoTitle=${preInfoTitle}   preInfoText=${preInfoText}   postInfoEnabled=${bool[1]}   postInfoTitle=${postInfoTitle}   postInfoText=${postInfoText}


        ${companySuffix}=  FakerLibrary.companySuffix
        # ${latti}=  get_latitude
        # ${longi}=  get_longitude
        # ${postcode}=  FakerLibrary.postcode
        # ${address}=  get_address
        ${latti}  ${longi}  ${postcode}  ${address}=  get_lat_long_add_pin
        ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
        Set Suite Variable  ${tz}
        ${description}=  FakerLibrary.sentence
        ${snote}=  FakerLibrary.Word
        ${dis}=  FakerLibrary.Word
        ${list}=  Create List  1  2  3  4  5  6  7
        ${sTime}=  add_timezone_time  ${tz}  0  15  
        ${eTime}=  add_timezone_time  ${tz}  3  00  
        ${DAY}=  db.get_date_by_timezone  ${tz}
        ${resp}=  Create Location  ${loc}  ${longi}  ${latti}  www.${companySuffix}.com  ${postcode}   ${address}  free  True  Weekly  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable   ${lid97}  ${resp.json()} 

       
        ${resp}=   Get jaldeeIntegration Settings
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

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

        ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid97}  ${duration}  ${bool1}   ${s_id1}
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
        ${serr}=   Create Dictionary  id=${s_id1}
        ${ser}=  Create List   ${serr} 
    
     
        ${appt_sh}=   Create Dictionary  id=${sch_id}
        ${appt_shd}=    Create List   ${appt_sh}
        ${app_status}=    Create List   ${apptStatus[1]}
        ${resp}=   Create Appointment QueueSet for Provider    ${s_name[0]}   ${s_name[1]}   ${s_desc}   ${fieldList}       ${ser}     ${EMPTY}   ${EMPTY}    ${appt_shd}    ${app_status}         ${statusboard_type[0]}   ${service_list}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${sba_id1}  ${resp.json()}

        ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id1}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
        Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

        ${resp}=  AddCustomer  ${CUSERNAME8}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid}  ${resp.json()}

        # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME8}
        # Log   ${resp.json()}
        # Should Be Equal As Strings  ${resp.status_code}  200
        # Set Test Variable  ${cid}   ${resp.json()[0]['id']}

        ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
        ${apptfor}=   Create List  ${apptfor1}
        ${cnote}=   FakerLibrary.word
        ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id1}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
        Set Test Variable  ${apptid1}  ${apptid[0]}

        ${resp}=  Get Bill By UUId  ${apptid1}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['uuid']}  ${apptid1}
        sleep  02s

        ${resp}=   Update Service with info   ${s_id1}  ${SERVICE10}  ${description}   ${ser_durtn}    ${bool[1]}    ${notifytype[1]}  ${EMPTY}  ${Total1}   ${status[0]}   ${btype}  ${bool[0]}  ${bool[0]}   ${serviceType[0]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  422
        Should Be Equal As Strings  "${resp.json()}"  "${SERVICETYPE_CAN_NOT_CHANGE_USED_IN_APPT}"



JD-TC-Update Service With info-5-Prepayment_amt
        [Documentation]  update  a service to set prepayment amount 0
        ${resp}=   Billable
        clear_service      ${resp}
        ${description}=  FakerLibrary.sentence
        ${min_pre}=   Random Int   min=10   max=50
        ${Total}=   Random Int   min=100   max=500
        ${min_pre}=  Convert To Number  ${min_pre}  1
        ${Total}=  Convert To Number  ${Total}  1

        ${consumerNoteTitle}=  FakerLibrary.sentence    
        ${preInfoTitle}=  FakerLibrary.sentence   
        ${preInfoText}=  FakerLibrary.sentence  
        ${postInfoTitle}=  FakerLibrary.sentence  
        ${postInfoText}=  FakerLibrary.sentence
        # ${resp}=  Create Service with info    ${SERVICE10}  ${description}   ${ser_durtn}    ${bool[1]}    ${notifytype[1]}  ${EMPTY}  ${Total1}   ${status[0]}   ${btype}  ${bool[0]}  ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        
        ${resp}=  Create Service with info  ${SERVICE4}  ${description}  ${service_duration[1]}  ${bool[1]}  ${notifytype[1]}  ${EMPTY}  ${Total}  ${status[0]}  ${btype}  ${bool[0]}  ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable   ${id4}   ${resp.json()}
        ${resp}=   Get Service By Id  ${id4}
        Verify Response  ${resp}  name=${SERVICE4}  description=${description}   serviceDuration=${service_duration[1]}    notification=${bool[1]}  notificationType=${notifytype[1]}  totalAmount=${Total}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}
        Verify Response  ${resp}  consumerNoteMandatory=${bool[0]}   consumerNoteTitle=${consumerNoteTitle}   preInfoEnabled=${bool[0]}   preInfoTitle=${preInfoTitle}   preInfoText=${preInfoText}   postInfoEnabled=${bool[0]}   postInfoTitle=${postInfoTitle}   postInfoText=${postInfoText}

        
        ${min_pre1}=   FakerLibrary.pyfloat   left_digits=2   right_digits=2   positive=True
        ${Total1}=   FakerLibrary.pyfloat   left_digits=3   right_digits=2   positive=True
        # ${resp}=  Update Service with info  ${id}  ${SERVICE2}  ${description}   ${service_duration[3]}  ${bool[0]}   ${notifytype[0]}  ${min_pre}  ${Total}  ${status[0]}  ${btype}  ${bool[1]}  ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        
        ${resp}=  Update Service with info  ${id4}  ${SERVICE7}   ${description}   ${service_duration[3]}  ${bool[1]}   ${notifytype[2]}  ${EMPTY}  ${Total1}  ${status[0]}  ${btype}  ${bool[0]}  ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  02s
        ${resp}=   Get Service By Id  ${id4}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  name=${SERVICE7}  description=${description}  serviceDuration=${service_duration[3]}  notification=${bool[1]}  notificationType=${notifytype[2]}  totalAmount=${Total1}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}
        Verify Response  ${resp}  consumerNoteMandatory=${bool[0]}   consumerNoteTitle=${consumerNoteTitle}   preInfoEnabled=${bool[0]}   preInfoTitle=${preInfoTitle}   preInfoText=${preInfoText}   postInfoEnabled=${bool[0]}   postInfoTitle=${postInfoTitle}   postInfoText=${postInfoText}



JD-TC-Update Service With info-6-Change_Prepayment_amt

        [Documentation]   Create a service with PrePayment  and  Update with 'remove_pre_payment Amount'
        ${resp}=   Billable
        clear_service      ${resp}
        ${description}=  FakerLibrary.sentence
        ${min_pre}=   Random Int   min=10   max=50
        ${Total}=   Random Int   min=100   max=500
        ${min_pre}=  Convert To Number  ${min_pre}  1
        ${Total}=  Convert To Number  ${Total}  1

        ${consumerNoteTitle}=  FakerLibrary.sentence    
        ${preInfoTitle}=  FakerLibrary.sentence   
        ${preInfoText}=  FakerLibrary.sentence  
        ${postInfoTitle}=  FakerLibrary.sentence  
        ${postInfoText}=  FakerLibrary.sentence

        # ${resp}=  Create Service with info    ${SERVICE10}  ${description}   ${ser_durtn}    ${bool[1]}    ${notifytype[1]}  ${EMPTY}  ${Total1}   ${status[0]}   ${btype}  ${bool[0]}  ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        
        ${resp}=  Create Service with info  ${SERVICE6}  ${description}   ${service_duration[3]}  ${bool[1]}  ${notifytype[2]}  ${min_pre}  ${Total}  ${status[0]}  ${btype}  ${bool[1]}   ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable   ${sid26}  ${resp.json()}
        ${resp}=   Get Service By Id  ${sid26}
        Verify Response  ${resp}  name=${SERVICE6}  description=${description}   serviceDuration=${service_duration[3]}   notification=${bool[1]}   notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre}  totalAmount=${Total}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}
        Verify Response  ${resp}  consumerNoteMandatory=${bool[0]}   consumerNoteTitle=${consumerNoteTitle}   preInfoEnabled=${bool[0]}   preInfoTitle=${preInfoTitle}   preInfoText=${preInfoText}   postInfoEnabled=${bool[0]}   postInfoTitle=${postInfoTitle}   postInfoText=${postInfoText}

        sleep  02s
        ${resp}=  Update Service with info  ${sid26}  ${SERVICE6}  ${description}   ${service_duration[2]}  ${bool[0]}  ${notifytype[0]}  0  ${Total}  ${status[0]}  ${btype}  ${bool[0]}   ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${resp}=   Get Service By Id  ${sid26}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  name=${SERVICE6}  description=${description}  serviceDuration=${service_duration[2]}  notification=${bool[0]}  notificationType=${notifytype[0]}  totalAmount=${Total}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}     
        Verify Response  ${resp}  consumerNoteMandatory=${bool[0]}   consumerNoteTitle=${consumerNoteTitle}   preInfoEnabled=${bool[0]}   preInfoTitle=${preInfoTitle}   preInfoText=${preInfoText}   postInfoEnabled=${bool[0]}   postInfoTitle=${postInfoTitle}   postInfoText=${postInfoText}



JD-TC-Update Service With info-7-Change_Prepayment_amt
        [Documentation]   Create service in a non billable domain and update service like billable (updation is not possible) 
        ${resp}=   Non Billable
        clear_service      ${resp}
        ${description}=  FakerLibrary.sentence
        ${min_pre}=   Random Int   min=10   max=50
        ${Total}=   Random Int   min=100   max=500
        ${min_pre}=  Convert To Number  ${min_pre}  1
        ${Total}=  Convert To Number  ${Total}  1

        ${consumerNoteTitle}=  FakerLibrary.sentence    
        ${preInfoTitle}=  FakerLibrary.sentence   
        ${preInfoText}=  FakerLibrary.sentence  
        ${postInfoTitle}=  FakerLibrary.sentence  
        ${postInfoText}=  FakerLibrary.sentence

        ${resp}=  Create Service with info  ${SERVICE7}  ${description}  ${service_duration[2]}  ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${EMPTY}  ${status[0]}  ${btype}  ${bool[0]}  ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        Set Test Variable   ${sid27}  ${resp.json()}
        ${resp}=   Get Service By Id  ${sid27}
        Verify Response  ${resp}  name=${SERVICE7}  description=${description}  serviceDuration=${service_duration[2]}  notification=${bool[1]}  notificationType=${notifytype[2]}  totalAmount=0.0  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}
        Verify Response  ${resp}  consumerNoteMandatory=${bool[0]}   consumerNoteTitle=${consumerNoteTitle}   preInfoEnabled=${bool[0]}   preInfoTitle=${preInfoTitle}   preInfoText=${preInfoText}   postInfoEnabled=${bool[0]}   postInfoTitle=${postInfoTitle}   postInfoText=${postInfoText}
        sleep  02s

        ${resp}=  Update Service with info  ${sid27}  ${SERVICE4}  ${description}  ${service_duration[2]}  ${bool[0]}  ${notifytype[0]}  ${min_pre}  ${Total}  ${status[0]}  ${btype}  ${bool[0]}  ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${resp}=   Get Service By Id  ${sid27}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  name=${SERVICE4}  description=${description}  serviceDuration=${service_duration[2]}  notification=${bool[0]}  notificationType=${notifytype[0]}  totalAmount=0.0  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}
        Verify Response  ${resp}  consumerNoteMandatory=${bool[0]}   consumerNoteTitle=${consumerNoteTitle}   preInfoEnabled=${bool[0]}   preInfoTitle=${preInfoTitle}   preInfoText=${preInfoText}   postInfoEnabled=${bool[0]}   postInfoTitle=${postInfoTitle}   postInfoText=${postInfoText}


JD-TC-Update Service With info-8- consumer_Note_Mandatory

        [Documentation]    Update  consumer note mandatory before add service to queue 
        # ${multilocPro}=  MultiLocation
        Log  ${multilocPro}
        Set Suite Variable   ${multilocPro}
        ${len}=  Get Length  ${multilocPro}
        ${resp}=  Encrypted Provider Login  ${multilocPro[2]}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        clear_service       ${multilocPro[2]}
        ${ser_durtn}=   Random Int   min=2   max=10
        ${description}=  FakerLibrary.sentence
        ${Total1}=   Random Int   min=100   max=500
        ${Total1}=  Convert To Number  ${Total1}  1

        ${consumerNoteTitle}=  FakerLibrary.sentence    
        ${preInfoTitle}=  FakerLibrary.sentence   
        ${preInfoText}=  FakerLibrary.sentence  
        ${postInfoTitle}=  FakerLibrary.sentence  
        ${postInfoText}=  FakerLibrary.sentence
        Log   ${virtualCallingModes}
        # ${resp}=  Create Service with info  ${SERVICE1}  ${description}  ${service_duration[1]}   ${bool[1]}    ${notifytype[2]}  ${EMPTY}  ${EMPTY}   ${status[0]}   ${btype}  ${bool[0]}   ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        
        ${resp}=  Create Service with info    ${SERVICE3}  ${description}   ${ser_durtn}    ${bool[1]}    ${notifytype[1]}  ${EMPTY}  ${Total1}   ${status[0]}   ${btype}  ${bool[0]}  ${bool[0]}   ${serviceType[0]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        Should Be Equal As Strings  ${resp.status_code}  200  
        Set Suite Variable    ${s_id3}    ${resp.json()} 
        ${resp}=   Get Service By Id   ${s_id3} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings   ${resp.json()['serviceType']}   ${serviceType[0]}
        Verify Response  ${resp}  name=${SERVICE3}  description=${description}  serviceDuration=${ser_durtn}  notification=${bool[1]}  notificationType=${notifytype[1]}   totalAmount=${Total1}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}
        Verify Response  ${resp}  consumerNoteMandatory=${bool[0]}   consumerNoteTitle=${consumerNoteTitle}   preInfoEnabled=${bool[0]}   preInfoTitle=${preInfoTitle}   preInfoText=${preInfoText}   postInfoEnabled=${bool[0]}   postInfoTitle=${postInfoTitle}   postInfoText=${postInfoText}

        
        ${resp}=  Update Service with info   ${s_id3}  ${SERVICE3}  ${description}   ${ser_durtn}    ${bool[1]}    ${notifytype[1]}  ${EMPTY}  ${Total1}   ${status[0]}   ${btype}  ${bool[0]}  ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[1]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200


        ${resp}=   Get Service By Id   ${s_id3} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings   ${resp.json()['serviceType']}   ${serviceType[1]}
        Verify Response  ${resp}  name=${SERVICE3}  description=${description}  serviceDuration=${ser_durtn}  notification=${bool[1]}  notificationType=${notifytype[1]}    totalAmount=${Total1}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}
        Verify Response  ${resp}  consumerNoteMandatory=${bool[1]}   consumerNoteTitle=${consumerNoteTitle}   preInfoEnabled=${bool[0]}   preInfoTitle=${preInfoTitle}   preInfoText=${preInfoText}   postInfoEnabled=${bool[0]}   postInfoTitle=${postInfoTitle}   postInfoText=${postInfoText}


        

JD-TC-Update Service With info-9- consumer_Note_Mandatory

        [Documentation]    Update  consumer note mandatory after add service to queue
        # ${multilocPro}=  MultiLocation
        Log  ${multilocPro}
        Set Suite Variable   ${multilocPro}
        ${len}=  Get Length  ${multilocPro}
        ${resp}=  Encrypted Provider Login  ${multilocPro[3]}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        clear_service       ${multilocPro[3]}
        ${ser_durtn}=   Random Int   min=2   max=10
        ${description}=  FakerLibrary.sentence
        ${Total1}=   Random Int   min=100   max=500
        ${Total1}=  Convert To Number  ${Total1}  1

        ${consumerNoteTitle}=  FakerLibrary.sentence    
        ${preInfoTitle}=  FakerLibrary.sentence   
        ${preInfoText}=  FakerLibrary.sentence  
        ${postInfoTitle}=  FakerLibrary.sentence  
        ${postInfoText}=  FakerLibrary.sentence
        Log   ${virtualCallingModes}
        # ${resp}=  Create Service with info  ${SERVICE1}  ${description}  ${service_duration[1]}   ${bool[1]}    ${notifytype[2]}  ${EMPTY}  ${EMPTY}   ${status[0]}   ${btype}  ${bool[0]}   ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        
        ${resp}=  Create Service with info    ${SERVICE3}  ${description}   ${ser_durtn}    ${bool[1]}    ${notifytype[1]}  ${EMPTY}  ${Total1}   ${status[0]}   ${btype}  ${bool[0]}  ${bool[0]}   ${serviceType[0]}   ${vstype}   ${virtualCallingModes}   ${NULL}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        Should Be Equal As Strings  ${resp.status_code}  200  
        Set Suite Variable    ${s_id3}    ${resp.json()} 
        ${resp}=   Get Service By Id   ${s_id3} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings   ${resp.json()['serviceType']}   ${serviceType[0]}
        Verify Response  ${resp}  name=${SERVICE3}  description=${description}  serviceDuration=${ser_durtn}  notification=${bool[1]}  notificationType=${notifytype[1]}  totalAmount=${Total1}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}
        Verify Response  ${resp}  consumerNoteMandatory=${bool[0]}   consumerNoteTitle=${consumerNoteTitle}   preInfoEnabled=${bool[0]}   preInfoTitle=${preInfoTitle}   preInfoText=${preInfoText}   postInfoEnabled=${bool[0]}   postInfoTitle=${postInfoTitle}   postInfoText=${postInfoText}


        ${capacity}=   Random Int   min=20   max=100
        ${parallel}=   Random Int   min=1   max=2
        ${sTime}=  add_timezone_time  ${tz}  0  30  
        ${eTime}=  add_timezone_time  ${tz}  0  60  
        ${list}=  Create List  1  2  3  4  5  6  7
        ${DAY}=  db.get_date_by_timezone  ${tz}   
        Set Suite Variable  ${DAY}

        ${resp}=    Get Locations
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${lid88}  ${resp.json()[0]['id']}

        ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${lid88}  ${s_id3}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${qid1}  ${resp.json()}


        ${resp}=  Update Service with info   ${s_id3}  ${SERVICE3}  ${description}   ${ser_durtn}    ${bool[1]}    ${notifytype[1]}  ${EMPTY}  ${Total1}   ${status[0]}   ${btype}  ${bool[0]}  ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[1]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200


        ${resp}=   Get Service By Id   ${s_id3} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings   ${resp.json()['serviceType']}   ${serviceType[1]}
        Verify Response  ${resp}  name=${SERVICE3}  description=${description}  serviceDuration=${ser_durtn}  notification=${bool[1]}  notificationType=${notifytype[1]}   totalAmount=${Total1}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}
        Verify Response  ${resp}  consumerNoteMandatory=${bool[1]}   consumerNoteTitle=${consumerNoteTitle}   preInfoEnabled=${bool[0]}   preInfoTitle=${preInfoTitle}   preInfoText=${preInfoText}   postInfoEnabled=${bool[0]}   postInfoTitle=${postInfoTitle}   postInfoText=${postInfoText}





JD-TC-Update Service With info-10- consumer_Note_Mandatory

        [Documentation]    Update  consumer note mandatory after add a customer to waitlist by provider
        # ${multilocPro}=  MultiLocation
        Log  ${multilocPro}
        Set Suite Variable   ${multilocPro}
        ${len}=  Get Length  ${multilocPro}
        ${resp}=  Encrypted Provider Login  ${multilocPro[4]}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        clear_service       ${multilocPro[4]}
        ${ser_durtn}=   Random Int   min=2   max=10
        ${description}=  FakerLibrary.sentence
        ${Total1}=   Random Int   min=100   max=500
        ${Total1}=  Convert To Number  ${Total1}  1

        ${consumerNoteTitle}=  FakerLibrary.sentence    
        ${preInfoTitle}=  FakerLibrary.sentence   
        ${preInfoText}=  FakerLibrary.sentence  
        ${postInfoTitle}=  FakerLibrary.sentence  
        ${postInfoText}=  FakerLibrary.sentence
        Log   ${virtualCallingModes}
        # ${resp}=  Create Service with info  ${SERVICE1}  ${description}  ${service_duration[1]}   ${bool[1]}    ${notifytype[2]}  ${EMPTY}  ${EMPTY}   ${status[0]}   ${btype}  ${bool[0]}   ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        
        ${resp}=  Create Service with info    ${SERVICE3}  ${description}   ${ser_durtn}    ${bool[1]}    ${notifytype[1]}  ${EMPTY}  ${Total1}   ${status[0]}   ${btype}  ${bool[0]}  ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[1]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        Should Be Equal As Strings  ${resp.status_code}  200  
        Set Suite Variable    ${s_id3}    ${resp.json()} 
        ${resp}=   Get Service By Id   ${s_id3} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings   ${resp.json()['serviceType']}   ${serviceType[1]}
        Verify Response  ${resp}  name=${SERVICE3}  description=${description}  serviceDuration=${ser_durtn}  notification=${bool[1]}  notificationType=${notifytype[1]}   totalAmount=${Total1}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}
        Verify Response  ${resp}  consumerNoteMandatory=${bool[1]}   consumerNoteTitle=${consumerNoteTitle}   preInfoEnabled=${bool[0]}   preInfoTitle=${preInfoTitle}   preInfoText=${preInfoText}   postInfoEnabled=${bool[0]}   postInfoTitle=${postInfoTitle}   postInfoText=${postInfoText}


        ${capacity}=   Random Int   min=20   max=100
        ${parallel}=   Random Int   min=1   max=2
        ${sTime}=  add_timezone_time  ${tz}  0  30  
        ${eTime}=  add_timezone_time  ${tz}  0  60  
        ${list}=  Create List  1  2  3  4  5  6  7
        ${DAY}=  db.get_date_by_timezone  ${tz}   
        Set Suite Variable  ${DAY}

        ${resp}=    Get Locations
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${lid79}  ${resp.json()[0]['id']}

        ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${lid79}  ${s_id3}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${qid1}  ${resp.json()}

        ${resp}=  AddCustomer  ${CUSERNAME9}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${cid}  ${resp.json()}

        # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME9}
        # Should Be Equal As Strings  ${resp.status_code}  200
        # Set Suite Variable  ${cid}  ${resp.json()[0]['id']}
        
        ${resp}=  Add To Waitlist  ${cid}  ${s_id3}  ${qid1}  ${DAY}  ${EMPTY}  ${bool[1]}  ${cid}
        Log  ${resp.json()}
        ${CONSUMER_NOTE_EMPTY}=  Format String  ${INVALID_CONSUMER_NOTE}  ${consumerNoteTitle}
        Should Be Equal As Strings  ${resp.status_code}  422
        Should Be Equal As Strings   ${resp.json()}   ${CONSUMER_NOTE_EMPTY}


        sleep  02s
        ${consumerNote}=  FakerLibrary.sentence

        ${resp}=  AddCustomer  ${CUSERNAME13}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${cid13}  ${resp.json()}

        # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME13}
        # Should Be Equal As Strings  ${resp.status_code}  200
        # Set Suite Variable  ${cid13}  ${resp.json()[0]['id']}
        ${resp}=  Add To Waitlist  ${cid13}  ${s_id3}  ${qid1}  ${DAY}  ${consumerNote}  ${bool[1]}  ${cid13}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${wid13}  ${wid[0]}

        ${resp}=  Get Waitlist By Id  ${wid13} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
          
        sleep  02s
        ${resp}=  Update Service with info   ${s_id3}  ${SERVICE9}  ${description}   ${ser_durtn}    ${bool[1]}    ${notifytype[1]}  ${EMPTY}  ${Total1}   ${status[0]}   ${btype}  ${bool[0]}  ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[1]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[1]}   ${postInfoTitle}   ${postInfoText}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=   Get Service By Id   ${s_id3} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  name=${SERVICE9}  description=${description}  serviceDuration=${ser_durtn}  notification=${bool[1]}  notificationType=${notifytype[1]}  totalAmount=${Total1}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}
        Verify Response  ${resp}  consumerNoteMandatory=${bool[0]}   consumerNoteTitle=${consumerNoteTitle}   preInfoEnabled=${bool[1]}   preInfoTitle=${preInfoTitle}   preInfoText=${preInfoText}   postInfoEnabled=${bool[1]}   postInfoTitle=${postInfoTitle}   postInfoText=${postInfoText}

        



JD-TC-Update Service With info-11- consumer_Note_Mandatory

        [Documentation]    Update  consumer note mandatory after consumer taking checkin
        # ${multilocPro}=  MultiLocation
        Log  ${multilocPro}
        Set Suite Variable   ${multilocPro}
        ${len}=  Get Length  ${multilocPro}
        ${resp}=  Encrypted Provider Login  ${multilocPro[5]}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        clear_service       ${multilocPro[5]}
        ${ser_durtn}=   Random Int   min=2   max=10
        ${description}=  FakerLibrary.sentence
        ${Total1}=   Random Int   min=100   max=500
        ${Total1}=  Convert To Number  ${Total1}  1

        ${consumerNoteTitle}=  FakerLibrary.sentence    
        ${preInfoTitle}=  FakerLibrary.sentence   
        ${preInfoText}=  FakerLibrary.sentence  
        ${postInfoTitle}=  FakerLibrary.sentence  
        ${postInfoText}=  FakerLibrary.sentence
        Log   ${virtualCallingModes}
        # ${resp}=  Create Service with info  ${SERVICE1}  ${description}  ${service_duration[1]}   ${bool[1]}    ${notifytype[2]}  ${EMPTY}  ${EMPTY}   ${status[0]}   ${btype}  ${bool[0]}   ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        
        ${resp}=  Create Service with info    ${SERVICE3}  ${description}   ${ser_durtn}    ${bool[1]}    ${notifytype[1]}  ${EMPTY}  ${Total1}   ${status[0]}   ${btype}  ${bool[0]}  ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[1]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        Should Be Equal As Strings  ${resp.status_code}  200  
        Set Suite Variable    ${s_id3}    ${resp.json()} 
        ${resp}=   Get Service By Id   ${s_id3} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings   ${resp.json()['serviceType']}   ${serviceType[1]}
        Verify Response  ${resp}  name=${SERVICE3}  description=${description}  serviceDuration=${ser_durtn}  notification=${bool[1]}  notificationType=${notifytype[1]}   totalAmount=${Total1}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}
        Verify Response  ${resp}  consumerNoteMandatory=${bool[1]}   consumerNoteTitle=${consumerNoteTitle}   preInfoEnabled=${bool[0]}   preInfoTitle=${preInfoTitle}   preInfoText=${preInfoText}   postInfoEnabled=${bool[0]}   postInfoTitle=${postInfoTitle}   postInfoText=${postInfoText}

     
        ${capacity}=   Random Int   min=20   max=100
        ${parallel}=   Random Int   min=1   max=2
        ${sTime}=  add_timezone_time  ${tz}  0  30  
        ${eTime}=  add_timezone_time  ${tz}  0  60  
        ${list}=  Create List  1  2  3  4  5  6  7
        ${DAY}=  db.get_date_by_timezone  ${tz}   
        Set Suite Variable  ${DAY}

        ${resp}=    Get Locations
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${lid76}  ${resp.json()[0]['id']}

        ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${lid76}  ${s_id3}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${qid1}  ${resp.json()}

        
        ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200 
        ${cid7}=  get_id  ${CUSERNAME7} 

        ${pid98}=  get_acc_id  ${multilocPro[5]}
        ${resp}=  Add To Waitlist Consumers  ${pid98}  ${qid1}  ${DAY}  ${s_id3}  ${EMPTY}  ${bool[0]}  0
        Log  ${resp.json()}
        ${CONSUMER_NOTE_EMPTY}=  Format String  ${INVALID_CONSUMER_NOTE}  ${consumerNoteTitle}
        Should Be Equal As Strings  ${resp.status_code}  422
        Should Be Equal As Strings   ${resp.json()}   ${CONSUMER_NOTE_EMPTY}


        ${cnote}=   FakerLibrary.word
        ${resp}=  Add To Waitlist Consumers  ${pid98}  ${qid1}  ${DAY}  ${s_id3}  ${cnote}  ${bool[0]}  0
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200    
        
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${wid7}  ${wid[0]}

        ${resp}=  Encrypted Provider Login  ${multilocPro[5]}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME7}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid}  ${resp.json()[0]['id']}

        ${resp}=   Consumer Login  ${CUSERNAME7}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Get consumer Waitlist By Id   ${wid7}  ${pid98}   
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}  partySize=1   waitlistedBy=CONSUMER
        Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE3}
        Should Be Equal As Strings  ${resp.json()['service']['id']}  ${s_id3}
        Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid7}           
        Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${cid}  
        Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${qid1}


        ${resp}=  Encrypted Provider Login  ${multilocPro[5]}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        

        ${resp}=  Update Service with info   ${s_id3}  ${SERVICE9}  ${description}   ${ser_durtn}    ${bool[1]}    ${notifytype[1]}  ${EMPTY}  ${Total1}   ${status[0]}   ${btype}  ${bool[0]}  ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[1]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[1]}   ${postInfoTitle}   ${postInfoText}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=   Get Service By Id   ${s_id3} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  name=${SERVICE9}  description=${description}  serviceDuration=${ser_durtn}  notification=${bool[1]}  notificationType=${notifytype[1]}  totalAmount=${Total1}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}
        Verify Response  ${resp}  consumerNoteMandatory=${bool[0]}   consumerNoteTitle=${consumerNoteTitle}   preInfoEnabled=${bool[1]}   preInfoTitle=${preInfoTitle}   preInfoText=${preInfoText}   postInfoEnabled=${bool[1]}   postInfoTitle=${postInfoTitle}   postInfoText=${postInfoText}



JD-TC-Update Service With info-UH1- consumer_Note_Mandatory

        [Documentation]    Update consumer note mandatory using consumer_note_title as EMPTY
        
        ${resp}=  Encrypted Provider Login  ${multilocPro[4]}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        clear_service       ${multilocPro[4]}
        ${ser_durtn}=   Random Int   min=2   max=10
        ${description}=  FakerLibrary.sentence
        ${Total1}=   Random Int   min=100   max=500
        ${Total1}=  Convert To Number  ${Total1}  1

        ${consumerNoteTitle}=  FakerLibrary.sentence    
        ${preInfoTitle}=  FakerLibrary.sentence   
        ${preInfoText}=  FakerLibrary.sentence  
        ${postInfoTitle}=  FakerLibrary.sentence  
        ${postInfoText}=  FakerLibrary.sentence
        Log   ${virtualCallingModes}
        # ${resp}=  Create Service with info  ${SERVICE1}  ${description}  ${service_duration[1]}   ${bool[1]}    ${notifytype[2]}  ${EMPTY}  ${EMPTY}   ${status[0]}   ${btype}  ${bool[0]}   ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        
        ${resp}=  Create Service with info    ${SERVICE5}  ${description}   ${ser_durtn}    ${bool[1]}    ${notifytype[1]}  ${EMPTY}  ${Total1}   ${status[0]}   ${btype}  ${bool[0]}  ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[1]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        Should Be Equal As Strings  ${resp.status_code}  200  
        Set Suite Variable    ${s_id25}    ${resp.json()} 
        ${resp}=   Get Service By Id   ${s_id25} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings   ${resp.json()['serviceType']}   ${serviceType[1]}
        Verify Response  ${resp}  name=${SERVICE5}  description=${description}  serviceDuration=${ser_durtn}  notification=${bool[1]}  notificationType=${notifytype[1]}  totalAmount=${Total1}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}
        Verify Response  ${resp}  consumerNoteMandatory=${bool[1]}   consumerNoteTitle=${consumerNoteTitle}   preInfoEnabled=${bool[0]}   preInfoTitle=${preInfoTitle}   preInfoText=${preInfoText}   postInfoEnabled=${bool[0]}   postInfoTitle=${postInfoTitle}   postInfoText=${postInfoText}


        ${capacity}=   Random Int   min=20   max=100
        ${parallel}=   Random Int   min=1   max=2
        ${sTime}=  add_timezone_time  ${tz}  0  30  
        ${eTime}=  add_timezone_time  ${tz}  0  60  
        ${list}=  Create List  1  2  3  4  5  6  7
        ${DAY}=  db.get_date_by_timezone  ${tz}   
        Set Suite Variable  ${DAY}

        ${resp}=    Get Locations
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${lid79}  ${resp.json()[0]['id']}

        ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${lid79}  ${s_id25}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${qid25}  ${resp.json()}
        sleep  02s
        
        Set Suite Variable  ${default_note}   Notes

        ${resp}=  Update Service with info   ${s_id25}  ${SERVICE7}  ${description}   ${ser_durtn}    ${bool[1]}    ${notifytype[1]}  ${EMPTY}  ${Total1}   ${status[0]}   ${btype}  ${bool[0]}  ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[1]}   ${EMPTY}   ${preInfoEnabled[1]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[1]}   ${postInfoTitle}   ${postInfoText}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        # Should Be Equal As Strings   "${resp.json()}"   "${INVALID_SERVICE_POST_INFO_TITLE}"

        ${resp}=   Get Service By Id   ${s_id25} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  name=${SERVICE7}  description=${description}  serviceDuration=${ser_durtn}  notification=${bool[1]}  notificationType=${notifytype[1]}  totalAmount=${Total1}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}
        Verify Response  ${resp}  consumerNoteMandatory=${bool[1]}   consumerNoteTitle=${default_note}   preInfoEnabled=${bool[1]}   preInfoTitle=${preInfoTitle}   preInfoText=${preInfoText}   postInfoEnabled=${bool[1]}   postInfoTitle=${postInfoTitle}   postInfoText=${postInfoText}

        ${CONSUMER_NOTE_EMPTY}=  Format String  ${INVALID_CONSUMER_NOTE}  ${default_note}

        ${consumerNote}=  FakerLibrary.sentence

        ${resp}=  AddCustomer  ${CUSERNAME23}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${cid23}  ${resp.json()}

        # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME23}
        # Should Be Equal As Strings  ${resp.status_code}  200
        # Set Suite Variable  ${cid23}  ${resp.json()[0]['id']}
        ${resp}=  Add To Waitlist  ${cid23}  ${s_id25}  ${qid25}  ${DAY}  ${EMPTY}  ${bool[1]}  ${cid23}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  422
        Should Be Equal As Strings   ${resp.json()}    ${CONSUMER_NOTE_EMPTY}



JD-TC-Update Service With info-12-Pre_info_&_Post_info
        [Documentation]     Change Pre_info_&_post_info  status, before and after taking appointment
        ${resp}=  Encrypted Provider Login  ${multilocPro[5]}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        clear_service       ${multilocPro[5]}
        ${ser_durtn}=   Random Int   min=2   max=10
        ${description}=  FakerLibrary.sentence
        ${Total1}=   Random Int   min=100   max=500
        ${Total1}=  Convert To Number  ${Total1}  1
        # ${resp}=  Create Service with info  ${SERVICE1}  ${description}  ${service_duration[1]}   ${bool[1]}    ${notifytype[2]}  ${EMPTY}  ${EMPTY}   ${status[0]}   ${btype}  ${bool[0]}   ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        ${consumerNoteTitle}=  FakerLibrary.sentence    
        ${preInfoTitle}=  FakerLibrary.sentence   
        ${preInfoText}=  FakerLibrary.sentence  
        ${postInfoTitle}=  FakerLibrary.sentence  
        ${postInfoText}=  FakerLibrary.sentence
        ${resp}=  Create Service with info    ${SERVICE3}  ${description}   ${ser_durtn}    ${bool[1]}    ${notifytype[1]}  ${EMPTY}  ${Total1}   ${status[0]}   ${btype}  ${bool[0]}  ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}    ${preInfoEnabled[1]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[1]}   ${postInfoTitle}   ${postInfoText}
        Should Be Equal As Strings  ${resp.status_code}  200  
        Set Suite Variable    ${s_id13}    ${resp.json()} 
        ${resp}=   Get Service By Id   ${s_id13} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings   ${resp.json()['serviceType']}   ${serviceType[1]}
        Verify Response  ${resp}  name=${SERVICE3}  description=${description}  serviceDuration=${ser_durtn}  notification=${bool[1]}  notificationType=${notifytype[1]}  totalAmount=${Total1}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}
        Verify Response  ${resp}  consumerNoteMandatory=${bool[0]}   consumerNoteTitle=${consumerNoteTitle}   preInfoEnabled=${bool[1]}   preInfoTitle=${preInfoTitle}   preInfoText=${preInfoText}   postInfoEnabled=${bool[1]}   postInfoTitle=${postInfoTitle}   postInfoText=${postInfoText}


        ${resp}=    Get Locations
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${lid60}  ${resp.json()[0]['id']}


        ${resp}=   Get jaldeeIntegration Settings
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

        ${DAY1}=  db.get_date_by_timezone  ${tz}
        Set Suite Variable  ${DAY1} 
        ${DAY2}=  db.add_timezone_date  ${tz}  10        
        Set Suite Variable  ${DAY2} 
        ${list}=  Create List  1  2  3  4  5  6  7
        Set Suite Variable  ${list} 
        ${sTime60}=  add_timezone_time  ${tz}  1  30  
        Set Suite Variable   ${sTime60}
        ${delta60}=  FakerLibrary.Random Int  min=10  max=60
        Set Suite Variable  ${delta60}
        ${eTime60}=  add_two   ${sTime60}  ${delta60}
        Set Suite Variable   ${eTime60}
        ${schedule_name60}=  FakerLibrary.bs
        Set Suite Variable  ${schedule_name60}
        ${parallel}=  FakerLibrary.Random Int  min=1  max=10
        ${duration}=  FakerLibrary.Random Int  min=1  max=${delta60}
        ${bool1}=  Random Element  ${bool}

        ${resp}=  Create Appointment Schedule  ${schedule_name60}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime60}  ${eTime60}  ${parallel}    ${parallel}  ${lid60}  ${duration}  ${bool1}   ${s_id13}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${sch_id60}  ${resp.json()}

    
     
        ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id60}  ${DAY1}  ${s_id13}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  scheduleName=${schedule_name60}  scheduleId=${sch_id60}
        Set Test Variable   ${slot60}   ${resp.json()['availableSlots'][0]['time']}

        ${resp}=  AddCustomer  ${CUSERNAME8}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid}  ${resp.json()}

        # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME8}
        # Log   ${resp.json()}
        # Should Be Equal As Strings  ${resp.status_code}  200
        # Set Test Variable  ${cid}   ${resp.json()[0]['id']}

        ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot60}
        ${apptfor}=   Create List  ${apptfor1}
        ${cnote}=   FakerLibrary.word
        ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id13}  ${sch_id60}  ${DAY1}  ${cnote}  ${apptfor}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
        Set Test Variable  ${apptid1}  ${apptid[0]}
        sleep  02s

        ${resp}=  Update Service with info   ${s_id13}   ${SERVICE3}  ${description}   ${ser_durtn}    ${bool[1]}    ${notifytype[1]}  ${EMPTY}  ${Total1}   ${status[0]}   ${btype}  ${bool[0]}  ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${EMPTY}   ${EMPTY}   ${postInfoEnabled[0]}   ${EMPTY}   ${EMPTY}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=   Get Service By Id   ${s_id13} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings   ${resp.json()['serviceType']}   ${serviceType[1]}
        Verify Response  ${resp}  name=${SERVICE3}  description=${description}  serviceDuration=${ser_durtn}  notification=${bool[1]}  notificationType=${notifytype[1]}  totalAmount=${Total1}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}
        Verify Response  ${resp}  consumerNoteMandatory=${bool[0]}   consumerNoteTitle=${consumerNoteTitle}   preInfoEnabled=${bool[0]}   preInfoTitle=${EMPTY}   preInfoText=${EMPTY}   postInfoEnabled=${bool[0]}   postInfoTitle=${EMPTY}   postInfoText=${EMPTY}


JD-TC-Update Service With info-13-Pre_info_&_Post_info

        [Documentation]    Enable pre_info status and try to set pre_info text as EMPTY
        
        ${resp}=  Encrypted Provider Login  ${multilocPro[4]}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        clear_service       ${multilocPro[4]}
        ${ser_durtn}=   Random Int   min=2   max=10
        ${description}=  FakerLibrary.sentence
        ${Total1}=   Random Int   min=100   max=500
        ${Total1}=  Convert To Number  ${Total1}  1

        ${consumerNoteTitle}=  FakerLibrary.sentence    
        ${preInfoTitle}=  FakerLibrary.sentence   
        ${preInfoText}=  FakerLibrary.sentence  
        ${postInfoTitle}=  FakerLibrary.sentence  
        ${postInfoText}=  FakerLibrary.sentence
        Log   ${virtualCallingModes}
        
        ${resp}=  Create Service with info    ${SERVICE5}  ${description}   ${ser_durtn}    ${bool[1]}    ${notifytype[1]}  ${EMPTY}  ${Total1}   ${status[0]}   ${btype}  ${bool[0]}  ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[1]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        Should Be Equal As Strings  ${resp.status_code}  200  
        Set Suite Variable    ${s_id23}    ${resp.json()} 
        ${resp}=   Get Service By Id   ${s_id23} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings   ${resp.json()['serviceType']}   ${serviceType[1]}
        Verify Response  ${resp}  name=${SERVICE5}  description=${description}  serviceDuration=${ser_durtn}  notification=${bool[1]}  notificationType=${notifytype[1]}  totalAmount=${Total1}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}
        Verify Response  ${resp}  consumerNoteMandatory=${bool[1]}   consumerNoteTitle=${consumerNoteTitle}   preInfoEnabled=${bool[0]}   preInfoTitle=${preInfoTitle}   preInfoText=${preInfoText}   postInfoEnabled=${bool[0]}   postInfoTitle=${postInfoTitle}   postInfoText=${postInfoText}


        ${resp}=  Update Service with info   ${s_id23}  ${SERVICE7}  ${description}   ${ser_durtn}    ${bool[1]}    ${notifytype[1]}  ${EMPTY}  ${Total1}   ${status[0]}   ${btype}  ${bool[0]}  ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[1]}   ${preInfoTitle}   ${EMPTY}   ${postInfoEnabled[1]}   ${postInfoTitle}   ${postInfoText}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}   200

        ${resp}=   Get Service By Id   ${s_id23} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  name=${SERVICE7}  description=${description}  serviceDuration=${ser_durtn}  notification=${bool[1]}  notificationType=${notifytype[1]}  totalAmount=${Total1}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}
        Verify Response  ${resp}  consumerNoteMandatory=${bool[0]}   consumerNoteTitle=${consumerNoteTitle}   preInfoEnabled=${bool[1]}   preInfoTitle=${preInfoTitle}   preInfoText=${EMPTY}   postInfoEnabled=${bool[1]}   postInfoTitle=${postInfoTitle}   postInfoText=${postInfoText}


        
JD-TC-Update Service With info-UH2-Pre_info_&_Post_info

        [Documentation]    Enable pre_info status and try to set pre_info title as EMPTY
        
        ${resp}=  Encrypted Provider Login  ${multilocPro[4]}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        clear_service       ${multilocPro[4]}
        ${ser_durtn}=   Random Int   min=2   max=10
        ${description}=  FakerLibrary.sentence
        ${Total1}=   Random Int   min=100   max=500
        ${Total1}=  Convert To Number  ${Total1}  1

        ${consumerNoteTitle}=  FakerLibrary.sentence    
        ${preInfoTitle}=  FakerLibrary.sentence   
        ${preInfoText}=  FakerLibrary.sentence  
        ${postInfoTitle}=  FakerLibrary.sentence  
        ${postInfoText}=  FakerLibrary.sentence
        Log   ${virtualCallingModes}
        
        ${resp}=  Create Service with info    ${SERVICE5}  ${description}   ${ser_durtn}    ${bool[1]}    ${notifytype[1]}  ${EMPTY}  ${Total1}   ${status[0]}   ${btype}  ${bool[0]}  ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[1]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        Should Be Equal As Strings  ${resp.status_code}  200  
        Set Suite Variable    ${s_id22}    ${resp.json()} 
        ${resp}=   Get Service By Id   ${s_id22} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings   ${resp.json()['serviceType']}   ${serviceType[1]}
        Verify Response  ${resp}  name=${SERVICE5}  description=${description}  serviceDuration=${ser_durtn}  notification=${bool[1]}  notificationType=${notifytype[1]}  totalAmount=${Total1}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}
        Verify Response  ${resp}  consumerNoteMandatory=${bool[1]}   consumerNoteTitle=${consumerNoteTitle}   preInfoEnabled=${bool[0]}   preInfoTitle=${preInfoTitle}   preInfoText=${preInfoText}   postInfoEnabled=${bool[0]}   postInfoTitle=${postInfoTitle}   postInfoText=${postInfoText}


        ${resp}=  Update Service with info   ${s_id22}  ${SERVICE7}  ${description}   ${ser_durtn}    ${bool[1]}    ${notifytype[1]}  ${EMPTY}  ${Total1}   ${status[0]}   ${btype}  ${bool[0]}  ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[1]}   ${EMPTY}   ${EMPTY}   ${postInfoEnabled[1]}   ${postInfoTitle}   ${postInfoText}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  422
        Should Be Equal As Strings   ${resp.json()}    ${INVALID_SERVICE_PRE_INFO_TITLE}

      
        
JD-TC-Update Service With info-14-Pre_info_&_Post_info

        [Documentation]    Enable post_info status and try to set post_info text as EMPTY
        
        ${resp}=  Encrypted Provider Login  ${multilocPro[4]}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        clear_service       ${multilocPro[4]}
        ${ser_durtn}=   Random Int   min=2   max=10
        ${description}=  FakerLibrary.sentence
        ${Total1}=   Random Int   min=100   max=500
        ${Total1}=  Convert To Number  ${Total1}  1

        ${consumerNoteTitle}=  FakerLibrary.sentence    
        ${preInfoTitle}=  FakerLibrary.sentence   
        ${preInfoText}=  FakerLibrary.sentence  
        ${postInfoTitle}=  FakerLibrary.sentence  
        ${postInfoText}=  FakerLibrary.sentence
        Log   ${virtualCallingModes}
        # ${resp}=  Create Service with info  ${SERVICE1}  ${description}  ${service_duration[1]}   ${bool[1]}    ${notifytype[2]}  ${EMPTY}  ${EMPTY}   ${status[0]}   ${btype}  ${bool[0]}   ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        
        ${resp}=  Create Service with info    ${SERVICE5}  ${description}   ${ser_durtn}    ${bool[1]}    ${notifytype[1]}  ${EMPTY}  ${Total1}   ${status[0]}   ${btype}  ${bool[0]}  ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[1]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        Should Be Equal As Strings  ${resp.status_code}  200  
        Set Suite Variable    ${s_id24}    ${resp.json()} 
        ${resp}=   Get Service By Id   ${s_id24} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings   ${resp.json()['serviceType']}   ${serviceType[1]}
        Verify Response  ${resp}  name=${SERVICE5}  description=${description}  serviceDuration=${ser_durtn}  notification=${bool[1]}  notificationType=${notifytype[1]}  totalAmount=${Total1}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}
        Verify Response  ${resp}  consumerNoteMandatory=${bool[1]}   consumerNoteTitle=${consumerNoteTitle}   preInfoEnabled=${bool[0]}   preInfoTitle=${preInfoTitle}   preInfoText=${preInfoText}   postInfoEnabled=${bool[0]}   postInfoTitle=${postInfoTitle}   postInfoText=${postInfoText}

        

        ${resp}=  Update Service with info   ${s_id24}  ${SERVICE7}  ${description}   ${ser_durtn}    ${bool[1]}    ${notifytype[1]}  ${EMPTY}  ${Total1}   ${status[0]}   ${btype}  ${bool[0]}  ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[1]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[1]}   ${postInfoTitle}   ${EMPTY}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=   Get Service By Id   ${s_id24} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  name=${SERVICE7}  description=${description}  serviceDuration=${ser_durtn}  notification=${bool[1]}  notificationType=${notifytype[1]}  totalAmount=${Total1}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}
        Verify Response  ${resp}  consumerNoteMandatory=${bool[0]}   consumerNoteTitle=${consumerNoteTitle}   preInfoEnabled=${bool[1]}   preInfoTitle=${preInfoTitle}   preInfoText=${preInfoText}   postInfoEnabled=${bool[1]}   postInfoTitle=${postInfoTitle}   postInfoText=${EMPTY}

        

JD-TC-Update Service With info-UH3-Pre_info_&_Post_info

        [Documentation]    Enable post_info status and try to set post_info title as EMPTY
        
        ${resp}=  Encrypted Provider Login  ${multilocPro[4]}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        clear_service       ${multilocPro[4]}
        ${ser_durtn}=   Random Int   min=2   max=10
        ${description}=  FakerLibrary.sentence
        ${Total1}=   Random Int   min=100   max=500
        ${Total1}=  Convert To Number  ${Total1}  1

        ${consumerNoteTitle}=  FakerLibrary.sentence    
        ${preInfoTitle}=  FakerLibrary.sentence   
        ${preInfoText}=  FakerLibrary.sentence  
        ${postInfoTitle}=  FakerLibrary.sentence  
        ${postInfoText}=  FakerLibrary.sentence
        Log   ${virtualCallingModes}
        
        ${resp}=  Create Service with info    ${SERVICE5}  ${description}   ${ser_durtn}    ${bool[1]}    ${notifytype[1]}  ${EMPTY}  ${Total1}   ${status[0]}   ${btype}  ${bool[0]}  ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[1]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        Should Be Equal As Strings  ${resp.status_code}  200  
        Set Suite Variable    ${s_id33}    ${resp.json()} 
        ${resp}=   Get Service By Id   ${s_id33} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings   ${resp.json()['serviceType']}   ${serviceType[1]}
        Verify Response  ${resp}  name=${SERVICE5}  description=${description}  serviceDuration=${ser_durtn}  notification=${bool[1]}  notificationType=${notifytype[1]}  totalAmount=${Total1}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}
        Verify Response  ${resp}  consumerNoteMandatory=${bool[1]}   consumerNoteTitle=${consumerNoteTitle}   preInfoEnabled=${bool[0]}   preInfoTitle=${preInfoTitle}   preInfoText=${preInfoText}   postInfoEnabled=${bool[0]}   postInfoTitle=${postInfoTitle}   postInfoText=${postInfoText}


        ${resp}=  Update Service with info   ${s_id33}  ${SERVICE7}  ${description}   ${ser_durtn}    ${bool[1]}    ${notifytype[1]}  ${EMPTY}  ${Total1}   ${status[0]}   ${btype}  ${bool[0]}  ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[1]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[1]}   ${EMPTY}   ${EMPTY}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  422
        Should Be Equal As Strings   ${resp.json()}   ${INVALID_SERVICE_POST_INFO_TITLE}

        ${resp}=   Get Service By Id   ${s_id33} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  name=${SERVICE5}  description=${description}  serviceDuration=${ser_durtn}  notification=${bool[1]}  notificationType=${notifytype[1]}  totalAmount=${Total1}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}
        Verify Response  ${resp}  consumerNoteMandatory=${bool[1]}   consumerNoteTitle=${consumerNoteTitle}   preInfoEnabled=${bool[0]}   preInfoTitle=${preInfoTitle}   preInfoText=${preInfoText}   postInfoEnabled=${bool[0]}   postInfoTitle=${postInfoTitle}   postInfoText=${postInfoText}



JD-TC-Update Service With info-UH4

        [Documentation]  Update a service name to  an already existing name
        ${resp}=  Encrypted Provider Login  ${multilocPro[4]}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        clear_service       ${multilocPro[4]}


        ${description}=  FakerLibrary.sentence
        ${min_pre}=   Random Int   min=10   max=50
        ${Total}=   Random Int   min=100   max=500
        ${min_pre}=  Convert To Number  ${min_pre}  1
        ${Total}=  Convert To Number  ${Total}  1

        ${consumerNoteTitle}=  FakerLibrary.sentence    
        ${preInfoTitle}=  FakerLibrary.sentence   
        ${preInfoText}=  FakerLibrary.sentence  
        ${postInfoTitle}=  FakerLibrary.sentence  
        ${postInfoText}=  FakerLibrary.sentence

    
        ${resp}=  Create Service with info  ${SERVICE1}  ${description}   ${service_duration[3]}    ${bool[1]}    ${notifytype[2]}  ${min_pre}  ${Total}  ${status[0]}  ${btype}  ${bool[1]}   ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${id1}  ${resp.json()}
        ${resp}=   Get Service By Id  ${id1}
        Should Be Equal As Strings  ${resp.status_code}  200 
        Verify Response  ${resp}  name=${SERVICE1}  description=${description}  serviceDuration=${service_duration[3]}   notification=${bool[1]}   notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre}  totalAmount=${Total}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}
        Verify Response  ${resp}  consumerNoteMandatory=${bool[0]}   consumerNoteTitle=${consumerNoteTitle}   preInfoEnabled=${bool[0]}   preInfoTitle=${preInfoTitle}   preInfoText=${preInfoText}   postInfoEnabled=${bool[0]}   postInfoTitle=${postInfoTitle}   postInfoText=${postInfoText}

        
        
        ${resp}=  Create Service with info  ${SERVICE2}  ${description}   ${service_duration[4]}  ${bool[1]}    ${notifytype[2]}  ${min_pre}  ${Total}   ${status[0]}  ${btype}  ${bool[1]}   ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${id2}  ${resp.json()} 
        ${resp}=   Get Service By Id  ${id2}
        Should Be Equal As Strings  ${resp.status_code}  200 
        Verify Response  ${resp}  name=${SERVICE2}  description=${description}  serviceDuration=${service_duration[4]}   notification=${bool[1]}   notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre}  totalAmount=${Total}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}
        Verify Response  ${resp}  consumerNoteMandatory=${bool[0]}   consumerNoteTitle=${consumerNoteTitle}   preInfoEnabled=${bool[0]}   preInfoTitle=${preInfoTitle}   preInfoText=${preInfoText}   postInfoEnabled=${bool[0]}   postInfoTitle=${postInfoTitle}   postInfoText=${postInfoText}

        
        ${min_pre1}=   FakerLibrary.pyfloat   left_digits=2   right_digits=2   positive=True
        ${Total1}=   FakerLibrary.pyfloat   left_digits=3   right_digits=2   positive=True
        
        ${resp}=  Update Service with info  ${id1}  ${SERVICE2}  ${description}   ${service_duration[4]}  ${bool[0]}  ${notifytype[1]}  ${min_pre1}  ${Total1}  ${status[0]}  ${btype}  ${bool[1]}   ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        Should Be Equal As Strings  ${resp.status_code}  422
        Should Be Equal As Strings   ${resp.json()}   ${SERVICE_CANT_BE_SAME}



JD-TC-Update Service With info-UH5

        [Documentation]  Update a service without login
        ${description}=  FakerLibrary.sentence
        ${min_pre}=   Random Int   min=10   max=50
        ${Total}=   Random Int   min=100   max=500
        ${min_pre}=  Convert To Number  ${min_pre}  1
        ${Total}=  Convert To Number  ${Total}  1

        ${consumerNoteTitle}=  FakerLibrary.sentence    
        ${preInfoTitle}=  FakerLibrary.sentence   
        ${preInfoText}=  FakerLibrary.sentence  
        ${postInfoTitle}=  FakerLibrary.sentence  
        ${postInfoText}=  FakerLibrary.sentence
        
        ${resp}=  Update Service with info  ${id}  ${SERVICE1}  ${description}  ${service_duration[3]}  ${bool[1]}  ${notifytype[2]}   ${min_pre}   ${Total}  ${status[0]}  ${btype}  ${bool[1]}   ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        Should Be Equal As Strings  ${resp.status_code}  419
        Should Be Equal As Strings   "${resp.json()}"    "${SESSION_EXPIRED}"


JD-TC-Update Service With info-UH6

        [Documentation]  Update a service using consumer login
        ${description}=  FakerLibrary.sentence
        ${min_pre}=   Random Int   min=10   max=50
        ${Total}=   Random Int   min=100   max=500
        ${min_pre}=  Convert To Number  ${min_pre}  1
        ${Total}=  Convert To Number  ${Total}  1
        ${resp}=  ConsumerLogin  ${CUSERNAME8}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${consumerNoteTitle}=  FakerLibrary.sentence    
        ${preInfoTitle}=  FakerLibrary.sentence   
        ${preInfoText}=  FakerLibrary.sentence  
        ${postInfoTitle}=  FakerLibrary.sentence  
        ${postInfoText}=  FakerLibrary.sentence
        
        ${resp}=  Update Service with info  ${id}  ${SERVICE1}  ${description}  ${service_duration[3]}  ${bool[1]}  ${notifytype[2]}  ${min_pre}   ${Total}  ${status[0]}  ${btype}  ${bool[1]}   ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        Should Be Equal As Strings  ${resp.status_code}  401
        Should Be Equal As Strings   ${resp.json()}    ${LOGIN_NO_ACCESS_FOR_URL}


JD-TC-Update Service With info-UH7

        [Documentation]  update service of another provider id
        ${description}=  FakerLibrary.sentence
  
        ${min_pre}=   Random Int  min=1   max=10
        ${Total}=   Random Int  min=11   max=100
        ${resp}=  Encrypted Provider Login  ${PUSERNAME69}  ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}    200
        clear_service       ${PUSERNAME69}

        ${consumerNoteTitle}=  FakerLibrary.sentence    
        ${preInfoTitle}=  FakerLibrary.sentence   
        ${preInfoText}=  FakerLibrary.sentence  
        ${postInfoTitle}=  FakerLibrary.sentence  
        ${postInfoText}=  FakerLibrary.sentence

        ${resp}=  Create Service with info  ${SERVICE1}  ${description}   ${service_duration[3]}    ${bool[1]}    ${notifytype[2]}  ${min_pre}   ${Total}  ${status[0]}  ${btype}   ${bool[1]}   ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${id123}  ${resp.json()}
        ${resp}=  ProviderLogout
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp}=  Encrypted Provider Login  ${PUSERNAME63}  ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}    200
        
        ${resp}=  Update Service with info  ${id123}  ${SERVICE2}  ${description}  ${service_duration[3]}  ${bool[1]}    ${notifytype[2]}  ${min_pre}   ${Total}  ${status[0]}  ${btype}   ${bool[1]}   ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        Should Be Equal As Strings  ${resp.status_code}  401
        Should Be Equal As Strings   ${resp.json()}    ${NO_PERMISSION}


JD-TC-Update Service With info-UH8

        [Documentation]  update a  service for a valid provider with 0 Total amount
        ${resp}=   Billable
        clear_service      ${resp}
        ${description}=  FakerLibrary.sentence
        ${min_pre}=   Random Int   min=10   max=20
        ${Total}=   Random Int   min=21   max=40
        ${min_pre}=  Convert To Number  ${min_pre}  0
        ${Total}=  Convert To Number  ${Total}  0

        ${consumerNoteTitle}=  FakerLibrary.sentence    
        ${preInfoTitle}=  FakerLibrary.sentence   
        ${preInfoText}=  FakerLibrary.sentence  
        ${postInfoTitle}=  FakerLibrary.sentence  
        ${postInfoText}=  FakerLibrary.sentence

        ${resp}=  Create Service with info  ${SERVICE8}  ${description}   ${service_duration[2]}  ${bool[1]}  ${notifytype[2]}  ${min_pre}  ${Total}  ${status[0]}  ${btype}  ${bool[1]}  ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable   ${sid38}  ${resp.json()}
        ${resp}=   Get Service By Id  ${sid38}
        Verify Response  ${resp}  name=${SERVICE8}  description=${description}  serviceDuration=${service_duration[2]}  notification=${bool[1]}  notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre}  totalAmount=${Total}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}
        Verify Response  ${resp}  consumerNoteMandatory=${bool[0]}   consumerNoteTitle=${consumerNoteTitle}   preInfoEnabled=${bool[0]}   preInfoTitle=${preInfoTitle}   preInfoText=${preInfoText}   postInfoEnabled=${bool[0]}   postInfoTitle=${postInfoTitle}   postInfoText=${postInfoText}

        ${resp}=  Update Service with info  ${sid38}  ${SERVICE8}  ${description}   ${service_duration[3]}  ${bool[0]}  ${notifytype[0]}  ${min_pre}  0  ${status[0]}  ${btype}  ${bool[1]}  ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        Should Be Equal As Strings  ${resp.status_code}  200
        # Should Be Equal As Strings  "${resp.json()}"  "${SERVICE_PRICE_REQUIRED}"


JD-TC-Update Service With info-UH9
        [Documentation]  Create a service with prePrePayment and  Update with remove pre payment Amount
        ${resp}=   Billable
        clear_service      ${resp}
        ${description}=  FakerLibrary.sentence
        ${min_pre}=   Random Int   min=10   max=50
        ${Total}=   Random Int   min=100   max=500
        ${min_pre}=  Convert To Number  ${min_pre}  1
        ${Total}=  Convert To Number  ${Total}  1

        ${consumerNoteTitle}=  FakerLibrary.sentence    
        ${preInfoTitle}=  FakerLibrary.sentence   
        ${preInfoText}=  FakerLibrary.sentence  
        ${postInfoTitle}=  FakerLibrary.sentence  
        ${postInfoText}=  FakerLibrary.sentence

        ${resp}=  Create Service with info  ${SERVICE9}  ${description}   ${service_duration[2]}  ${bool[1]}  ${notifytype[2]}  ${min_pre}  ${Total}   ${status[0]}  ${btype}  ${bool[1]}  ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable   ${sid39}  ${resp.json()}
        ${resp}=   Get Service By Id  ${sid39}
        Verify Response  ${resp}  name=${SERVICE9}  description=${description}  serviceDuration=${service_duration[2]}  notification=${bool[1]}  notificationType=${notifytype[2]}  minPrePaymentAmount=${min_pre}  totalAmount=${Total}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}
        Verify Response  ${resp}  consumerNoteMandatory=${bool[0]}   consumerNoteTitle=${consumerNoteTitle}   preInfoEnabled=${bool[0]}   preInfoTitle=${preInfoTitle}   preInfoText=${preInfoText}   postInfoEnabled=${bool[0]}   postInfoTitle=${postInfoTitle}   postInfoText=${postInfoText}

        ${resp}=  Update Service with info  ${sid39}  ${SERVICE10}  ${description}   ${service_duration[3]}  ${bool[0]}  ${notifytype[0]}  0  ${Total}  ${status[0]}  ${btype}  ${bool[1]}  ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  422
        Should Be Equal As Strings  "${resp.json()}"  "${MINIMUM_PREPAYMENT_AMOUNT_SHOULD_BE_PROVIDED}"   
  


*** Keywords ***
Billable

    ${resp}=   Get File    /ebs/TDD/varfiles/providers.py
    ${len}=   Split to lines  ${resp}
    ${length}=  Get Length   ${len}
     
    FOR   ${a}  IN RANGE   ${length-1}
            
        # clear_service       ${PUSERNAME${a}}
        ${resp}=  Encrypted Provider Login  ${PUSERNAME${a}}  ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}    200
        clear_customer   ${PUSERNAME${a}}

        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        ${domain}=   Set Variable    ${decrypted_data['sector']}
        ${subdomain}=    Set Variable      ${decrypted_data['subSector']}

        # ${domain}=   Set Variable    ${resp.json()['sector']}
        # ${subdomain}=    Set Variable      ${resp.json()['subSector']}
        ${resp2}=   Get Sub Domain Settings    ${domain}    ${subdomain}
        Should Be Equal As Strings    ${resp.status_code}    200
        Set Suite Variable  ${check}    ${resp2.json()['serviceBillable']} 
        Exit For Loop IF     '${check}' == 'True'

    END
    RETURN  ${PUSERNAME${a}}


Non Billable

    ${resp}=   Get File    /ebs/TDD/varfiles/providers.py
        ${len}=   Split to lines  ${resp}
        ${length}=  Get Length   ${len}

     FOR    ${a}   IN RANGE  ${start1}    ${length-1}
        # clear_service       ${PUSERNAME${a}}
        ${resp}=  Encrypted Provider Login  ${PUSERNAME${a}}  ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}    200
        clear_customer   ${PUSERNAME${a}}

        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        ${domain}=   Set Variable    ${decrypted_data['sector']}
        ${subdomain}=    Set Variable      ${decrypted_data['subSector']}

        # ${domain}=   Set Variable    ${resp.json()['sector']}
        # ${subdomain}=    Set Variable      ${resp.json()['subSector']}
        ${resp}=  View Waitlist Settings
	${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[1]}
        ${resp}=  Toggle Department Disable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END  
        ${resp2}=   Get Sub Domain Settings    ${domain}    ${subdomain}
        Should Be Equal As Strings    ${resp.status_code}    200
        Set Suite Variable  ${check}    ${resp2.json()['serviceBillable']} 
        Run Keyword IF   '${check}' == 'False'   Disable Services
        Exit For Loop IF     '${check}' == 'False'
       
     END 
     RETURN   ${PUSERNAME${a}}




# MultiLocation

#         ${multilocdoms}=  get_mutilocation_domains
#         Log  ${multilocdoms}
#         ${domlen}=  Get Length   ${multilocdoms}
#         ${resp}=   Get File    /ebs/TDD/varfiles/providers.py
#         ${len}=   Split to lines  ${resp}
#         ${length}=  Get Length   ${len}

#         FOR   ${i}  IN RANGE   ${domlen}
#                 ${dom}=  Convert To String   ${multilocdoms[${i}]['domain']}
#                 Append To List   ${dom_list}  ${dom}
#         END
#         Log   ${dom_list}

#         FOR   ${a}  IN RANGE  ${start}   ${length-1}    
#                 ${resp}=  Encrypted Provider Login  ${PUSERNAME${a}}  ${PASSWORD}
#                 Log   ${resp.json()}
#                 Should Be Equal As Strings    ${resp.status_code}    200
#                 clear_customer   ${PUSERNAME${a}}
#                 ${domain}=   Set Variable    ${resp.json()['sector']}
#                 ${subdomain}=    Set Variable      ${resp.json()['subSector']}
#                 Log  ${dom_list}
#                 ${status} 	${value} = 	Run Keyword And Ignore Error  List Should Contain Value  ${dom_list}  ${domain}
#                 Log Many  ${status} 	${value}
#                 Run Keyword If  '${status}' == 'PASS'   Append To List   ${multiloc_providers}  ${PUSERNAME${a}}
#                 ${resp}=  View Waitlist Settings
#                 Log   ${resp.json()}
#                 Should Be Equal As Strings    ${resp.status_code}    200
#                 ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[1]}
        ${resp}=  Toggle Department Disable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
#         END
#         RETURN  ${multiloc_providers}


Disable Services

        ${resp}=   Get Service  status-eq=ACTIVE
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${len}=  Get Length  ${resp.json()}
        FOR   ${i}   IN RANGE   ${len}
                Set Test Variable   ${sid${i}}   ${resp.json()[${i}]['id']}
        END
        FOR   ${i}   IN RANGE   ${len}
                Log   ${sid${i}}
                # ${resp}=   Run Keyword And Return If  '${resp.json()[${i}]['status']}' == 'ACTIVE'    Disable service  ${sid${i}} 
                ${resp}=   Disable service  ${sid${i}}
        END
        ${resp}=   Get Service  status-eq=ACTIVE
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200



