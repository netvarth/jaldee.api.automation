*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Communication
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py


*** Variables ***

${jpgfile}      /ebs/TDD/uploadimage.jpg
${order}        0
${fileSize}     0.00458

*** Test Cases ***


JD-TC-SendAttachmentFromWLByConsumer-1

	[Documentation]  ProviderConsumer  upload file to temporary location

    ${resp}=  Encrypted Provider Login  ${PUSERNAME309}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${acc_id}=  get_acc_id  ${PUSERNAME309}
    Set Suite Variable   ${acc_id} 

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
    Should Be Equal As Strings    ${resp.json()[0]['account']}  ${acc_id}
    ${fullName}   Set Variable    ${consumerFirstName} ${consumerLastName}
    Set Test Variable  ${fullName}

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${acc_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   12  
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
    Set Suite Variable    ${PCid}   ${resp.json()['id']}

    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite variable    ${fileType1}
    ${caption1}=  Fakerlibrary.Sentence
    Set Suite variable    ${caption1}
    ${fileName}=    FakerLibrary.firstname
    Set Suite variable    ${fileName}

    ${resp}    upload file to temporary location consumer   ${file_action[0]}    ${cid}    ${ownerType[1]}    ${consumerFirstName}    ${jpgfile}    ${fileSize}    ${caption1}    ${fileType1}    ${EMPTY}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Set Suite Variable    ${driveId}    ${resp.json()[0]['driveId']}

JD-TC-SendAttachmentFromWLByConsumer-2

	[Documentation]  ProviderConsumer  upload file to temporary location - file action is remove  

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${acc_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   12  
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
    Set Suite Variable    ${PCid}   ${resp.json()['id']}

    ${resp}    upload file to temporary location consumer   ${file_action[2]}    ${cid}    ${ownerType[1]}    ${consumerFirstName}    ${jpgfile}    ${fileSize}    ${caption1}    ${fileType1}    ${EMPTY}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 


JD-TC-SendAttachmentFromWLByConsumer-3

	[Documentation]  ProviderConsumer  upload file to temporary location - owner is empty

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${acc_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   12  
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
    Set Suite Variable    ${PCid}   ${resp.json()['id']}

    ${resp}    upload file to temporary location consumer   ${file_action[0]}    ${empty}    ${ownerType[1]}    ${consumerFirstName}    ${jpgfile}    ${fileSize}    ${caption1}    ${fileType1}    ${EMPTY}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings     ${resp.json()}         ${PROVIDE_OWNER_ID}


JD-TC-SendAttachmentFromWLByConsumer-4

	[Documentation]  ProviderConsumer  upload file to temporary location - owner is invalid  

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${acc_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   12  
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
    Set Suite Variable    ${PCid}   ${resp.json()['id']}

    ${inv}=     FakerLibrary.Random Int

    ${resp}    upload file to temporary location consumer   ${file_action[0]}    ${inv}    ${ownerType[1]}    ${consumerFirstName}    ${jpgfile}    ${fileSize}    ${caption1}    ${fileType1}    ${EMPTY}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

JD-TC-SendAttachmentFromWLByConsumer-5

	[Documentation]  ProviderConsumer  upload file to temporary location - owner type is wrong  

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${acc_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   12  
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
    Set Suite Variable    ${PCid}   ${resp.json()['id']}

    ${resp}    upload file to temporary location consumer   ${file_action[0]}    ${cid}    ${ownerType[0]}    ${consumerFirstName}    ${jpgfile}    ${fileSize}    ${caption1}    ${fileType1}    ${EMPTY}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

JD-TC-SendAttachmentFromWLByConsumer-6

	[Documentation]  ProviderConsumer  upload file to temporary location - first name is empty 

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${acc_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   12  
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
    Set Suite Variable    ${PCid}   ${resp.json()['id']}

    ${resp}    upload file to temporary location consumer   ${file_action[0]}    ${cid}    ${ownerType[1]}    ${empty}    ${jpgfile}    ${fileSize}    ${caption1}    ${fileType1}    ${EMPTY}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

JD-TC-SendAttachmentFromWLByConsumer-7

	[Documentation]  ProviderConsumer  upload file to temporary location - file name is empty

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${acc_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   12  
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
    Set Suite Variable    ${PCid}   ${resp.json()['id']}

    ${resp}    upload file to temporary location consumer   ${file_action[0]}    ${cid}    ${ownerType[1]}    ${consumerFirstName}    ${empty}    ${fileSize}    ${caption1}    ${fileType1}    ${EMPTY}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings     ${resp.json()}         ${FILE_NAME_NOT_FOUND} 

JD-TC-SendAttachmentFromWLByConsumer-8

	[Documentation]  ProviderConsumer  upload file to temporary location - file size is empty  

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${acc_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   12  
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
    Set Suite Variable    ${PCid}   ${resp.json()['id']}

    ${resp}    upload file to temporary location consumer   ${file_action[0]}    ${cid}    ${ownerType[1]}    ${consumerFirstName}    ${jpgfile}    ${empty}    ${caption1}    ${fileType1}    ${EMPTY}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings     ${resp.json()}    ${FILE_SIZE_ERROR}

JD-TC-SendAttachmentFromWLByConsumer-9

	[Documentation]  ProviderConsumer  upload file to temporary location - caption is empty

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${acc_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   12  
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
    Set Suite Variable    ${PCid}   ${resp.json()['id']}

    ${resp}    upload file to temporary location consumer   ${file_action[0]}    ${cid}    ${ownerType[1]}    ${consumerFirstName}    ${jpgfile}    ${fileSize}    ${empty}    ${fileType1}    ${EMPTY}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

JD-TC-SendAttachmentFromWLByConsumer-10

	[Documentation]  ProviderConsumer  upload file to temporary location - file type is empty  

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${acc_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   12  
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
    Set Suite Variable    ${PCid}   ${resp.json()['id']}

    ${resp}    upload file to temporary location consumer   ${file_action[0]}    ${cid}    ${ownerType[1]}    ${consumerFirstName}    ${jpgfile}    ${fileSize}    ${caption1}    ${empty}    ${EMPTY}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings     ${resp.json()}    ${FILE_TYPE_NOT_FOUND} 

JD-TC-SendAttachmentFromWLByConsumer-11

	[Documentation]  ProviderConsumer  upload file to temporary location - order is empty 

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${acc_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   12  
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
    Set Suite Variable    ${PCid}   ${resp.json()['id']}

    ${resp}    upload file to temporary location consumer   ${file_action[0]}    ${cid}    ${ownerType[1]}    ${consumerFirstName}    ${jpgfile}    ${fileSize}    ${caption1}    ${fileType1}    ${EMPTY}    ${empty}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

JD-TC-SendAttachmentFromWLByConsumer-12

	[Documentation]  ProviderConsumer  upload file to temporary location - without login

    ${resp}    upload file to temporary location consumer   ${file_action[0]}    ${cid}    ${ownerType[1]}    ${consumerFirstName}    ${jpgfile}    ${fileSize}    ${caption1}    ${fileType1}    ${EMPTY}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    419
    Should Be Equal As Strings     ${resp.json()}  ${SESSION_EXPIRED}

JD-TC-SendAttachmentFromWLByConsumer-13

	[Documentation]  ProviderConsumer  upload file to temporary location - with provider login
    
    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME309}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}    upload file to temporary location consumer   ${file_action[0]}    ${cid}    ${ownerType[1]}    ${consumerFirstName}    ${jpgfile}    ${fileSize}    ${caption1}    ${fileType1}    ${EMPTY}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    401

