*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Run Keywords  Delete All Sessions  
Force Tags        Questionnaire
Library           Collections
Library           String
Library           json
Library           FakerLibrary
#Library           ExcellentLibrary
# Library           ExcelLibrary
Library           OperatingSystem
Library           robot.api.logger
Library           /ebs/TDD/Imageupload.py
Library           /ebs/TDD/db.py
Library           /ebs/TDD/excelfuncs.py
Resource          /ebs/TDD/SuperAdminKeywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Library           /ebs/TDD/excelfuncs.py


*** Variables ***
${xlFile}      ${EXECDIR}/TDD/sampleqnr.xlsx    # DataSheet
${xlFile2}      ${EXECDIR}/TDD/qnr.xlsx    # DataSheet 2
@{emptylist}
@{Datatypes}   plainText  list  bool  date  number  fileUpload  map
@{property}   plainTextPropertie   listPropertie  booleanProperties   dateProperties  numberPropertie   filePropertie    
&{plainTextPropertie}   minNoOfLetter=0  maxNoOfLetter=0
&{numberPropertie}   start=0  end=0  minAnswers=0  maxAnswers=0
&{listPropertie}   minAnswers=0  maxAnswers=0
&{filePropertie}   minSize=0  maxSize=0  width=0  length=0  fileTypes=[]  minNoOfFile=0  maxNoOfFile=0  allowedDocuments=[]
&{dateProperties}   startDate=""  endDate=""  mandatory=true
&{booleanProperties}   mandatory=true

*** Keywords ***

Strip and split string
   [Arguments]    ${value}  ${char}
#    ${stripped}=    Remove String    ${value}    ${SPACE}
   ${split}=  Split String    ${value}  ${char}
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
            ...  ELSE	 Set Variable    ${labelValuesVal[0]}
        Set Test Variable  ${labelValuesVal${i}}   ${lv} 

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
        
    END

    FOR  ${i}  IN RANGE   ${len}
        ${x} =  Get Index From List  ${LabelVal}  ${resp.json()[${listno}]['questions'][${i}]['label']}
        Should Be Equal As Strings   ${resp.json()[${listno}]['questions'][${i}]['label']}  ${LabelVal[${x}]}
        Should Be Equal As Strings   ${resp.json()[${listno}]['questions'][${i}]['labelName']}  ${labelNameVal${x}}
        Should Be Equal As Strings  ${resp.json()[${listno}]['questions'][${i}]['fieldScope']}   ${ScopeVal${x}}
        Should Be Equal As Strings  ${resp.json()[${listno}]['questions'][${i}]['billable']}   ${billableVal${x}}

        Run Keyword If  '${resp.json()[${listno}]['questions'][${i}]['fieldDataType']}' != '${QnrDatatypes[5]}'
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

JD-TC-GetQuestionnaireList-1
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
    Set Suite Variable   ${unique_snames}

    ${resp}=  Provider Login  ${PUSERNAME113}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}

    # ${resp}=   Get jaldeeIntegration Settings
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # IF  '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[0]}'
    #     ${resp1}=   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
    #     Should Be Equal As Strings  ${resp1.status_code}  200
    # ELSE IF    '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[1]}'
    #     ${resp1}=   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
    #     Should Be Equal As Strings  ${resp1.status_code}  200
    # END

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

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
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${cookie}  ${resp}=  Imageupload.SALogin    ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Imageupload.UploadQuestionnaire   ${cookie}   ${account_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Questionnaire List   ${account_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
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
    # @{qnid}=  Create List
    # # Open given Excel file  ${xlFile}  doc1
    # @{data sheet}=  Read sheet data  get_column_names_from_header_row=${TRUE}
    # Log  ${data sheet}
    # FOR  ${row}  IN  @{data sheet}
    #    Log dictionary  ${row}
    #    Append To List   ${qnid}  ${row['questionnaireId']}
    # END
    # ${unique_qnids}=    Remove Duplicates    ${qnid}
    # Set Suite Variable   ${unique_qnids}
    # ${qnid_len}=  Get Length  ${unique_qnids}
    # Set Suite Variable   ${qnid_len}
    # Should Be Equal As Strings  ${len}  ${qnid_len}

    # FOR  ${i}  IN RANGE   ${qnid_len}
    #     Set Test Variable  ${qnid${i}}  ${unique_qnids[${i}]}
    # END
    ${wb}=  readWorkbook  ${xlFile}
    ${sheet1}  GetCurrentSheet   ${wb}
    Set Suite Variable   ${sheet1}
    ${colnames}=  getColumnHeaders  ${sheet1}
    Log  ${colnames}
    Set Suite Variable   ${colnames}
    # FOR  ${i}  IN RANGE   ${qnid_len}
    #    ${colvalues}   getColumnValueByAnotherVal  ${sheet1}  ${colnames[1]}  ${colnames[0]}  ${unique_qnids[${i}]}
    #    Set Test Variable  ${colvalues${i}}  ${colvalues}
    # END

    

    FOR  ${i}  IN RANGE   ${len}
        ${x} =  Get Index From List  ${unique_qnids}  ${resp.json()[${i}]['questionnaireId']}
        ${transactionTypeVal}=  getColumnValueByAnotherVal  ${sheet1}  ${colnames[5]}  ${colnames[0]}  ${unique_qnids[${x}]}          
        Log  ${transactionTypeVal}
        ${ChannelVal}=  getColumnValueByAnotherVal  ${sheet1}  ${colnames[6]}  ${colnames[0]}  ${unique_qnids[${x}]}  
        Log  ${ChannelVal}
        Set Suite Variable   ${unique_qnids}
        # ${captureTimeVal}=  getColumnValueByAnotherVal  ${sheet1}  ${colnames[17]}  ${colnames[0]}  ${unique_qnids[${x}]}  
        # Log  ${captureTimeVal}

        Should Be Equal As Strings   ${resp.json()[${i}]['account']}  ${account_id}
        Should Be Equal As Strings  ${resp.json()[${i}]['transactionType']}   ${transactionTypeVal[0]}
        Should Be Equal As Strings  ${resp.json()[${i}]['channel']}   ${ChannelVal[0]}
        # Should Be Equal As Strings  ${resp.json()[${i}]['captureTime']}   ${captureTimeVal[0]}
        Check Questions   ${i}   ${resp}   ${unique_qnids[${x}]}   ${sheet1}
        
    END



JD-TC-GetQuestionnaireList-2

    [Documentation]  Get questionnaire list after uploading 2nd file
    
    ${account_id}=  db.get_acc_id  ${PUSERNAME2}
    
    # ${cookie}  ${resp}=  Imageupload.SALogin    ${SUSERNAME}  ${SPASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Imageupload.UploadQuestionnaire   ${cookie}   ${account_id}   ${xlFile2}  
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Questionnaire List   ${account_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len1}=  Get Length  ${resp.json()}

    # @{qnid2}=  Create List
    # Open given Excel file  ${xlFile2}  doc2
    # @{data sheet}=  Read sheet data  get_column_names_from_header_row=${TRUE}
    # Log  ${data sheet}
    # FOR  ${row}  IN  @{data sheet}
    #    Log dictionary  ${row}
    #    Append To List   ${qnid2}  ${row['questionnaireId']}
    # END
    # ${unique_qnids2}=    Remove Duplicates    ${qnid2}
    # ${qnid2_len}=  Get Length  ${unique_qnids2}
    # ${tot_len}=  Evaluate  ${qnid2_len}+${qnid_len}
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${len1}  ${tot_len}

    # FOR  ${i}  IN RANGE   ${qnid2_len}
    #     Set Test Variable  ${qnid2${i}}  ${unique_qnids2[${i}]}
    # END

    ${wb}=  readWorkbook  ${xlFile2}
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
    Set Suite Variable   ${unique_snames}

    

    ${wb1}=  readWorkbook  ${xlFile2}
    ${sheet2}  GetCurrentSheet   ${wb1}
    Set Suite Variable   ${sheet2}
    ${colnames2}=  getColumnHeaders  ${sheet2}
    Log  ${colnames2}
    Set Suite Variable   ${colnames2}
    FOR  ${i}  IN RANGE   ${qnid2_len}
       ${colvalues2}   getColumnValueByAnotherVal  ${sheet2}  ${colnames2[1]}  ${colnames2[0]}  ${unique_qnids2[${i}]}
       Set Test Variable  ${colvalues2${i}}  ${colvalues2}
    END

    FOR  ${i}  IN RANGE   ${len1}
        ${status} 	${value} = 	Run Keyword And Ignore Error  List Should Contain Value  ${unique_qnids2}  ${resp.json()[${i}]['questionnaireId']}
        Log Many  ${status} 	${value}
        ${x} =  Run Keyword If   '${status}' == 'PASS'  Get Index From List  ${unique_qnids2}  ${resp.json()[${i}]['questionnaireId']}
        ...   ELSE  Get Index From List  ${unique_qnids}  ${resp.json()[${i}]['questionnaireId']}
        # ${x} =  Get Index From List  ${unique_qnids2}  ${resp.json()[${i}]['questionnaireId']}
        ${transactionTypeVal2}=   Run Keyword If   '${status}' == 'PASS'   getColumnValueByAnotherVal  ${sheet2}  ${colnames2[5]}  ${colnames2[0]}  ${unique_qnids2[${x}]}
        ...   ELSE  getColumnValueByAnotherVal  ${sheet1}  ${colnames[5]}  ${colnames[0]}  ${unique_qnids[${x}]}
        # ${transactionTypeVal2}=  getColumnValueByAnotherVal  ${sheet2}  ${colnames2[5]}  ${colnames2[0]}  ${unique_qnids2[${x}]}          
        Log  ${transactionTypeVal2}
        ${ChannelVal2}=  Run Keyword If   '${status}' == 'PASS'   getColumnValueByAnotherVal  ${sheet2}  ${colnames2[6]}  ${colnames2[0]}  ${unique_qnids2[${x}]}
        ...   ELSE  getColumnValueByAnotherVal  ${sheet1}  ${colnames[6]}  ${colnames[0]}  ${unique_qnids[${x}]}
        # ${ChannelVal2}=  getColumnValueByAnotherVal  ${sheet2}  ${colnames2[6]}  ${colnames2[0]}  ${unique_qnids2[${x}]}  
        Log  ${ChannelVal2}
        # # ${captureTimeVal2}=  getColumnValueByAnotherVal  ${sheet2}  ${colnames2[-1]}  ${colnames2[0]}  ${unique_qnids[${x}]}  
        # # Log  ${captureTimeVal2}
        Run Keyword If   '${status}' == 'PASS'
        ...    Run Keywords
        ...    Should Be Equal As Strings   ${resp.json()[${i}]['account']}  ${account_id}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['transactionType']}   ${transactionTypeVal2[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['channel']}   ${ChannelVal2[0]}
        # Should Be Equal As Strings  ${resp.json()[${i}]['captureTime']}   ${captureTimeVal2[0]}
        ...    AND  Check Questions   ${i}   ${resp}   ${unique_qnids2[${x}]}  ${sheet2}

        ...    ELSE IF   '${status}' == 'FAIL'
        ...    Run Keywords
        ...    Should Be Equal As Strings   ${resp.json()[${i}]['account']}  ${account_id}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['transactionType']}   ${transactionTypeVal2[0]}
        ...    AND  Should Be Equal As Strings  ${resp.json()[${i}]['channel']}   ${ChannelVal2[0]}
        # Should Be Equal As Strings  ${resp.json()[${i}]['captureTime']}   ${captureTimeVal[0]}
        ...    AND  Check Questions   ${i}   ${resp}   ${unique_qnids[${x}]}   ${sheet1}
        
    END


JD-TC-GetQuestionnaireList-UH1
    [Documentation]  Get questionnaire list without superadmin login
    ${account_id}=  db.get_acc_id  ${PUSERNAME2}
    
    ${resp}=  Get Questionnaire List   ${account_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}  ${SA_SESSION_EXPIRED}


JD-TC-GetQuestionnaireList-UH2
    [Documentation]  Get questionnaire list by provider login

    ${account_id}=  db.get_acc_id  ${PUSERNAME2}

    ${resp}=  Provider Login  ${PUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Questionnaire List   ${account_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}  ${SA_SESSION_EXPIRED}


JD-TC-GetQuestionnaireList-UH3
    [Documentation]  Get questionnaire list by consumer login

    ${account_id}=  get_acc_id  ${PUSERNAME2}

    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Questionnaire List   ${account_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}  ${SA_SESSION_EXPIRED}





