*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Communication
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py


*** Variables ***

${jpgfile}      /ebs/TDD/uploadimage.jpg
${pngfile}     /ebs/TDD/upload.png
${pdffile}     /ebs/TDD/sample.pdf
${giffile}     /ebs/TDD/sample.gif
${jpegfile}     /ebs/TDD/large.jpeg
${bmpfile}     /ebs/TDD/first.bmp
${shfile}     /ebs/TDD/example.sh
${docfile}     /ebs/TDD/docsample.doc
${txtfile}     /ebs/TDD/textsample.txt


*** Test Cases ***

JD-TC-GetConsumerCommunication-1

    [Documentation]  Get Communication with a valid consumer to provider with attachment as jpg file.

    clear_Providermsg  ${PUSERNAME215}
    ${resp}=   Encrypted Provider Login  ${PUSERNAME215}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${p_id}  ${decrypted_data['id']}

    # Set Test Variable  ${p_id}  ${resp.json()['id']}
    ${acc_id}=  get_acc_id  ${PUSERNAME215}
    Set Suite Variable   ${acc_id} 

    ${emptylist}=  Create List
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME6}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME6} 
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${cid6}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${cid6}  ${resp.json()[0]['id']}
    END

    ${resp}=   ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Login  ${CUSERNAME6}  ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${c_id}=  get_id  ${CUSERNAME6}
    # clear_Consumermsg  ${CUSERNAME6}

    # ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME6}   ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable    ${cookie} 


    ${resp}=    Send Otp For Login    ${CUSERNAME6}    ${acc_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME6}   12  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME6}    ${acc_id}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_Consumermsg  ${CUSERNAME6}
    
    
    ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME6}    ${acc_id}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Test Variable    ${con_id}   ${resp.json()['id']} 

    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}   ${acc_id}  ${msg}  ${messageType[0]}  ${caption}  ${EMPTY}  ${jpgfile}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep   2s
    ${resp}=  Get Consumer Communications
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}    ${con_id}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}    ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}    0
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}    ${acc_id}
    Should Contain 	${resp.json()[0]}   attachements
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   s3path
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   thumbPath
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .jpg
    Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption} 

JD-TC-GetConsumerCommunication-2

    [Documentation]  Get General Communication with a valid provider with attachment as png file.
    
    clear_Providermsg  ${PUSERNAME215}
    ${resp}=   Encrypted Provider Login  ${PUSERNAME215}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${p_id}  ${decrypted_data['id']}

    # Set Test Variable  ${p_id}  ${resp.json()['id']}
    ${acc_id}=  get_acc_id  ${PUSERNAME215}

    ${emptylist}=  Create List
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME14}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME14} 
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${cid14}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${cid14}  ${resp.json()[0]['id']}
    END


    ${resp}=   ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${CUSERNAME14}    ${acc_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME14}   12  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME14}    ${acc_id}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_Consumermsg  ${CUSERNAME14}
    
    
    ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME14}    ${acc_id}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Test Variable    ${con_id}   ${resp.json()['id']} 

    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}   ${acc_id}  ${msg}  ${messageType[0]}  ${caption}  ${EMPTY}  ${pngfile} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Communications
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}    ${con_id}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}    ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}    0
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}    ${acc_id}
    Should Contain 	${resp.json()[0]}   attachements
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   s3path
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   thumbPath
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption} 


JD-TC-GetConsumerCommunication-3

    [Documentation]  Get General Communication with a valid provider with attachment as pdf file.

    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME16}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${p_id}  ${decrypted_data['id']}

    # Set Test Variable  ${p_id}  ${resp.json()['id']}
    ${acc_id}=  get_acc_id  ${PUSERNAME16}

    ${emptylist}=  Create List
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME14}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME14} 
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${cid14}   ${resp1.json()}
    ELSE
        Set Test Variable  ${cid14}  ${resp.json()[0]['id']}
    END


    ${resp}=   ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Consumer Login  ${CUSERNAME14}  ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${c_id}=  get_id  ${CUSERNAME14}
    # clear_Consumermsg  ${CUSERNAME14}
    clear_Providermsg  ${PUSERNAME16}

    # ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME14}   ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Send Otp For Login    ${CUSERNAME14}    ${acc_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME14}   12  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME14}    ${acc_id}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_Consumermsg  ${CUSERNAME14}
    
    
    ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME14}    ${acc_id}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Test Variable    ${con_id}   ${resp.json()['id']} 

    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}   ${acc_id}  ${msg}  ${messageType[0]}  ${caption}  ${EMPTY}  ${pdffile} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Communications
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}    ${con_id}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}    ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}    0
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}    ${acc_id}
    Should Contain 	${resp.json()[0]}   attachements
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   s3path
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .pdf
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   thumbPath
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .pdf
    Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption}


JD-TC-GetConsumerCommunication-4

    [Documentation]  Get General Communication with a valid provider with attachment as jpeg file.

    clear_Providermsg  ${PUSERNAME17}
    ${resp}=   Encrypted Provider Login  ${PUSERNAME17}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${p_id}  ${decrypted_data['id']}

    # Set Test Variable  ${p_id}  ${resp.json()['id']}
    ${acc_id}=  get_acc_id  ${PUSERNAME17}

    ${emptylist}=  Create List
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME14}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME14} 
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${cid14}   ${resp1.json()}
    ELSE
        Set Test Variable  ${cid14}  ${resp.json()[0]['id']}
    END

    ${resp}=   ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=    Send Otp For Login    ${CUSERNAME14}    ${acc_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME14}   12  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME14}    ${acc_id}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_Consumermsg  ${CUSERNAME14}
    
    
    ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME14}    ${acc_id}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Test Variable    ${con_id}   ${resp.json()['id']} 

    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}   ${acc_id}  ${msg}  ${messageType[0]}  ${caption}  ${EMPTY}  ${jpegfile} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Communications
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}    ${con_id}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}    ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}    0
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}    ${acc_id}
    Should Contain 	${resp.json()[0]}   attachements
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   s3path
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .jpeg
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   thumbPath
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .jpeg
    Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption}


JD-TC-GetConsumerCommunication-5

    [Documentation]  Get General Communication with a valid provider without message.

    clear_Providermsg  ${PUSERNAME220}
    ${resp}=   Encrypted Provider Login  ${PUSERNAME220}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${p_id}  ${decrypted_data['id']}

    # Set Test Variable  ${p_id}  ${resp.json()['id']}
    ${acc_id}=  get_acc_id  ${PUSERNAME220}

    ${emptylist}=  Create List
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME14}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME14} 
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${cid14}   ${resp1.json()}
    ELSE
        Set Test Variable  ${cid14}  ${resp.json()[0]['id']}
    END

    ${resp}=   ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${CUSERNAME14}    ${acc_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME14}   12  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME14}    ${acc_id}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_Consumermsg  ${CUSERNAME14}
    
    
    ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME14}    ${acc_id}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Test Variable    ${con_id}   ${resp.json()['id']} 

    
    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}   ${acc_id}  ${EMPTY}  ${messageType[0]}  ${caption}  ${EMPTY}  ${jpgfile}    
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep   1s
    ${resp}=  Get Consumer Communications
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}    ${con_id}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}    ${EMPTY}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}    0
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}    ${acc_id}
    Should Contain 	${resp.json()[0]}   attachements
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   s3path
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   thumbPath
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .jpg
    Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption}


JD-TC-GetConsumerCommunication-6

    [Documentation]  Get General Communication with a valid provider without caption.

    clear_Providermsg  ${PUSERNAME13}
    ${resp}=   Encrypted Provider Login  ${PUSERNAME13}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${p_id}  ${decrypted_data['id']}

    # Set Test Variable  ${p_id}  ${resp.json()['id']}
    ${acc_id}=  get_acc_id  ${PUSERNAME13}

    ${emptylist}=  Create List
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME14}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME14} 
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${cid14}   ${resp1.json()}
    ELSE
        Set Test Variable  ${cid14}  ${resp.json()[0]['id']}
    END


    ${resp}=   ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${CUSERNAME14}    ${acc_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME14}   12  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME14}    ${acc_id}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_Consumermsg  ${CUSERNAME14}
    
    
    ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME14}    ${acc_id}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Test Variable    ${con_id}   ${resp.json()['id']} 
    ${msg}=  Fakerlibrary.sentence
    ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}   ${acc_id}  ${msg}  ${messageType[0]}  ${EMPTY}  ${EMPTY}  ${jpgfile}    
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Communications
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}    ${con_id}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}    ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}    0
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}    ${acc_id}
    Should Contain 	${resp.json()[0]}   attachements
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   s3path
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   thumbPath
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .jpg
    Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${EMPTY}


JD-TC-GetConsumerCommunication-7

    [Documentation]  Get General Communication with a valid provider with attachment as gif file.

    clear_Providermsg  ${PUSERNAME19}
    ${resp}=   Encrypted Provider Login  ${PUSERNAME19}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${p_id}  ${decrypted_data['id']}

    # Set Test Variable  ${p_id}  ${resp.json()['id']}
    ${acc_id}=  get_acc_id  ${PUSERNAME19}

    ${emptylist}=  Create List
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME14}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME14} 
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${cid14}   ${resp1.json()}
    ELSE
        Set Test Variable  ${cid14}  ${resp.json()[0]['id']}
    END


    ${resp}=   ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${CUSERNAME14}    ${acc_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME14}   12  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME14}    ${acc_id}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_Consumermsg  ${CUSERNAME14}
    
    
    ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME14}    ${acc_id}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Test Variable    ${con_id}   ${resp.json()['id']} 

    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}   ${acc_id}  ${msg}  ${messageType[0]}  ${caption}  ${EMPTY}  ${giffile} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Communications
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}    ${con_id}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}    ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}    0
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}    ${acc_id}
    Should Contain 	${resp.json()[0]}   attachements
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   s3path
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .gif
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   thumbPath
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .gif
    Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption}


JD-TC-GetConsumerCommunication-UH1

    [Documentation]  Get Communication done by without login

    ${resp}=  Get Consumer Communications
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

JD-TC-GetConsumerCommunication-UH2

    [Documentation]  Get Communication without having any communication.

    clear_Providermsg  ${PUSERNAME19}
    ${resp}=   Encrypted Provider Login  ${PUSERNAME19}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Set Test Variable  ${p_id}  ${resp.json()['id']}
    # ${acc_id}=  get_acc_id  ${PUSERNAME19}

    # ${resp}=   ProviderLogout
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Consumer Login  ${CUSERNAME14}  ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${c_id}=  get_id  ${CUSERNAME14}
    # clear_Consumermsg  ${CUSERNAME14}

    ${resp}=  Get Consumer Communications
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 


JD-TC-GetConsumerCommunication-UH3

    [Documentation]  Get Communication by provider login.

    clear_Providermsg  ${PUSERNAME19}
    ${resp}=   Encrypted Provider Login  ${PUSERNAME19}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${p_id}  ${decrypted_data['id']}

    # Set Test Variable  ${p_id}  ${resp.json()['id']}
    ${acc_id}=  get_acc_id  ${PUSERNAME19}

    ${emptylist}=  Create List
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME14}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME14} 
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${cid14}   ${resp1.json()}
    ELSE
        Set Test Variable  ${cid14}  ${resp.json()[0]['id']}
    END


    ${resp}=   ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${CUSERNAME14}    ${acc_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME14}   12  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME14}    ${acc_id}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_Consumermsg  ${CUSERNAME14}
    
    
    ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME14}    ${acc_id}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Test Variable    ${con_id}   ${resp.json()['id']} 

    ${resp}=  Get Consumer Communications
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 


JD-TC-GetConsumerCommunication-UH4

    [Documentation]  Get General Communication with a valid provider with attachment as doc file.

    clear_Providermsg  ${PUSERNAME31}
    ${resp}=   Encrypted Provider Login  ${PUSERNAME31}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${p_id}  ${decrypted_data['id']}

    # Set Test Variable  ${p_id}  ${resp.json()['id']}
    ${acc_id}=  get_acc_id  ${PUSERNAME31}


    ${emptylist}=  Create List
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME14}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME14} 
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${cid14}   ${resp1.json()}
    ELSE
        Set Test Variable  ${cid14}  ${resp.json()[0]['id']}
    END



    ${resp}=   ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${CUSERNAME14}    ${acc_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME14}   12  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME14}    ${acc_id}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_Consumermsg  ${CUSERNAME14}
    
    
    ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME14}    ${acc_id}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Test Variable    ${con_id}   ${resp.json()['id']} 


    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}   ${acc_id}  ${msg}  ${messageType[0]}  ${caption}  ${EMPTY}  ${docfile} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep   1s
    ${resp}=  Get Consumer Communications
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}    ${con_id}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}    ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}    0
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}    ${acc_id}
    Should Contain 	${resp.json()[0]}   attachements
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   s3path
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .doc
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   thumbPath
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .doc
    Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption}


JD-TC-GetConsumerCommunication-UH5

    [Documentation]  Get General Communication with a valid provider with attachment as sh file.
    
    clear_Providermsg  ${PUSERNAME31}
    ${resp}=   Encrypted Provider Login  ${PUSERNAME31}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${p_id}  ${decrypted_data['id']}

    # Set Test Variable  ${p_id}  ${resp.json()['id']}
    ${acc_id}=  get_acc_id  ${PUSERNAME31}

    ${emptylist}=  Create List
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME14}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME14} 
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${cid14}   ${resp1.json()}
    ELSE
        Set Test Variable  ${cid14}  ${resp.json()[0]['id']}
    END


    ${resp}=   ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${CUSERNAME14}    ${acc_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME14}   12  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME14}    ${acc_id}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_Consumermsg  ${CUSERNAME14}
    
    
    ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME14}    ${acc_id}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Test Variable    ${con_id}   ${resp.json()['id']} 

    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}   ${acc_id}  ${msg}  ${messageType[0]}  ${caption}  ${EMPTY}  ${shfile} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${IMAGE_TYPE_NOT_SUPPORTED}"

JD-TC-GetConsumerCommunication-UH6

    [Documentation]  Get General Communication with a valid provider with attachment as text file.
    
    clear_Providermsg  ${PUSERNAME3}
    ${resp}=   Encrypted Provider Login  ${PUSERNAME3}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${p_id}  ${decrypted_data['id']}

    # Set Test Variable  ${p_id}  ${resp.json()['id']}
    ${acc_id}=  get_acc_id  ${PUSERNAME3}

    ${emptylist}=  Create List
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME14}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME14} 
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${cid14}   ${resp1.json()}
    ELSE
        Set Test Variable  ${cid14}  ${resp.json()[0]['id']}
    END


    ${resp}=   ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${CUSERNAME14}    ${acc_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME14}   12  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME14}    ${acc_id}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_Consumermsg  ${CUSERNAME14}
    
    
    ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME14}    ${acc_id}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Test Variable    ${con_id}   ${resp.json()['id']} 

    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}   ${acc_id}  ${msg}  ${messageType[0]}  ${caption}  ${EMPTY}  ${txtfile} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep   1s
    ${resp}=  Get Consumer Communications
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}    ${con_id}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}    ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}    0
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}    ${acc_id}
    Should Contain 	${resp.json()[0]}   attachements
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   s3path
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .txt
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   thumbPath
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .txt
    Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption}

*** Comments ***



JD-TC-Get Consumer Communication-2
    Comment  Get Communication with a provider as a consumer to another provider 
    ${resp}=   Encrypted Provider Login  ${PUSERNAME2155}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${p_id}  ${resp.json()['id']}
    ${a_id}=  get_acc_id  ${PUSERNAME2155}
    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200
    ${msg}=   FakerLibrary.Word
    Log  ${msg}
    ${resp}=  Consumer Login  ${PUSERNAME2154}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${c_id}=  get_id  ${PUSERNAME2154}
    ${resp}=  General Communication with Provider   ${msg}   ${a_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${resp}=  Get Consumer Communications
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}    ${c_id}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}    ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}    ${a_id}






JD-TC-Get Consumer Communication-3
    Comment  Get Communication with a provider as a consumer to his own account
    ${resp}=   Encrypted Provider Login  ${PUSERNAME2156}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${p_id}  ${resp.json()['id']}
    ${a_id}=  get_acc_id  ${PUSERNAME2156}
    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200
    ${msg}=   FakerLibrary.Word
    Log  ${msg}
    ${resp}=  Consumer Login  ${PUSERNAME2156}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${c_id}=  get_id  ${PUSERNAME2156}
    ${resp}=  General Communication with Provider   ${msg}   ${a_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}    ${c_id}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}    ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}    ${a_id}






JD-TC-Get Consumer Communication-4
    Comment  Get Communication done by provider to another provider
    ${resp}=   Encrypted Provider Login  ${PUSERNAME2155}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${p_id}  ${resp.json()['id']}
    Log  ${p_id}
    ${id}=  get_acc_id  ${PUSERNAME2155}
    ${msg}=   FakerLibrary.Word
    Log  ${msg}
    ${resp}=   Encrypted Provider Login  ${PUSERNAME2156}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${c_id}=  get_id  ${PUSERNAME2156}
    ${resp}=  General Communication with Provider    ${msg}  ${id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}    ${c_id}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}    ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}    ${p_id}

