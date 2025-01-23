*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Appointment  
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/CustomKeywords.py
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
# JD-TC-GetAppointmentTodayCount-28

#     [Documentation]  taking a appt for a provider who has a branch in US. base location is India.(online appt from India),
#     ...   then verify get appt today details. 

#     # clear_location_n_service  ${PUSERNAME230}
#     # clear_queue     ${PUSERNAME230}

#     ${resp}=  Encrypted Provider Login  ${PUSERNAME230}  ${PASSWORD}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${decrypted_data}=  db.decrypt_data  ${resp.content}
#     Log  ${decrypted_data}
#     Set Test Variable  ${lic_id}   ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}
#     Set Test Variable  ${lic_name}   ${decrypted_data['accountLicenseDetails']['accountLicense']['name']}
   
#     ${highest_package}=  get_highest_license_pkg
#     Log  ${highest_package}
#     Set Test variable  ${lic2}  ${highest_package[0]}

#     IF  '${lic_id}' != '${lic2}'
#         ${resp1}=   Change License Package  ${highest_package[0]}
#         Log  ${resp1.content}
#         Should Be Equal As Strings  ${resp1.status_code}  200
#     END
   
#     ${resp}=  Get Business Profile
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${pid}=  get_acc_id  ${PUSERNAME230}
    
#     ${SERVICE1}=    generate_unique_service_name  ${service_names}
#     Append To List  ${service_names}  ${SERVICE1}
#     ${s_id1}=   Create Sample Service  ${SERVICE1}

#     ${resp}=    Get Locations
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     IF   '${resp.content}' == '${emptylist}'
#         ${loc_id1}=  Create Sample Location
#         Set Suite Variable   ${loc_id1}
#         ${resp}=   Get Location ById  ${loc_id1}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Set Suite Variable  ${tz}  ${resp.json()['timezone']}
#     ELSE
#         Set Suite Variable  ${loc_id1}  ${resp.json()[0]['id']}
#         Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
#     END

#     ${resp}=   Get Location ById  ${loc_id1}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=   Get Location ById  ${loc_id1}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${schedule_name}=  FakerLibrary.bs
#     ${parallel}=  FakerLibrary.Random Int  min=1  max=10
#     ${duration}=  FakerLibrary.Random Int  min=1  max=5
#     ${bool1}=  Random Element  ${bool}
#     ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${loc_id1}  ${duration}  ${bool1}  ${s_id1}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Suite Variable  ${sch_id1}  ${resp.json()}

#     ${resp}=  Get Appointment Schedule ById  ${sch_id1}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
    
#     ${resp}=  Get Monthly Schedule Availability by Location and Service  ${loc_id1}  ${s_id1}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
   
#     ${resp}=  ProviderLogout
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${firstName}=  generate_firstname
#     ${lastname}=  FakerLibrary.last_name
#     Set Test Variable  ${pc_emailid1}  ${firstName}${C_Email}.${test_mail}
#     ${resp}=    Send Otp For Login    ${CUSERNAME9}    ${pid}  alternateLoginId=${pc_emailid1}
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${jsessionynw_value}=   Get Cookie from Header  ${resp} 

#     ${jsessionynw_value}=   Get Cookie from Header  ${resp}

#     ${resp}=    Verify Otp For Login   ${CUSERNAME9}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200
#     Set Test Variable  ${token}  ${resp.json()['token']}

#     ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${pc_emailid1}  ${CUSERNAME9}  ${pid}  countryCode=${countryCodes[0]}    title=mr
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200    

#     ${resp}=  Consumer Logout   
#     Should Be Equal As Strings    ${resp.status_code}    200
   
#     ${resp}=    ProviderConsumer Login with token   ${CUSERNAME9}  ${pid}  ${token}   countryCode=${countryCodes[0]}
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200
#     Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}

#     ${resp}=    Get All Schedule Slots By Date Location and Service  ${pid}  ${DAY1}  ${loc_id1}  ${s_id1}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${no_of_slots}=  Get Length  ${resp.json()[0]['availableSlots']}
#     @{slots}=  Create List
#     FOR   ${i}  IN RANGE   0   ${no_of_slots}
#         IF  ${resp.json()[0]['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
#             Append To List   ${slots}  ${resp.json()[0]['availableSlots'][${i}]['time']}
#         END
#     END
#     ${num_slots}=  Get Length  ${slots}
#     ${j}=  Random Int  max=${num_slots-1}
#     Set Test Variable   ${slot1}   ${slots[${j}]}

#     ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
#     ${apptfor}=   Create List  ${apptfor1}

#     ${cnote}=   FakerLibrary.word
#     ${resp}=   Customer Take Appointment  ${pid}   ${s_id1}  ${sch_id1}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}  location=${{str('${loc_id1}')}}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${apptid}=  Get Dictionary Values  ${resp.json()}
#     Set Test Variable  ${apptid1}  ${apptid[0]}

#     ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200 

#     ${resp}=  Consumer Logout   
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=  Encrypted Provider Login  ${PUSERNAME230}  ${PASSWORD}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Get Appointments Today
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${len}=  Get Length  ${resp.json()}

#     ${resp}=  Get Today Appointment Count
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings  ${resp.json()}  ${len}



JD-TC-GetAppointmentTodayCount-5

    [Documentation]  takes an online appointment for today for a service with prepayment then do the pre payment , and it should in today appointment with status as confirmed.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME237}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${pid}=  get_acc_id  ${PUSERNAME237}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        Set Suite Variable   ${lid}
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Suite Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
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

    # clear_service   ${PUSERNAME237}
    # clear_appt_schedule   ${PUSERNAME237}

    ${description}=  FakerLibrary.sentence
    ${ser_durtn}=   Random Int   min=2   max=10
    ${prepay_amt}=   Random Int   min=50   max=100
    ${ser_amount}=   Random Int   min=100   max=1000
    ${ser_amount1}=   Convert To Number   ${ser_amount}
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${resp}=  Create Service  ${SERVICE1}   ${description}  ${ser_durtn}  ${bool[1]}  ${ser_amount1}  ${bool[0]}  minPrePaymentAmount=${prepay_amt}  maxBookingsAllowed=10
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Test Variable  ${s_id}  ${resp.json()}

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
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    # ${resp}=  Provider Logout
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=    Send Otp For Login    ${CUSERNAME18}    ${pid}
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}   200

    # ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    # ${resp}=    Verify Otp For Login    ${CUSERNAME18}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}   200
    # Set Test Variable  ${token}  ${resp.json()['token']}

    # ${resp}=    ProviderConsumer Login with token   ${CUSERNAME18}    ${pid}  ${token} 
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}   200


    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${firstName}=  generate_firstname
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${pc_emailid1}  ${firstName}${C_Email}.${test_mail}
    ${resp}=    Send Otp For Login    ${CUSERNAME9}    ${pid}  alternateLoginId=${pc_emailid1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp} 

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${CUSERNAME9}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${pc_emailid1}  ${CUSERNAME9}  ${pid}  countryCode=${countryCodes[0]}    title=mr
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200    

    ${resp}=  Consumer Logout   
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME9}  ${pid}  ${token}   countryCode=${countryCodes[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Test Variable   ${fname}   ${resp.json()['firstName']}
    # Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}


    ${resp}=    Get All Schedule Slots By Date Location and Service  ${pid}  ${DAY1}  ${lid}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${no_of_slots}=  Get Length  ${resp.json()[0]['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        IF  ${resp.json()[0]['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Append To List   ${slots}  ${resp.json()[0]['availableSlots'][${i}]['time']}
        END
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Test Variable   ${slot1}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Customer Take Appointment   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}    location=${lid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Make payment Consumer Mock  ${pid}  ${prepay_amt}  ${purpose[0]}  ${apptid1}  ${s_id}  ${bool[0]}   ${bool[1]}  ${cid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get ProviderConsumer
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['title']}    mr

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
