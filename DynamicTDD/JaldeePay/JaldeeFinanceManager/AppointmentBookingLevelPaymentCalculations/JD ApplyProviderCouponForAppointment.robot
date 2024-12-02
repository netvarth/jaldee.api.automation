*** Settings ***
Suite Teardown    Delete All Sessions 
Test Teardown     Delete All Sessions
Force Tags        Waitlist
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
# Variables         /ebs/TDD/varfiles/consumermail.py
Variables         /ebs/TDD/varfiles/hl_providers.py



*** Variables ***

@{service_names}
${waitlistedby}           PROVIDER
${SERVICE1}               SERVICE1001
${SERVICE2}               SERVICE2002
${SERVICE3}               SERVICE3003
${SERVICE4}               SERVICE4004
${SERVICE5}               SERVICE3005
${SERVICE6}               SERVICE4006
${sample}                     4452135820
${self}         0


*** Test Cases ***

JD-TC-ApplyProviderCouponForAppointmnet-1
    [Documentation]   Provider a Create Coupon (service based on coupon),apply for Appointment(ONLINE)

    ${PUSERPH0}=  Evaluate  ${PUSERNAME}+33888341
    Set Suite Variable   ${PUSERPH0}

    ${firstname}  ${lastname}  ${PhoneNumber}  ${PUSERPH0}=  Provider Signup  PhoneNumber=${PUSERPH0}
    


    ${resp}=  Encrypted Provider Login    ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}

    Set Suite Variable  ${pid}  ${decrypted_data['id']}
    Set Suite Variable    ${pdrname}    ${decrypted_data['userName']}
    Set Suite Variable    ${pdrfname}    ${decrypted_data['firstName']}
    Set Suite Variable    ${pdrlname}    ${decrypted_data['lastName']}


    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}
    Set Suite Variable  ${account_id1}  ${resp.json()['id']}

    ${pid}=  get_acc_id  ${PUSERPH0}
    Set Suite Variable  ${pid}
    ${cid}=  get_id  ${CUSERNAME32}

    ${resp}=  Create Sample Location  
    Set Suite Variable    ${lid}    ${resp}  

    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}



    ${sTime}=  db.add_timezone_time     ${tz}  0  15
    ${eTime}=  db.add_timezone_time     ${tz}   0  45


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
    Should Be Equal As Strings  ${resp.json()['enableJaldeeFinance']}  ${bool[1]}


    ${resp}=  Enable Waitlist
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # sleep   01s


    ${resp}=  Get Bill Settings 
    Log   ${resp.json}
    IF  ${resp.status_code}!=200
        Log   Status code is not 200: ${resp.status_code}
        ${resp}=  Enable Disable bill  ${bool[1]}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
    ELSE IF  ${resp.json()['enablepos']}==${bool[0]}
        ${resp}=  Enable Disable bill  ${bool[1]}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
    END


    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[0]}   

    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[0]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    Set Suite Variable  ${min_pre}
    ${servicecharge}=  Convert To Number  ${servicecharge}  1 
    Set Suite Variable  ${servicecharge}
    ${srv_duration}=   Random Int   min=10   max=20
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${srv_duration}  ${bool[1]}  ${servicecharge}  ${bool[0]}  minPrePaymentAmount=${min_pre}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Suite Variable  ${s_id}  ${resp.json()}


    # clear_appt_schedule   ${PUSERPH0}

    ${resp}=  Get Appointment Schedules
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}

    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    Set Suite Variable  ${DAY2}

    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.add_timezone_time     ${tz}  0  15
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${PH_Number}=  FakerLibrary.Numerify  %#####
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${PCPHONENO}  555${PH_Number}

    ${fname}=  generate_firstname
    Set Suite Variable  ${fname}
    ${lname}=  FakerLibrary.last_name
    Set Suite Variable  ${lname}

    Set Test Variable  ${pc_emailid1}  ${fname}${C_Email}.${test_mail}

    ${resp}=  AddCustomer  ${PCPHONENO}    firstName=${fname}   lastName=${lname}  countryCode=${countryCodes[1]}  email=${pc_emailid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Send Otp For Login    ${PCPHONENO}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}
    ${resp}=  Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}     JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}
    
    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${PCPHONENO}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200



    ${resp}=    Get All Schedule Slots By Date Location and Service  ${pid}  ${DAY1}  ${lid}  ${s_id}
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
    Set Suite Variable   ${slot1}   ${slots[${j}]}

    # ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    # @{slots}=  Create List
    # FOR   ${i}  IN RANGE   0   ${no_of_slots}
    #     IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
    #         Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    #     END
    # END
    # ${num_slots}=  Get Length  ${slots}
    # ${j}=  Random Int  max=${num_slots-1}
    # Set Test Variable   ${slot1}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Customer Take Appointment   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}    location=${lid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}
    Set Suite Variable  ${apptid1}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response    ${resp}     uid=${apptid1}   appmtDate=${DAY1}   appmtTime=${slot1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}  ${apptStatus[0]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${resp}=  Encrypted Provider Login    ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=  Get Coupons 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${coupon}=    FakerLibrary.word
    ${desc}=  FakerLibrary.Sentence   nb_words=2
    ${pc_amount}=   Random Int   min=10  max=50
    ${pc_amount}=  Convert To Number  ${pc_amount}  1
    Set Suite Variable  ${pc_amount}
    ${cupn_code}=   FakerLibrary.word
    Set Suite Variable  ${cupn_code}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime}=  subtract_time  0  15
    ${eTime}=  db.add_timezone_time     ${tz}   0  45
    ${ST_DAY}=  db.get_date_by_timezone  ${tz}
    ${EN_DAY}=  db.add_timezone_date  ${tz}   11
    ${min_bill_amount}=   Random Int   min=90   max=100
    ${max_disc_val}=   Random Int   min=90  max=100
    ${max_prov_use}=   Random Int   min=10   max=20
    ${book_channel}=   Create List   ${bookingChannel[1]}    ${bookingChannel[0]}
    ${coupn_based}=  Create List   ${couponBasedOn[0]}
    ${tc}=  FakerLibrary.sentence
    ${services}=   Create list     ${s_id}    
    ${resp}=  Create Provider Coupon   ${coupon}  ${desc}  ${pc_amount}  ${calctype[1]}  ${cupn_code}  ${recurringtype[1]}  ${list}  ${sTime}  ${eTime}  ${ST_DAY}  ${EN_DAY}  ${EMPTY}  ${bool[1]}  ${min_bill_amount}  ${max_disc_val}  ${bool[1]}  ${max_prov_use}  ${book_channel}  ${coupn_based}  ${tc}  services=${services}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${couponId}  ${resp.json()}

    ${resp}=  Get Coupons 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${discAmt}=    Evaluate  ${servicecharge}-${pc_amount}

    ${resp}=   Apply Provider Coupon for Appointment    ${apptid1}    ${cupn_code}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['netRate']}                  ${discAmt}
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}         ${paymentStatus[0]}

    ${resp}=   Get Appointment level Bill Details      ${apptid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['netRate']}                  ${discAmt}
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}         ${paymentStatus[0]}

JD-TC-ApplyProviderCouponForAppointmnet-2
    [Documentation]   Take Appointment for Future then apply provider coupon(ONLINE).

    ${resp}=    ProviderConsumer Login with token   ${PCPHONENO}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get All Schedule Slots By Date Location and Service  ${pid}  ${DAY1}  ${lid}  ${s_id}
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
    Set Suite Variable   ${slot1}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Customer Take Appointment   ${pid}  ${s_id}  ${sch_id}  ${DAY2}  ${cnote}   ${apptfor}    location=${lid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}
    Set Suite Variable  ${apptid1}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response    ${resp}     uid=${apptid1}   appmtDate=${DAY2}   appmtTime=${slot1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}  ${apptStatus[0]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${resp}=  Encrypted Provider Login    ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=   Apply Provider Coupon for Appointment    ${apptid1}    ${cupn_code}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['netRate']}                  ${discAmt}
    # Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}         ${paymentStatus[0]}

    ${resp}=   Get Appointment level Bill Details      ${apptid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['netRate']}                  ${discAmt}
    # Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}         ${paymentStatus[0]}

JD-TC-ApplyProviderCouponForAppointmnet-3
    [Documentation]   Provider a Create Coupon (service based on coupon),apply for Appointment(WALK-IN).

    ${resp}=  Encrypted Provider Login  ${PUSERNAME125}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id1}  ${resp.json()['id']}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]} 
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    # clear_service   ${PUSERNAME125}
    # clear_location  ${PUSERNAME125}
    # clear_customer   ${PUSERNAME125}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}
        ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
    END
  
    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]} 

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']} 

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}  

    ${lid}=  Create Sample Location  
    Set Suite Variable  ${lid}

    ${service_duration}=   Random Int   min=5   max=10
    ${P1SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${servicecharge1}=  Convert To Number  ${servicecharge}  1
    Set Suite Variable  ${servicecharge1}
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration}     ${bool[0]}    ${servicecharge1}  ${bool[0]}      automaticInvoiceGeneration=${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${ser_id1}  ${resp.json()}    

    ${resp}=   Get Service By Id  ${ser_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['isPrePayment']}   ${bool[0]} 
    Should Be Equal As Numbers  ${resp.json()['totalAmount']}    ${servicecharge1} 

    # clear_appt_schedule   ${PUSERNAME125}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    # ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${ser_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id1}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY1}  ${ser_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id1}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  AddCustomer  ${CUSERNAME8}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${ser_id1}  ${sch_id1}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Suite Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid1}
    # Should Be Equal As Strings  ${resp.json()['appointmentEncId']}   ${encId}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname}
    # Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    # Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id1}
    # Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[1]}
    # Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname}
    # Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}
    # Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    # Should Be Equal As Strings  ${resp.json()['appmtDate']}   ${DAY1}
    # Should Be Equal As Strings  ${resp.json()['appmtTime']}   ${slot1}
    # Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${coupon}=    FakerLibrary.word
    ${desc}=  FakerLibrary.Sentence   nb_words=2
    ${pc_amount}=   Random Int   min=10  max=50
    ${pc_amount1}=  Convert To Number  ${pc_amount}  1
    Set Suite Variable  ${pc_amount1}
    ${cupn_code1}=   FakerLibrary.word
    Set Suite Variable  ${cupn_code1}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime}=  subtract_time  0  15
    ${eTime}=  db.add_timezone_time     ${tz}   0  45
    ${ST_DAY}=  db.get_date_by_timezone  ${tz}
    ${EN_DAY}=  db.add_timezone_date  ${tz}   11
    ${min_bill_amount}=   Random Int   min=90   max=100
    ${max_disc_val}=   Random Int   min=90  max=100
    ${max_prov_use}=   Random Int   min=10   max=20
    ${book_channel}=   Create List   ${bookingChannel[1]}    ${bookingChannel[0]}
    ${coupn_based}=  Create List   ${couponBasedOn[0]}
    ${tc}=  FakerLibrary.sentence
    ${services}=   Create list     ${ser_id1}    
    ${resp}=  Create Provider Coupon   ${coupon}  ${desc}  ${pc_amount1}  ${calctype[1]}  ${cupn_code1}  ${recurringtype[1]}  ${list}  ${sTime}  ${eTime}  ${ST_DAY}  ${EN_DAY}  ${EMPTY}  ${bool[0]}  ${min_bill_amount}  ${max_disc_val}  ${bool[1]}  ${max_prov_use}  ${book_channel}  ${coupn_based}  ${tc}  services=${services}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${couponId}  ${resp.json()}

    ${resp}=  Get Coupons 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${discAmt}=    Evaluate  ${servicecharge1}-${pc_amount1}

    ${resp}=   Apply Provider Coupon for Appointment    ${apptid1}    ${cupn_code1}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['netRate']}                  ${discAmt}
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}         ${paymentStatus[0]}

    ${resp}=   Get Appointment level Bill Details      ${apptid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['netRate']}                  ${discAmt}
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}         ${paymentStatus[0]}

JD-TC-ApplyProviderCouponForAppointmnet-4
    [Documentation]   Take Appointment for Future then apply provider coupon(WALK-IN).

    ${resp}=  Encrypted Provider Login  ${PUSERNAME125}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id1}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=    Get All Schedule Slots By Date Location and Service  ${account_id1}  ${DAY2}  ${lid}  ${ser_id1}
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
    Set Suite Variable   ${slot1}   ${slots[${j}]}

    # ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY2}  ${ser_id1}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id1}
    # Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  AddCustomer  ${CUSERNAME9}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${ser_id1}  ${sch_id1}  ${DAY2}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Suite Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid1}

    ${discAmt}=    Evaluate  ${servicecharge1}-${pc_amount1}

    ${resp}=   Apply Provider Coupon for Appointment    ${apptid1}    ${cupn_code1}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['netRate']}                  ${discAmt}
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}         ${paymentStatus[0]}

    ${resp}=   Get Appointment level Bill Details      ${apptid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['netRate']}                  ${discAmt}

JD-TC-ApplyProviderCouponForAppointmnet-6
    [Documentation]   Took one appointment and apply provider coupon then share invoice via link ,then pay via cash that time given notes and get the details using get url.
    

    ${resp}=  Encrypted Provider Login  ${PUSERNAME125}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

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
    Should Be Equal As Strings  ${resp.json()['enableJaldeeFinance']}  ${bool[1]}

    # ${resp}=  Auto Invoice Generation For Service   ${ser_id1}    ${toggle[0]}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${ser_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['automaticInvoiceGeneration']}    ${bool[1]}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id1}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY2}  ${ser_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id1}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  AddCustomer  ${CUSERNAME12}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${ser_id1}  ${sch_id1}  ${DAY2}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid1}

    ${discAmt}=    Evaluate  ${servicecharge1}-${pc_amount1}

    ${resp}=   Apply Provider Coupon for Appointment    ${apptid1}    ${cupn_code1}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['netRate']}                  ${discAmt}
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}         ${paymentStatus[0]}

    ${resp1}=  Get Booking Invoices  ${apptid1}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Set Test Variable  ${invoice_uid}  ${resp1.json()[0]['invoiceUid']}
    # Should Be Equal As Strings  ${resp1.json()[0]['netTotal']}     ${tot_amt}
    # Should Be Equal As Strings  ${resp1.json()[0]['netRate']}     ${tot_amt}
    # Should Be Equal As Strings  ${resp1.json()[0]['amountDue']}     ${tot_amt}
    # Should Be Equal As Strings  ${resp1.json()[0]['amountTotal']}     ${tot_amt}

    # ${resp}=   Get Appointment level Bill Details      ${apptid1} 
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['netRate']}                  ${discAmt}

    # ${resp}=  Get Bill By UUId  ${apptid1}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # Should Be Equal As Strings  ${resp.json()['netTotal']}         ${ser_amount1}
    # Should Be Equal As Strings  ${resp.json()['amountDue']}        ${ser_amount1}   
    # Should Be Equal As Strings  ${resp.json()['netRate']}          ${ser_amount1}   
    
    # ${resp}=  Update Bill   ${apptid1}  ${action[12]}    ${cupn_code1}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200   

    # ${total_amount}=  Evaluate  ${ser_amount1} - ${amount}
    # ${total_amount}=  Convert To Number  ${total_amount}  2

    # ${resp}=  Get Bill By UUId  ${apptid1}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${PO_Number}    Generate random string    5    123456789
    ${vendor_phn}=  Evaluate  ${PUSERNAME}+${PO_Number}
    # ${email}=   FakerLibrary.word
    Set Suite Variable  ${email}  ${fname}${vendor_phn}.${test_mail}

    ${resp}=  Generate Link For Invoice  ${invoice_uid}   ${vendor_phn}    ${email}    ${boolean[1]}    ${boolean[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${note}=    FakerLibrary.word
    ${resp}=  Make Payment By Cash For Invoice   ${invoice_uid}  ${payment_modes[0]}  ${discAmt}  ${note}    paymentOndate=${DAY1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-ApplyProviderCouponForAppointmnet-7
    [Documentation]   Create one appt then took appointment and apply provider coupon,then cancel appt.then check the quantity using get url.then reconfirm that appt and check the amount and quantity details.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME125}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id1}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY2}  ${ser_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id1}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  AddCustomer  ${CUSERNAME13}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${ser_id1}  ${sch_id1}  ${DAY2}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid1}

    ${discAmt}=    Evaluate  ${servicecharge1}-${pc_amount1}

    ${resp}=   Apply Provider Coupon for Appointment    ${apptid1}    ${cupn_code1}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['netRate']}                  ${discAmt}
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}         ${paymentStatus[0]}

    ${resp}=  Get Appointment Status   ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['appointmentStatus']}   ${apptStatus[1]} 

    # ${reason}=  Random Element  ${cancelReason}
    # ${msg}=   FakerLibrary.word
    # ${resp}=    Provider Cancel Appointment  ${apptid1}  ${reason}  ${msg}  ${DAY2}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${reason}=  Random Element  ${cancelReason}

    ${resp}=  Appointment Action   ${apptStatus[4]}   ${apptid1}    cancelReason=${reason}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Status   ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Contain  "${resp.json()}"  ${apptStatus[4]}

    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${ser_id1}  ${sch_id1}  ${DAY2}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Suite Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid1}

JD-TC-ApplyProviderCouponForAppointmnet-8
    [Documentation]   Apply provider coupon with empty coupon code.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME125}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Apply Provider Coupon for Appointment    ${apptid1}    ${EMPTY}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}    ${JALDEE_COUPON_NOT_VALID}
 

JD-TC-ApplyProviderCouponForAppointmnet-5
    [Documentation]   Took one prepayment appt from consumer side and apply provider coupon.Initiated a refund from the provider side, Then check refund status.

    ${resp}=  Encrypted Provider Login    ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${lid}=  Create Sample Location  

    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.add_timezone_time     ${tz}  0  15
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=    ProviderConsumer Login with token   ${PCPHONENO}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${consumer_id}  ${resp.json()['id']}

    # ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    # @{slots}=  Create List
    # FOR   ${i}  IN RANGE   0   ${no_of_slots}
    #     IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
    #         Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    #     END
    # END
    # ${num_slots}=  Get Length  ${slots}
    # ${j}=  Random Int  max=${num_slots-1}
    # Set Test Variable   ${slot1}   ${slots[${j}]}

    ${resp}=    Get All Schedule Slots By Date Location and Service  ${pid}  ${DAY1}  ${lid}  ${s_id}
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
    Set Suite Variable   ${slot1}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${DAY}=  db.get_date_by_timezone  ${tz}

    ${resp}=   Customer Take Appointment   ${pid}  ${s_id}  ${sch_id}  ${DAY}  ${cnote}   ${apptfor}    location=${lid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}
    Set Suite Variable  ${apptid1}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response    ${resp}     uid=${apptid1}   appmtDate=${DAY}   appmtTime=${slot1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}  ${apptStatus[0]}
    # Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname}
    # Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${resp}=  Encrypted Provider Login    ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${discAmt}=    Evaluate  ${servicecharge}-${pc_amount}


    ${resp}=   Apply Provider Coupon for Appointment    ${apptid1}    ${cupn_code}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['netRate']}                  ${discAmt}
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}         ${paymentStatus[0]}

    ${resp}=    ProviderConsumer Login with token   ${PCPHONENO}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Make payment Consumer Mock  ${pid}  ${min_pre}  ${purpose[0]}  ${apptid1}  ${s_id}  ${bool[0]}   ${bool[1]}  ${consumer_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200




*** Comments ***
JD-TC-ApplyProviderCouponForAppointmnet-2
    [Documentation]   Provider Create Coupon  with Percentage Calculation Type,Then apply for Appointment.

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_Coupon   ${PUSERPH0}
    
    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${tz}  ${resp.json()['baseLocation']['timezone']}

    ${coupon}=    FakerLibrary.word
    ${desc}=  FakerLibrary.Sentence   nb_words=2
    ${amount}=  Random Int   min=10  max=50
    ${cupn_code}=   FakerLibrary.word
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${ST_DAY}=  db.get_date_by_timezone  ${tz}
    ${EN_DAY}=  db.add_timezone_date  ${tz}   10
    ${min_bill_amount}=   Random Int   min=100   max=1000
    ${max_disc_val}=   Random Int   min=100   max=500
    ${max_prov_use}=   Random Int   min=10   max=20
    ${book_channel}=   Create List   ${bookingChannel[0]}    ${bookingChannel[1]}
    ${coupn_based}=  Create List   ${couponBasedOn[0]}
    ${tc}=  FakerLibrary.sentence
    ${services}=   Create list   ${s_id}   
    ${resp}=  Create Provider Coupon   ${coupon}  ${desc}  ${amount}  ${calctype[0]}  ${cupn_code}  ${recurringtype[1]}  ${list}  ${sTime}  ${eTime}  ${ST_DAY}  ${EN_DAY}  ${EMPTY}  ${bool[1]}  ${min_bill_amount}  ${max_disc_val}  ${bool[1]}  ${max_prov_use}  ${book_channel}  ${coupn_based}  ${tc}  services=${services}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${coupon_id1}  ${resp.json()}
    
    ${resp}=  Get Coupon By Id  ${coupon_id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  

    # ${discAmt}=    Evaluate  ${ser_amount2}-${amount}

    ${resp}=   Apply Provider Coupon for Appointment    ${apptid1}    ${cupn_code}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['netRate']}                  ${discAmt}
    # Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}         ${paymentStatus[0]}

    ${resp}=   Get Appointment level Bill Details      ${apptid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['netRate']}                  ${discAmt}
    # Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}         ${paymentStatus[0]}

JD-TC-ApplyProviderCouponForAppointmnet-3
    [Documentation]   Provider a Create Coupon with online booking channel,Then apply for Appointment.

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_Coupon   ${PUSERPH0}


    ${coupon1}=    FakerLibrary.word
    ${desc}=  FakerLibrary.Sentence   nb_words=2
    ${amount}=  Random Int   min=10  max=50
    ${cupn_code}=   FakerLibrary.word
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${ST_DAY}=  db.get_date_by_timezone  ${tz}
    ${EN_DAY}=  db.add_timezone_date  ${tz}   10
    ${min_bill_amount}=   Random Int   min=100   max=1000
    ${max_disc_val}=   Random Int   min=100   max=500
    ${max_prov_use}=   Random Int   min=10   max=20
    ${book_channel}=   Create List   ${bookingChannel[1]}
    ${coupn_based}=  Create List   ${couponBasedOn[0]}
    ${tc}=  FakerLibrary.sentence
    ${services}=   Create list   ${s_id}   
    ${resp}=  Create Provider Coupon   ${coupon1}  ${desc}  ${amount}  ${calctype[1]}  ${cupn_code}  ${recurringtype[1]}  ${list}  ${sTime}  ${eTime}  ${ST_DAY}  ${EN_DAY}  ${EMPTY}  ${bool[1]}  ${min_bill_amount}  ${max_disc_val}  ${bool[1]}  ${max_prov_use}  ${book_channel}  ${coupn_based}   ${tc}  services=${services} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${coupon_id1}  ${resp.json()}
    
    ${resp}=  Get Coupon By Id  ${coupon_id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  

    # ${discAmt}=    Evaluate  ${ser_amount2}-${amount}

    ${resp}=   Apply Provider Coupon for Appointment    ${apptid1}    ${cupn_code}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['netRate']}                  ${discAmt}
    # Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}         ${paymentStatus[0]}

    ${resp}=   Get Appointment level Bill Details      ${apptid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['netRate']}                  ${discAmt}
    # Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}         ${paymentStatus[0]}

JD-TC-ApplyProviderCouponForAppointmnet-4
    [Documentation]   Provider a Create Coupon with online booking channel,Then apply for Appointment.

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_Coupon   ${PUSERPH0}
    
    ${coupon1}=    FakerLibrary.word
    ${desc}=  FakerLibrary.Sentence   nb_words=2
    ${amount}=  Random Int   min=10  max=50
    ${cupn_code}=   FakerLibrary.word
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${ST_DAY}=  db.get_date_by_timezone  ${tz}
    ${EN_DAY}=  db.add_timezone_date  ${tz}   10
    ${min_bill_amount}=   Random Int   min=100   max=1000
    ${max_disc_val}=   Random Int   min=100   max=500
    ${max_prov_use}=   Random Int   min=10   max=20
    ${book_channel}=   Create List   ${bookingChannel[2]}
    ${coupn_based}=  Create List   ${couponBasedOn[0]}
    ${tc}=  FakerLibrary.sentence
    ${services}=   Create list   ${s_id}
    ${resp}=  Create Provider Coupon   ${coupon1}  ${desc}  ${amount}  ${calctype[1]}  ${cupn_code}  ${recurringtype[1]}  ${list}  ${sTime}  ${eTime}  ${ST_DAY}  ${EN_DAY}  ${EMPTY}  ${bool[1]}  ${min_bill_amount}  ${max_disc_val}  ${bool[1]}  ${max_prov_use}  ${book_channel}  ${coupn_based}  ${tc}  services=${services}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${coupon_id1}  ${resp.json()}
    
    ${resp}=  Get Coupon By Id  ${coupon_id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  

    # ${discAmt}=    Evaluate  ${ser_amount2}-${amount}

    ${resp}=   Apply Provider Coupon for Appointment    ${apptid1}    ${cupn_code}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['netRate']}                  ${discAmt}
    # Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}         ${paymentStatus[0]}

    ${resp}=   Get Appointment level Bill Details      ${apptid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['netRate']}                  ${discAmt}
    # Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}         ${paymentStatus[0]}

JD-TC-ApplyProviderCouponForAppointmnet-5
    [Documentation]   Provider a Create Coupon with whatsapp booking channel,Then apply for Appointment.

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_Coupon   ${PUSERPH0}

    ${coupon1}=    FakerLibrary.word
    ${desc}=  FakerLibrary.Sentence   nb_words=2
    ${amount}=  Random Int   min=10  max=50
    ${cupn_code}=   FakerLibrary.word
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${ST_DAY}=  db.get_date_by_timezone  ${tz}
    ${EN_DAY}=  db.add_timezone_date  ${tz}   10
    ${min_bill_amount}=   Random Int   min=100   max=1000
    ${max_disc_val}=   Random Int   min=100   max=500
    ${max_prov_use}=   Random Int   min=10   max=20
    ${book_channel}=   Create List   ${bookingChannel[2]}
    ${coupn_based}=  Create List   ${couponBasedOn[0]}
    ${tc}=  FakerLibrary.sentence
    ${services}=   Create list   ${s_id}   
    ${resp}=  Create Provider Coupon   ${coupon1}  ${desc}  ${amount}  ${calctype[1]}  ${cupn_code}  ${recurringtype[1]}  ${list}  ${sTime}  ${eTime}  ${ST_DAY}  ${EN_DAY}  ${EMPTY}  ${bool[1]}  ${min_bill_amount}  ${max_disc_val}  ${bool[1]}  ${max_prov_use}  ${book_channel}  ${coupn_based}  ${tc}  services=${services}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${coupon_id1}  ${resp.json()}
    
    ${resp}=  Get Coupon By Id  ${coupon_id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  

    # ${discAmt}=    Evaluate  ${ser_amount2}-${amount}

    ${resp}=   Apply Provider Coupon for Appointment    ${apptid1}    ${cupn_code}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['netRate']}                  ${discAmt}
    # Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}         ${paymentStatus[0]}

    ${resp}=   Get Appointment level Bill Details      ${apptid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['netRate']}                  ${discAmt}
    # Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}         ${paymentStatus[0]}

JD-TC-ApplyProviderCouponForAppointmnet-6
    [Documentation]   Create one appointment and then share that link through email and sms.then check the invoice details.


JD-TC-ApplyProviderCouponForAppointmnet-9
    [Documentation]   Take one appointment having a service enabled auto invoice generation.then disable finance and check the service details whether the service auto invoice generation flag is off.


JD-TC-ApplyProviderCouponForAppointmnet-10
    [Documentation]   Service autogeneration is on.then create one appointment,then check invoice is generated or not.

JD-TC-ApplyProviderCouponForAppointmnet-11
    [Documentation]   Create teleservices and add to appointment and create invoice.

JD-TC-ApplyProviderCouponForAppointmnet-12
    [Documentation]   Service price is zero.then create one booking,then cancel that appointment and edit that service price from zero to higher value then again reconfirm that booking and get that invoice details (service autoinvoice generation flag is on).