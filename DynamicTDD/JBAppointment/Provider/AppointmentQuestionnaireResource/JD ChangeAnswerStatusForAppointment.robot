*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Run Keywords  Delete All Sessions
Force Tags        Questionnaire
Library           FakerLibrary
Library           /ebs/TDD/CustomKeywords.py
Library           /ebs/TDD/excelfuncs.py
Resource          /ebs/TDD/SuperAdminKeywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py


*** Variables ***
${xlFile}    ${EXECDIR}/TDD/sampleqnr.xlsx    # DataSheet
${self}      0
@{service_names}
@{emptylist}
${mp4file}   /ebs/TDD/MP4file.mp4
${mp3file}   /ebs/TDD/MP3file.mp3
${avifile}   /ebs/TDD/AVIfile.avi
${giffile}   /ebs/TDD/sample.gif
${pdffile}   /ebs/TDD/sample.pdf
${jpgfile}   /ebs/TDD/uploadimage.jpg
${pngfile}   /ebs/TDD/upload.png

*** Keywords ***

Check Answers
    [Arguments]  ${resp}  ${data}  ${status}=${QnrStatus[1]}  ${grid_status}=${QnrStatus[1]}
    ${len}=  Get Length  ${resp.json()['questionnaire']['questionAnswers']}
    ${data}=  json.loads  ${data}
    Log  ${data}
    ${dttypes}=  Create List  '${QnrDatatypes[0]}'  '${QnrDatatypes[1]}'  '${QnrDatatypes[2]}'  '${QnrDatatypes[3]}'

    FOR  ${i}  IN RANGE   ${len}
   
        Run Keyword And Continue On Failure  Should Be Equal As Strings   '${resp.json()['questionnaire']['questionAnswers'][${i}]['question']['id']}'  '${resp.json()['questionnaire']['questionAnswers'][${i}]['answerLine']['id']}'
        Run Keyword And Continue On Failure  Should Be Equal As Strings   '${resp.json()['questionnaire']['questionAnswers'][${i}]['question']['labelName']}'  '${resp.json()['questionnaire']['questionAnswers'][${i}]['answerLine']['labelName']}'

        
        IF   '${resp.json()['questionnaire']['questionAnswers'][${i}]['question']['fieldDataType']}' in @{dttypes}
            Run Keyword And Continue On Failure  Should Be Equal As Strings  '${resp.json()['questionnaire']['questionAnswers'][${i}]['answerLine']['answer']}'   '${data['answerLine'][${i}]['answer']}'

        ELSE IF   '${resp.json()['questionnaire']['questionAnswers'][${i}]['question']['fieldDataType']}' == '${QnrDatatypes[5]}'
            Run Keyword And Continue On Failure  Should Be Equal As Strings  '${resp.json()['questionnaire']['questionAnswers'][${i}]['answerLine']['answer']['${QnrDatatypes[5]}'][0]['caption']}'   '${data['answerLine'][${i}]['answer']['${QnrDatatypes[5]}'][0]['caption']}'
            Run Keyword And Continue On Failure  Should Be Equal As Strings  '${resp.json()['questionnaire']['questionAnswers'][${i}]['answerLine']['answer']['${QnrDatatypes[5]}'][0]['status']}'   '${status}'

        ELSE IF   '${resp.json()['questionnaire']['questionAnswers'][${i}]['question']['fieldDataType']}' == '${QnrDatatypes[7]}'
            ${DGLlen}=  Get Length  ${resp.json()['questionnaire']['questionAnswers'][${i}]['question']['dataGridProperties']['dataGridColumns']}
            FOR  ${j}  IN RANGE   ${DGLlen}
                IF   '${resp.json()['questionnaire']['questionAnswers'][${i}]['question']['dataGridProperties']['dataGridColumns'][${j}]['dataType']}' in @{dttypes}
                    Run Keyword And Continue On Failure  Should Be Equal As Strings  '${resp.json()['questionnaire']['questionAnswers'][${i}]['answerLine']['answer']['dataGridProperties']['dataGridColumns'][${j}]}'   '${data['answerLine'][${i}]['answer']['${QnrDatatypes[7]}'][0]['dataGridColumn'][${j}]}'

                ELSE IF   '${resp.json()['questionnaire']['questionAnswers'][${i}]['question']['dataGridProperties']['dataGridColumns'][${j}]['dataType']}' == '${QnrDatatypes[5]}'
                    Run Keyword And Continue On Failure  Should Be Equal As Strings  '${resp.json()['questionnaire']['questionAnswers'][${i}]['answerLine']['answer']['${QnrDatatypes[7]}'][0]['dataGridColumn'][${j}]['column']['${QnrDatatypes[5]}'][0]['caption']}'   '${data['answerLine'][${i}]['answer']['${QnrDatatypes[7]}'][0]['dataGridColumn'][${j}]['column']['${QnrDatatypes[5]}'][0]['caption']}'
                    Run Keyword And Continue On Failure  Should Be Equal As Strings  '${resp.json()['questionnaire']['questionAnswers'][${i}]['answerLine']['answer']['${QnrDatatypes[7]}'][0]['dataGridColumn'][${j}]['column']['${QnrDatatypes[5]}'][0]['status']}'   '${grid_status}'
                END
            END

        END
    END


*** Test Cases ***

JD-TC-ChangeAnsStatusForAppt-1

    [Documentation]   change Answer status to complete from incomplete for walkin appointment.
    
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

    ${resp}=  Encrypted Provider Login  ${PUSERNAME300}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['timezone']}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${s_len}=  Get Length  ${resp.json()}
    @{snames}=  Create List
    FOR  ${i}  IN RANGE   ${s_len}
        IF  '${resp.json()[${i}]['name']}' in @{unique_snames} and '${resp.json()[${i}]['serviceType']}' == '${ServiceType[1]}'
            ${s_id}=  Set Variable   ${resp.json()[${i}]['id']}
        ELSE IF  '${resp.json()[${i}]['name']}' in @{unique_snames} and '${resp.json()[${i}]['serviceType']}' == '${ServiceType[2]}'
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
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Imageupload.UploadQuestionnaire   ${cookie}   ${account_id}   ${xlFile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME300}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200 

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
    
    # ${resp}=    Get Locations
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${lid}   ${resp.json()[0]['id']}  

    # clear_appt_schedule   ${PUSERNAME300}

    # ${DAY1}=  db.get_date_by_timezone  ${tz}
    
    # ${resp}=  Create Sample Schedule   ${lid}   ${s_id}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${sch_id}  ${resp.json()}

    # ${resp}=  Get Appointment Schedule ById  ${sch_id}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

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
        IF  '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}'
            ${id}   Set Variable  ${resp.json()[${i}]['id']}
            ${qnrid}   Set Variable  ${resp.json()[${i}]['questionnaireId']}
            Exit For Loop If   '${id}' != '${None}'
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
    Set Suite Variable  ${Questionnaireid}  ${qns.json()['questionnaireId']}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME13}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME13}  
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${cid13}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${cid13}  ${resp.json()[0]['id']}
    END
    
    ${apptfor1}=  Create Dictionary  id=${cid13}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid13}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    # ${resp}=  Get Appointment EncodedID   ${apptid1}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${encId}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=  Get Questionnaire By uuid For Appmt    ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${fudata}=  db.fileUploadDT   ${resp.json()[0]}  ${FileAction[0]}  ${Questionnaireid}  ${mp4file}  ${mp3file}
    Log  ${fudata}

    ${data}=  db.QuestionnaireAnswers   ${resp.json()[0]}   ${cid13}   &{fudata}
    Log  ${data}
    ${resp}=  Provider Validate Questionnaire  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME300}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Imageupload.PApptQAnsUpload   ${cookie}  ${apptid1}   ${data}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${files_data}=  Create List
    ${len}=  Get Length  ${resp.json()['urls']}
    FOR  ${i}  IN RANGE   ${len}
        Set Test Variable  ${fileid${i}}  ${resp.json()['urls'][${i}]['uid']}
        Set Test Variable  ${lblname${i}}  ${resp.json()['urls'][${i}]['labelName']}
        IF  'columnId' in ${resp.json()['urls'][${i}]}
            Set Test Variable  ${columnId${i}}  ${resp.json()['urls'][${i}]['columnId']}
            ${file_data_dict}   Create Dictionary  uid=${fileid${i}}  labelName=${lblname${i}}  columnId=${columnId${i}}
        ELSE
            ${file_data_dict}   Create Dictionary  uid=${fileid${i}}  labelName=${lblname${i}}
        END
        Append To List  ${files_data}  ${file_data_dict}
    END

    ${resp}=   Provider Change Answer Status for Appointment  ${apptid1}  @{files_data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Check Answers   ${resp}  ${data}

JD-TC-ChangeAnsStatusForAppt-2

    [Documentation]   change Answer status to complete from incomplete for online appointment.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME300}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=   Get Service
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${s_len}=  Get Length  ${resp.json()}
    # FOR  ${i}  IN RANGE   ${s_len}
    #     IF  '${resp.json()[${i}]['name']}' in @{unique_snames} and '${resp.json()[${i}]['serviceType']}' == '${ServiceType[1]}'
    #         ${s_id}=  Set Variable   ${resp.json()[${i}]['id']}
    #     END
    # END

    # Set Suite Variable   ${s_id}

    # ${resp}=    Get Locations
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${lid}   ${resp.json()[0]['id']}  

    # # clear_appt_schedule   ${PUSERNAME300}

    # ${DAY1}=  db.get_date_by_timezone  ${tz}
    
    # ${resp}=  Create Sample Schedule   ${lid}   ${s_id}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${sch_id}  ${resp.json()}

    # ${resp}=  Get Appointment Schedule ById  ${sch_id}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
        IF  '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[1]}' and '${resp.json()[${i}]['captureTime']}' == '${QnrcaptureTime[0]}'
            ${id}   Set Variable  ${resp.json()[${i}]['id']}
            ${qnrid}   Set Variable  ${resp.json()[${i}]['questionnaireId']}
            Exit For Loop If   '${id}' != '${None}'
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
    Set Suite Variable  ${Questionnaireid}  ${qns.json()['questionnaireId']}
    Set Suite Variable  ${Questionnaireid2}  ${qns.json()['questionnaireId']}

    ${fname}=  generate_firstname
    ${lname}=  FakerLibrary.last_name
  
    ${resp}=  AddCustomer  ${CUSERNAME23}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}
   
    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${CUSERNAME23}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}
  
    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${CUSERNAME23}   ${OtpPurpose['Authentication']}   JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME23}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}

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
    Set Suite Variable   ${apptid1}

    ${resp}=   Get consumer Appointment By Id   ${account_id}  ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response     ${resp}     uid=${apptid1}   appmtDate=${DAY1}   appmtTime=${slot1}
    ...   apptStatus=${apptStatus[1]}

    ${resp}=  Consumer View Questionnaire  ${account_id}  ${s_id}  ${self}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${resp.json()['id']}   ${id}
    
    ${fudata}=  db.fileUploadDT   ${resp.json()}  ${FileAction[0]}  ${Questionnaireid2}  ${mp4file}  ${mp3file}
    Log  ${fudata}

    ${data}=  db.QuestionnaireAnswers   ${resp.json()}   ${self}   &{fudata}
    Log  ${data}
    Set Suite Variable  ${data}
    ${resp}=  Consumer Validate Questionnaire  ${account_id}  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=    Imageupload.ProconLogin    ${CUSERNAME23}    ${account_id}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${ans_resp}=  Imageupload.CApptQAnsUpload   ${cookie}  ${account_id}   ${apptid1}   ${data}  ${pdffile}  ${jpgfile}
    Log  ${ans_resp.content}
    Should Be Equal As Strings  ${ans_resp.status_code}  200

    ${resp}=   Get consumer Appointment By Id   ${account_id}  ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME300}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${files_data}=  Create List
    ${len}=  Get Length  ${ans_resp.json()['urls']}
    FOR  ${i}  IN RANGE   ${len}
        Set Test Variable  ${fileid${i}}  ${ans_resp.json()['urls'][${i}]['uid']}
        Set Test Variable  ${lblname${i}}  ${ans_resp.json()['urls'][${i}]['labelName']}
        IF  'columnId' in ${ans_resp.json()['urls'][${i}]}
            Set Test Variable  ${columnId${i}}  ${ans_resp.json()['urls'][${i}]['columnId']}
            ${file_data_dict}   Create Dictionary  uid=${fileid${i}}  labelName=${lblname${i}}  columnId=${columnId${i}}
        ELSE
            ${file_data_dict}   Create Dictionary  uid=${fileid${i}}  labelName=${lblname${i}}
        END
        Append To List  ${files_data}  ${file_data_dict}
    END

    ${resp}=   Provider Change Answer Status for Appointment  ${apptid1}  @{files_data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Check Answers   ${resp}  ${data}

JD-TC-ChangeAnsStatusForAppt-3

    [Documentation]   change status to complete for already completed uploads.

    # comment  file gives error, audio/video gives 200.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME300}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${files_data}=  Create List
    ${len}=  Get Length  ${resp.json()['questionnaire']['questionAnswers']}
    FOR  ${i}  IN RANGE   ${len}
        ${files_data}=  Create List
        IF  '${resp.json()['questionnaire']['questionAnswers'][${i}]['question']['fieldDataType']}' == '${QnrDatatypes[5]}'
            IF  '${resp.json()['questionnaire']['questionAnswers'][${i}]['answerLine']['answer']['${QnrDatatypes[5]}'][0]['status']}' == '${QnrStatus[1]}'
                Set Test Variable  ${fileid${i}}  ${resp.json()['questionnaire']['questionAnswers'][${i}]['answerLine']['answer']['${QnrDatatypes[5]}'][0]['uid']}
                Set Test Variable  ${lblname${i}}  ${resp.json()['questionnaire']['questionAnswers'][${i}]['answerLine']['labelName']}
                IF  'mimeType' in ${resp.json()['questionnaire']['questionAnswers'][${i}]['answerLine']['answer']['${QnrDatatypes[5]}'][0]}
                    ${file_data_dict}   Create Dictionary  uid=${fileid${i}}  labelName=${lblname${i}}
                    Append To List  ${files_data}  ${file_data_dict}
                    ${resp1}=   Provider Change Answer Status for Appointment  ${apptid1}  @{files_data}
                    Log  ${resp1.content}
                    Should Be Equal As Strings  ${resp1.status_code}  200
                ELSE
                    ${file_data_dict}   Create Dictionary  uid=${fileid${i}}  labelName=${lblname${i}}
                    Append To List  ${files_data}  ${file_data_dict}
                    ${resp1}=   Provider Change Answer Status for Appointment  ${apptid1}  @{files_data}
                    Log  ${resp1.content}
                    Should Be Equal As Strings  ${resp1.status_code}  422
                    Should Be Equal As Strings  ${resp1.json()}    ${UPDATE_ERROR}
                END
            END
        ELSE IF   '${resp.json()['questionnaire']['questionAnswers'][${i}]['question']['fieldDataType']}' == '${QnrDatatypes[7]}'
            ${DGLlen}=  Get Length  ${resp.json()['questionnaire']['questionAnswers'][${i}]['question']['dataGridProperties']['dataGridColumns']}
            FOR  ${j}  IN RANGE   ${DGLlen}
                IF   '${resp.json()['questionnaire']['questionAnswers'][${i}]['question']['dataGridProperties']['dataGridColumns'][${j}]['dataType']}' == '${QnrDatatypes[5]}'
                    IF  '${resp.json()['questionnaire']['questionAnswers'][${i}]['answerLine']['answer']['${QnrDatatypes[7]}'][0]['dataGridColumn'][${j}]['column']['${QnrDatatypes[5]}'][0]['status']}' == '${QnrStatus[0]}' 
                        Set Test Variable  ${fileid${i}}  ${resp.json()['questionnaire']['questionAnswers'][${i}]['answerLine']['answer']['${QnrDatatypes[7]}'][0]['dataGridColumn'][${j}]['column']['${QnrDatatypes[5]}'][0]['uid']}
                        Set Test Variable  ${lblname${i}}  ${resp.json()['questionnaire']['questionAnswers'][${i}]['answerLine']['labelName']}
                        Set Test Variable  ${columnId${i}}  ${resp.json()['questionnaire']['questionAnswers'][${i}]['answerLine']['answer']['${QnrDatatypes[7]}'][0]['dataGridColumn'][${j}]['column']['columnId']
                        IF  'mimeType' in ${resp.json()['questionnaire']['questionAnswers'][${i}]['answerLine']['answer']['${QnrDatatypes[7]}'][0]['dataGridColumn'][${j}]['column']['${QnrDatatypes[5]}'][0]}
                            ${file_data_dict}   Create Dictionary  uid=${fileid${i}}  labelName=${lblname${i}}  columnId=${columnId${i}}
                            Append To List  ${files_data}  ${file_data_dict}
                            ${resp}=   Provider Change Answer Status for Appointment  ${apptid1}  @{files_data}
                            Log  ${resp.content}
                            Should Be Equal As Strings  ${resp.status_code}  200
                        ELSE
                            ${file_data_dict}   Create Dictionary  uid=${fileid${i}}  labelName=${lblname${i}}  columnId=${columnId${i}}
                            Append To List  ${files_data}  ${file_data_dict}
                            ${resp}=   Provider Change Answer Status for Appointment  ${apptid1}  @{files_data}
                            Log  ${resp.content}
                            Should Be Equal As Strings  ${resp.status_code}  422
                            Should Be Equal As Strings  ${resp.json()}    ${UPDATE_ERROR}
                        END
                    END
                END
            END
        END 
    END

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Check Answers   ${resp}  ${data}


JD-TC-ChangeAnsStatusForAppt-4

    [Documentation]   change answer status to complete after resubmitting the answers.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME300}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=   Get Service
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${s_len}=  Get Length  ${resp.json()}
    # FOR  ${i}  IN RANGE   ${s_len}
    #     IF  '${resp.json()[${i}]['name']}' in @{unique_snames} and '${resp.json()[${i}]['serviceType']}' == '${ServiceType[1]}'
    #         ${s_id}=  Set Variable   ${resp.json()[${i}]['id']}
    #     END
    # END

    # Set Suite Variable   ${s_id}

    # ${resp}=    Get Locations
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${lid}   ${resp.json()[0]['id']}  

    # # clear_appt_schedule   ${PUSERNAME300}

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
        IF  '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}' and '${resp.json()[${i}]['captureTime']}' == '${QnrcaptureTime[0]}'
            ${id}   Set Variable  ${resp.json()[${i}]['id']}
            ${qnrid}   Set Variable  ${resp.json()[${i}]['questionnaireId']}
            Exit For Loop If   '${id}' != '${None}'
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
    Set Suite Variable  ${Questionnaireid3}  ${qns.json()['questionnaireId']}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}    scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME13}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME13}  firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${cid13}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${cid13}  ${resp.json()[0]['id']}
    END
    
    ${apptfor1}=  Create Dictionary  id=${cid13}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid13}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid1}

    ${resp}=  Get Questionnaire By uuid For Appmt    ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()[0]['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${id}
    
    ${fudata}=  db.fileUploadDT   ${resp.json()[0]}  ${FileAction[0]}  ${Questionnaireid3}  ${mp4file}  ${mp3file}
    Log  ${fudata}

    ${data}=  db.QuestionnaireAnswers   ${resp.json()[0]}   ${cid13}   &{fudata}
    Log  ${data}
    ${resp}=  Provider Validate Questionnaire  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME300}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Imageupload.PApptQAnsUpload   ${cookie}  ${apptid1}   ${data}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${files_data}=  Create List
    ${len}=  Get Length  ${resp.json()['urls']}
    FOR  ${i}  IN RANGE   ${len}
        Set Test Variable  ${fileid${i}}  ${resp.json()['urls'][${i}]['uid']}
        Set Test Variable  ${lblname${i}}  ${resp.json()['urls'][${i}]['labelName']}
        IF  'columnId' in ${resp.json()['urls'][${i}]}
            Set Test Variable  ${columnId${i}}  ${resp.json()['urls'][${i}]['columnId']}
            ${file_data_dict}   Create Dictionary  uid=${fileid${i}}  labelName=${lblname${i}}  columnId=${columnId${i}}
        ELSE
            ${file_data_dict}   Create Dictionary  uid=${fileid${i}}  labelName=${lblname${i}}
        END
        Append To List  ${files_data}  ${file_data_dict}
    END

    ${resp1}=   Provider Change Answer Status for Appointment  ${apptid1}  @{files_data}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Check Answers   ${resp}  ${data}

    ${ans_resp}=  Imageupload.PApptResubmitQns   ${cookie}   ${apptid1}   ${data}  ${pdffile}
    Log  ${ans_resp.content}
    Should Be Equal As Strings  ${ans_resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Check Answers   ${resp}  ${data}  ${QnrStatus[0]}  ${QnrStatus[0]}

    ${files_data}=  Create List
    ${len}=  Get Length  ${ans_resp.json()['urls']}
    FOR  ${i}  IN RANGE   ${len}
        Set Test Variable  ${fileid${i}}  ${ans_resp.json()['urls'][${i}]['uid']}
        Set Test Variable  ${lblname${i}}  ${ans_resp.json()['urls'][${i}]['labelName']}
        IF  'columnId' in ${ans_resp.json()['urls'][${i}]}
            Set Test Variable  ${columnId${i}}  ${ans_resp.json()['urls'][${i}]['columnId']}
            ${file_data_dict}   Create Dictionary  uid=${fileid${i}}  labelName=${lblname${i}}  columnId=${columnId${i}}
        ELSE
            ${file_data_dict}   Create Dictionary  uid=${fileid${i}}  labelName=${lblname${i}}
        END
        Append To List  ${files_data}  ${file_data_dict}
    END

    ${resp}=   Provider Change Answer Status for Appointment  ${apptid1}  @{files_data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Check Answers   ${resp}  ${data}


JD-TC-ChangeAnsStatusForAppt-5
    [Documentation]   change answer status to complete per upload question.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME300}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=   Get Service
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${s_len}=  Get Length  ${resp.json()}
    # FOR  ${i}  IN RANGE   ${s_len}
    #     IF  '${resp.json()[${i}]['name']}' in @{unique_snames} and '${resp.json()[${i}]['serviceType']}' == '${ServiceType[1]}'
    #         ${s_id}=  Set Variable   ${resp.json()[${i}]['id']}
    #     END
    # END

    # Set Suite Variable   ${s_id}

    # ${resp}=    Get Locations
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${lid}   ${resp.json()[0]['id']}  

    # clear_appt_schedule   ${PUSERNAME300}

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
        IF  '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}' and '${resp.json()[${i}]['captureTime']}' == '${QnrcaptureTime[0]}'
            ${id}   Set Variable  ${resp.json()[${i}]['id']}
            ${qnrid}   Set Variable  ${resp.json()[${i}]['questionnaireId']}
            Exit For Loop If   '${id}' != '${None}'
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
    Set Suite Variable  ${Questionnaireid4}  ${qns.json()['questionnaireId']}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}    scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME13}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME13}  firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${cid13}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${cid13}  ${resp.json()[0]['id']}
    END
    
    ${apptfor1}=  Create Dictionary  id=${cid13}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid13}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid1}

    ${resp}=  Get Questionnaire By uuid For Appmt    ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()[0]['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${id}
    
    ${fudata}=  db.fileUploadDT   ${resp.json()[0]}  ${FileAction[0]}  ${Questionnaireid4}  ${mp4file}  ${mp3file}
    Log  ${fudata}

    ${data}=  db.QuestionnaireAnswers   ${resp.json()[0]}   ${cid13}   &{fudata}
    Log  ${data}
    ${resp}=  Provider Validate Questionnaire  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME300}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Imageupload.PApptQAnsUpload   ${cookie}  ${apptid1}   ${data}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()['urls']}
    FOR  ${i}  IN RANGE   ${len}
        ${files_data}=  Create List
        Set Test Variable  ${fileid${i}}  ${resp.json()['urls'][${i}]['uid']}
        Set Test Variable  ${lblname${i}}  ${resp.json()['urls'][${i}]['labelName']}
        IF  'columnId' in ${resp.json()['urls'][${i}]}
            Set Test Variable  ${columnId${i}}  ${resp.json()['urls'][${i}]['columnId']}
            ${file_data_dict}   Create Dictionary  uid=${fileid${i}}  labelName=${lblname${i}}  columnId=${columnId${i}}
            Append To List  ${files_data}  ${file_data_dict}
            ${resp1}=   Provider Change Answer Status for Appointment  ${apptid1}  @{files_data}
            Log  ${resp1.content}
            Should Be Equal As Strings  ${resp1.status_code}  200
        ELSE
            ${file_data_dict}   Create Dictionary  uid=${fileid${i}}  labelName=${lblname${i}}
            Append To List  ${files_data}  ${file_data_dict}
            ${resp1}=   Provider Change Answer Status for Appointment  ${apptid1}  @{files_data}
            Log  ${resp1.content}
            Should Be Equal As Strings  ${resp1.status_code}  200
        END
    END
    
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Check Answers   ${resp}  ${data}


JD-TC-ChangeAnsStatusForAppt-UH1
    [Documentation]   change answer status to complete without giving details.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME300}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=   Get Service
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${s_len}=  Get Length  ${resp.json()}
    # FOR  ${i}  IN RANGE   ${s_len}
    #     IF  '${resp.json()[${i}]['name']}' in @{unique_snames} and '${resp.json()[${i}]['serviceType']}' == '${ServiceType[1]}'
    #         ${s_id}=  Set Variable   ${resp.json()[${i}]['id']}
    #     END
    # END

    # Set Suite Variable   ${s_id}

    # ${resp}=    Get Locations
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${lid}   ${resp.json()[0]['id']}  

    # clear_appt_schedule   ${PUSERNAME300}

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
        IF  '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}' and '${resp.json()[${i}]['captureTime']}' == '${QnrcaptureTime[0]}'
            ${id}   Set Variable  ${resp.json()[${i}]['id']}
            ${qnrid}   Set Variable  ${resp.json()[${i}]['questionnaireId']}
            Exit For Loop If   '${id}' != '${None}'
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
    Set Suite Variable  ${Questionnaireid5}  ${qns.json()['questionnaireId']}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}    scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME13}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME13}  firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${cid13}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${cid13}  ${resp.json()[0]['id']}
    END
    
    ${apptfor1}=  Create Dictionary  id=${cid13}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid13}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid1}

    ${resp}=  Get Questionnaire By uuid For Appmt    ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()[0]['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${id}
    
    ${fudata}=  db.fileUploadDT   ${resp.json()[0]}  ${FileAction[0]}  ${Questionnaireid5}  ${mp4file}  ${mp3file}
    Log  ${fudata}

    ${data}=  db.QuestionnaireAnswers   ${resp.json()[0]}   ${cid13}   &{fudata}
    Log  ${data}
    ${resp}=  Provider Validate Questionnaire  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME300}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Imageupload.PApptQAnsUpload   ${cookie}  ${apptid1}   ${data}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${files_data}=  Create List
    ${len}=  Get Length  ${resp.json()['urls']}
    FOR  ${i}  IN RANGE   ${len}
        Set Test Variable  ${fileid${i}}  ${resp.json()['urls'][${i}]['uid']}
        Set Test Variable  ${lblname${i}}  ${resp.json()['urls'][${i}]['labelName']}
        IF  'columnId' in ${resp.json()['urls'][${i}]}
            Set Test Variable  ${columnId${i}}  ${resp.json()['urls'][${i}]['columnId']}
            ${file_data_dict}   Create Dictionary  uid=${fileid${i}}  labelName=${lblname${i}}  columnId=${columnId${i}}
        ELSE
            ${file_data_dict}   Create Dictionary  uid=${fileid${i}}  labelName=${lblname${i}}
        END
        Append To List  ${files_data}  ${file_data_dict}
    END

    ${resp}=   Provider Change Answer Status for Appointment  ${apptid1}  ${NONE}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}    ${UPDATE_ERROR}
    
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Check Answers   ${resp}  ${data}  ${QnrStatus[0]}   ${QnrStatus[0]}

JD-TC-ChangeAnsStatusForAppt-UH2
    [Documentation]   change answer status without provider login

    ${resp}=  Encrypted Provider Login  ${PUSERNAME300}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=   Get Service
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${s_len}=  Get Length  ${resp.json()}
    # FOR  ${i}  IN RANGE   ${s_len}
    #     IF  '${resp.json()[${i}]['name']}' in @{unique_snames} and '${resp.json()[${i}]['serviceType']}' == '${ServiceType[1]}'
    #         ${s_id}=  Set Variable   ${resp.json()[${i}]['id']}
    #     END
    # END

    # Set Suite Variable   ${s_id}

    # ${resp}=    Get Locations
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${lid}   ${resp.json()[0]['id']}  

    # clear_appt_schedule   ${PUSERNAME300}

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
        IF  '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}' and '${resp.json()[${i}]['captureTime']}' == '${QnrcaptureTime[0]}'
            ${id}   Set Variable  ${resp.json()[${i}]['id']}
            ${qnrid}   Set Variable  ${resp.json()[${i}]['questionnaireId']}
            Exit For Loop If   '${id}' != '${None}'
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
    Set Suite Variable  ${Questionnaireid6}  ${qns.json()['questionnaireId']}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}    scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME13}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME13}  firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${cid13}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${cid13}  ${resp.json()[0]['id']}
    END
    
    ${apptfor1}=  Create Dictionary  id=${cid13}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid13}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid1}

    ${resp}=  Get Questionnaire By uuid For Appmt    ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()[0]['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${id}
    
    ${fudata}=  db.fileUploadDT   ${resp.json()[0]}  ${FileAction[0]}  ${Questionnaireid6}  ${mp4file}  ${mp3file}
    Log  ${fudata}

    ${data}=  db.QuestionnaireAnswers   ${resp.json()[0]}   ${cid13}   &{fudata}
    Log  ${data}
    ${resp}=  Provider Validate Questionnaire  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME300}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Imageupload.PApptQAnsUpload   ${cookie}  ${apptid1}   ${data}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${files_data}=  Create List
    ${len}=  Get Length  ${resp.json()['urls']}
    FOR  ${i}  IN RANGE   ${len}
        Set Test Variable  ${fileid${i}}  ${resp.json()['urls'][${i}]['uid']}
        Set Test Variable  ${lblname${i}}  ${resp.json()['urls'][${i}]['labelName']}
        IF  'columnId' in ${resp.json()['urls'][${i}]}
            Set Test Variable  ${columnId${i}}  ${resp.json()['urls'][${i}]['columnId']}
            ${file_data_dict}   Create Dictionary  uid=${fileid${i}}  labelName=${lblname${i}}  columnId=${columnId${i}}
        ELSE
            ${file_data_dict}   Create Dictionary  uid=${fileid${i}}  labelName=${lblname${i}}
        END
        Append To List  ${files_data}  ${file_data_dict}
    END

    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Provider Change Answer Status for Appointment  ${apptid1}  @{files_data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.json()}    ${SESSION_EXPIRED}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME300}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Check Answers   ${resp}  ${data}  ${QnrStatus[0]}   ${QnrStatus[0]}


JD-TC-ChangeAnsStatusForAppt-UH3
    [Documentation]   change answer status without file uid

    ${resp}=  Encrypted Provider Login  ${PUSERNAME300}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=   Get Service
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${s_len}=  Get Length  ${resp.json()}
    # FOR  ${i}  IN RANGE   ${s_len}
    #     IF  '${resp.json()[${i}]['name']}' in @{unique_snames} and '${resp.json()[${i}]['serviceType']}' == '${ServiceType[1]}'
    #         ${s_id}=  Set Variable   ${resp.json()[${i}]['id']}
    #     END
    # END

    # Set Suite Variable   ${s_id}

    # ${resp}=    Get Locations
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${lid}   ${resp.json()[0]['id']}  

    # clear_appt_schedule   ${PUSERNAME300}

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
        IF  '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}' and '${resp.json()[${i}]['captureTime']}' == '${QnrcaptureTime[0]}'
            ${id}   Set Variable  ${resp.json()[${i}]['id']}
            ${qnrid}   Set Variable  ${resp.json()[${i}]['questionnaireId']}
            Exit For Loop If   '${id}' != '${None}'
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
    Set Suite Variable  ${Questionnaireid7}  ${qns.json()['questionnaireId']}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}    scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME13}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME13}  firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${cid13}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${cid13}  ${resp.json()[0]['id']}
    END
    
    ${apptfor1}=  Create Dictionary  id=${cid13}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid13}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid1}

    ${resp}=  Get Questionnaire By uuid For Appmt    ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()[0]['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${id}
    
    ${fudata}=  db.fileUploadDT   ${resp.json()[0]}  ${FileAction[0]}  ${Questionnaireid7}  ${mp4file}  ${mp3file}
    Log  ${fudata}

    ${data}=  db.QuestionnaireAnswers   ${resp.json()[0]}   ${cid13}   &{fudata}
    Log  ${data}
    ${resp}=  Provider Validate Questionnaire  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME300}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Imageupload.PApptQAnsUpload   ${cookie}  ${apptid1}   ${data}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${files_data}=  Create List
    ${len}=  Get Length  ${resp.json()['urls']}
    FOR  ${i}  IN RANGE   ${len}
        Set Test Variable  ${fileid${i}}  ${resp.json()['urls'][${i}]['uid']}
        Set Test Variable  ${lblname${i}}  ${resp.json()['urls'][${i}]['labelName']}
        IF  'columnId' in ${resp.json()['urls'][${i}]}
            Set Test Variable  ${columnId${i}}  ${resp.json()['urls'][${i}]['columnId']}
            # ${file_data_dict}   Create Dictionary  uid=${fileid${i}}  labelName=${lblname${i}}  columnId=${columnId${i}}
            ${file_data_dict}   Create Dictionary  uid=${EMPTY}  labelName=${lblname${i}}  columnId=${columnId${i}}
        ELSE
            # ${file_data_dict}   Create Dictionary  uid=${fileid${i}}  labelName=${lblname${i}}
            ${file_data_dict}   Create Dictionary  uid=${EMPTY}  labelName=${lblname${i}}
        END
        Append To List  ${files_data}  ${file_data_dict}
    END

    ${resp}=   Provider Change Answer Status for Appointment  ${apptid1}  @{files_data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}    ${UPDATE_ERROR}
    
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Check Answers   ${resp}  ${data}  ${QnrStatus[0]}   ${QnrStatus[0]}


JD-TC-ChangeAnsStatusForAppt-UH4
    [Documentation]   change answer status without labelname

    ${resp}=  Encrypted Provider Login  ${PUSERNAME300}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=   Get Service
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${s_len}=  Get Length  ${resp.json()}
    # FOR  ${i}  IN RANGE   ${s_len}
    #     IF  '${resp.json()[${i}]['name']}' in @{unique_snames} and '${resp.json()[${i}]['serviceType']}' == '${ServiceType[1]}'
    #         ${s_id}=  Set Variable   ${resp.json()[${i}]['id']}
    #     END
    # END

    # Set Suite Variable   ${s_id}

    # ${resp}=    Get Locations
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${lid}   ${resp.json()[0]['id']}  

    # clear_appt_schedule   ${PUSERNAME300}

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
        IF  '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}' and '${resp.json()[${i}]['captureTime']}' == '${QnrcaptureTime[0]}'
            ${id}   Set Variable  ${resp.json()[${i}]['id']}
            ${qnrid}   Set Variable  ${resp.json()[${i}]['questionnaireId']}
            Exit For Loop If   '${id}' != '${None}'
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
    Set Suite Variable  ${Questionnaireid8}  ${qns.json()['questionnaireId']}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}    scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME13}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME13}  firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${cid13}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${cid13}  ${resp.json()[0]['id']}
    END
    
    ${apptfor1}=  Create Dictionary  id=${cid13}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid13}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid1}

    ${resp}=  Get Questionnaire By uuid For Appmt    ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()[0]['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${id}
    
    ${fudata}=  db.fileUploadDT   ${resp.json()[0]}  ${FileAction[0]}  ${Questionnaireid8}  ${mp4file}  ${mp3file}
    Log  ${fudata}

    ${data}=  db.QuestionnaireAnswers   ${resp.json()[0]}   ${cid13}   &{fudata}
    Log  ${data}
    ${resp}=  Provider Validate Questionnaire  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME300}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Imageupload.PApptQAnsUpload   ${cookie}  ${apptid1}   ${data}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${files_data}=  Create List
    ${len}=  Get Length  ${resp.json()['urls']}
    FOR  ${i}  IN RANGE   ${len}
        Set Test Variable  ${fileid${i}}  ${resp.json()['urls'][${i}]['uid']}
        Set Test Variable  ${lblname${i}}  ${resp.json()['urls'][${i}]['labelName']}
        IF  'columnId' in ${resp.json()['urls'][${i}]}
            Set Test Variable  ${columnId${i}}  ${resp.json()['urls'][${i}]['columnId']}
            # ${file_data_dict}   Create Dictionary  uid=${fileid${i}}  labelName=${lblname${i}}  columnId=${columnId${i}}
            ${file_data_dict}   Create Dictionary  uid=${fileid${i}}  labelName=${EMPTY}  columnId=${columnId${i}}
        ELSE
            # ${file_data_dict}   Create Dictionary  uid=${fileid${i}}  labelName=${lblname${i}}
            ${file_data_dict}   Create Dictionary  uid=${fileid${i}}  labelName=${EMPTY}
        END
        Append To List  ${files_data}  ${file_data_dict}
    END

    ${resp}=   Provider Change Answer Status for Appointment  ${apptid1}  @{files_data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.status_code}  422
    # Should Be Equal As Strings  ${resp.json()}    ${UPDATE_ERROR}
    
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Check Answers   ${resp}  ${data}  ${QnrStatus[0]}   ${QnrStatus[0]}


JD-TC-ChangeAnsStatusForAppt-UH5
    [Documentation]   change answer status without column id

    ${resp}=  Encrypted Provider Login  ${PUSERNAME300}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=   Get Service
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${s_len}=  Get Length  ${resp.json()}
    # FOR  ${i}  IN RANGE   ${s_len}
    #     IF  '${resp.json()[${i}]['name']}' in @{unique_snames} and '${resp.json()[${i}]['serviceType']}' == '${ServiceType[1]}'
    #         ${s_id}=  Set Variable   ${resp.json()[${i}]['id']}
    #     END
    # END

    # Set Suite Variable   ${s_id}

    # ${resp}=    Get Locations
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${lid}   ${resp.json()[0]['id']}  

    # clear_appt_schedule   ${PUSERNAME300}

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
        IF  '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}' and '${resp.json()[${i}]['captureTime']}' == '${QnrcaptureTime[0]}'
            ${id}   Set Variable  ${resp.json()[${i}]['id']}
            ${qnrid}   Set Variable  ${resp.json()[${i}]['questionnaireId']}
            Exit For Loop If   '${id}' != '${None}'
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
    Set Suite Variable  ${Questionnaireid9}  ${qns.json()['questionnaireId']}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}    scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME13}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME13}  firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${cid13}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${cid13}  ${resp.json()[0]['id']}
    END
    
    ${apptfor1}=  Create Dictionary  id=${cid13}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid13}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Suite Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid1}

    ${resp}=  Get Questionnaire By uuid For Appmt    ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()[0]['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${id}
    
    ${fudata}=  db.fileUploadDT   ${resp.json()[0]}  ${FileAction[0]}  ${Questionnaireid9}  ${mp4file}  ${mp3file}
    Log  ${fudata}

    ${data}=  db.QuestionnaireAnswers   ${resp.json()[0]}   ${cid13}   &{fudata}
    Log  ${data}
    ${resp}=  Provider Validate Questionnaire  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME300}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Imageupload.PApptQAnsUpload   ${cookie}  ${apptid1}   ${data}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${files_data}=  Create List
    ${len}=  Get Length  ${resp.json()['urls']}
    FOR  ${i}  IN RANGE   ${len}
        Set Test Variable  ${fileid${i}}  ${resp.json()['urls'][${i}]['uid']}
        Set Test Variable  ${lblname${i}}  ${resp.json()['urls'][${i}]['labelName']}
        IF  'columnId' in ${resp.json()['urls'][${i}]}
            Set Test Variable  ${columnId${i}}  ${resp.json()['urls'][${i}]['columnId']}
            # ${file_data_dict}   Create Dictionary  uid=${fileid${i}}  labelName=${lblname${i}}  columnId=${columnId${i}}
            ${file_data_dict}   Create Dictionary  uid=${fileid${i}}  labelName=${lblname${i}}  columnId=${EMPTY}
        ELSE
            # ${file_data_dict}   Create Dictionary  uid=${fileid${i}}  labelName=${lblname${i}}
            ${file_data_dict}   Create Dictionary  uid=${fileid${i}}  labelName=${lblname${i}}
        END
        Append To List  ${files_data}  ${file_data_dict}
    END

    ${resp}=   Provider Change Answer Status for Appointment  ${apptid1}  @{files_data}
    Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}    ${UPDATE_ERROR}
    
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Check Answers   ${resp}  ${data}  ${QnrStatus[0]}  ${QnrStatus[0]}


JD-TC-ChangeAnsStatusForAppt-UH6
    [Documentation]   change answer status with invalid appointment id.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME300}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid1}

    ${resp}=  Get Questionnaire By uuid For Appmt    ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()[0]['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${id}
    
    ${fudata}=  db.fileUploadDT   ${resp.json()[0]}  ${FileAction[0]}  ${Questionnaireid9}  ${mp4file}  ${mp3file}
    Log  ${fudata}

    ${data}=  db.QuestionnaireAnswers   ${resp.json()[0]}   ${cid13}   &{fudata}
    Log  ${data}
    ${resp}=  Provider Validate Questionnaire  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME300}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Imageupload.PApptQAnsUpload   ${cookie}  ${apptid1}   ${data}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${files_data}=  Create List
    ${len}=  Get Length  ${resp.json()['urls']}
    FOR  ${i}  IN RANGE   ${len}
        Set Test Variable  ${fileid${i}}  ${resp.json()['urls'][${i}]['uid']}
        Set Test Variable  ${lblname${i}}  ${resp.json()['urls'][${i}]['labelName']}
        IF  'columnId' in ${resp.json()['urls'][${i}]}
            Set Test Variable  ${columnId${i}}  ${resp.json()['urls'][${i}]['columnId']}
            ${file_data_dict}   Create Dictionary  uid=${fileid${i}}  labelName=${lblname${i}}  columnId=${columnId${i}}
        ELSE
            ${file_data_dict}   Create Dictionary  uid=${fileid${i}}  labelName=${lblname${i}}
        END
        Append To List  ${files_data}  ${file_data_dict}
    END

    ${inv_appt_id}=  Generate Random String  16  [LETTERS][NUMBERS]

    ${resp}=   Provider Change Answer Status for Appointment  ${inv_appt_id}  @{files_data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  404
    Should Be Equal As Strings  ${resp.json()}    ${INVALID_APPOINTMENT}
    
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Check Answers   ${resp}  ${data}  ${QnrStatus[0]}  ${QnrStatus[0]}


JD-TC-ChangeAnsStatusForAppt-UH7
    [Documentation]   change answer status with another provider's appointment id.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME114}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    # clear_appt_schedule   ${PUSERNAME114}
    # clear_service   ${PUSERNAME114}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}  

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${s_id}=  Create Sample Service  ${SERVICE1}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    
    ${resp}=  Create Sample Schedule   ${lid}   ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${fname}=  generate_firstname
    ${lname}=  FakerLibrary.last_name
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME13}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME13}  firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${cid13}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${cid13}  ${resp.json()[0]['id']}
    END
    
    ${apptfor1}=  Create Dictionary  id=${cid13}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid13}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid2}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid2}

    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME300}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid1}

    ${resp}=  Get Questionnaire By uuid For Appmt    ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()[0]['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${id}
    
    ${fudata}=  db.fileUploadDT   ${resp.json()[0]}  ${FileAction[0]}  ${Questionnaireid9}  ${mp4file}  ${mp3file}
    Log  ${fudata}

    ${data}=  db.QuestionnaireAnswers   ${resp.json()[0]}   ${cid13}   &{fudata}
    Log  ${data}
    ${resp}=  Provider Validate Questionnaire  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME300}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Imageupload.PApptQAnsUpload   ${cookie}  ${apptid1}   ${data}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${files_data}=  Create List
    ${len}=  Get Length  ${resp.json()['urls']}
    FOR  ${i}  IN RANGE   ${len}
        Set Test Variable  ${fileid${i}}  ${resp.json()['urls'][${i}]['uid']}
        Set Test Variable  ${lblname${i}}  ${resp.json()['urls'][${i}]['labelName']}
        IF  'columnId' in ${resp.json()['urls'][${i}]}
            Set Test Variable  ${columnId${i}}  ${resp.json()['urls'][${i}]['columnId']}
            ${file_data_dict}   Create Dictionary  uid=${fileid${i}}  labelName=${lblname${i}}  columnId=${columnId${i}}
        ELSE
            ${file_data_dict}   Create Dictionary  uid=${fileid${i}}  labelName=${lblname${i}}
        END
        Append To List  ${files_data}  ${file_data_dict}
    END

    ${resp}=   Provider Change Answer Status for Appointment  ${apptid2}  @{files_data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  ${resp.json()}    ${NO_PERMISSION}
    
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Check Answers   ${resp}  ${data}  ${QnrStatus[0]}  ${QnrStatus[0]}


JD-TC-ChangeAnsStatusForAppt-UH8
    [Documentation]   change answer status with another label name.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME300}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid1}

    ${resp}=  Get Questionnaire By uuid For Appmt    ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()[0]['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${id}
    
    ${fudata}=  db.fileUploadDT   ${resp.json()[0]}  ${FileAction[0]}  ${Questionnaireid9}  ${mp4file}  ${mp3file}
    Log  ${fudata}

    ${data}=  db.QuestionnaireAnswers   ${resp.json()[0]}   ${cid13}   &{fudata}
    Log  ${data}
    ${resp}=  Provider Validate Questionnaire  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME300}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Imageupload.PApptQAnsUpload   ${cookie}  ${apptid1}   ${data}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${files_data}=  Create List
    ${len}=  Get Length  ${resp.json()['urls']}
    FOR  ${i}  IN RANGE   ${len}
        Set Test Variable  ${fileid${i}}  ${resp.json()['urls'][${i}]['uid']}
        Set Test Variable  ${lblname${i}}  ${resp.json()['urls'][${i}]['labelName']}
        IF  'columnId' in ${resp.json()['urls'][${i}]}
            Set Test Variable  ${columnId${i}}  ${resp.json()['urls'][${i}]['columnId']}
            # ${file_data_dict}   Create Dictionary  uid=${fileid${i}}  labelName=${lblname${i}}  columnId=${columnId${i}}
            ${file_data_dict}   Create Dictionary  uid=${fileid${i}}  labelName=${lblname0}  columnId=${columnId${i}}
        ELSE
            # ${file_data_dict}   Create Dictionary  uid=${fileid${i}}  labelName=${lblname${i}}
            ${file_data_dict}   Create Dictionary  uid=${fileid${i}}  labelName=${lblname0}
        END
        Append To List  ${files_data}  ${file_data_dict}
    END

    ${resp}=   Provider Change Answer Status for Appointment  ${apptid1}  @{files_data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}    ${UPDATE_ERROR}
    
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Check Answers   ${resp}  ${data}  ${QnrStatus[0]}  ${QnrStatus[0]}


JD-TC-ChangeAnsStatusForAppt-UH9
    [Documentation]   change answer status with non existant label name.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME300}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid1}

    ${resp}=  Get Questionnaire By uuid For Appmt    ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()[0]['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${id}
    
    ${fudata}=  db.fileUploadDT   ${resp.json()[0]}  ${FileAction[0]}  ${Questionnaireid9}  ${mp4file}  ${mp3file}
    Log  ${fudata}

    ${data}=  db.QuestionnaireAnswers   ${resp.json()[0]}   ${cid13}   &{fudata}
    Log  ${data}
    ${resp}=  Provider Validate Questionnaire  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME300}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Imageupload.PApptQAnsUpload   ${cookie}  ${apptid1}   ${data}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${files_data}=  Create List
    ${len}=  Get Length  ${resp.json()['urls']}
    FOR  ${i}  IN RANGE   ${len}
        Set Test Variable  ${fileid${i}}  ${resp.json()['urls'][${i}]['uid']}
        # Set Test Variable  ${lblname${i}}  ${resp.json()['urls'][${i}]['labelName']}
        ${inv_lbl}=  FakerLibrary.word
        IF  'columnId' in ${resp.json()['urls'][${i}]}
            Set Test Variable  ${columnId${i}}  ${resp.json()['urls'][${i}]['columnId']}
            # ${file_data_dict}   Create Dictionary  uid=${fileid${i}}  labelName=${lblname${i}}  columnId=${columnId${i}}
            ${file_data_dict}   Create Dictionary  uid=${fileid${i}}  labelName=${inv_lbl}  columnId=${columnId${i}}
        ELSE
            # ${file_data_dict}   Create Dictionary  uid=${fileid${i}}  labelName=${lblname${i}}
            ${file_data_dict}   Create Dictionary  uid=${fileid${i}}  labelName=${inv_lbl}
        END
        Append To List  ${files_data}  ${file_data_dict}
    END

    ${resp}=   Provider Change Answer Status for Appointment  ${apptid1}  @{files_data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.status_code}  404
    # Should Be Equal As Strings  ${resp.json()}    ${UPDATE_ERROR}
    
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Check Answers   ${resp}  ${data}  ${QnrStatus[0]}  ${QnrStatus[0]}


JD-TC-ChangeAnsStatusForAppt-UH10
    [Documentation]   change answer status with invalid file id.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME300}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid1}

    ${resp}=  Get Questionnaire By uuid For Appmt    ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()[0]['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${id}
    
    ${fudata}=  db.fileUploadDT   ${resp.json()[0]}  ${FileAction[0]}  ${Questionnaireid9}  ${mp4file}  ${mp3file}
    Log  ${fudata}

    ${data}=  db.QuestionnaireAnswers   ${resp.json()[0]}   ${cid13}   &{fudata}
    Log  ${data}
    ${resp}=  Provider Validate Questionnaire  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME300}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Imageupload.PApptQAnsUpload   ${cookie}  ${apptid1}   ${data}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${files_data}=  Create List
    ${len}=  Get Length  ${resp.json()['urls']}
    FOR  ${i}  IN RANGE   ${len}
        # Set Test Variable  ${fileid${i}}  ${resp.json()['urls'][${i}]['uid']}
        Set Test Variable  ${lblname${i}}  ${resp.json()['urls'][${i}]['labelName']}
        ${inv_fileid}=  FakerLibrary.word
        IF  'columnId' in ${resp.json()['urls'][${i}]}
            Set Test Variable  ${columnId${i}}  ${resp.json()['urls'][${i}]['columnId']}
            # ${file_data_dict}   Create Dictionary  uid=${fileid${i}}  labelName=${lblname${i}}  columnId=${columnId${i}}
            ${file_data_dict}   Create Dictionary  uid=${inv_fileid}  labelName=${lblname${i}}  columnId=${columnId${i}}
        ELSE
            # ${file_data_dict}   Create Dictionary  uid=${fileid${i}}  labelName=${lblname${i}}
            ${file_data_dict}   Create Dictionary  uid=${inv_fileid}  labelName=${lblname${i}}
        END
        Append To List  ${files_data}  ${file_data_dict}
    END

    ${resp}=   Provider Change Answer Status for Appointment  ${apptid1}  @{files_data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}    ${UPDATE_ERROR}
    
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Check Answers   ${resp}  ${data}  ${QnrStatus[0]}  ${QnrStatus[0]}


JD-TC-ChangeAnsStatusForAppt-6
    [Documentation]   change answer status to complete after resubmitting the answers.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME300}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=   Get Service
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${s_len}=  Get Length  ${resp.json()}
    # FOR  ${i}  IN RANGE   ${s_len}
    #     IF  '${resp.json()[${i}]['name']}' in @{unique_snames} and '${resp.json()[${i}]['serviceType']}' == '${ServiceType[1]}'
    #         ${s_id}=  Set Variable   ${resp.json()[${i}]['id']}
    #     END
    # END

    # Set Suite Variable   ${s_id}

    # ${resp}=    Get Locations
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${lid}   ${resp.json()[0]['id']}  

    # clear_appt_schedule   ${PUSERNAME300}

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
        IF  '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}' and '${resp.json()[${i}]['captureTime']}' == '${QnrcaptureTime[0]}'
            ${id}   Set Variable  ${resp.json()[${i}]['id']}
            ${qnrid}   Set Variable  ${resp.json()[${i}]['questionnaireId']}
            Exit For Loop If   '${id}' != '${None}'
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
    Set Suite Variable  ${Questionnaireid10}  ${qns.json()['questionnaireId']}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}    scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME13}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME13}  firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${cid13}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${cid13}  ${resp.json()[0]['id']}
    END
    
    ${apptfor1}=  Create Dictionary  id=${cid13}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid13}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid1}

    ${resp}=  Get Questionnaire By uuid For Appmt    ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()[0]['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${id}
    
    ${fudata}=  db.fileUploadDT   ${resp.json()[0]}  ${FileAction[0]}  ${Questionnaireid10}  ${mp4file}  ${mp3file}
    Log  ${fudata}

    ${data}=  db.QuestionnaireAnswers   ${resp.json()[0]}   ${cid13}   &{fudata}
    Log  ${data}
    ${resp}=  Provider Validate Questionnaire  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME300}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Imageupload.PApptQAnsUpload   ${cookie}  ${apptid1}   ${data}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${files_data}=  Create List
    ${len}=  Get Length  ${resp.json()['urls']}
    FOR  ${i}  IN RANGE   ${len}
        Set Test Variable  ${fileid${i}}  ${resp.json()['urls'][${i}]['uid']}
        Set Test Variable  ${lblname${i}}  ${resp.json()['urls'][${i}]['labelName']}
        IF  'columnId' in ${resp.json()['urls'][${i}]}
            Set Test Variable  ${columnId${i}}  ${resp.json()['urls'][${i}]['columnId']}
            ${file_data_dict}   Create Dictionary  uid=${fileid${i}}  labelName=${lblname${i}}  columnId=${columnId${i}}
        ELSE
            ${file_data_dict}   Create Dictionary  uid=${fileid${i}}  labelName=${lblname${i}}
        END
        Append To List  ${files_data}  ${file_data_dict}
    END

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[1]}
    Check Answers   ${resp}  ${data}  ${QnrStatus[0]}  ${QnrStatus[0]}

    ${resp}=  Appointment Action   ${apptStatus[3]}   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[3]}

    ${resp1}=   Provider Change Answer Status for Appointment  ${apptid1}  @{files_data}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Check Answers   ${resp}  ${data}

    