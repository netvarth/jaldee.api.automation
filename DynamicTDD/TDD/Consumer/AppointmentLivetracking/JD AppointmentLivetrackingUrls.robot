*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Livetrack
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

*** Variables ***
${SERVICE1}     manicure 
${SERVICE2}     pedicure
${self}         0
${digits}       0123456789

*** Test Cases ***
JD-TC-Consumer Appointment Livetrack-1
    [Documentation]  Consumer  Sharing livetrack location before one hour and Travel mode is DRIVING  to start by consumer  
    ${resp}=  Encrypted Provider Login  ${PUSERNAME15}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
*** Comments ***
    ${pkg_id}=   get_highest_license_pkg
    ${resp}=  Change License Package  ${pkgid[0]}
    Should Be Equal As Strings    ${resp.status_code}   200
 
    clear_service   ${PUSERNAME15}
    clear_location  ${PUSERNAME15}    
    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Disbale Global Livetrack   Enable
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${pid}=  get_acc_id  ${PUSERNAME15}
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
    clear_appt_schedule   ${PUSERNAME15}
    ${SERVICE1}=   FakerLibrary.name
    ${s_id}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable   ${s_id}

    ${resp}=  Enable Disbale Service Livetrack   ${s_id}   Enable
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME10}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    ${cid1}=  get_id  ${CUSERNAME10}
   
    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

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
    ${j}=  Random Int  max=${num_slots-1}
    Set Test Variable   ${slot1}   ${slots[${j}]}
    
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}  
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid1}  ${apptid[0]}
*** Comments ***
    Comment    SaveMyLocation
    ${latti}  ${longi}  ${place}=  get_lat_long_city
    ${resp}=   Enable apptment SaveMyLocation by consumer   ${pid}    ${apptid1}  ${Empty}  ${travelMode[0]}   ${startTimeMode[0]}   ${latti}  ${longi}  ${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jaldeeDistanceTime']['jaldeelTravelTime']['travelMode']}   ${travelMode[0]}


JD-TC-Consumer Appointment Livetrack-2
    [Documentation]  Consumer after enable the livetrack and checking Update Consumer Mylocation

    ${resp}=  Consumer Login  ${CUSERNAME10}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Comment     UpdateLotitude/LogitudeInterval
    ${latti_1}  ${longi_1}  ${place}=  get_lat_long_city   
    ${resp}=    Update Consumer apptment MyLocation    ${pid}  ${apptid1}  ${latti_1}  ${longi_1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-Consumer Appointment Livetrack-3
    [Documentation]  Consumer after enable the livetrack and checking Update Consumer location

    ${resp}=  Consumer Login  ${CUSERNAME10}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Comment     UpdateLotitude/LogitudeInterval
    ${latti_1}  ${longi_1}  ${place}=  get_lat_long_city   
    ${resp}=    Update Consumer apptment latlong    ${pid}  ${apptid1}  ${latti_1}  ${longi_1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Consumer Appointment Livetrack-4
    [Documentation]  smae Consumer Sharing livetrack location before TWO Hours and Travel mode is WALK to start by consumer

    ${resp}=  Consumer Login  ${CUSERNAME10}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    ${family_fname}=  FakerLibrary.first_name
    Set Suite Variable   ${family_fname}
    ${family_lname}=  FakerLibrary.last_name
    Set Suite Variable   ${family_lname}
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMember   ${family_fname}  ${family_lname}  ${dob}  ${gender}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${cidfor}   ${resp.json()}
    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    Set Suite Variable   ${apptfor}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid1}  ${apptid[0]}

    Comment    SaveMyLocation
    ${latti}  ${longi}  ${place}=  get_lat_long_city
    ${resp}=   Enable apptment SaveMyLocation by consumer   ${pid}    ${apptid1}  ${Empty}  ${travelMode[1]}   ${startTimeMode[1]}   ${latti}  ${longi}  ${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jaldeeDistanceTime']['jaldeelTravelTime']['travelMode']}   ${travelMode[1]}

    ${resp}=   Update consumer apptment tavelmode  ${pid}  ${apptid1}   ${travelMode[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jaldeeDistanceTime']['jaldeelTravelTime']['travelMode']}   ${travelMode[1]}
    
    
JD-TC-Consumer Appointment Livetrack-5
    [Documentation]  smae Consumer Sharing livetrack location before TWO Hours and Travel mode is BICYCLING to start by consumer

    ${resp}=  Consumer Login  ${CUSERNAME10}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

     ${resp}=   Update consumer apptment tavelmode  ${pid}  ${apptid1}   ${travelMode[2]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jaldeeDistanceTime']['jaldeelTravelTime']['travelMode']}   ${travelMode[2]} 


JD-TC-Consumer Appointment Livetrack-6
    [Documentation]  Consumer after enable the livetrack and checking locate consumer

    ${resp}=  Consumer Login  ${CUSERNAME10}  ${PASSWORD}
    Log  ${resp.json()}
    ${family_fname}=  FakerLibrary.first_name
    Set Suite Variable   ${family_fname}
    ${family_lname}=  FakerLibrary.last_name
    Set Suite Variable   ${family_lname}
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMember   ${family_fname}  ${family_lname}  ${dob}  ${gender}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${cidfor}   ${resp.json()}
    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    Set Suite Variable   ${apptfor}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid1}  ${apptid[0]}

    Comment    SaveMyLocation
    ${latti}  ${longi}  ${place}=  get_lat_long_city
    ${resp}=   Enable apptment SaveMyLocation by consumer   ${pid}    ${apptid1}  ${Empty}  ${travelMode[1]}   ${startTimeMode[1]}   ${latti}  ${longi}  ${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jaldeeDistanceTime']['jaldeelTravelTime']['travelMode']}   ${travelMode[1]}

    ${resp}=    Locate apptment consumer    ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200