*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Appointment
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
${self}     0

*** Test Cases ***
JD-TC-GetAppointmentServicesByLocation-1

    [Documentation]  Provider get Service By LocationId.  

    ${multilocdoms}=  get_mutilocation_domains
    Log  ${multilocdoms}
    Set Suite Variable  ${dom}  ${multilocdoms[0]['domain']}
    Set Suite Variable  ${sub_dom}  ${multilocdoms[0]['subdomains'][0]}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_R}=  Evaluate  ${PUSERNAME}+5566011
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_R}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_R}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_R}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_R}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERNAME_R}${\n}
    Set Suite Variable  ${PUSERNAME_R}

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    clear_service   ${PUSERNAME_R}
    clear_location  ${PUSERNAME_R}
    ${pid}=  get_acc_id  ${PUSERNAME_R}

    

    # ${sTime}=  db.get_time_by_timezone   ${tz}
    # ${sTime}=  db.get_time_by_timezone  ${tz}
    # ${eTime}=  add_timezone_time  ${tz}  0  30  
    # ${city}=   FakerLibrary.state
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}

    ${sTime}=  db.get_time_by_timezone  ${tz}
    ${eTime}=  add_timezone_time  ${tz}  0  30  
    ${parking}    Random Element     ${parkingType} 
    ${24hours}    Random Element    ['True','False']
    ${url}=   FakerLibrary.url
    ${DAY}=  db.get_date_by_timezone  ${tz}   
    Set Suite Variable  ${DAY} 
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${url}  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_l1}  ${resp.json()}

    # ${sTime}=  db.get_time_by_timezone  ${tz}
    # ${eTime}=  add_timezone_time  ${tz}  0  30  
    ${sTime1}=  add_timezone_time  ${tz}  1  30  
    ${eTime1}=  add_timezone_time  ${tz}  3  00  
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${parking}    Random Element     ${parkingType} 
    ${24hours}    Random Element    ['True','False']
    ${url}=   FakerLibrary.url
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${url}  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_l2}  ${resp.json()}

    ${sTime1}=  add_timezone_time  ${tz}  0  30  
    ${eTime1}=  add_timezone_time  ${tz}  1  00  
    ${city}=   FakerLibrary.word
    ${latti}=  get_latitude
    ${longi}=  get_longitude
    ${postcode}=  FakerLibrary.postcode
    ${address}=  get_address
    ${parking}    Random Element     ${parkingType} 
    ${24hours}    Random Element    ['True','False']
    ${url}=   FakerLibrary.url
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${url}  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_l3}  ${resp.json()}

    clear_appt_schedule   ${PUSERNAME_R}
        
    ${service_duration}=   Random Int   min=5   max=10
    Set Suite Variable    ${service_duration}
    ${P1SERVICE1}=    FakerLibrary.word
    Set Suite Variable  ${P1SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_s1}  ${resp.json()}    
 
    ${P1SERVICE2}=    FakerLibrary.word
    Set Suite Variable  ${P1SERVICE2}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE2}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_s2}  ${resp.json()}

    ${P1SERVICE3}=    FakerLibrary.word
    Set Suite Variable   ${P1SERVICE3}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE3}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_s3}  ${resp.json()}

    ${P1SERVICE4}=    FakerLibrary.word
    Set Suite Variable   ${P1SERVICE4}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE4}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_s4}  ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=30
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${p1_l1}  ${duration}  ${bool1}  ${p1_s1}   ${p1_s3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id1}   name=${schedule_name}  apptState=${Qstate[0]}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${sTime1}=  add_timezone_time  ${tz}  0  35  
    ${delta}=  FakerLibrary.Random Int  min=10  max=25
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${p1_l2}  ${duration}  ${bool1}  ${p1_s2}   ${p1_s3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id2}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id2}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=    Get Appoinment Service By Location   ${p1_l1}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}   200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  2
    FOR  ${i}  IN RANGE   ${len}
        IF  '${resp.json()[${i}]['id']}' == '${p1_s1}'
            Verify Response List  ${resp}   0    id=${p1_s1}   name=${P1SERVICE1}  status=${status[0]}   notificationType=${notifytype[2]}  serviceDuration=${service_duration}
        ELSE IF  '${resp.json()[${i}]['id']}' == '${p1_s3}'
            Verify Response List  ${resp}   1    id=${p1_s3}   name=${P1SERVICE3}  status=${status[0]}   notificationType=${notifytype[2]}  serviceDuration=${service_duration}
        END
    END
    
JD-TC-GetAppointmentServicesByLocation-2

    [Documentation]  provider get Service By another LocationId of the same provider.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_R}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Appoinment Service By Location   ${p1_l2}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}   200
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
        IF  ${resp.json()[${i}]['id']} == ${p1_s2}
            Verify Response List   ${resp}   ${i}    id=${p1_s2}   name=${P1SERVICE2}  status=${status[0]}   notificationType=${notifytype[2]}  serviceDuration=${service_duration}
        ELSE IF   ${resp.json()[${i}]['id']} == ${p1_s3}
            Verify Response List   ${resp}   ${i}    id=${p1_s3}   name=${P1SERVICE3}  status=${status[0]}   notificationType=${notifytype[2]}  serviceDuration=${service_duration}
        END
    END

JD-TC-GetAppointmentServicesByLocation-3

    [Documentation]  provider get Service By LocationId which is not added in the appointment schedule.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_R}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Appoinment Service By Location   ${p1_l2}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}   200
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
        IF  ${resp.json()[${i}]['id']} == ${p1_s2}
            Verify Response List   ${resp}   ${i}    id=${p1_s2}   name=${P1SERVICE2}  status=${status[0]}   notificationType=${notifytype[2]}  serviceDuration=${service_duration}
        ELSE IF   ${resp.json()[${i}]['id']} == ${p1_s3}
            Verify Response List   ${resp}   ${i}    id=${p1_s3}   name=${P1SERVICE3}  status=${status[0]}   notificationType=${notifytype[2]}  serviceDuration=${service_duration}
        END
    END
    Should Not Contain  ${resp.json()}  ${p1_s4}

    ${resp}=    Get Appoinment Service By Location   ${p1_l1}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}   200
    FOR  ${i}  IN RANGE   ${len}
        IF  ${resp.json()[${i}]['id']} == ${p1_s2}
            Verify Response List   ${resp}   ${i}    id=${p1_s1}   name=${P1SERVICE1}  status=${status[0]}   notificationType=${notifytype[2]}  serviceDuration=${service_duration}
        ELSE IF   ${resp.json()[${i}]['id']} == ${p1_s3}
            Verify Response List   ${resp}   ${i}    id=${p1_s3}   name=${P1SERVICE3}  status=${status[0]}   notificationType=${notifytype[2]}  serviceDuration=${service_duration}
        END
    END
    Should Not Contain  ${resp.json()}  ${p1_s4}

JD-TC-GetAppointmentServicesByLocation-4

    [Documentation]  provider get Service By LocationId, When  One Service is disabled.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_R}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${RESP}=  Disable service  ${p1_s1} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appoinment Service By Location   ${p1_l1}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}   200
    Should Not Contain  ${resp.json()}  ${p1_s1}
    Should Be Equal As Strings  ${resp.json()[0]['id']}  ${p1_s3}
    Should Be Equal As Strings  ${resp.json()[0]['name']}  ${P1SERVICE3}

    ${RESP}=  Enable service  ${p1_s1} 
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-GetAppointmentServicesByLocation-5

    [Documentation]  provider get Service By LocationId, When  All Services in this location are disabled
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_R}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${RESP}=  Disable service  ${p1_s1} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${RESP}=  Disable service  ${p1_s3} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appoinment Service By Location   ${p1_l1}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}   200
    Should Not Contain  ${resp.json()}  ${p1_s1}
    Should Not Contain  ${resp.json()}  ${p1_s3}

    ${RESP}=  Enable service  ${p1_s1} 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${RESP}=  Enable service  ${p1_s3} 
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-GetAppointmentServicesByLocation-6

    [Documentation]  Another provider get Service By LocationId, When Services are disabled

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_R}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${RESP}=  Disable service  ${p1_s2} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${RESP}=  Disable service  ${p1_s3} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appoinment Service By Location   ${p1_l2}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}   200
    Should Not Contain  ${resp.json()}  ${p1_s2}
    Should Not Contain  ${resp.json()}  ${p1_s3}

    ${RESP}=  Enable service  ${p1_s2} 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${RESP}=  Enable service  ${p1_s3} 
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-GetAppointmentServicesByLocation-7

    [Documentation]  provider get Service By LocationId, which doesn't contain any service. 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_R}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appoinment Service By Location   ${p1_l3}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}   200
    Should Be Equal As Strings   ${resp.json()}   []

JD-TC-GetAppointmentServicesByLocation-UH1

    [Documentation]  provider get Service By LocationId without login.

    ${resp}=    Get Appoinment Service By Location   ${p1_l2}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}   419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"
    
JD-TC-GetAppointmentServicesByLocation-UH2

    [Documentation]  Trying to provider get Service By LocationId, with an invalid location.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_R}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appoinment Service By Location   0
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}   404
    Should Be Equal As Strings   ${resp.json()}       ${LOCATION_NOT_FOUND}

JD-TC-GetAppointmentServicesByLocation-UH3

    [Documentation]  Trying to provider get Service By LocationId, When Location is disabled 
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_R}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Disable Location  ${p1_l2} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appoinment Service By Location   ${p1_l2}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}   422
    Should Be Equal As Strings   ${resp.json()}       ${LOCATION_DISABLED}

    ${RESP}=  Enable Location  ${p1_l2} 
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-GetAppointmentServicesByLocation-UH4

    [Documentation]  Consumer get Service By LocationId .

    ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appoinment Service By Location   ${p1_l2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"

# ...........TIMEZONE CASES.........


JD-TC-GetAppointmentServicesByLocation-8

    [Documentation]  provider checks get service by location id for location in US

    # clear_service   ${PUSERNAME210}
    # clear_location   ${PUSERNAME210}
    clear_location_n_service  ${PUSERNAME210}
    clear_queue     ${PUSERNAME210}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME210}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${lic_id}   ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}
    Set Test Variable  ${lic_name}   ${decrypted_data['accountLicenseDetails']['accountLicense']['name']}
   
    ${highest_package}=  get_highest_license_pkg
    Log  ${highest_package}
    Set Test variable  ${lic2}  ${highest_package[0]}

    IF  '${lic_id}' != '${lic2}'
        ${resp1}=   Change License Package  ${highest_package[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END
   
    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${pid}=  get_acc_id  ${PUSERNAME210}
    
    ${SERVICE1}=    FakerLibrary.Word
    ${s_id1}=   Create Sample Service  ${SERVICE1}

    ${latti}  ${longi}  ${city}  ${country_abbr}  ${US_tz}=  FakerLibrary.Local Latlng  country_code=US  coords_only=False

    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime}=  db.subtract_timezone_time  ${US_tz}  2  00
    ${sTime}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  add_timezone_time  ${US_tz}  1  30  
    ${eTime}=  add_timezone_time  ${US_tz}  3  00  

    ${sTime1}  ${eTime1}=  db.endtime_conversion  ${sTime}  ${eTime}

    ${DAY}=  db.get_date_by_timezone  ${US_tz}
    ${DAY1}=  db.add_timezone_date  ${US_tz}  10       
    ${address} =  FakerLibrary.address
    ${postcode}=  FakerLibrary.postcode
    ${parking}    Random Element     ${parkingType} 
    ${24hours}    Random Element    ['True','False']
    ${url}=   FakerLibrary.url
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${url}  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${loc_id1}  ${resp.json()}

    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=5
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY}  ${DAY1}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${loc_id1}  ${duration}  ${bool1}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id1}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable     ${slot1}   ${resp.json()['availableSlots'][0]['time']}   

    ${resp}=    Get Appoinment Service By Location   ${loc_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}   200

    Should Be Equal As Strings  ${resp.json()[0]['id']}       ${s_id1}
    Should Be Equal As Strings  ${resp.json()[0]['name']}     ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()[0]['serviceAvailability']['nextAvailableDate']}    ${DAY}
    Should Be Equal As Strings  ${resp.json()[0]['serviceAvailability']['nextAvailable']}     ${slot1}
   