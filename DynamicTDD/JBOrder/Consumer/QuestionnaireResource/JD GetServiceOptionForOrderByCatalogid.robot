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
Variables         /ebs/TDD/varfiles/musers.py

*** Variables ***
${xlFile}      ${EXECDIR}/TDD/ServiceoptionsQnrOrder.xlsx    # DataSheet
${self}      0
@{emptylist}
${mp4file}   /ebs/TDD/MP4file.mp4
${mp4mime}   video/mp4
${mp3file}   /ebs/TDD/MP3file.mp3
${mp3mime}   audio/mpeg
${pdffile}   /ebs/TDD/sample.pdf
${jpgfile}     /ebs/TDD/uploadimage.jpg
${pngfile}     /ebs/TDD/upload.png
@{if_dt_list}   ${QnrDatatypes[5]}   ${QnrDatatypes[7]}    ${QnrDatatypes[8]}


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

   [Return]  ${final_list}

Open given Excel file
    [Arguments]    ${xlFile}  ${doc id}
    ${inputfileStatus}    ${msg}    Run Keyword And Ignore Error    OperatingSystem.File Should Exist    ${xlFile}
    Run Keyword If    "${inputfileStatus}"=="PASS"    Log   ${xlFile} Test data file exist    ELSE    Log    Cannot locate the given Excel file.  ERROR
    Open workbook   ${xlFile}   ${doc id}

Check Answers
    [Arguments]  ${resp}  ${data}  
    ${len}=  Get Length  ${resp.json()['serviceOptoin']['questionAnswers']}
    # ${answer}=  Set Variable  ${data}
    ${data}=  json.loads  ${data}
    Log  ${data}
    ${dttypes}=  Create List  '${QnrDatatypes[0]}'  '${QnrDatatypes[1]}'  '${QnrDatatypes[2]}'  '${QnrDatatypes[3]}'

    FOR  ${i}  IN RANGE   ${len}
   
        Run Keyword And Continue On Failure  Should Be Equal As Strings   '${resp.json()['serviceOptoin']['questionAnswers'][${i}]['question']['id']}'  '${resp.json()['serviceOptoin']['questionAnswers'][${i}]['answerLine']['id']}'
        Run Keyword And Continue On Failure  Should Be Equal As Strings   '${resp.json()['serviceOptoin']['questionAnswers'][${i}]['question']['labelName']}'  '${resp.json()['serviceOptoin']['questionAnswers'][${i}]['answerLine']['labelName']}'

        
        IF   '${resp.json()['serviceOptoin']['questionAnswers'][${i}]['question']['fieldDataType']}' in @{dttypes}
            Run Keyword And Continue On Failure  Should Be Equal As Strings  '${resp.json()['serviceOptoin']['questionAnswers'][${i}]['answerLine']['answer']}'   '${data['answerLine'][${i}]['answer']}'

        ELSE IF   '${resp.json()['serviceOptoin']['questionAnswers'][${i}]['question']['fieldDataType']}' == '${QnrDatatypes[5]}'
            Run Keyword And Continue On Failure  Should Be Equal As Strings  '${resp.json()['serviceOptoin']['questionAnswers'][${i}]['answerLine']['answer']['${QnrDatatypes[5]}'][0]['caption']}'   '${data['answerLine'][${i}]['answer']['${QnrDatatypes[5]}'][0]['caption']}'
            Run Keyword And Continue On Failure  Should Be Equal As Strings  '${resp.json()['serviceOptoin']['questionAnswers'][${i}]['answerLine']['answer']['${QnrDatatypes[5]}'][0]['status']}'   '${QnrStatus[1]}'

        ELSE IF   '${resp.json()['serviceOptoin']['questionAnswers'][${i}]['question']['fieldDataType']}' == '${QnrDatatypes[8]}'
            ${DGLlen}=  Get Length  ${resp.json()['serviceOptoin']['questionAnswers'][${i}]['question']['dataGridListProperties']['dataGridListColumns']}
            FOR  ${j}  IN RANGE   ${DGLlen}
                IF   '${resp.json()['serviceOptoin']['questionAnswers'][${i}]['question']['dataGridListProperties']['dataGridListColumns'][${j}]['dataType']}' in @{dttypes}
                    Run Keyword And Continue On Failure  Should Be Equal As Strings  '${resp.json()['serviceOptoin']['questionAnswers'][${i}]['answerLine']['answer']['dataGridListProperties']['dataGridListColumns'][${j}]}'   '${data['answerLine'][${i}]['answer']['${QnrDatatypes[8]}'][0]['dataGridListColumn'][${j}]}'

                ELSE IF   '${resp.json()['serviceOptoin']['questionAnswers'][${i}]['question']['dataGridListProperties']['dataGridListColumns'][${j}]['dataType']}' == '${QnrDatatypes[5]}'
                    Run Keyword And Continue On Failure  Should Be Equal As Strings  '${resp.json()['serviceOptoin']['questionAnswers'][${i}]['answerLine']['answer']['${QnrDatatypes[8]}'][0]['dataGridListColumn'][${j}]['column']['${QnrDatatypes[5]}'][0]['caption']}'   '${data['answerLine'][${i}]['answer']['${QnrDatatypes[8]}'][0]['dataGridListColumn'][${j}]['column']['${QnrDatatypes[5]}'][0]['caption']}'
                    Run Keyword And Continue On Failure  Should Be Equal As Strings  '${resp.json()['serviceOptoin']['questionAnswers'][${i}]['answerLine']['answer']['${QnrDatatypes[8]}'][0]['dataGridListColumn'][${j}]['column']['${QnrDatatypes[5]}'][0]['status']}'   '${QnrStatus[1]}'
                END
            END

        END
    END

Check Questions
    [Arguments]  ${resp}  ${qnid}  ${sheet}
    ${len}=  Get Length  ${resp.json()['labels']}
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
        ${x} =  Get Index From List  ${LabelVal}  ${resp.json()['labels'][${i}]['question']['label']}
        Should Be Equal As Strings   ${resp.json()['labels'][${i}]['question']['label']}  ${LabelVal[${x}]}
        Should Be Equal As Strings   ${resp.json()['labels'][${i}]['question']['labelName']}  ${labelNameVal${x}}
        Should Be Equal As Strings   ${resp.json()['labels'][${i}]['question']['fieldScope']}   ${ScopeVal${x}}
        Should Be Equal As Strings   ${resp.json()['labels'][${i}]['question']['billable']}   ${billableVal${x}}

        # Run Keyword If  '${resp.json()['labels'][${i}]['question']['fieldDataType']}' != '${QnrDatatypes[5]}'
        ${value2}=    evaluate    False if $labelValuesVal${x} is None else True
        Run Keyword If   '${resp.json()['labels'][${i}]['question']['fieldDataType']}' not in @{if_dt_list} and '${value2}' != 'False'
        ...    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['labels'][${i}]['question']['labelValues']}   ${labelValuesVal${x}}
        
        Run Keyword If  '${resp.json()['labels'][${i}]['question']['fieldDataType']}' == '${QnrDatatypes[1]}'
        ...    Run Keywords
        ...    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['labels'][${i}]['question']['${QnrProperty[1]}']['minAnswers']}   ${minAnswersVal${x}}
        ...    AND  Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['labels'][${i}]['question']['${QnrProperty[1]}']['maxAnswers']}   ${maxAnswersVal${x}}
        
        ...    ELSE IF  '${resp.json()['labels'][${i}]['question']['fieldDataType']}' == '${QnrDatatypes[5]}'
        ...    Run Keywords
        ...    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['labels'][${i}]['question']['${QnrProperty[5]}']['minNoOfFile']}   ${minAnswersVal${x}}
        ...    AND  Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['labels'][${i}]['question']['${QnrProperty[5]}']['maxNoOfFile']}   ${maxAnswersVal${x}}
        ...    AND  Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['labels'][${i}]['question']['${QnrProperty[5]}']['minSize']}   ${minVal${x}}
        ...    AND  Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['labels'][${i}]['question']['${QnrProperty[5]}']['maxSize']}   ${maxVal${x}}
        ...    AND  Comapre Lists without order  ${resp.json()['labels'][${i}]['question']['${QnrProperty[5]}']['fileTypes']}   ${filetypeVal${x}}  
        ...    AND  Comapre Lists without order  ${resp.json()['labels'][${i}]['question']['${QnrProperty[5]}']['allowedDocuments']}   ${alloweddocVal${x}}  
        
        ...    ELSE IF  '${resp.json()['labels'][${i}]['question']['fieldDataType']}' == '${QnrDatatypes[4]}'
        ...    Run Keywords
        ...    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['labels'][${i}]['question']['${QnrProperty[4]}']['minAnswers']}   ${minAnswersVal${x}}
        ...    AND  Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['labels'][${i}]['question']['${QnrProperty[4]}']['maxAnswers']}   ${maxAnswersVal${x}}
        ...    AND  Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['labels'][${i}]['question']['${QnrProperty[4]}']['start']}   ${minVal${x}}
        ...    AND  Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['labels'][${i}]['question']['${QnrProperty[4]}']['end']}   ${maxVal${x}}

        ...    ELSE IF  '${resp.json()['labels'][${i}]['question']['fieldDataType']}' == '${QnrDatatypes[0]}'
        ...    Run Keywords
        ...    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['labels'][${i}]['question']['${QnrProperty[0]}']['minNoOfLetter']}   ${minVal${x}}
        ...    AND  Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['labels'][${i}]['question']['${QnrProperty[0]}']['maxNoOfLetter']}   ${maxVal${x}}

        ...    ELSE IF  '${resp.json()['labels'][${i}]['question']['fieldDataType']}' == '${QnrDatatypes[3]}'
        ...    Run Keywords
        ...    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['labels'][${i}]['question']['${QnrProperty[3]}']['startDate']}   ${minVal${x}}
        ...    AND  Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['labels'][${i}]['question']['${QnrProperty[3]}']['endDate']}   ${maxVal${x}}

        
    END

    
*** Test Cases ***

JD-TC-GetServiceOptionsForOrder-1
    [Documentation]  Get service options for order

    clear_Item      ${PUSERNAME23}

    ${wb}=  readWorkbook  ${xlFile}
    ${sheet1}  GetCurrentSheet   ${wb}
    Set Suite Variable   ${sheet1}
    ${colnames}=  getColumnHeaders  ${sheet1}
    Log List  ${colnames}
    Log List  ${QnrChannel}
    Log List  ${QnrTransactionType}
    Set Suite Variable   ${colnames}
    ${catalognames}   getColumnValuesByName  ${sheet1}  ${colnames[6]}
    Log   ${catalognames}
    # Set Suite Variable   ${catalognames}
    Remove Values From List  ${catalognames}   ${NONE}
    Log  ${catalognames}
    ${unique_cnames}=    Remove Duplicates    ${catalognames}
    Log  ${unique_cnames}
    Set Suite Variable   ${unique_cnames}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME23}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
     ${p_id}=  get_acc_id            ${PUSERNAME23}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}

    ${resp}=  Get Order Settings by account id
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableOrder']}==${bool[0]}
        ${resp1}=  Enable Order Settings
        Log  ${resp1.json()}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[0]}'
        ${resp1}=   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    ELSE IF    '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[1]}'
        ${resp1}=   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}


    ${itemdata}=   FakerLibrary.words    	nb=4

    ${displayName1}=   FakerLibrary.user name    
    ${price1}=  Evaluate    random.uniform(50.0,300) 
    ${itemName1}=   Set Variable     ${itemdata[0]} 
    ${itemCode1}=   Set Variable     ${itemdata[1]}
    ${resp}=  Create Sample Item   ${displayName1}   ${itemName1}  ${itemCode1}  ${price1}  ${bool[0]}     
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id1}  ${resp.json()}

    ${displayName2}=   FakerLibrary.user name    
    ${price2}=  Evaluate    random.uniform(50.0,300) 
    ${itemName2}=   Set Variable     ${itemdata[2]} 
    ${itemCode2}=   Set Variable     ${itemdata[3]}
    ${resp}=  Create Sample Item   ${displayName2}   ${itemName2}  ${itemCode2}  ${price2}  ${bool[0]}     
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id2}  ${resp.json()}

    ${resp}=  Get Catalog By Criteria  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${s_id}   ${resp.json()['id']}
    ${c_len}=  Get Length  ${resp.json()}
    @{cnames}=  Create List
    FOR  ${i}  IN RANGE   ${c_len}
        ${catalogid}=  Run Keyword If   '${resp.json()[${i}]['catalogName']}' in @{unique_cnames} and '${resp.json()[${i}]['orderType']}' == '${OrderTypes[0]}'   Set Variable   ${resp.json()[${i}]['id']}
        Append To List  ${cnames}  ${resp.json()[${i}]['catalogName']}
    END

    ${cat_val}=    Get Variable Value    ${catalogid}

    ${cnames_len}=  Get Length  ${unique_cnames}
    IF  '${cat_val}'=='${None}'
        FOR  ${i}  IN RANGE   ${cnames_len}
            ${kwstatus} 	${value} = 	Run Keyword And Ignore Error  List Should Contain Value  ${cnames}  ${unique_cnames[${i}]}
            Log Many  ${kwstatus} 	${value}
            Continue For Loop If  '${kwstatus}' == 'PASS'
            &{dict}=  Create Dictionary   ${colnames[6]}=${unique_cnames[${i}]}
            ${ttype}=  getColumnValueByMultipleVals  ${sheet1}  ${colnames[1]}  &{dict}  
            Log  ${ttype}
            ${u_ttype}=    Remove Duplicates    ${ttype}
            Log  ${u_ttype}
            ${catalogid}=  Run Keyword If   '${kwstatus}' == 'FAIL' and '${QnrTransactionType[8]}' in @{u_ttype}  Create Sample Catalog  ${unique_cnames[${i}]}   ${tz}    ${item_id1}   ${item_id2}
        END
    END

    Set Suite Variable   ${catalogid}

    ${resp}=  Get Order Catalog    ${catalogid}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${minNumberItem}  ${resp.json()['catalogItem'][0]['minQuantity']}
    Set Suite Variable  ${maxNumberItem}  ${resp.json()['catalogItem'][0]['maxQuantity']}
    Set Suite Variable  ${minNumberItem2}  ${resp.json()['catalogItem'][1]['minQuantity']}
    Set Suite Variable  ${maxNumberItem2}  ${resp.json()['catalogItem'][1]['maxQuantity']}
    Set Suite Variable  ${sTime}  ${resp.json()['catalogSchedule']['timeSlots'][0]['sTime']}
    Set Suite Variable  ${eTime}  ${resp.json()['catalogSchedule']['timeSlots'][0]['eTime']}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${cookie}  ${resp}=  Imageupload.SALogin    ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Imageupload.UploadQuestionnaire   ${cookie}   ${account_id}   ${xlFile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME23}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
      ${id}  Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[8]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[1]}' and '${resp.json()[${i}]['captureTime']}' == '${QnrcaptureTime[2]}'  Set Variable  ${resp.json()[${i}]['id']} 
      ${qnrid}   Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[8]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[1]}' and '${resp.json()[${i}]['captureTime']}' == '${QnrcaptureTime[2]}'  Set Variable  ${resp.json()[${i}]['questionnaireId']}
      Exit For Loop If   '${id}' != '${None}'
    END
    Set Suite Variable   ${id}
    Set Suite Variable   ${qnrid}

    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings  ${qns.json()['transactionId']}  ${catalogid}

    ${resp1}=  Run Keyword If   '${qns.json()['status']}' == '${status[1]}'  Provider Change Questionnaire Status  ${id}  ${status[0]}  
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200
    
    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings   ${qns.json()['status']}  ${status[0]}
    Set Suite Variable  ${Questionnaireid}  ${qns.json()['questionnaireId']}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME30}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${jdconID}   ${resp.json()['id']}
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}

    ${DAY1}=   db.get_date_by_timezone  ${tz}
    ${pin}  ${city}  ${district}  ${state}=  get_pin_loc
    ${first}=  String . Split String   ${fname}
    Set Test Variable  ${C_email}  ${first[0]}${CUSERNAME31}.ynwtest@netvarth.com
    ${landMark}=  FakerLibrary.street name 
    ${address}=  Create Dictionary   phoneNumber=${CUSERNAME30}    firstName=${fname}   lastName=${lname}   email=${C_email}    address=${district}   city=${city}   postalCode=${pin}    landMark=${landMark}   countryCode=${countryCodes[0]}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minNumberItem}  max=${maxNumberItem-1}
    ${item_quantity2}=  FakerLibrary.Random Int  min=${minNumberItem2}  max=${maxNumberItem2-1}
    ${orderNote}=  FakerLibrary.Sentence   nb_words=5

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME30}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200
    
    ${resp}=   Create Order For HomeDelivery   ${cookie}  ${account_id}  ${self}  ${catalogid}  ${bool[1]}  ${address}  ${sTime}  ${eTime}  ${DAY1}  ${CUSERNAME30}  ${C_email}  ${countryCodes[1]}  ${emptylist}  ${item_id1}  ${item_quantity1}  ${item_id2}  ${item_quantity2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid1}  ${orderid[0]}
    Set Suite Variable      ${cookie}

    ${resp}=   Get Order By Id   ${account_id}   ${orderid1}  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}      ${orderid1}
    Log   ${resp}

    ${resp}=    Get Service Options By Order  ${catalogid}      ${account_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Check Questions   ${resp}   ${qnrid}   ${sheet1}

JD-TC-GetServiceOptionsForOrder-UH1
    [Documentation]  Get service options Without consumer login

    ${resp}=    Get Service Options By Order  ${catalogid}      ${account_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.json()}  ${SESSION_EXPIRED}

JD-TC-GetServiceOptionsForOrder-UH2
    [Documentation]  Get service options With provider login

    ${resp}=  Encrypted Provider Login  ${PUSERNAME27}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Service Options By Order  ${catalogid}      ${account_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    # Should Be Equal As Strings  ${resp.status_code}  419
    # Should Be Equal As Strings  ${resp.json()}  ${SESSION_EXPIRED}

JD-TC-GetServiceOptionsForOrder-UH3
    [Documentation]  Get service options With invalid catalog id 

    ${resp}=  Consumer Login  ${CUSERNAME30}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${inv_catalog_id}=  Generate Random String  3  [NUMBERS] 

    ${resp}=    Get Service Options By Order  ${inv_catalog_id}      ${account_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200