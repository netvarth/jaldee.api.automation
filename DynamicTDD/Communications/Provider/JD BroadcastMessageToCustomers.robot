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
    Set Test Variable    ${accountId}       ${resp.json()['id']}
    Set Test Variable    ${businessName}    ${resp.json()['businessName']}

    # ${lid}=  Create Sample Location
    # ${resp}=   Get Location ById  ${lid}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    FOR   ${i}  IN RANGE   5
        ${CUSERPH}=  Generate Random Test Phone Number  ${CUSERNAME}
        Set Test Variable  ${CUSERPH${i}}  ${CUSERPH}
        ${fname}=  FakerLibrary.first_name
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

    # ${fileSize}=  db.get_file_size   ${pdffile}
    ${fileSize}=  OperatingSystem.Get File Size  ${pdffile}
    Set Suite Variable  ${fileSize}
    ${fileType}=  db.get_filetype  ${pdffile}
    Set Suite Variable  ${fileType}
    ${caption}=    FakerLibrary.Text
    Set Suite Variable  ${caption}
    ${msg}=   FakerLibrary.sentence
    Set Suite Variable  ${msg}
    ${file1_details}=    Create Dictionary   action=${FileAction[0]}  owner=${accountId}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
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
        Should Be Equal As Strings  ${resp.json()[0]['attachmentList'][0]['owner']}     ${accountId}
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
        ${resp}=    Sms Status   ${toggle[1]}
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