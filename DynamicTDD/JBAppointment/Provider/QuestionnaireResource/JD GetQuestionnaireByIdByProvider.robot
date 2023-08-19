*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Run Keywords  Delete All Sessions  #Close Workbook
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
@{if_dt_list}   ${QnrDatatypes[5]}   ${QnrDatatypes[7]}  ${QnrDatatypes[8]}
# @{QnrDatatypes}   plainText  list  bool  date  number  fileUpload  map
# @{QnrProperty}   plainTextPropertie   listPropertie  booleanProperties   dateProperties  numberPropertie   filePropertie    

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
    [Arguments]  ${resp}  ${qnid}  ${sheet}
    ${len}=  Get Length  ${resp.json()['questions']}
    ${d}=  Create Dictionary   ${colnames[0]}=${qnid}
    ${LabelVal}   getColumnValueByAnotherVal  ${sheet}  ${colnames[10]}  ${colnames[0]}  ${qnid}
    Log List  ${LabelVal}
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
        # Run Keyword If  '${type}' == 'list' and '${FieldDTVal${i}}' == '${QnrDatatypes[0]}'  Set Test Variable  ${labelValuesVal${i}}   ${lv[0]}
        # ...    ELSE	 Set Test Variable  ${labelValuesVal${i}}   ${lv}
        # Set Test Variable  ${labelValuesVal${i}}   ${lv} 
        IF  '${type}' == 'list' and '${FieldDTVal${i}}' == '${QnrDatatypes[0]}'
            Set Test Variable  ${labelValuesVal${i}}   ${lv[0]}
        ELSE IF   '${type}' == 'int'
            ${float_lv}=  Convert To Number  ${lv[0]}
            Set Test Variable  ${labelValuesVal${i}}   ${float_lv}
        ELSE
            Set Test Variable  ${labelValuesVal${i}}   ${lv[0]}
        END

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
            ...    ELSE IF  '${FieldDTVal${i}}' == '${QnrDatatypes[7]}'  Split String    ${minVal[0]}  ${SPACE}
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
            ...    ELSE IF  '${FieldDTVal${i}}' == '${QnrDatatypes[7]}'  Split String    ${minVal[0]}  ${SPACE}
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
        ${x} =  Get Index From List  ${LabelVal}  ${resp.json()['questions'][${i}]['label']}
        Should Be Equal As Strings   ${resp.json()['questions'][${i}]['label']}  ${LabelVal[${x}]}
        Should Be Equal As Strings   ${resp.json()['questions'][${i}]['labelName']}  ${labelNameVal${x}}
        Should Be Equal As Strings  ${resp.json()['questions'][${i}]['fieldScope']}   ${ScopeVal${x}}
        Should Be Equal As Strings   ${resp.json()['questions'][${i}]['billable']}   ${billableVal${x}}

        ${value2}=    evaluate    False if $labelValuesVal${x} is None else True
        # Run Keyword If   '${resp.json()['questions'][${i}]['fieldDataType']}' not in @{if_dt_list} and '$labelValuesVal${x}' is not ${None}
        Run Keyword If   '${resp.json()['questions'][${i}]['fieldDataType']}' not in @{if_dt_list} and '${value2}' != 'False'
        ...    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['questions'][${i}]['labelValues']}   ${labelValuesVal${x}}
        
        Run Keyword If  '${resp.json()['questions'][${i}]['fieldDataType']}' == '${QnrDatatypes[1]}'
        ...    Run Keywords
        ...    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['questions'][${i}]['${QnrProperty[1]}']['minAnswers']}   ${minAnswersVal${x}}
        ...    AND  Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['questions'][${i}]['${QnrProperty[1]}']['maxAnswers']}   ${maxAnswersVal${x}}
        
        ...    ELSE IF  '${resp.json()['questions'][${i}]['fieldDataType']}' == '${QnrDatatypes[5]}'
        ...    Run Keywords
        ...    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['questions'][${i}]['${QnrProperty[5]}']['minNoOfFile']}   ${minAnswersVal${x}}
        ...    AND  Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['questions'][${i}]['${QnrProperty[5]}']['maxNoOfFile']}   ${maxAnswersVal${x}}
        ...    AND  Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['questions'][${i}]['${QnrProperty[5]}']['minSize']}   ${minVal${x}}
        ...    AND  Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['questions'][${i}]['${QnrProperty[5]}']['maxSize']}   ${maxVal${x}}
        ...    AND  Comapre Lists without order  ${resp.json()['questions'][${i}]['${QnrProperty[5]}']['fileTypes']}   ${filetypeVal${x}}  
        ...    AND  Comapre Lists without order  ${resp.json()['questions'][${i}]['${QnrProperty[5]}']['allowedDocuments']}   ${alloweddocVal${x}}  
        
        ...    ELSE IF  '${resp.json()['questions'][${i}]['fieldDataType']}' == '${QnrDatatypes[4]}'
        ...    Run Keywords
        ...    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['questions'][${i}]['${QnrProperty[4]}']['minAnswers']}   ${minAnswersVal${x}}
        ...    AND  Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['questions'][${i}]['${QnrProperty[4]}']['maxAnswers']}   ${maxAnswersVal${x}}
        ...    AND  Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['questions'][${i}]['${QnrProperty[4]}']['start']}   ${minVal${x}}
        ...    AND  Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['questions'][${i}]['${QnrProperty[4]}']['end']}   ${maxVal${x}}

        ...    ELSE IF  '${resp.json()['questions'][${i}]['fieldDataType']}' == '${QnrDatatypes[0]}'
        ...    Run Keywords
        ...    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['questions'][${i}]['${QnrProperty[0]}']['minNoOfLetter']}   ${minVal${x}}
        ...    AND  Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['questions'][${i}]['${QnrProperty[0]}']['maxNoOfLetter']}   ${maxVal${x}}

        ...    ELSE IF  '${resp.json()['questions'][${i}]['fieldDataType']}' == '${QnrDatatypes[3]}'
        ...    Run Keywords
        ...    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['questions'][${i}]['${QnrProperty[3]}']['startDate']}   ${minVal${x}}
        ...    AND  Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['questions'][${i}]['${QnrProperty[3]}']['endDate']}   ${maxVal${x}}

        
    END

*** Test Cases ***

JD-TC-ProviderGetQuestionnaireById-1
    [Documentation]  Get questionnaire by id after uploading a file
    ${wb}=  readWorkbook  ${xlFile}
    ${sheet1}  GetCurrentSheet   ${wb}
    Set Suite Variable   ${sheet1}
    ${colnames}=  getColumnHeaders  ${sheet1}
    Log List  ${colnames}
    Set Suite Variable   ${colnames}
    ${servicenames}   getColumnValuesByName  ${sheet1}  ${colnames[6]}
    Log   ${servicenames}
    ${resp}=  Provider Login  ${PUSERNAME13}  ${PASSWORD}
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

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${sa_resp}=  Get Questionnaire List   ${account_id}  
    Log  ${sa_resp.content}
    Should Be Equal As Strings  ${sa_resp.status_code}  200
    ${len}=  Get Length  ${sa_resp.json()}

    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Login  ${PUSERNAME13}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    ${list of ids}  Create List
    FOR  ${i}  IN RANGE   ${len}
      
        Append To List  ${list of ids}  ${resp.json()[${i}]['id']}
    END

    # @{qnrid}=  Create List
    # Open given Excel file  ${xlFile}  doc1
    # @{data sheet}=  Read sheet data  get_column_names_from_header_row=${TRUE}
    # Log  ${data sheet}
    # ${rows_list}=   Create List
    # FOR  ${row}  IN  @{data sheet}
    #   Log dictionary  ${row}
    #   ${row_dict}=  Copy Dictionary  ${row}
    #   Keep In Dictionary   ${row_dict}  ${colnames[1]}  ${colnames[3]}  ${colnames[6]}
    #   Append To List   ${rows_list}  ${row_dict}
    # END
    # Log List  ${rows_list}
    # ${row_len}=  Get Length  ${rows_list}
    # ${unique_rows_list}=    Remove Duplicates  ${rows_list}
    # Log List  ${unique_rows_list}
    # ${row_len}=  Get Length  ${unique_rows_list}
    # FOR  ${i}  IN RANGE  ${row_len}
    #     &{dict}=  Create Dictionary   ${colnames[1]}=${unique_rows_list[${i}]['${colnames[1]}']}  ${colnames[3]}=${unique_rows_list[${i}]['${colnames[3]}']}  ${colnames[6]}=${unique_rows_list[${i}]['${colnames[6]}']}
    #     ${qnrval}=  getColumnValueByMultipleVals  ${sheet1}  ${colnames[0]}  &{dict}
    #     ${unique_qnrval}=    Remove Duplicates    ${qnrval}
    #     Log List  ${unique_qnrval}
    #    Append To List   ${qnrid}  ${unique_qnrval[0]}
    # END
    ${qnrid}=  getColumnValuesByName  ${sheet1}  ${colnames[0]}
    Log List  ${qnrid}
    ${unique_qnrids}=    Remove Duplicates    ${qnrid}
    Log List  ${unique_qnrids}
    Set Suite Variable   ${unique_qnrids}
    ${qnrid_len}=  Get Length  ${unique_qnrids}
    Set Suite Variable   ${qnrid_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${len}  ${qnrid_len}    

    
    FOR  ${id}  IN  @{list of ids}
        ${resp}=  Get Provider Questionnaire By Id   ${id}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${x} =  Get Index From List  ${unique_qnrids}  ${resp.json()['questionnaireId']}
        &{dict}=  Create Dictionary   ${colnames[0]}=${unique_qnrids[${x}]}
        ${transactionTypeVal}=  getColumnValueByMultipleVals  ${sheet1}  ${colnames[1]}  &{dict}          
        Log  ${transactionTypeVal}
        ${ChannelVal}=  getColumnValueByMultipleVals  ${sheet1}  ${colnames[3]}  &{dict}  
        Log  ${ChannelVal}
        ${captureTimeVal}=  getColumnValueByMultipleVals  ${sheet1}  ${colnames[4]}  &{dict}  
        Log  ${captureTimeVal}

        Should Be Equal As Strings   ${resp.json()['account']}  ${account_id}
        Should Be Equal As Strings  ${resp.json()['transactionType']}   ${transactionTypeVal[0]}
        Should Be Equal As Strings  ${resp.json()['channel']}   ${ChannelVal[0]}
        Run Keyword And Ignore Error  Should Be Equal As Strings  ${resp.json()['captureTime']}   ${captureTimeVal[0]}
        Check Questions   ${resp}   ${unique_qnrids[${x}]}   ${sheet1}
        
    END

*** COMMENT *** 

JD-TC-ProviderGetQuestionnaireById-2
    [Documentation]  Get questionnaire by id after uploading the same file again
    ${wb}=  readWorkbook  ${xlFile}
    ${sheet1}  GetCurrentSheet   ${wb}
    Set Suite Variable   ${sheet1}
    ${colnames}=  getColumnHeaders  ${sheet1}
    Log List  ${colnames}
    Set Suite Variable   ${colnames}
    ${servicenames}   getColumnValuesByName  ${sheet1}  ${colnames[6]}
    Log   ${servicenames}
    ${resp}=  Provider Login  ${PUSERNAME13}  ${PASSWORD}
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

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${sa_resp}=  Get Questionnaire List   ${account_id}  
    Log  ${sa_resp.content}
    Should Be Equal As Strings  ${sa_resp.status_code}  200
    ${len}=  Get Length  ${sa_resp.json()}

    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Login  ${PUSERNAME13}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    ${list of ids}  Create List
    FOR  ${i}  IN RANGE   ${len}
      
        Append To List  ${list of ids}  ${resp.json()[${i}]['id']}
    END

    # @{qnrid}=  Create List
    # # Open given Excel file  ${xlFile}  doc1
    # @{data sheet}=  Read sheet data  get_column_names_from_header_row=${TRUE}
    # Log  ${data sheet}
    # ${rows_list}=   Create List
    # FOR  ${row}  IN  @{data sheet}
    #   Log dictionary  ${row}
    #   ${row_dict}=  Copy Dictionary  ${row}
    #   Keep In Dictionary   ${row_dict}  ${colnames[1]}  ${colnames[3]}  ${colnames[6]}
    #   Append To List   ${rows_list}  ${row_dict}
    # END
    # Log List  ${rows_list}
    # ${row_len}=  Get Length  ${rows_list}
    # ${unique_rows_list}=    Remove Duplicates  ${rows_list}
    # Log List  ${unique_rows_list}
    # ${row_len}=  Get Length  ${unique_rows_list}
    # FOR  ${i}  IN RANGE  ${row_len}
    #     &{dict}=  Create Dictionary   ${colnames[1]}=${unique_rows_list[${i}]['${colnames[1]}']}  ${colnames[3]}=${unique_rows_list[${i}]['${colnames[3]}']}  ${colnames[6]}=${unique_rows_list[${i}]['${colnames[6]}']}
    #     ${qnrval}=  getColumnValueByMultipleVals  ${sheet1}  ${colnames[0]}  &{dict}
    #     ${unique_qnrval}=    Remove Duplicates    ${qnrval}
    #     Log List  ${unique_qnrval}
    #    Append To List   ${qnrid}  ${unique_qnrval[0]}
    # END
    ${qnrid}=  getColumnValuesByName  ${sheet1}  ${colnames[0]}
    Log List  ${qnrid}
    ${unique_qnrids}=    Remove Duplicates    ${qnrid}
    Log List  ${unique_qnrids}
    Set Suite Variable   ${unique_qnrids}
    ${qnrid_len}=  Get Length  ${unique_qnrids}
    Set Suite Variable   ${qnrid_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${len}  ${qnrid_len}    

    
    FOR  ${id}  IN  @{list of ids}
        ${resp}=  Get Provider Questionnaire By Id   ${id}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${x} =  Get Index From List  ${unique_qnrids}  ${resp.json()['questionnaireId']}
        &{dict}=  Create Dictionary   ${colnames[0]}=${unique_qnrids[${x}]}
        ${transactionTypeVal}=  getColumnValueByMultipleVals  ${sheet1}  ${colnames[1]}  &{dict}          
        Log  ${transactionTypeVal}
        ${ChannelVal}=  getColumnValueByMultipleVals  ${sheet1}  ${colnames[3]}  &{dict}  
        Log  ${ChannelVal}
        ${captureTimeVal}=  getColumnValueByMultipleVals  ${sheet1}  ${colnames[4]}  &{dict}  
        Log  ${captureTimeVal}

        Should Be Equal As Strings   ${resp.json()['account']}  ${account_id}
        Should Be Equal As Strings  ${resp.json()['transactionType']}   ${transactionTypeVal[0]}
        Should Be Equal As Strings  ${resp.json()['channel']}   ${ChannelVal[0]}
        Run Keyword And Ignore Error  Should Be Equal As Strings  ${resp.json()['captureTime']}   ${captureTimeVal[0]}
        Check Questions   ${resp}   ${unique_qnrids[${x}]}   ${sheet1}
        
    END


JD-TC-ProviderGetQuestionnaireById-3
    [Documentation]  Get questionnaire by id after uploading another file
    ${wb}=  readWorkbook  ${xlFile2}
    ${sheet2}  GetCurrentSheet   ${wb}
    Set Suite Variable   ${sheet2}
    ${colnames}=  getColumnHeaders  ${sheet2}
    Log List  ${colnames}
    Set Suite Variable   ${colnames}
    ${servicenames}   getColumnValuesByName  ${sheet2}  ${colnames[6]}
    Log   ${servicenames}
    ${resp}=  Provider Login  ${PUSERNAME13}  ${PASSWORD}
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
    ${snames_len}=  Get Length  ${unique_snames}
    FOR  ${i}  IN RANGE   ${snames_len}
        ${kwstatus} 	${value} = 	Run Keyword And Ignore Error  List Should Contain Value  ${snames}  ${unique_snames[${i}]}
        Log Many  ${kwstatus} 	${value}
        Continue For Loop If  '${kwstatus}' == 'PASS'
        &{dict}=  Create Dictionary   ${colnames[6]}=${unique_snames[${i}]}
        ${ttype}=  getColumnValueByMultipleVals  ${sheet2}  ${colnames[1]}  &{dict}  
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

    ${resp}=  Imageupload.UploadQuestionnaire   ${cookie}   ${account_id}   ${xlFile2} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${sa_resp}=  Get Questionnaire List   ${account_id}  
    Log  ${sa_resp.content}
    Should Be Equal As Strings  ${sa_resp.status_code}  200
    ${len}=  Get Length  ${sa_resp.json()}

    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Login  ${PUSERNAME13}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    ${list of ids}  Create List
    FOR  ${i}  IN RANGE   ${len}
      
        Append To List  ${list of ids}  ${resp.json()[${i}]['id']}
    END

    # @{qnrid}=  Create List
    # Open given Excel file  ${xlFile2}  doc2
    # @{data sheet}=  Read sheet data  get_column_names_from_header_row=${TRUE}
    # Log  ${data sheet}
    # ${rows_list}=   Create List
    # FOR  ${row}  IN  @{data sheet}
    #   Log dictionary  ${row}
    #   ${row_dict}=  Copy Dictionary  ${row}
    #   Keep In Dictionary   ${row_dict}  ${colnames[1]}  ${colnames[3]}  ${colnames[6]}
    #   Append To List   ${rows_list}  ${row_dict}
    # END
    # Log List  ${rows_list}
    # ${row_len}=  Get Length  ${rows_list}
    # ${unique_rows_list}=    Remove Duplicates  ${rows_list}
    # Log List  ${unique_rows_list}
    # ${row_len}=  Get Length  ${unique_rows_list}
    # FOR  ${i}  IN RANGE  ${row_len}
    #     &{dict}=  Create Dictionary   ${colnames[1]}=${unique_rows_list[${i}]['${colnames[1]}']}  ${colnames[3]}=${unique_rows_list[${i}]['${colnames[3]}']}  ${colnames[6]}=${unique_rows_list[${i}]['${colnames[6]}']}
    #     ${qnrval}=  getColumnValueByMultipleVals  ${sheet2}  ${colnames[0]}  &{dict}
    #     ${unique_qnrval}=    Remove Duplicates    ${qnrval}
    #     Log List  ${unique_qnrval}
    #    Append To List   ${qnrid}  ${unique_qnrval[0]}
    # END
    ${qnrid}=  getColumnValuesByName  ${sheet2}  ${colnames[0]}
    Log List  ${qnrid}
    Remove Values From List  ${qnrid}   ${NONE}
    ${unique_qnrids1}=    Remove Duplicates    ${qnrid}
    Log List  ${unique_qnrids1}
    Set Suite Variable   ${unique_qnrids1}
    ${qnrid_len1}=  Get Length  ${unique_qnrids1}
    Set Suite Variable   ${qnrid_len1}
    ${qnrid_len}=  Evaluate  ${qnrid_len1}+${qnrid_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${len}  ${qnrid_len}    

    
    FOR  ${id}  IN  @{list of ids}
        ${resp}=  Get Provider Questionnaire By Id   ${id}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${status} 	${value} = 	Run Keyword And Ignore Error  List Should Contain Value  ${unique_qnrids1}  ${resp.json()['questionnaireId']}
        Log Many  ${status} 	${value}
        Log Many  ${unique_qnrids} 	${unique_qnrids1}
        ${x} =  Run Keyword If   '${status}' == 'PASS'  Get Index From List  ${unique_qnrids1}  ${resp.json()['questionnaireId']}
        ...   ELSE  Get Index From List  ${unique_qnrids}  ${resp.json()['questionnaireId']}
        # ${x} =  Get Index From List  ${unique_qnrids}  ${resp.json()['questionnaireId']}
        &{dict}=  Run Keyword If   '${status}' == 'PASS'  Create Dictionary   ${colnames[0]}=${unique_qnrids1[${x}]}
        ...   ELSE   Create Dictionary   ${colnames[0]}=${unique_qnrids[${x}]}
        ${transactionTypeVal}=  Run Keyword If   '${status}' == 'PASS'  getColumnValueByMultipleVals  ${sheet2}  ${colnames[1]}  &{dict}          
        ...   ELSE   getColumnValueByMultipleVals  ${sheet1}  ${colnames[1]}  &{dict}
        Log  ${transactionTypeVal}
        ${ChannelVal}=  Run Keyword If   '${status}' == 'PASS'  getColumnValueByMultipleVals  ${sheet2}  ${colnames[3]}  &{dict}  
        ...   ELSE   getColumnValueByMultipleVals  ${sheet1}  ${colnames[3]}  &{dict}
        Log  ${ChannelVal}
        ${captureTimeVal}=  Run Keyword If   '${status}' == 'PASS'  getColumnValueByMultipleVals  ${sheet2}  ${colnames[4]}  &{dict}  
        ...   ELSE   getColumnValueByMultipleVals  ${sheet1}  ${colnames[4]}  &{dict}
        Log  ${captureTimeVal}

        Run Keyword And Ignore Error  Should Be Equal As Strings   ${resp.json()['account']}  ${account_id}
        Run Keyword And Ignore Error  Should Be Equal As Strings  ${resp.json()['transactionType']}   ${transactionTypeVal[0]}
        Run Keyword And Ignore Error  Should Be Equal As Strings  ${resp.json()['channel']}   ${ChannelVal[0]}
        Run Keyword And Ignore Error  Should Be Equal As Strings  ${resp.json()['captureTime']}   ${captureTimeVal[0]}
        Run Keyword If   '${status}' == 'PASS'  Check Questions   ${resp}   ${unique_qnrids1[${x}]}   ${sheet2}
        ...    ELSE IF   '${status}' == 'FAIL'  Check Questions   ${resp}   ${unique_qnrids[${x}]}   ${sheet1}
        
    END


JD-TC-ProviderGetQuestionnaireById-UH1
    [Documentation]  Get questionnaire by id without provider login
    
    ${id}=  FakerLibrary.Random Int  min=1  max=3

    ${resp}=  Get Provider Questionnaire By Id   ${id}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}  ${SESSION_EXPIRED}


JD-TC-ProviderGetQuestionnaireById-UH2
    [Documentation]  Get questionnaire by id 

    ${id}=  FakerLibrary.Random Int  min=1  max=3

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Provider Questionnaire By Id   ${id}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}  ${SESSION_EXPIRED}


JD-TC-ProviderGetQuestionnaireById-UH3
    [Documentation]  Get questionnaire by id by consumer login

    ${id}=  FakerLibrary.Random Int  min=1  max=3

    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Provider Questionnaire By Id   ${id}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   ${resp.json()}  ${LOGIN_NO_ACCESS_FOR_URL}


JD-TC-ProviderGetQuestionnaireById-UH4
    [Documentation]  Get questionnaire by non existant id

    ${id}=  FakerLibrary.Random Int  min=520  max=530

    ${resp}=  Provider Login  ${PUSERNAME13}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Provider Questionnaire By Id   ${id}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}  ${QUESTIONNAIRE_NOT_EXIST}