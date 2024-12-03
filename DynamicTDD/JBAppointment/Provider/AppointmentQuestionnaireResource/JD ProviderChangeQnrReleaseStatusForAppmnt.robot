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
        ...    AND  Run Keyword And Continue On Failure  Should Be Equal As Strings  '${resp.json()['questionnaire']['questionAnswers'][${i}]['answerLine']['answer']['${QnrDatatypes[5]}'][0]['status']}'   '${QnrStatus[1]}'
        
    END


*** Test Cases ***

JD-TC-ProviderChangeQnrReleaseStatusForAppt-1
    [Documentation]  Take a walkin checkin and consumer submit after questionnaire 
    
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

    ${resp}=  Encrypted Provider Login  ${PUSERNAME301}  ${PASSWORD}
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
        IF   '${QnrTransactionType[3]}' in @{u_ttype} and '${srv_val}'=='${None}'
                ${s_id}=  Create Sample Service  ${unique_snames[${i}]}  maxBookingsAllowed=10
            ELSE IF  '${QnrTransactionType[0]}' in @{u_ttype} and '${don_val}'=='${None}'
                ${d_id}=  Create Sample Donation  ${unique_snames[${i}]}
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

    ${resp}=  Encrypted Provider Login  ${PUSERNAME301}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
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

    # clear_appt_schedule   ${PUSERNAME301}

    # ${DAY1}=  db.get_date_by_timezone  ${tz}
    
    # ${resp}=  Create Sample Schedule   ${lid}   ${s_id}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${sch_id}  ${resp.json()}

    # ${resp}=  Get Appointment Schedule ById  ${sch_id}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  id=${sch_id}  apptState=${Qstate[0]}

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
    ELSE
        Set Suite Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10    
    Set Suite Variable   ${DAY2}    
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable   ${list}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    Set Suite Variable   ${sTime1}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    Set Suite Variable   ${delta}
    ${eTime1}=  add_timezone_time  ${tz}  3   50  
    Set Suite Variable   ${eTime1}
   
    # ${SERVICE1}=    generate_unique_service_name  ${service_names}
    # Append To List  ${service_names}  ${SERVICE1}   
    # ${s_id}=  Create Sample Service  ${SERVICE1}      maxBookingsAllowed=20
    # Set Suite Variable  ${s_id}

    # ${SERVICE2}=  generate_service_name
    # ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    # Set Suite Variable   ${min_pre}
    # ${s_id1}=  Create Sample Service  ${SERVICE2}   maxBookingsAllowed=10   isPrePayment=${bool[1]}   minPrePaymentAmount=${min_pre} 
    # Set Suite Variable  ${s_id1}

    # ${SERVICE3}=    generate_unique_service_name  ${service_names}
    # Append To List  ${service_names}  ${SERVICE3}
    # ${s_id2}=  Create Sample Service  ${SERVICE3}   maxBookingsAllowed=10
    # Set Suite Variable  ${s_id2}

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'       
        ${schedule_name}=  FakerLibrary.bs
        ${parallel}=  FakerLibrary.Random Int  min=10  max=20
        ${maxval}=  Convert To Integer   ${delta/2}
        ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
        ${bool1}=  Random Element  ${bool}
        ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${sch_id}  ${resp.json()}
    ELSE
        Set Suite Variable  ${sch_id}  ${resp.json()[0]['id']}
        Set Suite Variable  ${lid}  ${resp.json()[0]['location']['id']}
        Set Suite Variable  ${s_id}  ${resp.json()[0]['services'][0]['id']}
    END

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
      ${id}  Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}' and '${resp.json()[${i}]['captureTime']}' == '${QnrcaptureTime[2]}'   Set Variable  ${resp.json()[${i}]['id']} 
      ${qnrid}   Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}' and '${resp.json()[${i}]['captureTime']}' == '${QnrcaptureTime[2]}'   Set Variable  ${resp.json()[${i}]['questionnaireId']}
      Exit For Loop If   '${id}' != '${None}'
    END
    Set Test Variable   ${id}
    Set Test Variable   ${qnrid}

    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings  ${qns.json()['transactionId']}  ${s_id}

    IF  '${qns.json()['status']}' == '${status[1]}' 
        ${resp1}=   Provider Change Questionnaire Status  ${id}  ${status[0]}  
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings   ${qns.json()['status']}  ${status[0]}
    Set Suite Variable  ${Questionnaireid}  ${qns.json()['questionnaireId']}
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

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME19}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${fname}=  generate_firstname
        ${lname}=  FakerLibrary.last_name
        ${resp1}=  AddCustomer  ${CUSERNAME19}    firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${cid}  ${resp1.json()}
    ELSE
        Set Suite Variable  ${cid}  ${resp.json()[0]['id']}
    END

    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid1}
    Should Be Equal As Strings   ${resp.json()['releasedQnr'][0]['status']}   ${QnrReleaseStatus[2]}

    ${resp}=  Provider Change Questionnaire release Status For Appmt    ${QnrReleaseStatus[1]}   ${apptid1}  ${id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid1}
    Should Be Equal As Strings   ${resp.json()['releasedQnr'][0]['status']}   ${QnrReleaseStatus[1]}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${CUSERNAME19}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login    ${CUSERNAME19}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME19}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  Get Consumer Questionnaire By uuid For Appmnt    ${apptid1}   ${account_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()[0]['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${id}
    
    ${fudata}=  db.fileUploadDT   ${resp.json()[0]}  ${FileAction[0]}  ${Questionnaireid}  ${pdffile}  ${jpgfile}
    Log  ${fudata}

    ${data}=  db.QuestionnaireAnswers   ${resp.json()[0]}   ${cid}   &{fudata}
    Log  ${data}
    ${resp}=  Consumer Validate Questionnaire  ${account_id}  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME19}    ${account_id}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Imageupload.CApptQAnsUpload   ${cookie}  ${account_id}   ${apptid1}   ${data}  ${pdffile}  ${jpgfile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get consumer Appointment By Id   ${account_id}  ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Check Answers   ${resp}  ${data}

JD-TC-ProviderChangeQnrReleaseStatusForAppt-2

    [Documentation]  submit questionnaire for appointment taken from provider side

    # clear_customer   ${PUSERNAME301}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME301}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=   Get Appointment Settings
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # IF  ${resp.json()['enableAppt']}==${bool[0]}   
    #     ${resp}=   Enable Disable Appointment   ${toggle[0]}
    #     Should Be Equal As Strings  ${resp.status_code}  200
    # END 

    # ${resp}=   Get Appointment Settings
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
  
    # ${resp}=    Get Locations
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${lid}   ${resp.json()[0]['id']} 
    # Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}

    # ${resp}=   Get Service
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${s_len}=  Get Length  ${resp.json()}
    # FOR  ${i}  IN RANGE   ${s_len}
    #     ${s_id}=  Run Keyword If   '${resp.json()[${i}]['name']}' in @{unique_snames} and '${resp.json()[${i}]['serviceType']}' != '${ServiceType[2]}'   Set Variable   ${resp.json()[${i}]['id']}
    #     Exit For Loop If   '${s_id}' != '${None}'
    # END
    # Set Suite Variable   ${s_id}  

    # clear_appt_schedule   ${PUSERNAME301}

    # ${DAY1}=  db.get_date_by_timezone  ${tz}
    
    # ${resp}=  Create Sample Schedule   ${lid}   ${s_id}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${sch_id}  ${resp.json()}

    # ${resp}=  Get Appointment Schedule ById  ${sch_id}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  id=${sch_id}  apptState=${Qstate[0]}

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
      ${id}  Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}' and '${resp.json()[${i}]['captureTime']}' == '${QnrcaptureTime[2]}'  Set Variable  ${resp.json()[${i}]['id']} 
      ${qnrid}   Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}' and '${resp.json()[${i}]['captureTime']}' == '${QnrcaptureTime[2]}'  Set Variable  ${resp.json()[${i}]['questionnaireId']}
      Exit For Loop If   '${id}' != '${None}'
    END
    Set Test Variable   ${id}
    Set Test Variable   ${qnrid}

    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings  ${qns.json()['transactionId']}  ${s_id}
    Set Suite Variable  ${Questionnaireid2}  ${qns.json()['questionnaireId']}

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

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME22}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${fname}=  generate_firstname
        ${lname}=  FakerLibrary.last_name
        ${resp1}=  AddCustomer  ${CUSERNAME22}    firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${cid}  ${resp1.json()}
    ELSE
        Set Suite Variable  ${cid}  ${resp.json()[0]['id']}
    END
    # ${resp}=  AddCustomer  ${CUSERNAME22}   
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

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid1}  appmtDate=${DAY1}   appmtTime=${slot1}  
    ...   appointmentEncId=${encId}  apptStatus=${apptStatus[1]}  

    ${qnr_resp}=  Get Questionnaire By uuid For Appmt    ${apptid1}
    Log  ${qnr_resp.content}
    Should Be Equal As Strings  ${qnr_resp.status_code}  200
    Should Be Equal As Strings   ${qnr_resp.json()[0]['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${qnr_resp.json()[0]['id']}   ${id}

    ${fudata}=  db.fileUploadDT   ${qnr_resp.json()[0]}  ${FileAction[0]}  ${Questionnaireid2}  ${pdffile}
    Log  ${fudata}

    ${data}=  db.QuestionnaireAnswers   ${qnr_resp.json()[0]}   ${self}   &{fudata}
    Log  ${data}
    ${resp}=  Provider Validate Questionnaire  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME301}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Imageupload.PApptQAnsUpload   ${cookie}  ${apptid1}   ${data}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Check Answers   ${resp}  ${data}

JD-TC-ProviderChangeQnrReleaseStatusForAppt-3

    [Documentation]  Take a online checkin and consumer submit after questionnaire 

    # clear_customer   ${PUSERNAME301}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME301}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
  
    # ${resp}=    Get Locations
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${lid}   ${resp.json()[0]['id']} 
    # Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}

    # ${resp}=   Get Service
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${s_len}=  Get Length  ${resp.json()}
    # FOR  ${i}  IN RANGE   ${s_len}
    #     ${s_id}=  Run Keyword If   '${resp.json()[${i}]['name']}' in @{unique_snames} and '${resp.json()[${i}]['serviceType']}' != '${ServiceType[2]}'   Set Variable   ${resp.json()[${i}]['id']}
    #     Exit For Loop If   '${s_id}' != '${None}'
    # END
    # Set Suite Variable   ${s_id}  

    # clear_appt_schedule   ${PUSERNAME301}

    # ${DAY1}=  db.get_date_by_timezone  ${tz}

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
    Set Test Variable   ${id}
    Set Test Variable   ${qnrid}


    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings  ${qns.json()['transactionId']}  ${s_id}

    IF  '${qns.json()['status']}' == '${status[1]}' 
        ${resp1}=   Provider Change Questionnaire Status  ${id}  ${status[0]}  
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings   ${qns.json()['status']}  ${status[0]}
    Set Suite Variable  ${Questionnaireid}  ${qns.json()['questionnaireId']}
    Set Suite Variable  ${Questionnaireid3}  ${qns.json()['questionnaireId']}

    # ${resp}=  Create Sample Schedule   ${lid}   ${s_id}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${sch_id}  ${resp.json()}

    # ${resp}=  Get Appointment Schedule ById  ${sch_id}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  id=${sch_id}  apptState=${Qstate[0]}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME23}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${fname}=  generate_firstname
        ${lname}=  FakerLibrary.last_name
        ${resp1}=  AddCustomer  ${CUSERNAME23}    firstName=${fname}   lastName=${lname}
        Log   ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${cid}  ${resp1.json()}
    ELSE
        Set Test Variable  ${cid}  ${resp.json()[0]['id']}
    END

    # ${fname}=  generate_firstname
    # ${lname}=  FakerLibrary.last_name
    # ${resp}=  AddCustomer  ${CUSERNAME22}    firstName=${fname}   lastName=${lname}
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${cid}   ${resp.json()}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${CUSERNAME23}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login    ${CUSERNAME23}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME23}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=    Get All Schedule Slots By Date Location and Service  ${account_id}  ${DAY1}  ${lid}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${no_of_slots}=  Get Length  ${resp.json()[0]['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        IF  ${resp.json()[0]['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Append To List   ${slots}  ${resp.json()[0]['availableSlots'][${i}]['time']}
        END
    END
    ${num_slots}=  Get Length  ${slots}
    ${j1}=  Random Int  max=${num_slots-1}
    Set Test Variable   ${slot1}   ${slots[${j1}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${account_id}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=   Get consumer Appointment By Id   ${account_id}  ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response     ${resp}     uid=${apptid1}   appmtDate=${DAY1}   appmtTime=${slot1}
    ...   apptStatus=${apptStatus[1]}
    Should Be Equal As Strings   ${resp.json()['releasedQnr'][0]['status']}   ${QnrReleaseStatus[2]}


    ${resp}=  Encrypted Provider Login  ${PUSERNAME301}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Provider Change Questionnaire release Status For Appmt    ${QnrReleaseStatus[1]}   ${apptid1}  ${id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${qnr_resp}=  Get Questionnaire By uuid For Appmt    ${apptid1}
    Log  ${qnr_resp.content}
    Should Be Equal As Strings   ${qnr_resp.json()[0]['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${qnr_resp.json()[0]['id']}   ${id}
    
    ${fudata}=  db.fileUploadDT   ${qnr_resp.json()[0]}  ${FileAction[0]}  ${Questionnaireid3}  ${pngfile} 
    Log  ${fudata}

    ${data}=  db.QuestionnaireAnswers   ${qnr_resp.json()[0]}   ${self}   &{fudata}
    Log  ${data}
    Set Suite Variable   ${data}

    ${resp}=  Provider Validate Questionnaire  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME301}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Imageupload.PApptQAnsUpload   ${cookie}  ${apptid1}   ${data}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Check Answers   ${resp}  ${data}

JD-TC-ProviderChangeQnrReleaseStatusForAppt-4

    [Documentation]  consumer submit questionnaire for waitlist taken from provider side

    # clear_customer   ${PUSERNAME301}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME301}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=    Get Locations
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${lid}   ${resp.json()[0]['id']} 
    # Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}

    # ${resp}=   Get Service
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${s_len}=  Get Length  ${resp.json()}
    # FOR  ${i}  IN RANGE   ${s_len}
    #     ${s_id}=  Run Keyword If   '${resp.json()[${i}]['name']}' in @{unique_snames} and '${resp.json()[${i}]['serviceType']}' != '${ServiceType[2]}'   Set Variable   ${resp.json()[${i}]['id']}
    #     Exit For Loop If   '${s_id}' != '${None}'
    # END
    # Set Suite Variable   ${s_id}  

    # clear_queue   ${PUSERNAME301}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
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

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
      ${id1}  Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}' and '${resp.json()[${i}]['captureTime']}' == '${QnrcaptureTime[2]}'  Set Variable  ${resp.json()[${i}]['id']} 
      ${qnrid1}   Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}' and '${resp.json()[${i}]['captureTime']}' == '${QnrcaptureTime[2]}'  Set Variable  ${resp.json()[${i}]['questionnaireId']}
      Exit For Loop If   '${id1}' != '${None}'
    END
    Set Test Variable   ${id1}
    Set Test Variable   ${qnrid1}

    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings  ${qns.json()['transactionId']}  ${s_id}

    IF  '${qns.json()['status']}' == '${status[1]}' 
        ${resp1}=   Provider Change Questionnaire Status  ${id}  ${status[0]}  
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings   ${qns.json()['status']}  ${status[0]}
    Set Suite Variable  ${Questionnaireid}  ${qns.json()['questionnaireId']}
    Set Suite Variable  ${Questionnaireid4}  ${qns.json()['questionnaireId']}
   
    # clear_appt_schedule   ${PUSERNAME301}
    # ${resp}=  Create Sample Schedule   ${lid}   ${s_id}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${sch_id}  ${resp.json()}

    # ${resp}=  Get Appointment Schedule ById  ${sch_id}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  id=${sch_id}  apptState=${Qstate[0]}

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

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME24}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${fname}=  generate_firstname
        ${lname}=  FakerLibrary.last_name
        ${resp1}=  AddCustomer  ${CUSERNAME24}    firstName=${fname}   lastName=${lname}
        Log   ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${cid}  ${resp1.json()}
    ELSE
        Set Test Variable  ${cid}  ${resp.json()[0]['id']}
    END

    # ${resp}=  AddCustomer  ${CUSERNAME19} 
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${cid}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid1}
    Should Be Equal As Strings   ${resp.json()['releasedQnr'][0]['status']}   ${QnrReleaseStatus[2]}

    ${resp}=  Provider Change Questionnaire release Status For Appmt    ${QnrReleaseStatus[1]}   ${apptid1}  ${id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid1}
    Should Be Equal As Strings   ${resp.json()['releasedQnr'][0]['status']}   ${QnrReleaseStatus[1]}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${CUSERNAME24}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login    ${CUSERNAME24}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME24}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    # ${resp}=  Consumer View Questionnaire  ${account_id}  ${s_id}  ${self}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings   ${resp.json()['questionnaireId']}  ${qnrid}
    # Should Be Equal As Strings  ${resp.json()['id']}   ${id}

    ${resp}=  Get Consumer Questionnaire By uuid For Appmnt    ${apptid1}   ${account_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()[0]['questionnaireId']}  ${qnrid1}
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${id1}
    
    ${fudata}=  db.fileUploadDT   ${resp.json()[0]}  ${FileAction[0]}  ${Questionnaireid4}  ${pdffile}
    Log  ${fudata}
    ${data}=  db.QuestionnaireAnswers   ${resp.json()[0]}   ${self}   &{fudata}
    Log  ${data}
    ${resp}=  Consumer Validate Questionnaire  ${account_id}  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME24}    ${account_id}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Imageupload.CApptQAnsUpload   ${cookie}  ${account_id}   ${apptid1}   ${data}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get consumer Appointment By Id   ${account_id}  ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Check Answers   ${resp}  ${data}

JD-TC-ProviderChangeQnrReleaseStatusForAppt-5

    [Documentation]  consumer submit questionnaire for waitlist taken from consumer side

    # clear_customer   ${PUSERNAME301}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME301}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=    Get Locations
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${lid}   ${resp.json()[0]['id']} 
    # Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}

    # ${resp}=   Get Service
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${s_len}=  Get Length  ${resp.json()}
    # FOR  ${i}  IN RANGE   ${s_len}
    #     ${s_id}=  Run Keyword If   '${resp.json()[${i}]['name']}' in @{unique_snames} and '${resp.json()[${i}]['serviceType']}' != '${ServiceType[2]}'   Set Variable   ${resp.json()[${i}]['id']}
    #     Exit For Loop If   '${s_id}' != '${None}'
    # END
    # Set Suite Variable   ${s_id}  

    # clear_queue   ${PUSERNAME301}

    # ${DAY1}=  db.get_date_by_timezone  ${tz}

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
      ${id2}  Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[1]}' and '${resp.json()[${i}]['captureTime']}' == '${QnrcaptureTime[2]}'  Set Variable  ${resp.json()[${i}]['id']} 
      ${qnrid2}   Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[1]}' and '${resp.json()[${i}]['captureTime']}' == '${QnrcaptureTime[2]}'  Set Variable  ${resp.json()[${i}]['questionnaireId']}
      Exit For Loop If   '${id2}' != '${None}'
    END
    Set Suite Variable   ${id2}
    Set Test Variable   ${qnrid2}

    ${qns}   Get Provider Questionnaire By Id   ${id2}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings  ${qns.json()['transactionId']}  ${s_id}

    ${resp1}=  Run Keyword If   '${qns.json()['status']}' == '${status[1]}'  Provider Change Questionnaire Status  ${id2}  ${status[0]}  
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${qns}   Get Provider Questionnaire By Id   ${id2}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings   ${qns.json()['status']}  ${status[0]}
    Set Suite Variable  ${Questionnaireid5}  ${qns.json()['questionnaireId']}

    # clear_appt_schedule   ${PUSERNAME301}
 
    # ${resp}=  Create Sample Schedule   ${lid}   ${s_id}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${sch_id}  ${resp.json()}

    # ${resp}=  Get Appointment Schedule ById  ${sch_id}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  id=${sch_id}  apptState=${Qstate[0]}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME25}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${fname}=  generate_firstname
        ${lname}=  FakerLibrary.last_name
        ${resp1}=  AddCustomer  ${CUSERNAME25}    firstName=${fname}   lastName=${lname}
        Log   ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${cid}  ${resp1.json()}
    ELSE
        Set Test Variable  ${cid}  ${resp.json()[0]['id']}
    END

    # ${fname}=  generate_firstname
    # ${lname}=  FakerLibrary.last_name
    # ${resp}=  AddCustomer  ${CUSERNAME24}    firstName=${fname}   lastName=${lname}
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${cid}   ${resp.json()}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${CUSERNAME25}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login    ${CUSERNAME25}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME25}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=    Get All Schedule Slots By Date Location and Service  ${account_id}  ${DAY1}  ${lid}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${no_of_slots}=  Get Length  ${resp.json()[0]['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        IF  ${resp.json()[0]['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Append To List   ${slots}  ${resp.json()[0]['availableSlots'][${i}]['time']}
        END
    END
    ${num_slots}=  Get Length  ${slots}
    ${j1}=  Random Int  max=${num_slots-1}
    Set Test Variable   ${slot1}   ${slots[${j1}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${account_id}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid2}=  Get From Dictionary  ${resp.json()}  ${fname}
    Set Suite Variable   ${apptid2} 

    ${resp}=   Get consumer Appointment By Id   ${account_id}  ${apptid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME301}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Provider Change Questionnaire release Status For Appmt    ${QnrReleaseStatus[1]}   ${apptid2}  ${id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()['releasedQnr'][0]['status']}   ${QnrReleaseStatus[1]}

    ${resp}=  ProviderLogout 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME25}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Consumer Questionnaire By uuid For Appmnt    ${apptid2}   ${account_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()[0]['questionnaireId']}  ${qnrid2}
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${id2}
    
    ${fudata}=  db.fileUploadDT   ${resp.json()[0]}  ${FileAction[0]}  ${Questionnaireid5}  ${pdffile}
    Log  ${fudata}
    ${data}=  db.QuestionnaireAnswers   ${resp.json()[0]}   ${self}   &{fudata}
    Log  ${data}
    ${resp}=  Consumer Validate Questionnaire  ${account_id}  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME25}    ${account_id}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200


    ${resp}=  Imageupload.CApptQAnsUpload   ${cookie}  ${account_id}   ${apptid2}   ${data}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get consumer Appointment By Id   ${account_id}  ${apptid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Check Answers   ${resp}  ${data}

JD-TC-ProviderChangeQnrReleaseStatusForAppt-UH1

    [Documentation]  change questinare release status by consumer login

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME25}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Provider Change Questionnaire release Status For Appmt    ${QnrReleaseStatus[1]}   ${apptid2}  ${id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401

JD-TC-ProviderChangeQnrReleaseStatusForAppt-UH2

    [Documentation]  change questinare release status without  login

    ${resp}=  Provider Change Questionnaire release Status For Appmt    ${QnrReleaseStatus[1]}   ${apptid2}  ${id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.json()}  ${SESSION_EXPIRED}

JD-TC-ProviderChangeQnrReleaseStatusForAppt-UH3

    [Documentation]   change questinare release status for a canceled appointment

    # clear_customer   ${PUSERNAME301}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME301}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=    Get Locations
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${lid}   ${resp.json()[0]['id']} 
    # Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}

    # ${resp}=   Get Service
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${s_len}=  Get Length  ${resp.json()}
    # FOR  ${i}  IN RANGE   ${s_len}
    #     ${s_id}=  Run Keyword If   '${resp.json()[${i}]['name']}' in @{unique_snames} and '${resp.json()[${i}]['serviceType']}' != '${ServiceType[2]}'   Set Variable   ${resp.json()[${i}]['id']}
    #     Exit For Loop If   '${s_id}' != '${None}'
    # END
    # Set Suite Variable   ${s_id}  

    # clear_appt_schedule   ${PUSERNAME301}

    # ${DAY1}=  db.get_date_by_timezone  ${tz}

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
    Should Be Equal As Strings  ${qns.json()['transactionId']}  ${s_id}

    IF  '${qns.json()['status']}' == '${status[1]}' 
        ${resp1}=   Provider Change Questionnaire Status  ${id}  ${status[0]}  
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings   ${qns.json()['status']}  ${status[0]}
    Set Suite Variable  ${Questionnaireid}  ${qns.json()['questionnaireId']}

    # ${resp}=  Create Sample Schedule   ${lid}   ${s_id}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${sch_id}  ${resp.json()}

    # ${resp}=  Get Appointment Schedule ById  ${sch_id}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  id=${sch_id}  apptState=${Qstate[0]}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME26}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${fname}=  generate_firstname
        ${lname}=  FakerLibrary.last_name
        ${resp1}=  AddCustomer  ${CUSERNAME26}    firstName=${fname}   lastName=${lname}
        Log   ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${cid}  ${resp1.json()}
    ELSE
        Set Test Variable  ${cid}  ${resp.json()[0]['id']}
    END

    # ${fname}=  generate_firstname
    # ${lname}=  FakerLibrary.last_name
    # ${resp}=  AddCustomer  ${CUSERNAME22}    firstName=${fname}   lastName=${lname}
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${CUSERNAME26}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login    ${CUSERNAME26}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME26}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=    Get All Schedule Slots By Date Location and Service  ${account_id}  ${DAY1}  ${lid}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${no_of_slots}=  Get Length  ${resp.json()[0]['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        IF  ${resp.json()[0]['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Append To List   ${slots}  ${resp.json()[0]['availableSlots'][${i}]['time']}
        END
    END
    ${num_slots}=  Get Length  ${slots}
    ${j1}=  Random Int  max=${num_slots-1}
    Set Test Variable   ${slot1}   ${slots[${j1}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${account_id}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${fname}

    ${resp}=   Get consumer Appointment By Id   ${account_id}  ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response     ${resp}     uid=${apptid1}   appmtDate=${DAY1}   appmtTime=${slot1}
    ...   apptStatus=${apptStatus[1]}

    ${resp}=  Cancel Appointment By Consumer  ${apptid1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    Sleep  02s

    ${resp}=   Get consumer Appointment By Id   ${account_id}  ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}    apptStatus=${apptStatus[4]}
    Should Be Equal As Strings   ${resp.json()['releasedQnr'][0]['status']}   ${QnrReleaseStatus[2]}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME301}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Provider Change Questionnaire release Status For Appmt    ${QnrReleaseStatus[1]}   ${apptid1}  ${id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME26}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get consumer Appointment By Id   ${account_id}  ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings   ${resp.json()['releasedQnr'][0]['status']}   ${QnrReleaseStatus[1]}
