*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Appointment
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library         /ebs/TDD/CustomKeywords.py
Library           /ebs/TDD/db.py
Library           random
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py


*** Variables ***
${self}     0
@{service_names}

*** Test Cases ***

JD-TC-GetAppointmentServicesByLocation-1

    [Documentation]  Provider get Service By LocationId.  
  
    ${PUSERNAME_R}=  Evaluate  ${PUSERNAME}+556601145
    ${firstname}  ${lastname}  ${PhoneNumber}  ${PUSERNAME_R}=  Provider Signup without Profile  PhoneNumber=${PUSERNAME_R}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_R}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_R}${\n}
    Set Suite Variable  ${PUSERNAME_R}

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    # clear_service   ${PUSERNAME_R}
    # clear_location  ${PUSERNAME_R}
    ${pid}=  get_acc_id  ${PUSERNAME_R}
    Set Suite Variable   ${pid}

    ${latti}  ${longi}  ${postcode}  ${city}  ${address}=  get_random_location_data
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    ${url}=   FakerLibrary.url
    ${resp}=  Create Location   ${city}  ${longi}  ${latti}  ${postcode}  ${address}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_l1}  ${resp.json()}

    ${latti}  ${longi}  ${postcode}  ${city}  ${address}=  get_random_location_data
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    ${url}=   FakerLibrary.url
    ${resp}=  Create Location   ${city}  ${longi}  ${latti}  ${postcode}  ${address}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_l2}  ${resp.json()}

    ${latti}  ${longi}  ${postcode}  ${city}  ${address}=  get_random_location_data
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    ${url}=   FakerLibrary.url
    ${resp}=  Create Location   ${city}  ${longi}  ${latti}  ${postcode}  ${address}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_l3}  ${resp.json()}

    # clear_appt_schedule   ${PUSERNAME_R}
        
    ${service_duration}=   Random Int   min=5   max=10
    Set Suite Variable    ${service_duration}
    ${P1SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${P1SERVICE1}
    Set Suite Variable  ${P1SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}  ${service_duration}  ${bool[0]}  ${servicecharge}  ${bool[0]}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_s1}  ${resp.json()}    
 
    ${P1SERVICE2}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${P1SERVICE2}
    Set Suite Variable  ${P1SERVICE2}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE2}  ${desc}   ${service_duration}  ${bool[0]}  ${servicecharge}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_s2}  ${resp.json()}

    ${P1SERVICE3}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${P1SERVICE3}
    Set Suite Variable   ${P1SERVICE3}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE3}  ${desc}   ${service_duration}  ${bool[0]}  ${servicecharge}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_s3}  ${resp.json()}

    ${P1SERVICE4}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${P1SERVICE4}
    Set Suite Variable   ${P1SERVICE4}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE4}  ${desc}   ${service_duration}  ${bool[0]}  ${servicecharge}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_s4}  ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY1}
    ${list}=  Create List  1  2  3  4  5  6  7
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
   
    ${resp}=    Get Appoinment Service By Location   ${p1_l1}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}   200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  2
    FOR  ${i}  IN RANGE   ${len}
        IF  '${resp.json()[${i}]['id']}' == '${p1_s1}'
            Verify Response List  ${resp}   ${i}    id=${p1_s1}   name=${P1SERVICE1}  status=${status[0]}    serviceDuration=${service_duration}
        ELSE IF  '${resp.json()[${i}]['id']}' == '${p1_s3}'
            Verify Response List  ${resp}   ${i}   id=${p1_s3}   name=${P1SERVICE3}  status=${status[0]}    serviceDuration=${service_duration}
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
            Verify Response List   ${resp}   ${i}    id=${p1_s2}   name=${P1SERVICE2}  status=${status[0]}   serviceDuration=${service_duration}
        ELSE IF   ${resp.json()[${i}]['id']} == ${p1_s3}
            Verify Response List   ${resp}   ${i}    id=${p1_s3}   name=${P1SERVICE3}  status=${status[0]}   serviceDuration=${service_duration}
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
            Verify Response List   ${resp}   ${i}    id=${p1_s2}   name=${P1SERVICE2}  status=${status[0]}   serviceDuration=${service_duration}
        ELSE IF   ${resp.json()[${i}]['id']} == ${p1_s3}
            Verify Response List   ${resp}   ${i}    id=${p1_s3}   name=${P1SERVICE3}  status=${status[0]}   serviceDuration=${service_duration}
        END
    END
    Should Not Contain  ${resp.json()}  ${p1_s4}

    ${resp}=    Get Appoinment Service By Location   ${p1_l1}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}   200
    FOR  ${i}  IN RANGE   ${len}
        IF  ${resp.json()[${i}]['id']} == ${p1_s2}
            Verify Response List   ${resp}   ${i}    id=${p1_s1}   name=${P1SERVICE1}  status=${status[0]}   serviceDuration=${service_duration}
        ELSE IF   ${resp.json()[${i}]['id']} == ${p1_s3}
            Verify Response List   ${resp}   ${i}    id=${p1_s3}   name=${P1SERVICE3}  status=${status[0]}   serviceDuration=${service_duration}
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

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_R}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  AddCustomer  ${CUSERNAME22}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${CUSERNAME22}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${CUSERNAME22}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME22}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Appoinment Service By Location   ${p1_l2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"

# ...........TIMEZONE CASES.........


JD-TC-GetAppointmentServicesByLocation-8

    [Documentation]  provider checks get service by location id for location in US

    # clear_location_n_service  ${PUSERNAME210}
    # clear_queue     ${PUSERNAME210}

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
    
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id1}=   Create Sample Service  ${SERVICE1}

    ${address} =  FakerLibrary.address
    ${postcode}=  FakerLibrary.postcode

    ${latti}  ${longi}  ${city}  ${country_abbr}  ${US_tz}=  FakerLibrary.Local Latlng  country_code=US  coords_only=False
    ${resp}=  Create Location   ${city}  ${longi}  ${latti}  ${postcode}  ${address}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${loc_id1}  ${resp.json()}

    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY}=  db.get_date_by_timezone  ${US_tz}
    ${DAY1}=  db.add_timezone_date  ${US_tz}  10

    ${sTime}=  db.subtract_timezone_time  ${US_tz}  2  00
    ${eTime}=  add_timezone_time  ${US_tz}  3  00  
    ${sTime1}  ${eTime1}=  db.endtime_conversion  ${sTime}  ${eTime}
    
    ${schedule_name}=  FakerLibrary.bs
    ${list}=  Create List  1  2  3  4  5  6  7
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
  
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        IF  ${resp.json()['availableSlots'][${i}]['active']} == True 
            Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
        END
    END
    Set Test Variable     ${slot1}   ${slots[0]}   

    ${resp}=    Get Appoinment Service By Location   ${loc_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()[0]['id']}       ${s_id1}
    Should Be Equal As Strings  ${resp.json()[0]['name']}     ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()[0]['serviceAvailability']['nextAvailableDate']}    ${DAY}
    Should Be Equal As Strings  ${resp.json()[0]['serviceAvailability']['nextAvailable']}     ${slot1}
   