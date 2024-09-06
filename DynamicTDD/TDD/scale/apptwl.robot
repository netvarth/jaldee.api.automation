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
${order}        0


*** Test Cases ***

JD-TC-AddToWL-1
    [Documentation]   Add To waitlist
    ${providers_list}=   Get File    ${EXECDIR}/data/${ENVIRONMENT}_varfiles/providers.py
    ${pro_list}=   Split to lines  ${providers_list}

    FOR  ${provider}  IN  @{pro_list}
        ${provider}=  Remove String    ${provider}    ${SPACE}
        ${provider}  ${ph}=   Split String    ${provider}  =
        Set Test Variable  ${ph}
        # ${cust_pro}=  Evaluate  random.choice(list(open('${EXECDIR}/data/${ENVIRONMENT}_varfiles/providers.py')))  random
        # Log  ${cust_pro}
        # ${cust_pro}=    Remove String    ${cust_pro}    ${SPACE}
        # ${cust_pro}=    Remove String    ${cust_pro}    ${\n}
        # ${cust_pro}=   Set Variable  ${cust_pro.strip()}
        # ${var} 	${ph}=   Split String    ${cust_pro}  =  
        # Set Suite Variable  ${ph}

        ${resp}=  Encrypted Provider Login  ${ph}  ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        Set Test Variable  ${provider_id}  ${decrypted_data['id']}
        Set Test Variable  ${provider_name}  ${decrypted_data['userName']}

        ${resp}=  Get Business Profile
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${account_id}  ${resp.json()['id']}
        Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['timezone']}

        ${resp}=   Get License UsageInfo 
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${ser_durtn}=   Random Int   min=2   max=2
        ${resp}=  Update Waitlist Settings  ${calc_mode[1]}  ${ser_durtn}  ${bool[1]}  ${bool[0]}  ${bool[1]}  ${bool[0]}   ${Empty}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  View Waitlist Settings
        Log  ${resp.content}
        Verify Response  ${resp}  onlineCheckIns=${bool[1]}
        IF  ${resp.json()['enabledWaitlist']}==${bool[0]}
            ${resp}=  Enable Waitlist
            Log  ${resp.content}
            Should Be Equal As Strings  ${resp.status_code}  200

        END

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

        ${resp}=   Get Service
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${s_id}=  Set Variable  ${NONE}
        IF   '${resp.content}' != '${emptylist}'
            
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
        # IF   '${resp.content}' == '${emptylist}'
        #     ${SERVICE1}=    FakerLibrary.job
        #     ${maxbookings}=   Random Int   min=5   max=10
        #     ${s_id}=  Create Sample Service  ${SERVICE1}  maxBookingsAllowed=${count}
        # ELSE
        #     Set Test Variable   ${s_id}   ${resp.json()[0]['id']}

        #     ${maxbookings}=   Random Int   min=5   max=10
        #     ${resp}=  Update Service  ${s_id}  ${resp.json()[0]['name']}  ${EMPTY}  ${resp.json()[0]['serviceDuration']}  ${status[0]}  ${btype}  ${bool[1]}  ${resp.json()[0]['notificationType']}  ${EMPTY}  ${resp.json()[0]['notificationType']}  ${bool[0]}  ${bool[0]}  maxBookingsAllowed=${count}
        #     Log  ${resp.content}
        #     Should Be Equal As Strings  ${resp.status_code}  200
        # END

        ${resp}=  Get Waitlist Today  waitlistStatus-eq=${wl_status[0]}  waitlistStatus-neq=${wl_status[5]},${wl_status[4]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${prepay_wl_len}=  Get Length   ${resp.json()}
        FOR   ${i}  IN RANGE   ${prepay_wl_len}

            ${resp1}=  Waitlist Action  ${waitlist_actions[4]}   ${resp.json()[${i}]['ynwUuid']}
            Log  ${resp1.content}
            Should Be Equal As Strings  ${resp1.status_code}  200
            

        END
        
        ${resp}=  Get Waitlist Today   waitlistStatus-neq=${wl_status[5]},${wl_status[4]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${today_wl_len}=  Get Length   ${resp.json()}
        FOR   ${i}  IN RANGE   ${today_wl_len}

            ${resp1}=  Waitlist Action  ${waitlist_actions[4]}   ${resp.json()[${i}]['ynwUuid']}
            Log  ${resp1.content}
            Should Be Equal As Strings  ${resp1.status_code}  200      

        END

        ${resp}=  Get Waitlist Future  waitlistStatus-neq=${wl_status[5]},${wl_status[4]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${future_wl_len}=  Get Length   ${resp.json()}
        FOR   ${i}  IN RANGE   ${future_wl_len}

            ${resp1}=  Waitlist Action  ${waitlist_actions[4]}   ${resp.json()[${i}]['ynwUuid']}
            Log  ${resp1.content}
            Should Be Equal As Strings  ${resp1.status_code}  200
            
        END

        # ${resp}=  ProviderKeywords.Get Provider Waitlist History
        ${resp}=  Get Provider Waitlist History
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Get Queues  state-eq=${Qstate[0]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}   200
        ${queues_count}=  Get Length  ${resp.json()}
        FOR   ${i}  IN RANGE   ${queues_count}

            # IF  ${resp.json()[${i}]['id']}
            ${resp1}=  Disable Queue  ${resp.json()[${i}]['id']}
            Log  ${resp1.json()}
            Should Be Equal As Strings  ${resp1.status_code}  200

        END


        ${DAY}=  get_date_by_timezone  ${tz}
        ${sTime1}=  db.get_time_by_timezone  ${tz} 
        ${eTime1}=  add_timezone_time  ${tz}  0  45  
        ${p1queue1}=    FakerLibrary.job
        # ${capacity}=  FakerLibrary.Numerify  %%
        ${capacity}=  IF    ${count} > 50    Convert To Integer   ${count}    ELSE    FakerLibrary.Random Int  min=${count}  max=${count+20}
        ${list}=  Create List  1  2  3  4  5  6  7
        ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  1  ${capacity}  ${lid}  ${s_id}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${q_id1}  ${resp.json()}

        FOR   ${a}  IN RANGE   ${count}
        
            ${PO_Number}    Generate random string    5    0123456789
            ${PO_Number}    Convert To Integer  ${PO_Number}
            ${CUSERPH}=  Evaluate  ${CUSERNAME}+${PO_Number}
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
            END
        

            ${desc}=   FakerLibrary.word
            ${resp}=  Add To Waitlist  ${cid${a}}  ${s_id}  ${q_id1}  ${DAY}  ${desc}  ${bool[1]}  ${cid${a}} 
            Log  ${resp.content}
            Should Be Equal As Strings  ${resp.status_code}  200
            ${wlresp}=  Get Dictionary Values  ${resp.json()}
            Set Test Variable  ${wid${a}}  ${wlresp[0]}

            ${resp}=  Get Waitlist By Id  ${wid${a}} 
            Log   ${resp.content}
            Should Be Equal As Strings  ${resp.status_code}  200

            ${fileSize}=  OperatingSystem.Get File Size  ${jpgfile}
            ${resp}=  db.getType   ${jpgfile}
            Log  ${resp}
            ${fileType1}=  Get From Dictionary       ${resp}    ${jpgfile}
            ${caption1}=  Fakerlibrary.Sentence
            ${path} 	${file} = 	Split String From Right 	${jpgfile} 	/ 	1
            ${fileName}  ${file_ext}= 	Split String 	${file}  .

            # ${resp}    upload file to temporary location    ${file_action[0]}    ${provider_id}    ${ownerType[0]}    ${provider_name}    ${jpgfile}    ${fileSize}    ${caption1}    ${fileType1}    ${EMPTY}    ${order}
            # Log  ${resp.content}
            # Should Be Equal As Strings     ${resp.status_code}    200 
            # Set Suite Variable    ${driveId}    ${resp.json()[0]['driveId']}

            # ${attachments}=  Create Dictionary  owner=${provider_id}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${provider_name}
            # ${attachment}=   Create List  ${attachments}

            ${uuid}=    Create List  ${wid${a}}

            ${resp}=    Send Message With Waitlist   ${caption1}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  uuid=${uuid}  # attachments=${attachment}
            Log  ${resp.content}
            Should Be Equal As Strings  ${resp.status_code}  200
        END
    END


JD-TC-TakeAppointment-1
    [Documentation]   Take appointment
    ${providers_list}=   Get File    ${EXECDIR}/data/${ENVIRONMENT}_varfiles/providers.py
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
        Set TEst Variable  ${tz}  ${resp.json()['baseLocation']['timezone']}

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

        ${resp}=   Get Service
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${s_id}=  Set Variable  ${NONE}
        IF   '${resp.content}' != '${emptylist}'
            
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
        
        ${resp}=  Get Appointments Today  apptStatus-neq=${apptStatus[6]},${apptStatus[5]},${apptStatus[4]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${today_appt_len}=  Get Length   ${resp.json()}
        FOR   ${i}  IN RANGE   ${today_appt_len}

            ${resp1}=  Appointment Action   ${apptStatus[6]}   ${resp.json()[${i}]['uid']}
            Log  ${resp1.content}
            Should Be Equal As Strings  ${resp1.status_code}  200
            
        END

        ${resp}=  Get Future Appointments  apptStatus-neq=${apptStatus[6]},${apptStatus[5]},${apptStatus[4]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${future_appt_len}=  Get Length   ${resp.json()}
        FOR   ${i}  IN RANGE   ${future_appt_len}

            ${resp1}=  Appointment Action   ${apptStatus[6]}   ${resp.json()[${i}]['uid']}
            Log  ${resp1.content}
            Should Be Equal As Strings  ${resp1.status_code}  200
            
        END

        ${resp}=   Get Appointments History
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Get Appointment Schedules  state-eq=${Qstate[0]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${schedules_count}=  Get Length  ${resp.json()}
        FOR   ${i}  IN RANGE   ${schedules_count}

            # IF  ${resp.json()[${i}]['apptState']}
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

        FOR   ${a}  IN RANGE   ${count}
        
            ${PO_Number}    Generate random string    5    0123456789
            ${PO_Number}    Convert To Integer  ${PO_Number}
            ${CUSERPH}=  Evaluate  ${CUSERNAME}+${PO_Number}
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
            # ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
            # Set Test Variable  ${apptid${a}}  ${apptid[0]}
            ${apptid}=  Get From Dictionary  ${resp.json()}  ${firstname}
            Set Suite Variable  ${apptid${a}}  ${apptid}

            ${resp}=  Get Appointment EncodedID   ${apptid${a}}
            Log   ${resp.content}
            Should Be Equal As Strings  ${resp.status_code}  200
            # ${encId}=  Set Variable   ${resp.json()}
            Set Test Variable  ${encId${a}}  ${resp.json()}

            ${resp}=  Get Appointment By Id   ${apptid${a}}
            Log   ${resp.content}
            Should Be Equal As Strings  ${resp.status_code}  200
            Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid${a}}
            Should Be Equal As Strings  ${resp.json()['appointmentEncId']}   ${encId${a}}

            ${fileSize}=  OperatingSystem.Get File Size  ${jpgfile}
            ${resp}=  db.getType   ${jpgfile}
            Log  ${resp}
            ${fileType1}=  Get From Dictionary       ${resp}    ${jpgfile}
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
        END
    END
