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
${unread_msg_count2}     0
${new_unread_count}     0
${new_unread_count3}     0
${new_unread_count2}    0
${fileSize}    0.00458


*** Test Cases ***


JD-TC-Update read count-1

    [Documentation]    Update read count

    ${resp}=   Encrypted Provider Login  ${PUSERNAME93}  ${PASSWORD} 
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
    Set Suite Variable    ${attachment_list}

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
    Set Suite Variable    ${total_msg_count}
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

    ${resp}=    Update Read Count    ${cid}    ${userType[8]}    ${pid}    ${userType[0]}    ${messageId1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Communication    ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    FOR   ${i}  IN RANGE   0   ${total_msg_count}
        IF    ${resp.json()[0]['message'][${i}]['read']} == ${bool[0]}
            ${new_unread_count}=  Evaluate    ${new_unread_count} + 1
        END
    END
    Set Suite Variable            ${new_unread_count}


JD-TC-Update read count-2

    [Documentation]    Update read count which is already read

    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings              ${resp.status_code}   200

    ${resp}=    Update Read Count    ${cid}    ${userType[8]}    ${pid}    ${userType[0]}    ${messageId1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Communication    ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-Update read count-UH1

    [Documentation]    Update read count all messages read

    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings              ${resp.status_code}   200

    ${resp}=    Update Read Count    ${cid}    ${userType[8]}    ${pid}    ${userType[0]}    ${messageId2}-${messageId3}-${messageId4}-${messageId5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Communication    ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    FOR   ${i}  IN RANGE   0   ${total_msg_count}
        IF    ${resp.json()[0]['message'][${i}]['read']} == ${bool[0]}
            ${new_unread_count2}=  Evaluate    ${new_unread_count2} + 1
        END
    END
    Set Suite Variable            ${new_unread_count2}


JD-TC-Update read count-UH2

    [Documentation]    Update read count where id is invalid

    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings              ${resp.status_code}   200

    ${resp}=    Communication between Provider_consumer and provider    ${cid}    ${userType[8]}    ${pid}    ${userType[0]}    ${communicationMessage}    ${messageType[0]}   ${attachment_list}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}  200

    ${resp}=    Get Communication    ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${total_msg_count2}=  Get length   ${resp.json()[0]['message']}
    Set Suite Variable    ${total_msg_count2}
    FOR   ${i}  IN RANGE   0   ${total_msg_count2}
        IF    ${resp.json()[0]['message'][${i}]['read']} == ${bool[0]}
            ${unread_msg_count}=  Evaluate    ${unread_msg_count} + 1
        END
    END
    Set Suite Variable            ${unread_msg_count}

    ${inv_msg_id}    FakerLibrary.Random Number

    ${resp}=    Update Read Count    ${cid}    ${userType[8]}    ${pid}    ${userType[0]}    ${inv_msg_id} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Communication    ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    FOR   ${i}  IN RANGE   0   ${total_msg_count2}
        IF    ${resp.json()[0]['message'][${i}]['read']} == ${bool[0]}
            ${new_unread_count3}=  Evaluate    ${new_unread_count3} + 1
        END
    END
    Set Suite Variable            ${new_unread_count3}


JD-TC-Update read count-UH3

    [Documentation]    Update read count where sender id is invalid

    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}

    ${inv_cid}    FakerLibrary.Random Number

    ${resp}=    Update Read Count    ${inv_cid}    ${userType[8]}    ${pid}    ${userType[0]}    ${messageType[0]}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}    ${INVALID_CONSUMER_ID}


JD-TC-Update read count-UH4

    [Documentation]    Update read count where sender id is empty

    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}

    ${resp}=    Update Read Count    ${empty}    ${userType[8]}    ${pid}    ${userType[0]}    ${messageType[0]}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}    ${INVALID_USER_ID}


JD-TC-Update read count-UH5

    [Documentation]    Update read count where sender user type is empty

    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}

    ${resp}=    Update Read Count    ${cid}    ${empty}    ${pid}    ${userType[0]}    ${messageType[0]}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}  500


JD-TC-Update read count-UH6

    [Documentation]    Update read count where sender user type is wrong

    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}

    ${resp}=    Update Read Count    ${cid}    ${userType[6]}    ${pid}    ${userType[0]}    ${messageType[0]}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}  500


JD-TC-Update read count-UH7

    [Documentation]    Update read count where receiver id is wrong

    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}

    ${inv_pid}    FakerLibrary.Random Number

    ${resp}=    Update Read Count    ${cid}    ${userType[8]}    ${inv_pid}    ${userType[0]}    ${messageType[0]}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}    ${INVALID_PROVIDER_ID}


JD-TC-Update read count-UH8

    [Documentation]    Update read count where receiver id is empty

    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}

    ${resp}=    Update Read Count    ${cid}    ${userType[8]}    ${empty}    ${userType[0]}   ${messageType[0]}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}    ${INVALID_USER_ID}


JD-TC-Update read count-UH9

    [Documentation]    Update read count where receiver usertype is empty

    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}

    ${resp}=    Update Read Count    ${cid}    ${userType[8]}    ${pid}    ${empty}    ${messageType[0]}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}  500


JD-TC-Update read count-UH10

    [Documentation]    Update read count where receiver usertype is wrong

    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}

    ${resp}=    Update Read Count    ${cid}    ${userType[8]}    ${pid}    ${userType[1]}    ${messageType[0]}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}  500


JD-TC-Update read count-UH11

    [Documentation]    Update read count without login

    ${resp}=    Update Read Count    ${cid}    ${userType[8]}    ${pid}    ${userType[0]}    ${messageType[0]}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}  419
    Should Be Equal As Strings    ${resp.json()}    ${SESSION_EXPIRED}


JD-TC-Update read count-UH12

    [Documentation]    Update read count with provider login

    ${resp}=  Encrypted Provider Login  ${PUSERNAME42}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Update Read Count    ${cid}    ${userType[8]}    ${pid}    ${userType[0]}    ${messageType[0]}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}  400
    Should Be Equal As Strings    ${resp.json()}    ${LOGIN_INVALID_URL}