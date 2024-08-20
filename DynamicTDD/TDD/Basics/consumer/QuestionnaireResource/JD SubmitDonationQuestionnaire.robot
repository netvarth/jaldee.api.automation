*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Run Keywords  Delete All Sessions
Force Tags        Questionnaire
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           OperatingSystem
Library           /ebs/TDD/excelfuncs.py
Resource          /ebs/TDD/SuperAdminKeywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

*** Variables ***
${xlFile}      ${EXECDIR}/TDD/sampleQnrWOAV.xlsx    # DataSheet
${pdffile}     /ebs/TDD/sample.pdf
${self}      0
@{emptylist}


*** Keywords ***

Strip and split string
   [Arguments]    ${value}  ${char}
#    ${stripped}=    Remove String    ${value}    ${SPACE}
   ${status} 	${split}=  Run Keyword And Ignore Error  Split String    ${value}  ${char}
   Return From Keyword If    '${status}' == 'FAIL'    ${value}
   ${final_list} =  Create List
   FOR  ${val}  IN  @{split}
      ${stripped}=  Strip String  ${val}
      Append To List  ${final_list}  ${stripped}
   END
   Log List   ${final_list}
   Log   ${final_list}

   RETURN  ${final_list}


Comapre Lists without order
    [Arguments]    ${list1}  ${list2}
    ${list1_copy}   Copy List  ${list1}
    ${list2_copy}   Copy List  ${list2}
    Sort List  ${list1_copy}
    Sort List  ${list2_copy}

    ${status} 	${value} = 	Run Keyword And Ignore Error  Lists Should Be Equal  ${list1_copy}  ${list2_copy}
    Log Many  ${status} 	${value}
    ${val}=  Run Keyword If   '${status}' == 'FAIL'  Set Variable  ${bool[0]}
    ...  ELSE	 Set Variable    ${bool[1]}
    RETURN  ${val}


Check Answers
    [Arguments]  ${resp}  ${data}  
    ${len}=  Get Length  ${resp.json()['questionnaire']['questionAnswers']}
    # ${answer}=  Set Variable  ${data}
    ${data}=  json.loads  ${data}
    Log  ${data}
    ${dttypes}=  Create List  '${QnrDatatypes[0]}'  '${QnrDatatypes[1]}'  '${QnrDatatypes[2]}'  '${QnrDatatypes[3]}'

    FOR  ${i}  IN RANGE   ${len}
        
        Run Keyword And Continue On Failure  Should Be Equal As Strings   '${resp.json()['questionnaire']['questionAnswers'][${i}]['question']['id']}'  '${resp.json()['questionnaire']['questionAnswers'][${i}]['answerLine']['id']}'
        Run Keyword And Continue On Failure  Should Be Equal As Strings   '${resp.json()['questionnaire']['questionAnswers'][${i}]['question']['labelName']}'  '${resp.json()['questionnaire']['questionAnswers'][${i}]['answerLine']['labelName']}'

        
        
        Run Keyword If  '${resp.json()['questionnaire']['questionAnswers'][${i}]['question']['fieldDataType']}' in @{dttypes}
        ...    Run Keywords
        ...    Run Keyword And Continue On Failure  Should Be Equal As Strings  '${resp.json()['questionnaire']['questionAnswers'][${i}]['answerLine']['answer']}'   '${data['answerLine'][${i}]['answer']}'
        
        
        ...    ELSE IF  '${resp.json()['questionnaire']['questionAnswers'][${i}]['question']['fieldDataType']}' == '${QnrDatatypes[5]}'
        ...    Run Keywords
        ...    Run Keyword And Continue On Failure  Should Be Equal As Strings  '${resp.json()['questionnaire']['questionAnswers'][${i}]['answerLine']['answer']['${QnrDatatypes[5]}'][0]['caption']}'   '${data['answerLine'][${i}]['answer']['${QnrDatatypes[5]}'][0]['caption']}'
        ...    AND  Run Keyword And Continue On Failure  Should Be Equal As Strings  '${resp.json()['questionnaire']['questionAnswers'][${i}]['answerLine']['answer']['${QnrDatatypes[5]}'][0]['status']}'   '${QnrStatus[0]}'
        
    END


*** Test Cases ***

JD-TC-SubmitQuestionnaireForDonation-1
    [Documentation]  Submit questionnaire for Donation

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

    ${resp}=  Encrypted Provider Login  ${PUSERNAME22}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Enable Disable Online Payment   ${toggle[0]}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['onlinePayment']}==${bool[0]}   
        ${resp}=   Enable Disable Online Payment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

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

    ${resp}=  Imageupload.UploadQuestionnaire   ${cookie}   ${account_id}   ${xlFile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME22}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}  

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']} 
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${s_len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${s_len}
        ${d_id}=  Run Keyword If   '${resp.json()[${i}]['name']}' in @{unique_snames} and '${resp.json()[${i}]['serviceType']}' == '${service_type[0]}'   Set Variable   ${resp.json()[${i}]['id']}
        Exit For Loop If   '${d_id}' != '${None}'
    END
    Set Suite Variable   ${d_id}

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
      ${id}  Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[0]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[1]}' and '${resp.json()[${i}]['captureTime']}' == '${QnrcaptureTime[0]}'  Set Variable  ${resp.json()[${i}]['id']} 
      ${qnrid}   Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[0]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[1]}' and '${resp.json()[${i}]['captureTime']}' == '${QnrcaptureTime[0]}'  Set Variable  ${resp.json()[${i}]['questionnaireId']}
      Exit For Loop If   '${id}' != '${None}'
    END
    Set Suite Variable   ${id}
    Set Suite Variable   ${qnrid}

    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings  ${qns.json()['transactionId']}  ${d_id}

    ${resp1}=  Run Keyword If   '${qns.json()['status']}' == '${status[1]}'  Provider Change Questionnaire Status  ${id}  ${status[0]}  
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings   ${qns.json()['status']}  ${status[0]}
    Set Suite Variable  ${Questionnaireid}  ${qns.json()['questionnaireId']}
    Set Suite Variable  ${Questionnaireid}  ${qns.json()['questionnaireId']}

    ${resp}=  Consumer Login  ${CUSERNAME12}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}
    Set Suite Variable  ${con_id}   ${resp.json()['id']}

    ${don_amt}=   Random Int   min=500   max=1000  step=10
    ${don_amt}=  Convert To Number  ${don_amt}  1
    ${resp}=  Donation By Consumer  ${con_id}  ${d_id}  ${lid}  ${don_amt}  ${fname}  ${lname}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${account_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    ${don_id}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${don_id}  ${don_id[0]}

    ${resp}=  Get Consumer Donation By Id  ${don_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}    uid=${don_id}

    # ${resp}=  Consumer View Questionnaire  ${account_id}  ${d_id}  ${self}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings   ${resp.json()['questionnaireId']}  ${qnrid}
    # Should Be Equal As Strings  ${resp.json()['id']}   ${id}

    ${resp}=   Get Donation Questionnaire By Id   ${account_id}  ${d_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${resp.json()['id']}   ${id}

    ${fudata}=  db.fileUploadDT   ${resp.json()}  ${FileAction[0]}  ${Questionnaireid}  ${pdffile}
    Log  ${fudata}
    ${data}=  db.QuestionnaireAnswers   ${resp.json()}   ${self}   &{fudata}
    Log  ${data}
    Set Suite Variable   ${data}
    ${resp}=  Consumer Validate Questionnaire  ${account_id}  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME12}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Imageupload.CDonationQAnsUpload   ${cookie}  ${account_id}   ${don_id}   ${data}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Consumer View Questionnaire  ${account_id}  ${d_id}  ${self}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # Check Answers   ${resp}  ${data}

    ${resp}=   Get Donation Questionnaire By Id   ${account_id}  ${d_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${resp.json()['id']}   ${id}

    ${resp}=  Get Consumer Donation By Id  ${don_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Check Answers   ${resp}  ${data}


JD-TC-SubmitQuestionnaireForDonation-UH1
    [Documentation]  Submit questionnaire for Donation without consumer login

    ${cookie_val}   Generate_random_value  size=32  chars=string.digits
    ${cookie}   Create Dictionary  JSESSIONYNW=${cookie_val}

    ${resp}=  Imageupload.CDonationQAnsUpload   ${cookie}  ${account_id}   ${don_id}   ${data}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.json()}  ${SESSION_EXPIRED}


JD-TC-SubmitQuestionnaireForDonation-UH2
    [Documentation]  Submit questionnaire for Donation by provider login

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME22}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200
    
    ${resp}=  Imageupload.CDonationQAnsUpload   ${cookie}  ${account_id}   ${don_id}   ${data}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422


JD-TC-SubmitQuestionnaireForDonation-UH3
    [Documentation]  Submit the same answers for Donation Questionnaire twice.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME22}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}  

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']} 
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${s_len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${s_len}
        ${d_id}=  Run Keyword If   '${resp.json()[${i}]['name']}' in @{unique_snames} and '${resp.json()[${i}]['serviceType']}' == '${service_type[0]}'   Set Variable   ${resp.json()[${i}]['id']}
        Exit For Loop If   '${d_id}' != '${None}'
    END
    Set Suite Variable   ${d_id}

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
      ${id}  Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[0]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[1]}' and '${resp.json()[${i}]['captureTime']}' == '${QnrcaptureTime[0]}'  Set Variable  ${resp.json()[${i}]['id']} 
      ${qnrid}   Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[0]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[1]}' and '${resp.json()[${i}]['captureTime']}' == '${QnrcaptureTime[0]}'  Set Variable  ${resp.json()[${i}]['questionnaireId']}
      Exit For Loop If   '${id}' != '${None}'
    END
    Set Suite Variable   ${id}
    Set Suite Variable   ${qnrid}

    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings  ${qns.json()['transactionId']}  ${d_id}

    ${resp1}=  Run Keyword If   '${qns.json()['status']}' == '${status[1]}'  Provider Change Questionnaire Status  ${id}  ${status[0]}  
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings   ${qns.json()['status']}  ${status[0]}
    Set Suite Variable  ${Questionnaireid}  ${qns.json()['questionnaireId']}
    Set Suite Variable  ${Questionnaireid2}  ${qns.json()['questionnaireId']}

    ${resp}=  Consumer Login  ${CUSERNAME12}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}
    Set Suite Variable  ${con_id}   ${resp.json()['id']}

    ${don_amt}=   Random Int   min=500   max=1000  step=10
    ${don_amt}=  Convert To Number  ${don_amt}  1
    ${resp}=  Donation By Consumer  ${con_id}  ${d_id}  ${lid}  ${don_amt}  ${fname}  ${lname}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${account_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    ${don_id}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${don_id}  ${don_id[0]}

    ${resp}=  Get Consumer Donation By Id  ${don_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}    uid=${don_id}

    # ${resp}=  Consumer View Questionnaire  ${account_id}  ${d_id}  ${self}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings   ${resp.json()['questionnaireId']}  ${qnrid}
    # Should Be Equal As Strings  ${resp.json()['id']}   ${id}

    ${resp}=   Get Donation Questionnaire By Id   ${account_id}  ${d_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${resp.json()['id']}   ${id}
  
    ${fudata}=  db.fileUploadDT   ${resp.json()}  ${FileAction[0]}  ${Questionnaireid2}  ${pdffile}
    Log  ${fudata}

    ${data}=  db.QuestionnaireAnswers   ${resp.json()}   ${self}   &{fudata}
    Log  ${data}
    ${resp}=  Consumer Validate Questionnaire  ${account_id}  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME12}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Imageupload.CDonationQAnsUpload   ${cookie}  ${account_id}   ${don_id}   ${data}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Consumer View Questionnaire  ${account_id}  ${d_id}  ${self}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # Check Answers   ${resp}  ${data}

    ${resp}=   Get Donation Questionnaire By Id   ${account_id}  ${d_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${resp.json()['id']}   ${id}

    ${resp}=  Get Consumer Donation By Id  ${don_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Check Answers   ${resp}  ${data}

    ${resp}=  Imageupload.CDonationQAnsUpload   ${cookie}  ${account_id}   ${don_id}   ${data}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Donation By Id  ${don_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Check Answers   ${resp}  ${data}