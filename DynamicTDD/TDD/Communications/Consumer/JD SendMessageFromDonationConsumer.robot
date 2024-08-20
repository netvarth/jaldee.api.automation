*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Donation
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Library           Process
Library           OperatingSystem
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py

*** Variables ***

@{multiples}  10  20  30   40   50
${SERVICE1}   MakeUp
${SERVICE2}   Coloring
${SERVICE3}   Painting
${digits}       0123456789

${jpgfile}      /ebs/TDD/uploadimage.jpg
${order}        0
${fileSize}     0.00458

*** Test Cases ***

JD-TC-SendMessageInDonation-1

    [Documentation]   Send Message in Donation
        
    ${resp}=  Encrypted Provider Login  ${PUSERNAME54}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${acc_id}  ${decrypted_data['id']}

    ${acc_id}=  get_acc_id  ${PUSERNAME54}
    Set Suite Variable  ${acc_id}
    delete_donation_service  ${PUSERNAME54}
    clear_service   ${PUSERNAME54}
    clear_queue      ${PUSERNAME54}
    clear_location   ${PUSERNAME54}
    ${resp}=   Create Sample Location
    Set Suite Variable    ${loc_id1}    ${resp} 

    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']} 

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['onlinePayment']}==${bool[0]}   
        ${resp}=   Enable Disable Online Payment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
        
    ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[3]}  ${GST_num} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
        
    ${resp}=  Enable Tax
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${description}=  FakerLibrary.sentence
    ${min_don_amt1}=   Random Int   min=100   max=500
    ${mod}=  Evaluate  ${min_don_amt1}%${multiples[0]}
    ${min_don_amt}=  Evaluate  ${min_don_amt1}-${mod}
    ${max_don_amt1}=   Random Int   min=10000   max=50000
    ${mod1}=  Evaluate  ${max_don_amt1}%${multiples[0]}
    ${max_don_amt}=  Evaluate  ${max_don_amt1}-${mod1}
    ${min_don_amt}=  Convert To Number  ${min_don_amt}  1
    Set Suite Variable  ${min_don_amt}
    ${max_don_amt}=  Convert To Number  ${max_don_amt}  1
    Set Suite Variable  ${max_don_amt}
    ${service_duration}=   Random Int   min=10   max=50
    ${total_amnt}=   Random Int   min=100   max=500
    ${resp}=  Create Donation Service  ${SERVICE1}   ${description}   ${service_duration}   ${btype}    ${bool[1]}    ${notifytype[2]}   ${total_amnt}  ${bool[0]}   ${bool[0]}  ${service_type[0]}  ${min_don_amt}  ${max_don_amt}  ${multiples[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${sid1}  ${resp.json()}
    ${resp}=  Create Donation Service  ${SERVICE2}   ${description}   ${service_duration}   ${btype}    ${bool[1]}    ${notifytype[2]}   ${total_amnt}  ${bool[0]}   ${bool[0]}  ${service_type[0]}  ${min_don_amt}  ${max_don_amt}  ${multiples[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${sid2}  ${resp.json()}

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
    Set Suite Variable  ${fullName}

    ${resp}=    Provider Logout     
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${acc_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   ${OtpPurpose['Authentication']}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${acc_id}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Suite Variable    ${con_id}   ${resp.json()['id']} 
        
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${CUR_DAY}
    ${don_amt1}=   Random Int   min=1000   max=4000
    ${mod}=  Evaluate  ${don_amt1}%${multiples[0]}
    ${don_amt1}=  Evaluate  ${don_amt1}-${mod}
    ${don_amt1}=  Convert To Number  ${don_amt1}  1
    Set Suite Variable  ${don_amt1}
    ${don_amt_float1}=  twodigitfloat  ${don_amt1}

    ${resp}=  Donation By Consumer  ${con_id}  ${sid1}  ${loc_id1}  ${don_amt1}  ${consumerFirstName}  ${consumerLastName}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${acc_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
        
    ${don_id}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${don_id1}  ${don_id[0]}

    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite variable    ${fileType1}
    ${caption1}=  Fakerlibrary.Sentence
    Set Suite variable    ${caption1}
    ${fileName}=    FakerLibrary.firstname
    Set Suite variable    ${fileName}

    ${resp}    upload file to temporary location consumer    ${file_action[0]}    ${con_id}    ${ownerType[0]}    ${fullName}    ${jpgfile}    ${fileSize}    ${caption1}    ${fileType1}    ${EMPTY}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Set Suite Variable    ${driveId}    ${resp.json()[0]['driveId']}

    ${attachments}=  Create Dictionary  owner=${con_id}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${fullName}
    ${attachments}=   Create List  ${attachments}
    Set Suite Variable   ${attachments}

    ${uuid}=    Create List  ${don_id1}
    Set Suite Variable  ${uuid}

    ${resp}=    Send Message With Donation By Consumer    ${caption1}   ${boolean[1]}   ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${uuid}   attachments=${attachments}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-SendMessageInDonation-UH1
    
    [Documentation]    Send Message In Order - caption is empty

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${accId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   ${OtpPurpose['Authentication']}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${accId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=    Send Message With Donation By Consumer   ${empty}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${uuid}  attachments=${attachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings     ${resp.json()}     ${MASS_COMMUNICATION_NOT_EMPTY}

JD-TC-SendMessageInDonation-UH2
    
    [Documentation]    Send Message In Order - email flag

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${accId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   ${OtpPurpose['Authentication']}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${accId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=    Send Message With Donation By Consumer   ${caption1}  ${boolean[0]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${uuid}  attachments=${attachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

JD-TC-SendMessageInDonation-UH3
    
    [Documentation]    Send Message In Order - sms flag is false

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${accId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   ${OtpPurpose['Authentication']}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${accId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=    Send Message With Donation By Consumer     ${caption1}  ${boolean[1]}  ${boolean[0]}  ${boolean[1]}  ${boolean[1]}  ${uuid}  attachments=${attachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

JD-TC-SendMessageInDonation-UH4
    
    [Documentation]    Send Message In Order - telegram flag is false

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${accId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   ${OtpPurpose['Authentication']}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${accId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=    Send Message With Donation By Consumer     ${caption1}  ${boolean[1]}  ${boolean[1]}  ${boolean[0]}  ${boolean[1]}  ${uuid}  attachments=${attachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

JD-TC-SendMessageInDonation-UH5
    
    [Documentation]    Send Message In Order - whats app flag is false

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${accId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   ${OtpPurpose['Authentication']}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${accId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=    Send Message With Donation By Consumer     ${caption1}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[0]}  ${uuid}  attachments=${attachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

# JD-TC-SendMessageInDonation-UH6
    
#     [Documentation]    Send Message In Order - uuid is empty list

#     ${resp}=    Send Otp For Login    ${consumerPhone}    ${accId}
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200
  
#     ${resp}=    Verify Otp For Login   ${consumerPhone}   ${OtpPurpose['Authentication']}  
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200
#     Set Test Variable   ${token}  ${resp.json()['token']}

#     ${resp}=  Customer Logout   
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
   
#     ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${accId}    ${token}
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}   200
    
#     ${resp}=    Send Message With Donation By Consumer     ${caption1}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  []  attachments=${attachments}
#     Log  ${resp.content}
#     Should Be Equal As Strings     ${resp.status_code}    200

JD-TC-SendMessageInDonation-UH7
    
    [Documentation]    Send Message In Order - with no attachment

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${accId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   ${OtpPurpose['Authentication']}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${accId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=    Send Message With Donation By Consumer      ${caption1}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${uuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


JD-TC-SendMessageInDonation-UH9
    
    [Documentation]    Send Message In Order - owner id is empty

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${accId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   ${OtpPurpose['Authentication']}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${accId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${attachments}=  Create Dictionary  owner=${empty}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${fullName}
    ${attachment2}=   Create List  ${attachments}
    Set Suite Variable   ${attachment2}
    
    ${resp}=    Send Message With Donation By Consumer      ${caption1}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${uuid}  attachments=${attachment2}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

JD-TC-SendMessageInDonation-UH10
    
    [Documentation]    Send Message In Order - owner id is invalid

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${accId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   ${OtpPurpose['Authentication']}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${accId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${inv}=  FakerLibrary.Random Int

    ${attachments}=  Create Dictionary  owner=${inv}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${fullName}
    ${attachment2}=   Create List  ${attachments}
    Set Suite Variable   ${attachment2}
    
    ${resp}=    Send Message With Donation By Consumer      ${caption1}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${uuid}  attachments=${attachment2}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

JD-TC-SendMessageInDonation-UH11
    
    [Documentation]    Send Message In Order - file name is empty

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${accId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   ${OtpPurpose['Authentication']}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${accId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${attachments}=  Create Dictionary  owner=${con_id}  fileName=${empty}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${fullName}
    ${attachment2}=   Create List  ${attachments}
    Set Suite Variable   ${attachment2}
    
    ${resp}=    Send Message With Donation By Consumer      ${caption1}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${uuid}  attachments=${attachment2}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings  ${resp.json()}  ${FILE_NAME_NOT_FOUND}

JD-TC-SendMessageInDonation-UH12
    
    [Documentation]    Send Message In Order - file size is empty

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${accId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   ${OtpPurpose['Authentication']}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${accId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${attachments}=  Create Dictionary  owner=${con_id}  fileName=${fileName}  fileSize=${empty}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${fullName}
    ${attachment2}=   Create List  ${attachments}
    Set Suite Variable   ${attachment2}
    
    ${resp}=    Send Message With Donation By Consumer      ${caption1}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${uuid}  attachments=${attachment2}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings  ${resp.json()}  ${FILE_SIZE_ERROR}

JD-TC-SendMessageInDonation-UH13
    
    [Documentation]    Send Message In Order - file type

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${accId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   ${OtpPurpose['Authentication']}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${accId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${attachments}=  Create Dictionary  owner=${con_id}  fileName=${fileName}  fileSize=${fileSize}  fileType=${empty}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${fullName}
    ${attachment2}=   Create List  ${attachments}
    Set Suite Variable   ${attachment2}
    
    ${resp}=    Send Message With Donation By Consumer      ${caption1}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${uuid}  attachments=${attachment2}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings  ${resp.json()}  ${FILE_TYPE_NOT_FOUND}

JD-TC-SendMessageInDonation-UH14
    
    [Documentation]    Send Message In Order - order is empty

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${accId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   ${OtpPurpose['Authentication']}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${accId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${attachments}=  Create Dictionary  owner=${con_id}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${empty}  driveId=${driveId}  action=${file_action[0]}  ownerName=${fullName}
    ${attachment2}=   Create List  ${attachments}
    Set Suite Variable   ${attachment2}
    
    ${resp}=    Send Message With Donation By Consumer      ${caption1}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${uuid}  attachments=${attachment2}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

JD-TC-SendMessageInDonation-UH15
    
    [Documentation]    Send Message In Order - drive id is empty

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${accId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   ${OtpPurpose['Authentication']}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${accId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${attachments}=  Create Dictionary  owner=${con_id}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${empty}  action=${file_action[0]}  ownerName=${fullName}
    ${attachment2}=   Create List  ${attachments}
    Set Suite Variable   ${attachment2}
    
    ${resp}=    Send Message With Donation By Consumer      ${caption1}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${uuid}  attachments=${attachment2}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

JD-TC-SendMessageInDonation-UH16
    
    [Documentation]    Send Message In Order - drive id is invalid

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${accId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   ${OtpPurpose['Authentication']}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${accId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${inv}=  FakerLibrary.Random Int

    ${attachments}=  Create Dictionary  owner=${con_id}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${inv}  action=${file_action[0]}  ownerName=${fullName}
    ${attachment2}=   Create List  ${attachments}
    Set Suite Variable   ${attachment2}
    
    ${resp}=    Send Message With Donation By Consumer      ${caption1}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${uuid}  attachments=${attachment2}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings     ${resp.json()}   ${INV_DRIVE_ID}

JD-TC-SendMessageInDonation-UH17
    
    [Documentation]    Send Message In Order - file action is remove

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${accId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   ${OtpPurpose['Authentication']}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${accId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${attachments}=  Create Dictionary  owner=${con_id}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[2]}  ownerName=${fullName}
    ${attachment2}=   Create List  ${attachments}
    Set Suite Variable   ${attachment2}
    
    ${resp}=    Send Message With Donation By Consumer      ${caption1}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${uuid}  attachments=${attachment2}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

JD-TC-SendMessageInDonation-UH18
    
    [Documentation]    Send Message In Order - owner name is empty

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${accId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   ${OtpPurpose['Authentication']}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${accId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${attachments}=  Create Dictionary  owner=${con_id}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${empty}
    ${attachment2}=   Create List  ${attachments}
    Set Suite Variable   ${attachment2}
    
    ${resp}=    Send Message With Donation By Consumer      ${caption1}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${uuid}  attachments=${attachment2}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

JD-TC-SendMessageInDonation-UH19
    
    [Documentation]    Send Message In Order - without login

    ${resp}=    Send Message With Donation By Consumer      ${caption1}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${uuid}  attachments=${attachment2}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    419
    Should Be Equal As Strings     ${resp.json()}   ${SESSION_EXPIRED}