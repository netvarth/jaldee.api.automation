*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        CDL Communication
Library           Collections
Library           String
Library           json
Library           DateTime
Library           requests
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Resource          /ebs/TDD/ApiKeywords.robot
Resource          /ebs/TDD/ProviderPartnerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumermail.py
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/hl_providers.py


*** Variables ***

${jpgfile}     /ebs/TDD/uploadimage.jpg
${pngfile}     /ebs/TDD/upload.png
${pdffile}     /ebs/TDD/sample.pdf
${order}    0
@{emptylist}


*** Test Cases ***

JD-TC-GetFullCommunicationOfUser-1

    [Documentation]   Provider send a message to a jaldee consumer without any attachment,
    ...   then verify the communication details.


    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${consumer_id}   ${resp.json()['id']}

    ${resp}=  ConsumerLogout  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME55}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${provider_id1}  ${resp.json()['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}

    clear_customer  ${PUSERNAME55} 

    ${comm_msg}=  Fakerlibrary.sentence
    ${caption}=  Fakerlibrary.sentence
    ${resp}=  Send Message   ${user[2]}  ${comm_msg}  ${provider_id1}  ${userType[0]}  ${consumer_id}  ${userType[3]}  ${messageType[0]}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}   []

    ${resp}=   Get Full Communication Of User  ${user[2]}  ${provider_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['owner']['id']}              ${provider_id1}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['owner']['userType']}        ${userType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['msg']}                      ${comm_msg}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['receiver']['userType']}     ${userType[8]}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['accountId']}                ${account_id1}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['read']}                     ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['messageType']}              ${messageType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['attachmentList']}           []
    Should Be Equal As Strings  ${resp.json()[0]['consumerId']}                             ${consumer_id}

JD-TC-GetFullCommunicationOfUser-2

    [Documentation]   Provider send a message(enquiry) to a jaldee consumer without any attachment,
    ...   then verify the communication details.


    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${consumer_id}   ${resp.json()['id']}

    ${resp}=  ConsumerLogout  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME60}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${provider_id1}  ${resp.json()['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}

    clear_customer  ${PUSERNAME60} 

    ${comm_msg}=  Fakerlibrary.sentence
    ${caption}=  Fakerlibrary.sentence
    ${resp}=  Send Message   ${user[2]}  ${comm_msg}  ${provider_id1}  ${userType[0]}  ${consumer_id}  ${userType[3]}  ${messageType[1]}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}   []

    ${resp}=   Get Full Communication Of User  ${user[2]}  ${provider_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['owner']['id']}              ${provider_id1}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['owner']['userType']}        ${userType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['msg']}                      ${comm_msg}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['receiver']['userType']}     ${userType[8]}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['accountId']}                ${account_id1}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['read']}                     ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['messageType']}              ${messageType[1]}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['attachmentList']}           []
    Should Be Equal As Strings  ${resp.json()[0]['consumerId']}                             ${consumer_id}

JD-TC-GetFullCommunicationOfUser-3

    [Documentation]   Provider send a message(alert) to a jaldee consumer without any attachment,
    ...   then verify the communication details.


    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${consumer_id}   ${resp.json()['id']}

    ${resp}=  ConsumerLogout  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME61}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${provider_id1}  ${resp.json()['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}

    clear_customer  ${PUSERNAME61} 

    ${comm_msg}=  Fakerlibrary.sentence
    ${caption}=  Fakerlibrary.sentence
    ${resp}=  Send Message   ${user[2]}  ${comm_msg}  ${provider_id1}  ${userType[0]}  ${consumer_id}  ${userType[3]}  ${messageType[2]}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}   []

    ${resp}=   Get Full Communication Of User  ${user[2]}  ${provider_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['owner']['id']}              ${provider_id1}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['owner']['userType']}        ${userType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['msg']}                      ${comm_msg}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['receiver']['userType']}     ${userType[8]}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['accountId']}                ${account_id1}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['read']}                     ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['messageType']}              ${messageType[2]}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['attachmentList']}           []
    Should Be Equal As Strings  ${resp.json()[0]['consumerId']}                             ${consumer_id}

JD-TC-GetFullCommunicationOfUser-4

    [Documentation]   Provider send a message(bookings) to a jaldee consumer without any attachment,
    ...   then verify the communication details.


    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${consumer_id}   ${resp.json()['id']}

    ${resp}=  ConsumerLogout  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME62}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${provider_id1}  ${resp.json()['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}

    clear_customer  ${PUSERNAME62} 

    ${comm_msg}=  Fakerlibrary.sentence
    ${caption}=  Fakerlibrary.sentence
    ${resp}=  Send Message   ${user[2]}  ${comm_msg}  ${provider_id1}  ${userType[0]}  ${consumer_id}  ${userType[3]}  ${messageType[3]}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}   []

    ${resp}=   Get Full Communication Of User  ${user[2]}  ${provider_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['owner']['id']}              ${provider_id1}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['owner']['userType']}        ${userType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['msg']}                      ${comm_msg}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['receiver']['userType']}     ${userType[8]}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['accountId']}                ${account_id1}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['read']}                     ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['messageType']}              ${messageType[3]}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['attachmentList']}           []
    Should Be Equal As Strings  ${resp.json()[0]['consumerId']}                             ${consumer_id}

JD-TC-GetFullCommunicationOfUser-5

    [Documentation]   Provider send a message to a jaldee consumer with one attachment,
    ...   then verify the communication details.


    ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${consumer_id}   ${resp.json()['id']}

    ${resp}=  ConsumerLogout  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME21}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}

    ${caption}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${jpgfile}
    ${attachment_list}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption}     fileType=${fileType}   action=${file_action[0]}  order=${order}

    ${comm_msg}=  Fakerlibrary.sentence
    ${resp}=  Send Message   ${user[2]}  ${comm_msg}  ${provider_id}  ${userType[0]}  ${consumer_id}  ${userType[3]}  ${messageType[0]}  ${attachment_list}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Full Communication Of User  ${user[2]}  ${provider_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['owner']['id']}              ${provider_id}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['owner']['userType']}        ${userType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['msg']}                      ${comm_msg}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['receiver']['userType']}     ${userType[8]}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['accountId']}                ${account_id1}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['read']}                     ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['messageType']}              ${messageType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['consumerId']}                             ${consumer_id}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['attachmentList'][0]['caption']}           ${caption}

JD-TC-GetFullCommunicationOfUser-6

    [Documentation]   verify communication details without sending any msg.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME56}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${provider_id1}  ${resp.json()['id']}

    ${resp}=   Get Full Communication Of User  ${user[2]}  ${provider_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}   []


JD-TC-GetFullCommunicationOfUser-7

    [Documentation]   Provider send a message(enquiry) to a jaldee consumer with one attachment,
    ...   then consumer verify the communication details.


    ${resp}=  Consumer Login  ${CUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${consumer_id}   ${resp.json()['id']}

    ${resp}=  ConsumerLogout  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME25}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}

    ${caption}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${jpgfile}
    ${attachment_list}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption}     fileType=${fileType}   action=${file_action[0]}  order=${order}

    ${comm_msg}=  Fakerlibrary.sentence
    ${resp}=  Send Message   ${user[2]}  ${comm_msg}  ${provider_id}  ${userType[0]}  ${consumer_id}  ${userType[3]}  ${messageType[1]}  ${attachment_list}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Full Communication Of User  ${user[2]}  ${provider_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['owner']['id']}              ${provider_id}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['owner']['userType']}        ${userType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['msg']}                      ${comm_msg}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['receiver']['userType']}     ${userType[8]}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['accountId']}                ${account_id1}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['read']}                     ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['messageType']}              ${messageType[1]}
    Should Be Equal As Strings  ${resp.json()[0]['consumerId']}                             ${consumer_id}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['attachmentList'][0]['caption']}           ${caption}


JD-TC-GetFullCommunicationOfUser-8

    [Documentation]   Provider send a message(alert) to a jaldee consumer with one attachment,
    ...   then consumer verify the communication details.


    ${resp}=  Consumer Login  ${CUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${consumer_id}   ${resp.json()['id']}

    ${resp}=  ConsumerLogout  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}

    ${caption}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${jpgfile}
    ${attachment_list}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption}     fileType=${fileType}   action=${file_action[0]}  order=${order}

    ${comm_msg}=  Fakerlibrary.sentence
    ${resp}=  Send Message   ${user[2]}  ${comm_msg}  ${provider_id}  ${userType[0]}  ${consumer_id}  ${userType[3]}  ${messageType[2]}  ${attachment_list}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Full Communication Of User  ${user[2]}  ${provider_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['owner']['id']}              ${provider_id}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['owner']['userType']}        ${userType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['msg']}                      ${comm_msg}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['receiver']['userType']}     ${userType[8]}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['accountId']}                ${account_id1}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['read']}                     ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['messageType']}              ${messageType[2]}
    Should Be Equal As Strings  ${resp.json()[0]['consumerId']}                             ${consumer_id}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['attachmentList'][0]['caption']}           ${caption}


JD-TC-GetFullCommunicationOfUser-9

    [Documentation]   Provider send a message(bookings) to a jaldee consumer with one attachment,
    ...   then consumer verify the communication details.


    ${resp}=  Consumer Login  ${CUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${consumer_id}   ${resp.json()['id']}

    ${resp}=  ConsumerLogout  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME27}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}

    ${caption}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${jpgfile}
    ${attachment_list}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption}     fileType=${fileType}   action=${file_action[0]}  order=${order}

    ${comm_msg}=  Fakerlibrary.sentence
    ${resp}=  Send Message   ${user[2]}  ${comm_msg}  ${provider_id}  ${userType[0]}  ${consumer_id}  ${userType[3]}  ${messageType[3]}  ${attachment_list}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Full Communication Of User  ${user[2]}  ${provider_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['owner']['id']}              ${provider_id}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['owner']['userType']}        ${userType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['msg']}                      ${comm_msg}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['receiver']['userType']}     ${userType[8]}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['accountId']}                ${account_id1}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['read']}                     ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['messageType']}              ${messageType[3]}
    Should Be Equal As Strings  ${resp.json()[0]['consumerId']}                             ${consumer_id}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['attachmentList'][0]['caption']}           ${caption}


JD-TC-GetFullCommunicationOfUser-10

    [Documentation]   Provider send a message(chat) to a jaldee consumer with more than 
    ...  one attachment, then verify the communication details.


    ${resp}=  Consumer Login  ${CUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${consumer_id}   ${resp.json()['id']}

    ${resp}=  ConsumerLogout  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}

    ${caption}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${jpgfile}
    ${attachment_list}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption}     fileType=${fileType}   action=${file_action[0]}  order=${order}

    ${caption1}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${pngfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${pngfile}
    ${attachment_list1}=  Create Dictionary         owner=${provider_id}   fileName=${pngfile}    fileSize= 0.00458     caption=${caption1}     fileType=${fileType1}   action=${file_action[0]}  order=${order}

    ${comm_msg}=  Fakerlibrary.sentence
    ${resp}=  Send Message   ${user[2]}  ${comm_msg}  ${provider_id}  ${userType[0]}  ${consumer_id}  ${userType[3]}  ${messageType[0]}  ${attachment_list}  ${attachment_list1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Full Communication Of User  ${user[2]}  ${provider_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['owner']['id']}              ${provider_id}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['owner']['userType']}        ${userType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['msg']}                      ${comm_msg}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['receiver']['userType']}     ${userType[8]}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['accountId']}                ${account_id1}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['read']}                     ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['messageType']}              ${messageType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['consumerId']}                             ${consumer_id}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['attachmentList'][0]['caption']}           ${caption}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['attachmentList'][1]['caption']}           ${caption1}


JD-TC-GetFullCommunicationOfUser-11

    [Documentation]   Provider send a message(enquiry) to a jaldee consumer with more than 
    ...  one attachment, then verify the communication details.


    ${resp}=  Consumer Login  ${CUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${consumer_id}   ${resp.json()['id']}

    ${resp}=  ConsumerLogout  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME29}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}

    ${caption}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${jpgfile}
    ${attachment_list}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption}     fileType=${fileType}   action=${file_action[0]}  order=${order}

    ${caption1}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${pngfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${pngfile}
    ${attachment_list1}=  Create Dictionary         owner=${provider_id}   fileName=${pngfile}    fileSize= 0.00458     caption=${caption1}     fileType=${fileType1}   action=${file_action[0]}  order=${order}

    ${comm_msg}=  Fakerlibrary.sentence
    ${resp}=  Send Message   ${user[2]}  ${comm_msg}  ${provider_id}  ${userType[0]}  ${consumer_id}  ${userType[3]}  ${messageType[1]}  ${attachment_list}  ${attachment_list1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Full Communication Of User  ${user[2]}  ${provider_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['owner']['id']}              ${provider_id}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['owner']['userType']}        ${userType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['msg']}                      ${comm_msg}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['receiver']['userType']}     ${userType[8]}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['accountId']}                ${account_id1}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['read']}                     ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['messageType']}              ${messageType[1]}
    Should Be Equal As Strings  ${resp.json()[0]['consumerId']}                             ${consumer_id}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['attachmentList'][0]['caption']}           ${caption}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['attachmentList'][1]['caption']}           ${caption1}


JD-TC-GetFullCommunicationOfUser-12

    [Documentation]   Provider send a message to a provider consumer with one attachment
    ...   then verify the communication details.


    ${resp}=  Encrypted Provider Login  ${PUSERNAME37}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}

    ${fname}=  Fakerlibrary.firstname
    ${lname}=  Fakerlibrary.lastname
    ${PO_Number}=  Generate Random Phone Number
    ${phone}=  Convert To Integer    ${PO_Number}
        ${resp}=  GetCustomer  phoneNo-eq=${phone}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${phone}  firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid}  ${resp.json()[0]['id']}
    END

    ${caption}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${jpgfile}
    ${attachment_list}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption}     fileType=${fileType}   action=${file_action[0]}  order=${order}

    ${comm_msg}=  Fakerlibrary.sentence
    ${resp}=  Send Message   ${user[2]}  ${comm_msg}  ${provider_id}  ${userType[0]}  ${pcid}  ${userType[3]}  ${messageType[0]}  ${attachment_list}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Full Communication Of User  ${user[2]}  ${provider_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['owner']['id']}              ${provider_id}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['owner']['userType']}        ${userType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['msg']}                      ${comm_msg}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['receiver']['userType']}     ${userType[8]}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['accountId']}                ${account_id1}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['read']}                     ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['messageType']}              ${messageType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['consumerId']}                             ${pcid}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['attachmentList'][0]['caption']}           ${caption}


JD-TC-GetFullCommunicationOfUser-13

    [Documentation]   Provider send a message(enqiury) to a provider consumer with one attachment
    ...   then verify the communication details.


    ${resp}=  Encrypted Provider Login  ${PUSERNAME31}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}

    ${fname}=  Fakerlibrary.firstname
    ${lname}=  Fakerlibrary.lastname
    ${PO_Number}=  Generate Random Phone Number
    ${phone}=  Convert To Integer    ${PO_Number}
        ${resp}=  GetCustomer  phoneNo-eq=${phone}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${phone}  firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid}  ${resp.json()[0]['id']}
    END

    ${caption}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${jpgfile}
    ${attachment_list}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption}     fileType=${fileType}   action=${file_action[0]}  order=${order}

    ${comm_msg}=  Fakerlibrary.sentence
    ${resp}=  Send Message   ${user[2]}  ${comm_msg}  ${provider_id}  ${userType[0]}  ${pcid}  ${userType[3]}  ${messageType[1]}  ${attachment_list}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Full Communication Of User  ${user[2]}  ${provider_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['owner']['id']}              ${provider_id}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['owner']['userType']}        ${userType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['msg']}                      ${comm_msg}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['receiver']['userType']}     ${userType[8]}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['accountId']}                ${account_id1}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['read']}                     ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['messageType']}              ${messageType[1]}
    Should Be Equal As Strings  ${resp.json()[0]['consumerId']}                             ${pcid}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['attachmentList'][0]['caption']}           ${caption}

JD-TC-GetFullCommunicationOfUser-14

    [Documentation]   Provider send a message to a partner with one attachment
    ...   then verify the communication details.


    ${resp}=  Encrypted Provider Login  ${PUSERNAME33}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    IF  ${resp.json()['enableBranchMaster']}==${bool[0]}
        ${resp1}=  Enable Disable Branch    ${status[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableBranchMaster']}  ${bool[1]}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        Set Test Variable  ${locId}

        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${locname}  ${resp.json()['place']}
        
    ELSE
        Set Test Variable  ${locId}  ${resp.json()[0]['id']}
        Set Test Variable  ${locname}  ${resp.json()[0]['place']}
    END

    ${branchCode}=    FakerLibrary.Random Number
    ${branchName}=    FakerLibrary.name
   
    ${resp}=    Create BranchMaster    ${branchCode}    ${branchName}    ${locId}    ${status[0]}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${branchid1}  ${resp.json()['id']}

    ${resp}=    Change Branch Status    ${branchid1}    ${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${PH_Number}    Random Number 	digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Test Variable  ${phone}  555${PH_Number}
    ${dealerfname}=  FakerLibrary.name
    ${dealername}=  FakerLibrary.bs
    ${dealerlname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
   
    ${resp}=  Generate Phone Partner Creation    ${phone}    ${countryCodes[0]}    partnerName=${dealername}   partnerUserFirstName=${dealerfname}  partnerUserLastName=${dealerlname}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
   
    ${branch}=      Create Dictionary   id=${branchid1}

    ${resp}=  Verify Phone Partner Creation    ${phone}   ${OtpPurpose['ProviderVerifyPhone']}    ${dealerfname}   ${dealerlname}   branch=${branch}    partnerUserFirstName=${dealerfname}  partnerUserLastName=${dealerlname}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Test Variable  ${partid1}  ${resp.json()['id']}
    Set Test Variable  ${partuid1}  ${resp.json()['uid']} 

    ${caption}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${jpgfile}
    ${attachment_list}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption}     fileType=${fileType}   action=${file_action[0]}  order=${order}

    ${comm_msg}=  Fakerlibrary.sentence
    ${resp}=  Send Message   ${user[2]}  ${comm_msg}  ${provider_id}  ${userType[0]}  ${partid1}  ${userType[3]}  ${messageType[0]}  ${attachment_list}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Full Communication Of User  ${user[2]}  ${provider_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['owner']['id']}              ${provider_id}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['owner']['userType']}        ${userType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['msg']}                      ${comm_msg}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['receiver']['userType']}     ${userType[8]}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['accountId']}                ${account_id1}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['read']}                     ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['messageType']}              ${messageType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['consumerId']}                             ${partid1}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['attachmentList'][0]['caption']}           ${caption}


JD-TC-GetFullCommunicationOfUser-15

    [Documentation]   Provider send a message(enquiry) to a partner with one attachment
    ...   then verify the communication details.


    ${resp}=  Encrypted Provider Login  ${PUSERNAME53}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    IF  ${resp.json()['enableBranchMaster']}==${bool[0]}
        ${resp1}=  Enable Disable Branch    ${status[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableBranchMaster']}  ${bool[1]}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        Set Test Variable  ${locId}

        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${locname}  ${resp.json()['place']}
        
    ELSE
        Set Test Variable  ${locId}  ${resp.json()[0]['id']}
        Set Test Variable  ${locname}  ${resp.json()[0]['place']}
    END

    ${branchCode}=    FakerLibrary.Random Number
    ${branchName}=    FakerLibrary.name
   
    ${resp}=    Create BranchMaster    ${branchCode}    ${branchName}    ${locId}    ${status[0]}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${branchid1}  ${resp.json()['id']}

    ${resp}=    Change Branch Status    ${branchid1}    ${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${PH_Number}    Random Number 	digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Test Variable  ${phone}  555${PH_Number}
    ${dealerfname}=  FakerLibrary.name
    ${dealername}=  FakerLibrary.bs
    ${dealerlname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
   
    ${resp}=  Generate Phone Partner Creation    ${phone}    ${countryCodes[0]}    partnerName=${dealername}   partnerUserFirstName=${dealerfname}  partnerUserLastName=${dealerlname}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
   
    ${branch}=      Create Dictionary   id=${branchid1}

    ${resp}=  Verify Phone Partner Creation    ${phone}   ${OtpPurpose['ProviderVerifyPhone']}    ${dealerfname}   ${dealerlname}   branch=${branch}    partnerUserFirstName=${dealerfname}  partnerUserLastName=${dealerlname}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Test Variable  ${partid1}  ${resp.json()['id']}
    Set Test Variable  ${partuid1}  ${resp.json()['uid']} 

    ${caption}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${jpgfile}
    ${attachment_list}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption}     fileType=${fileType}   action=${file_action[0]}  order=${order}

    ${comm_msg}=  Fakerlibrary.sentence
    ${resp}=  Send Message   ${user[2]}  ${comm_msg}  ${provider_id}  ${userType[0]}  ${partid1}  ${userType[3]}  ${messageType[1]}  ${attachment_list}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Full Communication Of User  ${user[2]}  ${provider_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['owner']['id']}              ${provider_id}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['owner']['userType']}        ${userType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['msg']}                      ${comm_msg}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['receiver']['userType']}     ${userType[8]}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['accountId']}                ${account_id1}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['read']}                     ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['messageType']}              ${messageType[1]}
    Should Be Equal As Strings  ${resp.json()[0]['consumerId']}                             ${partid1}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['attachmentList'][0]['caption']}           ${caption}


JD-TC-GetFullCommunicationOfUser-16

    [Documentation]   Provider send a message(alert) to a partner with one attachment
    ...   then verify the communication details.


    ${resp}=  Encrypted Provider Login  ${PUSERNAME54}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    IF  ${resp.json()['enableBranchMaster']}==${bool[0]}
        ${resp1}=  Enable Disable Branch    ${status[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableBranchMaster']}  ${bool[1]}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        Set Test Variable  ${locId}

        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${locname}  ${resp.json()['place']}
        
    ELSE
        Set Test Variable  ${locId}  ${resp.json()[0]['id']}
        Set Test Variable  ${locname}  ${resp.json()[0]['place']}
    END

    ${branchCode}=    FakerLibrary.Random Number
    ${branchName}=    FakerLibrary.name
   
    ${resp}=    Create BranchMaster    ${branchCode}    ${branchName}    ${locId}    ${status[0]}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${branchid1}  ${resp.json()['id']}

    ${resp}=    Change Branch Status    ${branchid1}    ${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${PH_Number}    Random Number 	digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Test Variable  ${phone}  555${PH_Number}
    ${dealerfname}=  FakerLibrary.name
    ${dealername}=  FakerLibrary.bs
    ${dealerlname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
   
    ${resp}=  Generate Phone Partner Creation    ${phone}    ${countryCodes[0]}    partnerName=${dealername}   partnerUserFirstName=${dealerfname}  partnerUserLastName=${dealerlname}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
   
    ${branch}=      Create Dictionary   id=${branchid1}

    ${resp}=  Verify Phone Partner Creation    ${phone}   ${OtpPurpose['ProviderVerifyPhone']}    ${dealerfname}   ${dealerlname}   branch=${branch}    partnerUserFirstName=${dealerfname}  partnerUserLastName=${dealerlname}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Test Variable  ${partid1}  ${resp.json()['id']}
    Set Test Variable  ${partuid1}  ${resp.json()['uid']} 

    ${caption}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${jpgfile}
    ${attachment_list}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption}     fileType=${fileType}   action=${file_action[0]}  order=${order}

    ${comm_msg}=  Fakerlibrary.sentence
    ${resp}=  Send Message   ${user[2]}  ${comm_msg}  ${provider_id}  ${userType[0]}  ${partid1}  ${userType[3]}  ${messageType[2]}  ${attachment_list}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Full Communication Of User  ${user[2]}  ${provider_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['owner']['id']}              ${provider_id}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['owner']['userType']}        ${userType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['msg']}                      ${comm_msg}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['receiver']['userType']}     ${userType[8]}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['accountId']}                ${account_id1}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['read']}                     ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['messageType']}              ${messageType[2]}
    Should Be Equal As Strings  ${resp.json()[0]['consumerId']}                             ${partid1}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['attachmentList'][0]['caption']}           ${caption}


JD-TC-GetFullCommunicationOfUser-17

    [Documentation]   Provider send a message(bookings) to a partner with one attachment
    ...   then verify the communication details.


    ${resp}=  Encrypted Provider Login  ${PUSERNAME55}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    IF  ${resp.json()['enableBranchMaster']}==${bool[0]}
        ${resp1}=  Enable Disable Branch    ${status[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableBranchMaster']}  ${bool[1]}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        Set Test Variable  ${locId}

        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${locname}  ${resp.json()['place']}
        
    ELSE
        Set Test Variable  ${locId}  ${resp.json()[0]['id']}
        Set Test Variable  ${locname}  ${resp.json()[0]['place']}
    END

    ${branchCode}=    FakerLibrary.Random Number
    ${branchName}=    FakerLibrary.name
   
    ${resp}=    Create BranchMaster    ${branchCode}    ${branchName}    ${locId}    ${status[0]}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${branchid1}  ${resp.json()['id']}

    ${resp}=    Change Branch Status    ${branchid1}    ${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${PH_Number}    Random Number 	digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Test Variable  ${phone}  555${PH_Number}
    ${dealerfname}=  FakerLibrary.name
    ${dealername}=  FakerLibrary.bs
    ${dealerlname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
   
    ${resp}=  Generate Phone Partner Creation    ${phone}    ${countryCodes[0]}    partnerName=${dealername}   partnerUserFirstName=${dealerfname}  partnerUserLastName=${dealerlname}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
   
    ${branch}=      Create Dictionary   id=${branchid1}

    ${resp}=  Verify Phone Partner Creation    ${phone}   ${OtpPurpose['ProviderVerifyPhone']}    ${dealerfname}   ${dealerlname}   branch=${branch}    partnerUserFirstName=${dealerfname}  partnerUserLastName=${dealerlname}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Test Variable  ${partid1}  ${resp.json()['id']}
    Set Test Variable  ${partuid1}  ${resp.json()['uid']} 

    ${caption}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${jpgfile}
    ${attachment_list}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption}     fileType=${fileType}   action=${file_action[0]}  order=${order}

    ${comm_msg}=  Fakerlibrary.sentence
    ${resp}=  Send Message   ${user[2]}  ${comm_msg}  ${provider_id}  ${userType[0]}  ${partid1}  ${userType[3]}  ${messageType[3]}  ${attachment_list}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Full Communication Of User  ${user[2]}  ${provider_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['owner']['id']}              ${provider_id}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['owner']['userType']}        ${userType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['msg']}                      ${comm_msg}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['receiver']['userType']}     ${userType[8]}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['accountId']}                ${account_id1}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['read']}                     ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['messageType']}              ${messageType[3]}
    Should Be Equal As Strings  ${resp.json()[0]['consumerId']}                             ${partid1}
    Should Be Equal As Strings  ${resp.json()[0]['message'][0]['attachmentList'][0]['caption']}           ${caption}

