*** Settings ***

Suite Teardown    Run Keywords  Delete All Sessions  
Test Teardown     Delete All Sessions
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

*** Variables ***
${xlFile}      ${EXECDIR}/TDD/sampleqnr.xlsx    # DataSheet
${xlFile2}      ${EXECDIR}/TDD/qnr.xlsx    # DataSheet 2
${SERVICE1}   consultation
@{Datatypes}   plainText  list  bool  date  number  fileUpload  map
@{property}   plainTextPropertie   listPropertie  booleanProperties   dateProperties  numberPropertie   filePropertie
@{if_dt_list}   ${QnrDatatypes[5]}   ${QnrDatatypes[7]}  ${QnrDatatypes[8]}

*** Keywords ***

Open given Excel file
    [Arguments]    ${xlFile}  ${doc id}
    #Check that the given Excel Exists
    ${inputfileStatus}    ${msg}    Run Keyword And Ignore Error    OperatingSystem.File Should Exist    ${xlFile}
    Run Keyword If    "${inputfileStatus}"=="PASS"    info    ${xlFile} Test data file exist    ELSE    Fail    Cannot locate the given Excel file.
    Open workbook   ${xlFile}   ${doc id}

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


 


Check Questions
    [Arguments]    ${resp}  ${qnid}  ${sheet}
    ${len}=  Get Length  ${resp.json()['questions']}
    ${LabelVal}   getColumnValueByAnotherVal  ${sheet}  ${colnames[10]}  ${colnames[0]}  ${qnid}
    Log  ${LabelVal}
    ${qn len}=  Get Length  ${LabelVal}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${qn len}   ${len} 	
    
    FOR  ${i}  IN RANGE   ${qn len}
        ${a}=  Create Dictionary   ${colnames[0]}=${qnid}  ${colnames[10]}=${LabelVal[${i}]}
        ${labelNameVal}   getColumnValueByMultipleVals  ${sheet}  ${colnames[10]}  &{a}
        Log  ${labelNameVal}
        Set Test Variable  ${labelNameVal${i}}  ${labelNameVal[0]}

        ${FieldDTVal}   getColumnValueByMultipleVals  ${sheet}  ${colnames[15]}  &{a}
        Log  ${FieldDTVal}
        Set Test Variable  ${FieldDTVal${i}}  ${FieldDTVal[0]}

        ${ScopeVal}   getColumnValueByMultipleVals  ${sheet}  ${colnames[14]}  &{a}
        Log  ${ScopeVal}
        Set Test Variable  ${ScopeVal${i}}  ${ScopeVal[0]}

        ${labelValuesVal}   getColumnValueByMultipleVals  ${sheet}  ${colnames[13]}   &{a}
        Log  ${labelValuesVal}
        ${lv}=  Run Keyword If  '${FieldDTVal${i}}' == '${QnrDatatypes[1]}'   Strip and split string    ${labelValuesVal[0].strip()}  ,
            ...    ELSE IF  '${FieldDTVal${i}}' == '${QnrDatatypes[2]}'   Strip and split string    ${labelValuesVal[0]}  ,
            ...    ELSE IF  '${FieldDTVal${i}}' == '${QnrDatatypes[0]}'   Strip and split string    ${labelValuesVal[0]}  ,
            ...    ELSE	 Set Variable    ${labelValuesVal[0]}
        ${type}=    Evaluate     type($lv).__name__
        Run Keyword If  '${type}' == 'list' and '${FieldDTVal${i}}' == '${QnrDatatypes[0]}'  Set Test Variable  ${labelValuesVal${i}}   ${lv[0]}
        ...    ELSE	 Set Test Variable  ${labelValuesVal${i}}   ${lv}

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
        # ${mnv}=  Run Keyword If  '${FieldDTVal${i}}' == '${Datatypes[4]}'   Split String    ${minVal[0]}  ${SPACE}
        #     ...    ELSE IF  '${FieldDTVal${i}}' == '${Datatypes[5]}'  Split String    ${minVal[0]}  ${SPACE}
        #     ...    ELSE IF  '${FieldDTVal${i}}' == '${Datatypes[0]}'  Split String    ${minVal[0]}  ${SPACE}
        #     ...    ELSE IF  '${FieldDTVal${i}}' == '${Datatypes[1]}'  Convert To Integer    ${minVal[0]}
        #     ...    ELSE	 Set Variable    ${minVal[0]}

        IF   '${FieldDTVal${i}}' == '${QnrDatatypes[0]}' or '${FieldDTVal${i}}' == '${QnrDatatypes[3]}' or '${FieldDTVal${i}}' == '${QnrDatatypes[4]}' or '${FieldDTVal${i}}' == '${QnrDatatypes[5]}'
            ${mnv}=  Split String    ${minVal[0]}  ${SPACE}
        ELSE IF    '${FieldDTVal${i}}' == '${QnrDatatypes[1]}'
            ${mnv}=  Convert To Integer    ${minVal[0]}
        ELSE
            ${mnv}=  Set Variable    ${minVal[0]}
        END

        ${type}=    Evaluate     type($mnv).__name__
        Run Keyword If  '${type}' == 'list'  Set Test Variable  ${minVal${i}}   ${mnv[0]}
        ...    ELSE	 Set Test Variable  ${minVal${i}}   ${mnv}

        ${maxVal}   getColumnValueByMultipleVals  ${sheet}  ${colnames[20]}  &{a}
        Log  ${maxVal}
        # ${mxv}=  Run Keyword If  '${FieldDTVal${i}}' == '${Datatypes[4]}'   Split String    ${maxVal[0]}  ${SPACE}
        #     ...    ELSE IF  '${FieldDTVal${i}}' == '${Datatypes[5]}'  Split String    ${maxVal[0]}  ${SPACE}
        #     ...    ELSE IF  '${FieldDTVal${i}}' == '${Datatypes[0]}'  Split String    ${maxVal[0]}  ${SPACE}
        #     ...    ELSE IF  '${FieldDTVal${i}}' == '${Datatypes[1]}'  Convert To Integer    ${maxVal[0]}
        #     ...    ELSE	 Set Variable    ${maxVal[0]}

        IF   '${FieldDTVal${i}}' == '${QnrDatatypes[0]}' or '${FieldDTVal${i}}' == '${QnrDatatypes[3]}' or '${FieldDTVal${i}}' == '${QnrDatatypes[4]}' or '${FieldDTVal${i}}' == '${QnrDatatypes[5]}'
            ${mxv}=  Split String    ${maxVal[0]}  ${SPACE}
        ELSE IF    '${FieldDTVal${i}}' == '${QnrDatatypes[1]}'
            ${mxv}=  Convert To Integer    ${maxVal[0]}
        ELSE
            ${mxv}=  Set Variable    ${maxVal[0]}
        END
        
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
        ${x} =  Get Index From List  ${LabelVal}  ${resp.json()['questions'][${i}]['label']}
        Should Be Equal As Strings   ${resp.json()['questions'][${i}]['label']}  ${LabelVal[${x}]}
        # Should Be Equal As Strings   ${resp.json()['questions'][${i}]['labelName']}  ${labelNameVal${x}}
        # Should Be Equal As Strings  ${resp.json()['questions'][${i}]['fieldScope']}   ${ScopeVal${x}}
        Should Be Equal As Strings  ${resp.json()['questions'][${i}]['billable']}   ${billableVal${x}}

        ${value2}=    evaluate    False if $labelValuesVal${x} is None else True
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

        # ...    ELSE IF  '${resp.json()['questions'][${i}]['fieldDataType']}' == '${QnrDatatypes[3]}'
        # ...    Run Keywords
        # ...    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['questions'][${i}]['${QnrProperty[3]}']['startDate']}   ${minVal${x}}
        # ...    AND  Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['questions'][${i}]['${QnrProperty[3]}']['endDate']}   ${maxVal${x}}

        
    END


*** Test Cases ***

JD-TC-GetQuestionsByID-1
    [Documentation]  Get questions by id
  
    # clear_service   ${PUSERNAME3}
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

    ${qnrids}   getColumnValuesByName  ${sheet1}  ${colnames[0]}
    Log   ${qnrids}
    Remove Values From List  ${qnrids}   ${NONE}
    Log  ${qnrids}
    ${unique_qnrids}=    Remove Duplicates    ${qnrids}
    Log  ${unique_qnrids}
    Set Suite Variable   ${unique_qnrids}
    ${qnrid_len}=  Get Length  ${unique_qnrids}


    ${resp}=  Encrypted Provider Login  ${PUSERNAME3}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # ${account_id}=  db.get_acc_id  ${PUSERNAME3}

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}

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

    ${resp}=  Imageupload.UploadQuestionnaire   ${cookie}   ${account_id}   ${xlFile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Questionnaire List   ${account_id}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${qnrid_len}   ${len}
    ${qnr_id_list}=  Create List
    FOR  ${i}  IN RANGE   ${len}
        Append To List   ${qnr_id_list}  ${resp.json()[${i}]['id']}
    END


    FOR  ${id}  IN   @{qnr_id_list}
        ${qns}=   Get Questionnaire By Id  ${account_id}  ${id}  
        Log  ${qns.content}
        Should Be Equal As Strings  ${qns.status_code}  200
        Set Test Variable   ${qnr_id}  ${qns.json()['questionnaireId']}
        ${transactionTypeVal}=  getColumnValueByAnotherVal  ${sheet1}  ${colnames[1]}  ${colnames[0]}  ${qnr_id}          
        Log  ${transactionTypeVal}
        ${ChannelVal}=  getColumnValueByAnotherVal  ${sheet1}  ${colnames[3]}  ${colnames[0]}  ${qnr_id}  
        Log  ${ChannelVal}
        # ${captureTimeVal}=  getColumnValueByAnotherVal  ${sheet1}  ${colnames[17]}  ${colnames[0]}  ${qnr_id}  
        # Log  ${captureTimeVal}

        # Should Be Equal As Strings   ${qns.json()['account']}  ${account_id}
        Should Be Equal As Strings  ${qns.json()['transactionType']}   ${transactionTypeVal[0]}
        Should Be Equal As Strings  ${qns.json()['channel']}   ${ChannelVal[0]}
        # Should Be Equal As Strings  ${qns.json()['captureTime']}   ${captureTimeVal[0]}
        Check Questions   ${qns}   ${qnr_id}   ${sheet1}
    END

JD-TC-GetQuestionsByID-2
    [Documentation]  Get questions by id on uploading 2nd file
    ${account_id}=  db.get_acc_id  ${PUSERNAME3}

    # clear_service   ${PUSERNAME3}

    ${wb1}=  readWorkbook  ${xlFile2}
    ${sheet2}  GetCurrentSheet   ${wb1}
    Set Suite Variable   ${sheet2}
    ${colnames1}=  getColumnHeaders  ${sheet2}
    Set Suite Variable   ${colnames1}
    ${servicenames1}   getColumnValuesByName  ${sheet2}  ${colnames[6]}
    Log   ${servicenames1}
    Remove Values From List  ${servicenames1}   ${NONE}
    Log  ${servicenames1}
    ${unique_snames1}=    Remove Duplicates    ${servicenames1}
    Log  ${unique_snames1}
    Set Suite Variable   ${unique_snames1}

    ${qnrids1}   getColumnValuesByName  ${sheet2}  ${colnames[0]}
    Log   ${qnrids1}
    Remove Values From List  ${qnrids1}   ${NONE}
    Log  ${qnrids1}
    ${unique_qnrids1}=    Remove Duplicates    ${qnrids1}
    Log  ${unique_qnrids1}
    Set Suite Variable   ${unique_qnrids1}
    ${qnrid_len1}=  Get Length  ${unique_qnrids1}
    ${qnrid_len}=  Get Length  ${unique_qnrids}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME3}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}

    
    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${s_len}=  Get Length  ${resp.json()}
    @{snames1}=  Create List
    FOR  ${i}  IN RANGE   ${s_len}
        IF  '${resp.json()[${i}]['name']}' in @{unique_snames1} and '${resp.json()[${i}]['serviceType']}' == '${service_type[2]}'
            ${s_id1}=  Set Variable   ${resp.json()[${i}]['id']}
        ELSE IF  '${resp.json()[${i}]['name']}' in @{unique_snames1} and '${resp.json()[${i}]['serviceType']}' == '${service_type[0]}'
            ${d_id1}=  Set Variable   ${resp.json()[${i}]['id']}
        ELSE
            Append To List  ${snames1}  ${resp.json()[${i}]['name']}
        END
    END

    Log  ${snames1}
    ${srv_val1}=    Get Variable Value    ${s_id1}
    ${don_val1}=    Get Variable Value    ${d_id1}
    
    IF  '${srv_val1}'=='${None}' or '${don_val1}'=='${None}'
        ${snames_len1}=  Get Length  ${unique_snames1}
        FOR  ${i}  IN RANGE   ${snames_len1}
            &{dict}=  Create Dictionary   ${colnames[6]}=${unique_snames1[${i}]}
            ${ttype}=  getColumnValueByMultipleVals  ${sheet2}  ${colnames[1]}  &{dict}  
            Log  ${ttype}
            ${u_ttype}=    Remove Duplicates    ${ttype}
            Log  ${u_ttype}
            IF   '${QnrTransactionType[3]}' in @{u_ttype} and '${srv_val1}'=='${None}'
                ${s_id1}=  Create Sample Service  ${unique_snames1[${i}]}  maxBookingsAllowed=10
            ELSE IF  '${QnrTransactionType[0]}' in @{u_ttype} and '${don_val1}'=='${None}'
                ${d_id1}=  Create Sample Donation  ${unique_snames1[${i}]}
            END
        END
    END

    Set Suite Variable   ${s_id1}
    

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

    ${resp}=  Get Questionnaire List   ${account_id}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    ${tot_len}=  Evaluate  ${qnrid_len1}+${qnrid_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${tot_len}   ${len}
    ${qnr_id_list}=  Create List
    FOR  ${i}  IN RANGE   ${len}
        Append To List   ${qnr_id_list}  ${resp.json()[${i}]['id']}
    END

    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${tot_len}   ${len}

    # ${j}=  Evaluate  ${tot_len}+1

    FOR  ${id}  IN   @{qnr_id_list}
        ${qns1}   Get Questionnaire By Id  ${account_id}  ${id}  
        Log  ${qns1.content}
        Should Be Equal As Strings  ${qns1.status_code}  200
        Set Test Variable   ${qnr_id1}  ${qns1.json()['questionnaireId']}
        ${status} 	${value} = 	Run Keyword And Ignore Error  List Should Contain Value  ${unique_qnrids1}  ${qnr_id1}
        Log Many  ${status} 	${value}
        ${x} =  Run Keyword If   '${status}' == 'PASS'  Get Index From List  ${unique_qnrids1}  ${qnr_id1}
        ...   ELSE  Get Index From List  ${unique_qnrids}  ${qnr_id1}
        ${transactionTypeVal1}=  Run Keyword If   '${status}' == 'PASS'   getColumnValueByAnotherVal  ${sheet2}  ${colnames1[1]}  ${colnames1[0]}  ${qnr_id1}
        ...   ELSE  getColumnValueByAnotherVal  ${sheet1}  ${colnames[1]}  ${colnames[0]}  ${qnr_id1}
        Log  ${transactionTypeVal1}
        ${ChannelVal1}=  Run Keyword If   '${status}' == 'PASS'   getColumnValueByAnotherVal  ${sheet2}  ${colnames1[3]}  ${colnames1[0]}  ${qnr_id1}
        ...   ELSE  getColumnValueByAnotherVal  ${sheet1}  ${colnames[3]}  ${colnames[0]}  ${qnr_id1}
        Log  ${ChannelVal1}
        # ${captureTimeVal}=  getColumnValueByAnotherVal  ${sheet2}  ${colnames1[-1]}  ${colnames1[0]}  ${qnr_id1}  
        # Log  ${captureTimeVal}

        Run Keyword If   '${status}' == 'PASS'
        ...    Run Keywords
        ...    Should Be Equal As Strings   ${qns1.json()['account']}  ${account_id}
        ...    AND  Should Be Equal As Strings  ${qns1.json()['transactionType']}   ${transactionTypeVal1[0]}
        ...    AND  Should Be Equal As Strings  ${qns1.json()['channel']}   ${ChannelVal1[0]}
        # ...    AND  Should Be Equal As Strings  ${qns1.json()['captureTime']}   ${captureTimeVal[0]}
        ...    AND  Check Questions   ${qns1}   ${qnr_id1}  ${sheet2}

        ...    ELSE IF   '${status}' == 'FAIL'
        ...    Run Keywords
        ...    Should Be Equal As Strings   ${qns1.json()['account']}  ${account_id}
        ...    AND  Should Be Equal As Strings  ${qns1.json()['transactionType']}   ${transactionTypeVal1[0]}
        ...    AND  Should Be Equal As Strings  ${qns1.json()['channel']}   ${ChannelVal1[0]}
        # ...    AND  Should Be Equal As Strings  ${qns1.json()['captureTime']}   ${captureTimeVal[0]}
        ...    AND  Check Questions   ${qns1}   ${qnr_id1}  ${sheet1}
    END
    

JD-TC-GetQuestionsByID-UH1
    [Documentation]  Get Questions without superadmin login
    ${account_id}=  db.get_acc_id  ${PUSERNAME2}
    
    ${resp}=  Get Questionnaire By Id  ${account_id}  1  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}  ${SA_SESSION_EXPIRED}


JD-TC-GetQuestionsByID-UH2
    [Documentation]  Get Questions by provider login

    ${account_id}=  db.get_acc_id  ${PUSERNAME2}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Questionnaire By Id  ${account_id}  1  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}  ${SA_SESSION_EXPIRED}


JD-TC-GetQuestionsByID-UH3
    [Documentation]  Get Questions by consumer login

    ${account_id}=  get_acc_id  ${PUSERNAME2}

    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Questionnaire By Id  ${account_id}  1  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}  ${SA_SESSION_EXPIRED}


JD-TC-GetQuestionsByID-UH4
    [Documentation]  Get Questions by non existant id

    ${account_id}=  get_acc_id  ${PUSERNAME78}

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Questionnaire By Id  ${account_id}  1397
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}  ${QUESTIONNAIRE_NOT_EXIST}