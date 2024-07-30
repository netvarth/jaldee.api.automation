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
${fileSize}    0.00458


*** Test Cases ***

JD-TC-Communication between Provider_consumer and provider-1

    [Documentation]    Communication between Provider_consumer and provider without attachment

    ${resp}=   Encrypted Provider Login  ${PUSERNAME70}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${pid}    ${resp.json()['id']}

    ${accountId}=    get_acc_id       ${PUSERNAME70}
    Set Suite Variable    ${accountId}

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
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}

    ${communicationMessage}    Fakerlibrary.word
    Set Suite Variable    ${communicationMessage}

    ${resp}=    Communication between Provider_consumer and provider    ${cid}    ${userType[8]}    ${pid}    ${userType[0]}    ${communicationMessage}    ${messageType[0]}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Communication    ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-Communication between Provider_consumer and provider-2

    [Documentation]    Communication between Provider_consumer and provider with attachment

    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}

    ${caption}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${jpgfile}
    ${attachment_list}=  Create Dictionary         owner=${cid}   fileName=${jpgfile}    fileSize= ${fileSize}     caption=${caption}     fileType=${fileType}   action=${file_action[0]}  order=${order}

    ${resp}=    Communication between Provider_consumer and provider    ${cid}    ${userType[8]}    ${pid}    ${userType[0]}    ${communicationMessage}    ${messageType[0]}   ${attachment_list}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}  200


JD-TC-Communication between Provider_consumer and provider-UH1

    [Documentation]    Communication between Provider_consumer and provider where sender id is invalid

    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}

    ${inv_cid}    FakerLibrary.Random Number

    ${resp}=    Communication between Provider_consumer and provider    ${inv_cid}    ${userType[8]}    ${pid}    ${userType[0]}    ${communicationMessage}    ${messageType[0]}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}    ${INVALID_CONSUMER_ID}


JD-TC-Communication between Provider_consumer and provider-UH2

    [Documentation]    Communication between Provider_consumer and provider where sender id is empty

    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}

    ${resp}=    Communication between Provider_consumer and provider    ${empty}    ${userType[8]}    ${pid}    ${userType[0]}    ${communicationMessage}    ${messageType[0]}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}    ${INVALID_USER_ID}


JD-TC-Communication between Provider_consumer and provider-UH3

    [Documentation]    Communication between Provider_consumer and provider where sender user type is empty

    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}

    ${resp}=    Communication between Provider_consumer and provider    ${cid}    ${empty}    ${pid}    ${userType[0]}    ${communicationMessage}    ${messageType[0]}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}  500


JD-TC-Communication between Provider_consumer and provider-UH4

    [Documentation]    Communication between Provider_consumer and provider where sender user type is wrong

    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}

    ${resp}=    Communication between Provider_consumer and provider    ${cid}    ${userType[6]}    ${pid}    ${userType[0]}    ${communicationMessage}    ${messageType[0]}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}  500


JD-TC-Communication between Provider_consumer and provider-UH5

    [Documentation]    Communication between Provider_consumer and provider where receiver id is wrong

    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}

    ${inv_pid}    FakerLibrary.Random Number

    ${resp}=    Communication between Provider_consumer and provider    ${cid}    ${userType[8]}    ${inv_pid}    ${userType[0]}    ${communicationMessage}    ${messageType[0]}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}    ${INVALID_PROVIDER_ID}


JD-TC-Communication between Provider_consumer and provider-UH6

    [Documentation]    Communication between Provider_consumer and provider where receiver id is empty

    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}

    ${resp}=    Communication between Provider_consumer and provider    ${cid}    ${userType[8]}    ${empty}    ${userType[0]}    ${communicationMessage}    ${messageType[0]}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}    ${INVALID_USER_ID}


JD-TC-Communication between Provider_consumer and provider-UH7

    [Documentation]    Communication between Provider_consumer and provider where receiver usertype is empty

    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}

    ${resp}=    Communication between Provider_consumer and provider    ${cid}    ${userType[8]}    ${pid}    ${empty}    ${communicationMessage}    ${messageType[0]}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}  500


JD-TC-Communication between Provider_consumer and provider-UH8

    [Documentation]    Communication between Provider_consumer and provider where receiver usertype is wrong

    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}

    ${resp}=    Communication between Provider_consumer and provider    ${cid}    ${userType[8]}    ${pid}    ${userType[1]}    ${communicationMessage}    ${messageType[0]}   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}  500


JD-TC-Communication between Provider_consumer and provider-UH9

    [Documentation]    Communication between Provider_consumer and provider where communication message is empty

    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}

    ${resp}=    Communication between Provider_consumer and provider    ${cid}    ${userType[8]}    ${pid}    ${userType[0]}    ${empty}    ${messageType[0]}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}  200


JD-TC-Communication between Provider_consumer and provider-UH10

    [Documentation]    Communication between Provider_consumer and provider where message type is ENQUIRY

    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}

    ${resp}=    Communication between Provider_consumer and provider    ${cid}    ${userType[8]}    ${pid}    ${userType[0]}    ${communicationMessage}    ${messageType[1]}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}  200


JD-TC-Communication between Provider_consumer and provider-UH11

    [Documentation]    Communication between Provider_consumer and provider where message type is ALERT

    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}

    ${resp}=    Communication between Provider_consumer and provider    ${cid}    ${userType[8]}    ${pid}    ${userType[0]}    ${communicationMessage}    ${messageType[2]}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}  200


JD-TC-Communication between Provider_consumer and provider-UH12

    [Documentation]    Communication between Provider_consumer and provider where message type is BOOKINGS

    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}

    ${resp}=    Communication between Provider_consumer and provider    ${cid}    ${userType[8]}    ${pid}    ${userType[0]}    ${communicationMessage}    ${messageType[3]}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}  200

    ${resp}=    Get Communication    ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-Communication between Provider_consumer and provider-UH13

    [Documentation]    Communication between Provider_consumer and provider without login

    ${resp}=    Communication between Provider_consumer and provider    ${cid}    ${userType[8]}    ${pid}    ${userType[0]}    ${communicationMessage}    ${messageType[0]}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}  419
    Should Be Equal As Strings    ${resp.json()}    ${SESSION_EXPIRED}


JD-TC-Communication between Provider_consumer and provider-UH14

    [Documentation]    Communication between Provider_consumer and provider where provider send to provider consumer
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME70}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Communication between Provider_consumer and provider    ${pid}    ${userType[0]}    ${cid}    ${userType[8]}    ${communicationMessage}    ${messageType[0]} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}  400
    Should Be Equal As Strings    ${resp.json()}    ${LOGIN_INVALID_URL}