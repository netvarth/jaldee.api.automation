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
Variables         /ebs/TDD/varfiles/hl_musers.py

*** Variables ***
${xlFile}      ${EXECDIR}/TDD/ServiceoptionsQnr.xlsx   # DataSheet
${jpgfile}     /ebs/TDD/uploadimage.jpg
${pngfile}     /ebs/TDD/upload.png
${pdffile}     /ebs/TDD/sample.pdf
${mp4file}   /ebs/TDD/MP4file.mp4
${avifile}   /ebs/TDD/AVIfile.avi
${mp3file}   /ebs/TDD/MP3file.mp3
${self}      0
@{emptylist}
${mp4mime}   video/mp4
${avimime}   video/avi
${mp3mime}   audio/mpeg


*** Keywords ***


Open given Excel file
    [Arguments]    ${xlFile}  ${doc id}
    ${inputfileStatus}    ${msg}    Run Keyword And Ignore Error    OperatingSystem.File Should Exist    ${xlFile}
    Run Keyword If    "${inputfileStatus}"=="PASS"    Log   ${xlFile} Test data file exist    ELSE    Log    Cannot locate the given Excel file.  ERROR
    Open workbook   ${xlFile}   ${doc id}

Check Answers
    [Arguments]  ${resp}  ${data}  
    ${len}=  Get Length  ${resp.json()['serviceOption']['questionAnswers']}
    # ${answer}=  Set Variable  ${data}
    ${data}=  json.loads  ${data}
    Log  ${data}
    ${dttypes}=  Create List  '${QnrDatatypes[0]}'  '${QnrDatatypes[1]}'  '${QnrDatatypes[2]}'  '${QnrDatatypes[3]}'

    FOR  ${i}  IN RANGE   ${len}
   
        Run Keyword And Continue On Failure  Should Be Equal As Strings   '${resp.json()['serviceOption']['questionAnswers'][${i}]['question']['id']}'  '${resp.json()['serviceOption']['questionAnswers'][${i}]['answerLine']['id']}'
        Run Keyword And Continue On Failure  Should Be Equal As Strings   '${resp.json()['serviceOption']['questionAnswers'][${i}]['question']['labelName']}'  '${resp.json()['serviceOption']['questionAnswers'][${i}]['answerLine']['labelName']}'

        
        IF   '${resp.json()['serviceOption']['questionAnswers'][${i}]['question']['fieldDataType']}' in @{dttypes}
            Run Keyword And Continue On Failure  Should Be Equal As Strings  '${resp.json()['serviceOption']['questionAnswers'][${i}]['answerLine']['answer']}'   '${data['answerLine'][${i}]['answer']}'

        ELSE IF   '${resp.json()['serviceOption']['questionAnswers'][${i}]['question']['fieldDataType']}' == '${QnrDatatypes[5]}'
            Run Keyword And Continue On Failure  Should Be Equal As Strings  '${resp.json()['serviceOption']['questionAnswers'][${i}]['answerLine']['answer']['${QnrDatatypes[5]}'][0]['caption']}'   '${data['answerLine'][${i}]['answer']['${QnrDatatypes[5]}'][0]['caption']}'
            Run Keyword And Continue On Failure  Should Be Equal As Strings  '${resp.json()['serviceOption']['questionAnswers'][${i}]['answerLine']['answer']['${QnrDatatypes[5]}'][0]['status']}'   '${QnrStatus[1]}'

        ELSE IF   '${resp.json()['serviceOption']['questionAnswers'][${i}]['question']['fieldDataType']}' == '${QnrDatatypes[8]}'
            ${DGLlen}=  Get Length  ${resp.json()['serviceOption']['questionAnswers'][${i}]['question']['dataGridListProperties']['dataGridListColumns']}
            FOR  ${j}  IN RANGE   ${DGLlen}
                IF   '${resp.json()['serviceOption']['questionAnswers'][${i}]['question']['dataGridListProperties']['dataGridListColumns'][${j}]['dataType']}' in @{dttypes}
                    Run Keyword And Continue On Failure  Should Be Equal As Strings  '${resp.json()['serviceOption']['questionAnswers'][${i}]['answerLine']['answer']['dataGridListProperties']['dataGridListColumns'][${j}]}'   '${data['answerLine'][${i}]['answer']['${QnrDatatypes[8]}'][0]['dataGridListColumn'][${j}]}'

                ELSE IF   '${resp.json()['serviceOption']['questionAnswers'][${i}]['question']['dataGridListProperties']['dataGridListColumns'][${j}]['dataType']}' == '${QnrDatatypes[5]}'
                    Run Keyword And Continue On Failure  Should Be Equal As Strings  '${resp.json()['serviceOption']['questionAnswers'][${i}]['answerLine']['answer']['${QnrDatatypes[8]}'][0]['dataGridListColumn'][${j}]['column']['${QnrDatatypes[5]}'][0]['caption']}'   '${data['answerLine'][${i}]['answer']['${QnrDatatypes[8]}'][0]['dataGridListColumn'][${j}]['column']['${QnrDatatypes[5]}'][0]['caption']}'
                    Run Keyword And Continue On Failure  Should Be Equal As Strings  '${resp.json()['serviceOption']['questionAnswers'][${i}]['answerLine']['answer']['${QnrDatatypes[8]}'][0]['dataGridListColumn'][${j}]['column']['${QnrDatatypes[5]}'][0]['status']}'   '${QnrStatus[0]}'
                END
            END

        END
    END

*** Test Cases ***

JD-TC-ServiceOptionsPaymentForWaitlist-1
    [Documentation]  Submit service option payment
    clear Queue     ${HLMUSERNAME4}

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
    Set Suite Variable   ${servicenames}
    ${unique_snames}=    Remove Duplicates    ${servicenames}
    Log  ${unique_snames}
    Set Suite Variable   ${unique_snames}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME34}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${fname}  ${decrypted_data['firstName']}
    Set Suite Variable  ${lname}  ${decrypted_data['lastName']}
    # Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    # Set Suite Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}

    ${resp}=   Get Account Payment Settings 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Tax Percentage 
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

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

    ${description}=  FakerLibrary.sentence
    Set Suite Variable   ${description}

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
                ${resp}=  Create Service  ${unique_snames[${i}]}  ${description}   2  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  50  500  ${bool[0]}  ${bool[0]}
                Should Be Equal As Strings  ${resp.status_code}  200
                ${s_id}=  Set Variable  ${resp.json()}
            ELSE IF  '${QnrTransactionType[0]}' in @{u_ttype} and '${don_val}'=='${None}'
                ${d_id}=  Create Sample Donation  ${unique_snames[${i}]}
            END
        END
    END

    Set Suite Variable   ${s_id}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${cookie}  ${resp}=  Imageupload.SALogin    ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Imageupload.UploadQuestionnaire   ${cookie}   ${account_id}   ${xlFile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

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

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log         ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200

    ${resp1}=  Run Keyword If   '${qns.json()['status']}' == '${status[1]}'  Superadmin Change Questionnaire Status  ${id}  ${status[0]}  ${account_id}
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${resp}=    SuperAdmin Logout
    Log         ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${qns}   Get Provider Questionnaire By Id   ${id}
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings   ${qns.json()['status']}  ${status[0]}

    # ${resp}=   Get Service
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${s_len}=  Get Length  ${resp.json()}
    # FOR  ${i}  IN RANGE   ${s_len}
    #     ${s_id}=  Run Keyword If   '${resp.json()[${i}]['name']}' in @{unique_snames} and '${resp.json()[${i}]['serviceType']}' != '${service_type[0]}'   Set Variable   ${resp.json()[${i}]['id']}
    #     Exit For Loop If   '${s_id}' != '${None}'
    # END
    # Set Suite Variable   ${s_id}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME4}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME4}  firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${cid1}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${cid1}  ${resp.json()[0]['id']}
    END

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']} 
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}

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
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable      ${bseamount}        ${resp.json()['fullAmt']}

    ${resp}=    Get Service Options By Serviceid and Channel  ${s_id}   ${QnrChannel[1]}
    Log     ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fudata}=  db.fileUploadDT   ${resp.json()}  ${FileAction[0]}  ${Questionnaireid}  ${pdffile} 
    Log  ${fudata}

    ${data}=  db.QuestionnaireAnswers   ${resp.json()}   ${cid1}   &{fudata}
    Log  ${data}
    Set Suite Variable   ${data}
    ${data}=   setPrice  ${resp.json()}  ${data}
    Log  ${data}
    Set Suite Variable   ${data}

    ${cookie}  ${resp}=  Imageupload.spLogin  ${HLMUSERNAME4}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Get Waitlist By Id  ${wid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=  Imageupload.PServiceOptionsUpload   ${cookie}  ${wid}   ${data}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Check Answers   ${resp}  ${data}
    Set Suite Variable  ${s1Price}      ${resp.json()['serviceOptions'][0]['questionAnswers'][0]['answerLine']['answer']['dataGridList'][0]['totalPrice']}
    Set Suite Variable  ${s2Price}      ${resp.json()['serviceOptions'][0]['questionAnswers'][1]['answerLine']['answer']['dataGridList'][0]['totalPrice']}
    ${ActualAmount}=    Evaluate    ${s1Price}+${s2Price}+${bseamount}
    Set Suite Variable  ${FullAmount}   ${resp.json()['fullAmt']}
    Should Be Equal As Strings      ${FullAmount}   ${ActualAmount}

JD-TC-ServiceOptionsPaymentForWaitlist-2
    [Documentation]  service option payment for Waitlist with GST
    clear Queue     ${HLMUSERNAME6}

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
    Set Suite Variable   ${servicenames}
    ${unique_snames}=    Remove Duplicates    ${servicenames}
    Log  ${unique_snames}
    Set Suite Variable   ${unique_snames}

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME6}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${fname}  ${decrypted_data['firstName']}
    Set Suite Variable  ${lname}  ${decrypted_data['lastName']}
    # Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    # Set Suite Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}

    ${GST_num}  ${pan_num}=   Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[2]}  ${GST_num}
    Log    ${resp.json()}   
    ${resp}=  Enable Tax
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Account Payment Settings 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp1}=   Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.content}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${resp}=   Get Tax Percentage 
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${s_len}=  Get Length  ${resp.json()}
    @{snames}=  Create List
    FOR  ${i}  IN RANGE   ${s_len}
        IF  '${resp.json()[${i}]['name']}' in @{unique_snames} and '${resp.json()[${i}]['serviceType']}' == '${service_type[2]}'
            ${s_id2}=  Set Variable   ${resp.json()[${i}]['id']}
        ELSE IF  '${resp.json()[${i}]['name']}' in @{unique_snames} and '${resp.json()[${i}]['serviceType']}' == '${service_type[0]}'
            ${d_id}=  Set Variable   ${resp.json()[${i}]['id']}
        ELSE
            Append To List  ${snames}  ${resp.json()[${i}]['name']}
        END
    END

    ${description}=  FakerLibrary.sentence
    Set Suite Variable   ${description}

    Log  ${snames}
    ${srv_val2}=    Get Variable Value    ${s_id2}
    ${don_val}=    Get Variable Value    ${d_id}
    
    IF  '${srv_val2}'=='${None}' or '${don_val}'=='${None}'
        ${snames_len}=  Get Length  ${unique_snames}
        FOR  ${i}  IN RANGE   ${snames_len}
            &{dict}=  Create Dictionary   ${colnames[6]}=${unique_snames[${i}]}
            ${ttype}=  getColumnValueByMultipleVals  ${sheet1}  ${colnames[1]}  &{dict}  
            Log  ${ttype}
            ${u_ttype}=    Remove Duplicates    ${ttype}
            Log  ${u_ttype}
            IF   '${QnrTransactionType[3]}' in @{u_ttype} and '${srv_val2}'=='${None}'
                ${resp}=  Create Service  ${unique_snames[${i}]}  ${description}   2  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  50  500  ${bool[1]}  ${bool[1]}
                Should Be Equal As Strings  ${resp.status_code}  200
                ${s_id2}=  Set Variable  ${resp.content}
            ELSE IF  '${QnrTransactionType[0]}' in @{u_ttype} and '${don_val}'=='${None}'
                ${d_id}=  Create Sample Donation  ${unique_snames[${i}]}
            END
        END
    END

    Set Suite Variable   ${s_id2}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${cookie}  ${resp}=  Imageupload.SALogin    ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Imageupload.UploadQuestionnaire   ${cookie}   ${account_id}   ${xlFile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME6}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

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

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log         ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200

    ${resp1}=  Run Keyword If   '${qns.json()['status']}' == '${status[1]}'  Superadmin Change Questionnaire Status  ${id}  ${status[0]}  ${account_id}
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${resp}=    SuperAdmin Logout
    Log         ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME6}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${qns}   Get Provider Questionnaire By Id   ${id}
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings   ${qns.json()['status']}  ${status[0]}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${s_len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${s_len}
        ${s_id2}=  Run Keyword If   '${resp.json()[${i}]['name']}' in @{unique_snames} and '${resp.json()[${i}]['serviceType']}' != '${service_type[0]}'   Set Variable   ${resp.json()[${i}]['id']}
        Exit For Loop If   '${s_id2}' != '${None}'
    END
    Set Suite Variable   ${s_id2}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME6}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME6}  firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${cid1}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${cid1}  ${resp.json()[0]['id']}
    END

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']} 
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}

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
    ${resp}=  Create Queue  ${queue1}  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${lid}  ${s_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${q_id}   queueState=${Qstate[0]}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid1}  ${s_id2}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable      ${bseamount}        ${resp.json()['fullAmt']}

    ${resp}=    Get Service Options By Serviceid and Channel  ${s_id2}   ${QnrChannel[1]}
    Log     ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fudata}=  db.fileUploadDT   ${resp.json()}  ${FileAction[0]}  ${Questionnaireid}  ${pdffile} 
    Log  ${fudata}

    ${data}=  db.QuestionnaireAnswers   ${resp.json()}   ${cid1}   &{fudata}
    Log  ${data}
    Set Suite Variable   ${data}
    ${data}=   setPrice  ${resp.json()}  ${data}
    Log  ${data}
    Set Suite Variable   ${data}

    ${cookie}  ${resp}=  Imageupload.spLogin  ${HLMUSERNAME6}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Get Waitlist By Id  ${wid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=  Imageupload.PServiceOptionsUpload   ${cookie}  ${wid}   ${data}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Check Answers   ${resp}  ${data}
    Set Suite Variable  ${s1Price}      ${resp.json()['serviceOptions'][0]['questionAnswers'][0]['answerLine']['answer']['dataGridList'][0]['totalPrice']}
    Set Suite Variable  ${s2Price}      ${resp.json()['serviceOptions'][0]['questionAnswers'][1]['answerLine']['answer']['dataGridList'][0]['totalPrice']}
    ${ActualAmount}=    Evaluate    ${s1Price}+${s2Price}+${bseamount}
    Set Suite Variable  ${FullAmount}   ${resp.json()['fullAmt']}
    Should Be Equal As Strings      ${FullAmount}   ${ActualAmount}

    ${resp}=  Get Bill By UUId  ${wid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-ServiceOptionPaymentForWaitlist-3
    [Documentation]  service option payment for Waitlist with GST And Coupon
    clear Queue     ${HLMUSERNAME11}

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
    Set Suite Variable   ${servicenames}
    ${unique_snames}=    Remove Duplicates    ${servicenames}
    Log  ${unique_snames}
    Set Suite Variable   ${unique_snames}

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME11}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${fname}  ${decrypted_data['firstName']}
    Set Suite Variable  ${lname}  ${decrypted_data['lastName']}
    Set Suite Variable  ${domain}  ${decrypted_data['sector']}
    Set Suite Variable  ${subDomain}  ${decrypted_data['subSector']}
    # Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    # Set Suite Variable  ${lname}   ${resp.json()['lastName']}
    # Set Suite Variable   ${domain}    ${resp.json()['sector']}
    # Set Suite Variable   ${subDomain}    ${resp.json()['subSector']}

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}

    ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[1]}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Active License
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${lic1}  ${resp.json()['accountLicense']['licPkgOrAddonId']}

    ${domains}=  Jaldee Coupon Target Domains   ${domain}    
    ${sub_domains}=  Jaldee Coupon Target SubDomains   ${domain}_${subDomain}  
    ${licenses}=  Jaldee Coupon Target License  ${lic1}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_codeG}=   FakerLibrary.word
    Set Suite Variable    ${cupn_codeG}
    ${cupn_name}=    FakerLibrary.name
    Set Suite Variable   ${cupn_name}
    ${cupn_des}=   FakerLibrary.sentence
    Set Suite Variable     ${cupn_des}
    ${c_des}=   FakerLibrary.sentence
    Set Suite Variable     ${c_des}
    ${p_des}=    FakerLibrary.sentence
    Set Suite Variable     ${p_des}
    clear_jaldeecoupon   ${cupn_codeG}
    Log  ${cupn_codeG} 
    ${list}=  Create List  1  2  3  4  5  6  7
    
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${eTime1}=  add_timezone_time  ${tz}  0  45  


    ${time}=  Create Dictionary  sTime=${sTime1}  eTime=${eTime1}
    ${timeslot}=  Create List  ${time}
    ${terminator}=  Create Dictionary  endDate=${EMPTY}  noOfOccurance=${EMPTY}
    ${targetDate}=  Create Dictionary  startDate=${EMPTY}   timeSlots=${timeslot}  terminator=${terminator}  recurringType=${recurringtype[1]}   repeatIntervals=${list}
    ${targetDate}=  Create List   ${targetDate}
    ${resp}=   Create Jaldee Coupon   ${cupn_codeG}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  100  1000  10  10  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}   ${domains}   ${sub_domains}   ALL  ${licenses}     targetDate=${targetDate}
    LOg   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon   ${cupn_codeG}   ${cupn_des}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${GST_num}  ${pan_num}=   Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[2]}  ${GST_num}
    Log    ${resp.json()}   
    ${resp}=  Enable Tax
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Account Payment Settings 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp1}=   Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.content}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${s_len}=  Get Length  ${resp.json()}
    @{snames}=  Create List
    FOR  ${i}  IN RANGE   ${s_len}
        IF  '${resp.json()[${i}]['name']}' in @{unique_snames} and '${resp.json()[${i}]['serviceType']}' == '${service_type[2]}'
            ${s_id1}=  Set Variable   ${resp.json()[${i}]['id']}
        ELSE IF  '${resp.json()[${i}]['name']}' in @{unique_snames} and '${resp.json()[${i}]['serviceType']}' == '${service_type[0]}'
            ${d_id}=  Set Variable   ${resp.json()[${i}]['id']}
        ELSE
            Append To List  ${snames}  ${resp.json()[${i}]['name']}
        END
    END

    ${description}=  FakerLibrary.sentence
    Set Suite Variable   ${description}

    Log  ${snames}
    ${srv_val1}=    Get Variable Value    ${s_id1}
    ${don_val}=    Get Variable Value    ${d_id}
    
    IF  '${srv_val1}'=='${None}' or '${don_val}'=='${None}'
        ${snames_len}=  Get Length  ${unique_snames}
        FOR  ${i}  IN RANGE   ${snames_len}
            &{dict}=  Create Dictionary   ${colnames[6]}=${unique_snames[${i}]}
            ${ttype}=  getColumnValueByMultipleVals  ${sheet1}  ${colnames[1]}  &{dict}  
            Log  ${ttype}
            ${u_ttype}=    Remove Duplicates    ${ttype}
            Log  ${u_ttype}
            IF   '${QnrTransactionType[3]}' in @{u_ttype} and '${srv_val1}'=='${None}'
                ${resp}=  Create Service  ${unique_snames[${i}]}  ${description}   2  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  50  500  ${bool[1]}  ${bool[1]}
                Should Be Equal As Strings  ${resp.status_code}  200
                ${s_id1}=  Set Variable  ${resp.content}
            ELSE IF  '${QnrTransactionType[0]}' in @{u_ttype} and '${don_val}'=='${None}'
                ${d_id}=  Create Sample Donation  ${unique_snames[${i}]}
            END
        END
    END

    Set Suite Variable   ${s_id1}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${cookie}  ${resp}=  Imageupload.SALogin    ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Imageupload.UploadQuestionnaire   ${cookie}   ${account_id}   ${xlFile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME11}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

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

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log         ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200

    ${resp1}=  Run Keyword If   '${qns.json()['status']}' == '${status[1]}'  Superadmin Change Questionnaire Status  ${id}  ${status[0]}  ${account_id}
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${resp}=    SuperAdmin Logout
    Log         ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME11}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${qns}   Get Provider Questionnaire By Id   ${id}
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings   ${qns.json()['status']}  ${status[0]}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${s_len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${s_len}
        ${s_id1}=  Run Keyword If   '${resp.json()[${i}]['name']}' in @{unique_snames} and '${resp.json()[${i}]['serviceType']}' != '${service_type[0]}'   Set Variable   ${resp.json()[${i}]['id']}
        Exit For Loop If   '${s_id1}' != '${None}'
    END
    Set Suite Variable   ${s_id1}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME8}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME8}  firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${cid1}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${cid1}  ${resp.json()[0]['id']}
    END

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']} 
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}

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
    ${resp}=  Create Queue  ${queue1}  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${lid}  ${s_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${q_id}   queueState=${Qstate[0]}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid1}  ${s_id1}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable      ${bseamount}        ${resp.json()['fullAmt']}

    ${resp}=    Get Service Options By Serviceid and Channel  ${s_id1}   ${QnrChannel[1]}
    Log     ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fudata}=  db.fileUploadDT   ${resp.json()}  ${FileAction[0]}  ${Questionnaireid}  ${pdffile} 
    Log  ${fudata}

    ${data}=  db.QuestionnaireAnswers   ${resp.json()}   ${cid1}   &{fudata}
    Log  ${data}
    Set Suite Variable   ${data}
    ${data}=   setPrice  ${resp.json()}  ${data}
    Log  ${data}
    Set Suite Variable   ${data}

    ${cookie}  ${resp}=  Imageupload.spLogin  ${HLMUSERNAME11}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Get Waitlist By Id  ${wid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=  Imageupload.PServiceOptionsUpload   ${cookie}  ${wid}   ${data}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Check Answers   ${resp}  ${data}
    Set Suite Variable  ${s1Price}      ${resp.json()['serviceOptions'][0]['questionAnswers'][0]['answerLine']['answer']['dataGridList'][0]['totalPrice']}
    Set Suite Variable  ${s2Price}      ${resp.json()['serviceOptions'][0]['questionAnswers'][1]['answerLine']['answer']['dataGridList'][0]['totalPrice']}
    ${ActualAmount}=    Evaluate    ${s1Price}+${s2Price}+${bseamount}
    Set Suite Variable  ${FullAmount}   ${resp.json()['fullAmt']}
    Should Be Equal As Strings      ${FullAmount}   ${ActualAmount}

    ${resp}=  Get Bill By UUId  ${wid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Jaldee Coupons By Coupon_code   ${cupn_codeG}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[0]}

    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_codeG}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_codeG}
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Apply Jaldee Coupon By Provider  ${cupn_codeG}  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${wid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-ServiceOptionsPaymentForWaitlist-4
    [Documentation]  Resubmit service option payment
    clear Queue     ${HLMUSERNAME13}

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
    Set Suite Variable   ${servicenames}
    ${unique_snames}=    Remove Duplicates    ${servicenames}
    Log  ${unique_snames}
    Set Suite Variable   ${unique_snames}

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME13}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${fname}  ${decrypted_data['firstName']}
    Set Suite Variable  ${lname}  ${decrypted_data['lastName']}
    # Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    # Set Suite Variable  ${lname}   ${resp.json()['lastName']}

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
        IF  '${resp.json()[${i}]['name']}' in @{unique_snames} and '${resp.json()[${i}]['serviceType']}' == '${service_type[2]}'
            ${s_id3}=  Set Variable   ${resp.json()[${i}]['id']}
        ELSE IF  '${resp.json()[${i}]['name']}' in @{unique_snames} and '${resp.json()[${i}]['serviceType']}' == '${service_type[0]}'
            ${d_id}=  Set Variable   ${resp.json()[${i}]['id']}
        ELSE
            Append To List  ${snames}  ${resp.json()[${i}]['name']}
        END
    END

    ${description}=  FakerLibrary.sentence
    Set Suite Variable   ${description}

    Log  ${snames}
    ${srv_val3}=    Get Variable Value    ${s_id3}
    ${don_val}=    Get Variable Value    ${d_id}
    
    IF  '${srv_val3}'=='${None}' or '${don_val}'=='${None}'
        ${snames_len}=  Get Length  ${unique_snames}
        FOR  ${i}  IN RANGE   ${snames_len}
            &{dict}=  Create Dictionary   ${colnames[6]}=${unique_snames[${i}]}
            ${ttype}=  getColumnValueByMultipleVals  ${sheet1}  ${colnames[1]}  &{dict}  
            Log  ${ttype}
            ${u_ttype}=    Remove Duplicates    ${ttype}
            Log  ${u_ttype}
            IF   '${QnrTransactionType[3]}' in @{u_ttype} and '${srv_val3}'=='${None}'
                ${resp}=  Create Service  ${unique_snames[${i}]}  ${description}   2  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  50  500  ${bool[0]}  ${bool[1]}
                Should Be Equal As Strings  ${resp.status_code}  200
                ${s_id3}=  Set Variable  ${resp.content}
            ELSE IF  '${QnrTransactionType[0]}' in @{u_ttype} and '${don_val}'=='${None}'
                ${d_id}=  Create Sample Donation  ${unique_snames[${i}]}
            END
        END
    END

    Set Suite Variable   ${s_id3}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${cookie}  ${resp}=  Imageupload.SALogin    ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Imageupload.UploadQuestionnaire   ${cookie}   ${account_id}   ${xlFile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME13}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

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

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log         ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200

    ${resp1}=  Run Keyword If   '${qns.json()['status']}' == '${status[1]}'  Superadmin Change Questionnaire Status  ${id}  ${status[0]}  ${account_id}
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${resp}=    SuperAdmin Logout
    Log         ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME13}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${qns}   Get Provider Questionnaire By Id   ${id}
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings   ${qns.json()['status']}  ${status[0]}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${s_len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${s_len}
        ${s_id3}=  Run Keyword If   '${resp.json()[${i}]['name']}' in @{unique_snames} and '${resp.json()[${i}]['serviceType']}' != '${service_type[0]}'   Set Variable   ${resp.json()[${i}]['id']}
        Exit For Loop If   '${s_id3}' != '${None}'
    END
    Set Suite Variable   ${s_id3}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME13}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME13}  firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${cid1}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${cid1}  ${resp.json()[0]['id']}
    END

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']} 
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}

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
    ${resp}=  Create Queue  ${queue1}  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${lid}  ${s_id3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${q_id}   queueState=${Qstate[0]}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid1}  ${s_id3}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable      ${bseamount}        ${resp.json()['fullAmt']}

    ${resp1}=    Get Service Options By Serviceid and Channel  ${s_id3}   ${QnrChannel[1]}
    Log     ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200

    ${fudata}=  db.fileUploadDT   ${resp1.json()}  ${FileAction[0]}  ${pdffile} 
    Log  ${fudata}

    ${data}=  db.QuestionnaireAnswers   ${resp1.json()}   ${cid1}   &{fudata}
    Log  ${data}
    Set Suite Variable   ${data}
    ${data}=   setPrice  ${resp1.json()}  ${data}
    Log  ${data}
    Set Suite Variable   ${data}

    ${cookie}  ${resp}=  Imageupload.spLogin  ${HLMUSERNAME13}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Get Waitlist By Id  ${wid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=  Imageupload.PServiceOptionsUpload   ${cookie}  ${wid}   ${data}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Check Answers   ${resp}  ${data}
    Set Suite Variable  ${s1Price}      ${resp.json()['serviceOptions'][0]['questionAnswers'][0]['answerLine']['answer']['dataGridList'][0]['totalPrice']}
    Set Suite Variable  ${s2Price}      ${resp.json()['serviceOptions'][0]['questionAnswers'][1]['answerLine']['answer']['dataGridList'][0]['totalPrice']}
    ${ActualAmount}=    Evaluate    ${s1Price}+${s2Price}+${bseamount}
    Set Suite Variable  ${FullAmount}   ${resp.json()['fullAmt']}
    Should Be Equal As Strings      ${FullAmount}   ${ActualAmount}
    
    ${data1}=  db.QuestionnaireAnswers   ${resp1.json()}   ${cid1}   &{fudata}
    Log  ${data1}
    Set Suite Variable   ${data1}
    ${data1}=   setPrice  ${resp1.json()}  ${data1}
    Log  ${data1}
    Set Suite Variable   ${data1}

    Should Not Be Equal As Strings    ${data1}    ${data}

    ${resp}=  Imageupload.PResubmitServiceOptions   ${cookie}  ${wid}   ${data1}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Check Answers   ${resp}  ${data1}
    Set Suite Variable  ${s1Price1}      ${resp.json()['serviceOptions'][0]['questionAnswers'][0]['answerLine']['answer']['dataGridList'][0]['totalPrice']}
    Set Suite Variable  ${s2Price1}      ${resp.json()['serviceOptions'][0]['questionAnswers'][1]['answerLine']['answer']['dataGridList'][0]['totalPrice']}
    ${ActualAmount1}=    Evaluate    ${s1Price1}+${s2Price1}+${bseamount}
    ${ActualAmount1}=    roundoff    ${ActualAmount1}
    Set Suite Variable  ${FullAmount1}   ${resp.json()['fullAmt']}
    Should Be Equal As Strings      ${FullAmount1}   ${ActualAmount1}

JD-TC-ServiceOptionPaymentForWaitlist-5
    [Documentation]  service option payment for Waitlist with Coupon
    clear Queue     ${HLMUSERNAME18}

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
    Set Suite Variable   ${servicenames}
    ${unique_snames}=    Remove Duplicates    ${servicenames}
    Log  ${unique_snames}
    Set Suite Variable   ${unique_snames}

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME18}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    # Set Suite Variable  ${lname}   ${resp.json()['lastName']}
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${fname}  ${decrypted_data['firstName']}
    Set Suite Variable  ${lname}   ${decrypted_data['lastName']}
    Set Suite Variable   ${domain}    ${resp.json()['sector']}
    Set Suite Variable   ${subDomain}    ${resp.json()['subSector']}

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}

    ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[1]}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Active License
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${lic1}  ${resp.json()['accountLicense']['licPkgOrAddonId']}

    ${domains}=  Jaldee Coupon Target Domains   ${domain}    
    ${sub_domains}=  Jaldee Coupon Target SubDomains   ${domain}_${subDomain}  
    ${licenses}=  Jaldee Coupon Target License  ${lic1}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_codeG}=   FakerLibrary.word
    Set Suite Variable    ${cupn_codeG}
    ${cupn_name}=    FakerLibrary.name
    Set Suite Variable   ${cupn_name}
    ${cupn_des}=   FakerLibrary.sentence
    Set Suite Variable     ${cupn_des}
    ${c_des}=   FakerLibrary.sentence
    Set Suite Variable     ${c_des}
    ${p_des}=    FakerLibrary.sentence
    Set Suite Variable     ${p_des}
    clear_jaldeecoupon   ${cupn_codeG}
    Log  ${cupn_codeG} 
    ${list}=  Create List  1  2  3  4  5  6  7
    
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${eTime1}=  add_timezone_time  ${tz}  0  45  


    ${time}=  Create Dictionary  sTime=${sTime1}  eTime=${eTime1}
    ${timeslot}=  Create List  ${time}
    ${terminator}=  Create Dictionary  endDate=${EMPTY}  noOfOccurance=${EMPTY}
    ${targetDate}=  Create Dictionary  startDate=${EMPTY}   timeSlots=${timeslot}  terminator=${terminator}  recurringType=${recurringtype[1]}   repeatIntervals=${list}
    ${targetDate}=  Create List   ${targetDate}
    ${resp}=   Create Jaldee Coupon   ${cupn_codeG}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  100  1000  10  10  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}   ${domains}   ${sub_domains}   ALL  ${licenses}     targetDate=${targetDate}
    LOg   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon   ${cupn_codeG}   ${cupn_des}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${GST_num}  ${pan_num}=   Generate_gst_number   ${Container_id}
    # ${resp}=  Update Tax Percentage  ${gstpercentage[2]}  ${GST_num}
    # Log    ${resp.json()}   
    # ${resp}=  Enable Tax
    # Should Be Equal As Strings    ${resp.status_code}   200

    # ${resp}=   Get Account Payment Settings 
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}   200
    # ${resp1}=   Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}
    # Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.content}
    # Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${s_len}=  Get Length  ${resp.json()}
    @{snames}=  Create List
    FOR  ${i}  IN RANGE   ${s_len}
        IF  '${resp.json()[${i}]['name']}' in @{unique_snames} and '${resp.json()[${i}]['serviceType']}' == '${service_type[2]}'
            ${s_id5}=  Set Variable   ${resp.json()[${i}]['id']}
        ELSE IF  '${resp.json()[${i}]['name']}' in @{unique_snames} and '${resp.json()[${i}]['serviceType']}' == '${service_type[0]}'
            ${d_id}=  Set Variable   ${resp.json()[${i}]['id']}
        ELSE
            Append To List  ${snames}  ${resp.json()[${i}]['name']}
        END
    END

    ${description}=  FakerLibrary.sentence
    Set Suite Variable   ${description}

    Log  ${snames}
    ${srv_val5}=    Get Variable Value    ${s_id5}
    ${don_val}=    Get Variable Value    ${d_id}
    
    IF  '${srv_val5}'=='${None}' or '${don_val}'=='${None}'
        ${snames_len}=  Get Length  ${unique_snames}
        FOR  ${i}  IN RANGE   ${snames_len}
            &{dict}=  Create Dictionary   ${colnames[6]}=${unique_snames[${i}]}
            ${ttype}=  getColumnValueByMultipleVals  ${sheet1}  ${colnames[1]}  &{dict}  
            Log  ${ttype}
            ${u_ttype}=    Remove Duplicates    ${ttype}
            Log  ${u_ttype}
            IF   '${QnrTransactionType[3]}' in @{u_ttype} and '${srv_val5}'=='${None}'
                ${resp}=  Create Service  ${unique_snames[${i}]}  ${description}   2  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  50  500  ${bool[0]}  ${bool[1]}
                Should Be Equal As Strings  ${resp.status_code}  200
                ${s_id5}=  Set Variable  ${resp.content}
            ELSE IF  '${QnrTransactionType[0]}' in @{u_ttype} and '${don_val}'=='${None}'
                ${d_id}=  Create Sample Donation  ${unique_snames[${i}]}
            END
        END
    END

    Set Suite Variable   ${s_id5}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${cookie}  ${resp}=  Imageupload.SALogin    ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Imageupload.UploadQuestionnaire   ${cookie}   ${account_id}   ${xlFile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME18}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

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

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log         ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200

    ${resp1}=  Run Keyword If   '${qns.json()['status']}' == '${status[1]}'  Superadmin Change Questionnaire Status  ${id}  ${status[0]}  ${account_id}
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${resp}=    SuperAdmin Logout
    Log         ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME18}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${qns}   Get Provider Questionnaire By Id   ${id}
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings   ${qns.json()['status']}  ${status[0]}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${s_len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${s_len}
        ${s_id5}=  Run Keyword If   '${resp.json()[${i}]['name']}' in @{unique_snames} and '${resp.json()[${i}]['serviceType']}' != '${service_type[0]}'   Set Variable   ${resp.json()[${i}]['id']}
        Exit For Loop If   '${s_id5}' != '${None}'
    END
    Set Suite Variable   ${s_id5}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME15}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME15}  firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${cid1}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${cid1}  ${resp.json()[0]['id']}
    END

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']} 
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}

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
    ${resp}=  Create Queue  ${queue1}  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${lid}  ${s_id5}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${q_id}   queueState=${Qstate[0]}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid1}  ${s_id5}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable      ${bseamount}        ${resp.json()['fullAmt']}

    ${resp}=    Get Service Options By Serviceid and Channel  ${s_id5}   ${QnrChannel[1]}
    Log     ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fudata}=  db.fileUploadDT   ${resp.json()}  ${FileAction[0]}  ${Questionnaireid}  ${pdffile} 
    Log  ${fudata}

    ${data}=  db.QuestionnaireAnswers   ${resp.json()}   ${cid1}   &{fudata}
    Log  ${data}
    Set Suite Variable   ${data}
    ${data}=   setPrice  ${resp.json()}  ${data}
    Log  ${data}
    Set Suite Variable   ${data}

    ${cookie}  ${resp}=  Imageupload.spLogin  ${HLMUSERNAME18}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Get Waitlist By Id  ${wid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=  Imageupload.PServiceOptionsUpload   ${cookie}  ${wid}   ${data}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Check Answers   ${resp}  ${data}
    Set Suite Variable  ${s1Price}      ${resp.json()['serviceOptions'][0]['questionAnswers'][0]['answerLine']['answer']['dataGridList'][0]['totalPrice']}
    Set Suite Variable  ${s2Price}      ${resp.json()['serviceOptions'][0]['questionAnswers'][1]['answerLine']['answer']['dataGridList'][0]['totalPrice']}
    ${ActualAmount}=    Evaluate    ${s1Price}+${s2Price}+${bseamount}
    Set Suite Variable  ${FullAmount}   ${resp.json()['fullAmt']}
    Should Be Equal As Strings      ${FullAmount}   ${ActualAmount}

    ${resp}=  Get Bill By UUId  ${wid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Jaldee Coupons By Coupon_code   ${cupn_codeG}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_codeG}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_codeG}
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Apply Jaldee Coupon By Provider  ${cupn_codeG}  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${wid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${wid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
