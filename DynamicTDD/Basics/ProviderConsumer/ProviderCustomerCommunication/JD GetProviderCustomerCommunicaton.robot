*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Login
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py

*** Variables ***

@{emptylist}
${jpgfile}     /ebs/TDD/uploadimage.jpg
${order}    0
${unread_msg_count}     0
${new_unread_count}     0
${new_unread_count2}    0
${fileSize}    0.00458


*** Test Cases ***


JD-TC-Get Communication-1

    [Documentation]    Get Communication

    ${resp}=   ProviderLogin  ${PUSERNAME77}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings          ${resp.status_code}   200
    Set Suite Variable    ${pid}        ${resp.json()['id']}
    Set Suite Variable    ${pdrname}    ${resp.json()['userName']}

    ${resp}=    Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${accountId}        ${resp.json()['id']}
    Set Suite Variable    ${accountName}      ${resp.json()['businessName']}

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${firstName}=  FakerLibrary.name
    Set Suite Variable    ${firstName}
    ${lastName}=  FakerLibrary.last_name
    Set Suite Variable    ${lastName}
    ${primaryMobileNo}    Generate random string    10    123456789
    ${primaryMobileNo}    Convert To Integer  ${primaryMobileNo}
    Set Suite Variable    ${primaryMobileNo}
    ${email}=    FakerLibrary.Email
    Set Suite Variable    ${email}

    ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   12
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    Customer Logout 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email}    ${primaryMobileNo}     ${accountId}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200    
   
    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings              ${resp.status_code}   200
    Set Suite Variable    ${cid}            ${resp.json()['providerConsumer']}
    Set Suite Variable    ${jconid}         ${resp.json()['id']}
    Set Suite Variable    ${proconfname}    ${resp.json()['firstName']}    
    Set Suite Variable    ${proconlname}    ${resp.json()['lastName']} 
    Set Suite Variable    ${fullname}       ${proconfname}${space}${proconlname}

    ${communicationMessage}    Fakerlibrary.word
    Set Suite Variable    ${communicationMessage}

    ${communicationMessage1}    Fakerlibrary.word
    Set Suite Variable    ${communicationMessage1}

    ${communicationMessage2}    Fakerlibrary.word
    Set Suite Variable    ${communicationMessage2}

    ${communicationMessage3}    Fakerlibrary.word
    Set Suite Variable    ${communicationMessage3}

    ${communicationMessage4}    Fakerlibrary.word
    Set Suite Variable    ${communicationMessage4}

    ${caption}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${jpgfile}
    ${attachment_list}=  Create Dictionary         owner=${cid}   fileName=${jpgfile}    fileSize= ${fileSize}     caption=${caption}     fileType=${fileType}   action=${file_action[0]}  order=${order}

    ${resp}=    Communication between Provider_consumer and provider    ${cid}    ${userType[8]}    ${pid}    ${userType[0]}    ${communicationMessage}    ${messageType[0]}   ${attachment_list}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}  200

    ${resp}=    Communication between Provider_consumer and provider    ${cid}    ${userType[8]}    ${pid}    ${userType[0]}    ${communicationMessage1}    ${messageType[0]}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Communication between Provider_consumer and provider    ${cid}    ${userType[8]}    ${pid}    ${userType[0]}    ${communicationMessage2}    ${messageType[1]}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Communication between Provider_consumer and provider    ${cid}    ${userType[8]}    ${pid}    ${userType[0]}    ${communicationMessage3}    ${messageType[2]}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Communication between Provider_consumer and provider    ${cid}    ${userType[8]}    ${pid}    ${userType[0]}    ${communicationMessage4}    ${messageType[3]}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Communication    ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${total_msg_count}=  Get length   ${resp.json()[0]['message']}
    FOR   ${i}  IN RANGE   0   ${total_msg_count}
        IF    ${resp.json()[0]['message'][${i}]['read']} == ${bool[0]}
            ${unread_msg_count}=  Evaluate    ${unread_msg_count} + 1
        END
    END
    Set Suite Variable            ${unread_msg_count}
    
    Set Suite Variable            ${messageId1}                                                       ${resp.json()[0]['message'][0]['messageId']}
    Set Suite Variable            ${messageId2}                                                       ${resp.json()[0]['message'][1]['messageId']}
    Set Suite Variable            ${messageId3}                                                       ${resp.json()[0]['message'][2]['messageId']}
    Set Suite Variable            ${messageId4}                                                       ${resp.json()[0]['message'][3]['messageId']}
    Set Suite Variable            ${messageId5}                                                       ${resp.json()[0]['message'][4]['messageId']}

    Should Be Equal As Strings    ${resp.json()[0]['message'][0]['owner']['id']}                      ${cid}
    Should Be Equal As Strings    ${resp.json()[0]['message'][0]['owner']['userType']}                ${userType[8]}
    Should Be Equal As Strings    ${resp.json()[0]['message'][0]['owner']['name']}                    ${fullname}
    Should Be Equal As Strings    ${resp.json()[0]['message'][0]['owner']['jaldeeConsumerId']}        ${jconid}
    Should Be Equal As Strings    ${resp.json()[0]['message'][0]['msg']}                              ${communicationMessage}
    Should Be Equal As Strings    ${resp.json()[0]['message'][0]['receiver']['id']}                   ${pid}
    Should Be Equal As Strings    ${resp.json()[0]['message'][0]['receiver']['userType']}             ${userType[0]}
    Should Be Equal As Strings    ${resp.json()[0]['message'][0]['receiver']['name']}                 ${pdrname}
    Should Be Equal As Strings    ${resp.json()[0]['message'][0]['accountId']}                        ${accountId}
    Should Be Equal As Strings    ${resp.json()[0]['message'][0]['accountName']}                      ${accountName}
    Should Be Equal As Strings    ${resp.json()[0]['message'][0]['messageType']}                      ${messageType[0]}
    Should Be Equal As Strings    ${resp.json()[0]['message'][0]['attachmentList'][0]['owner']}       ${cid}
    Should Be Equal As Strings    ${resp.json()[0]['message'][0]['attachmentList'][0]['fileName']}    ${jpgfile}
    Should Be Equal As Strings    ${resp.json()[0]['message'][0]['attachmentList'][0]['fileSize']}    ${fileSize}
    Should Be Equal As Strings    ${resp.json()[0]['message'][0]['attachmentList'][0]['caption']}     ${caption}
    Should Be Equal As Strings    ${resp.json()[0]['message'][0]['attachmentList'][0]['fileType']}    ${fileType}
    Should Be Equal As Strings    ${resp.json()[0]['message'][0]['attachmentList'][0]['order']}       ${order}
    Should Be Equal As Strings    ${resp.json()[0]['message'][0]['attachmentList'][0]['action']}      ${file_action[0]}

    Should Be Equal As Strings    ${resp.json()[0]['message'][1]['owner']['id']}                      ${cid}
    Should Be Equal As Strings    ${resp.json()[0]['message'][1]['owner']['userType']}                ${userType[8]}
    Should Be Equal As Strings    ${resp.json()[0]['message'][1]['owner']['name']}                    ${fullname}
    Should Be Equal As Strings    ${resp.json()[0]['message'][1]['owner']['jaldeeConsumerId']}        ${jconid}
    Should Be Equal As Strings    ${resp.json()[0]['message'][1]['msg']}                              ${communicationMessage1}
    Should Be Equal As Strings    ${resp.json()[0]['message'][1]['receiver']['id']}                   ${pid}
    Should Be Equal As Strings    ${resp.json()[0]['message'][1]['receiver']['userType']}             ${userType[0]}
    Should Be Equal As Strings    ${resp.json()[0]['message'][1]['receiver']['name']}                 ${pdrname}
    Should Be Equal As Strings    ${resp.json()[0]['message'][1]['accountId']}                        ${accountId}
    Should Be Equal As Strings    ${resp.json()[0]['message'][1]['accountName']}                      ${accountName}
    Should Be Equal As Strings    ${resp.json()[0]['message'][1]['messageType']}                      ${messageType[0]}

    Should Be Equal As Strings    ${resp.json()[0]['message'][2]['owner']['id']}                      ${cid}
    Should Be Equal As Strings    ${resp.json()[0]['message'][2]['owner']['userType']}                ${userType[8]}
    Should Be Equal As Strings    ${resp.json()[0]['message'][2]['owner']['name']}                    ${fullname}
    Should Be Equal As Strings    ${resp.json()[0]['message'][2]['owner']['jaldeeConsumerId']}        ${jconid}
    Should Be Equal As Strings    ${resp.json()[0]['message'][2]['msg']}                              ${communicationMessage2}
    Should Be Equal As Strings    ${resp.json()[0]['message'][2]['receiver']['id']}                   ${pid}
    Should Be Equal As Strings    ${resp.json()[0]['message'][2]['receiver']['userType']}             ${userType[0]}
    Should Be Equal As Strings    ${resp.json()[0]['message'][2]['receiver']['name']}                 ${pdrname}
    Should Be Equal As Strings    ${resp.json()[0]['message'][2]['accountId']}                        ${accountId}
    Should Be Equal As Strings    ${resp.json()[0]['message'][2]['accountName']}                      ${accountName}
    Should Be Equal As Strings    ${resp.json()[0]['message'][2]['messageType']}                      ${messageType[1]}    

    Should Be Equal As Strings    ${resp.json()[0]['message'][3]['owner']['id']}                      ${cid}
    Should Be Equal As Strings    ${resp.json()[0]['message'][3]['owner']['userType']}                ${userType[8]}
    Should Be Equal As Strings    ${resp.json()[0]['message'][3]['owner']['name']}                    ${fullname}
    Should Be Equal As Strings    ${resp.json()[0]['message'][3]['owner']['jaldeeConsumerId']}        ${jconid}
    Should Be Equal As Strings    ${resp.json()[0]['message'][3]['msg']}                              ${communicationMessage3}
    Should Be Equal As Strings    ${resp.json()[0]['message'][3]['receiver']['id']}                   ${pid}
    Should Be Equal As Strings    ${resp.json()[0]['message'][3]['receiver']['userType']}             ${userType[0]}
    Should Be Equal As Strings    ${resp.json()[0]['message'][3]['receiver']['name']}                 ${pdrname}
    Should Be Equal As Strings    ${resp.json()[0]['message'][3]['accountId']}                        ${accountId}
    Should Be Equal As Strings    ${resp.json()[0]['message'][3]['accountName']}                      ${accountName}
    Should Be Equal As Strings    ${resp.json()[0]['message'][3]['messageType']}                      ${messageType[2]}

    Should Be Equal As Strings    ${resp.json()[0]['message'][4]['owner']['id']}                      ${cid}
    Should Be Equal As Strings    ${resp.json()[0]['message'][4]['owner']['userType']}                ${userType[8]}
    Should Be Equal As Strings    ${resp.json()[0]['message'][4]['owner']['name']}                    ${fullname}
    Should Be Equal As Strings    ${resp.json()[0]['message'][4]['owner']['jaldeeConsumerId']}        ${jconid}
    Should Be Equal As Strings    ${resp.json()[0]['message'][4]['msg']}                              ${communicationMessage4}
    Should Be Equal As Strings    ${resp.json()[0]['message'][4]['receiver']['id']}                   ${pid}
    Should Be Equal As Strings    ${resp.json()[0]['message'][4]['receiver']['userType']}             ${userType[0]}
    Should Be Equal As Strings    ${resp.json()[0]['message'][4]['receiver']['name']}                 ${pdrname}
    Should Be Equal As Strings    ${resp.json()[0]['message'][4]['accountId']}                        ${accountId}
    Should Be Equal As Strings    ${resp.json()[0]['message'][4]['accountName']}                      ${accountName}
    Should Be Equal As Strings    ${resp.json()[0]['message'][4]['messageType']}                      ${messageType[3]}

    Should Be Equal As Strings    ${resp.json()[0]['userTwoUnReadCount']}                             ${unread_msg_count}
    Should Be Equal As Strings    ${resp.json()[0]['userOne']}                                        ${cid}
    Should Be Equal As Strings    ${resp.json()[0]['userTypeOne']}                                    ${userType[8]}
    Should Be Equal As Strings    ${resp.json()[0]['userTwo']}                                        ${pid}
    Should Be Equal As Strings    ${resp.json()[0]['userTypeTwo']}                                    ${userType[0]}
    Should Be Equal As Strings    ${resp.json()[0]['consumerId']}                                     ${jconid}


JD-TC-Get Communication-UH1

    [Documentation]    Get Communication with invalid provider_consumer_id

    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings              ${resp.status_code}   200

    ${invpcid}    FakerLibrary.Random Number

    ${resp}=    Get Communication    ${invpcid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-Get Communication-UH2

    [Documentation]    Get Communication with provider id

    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings              ${resp.status_code}   200

    ${resp}=    Get Communication    ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-Get Communication-UH3

    [Documentation]    Get Communication without login

    ${resp}=    Get Communication    ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings    ${resp.json()}    ${SESSION_EXPIRED}


JD-TC-Get Communication-UH4

    [Documentation]    Get Communication where no communication made

    ${resp}=   ProviderLogin  ${PUSERNAME72}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings          ${resp.status_code}   200
    Set Suite Variable    ${pid}        ${resp.json()['id']}

    ${resp}=    Get Communication    ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  400
    Should Be Equal As Strings    ${resp.json()}    ${LOGIN_INVALID_URL}