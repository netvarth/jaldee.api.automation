*** Settings ***
Suite Teardown    Delete All Sessions 
Test Teardown     Run Keywords   Delete All Sessions  resetsystem_time
Force Tags        Appointment
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py


*** Variables ***

${SERVICE1}    SERVICE1
${SERVICE2}    SERVICE2
${SERVICE3}    SERVICE3
${self}        0
${apptBy}       CONSUMER
@{dom_list}
@{multiloc_providers}

*** Test Cases ***

JD-TC-Get Appointment history Count-1

    [Documentation]  Consumer Appointments History Count    
    
    change_system_date  -3

    clear_location   ${PUSERNAME167}
    clear_service   ${PUSERNAME167}
    
    ${resp}=  ProviderLogin  ${PUSERNAME167}  ${PASSWORD}

    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    ${pid}=  get_acc_id  ${PUSERNAME167}
    Set Suite Variable  ${pid} 
   
    ${DAY}=  get_date  
    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}
    ${DAY2}=  add_date  10 
    Set Suite Variable  ${DAY2}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    ${sTime}=  db.get_time
    ${eTime}=  add_time  0  30
    ${city}=   get_place
    ${latti}=  get_latitude
    ${longi}=  get_longitude
    ${postcode}=  FakerLibrary.postcode
    ${address}=  get_address
    ${parking}    Random Element     ${parkingType} 
    ${24hours}    Random Element    ['True','False']
    ${url}=   FakerLibrary.url
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${url}  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Suite Variable  ${lid}  ${resp.json()} 

    ${sTime1}=  add_time   1  00
    ${eTime1}=  add_time   3  30
    ${city}=   get_place
    ${latti}=  get_latitude
    ${longi}=  get_longitude
    ${postcode}=  FakerLibrary.postcode
    ${address}=  get_address
    ${parking}    Random Element     ${parkingType} 
    ${24hours}    Random Element    ['True','False']
    ${url}=   FakerLibrary.url
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${url}  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Suite Variable  ${lid1}  ${resp.json()}
    clear_appt_schedule   ${PUSERNAME167}
      
    ${s_id1}=   Create Sample Service  ${SERVICE1}
    Set Suite Variable   ${s_id1}
    ${s_id2}=   Create Sample Service  ${SERVICE2}
    Set Suite Variable   ${s_id2}
    ${s_id3}=   Create Sample Service  ${SERVICE3}
    Set Suite Variable   ${s_id3} 

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${sTime1}=  add_time  0  15
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=3  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}    ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id3}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id3}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id3}  ${DAY1}   ${s_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id3}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor2}=   Create List  ${apptfor1} 

    ${sTime2}=  add_time  1  15
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime2}=  add_two   ${sTime2}  ${delta}
    ${schedule_name1}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=3  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel}    ${parallel}    ${parallel}    ${parallel}  ${lid1}  ${duration}  ${bool1}  ${s_id1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id2}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id2}   name=${schedule_name1}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id2}  ${DAY1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name1}  scheduleId=${sch_id2}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][0]['time']}
    ${apptfor3}=  Create Dictionary  id=${self}   apptTime=${slot2}
    ${apptfor4}=   Create List  ${apptfor3}

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME28}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${cid1}=  get_id  ${CUSERNAME28} 
    Set Suite Variable  ${f_Name}  ${resp.json()['firstName']}
    Set Suite Variable  ${l_Name}  ${resp.json()['lastName']}
    Set Suite Variable  ${ph_no}  ${resp.json()['primaryPhoneNumber']}
  
    ${cid1}=  get_id  ${CUSERNAME28}   
    Set Suite Variable   ${cid1}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment with ApptMode For Provider   ${appointmentMode[2]}   ${pid}  ${s_id1}  ${sch_id2}  ${DAY1}  ${cnote}   ${apptfor4}
     Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid1}  ${apptid[0]}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id2}  ${sch_id2}  ${DAY1}  ${cnote}   ${apptfor4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid2}  ${apptid[0]}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id3}  ${sch_id3}  ${DAY1}  ${cnote}   ${apptfor2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid3}  ${apptid[0]}

    
    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid3}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${f_name}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${l_name}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id3}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id3}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptBy']}   ${apptBy}
    Should Be Equal As Strings  ${resp.json()['appmtTime']}   ${slot1}

    ${resp}=  Consumer Logout
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  ProviderLogin  ${PUSERNAME167}  ${PASSWORD}
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment EncodedID    ${apptid1}
    Log   ${resp.json()}
    Set Suite Variable   ${A_uuid1}   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${A_uuid1}=  Set Variable   ${resp.json()}

    ${resp}=   Get Appointment EncodedID    ${apptid2}
    Log   ${resp.json()}
    Set Suite Variable   ${A_uuid2}   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${A_uuid2}=  Set Variable   ${resp.json()}

    ${resp}=   Get Appointment EncodedID    ${apptid3}
    Log   ${resp.json()}
    Set Suite Variable   ${A_uuid3}   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${A_uuid3}=  Set Variable   ${resp.json()}

    ${reason}=  Random Element  ${cancelReason}
    ${msg}=   FakerLibrary.word
    ${resp}=    Provider Cancel Appointment  ${apptid1}  ${reason}  ${msg}  ${DAY1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep  2s

    ${resp}=  Get Appointment Status   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['appointmentStatus']}   ${apptStatus[4]} 
    
    ${resp}=    ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    resetsystem_time
    
    ${resp}=  Consumer Login  ${CUSERNAME28}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['uid']}                                   ${apptid1}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}  ${f_name}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${l_name}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                         ${s_id1}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}                        ${sch_id2}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}                            ${apptStatus[4]}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}                             ${DAY1}
    Should Be Equal As Strings  ${resp.json()['apptBy']}                                ${apptBy}
    Should Be Equal As Strings  ${resp.json()['appmtTime']}                             ${slot2}
    
    ${resp}=   Get Consumer Appointments History Count
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}    200
    Should Be Equal As Integers  ${resp.json()}  3
    ${resp}=  Consumer Logout
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Get Appointment history Count-2 

    [Documentation]  Get Appointment history count By appointmentEncId
    
    ${resp}=  Consumer Login  ${CUSERNAME28}  ${PASSWORD}
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   

    ${resp}=  Get Consumer Appointments History Count           appointmentMode-eq=${appointmentMode[2]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Integers  ${resp.json()}  3


JD-TC-Get Appointment history Count-3 

    [Documentation]  Get Appointment history count By location
    
    ${resp}=  Consumer Login  ${CUSERNAME28}  ${PASSWORD}
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   

    ${resp}=  Get Consumer Appointments History Count           location-eq=${lid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Integers  ${resp.json()}  2
    

JD-TC-Get Appointment history Count-4

    [Documentation]  Get Appointment history count By service
    
    ${resp}=  Consumer Login  ${CUSERNAME28}  ${PASSWORD}
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   

    ${resp}=  Get Consumer Appointments History Count           service-eq=${s_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Integers  ${resp.json()}  1

JD-TC-Get Appointment history Count-5 

    [Documentation]  Get Appointment history count By schedule
    
    ${resp}=  Consumer Login  ${CUSERNAME28}  ${PASSWORD}
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   

    ${resp}=  Get Consumer Appointments History Count          schedule-eq=${sch_id3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Integers  ${resp.json()}  1

JD-TC-Get Appointment history Count-6 

    [Documentation]  Get Appointment history count By apptStatus
    
    ${resp}=  Consumer Login  ${CUSERNAME28}  ${PASSWORD}
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   

    ${resp}=  Get Consumer Appointments History Count          apptStatus-eq=${apptStatus[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Integers  ${resp.json()}  2

JD-TC-Get Appointment history Count-7 

    [Documentation]  Get Appointment history count By firstName
    
    ${resp}=  Consumer Login  ${CUSERNAME28}  ${PASSWORD}
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    Set Suite Variable   ${cname1}    ${resp.json()['firstName']}
    
    ${resp}=  Get Consumer Appointments History Count          firstName-eq=${cname1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Integers  ${resp.json()}  3

JD-TC-Get Appointment history Count-8 

    [Documentation]  Get Appointment history count By Appmt Date
    
    ${resp}=  Consumer Login  ${CUSERNAME28}  ${PASSWORD}
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Appointments History Count           date-eq=${DAY1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Integers  ${resp.json()}  3

JD-TC-Get Appointment history Count-9 

    [Documentation]  Get Appointment history count By Appmtby
    
    ${resp}=  Consumer Login  ${CUSERNAME28}  ${PASSWORD}
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   

    ${resp}=  Get Consumer Appointments History Count           apptBy-eq=${apptBy}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Integers  ${resp.json()}  3

JD-TC-Get Appointment history Count-10 

    [Documentation]  Get Appointment history count By Appmt Date  and  paymentStatus
    
    ${resp}=  Consumer Login  ${CUSERNAME28}  ${PASSWORD}
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   

    ${resp}=  Get Consumer Appointments History Count       date-eq=${DAY1}     paymentStatus-eq=${paymentStatus[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Integers  ${resp.json()}  3

JD-TC-Get Appointment history Count-11 

    [Documentation]  Get Appointment history count By apptStatus and firstName 
    
    ${resp}=  Consumer Login  ${CUSERNAME28}  ${PASSWORD}
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   

    ${resp}=  Get Consumer Appointments History Count        apptStatus-eq=${apptStatus[1]}    firstName-eq=${cname1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Integers  ${resp.json()}  2

JD-TC-Get Appointment history Count-12 

    [Documentation]  Get Appointment history count By schedule and apptStatus

    ${resp}=  Consumer Login  ${CUSERNAME28}  ${PASSWORD}
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Consumer Appointments History Count           schedule-eq=${sch_id3}    apptStatus-eq=${apptStatus[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Integers  ${resp.json()}  1

JD-TC-Get Appointment history Count-13 

    [Documentation]  Get Appointment history count By appointmentEncId And service
    
    ${resp}=  Consumer Login  ${CUSERNAME28}  ${PASSWORD}
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  

    ${resp}=  Get Consumer Appointments History Count           appointmentMode-eq=${appointmentMode[2]}    service-eq=${s_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Integers  ${resp.json()}  1

JD-TC-Get Appointment history Count-14

    [Documentation]   Get Appointment history Count  no input
    
    ${resp}=  Consumer Login  ${CUSERNAME28}  ${PASSWORD}
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Consumer Appointments History Count    
    Should Be Equal As Strings  ${resp.status_code}  200  
    Should Be Equal As Integers  ${resp.json()}  3
    
JD-TC-Get Appointment history Count-UH1

    [Documentation]   Get Appointment history Count  without Consumer login
    
    ${resp}=    Get Consumer Appointments History Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"
