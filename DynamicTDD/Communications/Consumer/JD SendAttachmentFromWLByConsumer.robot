*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Communication
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library         /ebs/TDD/CustomKeywords.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py


*** Variables ***

${self}     0
@{service_names}
${parallel}     1
${SERVICE1}  manicure 
${SERVICE2}  pedicure
${self}     0
@{service_names}
${digits}       0123456789
@{dom_list}
@{provider_list}
@{multiloc_providers}
@{multiloc_billable_providers}
${jpgfile}      /ebs/TDD/uploadimage.jpg
${order}        0
${fileSize}     0.00458

*** Test Cases ***


JD-TC-SendAttachmentFromWLByConsumer-1
	[Documentation]  ProviderConsumer  Send Attachment From WL By Consumer.
    
    # clear_queue      ${PUSERNAME306}
    # clear_location   ${PUSERNAME306}
    # clear_service    ${PUSERNAME306}
    clear_customer   ${PUSERNAME306}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME306}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${acc_id}=  get_acc_id  ${PUSERNAME306}
    Set Suite Variable   ${acc_id} 

    ${resp}=   Create Sample Location
    Set Suite Variable    ${loc_id1}    ${resp}

    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}  
    ${ser_name1}=   FakerLibrary.word
    Set Suite Variable    ${ser_name1} 
    ${resp}=   Create Sample Service  ${ser_name1}
    Set Suite Variable    ${ser_id1}    ${resp}  
    ${ser_name2}=   FakerLibrary.word
    Set Suite Variable    ${ser_name2} 
    ${resp}=   Create Sample Service  ${ser_name2}
    Set Suite Variable    ${ser_id2}    ${resp}  
    ${q_name}=    FakerLibrary.word
    Set Suite Variable    ${q_name}
    ${list}=  Create List   1  2  3  4  5  6  7
    Set Suite Variable    ${list}
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    Set Suite Variable    ${strt_time}
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    Set Suite Variable    ${end_time}   
    ${parallel}=   Random Int  min=1   max=2
    Set Suite Variable   ${parallel}
    ${capacity}=  Random Int   min=10   max=20
    Set Suite Variable   ${capacity}
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}  ${ser_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id1}   ${resp.json()}

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
    Should Be Equal As Strings    ${resp.json()[0]['account']}  ${acc_id}
    ${fullName}   Set Variable    ${consumerFirstName} ${consumerLastName}
    Set Test Variable  ${fullName}

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${acc_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   ${OtpPurpose['Authentication']}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Consumer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${acc_id}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Suite Variable    ${PCid}   ${resp.json()['id']}

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${cid}  ${acc_id}  ${que_id1}  ${CUR_DAY}  ${ser_id1}  ${cnote}  ${bool[0]}  ${self} 
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200   
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}   
    
    ${resp}=  Get consumer Waitlist By Id   ${wid}  ${acc_id}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['hasAttachment']}    ${bool[0]}

    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite variable    ${fileType1}
    ${caption1}=  Fakerlibrary.Sentence
    Set Suite variable    ${caption1}
    ${fileName}=    generate_filename
    Set Suite variable    ${fileName}

    ${resp}    upload file to temporary location consumer   ${file_action[0]}    ${cid}    ${ownerType[0]}    ${consumerFirstName}    ${jpgfile}    ${fileSize}    ${caption1}    ${fileType1}    ${EMPTY}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Set Suite Variable    ${driveId}    ${resp.json()[0]['driveId']}

    ${attachments}=  Create Dictionary  owner=${cid}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${consumerFirstName}

    ${resp}=  Send Attachment From Waitlist By Consumer   ${wid}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${attachments}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Attachments In Waitlist By Consumer    ${wid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']}          ${cid}
    Should Be Equal As Strings  ${resp.json()[0]['fileName']}       ${fileName}
    Should Be Equal As Strings  ${resp.json()[0]['fileSize']}       ${fileSize}
    Should Be Equal As Strings  ${resp.json()[0]['fileType']}       ${fileType1}
    Should Be Equal As Strings  ${resp.json()[0]['action']}         ${file_action[0]}
    Should Be Equal As Strings  ${resp.json()[0]['ownerName']}      ${consumerFirstName}

    ${resp}=  Get consumer Waitlist By Id   ${wid}  ${acc_id}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['hasAttachment']}    ${bool[1]}



# JD-TC-SendAttachmentWL-UH1

#     [Documentation]  Send Attachment Waitlist - waitlist id is invalid 

#     ${resp}=    Send Otp For Login    ${consumerPhone}    ${acc_id}
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200
  
#     ${resp}=    Verify Otp For Login   ${consumerPhone}   ${OtpPurpose['Authentication']}  
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200
#     Set Test Variable   ${token}  ${resp.json()['token']}

#     ${resp}=  Consumer Logout   
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
   
#     ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${acc_id}    ${token}
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}   200
#     Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}
#     Set Suite Variable    ${PCid}   ${resp.json()['id']}

#     ${inv}=     FakerLibrary.Random Int

#     ${attachments}=  Create Dictionary  owner=${cid}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${consumerFirstName}

#     ${resp}=  Send Attachment From Waitlist By Consumer   ${inv}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${attachments}
#     Log   ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  422


JD-TC-SendAttachmentWL-2

    [Documentation]  Send Attachment Waitlist - email flag is false 

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${acc_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   ${OtpPurpose['Authentication']}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Consumer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${acc_id}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Suite Variable    ${PCid}   ${resp.json()['id']}

    ${attachments}=  Create Dictionary  owner=${cid}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${consumerFirstName}

    ${resp}=  Send Attachment From Waitlist By Consumer   ${wid}  ${boolean[0]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${attachments}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Attachments In Waitlist By Consumer     ${wid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']}          ${cid}
    Should Be Equal As Strings  ${resp.json()[0]['fileName']}       ${fileName}
    Should Be Equal As Strings  ${resp.json()[0]['fileSize']}       ${fileSize}
    Should Be Equal As Strings  ${resp.json()[0]['fileType']}       ${fileType1}
    Should Be Equal As Strings  ${resp.json()[0]['action']}         ${file_action[0]}
    Should Be Equal As Strings  ${resp.json()[0]['ownerName']}      ${consumerFirstName}

    ${resp}=  Get consumer Waitlist By Id   ${wid}  ${acc_id}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['hasAttachment']}    ${bool[1]}

JD-TC-SendAttachmentWL-3

    [Documentation]  Send Attachment Waitlist - sms flag is false

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${acc_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   ${OtpPurpose['Authentication']}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Consumer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${acc_id}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Suite Variable    ${PCid}   ${resp.json()['id']}

    ${attachments}=  Create Dictionary  owner=${cid}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${consumerFirstName}

    ${resp}=  Send Attachment From Waitlist By Consumer   ${wid}  ${boolean[1]}  ${boolean[0]}  ${boolean[1]}  ${boolean[1]}  ${attachments}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Attachments In Waitlist By Consumer     ${wid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']}          ${cid}
    Should Be Equal As Strings  ${resp.json()[0]['fileName']}       ${fileName}
    Should Be Equal As Strings  ${resp.json()[0]['fileSize']}       ${fileSize}
    Should Be Equal As Strings  ${resp.json()[0]['fileType']}       ${fileType1}
    Should Be Equal As Strings  ${resp.json()[0]['action']}         ${file_action[0]}
    Should Be Equal As Strings  ${resp.json()[0]['ownerName']}      ${consumerFirstName}

    ${resp}=  Get consumer Waitlist By Id   ${wid}  ${acc_id}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['hasAttachment']}    ${bool[1]}

JD-TC-SendAttachmentWL-4

    [Documentation]  Send Attachment Waitlist - telegram flag is false

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${acc_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   ${OtpPurpose['Authentication']}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Consumer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${acc_id}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Suite Variable    ${PCid}   ${resp.json()['id']}

    ${attachments}=  Create Dictionary  owner=${cid}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${consumerFirstName}

    ${resp}=  Send Attachment From Waitlist By Consumer   ${wid}  ${boolean[1]}  ${boolean[1]}  ${boolean[0]}  ${boolean[1]}  ${attachments}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Attachments In Waitlist By Consumer     ${wid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']}          ${cid}
    Should Be Equal As Strings  ${resp.json()[0]['fileName']}       ${fileName}
    Should Be Equal As Strings  ${resp.json()[0]['fileSize']}       ${fileSize}
    Should Be Equal As Strings  ${resp.json()[0]['fileType']}       ${fileType1}
    Should Be Equal As Strings  ${resp.json()[0]['action']}         ${file_action[0]}
    Should Be Equal As Strings  ${resp.json()[0]['ownerName']}      ${consumerFirstName}

    ${resp}=  Get consumer Waitlist By Id   ${wid}  ${acc_id}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['hasAttachment']}    ${bool[1]}

JD-TC-SendAttachmentWL-5

    [Documentation]  Send Attachment Waitlist - whats app flag is false

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${acc_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   ${OtpPurpose['Authentication']}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Consumer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${acc_id}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Suite Variable    ${PCid}   ${resp.json()['id']}

    ${attachments}=  Create Dictionary  owner=${cid}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${consumerFirstName}

    ${resp}=  Send Attachment From Waitlist By Consumer   ${wid}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[0]}  ${attachments}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Attachments In Waitlist By Consumer     ${wid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']}          ${cid}
    Should Be Equal As Strings  ${resp.json()[0]['fileName']}       ${fileName}
    Should Be Equal As Strings  ${resp.json()[0]['fileSize']}       ${fileSize}
    Should Be Equal As Strings  ${resp.json()[0]['fileType']}       ${fileType1}
    Should Be Equal As Strings  ${resp.json()[0]['action']}         ${file_action[0]}
    Should Be Equal As Strings  ${resp.json()[0]['ownerName']}      ${consumerFirstName}

    ${resp}=  Get consumer Waitlist By Id   ${wid}  ${acc_id}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['hasAttachment']}    ${bool[1]}

JD-TC-SendAttachmentWL-6

    [Documentation]  Send Attachment Waitlist - owner is empty

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${acc_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   ${OtpPurpose['Authentication']}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Consumer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${acc_id}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Suite Variable    ${PCid}   ${resp.json()['id']}

    ${attachments}=  Create Dictionary  owner=${empty}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${consumerFirstName}

    ${resp}=  Send Attachment From Waitlist By Consumer   ${wid}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${attachments}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Attachments In Waitlist By Consumer     ${wid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']}          ${cid}
    Should Be Equal As Strings  ${resp.json()[0]['fileName']}       ${fileName}
    Should Be Equal As Strings  ${resp.json()[0]['fileSize']}       ${fileSize}
    Should Be Equal As Strings  ${resp.json()[0]['fileType']}       ${fileType1}
    Should Be Equal As Strings  ${resp.json()[0]['action']}         ${file_action[0]}
    Should Be Equal As Strings  ${resp.json()[0]['ownerName']}      ${consumerFirstName}

    ${resp}=  Get consumer Waitlist By Id   ${wid}  ${acc_id}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['hasAttachment']}    ${bool[1]}

JD-TC-SendAttachmentWL-UH2

    [Documentation]  Send Attachment Waitlist - file name

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${acc_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   ${OtpPurpose['Authentication']}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Consumer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${acc_id}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Suite Variable    ${PCid}   ${resp.json()['id']}

    ${attachments}=  Create Dictionary  owner=${cid}  fileName=${empty}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${consumerFirstName}

    ${resp}=  Send Attachment From Waitlist By Consumer   ${wid}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${attachments}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}       ${FILE_NAME_NOT_FOUND}

JD-TC-SendAttachmentWL-UH3

    [Documentation]  Send Attachment Waitlist - file size is empty

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${acc_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   ${OtpPurpose['Authentication']}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Consumer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${acc_id}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Suite Variable    ${PCid}   ${resp.json()['id']}

    ${attachments}=  Create Dictionary  owner=${cid}  fileName=${fileName}  fileSize=${empty}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${consumerFirstName}

    ${resp}=  Send Attachment From Waitlist By Consumer   ${wid}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${attachments}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}       ${FILE_SIZE_ERROR}

JD-TC-SendAttachmentWL-UH4

    [Documentation]  Send Attachment Waitlist - file type is empty

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${acc_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   ${OtpPurpose['Authentication']}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Consumer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${acc_id}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Suite Variable    ${PCid}   ${resp.json()['id']}

    ${attachments}=  Create Dictionary  owner=${cid}  fileName=${fileName}  fileSize=${fileSize}  fileType=${empty}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${consumerFirstName}

    ${resp}=  Send Attachment From Waitlist By Consumer   ${wid}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${attachments}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}       ${FILE_TYPE_NOT_FOUND}

JD-TC-SendAttachmentWL-7

    [Documentation]  Send Attachment Waitlist - order is empty

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${acc_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   ${OtpPurpose['Authentication']}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Consumer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${acc_id}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Suite Variable    ${PCid}   ${resp.json()['id']}

    ${attachments}=  Create Dictionary  owner=${cid}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${consumerFirstName}

    ${resp}=  Send Attachment From Waitlist By Consumer   ${wid}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${attachments}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Attachments In Waitlist By Consumer     ${wid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']}          ${cid}
    Should Be Equal As Strings  ${resp.json()[0]['fileName']}       ${fileName}
    Should Be Equal As Strings  ${resp.json()[0]['fileSize']}       ${fileSize}
    Should Be Equal As Strings  ${resp.json()[0]['fileType']}       ${fileType1}
    Should Be Equal As Strings  ${resp.json()[0]['action']}         ${file_action[0]}
    Should Be Equal As Strings  ${resp.json()[0]['ownerName']}      ${consumerFirstName}

    ${resp}=  Get consumer Waitlist By Id   ${wid}  ${acc_id}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['hasAttachment']}    ${bool[1]}

JD-TC-SendAttachmentWL-UH5

    [Documentation]  Send Attachment Waitlist - drive id is empty 

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${acc_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   ${OtpPurpose['Authentication']}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Consumer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${acc_id}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Suite Variable    ${PCid}   ${resp.json()['id']}

    ${attachments}=  Create Dictionary  owner=${cid}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${empty}  action=${file_action[0]}  ownerName=${consumerFirstName}

    ${resp}=  Send Attachment From Waitlist By Consumer   ${wid}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${attachments}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422

    ${resp}=    Get Attachments In Waitlist By Consumer     ${wid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-SendAttachmentWL-8

    [Documentation]  Send Attachment Waitlist - action is remove

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${acc_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   ${OtpPurpose['Authentication']}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Consumer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${acc_id}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Suite Variable    ${PCid}   ${resp.json()['id']}

    ${attachments}=  Create Dictionary  owner=${cid}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[2]}  ownerName=${consumerFirstName}

    ${resp}=  Send Attachment From Waitlist By Consumer   ${wid}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${attachments}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Attachments In Waitlist By Consumer     ${wid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']}          ${cid}
    Should Be Equal As Strings  ${resp.json()[0]['fileName']}       ${fileName}
    Should Be Equal As Strings  ${resp.json()[0]['fileSize']}       ${fileSize}
    Should Be Equal As Strings  ${resp.json()[0]['fileType']}       ${fileType1}
    Should Be Equal As Strings  ${resp.json()[0]['action']}         ${file_action[0]}
    Should Be Equal As Strings  ${resp.json()[0]['ownerName']}      ${consumerFirstName}

    ${resp}=  Get consumer Waitlist By Id   ${wid}  ${acc_id}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['hasAttachment']}    ${bool[1]}

JD-TC-SendAttachmentWL-UH6

    [Documentation]  Send Attachment Waitlist - attachment is empty

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${acc_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   ${OtpPurpose['Authentication']}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Consumer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${acc_id}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Suite Variable    ${PCid}   ${resp.json()['id']}

    ${attachments}=  Create Dictionary  

    ${resp}=  Send Attachment From Waitlist By Consumer   ${wid}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${attachments}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}       ${INV_DRIVE_ID}

JD-TC-SendAttachmentWL-UH7

    [Documentation]  Send Attachment Waitlist - inv drive id

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${acc_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   ${OtpPurpose['Authentication']}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Consumer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${acc_id}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Suite Variable    ${PCid}   ${resp.json()['id']}

    # ${inv}=     FakerLibrary.Random Int
    ${inv}=     Random Number  digits=3

    ${attachments}=  Create Dictionary  owner=${cid}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${inv}  action=${file_action[0]}  ownerName=${consumerFirstName}

    ${resp}=  Send Attachment From Waitlist By Consumer   ${wid}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${attachments}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422

JD-TC-SendAttachmentWL-UH8

    [Documentation]  Send Attachment Waitlist - without login

    ${attachments}=  Create Dictionary  owner=${cid}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${consumerFirstName}

    ${resp}=  Send Attachment From Waitlist By Consumer   ${wid}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${attachments}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.json()}       ${SESSION_EXPIRED}


JD-TC-SendAttachmentWL-UH9

    [Documentation]  Send Attachment Waitlist - with Provider login

    ${resp}=  Consumer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME306}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${attachments}=  Create Dictionary  owner=${cid}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${consumerFirstName}

    ${resp}=  Send Attachment From Waitlist By Consumer   ${wid}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${attachments}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  ${resp.json()}       ${NO_PERMISSION_FOR_REQUEST}

