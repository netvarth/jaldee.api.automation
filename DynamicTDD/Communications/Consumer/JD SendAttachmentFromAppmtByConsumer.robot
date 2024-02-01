*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        communication
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py
Variables         /ebs/TDD/varfiles/musers.py


*** Variables ***

${SERVICE1}  manicure 
${SERVICE2}  pedicure
${self}     0
${digits}       0123456789
@{dom_list}
@{provider_list}
@{multiloc_providers}
@{multiloc_billable_providers}
${jpgfile}      /ebs/TDD/uploadimage.jpg
${order}        0
${fileSize}     0.00458

*** Test Cases ***

JD-TC-SendAttachmentFromAppmtByConsumer-1

    [Documentation]    ProviderConsumer  Send Attachment From Appmt By Consumer

    ${resp}=   Encrypted Provider Login  ${PUSERNAME305}  ${PASSWORD} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${accountId}=    get_acc_id       ${PUSERNAME305}
    Set Suite Variable  ${accountId}

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${lic_id}  ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}
   
    ${highest_package}=  get_highest_license_pkg
    Log  ${highest_package}
    Set Suite variable  ${lic2}  ${highest_package[0]}

    IF  '${lic_id}' != '${lic2}'
        ${resp1}=   Change License Package  ${highest_package[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Appointment 
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}

    clear_service   ${PUSERNAME_B}
    clear_location  ${PUSERNAME_B} 

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp1}=   Run Keyword If  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]} 

    ${lid}=  Create Sample Location  
    Set Suite Variable  ${lid}
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid}  ${resp.json()['id']}  

    ${resp}=   Get License UsageInfo 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    # clear_appt_schedule   ${primaryMobileNo}
    
    ${s_id}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable  ${s_id}
    ${s_id2}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable  ${s_id2}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}    ${s_id2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log   ${resp.content}
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
    Should Be Equal As Strings    ${resp.json()[0]['account']}  ${account_id}
    ${fullName}   Set Variable    ${consumerFirstName} ${consumerLastName}
    Set Test Variable  ${fullName}

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   12  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Suite Variable    ${PCid}   ${resp.json()['id']}

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

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid1}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['uid']}                                           ${apptid1}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['id']}                        ${cid}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                                 ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}                                ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}                                    ${appt_status[1]}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}                                     ${DAY1}
    Should Be Equal As Strings  ${resp.json()['appmtTime']}                                     ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}                                ${lid}

    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite variable    ${fileType1}
    ${caption1}=  Fakerlibrary.Sentence
    Set Suite variable    ${caption1}
    ${fileName}=    FakerLibrary.firstname
    Set Suite variable    ${fileName}

    ${resp}    upload file to temporary location consumer   ${file_action[0]}    ${cid}    ${ownerType[0]}    ${consumerFirstName}    ${jpgfile}    ${fileSize}    ${caption1}    ${fileType1}    ${EMPTY}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Set Suite Variable    ${driveId}    ${resp.json()[0]['driveId']}

    ${attachments}=  Create Dictionary  owner=${cid}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${consumerFirstName}

    ${resp}=  Send Attachment From Appointment By Consumer   ${apptid1}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${attachments}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Attachments In Appointment By Consumer    ${apptid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']}          ${cid}
    Should Be Equal As Strings  ${resp.json()[0]['fileName']}       ${fileName}
    Should Be Equal As Strings  ${resp.json()[0]['fileSize']}       ${fileSize}
    Should Be Equal As Strings  ${resp.json()[0]['fileType']}       ${fileType1}
    Should Be Equal As Strings  ${resp.json()[0]['action']}         ${file_action[0]}
    Should Be Equal As Strings  ${resp.json()[0]['ownerName']}      ${consumerFirstName}


JD-TC-SendAttachmentFromAppmtByConsumer-2

    [Documentation]  ProviderConsumer  Send Attachment From Appmt By Consumer - Appmt id is invalid 

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   12  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Suite Variable    ${PCid}   ${resp.json()['id']}

    ${inv}=     FakerLibrary.Random Int

    ${attachments}=  Create Dictionary  owner=${cid}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${consumerFirstName}

    ${resp}=  Send Attachment From Appointment By Consumer   ${inv}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${attachments}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422

JD-TC-SendAttachmentFromAppmtByConsumer-3

    [Documentation]  ProviderConsumer  Send Attachment From Appmt By Consumer - email flag is false 

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   12  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Suite Variable    ${PCid}   ${resp.json()['id']}

    ${attachments}=  Create Dictionary  owner=${cid}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${consumerFirstName}

    ${resp}=  Send Attachment From Appointment By Consumer   ${apptid1}  ${boolean[0]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${attachments}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Attachments In Appointment By Consumer     ${apptid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']}          ${cid}
    Should Be Equal As Strings  ${resp.json()[0]['fileName']}       ${fileName}
    Should Be Equal As Strings  ${resp.json()[0]['fileSize']}       ${fileSize}
    Should Be Equal As Strings  ${resp.json()[0]['fileType']}       ${fileType1}
    Should Be Equal As Strings  ${resp.json()[0]['action']}         ${file_action[0]}
    Should Be Equal As Strings  ${resp.json()[0]['ownerName']}      ${consumerFirstName}

JD-TC-SendAttachmentFromAppmtByConsumer-4

    [Documentation]  ProviderConsumer  Send Attachment From Appmt By Consumer - sms flag is false

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   12  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Suite Variable    ${PCid}   ${resp.json()['id']}

    ${attachments}=  Create Dictionary  owner=${cid}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${consumerFirstName}

    ${resp}=  Send Attachment From Appointment By Consumer   ${apptid1}  ${boolean[1]}  ${boolean[0]}  ${boolean[1]}  ${boolean[1]}  ${attachments}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Attachments In Appointment By Consumer     ${apptid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']}          ${cid}
    Should Be Equal As Strings  ${resp.json()[0]['fileName']}       ${fileName}
    Should Be Equal As Strings  ${resp.json()[0]['fileSize']}       ${fileSize}
    Should Be Equal As Strings  ${resp.json()[0]['fileType']}       ${fileType1}
    Should Be Equal As Strings  ${resp.json()[0]['action']}         ${file_action[0]}
    Should Be Equal As Strings  ${resp.json()[0]['ownerName']}      ${consumerFirstName}

JD-TC-SendAttachmentFromAppmtByConsumer-5

    [Documentation]  ProviderConsumer  Send Attachment From Appmt By Consumer - telegram flag is false

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   12  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Suite Variable    ${PCid}   ${resp.json()['id']}

    ${attachments}=  Create Dictionary  owner=${cid}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${consumerFirstName}

    ${resp}=  Send Attachment From Appointment By Consumer   ${apptid1}  ${boolean[1]}  ${boolean[1]}  ${boolean[0]}  ${boolean[1]}  ${attachments}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Attachments In Appointment By Consumer     ${apptid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']}          ${cid}
    Should Be Equal As Strings  ${resp.json()[0]['fileName']}       ${fileName}
    Should Be Equal As Strings  ${resp.json()[0]['fileSize']}       ${fileSize}
    Should Be Equal As Strings  ${resp.json()[0]['fileType']}       ${fileType1}
    Should Be Equal As Strings  ${resp.json()[0]['action']}         ${file_action[0]}
    Should Be Equal As Strings  ${resp.json()[0]['ownerName']}      ${consumerFirstName}

JD-TC-SendAttachmentFromAppmtByConsumer-6

    [Documentation]  ProviderConsumer  Send Attachment From Appmt By Consumer - whats app flag is false

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   12  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Suite Variable    ${PCid}   ${resp.json()['id']}

    ${attachments}=  Create Dictionary  owner=${cid}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${consumerFirstName}

    ${resp}=  Send Attachment From Appointment By Consumer   ${apptid1}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[0]}  ${attachments}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Attachments In Appointment By Consumer     ${apptid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']}          ${cid}
    Should Be Equal As Strings  ${resp.json()[0]['fileName']}       ${fileName}
    Should Be Equal As Strings  ${resp.json()[0]['fileSize']}       ${fileSize}
    Should Be Equal As Strings  ${resp.json()[0]['fileType']}       ${fileType1}
    Should Be Equal As Strings  ${resp.json()[0]['action']}         ${file_action[0]}
    Should Be Equal As Strings  ${resp.json()[0]['ownerName']}      ${consumerFirstName}

JD-TC-SendAttachmentFromAppmtByConsumer-7

    [Documentation]  ProviderConsumer  Send Attachment From Appmt By Consumer - owner is empty

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   12  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Suite Variable    ${PCid}   ${resp.json()['id']}

    ${attachments}=  Create Dictionary  owner=${empty}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${consumerFirstName}

    ${resp}=  Send Attachment From Appointment By Consumer   ${apptid1}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${attachments}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Attachments In Appointment By Consumer     ${apptid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']}          ${cid}
    Should Be Equal As Strings  ${resp.json()[0]['fileName']}       ${fileName}
    Should Be Equal As Strings  ${resp.json()[0]['fileSize']}       ${fileSize}
    Should Be Equal As Strings  ${resp.json()[0]['fileType']}       ${fileType1}
    Should Be Equal As Strings  ${resp.json()[0]['action']}         ${file_action[0]}
    Should Be Equal As Strings  ${resp.json()[0]['ownerName']}      ${consumerFirstName}

JD-TC-SendAttachmentFromAppmtByConsumer-8

    [Documentation]  ProviderConsumer  Send Attachment From Appmt By Consumer - file name

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   12  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Suite Variable    ${PCid}   ${resp.json()['id']}

    ${attachments}=  Create Dictionary  owner=${cid}  fileName=${empty}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${consumerFirstName}

    ${resp}=  Send Attachment From Appointment By Consumer   ${apptid1}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${attachments}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}       ${FILE_NAME_NOT_FOUND}

JD-TC-SendAttachmentFromAppmtByConsumer-9

    [Documentation]  ProviderConsumer  Send Attachment From Appmt By Consumer - file size is empty

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   12  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Suite Variable    ${PCid}   ${resp.json()['id']}

    ${attachments}=  Create Dictionary  owner=${cid}  fileName=${fileName}  fileSize=${empty}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${consumerFirstName}

    ${resp}=  Send Attachment From Appointment By Consumer   ${apptid1}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${attachments}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}       ${FILE_SIZE_ERROR}

JD-TC-SendAttachmentFromAppmtByConsumer-10

    [Documentation]  ProviderConsumer  Send Attachment From Appmt By Consumer - file type is empty

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   12  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Suite Variable    ${PCid}   ${resp.json()['id']}

    ${attachments}=  Create Dictionary  owner=${cid}  fileName=${fileName}  fileSize=${fileSize}  fileType=${empty}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${consumerFirstName}

    ${resp}=  Send Attachment From Appointment By Consumer   ${apptid1}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${attachments}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}       ${FILE_TYPE_NOT_FOUND}

JD-TC-SendAttachmentFromAppmtByConsumer-11

    [Documentation]  ProviderConsumer  Send Attachment From Appmt By Consumer - order is empty

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   12  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Suite Variable    ${PCid}   ${resp.json()['id']}

    ${attachments}=  Create Dictionary  owner=${cid}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${consumerFirstName}

    ${resp}=  Send Attachment From Appointment By Consumer   ${apptid1}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${attachments}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Attachments In Appointment By Consumer     ${apptid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']}          ${cid}
    Should Be Equal As Strings  ${resp.json()[0]['fileName']}       ${fileName}
    Should Be Equal As Strings  ${resp.json()[0]['fileSize']}       ${fileSize}
    Should Be Equal As Strings  ${resp.json()[0]['fileType']}       ${fileType1}
    Should Be Equal As Strings  ${resp.json()[0]['action']}         ${file_action[0]}
    Should Be Equal As Strings  ${resp.json()[0]['ownerName']}      ${consumerFirstName}

JD-TC-SendAttachmentFromAppmtByConsumer-12

    [Documentation]  ProviderConsumer  Send Attachment From Appmt By Consumer - drive id is empty 

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   12  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Suite Variable    ${PCid}   ${resp.json()['id']}

    ${attachments}=  Create Dictionary  owner=${cid}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${consumerFirstName}

    ${resp}=  Send Attachment From Appointment By Consumer   ${apptid1}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${attachments}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422

JD-TC-SendAttachmentFromAppmtByConsumer-13

    [Documentation]  ProviderConsumer  Send Attachment From Appmt By Consumer - action is remove

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   12  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Suite Variable    ${PCid}   ${resp.json()['id']}

    ${attachments}=  Create Dictionary  owner=${cid}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[2]}  ownerName=${consumerFirstName}

    ${resp}=  Send Attachment From Appointment By Consumer   ${apptid1}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${attachments}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Attachments In Appointment By Consumer     ${apptid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']}          ${cid}
    Should Be Equal As Strings  ${resp.json()[0]['fileName']}       ${fileName}
    Should Be Equal As Strings  ${resp.json()[0]['fileSize']}       ${fileSize}
    Should Be Equal As Strings  ${resp.json()[0]['fileType']}       ${fileType1}
    Should Be Equal As Strings  ${resp.json()[0]['action']}         ${file_action[0]}
    Should Be Equal As Strings  ${resp.json()[0]['ownerName']}      ${consumerFirstName}

JD-TC-SendAttachmentFromAppmtByConsumer-14

    [Documentation]  ProviderConsumer  Send Attachment From Appmt By Consumer - attachment is empty

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   12  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Suite Variable    ${PCid}   ${resp.json()['id']}

    ${attachments}=  Create Dictionary  

    ${resp}=  Send Attachment From Appointment By Consumer   ${apptid1}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${attachments}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}       ${INV_DRIVE_ID}

JD-TC-SendAttachmentFromAppmtByConsumer-15

    [Documentation]  ProviderConsumer  Send Attachment From Appmt By Consumer - inv drive id

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   12  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Suite Variable    ${PCid}   ${resp.json()['id']}

    ${inv}=     FakerLibrary.Random Int

    ${attachments}=  Create Dictionary  owner=${cid}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${inv}  action=${file_action[0]}  ownerName=${consumerFirstName}

    ${resp}=  Send Attachment From Appointment By Consumer   ${apptid1}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${attachments}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422

JD-TC-SendAttachmentFromAppmtByConsumer-16

    [Documentation]  ProviderConsumer  Send Attachment From Appmt By Consumer - without login

    ${attachments}=  Create Dictionary  owner=${cid}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${consumerFirstName}

    ${resp}=  Send Attachment From Appointment By Consumer   ${apptid1}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${attachments}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.json()}       ${SESSION_EXPIRED}


JD-TC-SendAttachmentFromAppmtByConsumer-17

    [Documentation]  ProviderConsumer  Send Attachment From Appmt By Consumer - with Provider login

    ${resp}=   Encrypted Provider Login  ${PUSERNAME305}  ${PASSWORD} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${attachments}=  Create Dictionary  owner=${cid}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${consumerFirstName}

    ${resp}=  Send Attachment From Appointment By Consumer   ${apptid1}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${attachments}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  ${resp.json()}       ${NoAccess}