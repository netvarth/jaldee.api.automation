*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown    Delete All Sessions
Force Tags        Communications
Library           Collections
Library           String
Library           json
Library           /ebs/TDD/db.py
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 

*** Variables ***

${jpgfile}      /ebs/TDD/uploadimage.jpg
${pngfile}      /ebs/TDD/upload.png
${pdffile}      /ebs/TDD/sample.pdf
${order}    0

*** Test Cases ***

JD-TC-BroadcastMessageToCustomers-1

    [Documentation]   Send message to all provider consumers in account  with all medium enabled.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME302}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable     ${ownerName}     ${decrypted_data['userName']}
    Set Suite Variable     ${ownerId}       ${decrypted_data['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings              ${resp.status_code}   200
    Set Suite Variable    ${accountId}       ${resp.json()['id']}
    Set Suite Variable    ${businessName}    ${resp.json()['businessName']}

    # ${lid}=  Create Sample Location
    # ${resp}=   Get Location ById  ${lid}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    FOR   ${i}  IN RANGE   300
        ${CUSERPH}=  Generate Random Test Phone Number  ${CUSERNAME}
        Set Test Variable  ${CUSERPH${i}}  ${CUSERPH}
        ${fname}=  FakerLibrary.name
        ${lname}=  FakerLibrary.last_name
        ${resp}=  AddCustomer  ${CUSERPH}  firstName=${fname}  lastName=${lname}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid${i}}  ${resp.json()}

        ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH${i}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid${i}}
        
    END

    ${groupName}=   FakerLibrary.word
    ${desc}=   FakerLibrary.bs
    ${resp}=  Create Customer Group   ${groupName}  ${desc}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${groupid}  ${resp.json()}

    ${resp}=  Get Customer Group by id  ${groupid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${num}=    Generate Random 555 Test Phone Number
    ${fname}=  FakerLibrary.name
    ${lname}=  FakerLibrary.last_name
    ${resp}=  AddCustomer  ${num}  firstName=${fname}  lastName=${lname}
    Log  ${resp.content}
    Set Test Variable  ${custid}  ${resp.json()}
    
    ${cust ids}=  Create List

    ${resp}=  GetCustomer  phoneNo-eq=${num}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}  ${custid}
    Append To List   ${cust ids}  ${custid}

    ${resp}=  Add Customers to Group   ${groupName}  @{cust ids}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Customer Group by id  ${groupid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  groups-eq=${groupid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fileSize}=  OperatingSystem.Get File Size  ${pdffile}
    Set Suite Variable  ${fileSize}
    ${fileType}=  db.get_filetype  ${pdffile}
    Set Suite Variable  ${fileType}
    ${caption}=    FakerLibrary.Text
    Set Suite Variable  ${caption}
    ${msg}=   FakerLibrary.sentence
    Set Suite Variable  ${msg}

    ${resp}    upload file to temporary location    ${file_action[0]}    ${ownerId}    ${ownerType[0]}    ${ownerName}    ${pdffile}    ${fileSize}    ${caption}    ${fileType}    ${EMPTY}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Set Suite Variable    ${driveId}    ${resp.json()[0]['driveId']}

    ${file1_details}=    Create Dictionary   action=${FileAction[0]}  ownerName=${accountId}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  driveId=${driveId}  fileType=${fileType}  order=${order}
    ${file_details}=  Create List  ${file1_details}
    Set Suite Variable      ${file_details}
    ${resp}=  Broadcast Message to customers  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  attachments=${file_details}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    FOR   ${i}  IN RANGE   5
        ${resp}=    Send Otp For Login    ${CUSERPH${i}}    ${accountId}
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}   200
    
        ${resp}=    Verify Otp For Login   ${CUSERPH${i}}   12  
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}   200
        Set Test Variable   ${token}  ${resp.json()['token']}

        ${resp}=  Customer Logout   
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
    
        ${resp}=    ProviderConsumer Login with token    ${CUSERPH${i}}    ${accountId}    ${token}    ${countryCodes[0]}
        Log   ${resp.content}
        Should Be Equal As Strings          ${resp.status_code}   200
        Set Suite Variable    ${cid}        ${resp.json()['id']}
        Set Suite Variable    ${username}   ${resp.json()['userName']}
        ${current_date}=    Get Current Date    result_format=%a, %d %b %Y 
        
        ${resp}=  Get Consumer Communications
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200 
        Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}                    ${ownerId}
        Should Be Equal As Strings  ${resp.json()[0]['owner']['name']}                  ${ownerName}
        Should Be Equal As Strings  ${resp.json()[0]['msg']}                            ${username} ${\n}${msg}
        Should Be Equal As Strings  ${resp.json()[0]['service']}                        ${SPACE}Customer${SPACE}${SPACE}on ${current_date}
        Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}                 ${cid}
        Should Be Equal As Strings  ${resp.json()[0]['receiver']['name']}               ${username}
        Should Be Equal As Strings  ${resp.json()[0]['accountId']}                      ${accountId}
        Should Be Equal As Strings  ${resp.json()[0]['accountName']}                    ${businessName}
        Should Be Equal As Strings  ${resp.json()[0]['attachmentList'][0]['fileName']}  ${pdffile}
        Should Be Equal As Strings  ${resp.json()[0]['attachmentList'][0]['caption']}   ${caption}
        Should Be Equal As Strings  ${resp.json()[0]['attachmentList'][0]['fileType']}  ${fileType}
        Should Be Equal As Strings  ${resp.json()[0]['attachmentList'][0]['action']}    ${FileAction[0]}

        ${resp}=  Customer Logout   
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
    END


JD-TC-BroadcastMessageToCustomers-2

    [Documentation]   Send message to all provider - Where notification is disabled

    ${resp}=   Encrypted Provider Login  ${PUSERNAME302}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Accountsettings  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  ${resp.json()['sendNotification']}==${bool[1]}
        ${resp}=    Enable Disable Notification   ${toggle[1]}
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}   200
    END

    ${resp}=  Broadcast Message to customers  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  attachments=${file_details}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Consumer Communications
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()}  []

    ${resp}=    Enable Disable Notification   ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-BroadcastMessageToCustomers-3

    [Documentation]   Send message to all provider - Where sms is disabled

    ${resp}=   Encrypted Provider Login  ${PUSERNAME302}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Accountsettings  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  ${resp.json()['enableSms']}==${bool[1]}
        ${resp}=    Sms Status    ${toggle[1]}
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}   200
    END

    ${resp}=  Broadcast Message to customers  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  attachments=${file_details}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Consumer Communications
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()}  []

    ${resp}=    Sms Status    ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-BroadcastMessageToCustomers-4

    [Documentation]   Send message to all provider - Where whatsApp is disabled

    ${resp}=   Encrypted Provider Login  ${PUSERNAME302}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Accountsettings  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  ${resp.json()['enableWhatsApp']}==${bool[1]}
        ${resp}=    Enable Disable whatsApp    ${toggle[1]}
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}   200
    END

    ${resp}=  Broadcast Message to customers  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  attachments=${file_details}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Consumer Communications
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()}  []

    ${resp}=    Enable Disable whatsApp    ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200


JD-TC-BroadcastMessageToCustomers-5

    [Documentation]   Send message to all provider - Where notification and sms is disabled

    ${resp}=   Encrypted Provider Login  ${PUSERNAME302}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Accountsettings  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  ${resp.json()['sendNotification']}==${bool[1]}
        ${resp}=    Enable Disable Notification   ${toggle[1]}
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}   200
    END

    IF  ${resp.json()['enableSms']}==${bool[1]}
        ${resp}=    Sms Status    ${toggle[1]}
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}   200
    END

    ${resp}=  Broadcast Message to customers  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  attachments=${file_details}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Consumer Communications
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()}  []

    ${resp}=    Enable Disable Notification   ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Sms Status    ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200


JD-TC-BroadcastMessageToCustomers-6

    [Documentation]   Send message to all provider - Where notification and whatsapp is disabled

    ${resp}=   Encrypted Provider Login  ${PUSERNAME302}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Accountsettings  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  ${resp.json()['sendNotification']}==${bool[1]}
        ${resp}=    Enable Disable Notification   ${toggle[1]}
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}   200
    END

    IF  ${resp.json()['enableWhatsApp']}==${bool[1]}
        ${resp}=    Enable Disable whatsApp    ${toggle[1]}
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}   200
    END

    ${resp}=  Broadcast Message to customers  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  attachments=${file_details}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Consumer Communications
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()}  []

    ${resp}=    Enable Disable Notification   ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Enable Disable whatsApp    ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200


JD-TC-BroadcastMessageToCustomers-7

    [Documentation]   Send message to all provider - Where sms and whatsapp is disabled

    ${resp}=   Encrypted Provider Login  ${PUSERNAME302}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Accountsettings  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  ${resp.json()['enableSms']}==${bool[1]}
        ${resp}=    Sms Status    ${toggle[1]}
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}   200
    END

    IF  ${resp.json()['enableWhatsApp']}==${bool[1]}
        ${resp}=    Enable Disable whatsApp    ${toggle[1]}
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}   200
    END

    ${resp}=  Broadcast Message to customers  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  attachments=${file_details}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Consumer Communications
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()}  []

    ${resp}=    Sms Status   ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Enable Disable whatsApp    ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-BroadcastMessageToCustomers-8

    [Documentation]   Send message to all provider - where message is empty

    ${resp}=   Encrypted Provider Login  ${PUSERNAME302}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Broadcast Message to customers  ${empty}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  attachments=${file_details}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${MASS_COMMUNICATION_NOT_EMPTY}

JD-TC-BroadcastMessageToCustomers-9

    [Documentation]   Send message to all provider - email flag is false

    ${resp}=   Encrypted Provider Login  ${PUSERNAME302}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Broadcast Message to customers  ${msg}  ${bool[0]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  attachments=${file_details}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-BroadcastMessageToCustomers-10

    [Documentation]   Send message to all provider - sms flag is false

    ${resp}=   Encrypted Provider Login  ${PUSERNAME302}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Broadcast Message to customers  ${msg}  ${bool[1]}  ${bool[0]}  ${bool[1]}  ${bool[1]}  attachments=${file_details}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-BroadcastMessageToCustomers-11

    [Documentation]   Send message to all provider - telegram flag is false

    ${resp}=   Encrypted Provider Login  ${PUSERNAME302}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Broadcast Message to customers  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[0]}  ${bool[1]}  attachments=${file_details}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-BroadcastMessageToCustomers-12

    [Documentation]   Send message to all provider - whatsApp FLAG IS false

    ${resp}=   Encrypted Provider Login  ${PUSERNAME302}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Broadcast Message to customers  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[0]}  attachments=${file_details}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-BroadcastMessageToCustomers-13

    [Documentation]   Send message to all provider - Action is remove

    ${resp}=   Encrypted Provider Login  ${PUSERNAME302}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${file1_details}=    Create Dictionary   action=${FileAction[2]}  owner=${accountId}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  driveId=${driveId}  fileType=${fileType}  order=${order}
    ${file_detail}=  Create List  ${file1_details}

    ${resp}=  Broadcast Message to customers  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[0]}  attachments=${file_detail}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-BroadcastMessageToCustomers-14

    [Documentation]   Send message to all provider - owner is empty

    ${resp}=   Encrypted Provider Login  ${PUSERNAME302}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${file1_details}=    Create Dictionary   action=${FileAction[0]}  owner=${empty}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  driveId=${driveId}  fileType=${fileType}  order=${order}
    ${file_detail}=  Create List  ${file1_details}

    ${resp}=  Broadcast Message to customers  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[0]}  attachments=${file_detail}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-BroadcastMessageToCustomers-15

    [Documentation]   Send message to all provider - owner is invalid

    ${resp}=   Encrypted Provider Login  ${PUSERNAME302}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${inv}=  FakerLibrary.Random Int

    ${file1_details}=    Create Dictionary   action=${FileAction[2]}  owner=${inv}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  driveId=${driveId}  fileType=${fileType}  order=${order}
    ${file_detail}=  Create List  ${file1_details}

    ${resp}=  Broadcast Message to customers  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[0]}  attachments=${file_detail}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-BroadcastMessageToCustomers-16

    [Documentation]   Send message to all provider - file name is empty

    ${resp}=   Encrypted Provider Login  ${PUSERNAME302}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${file1_details}=    Create Dictionary   action=${FileAction[2]}  owner=${accountId}  fileName=${empty}  fileSize=${fileSize}  caption=${caption}  driveId=${driveId}  fileType=${fileType}  order=${order}
    ${file_detail}=  Create List  ${file1_details}

    ${resp}=  Broadcast Message to customers  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[0]}  attachments=${file_detail}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422

JD-TC-BroadcastMessageToCustomers-17

    [Documentation]   Send message to all provider - file size

    ${resp}=   Encrypted Provider Login  ${PUSERNAME302}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${file1_details}=    Create Dictionary   action=${FileAction[2]}  owner=${accountId}  fileName=${pdffile}  fileSize=${empty}  caption=${caption}  driveId=${driveId}  fileType=${fileType}  order=${order}
    ${file_detail}=  Create List  ${file1_details}

    ${resp}=  Broadcast Message to customers  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[0]}  attachments=${file_detail}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422

JD-TC-BroadcastMessageToCustomers-18

    [Documentation]   Send message to all provider - caption

    ${resp}=   Encrypted Provider Login  ${PUSERNAME302}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${file1_details}=    Create Dictionary   action=${FileAction[2]}  owner=${accountId}  fileName=${pdffile}  fileSize=${fileSize}  caption=${empty}  driveId=${driveId}  fileType=${fileType}  order=${order}
    ${file_detail}=  Create List  ${file1_details}

    ${resp}=  Broadcast Message to customers  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[0]}  attachments=${file_detail}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-BroadcastMessageToCustomers-19

    [Documentation]   Send message to all provider - filetype is empty

    ${resp}=   Encrypted Provider Login  ${PUSERNAME302}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${file1_details}=    Create Dictionary   action=${FileAction[2]}  owner=${accountId}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  driveId=${driveId}  fileType=${empty}  order=${order}
    ${file_detail}=  Create List  ${file1_details}

    ${resp}=  Broadcast Message to customers  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[0]}  attachments=${file_detail}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422

JD-TC-BroadcastMessageToCustomers-20

    [Documentation]   Send message to all provider - order is empty

    ${resp}=   Encrypted Provider Login  ${PUSERNAME302}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${file1_details}=    Create Dictionary   action=${FileAction[2]}  owner=${accountId}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  driveId=${driveId}  fileType=${fileType}  order=${empty}
    ${file_detail}=  Create List  ${file1_details}

    ${resp}=  Broadcast Message to customers  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[0]}  attachments=${file_detail}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-BroadcastMessageToCustomers-21

    [Documentation]   Send message to all provider - Drive id is empty

    ${resp}=   Encrypted Provider Login  ${PUSERNAME302}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${file1_details}=    Create Dictionary   action=${FileAction[2]}  owner=${accountId}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  driveId=${empty}  fileType=${fileType}  order=${order}
    ${file_detail}=  Create List  ${file1_details}

    ${resp}=  Broadcast Message to customers  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[0]}  attachments=${file_detail}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422

JD-TC-BroadcastMessageToCustomers-22

    [Documentation]   Send message to all provider - Drive id is invalid

    ${resp}=   Encrypted Provider Login  ${PUSERNAME302}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${inv}=  FakerLibrary.Random Int

    ${file1_details}=    Create Dictionary   action=${FileAction[2]}  owner=${accountId}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  driveId=${inv}  fileType=${fileType}  order=${order}
    ${file_detail}=  Create List  ${file1_details}

    ${resp}=  Broadcast Message to customers  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[0]}  attachments=${file_detail}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422

JD-TC-BroadcastMessageToCustomers-23

    [Documentation]   Send message to all provider - with group

    ${resp}=   Encrypted Provider Login  ${PUSERNAME302}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${inv}=  FakerLibrary.Random Int

    ${file1_details}=    Create Dictionary   action=${FileAction[2]}  owner=${accountId}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  driveId=${driveId}  fileType=${fileType}  order=${order}
    ${file_detail}=  Create List  ${file1_details}

    ${resp}=  Broadcast Message to customers  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[0]}  groupId=${groupid}  attachments=${file_detail}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422

JD-TC-BroadcastMessageToCustomers-24

    [Documentation]   Send message to all provider - without login

    ${resp}=  Broadcast Message to customers  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[0]}  groupId=${groupid}  attachments=${file_details}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings    ${resp.json()}    ${SESSION_EXPIRED}

