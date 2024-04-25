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
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 

*** Variables ***

${jpgfile}      /ebs/TDD/uploadimage.jpg
${pngfile}      /ebs/TDD/upload.png
${pdffile}      /ebs/TDD/sample.pdf
${excelfile}    /ebs/TDD/qnr.xlsx

*** Test Cases ***

JD-TC-Communication provider with consumer-1

    [Documentation]   Communication provider with consumer

    clear_Providermsg  ${PUSERNAME4}
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME4}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${p_id}  ${resp.json()['id']}
    ${acc_id}=  get_acc_id  ${PUSERNAME4}
    Set Suite Variable   ${acc_id} 
    
    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[0]}'
        ${resp1}=   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
        Should Be Equal As Strings  ${resp1.status_code}  200
    ELSE IF    '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[1]}'
        ${resp1}=   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    clear_customer   ${PUSERNAME4}
    ${resp}=  AddCustomer  ${CUSERNAME3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${c_id}=  get_id  ${CUSERNAME3}
    Set Suite Variable   ${c_id} 
    clear_Consumermsg  ${CUSERNAME3}

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME4}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable    ${cookie} 
    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${caption}=  Fakerlibrary.sentence   

    ${resp}=  Imageupload.GeneralCommunicationWithConsumer   ${cookie}   ${c_id}  ${msg}  ${messageType[0]}  ${caption}   ${EMPTY}  ${jpgfile}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get provider communications
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}   0
    Should Be Equal As Strings  ${resp.json()[0]['msg']}    ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}    ${c_id}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}    ${acc_id}
    Should Contain 	${resp.json()[0]}   attachements
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   s3path
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   thumbPath
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .jpg
    Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption} 

    ${resp}=  Imageupload.GeneralCommunicationWithConsumer   ${cookie}   ${c_id}  ${msg}  ${messageType[0]}  ${caption}   ${EMPTY}  ${excelfile}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get provider communications
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}   0
    Should Be Equal As Strings  ${resp.json()[1]['msg']}    ${msg}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}    ${c_id}
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}    ${acc_id}
    Should Contain 	${resp.json()[1]}   attachements
    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][0]}   s3path
    Should Contain  ${resp.json()[1]['attachements'][0]['s3path']}   .xlsx
    Dictionary Should Contain Key  ${resp.json()[1]['attachements'][0]}   thumbPath
    Should Contain  ${resp.json()[1]['attachements'][0]['s3path']}   .xlsx
    Should Be Equal As Strings  ${resp.json()[1]['attachements'][0]['caption']}     ${caption} 


JD-TC-Communication provider with consumer-2

    [Documentation]   Communication provider with consumer

    clear_Providermsg  ${PUSERNAME5}
    ${resp}=   Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${p_id}  ${resp.json()['id']}
    ${acc_id}=  get_acc_id  ${PUSERNAME5}
    Set Suite Variable   ${acc_id} 

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[0]}'
        ${resp1}=   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
        Should Be Equal As Strings  ${resp1.status_code}  200
    ELSE IF    '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[1]}'
        ${resp1}=   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    clear_customer   ${PUSERNAME5}
    ${resp}=  AddCustomer  ${CUSERNAME3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
   
    # ${c_id}=  get_id  ${CUSERNAME3}
    # Set Suite Variable   ${c_id} 
    clear_Consumermsg  ${CUSERNAME3}

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME5}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable    ${cookie} 
    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${caption}=  Fakerlibrary.sentence   

    ${resp}=  Imageupload.GeneralCommunicationWithConsumer   ${cookie}   ${c_id}  ${msg}  ${messageType[0]}  ${caption}   ${EMPTY}  ${pngfile}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get provider communications
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}   0
    Should Be Equal As Strings  ${resp.json()[0]['msg']}    ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}    ${c_id}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}    ${acc_id}
    Should Contain 	${resp.json()[0]}   attachements
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   s3path
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   thumbPath
    Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption} 

JD-TC-Communication provider with consumer-UH1
    [Documentation]   Provider communicates with consumer using invalid consumer id
    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${caption}=  Fakerlibrary.sentence

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME6}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${invconid}=    Generate Random String  5  [NUMBERS]
    
    # ${resp}=  Imageupload.GeneralCommunicationWithConsumer   ${cookie}  000  ${msg}  ${messageType[0]}  ${caption}   ${EMPTY}
    ${resp}=  Imageupload.GeneralCommunicationWithConsumer   ${cookie}  ${invconid}  ${msg}  ${messageType[0]}  ${caption}   ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  404
    Should Be Equal As Strings  "${resp.json()}"  "${CONSUMER_NOT_EXIST}" 

JD-TC-Communication provider with consumer-UH2
    [Documentation]  Consumer login to communicate with consumer 
    
    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME3}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg}=  Fakerlibrary.sentence
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.GeneralCommunicationWithConsumer   ${cookie}   ${c_id}  ${msg}  ${messageType[0]}  ${caption}   ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401  
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"
        
# JD-TC-Communication provider with consumer-UH3
#     [Documentation]   Communication provider with consumer without login
#     ${resp}=  Communication consumers  ${id}  ${msg}
#     Should Be Equal As Strings  ${resp.status_code}  419          
#     Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"
    
    
    
    
    
