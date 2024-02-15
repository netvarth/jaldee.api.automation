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
@{emptylist}
@{if_dt_list}   ${QnrDatatypes[5]}   ${QnrDatatypes[7]}  ${QnrDatatypes[8]}


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


Check Questions
    [Arguments]  ${resp}  ${qnid}  ${sheet}
    ${len}=  Get Length  ${resp.json()[0]['labels']}
    ${d}=  Create Dictionary   ${colnames[0]}=${qnid}
    ${LabelVal}   getColumnValueByAnotherVal  ${sheet}  ${colnames[10]}  ${colnames[0]}  ${qnid}
    Log  ${LabelVal}
    ${qn len}=  Get Length  ${LabelVal}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${qn len}   ${len} 	
    
    FOR  ${i}  IN RANGE   ${qn len}
        
        ${a}=  Create Dictionary   ${colnames[0]}=${qnid}  ${colnames[10]}=${LabelVal[${i}]}
        ${labelNameVal}   getColumnValueByMultipleVals  ${sheet}  ${colnames[12]}  &{a}
        Log  ${labelNameVal}
        ${strippedlbl}=  Strip String  ${labelNameVal[0]}
        Set Test Variable  ${labelNameVal${i}}  ${strippedlbl}

        ${FieldDTVal}   getColumnValueByMultipleVals  ${sheet}  ${colnames[15]}  &{a}
        Log  ${FieldDTVal}
        Set Test Variable  ${FieldDTVal${i}}  ${FieldDTVal[0]}

        ${ScopeVal}   getColumnValueByMultipleVals  ${sheet}  ${colnames[14]}  &{a}
        Log  ${ScopeVal}
        Set Test Variable  ${ScopeVal${i}}  ${ScopeVal[0]}

        ${labelValuesVal}   getColumnValueByMultipleVals  ${sheet}  ${colnames[13]}  &{a}
        Log  ${labelValuesVal}
        ${lv}=  Run Keyword If  '${FieldDTVal${i}}' == '${QnrDatatypes[1]}'   Strip and split string    ${labelValuesVal[0].strip()}  ,
            ...    ELSE IF  '${FieldDTVal${i}}' == '${QnrDatatypes[2]}'   Strip and split string    ${labelValuesVal[0]}  ,
            ...    ELSE IF  '${FieldDTVal${i}}' == '${QnrDatatypes[0]}'   Strip and split string    ${labelValuesVal[0]}  ,
            ...    ELSE	 Set Variable    ${labelValuesVal[0]}
        ${type}=    Evaluate     type($lv).__name__
        Run Keyword If  '${type}' == 'list' and '${FieldDTVal${i}}' == '${QnrDatatypes[0]}'  Set Test Variable  ${labelValuesVal${i}}   ${lv[0]}
        ...    ELSE	 Set Test Variable  ${labelValuesVal${i}}   ${lv}
        # Set Test Variable  ${labelValuesVal${i}}   ${lv} 

        ${minAnswersVal}   getColumnValueByMultipleVals  ${sheet}  ${colnames[21]}  &{a}
        Log  ${minAnswersVal}
        ${minAns}=  Convert To Integer  ${minAnswersVal[0]}
        Set Test Variable  ${minAnswersVal${i}}  ${minAns}

        ${maxAnswersVal}   getColumnValueByMultipleVals  ${sheet}  ${colnames[22]}  &{a}
        Log  ${maxAnswersVal}
        ${maxAns}=  Convert To Integer  ${maxAnswersVal[0]}
        Set Test Variable  ${maxAnswersVal${i}}  ${maxAns}

        ${billableVal}   getColumnValueByMultipleVals  ${sheet}  ${colnames[18]}  &{a}
        Log  ${billableVal}
        ${type}=    Evaluate     type($billableVal[0]).__name__
        ${stripped_val}=  Run Keyword If  '${type}' == 'bool'  Set Variable    ${billableVal[0]}
        ...    ELSE	 Strip String  ${billableVal[0]}
        Set Test Variable  ${billableVal${i}}  ${stripped_val}
        # Set Test Variable  ${billableVal${i}}  ${billableVal[0]}

        ${minVal}   getColumnValueByMultipleVals  ${sheet}  ${colnames[19]}  &{a}
        Log  ${minVal}
        ${mnv}=  Run Keyword If  '${FieldDTVal${i}}' == '${QnrDatatypes[4]}'   Split String    ${minVal[0]}  ${SPACE}
            ...    ELSE IF  '${FieldDTVal${i}}' == '${QnrDatatypes[5]}'  Split String    ${minVal[0]}  ${SPACE}
            ...    ELSE IF  '${FieldDTVal${i}}' == '${QnrDatatypes[0]}'  Split String    ${minVal[0]}  ${SPACE}
            ...    ELSE IF  '${FieldDTVal${i}}' == '${QnrDatatypes[3]}'  Split String    ${minVal[0]}  ${SPACE}
            ...    ELSE IF  '${FieldDTVal${i}}' == '${QnrDatatypes[1]}'  Convert To Integer    ${minVal[0]}
            ...    ELSE	 Set Variable    ${minVal[0]}
        ${type}=    Evaluate     type($mnv).__name__
        Run Keyword If  '${type}' == 'list'  Set Test Variable  ${minVal${i}}   ${mnv[0]}
        ...    ELSE	 Set Test Variable  ${minVal${i}}   ${mnv}

        ${maxVal}   getColumnValueByMultipleVals  ${sheet}  ${colnames[20]}  &{a}
        Log  ${maxVal}
        ${mxv}=  Run Keyword If  '${FieldDTVal${i}}' == '${QnrDatatypes[4]}'   Split String    ${maxVal[0]}  ${SPACE}
            ...    ELSE IF  '${FieldDTVal${i}}' == '${QnrDatatypes[5]}'  Split String    ${maxVal[0]}  ${SPACE}
            ...    ELSE IF  '${FieldDTVal${i}}' == '${QnrDatatypes[0]}'  Split String    ${maxVal[0]}  ${SPACE}
            ...    ELSE IF  '${FieldDTVal${i}}' == '${QnrDatatypes[3]}'  Split String    ${maxVal[0]}  ${SPACE}
            ...    ELSE IF  '${FieldDTVal${i}}' == '${QnrDatatypes[1]}'  Convert To Integer    ${maxVal[0]}
            ...    ELSE	 Set Variable    ${maxVal[0]}
        ${type}=    Evaluate     type($mxv).__name__
        Run Keyword If  '${type}' == 'list'  Set Test Variable  ${maxVal${i}}   ${mxv[0]}
        ...    ELSE	 Set Test Variable  ${maxVal${i}}   ${mxv}

        ${filetypeVal}   getColumnValueByMultipleVals  ${sheet}  ${colnames[16]}  &{a}
        Log  ${filetypeVal}
        ${ftv}=  Run Keyword If  '${FieldDTVal${i}}' == '${QnrDatatypes[5]}'   Strip and split string    ${filetypeVal[0]}  ,
            ...    ELSE	 Set Variable    ${filetypeVal[0]}
        Set Test Variable  ${filetypeVal${i}}   ${ftv}

        ${alloweddocVal}   getColumnValueByMultipleVals  ${sheet}  ${colnames[17]}  &{a}
        Log  ${alloweddocVal}
        ${adv}=  Run Keyword If  '${FieldDTVal${i}}' == '${QnrDatatypes[5]}'   Strip and split string    ${alloweddocVal[0]}  ,
            ...    ELSE	 Set Variable    ${alloweddocVal[0]}
        Set Test Variable  ${alloweddocVal${i}}   ${adv}
        
    END

    FOR  ${i}  IN RANGE   ${len}
        ${x} =  Get Index From List  ${LabelVal}  ${resp.json()[0]['labels'][${i}]['question']['label']}
        Should Be Equal As Strings   ${resp.json()[0]['labels'][${i}]['question']['label']}  ${LabelVal[${x}]}
        Should Be Equal As Strings   ${resp.json()[0]['labels'][${i}]['question']['labelName']}  ${labelNameVal${x}}
        Should Be Equal As Strings   ${resp.json()[0]['labels'][${i}]['question']['fieldScope']}   ${ScopeVal${x}}
        Should Be Equal As Strings   ${resp.json()[0]['labels'][${i}]['question']['billable']}   ${billableVal${x}}

        # Run Keyword If  '${resp.json()['labels'][${i}]['question']['fieldDataType']}' != '${QnrDatatypes[5]}'
        ${value2}=    evaluate    False if $labelValuesVal${x} is None else True
        Run Keyword If   '${resp.json()[0]['labels'][${i}]['question']['fieldDataType']}' not in @{if_dt_list} and '${value2}' != 'False'
        ...    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['labels'][${i}]['question']['labelValues']}   ${labelValuesVal${x}}
        
        Run Keyword If  '${resp.json()[0]['labels'][${i}]['question']['fieldDataType']}' == '${QnrDatatypes[1]}'
        ...    Run Keywords
        ...    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['labels'][${i}]['question']['${QnrProperty[1]}']['minAnswers']}   ${minAnswersVal${x}}
        ...    AND  Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['labels'][${i}]['question']['${QnrProperty[1]}']['maxAnswers']}   ${maxAnswersVal${x}}
        
        ...    ELSE IF  '${resp.json()[0]['labels'][${i}]['question']['fieldDataType']}' == '${QnrDatatypes[5]}'
        ...    Run Keywords
        ...    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['labels'][${i}]['question']['${QnrProperty[5]}']['minNoOfFile']}   ${minAnswersVal${x}}
        ...    AND  Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['labels'][${i}]['question']['${QnrProperty[5]}']['maxNoOfFile']}   ${maxAnswersVal${x}}
        ...    AND  Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['labels'][${i}]['question']['${QnrProperty[5]}']['minSize']}   ${minVal${x}}
        ...    AND  Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['labels'][${i}]['question']['${QnrProperty[5]}']['maxSize']}   ${maxVal${x}}
        ...    AND  Comapre Lists without order  ${resp.json()[0]['labels'][${i}]['question']['${QnrProperty[5]}']['fileTypes']}   ${filetypeVal${x}}  
        ...    AND  Comapre Lists without order  ${resp.json()[0]['labels'][${i}]['question']['${QnrProperty[5]}']['allowedDocuments']}   ${alloweddocVal${x}}  
        
        ...    ELSE IF  '${resp.json()[0]['labels'][${i}]['question']['fieldDataType']}' == '${QnrDatatypes[4]}'
        ...    Run Keywords
        ...    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['labels'][${i}]['question']['${QnrProperty[4]}']['minAnswers']}   ${minAnswersVal${x}}
        ...    AND  Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['labels'][${i}]['question']['${QnrProperty[4]}']['maxAnswers']}   ${maxAnswersVal${x}}
        ...    AND  Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['labels'][${i}]['question']['${QnrProperty[4]}']['start']}   ${minVal${x}}
        ...    AND  Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['labels'][${i}]['question']['${QnrProperty[4]}']['end']}   ${maxVal${x}}

        ...    ELSE IF  '${resp.json()[0]['labels'][${i}]['question']['fieldDataType']}' == '${QnrDatatypes[0]}'
        ...    Run Keywords
        ...    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['labels'][${i}]['question']['${QnrProperty[0]}']['minNoOfLetter']}   ${minVal${x}}
        ...    AND  Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['labels'][${i}]['question']['${QnrProperty[0]}']['maxNoOfLetter']}   ${maxVal${x}}

        ...    ELSE IF  '${resp.json()[0]['labels'][${i}]['question']['fieldDataType']}' == '${QnrDatatypes[3]}'
        ...    Run Keywords
        ...    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['labels'][${i}]['question']['${QnrProperty[3]}']['startDate']}   ${minVal${x}}
        ...    AND  Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['labels'][${i}]['question']['${QnrProperty[3]}']['endDate']}   ${maxVal${x}}

        
    END


*** Test Cases ***

JD-TC-GetQuestionnaireByUuidForWaitlist-1
    [Documentation]  Get questionnaire by uuid for wailtlist 
    
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

    ${resp}=  Encrypted Provider Login  ${PUSERNAME155}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_customer   ${PUSERNAME155}

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

    ${resp}=  Encrypted Provider Login  ${PUSERNAME155}  ${PASSWORD}
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
        ${s_id}=  Run Keyword If   '${resp.json()[${i}]['name']}' in @{unique_snames} and '${resp.json()[${i}]['serviceType']}' != '${service_type[0]}'   Set Variable   ${resp.json()[${i}]['id']}
        Exit For Loop If   '${s_id}' != '${None}'
    END
    Set Suite Variable   ${s_id}  

    clear_queue   ${PUSERNAME155}

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

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid1}  ${s_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
      
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Questionnaire By uuid For Waitlist    ${wid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()[0]['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${id}
    Check Questions   ${resp}   ${qnrid}   ${sheet1}

JD-TC-GetQuestionnaireByUuidForWaitlist-2
    [Documentation]  Get questionnaire for waitlist taken from consumer side

    clear_customer   ${PUSERNAME155}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME155}  ${PASSWORD}
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

    clear_queue   ${PUSERNAME155}

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

    ${resp}=  Encrypted Provider Login  ${PUSERNAME155}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Questionnaire By uuid For Waitlist    ${wid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()[0]['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${id}
    Check Questions   ${resp}   ${qnrid}   ${sheet1}

JD-TC-GetQuestionnaireByUuidForWaitlist-3
    [Documentation]  Get questionnaire for waitlist taken from consumer side canceld waitlist

    clear_customer   ${PUSERNAME155}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME155}  ${PASSWORD}
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

    clear_queue   ${PUSERNAME155}

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

    ${resp}=  Cancel Waitlist  ${wid1}  ${account_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${account_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}   waitlistStatus=${wl_status[4]}   


    ${resp}=  Encrypted Provider Login  ${PUSERNAME155}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Questionnaire By uuid For Waitlist    ${wid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()[0]['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${id}
    Check Questions   ${resp}   ${qnrid}   ${sheet1}


JD-TC-GetQuestionnaireByUuidForWaitlist-UH1
    [Documentation]  Get questionnaire by consumer login

    ${resp}=  Consumer Login  ${CUSERNAME11}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Questionnaire By uuid For Waitlist    ${wid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}    401
    Should Be Equal As Strings  ${resp.json()}   ${LOGIN_NO_ACCESS_FOR_URL}

JD-TC-GetQuestionnaireByUuidForWaitlist-UH2
    [Documentation]  Get questionnaire without login

    ${resp}=  Get Questionnaire By uuid For Waitlist    ${wid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.json()}  ${SESSION_EXPIRED}


    