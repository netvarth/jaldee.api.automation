*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Appointment
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 

*** Variables ***

${SERVICE1}  manicure 
${SERVICE2}  pedicure
${self}     0
${digits}       0123456789
@{dom_list}
@{provider_list}
@{multiloc_providers}
@{multiloc_billable_providers}

*** Test Cases ***

JD-TC-GetFollowUpDetails-1

    [Documentation]     Get GetFollowUp Details of appointment
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME144}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
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
        ${resp}=   Update Appointment Status   ${VarStatus} 
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    clear_service   ${PUSERNAME144}
    clear_location  ${PUSERNAME144}
    clear_customer   ${PUSERNAME144}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=   Get jaldeeIntegration Settings
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # IF  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}
    #     ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
    #     Log   ${resp.json()}
    #     Should Be Equal As Strings  ${resp.status_code}  200
    # END

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid}  ${resp.json()['id']} 
    Set Suite Variable  ${businessName}     ${resp.json()['businessName']}

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${lid}=  Create Sample Location  
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    clear_appt_schedule   ${PUSERNAME144}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable      ${s_id}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${PH_Number}    Random Number 	       digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable    ${consumerPhone}  555${PH_Number}
    Append To File  ${EXECDIR}/data/TDD_Logs/proconnum.txt  ${SUITE NAME} - ${TEST NAME} - ${consumerPhone}${\n}
    ${consumerFirstName}=   FakerLibrary.first_name
    Set Suite Variable      ${consumerFirstName}
    ${consumerLastName}=    FakerLibrary.last_name  
    Set Suite Variable      ${consumerLastName}
    ${dob}=    FakerLibrary.Date
    Set Suite Variable      ${dob}
    ${permanentAddress1}=  FakerLibrary.address
    Set Suite Variable      ${permanentAddress1}
    ${gender}=  Random Element    ${Genderlist}
    Set Suite Variable      ${gender}
    Set Suite Variable  ${consumerEmail}  ${C_Email}${consumerPhone}${consumerFirstName}.${test_mail}

    ${resp}=  AddCustomer  ${consumerPhone}  firstName=${consumerFirstName}   lastName=${consumerLastName}  address=${permanentAddress1}   gender=${gender}  dob=${dob}  email=${consumerEmail}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${consumerPhone}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable  ${cid}   ${resp.json()[0]['id']}
    Set Suite Variable  ${jcid}  ${resp.json()[0]['jaldeeConsumerDetails']['id']}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Suite Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${ageyrs}  ${agemonths}=  db.calculate_age_years_months     ${dob}
    Set Suite Variable  ${ageyrs}
    Set Suite Variable  ${agemonths}

    ${resp}=    GetFollowUpDetailsofAppmt  ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerAccount']['businessName']}                   ${businessName}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}              ${consumerFirstName}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}               ${consumerLastName}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['firstName']}                     ${consumerFirstName}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['lastName']}                      ${consumerLastName}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['address']}                       ${permanentAddress1}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['email']}                         ${consumerEmail}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['gender']}                        ${gender}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['dob']}                           ${dob}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['phoneNo']}                       ${consumerPhone}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['jaldeeConsumer']}                ${jcid}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['whatsAppNum']['number']}         ${consumerPhone}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['telegramNum']['number']}         ${consumerPhone}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['jaldeeConsumerDetails']['id']}   ${jcid}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['age']['year']}                   ${ageyrs}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['age']['month']}                  ${agemonths}
    Should Be Equal As Strings  ${resp.json()['service']['name']}                                   ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}                          ${consumerFirstName}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}                           ${consumerLastName}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['address']}                            ${permanentAddress1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['dob']}                                ${dob}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['gender']}                             ${gender}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['age']}                                ${ageyrs}

JD-TC-GetFollowUpDetails-2

    [Documentation]     Get GetFollowUp Details of appointment -  where appmt is Cancelled

    ${resp}=  Encrypted Provider Login  ${PUSERNAME144}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${reason}=  Random Element  ${cancelReason}
    ${resp}=    Appointment Action   ${apptStatus[4]}  ${apptid1}  cancelReason=${reason}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    GetFollowUpDetailsofAppmt  ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerAccount']['businessName']}                   ${businessName}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}              ${consumerFirstName}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}               ${consumerLastName}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['firstName']}                     ${consumerFirstName}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['lastName']}                      ${consumerLastName}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['address']}                       ${permanentAddress1}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['email']}                         ${consumerEmail}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['gender']}                        ${gender}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['dob']}                           ${dob}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['phoneNo']}                       ${consumerPhone}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['jaldeeConsumer']}                ${jcid}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['whatsAppNum']['number']}         ${consumerPhone}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['telegramNum']['number']}         ${consumerPhone}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['jaldeeConsumerDetails']['id']}   ${jcid}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['age']['year']}                   ${ageyrs}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['age']['month']}                  ${agemonths}
    Should Be Equal As Strings  ${resp.json()['service']['name']}                                   ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}                          ${consumerFirstName}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}                           ${consumerLastName}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['address']}                            ${permanentAddress1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['dob']}                                ${dob}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['gender']}                             ${gender}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['age']}                                ${ageyrs}

JD-TC-GetFollowUpDetails-3

    [Documentation]     Get GetFollowUp Details of appointment -  where appmt is Rejected

    ${resp}=  Encrypted Provider Login  ${PUSERNAME144}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Appointment Action   ${apptStatus[1]}   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200        

    ${reason}=  Random Element  ${cancelReason}
    ${resp}=    Appointment Action  ${apptStatus[5]}  ${apptid1}  rejectReason=${reason} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    GetFollowUpDetailsofAppmt  ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerAccount']['businessName']}                   ${businessName}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}              ${consumerFirstName}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}               ${consumerLastName}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['firstName']}                     ${consumerFirstName}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['lastName']}                      ${consumerLastName}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['address']}                       ${permanentAddress1}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['email']}                         ${consumerEmail}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['gender']}                        ${gender}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['dob']}                           ${dob}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['phoneNo']}                       ${consumerPhone}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['jaldeeConsumer']}                ${jcid}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['whatsAppNum']['number']}         ${consumerPhone}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['telegramNum']['number']}         ${consumerPhone}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['jaldeeConsumerDetails']['id']}   ${jcid}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['age']['year']}                   ${ageyrs}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['age']['month']}                  ${agemonths}
    Should Be Equal As Strings  ${resp.json()['service']['name']}                                   ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}                          ${consumerFirstName}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}                           ${consumerLastName}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['address']}                            ${permanentAddress1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['dob']}                                ${dob}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['gender']}                             ${gender}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['age']}                                ${ageyrs}

JD-TC-GetFollowUpDetails-4

    [Documentation]     Get GetFollowUp Details of appointment -  where appmt is blocked 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME144}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Appointment Action   ${apptStatus[1]}   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${apptfor1}=  Create Dictionary   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${resp}=  Block Appointment For Consumer  ${s_id}  ${sch_id}  ${DAY1}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    GetFollowUpDetailsofAppmt  ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerAccount']['businessName']}                   ${businessName}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}              ${consumerFirstName}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}               ${consumerLastName}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['firstName']}                     ${consumerFirstName}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['lastName']}                      ${consumerLastName}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['address']}                       ${permanentAddress1}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['email']}                         ${consumerEmail}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['gender']}                        ${gender}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['dob']}                           ${dob}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['phoneNo']}                       ${consumerPhone}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['jaldeeConsumer']}                ${jcid}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['whatsAppNum']['number']}         ${consumerPhone}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['telegramNum']['number']}         ${consumerPhone}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['jaldeeConsumerDetails']['id']}   ${jcid}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['age']['year']}                   ${ageyrs}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['age']['month']}                  ${agemonths}
    Should Be Equal As Strings  ${resp.json()['service']['name']}                                   ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}                          ${consumerFirstName}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}                           ${consumerLastName}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['address']}                            ${permanentAddress1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['dob']}                                ${dob}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['gender']}                             ${gender}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['age']}                                ${ageyrs}


JD-TC-GetFollowUpDetails-UH1

    [Documentation]     Get GetFollowUp Details of appointment where appointment id is invalid
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME144}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${inv}=     FakerLibrary.Random Int 

    ${resp}=    GetFollowUpDetailsofAppmt  ${inv}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  404
    Should Be Equal As Strings  ${resp.json()}       ${INVALID_APPOINTMENT}

JD-TC-GetFollowUpDetails-UH2

    [Documentation]     Get GetFollowUp Details - without login

    ${resp}=    GetFollowUpDetailsofAppmt  ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.json()}       ${SESSION_EXPIRED}

JD-TC-GetFollowUpDetails-UH3

    [Documentation]     Get GetFollowUp Details - provider consumer login
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME145}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']} 

    #............provider consumer creation..........

    ${PH_Number}=  FakerLibrary.Numerify  %#####
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${PCPHONENO}  555${PH_Number}

    ${fname}=  FakerLibrary.first_name
    Set Suite Variable  ${fname}
    ${lastname}=  FakerLibrary.last_name
   
    ${resp}=  AddCustomer  ${PCPHONENO}    firstName=${fname}   lastName=${lastname}  countryCode=${countryCodes[1]} 
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

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

    ${resp}=    GetFollowUpDetailsofAppmt  ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  ${resp.json()}       ${NoAccess}

JD-TC-GetFollowUpDetails-UH4

    [Documentation]     Get GetFollowUp Details - with another provider login
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME145}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    GetFollowUpDetailsofAppmt  ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  ${resp.json()}       ${NO_PERMISSION}
