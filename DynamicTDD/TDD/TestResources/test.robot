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
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/hl_providers.py

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
    clear Queue     ${HLPUSERNAME4}

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

    ${ser_durtn}=   Random Int   min=2   max=10
    ${min_pre}=   Random Int   min=40   max=50
    ${min_pre}=  Convert To Number  ${min_pre}  0
    ${service_amount}=   Random Int   min=100   max=500
    ${service_amount}=  Convert To Number  ${service_amount}  0
    ${desc}=   FakerLibrary.sentence

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
                ${resp}=  Create Service  ${unique_snames[${i}]}  ${desc}  ${ser_durtn}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}  ${min_pre}  ${service_amount}  ${bool[1]}  ${bool[0]}  prePaymentType=${advancepaymenttype[1]}
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

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
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

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${qns}   Get Provider Questionnaire By Id   ${id}
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings   ${qns.json()['status']}  ${status[0]}

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
    
    ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid1}  ${resp.json()['id']}

    ${desc}=   FakerLibrary.word
    ${EMPTY_List}=  Create List
    ${resp}=  Waitlist AdvancePayment Details   ${account_id}  ${q_id}  ${DAY1}  ${s_id}  ${desc}  ${bool[0]}  ${EMPTY_List}  ${self}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${service_amount}
    Should Be Equal As Strings  ${resp.json()['amountRequiredNow']}                     ${min_pre}

    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${account_id}  ${q_id}  ${DAY1}  ${s_id}  ${msg}  ${bool[0]}  ${self}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid}  ${wid[0]} 
    
    ${balamount}=  Evaluate  ${service_amount}-${min_pre}
    ${balamount}=  twodigitfloat  ${balamount}  

    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['paymentStatus']}   ${paymentStatus[0]} 
    Should Be Equal As Strings  ${resp.json()['waitlistStatus']}  ${wl_status[3]}

    ${resp}=  Make payment Consumer Mock  ${account_id}  ${min_pre}  ${purpose[0]}  ${cwid}  ${s_id}  ${bool[0]}   ${bool[1]}  ${cid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Bill By UUId  ${cwid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Get Payment Details  account-eq=${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Numbers  ${resp.json()[0]['amount']}        ${min_pre}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}     ${account_id}
    Should Be Equal As Strings  ${resp.json()[0]['paymentMode']}   ${payment_modes[5]}
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}       ${cwid}
    Should Be Equal As Strings  ${resp.json()[0]['paymentPurpose']}   ${purpose[0]}

    ${resp}=  Get Bill By consumer  ${cwid}  ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Numbers  ${resp.json()['netRate']}   ${service_amount} 
    Should Be Equal As Numbers  ${resp.json()['amountDue']}   ${s} 

    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[1]}     waitlistStatus=${wl_status[0]}
    
    ${resp}=  Make payment Consumer Mock  ${account_id}  ${balamount}  ${purpose[1]}  ${cwid}  ${s_id}  ${bool[0]}   ${bool[1]}  ${cid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200