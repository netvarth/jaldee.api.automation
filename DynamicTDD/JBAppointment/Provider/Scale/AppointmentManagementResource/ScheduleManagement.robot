*** Settings ***
# Suite Teardown    Delete All Sessions
# Test Teardown     Delete All Sessions
Force Tags        Appointment
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/CustomKeywords.py
Library           random
Library           /ebs/TDD/CustomKeywords.py
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/hl_providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
# Variables          ${EXECDIR}/data/${ENVIRONMENT}_varfiles/providers.py


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
    Set Global Variable   ${PUSERNAME_B}
    ${num}=  find_last  ${var_file}
    ${num}=  Evaluate   ${num}+1
    Append To File  ${data_file}  ${LoginId} - ${PASSWORD}${\n}
    Append To File  ${var_file}  PUSERNAME${num}=${LoginId}${\n}
    Log    PUSERNAME${num}
    # ${PUSERNAME_B}=  Set Variable  ${PUSERNAME4}

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

    # ........ Location Creation .......

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    FOR    ${i}    IN RANGE  1  len(${resp.json()})
        IF   '${resp.json()[${i}]['status']}' == '${status[0]}' && '${resp.json()[${i}]['baseLocation']}' == '${bool[0]}'
            ${resp}=  Disable Location  ${resp.json()[${i}]['id']}
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
    FOR    ${i}    IN RANGE  1  len(${resp.json()})
        IF   '${resp.json()[${i}]['status']}' == '${status[0]}' 
            ${resp}=  Disable service  ${resp.json()[${i}]['id']}
            Log  ${resp.content}
            Should Be Equal As Strings  ${resp.status_code}  200
        END
    END

    #  1. Create Service without Prepayment.

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}   
    ${s_id1}=  Create Sample Service  ${SERVICE1}   
    
    #  2. Create Service without Prepayment and Max Bookings Allowed > 1

    ${SERVICE2}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE2}   
    ${s_id2}=  Create Sample Service  ${SERVICE2}      maxBookingsAllowed=10
    
    #  3. Create Service with Fixed Prepayment

    ${SERVICE3}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE3}   
    ${min_pre3}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    ${s_id3}=  Create Sample Service  ${SERVICE3}   isPrePayment=${bool[1]}   minPrePaymentAmount=${min_pre3} 

    #  4. Create Service with Percentage Prepayment

    ${SERVICE4}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE4}   
    ${min_pre4}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    ${s_id4}=  Create Sample Service  ${SERVICE4}   isPrePayment=${bool[1]}   prePaymentType=${advancepaymenttype[0]}  minPrePaymentAmount=${min_pre4} 

    #  5. Create Taxable Service

    ${SERVICE5}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE5}   
    ${s_id5}=  Create Sample Service  ${SERVICE5}   taxable=${bool[1]} 

    #  6. Create Service with Lead Time

    ${SERVICE6}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE6}  
    ${leadTime}=   Random Int   min=1   max=5 
    ${s_id6}=  Create Sample Service  ${SERVICE6}    leadTime=${leadTime}

    #  7. Create Service with International Pricing

    ${SERVICE7}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE7}
    ${intlamt}=  Pyfloat  right_digits=1  min_value=250  max_value=500
    ${s_id7}=  Create Sample Service  ${SERVICE7}  supportInternationalConsumer=${bool[1]}  internationalAmount=${intlamt}

    #  8. Create Service with Dynamic Pricing

    ${SERVICE8}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE8}  
    ${leadTime}=   Random Int   min=1   max=5 
    ${s_id8}=  Create Sample Service  ${SERVICE8}    priceDynamic=${bool[1]}

    #  9. Create Virtual Service with Audio Only

    ${meeting_id}=   FakerLibrary.lexify  text='???-????-???'  letters=${lower}
    ${GoogleMeet_url}=     Format String    ${MEET_URL}    meeting_id=${meeting_id}
    Log    ${meet_url}
    
    ${Description1}=    FakerLibrary.sentences
    ${instructions2}=   FakerLibrary.sentence
    ${VScallingMode1}=   Create Dictionary   callingMode=${CallingModes[2]}   value=${PUSERNAME_B}   countryCode=${countryCodes[0]}    instructions=${Description1[0]}${\n}${Description1[1]}${\n}${Description1[2]}
    ${VScallingMode2}=   Create Dictionary   callingMode=${CallingModes[1]}   value=${PUSERNAME_B}   countryCode=${countryCodes[0]}  instructions=${instructions2} 
    ${virtualCallingModes}=  Create List  ${VScallingMode1}  ${VScallingMode2}
    ${vstype}=   Set Variable   ${vservicetype[0]}

    ${description}=    FakerLibrary.sentence
    ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    ${Total}=  Pyfloat  right_digits=1  min_value=100  max_value=500
    ${SERVICE9}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE9}
    ${resp}=  Create Service  ${SERVICE9}  ${description}  ${service_duration[1]}  ${bool[0]}  ${Total}  ${bool[0]}  serviceType=${ServiceType[0]}  virtualServiceType=${vstype}  virtualCallingModes=${virtualCallingModes}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id9}  ${resp.json()}

    #  10. Create Virtual Service with Video Only

    ${meeting_id}=   FakerLibrary.lexify  text='???-????-???'  letters=${lower}
    ${GoogleMeet_url}=     Format String    ${MEET_URL}    meeting_id=${meeting_id}
    Log    ${meet_url}
    
    ${Description1}=    FakerLibrary.sentences
    ${instructions2}=   FakerLibrary.sentence
    ${VScallingMode1}=   Create Dictionary   callingMode=${CallingModes[3]}   value=${GoogleMeet_url}   status=${status[0]}    instructions=${Description1[0]}${\n}${Description1[1]}${\n}${Description1[2]}
    ${VScallingMode2}=   Create Dictionary   callingMode=${CallingModes[1]}   value=${PUSERNAME_B}   countryCode=${countryCodes[0]}  instructions=${instructions2} 
    ${virtualCallingModes}=  Create List  ${VScallingMode1}  ${VScallingMode2}
    ${vstype}=   Set Variable   ${vservicetype[1]}

    ${description}=    FakerLibrary.sentence
    ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    ${Total}=  Pyfloat  right_digits=1  min_value=100  max_value=500
    ${SERVICE10}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE10}
    ${resp}=  Create Service  ${SERVICE10}  ${description}  ${service_duration[1]}  ${bool[0]}  ${Total}  ${bool[0]}  serviceType=${ServiceType[0]}  virtualServiceType=${vstype}  virtualCallingModes=${virtualCallingModes}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id10}  ${resp.json()}

    # ......Get All Services ..............

    ${resp}=   Get Service By Id  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${ser_amount1}  ${resp.json()['totalAmount']} 
    
    ${resp}=   Get Service By Id  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${s_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${s_id4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${s_id5}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${s_id6}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${s_id7}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${s_id8}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${s_id9}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${s_id10}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ...... Create Schedule ........

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    FOR    ${i}    IN RANGE  1  len(${resp.json()})
        IF   '${resp.json()[${i}]['apptState']}' == '${Qstate[0]}' 
            ${resp}=  Enable Disable Appointment Schedule  ${resp.json()[${i}]['id']}   ${Qstate[1]}
            Log  ${resp.content}
            Should Be Equal As Strings  ${resp.status_code}  200
        END
    END

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10    
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_timezone_time  ${tz}  3   50  
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=5
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  
    ...   ${s_id1}  ${s_id2}  ${s_id3}  ${s_id4}  ${s_id5}  ${s_id6}  ${s_id7}  ${s_id8}  ${s_id9}  ${s_id10} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    # .......Update Schedule .......

    ${parallel}=  FakerLibrary.Random Int  min=6  max=10
    ${resp}=  Update Appointment Schedule  ${sch_id}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
    ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
    ...  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${parallel}  ${parallel}  ${lid}  ${resp.json()['timeDuration']}  ${bool[1]}  
    ...  ${s_id1}  ${s_id2}  ${s_id3}  ${s_id4}  ${s_id5}  ${s_id6}  ${s_id7}  ${s_id8}  ${s_id9}  ${s_id10} 

    # .......Disable Schedule .......

    ${resp}=  Enable Disable Appointment Schedule  ${sch_id}  ${Qstate[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # .......Enable Schedule .......

    ${resp}=  Enable Disable Appointment Schedule  ${sch_id}  ${Qstate[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # .......... Add Customer ..........

    ${NewCustomer}=  Generate Random 555 Number
    # ${NewCustomer}    Generate random string    10    123456789
    # ${NewCustomer}    Convert To Integer  ${NewCustomer}
    ${fname}=  generate_firstname
    ${lname}=  FakerLibrary.last_name
    Set Test Variable  ${pc_emailid1}  ${fname}${C_Email}.${test_mail}
    ${resp}=  AddCustomer  ${NewCustomer}   firstName=${fname}   lastName=${lname}  countryCode=${countryCodes[1]}   email=${pc_emailid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${pcid}  ${resp.json()}

    ${NewCustomer1}=    Generate Random 555 Number
    ${fname1}=  generate_firstname
    ${lname1}=  FakerLibrary.last_name
    Set Test Variable  ${pc_emailid2}  ${fname}${C_Email}.${test_mail}
    ${resp}=  AddCustomer  ${NewCustomer1}   firstName=${fname1}   lastName=${lname1}  countryCode=${countryCodes[1]}   email=${pc_emailid2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${pcid1}  ${resp.json()}

    # ......... Take 1 Appointment with Attachment and Note .......

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
        END
    END
    ${num_slots}=  Get Length  ${slots}
    ${j1}=  Random Int  max=${num_slots-1}
    Set Test Variable   ${slot1}   ${slots[${j1}]}

    ${apptfor1}=  Create Dictionary  id=${pcid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${jpgfile}
    ${caption1}=  Fakerlibrary.Sentence
    ${fileName}=    generate_filename
    
    ${resp}    upload file to temporary location    ${file_action[0]}    ${provider_id}    ${ownerType[0]}    ${pdrname}    ${jpgfile}    ${fileSize}    ${caption1}    ${fileType1}    ${EMPTY}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Set Test Variable    ${driveId}    ${resp.json()[0]['driveId']}
    # Set Test Variable    ${S3_url}    ${resp.json()[0]['url']}

    # ${resp}=    Upload File To S3    ${S3_url}      ${jpgfile}
    ${resp}=    Change Status Of The Uploaded File    ${QnrStatus[1]}     ${driveId}

    ${attachments}=  Create Dictionary  owner=${provider_id}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${pdrname}
    ${attachment}=   Create List  ${attachments}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${pcid}  ${s_id1}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}  attachments=${attachment}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}

    # ........Take 1 Appointment by Blocking a Slot and Confirming ....

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
        END
    END
    ${num_slots}=  Get Length  ${slots}
    ${j1}=  Random Int  max=${num_slots-1}
    Set Test Variable   ${slot2}   ${slots[${j1}]}

    ${apptfor1}=  Create Dictionary   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}

    ${resp}=  Block Appointment For Consumer  ${s_id2}  ${sch_id}  ${DAY1}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${value}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid2}  ${value[0]}
    
    ${apptfor1}=  Create Dictionary  id=${pcid}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}

    ${resp}=  Confirm Blocked Appointment   ${pcid}   ${apptid2}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appmtTime']}    ${slot2}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[2]}

    # ..... Change Appointment Status(Confirmed-Arrived--started-Completed) .........

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[1]}

    ${resp}=  Appointment Action   ${apptStatus[2]}   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[2]}

    ${resp}=  Appointment Action   ${apptStatus[3]}   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[3]}

    ${resp}=  Appointment Action   ${apptStatus[6]}   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[6]}

    # ...Create 2 Appointments (Cancel 1, Reject the Other) .........

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
        END
    END
    ${num_slots}=  Get Length  ${slots}
    ${j1}=  Random Int  max=${num_slots-1}
    Set Test Variable   ${slot1}   ${slots[${j1}]}

    ${apptfor1}=  Create Dictionary  id=${pcid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${pcid}  ${s_id1}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid3}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${reason}=  Random Element  ${cancelReason}
    ${resp}=  Appointment Action   ${apptStatus[4]}   ${apptid3}    cancelReason=${reason}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${apptid3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[4]}

    ${apptfor1}=  Create Dictionary  id=${pcid1}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${pcid1}  ${s_id1}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid4}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${reason}=  Random Element  ${cancelReason}
    ${resp}=  Appointment Action   ${apptStatus[5]}   ${apptid4}    rejectReason=${reason}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${apptid4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[5]}

    # ......Settle Bill for 1 of the Appointments ...

    ${NO_INVOICE_GENERATED}=  format String   ${NO_INVOICE_GENERATED}   ${apptid1}

    ${resp}=  Get Bookings Invoices  ${apptid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}    ${NO_INVOICE_GENERATED}

    ${resp}=  Create Invoice for Booking  ${invoicebooking[0]}   ${apptid1}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep   2s
    ${resp}=  Get Bookings Invoices  ${apptid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable    ${invoice_uid}    ${resp.json()[0]['invoiceUid']}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}                                        ${account_id}
    Should Be Equal As Strings  ${resp.json()[0]['categoryName']}                                     ${CategoryName[0]}
    Should Be Equal As Strings  ${resp.json()[0]['invoiceDate']}                                      ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['providerConsumerId']}                               ${pcid}
    Should Be Equal As Strings  ${resp.json()[0]['providerConsumerData']['phoneNos'][0]['number']}    ${NewCustomer}
    Should Be Equal As Strings   ${resp.json()[0]['ynwUuid']}                                         ${apptid1}
    Should Be Equal As Strings   ${resp.json()[0]['amountPaid']}                                      0.0
    Should Be Equal As Strings   ${resp.json()[0]['amountDue']}                                       ${ser_amount1}
    Should Be Equal As Strings   ${resp.json()[0]['amountTotal']}                                     ${ser_amount1}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceId']}                      ${s_id1}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceName']}                    ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['quantity']}                       1.0
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['taxable']}                        ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['totalPrice']}                     ${ser_amount1}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['netRate']}                        ${ser_amount1}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceCategory']}                ${serviceCategory[1]}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['assigneeUsers']}                  ${empty_list}
    
    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${NewCustomer}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${NewCustomer}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${NewCustomer}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}

    ${resp}=  Make payment Consumer Mock  ${account_id}  ${ser_amount1}  ${purpose[1]}  ${apptid1}  ${s_id1}  ${bool[0]}   ${bool[1]}  ${cid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    #...... Generate Appointment Report ...........

    ${filter}=  Create Dictionary      
    ${resp}=  Generate Report REST details  ${reportType[1]}  ${Report_Date_Category[4]}  ${filter}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id1}   ${resp.json()}
  
    ${resp}=  Get Report Status By Token Id  ${token_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${tot_amt}   ${resp.json()['reportContent']['dataHeader']['Grand Total']}

    ${total_amt}=    Evaluate    ${ser_amount1}+${total}
    ${ser_date} =	Convert Date	${DAY1}	result_format=%d-%m-%Y
    ${tot_amt} =    Replace String    ${tot_amt}    Rs.     ${EMPTY}
    ${tot_amt} =    Replace String    ${tot_amt}    ,       ${EMPTY}
    ${tot_amt}=  Convert To Number  ${tot_amt}  1

    Should Be Equal As Strings  ${resp.json()['status']}                                        ${Report_Status[0]}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['1']}                 ${ser_date}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['2']}                 ${encId}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['3']}                 ${fname} ${lname}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['5']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['6']}                 1
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][0]['7']}                 ${ser_amount1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['1']}                 ${ser_date}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['2']}                 ${encId}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['3']}                 ${fname} ${lname}
    # Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['4']}                 ${userf_name} ${userl_name}
    # Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['5']}                 ${subser_name}
    # Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['6']}                 ${subser_qnty}
    Should Be Equal As Strings  ${resp.json()['reportContent']['data'][1]['7']}                 ${total}
    Should Be Equal As Strings  ${resp.json()['reportContent']['count']}                        1
    Should Be Equal As Strings  ${tot_amt}                                                      ${total_amt}
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportName']}                   User Performance Report
    Should Be Equal As Strings  ${resp.json()['reportType']}                                    ${reportType[1]}
    Should Be Equal As Strings  ${resp.json()['reportResponseType']}                            ${ReportResponseType[0]}
    Should Be Equal As Strings  ${resp.json()['reportTokenID']}                                 ${token_id1}
    Should Be Equal As Strings  ${resp.json()['reportContent']['reportHeader']['Time Period']}  ${Report_Date_filter[4]}  
