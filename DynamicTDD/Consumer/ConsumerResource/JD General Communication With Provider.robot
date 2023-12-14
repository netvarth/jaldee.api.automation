*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        ProviderCommunication
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
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

JD-TC-General Communication with Provider-1

    [Documentation]  General Communication with a valid provider with attachment as jpg file.

    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME214}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${p_id}  ${resp.json()['id']}
    ${acc_id}=  get_acc_id  ${PUSERNAME214}

    # ${resp}=   Get jaldeeIntegration Settings
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # IF  '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[0]}'
    #     ${resp1}=   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
    #     Should Be Equal As Strings  ${resp1.status_code}  200
    # ELSE IF    '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[1]}'
    #     ${resp1}=   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
    #     Should Be Equal As Strings  ${resp1.status_code}  200
    # END

    # ${resp}=   Get jaldeeIntegration Settings
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}


    # ${emptylist}=  Create List
    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME3}  
    # Log  ${resp.content}
    # Should Be Equal As Strings      ${resp.status_code}  200
    # IF   '${resp.content}' == '${emptylist}'
    #     ${resp1}=  AddCustomer  ${CUSERNAME3} 
    #     Log  ${resp1.content}
    #     Should Be Equal As Strings  ${resp1.status_code}  200
    #     Set Suite Variable  ${cid3}   ${resp1.json()}
    # ELSE
    #     Set Suite Variable  ${cid3}  ${resp.json()[0]['id']}
    # END
    Set Suite Variable   ${acc_id} 
    ${resp}=   ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${c_id}=  get_id  ${CUSERNAME3}
    clear_Consumermsg  ${CUSERNAME3}
    clear_Providermsg  ${PUSERNAME214}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME3}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable    ${cookie} 
    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/TDD/TDD_Output/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}   ${acc_id}  ${msg}  ${messageType[0]}  ${caption}  ${EMPTY}  ${jpgfile}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  2s
    ${resp}=  Get Consumer Communications
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}    ${c_id}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}    ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}    0
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}    ${acc_id}
    Should Contain 	${resp.json()[0]}   attachements
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   s3path
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   thumbPath
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .jpg
    Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME214}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}    ${c_id}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}    ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}    0
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}    ${acc_id}
    Should Contain 	${resp.json()[0]}   attachements
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   s3path
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   thumbPath
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .jpg
    Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption}

JD-TC-General Communication with Provider-2

    [Documentation]  General Communication with a valid provider with attachment as png file.
    
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME214}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${p_id}  ${resp.json()['id']}
    ${acc_id}=  get_acc_id  ${PUSERNAME214}

    ${resp}=   ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${c_id}=  get_id  ${CUSERNAME3}
    clear_Consumermsg  ${CUSERNAME3}
    clear_Providermsg  ${PUSERNAME214}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME3}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/TDD/TDD_Output/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}   ${acc_id}  ${msg}  ${messageType[0]}  ${caption}  ${EMPTY}   ${pngfile} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep   2s
    ${resp}=  Get Consumer Communications
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}    ${c_id}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}    ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}    0
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}    ${acc_id}
    Should Contain 	${resp.json()[0]}   attachements
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   s3path
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   thumbPath
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption} 

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME214}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}    ${c_id}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}    ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}    0
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}    ${acc_id}
    Should Contain 	${resp.json()[0]}   attachements
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   s3path
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   thumbPath
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption}

JD-TC-General Communication with Provider-3

    [Documentation]  General Communication with a valid provider with attachment as pdf file.
    
    clear_Providermsg  ${PUSERNAME214}
    ${resp}=   Encrypted Provider Login  ${PUSERNAME214}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${p_id}  ${resp.json()['id']}
    ${acc_id}=  get_acc_id  ${PUSERNAME214}

    ${resp}=   ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${c_id}=  get_id  ${CUSERNAME3}
    clear_Consumermsg  ${CUSERNAME3}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME3}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/TDD/TDD_Output/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}   ${acc_id}  ${msg}  ${messageType[0]}  ${caption}  ${EMPTY}  ${pdffile} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep   2s
    ${resp}=  Get Consumer Communications
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}    ${c_id}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}    ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}    0
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}    ${acc_id}
    Should Contain 	${resp.json()[0]}   attachements
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   s3path
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .pdf
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   thumbPath
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .pdf
    Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME214}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}    ${c_id}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}    ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}    0
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}    ${acc_id}
    Should Contain 	${resp.json()[0]}   attachements
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   s3path
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .pdf
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   thumbPath
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .pdf
    Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption}

JD-TC-General Communication with Provider-4

    [Documentation]  General Communication with a valid provider with attachment as jpeg file.
    
    clear_Providermsg  ${PUSERNAME214}
    ${resp}=   Encrypted Provider Login  ${PUSERNAME214}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${p_id}  ${resp.json()['id']}
    ${acc_id}=  get_acc_id  ${PUSERNAME214}

    ${resp}=   ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${c_id}=  get_id  ${CUSERNAME3}
    clear_Consumermsg  ${CUSERNAME3}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME3}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/TDD/TDD_Output/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}   ${acc_id}  ${msg}  ${messageType[0]}  ${caption}  ${EMPTY}  ${jpegfile} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep  2s
    ${resp}=  Get Consumer Communications
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}    ${c_id}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}    ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}    0
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}    ${acc_id}
    Should Contain 	${resp.json()[0]}   attachements
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   s3path
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .jpeg
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   thumbPath
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .jpeg
    Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME214}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}    ${c_id}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}    ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}    0
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}    ${acc_id}
    Should Contain 	${resp.json()[0]}   attachements
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   s3path
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .jpeg
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   thumbPath
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .jpeg
    Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption}

JD-TC-General Communication with Provider-5

    [Documentation]  General Communication with a valid provider without message.
    
    clear_Providermsg  ${PUSERNAME214}
    ${resp}=   Encrypted Provider Login  ${PUSERNAME214}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${p_id}  ${resp.json()['id']}
    ${acc_id}=  get_acc_id  ${PUSERNAME214}

    ${resp}=   ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${c_id}=  get_id  ${CUSERNAME3}
    clear_Consumermsg  ${CUSERNAME3}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME3}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}   ${acc_id}  ${EMPTY}  ${messageType[0]}  ${caption}  ${EMPTY}  ${jpgfile}    
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Communications
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}    ${c_id}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}    ${EMPTY}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}    0
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}    ${acc_id}
    Should Contain 	${resp.json()[0]}   attachements
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   s3path
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   thumbPath
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .jpg
    Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME214}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}    ${c_id}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}    ${EMPTY}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}    0
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}    ${acc_id}
    Should Contain 	${resp.json()[0]}   attachements
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   s3path
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   thumbPath
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .jpg
    Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption}

JD-TC-General Communication with Provider-6

    [Documentation]  General Communication with a valid provider without caption.
    
    clear_Providermsg  ${PUSERNAME214}
    ${resp}=   Encrypted Provider Login  ${PUSERNAME214}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${p_id}  ${resp.json()['id']}
    ${acc_id}=  get_acc_id  ${PUSERNAME214}

    ${resp}=   ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${c_id}=  get_id  ${CUSERNAME3}
    clear_Consumermsg  ${CUSERNAME3}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME3}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/TDD/TDD_Output/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
  
    ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}   ${acc_id}  ${msg}  ${messageType[0]}  ${EMPTY}  ${EMPTY}  ${jpgfile}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Communications
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}    ${c_id}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}    ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}    0
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}    ${acc_id}
    Should Contain 	${resp.json()[0]}   attachements
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   s3path
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   thumbPath
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .jpg
    Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${EMPTY}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME214}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}    ${c_id}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}    ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}    0
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}    ${acc_id}
    Should Contain 	${resp.json()[0]}   attachements
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   s3path
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   thumbPath
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .jpg
    Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${EMPTY}

JD-TC-General Communication with Provider-7

    [Documentation]  General Communication with a valid provider with attachment as gif file.
    
    clear_Providermsg  ${PUSERNAME214}
    ${resp}=   Encrypted Provider Login  ${PUSERNAME214}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${p_id}  ${resp.json()['id']}
    ${acc_id}=  get_acc_id  ${PUSERNAME214}

    ${resp}=   ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${c_id}=  get_id  ${CUSERNAME3}
    clear_Consumermsg  ${CUSERNAME3}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME3}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/TDD/TDD_Output/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}   ${acc_id}  ${msg}  ${messageType[0]}  ${caption}  ${EMPTY}  ${giffile} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep  2s
    ${resp}=  Get Consumer Communications
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}    ${c_id}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}    ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}    0
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}    ${acc_id}
    Should Contain 	${resp.json()[0]}   attachements
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   s3path
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .gif
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   thumbPath
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .gif
    Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME214}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}    ${c_id}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}    ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}    0
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}    ${acc_id}
    Should Contain 	${resp.json()[0]}   attachements
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   s3path
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .gif
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   thumbPath
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .gif
    Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption}

JD-TC-General Communication with Provider-UH1
    [Documentation]  General Communication with invalid account
   
    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME3}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable    ${cookie} 

    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/TDD/TDD_Output/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}   0000  ${msg}  ${messageType[0]}  ${caption}  ${EMPTY}  ${jpgfile}  
    Log  ${resp.json()}

    Should Be Equal As Strings  ${resp.status_code}  404
    Should Be Equal As Strings  "${resp.json()}"  "${ACCOUNT_NOT_EXIST}"


JD-TC-General Communication with Provider-UH3
    [Documentation]  General Communication done by without login

    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/TDD/TDD_Output/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}  ${acc_id}   ${msg}  ${messageType[0]}  ${caption}  ${EMPTY}  ${jpgfile}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.status_code}  419
    # Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

JD-TC-General Communication with Provider-UH4

    [Documentation]  General Communication with a valid provider with attachment as doc file.
    
    clear_Providermsg  ${PUSERNAME214}
    ${resp}=   Encrypted Provider Login  ${PUSERNAME214}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${p_id}  ${resp.json()['id']}
    ${acc_id}=  get_acc_id  ${PUSERNAME214}

    ${resp}=   ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${c_id}=  get_id  ${CUSERNAME3}
    clear_Consumermsg  ${CUSERNAME3}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME3}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/TDD/TDD_Output/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}   ${acc_id}  ${msg}  ${messageType[0]}  ${caption}  ${EMPTY}  ${docfile} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Communications
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}    ${c_id}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}    ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}    0
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}    ${acc_id}
    Should Contain 	${resp.json()[0]}   attachements
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   s3path
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .doc
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   thumbPath
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .doc
    Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME214}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}    ${c_id}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}    ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}    0
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}    ${acc_id}
    Should Contain 	${resp.json()[0]}   attachements
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   s3path
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .doc
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   thumbPath
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .doc
    Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption}


JD-TC-General Communication with Provider-UH5

    [Documentation]  General Communication with a valid provider with attachment as sh file.
    
    clear_Providermsg  ${PUSERNAME214}
    ${resp}=   Encrypted Provider Login  ${PUSERNAME214}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${p_id}  ${resp.json()['id']}
    ${acc_id}=  get_acc_id  ${PUSERNAME214}

    ${resp}=   ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${c_id}=  get_id  ${CUSERNAME3}
    clear_Consumermsg  ${CUSERNAME3}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME3}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/TDD/TDD_Output/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}   ${acc_id}  ${msg}  ${messageType[0]}  ${caption}  ${EMPTY}  ${shfile} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${IMAGE_TYPE_NOT_SUPPORTED}"

JD-TC-General Communication with Provider-UH6

    [Documentation]  General Communication with a valid provider with attachment as txt file.
    
    clear_Providermsg  ${PUSERNAME214}
    ${resp}=   Encrypted Provider Login  ${PUSERNAME214}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${p_id}  ${resp.json()['id']}
    ${acc_id}=  get_acc_id  ${PUSERNAME214}

    ${resp}=   ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${c_id}=  get_id  ${CUSERNAME3}
    clear_Consumermsg  ${CUSERNAME3}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME3}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/TDD/TDD_Output/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}   ${acc_id}  ${msg}  ${messageType[0]}  ${caption}  ${EMPTY}  ${txtfile} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Communications
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}    ${c_id}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}    ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}    0
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}    ${acc_id}
    Should Contain 	${resp.json()[0]}   attachements
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   s3path
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .txt
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   thumbPath
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .txt
    Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME214}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}    ${c_id}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}    ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}    0
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}    ${acc_id}
    Should Contain 	${resp.json()[0]}   attachements
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   s3path
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .txt
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   thumbPath
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .txt
    Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption}


JD-TC-General Communication with Provider-8

    [Documentation]  consumer communicate with provider with massage type enquiry and  that consumer  becomes provider consumer 
    
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME214}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${p_id}  ${resp.json()['id']}
    ${acc_id}=  get_acc_id  ${PUSERNAME214}

    ${resp}=   ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${c_id}=  get_id  ${CUSERNAME3}
    clear_Consumermsg  ${CUSERNAME3}
    clear_Providermsg  ${PUSERNAME214}
    Set Test Variable  ${fname1}   ${resp.json()['firstName']}
    Set Test Variable  ${lname1}   ${resp.json()['lastName']}
    Set Test Variable  ${ph_num}   ${resp.json()['primaryPhoneNumber']}


    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME3}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/TDD/TDD_Output/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}   ${acc_id}  ${msg}  ${messageType[1]}  ${caption}  ${EMPTY}   NONE 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep   2s
    ${resp}=  Get Consumer Communications
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}    ${c_id}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}    ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}    0
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}    ${acc_id}
    Should Be Equal As Strings  ${resp.json()[0]['messageType']}    ${messageType[1]}
  
  
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME214}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}    ${c_id}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}    ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}    0
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}    ${acc_id}
    Should Be Equal As Strings  ${resp.json()[0]['messageType']}    ${messageType[1]}
  
   
    ${resp}=  GetCustomer   account-eq=${c_id} 
    Should Be Equal As Strings  ${resp.status_code}  200  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[0]['firstName']}      ${fname1} 
    Should Be Equal As Strings  ${resp.json()[0]['lastName']}       ${lname1}
    Should Be Equal As Strings  ${resp.json()[0]['phoneNo']}        ${ph_num} 
   
    
# clear_queueand Waitlist
#      clear_queue  ${PUSERNAME5}    
#      clear_service  ${PUSERNAME5}



# JD-TC-General Communication with Provider-2
#     Comment  General Communication done by provider as a consumer with consumer login
#     ${resp}=   Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD} 
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}   200
#     Set Test Variable  ${p_id}  ${resp.json()['id']}
#     ${a_id}=  get_acc_id  ${PUSERNAME5}
#     ${resp}=   ProviderLogout
#     Log   ${resp.json()}
#     ${resp}=   Consumer Login   ${PUSERNAME214}  ${PASSWORD}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${c_id}=  get_id  ${PUSERNAME214}
#     clear_Consumermsg  ${PUSERNAME214}
#     ${msg}=   FakerLibrary.Word
#     ${resp}=  General Communication with Provider    ${msg}  ${a_id}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=  Get Consumer Communications
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200 
#     Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}    ${c_id}
#     Should Be Equal As Strings  ${resp.json()[0]['msg']}    ${msg}
#     Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}    ${a_id}

