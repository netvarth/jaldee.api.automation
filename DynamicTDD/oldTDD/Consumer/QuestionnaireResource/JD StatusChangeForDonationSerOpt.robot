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
# Library           /ebs/TDD/Imageupload.py
# Library           /ebs/TDD/db.py
Library           /ebs/TDD/excelfuncs.py
Resource          /ebs/TDD/SuperAdminKeywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

*** Variables ***
${xlFile}      ${EXECDIR}/TDD/ServiceoptionsDonation.xlsx   # DataSheet
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
                    Run Keyword And Continue On Failure  Should Be Equal As Strings  '${resp.json()['serviceOptoin']['questionAnswers'][${i}]['answerLine']['answer']['${QnrDatatypes[8]}'][0]['dataGridListColumn'][${j}]['column']['${QnrDatatypes[5]}'][0]['status']}'   '${QnrStatus[0]}'
                END
            END

        END

*** Test Cases ***

JD-TC-StatusChangeForDonationsInServiceOption-1
    [Documentation]  Status Change for donation

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
    ${resp}=  Encrypted Provider Login  ${PUSERNAME67}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']} 
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}

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

    ${resp}=  Encrypted Provider Login  ${PUSERNAME67}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
      ${id}  Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[0]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[1]}' and '${resp.json()[${i}]['captureTime']}' == '${QnrcaptureTime[2]}'  Set Variable  ${resp.json()[${i}]['id']} 
      ${qnrid}   Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[1]}' and '${resp.json()[${i}]['captureTime']}' == '${QnrcaptureTime[2]}'  Set Variable  ${resp.json()[${i}]['questionnaireId']}
      Exit For Loop If   '${id}' != '${None}'
    END
    Set Suite Variable   ${id}
    Set Suite Variable   ${qnrid}

    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200

    ${resp1}=  Run Keyword If   '${qns.json()['status']}' == '${status[1]}'  Provider Change Questionnaire Status  ${id}  ${status[0]}  
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings  ${qns.json()['transactionId']}  ${d_id}

    ${resp1}=  Run Keyword If   '${qns.json()['status']}' == '${status[1]}'  Provider Change Questionnaire Status  ${id}  ${status[0]}  
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings   ${qns.json()['status']}  ${status[0]}
    Set Suite Variable  ${Questionnaireid}  ${qns.json()['questionnaireId']}

    ${resp}=  Consumer Login  ${CUSERNAME12}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}
    Set Suite Variable  ${con_id}   ${resp.json()['id']}

    ${don_amt}=   Random Int   min=500   max=1000  step=10
    ${don_amt}=  Convert To Number  ${don_amt}  1
    ${resp}=  Donation By Consumer  ${con_id}  ${d_id}  ${lid}  ${don_amt}  ${fname}  ${lname}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${account_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    ${don_id}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${don_id}  ${don_id[0]}

    ${resp}=  Get Consumer Donation By Id  ${don_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}    uid=${don_id}

    ${resp}=    Get Service Options By Donation  ${d_id}     ${account_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${fudata}=  db.fileUploadDT   ${resp.json()}  ${FileAction[0]}  ${Questionnaireid}  ${pdffile}
    Log  ${fudata}

    ${data}=  db.QuestionnaireAnswers   ${resp.json()}   ${self}   &{fudata}
    Log  ${data}
    Set Suite Variable    ${data}
    ${resp}=  Consumer Validate Questionnaire  ${account_id}  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME12}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    Log  ${s_id}

    ${resp}=    Imageupload.CSubmitSerOptForDonation  ${cookie}  ${account_id}    ${don_id}   ${data}  ${pdffile}  ${pdffile}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${files_data}=  Create List
    ${len}=  Get Length  ${resp.json()['urls']}
    FOR  ${i}  IN RANGE   ${len}
        Set Test Variable  ${fileid${i}}  ${resp.json()['urls'][${i}]['uid']}
        Set Test Variable  ${lblname${i}}  ${resp.json()['urls'][${i}]['labelName']}
        Set Test Variable  ${columnId${i}}  ${resp.json()['urls'][${i}]['columnId']}
        ${file_data_dict}   Create Dictionary  uid=${fileid${i}}  labelName=${lblname${i}}  columnId=${columnId${i}}
        Append To List  ${files_data}  ${file_data_dict}
    END

    ${resp}=   Change Status Of Service Option Donation    ${account_id}   ${don_id}  @{files_data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Service Options By Donation  ${d_id}     ${account_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Imageupload.CResubmitSerOptForDonation  ${cookie}  ${account_id}    ${don_id}   ${data}  ${pdffile}  ${pngfile}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${files_data}=  Create List
    ${len}=  Get Length  ${resp.json()['urls']}
    FOR  ${i}  IN RANGE   ${len}
        Set Test Variable  ${fileid${i}}  ${resp.json()['urls'][${i}]['uid']}
        Set Test Variable  ${lblname${i}}  ${resp.json()['urls'][${i}]['labelName']}
        Set Test Variable  ${columnId${i}}  ${resp.json()['urls'][${i}]['columnId']}
        ${file_data_dict}   Create Dictionary  uid=${fileid${i}}  labelName=${lblname${i}}  columnId=${columnId${i}}
        Append To List  ${files_data}  ${file_data_dict}
    END

    ${resp}=   Change Status Of Service Option Donation    ${account_id}   ${don_id}  @{files_data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Service Options By Donation  ${d_id}     ${account_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-StatusChangeForDonationsInServiceOption-UH1
    [Documentation]  Status Change for donation without consumer login

    ${cookie_val}   Generate_random_value  size=32  chars=string.digits
    ${cookie}   Create Dictionary  JSESSIONYNW=${cookie_val}
    
    ${resp}=    Imageupload.CResubmitSerOptForDonation  ${cookie}  ${account_id}    ${don_id}   ${data}  ${pdffile}  ${pngfile}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419

JD-TC-StatusChangeForDonationsInServiceOption-UH2
    [Documentation]  Status Change for donation with invalid account id

     ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME12}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200
    
    ${resp}=    Imageupload.CResubmitSerOptForDonation  ${cookie}  ${account_id}    ${don_id}   ${data}  ${pdffile}  ${pngfile}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${files_data}=  Create List
    ${len}=  Get Length  ${resp.json()['urls']}
    FOR  ${i}  IN RANGE   ${len}
        Set Test Variable  ${fileid${i}}  ${resp.json()['urls'][${i}]['uid']}
        Set Test Variable  ${lblname${i}}  ${resp.json()['urls'][${i}]['labelName']}
        Set Test Variable  ${columnId${i}}  ${resp.json()['urls'][${i}]['columnId']}
        ${file_data_dict}   Create Dictionary  uid=${fileid${i}}  labelName=${lblname${i}}  columnId=${columnId${i}}
        Append To List  ${files_data}  ${file_data_dict}
    END
    
    ${inv_account_id}=  Generate Random String  3  [NUMBERS] 

    ${resp}=   Change Status Of Service Option Donation    ${inv_account_id}   ${don_id}  @{files_data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419


JD-TC-StatusChangeForDonationsInServiceOption-UH3
    [Documentation]  Status Change for donation with invalid donation id

     ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME12}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200
    
    ${resp}=    Imageupload.CResubmitSerOptForDonation  ${cookie}  ${account_id}    ${don_id}   ${data}  ${pdffile}  ${pngfile}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${files_data}=  Create List
    ${len}=  Get Length  ${resp.json()['urls']}
    FOR  ${i}  IN RANGE   ${len}
        Set Test Variable  ${fileid${i}}  ${resp.json()['urls'][${i}]['uid']}
        Set Test Variable  ${lblname${i}}  ${resp.json()['urls'][${i}]['labelName']}
        Set Test Variable  ${columnId${i}}  ${resp.json()['urls'][${i}]['columnId']}
        ${file_data_dict}   Create Dictionary  uid=${fileid${i}}  labelName=${lblname${i}}  columnId=${columnId${i}}
        Append To List  ${files_data}  ${file_data_dict}
    END
    
    ${inv_donation_id}=  Generate Random String  3  [NUMBERS] 

    ${resp}=   Change Status Of Service Option Donation    ${account_id}   ${inv_donation_id}  @{files_data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419