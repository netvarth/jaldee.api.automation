*** Settings ***
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
${jpgfile}      /ebs/TDD/uploadimage.jpg
${order}        0
${fileSize}     0.00458
${pdffile}      /ebs/TDD/sample.pdf
${domain}       healthCare
${subdomain}    dentists
${MEET_URL}    https://meet.google.com/{meeting_id}
@{service_duration}  10  20  30   40   50

${var_file}               ${EXECDIR}/data/${ENVIRONMENT}_varfiles/providers.py
${data_file}              ${EXECDIR}/data/${ENVIRONMENT}data/${ENVIRONMENT}phnumbers.txt

*** Test Cases ***

JD-TC-Schedule-1

    [Documentation]  Schedule workflow for pre deployment.

    ${firstname}  ${lastname}  ${PUSERNAME_B}  ${LoginId}=  Provider Signup   Domain=${domain}   SubDomain=${subdomain}
    Set Suite Variable   ${PUSERNAME_B}
    # ${num}=  find_last  ${var_file}
    # ${num}=  Evaluate   ${num}+1
    # Append To File  ${data_file}  ${LoginId} - ${PASSWORD}${\n}
    # Append To File  ${var_file}  PUSERNAME${num}=${LoginId}${\n}
    # Log    PUSERNAME${num}
    # ${PUSERNAME_B}=  Set Variable  ${PUSERNAME17}
    # ${PUSERNAME_B}=  Set Variable  ${PUSERNAME23}

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
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  ${resp.json()['enableJaldeeFinance']}==${bool[0]}
        ${resp1}=    Enable Disable Jaldee Finance   ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get jp finance settings    
    Log  ${resp.json()}
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
    FOR     ${loc_json}    IN   @{resp.json()}
        IF   '${loc_json['status']}' == '${status[0]}' and '${loc_json['baseLocation']}' == '${bool[0]}'
            ${resp}=  Disable Location  ${loc_json['id']}
            Log  ${resp.content}
            Should Be Equal As Strings  ${resp.status_code}  200
        END
    END

    ${lid}=  Create Sample Location
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${tz}  ${resp.json()['timezone']}

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

    #  1. Create Service without Prepayment-Registration fee.

    ${ser_durtn}=   Random Int   min=2   max=2
    ${desc}=   FakerLibrary.sentence
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${ser_durtn}  ${bool[0]}  100  ${bool[0]}    maxBookingsAllowed=400
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id1}  ${resp.json()}

    # ${SERVICE1}=    generate_unique_service_name  ${service_names}      
    # Append To List  ${service_names}  ${SERVICE1}   
    # ${s_id1}=  Create Sample Service  ${SERVICE1}    maxBookingsAllowed=200   automaticInvoiceGeneration=${bool[0]}
    #----------------------Service with zero service charge------------------


    ${SERVICE2}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE2}
    ${desc1}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${SERVICE2}  ${desc1}   ${ser_durtn}  ${bool[0]}  0  ${bool[0]}     maxBookingsAllowed=400
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id2}  ${resp.json()}

    ##....subservice creation..........

    ${desc}=  FakerLibrary.sentence
    ${subser_dur}=   Random Int   min=5   max=10
    ${subser_price}=   Random Int   min=100   max=500
    ${subser_price}=  Convert To Number  ${subser_price}  1
    Set Suite Variable   ${subser_price}
    ${subser_name}=    generate_service_name
    Set Suite Variable   ${subser_name}

    ${resp}=  Create Service    ${subser_name}  ${desc}   ${subser_dur}  ${bool[0]}  ${subser_price}  ${bool[0]}   serviceCategory=${serviceCategory[0]}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${subser_id1}  ${resp.json()}
    
    # #  2. Create Service without Prepayment and Max Bookings Allowed > 1

    # ${SERVICE2}=    generate_unique_service_name  ${service_names}
    # Append To List  ${service_names}  ${SERVICE2}   
    # ${s_id2}=  Create Sample Service  ${SERVICE2}      maxBookingsAllowed=10
    
    # #  3. Create Service with Fixed Prepayment

    # ${SERVICE3}=    generate_unique_service_name  ${service_names}
    # Append To List  ${service_names}  ${SERVICE3}   
    # ${min_pre3}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    # ${s_id3}=  Create Sample Service  ${SERVICE3}   isPrePayment=${bool[1]}   minPrePaymentAmount=${min_pre3} 

    # #  4. Create Service with Percentage Prepayment

    # ${SERVICE4}=    generate_unique_service_name  ${service_names}
    # Append To List  ${service_names}  ${SERVICE4}   
    # ${min_pre4}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    # ${s_id4}=  Create Sample Service  ${SERVICE4}   isPrePayment=${bool[1]}   prePaymentType=${advancepaymenttype[0]}  minPrePaymentAmount=${min_pre4} 

    # #  5. Create Taxable Service

    # ${SERVICE5}=    generate_unique_service_name  ${service_names}
    # Append To List  ${service_names}  ${SERVICE5}   
    # ${s_id5}=  Create Sample Service  ${SERVICE5}   taxable=${bool[1]} 

    # #  6. Create Service with Lead Time

    # ${SERVICE6}=    generate_unique_service_name  ${service_names}
    # Append To List  ${service_names}  ${SERVICE6}  
    # ${leadTime}=   Random Int   min=1   max=5 
    # ${s_id6}=  Create Sample Service  ${SERVICE6}    leadTime=${leadTime}

    # #  7. Create Service with International Pricing

    # ${SERVICE7}=    generate_unique_service_name  ${service_names}
    # Append To List  ${service_names}  ${SERVICE7}
    # ${intlamt}=  Pyfloat  right_digits=1  min_value=250  max_value=500
    # ${s_id7}=  Create Sample Service  ${SERVICE7}  supportInternationalConsumer=${bool[1]}  internationalAmount=${intlamt}

    # #  8. Create Service with Dynamic Pricing

    # ${SERVICE8}=    generate_unique_service_name  ${service_names}
    # Append To List  ${service_names}  ${SERVICE8}  
    # ${leadTime}=   Random Int   min=1   max=5 
    # ${s_id8}=  Create Sample Service  ${SERVICE8}    priceDynamic=${bool[1]}

    # #  9. Create Virtual Service with Audio Only

    # ${meeting_id}=   FakerLibrary.lexify  text='???-????-???'  letters=${lower}
    # ${GoogleMeet_url}=     Format String    ${MEET_URL}    meeting_id=${meeting_id}
    # Log    ${meet_url}
    
    # ${Description1}=    FakerLibrary.sentences
    # ${instructions2}=   FakerLibrary.sentence
    # ${VScallingMode1}=   Create Dictionary   callingMode=${CallingModes[2]}   value=${PUSERNAME_B}   countryCode=${countryCodes[0]}    instructions=${Description1[0]}${\n}${Description1[1]}${\n}${Description1[2]}
    # ${VScallingMode2}=   Create Dictionary   callingMode=${CallingModes[1]}   value=${PUSERNAME_B}   countryCode=${countryCodes[0]}  instructions=${instructions2} 
    # ${virtualCallingModes}=  Create List  ${VScallingMode1}  ${VScallingMode2}
    # ${vstype}=   Set Variable   ${vservicetype[0]}

    # ${description}=    FakerLibrary.sentence
    # ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    # ${Total}=  Pyfloat  right_digits=1  min_value=100  max_value=500
    # ${SERVICE9}=    generate_unique_service_name  ${service_names}
    # Append To List  ${service_names}  ${SERVICE9}
    # ${resp}=  Create Service  ${SERVICE9}  ${description}  ${service_duration[1]}  ${bool[0]}  ${Total}  ${bool[0]}  serviceType=${ServiceType[0]}  virtualServiceType=${vstype}  virtualCallingModes=${virtualCallingModes}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${s_id9}  ${resp.json()}

    # #  10. Create Virtual Service with Video Only

    # ${meeting_id}=   FakerLibrary.lexify  text='???-????-???'  letters=${lower}
    # ${GoogleMeet_url}=     Format String    ${MEET_URL}    meeting_id=${meeting_id}
    # Log    ${meet_url}
    
    # ${Description1}=    FakerLibrary.sentences
    # ${instructions2}=   FakerLibrary.sentence
    # ${VScallingMode1}=   Create Dictionary   callingMode=${CallingModes[3]}   value=${GoogleMeet_url}   status=${status[0]}    instructions=${Description1[0]}${\n}${Description1[1]}${\n}${Description1[2]}
    # ${VScallingMode2}=   Create Dictionary   callingMode=${CallingModes[1]}   value=${PUSERNAME_B}   countryCode=${countryCodes[0]}  instructions=${instructions2} 
    # ${virtualCallingModes}=  Create List  ${VScallingMode1}  ${VScallingMode2}
    # ${vstype}=   Set Variable   ${vservicetype[1]}

    # ${description}=    FakerLibrary.sentence
    # ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    # ${Total}=  Pyfloat  right_digits=1  min_value=100  max_value=500
    # ${SERVICE10}=    generate_unique_service_name  ${service_names}
    # Append To List  ${service_names}  ${SERVICE10}
    # ${resp}=  Create Service  ${SERVICE10}  ${description}  ${service_duration[1]}  ${bool[0]}  ${Total}  ${bool[0]}  serviceType=${ServiceType[0]}  virtualServiceType=${vstype}  virtualCallingModes=${virtualCallingModes}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${s_id10}  ${resp.json()}

    # ......Get All Services ..............

    ${resp}=   Get Service By Id  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${ser_amount1}  ${resp.json()['totalAmount']} 
    
    # ${resp}=   Get Service By Id  ${s_id2}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${ser_amount2}  ${resp.json()['totalAmount']} 

    # ${resp}=   Get Service By Id  ${s_id3}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${pre_pay3}  ${resp.json()['minPrePaymentAmount']} 

    # ${resp}=   Get Service By Id  ${s_id4}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${ser_amount4}  ${resp.json()['totalAmount']} 
    
    # ${resp}=   Get Service By Id  ${s_id5}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
   
    # ${resp}=   Get Service By Id  ${s_id6}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=   Get Service By Id  ${s_id7}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=   Get Service By Id  ${s_id8}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=   Get Service By Id  ${s_id9}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=   Get Service By Id  ${s_id10}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

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
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  
    ...   ${s_id2}  ${subser_id1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    # # .......Update Schedule .......

    # ${parallel}=  FakerLibrary.Random Int  min=6  max=10
    # ${resp}=  Update Appointment Schedule  ${sch_id}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
    # ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
    # ...  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${parallel}  ${parallel}  ${lid}  ${resp.json()['timeDuration']}  ${bool[1]}  
    # ...  ${s_id1}  ${s_id2}  ${s_id3}  ${s_id4}  ${s_id5}  ${s_id6}  ${s_id7}  ${s_id8}  ${s_id9}  ${s_id10} 

    # # .......Disable Schedule .......

    # ${resp}=  Enable Disable Appointment Schedule  ${sch_id}  ${Qstate[1]}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # # .......Enable Schedule .......

    # ${resp}=  Enable Disable Appointment Schedule  ${sch_id}  ${Qstate[0]}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id1}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    # @{slots}=  Create List
    # FOR   ${i}  IN RANGE   0   ${no_of_slots}
    #     IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
    #         Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    #     END
    # END
    # ${num_slots}=  Get Length  ${slots}
    # ${j1}=  Random Int  max=${num_slots-1}
    # Set Test Variable   ${wslot1}   ${slots[${j1}]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    # Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    ${slots}=  Create List
    FOR   ${i}  IN RANGE   ${no_of_slots}
        ${available_slots_cnt}=  Set Variable  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']}
        FOR   ${j}  IN RANGE   ${available_slots_cnt}
            Append To List  ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
        END
    END
    ${slots_len}=  Get Length  ${slots}


    ${name1}=   FakerLibrary.word
    ${resp}=  Create Category   ${name1}  ${categoryType[3]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${category_id}   ${resp.json()}


    ${invoiceDate}=   db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${invoiceDate}

    ${invoiceId}=   FakerLibrary.word
    Set Suite Variable   ${invoiceId}


    # .......... Take appointent for service with zero amount..........
    FOR   ${i}  IN RANGE   200
        ${PO_Number}    Generate random string    5    0123456789
        ${PO_Number}    Convert To Integer  ${PO_Number}
        ${CUSERPH}=  Evaluate  ${CUSERNAME}+${PO_Number}
        Set Test Variable  ${CUSERPH${i}}  ${CUSERPH}
        ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH${i}}  
        Log  ${resp.content}
        Should Be Equal As Strings      ${resp.status_code}  200
        IF   '${resp.content}' == '${emptylist}'
            ${firstname}=  FakerLibrary.name
            ${lastname}=  FakerLibrary.last_name
            ${resp1}=  AddCustomer  ${CUSERPH${i}}   firstName=${firstname}   lastName=${lastname}  countryCode=${countryCodes[1]}
            Log  ${resp1.content}
            Should Be Equal As Strings  ${resp1.status_code}  200
            Set Test Variable  ${cid${i}}  ${resp1.json()}
        ELSE
            Set Suite Variable  ${cid${i}}  ${resp.json()[0]['id']}
            Set Suite Variable  ${firstname}  ${resp.json()[0]['firstName']}
        END

        ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH${i}}  
        Log  ${resp.content}
        Should Be Equal As Strings      ${resp.status_code}  200

        # ......... Take walkin appointments for all services .........

        ${apptfor1}=  Create Dictionary  id=${cid${i}}   apptTime=${slots[${i}]}
        ${apptfor}=   Create List  ${apptfor1}

        ${cnote}=   FakerLibrary.word
        ${resp}=  Take Appointment For Consumer  ${cid${i}}  ${s_id2}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
        Set Test Variable  ${wapptid1}  ${apptid[0]}

        ${resp}=  Get Appointment By Id   ${wapptid1}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${providerConsumerIdList}=  Create List  ${cid${i}}
        Set Test Variable  ${providerConsumerIdList}   
        
        ${quantity}=   Random Int  min=5  max=10
        ${quantity}=  Convert To Number  ${quantity}  1
        ${servicecharge}=   Random Int  min=5  max=10



        ${serviceList}=  Create Dictionary  serviceId=${s_id1}   quantity=${quantity} 
        ${serviceList1}=  Create Dictionary  serviceId=${s_id2}   quantity=${quantity}    price=${servicecharge}
        #  price=${servicecharge}
        ${serviceList}=    Create List    ${serviceList}   ${serviceList1}
        Set Test Variable   ${serviceList}

        ${servicenetRate}=  Evaluate  ${quantity} * 100
        ${servicenetRate2}=  Evaluate  ${quantity} * ${servicecharge}
        ${Total}=  Evaluate  ${servicenetRate} + ${servicenetRate2}

        
        ${resp}=  Create Invoice   ${category_id}    ${invoiceDate}      ${invoiceId}    ${providerConsumerIdList}   ${lid}   serviceList=${serviceList}        ynwUuid=${wapptid1}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable   ${invoice_uid}   ${resp.json()['uidList'][0]}  

        ${resp1}=  Get Invoice By Id  ${invoice_uid}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200


    END

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    # Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    ${slots}=  Create List
    FOR   ${i}  IN RANGE   ${no_of_slots}
        ${available_slots_cnt}=  Set Variable  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']}
        FOR   ${j}  IN RANGE   ${available_slots_cnt}
            Append To List  ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
        END
    END
    ${slots_len}=  Get Length  ${slots}
#---------------------------------Take appt for service with zero amount and make payment for that invoice######################33333333333

    FOR   ${i}  IN RANGE   200
        ${PO_Number}    Generate random string    5    0123456789
        ${PO_Number}    Convert To Integer  ${PO_Number}
        ${CUSERPH}=  Evaluate  ${CUSERNAME}+${PO_Number}
        Set Test Variable  ${CUSERPH${i}}  ${CUSERPH}
        ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH${i}}  
        Log  ${resp.content}
        Should Be Equal As Strings      ${resp.status_code}  200
        IF   '${resp.content}' == '${emptylist}'
            ${firstname}=  FakerLibrary.name
            ${lastname}=  FakerLibrary.last_name
            ${resp1}=  AddCustomer  ${CUSERPH${i}}   firstName=${firstname}   lastName=${lastname}  countryCode=${countryCodes[1]}
            Log  ${resp1.content}
            Should Be Equal As Strings  ${resp1.status_code}  200
            Set Test Variable  ${cid${i}}  ${resp1.json()}
        ELSE
            Set Suite Variable  ${cid${i}}  ${resp.json()[0]['id']}
            Set Suite Variable  ${firstname}  ${resp.json()[0]['firstName']}
        END

        ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH${i}}  
        Log  ${resp.content}
        Should Be Equal As Strings      ${resp.status_code}  200

        # ......... Take walkin appointments for all services .........

        ${apptfor1}=  Create Dictionary  id=${cid${i}}   apptTime=${slots[${i}]}
        ${apptfor}=   Create List  ${apptfor1}

        ${cnote}=   FakerLibrary.word
        ${resp}=  Take Appointment For Consumer  ${cid${i}}  ${s_id2}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
        Set Test Variable  ${wapptid1}  ${apptid[0]}

        ${resp}=  Get Appointment By Id   ${wapptid1}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable   ${fullAmount}  ${resp.json()['fullAmount']}         

        # ${resp}=  Get Booking Invoices  ${wapptid1}
        # Log   ${resp.content}
        # Should Be Equal As Strings  ${resp.status_code}  200


        ${providerConsumerIdList}=  Create List  ${cid${i}}
        Set Test Variable  ${providerConsumerIdList}   
        
        
        # ${servicenetRate}=  Convert To Number  ${servicenetRate}   2
        # Set Test Variable   ${servicenetRate}

        
        ${resp}=  Create Invoice   ${category_id}    ${invoiceDate}      ${invoiceId}    ${providerConsumerIdList}   ${lid}   serviceList=${serviceList}        ynwUuid=${wapptid1}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable   ${invoice_uid}   ${resp.json()['uidList'][0]}  


        ${resp1}=  Get Invoice By Id  ${invoice_uid}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200

        # ${note}=    FakerLibrary.word
        # # Set Suite Variable  ${note}   
        # ${resp}=  Make Payment By Cash   ${wapptid1}  ${payment_modes[0]}  ${fullAmount}  ${note}
        # Log  ${resp.json()}
        # Should Be Equal As Strings  ${resp.status_code}  200

        ${note}=    FakerLibrary.word
        ${resp}=  Make Payment By Cash For Invoice   ${invoice_uid}  ${payment_modes[0]}  ${Total}  ${note}  paymentOndate=${DAY1}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${user1}=  Create Sample User 
    Set suite Variable                    ${user1}
    
    ${resp}=  Get User By Id            ${user1}
    Log   ${resp.json()}
    Should Be Equal As Strings          ${resp.status_code}  200
    Set Suite Variable  ${user1_id}     ${resp.json()['id']}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    # Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    ${slots}=  Create List
    FOR   ${i}  IN RANGE   ${no_of_slots}
        ${available_slots_cnt}=  Set Variable  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']}
        FOR   ${j}  IN RANGE   ${available_slots_cnt}
            Append To List  ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
        END
    END
    ${slots_len}=  Get Length  ${slots}
#-------------------------Take appt for one service-Add sub service in that appt and also that sub service to a  user**************************
    FOR   ${i}  IN RANGE   200
        ${PO_Number}    Generate random string    5    0123456789
        ${PO_Number}    Convert To Integer  ${PO_Number}
        ${CUSERPH}=  Evaluate  ${CUSERNAME}+${PO_Number}
        Set Test Variable  ${CUSERPH${i}}  ${CUSERPH}
        ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH${i}}  
        Log  ${resp.content}
        Should Be Equal As Strings      ${resp.status_code}  200
        IF   '${resp.content}' == '${emptylist}'
            ${firstname}=  FakerLibrary.name
            ${lastname}=  FakerLibrary.last_name
            ${resp1}=  AddCustomer  ${CUSERPH${i}}   firstName=${firstname}   lastName=${lastname}  countryCode=${countryCodes[1]}
            Log  ${resp1.content}
            Should Be Equal As Strings  ${resp1.status_code}  200
            Set Test Variable  ${cid${i}}  ${resp1.json()}
        ELSE
            Set Suite Variable  ${cid${i}}  ${resp.json()[0]['id']}
            Set Suite Variable  ${firstname}  ${resp.json()[0]['firstName']}
        END

        ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH${i}}  
        Log  ${resp.content}
        Should Be Equal As Strings      ${resp.status_code}  200

        # ......... Take walkin appointments for all services .........

        ${apptfor1}=  Create Dictionary  id=${cid${i}}   apptTime=${slots[${i}]}
        ${apptfor}=   Create List  ${apptfor1}

        ${cnote}=   FakerLibrary.word
        ${resp}=  Take Appointment For Consumer  ${cid${i}}  ${s_id2}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
        Set Test Variable  ${wapptid1}  ${apptid[0]}

        ${resp}=  Get Appointment By Id   ${wapptid1}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${providerConsumerIdList}=  Create List  ${cid${i}}
        Set Test Variable  ${providerConsumerIdList}   
        
        ${quantity}=   Random Int  min=5  max=10
        ${quantity}=  Convert To Number  ${quantity}  1
        ${servicecharge}=   Random Int  min=5  max=10



        ${serviceList}=  Create Dictionary  serviceId=${s_id1}   quantity=${quantity} 
        ${serviceList1}=  Create Dictionary  serviceId=${s_id2}   quantity=${quantity}    price=${servicecharge}
        ${assigneeUsers}=  Create List  ${user1_id}
        ${serviceList2}=  Create Dictionary  serviceId=${subser_id1}   quantity=${quantity}    price=${servicecharge}   assigneeUsers=${assigneeUsers}
        #  price=${servicecharge}
        ${serviceList}=    Create List    ${serviceList}   ${serviceList1}    ${serviceList2}
        Set Test Variable   ${serviceList}

        # ${servicenetRate}=  Evaluate  ${quantity} * 100
        # ${servicenetRate2}=  Evaluate  ${quantity} * ${servicecharge}
        # ${Total}=  Evaluate  ${servicenetRate} + ${servicenetRate2}

        
        ${resp}=  Create Invoice   ${category_id}    ${invoiceDate}      ${invoiceId}    ${providerConsumerIdList}   ${lid}   serviceList=${serviceList}        ynwUuid=${wapptid1}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable   ${invoice_uid}   ${resp.json()['uidList'][0]}  

        ${resp1}=  Get Invoice By Id  ${invoice_uid}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200


    END

###################################-Take appt for future####################################################333
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY3}  ${s_id2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    # Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    ${slots}=  Create List
    FOR   ${i}  IN RANGE   ${no_of_slots}
        ${available_slots_cnt}=  Set Variable  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']}
        FOR   ${j}  IN RANGE   ${available_slots_cnt}
            Append To List  ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
        END
    END
    ${slots_len}=  Get Length  ${slots}


    ${name1}=   FakerLibrary.word
    ${resp}=  Create Category   ${name1}  ${categoryType[3]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${category_id}   ${resp.json()}


    ${invoiceDate}=   db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${invoiceDate}

    ${invoiceId}=   FakerLibrary.word
    Set Suite Variable   ${invoiceId}


    # .......... Take appointent for service with zero amount(Future)..........
    FOR   ${i}  IN RANGE   200
        ${PO_Number}    Generate random string    5    0123456789
        ${PO_Number}    Convert To Integer  ${PO_Number}
        ${CUSERPH}=  Evaluate  ${CUSERNAME}+${PO_Number}
        Set Test Variable  ${CUSERPH${i}}  ${CUSERPH}
        ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH${i}}  
        Log  ${resp.content}
        Should Be Equal As Strings      ${resp.status_code}  200
        IF   '${resp.content}' == '${emptylist}'
            ${firstname}=  FakerLibrary.name
            ${lastname}=  FakerLibrary.last_name
            ${resp1}=  AddCustomer  ${CUSERPH${i}}   firstName=${firstname}   lastName=${lastname}  countryCode=${countryCodes[1]}
            Log  ${resp1.content}
            Should Be Equal As Strings  ${resp1.status_code}  200
            Set Test Variable  ${cid${i}}  ${resp1.json()}
        ELSE
            Set Suite Variable  ${cid${i}}  ${resp.json()[0]['id']}
            Set Suite Variable  ${firstname}  ${resp.json()[0]['firstName']}
        END

        ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH${i}}  
        Log  ${resp.content}
        Should Be Equal As Strings      ${resp.status_code}  200

        # ......... Take walkin appointments for all services .........

        ${apptfor1}=  Create Dictionary  id=${cid${i}}   apptTime=${slots[${i}]}
        ${apptfor}=   Create List  ${apptfor1}

        ${cnote}=   FakerLibrary.word
        ${resp}=  Take Appointment For Consumer  ${cid${i}}  ${s_id2}  ${sch_id}  ${DAY3}  ${cnote}  ${apptfor}  location=${{str('${lid}')}} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
        Set Test Variable  ${wapptid1}  ${apptid[0]}

        ${resp}=  Get Appointment By Id   ${wapptid1}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${providerConsumerIdList}=  Create List  ${cid${i}}
        Set Test Variable  ${providerConsumerIdList}   
        
        ${quantity}=   Random Int  min=5  max=10
        ${quantity}=  Convert To Number  ${quantity}  1
        ${servicecharge}=   Random Int  min=5  max=10



        ${serviceList}=  Create Dictionary  serviceId=${s_id1}   quantity=${quantity} 
        ${serviceList1}=  Create Dictionary  serviceId=${s_id2}   quantity=${quantity}    price=${servicecharge}
        #  price=${servicecharge}
        ${serviceList}=    Create List    ${serviceList}   ${serviceList1}
        Set Test Variable   ${serviceList}

        ${servicenetRate}=  Evaluate  ${quantity} * 100
        ${servicenetRate2}=  Evaluate  ${quantity} * ${servicecharge}
        ${Total}=  Evaluate  ${servicenetRate} + ${servicenetRate2}

        
        ${resp}=  Create Invoice   ${category_id}    ${invoiceDate}      ${invoiceId}    ${providerConsumerIdList}   ${lid}   serviceList=${serviceList}        ynwUuid=${wapptid1}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable   ${invoice_uid}   ${resp.json()['uidList'][0]}  

        ${resp1}=  Get Invoice By Id  ${invoice_uid}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200


    END

##########################################Make payment-Future###################################################################
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY3}  ${s_id2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    # Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    ${slots}=  Create List
    FOR   ${i}  IN RANGE   ${no_of_slots}
        ${available_slots_cnt}=  Set Variable  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']}
        FOR   ${j}  IN RANGE   ${available_slots_cnt}
            Append To List  ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
        END
    END
    ${slots_len}=  Get Length  ${slots}
#---------------------------------Take appt for service with zero amount and make payment for that invoice######################33333333333

    FOR   ${i}  IN RANGE   200
        ${PO_Number}    Generate random string    5    0123456789
        ${PO_Number}    Convert To Integer  ${PO_Number}
        ${CUSERPH}=  Evaluate  ${CUSERNAME}+${PO_Number}
        Set Test Variable  ${CUSERPH${i}}  ${CUSERPH}
        ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH${i}}  
        Log  ${resp.content}
        Should Be Equal As Strings      ${resp.status_code}  200
        IF   '${resp.content}' == '${emptylist}'
            ${firstname}=  FakerLibrary.name
            ${lastname}=  FakerLibrary.last_name
            ${resp1}=  AddCustomer  ${CUSERPH${i}}   firstName=${firstname}   lastName=${lastname}  countryCode=${countryCodes[1]}
            Log  ${resp1.content}
            Should Be Equal As Strings  ${resp1.status_code}  200
            Set Test Variable  ${cid${i}}  ${resp1.json()}
        ELSE
            Set Suite Variable  ${cid${i}}  ${resp.json()[0]['id']}
            Set Suite Variable  ${firstname}  ${resp.json()[0]['firstName']}
        END

        ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH${i}}  
        Log  ${resp.content}
        Should Be Equal As Strings      ${resp.status_code}  200

        # ......... Take walkin appointments for all services .........

        ${apptfor1}=  Create Dictionary  id=${cid${i}}   apptTime=${slots[${i}]}
        ${apptfor}=   Create List  ${apptfor1}

        ${cnote}=   FakerLibrary.word
        ${resp}=  Take Appointment For Consumer  ${cid${i}}  ${s_id2}  ${sch_id}  ${DAY3}  ${cnote}  ${apptfor}  location=${{str('${lid}')}} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
        Set Test Variable  ${wapptid1}  ${apptid[0]}

        ${resp}=  Get Appointment By Id   ${wapptid1}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable   ${fullAmount}  ${resp.json()['fullAmount']}         

        # ${resp}=  Get Booking Invoices  ${wapptid1}
        # Log   ${resp.content}
        # Should Be Equal As Strings  ${resp.status_code}  200


        ${providerConsumerIdList}=  Create List  ${cid${i}}
        Set Test Variable  ${providerConsumerIdList}   
        
        
        # ${servicenetRate}=  Convert To Number  ${servicenetRate}   2
        # Set Test Variable   ${servicenetRate}

        
        ${resp}=  Create Invoice   ${category_id}    ${invoiceDate}      ${invoiceId}    ${providerConsumerIdList}   ${lid}   serviceList=${serviceList}        ynwUuid=${wapptid1}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable   ${invoice_uid}   ${resp.json()['uidList'][0]}  


        ${resp1}=  Get Invoice By Id  ${invoice_uid}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200

        # ${note}=    FakerLibrary.word
        # # Set Suite Variable  ${note}   
        # ${resp}=  Make Payment By Cash   ${wapptid1}  ${payment_modes[0]}  ${fullAmount}  ${note}
        # Log  ${resp.json()}
        # Should Be Equal As Strings  ${resp.status_code}  200

        ${note}=    FakerLibrary.word
        ${resp}=  Make Payment By Cash For Invoice   ${invoice_uid}  ${payment_modes[0]}  ${Total}  ${note}  paymentOndate=${DAY1}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

#######################################Sub service-Assign user to invoice##########################################3
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY3}  ${s_id2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    # Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    ${slots}=  Create List
    FOR   ${i}  IN RANGE   ${no_of_slots}
        ${available_slots_cnt}=  Set Variable  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']}
        FOR   ${j}  IN RANGE   ${available_slots_cnt}
            Append To List  ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
        END
    END
    ${slots_len}=  Get Length  ${slots}
#-------------------------Take appt for one service-Add sub service in that appt and also that sub service to a  user**************************
    FOR   ${i}  IN RANGE   200
        ${PO_Number}    Generate random string    5    0123456789
        ${PO_Number}    Convert To Integer  ${PO_Number}
        ${CUSERPH}=  Evaluate  ${CUSERNAME}+${PO_Number}
        Set Test Variable  ${CUSERPH${i}}  ${CUSERPH}
        ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH${i}}  
        Log  ${resp.content}
        Should Be Equal As Strings      ${resp.status_code}  200
        IF   '${resp.content}' == '${emptylist}'
            ${firstname}=  FakerLibrary.name
            ${lastname}=  FakerLibrary.last_name
            ${resp1}=  AddCustomer  ${CUSERPH${i}}   firstName=${firstname}   lastName=${lastname}  countryCode=${countryCodes[1]}
            Log  ${resp1.content}
            Should Be Equal As Strings  ${resp1.status_code}  200
            Set Test Variable  ${cid${i}}  ${resp1.json()}
        ELSE
            Set Suite Variable  ${cid${i}}  ${resp.json()[0]['id']}
            Set Suite Variable  ${firstname}  ${resp.json()[0]['firstName']}
        END

        ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH${i}}  
        Log  ${resp.content}
        Should Be Equal As Strings      ${resp.status_code}  200

        # ......... Take walkin appointments for all services .........

        ${apptfor1}=  Create Dictionary  id=${cid${i}}   apptTime=${slots[${i}]}
        ${apptfor}=   Create List  ${apptfor1}

        ${cnote}=   FakerLibrary.word
        ${resp}=  Take Appointment For Consumer  ${cid${i}}  ${s_id2}  ${sch_id}  ${DAY3}  ${cnote}  ${apptfor}  location=${{str('${lid}')}} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
        Set Test Variable  ${wapptid1}  ${apptid[0]}

        ${resp}=  Get Appointment By Id   ${wapptid1}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${providerConsumerIdList}=  Create List  ${cid${i}}
        Set Test Variable  ${providerConsumerIdList}   
        
        ${quantity}=   Random Int  min=5  max=10
        ${quantity}=  Convert To Number  ${quantity}  1
        ${servicecharge}=   Random Int  min=5  max=10



        ${serviceList}=  Create Dictionary  serviceId=${s_id1}   quantity=${quantity} 
        ${serviceList1}=  Create Dictionary  serviceId=${s_id2}   quantity=${quantity}    price=${servicecharge}
        ${assigneeUsers}=  Create List  ${user1_id}
        ${serviceList2}=  Create Dictionary  serviceId=${subser_id1}   quantity=${quantity}    price=${servicecharge}   assigneeUsers=${assigneeUsers}
        #  price=${servicecharge}
        ${serviceList}=    Create List    ${serviceList}   ${serviceList1}    ${serviceList2}
        Set Test Variable   ${serviceList}

        # ${servicenetRate}=  Evaluate  ${quantity} * 100
        # ${servicenetRate2}=  Evaluate  ${quantity} * ${servicecharge}
        # ${Total}=  Evaluate  ${servicenetRate} + ${servicenetRate2}

        
        ${resp}=  Create Invoice   ${category_id}    ${invoiceDate}      ${invoiceId}    ${providerConsumerIdList}   ${lid}   serviceList=${serviceList}        ynwUuid=${wapptid1}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable   ${invoice_uid}   ${resp.json()['uidList'][0]}  

        ${resp1}=  Get Invoice By Id  ${invoice_uid}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200


    END


#######################################Sub service-Add to invoice ##########################################3
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    # Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    ${slots}=  Create List
    FOR   ${i}  IN RANGE   ${no_of_slots}
        ${available_slots_cnt}=  Set Variable  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']}
        FOR   ${j}  IN RANGE   ${available_slots_cnt}
            Append To List  ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
        END
    END
    ${slots_len}=  Get Length  ${slots}
#-------------------------Take appt for one service-Add sub service in that appt and also that sub service to a  user**************************
    FOR   ${i}  IN RANGE   200
        ${PO_Number}    Generate random string    5    0123456789
        ${PO_Number}    Convert To Integer  ${PO_Number}
        ${CUSERPH}=  Evaluate  ${CUSERNAME}+${PO_Number}
        Set Test Variable  ${CUSERPH${i}}  ${CUSERPH}
        ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH${i}}  
        Log  ${resp.content}
        Should Be Equal As Strings      ${resp.status_code}  200
        IF   '${resp.content}' == '${emptylist}'
            ${firstname}=  FakerLibrary.name
            ${lastname}=  FakerLibrary.last_name
            ${resp1}=  AddCustomer  ${CUSERPH${i}}   firstName=${firstname}   lastName=${lastname}  countryCode=${countryCodes[1]}
            Log  ${resp1.content}
            Should Be Equal As Strings  ${resp1.status_code}  200
            Set Test Variable  ${cid${i}}  ${resp1.json()}
        ELSE
            Set Suite Variable  ${cid${i}}  ${resp.json()[0]['id']}
            Set Suite Variable  ${firstname}  ${resp.json()[0]['firstName']}
        END

        ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH${i}}  
        Log  ${resp.content}
        Should Be Equal As Strings      ${resp.status_code}  200

        # ......... Take walkin appointments for all services .........

        ${apptfor1}=  Create Dictionary  id=${cid${i}}   apptTime=${slots[${i}]}
        ${apptfor}=   Create List  ${apptfor1}

        ${cnote}=   FakerLibrary.word
        ${resp}=  Take Appointment For Consumer  ${cid${i}}  ${s_id2}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
        Set Test Variable  ${wapptid1}  ${apptid[0]}

        ${resp}=  Get Appointment By Id   ${wapptid1}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${providerConsumerIdList}=  Create List  ${cid${i}}
        Set Test Variable  ${providerConsumerIdList}   
        
        ${quantity}=   Random Int  min=5  max=10
        ${quantity}=  Convert To Number  ${quantity}  1
        ${servicecharge}=   Random Int  min=5  max=10



        ${serviceList}=  Create Dictionary  serviceId=${s_id1}   quantity=${quantity} 
        ${serviceList1}=  Create Dictionary  serviceId=${s_id2}   quantity=${quantity}    price=${servicecharge}
        ${serviceList2}=  Create Dictionary  serviceId=${subser_id1}   quantity=${quantity}    price=${servicecharge}  
        #  price=${servicecharge}
        ${serviceList}=    Create List    ${serviceList}   ${serviceList1}    ${serviceList2}
        Set Test Variable   ${serviceList}

        # ${servicenetRate}=  Evaluate  ${quantity} * 100
        # ${servicenetRate2}=  Evaluate  ${quantity} * ${servicecharge}
        # ${Total}=  Evaluate  ${servicenetRate} + ${servicenetRate2}

        
        ${resp}=  Create Invoice   ${category_id}    ${invoiceDate}      ${invoiceId}    ${providerConsumerIdList}   ${lid}   serviceList=${serviceList}        ynwUuid=${wapptid1}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable   ${invoice_uid}   ${resp.json()['uidList'][0]}  

        ${resp1}=  Get Invoice By Id  ${invoice_uid}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200


    END
    ${DAY4}=  db.add_timezone_date  ${tz}  3  
#######################################Sub service-Add to invoice(Future) ##########################################3
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY4}  ${s_id2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    # Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    ${slots}=  Create List
    FOR   ${i}  IN RANGE   ${no_of_slots}
        ${available_slots_cnt}=  Set Variable  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']}
        FOR   ${j}  IN RANGE   ${available_slots_cnt}
            Append To List  ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
        END
    END
    ${slots_len}=  Get Length  ${slots}
#-------------------------Take appt for one service-Add sub service in that appt and also that sub service to a  user**************************
    FOR   ${i}  IN RANGE   200
        ${PO_Number}    Generate random string    5    0123456789
        ${PO_Number}    Convert To Integer  ${PO_Number}
        ${CUSERPH}=  Evaluate  ${CUSERNAME}+${PO_Number}
        Set Test Variable  ${CUSERPH${i}}  ${CUSERPH}
        ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH${i}}  
        Log  ${resp.content}
        Should Be Equal As Strings      ${resp.status_code}  200
        IF   '${resp.content}' == '${emptylist}'
            ${firstname}=  FakerLibrary.name
            ${lastname}=  FakerLibrary.last_name
            ${resp1}=  AddCustomer  ${CUSERPH${i}}   firstName=${firstname}   lastName=${lastname}  countryCode=${countryCodes[1]}
            Log  ${resp1.content}
            Should Be Equal As Strings  ${resp1.status_code}  200
            Set Test Variable  ${cid${i}}  ${resp1.json()}
        ELSE
            Set Suite Variable  ${cid${i}}  ${resp.json()[0]['id']}
            Set Suite Variable  ${firstname}  ${resp.json()[0]['firstName']}
        END

        ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH${i}}  
        Log  ${resp.content}
        Should Be Equal As Strings      ${resp.status_code}  200

        # ......... Take walkin appointments for all services .........

        ${apptfor1}=  Create Dictionary  id=${cid${i}}   apptTime=${slots[${i}]}
        ${apptfor}=   Create List  ${apptfor1}

        ${cnote}=   FakerLibrary.word
        ${resp}=  Take Appointment For Consumer  ${cid${i}}  ${s_id2}  ${sch_id}  ${DAY4}  ${cnote}  ${apptfor}  location=${{str('${lid}')}} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
        Set Test Variable  ${wapptid1}  ${apptid[0]}

        ${resp}=  Get Appointment By Id   ${wapptid1}
        Log   ${resp.json()}6
        Should Be Equal As Strings  ${resp.status_code}  200

        ${providerConsumerIdList}=  Create List  ${cid${i}}
        Set Test Variable  ${providerConsumerIdList}   
        
        ${quantity}=   Random Int  min=5  max=10
        ${quantity}=  Convert To Number  ${quantity}  1
        ${servicecharge}=   Random Int  min=5  max=10



        ${serviceList}=  Create Dictionary  serviceId=${s_id1}   quantity=${quantity} 
        ${serviceList1}=  Create Dictionary  serviceId=${s_id2}   quantity=${quantity}    price=${servicecharge}
        ${serviceList2}=  Create Dictionary  serviceId=${subser_id1}   quantity=${quantity}    price=${servicecharge}  
        #  price=${servicecharge}
        ${serviceList}=    Create List    ${serviceList}   ${serviceList1}    ${serviceList2}
        Set Test Variable   ${serviceList}

        # ${servicenetRate}=  Evaluate  ${quantity} * 100
        # ${servicenetRate2}=  Evaluate  ${quantity} * ${servicecharge}
        # ${Total}=  Evaluate  ${servicenetRate} + ${servicenetRate2}

        
        ${resp}=  Create Invoice   ${category_id}    ${invoiceDate}      ${invoiceId}    ${providerConsumerIdList}   ${lid}   serviceList=${serviceList}        ynwUuid=${wapptid1}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable   ${invoice_uid}   ${resp.json()['uidList'][0]}  

        ${resp1}=  Get Invoice By Id  ${invoice_uid}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200


    END


    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    # Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    ${slots}=  Create List
    FOR   ${i}  IN RANGE   ${no_of_slots}
        ${available_slots_cnt}=  Set Variable  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']}
        FOR   ${j}  IN RANGE   ${available_slots_cnt}
            Append To List  ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
        END
    END
    ${slots_len}=  Get Length  ${slots}




#-------------------------Take an appt then apply service level discount**************************
    FOR   ${i}  IN RANGE   200
        ${PO_Number}    Generate random string    5    0123456789
        ${PO_Number}    Convert To Integer  ${PO_Number}
        ${CUSERPH}=  Evaluate  ${CUSERNAME}+${PO_Number}
        Set Test Variable  ${CUSERPH${i}}  ${CUSERPH}
        ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH${i}}  
        Log  ${resp.content}
        Should Be Equal As Strings      ${resp.status_code}  200
        IF   '${resp.content}' == '${emptylist}'
            ${firstname}=  FakerLibrary.name
            ${lastname}=  FakerLibrary.last_name
            ${resp1}=  AddCustomer  ${CUSERPH${i}}   firstName=${firstname}   lastName=${lastname}  countryCode=${countryCodes[1]}
            Log  ${resp1.content}
            Should Be Equal As Strings  ${resp1.status_code}  200
            Set Test Variable  ${cid${i}}  ${resp1.json()}
        ELSE
            Set Suite Variable  ${cid${i}}  ${resp.json()[0]['id']}
            Set Suite Variable  ${firstname}  ${resp.json()[0]['firstName']}
        END

        ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH${i}}  
        Log  ${resp.content}
        Should Be Equal As Strings      ${resp.status_code}  200

        # ......... Take walkin appointments for all services .........

        ${apptfor1}=  Create Dictionary  id=${cid${i}}   apptTime=${slots[${i}]}
        ${apptfor}=   Create List  ${apptfor1}

        ${cnote}=   FakerLibrary.word
        ${resp}=  Take Appointment For Consumer  ${cid${i}}  ${s_id2}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
        Set Test Variable  ${wapptid1}  ${apptid[0]}

        ${resp}=  Get Appointment By Id   ${wapptid1}
        Log   ${resp.json()}6
        Should Be Equal As Strings  ${resp.status_code}  200

        ${providerConsumerIdList}=  Create List  ${cid${i}}
        Set Test Variable  ${providerConsumerIdList}   
        
        ${quantity}=   Random Int  min=5  max=10
        ${quantity}=  Convert To Number  ${quantity}  1
        ${servicecharge}=   Random Int  min=5  max=10



        ${serviceList}=  Create Dictionary  serviceId=${s_id1}   quantity=${quantity} 
        ${serviceList1}=  Create Dictionary  serviceId=${s_id2}   quantity=${quantity}    price=${servicecharge}
        ${serviceList2}=  Create Dictionary  serviceId=${subser_id1}   quantity=${quantity}    price=${servicecharge}  
        #  price=${servicecharge}
        ${serviceList}=    Create List    ${serviceList}   ${serviceList1}    ${serviceList2}
        Set Test Variable   ${serviceList}

        # ${servicenetRate}=  Evaluate  ${quantity} * 100
        # ${servicenetRate2}=  Evaluate  ${quantity} * ${servicecharge}
        # ${Total}=  Evaluate  ${servicenetRate} + ${servicenetRate2}

        
        ${resp}=  Create Invoice   ${category_id}    ${invoiceDate}      ${invoiceId}    ${providerConsumerIdList}   ${lid}   serviceList=${serviceList}        ynwUuid=${wapptid1}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable   ${invoice_uid}   ${resp.json()['uidList'][0]}  

        ${discount1}=     FakerLibrary.word
        ${desc}=   FakerLibrary.word
        ${discountprice1}=     Random Int   min=50   max=100
        ${discountprice}=  Convert To Number  ${discountprice1}  1
        Set Suite Variable   ${discountprice}
        ${resp}=   Create Discount  ${discount1}   ${desc}    ${discountprice}   ${calctype[1]}  ${disctype[0]}
        Log  ${resp.json()}
        Set Suite Variable   ${discountId}   ${resp.json()}   
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=   Get Discounts 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${privateNote}=     FakerLibrary.word
        ${displayNote}=   FakerLibrary.word
        ${discountValue1}=     Random Int   min=50   max=100
        ${discountValue1}=  Convert To Number  ${discountValue1}  1

        ${resp}=  Apply Service Level Discount   ${invoice_uid}   ${discountId}    ${discountValue1}   ${privateNote}  ${displayNote}   ${s_id1}
        Log  ${resp.json()} 
        Should Be Equal As Strings  ${resp.status_code}  200


        ${resp1}=  Get Invoice By Id  ${invoice_uid}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200


    END


