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

JD-TC-SendMessagebyChat-1

    [Documentation]   Send Message by chat
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

    ${consumerIdList}=    Create List
    ${consumerNumList}=   Create List

    FOR   ${i}  IN RANGE   3
        ${CUSERPH}=  Generate Random Test Phone Number  ${CUSERNAME}
        Set Test Variable  ${CUSERPH${i}}  ${CUSERPH}
        ${fname}=  FakerLibrary.name
        ${lname}=  FakerLibrary.last_name
        ${resp}=  AddCustomer  ${CUSERPH}  firstName=${fname}  lastName=${lname}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid${i}}  ${resp.json()}

        Append To List   ${consumerNumList}  ${CUSERPH${i}}

        ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH${i}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid${i}}

        Append To List   ${consumerIdList}  ${cid${i}}
        
    END

    Set Suite Variable      ${consumerIdList}

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

    ${file_details}=    Create Dictionary   action=${FileAction[0]}  ownerName=${ownerName}  fileName=${pdffile}  fileSize=${fileSize}  driveId=${driveId}  fileType=${fileType}  order=${order}
    Set Suite Variable      ${file_details}
    
    ${resp}=        Send Message by Chat    ${ownerId}  ${consumerIdList[1]}  ${msg}  ${messageType[0]}  ${file_details} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${consumerNumList[1]}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=    Verify Otp For Login   ${consumerNumList[1]}   ${OtpPurpose['Authentication']}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=    ProviderConsumer Login with token    ${consumerNumList[1]}    ${accountId}    ${token}    ${countryCodes[0]}
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

JD-TC-SendMessagebyChat-UH1

    [Documentation]   Send Message by chat - where owner id is empty

    ${resp}=   Encrypted Provider Login  ${PUSERNAME302}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=        Send Message by Chat    ${empty}  ${consumerIdList[1]}  ${msg}  ${messageType[0]}  ${file_details} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

JD-TC-SendMessagebyChat-UH2

    [Documentation]   Send Message by chat - where owner id is invalid

    ${resp}=   Encrypted Provider Login  ${PUSERNAME302}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${inv}=     FakerLibrary.Random Int

    ${resp}=        Send Message by Chat    ${inv}  ${consumerIdList[1]}  ${msg}  ${messageType[0]}  ${file_details} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

JD-TC-SendMessagebyChat-UH3

    [Documentation]   Send Message by chat - where consumer id is invalid

    ${resp}=   Encrypted Provider Login  ${PUSERNAME302}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${inv}=     FakerLibrary.Random Int

    ${resp}=        Send Message by Chat    ${ownerId}  ${inv}  ${msg}  ${messageType[0]}  ${file_details} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

JD-TC-SendMessagebyChat-UH4

    [Documentation]   Send Message by chat - where message is empty

    ${resp}=   Encrypted Provider Login  ${PUSERNAME302}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=        Send Message by Chat    ${ownerId}  ${consumerIdList[1]}  ${empty}  ${messageType[0]}  ${file_details} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

# JD-TC-SendMessagebyChat-UH5

#     [Documentation]   Send Message by chat - where message type is empty

#     ${resp}=   Encrypted Provider Login  ${PUSERNAME302}  ${PASSWORD} 
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${resp}=        Send Message by Chat    ${ownerId}  ${consumerIdList[1]}  ${msg}  ${empty}  ${file_details} 
#     Log  ${resp.content}
#     Should Be Equal As Strings     ${resp.status_code}    200

JD-TC-SendMessagebyChat-UH6

    [Documentation]   Send Message by chat - where message type is enquire

    ${resp}=   Encrypted Provider Login  ${PUSERNAME302}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=        Send Message by Chat    ${ownerId}  ${consumerIdList[1]}  ${msg}  ${messageType[2]}  ${file_details} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

# JD-TC-SendMessagebyChat-UH7

#     [Documentation]   Send Message by chat - where file details are empty list

#     ${resp}=   Encrypted Provider Login  ${PUSERNAME302}  ${PASSWORD} 
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${resp}=        Send Message by Chat    ${ownerId}  ${consumerIdList[1]}  ${msg}  ${messageType[0]}  []
#     Log  ${resp.content}
#     Should Be Equal As Strings     ${resp.status_code}    200

JD-TC-SendMessagebyChat-UH8

    [Documentation]   Send Message by chat - where 

    ${resp}=   Encrypted Provider Login  ${PUSERNAME302}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${file}=    Create Dictionary   action=${FileAction[0]}  ownerName=${ownerName}  fileName=${pdffile}  fileSize=${fileSize}  driveId=${driveId}  fileType=${fileType}  order=${order}
    Set Suite Variable      ${file_details}

    ${resp}=        Send Message by Chat    ${ownerId}  ${consumerIdList[1]}  ${msg}  ${messageType[0]}  ${file} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

JD-TC-SendMessagebyChat-UH9

    [Documentation]   Send Message by chat - where file action is remove

    ${resp}=   Encrypted Provider Login  ${PUSERNAME302}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${file}=    Create Dictionary   action=${FileAction[0]}  ownerName=${ownerName}  fileName=${pdffile}  fileSize=${fileSize}  driveId=${driveId}  fileType=${fileType}  order=${order}
    Set Suite Variable      ${file_details}

    ${resp}=        Send Message by Chat    ${ownerId}  ${consumerIdList[1]}  ${msg}  ${messageType[0]}  ${file} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

JD-TC-SendMessagebyChat-UH10

    [Documentation]   Send Message by chat - where owner name is empty

    ${resp}=   Encrypted Provider Login  ${PUSERNAME302}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${file}=    Create Dictionary   action=${FileAction[0]}  ownerName=${empty}  fileName=${pdffile}  fileSize=${fileSize}  driveId=${driveId}  fileType=${fileType}  order=${order}
    Set Suite Variable      ${file_details}

    ${resp}=        Send Message by Chat    ${ownerId}  ${consumerIdList[1]}  ${msg}  ${messageType[0]}  ${file} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

JD-TC-SendMessagebyChat-UH11

    [Documentation]   Send Message by chat - where file name is empty

    ${resp}=   Encrypted Provider Login  ${PUSERNAME302}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${file}=    Create Dictionary   action=${FileAction[0]}  ownerName=${ownerName}  fileName=${empty}  fileSize=${fileSize}  driveId=${driveId}  fileType=${fileType}  order=${order}
    Set Suite Variable      ${file_details}

    ${resp}=        Send Message by Chat    ${ownerId}  ${consumerIdList[1]}  ${msg}  ${messageType[0]}  ${file} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

JD-TC-SendMessagebyChat-UH12

    [Documentation]   Send Message by chat - where file size is empty

    ${resp}=   Encrypted Provider Login  ${PUSERNAME302}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${file}=    Create Dictionary   action=${FileAction[0]}  ownerName=${ownerName}  fileName=${pdffile}  fileSize=${empty}  driveId=${driveId}  fileType=${fileType}  order=${order}
    Set Suite Variable      ${file_details}

    ${resp}=        Send Message by Chat    ${ownerId}  ${consumerIdList[1]}  ${msg}  ${messageType[0]}  ${file} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422

JD-TC-SendMessagebyChat-UH13

    [Documentation]   Send Message by chat - where driveId is empty

    ${resp}=   Encrypted Provider Login  ${PUSERNAME302}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${file}=    Create Dictionary   action=${FileAction[0]}  ownerName=${ownerName}  fileName=${pdffile}  fileSize=${fileSize}  driveId=${empty}  fileType=${fileType}  order=${order}
    Set Suite Variable      ${file_details}

    ${resp}=        Send Message by Chat    ${ownerId}  ${consumerIdList[1]}  ${msg}  ${messageType[0]}  ${file} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422

JD-TC-SendMessagebyChat-UH14

    [Documentation]   Send Message by chat - where driveId is invalid

    ${resp}=   Encrypted Provider Login  ${PUSERNAME302}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${inv}=     FakerLibrary.Random Int

    ${file}=    Create Dictionary   action=${FileAction[0]}  ownerName=${ownerName}  fileName=${pdffile}  fileSize=${fileSize}  driveId=${inv}  fileType=${fileType}  order=${order}
    Set Suite Variable      ${file_details}

    ${resp}=        Send Message by Chat    ${ownerId}  ${consumerIdList[1]}  ${msg}  ${messageType[0]}  ${file} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422

JD-TC-SendMessagebyChat-UH15

    [Documentation]   Send Message by chat - where file type is empty

    ${resp}=   Encrypted Provider Login  ${PUSERNAME302}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${file}=    Create Dictionary   action=${FileAction[0]}  ownerName=${ownerName}  fileName=${pdffile}  fileSize=${fileSize}  driveId=${driveId}  fileType=${empty}  order=${order}
    Set Suite Variable      ${file_details}

    ${resp}=        Send Message by Chat    ${ownerId}  ${consumerIdList[1]}  ${msg}  ${messageType[0]}  ${file} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422

JD-TC-SendMessagebyChat-UH16

    [Documentation]   Send Message by chat - where order is empty

    ${resp}=   Encrypted Provider Login  ${PUSERNAME302}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${file}=    Create Dictionary   action=${FileAction[0]}  ownerName=${ownerName}  fileName=${pdffile}  fileSize=${fileSize}  driveId=${driveId}  fileType=${fileType}  order=${empty}
    Set Suite Variable      ${file_details}

    ${resp}=        Send Message by Chat    ${ownerId}  ${consumerIdList[1]}  ${msg}  ${messageType[0]}  ${file} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

JD-TC-SendMessagebyChat-UH17

    [Documentation]   Send Message by chat - without login

    ${resp}=        Send Message by Chat    ${ownerId}  ${consumerIdList[1]}  ${msg}  ${messageType[0]}  ${file_details} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    419
    Should Be Equal As Strings     ${resp.json()}    ${SESSION_EXPIRED}