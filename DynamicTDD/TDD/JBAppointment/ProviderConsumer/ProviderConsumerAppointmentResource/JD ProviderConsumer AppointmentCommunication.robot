*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Run Keywords     Delete All Sessions
...               AND           Remove File  cookies.txt
Force Tags        Appointment Communication
Library           FakerLibrary
Library           /ebs/TDD/db.py
Library           String
Library           json
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/consumermail.py

*** Variables ***

${self}         0
${digits}       0123456789
${jpgfile}      /ebs/TDD/uploadimage.jpg
${pngfile}      /ebs/TDD/upload.png
${pdffile}      /ebs/TDD/sample.pdf

*** Test Cases ***

JD-TC-ConsumerAppointmentCommunication-1


    [Documentation]  Send appointment communication message to Provider without attachment.
    
    ${multilocdoms}=  get_mutilocation_domains
    Log  ${multilocdoms}
    Set Suite Variable  ${dom}  ${multilocdoms[0]['domain']}
    Set Suite Variable  ${sub_dom}  ${multilocdoms[0]['subdomains'][0]}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_H}=  Evaluate  ${PUSERNAME}+5566004
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_H}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_H}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_H}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${PUSERNAME_H}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_H}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_H}${\n}
    Set Suite Variable  ${PUSERNAME_H}

    # ${resp}=  Encrypted Provider Login  ${PUSERNAME_H}  ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${p_id2}  ${decrypted_data['id']}

    # Set Suite Variable  ${p_id2}  ${resp.json()['id']}

    Set Test Variable  ${email_id}  ${PUSERNAME_H}.${P_EMAIL}.${test_mail}

    ${resp}=  Update Email   ${p_id2}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

# *** Comments ***
    
    ${list}=  Create List  1  2  3  4  5  6  7
    ${ph1}=  Evaluate  ${PUSERNAME_H}+15566001
    ${ph2}=  Evaluate  ${PUSERNAME_H}+25566002
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}183.${test_mail}  ${views}
    ${bsname}=  FakerLibrary.bs
    Set Suite Variable   ${bsname}
    ${city}=   get_place
    ${companySuffix}=  FakerLibrary.companySuffix
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz1}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Test Variable  ${tz1}
    ${DAY1}=  db.get_date_by_timezone  ${tz1}
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ${bool}
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${sTime}=  add_timezone_time  ${tz1}  0  15  
    Set Suite Variable   ${sTime}
    ${eTime}=  add_timezone_time  ${tz1}  0  45  
    Set Suite Variable   ${eTime}
    ${resp}=  Update Business Profile with Schedule   ${bsname}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fields}=   Get subDomain level Fields  ${dom}  ${sub_dom}
    Log  ${fields.json()}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_dom}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${dom}  ${sub_dom}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Enable Appointment
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep   1s
    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}
    
    ${resp}=  Get Consumer Notification Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${pid}=  get_acc_id  ${PUSERNAME_H}
    Set Suite Variable   ${pid}
    
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime2}=  db.get_time_by_timezone   ${tz}  
    
    ${lid}=  Create Sample Location
    Set Suite Variable   ${lid}
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${sTime2}=  db.get_time_by_timezone  ${tz}  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime2}=  add_two   ${sTime2}  ${delta}

    clear_appt_schedule   ${PUSERNAME_H}
    ${SERVICE1}=   FakerLibrary.name
    Set Suite Variable   ${SERVICE1}
    ${s_id1}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable   ${s_id1}
    ${SERVICE2}=   FakerLibrary.name
    Set Suite Variable   ${SERVICE2}
    ${s_id2}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable   ${s_id2}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=3  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${schedule_name1}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id1}   name=${schedule_name1}  apptState=${Qstate[0]}
   
    ${PH_Number}    Random Number 	       digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable    ${consumerPhone}  555${PH_Number}
    Append To File  ${EXECDIR}/data/TDD_Logs/proconnum.txt  ${SUITE NAME} - ${TEST NAME} - ${consumerPhone}${\n}
    ${consumerFirstName}=   FakerLibrary.first_name
    Set Suite Variable  ${consumerFirstName}
    ${consumerLastName}=    FakerLibrary.last_name  
    ${dob}=    FakerLibrary.Date
    ${permanentAddress1}=  FakerLibrary.address
    ${gender}=  Random Element    ${Genderlist}
    Set Test Variable  ${consumerEmail}  ${C_Email}${consumerPhone}${consumerFirstName}.${test_mail}

    ${resp}=  AddCustomer  ${consumerPhone}  firstName=${consumerFirstName}   lastName=${consumerLastName}  address=${permanentAddress1}   gender=${gender}  dob=${dob}  email=${consumerEmail}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${ageyrs}  ${agemonths}=  db.calculate_age_years_months     ${dob}

    ${resp}=  GetCustomer  phoneNo-eq=${consumerPhone}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${consumerId}  ${resp.json()[0]['id']}
    Should Be Equal As Strings    ${resp.json()[0]['id']}  ${consumerId}
    Should Be Equal As Strings    ${resp.json()[0]['firstName']}  ${consumerFirstName}
    Should Be Equal As Strings    ${resp.json()[0]['lastName']}  ${consumerLastName}
    Should Be Equal As Strings    ${resp.json()[0]['email']}  ${consumerEmail}
    Should Be Equal As Strings    ${resp.json()[0]['gender']}  ${gender}
    Should Be Equal As Strings    ${resp.json()[0]['dob']}  ${dob}
    Should Be Equal As Strings    ${resp.json()[0]['phoneNo']}  ${consumerPhone}
    Should Be Equal As Strings    ${resp.json()[0]['countryCode']}  ${countryCodes[0]}
    Should Be Equal As Strings    ${resp.json()[0]['status']}  ${status[0]}
    Should Be Equal As Strings    ${resp.json()[0]['favourite']}  ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['phone_verified']}  ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['email_verified']}  ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['whatsAppNum']['countryCode']}  ${countryCodes[1]}
    Should Be Equal As Strings    ${resp.json()[0]['whatsAppNum']['number']}  ${consumerPhone}
    Should Be Equal As Strings    ${resp.json()[0]['telegramNum']['countryCode']}  ${countryCodes[1]}
    Should Be Equal As Strings    ${resp.json()[0]['telegramNum']['number']}  ${consumerPhone}
    Should Be Equal As Strings    ${resp.json()[0]['age']['year']}  ${ageyrs}
    Should Be Equal As Strings    ${resp.json()[0]['age']['month']}  ${agemonths}
    Should Be Equal As Strings    ${resp.json()[0]['account']}  ${pid}
    ${fullName}   Set Variable    ${consumerFirstName} ${consumerLastName}
    Set Test Variable  ${fullName}

    # provider consumer 2

    ${PH_Number2}    Random Number 	       digits=5 
    ${PH_Number2}=    Evaluate    f'{${PH_Number2}:0>7d}'
    Log  ${PH_Number2}
    Set Suite Variable    ${consumerPhone2}  555${PH_Number2}
    Append To File  ${EXECDIR}/data/TDD_Logs/proconnum.txt  ${SUITE NAME} - ${TEST NAME} - ${consumerPhone2}${\n}
    ${consumerFirstName2}=   FakerLibrary.first_name
    Set Suite Variable  ${consumerFirstName2}
    ${consumerLastName2}=    FakerLibrary.last_name  
    Set Suite Variable  ${consumerFirstName2}
     Set Suite Variable  ${consumerLastName2}
    ${dob2}=    FakerLibrary.Date
     Set Suite Variable  ${dob2}
    ${permanentAddress11}=  FakerLibrary.address
     Set Suite Variable  ${permanentAddress11}
    ${gender2}=  Random Element    ${Genderlist}
     Set Suite Variable  ${gender2}
    Set Test Variable  ${consumerEmail2}  ${C_Email}${consumerPhone2}${consumerFirstName2}.${test_mail}

    ${resp}=  AddCustomer  ${consumerPhone2}  firstName=${consumerFirstName2}   lastName=${consumerLastName2}  address=${permanentAddress11}   gender=${gender2}  dob=${dob2}  email=${consumerEmail2}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # provider consumer 3

    ${PH_Number3}    Random Number 	       digits=5 
    ${PH_Number3}=    Evaluate    f'{${PH_Number3}:0>7d}'
    Log  ${PH_Number3}
    Set Suite Variable    ${consumerPhone3}  555${PH_Number3}
    Append To File  ${EXECDIR}/data/TDD_Logs/proconnum.txt  ${SUITE NAME} - ${TEST NAME} - ${consumerPhone3}${\n}
    ${consumerFirstName3}=   FakerLibrary.first_name
    Set Suite Variable  ${consumerFirstName3}
    ${consumerLastName3}=    FakerLibrary.last_name  
    Set Suite Variable  ${consumerLastName3}
    ${dob3}=    FakerLibrary.Date
    Set Suite Variable  ${dob3}
    ${permanentAddress12}=  FakerLibrary.address
    Set Suite Variable  ${permanentAddress12}
    ${gender3}=  Random Element    ${Genderlist}
    Set Suite Variable  ${gender3}
    Set Test Variable  ${consumerEmail3}  ${C_Email}${consumerPhone3}${consumerFirstName3}.${test_mail}

    ${resp}=  AddCustomer  ${consumerPhone3}  firstName=${consumerFirstName3}   lastName=${consumerLastName3}  address=${permanentAddress12}   gender=${gender3}  dob=${dob3}  email=${consumerEmail3}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # provider consumer 4

    ${PH_Number4}    Random Number 	       digits=5 
    ${PH_Number4}=    Evaluate    f'{${PH_Number4}:0>7d}'
    Log  ${PH_Number4}
    Set Suite Variable    ${consumerPhone4}  555${PH_Number4}
    Append To File  ${EXECDIR}/data/TDD_Logs/proconnum.txt  ${SUITE NAME} - ${TEST NAME} - ${consumerPhone4}${\n}
    ${consumerFirstName4}=   FakerLibrary.first_name
    Set Suite Variable  ${consumerFirstName4}
    ${consumerLastName4}=    FakerLibrary.last_name  
    Set Suite Variable  ${consumerLastName4}
    ${dob4}=    FakerLibrary.Date
    Set Suite Variable  ${dob4}
    ${permanentAddress13}=  FakerLibrary.address
    Set Suite Variable  ${permanentAddress13}
    ${gender4}=  Random Element    ${Genderlist}
    Set Suite Variable  ${gender4}
    Set Test Variable  ${consumerEmail4}  ${C_Email}${consumerPhone4}${consumerFirstName4}.${test_mail}

    ${resp}=  AddCustomer  ${consumerPhone4}  firstName=${consumerFirstName4}   lastName=${consumerLastName4}  address=${permanentAddress13}   gender=${gender4}  dob=${dob4}  email=${consumerEmail4}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   ${OtpPurpose['Authentication']}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${pid}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}   ${resp.json()['id']}

    ${resp}=  Get Appointment Schedules Consumer  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
        END
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Suite Variable   ${slot1}   ${slots[${j}]}
    
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
 
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id2}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
     Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid1}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response   ${resp}  uid=${apptid1}  appmtDate=${DAY1}   appmtTime=${slot1}    apptStatus=${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${cid}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${consumerFirstName}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${consumerLastName}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id2}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${consumerFirstName}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${consumerLastName}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${cookie}  ${resp}=  Imageupload.ProconLogin  ${consumerPhone}    ${pid}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${caption}=  Fakerlibrary.sentence
    ${resp}=  Imageupload.CAppmntcomm   ${cookie}   ${apptid1}  ${pid}   ${msg}  ${messageType[0]}  ${EMPTY}  ${EMPTY}  ${EMPTY}  
    Log  ${resp}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   4s
    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}        ${cid}
    Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}         ${apptid1}
    Should Be Equal As Strings  ${resp.json()[1]['msg']}                ${msg}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}     0
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}          ${pid}



JD-TC-ConsumerAppointmentCommunication-2

    [Documentation]  Send appointment communication message to Provider with attachment.
    
    ${resp}=    Send Otp For Login    ${consumerPhone2}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone2}   ${OtpPurpose['Authentication']}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone2}    ${pid}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid2}   ${resp.json()['id']}

    ${resp}=  Get Appointment Schedules Consumer  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
        END
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Test Variable   ${slot1}   ${slots[${j}]}
    
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id2}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response   ${resp}  uid=${apptid1}  appmtDate=${DAY1}   appmtTime=${slot1}    apptStatus=${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${cid2}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${consumerFirstName2}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${consumerLastName2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id2}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${consumerFirstName2}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${consumerLastName2}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}
    
    ${cookie}  ${resp}=  Imageupload.ProconLogin  ${consumerPhone2}    ${pid}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${caption1}=  Fakerlibrary.sentence
    ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
    @{fileswithcaption}=  Create List   ${filecap_dict1}

    ${caption}=  Fakerlibrary.sentence
    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Imageupload.CAppmntcomm   ${cookie}  ${apptid1}  ${pid}   ${msg}  ${messageType[0]}  ${caption}  ${EMPTY}  ${jpgfile}  
    Log  ${resp}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep   2s
    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}        ${cid2}
    Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}         ${apptid1}
    Should Be Equal As Strings  ${resp.json()[1]['msg']}                ${msg}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}     0
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}          ${pid}

JD-TC-ConsumerAppointmentCommunication-3

    [Documentation]  Send appointment communication message to provider with multiple files using file types jpeg, png and pdf.

    ${resp}=    Send Otp For Login    ${consumerPhone3}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone3}   ${OtpPurpose['Authentication']}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone3}    ${pid}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid3}   ${resp.json()['id']}

    ${resp}=  Get Appointment Schedules Consumer  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
        END
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Test Variable   ${slot1}   ${slots[${j}]}
    
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id2}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
     Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response   ${resp}  uid=${apptid1}  appmtDate=${DAY1}   appmtTime=${slot1}    apptStatus=${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${cid3}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${consumerFirstName3}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${consumerLastName3}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id2}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${consumerFirstName3}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${consumerLastName3}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}
    
    ${cookie}  ${resp}=  Imageupload.ProconLogin  ${consumerPhone3}    ${pid}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${caption1}=  Fakerlibrary.sentence
    ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
    ${caption2}=  Fakerlibrary.sentence
    ${filecap_dict2}=  Create Dictionary   file=${pngfile}   caption=${caption2}
    ${caption3}=  Fakerlibrary.sentence
    ${filecap_dict3}=  Create Dictionary   file=${pdffile}   caption=${caption3}
    @{fileswithcaption}=  Create List   ${filecap_dict1}   ${filecap_dict2}  ${filecap_dict3}

    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Imageupload.CAppmntCommMultiFile   ${cookie}  ${apptid1}  ${pid}  ${msg}  ${messageType[0]}  ${EMPTY}  @{fileswithcaption}  
    Log  ${resp}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}        ${cid3}
    Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}         ${apptid1}
    Should Be Equal As Strings  ${resp.json()[1]['msg']}                ${msg}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}     0
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}          ${pid}

JD-TC-ConsumerAppointmentCommunication-4

    [Documentation]  Send appointment communication message to Provider with attachment and without caption.

    ${resp}=    Send Otp For Login    ${consumerPhone4}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone4}   ${OtpPurpose['Authentication']}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone4}    ${pid}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid4}   ${resp.json()['id']}

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
        END
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Test Variable   ${slot1}   ${slots[${j}]}
    
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}   

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id2}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
     Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response   ${resp}  uid=${apptid1}  appmtDate=${DAY1}   appmtTime=${slot1}    apptStatus=${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${cid4}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${consumerFirstName4}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${consumerLastName4}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id2}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${consumerFirstName4}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${consumerLastName4}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}
    
    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME33}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${EMPTY}
    @{fileswithcaption}=  Create List   ${filecap_dict1}

    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Imageupload.CAppmntcomm   ${cookie}  ${apptid1}  ${pid}   ${msg}  ${messageType[0]}  ${EMPTY}  ${EMPTY}  ${jpgfile}  
    Log  ${resp}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}        ${cid4}
    Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}         ${apptid1}
    Should Be Equal As Strings  ${resp.json()[1]['msg']}                ${msg}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}     0
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}          ${pid}

JD-TC-ConsumerAppointmentCommunication-5

    [Documentation]  Send appointment communication message to Provider after appointment status changed to arrived.
    
    ${resp}=    Send Otp For Login    ${consumerPhone4}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone4}   ${OtpPurpose['Authentication']}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone4}    ${pid}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid4}   ${resp.json()['id']}

    ${family_fname}=  FakerLibrary.first_name
    ${family_lname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMember   ${family_fname}  ${family_lname}  ${dob}  ${gender}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${cidfor}   ${resp.json()}
   
    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id1}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
        END
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Test Variable   ${slot1}   ${slots[${j}]}
    
    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot1}   firstName=${family_fname}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id1}  ${sch_id1}  ${DAY1}  ${cnote}   ${apptfor}
     Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid2}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response   ${resp}  uid=${apptid2}  appmtDate=${DAY1}   appmtTime=${slot1}    apptStatus=${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${cid4}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${consumerFirstName4}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${consumerLastName4}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id1}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${family_fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${family_lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_H}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Appointment Action   ${apptStatus[2]}   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep  3s
    ${resp}=  Get Appointment Status   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[1]['appointmentStatus']}   ${apptStatus[2]}
    Should Contain  "${resp.json()}"  ${apptStatus[2]}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME33}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${caption1}=  Fakerlibrary.sentence
    ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
    @{fileswithcaption}=  Create List   ${filecap_dict1}

    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    Set Suite Variable   ${msg}
    ${resp}=  Imageupload.CAppmntcomm   ${cookie}   ${apptid2}   ${pid}   ${msg}  ${messageType[0]}  ${caption1}  ${EMPTY}  ${jpgfile}  
    Log  ${resp}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME33}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}        ${cid4}
    Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}         ${apptid2}
    Should Be Equal As Strings  ${resp.json()[1]['msg']}                ${msg}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}     0
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}          ${pid}

JD-TC-ConsumerAppointmentCommunication-6

    [Documentation]  Send appointment communication message to Provider after Starting appointment.

    ${cid}=  get_id  ${CUSERNAME33}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_H}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_Consumermsg  ${CUSERNAME33}
    clear_Providermsg  ${PUSERNAME_H}

    ${resp}=  Appointment Action   ${apptStatus[3]}   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Status   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[2]['appointmentStatus']}   ${apptStatus[3]}
    Should Contain  "${resp.json()}"  ${apptStatus[3]}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME33}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${caption1}=  Fakerlibrary.sentence
    ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
    @{fileswithcaption}=  Create List   ${filecap_dict1}

    ${resp}=  Imageupload.CAppmntcomm   ${cookie}  ${apptid2}  ${pid}  ${msg}  ${messageType[0]}  ${caption1}  ${EMPTY}  ${jpgfile}  
    Log  ${resp}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME33}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        ${cid}
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${apptid2}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     0
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}          ${pid}

JD-TC-ConsumerAppointmentCommunication-7

    [Documentation]  Send appointment communication message to Provider after Completing appointment.

    clear_Consumermsg  ${CUSERNAME33}
    clear_Providermsg  ${PUSERNAME_H}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_H}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Appointment Action   ${apptStatus[6]}   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Status   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[3]['appointmentStatus']}   ${apptStatus[6]}
    Should Contain  "${resp.json()}"  ${apptStatus[6]}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME33}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${caption1}=  Fakerlibrary.sentence
    ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
    @{fileswithcaption}=  Create List   ${filecap_dict1}
   
    ${resp}=  Imageupload.CAppmntcomm   ${cookie}   ${apptid2}  ${pid}  ${msg}  ${messageType[0]}  ${caption1}  ${EMPTY}  ${jpgfile}  
    Log  ${resp}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME33}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cid}=  get_id  ${CUSERNAME33}

    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        ${cid}
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${apptid2}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     0
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}          ${pid}


JD-TC-ConsumerAppointmentCommunication-8

    [Documentation]  Send appointment communication message to Provider after cancelling appointment.

    clear_Consumermsg  ${CUSERNAME21}
    clear_Providermsg  ${PUSERNAME_H}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_H}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${reason}=  Random Element  ${cancelReason}
    ${msg}=   FakerLibrary.word
    ${resp}=    Provider Cancel Appointment  ${apptid1}  ${reason}  ${msg}  ${DAY1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep   2s
    ${resp}=  Get Appointment Status   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[1]['appointmentStatus']}   ${apptStatus[4]}
    Should Contain  "${resp.json()}"  ${apptStatus[4]}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME21}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${caption1}=  Fakerlibrary.sentence
    ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
    @{fileswithcaption}=  Create List   ${filecap_dict1}
    
    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Imageupload.CAppmntcomm   ${cookie}   ${apptid1}  ${pid}  ${msg}  ${messageType[0]}  ${caption1}  ${EMPTY}  ${jpgfile}  
    Log  ${resp}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME21}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}        ${cid}
    Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}         ${apptid1}
    Should Be Equal As Strings  ${resp.json()[1]['msg']}                ${msg}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}     0
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}          ${pid}    

JD-TC-ConsumerAppointmentCommunication-9

    [Documentation]  Send appointment communication message to Provider after Rejecting appointment.
    
    clear_Consumermsg  ${CUSERNAME34}
    clear_Providermsg  ${PUSERNAME_H}
    ${resp}=  Consumer Login  ${CUSERNAME34}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${cid}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}
    Set Test Variable  ${uname}   ${resp.json()['userName']}
    ${cid}=  get_id  ${CUSERNAME34}  

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id1}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
        END
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Test Variable   ${slot1}   ${slots[${j}]}
    
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id1}  ${sch_id1}  ${DAY1}  ${cnote}   ${apptfor}
     Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response   ${resp}  uid=${apptid1}  appmtDate=${DAY1}   appmtTime=${slot1}    apptStatus=${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${cid}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id1}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_H}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment EncodedID    ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}
    Set Test Variable   ${encId}   

    ${reason}=  Random Element  ${cancelReason}
    ${msg}=   FakerLibrary.word
    ${resp}=    Reject Appointment  ${apptid1}  ${reason}  ${msg}  ${DAY1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep   3s
    ${resp}=  Get Appointment Status   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[1]['appointmentStatus']}   ${apptStatus[5]}
    Should Contain  "${resp.json()}"  ${apptStatus[5]}

    ${resp}=  Get Appointment Messages
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${confirmAppt_push}=  Set Variable   ${resp.json()['confirmationMessages']['SP_APP']}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME34}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${caption1}=  Fakerlibrary.sentence
    ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
    @{fileswithcaption}=  Create List   ${filecap_dict1}
    
    ${msg1}=  Fakerlibrary.sentence
    ${resp}=  Imageupload.CAppmntcomm   ${cookie}   ${apptid1}  ${pid}  ${msg1}  ${messageType[0]}  ${caption1}  ${EMPTY}  ${jpgfile}  
    Log  ${resp}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${date}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y
    # ${converted_slot}=  convert_slot_12hr  ${slot1} 
    # log    ${converted_slot}
    # ${defconfirm_msg}=  Replace String  ${confirmAppt_push}  [username]   ${uname} 
    # ${defconfirm_msg}=  Replace String  ${defconfirm_msg}  [service]   ${SERVICE1}
    # ${defconfirm_msg}=  Replace String  ${defconfirm_msg}  [date]   ${date}
    # ${defconfirm_msg}=  Replace String  ${defconfirm_msg}  [time]   ${converted_slot}
    # ${defconfirm_msg}=  Replace String  ${defconfirm_msg}  [providerName]   ${bsname}

     

    # ${bookingid}=  Format String  ${bookinglink}  ${encId}  ${encId}
    ${defconfirm_msg}=  Replace String  ${confirmAppt_push}  [consumer]   ${uname}
    ${defconfirm_msg}=  Replace String  ${defconfirm_msg}  [bookingId]   ${encId}

    ${resp}=  Consumer Login  ${CUSERNAME34}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep  2s
    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}

    Run Keyword IF  '${len}' == '3'
    ...    Run Keywords
    
    ...    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        0
    ...    AND  Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${apptid1}
    ...    AND  Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${defconfirm_msg}
    ...    AND  Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     ${cid}
    ...    AND  Should Be Equal As Strings  ${resp.json()[0]['accountId']}          ${pid}

    ...    AND  Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}        0
    ...    AND  Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}         ${apptid1}
    ...    AND  Should Be Equal As Strings  ${resp.json()[1]['msg']}                ${msg}
    ...    AND  Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}     ${cid}
    ...    AND  Should Be Equal As Strings  ${resp.json()[1]['accountId']}          ${pid}

    ...    AND  Should Be Equal As Strings  ${resp.json()[2]['owner']['id']}        ${cid}
    ...    AND  Should Be Equal As Strings  ${resp.json()[2]['waitlistId']}         ${apptid1}
    ...    AND  Should Be Equal As Strings  ${resp.json()[2]['msg']}                ${msg1}
    ...    AND  Should Be Equal As Strings  ${resp.json()[2]['receiver']['id']}     0
    ...    AND  Should Be Equal As Strings  ${resp.json()[2]['accountId']}          ${pid}
    ...    AND  Should Contain 	${resp.json()[2]}   attachements
    ...    AND  Dictionary Should Contain Key  ${resp.json()[2]['attachements'][0]}   s3path
    ...    AND  Should Contain  ${resp.json()[2]['attachements'][0]['s3path']}   .jpg
    ...    AND  Dictionary Should Contain Key  ${resp.json()[2]['attachements'][0]}   thumbPath
    ...    AND  Should Contain  ${resp.json()[2]['attachements'][0]['s3path']}   .jpg
    ...    AND  Should Be Equal As Strings  ${resp.json()[2]['attachements'][0]['caption']}   ${caption1}

    ...    ELSE IF  '${len}' == '2'
    ...    Run Keywords

    ...    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        0
    ...    AND  Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${apptid1}
    ...    AND  Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${defconfirm_msg}
    ...    AND  Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     ${cid}
    ...    AND  Should Be Equal As Strings  ${resp.json()[0]['accountId']}          ${pid}

    ...    AND  Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}        ${cid}
    ...    AND  Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}         ${apptid1}
    ...    AND  Should Be Equal As Strings  ${resp.json()[1]['msg']}                ${msg1}
    ...    AND  Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}     0
    ...    AND  Should Be Equal As Strings  ${resp.json()[1]['accountId']}          ${pid}
    ...    AND  Should Contain 	${resp.json()[1]}   attachements
    ...    AND  Dictionary Should Contain Key  ${resp.json()[1]['attachements'][0]}   s3path
    ...    AND  Should Contain  ${resp.json()[1]['attachements'][0]['s3path']}   .jpg
    ...    AND  Dictionary Should Contain Key  ${resp.json()[1]['attachements'][0]}   thumbPath
    ...    AND  Should Contain  ${resp.json()[1]['attachements'][0]['s3path']}   .jpg
    ...    AND  Should Be Equal As Strings  ${resp.json()[1]['attachements'][0]['caption']}   ${caption1}
    
# JD-TC-ConsumerAppointmentCommunication-UH1

#     [Documentation]  Send appointment communication message to Provider without login.

#     ${caption1}=  Fakerlibrary.sentence
#     ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
#     @{fileswithcaption}=  Create List   ${filecap_dict1}
#     ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
#     ${resp}=  Imageupload.CAppmntcomm   ${cookie}   ${apptid1}  ${pid}  ${msg}  ${messageType[0]}  ${caption1}  ${EMPTY}  ${jpgfile}  
#     Log  ${resp}
#     Should Be Equal As Strings  ${resp.status_code}    419
#     Should Be Equal As Strings  ${resp.json()}  ${SESSION_EXPIRED}

JD-TC-ConsumerAppointmentCommunication-UH2

    [Documentation]  Send appointment communication message to Provider by another Consumer.
    
    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME9}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${caption1}=  Fakerlibrary.sentence
    ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
    @{fileswithcaption}=  Create List   ${filecap_dict1}
    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Imageupload.CAppmntcomm   ${cookie}   ${apptid1}  ${pid}  ${msg}  ${messageType[0]}  ${caption1}  ${EMPTY}  ${jpgfile}  
    Log  ${resp}
    Should Be Equal As Strings  ${resp.status_code}    403
    Should Be Equal As Strings  ${resp.json()}   ${NO_PERMISSION}

JD-TC-ConsumerAppointmentCommunication-UH3

    [Documentation]  Send appointment communication message using invalid appointment id.
    
    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME33}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${caption1}=  Fakerlibrary.sentence
    ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
    @{fileswithcaption}=  Create List   ${filecap_dict1}
    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${p_id5}=    Random Int   min=1000    max=2000
    ${resp}=  Imageupload.CAppmntcomm    ${cookie}   ${apptid1}  ${p_id5}  ${msg}  ${messageType[0]}  ${caption1}  ${EMPTY}  ${jpgfile}  
    Log  ${resp}
    Should Be Equal As Strings  ${resp.status_code}    404
    Should Be Equal As Strings  ${resp.json()}   ${ACCOUNT_NOT_EXIST}

JD-TC-ConsumerAppointmentCommunication-UH4

    [Documentation]  Send appointment communication message by Provider login.

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME203}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${caption1}=  Fakerlibrary.sentence
    ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
    @{fileswithcaption}=  Create List   ${filecap_dict1}
    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Imageupload.CAppmntcomm   ${cookie}   ${apptid1}  ${pid}  ${msg}  ${messageType[0]}  ${caption1}  ${EMPTY}  ${jpgfile}  
    Log  ${resp}
    Should Be Equal As Strings  ${resp.status_code}    403
    Should Be Equal As Strings  ${resp.json()}   ${NO_PERMISSION}