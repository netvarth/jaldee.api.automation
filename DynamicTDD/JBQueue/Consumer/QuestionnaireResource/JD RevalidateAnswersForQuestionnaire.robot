*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Run Keywords  Delete All Sessions
Force Tags        Questionnaire
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library         /ebs/TDD/CustomKeywords.py
Library           OperatingSystem
Library           /ebs/TDD/CustomKeywords.py
Library           /ebs/TDD/excelfuncs.py
Resource          /ebs/TDD/SuperAdminKeywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

*** Variables ***
# ${xlFile}      ${EXECDIR}/ebs/TDD/sampleqnr.xlsx
${xlFile}      ${EXECDIR}/TDD/sampleqnr.xlsx    # DataSheet
${xlFile2}      ${EXECDIR}/TDD/qnr.xlsx    # DataSheet 2
${self}      0
@{service_names}
@{emptylist}
${mp4file}   /ebs/TDD/MP4file.mp4
${mp4mime}   video/mp4
${mp3file}   /ebs/TDD/MP3file.mp3
${mp3mime}   audio/mpeg



*** Test Cases ***

JD-TC-RevalidateConsumerQuestionnaire-1

    [Documentation]  Revalidate service questionnaire with same data.

    ${wb}=  readWorkbook  ${xlFile}
    ${sheet1}  GetCurrentSheet   ${wb}
    Set Suite Variable   ${sheet1}
    ${colnames}=  getColumnHeaders  ${sheet1}
    Log List  ${colnames}
    Log List  ${QnrChannel}
    Log List  ${QnrTransactionType}
    Set Suite Variable   ${colnames}
    ${servicenames}   getColumnValuesByName  ${sheet1}  ${colnames[6]}
    Log   ${servicenames}
    Set Suite Variable   ${servicenames}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME23}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['timezone']}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${s_len}=  Get Length  ${resp.json()}
    @{snames}=  Create List
    FOR  ${i}  IN RANGE   ${s_len}
        Append To List  ${snames}  ${resp.json()[${i}]['name']}
    END

    Remove Values From List  ${servicenames}   ${NONE}
    Log  ${servicenames}
    ${unique_snames}=    Remove Duplicates    ${servicenames}
    Log  ${unique_snames}
    Set Suite Variable   ${unique_snames}
    ${snames_len}=  Get Length  ${unique_snames}
    FOR  ${i}  IN RANGE   ${snames_len}
        ${kwstatus} 	${value} = 	Run Keyword And Ignore Error  List Should Contain Value  ${snames}  ${unique_snames[${i}]}
        Log Many  ${kwstatus} 	${value}
        Continue For Loop If  '${kwstatus}' == 'PASS'
        &{dict}=  Create Dictionary   ${colnames[6]}=${unique_snames[${i}]}
        ${ttype}=  getColumnValueByMultipleVals  ${sheet1}  ${colnames[1]}  &{dict}  
        Log  ${ttype}
        ${u_ttype}=    Remove Duplicates    ${ttype}
        Log  ${u_ttype}
        ${s_id}=  Run Keyword If   '${kwstatus}' == 'FAIL' and '${QnrTransactionType[3]}' in @{u_ttype}  Create Sample Service  ${unique_snames[${i}]}
        ${d_id}=  Run Keyword If   '${kwstatus}' == 'FAIL' and '${QnrTransactionType[0]}' in @{u_ttype}   Create Sample Donation  ${unique_snames[${i}]}
    END

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${cookie}  ${resp}=  Imageupload.SALogin    ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Imageupload.UploadQuestionnaire   ${cookie}   ${account_id}    ${xlFile} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME23}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
      ${id}  Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[1]}' and '${resp.json()[${i}]['captureTime']}' == '${QnrcaptureTime[0]}'  Set Variable  ${resp.json()[${i}]['id']} 
      ${qnrid}   Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[1]}' and '${resp.json()[${i}]['captureTime']}' == '${QnrcaptureTime[0]}'  Set Variable  ${resp.json()[${i}]['questionnaireId']}
      Exit For Loop If   '${id}' != '${None}'
    END
    Set Suite Variable   ${id}
    Set Suite Variable   ${qnrid}

    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200

    ${resp1}=  Run Keyword If   '${qns.json()['status']}' == '${status[1]}'  Provider Change Questionnaire Status  ${id}  ${status[0]}  
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings   ${qns.json()['status']}  ${status[0]}
    Set Suite Variable  ${Questionnaireid}  ${qns.json()['questionnaireId']}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${s_len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${s_len}
        ${s_id}=  Run Keyword If   '${resp.json()[${i}]['name']}' in @{unique_snames} and '${resp.json()[${i}]['serviceType']}' != '${ServiceType[2]}'   Set Variable   ${resp.json()[${i}]['id']}
        Exit For Loop If   '${s_id}' != '${None}'
    END
    Set Suite Variable   ${s_id}

    ${fname}=  FakerLibrary.first_name
    ${lname}=  FakerLibrary.last_name
   
    ${resp}=  AddCustomer  ${CUSERNAME10}   firstName=${fname}   lastName=${lname}  countryCode=${countryCodes[1]}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${cid}  ${resp.json()}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${CUSERNAME10}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${CUSERNAME10}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME10}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200 

    ${qnr_resp}=  Consumer View Questionnaire  ${account_id}  ${s_id}  ${self}
    Log  ${qnr_resp.content}
    Should Be Equal As Strings    ${qnr_resp.status_code}    200
    Should Be Equal As Strings   ${qnr_resp.json()['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${qnr_resp.json()['id']}   ${id}
    
    ${fudata}=  db.fileUploadDT   ${qnr_resp.json()}  ${FileAction[0]}  ${mp4file}  ${mp3file}
    Log  ${fudata}

    ${data}=  db.QuestionnaireAnswers   ${qnr_resp.json()}   ${self}   &{fudata}
    Log  ${data}

    ${resp}=  Consumer Validate Questionnaire  ${account_id}  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${fudata}=  db.fileUploadDT   ${qnr_resp.json()}  ${FileAction[0]}  ${mp4file}  ${mp3file}
    # Log  ${fudata}

    # ${data}=  db.QuestionnaireAnswers   ${qnr_resp.json()}   ${self}   &{fudata}
    # Log  ${data}

    ${resp}=  Consumer Validate Questionnaire  ${account_id}  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Revalidate Questionnaire  ${account_id}  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-RevalidateConsumerQuestionnaire-2
    [Documentation]  Revalidate service questionnaire with updated data.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME23}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['timezone']}

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
      ${id}  Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[1]}' and '${resp.json()[${i}]['captureTime']}' == '${QnrcaptureTime[0]}'  Set Variable  ${resp.json()[${i}]['id']} 
      ${qnrid}   Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[1]}' and '${resp.json()[${i}]['captureTime']}' == '${QnrcaptureTime[0]}'  Set Variable  ${resp.json()[${i}]['questionnaireId']}
      Exit For Loop If   '${id}' != '${None}'
    END
    Set Suite Variable   ${id}
    Set Suite Variable   ${qnrid}

    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200

    ${resp1}=  Run Keyword If   '${qns.json()['status']}' == '${status[1]}'  Provider Change Questionnaire Status  ${id}  ${status[0]}  
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings   ${qns.json()['status']}  ${status[0]}
    Set Suite Variable  ${Questionnaireid}  ${qns.json()['questionnaireId']}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${s_len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${s_len}
        ${s_id}=  Run Keyword If   '${resp.json()[${i}]['name']}' in @{unique_snames} and '${resp.json()[${i}]['serviceType']}' != '${ServiceType[2]}'   Set Variable   ${resp.json()[${i}]['id']}
        Exit For Loop If   '${s_id}' != '${None}'
    END
    Set Suite Variable   ${s_id}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME10}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200 

    ${qnr_resp}=  Consumer View Questionnaire  ${account_id}  ${s_id}  ${self}
    Log  ${resp.content}
    Should Be Equal As Strings    ${qnr_resp.status_code}    200
    Should Be Equal As Strings   ${qnr_resp.json()['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${qnr_resp.json()['id']}   ${id}
    
    ${fudata}=  db.fileUploadDT   ${qnr_resp.json()}  ${FileAction[0]}  ${mp4file}  ${mp3file}
    Log  ${fudata}

    ${data}=  db.QuestionnaireAnswers   ${qnr_resp.json()}   ${self}   &{fudata}
    Log  ${data}

    ${resp}=  Consumer Validate Questionnaire  ${account_id}  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fudata}=  db.fileUploadDT   ${qnr_resp.json()}  ${FileAction[1]}  ${mp4file}  ${mp3file}
    Log  ${fudata}

    ${data}=  db.QuestionnaireAnswers   ${qnr_resp.json()}   ${self}   &{fudata}
    Log  ${data}

    ${resp}=  Consumer Validate Questionnaire  ${account_id}  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Revalidate Questionnaire  ${account_id}  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-RevalidateConsumerQuestionnaire-3
    [Documentation]  Revalidate service questionnaire with just the updated part data.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME23}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['timezone']}

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
      ${id}  Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[1]}' and '${resp.json()[${i}]['captureTime']}' == '${QnrcaptureTime[0]}'  Set Variable  ${resp.json()[${i}]['id']} 
      ${qnrid}   Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[1]}' and '${resp.json()[${i}]['captureTime']}' == '${QnrcaptureTime[0]}'  Set Variable  ${resp.json()[${i}]['questionnaireId']}
      Exit For Loop If   '${id}' != '${None}'
    END
    Set Suite Variable   ${id}
    Set Suite Variable   ${qnrid}

    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200

    ${resp1}=  Run Keyword If   '${qns.json()['status']}' == '${status[1]}'  Provider Change Questionnaire Status  ${id}  ${status[0]}  
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings   ${qns.json()['status']}  ${status[0]}
    Set Suite Variable  ${Questionnaireid}  ${qns.json()['questionnaireId']}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${s_len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${s_len}
        ${s_id}=  Run Keyword If   '${resp.json()[${i}]['name']}' in @{unique_snames} and '${resp.json()[${i}]['serviceType']}' != '${ServiceType[2]}'   Set Variable   ${resp.json()[${i}]['id']}
        Exit For Loop If   '${s_id}' != '${None}'
    END
    Set Suite Variable   ${s_id}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME10}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200 

    ${qnr_resp}=  Consumer View Questionnaire  ${account_id}  ${s_id}  ${self}
    Log  ${resp.content}
    Should Be Equal As Strings    ${qnr_resp.status_code}    200
    Should Be Equal As Strings   ${qnr_resp.json()['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${qnr_resp.json()['id']}   ${id}
    
    ${fudata}=  db.fileUploadDT   ${qnr_resp.json()}  ${FileAction[0]}  ${mp4file}  ${mp3file}
    Log  ${fudata}

    ${data}=  db.QuestionnaireAnswers   ${qnr_resp.json()}   ${self}   &{fudata}
    Log  ${data}

    ${resp}=  Consumer Validate Questionnaire  ${account_id}  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fudata}=  db.fileUploadDT   ${qnr_resp.json()}  ${FileAction[1]}  ${mp4file}  ${mp3file}
    Log  ${fudata}

    ${data}=  db.QuestionnaireAnswers   ${qnr_resp.json()}   ${self}   &{fudata}
    Log  ${data}

    ${jsondata}=    evaluate    json.loads('''${data}''')    json
    ${len}=  Get Length  ${jsondata['answerLine']}
    ${ranlist}=   FakerLibrary.words
    FOR  ${i}  IN RANGE   ${len}
        ${key} =	Get Dictionary Keys	${jsondata['answerLine'][${i}]['answer']}  
        Run Keyword If  '${key[0]}' == '${QnrDatatypes[1]}'  
        ...   Set to Dictionary      ${jsondata['answerLine'][${i}]['answer']}    ${QnrDatatypes[1]}=${ranlist}
        ${dataval}=   Set Variable  ${jsondata['answerLine'][${i}]}
        Exit For Loop If   '${key[0]}' == '${QnrDatatypes[1]}'

    END
    ${newData}=   Create List  ${dataval}
    ${DataDict}=  Create Dictionary  questionnaireId=${jsondata['questionnaireId']}  proConId=${jsondata['proConId']}  answerLine=${newData}
    # Set to Dictionary      ${jsondata['answerLine'][0]['answer']}    bool=something
    ${modifieddata}=    Evaluate    json.dumps(${DataDict})    json
    Log  ${modifieddata}

    ${resp}=  Consumer Revalidate Questionnaire  ${account_id}  ${modifieddata}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-RevalidateConsumerQuestionnaire-UH1
    [Documentation]  Revalidate service questionnaire with incorrect data.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME23}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['timezone']}

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
      ${id}  Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[1]}' and '${resp.json()[${i}]['captureTime']}' == '${QnrcaptureTime[0]}'  Set Variable  ${resp.json()[${i}]['id']} 
      ${qnrid}   Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[1]}' and '${resp.json()[${i}]['captureTime']}' == '${QnrcaptureTime[0]}'  Set Variable  ${resp.json()[${i}]['questionnaireId']}
      Exit For Loop If   '${id}' != '${None}'
    END
    Set Suite Variable   ${id}
    Set Suite Variable   ${qnrid}

    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200

    ${resp1}=  Run Keyword If   '${qns.json()['status']}' == '${status[1]}'  Provider Change Questionnaire Status  ${id}  ${status[0]}  
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings   ${qns.json()['status']}  ${status[0]}
    Set Suite Variable  ${Questionnaireid}  ${qns.json()['questionnaireId']}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${s_len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${s_len}
        ${s_id}=  Run Keyword If   '${resp.json()[${i}]['name']}' in @{unique_snames} and '${resp.json()[${i}]['serviceType']}' != '${ServiceType[2]}'   Set Variable   ${resp.json()[${i}]['id']}
        Exit For Loop If   '${s_id}' != '${None}'
    END
    Set Suite Variable   ${s_id}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME10}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200  

    ${qnr_resp}=  Consumer View Questionnaire  ${account_id}  ${s_id}  ${self}
    Log  ${resp.content}
    Should Be Equal As Strings    ${qnr_resp.status_code}    200
    Should Be Equal As Strings   ${qnr_resp.json()['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${qnr_resp.json()['id']}   ${id}
    
    ${fudata}=  db.fileUploadDT   ${qnr_resp.json()}  ${FileAction[0]}  ${mp4file}  ${mp3file}
    Log  ${fudata}

    ${data}=  db.QuestionnaireAnswers   ${qnr_resp.json()}   ${self}   &{fudata}
    Log  ${data}

    ${resp}=  Consumer Validate Questionnaire  ${account_id}  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fudata}=  db.fileUploadDT   ${qnr_resp.json()}  ${FileAction[1]}  ${mp4file}  ${mp3file}
    Log  ${fudata}

    ${data}=  db.QuestionnaireAnswers   ${qnr_resp.json()}   ${self}   &{fudata}
    Log  ${data}
    Set Suite Variable   ${data}

    ${jsondata}=    evaluate    json.loads('''${data}''')    json
    ${len}=  Get Length  ${jsondata['answerLine']}
    ${ranlist}=   FakerLibrary.words
    FOR  ${i}  IN RANGE   ${len}
        ${key} =	Get Dictionary Keys	${jsondata['answerLine'][${i}]['answer']}  
        Run Keyword If  '${key[0]}' == '${QnrDatatypes[1]}'  
        ...   Set to Dictionary      ${jsondata['answerLine'][${i}]['answer']}    ${QnrDatatypes[1]}=${ranlist}

    END
    
    # Set to Dictionary      ${jsondata['answerLine'][0]['answer']}    bool=something
    ${modifieddata}=    Evaluate    json.dumps(${jsondata})    json
    Log  ${modifieddata}

    ${resp}=  Consumer Validate Questionnaire  ${account_id}  ${modifieddata}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Revalidate Questionnaire  ${account_id}  ${modifieddata}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-RevalidateConsumerQuestionnaire-UH2
    [Documentation]  Revalidate data without consumer login.

    ${resp}=  Consumer Revalidate Questionnaire  ${account_id}  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.json()}  ${SESSION_EXPIRED}


JD-TC-RevalidateConsumerQuestionnaire-UH3
    [Documentation]  Revalidate data by provider login

    ${resp}=  Encrypted Provider Login  ${PUSERNAME23}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Consumer Revalidate Questionnaire  ${account_id}  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200