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

JD-TC-SendMessageToMultipleCustomers-1

    [Documentation]   Send Message to Multiple Customers in account  with all medium enabled.

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

    ${consumerIdList}=   Create List

    FOR   ${i}  IN RANGE   3
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

    ${file1_details}=    Create Dictionary   action=${FileAction[0]}  ownerName=${ownerName}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  driveId=${driveId}  fileType=${fileType}  order=${order}
    ${file_details}=  Create List  ${file1_details}
    Set Suite Variable      ${file_details}
    
    ${resp}=        Send Message to Multiple Customers  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  consumerId=${consumerIdList}  attachments=${file_details}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    FOR   ${i}  IN RANGE   3
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


JD-TC-SendMessageToMultipleCustomers-2

    [Documentation]   Send Message to Multiple Customers - message is empty

    ${resp}=   Encrypted Provider Login  ${PUSERNAME302}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=        Send Message to Multiple Customers  ${empty}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  consumerId=${consumerIdList}  attachments=${file_details}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

JD-TC-SendMessageToMultipleCustomers-3

    [Documentation]   Send Message to Multiple Customers - email flag is false

    ${resp}=   Encrypted Provider Login  ${PUSERNAME302}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=        Send Message to Multiple Customers  ${msg}  ${bool[0]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  consumerId=${consumerIdList}  attachments=${file_details}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

JD-TC-SendMessageToMultipleCustomers-4

    [Documentation]   Send Message to Multiple Customers - sms flag is false

    ${resp}=   Encrypted Provider Login  ${PUSERNAME302}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=        Send Message to Multiple Customers  ${msg}  ${bool[1]}  ${bool[0]}  ${bool[1]}  ${bool[1]}  consumerId=${consumerIdList}  attachments=${file_details}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

JD-TC-SendMessageToMultipleCustomers-5

    [Documentation]   Send Message to Multiple Customers - telegram flag is false

    ${resp}=   Encrypted Provider Login  ${PUSERNAME302}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=        Send Message to Multiple Customers  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[0]}  ${bool[1]}  consumerId=${consumerIdList}  attachments=${file_details}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

JD-TC-SendMessageToMultipleCustomers-6

    [Documentation]   Send Message to Multiple Customers - whatsapp flag is false

    ${resp}=   Encrypted Provider Login  ${PUSERNAME302}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=        Send Message to Multiple Customers  ${msg}  ${bool[0]}  ${bool[1]}  ${bool[1]}  ${bool[0]}  consumerId=${consumerIdList}  attachments=${file_details}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

# JD-TC-SendMessageToMultipleCustomers-7

#     [Documentation]   Send Message to Multiple Customers - customer list is not given

#     ${resp}=   Encrypted Provider Login  ${PUSERNAME302}  ${PASSWORD} 
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${resp}=        Send Message to Multiple Customers  ${msg}  ${bool[0]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  attachments=${file_details}
#     Log  ${resp.content}
#     Should Be Equal As Strings     ${resp.status_code}    200

JD-TC-SendMessageToMultipleCustomers-8

    [Documentation]   Send Message to Multiple Customers - consumer list is empty

    ${resp}=   Encrypted Provider Login  ${PUSERNAME302}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${l1}=  Create List

    ${resp}=        Send Message to Multiple Customers  ${msg}  ${bool[0]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  consumerId=${l1}  attachments=${file_details}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings     ${resp.json()}    ${ENTER_CONSUMERID}

JD-TC-SendMessageToMultipleCustomers-9

    [Documentation]   Send Message to Multiple Customers - attachment not found

    ${resp}=   Encrypted Provider Login  ${PUSERNAME302}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=        Send Message to Multiple Customers  ${msg}  ${bool[0]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  consumerId=${consumerIdList}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

JD-TC-SendMessageToMultipleCustomers-10

    [Documentation]   Send Message to Multiple Customers - attachment Details are empty list

    ${resp}=   Encrypted Provider Login  ${PUSERNAME302}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${li}=  Create List

    ${resp}=        Send Message to Multiple Customers  ${msg}  ${bool[0]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  consumerId=${consumerIdList}  attachments=${li}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

JD-TC-SendMessageToMultipleCustomers-11

    [Documentation]   Send Message to Multiple Customers - action is remove

    ${resp}=   Encrypted Provider Login  ${PUSERNAME302}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${file1_details}=    Create Dictionary   action=${FileAction[2]}  ownerName=${ownerName}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  driveId=${driveId}  fileType=${fileType}  order=${order}
    ${file_details2}=  Create List  ${file1_details}

    ${resp}=        Send Message to Multiple Customers  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  consumerId=${consumerIdList}  attachments=${file_details2}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

JD-TC-SendMessageToMultipleCustomers-12

    [Documentation]   Send Message to Multiple Customers - owner name is empty

    ${resp}=   Encrypted Provider Login  ${PUSERNAME302}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${file1_details}=    Create Dictionary   action=${FileAction[0]}  ownerName=${empty}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  driveId=${driveId}  fileType=${fileType}  order=${order}
    ${file_details2}=  Create List  ${file1_details}

    ${resp}=        Send Message to Multiple Customers  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  consumerId=${consumerIdList}  attachments=${file_details2}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

JD-TC-SendMessageToMultipleCustomers-13

    [Documentation]   Send Message to Multiple Customers - file name is empty

    ${resp}=   Encrypted Provider Login  ${PUSERNAME302}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${file1_details}=    Create Dictionary   action=${FileAction[0]}  ownerName=${ownerName}  fileName=${empty}  fileSize=${fileSize}  caption=${caption}  driveId=${driveId}  fileType=${fileType}  order=${order}
    ${file_details2}=  Create List  ${file1_details}

    ${resp}=        Send Message to Multiple Customers  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  consumerId=${consumerIdList}  attachments=${file_details2}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings     ${resp.json()}    ${FILE_NAME_NOT_FOUND}


JD-TC-SendMessageToMultipleCustomers-14

    [Documentation]   Send Message to Multiple Customers - file size is empty

    ${resp}=   Encrypted Provider Login  ${PUSERNAME302}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${file1_details}=    Create Dictionary   action=${FileAction[0]}  ownerName=${ownerName}  fileName=${pdffile}  fileSize=${empty}  caption=${caption}  driveId=${driveId}  fileType=${fileType}  order=${order}
    ${file_details2}=  Create List  ${file1_details}

    ${resp}=        Send Message to Multiple Customers  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  consumerId=${consumerIdList}  attachments=${file_details2}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings     ${resp.json()}    ${FILE_SIZE_ERROR}

JD-TC-SendMessageToMultipleCustomers-15

    [Documentation]   Send Message to Multiple Customers - caption is empty

    ${resp}=   Encrypted Provider Login  ${PUSERNAME302}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${file1_details}=    Create Dictionary   action=${FileAction[0]}  ownerName=${ownerName}  fileName=${pdffile}  fileSize=${fileSize}  caption=${empty}  driveId=${driveId}  fileType=${fileType}  order=${order}
    ${file_details2}=  Create List  ${file1_details}

    ${resp}=        Send Message to Multiple Customers  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  consumerId=${consumerIdList}  attachments=${file_details2}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

JD-TC-SendMessageToMultipleCustomers-16

    [Documentation]   Send Message to Multiple Customers - driveid is empty

    ${resp}=   Encrypted Provider Login  ${PUSERNAME302}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${file1_details}=    Create Dictionary   action=${FileAction[0]}  ownerName=${ownerName}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  driveId=${empty}  fileType=${fileType}  order=${order}
    ${file_details2}=  Create List  ${file1_details}

    ${resp}=        Send Message to Multiple Customers  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  consumerId=${consumerIdList}  attachments=${file_details2}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings     ${resp.json()}    ${INV_DRIVE_ID}

JD-TC-SendMessageToMultipleCustomers-17

    [Documentation]   Send Message to Multiple Customers - drive id is invalid

    ${resp}=   Encrypted Provider Login  ${PUSERNAME302}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${did}=  FakerLibrary.Random Int

    ${file1_details}=    Create Dictionary   action=${FileAction[0]}  ownerName=${ownerName}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  driveId=${did}  fileType=${fileType}  order=${order}
    ${file_details2}=  Create List  ${file1_details}

    ${resp}=        Send Message to Multiple Customers  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  consumerId=${consumerIdList}  attachments=${file_details2}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings     ${resp.json()}    ${INV_DRIVE_ID}

JD-TC-SendMessageToMultipleCustomers-18

    [Documentation]   Send Message to Multiple Customers - filetype is empty

    ${resp}=   Encrypted Provider Login  ${PUSERNAME302}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${file1_details}=    Create Dictionary   action=${FileAction[0]}  ownerName=${ownerName}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  driveId=${driveId}  fileType=${empty}  order=${order}
    ${file_details2}=  Create List  ${file1_details}

    ${resp}=        Send Message to Multiple Customers  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  consumerId=${consumerIdList}  attachments=${file_details2}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings     ${resp.json()}    ${FILE_TYPE_NOT_FOUND}

JD-TC-SendMessageToMultipleCustomers-19

    [Documentation]   Send Message to Multiple Customers - order is empty

    ${resp}=   Encrypted Provider Login  ${PUSERNAME302}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${file1_details}=    Create Dictionary   action=${FileAction[0]}  ownerName=${ownerName}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  driveId=${driveId}  fileType=${fileType}  order=${empty}
    ${file_details2}=  Create List  ${file1_details}

    ${resp}=        Send Message to Multiple Customers  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  consumerId=${consumerIdList}  attachments=${file_details2}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

JD-TC-SendMessageToMultipleCustomers-20

    [Documentation]   Send Message to Multiple Customers - withput login

    ${resp}=        Send Message to Multiple Customers  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  consumerId=${consumerIdList}  attachments=${file_details}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    419
    Should Be Equal As Strings     ${resp.json()}    ${SESSION_EXPIRED}