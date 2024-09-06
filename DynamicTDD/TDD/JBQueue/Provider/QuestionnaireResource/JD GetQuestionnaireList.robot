*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Run Keywords  Delete All Sessions  #Close Workbook
Force Tags        Questionnaire
Library           Collections
Library           String
Library           json
Library           FakerLibrary
#Library           ExcellentLibrary
# Library           ExcelLibrary
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
# @{QnrDatatypes}   plainText  list  bool  date  number  fileUpload  map
# @{QnrProperty}   plainTextPropertie   listPropertie  booleanProperties   dateProperties  numberPropertie   filePropertie    
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
    [Arguments]  ${listno}  ${resp}  ${qnid}  ${sheet}
    ${len}=  Get Length  ${resp.json()[${listno}]['questions']}
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
        ${type}=    Evaluate     type($billableVal[0]).__name__
        # ${stripped_val}=  Strip String  ${billableVal[0]}
        ${stripped_val}=  Run Keyword If  '${type}' == 'bool'  Set Variable    ${billableVal[0]}
        ...    ELSE	 Strip String  ${billableVal[0]}
        Set Test Variable  ${billableVal${i}}  ${stripped_val}

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
        ${x} =  Get Index From List  ${LabelVal}  ${resp.json()[${listno}]['questions'][${i}]['label']}
        Should Be Equal As Strings   ${resp.json()[${listno}]['questions'][${i}]['label']}  ${LabelVal[${x}]}
        Should Be Equal As Strings   ${resp.json()[${listno}]['questions'][${i}]['labelName']}  ${labelNameVal${x}}
        Should Be Equal As Strings  ${resp.json()[${listno}]['questions'][${i}]['fieldScope']}   ${ScopeVal${x}}
        Should Be Equal As Strings  ${resp.json()[${listno}]['questions'][${i}]['billable']}   ${billableVal${x}}

        # Run Keyword If  '${resp.json()[${listno}]['questions'][${i}]['fieldDataType']}' != '${QnrDatatypes[5]}'
        ${value2}=    evaluate    False if $labelValuesVal${x} is None else True
        Run Keyword If   '${resp.json()[${listno}]['questions'][${i}]['fieldDataType']}' not in @{if_dt_list} and '${value2}' != 'False'
        ...    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[${listno}]['questions'][${i}]['labelValues']}   ${labelValuesVal${x}}
        
        Run Keyword If  '${resp.json()[${listno}]['questions'][${i}]['fieldDataType']}' == '${QnrDatatypes[1]}'
        ...    Run Keywords
        ...    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[${listno}]['questions'][${i}]['${QnrProperty[1]}']['minAnswers']}   ${minAnswersVal${x}}
        ...    AND  Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[${listno}]['questions'][${i}]['${QnrProperty[1]}']['maxAnswers']}   ${maxAnswersVal${x}}
        
        ...    ELSE IF  '${resp.json()[${listno}]['questions'][${i}]['fieldDataType']}' == '${QnrDatatypes[5]}'
        ...    Run Keywords
        ...    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[${listno}]['questions'][${i}]['${QnrProperty[5]}']['minNoOfFile']}   ${minAnswersVal${x}}
        ...    AND  Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[${listno}]['questions'][${i}]['${QnrProperty[5]}']['maxNoOfFile']}   ${maxAnswersVal${x}}
        ...    AND  Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[${listno}]['questions'][${i}]['${QnrProperty[5]}']['minSize']}   ${minVal${x}}
        ...    AND  Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[${listno}]['questions'][${i}]['${QnrProperty[5]}']['maxSize']}   ${maxVal${x}}
        ...    AND  Comapre Lists without order  ${resp.json()[${listno}]['questions'][${i}]['${QnrProperty[5]}']['fileTypes']}   ${filetypeVal${x}}  
        ...    AND  Comapre Lists without order  ${resp.json()[${listno}]['questions'][${i}]['${QnrProperty[5]}']['allowedDocuments']}   ${alloweddocVal${x}}  
        
        ...    ELSE IF  '${resp.json()[${listno}]['questions'][${i}]['fieldDataType']}' == '${QnrDatatypes[4]}'
        ...    Run Keywords
        ...    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[${listno}]['questions'][${i}]['${QnrProperty[4]}']['minAnswers']}   ${minAnswersVal${x}}
        ...    AND  Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[${listno}]['questions'][${i}]['${QnrProperty[4]}']['maxAnswers']}   ${maxAnswersVal${x}}
        ...    AND  Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[${listno}]['questions'][${i}]['${QnrProperty[4]}']['start']}   ${minVal${x}}
        ...    AND  Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[${listno}]['questions'][${i}]['${QnrProperty[4]}']['end']}   ${maxVal${x}}

        ...    ELSE IF  '${resp.json()[${listno}]['questions'][${i}]['fieldDataType']}' == '${QnrDatatypes[0]}'
        ...    Run Keywords
        ...    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[${listno}]['questions'][${i}]['${QnrProperty[0]}']['minNoOfLetter']}   ${minVal${x}}
        ...    AND  Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[${listno}]['questions'][${i}]['${QnrProperty[0]}']['maxNoOfLetter']}   ${maxVal${x}}

        ...    ELSE IF  '${resp.json()[${listno}]['questions'][${i}]['fieldDataType']}' == '${QnrDatatypes[3]}'
        ...    Run Keywords
        ...    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[${listno}]['questions'][${i}]['${QnrProperty[3]}']['startDate']}   ${minVal${x}}
        ...    AND  Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[${listno}]['questions'][${i}]['${QnrProperty[3]}']['endDate']}   ${maxVal${x}}

        
    END

*** Test Cases ***

JD-TC-GetQuestionnaireListByProvider-1
    [Documentation]  Get questionnaire list after uploading a file
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
    Remove Values From List  ${servicenames}   ${NONE}
    Log  ${servicenames}
    ${unique_snames}=    Remove Duplicates    ${servicenames}
    Log  ${unique_snames}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['timezone']}

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

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${sa_resp}=  Get Questionnaire List   ${account_id}  
    Log  ${sa_resp.content}
    Should Be Equal As Strings  ${sa_resp.status_code}  200
    ${len}=  Get Length  ${sa_resp.json()}

    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    # Should Be Equal   ${sa_resp.json()}  ${resp.json()}

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
    # FOR  ${row}  IN  @{data sheet}
    #    Log dictionary  ${row}
    #    Append To List   ${qnrid}  ${row['questionnaireId']}
    # END
    Remove Values From List  ${qnrid}   ${NONE}
    ${unique_qnrids}=    Remove Duplicates    ${qnrid}
    Log List  ${unique_qnrids}
    Set Suite Variable   ${unique_qnrids}
    ${qnrid_len}=  Get Length  ${unique_qnrids}
    Set Suite Variable   ${qnrid_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${len}  ${qnrid_len}
    FOR  ${i}  IN RANGE   ${len}
        ${x} =  Get Index From List  ${unique_qnrids}  ${resp.json()[${i}]['questionnaireId']}
        &{dict}=  Create Dictionary   ${colnames[0]}=${unique_qnrids[${x}]}
        ${transactionTypeVal}=  getColumnValueByMultipleVals  ${sheet1}  ${colnames[1]}  &{dict}          
        Log  ${transactionTypeVal}
        ${ChannelVal}=  getColumnValueByMultipleVals  ${sheet1}  ${colnames[3]}  &{dict}  
        Log  ${ChannelVal}
        ${captureTimeVal}=  getColumnValueByMultipleVals  ${sheet1}  ${colnames[4]}  &{dict}  
        Log  ${captureTimeVal}

        Should Be Equal As Strings   ${resp.json()[${i}]['account']}  ${account_id}
        Should Be Equal As Strings  ${resp.json()[${i}]['transactionType']}   ${transactionTypeVal[0]}
        Should Be Equal As Strings  ${resp.json()[${i}]['channel']}   ${ChannelVal[0]}
        Run Keyword And Ignore Error  Should Be Equal As Strings  ${resp.json()[${i}]['captureTime']}   ${captureTimeVal[0]}
        Check Questions   ${i}   ${resp}   ${unique_qnrids[${x}]}   ${sheet1}
        
    END

JD-TC-GetQuestionnaireListByProvider-2
    [Documentation]  Get questionnaire list after uploading the same file again
    ${wb}=  readWorkbook  ${xlFile}
    ${sheet1}  GetCurrentSheet   ${wb}
    Set Suite Variable   ${sheet1}
    ${colnames}=  getColumnHeaders  ${sheet1}
    Log List  ${colnames}
    Set Suite Variable   ${colnames}
    ${servicenames}   getColumnValuesByName  ${sheet1}  ${colnames[6]}
    Log   ${servicenames}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
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
    
    # ${cookie}  ${resp}=  Imageupload.SALogin    ${SUSERNAME}  ${SPASSWORD}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Imageupload.UploadQuestionnaire   ${cookie}   ${account_id}   ${xlFile}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${sa_resp}=  Get Questionnaire List   ${account_id}  
    Log  ${sa_resp.content}
    Should Be Equal As Strings  ${sa_resp.status_code}  200
    ${len}=  Get Length  ${sa_resp.json()}

    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    # Should Be Equal   ${sa_resp.json()}  ${resp.json()}

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
    # FOR  ${row}  IN  @{data sheet}
    #    Log dictionary  ${row}
    #    Append To List   ${qnrid}  ${row['questionnaireId']}
    # END
    ${unique_qnrids}=    Remove Duplicates    ${qnrid}
    Set Suite Variable   ${unique_qnrids}
    ${qnrid_len}=  Get Length  ${unique_qnrids}
    Set Suite Variable   ${qnrid_len}
    Should Be Equal As Strings  ${len}  ${qnrid_len}
    FOR  ${i}  IN RANGE   ${len}
        ${x} =  Get Index From List  ${unique_qnrids}  ${resp.json()[${i}]['questionnaireId']}
        &{dict}=  Create Dictionary   ${colnames[0]}=${unique_qnrids[${x}]}
        ${transactionTypeVal}=  getColumnValueByMultipleVals  ${sheet1}  ${colnames[1]}  &{dict}          
        Log  ${transactionTypeVal}
        ${ChannelVal}=  getColumnValueByMultipleVals  ${sheet1}  ${colnames[3]}  &{dict}  
        Log  ${ChannelVal}
        ${captureTimeVal}=  getColumnValueByMultipleVals  ${sheet1}  ${colnames[4]}  &{dict}  
        Log  ${captureTimeVal}

        Should Be Equal As Strings   ${resp.json()[${i}]['account']}  ${account_id}
        Should Be Equal As Strings  ${resp.json()[${i}]['transactionType']}   ${transactionTypeVal[0]}
        Should Be Equal As Strings  ${resp.json()[${i}]['channel']}   ${ChannelVal[0]}
        Run Keyword And Ignore Error  Should Be Equal As Strings  ${resp.json()[${i}]['captureTime']}   ${captureTimeVal[0]}
        Check Questions   ${i}   ${resp}   ${unique_qnrids[${x}]}   ${sheet1}
        
    END

JD-TC-GetQuestionnaireListByProvider-3
    [Documentation]  Get questionnaire list after uploading a second file
    ${wb1}=  readWorkbook  ${xlFile2}
    ${sheet2}  GetCurrentSheet   ${wb1}
    # Set Suite Variable   ${sheet2}
    ${colnames1}=  getColumnHeaders  ${sheet2}
    Log List  ${colnames1}
    Set Suite Variable   ${colnames1}
    ${servicenames}   getColumnValuesByName  ${sheet2}  ${colnames1[6]}
    Log   ${servicenames}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
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

    ${resp}=  Imageupload.UploadQuestionnaire   ${cookie}   ${account_id}  ${xlFile2} 
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

    ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    # Should Be Equal   ${sa_resp.json()}  ${resp.json()}

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
    # FOR  ${row}  IN  @{data sheet}
    #    Log dictionary  ${row}
    #    Append To List   ${qnrid}  ${row['questionnaireId']}
    # END
    Remove Values From List  ${qnrid}   ${NONE}
    ${unique_qnrids2}=    Remove Duplicates    ${qnrid}
    Set Suite Variable   ${unique_qnrids2}
    ${qnrid_len1}=  Get Length  ${unique_qnrids2}
    Set Suite Variable   ${qnrid_len1}
    ${qnrid_len}=  Evaluate  ${qnrid_len1}+${qnrid_len}
    Should Be Equal As Strings  ${len}  ${qnrid_len}
    FOR  ${i}  IN RANGE   ${len}

        ${status} 	${value} = 	Run Keyword And Ignore Error  List Should Contain Value  ${unique_qnrids2}  ${resp.json()[${i}]['questionnaireId']}
        Log Many  ${status} 	${value}
        Log Many  ${unique_qnrids} 	${unique_qnrids2}

        # ${x} =  Get Index From List  ${unique_qnrids2}  ${resp.json()[${i}]['questionnaireId']}
        ${x} =  Run Keyword If   '${status}' == 'PASS'  Get Index From List  ${unique_qnrids2}  ${resp.json()[${i}]['questionnaireId']}
        ...   ELSE  Get Index From List  ${unique_qnrids}  ${resp.json()[${i}]['questionnaireId']}
        # &{dict}=  Create Dictionary   ${colnames[0]}=${unique_qnrids2[${x}]}
        &{dict}=  Run Keyword If   '${status}' == 'PASS'  Create Dictionary   ${colnames[0]}=${unique_qnrids1[${x}]}
        ...   ELSE   Create Dictionary   ${colnames[0]}=${unique_qnrids[${x}]}
        # ${transactionTypeVal}=  getColumnValueByMultipleVals  ${sheet2}  ${colnames[1]}  &{dict}          
        # Log  ${transactionTypeVal}
        # ${ChannelVal}=  getColumnValueByMultipleVals  ${sheet2}  ${colnames[3]}  &{dict}  
        # Log  ${ChannelVal}
        # ${captureTimeVal}=  getColumnValueByMultipleVals  ${sheet2}  ${colnames[4]}  &{dict}  
        # Log  ${captureTimeVal}
        ${transactionTypeVal}=  Run Keyword If   '${status}' == 'PASS'  getColumnValueByMultipleVals  ${sheet2}  ${colnames[1]}  &{dict}          
        ...   ELSE   getColumnValueByMultipleVals  ${sheet1}  ${colnames[1]}  &{dict}
        Log  ${transactionTypeVal}
        ${ChannelVal}=  Run Keyword If   '${status}' == 'PASS'  getColumnValueByMultipleVals  ${sheet2}  ${colnames[3]}  &{dict}  
        ...   ELSE   getColumnValueByMultipleVals  ${sheet1}  ${colnames[3]}  &{dict}
        Log  ${ChannelVal}
        ${captureTimeVal}=  Run Keyword If   '${status}' == 'PASS'  getColumnValueByMultipleVals  ${sheet2}  ${colnames[4]}  &{dict}  
        ...   ELSE   getColumnValueByMultipleVals  ${sheet1}  ${colnames[4]}  &{dict}
        Log  ${captureTimeVal}

        Should Be Equal As Strings   ${resp.json()[${i}]['account']}  ${account_id}
        Should Be Equal As Strings  ${resp.json()[${i}]['transactionType']}   ${transactionTypeVal[0]}
        Should Be Equal As Strings  ${resp.json()[${i}]['channel']}   ${ChannelVal[0]}
        Run Keyword And Ignore Error  Should Be Equal As Strings  ${resp.json()[${i}]['captureTime']}   ${captureTimeVal[0]}
        # Check Questions   ${i}   ${resp}   ${unique_qnrids2[${x}]}   ${sheet2}
        IF   '${status}' == 'PASS'  
            Check Questions   ${i}   ${resp}   ${unique_qnrids2[${x}]}   ${sheet2}
        ELSE IF   '${status}' == 'FAIL'  
            Check Questions   ${i}    ${resp}   ${unique_qnrids[${x}]}   ${sheet1}
        END
    END

JD-TC-GetQuestionnaireListByProvider-UH1
    [Documentation]  Get questionnaire list without superadmin login
    ${account_id}=  db.get_acc_id  ${PUSERNAME2}
    
    ${resp}=  Get Questionnaire List   ${account_id}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   "${resp.json()}"   "${SA_SESSION_EXPIRED}"


JD-TC-GetQuestionnaireListByProvider-UH2
    [Documentation]  Get questionnaire list by provider login

    ${account_id}=  db.get_acc_id  ${PUSERNAME2}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Questionnaire List   ${account_id}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   "${resp.json()}"   "${SA_SESSION_EXPIRED}"

JD-TC-GetQuestionnaireListByProvider-UH3
    [Documentation]  Get questionnaire list by consumer login

    ${account_id}=  get_acc_id  ${PUSERNAME2}

    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Questionnaire List   ${account_id}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   "${resp.json()}"   "${SA_SESSION_EXPIRED}"



*** Comments ***

JD-TC-GetQuestionnaireListByProvider-3
    [Documentation]  Get questionnaire list after uploading a second file
    ${wb1}=  readWorkbook  ${xlFile2}
    ${sheet2}  GetCurrentSheet   ${wb1}
    # Set Suite Variable   ${sheet2}
    ${colnames1}=  getColumnHeaders  ${sheet2}
    Set Suite Variable   ${colnames1}
    ${servicenames}   getColumnValuesByName  ${sheet2}  ${colnames1[7]}
    Log   ${servicenames}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
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
        &{dict}=  Create Dictionary   ${colnames[7]}=${unique_snames[${i}]}
        ${ttype}=  getColumnValueByMultipleVals  ${sheet2}  ${colnames[5]}  &{dict}  
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

    ${resp}=  Imageupload.UploadQuestionnaire   ${cookie}   ${account_id}  ${xlFile2} 
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

    ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    # Should Be Equal   ${sa_resp.json()}  ${resp.json()}

    @{qnrid}=  Create List
    Open given Excel file  ${xlFile2}  doc2
    @{data sheet}=  Read sheet data  get_column_names_from_header_row=${TRUE}
    Log  ${data sheet}
    ${rows_list}=   Create List
    FOR  ${row}  IN  @{data sheet}
      Log dictionary  ${row}
      ${row_dict}=  Copy Dictionary  ${row}
      Keep In Dictionary   ${row_dict}  ${colnames[5]}  ${colnames[6]}  ${colnames[7]}
      Append To List   ${rows_list}  ${row_dict}
    END
    Log List  ${rows_list}
    ${row_len}=  Get Length  ${rows_list}
    ${unique_rows_list}=    Remove Duplicates  ${rows_list}
    Log List  ${unique_rows_list}
    ${row_len}=  Get Length  ${unique_rows_list}
    FOR  ${i}  IN RANGE  ${row_len}
        &{dict}=  Create Dictionary   ${colnames[5]}=${unique_rows_list[${i}]['${colnames[5]}']}  ${colnames[6]}=${unique_rows_list[${i}]['${colnames[6]}']}  ${colnames[7]}=${unique_rows_list[${i}]['${colnames[7]}']}
        ${qnrval}=  getColumnValueByMultipleVals  ${sheet1}  ${colnames[0]}  &{dict}
        ${unique_qnrval}=    Remove Duplicates    ${qnrval}
        Log List  ${unique_qnrval}
       Append To List   ${qnrid}  ${unique_qnrval[0]}
    END
    Log List  ${qnrid}
    # FOR  ${row}  IN  @{data sheet}
    #    Log dictionary  ${row}
    #    Append To List   ${qnrid}  ${row['questionnaireId']}
    # END
    ${unique_qnrids2}=    Remove Duplicates    ${qnrid}
    Set Suite Variable   ${unique_qnrids2}
    ${qnrid_len}=  Get Length  ${unique_qnrids2}
    Set Suite Variable   ${qnrid_len}
    Should Be Equal As Strings  ${len}  ${qnrid_len}
    FOR  ${i}  IN RANGE   ${len}

        ${status} 	${value} = 	Run Keyword And Ignore Error  List Should Contain Value  ${unique_qnrids2}  ${resp.json()[${i}]['questionnaireId']}
        Log Many  ${status} 	${value}
        ${x} =  Run Keyword If   '${status}' == 'PASS'  Get Index From List  ${unique_qnrids2}  ${resp.json()[${i}]['questionnaireId']}
        ...   ELSE  Get Index From List  ${unique_qnrids}  ${resp.json()[${i}]['questionnaireId']}
        
        ${transactionTypeVal2}=   Run Keyword If   '${status}' == 'PASS'   getColumnValueByAnotherVal  ${sheet2}  ${colnames2[5]}  ${colnames2[0]}  ${unique_qnrids2[${x}]}
        ...   ELSE  getColumnValueByAnotherVal  ${sheet1}  ${colnames[5]}  ${colnames[0]}  ${unique_qnrids[${x}]}
        Log  ${transactionTypeVal2}

        ${ChannelVal2}=  Run Keyword If   '${status}' == 'PASS'   getColumnValueByAnotherVal  ${sheet2}  ${colnames2[6]}  ${colnames2[0]}  ${unique_qnrids2[${x}]}
        ...   ELSE  getColumnValueByAnotherVal  ${sheet1}  ${colnames[6]}  ${colnames[0]}  ${unique_qnrids[${x}]}  
        Log  ${ChannelVal2}
        
        Run Keyword If   '${status}' == 'PASS'
        ...    Run Keywords
        ...    Should Be Equal As Strings   ${resp.json()[${i}]['account']}  ${account_id}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['transactionType']}   ${transactionTypeVal2[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['channel']}   ${ChannelVal2[0]}
        # Should Be Equal As Strings  ${resp.json()[${i}]['captureTime']}   ${captureTimeVal2[0]}
        ...    AND  Check Questions   ${i}   ${resp}   ${unique_qnrids2[${x}]}  ${sheet2}

        ...    ELSE IF   '${status}' == 'FAIL'
        ...    Run Keywords
        ...    Should Be Equal As Strings   ${resp.json()[${i}]['account']}  ${account_id}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['transactionType']}   ${transactionTypeVal2[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['channel']}   ${ChannelVal2[0]}
        # Should Be Equal As Strings  ${resp.json()[${i}]['captureTime']}   ${captureTimeVal[0]}
        ...    AND  Check Questions   ${i}   ${resp}   ${unique_qnrids[${x}]}   ${sheet1}
        
    END