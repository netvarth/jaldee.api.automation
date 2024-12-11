*** Settings ***
# Suite Teardown    Run Keywords   Delete All Sessions  resetsystem_time
# Test Teardown     Run Keywords   Delete All Sessions  resetsystem_time
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Appointment
Library           Collections
Library           String
Library           json
Library           random
Library           FakerLibrary
Library           /ebs/TDD/CustomKeywords.py
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables          ${EXECDIR}/data/${ENVIRONMENT}_varfiles/providers.py


*** Variables ***

${self}     0
@{service_names}
${domain}       healthCare
${subdomain}    dentists
@{service_duration}  10  20  30   40   50
${SERVICE1}   Registration
# ${SERVICE2}   Registration
${maxBookings}  400

${var_file}               ${EXECDIR}/data/${ENVIRONMENT}_varfiles/providers.py
${data_file}              ${EXECDIR}/data/${ENVIRONMENT}data/${ENVIRONMENT}phnumbers.txt


*** KEYWORDS ***
Enable Department 
    [Documentation]  keyword to enable department

    ${resp}=  Get Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp1}=  Enable Disable Department  ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get Departments
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
            ${dep_name1}=  FakerLibrary.bs
            ${dep_code1}=   Random Int  min=100   max=999
            ${dep_desc1}=   FakerLibrary.word  
            ${resp1}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
            Log  ${resp1.content}
            Should Be Equal As Strings  ${resp1.status_code}  200
            Set Test Variable  ${dep_id}  ${resp1.json()}
    ELSE
            Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    END

RETURN  ${dep_id}


Create Services

    # ---------------Create Service without Prepayment-Registration fee.--------------

    ${s_id1}=  Create Sample Service  ${SERVICE1}  totalAmount=100  maxBookingsAllowed=${maxBookings}


    #----------------------Service with zero service charge------------------

    ${SERVICE2}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE2}
    ${s_id2}=  Create Sample Service  ${SERVICE2}  totalAmount=0  maxBookingsAllowed=${maxBookings}

    #----------------------subservice creation----------------------

    ${subser_name}=    generate_service_name
    Append To List  ${service_names}  ${subser_name}
    ${subser_id1}=  Create Sample Service  ${subser_name}  maxBookingsAllowed=${maxBookings}  serviceCategory=${serviceCategory[0]}

    RETURN  ${s_id1}  ${s_id2}  ${subser_id1}



Create services with department
    [Arguments]   ${dep_id}

    # ---------------Create Service without Prepayment-Registration fee.--------------

    ${s_id1}=  Create Sample Service  ${SERVICE1}  totalAmount=100  maxBookingsAllowed=${maxBookings}  department=${dep_id}

    #----------------------Service with zero service charge------------------

    ${SERVICE2}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE2}
    ${s_id2}=  Create Sample Service  ${SERVICE2}  totalAmount=0  maxBookingsAllowed=${maxBookings}  department=${dep_id}

    #----------------------subservice creation----------------------

    ${subser_name}=    generate_service_name
    Append To List  ${service_names}  ${subser_name}
    ${subser_id1}=  Create Sample Service  ${subser_name}  maxBookingsAllowed=${maxBookings}  serviceCategory=${serviceCategory[0]}  department=${dep_id}

    RETURN  ${s_id1}  ${s_id2}  ${subser_id1}



*** Test Cases ***

JD-TC-Basic-1

    [Documentation]  2 Service,1 sub service,schedule creation.

    ${firstname}  ${lastname}  ${PUSERNAME_B}  ${LoginId}=  Provider Signup   Domain=${domain}   SubDomain=${subdomain}
    Set Suite Variable   ${PUSERNAME_B}
    ${num}=  find_last  ${var_file}
    ${num}=  Evaluate   ${num}+1
    Append To File  ${data_file}  ${LoginId} - ${PASSWORD}${\n}
    Append To File  ${var_file}  PUSERNAME${num}=${LoginId}${\n}
    Log    PUSERNAME${num}


    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${provider_id}  ${decrypted_data['id']}
    Set Test Variable  ${pdrname}  ${decrypted_data['userName']}

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']} 

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=  Get jp finance settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  ${resp.json()['enableJaldeeFinance']}==${bool[0]}
        ${resp1}=    Enable Disable Jaldee Finance   ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get jp finance settings    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointments Today  apptStatus-eq=${apptStatus[1]}  apptStatus-neq=${apptStatus[6]},${apptStatus[5]},${apptStatus[4]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${prepay_appt_len}=  Get Length   ${resp.json()}
    FOR   ${i}  IN RANGE   ${prepay_appt_len}

        ${resp1}=  Appointment Action   ${apptStatus[6]}   ${resp.json()[${i}]['uid']}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        
    END

    ${resp}=  Get Appointments Today  apptStatus-eq=${apptStatus[1]}  apptStatus-neq=${apptStatus[6]},${apptStatus[5]},${apptStatus[4]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${prepay_appt_len}=  Get Length   ${resp.json()}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${prepay_appt_len}  ${self}
    
    ${resp}=  Get Appointments Today  apptStatus-neq=${apptStatus[6]},${apptStatus[5]},${apptStatus[4]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${today_appt_len}=  Get Length   ${resp.json()}
    FOR   ${i}  IN RANGE   ${today_appt_len}

        ${resp1}=  Appointment Action   ${apptStatus[6]}   ${resp.json()[${i}]['uid']}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        
    END

    ${resp}=  Get Appointments Today  apptStatus-neq=${apptStatus[6]},${apptStatus[5]},${apptStatus[4]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${today_appt_len}=  Get Length   ${resp.json()}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${today_appt_len}  ${self}

    ${resp}=  Get Appointments Today
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${today_appt_len}=  Get Length   ${resp.json()}

    ${resp}=  Get Future Appointments  apptStatus-neq=${apptStatus[6]},${apptStatus[5]},${apptStatus[4]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${future_appt_len}=  Get Length   ${resp.json()}
    FOR   ${i}  IN RANGE   ${future_appt_len}

        ${resp1}=  Appointment Action   ${apptStatus[6]}   ${resp.json()[${i}]['uid']}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        
    END

    ${resp}=  Get Future Appointments  apptStatus-neq=${apptStatus[6]},${apptStatus[5]},${apptStatus[4]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${future_appt_len}=  Get Length   ${resp.json()}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${future_appt_len}  ${self}

    ${resp}=  Get Future Appointments
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${future_appt_len}=  Get Length   ${resp.json()}
    
    ${resp}=   Get Appointments History  apptStatus-neq=${apptStatus[6]},${apptStatus[5]},${apptStatus[4]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${past_appt_len}=  Get Length   ${resp.json()}
    FOR   ${i}  IN RANGE   ${past_appt_len}

        ${resp1}=  Appointment Action   ${apptStatus[6]}   ${resp.json()[${i}]['uid']}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        
    END

    # ........ Location Creation .......


    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Suite Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # .................... Enable Department .....................

    ${dep_id}=  Enable Department 

    # ........ Service Creations ............

    ${resp}=    Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    FOR    ${srv_json}    IN   @{resp.json()}
        IF   '${srv_json['status']}' == '${status[0]}' 
            ${resp}=  Disable service  ${srv_json['id']}
            Log  ${resp.content}
            Should Be Equal As Strings  ${resp.status_code}  200
        END
    END

    # ${s_id1}  ${s_id2}  ${subser_id1}=   Create Services
    ${s_id1}  ${s_id2}  ${subser_id1}=   Create services with department  ${dep_id}
    


    # ......Get All Services ..............

    ${resp}=   Get Service By Id  ${s_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${ser_amount1}  ${resp.json()['totalAmount']} 
    
    #.................Create User.........................

    ${user1}=  Create Sample User 
    Set suite Variable                    ${user1}
    
    ${resp}=  Get User By Id            ${user1}
    Log   ${resp.json()}
    Should Be Equal As Strings          ${resp.status_code}  200
    Set Suite Variable  ${user1_id}     ${resp.json()['id']}

    ${name1}=   FakerLibrary.word
    ${resp}=  Create Category   ${name1}  ${categoryType[3]} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${category_id}   ${resp.json()}

    # ...... Create Schedule ........

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    FOR    ${sch_json}  IN  @{resp.json()}
        IF   '${sch_json['apptState']}' == '${Qstate[0]}' 
            ${resp}=  Enable Disable Appointment Schedule  ${sch_json['id']}   ${Qstate[1]}
            Log  ${resp.content}
            Should Be Equal As Strings  ${resp.status_code}  200
        END
    END

    
    # ${cur_date}=   change_system_date   -90
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY3}=  db.add_timezone_date  ${tz}  2  
    ${DAY2}=  db.add_timezone_date  ${tz}  10    
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    # ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_timezone_time  ${tz}  6   00  
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=5
    # ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=2  max=2
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  
    ...   ${s_id2}  ${subser_id1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${timespecString}  ${resp.json()['apptSchedule']['timespecString']}
    # x.apptSchedule.timespecString

    adjust_schedule_date  ${timespecString}  -6  ${sch_id}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${timespecString}  ${resp.json()['apptSchedule']['timespecString']}

    # resetsystem_time

    ${discountprice}=     Pyfloat  right_digits=1  min_value=50  max_value=99
    ${discount_name}=     Set Variable  Rs ${discountprice} Off
    ${desc}=   FakerLibrary.word
    ${resp}=   Create Discount  ${discount_name}   ${desc}    ${discountprice}   ${calctype[1]}  ${disctype[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${discountId}   ${resp.json()}




    


    # ${invoiceDate}=   db.get_date_by_timezone  ${tz}
    # Set Suite Variable   ${invoiceDate}

    # ${invoiceId}=   FakerLibrary.word
    # Set Suite Variable   ${invoiceId}

   
