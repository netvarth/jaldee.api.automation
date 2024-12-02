*** Settings ***
Suite Teardown    Run Keywords   Delete All Sessions  resetsystem_time
Test Teardown     Run Keywords   Delete All Sessions  resetsystem_time
Force Tags        Appointment
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/CustomKeywords.py
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/hl_providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

*** Variables ***

${self}   0
@{service_names}

*** Test Cases ***   

JD-TC-GetAppointmentHistory-1

    [Documentation]   Get Appointment History  and History count

    ${resp}=  Encrypted Provider Login  ${PUSERNAME342}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${accId}=  get_acc_id  ${PUSERNAME342}
    Set Suite Variable  ${accId}
    
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}   
    ${s_id1}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable  ${s_id1}
    ${SERVICE2}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE2}   
    ${s_id2}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable  ${s_id2}
    ${SERVICE3}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE3}   
    ${s_id3}=  Create Sample Service  ${SERVICE3}
    Set Suite Variable  ${s_id3}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid1}=  Create Sample Location
        Set Suite Variable   ${lid1}
        ${resp}=   Get Location ById  ${lid1}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Suite Variable  ${lid1}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    ${today}=   db.get_date_by_timezone  ${tz}
    
    ${cur_date}=   change_system_date   -5
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 

    ${DAY2}=  db.add_timezone_date  ${tz}  2     
    Set Suite Variable  ${DAY2}   
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list} 
    ${sTime1}=  add_timezone_time  ${tz}  2  00  
    Set Suite Variable   ${sTime1}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    Set Suite Variable  ${delta}
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    Set Suite Variable   ${eTime1}
    ${schedule_name}=  FakerLibrary.bs
    Set Suite Variable  ${schedule_name}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
    ${bool1}=  Random Element  ${bool}

    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid1}  ${duration}  ${bool1}   ${s_id1}  ${s_id2}  ${s_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${fname1}=  generate_firstname
    ${lname1}=  FakerLibrary.last_name
    ${resp}=  AddCustomer  ${CUSERNAME16}   firstName=${fname1}   lastName=${lname1}  countryCode=${countryCodes[1]}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${cid}  ${resp.json()}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${CUSERNAME16}    ${accId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login    ${CUSERNAME16}   ${OtpPurpose['Authentication']}   JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME16}    ${accId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable   ${cname1}   ${resp.json()['firstName']}
    Set Suite Variable   ${cname2}   ${resp.json()['lastName']}
    Set Suite Variable   ${username}   ${resp.json()['userName']}
    Set Suite Variable   ${primaryPhoneNumber}   ${resp.json()['primaryPhoneNumber']}

    ${resp}=    Get All Schedule Slots By Date Location and Service  ${accId}  ${DAY1}  ${lid1}  ${s_id1}
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
    Set Suite Variable   ${apptfor}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${accId}  ${s_id1}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${cur_date}=   change_system_date   5
    ${resp}=  db.get_date_by_timezone  ${tz}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME342}  ${PASSWORD} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Appointments History
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()[0]['uid']}  h_${apptid1}

JD-TC-GetAppointmentHistory-2

    [Documentation]    Get provider's appointments history with appointment status conform

    ${resp}=  Encrypted Provider Login  ${PUSERNAME342}  ${PASSWORD} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointments History  apptStatus-eq=${apptStatus[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()[0]['uid']}  h_${apptid1}

JD-TC-GetAppointmentHistory-3

    [Documentation]    Get provider's appointments history for service  ${SERVICE1} 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME342}  ${PASSWORD} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointments History  service-eq=${s_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings   ${resp.json()[0]['uid']}  h_${apptid1}
   
JD-TC-GetAppointmentHistory-4
    
    [Documentation]  Get provider's appointments history for consumers with firstname  ${cname1}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME342}  ${PASSWORD} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointments History  firstName-eq=${cname1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings   ${resp.json()[0]['uid']}  h_${apptid1}

JD-TC-GetAppointmentHistory-5

    [Documentation]   Get provider's appointments history for consumers with lastname  ${cname2}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME342}  ${PASSWORD} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointments History  lastName-eq=${cname2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings   ${resp.json()[0]['uid']}  h_${apptid1}
    
JD-TC-GetAppointmentHistory-6

    [Documentation]    Get provider's appointments history in schedule ${sch_id1}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME342}  ${PASSWORD} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointments History  schedule-eq=${sch_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings   ${resp.json()[0]['uid']}  h_${apptid1}
    
JD-TC-GetAppointmentHistory-7

    [Documentation]   Get provider's appointments history   appointment taken by consumer(apptBy)

    ${resp}=  Encrypted Provider Login  ${PUSERNAME342}  ${PASSWORD} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointments History   apptBy-eq=CONSUMER
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings   ${resp.json()[0]['uid']}  h_${apptid1}

JD-TC-GetAppointmentHistory-8

    [Documentation]   Get provider's appointments history   where appointment slot is ${slot1} (apptTime)

    ${resp}=  Encrypted Provider Login  ${PUSERNAME342}  ${PASSWORD} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointments History  apptTime-eq=${slot1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings   ${resp.json()[0]['uid']}  h_${apptid1}
    
JD-TC-GetAppointmentHistory-9

    [Documentation]   Get provider's appointments history   where paymentStatus is NotPaid

    ${resp}=  Encrypted Provider Login  ${PUSERNAME342}  ${PASSWORD} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointments History  paymentStatus-eq=${paymentStatus[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings   ${resp.json()[0]['uid']}  h_${apptid1}

JD-TC-GetAppointmentHistory-10

    [Documentation]   Get provider's appointments history   where location is  ${lid1}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME342}  ${PASSWORD} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointments History  location-eq=${lid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings   ${resp.json()[0]['uid']}  h_${apptid1}
  
JD-TC-GetAppointmentHistory-11

    [Documentation]   Check appointment history count

    ${cur_date}=   change_system_date   -5

    ${resp}=  Encrypted Provider Login  ${PUSERNAME342}  ${PASSWORD} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fname1}=  generate_firstname
    ${lname1}=  FakerLibrary.last_name
    ${resp}=  AddCustomer  ${CUSERNAME11}   firstName=${fname1}   lastName=${lname1}  countryCode=${countryCodes[1]}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${cid}  ${resp.json()}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${CUSERNAME11}    ${accId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login    ${CUSERNAME11}   ${OtpPurpose['Authentication']}   JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME11}    ${accId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable   ${cname1}   ${resp.json()['firstName']}
    Set Suite Variable   ${cname2}   ${resp.json()['lastName']}
    Set Suite Variable   ${username}   ${resp.json()['userName']}
    Set Suite Variable   ${primaryPhoneNumber}   ${resp.json()['primaryPhoneNumber']}

    ${resp}=    Get All Schedule Slots By Date Location and Service  ${accId}  ${DAY1}  ${lid1}  ${s_id2}
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
    Set Suite Variable   ${apptfor}

    ${cid}=  get_id  ${CUSERNAME11}   
    Set Suite Variable   ${cid}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${accId}  ${s_id2}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${cur_date}=   change_system_date   5
    ${resp}=  db.get_date_by_timezone  ${tz}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME342}  ${PASSWORD} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment History Count
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}   2 

    ${resp}=  Get Appointment History Count   apptStatus-eq=${apptStatus[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}   2 

JD-TC-GetAppointmentHistory-12

    [Documentation]  Get provider's appointments history with appointment status cancelled

    ${cur_date}=   change_system_date   -5
    ${resp}=  db.get_date_by_timezone  ${tz}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME342}  ${PASSWORD} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fname1}=  generate_firstname
    ${lname1}=  FakerLibrary.last_name
    ${resp}=  AddCustomer  ${CUSERNAME8}   firstName=${fname1}   lastName=${lname1}  countryCode=${countryCodes[1]}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${cid}  ${resp.json()}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${CUSERNAME8}    ${accId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login    ${CUSERNAME8}   ${OtpPurpose['Authentication']}   JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME8}    ${accId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable   ${cname1}   ${resp.json()['firstName']}
    Set Suite Variable   ${cname2}   ${resp.json()['lastName']}
    Set Suite Variable   ${username}   ${resp.json()['userName']}
    Set Suite Variable   ${primaryPhoneNumber}   ${resp.json()['primaryPhoneNumber']}

    ${resp}=    Get All Schedule Slots By Date Location and Service  ${accId}  ${DAY1}  ${lid1}  ${s_id2}
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
    Set Suite Variable   ${apptfor}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${accId}  ${s_id3}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid2}  ${apptid[0]}

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME342}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${reason}=  Random Element  ${cancelReason}
    ${resp}=     Appointment Action   ${apptStatus[4]}   ${apptid2}  cancelReason=${reason}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${cur_date}=   change_system_date   5
    ${resp}=  db.get_date_by_timezone  ${tz}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME342}  ${PASSWORD} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=   Get Appointments History  apptStatus-eq=${apptStatus[4]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Appointment History Count   apptStatus-eq=${apptStatus[4]}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetAppointmentHistory-13

    [Documentation]   Get provider's appointments history with appointment status Rejected

    ${cur_date}=   change_system_date   -5
    ${resp}=  db.get_date_by_timezone  ${tz}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME342}  ${PASSWORD} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fname1}=  generate_firstname
    ${lname1}=  FakerLibrary.last_name
    ${resp}=  AddCustomer  ${CUSERNAME7}   firstName=${fname1}   lastName=${lname1}  countryCode=${countryCodes[1]}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${cid}  ${resp.json()}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${CUSERNAME7}    ${accId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login    ${CUSERNAME7}   ${OtpPurpose['Authentication']}   JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME7}    ${accId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable   ${cname1}   ${resp.json()['firstName']}
    Set Suite Variable   ${cname2}   ${resp.json()['lastName']}
    Set Suite Variable   ${username}   ${resp.json()['userName']}
    Set Suite Variable   ${primaryPhoneNumber}   ${resp.json()['primaryPhoneNumber']}

    ${resp}=    Get All Schedule Slots By Date Location and Service  ${accId}  ${DAY1}  ${lid1}  ${s_id3}
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
    Set Suite Variable   ${apptfor}

    ${cid}=  get_id  ${CUSERNAME7}   
    Set Suite Variable   ${cid}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${accId}  ${s_id3}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid3}  ${apptid[0]}

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME342}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment By Id   ${apptid3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${reason}=  Random Element  ${cancelReason}
    ${resp}=     Appointment Action   ${apptStatus[5]}   ${apptid3}  rejectReason=${reason}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${apptid3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${cur_date}=   change_system_date   5
    ${resp}=  db.get_date_by_timezone  ${tz}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME342}  ${PASSWORD} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Status   ${apptid3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointments History  apptStatus-eq=${apptStatus[5]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Appointment History Count   apptStatus-eq=${apptStatus[5]}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetAppointmentHistory-UH1

    [Documentation]  Consumer try to get Appointment History 

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME7}    ${accId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Appointments History 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-GetAppointmentHistory-UH2

    [Documentation]   Get Appointment History without login
    ${resp}=   Get Appointments History
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}"
