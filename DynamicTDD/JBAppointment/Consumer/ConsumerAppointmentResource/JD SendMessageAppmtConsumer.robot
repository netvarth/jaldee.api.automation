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
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables       /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/hl_providers.py
Variables       /ebs/TDD/varfiles/consumerlist.py 

*** Variables ***
${SERVICE1}     manicure 
${SERVICE2}     pedicure
${self}     0
@{service_names}
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

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME50}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${prov_id}=  get_acc_id  ${HLPUSERNAME50}
    Set Suite Variable  ${prov_id}

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp1}=  Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END


    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  ${resp.json()['enableJaldeeFinance']}==${bool[0]}
        ${resp1}=    Enable Disable Jaldee Finance   ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END
    ${loc_id1}=  Create Sample Location

    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    ${servicecharge}=  Convert To Number  ${servicecharge}  1 
    ${srv_duration}=   Random Int   min=10   max=20
    ${resp}=  Create Service  ${SERVICE1}  ${desc}  ${srv_duration}  ${bool[1]}  ${servicecharge}  ${bool[0]}  minPrePaymentAmount=${min_pre}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${ser_id1}  ${resp.json()}

    ${resp}=  Auto Invoice Generation For Service   ${ser_id1}    ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    # clear_appt_schedule   ${HLPUSERNAME50}

    ${resp}=  Get Appointment Schedules
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['onlinePayment']}==${bool[0]}   
        ${resp}=   Enable Disable Online Payment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=   Get Account Settings 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  4  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${loc_id1}  ${duration}  ${bool1}  ${ser_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${schedule_id1}  ${resp.json()}


    # ${fname}=  FakerLibrary.first_name
    # ${lname}=  FakerLibrary.last_name
   
    # ${resp}=  AddCustomer  ${CUSERNAME27}   firstName=${fname}   lastName=${lname}  countryCode=${countryCodes[1]}  
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    Set Test Variable  ${consumerEmail}  ${CUSERNAME27}${fname}.${test_mail}
   
    ${resp}=  AddCustomer  ${CUSERNAME27}    firstName=${fname}   lastName=${lname}  countryCode=${countryCodes[1]}    email=${consumerEmail}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${CUSERNAME27}    ${prov_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${CUSERNAME27}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME27}    ${prov_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${cid}  ${resp.json()['id']}
    Set Suite Variable    ${PCid}   ${resp.json()['id']}
    Set Suite Variable    ${PCname}   ${resp.json()['userName']}


    ${resp}=    Get All Schedule Slots By Date Location and Service  ${prov_id}  ${DAY1}  ${loc_id1}  ${ser_id1}
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
    Set Suite Variable   ${slot21}   ${slots[${j}]}


    
    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot21}
    ${apptfor}=   Create List  ${apptfor1}

    ${DAY6}=  db.add_timezone_date  ${tz}   6
    Set Suite Variable   ${DAY6}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Customer Take Appointment   ${prov_id}  ${ser_id1}  ${schedule_id1}  ${DAY6}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid1}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${prov_id}  ${apptid1}
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
    ${fileName}=    generate_filename
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


    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME27}    ${prov_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Send Message With Appoinment consumer  ${empty}  ${apptid1}  ${message}  ${messageType[0]}  attachments=${attachment}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200


JD-TC-SendMessageWithAppmt-UH2

	[Documentation]  Send Message With Appmt - where provider id is invalid


    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME27}    ${prov_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${inv}=     FakerLibrary.Random Int

    ${resp}=    Send Message With Appoinment consumer  ${inv}  ${apptid1}  ${message}  ${messageType[0]}  attachments=${attachment}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200


JD-TC-SendMessageWithAppmt-UH3

	[Documentation]  Send Message With Appmt - waitilist id is invalid


    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME27}    ${prov_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${inv}=     FakerLibrary.Random Int

    ${resp}=    Send Message With Appoinment consumer  ${PCid}  ${inv}  ${message}  ${messageType[0]}  attachments=${attachment}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   404
    Should Be Equal As Strings    ${resp.json()}        ${INVALID_APPOINTMENT}


JD-TC-SendMessageWithAppmt-UH4

	[Documentation]  Send Message With Appmt - message is empty


    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME27}    ${prov_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Send Message With Appoinment consumer  ${PCid}  ${apptid1}  ${empty}  ${messageType[0]}  attachments=${attachment}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200


JD-TC-SendMessageWithAppmt-UH5

	[Documentation]  Send Message With Appmt - where message type is enquiry


    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME27}    ${prov_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Send Message With Appoinment consumer  ${PCid}  ${apptid1}  ${message}  ${messageType[1]}  attachments=${attachment}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200


JD-TC-SendMessageWithAppmt-UH6

	[Documentation]  Send Message With Appmt - where owner is empty


    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME27}    ${prov_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${attachments}=  Create Dictionary  owner=${empty}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${PCname}
    ${attachment2}=   Create List  ${attachments}

    ${resp}=    Send Message With Appoinment consumer  ${PCid}  ${apptid1}  ${message}  ${messageType[0]}  attachments=${attachment2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-SendMessageWithAppmt-UH7

	[Documentation]  Send Message With Appmt - owner is invalid

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME27}    ${prov_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${inv}=     FakerLibrary.Random Int

    ${attachments}=  Create Dictionary  owner=${inv}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${PCname}
    ${attachment2}=   Create List  ${attachments}

    ${resp}=    Send Message With Appoinment consumer  ${PCid}  ${apptid1}  ${message}  ${messageType[0]}  attachments=${attachment2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-SendMessageWithAppmt-UH8

	[Documentation]  Send Message With Appmt - file name is empty


    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME27}    ${prov_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${attachments}=  Create Dictionary  owner=${PCid}  fileName=${empty}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${PCname}
    ${attachment2}=   Create List  ${attachments}

    ${resp}=    Send Message With Appoinment consumer  ${PCid}  ${apptid1}  ${message}  ${messageType[0]}  attachments=${attachment2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${FILE_NAME_NOT_FOUND}

JD-TC-SendMessageWithAppmt-UH9

	[Documentation]  Send Message With Appmt - where file size is empty


    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME27}    ${prov_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${attachments}=  Create Dictionary  owner=${PCid}  fileName=${fileName}  fileSize=${empty}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${PCname}
    ${attachment2}=   Create List  ${attachments}

    ${resp}=    Send Message With Appoinment consumer  ${PCid}  ${apptid1}  ${message}  ${messageType[0]}  attachments=${attachment2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${FILE_SIZE_ERROR}

JD-TC-SendMessageWithAppmt-UH10

	[Documentation]  Send Message With Appmt - where file type is empty

    ${resp}=    Send Otp For Login    ${CUSERNAME27}    ${prov_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME27}   ${OtpPurpose['Authentication']}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Consumer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME27}    ${prov_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${attachments}=  Create Dictionary  owner=${PCid}  fileName=${fileName}  fileSize=${fileSize}  fileType=${empty}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${PCname}
    ${attachment2}=   Create List  ${attachments}

    ${resp}=    Send Message With Appoinment consumer  ${PCid}  ${apptid1}  ${message}  ${messageType[0]}  attachments=${attachment2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${FILE_TYPE_NOT_FOUND}

JD-TC-SendMessageWithAppmt-UH11

	[Documentation]  Send Message With Appmt - order id empty


    ${resp}=    Send Otp For Login    ${CUSERNAME27}    ${prov_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME27}   ${OtpPurpose['Authentication']}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Consumer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME27}    ${prov_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${attachments}=  Create Dictionary  owner=${PCid}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${empty}  driveId=${driveId}  action=${file_action[0]}  ownerName=${PCname}
    ${attachment2}=   Create List  ${attachments}

    ${resp}=    Send Message With Appoinment consumer  ${PCid}  ${apptid1}  ${message}  ${messageType[0]}  attachments=${attachment2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-SendMessageWithAppmt-UH12

	[Documentation]  Send Message With Appmt -drive id is empty


    ${resp}=    Send Otp For Login    ${CUSERNAME27}    ${prov_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME27}   ${OtpPurpose['Authentication']}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Consumer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME27}    ${prov_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${attachments}=  Create Dictionary  owner=${PCid}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${empty}  action=${file_action[0]}  ownerName=${PCname}
    ${attachment2}=   Create List  ${attachments}

    ${resp}=    Send Message With Appoinment consumer  ${PCid}  ${apptid1}  ${message}  ${messageType[0]}  attachments=${attachment2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${S3_SERVICE_UPLOAD_FAILED}

JD-TC-SendMessageWithAppmt-UH13

	[Documentation]  Send Message With Appmt - drive id id invalid


    ${resp}=    Send Otp For Login    ${CUSERNAME27}    ${prov_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME27}   ${OtpPurpose['Authentication']}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Consumer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME27}    ${prov_id}  ${token} 
    Log   ${resp.content}
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


    ${resp}=    Send Otp For Login    ${CUSERNAME27}    ${prov_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME27}   ${OtpPurpose['Authentication']}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Consumer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME27}    ${prov_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${attachments}=  Create Dictionary  owner=${PCid}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${PCname}
    ${attachment2}=   Create List  ${attachments}

    ${resp}=    Send Message With Appoinment consumer  ${PCid}  ${apptid1}  ${message}  ${messageType[2]}  attachments=${attachment2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-SendMessageWithAppmt-UH15

	[Documentation]  Send Message With Appmt - attachment is empty list


    ${resp}=    Send Otp For Login    ${CUSERNAME27}    ${prov_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME27}   ${OtpPurpose['Authentication']}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Consumer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME27}    ${prov_id}  ${token} 
    Log   ${resp.content}
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