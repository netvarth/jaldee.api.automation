*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Service Advance payment
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Library           Process
Library           OperatingSystem
Library           /ebs/TDD/CustomKeywords.py
Library           /ebs/TDD/excelfuncs.py
Resource          /ebs/TDD/SuperAdminKeywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
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
@{service_names}
@{emptylist}
${mp4mime}   video/mp4
${avimime}   video/avi
${mp3mime}   audio/mpeg
@{service_names}


*** Keywords ***


# Open given Excel file
#     [Arguments]    ${xlFile}  ${doc id}
#     ${inputfileStatus}    ${msg}    Run Keyword And Ignore Error    OperatingSystem.File Should Exist    ${xlFile}
#     Run Keyword If    "${inputfileStatus}"=="PASS"    Log   ${xlFile} Test data file exist    ELSE    Log    Cannot locate the given Excel file.  ERROR
#     Open workbook   ${xlFile}   ${doc id}

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

   
JD-TC-GetAppointmentAdvancePaymentDetails-1

    [Documentation]   Create a service with prepayment type as fixed then verify the advance payment from consumer side for appointment.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME101}  ${PASSWORD}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    
    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${loc_id1}=  Create Sample Location
        ${resp}=   Get Location ById  ${loc_id1}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${loc_id1}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # ${loc_id1}=  Create Sample Location
    # Set Test Variable   ${loc_id1}

    # ${resp}=   Get Location ById  ${loc_id1}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    # clear_service  ${PUSERNAME101} 
    ${ser_durtn}=   Random Int   min=2   max=10
    ${min_pre}=   Random Int   min=40   max=50
    ${min_pre}=  Convert To Number  ${min_pre}  0
    ${service_amount}=   Random Int   min=100   max=500
    ${service_amount}=  Convert To Number  ${service_amount}  0
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${ser_durtn}  ${bool[1]}  ${service_amount}  ${bool[1]}  minPrePaymentAmount=${min_pre}  taxable=${bool[0]}  prePaymentType=${advancepaymenttype[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${ser_id1}  ${resp.json()}

    # ${resp}=   Get Service By Id  ${ser_id1}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200


    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}   10
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=10
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${loc_id1}  ${duration}  ${bool1}  ${ser_id1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${fname}=  generate_firstname
    Set Suite Variable  ${fname}
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${consumerEmail}  ${CUSERNAME19}${fname}.${test_mail}
   
    ${resp}=  AddCustomer  ${CUSERNAME19}    firstName=${fname}   lastName=${lastname}  countryCode=${countryCodes[1]}    email=${consumerEmail}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Send Otp For Login    ${CUSERNAME19}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login    ${CUSERNAME19}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME19}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200


    ${resp}=    Get All Schedule Slots By Date Location and Service  ${pid}  ${DAY1}  ${loc_id1}  ${ser_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${no_of_slots}=  Get Length  ${resp.json()[0]['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        IF  ${resp.json()[0]['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Set Test Variable   ${a${i}}  ${resp.json()[0]['availableSlots'][${i}]['time']}
            Append To List   ${slots}  ${resp.json()[0]['availableSlots'][${i}]['time']}
        END
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Suite Variable   ${slot1}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}


    ${cnote}=   FakerLibrary.word
    ${EMPTY_List}=  Create List
    ${resp}=   Appointment AdvancePayment Details   ${pid}  ${ser_id1}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}  ${EMPTY_List}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${service_amount}
    Should Be Equal As Strings  ${resp.json()['amountRequiredNow']}                     ${min_pre}



   
JD-TC-GetAppointmentAdvancePaymentDetails-2

    [Documentation]   Create a service with prepayment type as percentage then verify the advance payment from consumer side for appointment.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME101}  ${PASSWORD}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    
    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}
    
    # clear_service  ${PUSERNAME101} 
    # clear_location  ${PUSERNAME101} 
    # clear_queue  ${PUSERNAME101} 

    ${loc_id1}=  Create Sample Location
    Set Test Variable   ${loc_id1}

    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}
   
    ${ser_durtn}=   Random Int   min=2   max=10
    ${min_pre}=   Random Int   min=40   max=50
    ${min_pre}=  Convert To Number  ${min_pre}  0
    ${service_amount}=   Random Int   min=100   max=500
    ${service_amount}=  Convert To Number  ${service_amount}  0
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${ser_durtn}  ${bool[1]}  ${service_amount}  ${bool[0]}  minPrePaymentAmount=${min_pre}  prePaymentType=${advancepaymenttype[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${ser_id1}  ${resp.json()}

    # ${resp}=   Get Service By Id  ${ser_id1}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200


    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}   10
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=10
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${loc_id1}  ${duration}  ${bool1}  ${ser_id1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Send Otp For Login    ${CUSERNAME19}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login    ${CUSERNAME19}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME19}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200


    ${resp}=    Get All Schedule Slots By Date Location and Service  ${pid}  ${DAY1}  ${loc_id1}  ${ser_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${no_of_slots}=  Get Length  ${resp.json()[0]['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        IF  ${resp.json()[0]['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Set Test Variable   ${a${i}}  ${resp.json()[0]['availableSlots'][${i}]['time']}
            Append To List   ${slots}  ${resp.json()[0]['availableSlots'][${i}]['time']}
        END
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Suite Variable   ${slot1}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${adv_pay_amnt}=  Evaluate  ${service_amount} * ${min_pre} / 100
    ${adv_pay_amnt}=      Convert To Number   ${adv_pay_amnt}   2

    ${cnote}=   FakerLibrary.word
    ${EMPTY_List}=  Create List
    ${resp}=   Appointment AdvancePayment Details   ${pid}  ${ser_id1}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}  ${EMPTY_List}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${service_amount}
    Should Be Equal As Strings  ${resp.json()['amountRequiredNow']}                     ${adv_pay_amnt}


JD-TC-GetAppointmentAdvancePaymentDetails-3

    [Documentation]   Create a service with prepayment type as fixed then take an appointment and do the payment then verify the details.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME101}  ${PASSWORD}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  ${resp.json()['enableJaldeeFinance']}==${bool[0]}
        ${resp1}=    Enable Disable Jaldee Finance   ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END
    
    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}

    ${loc_id1}=  Create Sample Location
    Set Test Variable   ${loc_id1}

    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    # clear_service  ${PUSERNAME101} 
    ${ser_durtn}=   Random Int   min=2   max=10
    ${min_pre}=   Random Int   min=40   max=50
    ${min_pre}=  Convert To Number  ${min_pre}  0
    ${service_amount}=   Random Int   min=100   max=500
    ${service_amount}=  Convert To Number  ${service_amount}  0
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${ser_durtn}  ${bool[1]}  ${service_amount}  ${bool[0]}  minPrePaymentAmount=${min_pre}  prePaymentType=${advancepaymenttype[1]}  automaticInvoiceGeneration=${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${ser_id1}  ${resp.json()}

    # ${resp}=   Get Service By Id  ${ser_id1}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['minPrePaymentAmount']}  ${min_pre}
    # Should Be Equal As Strings  ${resp.json()['prePaymentType']}       ${advancepaymenttype[1]}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}   10
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=10
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${loc_id1}  ${duration}  ${bool1}  ${ser_id1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}


    # ${resp}=  ProviderLogout
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200


    ${f_Name}=  generate_firstname
    Set Test Variable  ${f_Name}
    ${l_Name}=  FakerLibrary.last_name

    Set Test Variable  ${consumerEmail}  ${CUSERNAME15}${f_Name}.${test_mail}

    ${resp}=  AddCustomer  ${CUSERNAME15}    firstName=${f_Name}   lastName=${l_Name}  countryCode=${countryCodes[1]}  email=${consumerEmail} 
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME15}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()[0]['id']}

    ${resp}=    Send Otp For Login    ${CUSERNAME15}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login    ${CUSERNAME15}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token7}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME15}    ${pid}  ${token7} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}


    ${resp}=    Update ProviderConsumer    ${cid}    email=${consumerEmail}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get ProviderConsumer
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get All Schedule Slots By Date Location and Service  ${pid}  ${DAY1}  ${loc_id1}  ${ser_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${no_of_slots}=  Get Length  ${resp.json()[0]['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        IF  ${resp.json()[0]['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Set Test Variable   ${a${i}}  ${resp.json()[0]['availableSlots'][${i}]['time']}
            Append To List   ${slots}  ${resp.json()[0]['availableSlots'][${i}]['time']}
        END
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Suite Variable   ${slot1}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${balamount}=  Evaluate  ${service_amount}-${min_pre}
    ${balamount}=  twodigitfloat  ${balamount}  

    ${cnote}=   FakerLibrary.name
    ${resp}=   Customer Take Appointment   ${pid}  ${ser_id1}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${loc_id1}')}} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200    
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Make payment Consumer Mock  ${pid}  ${min_pre}  ${purpose[0]}  ${apptid1}  ${ser_id1}  ${bool[0]}   ${bool[1]}  ${cid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Encrypted Provider Login  ${PUSERNAME101}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep  01s

    ${resp}=  Get Booking Invoices  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}   ${pid}
    Set Suite Variable  ${invoice_uid}   ${resp.json()[0]['invoiceUid']}

    ${resp1}=  Get Invoice By Id  ${invoice_uid}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Should Be Equal As Strings  ${resp1.json()['billStatus']}  ${billStatus[0]}

    ${resp}=    Send Otp For Login    ${CUSERNAME15}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login    ${CUSERNAME15}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token7}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME15}    ${pid}  ${token7} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    # ${resp}=    Send Otp For Login    ${CUSERNAME15}    ${pid}
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}   200

    # ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    # ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${CUSERNAME15}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}   200
    # Set Suite Variable  ${token7}  ${resp.json()['token']}
   
    # ${resp}=  Get Payment Details  account-eq=${pid}
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200




    ${resp}=  Get consumer Appointment By Id    ${pid}  ${apptid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Make payment Consumer Mock  ${pid}  ${balamount}  ${purpose[1]}  ${apptid1}  ${ser_id1}  ${bool[0]}   ${bool[1]}  ${cid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cnote}=   FakerLibrary.word
    ${EMPTY_List}=  Create List
    ${resp}=   Appointment AdvancePayment Details   ${pid}  ${ser_id1}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}  ${EMPTY_List}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${service_amount}
    Should Be Equal As Strings  ${resp.json()['amountRequiredNow']}                     ${min_pre}
   


JD-TC-GetAppointmentAdvancePaymentDetails-4

    [Documentation]   Create a service with prepayment type as percentage then take an appointment and do the payment then verify the details.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME101}  ${PASSWORD}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    
    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}

    ${loc_id1}=  Create Sample Location
    Set Test Variable   ${loc_id1}

    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    # clear_service  ${PUSERNAME101} 
    ${ser_durtn}=   Random Int   min=2   max=10
    ${min_pre}=   Random Int   min=40   max=50
    ${min_pre}=  Convert To Number  ${min_pre}  0
    ${service_amount}=   Random Int   min=100   max=500
    ${service_amount}=  Convert To Number  ${service_amount}  0
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${ser_durtn}  ${bool[1]}  ${service_amount}  ${bool[0]}  minPrePaymentAmount=${min_pre}  prePaymentType=${advancepaymenttype[0]}  automaticInvoiceGeneration=${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${ser_id1}  ${resp.json()}

    # ${resp}=   Get Service By Id  ${ser_id1}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['minPrePaymentAmount']}  ${min_pre}
    # Should Be Equal As Strings  ${resp.json()['prePaymentType']}       ${advancepaymenttype[0]}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}   10
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=10
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${loc_id1}  ${duration}  ${bool1}  ${ser_id1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=    Send Otp For Login    ${CUSERNAME19}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login    ${CUSERNAME19}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME19}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${cid1}    ${resp.json()['providerConsumer']}

    ${resp}=    Get All Schedule Slots By Date Location and Service  ${pid}  ${DAY1}  ${loc_id1}  ${ser_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${no_of_slots}=  Get Length  ${resp.json()[0]['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        IF  ${resp.json()[0]['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Set Test Variable   ${a${i}}  ${resp.json()[0]['availableSlots'][${i}]['time']}
            Append To List   ${slots}  ${resp.json()[0]['availableSlots'][${i}]['time']}
        END
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Suite Variable   ${slot1}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${adv_pay_amnt}=  Evaluate  ${service_amount} * ${min_pre} / 100
    ${adv_pay_amnt}=      Convert To Number   ${adv_pay_amnt}   2

    ${balamount}=  Evaluate  ${service_amount}-${adv_pay_amnt}
    ${balamount}=  twodigitfloat  ${balamount}  

    ${cnote}=   FakerLibrary.name
    ${resp}=   Customer Take Appointment   ${pid}  ${ser_id1}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}  location=${{str('${loc_id1}')}}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200    
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Make payment Consumer Mock  ${pid}  ${adv_pay_amnt}  ${purpose[0]}  ${apptid1}  ${ser_id1}  ${bool[0]}   ${bool[1]}  ${cid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Encrypted Provider Login  ${PUSERNAME101}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=    Get Bill By UUId  ${apptid1}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    sleep  01s

    ${resp}=  Get Booking Invoices  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}   ${pid}
    Set Suite Variable  ${invoice_uid}   ${resp.json()[0]['invoiceUid']}

    ${resp1}=  Get Invoice By Id  ${invoice_uid}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Should Be Equal As Strings  ${resp1.json()['billStatus']}  ${billStatus[0]}

    ${resp}=    Send Otp For Login    ${CUSERNAME19}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login    ${CUSERNAME19}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME19}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
   
    ${resp}=  Get Payment Details  account-eq=${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Get consumer Appointment By Id    ${pid}  ${apptid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    
    ${resp}=  Make payment Consumer Mock  ${pid}  ${balamount}  ${purpose[1]}  ${apptid1}  ${ser_id1}  ${bool[0]}   ${bool[1]}  ${cid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cnote}=   FakerLibrary.word
    ${EMPTY_List}=  Create List
    ${resp}=   Appointment AdvancePayment Details   ${pid}  ${ser_id1}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}  ${EMPTY_List}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${service_amount}
    Should Be Equal As Strings  ${resp.json()['amountRequiredNow']}                     ${adv_pay_amnt}
   



JD-TC-GetAppointmentAdvancePaymentDetails-5

    [Documentation]   Create a service with prepayment type as percentage(100%) then take an appointment and do the payment then verify the details.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME101}  ${PASSWORD}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    
    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}

    ${loc_id1}=  Create Sample Location
    Set Test Variable   ${loc_id1}

    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    # clear_service  ${PUSERNAME101} 
    ${ser_durtn}=   Random Int   min=2   max=10
    ${min_pre}=   Random Int   min=100   max=100
    ${min_pre}=  Convert To Number  ${min_pre}  0
    ${service_amount}=   Random Int   min=100   max=500
    ${service_amount}=  Convert To Number  ${service_amount}  0
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${ser_durtn}  ${bool[1]}  ${service_amount}  ${bool[0]}  minPrePaymentAmount=${min_pre}  prePaymentType=${advancepaymenttype[0]}  automaticInvoiceGeneration=${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${ser_id1}  ${resp.json()}

    # ${resp}=   Get Service By Id  ${ser_id1}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200


    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}   10
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=10
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${loc_id1}  ${duration}  ${bool1}  ${ser_id1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=    Send Otp For Login    ${CUSERNAME19}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login    ${CUSERNAME19}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}
    
    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME19}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${cid1}  ${resp.json()['providerConsumer']}

    ${resp}=    Get All Schedule Slots By Date Location and Service  ${pid}  ${DAY1}  ${loc_id1}  ${ser_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${no_of_slots}=  Get Length  ${resp.json()[0]['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        IF  ${resp.json()[0]['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Set Test Variable   ${a${i}}  ${resp.json()[0]['availableSlots'][${i}]['time']}
            Append To List   ${slots}  ${resp.json()[0]['availableSlots'][${i}]['time']}
        END
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Suite Variable   ${slot1}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${adv_pay_amnt}=  Evaluate  ${service_amount} * ${min_pre} / 100
    ${adv_pay_amnt}=      Convert To Number   ${adv_pay_amnt}   2


    ${balamount}=  Evaluate  ${service_amount}-${adv_pay_amnt}
    ${balamount}=  twodigitfloat  ${balamount}  

    ${cnote}=   FakerLibrary.name
    ${resp}=   Customer Take Appointment   ${pid}  ${ser_id1}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}  location=${{str('${loc_id1}')}}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200    
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Make payment Consumer Mock  ${pid}  ${adv_pay_amnt}  ${purpose[0]}  ${apptid1}  ${ser_id1}  ${bool[0]}   ${bool[1]}  ${cid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Encrypted Provider Login  ${PUSERNAME101}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=    Get Bill By UUId  ${apptid1}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    sleep  01s

    ${resp}=  Get Booking Invoices  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}   ${pid}
    Set Suite Variable  ${invoice_uid}   ${resp.json()[0]['invoiceUid']}

    ${resp1}=  Get Invoice By Id  ${invoice_uid}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Should Be Equal As Strings  ${resp1.json()['billStatus']}  ${billStatus[0]}

    ${resp}=    Send Otp For Login    ${CUSERNAME19}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login    ${CUSERNAME19}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME19}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
   
    ${resp}=  Get Payment Details  account-eq=${pid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get consumer Appointment By Id    ${pid}  ${apptid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cnote}=   FakerLibrary.word
    ${EMPTY_List}=  Create List
    ${resp}=   Appointment AdvancePayment Details   ${pid}  ${ser_id1}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}  ${EMPTY_List}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${service_amount}
    Should Be Equal As Strings  ${resp.json()['amountRequiredNow']}                     ${adv_pay_amnt}



JD-TC-GetAppointmentAdvancePaymentDetails-6

    [Documentation]  Create a serviceOption with prepayment type as fixed then take a appointment and do the prepayment and verify the details.

    # clear Queue     ${HLPUSERNAME6}

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

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME6}  ${PASSWORD}
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
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['timezone']}

    ${resp}=   Get Account Settings 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  ${resp.json()['enableJaldeeFinance']}==${bool[0]}
        ${resp1}=    Enable Disable Jaldee Finance   ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=   Get Tax Percentage 
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

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

    ${ser_durtn}=   Random Int   min=2   max=10
    ${min_pre}=   Random Int   min=40   max=50
    ${min_pre}=  Convert To Number  ${min_pre}  0
    ${service_amount}=   Random Int   min=100   max=500
    ${service_amount}=  Convert To Number  ${service_amount}  0
    ${desc}=   FakerLibrary.sentence

    Log  ${snames}
    ${srv_val}=    Get Variable Value    ${s_id}
    
    ${resp}=  Create Service  ${unique_snames[${i}]}  ${desc}   ${ser_durtn}  ${bool[1]}  ${service_amount}  ${bool[0]}  minPrePaymentAmount=${min_pre}  prePaymentType=${advancepaymenttype[1]}  automaticInvoiceGeneration=${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${s_id}=  Set Variable  ${resp.json()}

    Set Suite Variable   ${s_id}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    
    ${cookie}  ${resp}=  Imageupload.SALogin    ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Imageupload.UploadQuestionnaire   ${cookie}   ${account_id}   ${xlFile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME6}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

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


    ${resp}=    SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log         ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200

    IF    '${qns.json()["status"]}' == '${status[1]}'
        ${resp1}=    Superadmin Change Questionnaire Status    ${id}    ${status[0]}    ${account_id}
        Log    ${resp1.json()}
        Should Be Equal As Strings    ${resp1.status_code}    200
    END

    ${resp}=    SuperAdmin Logout
    Log         ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME6}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${qns}   Get Provider Questionnaire By Id   ${id}
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings   ${qns.json()['status']}  ${status[0]}
    Set Suite Variable  ${Questionnaireid3}  ${qns.json()['questionnaireId']}

    ${fname}=  generate_firstname
    Set Suite Variable  ${fname}
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${consumerEmail}  ${CUSERNAME4}${fname}.${test_mail}
   
    ${resp}=  AddCustomer  ${CUSERNAME4}    firstName=${fname}   lastName=${lastname}  countryCode=${countryCodes[1]}    email=${consumerEmail}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME4}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${fname}=  generate_firstname
        ${lname}=  FakerLibrary.last_name
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
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}   10
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=10
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=    Get Service Options By Serviceid and Channel  ${s_id}   ${QnrChannel[1]}
    Log     ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fudata}=  db.fileUploadDT   ${resp.json()}  ${FileAction[0]}  ${Questionnaireid3}  ${pdffile} 
    Log  ${fudata}

    ${data}=  db.QuestionnaireAnswers   ${resp.json()}   ${cid1}   &{fudata}
    Log  ${data}
    Set Suite Variable   ${data}
    ${data}=   setPrice  ${resp.json()}  ${data}
    Log  ${data}
    Set Suite Variable   ${data}

    ${resp}=    Send Otp For Login    ${CUSERNAME4}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login    ${CUSERNAME4}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME4}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${cid1}  ${resp.json()['providerConsumer']}


    ${resp}=    Get All Schedule Slots By Date Location and Service  ${account_id}  ${DAY1}  ${lid}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${no_of_slots}=  Get Length  ${resp.json()[0]['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        IF  ${resp.json()[0]['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Set Test Variable   ${a${i}}  ${resp.json()[0]['availableSlots'][${i}]['time']}
            Append To List   ${slots}  ${resp.json()[0]['availableSlots'][${i}]['time']}
        END
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Suite Variable   ${slot1}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}


    ${cnote}=   FakerLibrary.name
    ${resp}=   Customer Take Appointment   ${account_id}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200    
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${account_id}  ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['paymentStatus']}   ${paymentStatus[0]} 
    Should Be Equal As Strings  ${resp.json()['apptStatus']}      ${apptStatus[0]}

    ${cookie}  ${resp}=  Imageupload.spLogin  ${HLPUSERNAME6}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200
  
    ${resp}=  Imageupload.PApptserviceoptionsUpload   ${cookie}  ${apptid1}   ${data}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get consumer Appointment By Id   ${account_id}  ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Check Answers   ${resp}  ${data}
    Set Suite Variable  ${s1Price}      ${resp.json()['serviceOptions'][0]['questionAnswers'][0]['answerLine']['answer']['dataGridList'][0]['totalPrice']}
    Set Suite Variable  ${s2Price}      ${resp.json()['serviceOptions'][0]['questionAnswers'][1]['answerLine']['answer']['dataGridList'][0]['totalPrice']}
    ${ActualAmount}=    Evaluate    ${s1Price}+${s2Price}+${service_amount}
    Set Suite Variable  ${FullAmount}   ${resp.json()['fullAmount']}

    ${resp}=  Make payment Consumer Mock  ${account_id}  ${min_pre}  ${purpose[0]}  ${apptid1}  ${s_id}  ${bool[0]}   ${bool[1]}  ${cid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME6}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=    Get Bill By UUId  ${apptid1}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    sleep  01s

    ${resp}=  Get Booking Invoices  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}   ${pid}
    Set Suite Variable  ${invoice_uid}   ${resp.json()[0]['invoiceUid']}

    ${resp1}=  Get Invoice By Id  ${invoice_uid}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Should Be Equal As Strings  ${resp1.json()['billStatus']}  ${billStatus[0]}

    ${resp}=    Send Otp For Login    ${CUSERNAME4}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login    ${CUSERNAME4}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME4}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Payment Details  account-eq=${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${balamount}=  Evaluate  ${FullAmount}-${min_pre}
    ${balamount}=  twodigitfloat  ${balamount} 


    ${resp}=  Get consumer Appointment By Id    ${account_id}  ${apptid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    
    ${resp}=  Make payment Consumer Mock  ${account_id}  ${balamount}  ${purpose[1]}  ${apptid1}  ${s_id}  ${bool[0]}   ${bool[1]}  ${cid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cnote}=   FakerLibrary.word
    ${EMPTY_List}=  Create List
    ${resp}=   Appointment AdvancePayment Details   ${account_id}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}  ${EMPTY_List}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${service_amount}
    Should Be Equal As Strings  ${resp.json()['amountRequiredNow']}                     ${min_pre} 


JD-TC-GetAppointmentAdvancePaymentDetails-7

    [Documentation]  Create a serviceOption with prepayment type as Percentage then take a appointment and do the prepayment and verify the details.

    # clear Queue     ${HLPUSERNAME2}

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

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME2}  ${PASSWORD}
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
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['timezone']}


    ${resp}=   Get Account Settings 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  ${resp.json()['enableJaldeeFinance']}==${bool[0]}
        ${resp1}=    Enable Disable Jaldee Finance   ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=   Get Tax Percentage 
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

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

    ${ser_durtn}=   Random Int   min=2   max=10
    ${min_pre}=   Random Int   min=40   max=50
    ${min_pre}=  Convert To Number  ${min_pre}  0
    ${service_amount}=   Random Int   min=100   max=500
    ${service_amount}=  Convert To Number  ${service_amount}  0
    ${desc}=   FakerLibrary.sentence

    Log  ${snames}
    ${srv_val}=    Get Variable Value    ${s_id}
    
    ${resp}=  Create Service  ${unique_snames[${i}]}  ${desc}   ${ser_durtn}  ${bool[1]}  ${service_amount}  ${bool[0]}  minPrePaymentAmount=${min_pre}  prePaymentType=${advancepaymenttype[0]}  automaticInvoiceGeneration=${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${s_id}=  Set Variable  ${resp.json()}

    Set Suite Variable   ${s_id}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    
    ${cookie}  ${resp}=  Imageupload.SALogin    ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Imageupload.UploadQuestionnaire   ${cookie}   ${account_id}   ${xlFile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME2}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

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


    ${resp}=    SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log         ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200

    IF    '${qns.json()["status"]}' == '${status[1]}'
        ${resp1}=    Superadmin Change Questionnaire Status    ${id}    ${status[0]}    ${account_id}
        Log    ${resp1.json()}
        Should Be Equal As Strings    ${resp1.status_code}    200
    END

    ${resp}=    SuperAdmin Logout
    Log         ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     200

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME2}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${qns}   Get Provider Questionnaire By Id   ${id}
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings   ${qns.json()['status']}  ${status[0]}
    Set Suite Variable  ${Questionnaireid4}  ${qns.json()['questionnaireId']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME4}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${fname}=  generate_firstname
        ${lname}=  FakerLibrary.last_name
        Set Test Variable  ${pc_emailid1}  ${fname}${C_Email}.${test_mail}
        ${resp1}=  AddCustomer  ${CUSERNAME4}  firstName=${fname}   lastName=${lname}  email=${pc_emailid1}
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
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}   10
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=10
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=    Get Service Options By Serviceid and Channel  ${s_id}   ${QnrChannel[1]}
    Log     ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fudata}=  db.fileUploadDT   ${resp.json()}  ${FileAction[0]}  ${Questionnaireid4}  ${pdffile} 
    Log  ${fudata}

    ${data}=  db.QuestionnaireAnswers   ${resp.json()}   ${cid1}   &{fudata}
    Log  ${data}
    Set Suite Variable   ${data}
    ${data}=   setPrice  ${resp.json()}  ${data}
    Log  ${data}
    Set Suite Variable   ${data}


    ${resp}=    Send Otp For Login    ${CUSERNAME4}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login    ${CUSERNAME4}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME4}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${cid1}  ${resp.json()['providerConsumer']}


    ${resp}=    Get All Schedule Slots By Date Location and Service  ${account_id}  ${DAY1}  ${lid}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${no_of_slots}=  Get Length  ${resp.json()[0]['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        IF  ${resp.json()[0]['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Set Test Variable   ${a${i}}  ${resp.json()[0]['availableSlots'][${i}]['time']}
            Append To List   ${slots}  ${resp.json()[0]['availableSlots'][${i}]['time']}
        END
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Suite Variable   ${slot1}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${adv_pay_amnt}=  Evaluate  ${service_amount} * ${min_pre} / 100
    ${adv_pay_amnt}=      Convert To Number   ${adv_pay_amnt}   2

    ${cnote}=   FakerLibrary.name
    ${resp}=   Customer Take Appointment   ${account_id}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200    
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${account_id}  ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 


    ${cookie}  ${resp}=  Imageupload.spLogin  ${HLPUSERNAME2}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200
  
    ${resp}=  Imageupload.PApptserviceoptionsUpload   ${cookie}  ${apptid1}   ${data}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=   Get consumer Appointment By Id   ${account_id}  ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Check Answers   ${resp}  ${data}
    Set Suite Variable  ${s1Price}      ${resp.json()['serviceOptions'][0]['questionAnswers'][0]['answerLine']['answer']['dataGridList'][0]['totalPrice']}
    Set Suite Variable  ${s2Price}      ${resp.json()['serviceOptions'][0]['questionAnswers'][1]['answerLine']['answer']['dataGridList'][0]['totalPrice']}
    ${ActualAmount}=    Evaluate    ${s1Price}+${s2Price}+${service_amount}
    Set Suite Variable  ${FullAmount}   ${resp.json()['fullAmount']}


    ${resp}=  Make payment Consumer Mock  ${account_id}  ${adv_pay_amnt}  ${purpose[0]}  ${apptid1}  ${s_id}  ${bool[0]}   ${bool[1]}  ${cid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=    Get Bill By UUId  ${apptid1}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    sleep  01s

    ${resp}=  Get Booking Invoices  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}   ${pid}
    Set Suite Variable  ${invoice_uid}   ${resp.json()[0]['invoiceUid']}

    ${resp1}=  Get Invoice By Id  ${invoice_uid}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Should Be Equal As Strings  ${resp1.json()['billStatus']}  ${billStatus[0]}

    ${resp}=    Send Otp For Login    ${CUSERNAME4}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login    ${CUSERNAME4}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME4}    ${account_id}  ${token}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
   
    ${resp}=  Get Payment Details  account-eq=${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${balamount}=  Evaluate  ${FullAmount}-${adv_pay_amnt}
    ${balamount}=  twodigitfloat  ${balamount} 

    ${resp}=  Get consumer Appointment By Id    ${account_id}  ${apptid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    
    ${resp}=  Make payment Consumer Mock  ${account_id}  ${balamount}  ${purpose[1]}  ${apptid1}  ${s_id}  ${bool[0]}   ${bool[1]}  ${cid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cnote}=   FakerLibrary.word
    ${EMPTY_List}=  Create List
    ${resp}=   Appointment AdvancePayment Details   ${account_id}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}  ${EMPTY_List}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${service_amount}
    Should Be Equal As Strings  ${resp.json()['amountRequiredNow']}                     ${adv_pay_amnt} 
   
