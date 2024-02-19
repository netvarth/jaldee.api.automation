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

    ${resp}=    Provider Logout     
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

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

    ${fileSize}=  OperatingSystem.Get File Size  ${pdffile}
    Set Suite Variable  ${fileSize}
    ${fileType}=  db.get_filetype  ${pdffile}
    Set Suite Variable  ${fileType}
    ${caption}=    FakerLibrary.Text
    Set Suite Variable  ${caption}
    ${msg}=   FakerLibrary.sentence
    Set Suite Variable  ${msg}

    ${resp}    upload file to temporary location consumer    ${file_action[0]}    ${PCid}    ${ownerType[0]}    ${consumerFirstName}    ${pdffile}    ${fileSize}    ${caption}    ${fileType}    ${EMPTY}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Set Suite Variable    ${driveId}    ${resp.json()[0]['driveId']}

    ${file_details}=    Create Dictionary   action=${FileAction[0]}  ownerName=${consumerFirstName}  fileName=${pdffile}  fileSize=${fileSize}  driveId=${driveId}  fileType=${fileType}  order=${order}
    Set Suite Variable      ${file_details}
    
    ${resp}=       Send Message By Chat from Consumer    ${PCid}  ${msg}  ${messageType[0]}  ${file_details} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
        
    ${resp}=  Get Consumer Communications
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}                    ${PCid}
    Should Be Equal As Strings  ${resp.json()[0]['owner']['name']}                  ${consumerFirstName}
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