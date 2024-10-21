*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Appointment Rating
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library         /ebs/TDD/CustomKeywords.py
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Resource          /ebs/TDD/ProviderConsumerKeywords.robot

*** Variables ***

${SERVICE1}   Bleach
${SERVICE3}   Makeup
${SERVICE4}   FacialBody6
${SERVICE2}   MakeupHair6
${self}       0
@{service_names}

*** Test Cases ***

JD-TC-GetAppointmentRating-1

	[Documentation]    Get Appointment Rating filter by account id.
	
    ${resp}=  Encrypted Provider Login  ${PUSERNAME200}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${lic_id}  ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}

    # clear_queue    ${PUSERNAME200}
    # clear_service  ${PUSERNAME200}
    clear_rating    ${PUSERNAME200}

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']} 
 
    ${resp}=  Get Locations
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${lid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    # clear_appt_schedule   ${PUSERNAME200}

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${pkg_id}=   get_highest_license_pkg
    Log   ${pkg_id}
    Set Suite Variable  ${pkgId}   ${pkg_id[0]}

    IF  '${lic_id}' != '${pkgId}'
        ${resp}=  Change License Package  ${pkgId}
        Should Be Equal As Strings    ${resp.status_code}   200
    END

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable   ${s_id}
    
    ${SERVICE2}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE2}
    ${s_id2}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable   ${s_id2}

    ${SERVICE3}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE3}
    ${s_id3}=  Create Sample Service  ${SERVICE3}
    Set Suite Variable   ${s_id3}

    ${SERVICE4}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE4}
    ${s_id4}=  Create Sample Service  ${SERVICE4}
    Set Suite Variable   ${s_id4}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=90
    ${eTime1}=  add_two   ${sTime1}  ${delta}

    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${DAY2}=  db.add_timezone_date  ${tz}  11      
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  1  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}

    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id3}  ${s_id4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    #............provider consumer creation..........

    ${PH_Number}=  FakerLibrary.Numerify  %#####
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${PCPHONENO}  555${PH_Number}

    ${fname}=  generate_firstname
    Set Suite Variable  ${fname}
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable  ${pc_emailid1}  ${fname}${C_Email}.${test_mail}

    ${resp}=  AddCustomer  ${PCPHONENO}    firstName=${fname}   lastName=${lastname}  countryCode=${countryCodes[1]}  email=${pc_emailid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${PCPHONENO}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()[0]['id']}

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Send Otp For Login    ${PCPHONENO}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${PCPHONENO}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
   
    # ${resp}=  Consumer Login  ${CUSERNAME13}  ${PASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200  

    # ${resp}=  Get Appointment Schedules Consumer  ${account_id}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id}   ${account_id}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get All Schedule Slots By Date Location and Service  ${account_id}  ${DAY1}  ${lid}  ${s_id}
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
    Set Suite Variable   ${slot1}   ${slots[${j}]}
    
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    # ${cnote}=   FakerLibrary.name
    # ${resp}=   Take Appointment For Provider   ${account_id}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200


    ${cnote}=   FakerLibrary.word
    ${resp}=   Customer Take Appointment  ${account_id}   ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid1}  ${apptid[0]}

    ${rating1}=  Random Int  min=1   max=5
    Set Suite Variable   ${rating1}
    ${comment1}=   FakerLibrary.word
    Set Suite Variable   ${comment1}
    ${resp}=  Add Appointment Rating  ${account_id}  ${apptid1}   ${rating1}   ${comment1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get consumer Appointment By Id    ${account_id}    ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=   Get Appointment Rating   account-eq=${account_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Should Be Equal As Strings  ${resp.json()[0]['uuid']}               ${apptid1}
    Should Be Equal As Strings  ${resp.json()[0]['stars']}              ${rating1}
    Should Be Equal As Strings  ${resp.json()[0]['feedback'][0]['comments']}  ${comment1}
    Should Be Equal As Strings  ${resp.json()[0]['service']['id']}      ${s_id}
   
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}    1

JD-TC-GetAppointmentRating-2

    [Documentation]  Get Multiple Appointment Ratings filter by account id.

    ${resp}=    ProviderConsumer Login with token   ${PCPHONENO}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get All Schedule Slots By Date Location and Service  ${account_id}  ${DAY1}  ${lid}  ${s_id}
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

    ${DAY2}=  db.add_timezone_date  ${tz}  6  
    # ${cnote}=   FakerLibrary.name
    # ${resp}=   Take Appointment For Provider   ${account_id}  ${s_id2}  ${sch_id}  ${DAY2}  ${cnote}   ${apptfor}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${cnote}=   FakerLibrary.word
    ${resp}=   Customer Take Appointment  ${account_id}   ${s_id2}  ${sch_id}  ${DAY2}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid2}  ${apptid[0]}

    # ${rating2}=  Random Int  min=1   max=5
    # Set Suite Variable   ${rating2}
    ${comment2}=   FakerLibrary.word
    Set Suite Variable   ${comment2}
    ${resp}=  Add Appointment Rating  ${account_id}  ${apptid2}   ${rating1}   ${comment2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get consumer Appointment By Id    ${account_id}    ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    Get All Schedule Slots By Date Location and Service  ${account_id}  ${DAY1}  ${lid}  ${s_id3}
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
    Set Test Variable   ${slot2}   ${slots[${j}]}
    
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}
    # ${cnote}=   FakerLibrary.name
    # ${resp}=   Take Appointment For Provider   ${account_id}  ${s_id3}  ${sch_id1}  ${DAY1}  ${cnote}   ${apptfor}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${cnote}=   FakerLibrary.word
    ${resp}=   Customer Take Appointment  ${account_id}   ${s_id3}  ${sch_id1}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid3}  ${apptid[0]}

    # ${rating3}=  Random Int  min=1   max=5
    # Set Suite Variable   ${rating3}
    ${comment3}=   FakerLibrary.word
    Set Suite Variable  ${comment3}
    ${resp}=  Add Appointment Rating  ${account_id}  ${apptid3}   ${rating1}   ${comment3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get consumer Appointment By Id    ${account_id}    ${apptid3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Rating   account-eq=${account_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  3
    Should Be Equal As Strings  ${resp.json()[0]['uuid']}        ${apptid3}
    Should Be Equal As Strings  ${resp.json()[1]['uuid']}        ${apptid2}
    Should Be Equal As Strings  ${resp.json()[2]['uuid']}        ${apptid1}
    Should Be Equal As Strings  ${resp.json()[0]['stars']}       ${rating1}
    Should Be Equal As Strings  ${resp.json()[1]['stars']}       ${rating1}
    Should Be Equal As Strings  ${resp.json()[2]['stars']}       ${rating1}
    Should Be Equal As Strings  ${resp.json()[0]['feedback'][0]['comments']}  ${comment3}
    Should Be Equal As Strings  ${resp.json()[1]['feedback'][0]['comments']}  ${comment2}
    Should Be Equal As Strings  ${resp.json()[2]['feedback'][0]['comments']}  ${comment1}
    Should Be Equal As Strings  ${resp.json()[0]['service']['id']}      ${s_id3}
    Should Be Equal As Strings  ${resp.json()[1]['service']['id']}      ${s_id2}
    Should Be Equal As Strings  ${resp.json()[2]['service']['id']}      ${s_id}

JD-TC-GetAppointmentRating-3

    [Documentation]  Get Appointment Rating filter by rating.  

    ${resp}=  Encrypted Provider Login  ${PUSERNAME101}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${lic_id}  ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}

    # clear_queue    ${PUSERNAME101}
    # clear_service  ${PUSERNAME101}
    clear_rating    ${PUSERNAME101}
    
    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${pkg_id}=   get_highest_license_pkg
    Log   ${pkg_id}
    Set Suite Variable  ${pkgId}   ${pkg_id[0]}

    IF  '${lic_id}' != '${pkgId}'
        ${resp}=  Change License Package  ${pkgId}
        Should Be Equal As Strings    ${resp.status_code}   200
    END
 
    ${account_id1}=  get_acc_id  ${PUSERNAME101}
    Set Suite Variable  ${account_id1} 
    
    ${resp}=  Get Locations
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${lid1}  ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}
    # clear_appt_schedule   ${PUSERNAME101}

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${ser_id}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable   ${ser_id}
    
    ${SERVICE2}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE2}
    ${ser_id2}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable   ${ser_id2}

    ${SERVICE3}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE3}
    ${ser_id3}=  Create Sample Service  ${SERVICE3}
    Set Suite Variable   ${ser_id3}

    ${SERVICE4}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE4}
    ${ser_id4}=  Create Sample Service  ${SERVICE4}
    Set Suite Variable   ${ser_id4}

    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=90
    ${eTime1}=  add_two   ${sTime1}  ${delta}

    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid1}  ${duration}  ${bool1}  ${ser_id}  ${ser_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${schedule_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${schedule_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DAY2}=  db.add_timezone_date  ${tz}  11      
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  1  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}

    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid1}  ${duration}  ${bool1}  ${ser_id3}  ${ser_id4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${schedule_id1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${schedule_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

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

    ${resp}=    Verify Otp For Login   ${PCPHONENO1}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token1}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${PCPHONENO1}    ${account_id1}  ${token1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    # ${resp}=  Consumer Login  ${CUSERNAME14}  ${PASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Appointment Schedules Consumer  ${account_id}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id}   ${account_id}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${account_id}
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
    ${resp}=    Get All Schedule Slots By Date Location and Service  ${account_id1}  ${DAY1}  ${lid1}  ${ser_id}
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

    ${DAY2}=  db.add_timezone_date  ${tz}  2  
    # ${cnote}=   FakerLibrary.name
    # ${resp}=   Take Appointment For Provider   ${account_id1}  ${ser_id}  ${schedule_id}  ${DAY2}  ${cnote}   ${apptfor}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${cnote}=   FakerLibrary.word
    ${resp}=   Customer Take Appointment  ${account_id}   ${ser_id}  ${schedule_id}  ${DAY2}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid4}  ${apptid[0]}

    ${rating}=  Random Int  min=1   max=5
    Set Suite Variable   ${rating}
    ${resp}=  Add Appointment Rating  ${account_id1}  ${apptid4}   ${rating}   ${comment1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get All Schedule Slots By Date Location and Service  ${account_id1}  ${DAY2}  ${lid1}  ${ser_id3}
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
    Set Test Variable   ${slot2}   ${slots[${j}]}
    
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Customer Take Appointment   ${account_id1}  ${ser_id3}  ${schedule_id1}  ${DAY2}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid5}  ${apptid[0]}
  
    ${resp}=  Add Appointment Rating  ${account_id1}  ${apptid5}   ${rating}   ${comment1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Rating   rating-eq=${rating}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  2
    Should Be Equal As Strings  ${resp.json()[0]['uuid']}    ${apptid5}
    Should Be Equal As Strings  ${resp.json()[1]['uuid']}    ${apptid4}
    # Should Be Equal As Strings  ${resp.json()[2]['uuid']}    ${apptid3}
    # Should Be Equal As Strings  ${resp.json()[3]['uuid']}    ${apptid2}
    # Should Be Equal As Strings  ${resp.json()[4]['uuid']}    ${apptid1}

JD-TC-GetAppointmentRating-4

    [Documentation]  Get Appointment Rating filter by service.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME101}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Location By Id   ${lid1} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${tz}  ${resp.json()['timezone']}
    
    ${resp}=  ProviderLogout 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderConsumer Login with token   ${PCPHONENO1}    ${account_id1}  ${token1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${DAY4}=  db.add_timezone_date  ${tz}  4  
    ${resp}=    Get All Schedule Slots By Date Location and Service  ${account_id1}  ${DAY4}  ${lid1}  ${ser_id}
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
    Set Test Variable   ${slot2}   ${slots[${j}]}
    
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Customer Take Appointment   ${account_id1}  ${ser_id}  ${schedule_id}  ${DAY4}  ${cnote}   ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid6}  ${apptid[0]}

    ${resp}=  Add Appointment Rating  ${account_id1}  ${apptid6}   ${rating1}   ${comment1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Rating   service-eq=${ser_id}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['stars']}                      ${rating1}
    Should Be Equal As Strings  ${resp.json()[0]['service']['id']}              ${ser_id}
    Should Be Equal As Strings  ${resp.json()[1]['stars']}                      ${rating}
    Should Be Equal As Strings  ${resp.json()[1]['service']['id']}              ${ser_id}
    Should Be Equal As Strings  ${resp.json()[0]['uuid']}                       ${apptid6}
    Should Be Equal As Strings  ${resp.json()[1]['uuid']}                       ${apptid4} 

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  2

JD-TC-GetAppointmentRating-5

    [Documentation]  Get Appointment Rating filter by appointment id.

    ${resp}=    ProviderConsumer Login with token   ${PCPHONENO1}    ${account_id1}  ${token1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Appointment Rating   uId-eq=${apptid4}
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1 
    Should Be Equal As Strings  ${resp.json()[0]['stars']}                      ${rating}
    Should Be Equal As Strings  ${resp.json()[0]['feedback'][0]['comments']}    ${comment1}
    Should Be Equal As Strings  ${resp.json()[0]['uuid']}                       ${apptid4}
    
JD-TC-GetAppointmentRating-6

    [Documentation]  Get Appointment Rating filter by rating and account id.

    ${resp}=    ProviderConsumer Login with token   ${PCPHONENO1}    ${account_id1}  ${token1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Appointment Rating    rating-eq=${rating}  account-eq=${account_id1}
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${len}=  Get Length  ${resp.json()}
    # Should Be Equal As Integers  ${len}  2

    Should Be Equal As Strings  ${resp.json()[0]['stars']}                      ${rating}
    Should Be Equal As Strings  ${resp.json()[0]['feedback'][0]['comments']}    ${comment1}
    Should Be Equal As Strings  ${resp.json()[0]['uuid']}                       ${apptid5}
    Should Be Equal As Strings  ${resp.json()[1]['uuid']}                       ${apptid4}

JD-TC-GetAppointmentRating-7

    [Documentation]  Get Appointment Rating filter by rating and service id.

    ${resp}=    ProviderConsumer Login with token   ${PCPHONENO}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Appointment Rating    rating-eq=${rating1}  service-eq=${s_id}
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1 

    Should Be Equal As Strings  ${resp.json()[0]['stars']}                      ${rating1}
    Should Be Equal As Strings  ${resp.json()[0]['feedback'][0]['comments']}    ${comment1}
    Should Be Equal As Strings  ${resp.json()[0]['uuid']}                       ${apptid1}
    
JD-TC-GetAppointmentRating-8

    [Documentation]  Get Appointment Rating filter by past date. 

    # ${resp}=  Encrypted Provider Login  ${PUSERNAME101}  ${PASSWORD}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Location By Id   ${lid1} 
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${tz}  ${resp.json()['timezone']}
    
    # ${resp}=  ProviderLogout 
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderConsumer Login with token   ${PCPHONENO}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${DAY2}=  db.subtract_timezone_date  ${tz}   2
    ${resp}=  Get Appointment Rating    createdDate-eq=${DAY2}
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  	[]

JD-TC-GetAppointmentRating-UH1

    [Documentation]  Trying to get Appointments Rating With out login by Consumer

    ${resp}=  Get Appointment Rating    account-eq=${account_id1}
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  419  
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}" 

JD-TC-GetAppointmentRating-UH2

    [Documentation]  Get Appointment Rating filter by invalid rating.

    ${resp}=    ProviderConsumer Login with token   ${PCPHONENO}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Appointment Rating    rating-eq=-1
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  	[]

*** Comments ***

JD-TC-GetAppointmentRating-UH1

    [Documentation]  Get Appointment Rating filter by another providerid 

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Appointment Rating    account-eq=${account_id1}
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  	[]

JD-TC-GetAppointmentRating-5

    [Documentation]  Get Appointment Rating filter by created date.

    ${resp}=  Consumer Login  ${CUSERNAME13}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Appointment Rating    createdDate-eq=${DAY1}
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  2
    Should Be Equal As Strings  ${resp.json()[0]['stars']}                      ${rating1}
    Should Be Equal As Strings  ${resp.json()[0]['service']['id']}              ${s_id3}
    Should Be Equal As Strings  ${resp.json()[1]['stars']}                      ${rating1}
    Should Be Equal As Strings  ${resp.json()[1]['service']['id']}              ${s_id}
    Should Be Equal As Strings  ${resp.json()[0]['uuid']}                       ${apptid3}
    Should Be Equal As Strings  ${resp.json()[1]['uuid']}                       ${apptid1} 

