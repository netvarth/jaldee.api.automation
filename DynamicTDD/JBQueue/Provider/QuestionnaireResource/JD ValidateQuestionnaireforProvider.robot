*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Run Keywords  Delete All Sessions
Force Tags        Questionnaire
Library           Collections
Library           String
Library           json
Library           FakerLibrary
#Library           ExcellentLibrary
Library           OperatingSystem
Library           /ebs/TDD/excelfuncs.py
Resource          /ebs/TDD/SuperAdminKeywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

*** Variables ***
${xlFile}      ${EXECDIR}/TDD/sampleqnr.xlsx    # DataSheet
${xlFile2}      ${EXECDIR}/TDD/qnr.xlsx    # DataSheet 2
${self}      0
@{emptylist}
${mp4file}   /ebs/TDD/MP4file.mp4
${mp4mime}   video/mp4
${mp3file}   /ebs/TDD/MP3file.mp3
${mp3mime}   audio/mpeg
${pdffile}   /ebs/TDD/sample.pdf


*** Keywords ***


# Open given Excel file
#     [Arguments]    ${xlFile}  ${doc id}
#     #Check that the given Excel Exists
#     ${inputfileStatus}    ${msg}    Run Keyword And Ignore Error    OperatingSystem.File Should Exist    ${xlFile}
#     Run Keyword If    "${inputfileStatus}"=="PASS"    Log   ${xlFile} Test data file exist    ELSE    Log    Cannot locate the given Excel file.  ERROR
#     Open workbook   ${xlFile}   ${doc id}


*** Test Cases ***

JD-TC-ValidateQuestionnaire-1
    [Documentation]  Validate service questionnaire after enabling it.

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
    Remove Values From List  ${servicenames}   ${NONE}
    Log  ${servicenames}
    ${unique_snames}=    Remove Duplicates    ${servicenames}
    Log  ${unique_snames}
    Set Suite Variable   ${unique_snames}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME14}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${s_len}=  Get Length  ${resp.json()}
    @{snames}=  Create List
    FOR  ${i}  IN RANGE   ${s_len}
        IF  '${resp.json()[${i}]['name']}' in @{unique_snames} and '${resp.json()[${i}]['serviceType']}' == '${service_type[2]}'
            ${s_id}=  Set Variable   ${resp.json()[${i}]['id']}
        ELSE IF  '${resp.json()[${i}]['name']}' in @{unique_snames} and '${resp.json()[${i}]['serviceType']}' == '${service_type[0]}'
            ${d_id}=  Set Variable   ${resp.json()[${i}]['id']}
        ELSE
            Append To List  ${snames}  ${resp.json()[${i}]['name']}
        END
    END

    Log  ${snames}
    ${srv_val}=    Get Variable Value    ${s_id}
    ${don_val}=    Get Variable Value    ${d_id}
    
    IF  '${srv_val}'=='${None}' or '${don_val}'=='${None}'
        ${snames_len}=  Get Length  ${unique_snames}
        FOR  ${i}  IN RANGE   ${snames_len}
            &{dict}=  Create Dictionary   ${colnames[6]}=${unique_snames[${i}]}
            ${ttype}=  getColumnValueByMultipleVals  ${sheet1}  ${colnames[1]}  &{dict}  
            Log  ${ttype}
            ${u_ttype}=    Remove Duplicates    ${ttype}
            Log  ${u_ttype}
            IF   '${QnrTransactionType[3]}' in @{u_ttype} and '${srv_val}'=='${None}'
                ${s_id}=  Create Sample Service  ${unique_snames[${i}]}  maxBookingsAllowed=10
            ELSE IF  '${QnrTransactionType[0]}' in @{u_ttype} and '${don_val}'=='${None}'
                ${d_id}=  Create Sample Donation  ${unique_snames[${i}]}
            END
        END
    END

    Set Suite Variable   ${s_id}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${cookie}  ${resp}=  Imageupload.SALogin    ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Imageupload.UploadQuestionnaire   ${cookie}   ${account_id}    ${xlFile}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME14}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
        IF  '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[1]}'
            ${id}   Set Variable  ${resp.json()[${i}]['id']}
            ${qnrid}   Set Variable  ${resp.json()[${i}]['questionnaireId']}
            Exit For Loop If   '${id}' != '${None}'
        END
    #   ${id}  Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[1]}'  Set Variable  ${resp.json()[${i}]['id']} 
    #   ${qnrid}   Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[1]}'  Set Variable  ${resp.json()[${i}]['questionnaireId']}
    #   Exit For Loop If   '${id}' != '${None}'
    END
    Set Suite Variable   ${id}
    Set Suite Variable   ${qnrid}

    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings  ${qns.json()['transactionId']}  ${s_id}
    IF  '${qns.json()['status']}' == '${status[1]}' 
        ${resp1}=   Provider Change Questionnaire Status  ${id}  ${status[0]}  
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    # ${resp1}=  Run Keyword If   '${qns.json()['status']}' == '${status[1]}'  Provider Change Questionnaire Status  ${id}  ${status[0]}  
    # Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    # Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings   ${qns.json()['status']}  ${status[0]}
    Set Suite Variable  ${Questionnaireid}  ${qns.json()['questionnaireId']}
    Set Suite Variable  ${Questionnaireid}  ${qns.json()['questionnaireId']}

    # ${resp}=   Get Service
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${s_len}=  Get Length  ${resp.json()}
    # FOR  ${i}  IN RANGE   ${s_len}
    #     ${s_id}=  Run Keyword If   '${resp.json()[${i}]['name']}' in @{unique_snames} and '${resp.json()[${i}]['serviceType']}' != '${service_type[0]}'   Set Variable   ${resp.json()[${i}]['id']}
    #     Exit For Loop If   '${s_id}' != '${None}'
    # END
    # Set Suite Variable   ${s_id}

    ${cid}=  get_id  ${CUSERNAME1}

    ${resp}=  Get Consumer Questionnaire By Channel and ServiceID   ${s_id}   ${QnrChannel[1]}  ${cid}      
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${resp.json()['id']}   ${id}
    
    ${fudata}=  db.fileUploadDT   ${resp.json()}  ${FileAction[0]}  ${Questionnaireid}  ${mp4file}  ${mp3file}
    Log  ${fudata}

    ${data}=  db.QuestionnaireAnswers   ${resp.json()}   ${self}   &{fudata}
    Log  ${data}
    Set Suite Variable   ${data}

    ${resp}=  Provider Validate Questionnaire  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-ValidateQuestionnaire-2
    [Documentation]  Validate Donation questionnaire after enabling it.

    comment  Cannot get donation questionnaire from provider side.

    # ${wb}=  readWorkbook  ${xlFile}
    # ${sheet1}  GetCurrentSheet   ${wb}
    # Set Suite Variable   ${sheet1}
    # ${colnames}=  getColumnHeaders  ${sheet1}
    # Log List  ${colnames}
    # Log List  ${QnrChannel}
    # Log List  ${QnrTransactionType}
    # Set Suite Variable   ${colnames}
    # ${servicenames}   getColumnValuesByName  ${sheet1}  ${colnames[6]}
    # Log   ${servicenames}
    # Set Suite Variable   ${servicenames}

    # ${resp}=  Encrypted Provider Login  ${PUSERNAME14}  ${PASSWORD}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Get Business Profile
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${account_id}  ${resp.json()['id']}

    # ${resp}=   Get Service
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${s_len}=  Get Length  ${resp.json()}
    # @{snames}=  Create List
    # FOR  ${i}  IN RANGE   ${s_len}
    #     Append To List  ${snames}  ${resp.json()[${i}]['name']}
    # END

    # Remove Values From List  ${servicenames}   ${NONE}
    # Log  ${servicenames}
    # ${unique_snames}=    Remove Duplicates    ${servicenames}
    # Log  ${unique_snames}
    # Set Suite Variable   ${unique_snames}
    # ${snames_len}=  Get Length  ${unique_snames}
    # FOR  ${i}  IN RANGE   ${snames_len}
    #     ${kwstatus} 	${value} = 	Run Keyword And Ignore Error  List Should Contain Value  ${snames}  ${unique_snames[${i}]}
    #     Log Many  ${kwstatus} 	${value}
    #     Continue For Loop If  '${kwstatus}' == 'PASS'
    #     &{dict}=  Create Dictionary   ${colnames[6]}=${unique_snames[${i}]}
    #     ${ttype}=  getColumnValueByMultipleVals  ${sheet1}  ${colnames[1]}  &{dict}  
    #     Log  ${ttype}
    #     ${u_ttype}=    Remove Duplicates    ${ttype}
    #     Log  ${u_ttype}
    #     ${s_id}=  Run Keyword If   '${kwstatus}' == 'FAIL' and '${QnrTransactionType[3]}' in @{u_ttype}  Create Sample Service  ${unique_snames[${i}]}
    #     ${d_id}=  Run Keyword If   '${kwstatus}' == 'FAIL' and '${QnrTransactionType[0]}' in @{u_ttype}   Create Sample Donation  ${unique_snames[${i}]}
    # END

    # ${resp}=  Provider Logout
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    
    # ${cookie}  ${resp}=  Imageupload.SALogin    ${SUSERNAME}  ${SPASSWORD}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Imageupload.UploadQuestionnaire   ${cookie}   ${account_id}   ${xlFile}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Encrypted Provider Login  ${PUSERNAME14}  ${PASSWORD}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Get Questionnaire List By Provider   
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${len}=  Get Length  ${resp.json()}

    # Comment   Disable Service Questionnaire
    # FOR  ${i}  IN RANGE   ${len}
    #   ${id}  Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[1]}'  Set Variable  ${resp.json()[${i}]['id']} 
    # #   ${qnrid}   Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[1]}'  Set Variable  ${resp.json()[${i}]['questionnaireId']}
    #   Exit For Loop If   '${id}' != '${None}'
    # END
    # # Set Suite Variable   ${id}
    # # Set Suite Variable   ${qnrid}

    # ${qns}   Get Provider Questionnaire By Id   ${id}  
    # Log  ${qns.content}
    # Should Be Equal As Strings  ${qns.status_code}  200

    # ${resp1}=  Run Keyword If   '${qns.json()['status']}' == '${status[0]}'  Provider Change Questionnaire Status  ${id}  ${status[1]}  
    # Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    # Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    # ${qns}   Get Provider Questionnaire By Id   ${id}  
    # Log  ${qns.content}
    # Should Be Equal As Strings  ${qns.status_code}  200
    # Should Be Equal As Strings   ${qns.json()['status']}  ${status[1]}

    # Comment   Enable Donation Questionnaire
    
    # FOR  ${i}  IN RANGE   ${len}
    #   ${id}  Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[0]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[1]}'  Set Variable  ${resp.json()[${i}]['id']} 
    #   ${qnrid}   Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[0]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[1]}'  Set Variable  ${resp.json()[${i}]['questionnaireId']}
    #   Exit For Loop If   '${id}' != '${None}'
    # END
    # # Set Suite Variable   ${id}
    # # Set Suite Variable   ${qnrid}

    # ${qns}   Get Provider Questionnaire By Id   ${id}  
    # Log  ${qns.content}
    # Should Be Equal As Strings  ${qns.status_code}  200

    # ${resp1}=  Run Keyword If   '${qns.json()['status']}' == '${status[1]}'  Provider Change Questionnaire Status  ${id}  ${status[0]}  
    # Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    # Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    # ${qns}   Get Provider Questionnaire By Id   ${id}  
    # Log  ${qns.content}
    # Should Be Equal As Strings  ${qns.status_code}  200
    # Should Be Equal As Strings   ${qns.json()['status']}  ${status[0]}

    # ${resp}=   Get Service
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${s_len}=  Get Length  ${resp.json()}
    # FOR  ${i}  IN RANGE   ${s_len}
    #     ${s_id}=  Run Keyword If   '${resp.json()[${i}]['name']}' in @{unique_snames} and '${resp.json()[${i}]['serviceType']}' == '${service_type[0]}'   Set Variable   ${resp.json()[${i}]['id']}
    #     Exit For Loop If   '${s_id}' != '${None}'
    # END
    # # Set Suite Variable   ${s_id}

    # ${cid}=  get_id  ${CUSERNAME1}

    # ${resp}=  Get Consumer Questionnaire By Channel and ServiceID   ${s_id}   ${QnrChannel[1]}  ${cid}      
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings   ${resp.json()['questionnaireId']}  ${qnrid}
    # Should Be Equal As Strings  ${resp.json()['id']}   ${id}

    # ${fudata}=  db.fileUploadDT   ${resp.json()}  ${FileAction[0]}  ${Questionnaireid}${mp4file}  ${mp3file}
    # Log  ${fudata}

    # ${data}=  db.QuestionnaireAnswers   ${resp.json()}   ${self}   &{fudata}
    # Log  ${data}

    # ${resp}=  Provider Validate Questionnaire  ${data}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Provider Logout
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-ValidateQuestionnaire-UH1
    [Documentation]  Validate service questionnaire with wrong caption.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME14}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}

    Comment   Disable Donation Questionnaire
    # FOR  ${i}  IN RANGE   ${len}
    #   ${id}  Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[0]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[1]}'  Set Variable  ${resp.json()[${i}]['id']} 
    # #   ${qnrid}   Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[1]}'  Set Variable  ${resp.json()[${i}]['questionnaireId']}
    #   Exit For Loop If   '${id}' != '${None}'
    # END
    # # Set Suite Variable   ${id}
    # # Set Suite Variable   ${qnrid}

    # ${qns}   Get Provider Questionnaire By Id   ${id}  
    # Log  ${qns.content}
    # Should Be Equal As Strings  ${qns.status_code}  200

    # IF  '${qns.json()['status']}' == '${status[0]}' 
    #     ${resp1}=   Provider Change Questionnaire Status  ${id}  ${status[1]}  
    #     Should Be Equal As Strings  ${resp1.status_code}  200
    # END

    # # ${resp1}=  Run Keyword If   '${qns.json()['status']}' == '${status[0]}'  Provider Change Questionnaire Status  ${id}  ${status[1]}  
    # # Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    # # Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    # ${qns}   Get Provider Questionnaire By Id   ${id}  
    # Log  ${qns.content}
    # Should Be Equal As Strings  ${qns.status_code}  200
    # Should Be Equal As Strings   ${qns.json()['status']}  ${status[1]}

    Comment   Enable Service Questionnaire
    
    FOR  ${i}  IN RANGE   ${len}
        IF  '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[1]}'
            ${id}   Set Variable  ${resp.json()[${i}]['id']}
            ${qnrid}   Set Variable  ${resp.json()[${i}]['questionnaireId']}
            Exit For Loop If   '${id}' != '${None}'
        END
    #   ${id}  Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[1]}'  Set Variable  ${resp.json()[${i}]['id']} 
    #   ${qnrid}   Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[1]}'  Set Variable  ${resp.json()[${i}]['questionnaireId']}
    #   Exit For Loop If   '${id}' != '${None}'
    END
    # Set Suite Variable   ${id}
    # Set Suite Variable   ${qnrid}

    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200

    IF  '${qns.json()['status']}' == '${status[1]}' 
        ${resp1}=   Provider Change Questionnaire Status  ${id}  ${status[0]}  
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    # ${resp1}=  Run Keyword If   '${qns.json()['status']}' == '${status[1]}'  Provider Change Questionnaire Status  ${id}  ${status[0]}  
    # Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    # Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

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
        ${s_id}=  Run Keyword If   '${resp.json()[${i}]['name']}' in @{unique_snames} and '${resp.json()[${i}]['serviceType']}' != '${service_type[0]}'   Set Variable   ${resp.json()[${i}]['id']}
        Exit For Loop If   '${s_id}' != '${None}'
    END
    # Set Suite Variable   ${s_id}

    ${cid}=  get_id  ${CUSERNAME1}

    ${resp}=  Get Consumer Questionnaire By Channel and ServiceID   ${s_id}   ${QnrChannel[1]}  ${cid}      
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${resp.json()['id']}   ${id}
    
    ${fudata}=  db.fileUploadDT   ${resp.json()}  ${FileAction[0]}  ${Questionnaireid}  ${mp4file}  ${mp3file}
    Log  ${fudata}

    # ${caption}=  FakerLibrary.word
    # Set to Dictionary      ${fudata['fileupload'][0]['files'][0]}    caption=${caption}
    
    ${data}=  db.QuestionnaireAnswers   ${resp.json()}   ${self}   &{fudata}
    Log  ${data}

    ${caption}=  FakerLibrary.word
    ${jsondata}=    evaluate    json.loads('''${data}''')    json
    Log  ${jsondata}
    ${len}=  Get Length  ${jsondata['answerLine']}
    FOR  ${i}  IN RANGE   ${len}
        ${keys} =	Get Dictionary Keys	${jsondata['answerLine'][${i}]['answer']} 
        FOR  ${QnrDatatypes[5]}  IN  @{keys}
            Set to Dictionary      ${jsondata['answerLine'][${i}]['answer']['fileUpload'][0]}    caption=${caption}
        END
    END
    # Set to Dictionary      ${jsondata['answerLine'][2]['answer']['fileUpload'][0]}    caption=${caption}
    ${modifieddata}=    Evaluate    json.dumps(${jsondata})    json
    
    ${resp}=  Provider Validate Questionnaire  ${modifieddata}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[0]['questionField']}   ${LabelName}
    Should Be Equal As Strings  ${resp.json()[0]['error']}   ${INCORRECT_DOUMENT}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-ValidateQuestionnaire-UH2
    [Documentation]  Validate service questionnaire without caption

    ${resp}=  Encrypted Provider Login  ${PUSERNAME14}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${cid}=  get_id  ${CUSERNAME1}

    ${resp}=  Get Consumer Questionnaire By Channel and ServiceID   ${s_id}   ${QnrChannel[1]}  ${cid}      
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${resp.json()['id']}   ${id}
    
    ${fudata}=  db.fileUploadDT   ${resp.json()}  ${FileAction[0]}  ${Questionnaireid}  ${mp4file}  ${mp3file}
    Log  ${fudata}

    # Set to Dictionary      ${fudata['fileupload'][0]['files'][0]}    caption=${EMPTY}
    
    ${data}=  db.QuestionnaireAnswers   ${resp.json()}   ${self}   &{fudata}
    Log  ${data}

    ${jsondata}=    evaluate    json.loads('''${data}''')    json
    Log  ${jsondata}
    ${len}=  Get Length  ${jsondata['answerLine']}
    FOR  ${i}  IN RANGE   ${len}
        ${keys} =	Get Dictionary Keys	${jsondata['answerLine'][${i}]['answer']} 
        FOR  ${QnrDatatypes[5]}  IN  @{keys}
            Set to Dictionary      ${jsondata['answerLine'][${i}]['answer']['fileUpload'][0]}    caption=${EMPTY}
        END
    END
    # Set to Dictionary      ${jsondata['answerLine'][2]['answer']['fileUpload'][0]}    caption=${EMPTY}
    ${modifieddata}=    Evaluate    json.dumps(${jsondata})    json
    Log  ${modifieddata}
    
    ${resp}=  Provider Validate Questionnaire  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[0]['questionField']}   ${fileLabelName}
    Should Be Equal As Strings  ${resp.json()[0]['error']}   ${INCORRECT_DOUMENT}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-ValidateQuestionnaire-UH3
    [Documentation]  Validate service questionnaire without index

    ${resp}=  Encrypted Provider Login  ${PUSERNAME14}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${cid}=  get_id  ${CUSERNAME1}

    ${resp}=  Get Consumer Questionnaire By Channel and ServiceID   ${s_id}   ${QnrChannel[1]}  ${cid}      
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${resp.json()['id']}   ${id}
    
    ${fudata}=  db.fileUploadDT   ${resp.json()}  ${FileAction[0]}  ${Questionnaireid}  ${mp4file}  ${mp3file}
    Log  ${fudata}

    Set to Dictionary      ${fudata['fileupload'][0]['files'][0]}    index=${EMPTY}
    
    ${data}=  db.QuestionnaireAnswers   ${resp.json()}   ${self}   &{fudata}
    Log  ${data}
    
    ${resp}=  Provider Validate Questionnaire  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()}    []

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-ValidateQuestionnaire-UH4
    [Documentation]  Validate service questionnaire with incorrect action (anything other than "add")

    ${resp}=  Encrypted Provider Login  ${PUSERNAME14}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${cid}=  get_id  ${CUSERNAME1}

    ${resp}=  Get Consumer Questionnaire By Channel and ServiceID   ${s_id}   ${QnrChannel[1]}  ${cid}      
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${resp.json()['id']}   ${id}
    
    ${fudata}=  db.fileUploadDT   ${resp.json()}  ${FileAction[1]}  ${mp4file}  ${mp3file}
    Log  ${fudata}
    
    ${data}=  db.QuestionnaireAnswers   ${resp.json()}   ${self}   &{fudata}
    Log  ${data}
    
    ${resp}=  Provider Validate Questionnaire  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()}    []

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


# JD-TC-ValidateQuestionnaire-UH5
#     [Documentation]  Validate service questionnaire with invalid action

#     ${resp}=  Encrypted Provider Login  ${PUSERNAME14}  ${PASSWORD}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${cid}=  get_id  ${CUSERNAME1}

#     ${resp}=  Get Consumer Questionnaire By Channel and ServiceID   ${s_id}   ${QnrChannel[1]}  ${cid}      
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings   ${resp.json()['questionnaireId']}  ${qnrid}
#     Should Be Equal As Strings  ${resp.json()['id']}   ${id}
    
#     ${fudata}=  db.fileUploadDT   ${resp.json()}  ${FileAction[0]}  ${Questionnaireid}  ${mp4file}  ${mp3file}
#     Log  ${fudata}

#     ${action}=  FakerLibrary.word
#     Set to Dictionary      ${fudata['fileupload'][0]['files'][0]}    action=${action}
    
#     ${data}=  db.QuestionnaireAnswers   ${resp.json()}   ${self}   &{fudata}
#     Log  ${data}
    
#     ${resp}=  Provider Validate Questionnaire  ${data}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  422

#     ${resp}=  Provider Logout
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200


# JD-TC-ValidateQuestionnaire-UH6
#     [Documentation]  Validate service questionnaire without action.

#     ${resp}=  Encrypted Provider Login  ${PUSERNAME14}  ${PASSWORD}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${cid}=  get_id  ${CUSERNAME1}

#     ${resp}=  Get Consumer Questionnaire By Channel and ServiceID   ${s_id}   ${QnrChannel[1]}  ${cid}      
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings   ${resp.json()['questionnaireId']}  ${qnrid}
#     Should Be Equal As Strings  ${resp.json()['id']}   ${id}
    
#     ${fudata}=  db.fileUploadDT   ${resp.json()}  ${FileAction[0]}  ${Questionnaireid}  ${mp4file}  ${mp3file}
#     Log  ${fudata}

#     Set to Dictionary      ${fudata['fileupload'][0]['files'][0]}    action=${EMPTY}
    
#     ${data}=  db.QuestionnaireAnswers   ${resp.json()}   ${self}   &{fudata}
#     Log  ${data}
    
#     ${resp}=  Provider Validate Questionnaire  ${data}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  422

#     ${resp}=  Provider Logout
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-ValidateQuestionnaire-UH7
    [Documentation]  Validate service questionnaire without provider login.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME14}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${cid}=  get_id  ${CUSERNAME1}

    ${resp}=  Get Consumer Questionnaire By Channel and ServiceID   ${s_id}   ${QnrChannel[1]}  ${cid}      
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${resp.json()['id']}   ${id}
    
    ${fudata}=  db.fileUploadDT   ${resp.json()}  ${FileAction[0]}  ${Questionnaireid}  ${mp4file}  ${mp3file}
    Log  ${fudata}
    
    ${data}=  db.QuestionnaireAnswers   ${resp.json()}   ${self}   &{fudata}
    Log  ${data}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Provider Validate Questionnaire  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}    ${SESSION_EXPIRED}


JD-TC-ValidateQuestionnaire-UH8
    [Documentation]  Validate service questionnaire by consumer login.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME14}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${cid}=  get_id  ${CUSERNAME1}

    ${resp}=  Get Consumer Questionnaire By Channel and ServiceID   ${s_id}   ${QnrChannel[1]}  ${cid}      
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${resp.json()['id']}   ${id}
    
    ${fudata}=  db.fileUploadDT   ${resp.json()}  ${FileAction[0]}  ${Questionnaireid}  ${mp4file}  ${mp3file}
    Log  ${fudata}
    
    ${data}=  db.QuestionnaireAnswers   ${resp.json()}   ${self}   &{fudata}
    Log  ${data}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Provider Validate Questionnaire  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}    ${SESSION_EXPIRED}

    
