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

*** Variables ***
${xlFile}      ${EXECDIR}/TDD/ServiceoptionsQnrOrder.xlsx    # DataSheet
${self}      0
@{emptylist}
${mp4file}   /ebs/TDD/MP4file.mp4
${mp4mime}   video/mp4
${mp3file}   /ebs/TDD/MP3file.mp3
${mp3mime}   audio/mpeg
${pdffile}   /ebs/TDD/sample.pdf
${jpgfile}     /ebs/TDD/uploadimage.jpg
${pngfile}     /ebs/TDD/upload.png


*** Keywords ***


Open given Excel file
    [Arguments]    ${xlFile}  ${doc id}
    ${inputfileStatus}    ${msg}    Run Keyword And Ignore Error    OperatingSystem.File Should Exist    ${xlFile}
    Run Keyword If    "${inputfileStatus}"=="PASS"    Log   ${xlFile} Test data file exist    ELSE    Log    Cannot locate the given Excel file.  ERROR
    Open workbook   ${xlFile}   ${doc id}

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
    END
*** Test Cases ***

JD-TC-SubmitServiceOptionsForOrder-1
    [Documentation]  Submit service options for order

    clear_Item      ${PUSERNAME6}

    ${wb}=  readWorkbook  ${xlFile}
    ${sheet1}  GetCurrentSheet   ${wb}
    Set Suite Variable   ${sheet1}
    ${colnames}=  getColumnHeaders  ${sheet1}
    Log List  ${colnames}
    Log List  ${QnrChannel}
    Log List  ${QnrTransactionType}
    Set Suite Variable   ${colnames}
    ${catalognames}   getColumnValuesByName  ${sheet1}  ${colnames[6]}
    Log   ${catalognames}
    # Set Suite Variable   ${catalognames}
    Remove Values From List  ${catalognames}   ${NONE}
    Log  ${catalognames}
    ${unique_cnames}=    Remove Duplicates    ${catalognames}
    Log  ${unique_cnames}
    Set Suite Variable   ${unique_cnames}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME6}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
     ${p_id}=  get_acc_id            ${PUSERNAME6}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}

    ${resp}=  Get Order Settings by account id
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableOrder']}==${bool[0]}
        ${resp1}=  Enable Order Settings
        Log  ${resp1.json()}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[0]}'
        ${resp1}=   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    ELSE IF    '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[1]}'
        ${resp1}=   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}


    ${itemdata}=   FakerLibrary.words    	nb=4

    ${displayName1}=   FakerLibrary.user name    
    ${price1}=  Evaluate    random.uniform(50.0,300) 
    ${itemName1}=   Set Variable     ${itemdata[0]} 
    ${itemCode1}=   Set Variable     ${itemdata[1]}
    ${resp}=  Create Sample Item   ${displayName1}   ${itemName1}  ${itemCode1}  ${price1}  ${bool[0]}     
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id1}  ${resp.json()}

    ${displayName2}=   FakerLibrary.user name    
    ${price2}=  Evaluate    random.uniform(50.0,300) 
    ${itemName2}=   Set Variable     ${itemdata[2]} 
    ${itemCode2}=   Set Variable     ${itemdata[3]}
    ${resp}=  Create Sample Item   ${displayName2}   ${itemName2}  ${itemCode2}  ${price2}  ${bool[0]}     
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id2}  ${resp.json()}

    ${resp}=  Get Catalog By Criteria  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${s_id}   ${resp.json()['id']}
    ${c_len}=  Get Length  ${resp.json()}
    @{cnames}=  Create List
    FOR  ${i}  IN RANGE   ${c_len}
        ${catalogid}=  Run Keyword If   '${resp.json()[${i}]['catalogName']}' in @{unique_cnames} and '${resp.json()[${i}]['orderType']}' == '${OrderTypes[0]}'   Set Variable   ${resp.json()[${i}]['id']}
        Append To List  ${cnames}  ${resp.json()[${i}]['catalogName']}
    END

    ${cat_val}=    Get Variable Value    ${catalogid}

    ${cnames_len}=  Get Length  ${unique_cnames}
    IF  '${cat_val}'=='${None}'
        FOR  ${i}  IN RANGE   ${cnames_len}
            ${kwstatus} 	${value} = 	Run Keyword And Ignore Error  List Should Contain Value  ${cnames}  ${unique_cnames[${i}]}
            Log Many  ${kwstatus} 	${value}
            Continue For Loop If  '${kwstatus}' == 'PASS'
            &{dict}=  Create Dictionary   ${colnames[6]}=${unique_cnames[${i}]}
            ${ttype}=  getColumnValueByMultipleVals  ${sheet1}  ${colnames[1]}  &{dict}  
            Log  ${ttype}
            ${u_ttype}=    Remove Duplicates    ${ttype}
            Log  ${u_ttype}
            ${catalogid}=  Run Keyword If   '${kwstatus}' == 'FAIL' and '${QnrTransactionType[8]}' in @{u_ttype}  Create Sample Catalog  ${unique_cnames[${i}]}   ${tz}    ${item_id1}   ${item_id2}
        END
    END

    Set Suite Variable   ${catalogid}

    ${resp}=  Get Order Catalog    ${catalogid}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${minNumberItem}  ${resp.json()['catalogItem'][0]['minQuantity']}
    Set Suite Variable  ${maxNumberItem}  ${resp.json()['catalogItem'][0]['maxQuantity']}
    Set Suite Variable  ${minNumberItem2}  ${resp.json()['catalogItem'][1]['minQuantity']}
    Set Suite Variable  ${maxNumberItem2}  ${resp.json()['catalogItem'][1]['maxQuantity']}
    Set Suite Variable  ${sTime}  ${resp.json()['catalogSchedule']['timeSlots'][0]['sTime']}
    Set Suite Variable  ${eTime}  ${resp.json()['catalogSchedule']['timeSlots'][0]['eTime']}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${cookie}  ${resp}=  Imageupload.SALogin    ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Imageupload.UploadQuestionnaire   ${cookie}   ${account_id}   ${xlFile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME6}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
      ${id}  Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[8]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[1]}' and '${resp.json()[${i}]['captureTime']}' == '${QnrcaptureTime[2]}'  Set Variable  ${resp.json()[${i}]['id']} 
      ${qnrid}   Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[8]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[1]}' and '${resp.json()[${i}]['captureTime']}' == '${QnrcaptureTime[2]}'  Set Variable  ${resp.json()[${i}]['questionnaireId']}
      Exit For Loop If   '${id}' != '${None}'
    END
    Set Suite Variable   ${id}
    Set Suite Variable   ${qnrid}

    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings  ${qns.json()['transactionId']}  ${catalogid}

    ${resp1}=  Run Keyword If   '${qns.json()['status']}' == '${status[1]}'  Provider Change Questionnaire Status  ${id}  ${status[0]}  
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200
    
    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings   ${qns.json()['status']}  ${status[0]}
    Set Suite Variable  ${Questionnaireid}  ${qns.json()['questionnaireId']}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME14}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${jdconID}   ${resp.json()['id']}
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}

    ${DAY1}=   db.get_date_by_timezone  ${tz}
    ${pin}  ${city}  ${district}  ${state}=  get_pin_loc
    ${first}=  String . Split String   ${fname}
    Set Test Variable  ${C_email}  ${first[0]}${CUSERNAME31}.${test_mail}
    ${landMark}=  FakerLibrary.street name 
    ${address}=  Create Dictionary   phoneNumber=${CUSERNAME14}    firstName=${fname}   lastName=${lname}   email=${C_email}    address=${district}   city=${city}   postalCode=${pin}    landMark=${landMark}   countryCode=${countryCodes[0]}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minNumberItem}  max=${maxNumberItem-1}
    ${item_quantity2}=  FakerLibrary.Random Int  min=${minNumberItem2}  max=${maxNumberItem2-1}
    ${orderNote}=  FakerLibrary.Sentence   nb_words=5

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME14}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200
    
    ${resp}=   Create Order For HomeDelivery   ${cookie}  ${account_id}  ${self}  ${catalogid}  ${bool[1]}  ${address}  ${sTime}  ${eTime}  ${DAY1}  ${CUSERNAME14}  ${C_email}  ${countryCodes[1]}  ${emptylist}  ${item_id1}  ${item_quantity1}  ${item_id2}  ${item_quantity2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid1}  ${orderid[0]}
    Set Suite Variable      ${cookie}

    ${resp}=   Get Order By Id   ${account_id}   ${orderid1}  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}      ${orderid1}
    Log   ${resp}

    ${resp}=    Get Service Options By Order  ${catalogid}      ${account_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${fudata}=  db.fileUploadDT   ${resp.json()}  ${FileAction[0]}  ${Questionnaireid}  ${pdffile}  ${pdffile}
    Log  ${fudata}
    ${data}=  db.QuestionnaireAnswers   ${resp.json()}   ${jdconID}   &{fudata}
    Log  ${data}
    Set Suite Variable   ${data}

    ${resp}=    Imageupload.CSubmitSerOptForOrder   ${cookie}  ${account_id}  ${orderid1}   ${data}  ${pdffile}  ${pdffile}  
    Log  ${resp.content}    
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    Get Service Options By Order  ${catalogid}      ${account_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-SubmitServiceOptionsForOrder-2
    [Documentation]  Submit service options for order after starting order

    ${resp}=  Encrypted Provider Login  ${PUSERNAME6}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Order Settings by account id
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableOrder']}==${bool[0]}
        ${resp1}=  Enable Order Settings
        Log  ${resp1.json()}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get Order Catalog    ${catalogid}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${minNumberItem}  ${resp.json()['catalogItem'][0]['minQuantity']}
    Set Test Variable  ${maxNumberItem}  ${resp.json()['catalogItem'][0]['maxQuantity']}
    Set Test Variable  ${minNumberItem2}  ${resp.json()['catalogItem'][1]['minQuantity']}
    Set Test Variable  ${maxNumberItem2}  ${resp.json()['catalogItem'][1]['maxQuantity']}
    Set Test Variable  ${sTime}  ${resp.json()['catalogSchedule']['timeSlots'][0]['sTime']}
    Set Test Variable  ${eTime}  ${resp.json()['catalogSchedule']['timeSlots'][0]['eTime']}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME34}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME34}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${DAY1}=   db.get_date_by_timezone  ${tz}
    ${pin}  ${city}  ${district}  ${state}=  get_pin_loc
    ${first}= 	Split String 	${fname}
    Set Test Variable  ${C_email}  ${first[0]}${CUSERNAME34}.${test_mail}
    ${landMark}=  FakerLibrary.street name 
    ${address}=  Create Dictionary   phoneNumber=${CUSERNAME34}    firstName=${fname}   lastName=${lname}   email=${C_email}    address=${district}   city=${city}   postalCode=${pin}    landMark=${landMark}   countryCode=${countryCodes[0]}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minNumberItem}  max=${maxNumberItem-1}
    ${item_quantity2}=  FakerLibrary.Random Int  min=${minNumberItem2}  max=${maxNumberItem2-1}
    ${orderNote}=  FakerLibrary.Sentence   nb_words=5
    
    ${resp}=   Create Order For HomeDelivery   ${cookie}  ${account_id}    ${self}    ${catalogid}     ${bool[1]}    ${address}    ${sTime}    ${eTime}   ${DAY1}    ${CUSERNAME34}    ${C_email}  ${countryCodes[1]}  ${emptylist}  ${item_id1}  ${item_quantity1}  ${item_id2}  ${item_quantity2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid1}  ${orderid[0]}

    ${resp}=   Get Order By Id   ${account_id}   ${orderid1}  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}   ${orderid1}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME6}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Change Order Status   ${orderid1}   ${orderStatuses[2]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    sleep  03s
    ${resp}=  Get Order Status Changes by uid   ${orderid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}   ${orderStatuses[2]}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME34}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    Get Service Options By Order  ${catalogid}      ${account_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${fudata}=  db.fileUploadDT   ${resp.json()}  ${FileAction[0]}  ${Questionnaireid}  ${pdffile}  ${pdffile}
    Log  ${fudata}
    ${data}=  db.QuestionnaireAnswers   ${resp.json()}   ${jdconID}   &{fudata}
    Log  ${data}
    Set Suite Variable   ${data}

    ${resp}=    Imageupload.CSubmitSerOptForOrder   ${cookie}  ${account_id}  ${orderid1}   ${data}  ${pdffile}  ${pdffile}  
    Log  ${resp.content}    
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    Get Service Options By Order  ${catalogid}      ${account_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-SubmitServiceOptionsForOrder-3
    [Documentation]  Submit service options for order after completing order

    ${resp}=  Encrypted Provider Login  ${PUSERNAME6}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Order Settings by account id
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableOrder']}==${bool[0]}
        ${resp1}=  Enable Order Settings
        Log  ${resp1.json()}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get Order Catalog    ${catalogid}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${minNumberItem}  ${resp.json()['catalogItem'][0]['minQuantity']}
    Set Test Variable  ${maxNumberItem}  ${resp.json()['catalogItem'][0]['maxQuantity']}
    Set Test Variable  ${minNumberItem2}  ${resp.json()['catalogItem'][1]['minQuantity']}
    Set Test Variable  ${maxNumberItem2}  ${resp.json()['catalogItem'][1]['maxQuantity']}
    Set Test Variable  ${sTime}  ${resp.json()['catalogSchedule']['timeSlots'][0]['sTime']}
    Set Test Variable  ${eTime}  ${resp.json()['catalogSchedule']['timeSlots'][0]['eTime']}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME34}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME34}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${DAY1}=   db.get_date_by_timezone  ${tz}
    ${pin}  ${city}  ${district}  ${state}=  get_pin_loc
    ${first}= 	Split String 	${fname}
    Set Test Variable  ${C_email}  ${first[0]}${CUSERNAME34}.${test_mail}
    ${landMark}=  FakerLibrary.street name 
    ${address}=  Create Dictionary   phoneNumber=${CUSERNAME34}    firstName=${fname}   lastName=${lname}   email=${C_email}    address=${district}   city=${city}   postalCode=${pin}    landMark=${landMark}   countryCode=${countryCodes[0]}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minNumberItem}  max=${maxNumberItem-1}
    ${item_quantity2}=  FakerLibrary.Random Int  min=${minNumberItem2}  max=${maxNumberItem2-1}
    ${orderNote}=  FakerLibrary.Sentence   nb_words=5
    
    ${resp}=   Create Order For HomeDelivery   ${cookie}  ${account_id}    ${self}    ${catalogid}     ${bool[1]}    ${address}    ${sTime}    ${eTime}   ${DAY1}    ${CUSERNAME34}    ${C_email}  ${countryCodes[1]}  ${emptylist}  ${item_id1}  ${item_quantity1}  ${item_id2}  ${item_quantity2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid1}  ${orderid[0]}

    ${resp}=   Get Order By Id   ${account_id}   ${orderid1}  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}   ${orderid1}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME6}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Change Order Status   ${orderid1}   ${orderStatuses[9]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    sleep  03s
    ${resp}=  Get Order Status Changes by uid   ${orderid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}   ${orderStatuses[9]}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME34}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    Get Service Options By Order  ${catalogid}      ${account_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${fudata}=  db.fileUploadDT   ${resp.json()}  ${FileAction[0]}  ${Questionnaireid}  ${pdffile}  ${pdffile}
    Log  ${fudata}
    ${data}=  db.QuestionnaireAnswers   ${resp.json()}   ${jdconID}   &{fudata}
    Log  ${data}
    Set Suite Variable   ${data}

    ${resp}=    Imageupload.CSubmitSerOptForOrder   ${cookie}  ${account_id}  ${orderid1}   ${data}  ${pdffile}  ${pdffile}  
    Log  ${resp.content}    
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    Get Service Options By Order  ${catalogid}      ${account_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-SubmitServiceOptionsForOrder-UH1
    [Documentation]  Submit service options for order after canceled order

    ${resp}=  Encrypted Provider Login  ${PUSERNAME6}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Order Settings by account id
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableOrder']}==${bool[0]}
        ${resp1}=  Enable Order Settings
        Log  ${resp1.json()}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get Order Catalog    ${catalogid}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${minNumberItem}  ${resp.json()['catalogItem'][0]['minQuantity']}
    Set Test Variable  ${maxNumberItem}  ${resp.json()['catalogItem'][0]['maxQuantity']}
    Set Test Variable  ${minNumberItem2}  ${resp.json()['catalogItem'][1]['minQuantity']}
    Set Test Variable  ${maxNumberItem2}  ${resp.json()['catalogItem'][1]['maxQuantity']}
    Set Test Variable  ${sTime}  ${resp.json()['catalogSchedule']['timeSlots'][0]['sTime']}
    Set Test Variable  ${eTime}  ${resp.json()['catalogSchedule']['timeSlots'][0]['eTime']}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME34}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME34}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${DAY1}=   db.get_date_by_timezone  ${tz}
    ${pin}  ${city}  ${district}  ${state}=  get_pin_loc
    ${first}= 	Split String 	${fname}
    Set Test Variable  ${C_email}  ${first[0]}${CUSERNAME34}.${test_mail}
    ${landMark}=  FakerLibrary.street name 
    ${address}=  Create Dictionary   phoneNumber=${CUSERNAME34}    firstName=${fname}   lastName=${lname}   email=${C_email}    address=${district}   city=${city}   postalCode=${pin}    landMark=${landMark}   countryCode=${countryCodes[0]}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minNumberItem}  max=${maxNumberItem-1}
    ${item_quantity2}=  FakerLibrary.Random Int  min=${minNumberItem2}  max=${maxNumberItem2-1}
    ${orderNote}=  FakerLibrary.Sentence   nb_words=5
    
    ${resp}=   Create Order For HomeDelivery   ${cookie}  ${account_id}    ${self}    ${catalogid}     ${bool[1]}    ${address}    ${sTime}    ${eTime}   ${DAY1}    ${CUSERNAME34}    ${C_email}  ${countryCodes[1]}  ${emptylist}  ${item_id1}  ${item_quantity1}  ${item_id2}  ${item_quantity2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid1}  ${orderid[0]}

    ${resp}=   Get Order By Id   ${account_id}   ${orderid1}  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}   ${orderid1}

    ${resp}=   Cancel Order By Consumer    ${account_id}   ${orderid1}   
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    sleep  03s
    ${resp}=   Get Order By Id   ${account_id}   ${orderid1}  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['orderStatus']}   ${orderStatuses[12]}
    
    ${resp}=    Get Service Options By Order  ${catalogid}      ${account_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${fudata}=  db.fileUploadDT   ${resp.json()}  ${FileAction[0]}  ${Questionnaireid}  ${pdffile}  ${pdffile}
    Log  ${fudata}
    ${data}=  db.QuestionnaireAnswers   ${resp.json()}   ${jdconID}   &{fudata}
    Log  ${data}
    Set Suite Variable   ${data}

    ${resp}=    Imageupload.CSubmitSerOptForOrder   ${cookie}  ${account_id}  ${orderid1}   ${data}  ${pdffile}  ${pdffile}  
    Log  ${resp.content}    
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    Get Service Options By Order  ${catalogid}      ${account_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-SubmitServiceOptionsForOrder-UH2
    [Documentation]  Submit serviceoptions by provider login.

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME6}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=    Imageupload.CSubmitSerOptForOrder   ${cookie}  ${account_id}  ${orderid1}   ${data}  ${pdffile}  ${pdffile}  
    Log  ${resp.content}    
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-SubmitServiceOptionsForOrder-UH3
    [Documentation]  Submit serviceoptions without consumer login

    ${cookie_val}   Generate_random_value  size=32  chars=string.digits
    ${cookie}   Create Dictionary  JSESSIONYNW=${cookie_val}

    ${resp}=    Imageupload.CSubmitSerOptForOrder   ${cookie}  ${account_id}  ${orderid1}   ${data}  ${pdffile}  ${pdffile}  
    Log  ${resp.content}    
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.json()}  ${SESSION_EXPIRED}