*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Appointment  
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library         /ebs/TDD/CustomKeywords.py
Library           random
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
# Variables         /ebs/TDD/varfiles/consumermail.py

*** Variables ***

${SERVICE1}  sampleservice11 
${SERVICE2}  sampleservice22
${self}     0
@{service_names}
${digits}       0123456789
@{provider_list}
@{dom_list}
@{multiloc_providers}

*** Test Cases ***

JD-TC-Get consumer Appt Bill Details-1

    [Documentation]  Get consumer Appt Bill Details .

    ${pid}=  get_acc_id  ${PUSERNAME249}
   
    ${resp}=  Encrypted Provider Login  ${PUSERNAME249}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Update Appointment Status   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    # clear_location_n_service  ${PUSERNAME249}
    clear_customer   ${PUSERNAME249}

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']} 

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${lid}=  Create Sample Location
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    ${s_id}=  Create Sample Service  ${SERVICE1}   maxBookingsAllowed=10

    
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

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    
    #............provider consumer creation..........

    ${PH_Number}=  FakerLibrary.Numerify  %#####
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${PCPHONENO}  555${PH_Number}

    ${fname}=  generate_firstname
    Set Suite Variable  ${fname}
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname}
   
    ${resp}=  AddCustomer  ${PCPHONENO}    firstName=${fname}   lastName=${lastname}  countryCode=${countryCodes[1]}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${PCPHONENO}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()[0]['id']}
    Set Test Variable  ${jaldeeConsumer}  ${resp.json()[0]['jaldeeConsumer']}
 
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${amountDue}   ${resp.json()['amountDue']}
    
    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

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
    Set Test Variable   ${slot2}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Customer Take Appointment   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid2}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get consumer Appt Bill Details   ${apptid1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}   ${apptid1}
    Should Be Equal As Strings  ${resp.json()['customer']['userProfile']['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['customer']['userProfile']['primaryMobileNo']}   ${PCPHONENO}
    Should Be Equal As Strings  ${resp.json()['customer']['accountId']}   ${account_id}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['lastName']}   ${lastname}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['phoneNo']}   ${PCPHONENO}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['jaldeeConsumer']}   ${jaldeeConsumer}
    Should Be Equal As Strings  ${resp.json()['netTotal']}   ${amountDue}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}   ${amountDue}
    Should Be Equal As Strings  ${resp.json()['service'][0]['totalPrice']}   ${amountDue}
    Should Be Equal As Strings  ${resp.json()['billStatus']}   ${billStatus[0]}
    Should Be Equal As Strings  ${resp.json()['billFor']['firstName']}   ${fname}
   
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    

JD-TC-Get consumer Appt Bill Details-2

    [Documentation]  Get provider's appointments for service with prepayment but prepayment not done by consumer and get that bill details
    
    # clear_location_n_service  ${PUSERNAME234}
    clear_customer   ${PUSERNAME234}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME234}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${p_id}  ${decrypted_data['id']}
    Set Test Variable  ${firstname}   ${decrypted_data['firstName']}
    Set Test Variable  ${lastname}   ${decrypted_data['lastName']}

    Set Test Variable  ${email_id}  ${PUSERNAME234}.${P_EMAIL}.${test_mail}

    ${resp}=  Update Email   ${pid}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id1}  ${resp.json()['id']} 

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Update Appointment Status   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

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
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    ${desc}=   FakerLibrary.sentence
    # ${min_pre}=   Random Int   min=1   max=50
    # ${servicecharge}=   Random Int  min=100  max=500
    # ${srv_duration}=   Random Int   min=10   max=20
    # ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${srv_duration}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${min_pre}  ${servicecharge}  ${bool[1]}  ${bool[0]}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}   200
    # ${s_id}=  Create Sample Service   ${SERVICE1}   isPrePayment=${bool[1]}  PrePaymentAmount=${min_pre}
    # Set Test Variable  ${s_id}  ${resp.json()}

    ${service_duration}=   Random Int   min=5   max=10
    Set Suite Variable    ${service_duration}
    ${P1SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${P1SERVICE1}
    Set Suite Variable  ${P1SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}  ${service_duration}  ${bool[0]}  ${servicecharge}  ${bool[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id}  ${resp.json()}  

    ${resp}=  Get Appointment Schedules
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['onlinePayment']}==${bool[0]}
        ${resp}=    Enable Disable Online Payment   ${toggle[0]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
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

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    #............provider consumer creation..........

    ${PH_Number}=  FakerLibrary.Numerify  %#####
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${PCPHONENO1}  555${PH_Number}

    ${fname1}=  generate_firstname
    Set Suite Variable   ${fname1}
    ${lname1}=  FakerLibrary.last_name
    Set Suite Variable   ${lname1}
    Set Suite Variable  ${pc_emailid1}  ${fname}${C_Email}.${test_mail}
  
    ${resp}=  AddCustomer  ${PCPHONENO1}    firstName=${fname1}   lastName=${lname1}  countryCode=${countryCodes[1]}  email=${pc_emailid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${PCPHONENO1}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()[0]['id']}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

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

    ${resp}=    Get All Schedule Slots By Date Location and Service  ${account_id1}  ${DAY1}  ${lid}  ${s_id}
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
    ${resp}=   Customer Take Appointment   ${account_id1}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname1}

    ${resp}=   Get consumer Appointment By Id   ${account_id1}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME234}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${amountDue}   ${resp.json()['amountDue']}

    ${resp}=    Provider Logout
    Should Be Equal As Strings  ${resp.status_code}    200


    ${resp}=    ProviderConsumer Login with token   ${PCPHONENO1}    ${account_id1}  ${token1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200


    ${resp}=  Get consumer Appt Bill Details   ${apptid1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}   ${apptid1}
    Should Be Equal As Strings  ${resp.json()['customer']['userProfile']['firstName']}   ${fname1}
    Should Be Equal As Strings  ${resp.json()['customer']['userProfile']['primaryMobileNo']}   ${PCPHONENO1}
    Should Be Equal As Strings  ${resp.json()['customer']['accountId']}   ${account_id1}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['firstName']}   ${fname1}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['phoneNo']}   ${PCPHONENO1}
    Should Be Equal As Strings  ${resp.json()['netTotal']}   ${amountDue}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}   ${amountDue}
    Should Be Equal As Strings  ${resp.json()['service'][0]['totalPrice']}   ${amountDue}
    Should Be Equal As Strings  ${resp.json()['billStatus']}   ${billStatus[0]}
    Should Be Equal As Strings  ${resp.json()['billFor']['firstName']}   ${fname1}
   



JD-TC-Get consumer Appt Bill Details-3

    [Documentation]  Get consumer Appt Bill Details  after prepayment
    
    # clear_location_n_service  ${PUSERNAME234}
   
    ${resp}=  Encrypted Provider Login  ${PUSERNAME234}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

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
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    ${servicecharge}=  Convert To Number  ${servicecharge}  1 
    ${srv_duration}=   Random Int   min=10   max=20
    # ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${srv_duration}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${min_pre}  ${servicecharge}  ${bool[1]}  ${bool[0]}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}   200
    # Set Test Variable  ${s_id}  ${resp.json()}

    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${srv_duration}  ${bool[1]}  ${servicecharge}  ${bool[1]}  minPrePaymentAmount=${min_pre}  taxable=${bool[0]}  prePaymentType=${advancepaymenttype[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id}  ${resp.json()}

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

    ${resp}=  Auto Invoice Generation For Service   ${s_id}    ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedules
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
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

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=    ProviderConsumer Login with token   ${PCPHONENO1}    ${account_id1}  ${token1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get All Schedule Slots By Date Location and Service  ${account_id1}  ${DAY1}  ${lid}  ${s_id}
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
    ${resp}=   Customer Take Appointment   ${account_id1}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname1}

    ${resp}=   Get consumer Appointment By Id   ${account_id1}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${resp}=  Make payment Consumer Mock  ${account_id1}  ${min_pre}  ${purpose[0]}  ${apptid1}  ${s_id}  ${bool[0]}   ${bool[1]}  ${None}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${merchantid}   ${resp.json()['merchantId']}  
    Set Test Variable   ${payref}   ${resp.json()['paymentRefId']}

    ${resp}=  ConsumerLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login   ${PUSERNAME234}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderConsumer Login with token   ${PCPHONENO1}    ${account_id1}  ${token1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get consumer Appt Bill Details   ${apptid1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Payment Details  paymentRefId-eq=${payref}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Get Payment Details By UUId  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${amountDue}=  Evaluate  ${servicecharge} - ${min_pre} 


    ${resp}=  Get consumer Appt Bill Details   ${apptid1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}   ${apptid1}
    Should Be Equal As Strings  ${resp.json()['customer']['userProfile']['firstName']}   ${fname1}
    Should Be Equal As Strings  ${resp.json()['customer']['userProfile']['primaryMobileNo']}   ${PCPHONENO1}
    Should Be Equal As Strings  ${resp.json()['customer']['accountId']}   ${account_id1}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['firstName']}   ${fname1}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['lastName']}   ${lname1}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['phoneNo']}   ${PCPHONENO1}
    Should Be Equal As Strings  ${resp.json()['netTotal']}   ${servicecharge}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}   ${servicecharge}
    Should Be Equal As Strings  ${resp.json()['service'][0]['totalPrice']}   ${servicecharge}
    Should Be Equal As Strings  ${resp.json()['billStatus']}   ${billStatus[0]}
    Should Be Equal As Strings  ${resp.json()['billFor']['firstName']}   ${fname1}
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}   ${paymentStatus[1]}
    Should Be Equal As Strings  ${resp.json()['totalAmountPaid']}   ${min_pre}
    Should Be Equal As Strings  ${resp.json()['amountDue']}   ${amountDue}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    



    
JD-TC-Get consumer Appt Bill Details-4

    [Documentation]  Get provider's appointments today with appointment status confirmed
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME249}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Update Appointment Status   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    # clear_location_n_service  ${PUSERNAME249}
    
    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
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
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    ${s_id}=  Create Sample Service  ${SERVICE1}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
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

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${PCPHONENO}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()[0]['id']}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    #............provider consumer creation..........

    ${PH_Number}=  FakerLibrary.Numerify  %#####
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${PCPHONENO2}  555${PH_Number}

    ${fname2}=  generate_firstname
    Set Suite Variable  ${fname2}
    ${lname2}=  FakerLibrary.last_name
    Set Suite Variable  ${lname2}
    
    ${resp}=  AddCustomer  ${PCPHONENO2}    firstName=${fname2}   lastName=${lname2}  countryCode=${countryCodes[1]} 
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${PCPHONENO2}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()[0]['id']}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${PCPHONENO2}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${PCPHONENO2}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token2}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${PCPHONENO2}    ${account_id}  ${token2} 
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
    Set Test Variable   ${slot2}   ${slots[${j}]}
    
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Customer Take Appointment   ${account_id}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid2}=  Get From Dictionary  ${resp.json()}  ${fname2}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME249}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${amountDue}   ${resp.json()['amountDue']}

    ${resp}=    Provider Logout
    Should Be Equal As Strings  ${resp.status_code}    200



    ${resp}=    ProviderConsumer Login with token   ${PCPHONENO2}    ${account_id}  ${token2} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200


    ${resp}=  Get consumer Appt Bill Details   ${apptid2}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}   ${apptid2}
    Should Be Equal As Strings  ${resp.json()['customer']['userProfile']['firstName']}   ${fname2}
    Should Be Equal As Strings  ${resp.json()['customer']['userProfile']['primaryMobileNo']}   ${PCPHONENO2}
    Should Be Equal As Strings  ${resp.json()['customer']['accountId']}   ${account_id}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['firstName']}   ${fname2}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['lastName']}   ${lname2}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['phoneNo']}   ${PCPHONENO2}
    Should Be Equal As Strings  ${resp.json()['netTotal']}   ${amountDue}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}   ${amountDue}
    Should Be Equal As Strings  ${resp.json()['service'][0]['totalPrice']}   ${amountDue}
    Should Be Equal As Strings  ${resp.json()['billStatus']}   ${billStatus[0]}
    Should Be Equal As Strings  ${resp.json()['billFor']['firstName']}   ${fname2}
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}   ${paymentStatus[0]}
    Should Be Equal As Strings  ${resp.json()['totalAmountPaid']}   0.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}   ${amountDue}

    
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    


JD-TC-Get consumer Appt Bill Details-5

    [Documentation]  Get provider's appointments today with appointment status cancelled and Get consumer Appt Bill Details
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME249}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Update Appointment Status   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END
 


    # clear_location_n_service  ${PUSERNAME249}
    
    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${lid}=  Create Sample Location
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    ${s_id}=  Create Sample Service  ${SERVICE1}

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

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${PCPHONENO}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}   ${resp.json()[0]['id']}

    ${resp}=  GetCustomer  phoneNo-eq=${PCPHONENO2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}   ${resp.json()[0]['id']}
    
    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Suite Variable  ${apptid3}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${apptfor2}=  Create Dictionary  id=${cid2}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor2}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid2}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid2}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${reason}=  Random Element  ${cancelReason}
    ${resp}=     Appointment Action    ${apptStatus[4]}   ${apptid3}   cancelReason=${reason}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${apptid3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${amountDue}   ${resp.json()['fullAmount']}

    ${resp}=  Get Appointments Today
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['uid']}   ${apptid3}
    Should Be Equal As Strings  ${resp.json()[1]['uid']}   ${apptid2}

    ${resp}=  Get Appointments Today   apptStatus-eq=${apptStatus[4]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['uid']}   ${apptid3}

    ${resp}=    Provider Logout
    Should Be Equal As Strings  ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${PCPHONENO}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get consumer Appt Bill Details   ${apptid3}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}   ${apptid3}
    Should Be Equal As Strings  ${resp.json()['customer']['userProfile']['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['customer']['userProfile']['primaryMobileNo']}   ${PCPHONENO}
    Should Be Equal As Strings  ${resp.json()['customer']['accountId']}   ${account_id}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['lastName']}   ${lastname}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['phoneNo']}   ${PCPHONENO}
    Should Be Equal As Strings  ${resp.json()['netTotal']}   ${amountDue}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}   ${amountDue}
    Should Be Equal As Strings  ${resp.json()['service'][0]['totalPrice']}   0.0
    Should Be Equal As Strings  ${resp.json()['billStatus']}   ${billStatus[0]}
    Should Be Equal As Strings  ${resp.json()['billFor']['firstName']}   ${fname}

JD-TC-Get consumer Appt Bill Details-6

    [Documentation]  Get consumer Appt Bill Details using provider login
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME249}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get consumer Appt Bill Details   ${apptid3}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}   ${apptid3}
    Should Be Equal As Strings  ${resp.json()['customer']['userProfile']['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['customer']['userProfile']['primaryMobileNo']}   ${PCPHONENO}
    Should Be Equal As Strings  ${resp.json()['customer']['accountId']}   ${account_id}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['lastName']}   ${lastname}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['phoneNo']}   ${PCPHONENO}


JD-TC-Get consumer Appt Bill Details-UH2

    [Documentation]  Get consumer Appt Bill Details without login
    
    ${resp}=  Get consumer Appt Bill Details   ${apptid3}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings    ${resp.json()}   ${SESSION_EXPIRED}



    


