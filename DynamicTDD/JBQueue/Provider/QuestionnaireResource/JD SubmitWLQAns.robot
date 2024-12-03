*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Run Keywords  Delete All Sessions
Force Tags        Questionnaire
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           OperatingSystem
Library           /ebs/TDD/CustomKeywords.py
Library           /ebs/TDD/excelfuncs.py
Resource          /ebs/TDD/SuperAdminKeywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/hl_providers.py

*** Variables ***
${xlFile}    ${EXECDIR}/TDD/sampleqnr.xlsx    # DataSheet
${xlFile2}   ${EXECDIR}/TDD/qnr.xlsx    # DataSheet 2
${self}      0
@{service_names}
@{emptylist}
${mp4file}   /ebs/TDD/MP4file.mp4
${mp4mime}   video/mp4
${mp3file}   /ebs/TDD/MP3file.mp3
${mp3mime}   audio/mpeg
${pdffile}   /ebs/TDD/sample.pdf
${jpgfile}   /ebs/TDD/uploadimage.jpg
${pngfile}   /ebs/TDD/upload.png

*** Keywords ***

Check Answers
    [Arguments]  ${resp}  ${data}  ${status}=${QnrStatus[0]}  ${grid_status}=${QnrStatus[0]}
    ${len}=  Get Length  ${resp.json()['questionnaire']['questionAnswers']}
    # ${answer}=  Set Variable  ${data}
    ${data}=  json.loads  ${data}
    Log  ${data}
    ${dttypes}=  Create List  '${QnrDatatypes[0]}'  '${QnrDatatypes[1]}'  '${QnrDatatypes[2]}'  '${QnrDatatypes[3]}'

    FOR  ${i}  IN RANGE   ${len}
   
        Run Keyword And Continue On Failure  Should Be Equal As Strings   '${resp.json()['questionnaire']['questionAnswers'][${i}]['question']['id']}'  '${resp.json()['questionnaire']['questionAnswers'][${i}]['answerLine']['id']}'
        Run Keyword And Continue On Failure  Should Be Equal As Strings   '${resp.json()['questionnaire']['questionAnswers'][${i}]['question']['labelName']}'  '${resp.json()['questionnaire']['questionAnswers'][${i}]['answerLine']['labelName']}'

        
        IF   '${resp.json()['questionnaire']['questionAnswers'][${i}]['question']['fieldDataType']}' in @{dttypes}
            Run Keyword And Continue On Failure  Should Be Equal As Strings  '${resp.json()['questionnaire']['questionAnswers'][${i}]['answerLine']['answer']}'   '${data['answerLine'][${i}]['answer']}'

        ELSE IF   '${resp.json()['questionnaire']['questionAnswers'][${i}]['question']['fieldDataType']}' == '${QnrDatatypes[5]}'
            Run Keyword And Continue On Failure  Should Be Equal As Strings  '${resp.json()['questionnaire']['questionAnswers'][${i}]['answerLine']['answer']['${QnrDatatypes[5]}'][0]['caption']}'   '${data['answerLine'][${i}]['answer']['${QnrDatatypes[5]}'][0]['caption']}'
            Run Keyword And Continue On Failure  Should Be Equal As Strings  '${resp.json()['questionnaire']['questionAnswers'][${i}]['answerLine']['answer']['${QnrDatatypes[5]}'][0]['status']}'   '${status}'

        ELSE IF   '${resp.json()['questionnaire']['questionAnswers'][${i}]['question']['fieldDataType']}' == '${QnrDatatypes[7]}'
            ${DGLlen}=  Get Length  ${resp.json()['questionnaire']['questionAnswers'][${i}]['question']['dataGridProperties']['dataGridColumns']}
            FOR  ${j}  IN RANGE   ${DGLlen}
                IF   '${resp.json()['questionnaire']['questionAnswers'][${i}]['question']['dataGridProperties']['dataGridColumns'][${j}]['dataType']}' in @{dttypes}
                    Run Keyword And Continue On Failure  Should Be Equal As Strings  '${resp.json()['questionnaire']['questionAnswers'][${i}]['answerLine']['answer']['dataGridProperties']['dataGridColumns'][${j}]}'   '${data['answerLine'][${i}]['answer']['${QnrDatatypes[7]}'][0]['dataGridColumn'][${j}]}'

                ELSE IF   '${resp.json()['questionnaire']['questionAnswers'][${i}]['question']['dataGridProperties']['dataGridColumns'][${j}]['dataType']}' == '${QnrDatatypes[5]}'
                    Run Keyword And Continue On Failure  Should Be Equal As Strings  '${resp.json()['questionnaire']['questionAnswers'][${i}]['answerLine']['answer']['${QnrDatatypes[7]}'][0]['dataGridColumn'][${j}]['column']['${QnrDatatypes[5]}'][0]['caption']}'   '${data['answerLine'][${i}]['answer']['${QnrDatatypes[7]}'][0]['dataGridColumn'][${j}]['column']['${QnrDatatypes[5]}'][0]['caption']}'
                    Run Keyword And Continue On Failure  Should Be Equal As Strings  '${resp.json()['questionnaire']['questionAnswers'][${i}]['answerLine']['answer']['${QnrDatatypes[7]}'][0]['dataGridColumn'][${j}]['column']['${QnrDatatypes[5]}'][0]['status']}'   '${grid_status}'
                END
            END

        END
    END

*** Test Cases ***


JD-TC-SubmitQuestionnaireForWaitlist-1
    [Documentation]  Submit questionnaire for wailtlist(capure time After)

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

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME30}  ${PASSWORD}
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
        IF   '${QnrTransactionType[3]}' in @{u_ttype} and '${srv_val}'=='${None}'
                ${s_id}=  Create Sample Service  ${unique_snames[${i}]}  maxBookingsAllowed=10
            ELSE IF  '${QnrTransactionType[0]}' in @{u_ttype} and '${don_val}'=='${None}'
                ${d_id}=  Create Sample Donation  ${unique_snames[${i}]}
            END
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

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME30}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
      ${id}  Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}' and '${resp.json()[${i}]['captureTime']}' == '${QnrcaptureTime[2]}'  Set Variable  ${resp.json()[${i}]['id']} 
      ${qnrid}   Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}' and '${resp.json()[${i}]['captureTime']}' == '${QnrcaptureTime[2]}'  Set Variable  ${resp.json()[${i}]['questionnaireId']}
      Exit For Loop If   '${id}' != '${None}'
    END
    Set Suite Variable   ${id}
    Set Suite Variable   ${qnrid}

    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200

    IF  '${qns.json()['status']}' == '${status[1]}' 
        ${resp1}=   Provider Change Questionnaire Status  ${id}  ${status[0]}  
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings   ${qns.json()['status']}  ${status[0]}
    Set Suite Variable  ${Questionnaireid}  ${qns.json()['questionnaireId']}
    Set Suite Variable  ${Questionnaireid}  ${qns.json()['questionnaireId']}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${s_len}=  Get Length  ${resp.json()}
    FOR    ${i}    IN RANGE    ${s_len}
        IF    '${resp.json()[${i}]["name"]}' in @{unique_snames} and '${resp.json()[${i}]["serviceType"]}' != '${ServiceType[2]}'
            ${s_id}=    Set Variable    ${resp.json()[${i}]["id"]}
        END
        Exit For Loop If    '${s_id}' != '${None}'
    END
    Set Suite Variable   ${s_id}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${fname}=  generate_firstname
        ${lname}=  FakerLibrary.last_name
        ${resp1}=  AddCustomer  ${CUSERNAME1}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${cid1}  ${resp1.json()}
    ELSE
        Set Suite Variable  ${cid1}  ${resp.json()[0]['id']}
    END

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']} 
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10   
    # ${sTime}=  db.get_time_by_timezone   ${tz}
    ${sTime}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=15  max=60
    ${eTime}=  add_two   ${sTime}  ${delta}
    ${capacity}=  Random Int  min=20   max=40
    ${parallel}=  Random Int   min=1   max=2
    ${queue1}=    FakerLibrary.Word
    ${resp}=  Create Queue  ${queue1}  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${lid}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${q_id}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${q_id}   queueState=${Qstate[0]}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid1}  ${s_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Change Questionnaire release Status For waitlist    ${QnrReleaseStatus[1]}   ${wid}  ${id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Questionnaire By uuid For Waitlist    ${wid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()[0]['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${id}
    
    ${fudata}=  db.fileUploadDT   ${resp.json()[0]}  ${FileAction[0]}  ${Questionnaireid}  ${pdffile} 
    Log  ${fudata}

    ${data}=  db.QuestionnaireAnswers   ${resp.json()[0]}   ${cid1}   &{fudata}
    Log  ${data}
    Set Suite Variable   ${data}

    ${resp}=  Provider Validate Questionnaire  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.spLogin  ${HLPUSERNAME30}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Imageupload.PWlQAnsUpload   ${cookie}  ${wid}   ${data}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME30}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Check Answers   ${resp}  ${data}

JD-TC-SubmitQuestionnaireForWaitlist-2
    [Documentation]  Submit questionnaire for waitlist after starting waitlist

    clear_customer   ${HLPUSERNAME30}
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME30}  ${PASSWORD}
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
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${s_len}=  Get Length  ${resp.json()}
    FOR    ${i}    IN RANGE    ${s_len}
        IF    '${resp.json()[${i}]["name"]}' in @{unique_snames} and '${resp.json()[${i}]["serviceType"]}' != '${ServiceType[2]}'
            ${s_id}=    Set Variable    ${resp.json()[${i}]["id"]}
        END
        Exit For Loop If    '${s_id}' != '${None}'
    END
    Set Suite Variable   ${s_id}  

    # clear_queue   ${HLPUSERNAME30}
    
    # ${list}=  Create List  1  2  3  4  5  6  7
    # ${DAY1}=  db.get_date_by_timezone  ${tz}
    # ${DAY2}=  db.add_timezone_date  ${tz}  10   
    # # ${sTime}=  db.get_time_by_timezone   ${tz}
    # ${sTime}=  db.get_time_by_timezone  ${tz}
    # ${delta}=  FakerLibrary.Random Int  min=15  max=60
    # ${eTime}=  add_two   ${sTime}  ${delta}
    # ${capacity}=  Random Int  min=20   max=40
    # ${parallel}=  Random Int   min=1   max=2
    # ${queue1}=    FakerLibrary.Word
    # ${resp}=  Create Queue  ${queue1}  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${lid}  ${s_id}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${q_id}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${q_id}   queueState=${Qstate[0]}

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
      ${id}  Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}' and '${resp.json()[${i}]['captureTime']}' == '${QnrcaptureTime[2]}'  Set Variable  ${resp.json()[${i}]['id']} 
      ${qnrid}   Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}' and '${resp.json()[${i}]['captureTime']}' == '${QnrcaptureTime[2]}'  Set Variable  ${resp.json()[${i}]['questionnaireId']}
      Exit For Loop If   '${id}' != '${None}'
    END
    Set Suite Variable   ${id}
    Set Suite Variable   ${qnrid}

    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings  ${qns.json()['transactionId']}  ${s_id}
    Set Suite Variable  ${Questionnaireid2}  ${qns.json()['questionnaireId']}

    IF  '${qns.json()['status']}' == '${status[1]}' 
        ${resp1}=   Provider Change Questionnaire Status  ${id}  ${status[0]}  
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings   ${qns.json()['status']}  ${status[0]}
    Set Suite Variable  ${Questionnaireid}  ${qns.json()['questionnaireId']}

    ${resp}=  AddCustomer  ${CUSERNAME13}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10 
    
    ${description}=  FakerLibrary.sentence
    ${resp}=  Add To Waitlist  ${cid}  ${s_id}  ${q_id}  ${DAY1}  ${description}   ${bool[1]}  ${cid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200     
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=   Get Waitlist EncodedId    ${wid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}

    ${resp}=  Get Waitlist By Id  ${wid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  waitlistStatus=${wl_status[1]}

    ${resp}=  Waitlist Action   ${waitlist_actions[1]}   ${wid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  waitlistStatus=${wl_status[2]}

    ${resp}=  Provider Change Questionnaire release Status For waitlist    ${QnrReleaseStatus[1]}   ${wid1}  ${id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Questionnaire By uuid For Waitlist    ${wid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()[0]['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${id}
    
    ${fudata}=  db.fileUploadDT   ${resp.json()[0]}  ${FileAction[0]}  ${Questionnaireid2}  ${pdffile}
    Log  ${fudata}
    ${data}=  db.QuestionnaireAnswers   ${resp.json()[0]}   ${cid}   &{fudata}
    Log  ${data}
    ${resp}=  Provider Validate Questionnaire  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.spLogin  ${HLPUSERNAME30}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Imageupload.PWlQAnsUpload   ${cookie}  ${wid1}   ${data}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME30}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Check Answers   ${resp}  ${data}


JD-TC-SubmitQuestionnaireForWaitlist-3
    [Documentation]  Submit questionnaire for waitlist after completing waitlist

    clear_customer   ${HLPUSERNAME30}
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME30}  ${PASSWORD}
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
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${s_len}=  Get Length  ${resp.json()}
    FOR    ${i}    IN RANGE    ${s_len}
        IF    '${resp.json()[${i}]["name"]}' in @{unique_snames} and '${resp.json()[${i}]["serviceType"]}' != '${ServiceType[2]}'
            ${s_id}=    Set Variable    ${resp.json()[${i}]["id"]}
        END
        Exit For Loop If    '${s_id}' != '${None}'
    END
    Set Suite Variable   ${s_id}  

    # clear_queue   ${HLPUSERNAME30}

    # ${list}=  Create List  1  2  3  4  5  6  7
    # ${DAY1}=  db.get_date_by_timezone  ${tz}
    # ${DAY2}=  db.add_timezone_date  ${tz}  10   
    # # ${sTime}=  db.get_time_by_timezone   ${tz}
    # ${sTime}=  db.get_time_by_timezone  ${tz}
    # ${delta}=  FakerLibrary.Random Int  min=15  max=60
    # ${eTime}=  add_two   ${sTime}  ${delta}
    # ${capacity}=  Random Int  min=20   max=40
    # ${parallel}=  Random Int   min=1   max=2
    # ${queue1}=    FakerLibrary.Word
    # ${resp}=  Create Queue  ${queue1}  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${lid}  ${s_id}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${q_id}  ${resp.json()}
  
    ${resp}=  Get Queue ById  ${q_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${q_id}   queueState=${Qstate[0]}

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
      ${id}  Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}' and '${resp.json()[${i}]['captureTime']}' == '${QnrcaptureTime[2]}'  Set Variable  ${resp.json()[${i}]['id']} 
      ${qnrid}   Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}' and '${resp.json()[${i}]['captureTime']}' == '${QnrcaptureTime[2]}'  Set Variable  ${resp.json()[${i}]['questionnaireId']}
      Exit For Loop If   '${id}' != '${None}'
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

    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings   ${qns.json()['status']}  ${status[0]}
    Set Suite Variable  ${Questionnaireid}  ${qns.json()['questionnaireId']}
    Set Suite Variable  ${Questionnaireid3}  ${qns.json()['questionnaireId']}

    ${resp}=  AddCustomer  ${CUSERNAME13}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10 
    
    ${description}=  FakerLibrary.sentence
    ${resp}=  Add To Waitlist  ${cid}  ${s_id}  ${q_id}  ${DAY1}  ${description}   ${bool[1]}  ${cid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=   Get Waitlist EncodedId    ${wid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}

    ${resp}=  Get Waitlist By Id  ${wid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  waitlistStatus=${wl_status[1]} 

    ${resp}=  Waitlist Action   ${waitlist_actions[1]}   ${wid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  waitlistStatus=${wl_status[2]}

    ${resp}=  Waitlist Action  ${waitlist_actions[4]}  ${wid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  waitlistStatus=${wl_status[5]}

    ${resp}=  Provider Change Questionnaire release Status For waitlist    ${QnrReleaseStatus[1]}   ${wid1}  ${id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Questionnaire By uuid For Waitlist    ${wid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()[0]['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${id}
    
    ${fudata}=  db.fileUploadDT   ${resp.json()[0]}  ${FileAction[0]}  ${Questionnaireid3}  ${pdffile}
    Log  ${fudata}
    ${data}=  db.QuestionnaireAnswers   ${resp.json()[0]}   ${cid}   &{fudata}
    Log  ${data}
    ${resp}=  Provider Validate Questionnaire  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.spLogin  ${HLPUSERNAME30}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Imageupload.PWlQAnsUpload   ${cookie}  ${wid1}   ${data}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME30}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Check Answers   ${resp}  ${data}


JD-TC-SubmitQuestionnaireForWaitlist-UH1
    [Documentation]  Submit questionnaire for cancelled waitlist
    
    clear_customer   ${HLPUSERNAME30}
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME30}  ${PASSWORD}
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
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${s_len}=  Get Length  ${resp.json()}
    FOR    ${i}    IN RANGE    ${s_len}
        IF    '${resp.json()[${i}]["name"]}' in @{unique_snames} and '${resp.json()[${i}]["serviceType"]}' != '${ServiceType[2]}'
            ${s_id}=    Set Variable    ${resp.json()[${i}]["id"]}
        END
        Exit For Loop If    '${s_id}' != '${None}'
    END
    Set Suite Variable   ${s_id}  

    # clear_queue   ${HLPUSERNAME30}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    
    # ${resp}=  Sample Queue  ${lid}   ${s_id}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${q_id}  ${resp.json()}

    # ${resp}=  Get Queue ById  ${q_id}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  id=${q_id}   queueState=${Qstate[0]}

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
      ${id}  Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}' and '${resp.json()[${i}]['captureTime']}' == '${QnrcaptureTime[2]}'  Set Variable  ${resp.json()[${i}]['id']} 
      ${qnrid}   Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}' and '${resp.json()[${i}]['captureTime']}' == '${QnrcaptureTime[2]}'  Set Variable  ${resp.json()[${i}]['questionnaireId']}
      Exit For Loop If   '${id}' != '${None}'
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

    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings   ${qns.json()['status']}  ${status[0]}
    Set Suite Variable  ${Questionnaireid}  ${qns.json()['questionnaireId']}
    Set Suite Variable  ${Questionnaireid4}  ${qns.json()['questionnaireId']}

    ${resp}=  AddCustomer  ${CUSERNAME13}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}
    
    ${description}=  FakerLibrary.sentence
    ${resp}=  Add To Waitlist  ${cid}  ${s_id}  ${q_id}  ${DAY1}  ${description}   ${bool[1]}  ${cid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=   Get Waitlist EncodedId    ${wid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}

    ${resp}=  Get Waitlist By Id  ${wid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  waitlistStatus=${wl_status[1]} 

    ${reason}=  Random Element  ${waitlist_cancl_reasn}
    ${msg}=   FakerLibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=   Waitlist Action Cancel  ${wid1}  ${reason}  ${msg}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  waitlistStatus=${wl_status[4]}

    ${resp}=  Get Questionnaire By uuid For Waitlist    ${wid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()[0]['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${id}
    
    ${fudata}=  db.fileUploadDT   ${resp.json()[0]}  ${FileAction[0]}  ${Questionnaireid4}  ${pdffile}
    Log  ${fudata}
    ${data}=  db.QuestionnaireAnswers   ${resp.json()[0]}   ${cid}   &{fudata}
    Log  ${data}
    ${resp}=  Provider Validate Questionnaire  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.spLogin  ${HLPUSERNAME30}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Imageupload.PWlQAnsUpload   ${cookie}  ${wid1}   ${data}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME30}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Check Answers   ${resp}  ${data}

JD-TC-SubmitQuestionnaireForWaitlist-UH2
    [Documentation]  Submit questionnaire without validating data

    clear_customer   ${HLPUSERNAME30}

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME30}  ${PASSWORD}
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
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${s_len}=  Get Length  ${resp.json()}
    FOR    ${i}    IN RANGE    ${s_len}
        IF    '${resp.json()[${i}]["name"]}' in @{unique_snames} and '${resp.json()[${i}]["serviceType"]}' != '${ServiceType[2]}'
            ${s_id}=    Set Variable    ${resp.json()[${i}]["id"]}
        END
        Exit For Loop If    '${s_id}' != '${None}'
    END
    Set Suite Variable   ${s_id}  

    # clear_queue   ${HLPUSERNAME30}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    
    # ${resp}=  Sample Queue  ${lid}   ${s_id}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${q_id}  ${resp.json()}

    # ${resp}=  Get Queue ById  ${q_id}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  id=${q_id}   queueState=${Qstate[0]}

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
      ${id}  Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}'  Set Variable  ${resp.json()[${i}]['id']} 
      ${qnrid}   Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}'  Set Variable  ${resp.json()[${i}]['questionnaireId']}
      Exit For Loop If   '${id}' != '${None}'
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

    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings   ${qns.json()['status']}  ${status[0]}
    Set Suite Variable  ${Questionnaireid}  ${qns.json()['questionnaireId']}
    Set Suite Variable  ${Questionnaireid5}  ${qns.json()['questionnaireId']}

    ${resp}=  AddCustomer  ${CUSERNAME14}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}
    
    ${description}=  FakerLibrary.sentence
    ${resp}=  Add To Waitlist  ${cid}  ${s_id}  ${q_id}  ${DAY1}  ${description}   ${bool[1]}  ${cid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=   Get Waitlist EncodedId    ${wid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}

    ${resp}=  Get Waitlist By Id  ${wid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  waitlistStatus=${wl_status[1]}

    ${resp}=  Get Questionnaire By uuid For Waitlist    ${wid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${qnrlen}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE  ${qnrlen} 
        IF  '${resp.json()[${i}]['id']}' == '${id}'
            Should Be Equal As Strings   ${resp.json()[${i}]['questionnaireId']}  ${qnrid}
            Set Test Variable   ${index}   ${i}
        END
    END
    
    ${fudata}=  db.fileUploadDT   ${resp.json()[${index}]}  ${FileAction[0]}  ${Questionnaireid5}  ${pdffile}
    Log  ${fudata}
    ${data}=  db.QuestionnaireAnswers   ${resp.json()[${index}]}   ${cid}   &{fudata}
    Log  ${data}

    ${cookie}  ${resp}=  Imageupload.spLogin  ${HLPUSERNAME30}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Imageupload.PWlQAnsUpload   ${cookie}  ${wid1}   ${data}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME30}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Check Answers   ${resp}  ${data}

JD-TC-SubmitQuestionnaireForWaitlist-UH3
    [Documentation]  Submit questionnaire by consumer login

    clear_customer   ${HLPUSERNAME30}

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME30}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${account_id}=  get_acc_id  ${HLPUSERNAME30}
    Set Suite Variable  ${account_id}

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}  

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']} 
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${s_len}=  Get Length  ${resp.json()}
    FOR    ${i}    IN RANGE    ${s_len}
        IF    '${resp.json()[${i}]["name"]}' in @{unique_snames} and '${resp.json()[${i}]["serviceType"]}' != '${ServiceType[2]}'
            ${s_id}=    Set Variable    ${resp.json()[${i}]["id"]}
        END
        Exit For Loop If    '${s_id}' != '${None}'
    END
    Set Suite Variable   ${s_id}  

    # clear_queue   ${HLPUSERNAME30}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    
    # ${resp}=  Sample Queue  ${lid}   ${s_id}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${q_id}  ${resp.json()}

    # ${resp}=  Get Queue ById  ${q_id}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  id=${q_id}   queueState=${Qstate[0]}

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
      ${id}  Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}'  Set Variable  ${resp.json()[${i}]['id']} 
      ${qnrid}   Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}'  Set Variable  ${resp.json()[${i}]['questionnaireId']}
      Exit For Loop If   '${id}' != '${None}'
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

    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings   ${qns.json()['status']}  ${status[0]}
    Set Suite Variable  ${Questionnaireid}  ${qns.json()['questionnaireId']}
    Set Suite Variable  ${Questionnaireid6}  ${qns.json()['questionnaireId']}

    ${resp}=  AddCustomer  ${CUSERNAME15}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}
    
    ${description}=  FakerLibrary.sentence
    ${resp}=  Add To Waitlist  ${cid}  ${s_id}  ${q_id}  ${DAY1}  ${description}   ${bool[1]}  ${cid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=   Get Waitlist EncodedId    ${wid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}

    ${resp}=  Get Waitlist By Id  ${wid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  waitlistStatus=${wl_status[1]}

    ${resp}=  Get Questionnaire By uuid For Waitlist    ${wid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${qnrlen}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE  ${qnrlen} 
        IF  '${resp.json()[${i}]['id']}' == '${id}'
            Should Be Equal As Strings   ${resp.json()[${i}]['questionnaireId']}  ${qnrid}
            Set Test Variable   ${index}   ${i}
        END
    END
    
    ${fudata}=  db.fileUploadDT   ${resp.json()[${index}]}  ${FileAction[0]}  ${Questionnaireid6}  ${pdffile}
    Log  ${fudata}
    ${data}=  db.QuestionnaireAnswers   ${resp.json()[${index}]}   ${cid}   &{fudata}
    Log  ${data}
    ${resp}=  Provider Validate Questionnaire  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${CUSERNAME15}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${CUSERNAME15}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME15}    ${account_id}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME15}    ${account_id}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Imageupload.PWlQAnsUpload   ${cookie}  ${wid1}   ${data}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   ${resp.json()}    ${LOGIN_NO_ACCESS_FOR_URL}

JD-TC-SubmitQuestionnaireForWaitlist-4
    [Documentation]  Submit questionnaire for wailtlist(capure time Before)

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME30}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    # clear_queue   ${HLPUSERNAME30}

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
        IF   '${QnrTransactionType[3]}' in @{u_ttype} and '${srv_val}'=='${None}'
                ${s_id}=  Create Sample Service  ${unique_snames[${i}]}  maxBookingsAllowed=10
            ELSE IF  '${QnrTransactionType[0]}' in @{u_ttype} and '${don_val}'=='${None}'
                ${d_id}=  Create Sample Donation  ${unique_snames[${i}]}
            END
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

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME30}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
      ${id}  Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}' and '${resp.json()[${i}]['captureTime']}' == '${QnrcaptureTime[0]}'  Set Variable  ${resp.json()[${i}]['id']} 
      ${qnrid}   Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}' and '${resp.json()[${i}]['captureTime']}' == '${QnrcaptureTime[0]}'  Set Variable  ${resp.json()[${i}]['questionnaireId']}
      Exit For Loop If   '${id}' != '${None}'
    END
    Set Suite Variable   ${id}
    Set Suite Variable   ${qnrid}

    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200

    IF  '${qns.json()['status']}' == '${status[1]}' 
        ${resp1}=   Provider Change Questionnaire Status  ${id}  ${status[0]}  
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings   ${qns.json()['status']}  ${status[0]}
    Set Suite Variable  ${Questionnaireid}  ${qns.json()['questionnaireId']}
    Set Suite Variable  ${Questionnaireid7}  ${qns.json()['questionnaireId']}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${s_len}=  Get Length  ${resp.json()}
    FOR    ${i}    IN RANGE    ${s_len}
        IF    '${resp.json()[${i}]["name"]}' in @{unique_snames} and '${resp.json()[${i}]["serviceType"]}' != '${ServiceType[2]}'
            ${s_id}=    Set Variable    ${resp.json()[${i}]["id"]}
        END
        Exit For Loop If    '${s_id}' != '${None}'
    END
    Set Suite Variable   ${s_id}

    ${resp}=  AddCustomer  ${CUSERNAME12}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid1}  ${resp.json()}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']} 
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    
    # ${resp}=  Sample Queue  ${lid}   ${s_id}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${q_id}  ${resp.json()}

    # ${resp}=  Get Queue ById  ${q_id}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  id=${q_id}   queueState=${Qstate[0]}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid1}  ${s_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
      
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid}=  get_id  ${CUSERNAME1}

    ${resp}=  Get Consumer Questionnaire By Channel and ServiceID   ${s_id}   ${QnrChannel[0]}  ${cid}      
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${resp.json()['id']}   ${id}
    
    ${fudata}=  db.fileUploadDT   ${resp.json()}  ${FileAction[0]}  ${Questionnaireid7}  ${pdffile}
    Log  ${fudata}

    ${data}=  db.QuestionnaireAnswers   ${resp.json()}   ${cid1}   &{fudata}
    Log  ${data}
    Set Suite Variable   ${data}

    ${resp}=  Provider Validate Questionnaire  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.spLogin  ${HLPUSERNAME30}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Imageupload.PWlQAnsUpload   ${cookie}  ${wid}   ${data}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Check Answers   ${resp}  ${data}

JD-TC-SubmitQuestionnaireForWaitlist-5
    [Documentation]  Submit questionnaire for waitlist with audio and video upload too.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME120}  ${PASSWORD}
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
        IF   '${QnrTransactionType[3]}' in @{u_ttype} and '${srv_val}'=='${None}'
                ${s_id}=  Create Sample Service  ${unique_snames[${i}]}  maxBookingsAllowed=10
            ELSE IF  '${QnrTransactionType[0]}' in @{u_ttype} and '${don_val}'=='${None}'
                ${d_id}=  Create Sample Donation  ${unique_snames[${i}]}
            END
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
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME120}  ${PASSWORD}
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
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${s_len}=  Get Length  ${resp.json()}
    FOR    ${i}    IN RANGE    ${s_len}
        IF    '${resp.json()[${i}]["name"]}' in @{unique_snames} and '${resp.json()[${i}]["serviceType"]}' != '${ServiceType[2]}'
            ${s_id}=    Set Variable    ${resp.json()[${i}]["id"]}
        END
        Exit For Loop If    '${s_id}' != '${None}'
    END
    Set Suite Variable   ${s_id}  

    # clear_queue   ${PUSERNAME120}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    
    # ${resp}=  Sample Queue  ${lid}   ${s_id}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${q_id}  ${resp.json()}

    # ${resp}=  Get Queue ById  ${q_id}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  id=${q_id}   queueState=${Qstate[0]}

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
      ${id}  Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}' and '${resp.json()[${i}]['captureTime']}' == '${QnrcaptureTime[0]}'  Set Variable  ${resp.json()[${i}]['id']} 
      ${qnrid}   Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}' and '${resp.json()[${i}]['captureTime']}' == '${QnrcaptureTime[0]}'  Set Variable  ${resp.json()[${i}]['questionnaireId']}
      Exit For Loop If   '${id}' != '${None}'
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

    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings   ${qns.json()['status']}  ${status[0]}
    Set Suite Variable  ${Questionnaireid}  ${qns.json()['questionnaireId']}
    Set Suite Variable  ${Questionnaireid8}  ${qns.json()['questionnaireId']}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${s_len}=  Get Length  ${resp.json()}
    FOR    ${i}    IN RANGE    ${s_len}
        IF    '${resp.json()[${i}]["name"]}' in @{unique_snames} and '${resp.json()[${i}]["serviceType"]}' != '${ServiceType[2]}'
            ${s_id}=    Set Variable    ${resp.json()[${i}]["id"]}
        END
        Exit For Loop If    '${s_id}' != '${None}'
    END
    Set Suite Variable   ${s_id}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME13}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${fname}=  generate_firstname
        ${lname}=  FakerLibrary.last_name
        ${resp1}=  AddCustomer  ${CUSERNAME13}  
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${cid1}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${cid1}  ${resp.json()[0]['id']}
    END

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid1}  ${s_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid1}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${qnr_resp}=  Get Questionnaire By uuid For Waitlist    ${wid1}
    Log  ${qnr_resp.content}
    Should Be Equal As Strings  ${qnr_resp.status_code}  200
    Should Be Equal As Strings   ${qnr_resp.json()[0]['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${qnr_resp.json()[0]['id']}   ${id}
    
    
    ${fudata}=  db.fileUploadDT   ${qnr_resp.json()[0]}  ${FileAction[0]}  ${Questionnaireid8}  ${pdffile}  ${jpgfile}  ${mp4file}  ${mp3file}
    Log  ${fudata}

    ${data}=  db.QuestionnaireAnswers   ${qnr_resp.json()[0]}   ${self}   &{fudata}
    Log  ${data}
    Set Suite Variable   ${data}

    ${resp}=  Provider Validate Questionnaire  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME120}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Imageupload.PWlQAnsUpload   ${cookie}  ${wid1}   ${data}  ${pdffile}  ${jpgfile}  ${mp4file}  ${mp3file}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${files_data}=  Create List
    ${len}=  Get Length  ${resp.json()['urls']}
    FOR  ${i}  IN RANGE   ${len}
        Set Test Variable  ${fileid${i}}  ${resp.json()['urls'][${i}]['uid']}
        Set Test Variable  ${lblname${i}}  ${resp.json()['urls'][${i}]['labelName']}
        IF  'columnId' in ${resp.json()['urls'][${i}]}
            Set Test Variable  ${columnId${i}}  ${resp.json()['urls'][${i}]['columnId']}
            ${file_data_dict}   Create Dictionary  uid=${fileid${i}}  labelName=${lblname${i}}  columnId=${columnId${i}}
        ELSE
            ${file_data_dict}   Create Dictionary  uid=${fileid${i}}  labelName=${lblname${i}}
        END
        Append To List  ${files_data}  ${file_data_dict}
    END

    Log  ${files_data}

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Check Answers   ${resp}  ${data}

    ${resp}=   Provider Change Answer Status for Waitlist  ${wid1}  @{files_data}
    Should Be Equal As Strings  ${resp.status_code}  200
 
    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Check Answers   ${resp}  ${data}  ${QnrStatus[1]}  ${QnrStatus[1]}

*** Comments ***    

JD-TC-SubmitQuestionnaireForWaitlist-UH4
    [Documentation]  Submit questionnaire for waitlist removing some answer

    clear_customer   ${HLPUSERNAME30}
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME30}  ${PASSWORD}
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
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${s_len}=  Get Length  ${resp.json()}
    FOR    ${i}    IN RANGE    ${s_len}
        IF    '${resp.json()[${i}]["name"]}' in @{unique_snames} and '${resp.json()[${i}]["serviceType"]}' != '${ServiceType[2]}'
            ${s_id}=    Set Variable    ${resp.json()[${i}]["id"]}
        END
        Exit For Loop If    '${s_id}' != '${None}'
    END
    Set Suite Variable   ${s_id}  

    # clear_queue   ${HLPUSERNAME30}
    
    ${list}=  Create List  1  2  3  4  5  6  7
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10   
    # ${sTime}=  db.get_time_by_timezone   ${tz}
    ${sTime}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=15  max=60
    ${eTime}=  add_two   ${sTime}  ${delta}
    ${capacity}=  Random Int  min=20   max=40
    ${parallel}=  Random Int   min=1   max=2
    ${queue1}=    FakerLibrary.Word
    ${resp}=  Create Queue  ${queue1}  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${lid}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${q_id}   queueState=${Qstate[0]}

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
      ${id}  Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}'  Set Variable  ${resp.json()[${i}]['id']} 
      ${qnrid}   Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}'  Set Variable  ${resp.json()[${i}]['questionnaireId']}
      Exit For Loop If   '${id}' != '${None}'
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

    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings   ${qns.json()['status']}  ${status[0]}
    Set Suite Variable  ${Questionnaireid}  ${qns.json()['questionnaireId']}
    Set Suite Variable  ${Questionnaireid9}  ${qns.json()['questionnaireId']}

    ${resp}=  AddCustomer  ${CUSERNAME1}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}
    
    ${description}=  FakerLibrary.sentence
    ${resp}=  Add To Waitlist  ${cid}  ${s_id}  ${q_id}  ${DAY1}  ${description}   ${bool[1]}  ${cid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200     
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=   Get Waitlist EncodedId    ${wid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}

    ${resp}=  Get Waitlist By Id  ${wid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  waitlistStatus=${wl_status[1]}

    ${resp}=  Get Questionnaire By uuid For Waitlist    ${wid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()[0]['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${id}
    
    ${fudata}=  db.fileUploadDT   ${resp.json()[0]}  ${FileAction[0]}  ${Questionnaireid9}  ${pdffile}
    Log  ${fudata}
    ${data}=  db.QuestionnaireAnswers   ${resp.json()[0]}   ${cid}   &{fudata}
    Log  ${data}

    Set to Dictionary      ${data['answerLine'][0]['answer']}    bool=${EMPTY}

    ${cookie}  ${resp}=  Imageupload.spLogin  ${HLPUSERNAME30}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Imageupload.PWlQAnsUpload   ${cookie}  ${wid1}   ${data}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    

