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
Library           /ebs/TDD/Imageupload.py
Library           /ebs/TDD/db.py
Library           /ebs/TDD/excelfuncs.py
Resource          /ebs/TDD/SuperAdminKeywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

*** Variables ***
${xlFile}      ${EXECDIR}/TDD/sampleqnr.xlsx    # DataSheet
${xlFile2}      ${EXECDIR}/TDD/qnr.xlsx    # DataSheet 2
@{emptylist}
&{uh-error}     id=${0}   proConId=${0}
# &{uh-error}     id=0


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
    [Return]  ${val}


# Open given Excel file
#     [Arguments]    ${xlFile}  ${doc id}
#     #Check that the given Excel Exists
#     ${inputfileStatus}    ${msg}    Run Keyword And Ignore Error    OperatingSystem.File Should Exist    ${xlFile}
#     Run Keyword If    "${inputfileStatus}"=="PASS"    Log   ${xlFile} Test data file exist    ELSE    Log    Cannot locate the given Excel file.  ERROR
#     Open workbook   ${xlFile}   ${doc id}


Check Questions
    [Arguments]  ${listno}  ${resp}  ${qnid}  ${sheet}
    ${len}=  Get Length  ${resp.json()['labels'][${listno}]['questions']}
    ${d}=  Create Dictionary   ${colnames[0]}=${qnid}
    ${LabelVal}   getColumnValueByAnotherVal  ${sheet}  ${colnames[10]}  ${colnames[0]}  ${qnid}
    Log  ${LabelVal}
    ${qn len}=  Get Length  ${LabelVal}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${qn len}   ${len} 	
    
    FOR  ${i}  IN RANGE   ${qn len}
        
        ${a}=  Create Dictionary   ${colnames[0]}=${qnid}  ${colnames[10]}=${LabelVal[${i}]}
        ${labelNameVal}   getColumnValueByMultipleVals  ${sheet}  ${colnames[12]}  &{a}
        Log  ${labelNameVal}
        ${lNVal}  Strip String  ${labelNameVal[0]}
        Set Test Variable  ${labelNameVal${i}}  ${lNVal}

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
            ...  ELSE	 Set Variable    ${labelValuesVal[0]}
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
        ${stripped_val}=  Strip String  ${billableVal[0]}
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

        ${hintVal}   getColumnValueByMultipleVals  ${sheet}  ${colnames[11]}  &{a}
        Log  ${hintVal}
        # ${hv}=  Run Keyword If  '${FieldDTVal${i}}' == '${QnrDatatypes[1]}'   Strip and split string    ${labelValuesVal[0].strip()}  ,
        #     ...    ELSE IF  '${FieldDTVal${i}}' == '${QnrDatatypes[2]}'   Strip and split string    ${labelValuesVal[0]}  ,
        #     ...    ELSE IF  '${FieldDTVal${i}}' == '${QnrDatatypes[0]}'   Strip and split string    ${labelValuesVal[0]}  ,
        #     ...  ELSE	 Set Variable    ${labelValuesVal[0]}
        Set Test Variable  ${hintVal${i}}   ${hintVal}
        
    END

    FOR  ${i}  IN RANGE   ${len}
        ${x} =  Get Index From List  ${LabelVal}  ${resp.json()['labels'][${listno}]['questions'][${i}]['label']}
        Should Be Equal As Strings   ${resp.json()['labels'][${listno}]['questions'][${i}]['label']}  ${LabelVal[${x}]}
        Should Be Equal As Strings   ${resp.json()['labels'][${listno}]['questions'][${i}]['labelName']}  ${labelNameVal${x}}
        Should Be Equal As Strings   ${resp.json()['labels'][${listno}]['questions'][${i}]['fieldScope']}   ${ScopeVal${x}}
        Should Be Equal As Strings   ${resp.json()['labels'][${listno}]['questions'][${i}]['billable']}   ${billableVal${x}}

        Run Keyword If  '${resp.json()['labels'][${listno}]['questions'][${i}]['fieldDataType']}' != '${QnrDatatypes[5]}'
        ...    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['labels'][${listno}]['questions'][${i}]['labelValues']}   ${labelValuesVal${x}}
        
        Run Keyword If  '${resp.json()['labels'][${listno}]['questions'][${i}]['fieldDataType']}' == '${QnrDatatypes[1]}'
        ...    Run Keywords
        ...    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['labels'][${listno}]['questions'][${i}]['${QnrProperty[1]}']['minAnswers']}   ${minAnswersVal${x}}
        ...    AND  Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['labels'][${listno}]['questions'][${i}]['${QnrProperty[1]}']['maxAnswers']}   ${maxAnswersVal${x}}
        
        ...    ELSE IF  '${resp.json()['labels'][${listno}]['questions'][${i}]['fieldDataType']}' == '${QnrDatatypes[5]}'
        ...    Run Keywords
        ...    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['labels'][${listno}]['questions'][${i}]['${QnrProperty[5]}']['minNoOfFile']}   ${minAnswersVal${x}}
        ...    AND  Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['labels'][${listno}]['questions'][${i}]['${QnrProperty[5]}']['maxNoOfFile']}   ${maxAnswersVal${x}}
        ...    AND  Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['labels'][${listno}]['questions'][${i}]['${QnrProperty[5]}']['minSize']}   ${minVal${x}}
        ...    AND  Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['labels'][${listno}]['questions'][${i}]['${QnrProperty[5]}']['maxSize']}   ${maxVal${x}}
        ...    AND  Comapre Lists without order  ${resp.json()['labels'][${listno}]['questions'][${i}]['${QnrProperty[5]}']['fileTypes']}   ${filetypeVal${x}}  
        ...    AND  Comapre Lists without order  ${resp.json()['labels'][${listno}]['questions'][${i}]['${QnrProperty[5]}']['allowedDocuments']}   ${alloweddocVal${x}}  
        
        ...    ELSE IF  '${resp.json()['labels'][${listno}]['questions'][${i}]['fieldDataType']}' == '${QnrDatatypes[4]}'
        ...    Run Keywords
        ...    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['labels'][${listno}]['questions'][${i}]['${QnrProperty[4]}']['minAnswers']}   ${minAnswersVal${x}}
        ...    AND  Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['labels'][${listno}]['questions'][${i}]['${QnrProperty[4]}']['maxAnswers']}   ${maxAnswersVal${x}}
        ...    AND  Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['labels'][${listno}]['questions'][${i}]['${QnrProperty[4]}']['start']}   ${minVal${x}}
        ...    AND  Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['labels'][${listno}]['questions'][${i}]['${QnrProperty[4]}']['end']}   ${maxVal${x}}

        ...    ELSE IF  '${resp.json()['labels'][${listno}]['questions'][${i}]['fieldDataType']}' == '${QnrDatatypes[0]}'
        ...    Run Keywords
        ...    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['labels'][${listno}]['questions'][${i}]['${QnrProperty[0]}']['minNoOfLetter']}   ${minVal${x}}
        ...    AND  Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['labels'][${listno}]['questions'][${i}]['${QnrProperty[0]}']['maxNoOfLetter']}   ${maxVal${x}}

        ...    ELSE IF  '${resp.json()['labels'][${listno}]['questions'][${i}]['fieldDataType']}' == '${QnrDatatypes[3]}'
        ...    Run Keywords
        ...    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['labels'][${listno}]['questions'][${i}]['${QnrProperty[3]}']['startDate']}   ${minVal${x}}
        ...    AND  Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['labels'][${listno}]['questions'][${i}]['${QnrProperty[3]}']['endDate']}   ${maxVal${x}}

        
    END

*** Test Cases ***

JD-TC-GetQuestionnaireforConsumer-1
    [Documentation]  Get Consumer Creation questionnaire after enabling it.

    ${wb}=  readWorkbook  ${xlFile}
    ${sheet1}  GetCurrentSheet   ${wb}
    Set Suite Variable   ${sheet1}
    ${colnames}=  getColumnHeaders  ${sheet1}
    Log List  ${colnames}
    Set Suite Variable   ${colnames}
    ${servicenames}   getColumnValuesByName  ${sheet1}  ${colnames[6]}
    Log   ${servicenames}
    Set Suite Variable   ${servicenames}
    ${resp}=  Provider Login  ${PUSERNAME6}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}

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

    ${resp}=  Imageupload.UploadQuestionnaire   ${cookie}   ${account_id}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${sa_resp}=  Get Questionnaire List   ${account_id}  
    Log  ${sa_resp.content}
    Should Be Equal As Strings  ${sa_resp.status_code}  200

    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Login  ${PUSERNAME6}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
      ${id}  Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[4]}'  Set Variable  ${resp.json()[${i}]['id']} 
      ${qnrid}   Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[4]}'  Set Variable  ${resp.json()[${i}]['questionnaireId']}
      Exit For Loop If   '${id}' != '${None}'
    END

    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings   ${qns.json()['status']}  ${status[1]}

    ${resp}=  Provider Change Questionnaire Status  ${id}  ${status[0]}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings   ${qns.json()['status']}  ${status[0]}
    Set Suite Variable  ${Questionnaireid}  ${qns.json()['questionnaireId']}

    ${resp}=  Get Questionnaire for Consumer   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    &{dict}=  Create Dictionary   ${colnames[0]}=${qnrid}
    ${transactionTypeVal}=  getColumnValueByMultipleVals  ${sheet1}  ${colnames[1]}  &{dict}          
    Log  ${transactionTypeVal}
    ${ChannelVal}=  getColumnValueByMultipleVals  ${sheet1}  ${colnames[3]}  &{dict}  
    Log  ${ChannelVal}
    ${captureTimeVal}=  getColumnValueByMultipleVals  ${sheet1}  ${colnames[4]}  &{dict}  
    Log  ${captureTimeVal}

    Should Be Equal As Strings   ${resp.json()['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${resp.json()['id']}   ${id}
    Should Be Equal As Strings  ${resp.json()['labels'][0]['transactionType']}   ${QnrTransactionType[4]}
    Should Be Equal As Strings  ${resp.json()['labels'][0]['channel']}   ${QnrChannel[3]}
    Should Be Equal As Strings  ${resp.json()['labels'][0]['questionnaireId']}   ${qnrid}
    # Run Keyword And Ignore Error  Should Be Equal As Strings  ${resp.json()['captureTime']}   ${captureTimeVal[0]}
    Check Questions   0  ${resp}   ${qnrid}   ${sheet1}


JD-TC-GetQuestionnaireforConsumer-2
    [Documentation]  Get Consumer Creation questionnaire after enabling all questionnaires.

    # ${wb}=  readWorkbook  ${xlFile}
    # ${sheet1}  GetCurrentSheet   ${wb}
    # Set Suite Variable   ${sheet1}
    # ${colnames}=  getColumnHeaders  ${sheet1}
    # Log List  ${colnames}
    # Set Suite Variable   ${colnames}
    # ${servicenames}   getColumnValuesByName  ${sheet1}  ${colnames[7]}
    # Log   ${servicenames}
    ${resp}=  Provider Login  ${PUSERNAME6}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${s_len}=  Get Length  ${resp.json()}
    @{snames}=  Create List
    FOR  ${i}  IN RANGE   ${s_len}
        Append To List  ${snames}  ${resp.json()[${i}]['name']}
    END

    # Remove Values From List  ${servicenames}   ${NONE}
    # Log  ${servicenames}
    # ${unique_snames}=    Remove Duplicates    ${servicenames}
    # Log  ${unique_snames}
    ${snames_len}=  Get Length  ${unique_snames}
    FOR  ${i}  IN RANGE   ${snames_len}
        ${kwstatus} 	${value} = 	Run Keyword And Ignore Error  List Should Contain Value  ${snames}  ${unique_snames[${i}]}
        Log Many  ${kwstatus} 	${value}
        Continue For Loop If  '${kwstatus}' == 'PASS'
        ${s_id}=  Run Keyword If   '${kwstatus}' == 'FAIL'   Create Sample Service  ${unique_snames[${i}]}
    END

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
      ${ccid}  Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[4]}'  Set Variable  ${resp.json()[${i}]['id']} 
      ${ccqnrid}   Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[4]}'  Set Variable  ${resp.json()[${i}]['questionnaireId']}
      Exit For Loop If   '${ccid}' != ${None}
    END

    @{ids}=  Create List
    @{qnrids}=  Create List
    FOR  ${i}  IN RANGE   ${len}
        Append To List  ${ids}   ${resp.json()[${i}]['id']} 
        Append To List  ${qnrids}   ${resp.json()[${i}]['questionnaireId']}
    END

    FOR  ${id}  IN   @{ids}
        ${qns}   Get Provider Questionnaire By Id   ${id}  
        Log  ${qns.content}
        Should Be Equal As Strings  ${qns.status_code}  200
        # Should Be Equal As Strings   ${qns.json()['status']}  ${status[1]}

        ${resp1}=  Run Keyword If   '${qns.json()['status']}' == '${status[1]}'  Provider Change Questionnaire Status  ${id}  ${status[0]}  
        Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
        Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

        ${qns}   Get Provider Questionnaire By Id   ${id}  
        Log  ${qns.content}
        Should Be Equal As Strings  ${qns.status_code}  200
        Should Be Equal As Strings   ${qns.json()['status']}  ${status[0]}
    END

    ${resp}=  Get Questionnaire for Consumer   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    &{dict}=  Create Dictionary   ${colnames[0]}=${ccqnrid}
    ${transactionTypeVal}=  getColumnValueByMultipleVals  ${sheet1}  ${colnames[1]}  &{dict}          
    Log  ${transactionTypeVal}
    ${ChannelVal}=  getColumnValueByMultipleVals  ${sheet1}  ${colnames[3]}  &{dict}  
    Log  ${ChannelVal}
    ${captureTimeVal}=  getColumnValueByMultipleVals  ${sheet1}  ${colnames[4]}  &{dict}  
    Log  ${captureTimeVal}

    Should Be Equal As Strings   ${resp.json()['questionnaireId']}  ${ccqnrid}
    Should Be Equal As Strings  ${resp.json()['id']}   ${ccid}
    Should Be Equal As Strings  ${resp.json()['labels'][0]['transactionType']}   ${QnrTransactionType[4]}
    Should Be Equal As Strings  ${resp.json()['labels'][0]['channel']}   ${QnrChannel[3]}
    Should Be Equal As Strings  ${resp.json()['labels'][0]['questionnaireId']}   ${ccqnrid}
    # Run Keyword And Ignore Error  Should Be Equal As Strings  ${resp.json()['captureTime']}   ${captureTimeVal[0]}
    Check Questions   0  ${resp}   ${ccqnrid}   ${sheet1}


JD-TC-GetQuestionnaireforConsumer-UH1
    [Documentation]  Get Consumer Creation questionnaire after enabling all questionnairs except consumer creation questionnaire

    # ${wb}=  readWorkbook  ${xlFile}
    # ${sheet1}  GetCurrentSheet   ${wb}
    # Set Suite Variable   ${sheet1}
    # ${colnames}=  getColumnHeaders  ${sheet1}
    # Log List  ${colnames}
    # Set Suite Variable   ${colnames}
    # ${servicenames}   getColumnValuesByName  ${sheet1}  ${colnames[7]}
    # Log   ${servicenames}
    ${resp}=  Provider Login  ${PUSERNAME6}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${s_len}=  Get Length  ${resp.json()}
    @{snames}=  Create List
    FOR  ${i}  IN RANGE   ${s_len}
        Append To List  ${snames}  ${resp.json()[${i}]['name']}
    END

    # Remove Values From List  ${servicenames}   ${NONE}
    # Log  ${servicenames}
    # ${unique_snames}=    Remove Duplicates    ${servicenames}
    # Log  ${unique_snames}
    ${snames_len}=  Get Length  ${unique_snames}
    FOR  ${i}  IN RANGE   ${snames_len}
        ${kwstatus} 	${value} = 	Run Keyword And Ignore Error  List Should Contain Value  ${snames}  ${unique_snames[${i}]}
        Log Many  ${kwstatus} 	${value}
        Continue For Loop If  '${kwstatus}' == 'PASS'
        ${s_id}=  Run Keyword If   '${kwstatus}' == 'FAIL'   Create Sample Service  ${unique_snames[${i}]}
    END

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
      ${ccid}  Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}'  Set Variable  ${resp.json()[${i}]['id']} 
      ${qnrid}   Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}'  Set Variable  ${resp.json()[${i}]['questionnaireId']}
      Exit For Loop If   '${ccid}' != '${None}'
    END
    Set Suite Variable   ${ccid}
    Set Suite Variable   ${qnrid}

    @{ids}=  Create List
    @{qnrids}=  Create List
    FOR  ${i}  IN RANGE   ${len}
        Append To List  ${ids}   ${resp.json()[${i}]['id']} 
        Append To List  ${qnrids}   ${resp.json()[${i}]['questionnaireId']}
    END
    Log List   ${ids}
    Log List   ${qnrids}

    ${qns}   Get Provider Questionnaire By Id   ${ccid}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    # Should Be Equal As Strings   ${qns.json()['status']}  ${status[1]}

    ${resp1}=  Run Keyword If   '${qns.json()['status']}' == '${status[0]}'  Provider Change Questionnaire Status  ${ccid}  ${status[1]}  
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${qns}   Get Provider Questionnaire By Id   ${ccid}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings   ${qns.json()['status']}  ${status[1]}

    FOR  ${id}  IN   @{ids}
        
        Continue For Loop If   '${id}' == '${ccid}'  
        
        ${qns}   Get Provider Questionnaire By Id   ${id}  
        Log  ${qns.content}
        Should Be Equal As Strings  ${qns.status_code}  200
        # Should Be Equal As Strings   ${qns.json()['status']}  ${status[1]}

        ${resp1}=  Run Keyword If   '${qns.json()['status']}' == '${status[1]}'  Provider Change Questionnaire Status  ${id}  ${status[0]}  
        Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
        Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

        ${qns}   Get Provider Questionnaire By Id   ${id}  
        Log  ${qns.content}
        Should Be Equal As Strings  ${qns.status_code}  200
        Should Be Equal As Strings   ${qns.json()['status']}  ${status[0]}
    END

    ${resp}=  Get Questionnaire for Consumer   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings   ${resp.json()}   ${uh-error}


JD-TC-GetQuestionnaireforConsumer-UH2
    [Documentation]  Get Consumer Creation questionnaire without enabling any questionnaire

    # ${wb}=  readWorkbook  ${xlFile}
    # ${sheet1}  GetCurrentSheet   ${wb}
    # Set Suite Variable   ${sheet1}
    # ${colnames}=  getColumnHeaders  ${sheet1}
    # Log List  ${colnames}
    # Set Suite Variable   ${colnames}
    # ${servicenames}   getColumnValuesByName  ${sheet1}  ${colnames[7]}
    # Log   ${servicenames}
    ${resp}=  Provider Login  ${PUSERNAME6}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${s_len}=  Get Length  ${resp.json()}
    @{snames}=  Create List
    FOR  ${i}  IN RANGE   ${s_len}
        Append To List  ${snames}  ${resp.json()[${i}]['name']}
    END

    # Remove Values From List  ${servicenames}   ${NONE}
    # Log  ${servicenames}
    # ${unique_snames}=    Remove Duplicates    ${servicenames}
    # Log  ${unique_snames}
    ${snames_len}=  Get Length  ${unique_snames}
    FOR  ${i}  IN RANGE   ${snames_len}
        ${kwstatus} 	${value} = 	Run Keyword And Ignore Error  List Should Contain Value  ${snames}  ${unique_snames[${i}]}
        Log Many  ${kwstatus} 	${value}
        Continue For Loop If  '${kwstatus}' == 'PASS'
        ${s_id}=  Run Keyword If   '${kwstatus}' == 'FAIL'   Create Sample Service  ${unique_snames[${i}]}
    END

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
      ${ccid}  Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[4]}'  Set Variable  ${resp.json()[${i}]['id']} 
      ${ccqnrid}   Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[4]}'  Set Variable  ${resp.json()[${i}]['questionnaireId']}
      Exit For Loop If   '${ccid}' != ${None}
    END

    Log Many  ${ccid}  ${ccqnrid}

    @{ids}=  Create List
    @{qnrids}=  Create List
    FOR  ${i}  IN RANGE   ${len}
        Append To List  ${ids}   ${resp.json()[${i}]['id']} 
        Append To List  ${qnrids}   ${resp.json()[${i}]['questionnaireId']}
    END

    Log List   ${ids}
    Log List   ${qnrids}

    FOR  ${id}  IN   @{ids}
        ${qns}   Get Provider Questionnaire By Id   ${id}  
        Log  ${qns.content}
        Should Be Equal As Strings  ${qns.status_code}  200
        # Should Be Equal As Strings   ${qns.json()['status']}  ${status[1]}

        ${resp1}=  Run Keyword If   '${qns.json()['status']}' == '${status[0]}'  Provider Change Questionnaire Status  ${id}  ${status[1]}  
        Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
        Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

        ${qns}   Get Provider Questionnaire By Id   ${id}  
        Log  ${qns.content}
        Should Be Equal As Strings  ${qns.status_code}  200
        Should Be Equal As Strings   ${qns.json()['status']}  ${status[1]}
    END

    ${resp}=  Get Questionnaire for Consumer   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()}   ${uh-error}
    


JD-TC-GetQuestionnaireforConsumer-UH3
    [Documentation]  Get Consumer Creation questionnaire without provider login

    ${resp}=  Get Questionnaire for Consumer   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}  ${SESSION_EXPIRED}


JD-TC-GetQuestionnaireforConsumer-UH4
    [Documentation]  Get Consumer Creation questionnaire by consumer login

    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Questionnaire for Consumer   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   ${resp.json()}  ${LOGIN_NO_ACCESS_FOR_URL}


JD-TC-GetQuestionnaireforConsumer-UH5
    [Documentation]  Get Consumer Creation questionnaire by superadmin login

    ${resp}=   SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Questionnaire for Consumer   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}  ${SESSION_EXPIRED}


JD-TC-GetQuestionnaireforConsumer-UH6
    [Documentation]  Get Consumer Creation questionnaire without uploading questionnaire


    ${resp}=  Provider Login  ${PUSERNAME144}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Questionnaire for Consumer   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings   ${resp.json()}  ${LOGIN_NO_ACCESS_FOR_URL}
    Should Be Equal As Strings   ${resp.json()}   ${uh-error}
