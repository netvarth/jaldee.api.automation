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
${xlFile}      ${EXECDIR}/TDD/sampleQnrWOAV.xlsx    # DataSheet
${xlFile1}     ${EXECDIR}/TDD/sampleqnr.xlsx    # DataSheet 1
${xlFile2}     ${EXECDIR}/TDD/qnr.xlsx    # DataSheet 2
${jpgfile}     /ebs/TDD/uploadimage.jpg
${pngfile}     /ebs/TDD/upload.png
${pdffile}     /ebs/TDD/sample.pdf
${mp4file}     /ebs/TDD/MP4file.mp4
${avifile}     /ebs/TDD/AVIfile.avi
${mp3file}     /ebs/TDD/MP3file.mp3
${self}      0
@{emptylist}
${mp4mime}   video/mp4
${avimime}   video/avi
${mp3mime}   audio/mpeg


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


# Open given Excel file
#     [Arguments]    ${xlFile}  ${doc id}
#     #Check that the given Excel Exists
#     ${inputfileStatus}    ${msg}    Run Keyword And Ignore Error    OperatingSystem.File Should Exist    ${xlFile}
#     Run Keyword If    "${inputfileStatus}"=="PASS"    Log   ${xlFile} Test data file exist    ELSE    Log    Cannot locate the given Excel file.  ERROR
#     Open workbook   ${xlFile}   ${doc id}


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

JD-TC-ProviderChangeQnrReleaseStatusForWL-1
    [Documentation]  Take a walkin checkin and submit questionnaire with capture time 'after'
    
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

    ${resp}=  Encrypted Provider Login  ${PUSERNAME151}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_customer   ${PUSERNAME151}

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}

    reset_metric_usage  ${account_id}

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

    ${resp}=  Encrypted Provider Login  ${PUSERNAME151}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}  

    ${resp}=   Run Keyword If  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
    Run Keyword If   '${resp}' != '${None}'  Log  ${resp.content}
    Run Keyword If   '${resp}' != '${None}'  Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

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
        ${s_id}=  Run Keyword If   '${resp.json()[${i}]['name']}' in @{unique_snames} and '${resp.json()[${i}]['serviceType']}' != '${service_type[0]}'   Set Variable   ${resp.json()[${i}]['id']}
        Exit For Loop If   '${s_id}' != '${None}'
    END
    Set Suite Variable   ${s_id}  

    clear_queue   ${PUSERNAME151}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    
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

    ${resp1}=  Run Keyword If   '${qns.json()['status']}' == '${status[1]}'  Provider Change Questionnaire Status  ${id}  ${status[0]}  
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings   ${qns.json()['status']}  ${status[0]}
    Set Suite Variable  ${Questionnaireid}  ${qns.json()['questionnaireId']}

    ${resp}=  AddCustomer  ${CUSERNAME1}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid1}  ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10   
    # ${sTime}=  db.get_time_by_timezone  ${tz}
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

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid1}  ${s_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
      
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()['releasedQnr'][0]['status']}   ${QnrReleaseStatus[2]}

    ${resp}=  Provider Change Questionnaire release Status For waitlist    ${QnrReleaseStatus[1]}   ${wid}  ${id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()['releasedQnr'][0]['status']}   ${QnrReleaseStatus[1]}

    ${qnr_resp}=  Get Questionnaire By uuid For Waitlist    ${wid}
    Log  ${qnr_resp.content}
    Should Be Equal As Strings  ${qnr_resp.status_code}  200
    Should Be Equal As Strings   ${qnr_resp.json()[0]['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${qnr_resp.json()[0]['id']}   ${id}
    
    ${fudata}=  db.fileUploadDT   ${qnr_resp.json()[0]}  ${FileAction[0]}  ${pdffile}
    Log  ${fudata}
    ${data}=  db.QuestionnaireAnswers   ${qnr_resp.json()[0]}   ${self}   &{fudata}
    Log  ${data}
    ${resp}=  Provider Validate Questionnaire  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME151}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Imageupload.PWlQAnsUpload   ${cookie}  ${wid}   ${data}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Check Answers   ${resp}  ${data}

# *** Comment ***

JD-TC-ProviderChangeQnrReleaseStatusForWL-2
    [Documentation]  Take a walkin checkin and provider submit questionnaire 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME151}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}

    reset_metric_usage  ${account_id}

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
        ${s_id}=  Run Keyword If   '${resp.json()[${i}]['name']}' in @{unique_snames} and '${resp.json()[${i}]['serviceType']}' != '${service_type[0]}'   Set Variable   ${resp.json()[${i}]['id']}
        Exit For Loop If   '${s_id}' != '${None}'
    END
    Set Suite Variable   ${s_id}  

    clear_queue   ${PUSERNAME151}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    
    ${resp}=  Sample Queue  ${lid}   ${s_id}
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

    ${resp1}=  Run Keyword If   '${qns.json()['status']}' == '${status[1]}'  Provider Change Questionnaire Status  ${id}  ${status[0]}  
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings   ${qns.json()['status']}  ${status[0]}
    Set Suite Variable  ${Questionnaireid}  ${qns.json()['questionnaireId']}

    ${resp}=  AddCustomer  ${CUSERNAME2}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid1}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid1}  ${s_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
      
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${qnr_resp}=  Get Questionnaire By uuid For Waitlist    ${wid}
    Log  ${qnr_resp.content}
    Should Be Equal As Strings  ${qnr_resp.status_code}  200
    ${qnrlen}=  Get Length  ${qnr_resp.json()}
    FOR  ${i}  IN RANGE  ${qnrlen} 
        IF  '${qnr_resp.json()[${i}]['id']}' == '${id}'
            Should Be Equal As Strings   ${qnr_resp.json()[${i}]['questionnaireId']}  ${qnrid}
            Set Test Variable   ${index}   ${i}
        END
    END
    # Should Be Equal As Strings   ${qnr_resp.json()[0]['questionnaireId']}  ${qnrid}
    # Should Be Equal As Strings  ${qnr_resp.json()[0]['id']}   ${id}
    
    ${fudata}=  db.fileUploadDT   ${qnr_resp.json()[${index}]}  ${FileAction[0]}  ${pngfile} 
    Log  ${fudata}

    ${data}=  db.QuestionnaireAnswers   ${qnr_resp.json()[${index}]}   ${cid1}   &{fudata}
    Log  ${data}
    Set Suite Variable   ${data}

    ${resp}=  Provider Validate Questionnaire  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME151}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Imageupload.PWlQAnsUpload   ${cookie}  ${wid}   ${data}  ${pngfile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Check Answers   ${resp}  ${data}

   

JD-TC-ProviderChangeQnrReleaseStatusForWL-3
    [Documentation]  Take a online checkin and consumer submit after questionnaire 

    clear_customer   ${PUSERNAME151}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME151}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    ${resp1}=   Run Keyword If  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}  

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
        ${s_id}=  Run Keyword If   '${resp.json()[${i}]['name']}' in @{unique_snames} and '${resp.json()[${i}]['serviceType']}' != '${service_type[0]}'   Set Variable   ${resp.json()[${i}]['id']}
        Exit For Loop If   '${s_id}' != '${None}'
    END
    Set Suite Variable   ${s_id}  

    clear_queue   ${PUSERNAME151}

    ${DAY1}=  db.get_date_by_timezone  ${tz}

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
      ${id}  Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[1]}' and '${resp.json()[${i}]['captureTime']}' == '${QnrcaptureTime[2]}'  Set Variable  ${resp.json()[${i}]['id']} 
      ${qnrid}   Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[1]}' and '${resp.json()[${i}]['captureTime']}' == '${QnrcaptureTime[2]}'  Set Variable  ${resp.json()[${i}]['questionnaireId']}
      Exit For Loop If   '${id}' != '${None}'
    END
    Set Suite Variable   ${id}
    Set Suite Variable   ${qnrid}


    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings  ${qns.json()['transactionId']}  ${s_id}

    ${resp1}=  Run Keyword If   '${qns.json()['status']}' == '${status[1]}'  Provider Change Questionnaire Status  ${id}  ${status[0]}  
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings   ${qns.json()['status']}  ${status[0]}
    Set Suite Variable  ${Questionnaireid}  ${qns.json()['questionnaireId']}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10   
    # ${sTime}=  db.get_time_by_timezone  ${tz}
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


    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME13}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}

    ${cnote}=   FakerLibrary.name
    ${resp}=  Add To Waitlist Consumers  ${account_id}  ${q_id}  ${DAY1}  ${s_id}  ${cnote}  ${bool[0]}  ${self}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
          
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${account_id}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[0]}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME151}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${qnr_resp}=  Get Questionnaire By uuid For Waitlist    ${wid1}
    Log  ${qnr_resp.content}
    Should Be Equal As Strings  ${qnr_resp.status_code}  200
    Should Be Equal As Strings   ${qnr_resp.json()[0]['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${qnr_resp.json()[0]['id']}   ${id}
    
    
    ${fudata}=  db.fileUploadDT   ${qnr_resp.json()[0]}  ${FileAction[0]}  ${pngfile} 
    Log  ${fudata}

    ${data}=  db.QuestionnaireAnswers   ${qnr_resp.json()[0]}   ${self}   &{fudata}
    Log  ${data}
    Set Suite Variable   ${data}

    ${resp}=  Provider Validate Questionnaire  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME151}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Imageupload.PWlQAnsUpload   ${cookie}  ${wid1}   ${data}  ${pngfile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Check Answers   ${resp}  ${data}

    ${fudata}=  db.fileUploadDT   ${qnr_resp.json()[0]}  ${FileAction[0]}  ${pngfile} 
    Log  ${fudata}

    ${data}=  db.QuestionnaireAnswers   ${qnr_resp.json()[0]}   ${self}   &{fudata}
    Log  ${data}
    Set Suite Variable   ${data}

    ${resp}=  Provider Revalidate Questionnaire  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Imageupload.PWlResubmitQns   ${cookie}  ${wid1}   ${data}  ${pngfile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Check Answers   ${resp}  ${data}

JD-TC-ProviderChangeQnrReleaseStatusForWL-4
    [Documentation]  consumer submit questionnaire for waitlist taken from provider side

    clear_customer   ${PUSERNAME151}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME151}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    ${resp1}=   Run Keyword If  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}  

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
        ${s_id}=  Run Keyword If   '${resp.json()[${i}]['name']}' in @{unique_snames} and '${resp.json()[${i}]['serviceType']}' != '${service_type[0]}'   Set Variable   ${resp.json()[${i}]['id']}
        Exit For Loop If   '${s_id}' != '${None}'
    END
    Set Suite Variable   ${s_id}  

    clear_queue   ${PUSERNAME151}

    ${DAY1}=  db.get_date_by_timezone  ${tz}

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
      ${id}  Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[1]}' and '${resp.json()[${i}]['captureTime']}' == '${QnrcaptureTime[2]}'  Set Variable  ${resp.json()[${i}]['id']} 
      ${qnrid}   Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[1]}' and '${resp.json()[${i}]['captureTime']}' == '${QnrcaptureTime[2]}'  Set Variable  ${resp.json()[${i}]['questionnaireId']}
      Exit For Loop If   '${id}' != '${None}'
    END
    Set Suite Variable   ${id}
    Set Suite Variable   ${qnrid}

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
      ${id1}  Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}' and '${resp.json()[${i}]['captureTime']}' == '${QnrcaptureTime[2]}'  Set Variable  ${resp.json()[${i}]['id']} 
      ${qnrid1}   Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}' and '${resp.json()[${i}]['captureTime']}' == '${QnrcaptureTime[2]}'  Set Variable  ${resp.json()[${i}]['questionnaireId']}
      Exit For Loop If   '${id1}' != '${None}'
    END
    Set Suite Variable   ${id1}
    Set Suite Variable   ${qnrid1}


    ${qns}   Get Provider Questionnaire By Id   ${id1}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings  ${qns.json()['transactionId']}  ${s_id}

    ${resp1}=  Run Keyword If   '${qns.json()['status']}' == '${status[1]}'  Provider Change Questionnaire Status  ${id1}  ${status[0]}  
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${qns}   Get Provider Questionnaire By Id   ${id1}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings   ${qns.json()['status']}  ${status[0]}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10   
    # ${sTime}=  db.get_time_by_timezone  ${tz}
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

    ${resp}=  AddCustomer  ${CUSERNAME18}  
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
    Should Be Equal As Strings   ${resp.json()['releasedQnr'][0]['status']}   ${QnrReleaseStatus[2]}


    ${resp}=  Provider Change Questionnaire release Status For waitlist    ${QnrReleaseStatus[1]}   ${wid1}  ${id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${qnrlen}=  Get Length  ${resp.json()['releasedQnr']}
    FOR  ${i}  IN RANGE  ${qnrlen} 
        IF  '${resp.json()['releasedQnr'][${i}]['id']}' == '${qnrid1}'
            Should Be Equal As Strings   ${resp.json()['releasedQnr'][${i}]['status']}  ${QnrReleaseStatus[1]}
        END
    END
    # Should Be Equal As Strings   ${resp.json()['releasedQnr'][0]['status']}   ${QnrReleaseStatus[1]}

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    
    ${resp}=  Get Consumer Questionnaire By uuid For Waitlist    ${wid1}   ${account_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()[0]['questionnaireId']}  ${qnrid1}
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${id1}
    
    ${fudata}=  db.fileUploadDT   ${resp.json()[0]}  ${FileAction[0]}  ${pdffile}
    Log  ${fudata}
    ${data}=  db.QuestionnaireAnswers   ${resp.json()[0]}   ${self}   &{fudata}
    Log  ${data}
    ${resp}=  Consumer Validate Questionnaire  ${account_id}  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME18}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Imageupload.CWlQAnsUpload   ${cookie}  ${account_id}   ${wid1}   ${data}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${account_id}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Check Answers   ${resp}  ${data}

JD-TC-ProviderChangeQnrReleaseStatusForWL-5
    [Documentation]  consumer submit questionnaire for waitlist taken from consumer side

    clear_customer   ${PUSERNAME151}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME151}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    ${resp1}=   Run Keyword If  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}  

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
        ${s_id}=  Run Keyword If   '${resp.json()[${i}]['name']}' in @{unique_snames} and '${resp.json()[${i}]['serviceType']}' != '${service_type[0]}'   Set Variable   ${resp.json()[${i}]['id']}
        Exit For Loop If   '${s_id}' != '${None}'
    END
    Set Suite Variable   ${s_id}  

    clear_queue   ${PUSERNAME151}

    ${DAY1}=  db.get_date_by_timezone  ${tz}

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
      ${id2}  Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[1]}' and '${resp.json()[${i}]['captureTime']}' == '${QnrcaptureTime[2]}'  Set Variable  ${resp.json()[${i}]['id']} 
      ${qnrid2}   Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[1]}' and '${resp.json()[${i}]['captureTime']}' == '${QnrcaptureTime[2]}'  Set Variable  ${resp.json()[${i}]['questionnaireId']}
      Exit For Loop If   '${id2}' != '${None}'
    END
    Set Suite Variable   ${id2}
    Set Suite Variable   ${qnrid2}


    ${qns}   Get Provider Questionnaire By Id   ${id2}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings  ${qns.json()['transactionId']}  ${s_id}

    ${resp1}=  Run Keyword If   '${qns.json()['status']}' == '${status[1]}'  Provider Change Questionnaire Status  ${id2}  ${status[0]}  
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${qns}   Get Provider Questionnaire By Id   ${id2}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings   ${qns.json()['status']}  ${status[0]}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10   
    # ${sTime}=  db.get_time_by_timezone  ${tz}
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

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME13}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}

    ${cnote}=   FakerLibrary.name
    ${resp}=  Add To Waitlist Consumers  ${account_id}  ${q_id}  ${DAY1}  ${s_id}  ${cnote}  ${bool[0]}  ${self}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
          
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid2}  ${wid[0]}

    ${resp}=  Get consumer Waitlist By Id   ${wid2}  ${account_id}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[0]}
    Should Be Equal As Strings   ${resp.json()['releasedQnr'][0]['status']}   ${QnrReleaseStatus[2]}

    # ${qnr_resp}=  Consumer View Questionnaire  ${account_id}  ${s_id}  ${self}
    # Log  ${qnr_resp.content}
    # Should Be Equal As Strings    ${qnr_resp.status_code}    200
    # Should Be Equal As Strings   ${qnr_resp.json()['questionnaireId']}  ${qnrid}
    # Should Be Equal As Strings  ${qnr_resp.json()['id']}   ${id}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME151}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Provider Change Questionnaire release Status For waitlist    ${QnrReleaseStatus[1]}   ${wid2}  ${id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid2} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()['releasedQnr'][0]['status']}   ${QnrReleaseStatus[1]}


    ${resp}=  Consumer Login  ${CUSERNAME13}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Consumer Questionnaire By uuid For Waitlist    ${wid2}   ${account_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()[0]['questionnaireId']}  ${qnrid2}
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${id2}
    
    
    ${fudata}=  db.fileUploadDT   ${resp.json()[0]}  ${FileAction[0]}  ${pdffile}
    Log  ${fudata}
    ${data}=  db.QuestionnaireAnswers   ${resp.json()[0]}   ${self}   &{fudata}
    Log  ${data}
    ${resp}=  Consumer Validate Questionnaire  ${account_id}  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME1}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Imageupload.CWlQAnsUpload   ${cookie}  ${account_id}   ${wid2}   ${data}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get consumer Waitlist By Id   ${wid2}  ${account_id}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Check Answers   ${resp}  ${data}

JD-TC-ProviderChangeQnrReleaseStatusForWL-UH1
    [Documentation]  change questinare release status by consumer login

    ${resp}=  Consumer Login  ${CUSERNAME13}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Provider Change Questionnaire release Status For waitlist    ${QnrReleaseStatus[1]}   ${wid2}  ${id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401

JD-TC-ProviderChangeQnrReleaseStatusForWL-UH2
    [Documentation]  change questinare release status without  login

    ${resp}=  Provider Change Questionnaire release Status For waitlist    ${QnrReleaseStatus[1]}   ${wid2}  ${id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.json()}  ${SESSION_EXPIRED}

JD-TC-ProviderChangeQnrReleaseStatusForWL-UH3
    [Documentation]   change questinare release status for a canceled waitlist

    clear_customer   ${PUSERNAME151}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME151}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    ${resp1}=   Run Keyword If  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}  

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
        ${s_id}=  Run Keyword If   '${resp.json()[${i}]['name']}' in @{unique_snames} and '${resp.json()[${i}]['serviceType']}' != '${service_type[0]}'   Set Variable   ${resp.json()[${i}]['id']}
        Exit For Loop If   '${s_id}' != '${None}'
    END
    Set Suite Variable   ${s_id}  

    clear_queue   ${PUSERNAME151}

    ${DAY1}=  db.get_date_by_timezone  ${tz}

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
      ${id}  Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[1]}' and '${resp.json()[${i}]['captureTime']}' == '${QnrcaptureTime[2]}'  Set Variable  ${resp.json()[${i}]['id']} 
      ${qnrid}   Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[1]}' and '${resp.json()[${i}]['captureTime']}' == '${QnrcaptureTime[2]}'  Set Variable  ${resp.json()[${i}]['questionnaireId']}
      Exit For Loop If   '${id}' != '${None}'
    END
    Set Suite Variable   ${id}
    Set Suite Variable   ${qnrid}


    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings  ${qns.json()['transactionId']}  ${s_id}

    ${resp1}=  Run Keyword If   '${qns.json()['status']}' == '${status[1]}'  Provider Change Questionnaire Status  ${id}  ${status[0]}  
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings   ${qns.json()['status']}  ${status[0]}
    Set Suite Variable  ${Questionnaireid}  ${qns.json()['questionnaireId']}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10   
    # ${sTime}=  db.get_time_by_timezone  ${tz}
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

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}

    ${cnote}=   FakerLibrary.name
    ${resp}=  Add To Waitlist Consumers  ${account_id}  ${q_id}  ${DAY1}  ${s_id}  ${cnote}  ${bool[0]}  ${self}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
          
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}

    ${resp}=  Get consumer Waitlist By Id   ${wid}  ${account_id}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[0]}
    Should Be Equal As Strings   ${resp.json()['releasedQnr'][0]['status']}   ${QnrReleaseStatus[2]}

    ${resp}=  Cancel Waitlist  ${wid}  ${account_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get consumer Waitlist By Id   ${wid}  ${account_id}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}    waitlistStatus=${wl_status[4]}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME151}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Provider Change Questionnaire release Status For waitlist    ${QnrReleaseStatus[1]}   ${wid}  ${id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get consumer Waitlist By Id   ${wid}  ${account_id}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200



    