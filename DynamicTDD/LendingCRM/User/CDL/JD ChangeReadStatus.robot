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
Variables         /ebs/TDD/varfiles/musers.py
Variables         /ebs/TDD/varfiles/consumermail.py
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/hl_musers.py


*** Variables ***

${jpgfile}     /ebs/TDD/uploadimage.jpg
${pngfile}     /ebs/TDD/upload.png
${pdffile}     /ebs/TDD/sample.pdf
${order}    0
@{emptylist}


*** Test Cases ***

JD-TC-ChangeReadStatus-1

    [Documentation]   Provider send a message to a jaldee consumer without any attachment and
    ...   change the read status of that communication.


    ${resp}=  Consumer Login  ${CUSERNAME30}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${consumer_id2}   ${resp.json()['id']}

    clear_Consumermsg  ${CUSERNAME30}

    ${resp}=  ConsumerLogout  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${MUSERNAME90}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${provider_id1}  ${decrypted_data['id']}

    ${comm_msg}=  Fakerlibrary.sentence
    ${caption}=  Fakerlibrary.sentence
    ${resp}=  Send Message   ${user[2]}  ${comm_msg}  ${provider_id1}  ${userType[0]}  ${consumer_id2}  ${userType[3]}  ${messageType[0]}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}   []

    ${resp}=   Get Full Communication Of User  ${user[2]}  ${provider_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['userTwoUnReadCount']}       1
    Set Suite Variable  ${msgId1}  ${resp.json()[0]['message'][0]['messageId']}

    ${resp}=  Change Read Status  ${user[2]}  ${provider_id1}   ${userType[0]}  ${consumer_id2}  ${userType[3]}   ${msgId1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Full Communication Of User  ${user[2]}  ${provider_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['userTwoUnReadCount']}       0

JD-TC-ChangeReadStatus-2

    [Documentation]   Provider send multiple messages to a jaldee consumer without any attachment and
    ...   change the read status of that messages.


    ${resp}=  Consumer Login  ${CUSERNAME31}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${consumer_id}   ${resp.json()['id']}

    clear_Consumermsg  ${CUSERNAME31}

    ${resp}=  ConsumerLogout  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${MUSERNAME91}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${provider_id}  ${decrypted_data['id']}
    
    ${comm_msg}=  Fakerlibrary.sentence
    ${caption}=  Fakerlibrary.sentence
    ${resp}=  Send Message   ${user[2]}  ${comm_msg}  ${provider_id}  ${userType[0]}  ${consumer_id}  ${userType[3]}  ${messageType[0]}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${comm_msg}=  Fakerlibrary.sentence
    ${caption}=  Fakerlibrary.sentence
    ${resp}=  Send Message   ${user[2]}  ${comm_msg}  ${provider_id}  ${userType[0]}  ${consumer_id}  ${userType[3]}  ${messageType[0]}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Full Communication Of User  ${user[2]}  ${provider_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['userTwoUnReadCount']}       2
    Set Test Variable  ${msgId1}  ${resp.json()[0]['message'][0]['messageId']}
    Set Test Variable  ${msgId2}  ${resp.json()[0]['message'][1]['messageId']}

    ${resp}=  Change Read Status  ${user[2]}  ${provider_id}   ${userType[0]}  ${consumer_id}  ${userType[3]}   ${msgId1}-${msgId2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Full Communication Of User  ${user[2]}  ${provider_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['userTwoUnReadCount']}       0


JD-TC-ChangeReadStatus-3

    [Documentation]   Provider send multiple messages to a jaldee consumer without any attachment and
    ...   change the read status of one of the messages.


    ${resp}=  Consumer Login  ${CUSERNAME32}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${consumer_id}   ${resp.json()['id']}

    clear_Consumermsg  ${CUSERNAME32}

    ${resp}=  ConsumerLogout  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${MUSERNAME92}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${provider_id}  ${decrypted_data['id']}

    clear_Providermsg  ${MUSERNAME92}
    
    ${comm_msg}=  Fakerlibrary.sentence
    ${caption}=  Fakerlibrary.sentence
    ${resp}=  Send Message   ${user[2]}  ${comm_msg}  ${provider_id}  ${userType[0]}  ${consumer_id}  ${userType[3]}  ${messageType[0]}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${comm_msg}=  Fakerlibrary.sentence
    ${caption}=  Fakerlibrary.sentence
    ${resp}=  Send Message   ${user[2]}  ${comm_msg}  ${provider_id}  ${userType[0]}  ${consumer_id}  ${userType[3]}  ${messageType[0]}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Full Communication Of User  ${user[2]}  ${provider_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['userTwoUnReadCount']}       2
    Set Test Variable  ${msgId1}  ${resp.json()[0]['message'][0]['messageId']}
    Set Test Variable  ${msgId2}  ${resp.json()[0]['message'][1]['messageId']}

    ${resp}=  Change Read Status  ${user[2]}  ${provider_id}   ${userType[0]}  ${consumer_id}  ${userType[3]}   ${msgId2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Full Communication Of User  ${user[2]}  ${provider_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['userTwoUnReadCount']}       1


JD-TC-ChangeReadStatus-4

    [Documentation]   Provider send a message(enquiry) to a jaldee consumer without any attachment and
    ...   change the read status of that communication.


    ${resp}=  Consumer Login  ${CUSERNAME32}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${consumer_id}   ${resp.json()['id']}

    clear_Consumermsg  ${CUSERNAME32}

    ${resp}=  ConsumerLogout  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${MUSERNAME94}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${provider_id}  ${decrypted_data['id']}

    ${comm_msg}=  Fakerlibrary.sentence
    ${caption}=  Fakerlibrary.sentence
    ${resp}=  Send Message   ${user[2]}  ${comm_msg}  ${provider_id}  ${userType[0]}  ${consumer_id}  ${userType[3]}  ${messageType[1]}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}   []

    ${resp}=   Get Full Communication Of User  ${user[2]}  ${provider_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['userTwoUnReadCount']}       1
    Set Test Variable  ${msgId1}  ${resp.json()[0]['message'][0]['messageId']}

    ${resp}=  Change Read Status  ${user[2]}  ${provider_id}   ${userType[0]}  ${consumer_id}  ${userType[3]}   ${msgId1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Full Communication Of User  ${user[2]}  ${provider_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['userTwoUnReadCount']}       0
      

JD-TC-ChangeReadStatus-5

    [Documentation]   Provider send a message(alert) to a jaldee consumer without any attachment and
    ...   change the read status of that communication.

    ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${consumer_id}   ${resp.json()['id']}

    clear_Consumermsg  ${CUSERNAME1}

    ${resp}=  ConsumerLogout  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${MUSERNAME95}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${provider_id}  ${decrypted_data['id']}

    ${comm_msg}=  Fakerlibrary.sentence
    ${caption}=  Fakerlibrary.sentence
    ${resp}=  Send Message   ${user[2]}  ${comm_msg}  ${provider_id}  ${userType[0]}  ${consumer_id}  ${userType[3]}  ${messageType[2]}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}   []

    ${resp}=   Get Full Communication Of User  ${user[2]}  ${provider_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['userTwoUnReadCount']}       1
    Set Test Variable  ${msgId1}  ${resp.json()[0]['message'][0]['messageId']}

    ${resp}=  Change Read Status  ${user[2]}  ${provider_id}   ${userType[0]}  ${consumer_id}  ${userType[3]}   ${msgId1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Full Communication Of User  ${user[2]}  ${provider_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['userTwoUnReadCount']}       0

JD-TC-ChangeReadStatus-6

    [Documentation]   Provider send a message(bookings) to a jaldee consumer without any attachment and
    ...   change the read status of that communication.

    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${consumer_id}   ${resp.json()['id']}

    clear_Consumermsg  ${CUSERNAME2}

    ${resp}=  ConsumerLogout  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${MUSERNAME96}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${provider_id}  ${decrypted_data['id']}

    ${comm_msg}=  Fakerlibrary.sentence
    ${caption}=  Fakerlibrary.sentence
    ${resp}=  Send Message   ${user[2]}  ${comm_msg}  ${provider_id}  ${userType[0]}  ${consumer_id}  ${userType[3]}  ${messageType[3]}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}   []

    ${resp}=   Get Full Communication Of User  ${user[2]}  ${provider_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['userTwoUnReadCount']}       1
    Set Test Variable  ${msgId1}  ${resp.json()[0]['message'][0]['messageId']}

    ${resp}=  Change Read Status  ${user[2]}  ${provider_id}   ${userType[0]}  ${consumer_id}  ${userType[3]}   ${msgId1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Full Communication Of User  ${user[2]}  ${provider_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['userTwoUnReadCount']}       0


JD-TC-ChangeReadStatus-7

    [Documentation]   Provider send a message(chat) to a jaldee consumer with one attachment.
    ...   change the read status of that communication.


    ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${consumer_id}   ${resp.json()['id']}

    ${resp}=  ConsumerLogout  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${MUSERNAME97}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${provider_id}  ${decrypted_data['id']}

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
    Should Be Equal As Strings  ${resp.json()[0]['userTwoUnReadCount']}       1
    Set Test Variable  ${msgId1}  ${resp.json()[0]['message'][0]['messageId']}

    ${resp}=  Change Read Status  ${user[2]}  ${provider_id}   ${userType[0]}  ${consumer_id}  ${userType[3]}   ${msgId1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Full Communication Of User  ${user[2]}  ${provider_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['userTwoUnReadCount']}       0


JD-TC-ChangeReadStatus-8

    [Documentation]   Provider send a message(enquiry) to a jaldee consumer with one attachment.
    ...   change the read status of that communication.


    ${resp}=  Consumer Login  ${CUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${consumer_id}   ${resp.json()['id']}

    ${resp}=  ConsumerLogout  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${MUSERNAME98}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${provider_id}  ${decrypted_data['id']}

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
    Should Be Equal As Strings  ${resp.json()[0]['userTwoUnReadCount']}       1
    Set Test Variable  ${msgId1}  ${resp.json()[0]['message'][0]['messageId']}

    ${resp}=  Change Read Status  ${user[2]}  ${provider_id}   ${userType[0]}  ${consumer_id}  ${userType[3]}   ${msgId1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Full Communication Of User  ${user[2]}  ${provider_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['userTwoUnReadCount']}       0


JD-TC-ChangeReadStatus-9

    [Documentation]   Provider send a message(alert) to a jaldee consumer with one attachment.
    ...   change the read status of that communication.


    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${consumer_id}   ${resp.json()['id']}

    ${resp}=  ConsumerLogout  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${MUSERNAME99}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${provider_id}  ${decrypted_data['id']}

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
    Should Be Equal As Strings  ${resp.json()[0]['userTwoUnReadCount']}       1
    Set Test Variable  ${msgId1}  ${resp.json()[0]['message'][0]['messageId']}

    ${resp}=  Change Read Status  ${user[2]}  ${provider_id}   ${userType[0]}  ${consumer_id}  ${userType[3]}   ${msgId1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Full Communication Of User  ${user[2]}  ${provider_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['userTwoUnReadCount']}       0


JD-TC-ChangeReadStatus-10

    [Documentation]   Provider send a message(bookings) to a jaldee consumer with one attachment.
    ...   change the read status of that communication.


    ${resp}=  Consumer Login  ${CUSERNAME6}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${consumer_id}   ${resp.json()['id']}

    ${resp}=  ConsumerLogout  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${MUSERNAME100}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${provider_id}  ${decrypted_data['id']}

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
    Should Be Equal As Strings  ${resp.json()[0]['userTwoUnReadCount']}       1
    Set Test Variable  ${msgId1}  ${resp.json()[0]['message'][0]['messageId']}

    ${resp}=  Change Read Status  ${user[2]}  ${provider_id}   ${userType[0]}  ${consumer_id}  ${userType[3]}   ${msgId1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Full Communication Of User  ${user[2]}  ${provider_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['userTwoUnReadCount']}       0


JD-TC-ChangeReadStatus-11

    [Documentation]   Provider send a message(chat) to a provider consumer with one attachment.
    ...   change the read status of that communication.


    ${resp}=  Encrypted Provider Login  ${MUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${provider_id}  ${decrypted_data['id']}

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
    ${resp}=  Send Message   ${user[2]}  ${comm_msg}  ${provider_id}  ${userType[0]}  ${pcid}  ${userType[8]}  ${messageType[0]}  ${attachment_list}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Full Communication Of User  ${user[2]}  ${provider_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['userTwoUnReadCount']}       1
    Set Test Variable  ${msgId1}  ${resp.json()[0]['message'][0]['messageId']}

    ${resp}=  Change Read Status  ${user[2]}  ${provider_id}   ${userType[0]}  ${pcid}  ${userType[8]}   ${msgId1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Full Communication Of User  ${user[2]}  ${provider_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['userTwoUnReadCount']}       0


JD-TC-ChangeReadStatus-12

    [Documentation]   Provider send a message(enquiry) to a provider consumer with one attachment.
    ...   change the read status of that communication.


    ${resp}=  Encrypted Provider Login  ${MUSERNAME2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${provider_id}  ${decrypted_data['id']}

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
    ${resp}=  Send Message   ${user[2]}  ${comm_msg}  ${provider_id}  ${userType[0]}  ${pcid}  ${userType[8]}  ${messageType[1]}  ${attachment_list}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Full Communication Of User  ${user[2]}  ${provider_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['userTwoUnReadCount']}       1
    Set Test Variable  ${msgId1}  ${resp.json()[0]['message'][0]['messageId']}

    ${resp}=  Change Read Status  ${user[2]}  ${provider_id}   ${userType[0]}  ${pcid}  ${userType[8]}   ${msgId1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Full Communication Of User  ${user[2]}  ${provider_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['userTwoUnReadCount']}       0


JD-TC-ChangeReadStatus-13

    [Documentation]   Provider send a message(alert) to a provider consumer with one attachment.
    ...   change the read status of that communication.


    ${resp}=  Encrypted Provider Login  ${MUSERNAME3}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${provider_id}  ${decrypted_data['id']}

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
    ${resp}=  Send Message   ${user[2]}  ${comm_msg}  ${provider_id}  ${userType[0]}  ${pcid}  ${userType[8]}  ${messageType[2]}  ${attachment_list}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Full Communication Of User  ${user[2]}  ${provider_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['userTwoUnReadCount']}       1
    Set Test Variable  ${msgId1}  ${resp.json()[0]['message'][0]['messageId']}

    ${resp}=  Change Read Status  ${user[2]}  ${provider_id}   ${userType[0]}  ${pcid}  ${userType[8]}   ${msgId1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Full Communication Of User  ${user[2]}  ${provider_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['userTwoUnReadCount']}       0


JD-TC-ChangeReadStatus-14

    [Documentation]   Provider send a message(bookings) to a provider consumer with one attachment.
    ...   change the read status of that communication.


    ${resp}=  Encrypted Provider Login  ${MUSERNAME5}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${provider_id}  ${decrypted_data['id']}

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
    ${resp}=  Send Message   ${user[2]}  ${comm_msg}  ${provider_id}  ${userType[0]}  ${pcid}  ${userType[8]}  ${messageType[3]}  ${attachment_list}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Full Communication Of User  ${user[2]}  ${provider_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['userTwoUnReadCount']}       1
    Set Test Variable  ${msgId1}  ${resp.json()[0]['message'][0]['messageId']}

    ${resp}=  Change Read Status  ${user[2]}  ${provider_id}   ${userType[0]}  ${pcid}  ${userType[8]}   ${msgId1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Full Communication Of User  ${user[2]}  ${provider_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['userTwoUnReadCount']}       0

JD-TC-ChangeReadStatus-15

    [Documentation]   Provider send a message(chat) to a partner with one attachment.
    ...   change the read status of that communication.

    ${resp}=  Encrypted Provider Login  ${MUSERNAME6}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${provider_id}  ${decrypted_data['id']}

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

    ELSE
        Set Test Variable  ${locId}  ${resp.json()[0]['id']}
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
    ${dealerfname2}=  FakerLibrary.name
    ${dealerlname2}=  FakerLibrary.last_name
   
    ${resp}=  Generate Phone Partner Creation    ${phone}    ${countryCodes[0]}    partnerName=${dealername}   partnerUserFirstName=${dealerfname2}  partnerUserLastName=${dealerlname2}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${dealerfname}=  FakerLibrary.name
    ${dealerlname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
   
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
    ${resp}=  Send Message   ${user[2]}  ${comm_msg}  ${provider_id}  ${userType[0]}  ${partid1}  ${userType[9]}  ${messageType[0]}  ${attachment_list}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Full Communication Of User  ${user[2]}  ${provider_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['userTwoUnReadCount']}       1
    Set Test Variable  ${msgId1}  ${resp.json()[0]['message'][0]['messageId']}

    ${resp}=  Change Read Status  ${user[2]}  ${provider_id}   ${userType[0]}  ${partid1}  ${userType[9]}   ${msgId1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Full Communication Of User  ${user[2]}  ${provider_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['userTwoUnReadCount']}       0


JD-TC-ChangeReadStatus-16

    [Documentation]   Provider send a message(enquiry) to a partner with one attachment.
    ...   change the read status of that communication.

    ${resp}=  Encrypted Provider Login  ${MUSERNAME7}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${provider_id}  ${decrypted_data['id']}

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

    ELSE
        Set Test Variable  ${locId}  ${resp.json()[0]['id']}
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
    ${resp}=  Send Message   ${user[2]}  ${comm_msg}  ${provider_id}  ${userType[0]}  ${partid1}  ${userType[9]}  ${messageType[1]}  ${attachment_list}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Full Communication Of User  ${user[2]}  ${provider_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['userTwoUnReadCount']}       1
    Set Test Variable  ${msgId1}  ${resp.json()[0]['message'][0]['messageId']}

    ${resp}=  Change Read Status  ${user[2]}  ${provider_id}   ${userType[0]}  ${partid1}  ${userType[9]}   ${msgId1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Full Communication Of User  ${user[2]}  ${provider_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['userTwoUnReadCount']}       0


JD-TC-ChangeReadStatus-17

    [Documentation]   Provider send a message(alert) to a partner with one attachment.
    ...   change the read status of that communication.

    ${resp}=  Encrypted Provider Login  ${MUSERNAME8}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${provider_id}  ${decrypted_data['id']}

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

    ELSE
        Set Test Variable  ${locId}  ${resp.json()[0]['id']}
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
    ${resp}=  Send Message   ${user[2]}  ${comm_msg}  ${provider_id}  ${userType[0]}  ${partid1}  ${userType[9]}  ${messageType[2]}  ${attachment_list}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Full Communication Of User  ${user[2]}  ${provider_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['userTwoUnReadCount']}       1
    Set Test Variable  ${msgId1}  ${resp.json()[0]['message'][0]['messageId']}

    ${resp}=  Change Read Status  ${user[2]}  ${provider_id}   ${userType[0]}  ${partid1}  ${userType[9]}   ${msgId1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Full Communication Of User  ${user[2]}  ${provider_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['userTwoUnReadCount']}       0


JD-TC-ChangeReadStatus-18

    [Documentation]   Provider send a message(bookings) to a partner with one attachment.
    ...   change the read status of that communication.

    ${resp}=  Encrypted Provider Login  ${MUSERNAME9}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${provider_id}  ${decrypted_data['id']}

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

    ELSE
        Set Test Variable  ${locId}  ${resp.json()[0]['id']}
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
    ${resp}=  Send Message   ${user[2]}  ${comm_msg}  ${provider_id}  ${userType[0]}  ${partid1}  ${userType[9]}  ${messageType[3]}  ${attachment_list}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Full Communication Of User  ${user[2]}  ${provider_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['userTwoUnReadCount']}       1
    Set Test Variable  ${msgId1}  ${resp.json()[0]['message'][0]['messageId']}

    ${resp}=  Change Read Status  ${user[2]}  ${provider_id}   ${userType[0]}  ${partid1}  ${userType[9]}   ${msgId1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Full Communication Of User  ${user[2]}  ${provider_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['userTwoUnReadCount']}       0


JD-TC-ChangeReadStatus-19

    [Documentation]   Provider send a message(chat) to a jaldee consumer without any attachment and
    ...   consumer change the read status of that communication.


    ${resp}=  Consumer Login  ${CUSERNAME30}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${consumer_id}   ${resp.json()['id']}

    clear_Consumermsg  ${CUSERNAME30}

    ${resp}=  ConsumerLogout  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${MUSERNAME90}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${provider_id}  ${decrypted_data['id']}

    ${comm_msg}=  Fakerlibrary.sentence
    ${caption}=  Fakerlibrary.sentence
    ${resp}=  Send Message   ${user[2]}  ${comm_msg}  ${provider_id1}  ${userType[0]}  ${consumer_id2}  ${userType[3]}  ${messageType[0]}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}   []

    ${resp}=  ProviderLogout  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME30}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Full Communication Of User  ${user[0]}  ${consumer_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['userTwoUnReadCount']}       1
    Set Suite Variable  ${msgId1}  ${resp.json()[0]['message'][0]['messageId']}
    
    ${resp}=  Change Read Status  ${user[0]}  ${consumer_id}   ${userType[3]}  ${provider_id}  ${userType[0]}   ${msgId1}   ${provider_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Full Communication Of User  ${user[0]}  ${provider_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['userTwoUnReadCount']}       0
