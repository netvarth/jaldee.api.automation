*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
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
    ${len}=  Get Length  ${resp.json()['questionnaire']['questionAnswers']}
    # ${answer}=  Set Variable  ${data}
    ${data}=  json.loads  ${data}
    Log  ${data}
    ${dttypes}=  Create List  '${QnrDatatypes[0]}'  '${QnrDatatypes[1]}'  '${QnrDatatypes[2]}'  '${QnrDatatypes[3]}'

    FOR  ${i}  IN RANGE   ${len}
        
        Run Keyword And Continue On Failure  Should Be Equal As Strings   '${resp.json()['questionnaire']['questionAnswers'][${i}]['question']['id']}'  '${resp.json()['questionnaire']['questionAnswers'][${i}]['answerLine']['id']}'
        Run Keyword And Continue On Failure  Should Be Equal As Strings   '${resp.json()['questionnaire']['questionAnswers'][${i}]['question']['labelName']}'  '${resp.json()['questionnaire']['questionAnswers'][${i}]['answerLine']['labelName']}'

        Run Keyword If  '${resp.json()['questionnaire']['questionAnswers'][${i}]['question']['fieldDataType']}' in @{dttypes}
        ...    Run Keywords
        ...    Run Keyword And Continue On Failure  Should Be Equal As Strings  '${resp.json()['questionnaire']['questionAnswers'][${i}]['answerLine']['answer']}'   '${data['answerLine'][${i}]['answer']}'
        
        
        ...    ELSE IF  '${resp.json()['questionnaire']['questionAnswers'][${i}]['question']['fieldDataType']}' == '${QnrDatatypes[5]}'
        ...    Run Keywords
        ...    Run Keyword And Continue On Failure  Should Be Equal As Strings  '${resp.json()['questionnaire']['questionAnswers'][${i}]['answerLine']['answer']['${QnrDatatypes[5]}'][0]['caption']}'   '${data['answerLine'][${i}]['answer']['${QnrDatatypes[5]}'][0]['caption']}'
        ...    AND  Run Keyword And Continue On Failure  Should Be Equal As Strings  '${resp.json()['questionnaire']['questionAnswers'][${i}]['answerLine']['answer']['${QnrDatatypes[5]}'][0]['status']}'   '${QnrStatus[0]}'
        
    END


*** Test Cases ***

JD-TC-GetQuestionnaireByUuidForAppointment-1

    [Documentation]  Resubmit Questionnaire for Appointment from provider.
    
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

    ${resp}=  Encrypted Provider Login  ${PUSERNAME332}  ${PASSWORD}
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

    ${resp}=  Encrypted Provider Login  ${PUSERNAME332}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']} 
    Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${s_len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${s_len}
        ${s_id}=  Run Keyword If   '${resp.json()[${i}]['name']}' in @{unique_snames} and '${resp.json()[${i}]['serviceType']}' != '${ServiceType[2]}'   Set Variable   ${resp.json()[${i}]['id']}
        Exit For Loop If   '${s_id}' != '${None}'
    END
    Set Suite Variable   ${s_id}  

    # clear_appt_schedule   ${PUSERNAME332}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable    ${DAY1}
    
    ${resp}=  Create Sample Schedule   ${lid}   ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
      ${id}  Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}'  Set Variable  ${resp.json()[${i}]['id']} 
      ${qnrid}   Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}'  Set Variable  ${resp.json()[${i}]['questionnaireId']}
      Exit For Loop If   '${id}' != '${None}'
    END
    Set Suite Variable   ${id}
    Set Suite Variable   ${qnrid}

    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings  ${qns.json()['transactionId']}  ${s_id}

    ${resp1}=  Run Keyword If   '${qns.json()['status']}' == '${status[1]}'  Provider Change Questionnaire Status  ${id}  ${status[0]}  
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings   ${qns.json()['status']}  ${status[0]}
    Set Suite Variable  ${Questionnaireid}  ${qns.json()['questionnaireId']}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
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
        ${resp1}=  AddCustomer  ${CUSERNAME8}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${cid}  ${resp1.json()}
    ELSE
        Set Test Variable  ${cid}  ${resp.json()[0]['id']}
    END
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${qnr_resp}=  Get Questionnaire By uuid For Appmt    ${apptid1}
    Log  ${qnr_resp.content}
    Should Be Equal As Strings  ${qnr_resp.status_code}  200
    Should Be Equal As Strings   ${qnr_resp.json()[0]['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${qnr_resp.json()[0]['id']}   ${id}

JD-TC-GetQuestionnaireByUuidForAppointment-2

    [Documentation]  Resubmit questionnaire for appointment after starting appointment

    # clear_customer   ${PUSERNAME332}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME332}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    # clear_appt_schedule   ${PUSERNAME332}

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

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME9}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME9}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${cid}  ${resp1.json()}
    ELSE
        Set Test Variable  ${cid}  ${resp.json()[0]['id']}
    END

    # ${resp}=  AddCustomer  ${CUSERNAME11}   
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${cid}  ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=  Appointment Action   ${apptStatus[3]}   ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Status   ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${qnr_resp}=  Get Questionnaire By uuid For Appmt    ${apptid1}
    Log  ${qnr_resp.content}
    Should Be Equal As Strings  ${qnr_resp.status_code}  200
   
    ${fudata}=  db.fileUploadDT   ${qnr_resp.json()[0]}  ${FileAction[0]}  ${Questionnaireid}  ${pdffile}
    Log  ${fudata}

    ${data}=  db.QuestionnaireAnswers   ${qnr_resp.json()[0]}   ${cid}   &{fudata}
    Log  ${data}
    ${resp}=  Provider Validate Questionnaire  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME332}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Imageupload.PApptQAnsUpload   ${cookie}  ${apptid1}   ${data}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Check Answers   ${resp}  ${data}
                                            
JD-TC-GetQuestionnaireByUuidForAppointment-3

    [Documentation]  Resubmit questionnaire for appointment after completing appointment

    # clear_customer   ${PUSERNAME332}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME332}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

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

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME10}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME10}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${cid}  ${resp1.json()}
    ELSE
        Set Test Variable  ${cid}  ${resp.json()[0]['id']}
    END

    # ${resp}=  AddCustomer  ${CUSERNAME11}   
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${cid}  ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Get Appointment Status   ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Appointment Action   ${apptStatus[3]}   ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Status   ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=  Appointment Action   ${apptStatus[6]}   ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Status   ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${qnr_resp}=  Get Questionnaire By uuid For Appmt    ${apptid1}
    Log  ${qnr_resp.content}
    Should Be Equal As Strings  ${qnr_resp.status_code}  200
    Should Be Equal As Strings   ${qnr_resp.json()[0]['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${qnr_resp.json()[0]['id']}   ${id}

JD-TC-GetQuestionnaireByUuidForAppointment-4

    [Documentation]  Resubmit questionnaire for appointment after completing appointment

    # clear_customer   ${PUSERNAME332}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME332}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

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

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME11}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME11}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${cid}  ${resp1.json()}
    ELSE
        Set Test Variable  ${cid}  ${resp.json()[0]['id']}
    END

    # ${resp}=  AddCustomer  ${CUSERNAME11}   
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${cid}  ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Suite Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Get Appointment Status   ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Appointment Action   ${apptStatus[3]}   ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Status   ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=  Appointment Action   ${apptStatus[6]}   ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Status   ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${qnr_resp}=  Get Questionnaire By uuid For Appmt    ${apptid1}
    Log  ${qnr_resp.content}
    Should Be Equal As Strings  ${qnr_resp.status_code}  200
    Should Be Equal As Strings   ${qnr_resp.json()[0]['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${qnr_resp.json()[0]['id']}   ${id}

JD-TC-GetQuestionnaireByUuidForAppointment-UH1

    [Documentation]  Get questionnaire by consumer login

    ${resp}=    Send Otp For Login    ${CUSERNAME11}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}
    
    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${CUSERNAME11}   ${OtpPurpose['Authentication']}   JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME11}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Questionnaire By uuid For Appmt    ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}    401
    Should Be Equal As Strings  ${resp.json()}   ${LOGIN_NO_ACCESS_FOR_URL}

JD-TC-GetQuestionnaireByUuidForAppointment-UH2

    [Documentation]  Get questionnaire without login

    ${resp}=  Get Questionnaire By uuid For Appmt    ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.json()}  ${SESSION_EXPIRED}


    