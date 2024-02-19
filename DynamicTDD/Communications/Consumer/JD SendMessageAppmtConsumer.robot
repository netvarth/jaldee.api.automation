*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Appointment
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           random
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/musers.py

*** Variables ***
${SERVICE1}     manicure 
${SERVICE2}     pedicure
${self}         0
${digits}       0123456789
@{provider_list}
@{dom_list}
@{multiloc_providers}
${countryCode}   +91

${jpgfile}      /ebs/TDD/uploadimage.jpg
${order}        0
${fileSize}     0.00458


*** Test Cases ***

JD-TC-SendMessageWithAppmt-1

    [Documentation]  Send Message With Appmt

    ${multilocdoms}=  get_mutilocation_domains
    Log  ${multilocdoms}
    Set Suite Variable  ${dom}  ${multilocdoms[0]['domain']}
    Set Suite Variable  ${sub_dom}  ${multilocdoms[0]['subdomains'][0]}

    ${PO_Number}    Generate random string    7    0123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${PUSERNAME_B}=  Evaluate  ${PUSERNAME}+${PO_Number}
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_B}    ${highest_package[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_B}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_B}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pid}  ${decrypted_data['id']}
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERNAME_B}${\n}
    Set Suite Variable  ${PUSERNAME_B}

    ${list}=  Create List  1  2  3  4  5  6  7
    ${ph1}=  Evaluate  ${PUSERNAME_B}+15566122
    ${ph2}=  Evaluate  ${PUSERNAME_B}+25566122
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}183.${test_mail}  ${views}
    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ${bool}
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fields}=   Get subDomain level Fields  ${dom}  ${sub_dom}
    Log  ${fields.json()}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_dom}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${dom}  ${sub_dom}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    Set Test Variable  ${email_id}  ${P_Email}${PUSERNAME_B}.${test_mail}

    ${resp}=  Update Email   ${p_id}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Enable Appointment
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   01s
    
    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[0]}  ${boolean[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}

    clear_service   ${PUSERNAME_B}
    clear_location  ${PUSERNAME_B}    
    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${pid}=  get_acc_id  ${PUSERNAME_B}
    Set Suite Variable   ${pid}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${lid}=  Create Sample Location
    Set Suite Variable   ${lid}
    
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    clear_appt_schedule   ${PUSERNAME_B}
    ${SERVICE1}=   FakerLibrary.name
    ${s_id}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable   ${s_id}
    ${SERVICE2}=   FakerLibrary.name
    ${s_id2}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable   ${s_id2}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}  ${s_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]} 

    ${PH_Number}    Random Number 	       digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable    ${consumerPhone}  555${PH_Number}
    Append To File  ${EXECDIR}/TDD/TDD_Logs/proconnum.txt  ${SUITE NAME} - ${TEST NAME} - ${consumerPhone}${\n}
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

    ${resp}=    Provider Logout     
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   12  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${pid}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Suite Variable    ${PCid}   ${resp.json()['id']}
    Set Suite Variable    ${PCname}   ${resp.json()['userName']}

    ${resp}=  Get Appointment Schedules Consumer  ${pid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id}   ${pid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Suite Variable   ${slot1}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cid}=  get_id  ${CUSERNAME7}   
    Set Suite Variable   ${cid}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid1}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${message}=  Fakerlibrary.Sentence
    Set Suite variable    ${message}

    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite variable    ${fileType1}
    ${caption1}=  Fakerlibrary.Sentence
    Set Suite variable    ${caption1}
    ${fileName}=    FakerLibrary.firstname
    Set Suite variable    ${fileName}

    ${resp}    upload file to temporary location consumer    ${file_action[0]}    ${PCid}    ${ownerType[0]}    ${PCname}    ${jpgfile}    ${fileSize}    ${caption1}    ${fileType1}    ${EMPTY}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Set Suite Variable    ${driveId}    ${resp.json()[0]['driveId']}

    ${attachments}=  Create Dictionary  owner=${PCid}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${PCname}
    ${attachment}=   Create List  ${attachments}
    Set Suite Variable      ${attachment}

    ${resp}=    Send Message With Appoinment consumer  ${PCid}  ${apptid1}  ${message}  ${messageType[0]}  attachments=${attachment}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Attachments In Appointment By Consumer    ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['fileName']}       ${fileName}
    Should Be Equal As Strings  ${resp.json()[0]['fileSize']}       ${fileSize}
    Should Be Equal As Strings  ${resp.json()[0]['fileType']}       ${fileType1}
    Should Be Equal As Strings  ${resp.json()[0]['action']}         ${file_action[0]}


JD-TC-SendMessageWithAppmt-UH1

	[Documentation]  Send Message With Appmt - where provider id is empty

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   12  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${pid}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Send Message With Appoinment consumer  ${empty}  ${apptid1}  ${message}  ${messageType[0]}  attachments=${attachment}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200


JD-TC-SendMessageWithAppmt-UH2

	[Documentation]  Send Message With Appmt - where provider id is invalid

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   12  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${pid}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${inv}=     FakerLibrary.Random Int

    ${resp}=    Send Message With Appoinment consumer  ${inv}  ${apptid1}  ${message}  ${messageType[0]}  attachments=${attachment}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200


JD-TC-SendMessageWithAppmt-UH3

	[Documentation]  Send Message With Appmt - waitilist id is invalid

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   12  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${pid}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${inv}=     FakerLibrary.Random Int

    ${resp}=    Send Message With Appoinment consumer  ${PCid}  ${inv}  ${message}  ${messageType[0]}  attachments=${attachment}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   404
    Should Be Equal As Strings    ${resp.json()}        ${INVALID_APPOINTMENT}


JD-TC-SendMessageWithAppmt-UH4

	[Documentation]  Send Message With Appmt - message is empty

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   12  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${pid}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Send Message With Appoinment consumer  ${PCid}  ${apptid1}  ${empty}  ${messageType[0]}  attachments=${attachment}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200


JD-TC-SendMessageWithAppmt-UH5

	[Documentation]  Send Message With Appmt - where message type is enquiry

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   12  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${pid}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Send Message With Appoinment consumer  ${PCid}  ${apptid1}  ${message}  ${messageType[1]}  attachments=${attachment}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200


JD-TC-SendMessageWithAppmt-UH6

	[Documentation]  Send Message With Appmt - where owner is empty

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   12  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${pid}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${attachments}=  Create Dictionary  owner=${empty}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${PCname}
    ${attachment2}=   Create List  ${attachments}

    ${resp}=    Send Message With Appoinment consumer  ${PCid}  ${apptid1}  ${message}  ${messageType[0]}  attachments=${attachment2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-SendMessageWithAppmt-UH7

	[Documentation]  Send Message With Appmt - owner is invalid

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   12  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${pid}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${inv}=     FakerLibrary.Random Int

    ${attachments}=  Create Dictionary  owner=${inv}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${PCname}
    ${attachment2}=   Create List  ${attachments}

    ${resp}=    Send Message With Appoinment consumer  ${PCid}  ${apptid1}  ${message}  ${messageType[0]}  attachments=${attachment2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-SendMessageWithAppmt-UH8

	[Documentation]  Send Message With Appmt - file name is empty

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   12  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${pid}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${attachments}=  Create Dictionary  owner=${PCid}  fileName=${empty}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${PCname}
    ${attachment2}=   Create List  ${attachments}

    ${resp}=    Send Message With Appoinment consumer  ${PCid}  ${apptid1}  ${message}  ${messageType[0]}  attachments=${attachment2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${FILE_NAME_NOT_FOUND}

JD-TC-SendMessageWithAppmt-UH9

	[Documentation]  Send Message With Appmt - where file size is empty

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   12  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${pid}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${attachments}=  Create Dictionary  owner=${PCid}  fileName=${fileName}  fileSize=${empty}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${PCname}
    ${attachment2}=   Create List  ${attachments}

    ${resp}=    Send Message With Appoinment consumer  ${PCid}  ${apptid1}  ${message}  ${messageType[0]}  attachments=${attachment2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${FILE_SIZE_ERROR}

JD-TC-SendMessageWithAppmt-UH10

	[Documentation]  Send Message With Appmt - where file type is empty

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   12  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${pid}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${attachments}=  Create Dictionary  owner=${PCid}  fileName=${fileName}  fileSize=${fileSize}  fileType=${empty}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${PCname}
    ${attachment2}=   Create List  ${attachments}

    ${resp}=    Send Message With Appoinment consumer  ${PCid}  ${apptid1}  ${message}  ${messageType[0]}  attachments=${attachment2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${FILE_TYPE_NOT_FOUND}

JD-TC-SendMessageWithAppmt-UH11

	[Documentation]  Send Message With Appmt - order id empty

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   12  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${pid}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${attachments}=  Create Dictionary  owner=${PCid}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${empty}  driveId=${driveId}  action=${file_action[0]}  ownerName=${PCname}
    ${attachment2}=   Create List  ${attachments}

    ${resp}=    Send Message With Appoinment consumer  ${PCid}  ${apptid1}  ${message}  ${messageType[0]}  attachments=${attachment2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-SendMessageWithAppmt-UH12

	[Documentation]  Send Message With Appmt -drive id is empty

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   12  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${pid}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${attachments}=  Create Dictionary  owner=${PCid}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${empty}  action=${file_action[0]}  ownerName=${PCname}
    ${attachment2}=   Create List  ${attachments}

    ${resp}=    Send Message With Appoinment consumer  ${PCid}  ${apptid1}  ${message}  ${messageType[0]}  attachments=${attachment2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${S3_SERVICE_UPLOAD_FAILED}

JD-TC-SendMessageWithAppmt-UH13

	[Documentation]  Send Message With Appmt - drive id id invalid

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   12  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${pid}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${inv}=     FakerLibrary.Random Int

    ${attachments}=  Create Dictionary  owner=${PCid}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${inv}  action=${file_action[0]}  ownerName=${PCname}
    ${attachment2}=   Create List  ${attachments}

    ${resp}=    Send Message With Appoinment consumer  ${PCid}  ${apptid1}  ${message}  ${messageType[0]}  attachments=${attachment2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${INV_DRIVE_ID}

JD-TC-SendMessageWithAppmt-UH14

	[Documentation]  Send Message With Appmt - file action is remove

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   12  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${pid}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${attachments}=  Create Dictionary  owner=${PCid}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${PCname}
    ${attachment2}=   Create List  ${attachments}

    ${resp}=    Send Message With Appoinment consumer  ${PCid}  ${apptid1}  ${message}  ${messageType[2]}  attachments=${attachment2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-SendMessageWithAppmt-UH15

	[Documentation]  Send Message With Appmt - attachment is empty list

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   12  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${pid}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${attachment2}=   Create List

    ${resp}=    Send Message With Appoinment consumer  ${PCid}  ${apptid1}  ${message}  ${messageType[0]}  attachments=${attachment2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-SendMessageWithAppmt-UH16

	[Documentation]  Send Message With Appmt - without login 

    ${resp}=    Send Message With Appoinment consumer  ${PCid}  ${apptid1}  ${message}  ${messageType[0]}  attachments=${attachment}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings    ${resp.json()}        ${SESSION_EXPIRED}