
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

*** Variables ***
${xlFile}      ${EXECDIR}/TDD/sampleQnrWOAV.xlsx    # DataSheet
${xlFile1}     ${EXECDIR}/TDD/sampleqnr.xlsx    # DataSheet 1
${xlFile2}     ${EXECDIR}/TDD/qnr.xlsx    # DataSheet 2
${jpgfile}     /ebs/TDD/uploadimage.jpg
${pngfile}     /ebs/TDD/upload.png
${pdffile}     /ebs/TDD/sample.pdf
${mp4file}   /ebs/TDD/MP4file.mp4
${avifile}   /ebs/TDD/AVIfile.avi
${mp3file}   /ebs/TDD/MP3file.mp3
${self}      0
@{service_names}
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


Compare Lists Without Order
    [Arguments]    ${list1}  ${list2}
    ${list1_copy}   Copy List  ${list1}
    ${list2_copy}   Copy List  ${list2}
    Sort List  ${list1_copy}
    Sort List  ${list2_copy}

    IF    ${list1_copy} == ${list2_copy}
        ${val}=    Set Variable    ${bool[1]}
    ELSE
        ${val}=    Set Variable    ${bool[0]}
    END

    RETURN    ${val}



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
        IF  '${FieldDTVal${i}}' == '${QnrDatatypes[1]}'
            ${lv}=  Strip and split string    ${labelValuesVal[0].strip()}  ,
        ELSE IF  '${FieldDTVal${i}}' == '${QnrDatatypes[2]}'
            ${lv}=  Strip and split string    ${labelValuesVal[0]}  ,
        ELSE IF  '${FieldDTVal${i}}' == '${QnrDatatypes[0]}'
            ${lv}=  Strip and split string    ${labelValuesVal[0]}  ,
        ELSE
            ${lv}=  Set Variable    ${labelValuesVal[0]}
        END
        ${type}=    Evaluate     type($lv).__name__
        IF  '${type}' == 'list' and '${FieldDTVal${i}}' == '${QnrDatatypes[0]}'
            Set Test Variable  ${labelValuesVal${i}}   ${lv[0]}
        ELSE
            Set Test Variable  ${labelValuesVal${i}}   ${lv}
        END

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
        IF  '${type}' == 'bool'
            ${stripped_val}=  Set Variable    ${billableVal[0]}
        ELSE
            ${stripped_val}=  Strip String  ${billableVal[0]}
        END
        Set Test Variable  ${billableVal${i}}  ${stripped_val}
        # Set Test Variable  ${billableVal${i}}  ${billableVal[0]}

        ${minVal}   getColumnValueByMultipleVals  ${sheet}  ${colnames[19]}  &{a}
        Log  ${minVal}
        IF  '${FieldDTVal${i}}' == '${QnrDatatypes[4]}'
            ${mnv}=  Split String    ${minVal[0]}  ${SPACE}
        ELSE IF  '${FieldDTVal${i}}' == '${QnrDatatypes[5]}'
            ${mnv}=  Split String    ${minVal[0]}  ${SPACE}
        ELSE IF  '${FieldDTVal${i}}' == '${QnrDatatypes[0]}'
            ${mnv}=  Split String    ${minVal[0]}  ${SPACE}
        ELSE IF  '${FieldDTVal${i}}' == '${QnrDatatypes[3]}'
            ${mnv}=  Split String    ${minVal[0]}  ${SPACE}
        ELSE IF  '${FieldDTVal${i}}' == '${QnrDatatypes[1]}'
            ${mnv}=  Convert To Integer    ${minVal[0]}
        ELSE
            ${mnv}=  Set Variable    ${minVal[0]}
        END
        ${type}=    Evaluate     type($mnv).__name__
        IF  '${type}' == 'list'
            Set Test Variable  ${minVal${i}}   ${mnv[0]}
        ELSE
            Set Test Variable  ${minVal${i}}   ${mnv}
        END


        ${maxVal}   getColumnValueByMultipleVals  ${sheet}  ${colnames[20]}  &{a}
        Log  ${maxVal}
        IF  '${FieldDTVal${i}}' == '${QnrDatatypes[4]}'
            ${mxv}=  Split String    ${maxVal[0]}  ${SPACE}
        ELSE IF  '${FieldDTVal${i}}' == '${QnrDatatypes[5]}'
            ${mxv}=  Split String    ${maxVal[0]}  ${SPACE}
        ELSE IF  '${FieldDTVal${i}}' == '${QnrDatatypes[0]}'
            ${mxv}=  Split String    ${maxVal[0]}  ${SPACE}
        ELSE IF  '${FieldDTVal${i}}' == '${QnrDatatypes[3]}'
            ${mxv}=  Split String    ${maxVal[0]}  ${SPACE}
        ELSE IF  '${FieldDTVal${i}}' == '${QnrDatatypes[1]}'
            ${mxv}=  Convert To Integer    ${maxVal[0]}
        ELSE
            ${mxv}=  Set Variable    ${maxVal[0]}
        END
        ${type}=    Evaluate     type($mxv).__name__
        IF  '${type}' == 'list'
            Set Test Variable  ${maxVal${i}}   ${mxv[0]}
        ELSE
            Set Test Variable  ${maxVal${i}}   ${mxv}
        END

        ${filetypeVal}   getColumnValueByMultipleVals  ${sheet}  ${colnames[16]}  &{a}
        Log  ${filetypeVal}
        IF  '${FieldDTVal${i}}' == '${QnrDatatypes[5]}'
            ${ftv}=  Strip and split string    ${filetypeVal[0]}  ,
        ELSE
            ${ftv}=  Set Variable    ${filetypeVal[0]}
        END
        Set Test Variable  ${filetypeVal${i}}   ${ftv}

        ${alloweddocVal}   getColumnValueByMultipleVals  ${sheet}  ${colnames[17]}  &{a}
        Log  ${alloweddocVal}
        IF    '${FieldDTVal${i}}' == '${QnrDatatypes[5]}'
            ${adv}=    Strip and split string    ${alloweddocVal[0]}  ,
        ELSE
            ${adv}=    Set Variable    ${alloweddocVal[0]}
        END
        Set Test Variable    ${alloweddocVal${i}}    ${adv}

        
    END

    FOR  ${i}  IN RANGE   ${len}
        ${x} =  Get Index From List  ${LabelVal}  ${resp.json()[0]['labels'][${i}]['question']['label']}
        Should Be Equal As Strings   ${resp.json()[0]['labels'][${i}]['question']['label']}  ${LabelVal[${x}]}
        Should Be Equal As Strings   ${resp.json()[0]['labels'][${i}]['question']['labelName']}  ${labelNameVal${x}}
        Should Be Equal As Strings   ${resp.json()[0]['labels'][${i}]['question']['fieldScope']}   ${ScopeVal${x}}
        Should Be Equal As Strings   ${resp.json()[0]['labels'][${i}]['question']['billable']}   ${billableVal${x}}

        # Run Keyword If  '${resp.json()['labels'][${i}]['question']['fieldDataType']}' != '${QnrDatatypes[5]}'
        ${value2}=    evaluate    False if $labelValuesVal${x} is None else True
        IF    '${resp.json()[0]["labels"][${i}]["question"]["fieldDataType"]}' not in @{if_dt_list} and '${value2}' != 'False'
            Run Keyword And Continue On Failure    Should Be Equal As Strings    ${resp.json()[0]["labels"][${i}]["question"]["labelValues"]}    ${labelValuesVal${x}}
        END
        
        # Run Keyword If  '${resp.json()[0]['labels'][${i}]['question']['fieldDataType']}' == '${QnrDatatypes[1]}'
        # ...    Run Keywords
        # ...    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['labels'][${i}]['question']['${QnrProperty[1]}']['minAnswers']}   ${minAnswersVal${x}}
        # ...    AND  Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['labels'][${i}]['question']['${QnrProperty[1]}']['maxAnswers']}   ${maxAnswersVal${x}}
        
        # ...    ELSE IF  '${resp.json()[0]['labels'][${i}]['question']['fieldDataType']}' == '${QnrDatatypes[5]}'
        # ...    Run Keywords
        # ...    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['labels'][${i}]['question']['${QnrProperty[5]}']['minNoOfFile']}   ${minAnswersVal${x}}
        # ...    AND  Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['labels'][${i}]['question']['${QnrProperty[5]}']['maxNoOfFile']}   ${maxAnswersVal${x}}
        # ...    AND  Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['labels'][${i}]['question']['${QnrProperty[5]}']['minSize']}   ${minVal${x}}
        # ...    AND  Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['labels'][${i}]['question']['${QnrProperty[5]}']['maxSize']}   ${maxVal${x}}
        # ...    AND  Compare Lists Without Order  ${resp.json()[0]['labels'][${i}]['question']['${QnrProperty[5]}']['fileTypes']}   ${filetypeVal${x}}  
        # ...    AND  Compare Lists Without Order  ${resp.json()[0]['labels'][${i}]['question']['${QnrProperty[5]}']['allowedDocuments']}   ${alloweddocVal${x}}  
        
        # ...    ELSE IF  '${resp.json()[0]['labels'][${i}]['question']['fieldDataType']}' == '${QnrDatatypes[4]}'
        # ...    Run Keywords
        # ...    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['labels'][${i}]['question']['${QnrProperty[4]}']['minAnswers']}   ${minAnswersVal${x}}
        # ...    AND  Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['labels'][${i}]['question']['${QnrProperty[4]}']['maxAnswers']}   ${maxAnswersVal${x}}
        # ...    AND  Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['labels'][${i}]['question']['${QnrProperty[4]}']['start']}   ${minVal${x}}
        # ...    AND  Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['labels'][${i}]['question']['${QnrProperty[4]}']['end']}   ${maxVal${x}}

        # ...    ELSE IF  '${resp.json()[0]['labels'][${i}]['question']['fieldDataType']}' == '${QnrDatatypes[0]}'
        # ...    Run Keywords
        # ...    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['labels'][${i}]['question']['${QnrProperty[0]}']['minNoOfLetter']}   ${minVal${x}}
        # ...    AND  Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['labels'][${i}]['question']['${QnrProperty[0]}']['maxNoOfLetter']}   ${maxVal${x}}

        # ...    ELSE IF  '${resp.json()[0]['labels'][${i}]['question']['fieldDataType']}' == '${QnrDatatypes[3]}'
        # ...    Run Keywords
        # ...    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['labels'][${i}]['question']['${QnrProperty[3]}']['startDate']}   ${minVal${x}}
        # ...    AND  Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['labels'][${i}]['question']['${QnrProperty[3]}']['endDate']}   ${maxVal${x}}

        IF    '${resp.json()[0]["labels"][${i}]["question"]["fieldDataType"]}' == '${QnrDatatypes[1]}'
            Run Keyword And Continue On Failure    Should Be Equal As Strings    ${resp.json()[0]["labels"][${i}]["question"]["${QnrProperty[1]}"]["minAnswers"]}    ${minAnswersVal${x}}
            Run Keyword And Continue On Failure    Should Be Equal As Strings    ${resp.json()[0]["labels"][${i}]["question"]["${QnrProperty[1]}"]["maxAnswers"]}    ${maxAnswersVal${x}}
        ELSE IF    '${resp.json()[0]["labels"][${i}]["question"]["fieldDataType"]}' == '${QnrDatatypes[5]}'
            Run Keyword And Continue On Failure    Should Be Equal As Strings    ${resp.json()[0]["labels"][${i}]["question"]["${QnrProperty[5]}"]["minNoOfFile"]}    ${minAnswersVal${x}}
            Run Keyword And Continue On Failure    Should Be Equal As Strings    ${resp.json()[0]["labels"][${i}]["question"]["${QnrProperty[5]}"]["maxNoOfFile"]}    ${maxAnswersVal${x}}
            Run Keyword And Continue On Failure    Should Be Equal As Strings    ${resp.json()[0]["labels"][${i}]["question"]["${QnrProperty[5]}"]["minSize"]}    ${minVal${x}}
            Run Keyword And Continue On Failure    Should Be Equal As Strings    ${resp.json()[0]["labels"][${i}]["question"]["${QnrProperty[5]}"]["maxSize"]}    ${maxVal${x}}
            Compare Lists Without Order    ${resp.json()[0]["labels"][${i}]["question"]["${QnrProperty[5]}"]["fileTypes"]}    ${filetypeVal${x}}
            Compare Lists Without Order    ${resp.json()[0]["labels"][${i}]["question"]["${QnrProperty[5]}"]["allowedDocuments"]}    ${alloweddocVal${x}}
        ELSE IF    '${resp.json()[0]["labels"][${i}]["question"]["fieldDataType"]}' == '${QnrDatatypes[4]}'
            Run Keyword And Continue On Failure    Should Be Equal As Strings    ${resp.json()[0]["labels"][${i}]["question"]["${QnrProperty[4]}"]["minAnswers"]}    ${minAnswersVal${x}}
            Run Keyword And Continue On Failure    Should Be Equal As Strings    ${resp.json()[0]["labels"][${i}]["question"]["${QnrProperty[4]}"]["maxAnswers"]}    ${maxAnswersVal${x}}
            Run Keyword And Continue On Failure    Should Be Equal As Strings    ${resp.json()[0]["labels"][${i}]["question"]["${QnrProperty[4]}"]["start"]}    ${minVal${x}}
            Run Keyword And Continue On Failure    Should Be Equal As Strings    ${resp.json()[0]["labels"][${i}]["question"]["${QnrProperty[4]}"]["end"]}    ${maxVal${x}}
        ELSE IF    '${resp.json()[0]["labels"][${i}]["question"]["fieldDataType"]}' == '${QnrDatatypes[0]}'
            Run Keyword And Continue On Failure    Should Be Equal As Strings    ${resp.json()[0]["labels"][${i}]["question"]["${QnrProperty[0]}"]["minNoOfLetter"]}    ${minVal${x}}
            Run Keyword And Continue On Failure    Should Be Equal As Strings    ${resp.json()[0]["labels"][${i}]["question"]["${QnrProperty[0]}"]["maxNoOfLetter"]}    ${maxVal${x}}
        ELSE IF    '${resp.json()[0]["labels"][${i}]["question"]["fieldDataType"]}' == '${QnrDatatypes[3]}'
            Run Keyword And Continue On Failure    Should Be Equal As Strings    ${resp.json()[0]["labels"][${i}]["question"]["${QnrProperty[3]}"]["startDate"]}    ${minVal${x}}
            Run Keyword And Continue On Failure    Should Be Equal As Strings    ${resp.json()[0]["labels"][${i}]["question"]["${QnrProperty[3]}"]["endDate"]}    ${maxVal${x}}
        END

    END


*** Test Cases ***

JD-TC-GetConsumerQuestionnaireByUuidForAppointment-1

    [Documentation]  Get questionnaire by uuid for walkin appointment
    
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
    Remove Values From List  ${servicenames}   ${NONE}
    Log  ${servicenames}
    ${unique_snames}=    Remove Duplicates    ${servicenames}
    Log  ${unique_snames}
    Set Suite Variable   ${unique_snames}

    ${firstname}  ${lastname}  ${PUSERNAME_A}  ${LoginId}=  Provider Signup 
    Set Suite Variable   ${PUSERNAME_A}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
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
    Log  ${snames}

    ${snames_len}=  Get Length  ${unique_snames}
    FOR  ${i}  IN RANGE   ${snames_len}
        IF  '${unique_snames[${i}]}' not in @{snames}
            &{dict}=  Create Dictionary   ${colnames[6]}=${unique_snames[${i}]}
            ${ttype}=  getColumnValueByMultipleVals  ${sheet1}  ${colnames[1]}  &{dict}  
            Log  ${ttype}
            ${u_ttype}=    Remove Duplicates    ${ttype}
            Log  ${u_ttype}
            IF  '${QnrTransactionType[3]}' in @{u_ttype}
                ${s_id}=    Create Sample Service    ${unique_snames[${i}]}
            ELSE IF   '${QnrTransactionType[0]}' in @{u_ttype}
                ${d_id}=    Create Sample Donation    ${unique_snames[${i}]}
            END
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

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=   Get jaldeeIntegration Settings
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}  

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    # Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]} 

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        Set Suite Variable   ${lid}
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
        Set Suite Variable  ${lid}  ${resp.json()['id']}
    ELSE
        Set Suite Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # ${resp}=    Get Locations
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${lid}   ${resp.json()[0]['id']} 
    # Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}

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

    # clear_appt_schedule   ${PUSERNAME_A}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    
    ${resp}=  Create Sample Schedule   ${lid}   ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}  apptState=${Qstate[0]}

    ${parallel}=  FakerLibrary.Random Int  min=5  max=10
    ${resp}=  Update Schedule data  ${sch_id}  ${resp.json()}  parallelServing=${parallel}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    FOR    ${i}    IN RANGE    ${len}
        IF    '${resp.json()[${i}]["transactionType"]}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]["channel"]}' == '${QnrChannel[0]}' and '${resp.json()[${i}]["captureTime"]}' == '${QnrcaptureTime[0]}'
            ${id}=    Set Variable    ${resp.json()[${i}]["id"]}
            ${qnrid}=    Set Variable    ${resp.json()[${i}]["questionnaireId"]}
            Exit For Loop If    '${id}' != '${None}'
        END
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

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleId=${sch_id}
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
        END
    END
    ${num_slots}=  Get Length  ${slots}
    ${j1}=  Random Int  max=${num_slots-1}
    Set Test Variable   ${slot1}   ${slots[${j1}]}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME8}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${fname}=  generate_firstname
        ${lname}=  FakerLibrary.last_name
        ${resp1}=  AddCustomer  ${CUSERNAME8}  
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${cid}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${cid}  ${resp.json()[0]['id']}
    END
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid2}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Suite Variable  ${apptid2}  ${apptid2[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid2}
    Should Be Equal As Strings   ${resp.json()['releasedQnr'][0]['status']}   ${QnrReleaseStatus[2]}                    

    ${resp}=  Provider Change Questionnaire release Status For Appmt    ${QnrReleaseStatus[1]}   ${apptid2}  ${id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${CUSERNAME8}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login    ${CUSERNAME8}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME8}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Consumer Questionnaire By uuid For Appmnt   ${apptid2}   ${account_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()[0]['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${id}
    Check Questions   ${resp}   ${qnrid}   ${sheet1}

JD-TC-GetConsumerQuestionnaireByUuidForAppointment-2

    [Documentation]  Get questionnaire for appointment taken from consumer side

    clear_customer   ${PUSERNAME_A}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['onlinePresence']}==${bool[0]}
        ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${EMPTY}  ${EMPTY}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END 

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]} 

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

    # clear_appt_schedule   ${PUSERNAME_A}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    
    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp}=  Create Sample Schedule   ${lid}   ${s_id}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${sch_id}  ${resp.json()}
    ELSE
        Set Test Variable  ${sch_id}  ${resp.json()[0]['id']}
    END

    ${schedule_services}=  Create List
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    FOR  ${service}  IN  @{resp.json()['services']}
        Append To List  ${schedule_services}  ${service['id']}
    END
    IF   ${s_id} not in @{schedule_services}
        ${resp}=  Update Schedule data  ${sch_id}  ${resp.json()[0]}  ${s_id}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    FOR    ${i}    IN RANGE    ${len}
        IF    '${resp.json()[${i}]["transactionType"]}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]["channel"]}' == '${QnrChannel[1]}' and '${resp.json()[${i}]["captureTime"]}' == '${QnrcaptureTime[2]}'
            ${id}=    Set Variable    ${resp.json()[${i}]["id"]}
            ${qnrid}=    Set Variable    ${resp.json()[${i}]["questionnaireId"]}
            Exit For Loop If    '${id}' != '${None}'
        END
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

    # ${resp}=  Consumer Login  ${CUSERNAME11}  ${PASSWORD} 
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200 
    # Set Test Variable  ${fname}   ${resp.json()['firstName']}

    ${CUSERNAME11}  ${token}  Create Sample Customer  ${account_id}  primaryMobileNo=${CUSERNAME11}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME11}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=    Get All Schedule Slots By Date Location and Service  ${account_id}  ${DAY1}  ${lid}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${sch_id}=  Set Variable  ${resp.json()[0]['scheduleId']}
    ${no_of_slots}=  Get Length  ${resp.json()[0]['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        IF  ${resp.json()[0]['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            # Set Test Variable   ${a${i}}  ${resp.json()[0]['availableSlots'][${i}]['time']}
            Append To List   ${slots}  ${resp.json()[0]['availableSlots'][${i}]['time']}
        END
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Test Variable   ${slot1}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Customer Take Appointment   ${account_id}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}    location=${lid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=   Get consumer Appointment By Id   ${account_id}  ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response     ${resp}     uid=${apptid1}   appmtDate=${DAY1}   appmtTime=${slot1}
    ...   apptStatus=${apptStatus[1]}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Provider Change Questionnaire release Status For Appmt    ${QnrReleaseStatus[1]}   ${apptid1}  ${id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Send Otp For Login    ${CUSERNAME11}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login    ${CUSERNAME11}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME11}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    # ${resp}=  Consumer Login  ${CUSERNAME11}  ${PASSWORD} 
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200    
    
    ${resp}=  Get Consumer Questionnaire By uuid For Appmnt   ${apptid1}   ${account_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()[0]['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${id}
    Check Questions   ${resp}   ${qnrid}   ${sheet1}

JD-TC-GetConsumerQuestionnaireByUuidForAppointment-3
    [Documentation]  Get questionnaire for appointment taken from consumer side canceld appmnt

    clear_customer   ${PUSERNAME_A}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['onlinePresence']}==${bool[0]}
        ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${EMPTY}  ${EMPTY}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}  

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END 

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]} 

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

    # clear_appt_schedule   ${PUSERNAME_A}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    
    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp}=  Create Sample Schedule   ${lid}   ${s_id}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${sch_id}  ${resp.json()}
    ELSE
        Set Test Variable  ${sch_id}  ${resp.json()[0]['id']}
    END

    ${schedule_services}=  Create List
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    FOR  ${service}  IN  @{resp.json()['services']}
        Append To List  ${schedule_services}  ${service['id']}
    END
    IF   ${s_id} not in @{schedule_services}
        ${resp}=  Update Schedule data  ${sch_id}  ${resp.json()[0]}  ${s_id}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    FOR    ${i}    IN RANGE    ${len}
        IF    '${resp.json()[${i}]["transactionType"]}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]["channel"]}' == '${QnrChannel[1]}' and '${resp.json()[${i}]["captureTime"]}' == '${QnrcaptureTime[2]}'
            ${id}=    Set Variable    ${resp.json()[${i}]["id"]}
            ${qnrid}=    Set Variable    ${resp.json()[${i}]["questionnaireId"]}
            Exit For Loop If    '${id}' != '${None}'
        END
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

    # ${resp}=  Consumer Login  ${CUSERNAME11}  ${PASSWORD} 
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200 
    # Set Test Variable  ${fname}   ${resp.json()['firstName']}

    ${CUSERNAME11}  ${token}  Create Sample Customer  ${account_id}  primaryMobileNo=${CUSERNAME11}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME11}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=    Get All Schedule Slots By Date Location and Service  ${account_id}  ${DAY1}  ${lid}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${sch_id}=  Set Variable  ${resp.json()[0]['scheduleId']}
    ${no_of_slots}=  Get Length  ${resp.json()[0]['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        IF  ${resp.json()[0]['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            # Set Test Variable   ${a${i}}  ${resp.json()[0]['availableSlots'][${i}]['time']}
            Append To List   ${slots}  ${resp.json()[0]['availableSlots'][${i}]['time']}
        END
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Test Variable   ${slot1}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Customer Take Appointment   ${account_id}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}    location=${lid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=   Get consumer Appointment By Id   ${account_id}  ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response     ${resp}     uid=${apptid1}   appmtDate=${DAY1}   appmtTime=${slot1}
    ...   apptStatus=${apptStatus[1]}

    # ${resp}=  Cancel Appointment By Consumer  ${apptid1}   ${account_id}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Provider Change Questionnaire release Status For Appmt    ${QnrReleaseStatus[1]}   ${apptid1}  ${id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Consumer Login  ${CUSERNAME11}  ${PASSWORD} 
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200    

    ${resp}=    Send Otp For Login    ${CUSERNAME11}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login    ${CUSERNAME11}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME11}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  Cancel Appointment By Consumer  ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Consumer Questionnaire By uuid For Appmnt   ${apptid1}   ${account_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()[0]['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${id}
    Check Questions   ${resp}   ${qnrid}   ${sheet1}


JD-TC-GetConsumerQuestionnaireByUuidForAppointment-UH1
    [Documentation]  Get questionnaire by provider login

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

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

    # clear_appt_schedule   ${PUSERNAME_A}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    
    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp}=  Create Sample Schedule   ${lid}   ${s_id}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${sch_id}  ${resp.json()}
    ELSE
        Set Test Variable  ${sch_id}  ${resp.json()[0]['id']}
    END

    ${schedule_services}=  Create List
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    FOR  ${service}  IN  @{resp.json()['services']}
        Append To List  ${schedule_services}  ${service['id']}
    END
    IF   ${s_id} not in @{schedule_services}
        ${resp}=  Update Schedule data  ${sch_id}  ${resp.json()[0]}  ${s_id}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleId=${sch_id}
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
        END
    END
    ${num_slots}=  Get Length  ${slots}
    ${j1}=  Random Int  max=${num_slots-1}
    Set Test Variable   ${slot1}   ${slots[${j1}]}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME8}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${fname}=  generate_firstname
        ${lname}=  FakerLibrary.last_name
        ${resp1}=  AddCustomer  ${CUSERNAME8}  
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${cid}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${cid}  ${resp.json()[0]['id']}
    END
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid2}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Suite Variable  ${apptid2}  ${apptid2[0]}

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Questionnaire By uuid For Appmnt   ${apptid2}   ${account_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}    200
    # Should Be Equal As Strings  ${resp.status_code}    401
    # Should Be Equal As Strings  ${resp.json()}   ${LOGIN_NO_ACCESS_FOR_URL}

JD-TC-GetConsumerQuestionnaireByUuidForAppointment-UH2
    [Documentation]  Get questionnaire without login

    ${resp}=  Get Consumer Questionnaire By uuid For Appmnt   ${apptid2}   ${account_id}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.json()}  ${SESSION_EXPIRED}
 
JD-TC-GetConsumerQuestionnaireByUuidForAppointment-UH3
    [Documentation]  Get questionnaire by invalid appmnid

    ${resp}=    Send Otp For Login    ${CUSERNAME11}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login    ${CUSERNAME11}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME11}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Consumer Questionnaire By uuid For Appmnt    000   ${account_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}    404
    Should Be Equal As Strings  ${resp.json()}   ${INVALID_WAITLIST}

    