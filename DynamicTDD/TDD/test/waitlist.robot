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


*** Test Cases ***

JD-TC-AddToWL-1
    [Documentation]   Add To waitlist
    ${providers_list}=   Get File    ${EXECDIR}/TDD/${ENVIRONMENT}_varfiles/providers.py
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
        Set Suite Variable  ${account_id}  ${resp.json()['id']}
        # Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}

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
            Set Test Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
        ELSE
            Set Suite Variable  ${lid}  ${resp.json()[0]['id']}
            Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
        END

        ${s_id}=  Set Variable  ${NONE}
        ${resp}=   Get Service
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        # IF   '${resp.content}' != '${emptylist}'
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

        ${resp}=  Get Waitlist Today  waitlistStatus-eq=${wl_status[0]}  waitlistStatus-neq=${wl_status[5]},${wl_status[4]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${prepay_wl_len}=  Get Length   ${resp.json()}
        FOR   ${i}  IN RANGE   ${prepay_wl_len}

            ${resp1}=  Waitlist Action  ${waitlist_actions[4]}   ${resp.json()[${i}]['ynwUuid']}
            Log  ${resp1.content}
            Should Be Equal As Strings  ${resp1.status_code}  200
            

        END

        ${resp}=  Get Waitlist Today  waitlistStatus-eq=${wl_status[0]}  waitlistStatus-neq=${wl_status[5]},${wl_status[4]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${prepay_wl_len}=  Get Length   ${resp.json()}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${prepay_wl_len}  ${zero}
        
        ${resp}=  Get Waitlist Today   waitlistStatus-neq=${wl_status[5]},${wl_status[4]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${today_wl_len}=  Get Length   ${resp.json()}
        FOR   ${i}  IN RANGE   ${today_wl_len}

            ${resp1}=  Waitlist Action  ${waitlist_actions[4]}   ${resp.json()[${i}]['ynwUuid']}
            Log  ${resp1.content}
            Should Be Equal As Strings  ${resp1.status_code}  200      

        END

        ${resp}=  Get Waitlist Today   waitlistStatus-neq=${wl_status[5]},${wl_status[4]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${today_wl_len}=  Get Length   ${resp.json()}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${today_wl_len}  ${zero}

        ${resp}=  Get Waitlist Today
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${today_wl_len}=  Get Length   ${resp.json()}

        ${resp}=  Get Waitlist Future  waitlistStatus-neq=${wl_status[5]},${wl_status[4]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${future_wl_len}=  Get Length   ${resp.json()}
        FOR   ${i}  IN RANGE   ${future_wl_len}

            ${resp1}=  Waitlist Action  ${waitlist_actions[4]}   ${resp.json()[${i}]['ynwUuid']}
            Log  ${resp1.content}
            Should Be Equal As Strings  ${resp1.status_code}  200
            
        END

        ${resp}=  Get Waitlist Future  waitlistStatus-neq=${wl_status[5]},${wl_status[4]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${future_wl_len}=  Get Length   ${resp.json()}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${future_wl_len}  ${zero}

        ${resp}=  Get Waitlist Future
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${future_wl_len}=  Get Length   ${resp.json()}

        ${resp}=  Get history Waitlist  waitlistStatus-neq=${wl_status[5]},${wl_status[4]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${past_wl_len}=  Get Length   ${resp.json()}
        FOR   ${i}  IN RANGE   ${past_wl_len}

            ${resp1}=  Waitlist Action  ${waitlist_actions[4]}   ${resp.json()[${i}]['ynwUuid']}
            Log  ${resp1.content}
            Should Be Equal As Strings  ${resp1.status_code}  200
            
        END

        ${resp}=  Get history Waitlist  waitlistStatus-neq=${wl_status[5]},${wl_status[4]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${past_wl_len}=  Get Length   ${resp.json()}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${past_wl_len}  ${zero}

        ${resp}=  Get history Waitlist  
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${past_wl_len}=  Get Length   ${resp.json()}

        ${resp}=  Get Queues
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}   200
        ${queues_count}=  Get Length  ${resp.json()}

        ${resp}=  Get Queues  state-eq=${Qstate[0]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}   200
        ${queues_count}=  Get Length  ${resp.json()}
        FOR   ${i}  IN RANGE   ${queues_count}

            ${resp1}=  Disable Queue  ${resp.json()[${i}]['id']}
            Log  ${resp1.json()}
            Should Be Equal As Strings  ${resp1.status_code}  200

        END


        ${DAY}=  get_date_by_timezone  ${tz}
        ${sTime1}=  db.get_time_by_timezone  ${tz} 
        ${eTime1}=  add_timezone_time  ${tz}  0  45  
        ${p1queue1}=    FakerLibrary.job
        ${capacity}=  IF    ${count} > 50    Convert To Integer   ${count}    ELSE    FakerLibrary.Random Int  min=${count}  max=${count+20}
        ${list}=  Create List  1  2  3  4  5  6  7
        ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  1  ${capacity}  ${lid}  ${s_id}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${q_id1}  ${resp.json()}

        FOR   ${a}  IN RANGE   ${count}
        
            ${PH_Number}=  FakerLibrary.Numerify  %#####
            # ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
            # Log  ${PH_Number}
            # Set Suite Variable  ${CUSERPH}  555${PH_Number}
            ${CUSERPH}=  Evaluate  ${CUSERNAME}+${PH_Number}
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
            # BREAK
        END
        # BREAK
    END