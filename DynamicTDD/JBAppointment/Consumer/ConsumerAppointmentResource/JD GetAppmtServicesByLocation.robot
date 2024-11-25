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
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py


*** Variables ***

${self}     0
@{service_names}
@{emptylist} 

*** Test Cases ***

JD-TC-GetAppmtServicesByLocation-1

    [Documentation]  Consumer get Service By LocationId.  



    ${firstname}  ${lastname}  ${PUSERNAME_R}  ${LoginId}=  Provider Signup
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

    ${account_id1}=  get_acc_id  ${PUSERNAME_R}
    Set Suite Variable  ${account_id1}
    

    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${sTime}=  db.get_time_by_timezone  ${tz}
    ${eTime}=  add_timezone_time  ${tz}  0  30  
    ${DAY}=  db.get_date_by_timezone  ${tz}   
    Set Suite Variable  ${DAY} 
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}


    ${bs}=  TimeSpec  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}    ${sTime}  ${eTime}
    ${bs}=  Create List  ${bs}
    ${bs}=  Create Dictionary  timespec=${bs}


    ${parking}    Random Element     ${parkingType} 
    ${24hours}    Random Element    ['True','False']
    ${url}=   FakerLibrary.url
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${postcode}     ${address}  googleMapUrl=${url}   parkingType=${parking}  open24hours=${24hours}   bSchedule=${bs}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_l1}  ${resp.json()}


    
    ${sTime1}=  add_timezone_time  ${tz}  1  30  
    ${eTime1}=  add_timezone_time  ${tz}  3  00  
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${parking}    Random Element     ${parkingType} 
    ${24hours}    Random Element    ['True','False']
    ${url}=   FakerLibrary.url

    ${bs1}=  TimeSpec  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}   ${sTime1}  ${eTime1}
    ${bs1}=  Create List  ${bs1}
    ${bs1}=  Create Dictionary  timespec=${bs1}

    ${resp}=  Create Location  ${city}  ${longi}  ${latti}   ${postcode}  ${address}     googleMapUrl=${url}   parkingType=${parking}  open24hours=${24hours}   bSchedule=${bs1}
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

    ${bs2}=  TimeSpec   ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}    ${sTime1}  ${eTime1}
    ${bs2}=  Create List  ${bs2}
    ${bs2}=  Create Dictionary  timespec=${bs2}

    ${resp}=  Create Location  ${city}  ${longi}  ${latti}    ${postcode}  ${address}  googleMapUrl=${url}   parkingType=${parking}  open24hours=${24hours}   bSchedule=${bs2}
    Log  ${resp.json()}
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
    ${resp}=  Create Service  ${P1SERVICE2}  ${desc}  ${service_duration}  ${bool[0]}  ${servicecharge}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_s2}  ${resp.json()}

    ${P1SERVICE3}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${P1SERVICE3}
    Set Suite Variable   ${P1SERVICE3}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE3}  ${desc}  ${service_duration}  ${bool[0]}  ${servicecharge}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_s3}  ${resp.json()}

    ${P1SERVICE4}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${P1SERVICE4}
    Set Suite Variable   ${P1SERVICE4}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE4}  ${desc}  ${service_duration}  ${bool[0]}  ${servicecharge}  ${bool[0]}
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



    #............provider consumer creation..........

    ${PH_Number}=  FakerLibrary.Numerify  %#####
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${PCPHONENO1}  555${PH_Number}

    ${fname1}=  generate_firstname
    Set Suite Variable  ${fname1}
    ${lastname1}=  FakerLibrary.last_name
    
    ${resp}=  AddCustomer  ${PCPHONENO1}    firstName=${fname1}   lastName=${lastname1}  countryCode=${countryCodes[1]}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${PCPHONENO1}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable  ${cid1}  ${resp.json()[0]['id']}

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Send Otp For Login    ${PCPHONENO1}    ${account_id1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${PCPHONENO1}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token1}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${PCPHONENO1}    ${account_id1}  ${token1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    

    ${resp}=    Get All Schedule Slots By Date Location and Service  ${account_id1}  ${DAY1}  ${p1_l1}  ${p1_s1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${no_of_slots}=  Get Length  ${resp.json()[0]['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        IF  ${resp.json()[0]['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Set Test Variable   ${a${i}}  ${resp.json()[0]['availableSlots'][${i}]['time']}
            Append To List   ${slots}  ${resp.json()[0]['availableSlots'][${i}]['time']}
        END
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Test Variable   ${slot1}   ${slots[${j}]}


    ${resp}=    Get All Schedule Slots By Date Location and Service  ${account_id1}  ${DAY1}  ${p1_l1}  ${p1_s3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${no_of_slots}=  Get Length  ${resp.json()[0]['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        IF  ${resp.json()[0]['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Set Test Variable   ${b${i}}  ${resp.json()[0]['availableSlots'][${i}]['time']}
            Append To List   ${slots}  ${resp.json()[0]['availableSlots'][${i}]['time']}
        END
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Test Variable   ${slot2}   ${slots[${j}]}
    
    ${resp}=    Get Appmt Service By LocationId   ${p1_l1}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}   200

    ${len}=  Get Length  ${resp.json()}


    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['id']}' == '${p1_s1}'  

            Should Be Equal As Strings       ${resp.json()[${i}]['name']}                       ${P1SERVICE1}       
            Should Be Equal As Strings  ${resp.json()[${i}]['status']}                      ${status[0]}     
            # Should Be Equal As Strings  ${resp.json()[${i}]['notificationType']}                        ${notifytype[2]}
            Should Be Equal As Strings  ${resp.json()[${i}]['serviceDuration']}                            ${service_duration}   
            Should Be Equal As Strings  ${resp.json()[${i}]['serviceAvailability']['nextAvailableDate']}                              ${DAY1}
            Should Be Equal As Strings  ${resp.json()[${i}]['serviceAvailability']['nextAvailable']}                              ${a${i}}

        ELSE IF     '${resp.json()[${i}]['id']}' == '${p1_s3}'  

            Should Be Equal As Strings       ${resp.json()[${i}]['name']}                       ${P1SERVICE3}       
            Should Be Equal As Strings  ${resp.json()[${i}]['status']}                      ${status[0]}     
            # Should Be Equal As Strings  ${resp.json()[${i}]['notificationType']}                        ${notifytype[2]}
            Should Be Equal As Strings  ${resp.json()[${i}]['serviceDuration']}                            ${service_duration}   
            Should Be Equal As Strings  ${resp.json()[${i}]['serviceAvailability']['nextAvailableDate']}                              ${DAY1}
            Should Be Equal As Strings  ${resp.json()[${i}]['serviceAvailability']['nextAvailable']}                              ${b0}

        END
    END

   
JD-TC-GetAppmtServicesByLocation-2

    [Documentation]  Consumer get Service By another LocationId of the same provider.

   ${resp}=    ProviderConsumer Login with token   ${PCPHONENO1}    ${account_id1}  ${token1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Appmt Service By LocationId   ${p1_l2}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}   200
    Should Be Equal As Strings       ${resp.json()[0]['id']}                       ${p1_s2}  
    Should Be Equal As Strings       ${resp.json()[0]['name']}                       ${P1SERVICE2}       
    Should Be Equal As Strings  ${resp.json()[0]['status']}                      ${status[0]}     
    # Should Be Equal As Strings  ${resp.json()[0]['notificationType']}                        ${notifytype[2]}
    Should Be Equal As Strings  ${resp.json()[0]['serviceDuration']}                            ${service_duration}   
    Should Be Equal As Strings       ${resp.json()[1]['id']}                       ${p1_s3}  
    Should Be Equal As Strings       ${resp.json()[1]['name']}                       ${P1SERVICE3}       
    Should Be Equal As Strings  ${resp.json()[1]['status']}                      ${status[0]}     
    # Should Be Equal As Strings  ${resp.json()[1]['notificationType']}                        ${notifytype[2]}
    Should Be Equal As Strings  ${resp.json()[1]['serviceDuration']}                            ${service_duration}  


JD-TC-GetAppmtServicesByLocation-3

    [Documentation]  Consumer get Service By LocationId which is not added in the appointment schedule.

   ${resp}=    ProviderConsumer Login with token   ${PCPHONENO1}    ${account_id1}  ${token1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Appmt Service By LocationId   ${p1_l2}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}   200
    Should Be Equal As Strings       ${resp.json()[0]['id']}                       ${p1_s2}  
    Should Be Equal As Strings       ${resp.json()[0]['name']}                       ${P1SERVICE2}       
    Should Be Equal As Strings  ${resp.json()[0]['status']}                      ${status[0]}     
    # Should Be Equal As Strings  ${resp.json()[0]['notificationType']}                        ${notifytype[2]}
    Should Be Equal As Strings  ${resp.json()[0]['serviceDuration']}                            ${service_duration}   
    Should Be Equal As Strings       ${resp.json()[1]['id']}                       ${p1_s3}  
    Should Be Equal As Strings       ${resp.json()[1]['name']}                       ${P1SERVICE3}       
    Should Be Equal As Strings  ${resp.json()[1]['status']}                      ${status[0]}     
    # Should Be Equal As Strings  ${resp.json()[1]['notificationType']}                        ${notifytype[2]}
    Should Be Equal As Strings  ${resp.json()[1]['serviceDuration']}                            ${service_duration}  
    Should Not Contain  ${resp.json()}  ${p1_s4}

    ${resp}=    Get Appmt Service By LocationId   ${p1_l1}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}   200
    Should Be Equal As Strings       ${resp.json()[0]['id']}                       ${p1_s1}  
    Should Be Equal As Strings       ${resp.json()[0]['name']}                       ${P1SERVICE1}       
    Should Be Equal As Strings  ${resp.json()[0]['status']}                      ${status[0]}     
    # Should Be Equal As Strings  ${resp.json()[0]['notificationType']}                        ${notifytype[2]}
    Should Be Equal As Strings  ${resp.json()[0]['serviceDuration']}                            ${service_duration}   
    Should Be Equal As Strings       ${resp.json()[1]['id']}                       ${p1_s3}  
    Should Be Equal As Strings       ${resp.json()[1]['name']}                       ${P1SERVICE3}       
    Should Be Equal As Strings  ${resp.json()[1]['status']}                      ${status[0]}     
    # Should Be Equal As Strings  ${resp.json()[1]['notificationType']}                        ${notifytype[2]}
    Should Be Equal As Strings  ${resp.json()[1]['serviceDuration']}                            ${service_duration}  
    Should Not Contain  ${resp.json()}  ${p1_s4}

JD-TC-GetAppmtServicesByLocation-4

    [Documentation]  Consumer get Service By LocationId, When  One Service is disabled.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_R}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${RESP}=  Disable service  ${p1_s1} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

   ${resp}=    ProviderConsumer Login with token   ${PCPHONENO1}    ${account_id1}  ${token1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Appmt Service By LocationId   ${p1_l1}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}   200
    Should Not Contain  ${resp.json()}  ${p1_s1}
    Should Be Equal As Strings  ${resp.json()[0]['id']}  ${p1_s3}
    Should Be Equal As Strings  ${resp.json()[0]['name']}  ${P1SERVICE3}

   ${resp}=  Encrypted Provider Login  ${PUSERNAME_R}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${RESP}=  Enable service  ${p1_s1} 
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-GetAppmtServicesByLocation-5

    [Documentation]  Consumer get Service By LocationId, When  All Services in this location are disabled
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_R}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${RESP}=  Disable service  ${p1_s1} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${RESP}=  Disable service  ${p1_s3} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

   ${resp}=    ProviderConsumer Login with token   ${PCPHONENO1}    ${account_id1}  ${token1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Appmt Service By LocationId   ${p1_l1}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}   200
    Should Not Contain  ${resp.json()}  ${p1_s1}
    Should Not Contain  ${resp.json()}  ${p1_s3}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_R}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${RESP}=  Enable service  ${p1_s1} 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${RESP}=  Enable service  ${p1_s3} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-GetAppmtServicesByLocation-7

    [Documentation]  Consumer get Service By LocationId, which doesn't contain any service. 


    ${resp}=    ProviderConsumer Login with token   ${PCPHONENO1}    ${account_id1}  ${token1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Appmt Service By LocationId   ${p1_l3}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}   200
    Should Be Equal As Strings   ${resp.json()}   []

    ${resp}=    Consumer Logout 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-GetAppmtServicesByLocation-8

    [Documentation]  Consumer get Service By LocationId without login.

    ${resp}=    Get Appmt Service By LocationId   ${p1_l2}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}   200
    Should Be Equal As Strings       ${resp.json()[0]['id']}                       ${p1_s2}  
    Should Be Equal As Strings       ${resp.json()[0]['name']}                       ${P1SERVICE2}       
    Should Be Equal As Strings  ${resp.json()[0]['status']}                      ${status[0]}     
    # Should Be Equal As Strings  ${resp.json()[0]['notificationType']}                        ${notifytype[2]}
    Should Be Equal As Strings  ${resp.json()[0]['serviceDuration']}                            ${service_duration}   
    Should Be Equal As Strings       ${resp.json()[1]['id']}                       ${p1_s3}  
    Should Be Equal As Strings       ${resp.json()[1]['name']}                       ${P1SERVICE3}       
    Should Be Equal As Strings  ${resp.json()[1]['status']}                      ${status[0]}     
    # Should Be Equal As Strings  ${resp.json()[1]['notificationType']}                        ${notifytype[2]}
    Should Be Equal As Strings  ${resp.json()[1]['serviceDuration']}                            ${service_duration}  


JD-TC-GetAppmtServicesByLocation-9
    
    [Documentation]   Try to get an appt service by a provider consumer.

    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME117}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}
   
    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        Set Test Variable  ${locId}
        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    ${service_duration}=   Random Int   min=5   max=10
    ${P1SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${P1SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}  ${service_duration}  ${bool[0]}  ${servicecharge}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${ser_id1}  ${resp.json()}    

    ${resp}=   Get Service By Id  ${ser_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${locId}  ${duration}  ${bool1}  ${ser_id1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${firstName}=  FakerLibrary.name
    ${lastName}=  FakerLibrary.last_name
    ${primaryMobileNo}    Generate random string    10    123456789
    ${primaryMobileNo}    Convert To Integer  ${primaryMobileNo}
    ${email}=    FakerLibrary.Email

    ${resp}=    Provider Logout 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
   
    ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${account_id1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    ${resp}=    Consumer Logout 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email}    ${primaryMobileNo}     ${account_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200    
   
    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${account_id1}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Appmt Service By LocationId   ${locId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}  ${ser_id1}
    Should Be Equal As Strings  ${resp.json()[0]['name']}  ${P1SERVICE1}

    ${resp}=    Consumer Logout 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-GetAppmtServicesByLocation-UH1

    [Documentation]  Trying to Consumer get Service By LocationId, wiht an invalid location.
    
   ${resp}=    ProviderConsumer Login with token   ${PCPHONENO1}    ${account_id1}  ${token1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Appmt Service By LocationId   0
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}   404
    Should Be Equal As Strings  "${resp.json()}"       "${LOCATION_NOT_FOUND}"

    ${resp}=    Consumer Logout 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-GetAppmtServicesByLocation-UH2

    [Documentation]  Trying to Consumer get Service By LocationId, When Location is disabled 
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_R}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Disable Location  ${p1_l2} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderConsumer Login with token   ${PCPHONENO1}    ${account_id1}  ${token1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Appmt Service By LocationId   ${p1_l2}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}   422
    Should Be Equal As Strings  "${resp.json()}"       "${LOCATION_DISABLED}"

   ${resp}=  Encrypted Provider Login  ${PUSERNAME_R}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${RESP}=  Enable Location  ${p1_l2} 
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-GetAppmtServicesByLocation-UH3
    
    [Documentation]   Try to get an appt service(not added in appt schedule) by a provider consumer.

    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME115}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}
   
    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        Set Test Variable  ${locId}
        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    ${service_duration}=   Random Int   min=5   max=10
    ${P1SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${P1SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}  ${service_duration}  ${bool[0]}  ${servicecharge}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${ser_id1}  ${resp.json()}    

    ${resp}=   Get Service By Id  ${ser_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

       #............provider consumer creation..........



    ${fname1}=  generate_firstname
    Set Suite Variable  ${fname1}
    ${lastname1}=  FakerLibrary.last_name
    
    ${resp}=  AddCustomer  ${CUSERNAME17}    firstName=${fname1}   lastName=${lastname1}  countryCode=${countryCodes[1]}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME17}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()[0]['id']}

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Send Otp For Login    ${CUSERNAME17}    ${account_id1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${CUSERNAME17}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token1}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME17}    ${account_id1}  ${token1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    

    ${resp}=  Get Appmt Service By LocationId   ${locId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}        []


JD-TC-GetAppmtServicesByLocation-UH4
    
    [Documentation]   Try to get an appt service(not added in appt schedule) by a provider consumer.

    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME114}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}
   
    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        Set Test Variable  ${locId}
        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    ${service_duration}=   Random Int   min=5   max=10
    ${P1SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${P1SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}  ${service_duration}  ${bool[0]}  ${servicecharge}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${ser_id1}  ${resp.json()}    

    ${resp}=   Get Service By Id  ${ser_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${firstName}=  FakerLibrary.name
    ${lastName}=  FakerLibrary.last_name
    ${primaryMobileNo}    Generate random string    10    123456789
    ${primaryMobileNo}    Convert To Integer  ${primaryMobileNo}
    ${email}=    FakerLibrary.Email
   
    ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${account_id1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    ${resp}=    Consumer Logout 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email}    ${primaryMobileNo}     ${account_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200    
   
    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${account_id1}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Appmt Service By LocationId   ${locId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}        []

JD-TC-GetAppmtServicesByLocation-10

    [Documentation]  Consumer get Service By LocationId THEN VERIFY NEXT AVAILABLE DATE.  



    ${firstname}  ${lastname}  ${PUSERNAME_S}  ${LoginId}=  Provider Signup

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    # clear_service   ${PUSERNAME_S}
    # clear_location  ${PUSERNAME_S}
   

    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    ${sTime}=  db.get_time_by_timezone  ${tz}
    ${eTime}=  add_timezone_time  ${tz}  0  30  
    ${DAY1}=  db.get_date_by_timezone  ${tz}   
    ${list}=  Create List  1  2  3  4  5  6  7

    ${bs}=  TimeSpec  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}    ${sTime}  ${eTime}
    ${bs}=  Create List  ${bs}
    ${bs}=  Create Dictionary  timespec=${bs}
  
    ${parking}    Random Element     ${parkingType} 
    ${24hours}    Random Element    ['True','False']
    ${url}=   FakerLibrary.url
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${postcode}     ${address}  googleMapUrl=${url}   parkingType=${parking}  open24hours=${24hours}   bSchedule=${bs}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_l1}  ${resp.json()}
   
    # clear_appt_schedule   ${PUSERNAME_S}

    ${account_id2}=  get_acc_id  ${PUSERNAME_S}
    Set Test Variable  ${account_id2}
        
    ${service_duration}=   Random Int   min=5   max=10
    ${P1SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${P1SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}  ${service_duration}  ${bool[0]}  ${servicecharge}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1_s1}  ${resp.json()}    
 
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${sTime1}=  db.subtract_timezone_time  ${tz}  2  15  
    ${eTime1}=  add_timezone_time  ${tz}  2  15  
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=2  max=5
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${p1_l1}  ${duration}  ${bool1}  ${p1_s1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id1}   name=${schedule_name}  apptState=${Qstate[0]}

       #............provider consumer creation..........

    ${PH_Number}=  FakerLibrary.Numerify  %#####
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${PCPHONENO2}  555${PH_Number}

    ${fname1}=  generate_firstname
    Set Suite Variable  ${fname1}
    ${lastname1}=  FakerLibrary.last_name
    
    ${resp}=  AddCustomer  ${PCPHONENO2}    firstName=${fname1}   lastName=${lastname1}  countryCode=${countryCodes[1]}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${PCPHONENO2}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable  ${cid1}  ${resp.json()[0]['id']}

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Send Otp For Login    ${PCPHONENO2}    ${account_id2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${PCPHONENO2}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token1}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${PCPHONENO2}    ${account_id2}  ${token1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    

    ${resp}=    Get All Schedule Slots By Date Location and Service  ${account_id2}  ${DAY1}  ${p1_l1}  ${p1_s1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${no_of_slots}=  Get Length  ${resp.json()[0]['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        IF  ${resp.json()[0]['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Set Test Variable   ${slot${i}}  ${resp.json()[0]['availableSlots'][${i}]['time']}
            Append To List   ${slots}  ${resp.json()[0]['availableSlots'][${i}]['time']}
        END
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Test Variable   ${slot1}   ${slots[${j}]}

   
    ${resp}=  Consumer Logout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Appmt Service By LocationId   ${p1_l1}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}   200
    Should Be Equal As Strings   ${resp.json()[0]['serviceAvailability']['nextAvailableDate']}  ${DAY1}

   
# JD-TC-GetAppmtServicesByLocation-UH3

#     [Documentation]  Consumer get Service By LocationId without login.

#     ${resp}=    Get Appmt Service By LocationId   ${p1_l2}
#     Log   ${resp.json()}
#     Should Be Equal As Strings   ${resp.status_code}   419
#     Should Be Equal As Strings  "${resp.json()}"       "${SESSION_EXPIRED}"
