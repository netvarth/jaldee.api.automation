*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Appointment  Waitlist
Library           Collections
Library           OperatingSystem
Library           String
Library           json
Library           random
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot

*** Variables ***
@{Views}  self  all  customersOnly
# ${count}  ${1000}
${count}  ${50}
${jpgfile}      /ebs/TDD/uploadimage.jpg
${zero}        0
@{emptylist}
${var_file}     ${EXECDIR}/data/${ENVIRONMENT}_varfiles/providers.py


*** Test Cases ***
JD-TC-TakeAppointment-1
    [Documentation]   Take appointment
    ${providers_list}=   Get File    ${var_file}
    ${pro_list}=   Split to lines  ${providers_list}

    FOR  ${provider}  IN  @{pro_list}
        ${provider}=  Remove String    ${provider}    ${SPACE}
        ${provider}  ${ph}=   Split String    ${provider}  =
        Set Test Variable  ${ph}

        ${resp}=  Encrypted Provider Login  ${ph}  ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        Set Test Variable  ${provider_id}  ${decrypted_data['id']}
        Set Test Variable  ${provider_name}  ${decrypted_data['userName']}

        ${resp}=  Get Business Profile
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${account_id}  ${resp.json()['id']}
        # Set TEst Variable  ${tz}  ${resp.json()['baseLocation']['timezone']}

        ${resp}=   Get License UsageInfo 
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=   Get jaldeeIntegration Settings
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        IF  '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[0]}'
            ${resp1}=   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
            Should Be Equal As Strings  ${resp1.status_code}  200
        ELSE IF    '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[1]}'
            ${resp1}=   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
            Should Be Equal As Strings  ${resp1.status_code}  200
        END

        ${resp}=   Get jaldeeIntegration Settings
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
        Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

        ${resp}=   Get Appointment Settings
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        IF  ${resp.json()['enableAppt']}==${bool[0]}   
            ${resp1}=  Enable Appointment
            Should Be Equal As Strings  ${resp1.status_code}  200
        END

        ${resp}=   Get Appointment Settings
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
        Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]} 
        
        ${resp}=    Get Locations
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        IF   '${resp.content}' == '${emptylist}'
            ${lid}=  Create Sample Location
            ${resp}=   Get Location ById  ${lid}
            Log  ${resp.content}
            Should Be Equal As Strings  ${resp.status_code}  200
            Set Test Variable  ${tz}  ${resp.json()['timezone']}
        ELSE
            Set Suite Variable  ${lid}  ${resp.json()[0]['id']}
            Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}
        END

        ${s_id}=  Set Variable  ${NONE}
        ${resp}=   Get Service  serviceType-neq=donationService
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        # IF   "${resp.content}" != "${emptylist}"
        IF   "$resp.content" != "${emptylist}"
            
            ${service_len}=  Get Length   ${resp.json()}
            FOR   ${i}  IN RANGE   ${service_len}
                IF  '${resp.json()[${i}]['status']}' == '${status[0]}'
                    Set Test Variable   ${s_id}   ${resp.json()[${i}]['id']}

                    IF  '${resp.json()[${i}]['isPrePayment']}' == '${bool[1]}'
                        ${maxbookings}=   Random Int   min=5   max=10
                        ${resp}=  Update Service  ${s_id}  ${resp.json()[${i}]['name']}  ${EMPTY}  ${resp.json()[${i}]['serviceDuration']}  ${resp.json()[${i}]['status']}  ${btype}  ${resp.json()[${i}]['notification']}  ${resp.json()[${i}]['notificationType']}  ${resp.json()[${i}]['minPrePaymentAmount']}  ${resp.json()[${i}]['totalAmount']}  ${resp.json()[${i}]['isPrePayment']}  ${resp.json()[${i}]['taxable']}  maxBookingsAllowed=${count}
                        Log  ${resp.content}
                        Should Be Equal As Strings  ${resp.status_code}  200
                    ELSE

                        ${maxbookings}=   Random Int   min=5   max=10
                        ${resp}=  Update Service  ${s_id}  ${resp.json()[${i}]['name']}  ${EMPTY}  ${resp.json()[${i}]['serviceDuration']}  ${resp.json()[${i}]['status']}  ${btype}  ${resp.json()[${i}]['notification']}  ${resp.json()[${i}]['notificationType']}  ${EMPTY}  ${resp.json()[${i}]['totalAmount']}  ${resp.json()[${i}]['isPrePayment']}  ${resp.json()[${i}]['taxable']}  maxBookingsAllowed=${count}
                        Log  ${resp.content}
                        Should Be Equal As Strings  ${resp.status_code}  200

                    END
                    BREAK
                END
            END

            ${srv_val}=    Get Variable Value    ${s_id}
            IF  '${srv_val}'=='${None}'
                ${SERVICE1}=    FakerLibrary.job
                ${maxbookings}=   Random Int   min=5   max=10
                ${s_id}=  Create Sample Service  ${SERVICE1}  maxBookingsAllowed=${count}
            END
        ELSE

            ${SERVICE1}=    FakerLibrary.job
            ${maxbookings}=   Random Int   min=5   max=10
            ${s_id}=  Create Sample Service  ${SERVICE1}  maxBookingsAllowed=${count}

        END

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
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${prepay_appt_len}  ${zero}
        
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
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${today_appt_len}  ${zero}

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
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${future_appt_len}  ${zero}

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

        ${resp}=   Get Appointments History  apptStatus-neq=${apptStatus[6]},${apptStatus[5]},${apptStatus[4]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${past_appt_len}=  Get Length   ${resp.json()}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${past_appt_len}  ${zero}

        ${resp}=   Get Appointments History
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${past_appt_len}=  Get Length   ${resp.json()}

        ${resp}=  Get Appointment Schedules
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${schedules_count}=  Get Length  ${resp.json()}

        ${resp}=  Get Appointment Schedules  state-eq=${Qstate[0]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${schedules_count}=  Get Length  ${resp.json()}
        FOR   ${i}  IN RANGE   ${schedules_count}

            ${resp1}=  Disable Appointment Schedule  ${resp.json()[${i}]['id']}
            Log  ${resp1.json()}
            Should Be Equal As Strings  ${resp1.status_code}  200

        END

        ${DAY1}=  get_date_by_timezone  ${tz}
        ${DAY2}=  db.add_timezone_date  ${tz}  10
        ${sTime1}=  get_time_by_timezone  ${tz}   
        ${delta}=  FakerLibrary.Random Int  min=30  max=60
        ${eTime1}=  add_two   ${sTime1}  ${delta}
        ${list}=  Create List  1  2  3  4  5  6  7
        ${schedule_name}=  FakerLibrary.bs
        # ${parallelServing}=  FakerLibrary.Random Int  min=10  max=20
        # ${consumerparallelserving}=  FakerLibrary.Random Int  min=1  max=${parallelServing}
        ${parallelServing} =    IF    ${count} > 50    Convert To Integer   ${count/10}    ELSE    FakerLibrary.Random Int  min=10  max=20
        ${maxval}=  Convert To Integer   ${delta/10}
        ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
        ${bool1}=  Random Element  ${bool}
        ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallelServing}  ${parallelServing}  ${lid}  ${duration}  ${bool1}  ${s_id}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${sch_id}  ${resp.json()}

        ${resp}=  Get Appointment Schedule ById  ${sch_id}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

        ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
        ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
        ${slots}=  Create List
        FOR   ${i}  IN RANGE   ${no_of_slots}
            ${available_slots_cnt}=  Set Variable  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']}
            FOR   ${j}  IN RANGE   ${available_slots_cnt}
                Append To List  ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
            END
        END
        ${slots_len}=  Get Length  ${slots}

        FOR   ${a}  IN RANGE   ${count}
        
            ${PH_Number}=  FakerLibrary.Numerify  %#####
            ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
            Log  ${PH_Number}
            Set Test Variable  ${CUSERPH}  555${PH_Number}
            # ${CUSERPH}=  Evaluate  ${CUSERNAME}+${PH_Number}
            Set Test Variable  ${CUSERPH${a}}  ${CUSERPH}
            ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH${a}}  
            Log  ${resp.content}
            Should Be Equal As Strings      ${resp.status_code}  200
            IF   '${resp.content}' == '${emptylist}'
                ${firstname}=  FakerLibrary.name
                ${lastname}=  FakerLibrary.last_name
                ${resp1}=  AddCustomer  ${CUSERPH${a}}   firstName=${firstname}   lastName=${lastname}  countryCode=${countryCodes[1]}
                Log  ${resp1.content}
                Should Be Equal As Strings  ${resp1.status_code}  200
                Set Test Variable  ${cid${a}}  ${resp1.json()}
            ELSE
                Set Suite Variable  ${cid${a}}  ${resp.json()[0]['id']}
                Set Suite Variable  ${firstname}  ${resp.json()[0]['firstName']}
            END

            ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH${a}}  
            Log  ${resp.content}
            Should Be Equal As Strings      ${resp.status_code}  200

            ${apptfor1}=  Create Dictionary  id=${cid${a}}   apptTime=${slots[${a}]}
            ${apptfor}=   Create List  ${apptfor1}

            ${cnote}=   FakerLibrary.word
            ${resp}=  Take Appointment For Consumer  ${cid${a}}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
            Log   ${resp.content}
            Should Be Equal As Strings  ${resp.status_code}  200
            ${apptid}=  Get From Dictionary  ${resp.json()}  ${firstname}
            Set Suite Variable  ${apptid${a}}  ${apptid}

            ${resp}=  Get Appointment EncodedID   ${apptid${a}}
            Log   ${resp.content}
            Should Be Equal As Strings  ${resp.status_code}  200
            Set Test Variable  ${encId${a}}  ${resp.json()}

            ${resp}=  Get Appointment By Id   ${apptid${a}}
            Log   ${resp.content}
            Should Be Equal As Strings  ${resp.status_code}  200
            Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid${a}}
            Should Be Equal As Strings  ${resp.json()['appointmentEncId']}   ${encId${a}}

            ${fileSize}=  OperatingSystem.Get File Size  ${jpgfile}
            ${type}=  db.getType   ${jpgfile}
            Log  ${type}
            ${fileType1}=  Get From Dictionary       ${type}    ${jpgfile}
            ${caption1}=  Fakerlibrary.Sentence
            ${path} 	${file} = 	Split String From Right 	${jpgfile} 	/ 	1
            ${fileName}  ${file_ext}= 	Split String 	${file}  .
            # ${resp}    upload file to temporary location    ${file_action[0]}    ${provider_id}    ${ownerType[0]}    ${provider_name}    ${jpgfile}    ${fileSize}    ${caption1}    ${fileType1}    ${EMPTY}    ${order}
            # Log  ${resp.content}
            # Should Be Equal As Strings     ${resp.status_code}    200 
            # Set Suite Variable    ${driveId}    ${resp.json()[0]['driveId']}

            # ${attachments}=  Create Dictionary  owner=${provider_id}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${provider_name}
            # ${attachment}=   Create List  ${attachments}

            ${uuid}=    Create List  ${apptid${a}}

            ${resp}=    Send Message With Appointment   ${caption1}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  uuid=${uuid}  # attachments=${attachment}
            Log  ${resp.content}
            Should Be Equal As Strings  ${resp.status_code}  200
            # BREAK
        END
        # BREAK
    END