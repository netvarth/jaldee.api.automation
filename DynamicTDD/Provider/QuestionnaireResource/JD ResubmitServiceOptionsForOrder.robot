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
        # Run Keyword If  '${resp.json()['questionnaire']['questionAnswers'][${i}]['question']['fieldDataType']}' in @{dttypes}
        # ...    Run Keywords
        # ...    Run Keyword And Continue On Failure  Should Be Equal As Strings  '${resp.json()['questionnaire']['questionAnswers'][${i}]['answerLine']['answer']}'   '${data['answerLine'][${i}]['answer']}'
        
        
        # ...    ELSE IF  '${resp.json()['questionnaire']['questionAnswers'][${i}]['question']['fieldDataType']}' == '${QnrDatatypes[5]}'
        # ...    Run Keywords
        # ...    Run Keyword And Continue On Failure  Should Be Equal As Strings  '${resp.json()['questionnaire']['questionAnswers'][${i}]['answerLine']['answer']['${QnrDatatypes[5]}'][0]['caption']}'   '${data['answerLine'][${i}]['answer']['${QnrDatatypes[5]}'][0]['caption']}'
        # ...    AND  Run Keyword And Continue On Failure  Should Be Equal As Strings  '${resp.json()['questionnaire']['questionAnswers'][${i}]['answerLine']['answer']['${QnrDatatypes[5]}'][0]['status']}'   '${QnrStatus[1]}'

   
    END


*** Test Cases ***

JD-TC-ProviderResubmitServiceOptionForOrder-1
    [Documentation]  Resubmit service option for Order taken from consumer side

    clear_customer   ${CUSERNAME23}

    ${resp}=  Consumer Login  ${CUSERNAME23}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${jdconID}   ${resp.json()['id']}
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}
    Set Suite Variable  ${uname}   ${resp.json()['userName']}

    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

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
    Remove Values From List  ${catalognames}   ${NONE}
    Log  ${catalognames}
    ${unique_cnames}=    Remove Duplicates    ${catalognames}
    Log  ${unique_cnames}
    Set Suite Variable   ${unique_cnames}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME48}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

*** Comments ***

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}
  
    ${resp}=  Get Order Settings by account id
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableOrder']}==${bool[0]}
        ${resp1}=  Enable Order Settings
        Log  ${resp1.json()}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END
    # ${resp1}=  Run Keyword If  ${resp.json()['enableOrder']}==${bool[0]}   Enable Order Settings   
    # Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    # Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${displayName1}=   FakerLibrary.user name    
    ${price1}=  Evaluate    random.uniform(50.0,300) 
    ${itemName1}=   FakerLibrary.name    
    ${itemCode1}=   FakerLibrary.word 
    ${resp}=  Create Sample Item   ${DisplayName1}   ${itemName1}  ${itemCode1}  ${price1}  ${bool[0]}     
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${item_id1}  ${resp.json()}

    ${resp}=   Get Item By Id    ${item_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Catalog By Criteria
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${c_len}=  Get Length  ${resp.json()}
    @{cnames}=  Create List
    # FOR  ${i}  IN RANGE   ${c_len}
    #     Append To List  ${cnames}  ${resp.json()[${i}]['catalogName']}
    # END
    
    # ${cnames_len}=  Get Length  ${unique_cnames}
    # FOR  ${i}  IN RANGE   ${cnames_len}
    #     ${kwstatus} 	${value} = 	Run Keyword And Ignore Error  List Should Contain Value  ${cnames}  ${unique_cnames[${i}]}
    #     Log Many  ${kwstatus} 	${value}
    #     Continue For Loop If  '${kwstatus}' == 'PASS'
    #     &{dict}=  Create Dictionary   ${colnames[6]}=${unique_cnames[${i}]}
    #     ${ttype}=  getColumnValueByMultipleVals  ${sheet1}  ${colnames[1]}  &{dict}  
    #     Log  ${ttype}
    #     ${u_ttype}=    Remove Duplicates    ${ttype}
    #     Log  ${u_ttype}
    #     ${CatalogId1}=  Run Keyword If   '${kwstatus}' == 'FAIL' and '${QnrTransactionType[8]}' in @{u_ttype}  Create Sample Catalog  ${unique_cnames[${i}]}   ${tz}  ${item_id1}  
    # END
    FOR  ${i}  IN RANGE   ${c_len}
        IF   '${resp.json()[${i}]['catalogName']}' in @{unique_cnames} and '${resp.json()[${i}]['orderType']}' == '${OrderTypes[0]}'
            ${CatalogId1}=   Set Variable   ${resp.json()[${i}]['id']}
        ELSE
            Append To List  ${cnames}  ${resp.json()[${i}]['catalogName']}
        END
    END

    ${cat_val}=    Get Variable Value    ${CatalogId1}
    
    IF  '${cat_val}'=='${None}'
        ${cnames_len}=  Get Length  ${unique_cnames}
        FOR  ${i}  IN RANGE   ${cnames_len}
            ${kwstatus} 	${value} = 	Run Keyword And Ignore Error  List Should Contain Value  ${cnames}  ${unique_cnames[${i}]}
            Log Many  ${kwstatus} 	${value}
            Continue For Loop If  '${kwstatus}' == 'PASS'
            &{dict}=  Create Dictionary   ${colnames[6]}=${unique_cnames[${i}]}
            ${ttype}=  getColumnValueByMultipleVals  ${sheet1}  ${colnames[1]}  &{dict}  
            Log  ${ttype}
            ${u_ttype}=    Remove Duplicates    ${ttype}
            Log  ${u_ttype}
            ${CatalogId1}=  Run Keyword If   '${kwstatus}' == 'FAIL' and '${QnrTransactionType[8]}' in @{u_ttype}  Create Sample Catalog  ${unique_cnames[${i}]}   ${tz}    ${item_id1}
   
        END
    END
    Set Suite Variable  ${CatalogId1}

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${minNumberItem}  ${resp.json()['catalogItem'][0]['minQuantity']}
    Set Suite Variable  ${maxNumberItem}  ${resp.json()['catalogItem'][0]['maxQuantity']}
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

    ${resp}=  Encrypted Provider Login  ${PUSERNAME48}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
        IF  '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[8]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}'
            ${id}   Set Variable  ${resp.json()[${i}]['id']}
            ${qnrid}   Set Variable  ${resp.json()[${i}]['questionnaireId']}
        END
    #   ${id}  Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[8]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}'  Set Variable  ${resp.json()[${i}]['id']} 
    #   ${qnrid}   Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[8]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}'  Set Variable  ${resp.json()[${i}]['questionnaireId']}
    #   Exit For Loop If   '${id}' != '${None}'
    END
    Set Suite Variable   ${id}
    Set Suite Variable   ${qnrid}

    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings  ${qns.json()['transactionId']}  ${CatalogId1} 

    ${resp1}=  Run Keyword If   '${qns.json()['status']}' == '${status[1]}'  Provider Change Questionnaire Status  ${id}  ${status[0]}  
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200
    
    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings   ${qns.json()['status']}  ${status[0]}
    Set Suite Variable  ${Questionnaireid}  ${qns.json()['questionnaireId']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME23}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME23}  firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${proconid}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${proconid}  ${resp.json()[0]['id']}
    END

    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    ${pin}  ${city}  ${district}  ${state}=  get_pin_loc
    ${first}= 	Split String 	${fname}
    Set Test Variable  ${C_email}  ${first[0]}${CUSERNAME23}.${test_mail}
    ${landMark}=  FakerLibrary.street name 
    ${address}=  Create Dictionary   phoneNumber=${CUSERNAME23}    firstName=${fname}   lastName=${lname}   email=${C_email}    address=${district}   city=${city}   postalCode=${pin}    landMark=${landMark}   countryCode=${countryCodes[0]}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minNumberItem}  max=${maxNumberItem}
    ${orderNote}=  FakerLibrary.Sentence   nb_words=5

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME48}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Create Order By Provider For HomeDelivery    ${cookie}  ${proconid}   ${proconid}   ${CatalogId1}   ${boolean[1]}   ${address}  ${sTime}    ${eTime}   ${DAY1}    ${CUSERNAME23}    ${C_email}  ${orderNote}  ${countryCodes[1]}  ${item_id1}   ${item_quantity1}  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid1}  ${orderid[0]}

    ${resp}=   Get Order by uid    ${orderid1}  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid1}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}            ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}             ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['orderStatus']}             ${orderStatuses[0]}

    ${resp}=    Get Service Options For Order By Catalogueid and Channel  ${CatalogId1}  ${QnrChannel[0]}
    Log     ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}     200

    ${fudata}=  db.fileUploadDT   ${resp.json()}  ${FileAction[0]}  ${Questionnaireid}  ${pdffile}
    Log  ${fudata}
    ${data}=  db.QuestionnaireAnswers   ${resp.json()}   ${jdconID}   &{fudata}
    Log  ${data}
    Set Suite Variable   ${data}
    ${data}=   setPrice  ${resp.json()}  ${data}
    Log  ${data}
    Set Suite Variable   ${data}
    ${resp}=  Provider Validate Questionnaire  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Item By Id    ${item_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  '${resp.json()['promotionalPrice']}' == '${emptylist}'
        Set Suite Variable   ${itmprze}      ${resp.json()['price']}
    ELSE 
        Set Suite Variable   ${itmprze}      ${resp.json()['promotionalPrice']}
    END

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME48}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${qty}          ${resp.json()['orderItem'][0]['quantity']}
    ${itemttl}=     Evaluate    ${itmprze}*${qty}
    Set Suite Variable   ${dlryChrg}     ${resp.json()['deliveryCharge']}
    ${ttl}      Evaluate    ${itemttl}+${dlryChrg}
    ${ttl}=     Convert To Number   ${ttl}   2
    Set Suite Variable   ${Servcost}     ${resp.json()['cartAmount']}
    Should Be Equal As Strings      ${Servcost}     ${ttl} 

    ${resp}=  Imageupload.PSubmitServiceOptionsForOrder   ${cookie}  ${orderid1}   ${data}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Check Answers   ${resp}  ${data}

    ${resp}=  Imageupload.PResubmitServiceOptionsForOrder   ${cookie}  ${orderid1}   ${data}  ${pngfile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Check Answers   ${resp}  ${data}

JD-TC-ResubmitServiceoptionsForOrder-2
    [Documentation]  Resubmit serviceoptions for Order after starting Order

    clear_customer   ${CUSERNAME26}

    ${resp}=  Consumer Login  ${CUSERNAME26}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${jdconID}   ${resp.json()['id']}
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}
    Set Suite Variable  ${uname}   ${resp.json()['userName']}

    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

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
    Remove Values From List  ${catalognames}   ${NONE}
    Log  ${catalognames}
    ${unique_cnames}=    Remove Duplicates    ${catalognames}
    Log  ${unique_cnames}
    Set Suite Variable   ${unique_cnames}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME51}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}
  
    ${resp}=  Get Order Settings by account id
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableOrder']}==${bool[0]}
        ${resp1}=  Enable Order Settings
        Log  ${resp1.json()}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END
    # ${resp1}=  Run Keyword If  ${resp.json()['enableOrder']}==${bool[0]}   Enable Order Settings   
    # Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    # Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${displayName1}=   FakerLibrary.user name    
    ${price1}=  Evaluate    random.uniform(50.0,300) 
    ${itemName1}=   FakerLibrary.name    
    ${itemCode1}=   FakerLibrary.word 
    ${resp}=  Create Sample Item   ${DisplayName1}   ${itemName1}  ${itemCode1}  ${price1}  ${bool[0]}     
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${item_id1}  ${resp.json()}

    ${resp}=   Get Item By Id    ${item_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Catalog By Criteria
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${c_len}=  Get Length  ${resp.json()}
    @{cnames}=  Create List
    FOR  ${i}  IN RANGE   ${c_len}
        IF   '${resp.json()[${i}]['catalogName']}' in @{unique_cnames} and '${resp.json()[${i}]['orderType']}' == '${OrderTypes[0]}'
            ${CatalogId2}=   Set Variable   ${resp.json()[${i}]['id']}
        ELSE
            Append To List  ${cnames}  ${resp.json()[${i}]['catalogName']}
        END
    END

    ${cat_val}=    Get Variable Value    ${CatalogId2}
    
    IF  '${cat_val}'=='${None}'
        ${cnames_len}=  Get Length  ${unique_cnames}
        FOR  ${i}  IN RANGE   ${cnames_len}
            ${kwstatus} 	${value} = 	Run Keyword And Ignore Error  List Should Contain Value  ${cnames}  ${unique_cnames[${i}]}
            Log Many  ${kwstatus} 	${value}
            Continue For Loop If  '${kwstatus}' == 'PASS'
            &{dict}=  Create Dictionary   ${colnames[6]}=${unique_cnames[${i}]}
            ${ttype}=  getColumnValueByMultipleVals  ${sheet1}  ${colnames[1]}  &{dict}  
            Log  ${ttype}
            ${u_ttype}=    Remove Duplicates    ${ttype}
            Log  ${u_ttype}
            ${CatalogId2}=  Run Keyword If   '${kwstatus}' == 'FAIL' and '${QnrTransactionType[8]}' in @{u_ttype}  Create Sample Catalog  ${unique_cnames[${i}]}   ${tz}    ${item_id1}
   
        END
    END
    Set Suite Variable  ${CatalogId2}

    ${resp}=  Get Order Catalog    ${CatalogId2}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${minNumberItem}  ${resp.json()['catalogItem'][0]['minQuantity']}
    Set Suite Variable  ${maxNumberItem}  ${resp.json()['catalogItem'][0]['maxQuantity']}
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

    ${resp}=  Encrypted Provider Login  ${PUSERNAME51}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
        IF  '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[8]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}'
            ${id}   Set Variable  ${resp.json()[${i}]['id']}
            ${qnrid}   Set Variable  ${resp.json()[${i}]['questionnaireId']}
        END
    #   ${id}  Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[8]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}'  Set Variable  ${resp.json()[${i}]['id']} 
    #   ${qnrid}   Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[8]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}'  Set Variable  ${resp.json()[${i}]['questionnaireId']}
    #   Exit For Loop If   '${id}' != '${None}'
    END
    Set Suite Variable   ${id}
    Set Suite Variable   ${qnrid}

    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings  ${qns.json()['transactionId']}  ${CatalogId2} 

    ${resp1}=  Run Keyword If   '${qns.json()['status']}' == '${status[1]}'  Provider Change Questionnaire Status  ${id}  ${status[0]}  
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200
    
    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings   ${qns.json()['status']}  ${status[0]}
    Set Suite Variable  ${Questionnaireid}  ${qns.json()['questionnaireId']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME26}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME26}  firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${proconid}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${proconid}  ${resp.json()[0]['id']}
    END

    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    ${pin}  ${city}  ${district}  ${state}=  get_pin_loc
    ${first}= 	Split String 	${fname}
    Set Test Variable  ${C_email}  ${first[0]}${CUSERNAME26}.${test_mail}
    ${landMark}=  FakerLibrary.street name 
    ${address}=  Create Dictionary   phoneNumber=${CUSERNAME26}    firstName=${fname}   lastName=${lname}   email=${C_email}    address=${district}   city=${city}   postalCode=${pin}    landMark=${landMark}   countryCode=${countryCodes[0]}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minNumberItem}  max=${maxNumberItem}
    ${orderNote}=  FakerLibrary.Sentence   nb_words=5

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME51}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Create Order By Provider For HomeDelivery    ${cookie}  ${proconid}   ${proconid}   ${CatalogId2}   ${boolean[1]}   ${address}  ${sTime}    ${eTime}   ${DAY1}    ${CUSERNAME23}    ${C_email}  ${orderNote}  ${countryCodes[1]}  ${item_id1}   ${item_quantity1}  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid1}  ${orderid[0]}

    ${resp}=   Get Order by uid    ${orderid1}  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid1}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}            ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}             ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['orderStatus']}             ${orderStatuses[0]}

    ${resp}=  Change Order Status   ${orderid1}   ${orderStatuses[2]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    sleep  03s
    ${resp}=  Get Order Status Changes by uid   ${orderid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['orderStatus']}   ${orderStatuses[2]}

    ${resp}=    Get Service Options For Order By Catalogueid and Channel  ${CatalogId2}  ${QnrChannel[0]}
    Log     ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}     200

    ${fudata}=  db.fileUploadDT   ${resp.json()}  ${FileAction[0]}  ${Questionnaireid}  ${pdffile}
    Log  ${fudata}
    ${data}=  db.QuestionnaireAnswers   ${resp.json()}   ${jdconID}   &{fudata}
    Log  ${data}
    Set Suite Variable   ${data}
    ${data}=   setPrice  ${resp.json()}  ${data}
    Log  ${data}
    Set Suite Variable   ${data}
    ${resp}=  Provider Validate Questionnaire  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Item By Id    ${item_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  '${resp.json()['promotionalPrice']}' == '${emptylist}'
        Set Suite Variable   ${itmprze}      ${resp.json()['price']}
    ELSE 
        Set Suite Variable   ${itmprze}      ${resp.json()['promotionalPrice']}
    END

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME51}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${qty}          ${resp.json()['orderItem'][0]['quantity']}
    ${itemttl}=     Evaluate    ${itmprze}*${qty}
    Set Suite Variable   ${dlryChrg}     ${resp.json()['deliveryCharge']}
    ${ttl}      Evaluate    ${itemttl}+${dlryChrg}
    ${ttl}=     Convert To Number   ${ttl}   2
    Set Suite Variable   ${Servcost}     ${resp.json()['cartAmount']}
    Should Be Equal As Strings      ${Servcost}     ${ttl} 

    ${resp}=  Imageupload.PSubmitServiceOptionsForOrder   ${cookie}  ${orderid1}   ${data}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Check Answers   ${resp}  ${data}

    ${resp}=  Imageupload.PResubmitServiceOptionsForOrder   ${cookie}  ${orderid1}   ${data}  ${pngfile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Check Answers   ${resp}  ${data}

JD-TC-ResubmitServiceoptionsForOrder-3
    [Documentation]  Resubmit serviceoptions for Order after completing Order

    clear_customer   ${CUSERNAME28}

    ${resp}=  Consumer Login  ${CUSERNAME28}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${jdconID}   ${resp.json()['id']}
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}
    Set Suite Variable  ${uname}   ${resp.json()['userName']}

    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

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
    Remove Values From List  ${catalognames}   ${NONE}
    Log  ${catalognames}
    ${unique_cnames}=    Remove Duplicates    ${catalognames}
    Log  ${unique_cnames}
    Set Suite Variable   ${unique_cnames}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME54}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}
  
    ${resp}=  Get Order Settings by account id
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableOrder']}==${bool[0]}
        ${resp1}=  Enable Order Settings
        Log  ${resp1.json()}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END
    # ${resp1}=  Run Keyword If  ${resp.json()['enableOrder']}==${bool[0]}   Enable Order Settings   
    # Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    # Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${displayName1}=   FakerLibrary.user name    
    ${price1}=  Evaluate    random.uniform(50.0,300) 
    ${itemName2}=   FakerLibrary.name    
    ${itemCode1}=   FakerLibrary.word 
    ${resp}=  Create Sample Item   ${DisplayName1}   ${itemName2}  ${itemCode1}  ${price1}  ${bool[0]}     
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${item_id1}  ${resp.json()}

    ${resp}=   Get Item By Id    ${item_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Catalog By Criteria
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${c_len}=  Get Length  ${resp.json()}
    @{cnames}=  Create List
    FOR  ${i}  IN RANGE   ${c_len}
        IF   '${resp.json()[${i}]['catalogName']}' in @{unique_cnames} and '${resp.json()[${i}]['orderType']}' == '${OrderTypes[0]}'
            ${CatalogId3}=   Set Variable   ${resp.json()[${i}]['id']}
        ELSE
            Append To List  ${cnames}  ${resp.json()[${i}]['catalogName']}
        END
    END

    ${cat_val}=    Get Variable Value    ${CatalogId3}
    
    IF  '${cat_val}'=='${None}'
        ${cnames_len}=  Get Length  ${unique_cnames}
        FOR  ${i}  IN RANGE   ${cnames_len}
            ${kwstatus} 	${value} = 	Run Keyword And Ignore Error  List Should Contain Value  ${cnames}  ${unique_cnames[${i}]}
            Log Many  ${kwstatus} 	${value}
            Continue For Loop If  '${kwstatus}' == 'PASS'
            &{dict}=  Create Dictionary   ${colnames[6]}=${unique_cnames[${i}]}
            ${ttype}=  getColumnValueByMultipleVals  ${sheet1}  ${colnames[1]}  &{dict}  
            Log  ${ttype}
            ${u_ttype}=    Remove Duplicates    ${ttype}
            Log  ${u_ttype}
            ${CatalogId3}=  Run Keyword If   '${kwstatus}' == 'FAIL' and '${QnrTransactionType[8]}' in @{u_ttype}  Create Sample Catalog  ${unique_cnames[${i}]}   ${tz}    ${item_id1}
   
        END
    END
    Set Suite Variable  ${CatalogId3}

    ${resp}=  Get Order Catalog    ${CatalogId3}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${minNumberItem}  ${resp.json()['catalogItem'][0]['minQuantity']}
    Set Suite Variable  ${maxNumberItem}  ${resp.json()['catalogItem'][0]['maxQuantity']}
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

    ${resp}=  Encrypted Provider Login  ${PUSERNAME54}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
        IF  '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[8]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}'
            ${id}   Set Variable  ${resp.json()[${i}]['id']}
            ${qnrid}   Set Variable  ${resp.json()[${i}]['questionnaireId']}
        END
    #   ${id}  Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[8]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}'  Set Variable  ${resp.json()[${i}]['id']} 
    #   ${qnrid}   Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[8]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}'  Set Variable  ${resp.json()[${i}]['questionnaireId']}
    #   Exit For Loop If   '${id}' != '${None}'
    END
    Set Suite Variable   ${id}
    Set Suite Variable   ${qnrid}

    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings  ${qns.json()['transactionId']}  ${CatalogId3} 

    ${resp1}=  Run Keyword If   '${qns.json()['status']}' == '${status[1]}'  Provider Change Questionnaire Status  ${id}  ${status[0]}  
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200
    
    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings   ${qns.json()['status']}  ${status[0]}
    Set Suite Variable  ${Questionnaireid}  ${qns.json()['questionnaireId']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME28}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME28}  firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${proconid}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${proconid}  ${resp.json()[0]['id']}
    END

    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    ${pin}  ${city}  ${district}  ${state}=  get_pin_loc
    ${first}= 	Split String 	${fname}
    Set Test Variable  ${C_email}  ${first[0]}${CUSERNAME28}.${test_mail}
    ${landMark}=  FakerLibrary.street name 
    ${address}=  Create Dictionary   phoneNumber=${CUSERNAME28}    firstName=${fname}   lastName=${lname}   email=${C_email}    address=${district}   city=${city}   postalCode=${pin}    landMark=${landMark}   countryCode=${countryCodes[0]}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minNumberItem}  max=${maxNumberItem}
    ${orderNote}=  FakerLibrary.Sentence   nb_words=5

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME54}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Create Order By Provider For HomeDelivery    ${cookie}  ${proconid}   ${proconid}   ${CatalogId3}   ${boolean[1]}   ${address}  ${sTime}    ${eTime}   ${DAY1}    ${CUSERNAME23}    ${C_email}  ${orderNote}  ${countryCodes[1]}  ${item_id1}   ${item_quantity1}  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid1}  ${orderid[0]}

    ${resp}=   Get Order by uid    ${orderid1}  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid1}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}            ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}             ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['orderStatus']}             ${orderStatuses[0]}

    ${resp}=   Change Order Status    ${orderid1}   ${orderStatuses[9]}     
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep  02s
    
    ${resp}=  Get Order Status Changes by uid   ${orderid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order by uid    ${orderid1} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['orderStatus']}   ${orderStatuses[9]}

    ${resp}=    Get Service Options For Order By Catalogueid and Channel  ${CatalogId3}  ${QnrChannel[0]}
    Log     ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}     200

    ${fudata}=  db.fileUploadDT   ${resp.json()}  ${FileAction[0]}  ${Questionnaireid}  ${pdffile}
    Log  ${fudata}
    ${data}=  db.QuestionnaireAnswers   ${resp.json()}   ${jdconID}   &{fudata}
    Log  ${data}
    Set Suite Variable   ${data}
    ${data}=   setPrice  ${resp.json()}  ${data}
    Log  ${data}
    Set Suite Variable   ${data}
    ${resp}=  Provider Validate Questionnaire  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Item By Id    ${item_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  '${resp.json()['promotionalPrice']}' == '${emptylist}'
        Set Suite Variable   ${itmprze}      ${resp.json()['price']}
    ELSE 
        Set Suite Variable   ${itmprze}      ${resp.json()['promotionalPrice']}
    END

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME54}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${qty}          ${resp.json()['orderItem'][0]['quantity']}
    ${itemttl}=     Evaluate    ${itmprze}*${qty}
    Set Suite Variable   ${dlryChrg}     ${resp.json()['deliveryCharge']}
    ${ttl}      Evaluate    ${itemttl}+${dlryChrg}
    ${ttl}=     Convert To Number   ${ttl}   2
    Set Suite Variable   ${Servcost}     ${resp.json()['cartAmount']}
    Should Be Equal As Strings      ${Servcost}     ${ttl} 

    ${resp}=  Imageupload.PSubmitServiceOptionsForOrder   ${cookie}  ${orderid1}   ${data}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Check Answers   ${resp}  ${data}

    ${resp}=  Imageupload.PResubmitServiceOptionsForOrder   ${cookie}  ${orderid1}   ${data}  ${pngfile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Check Answers   ${resp}  ${data}



JD-TC-ResubmitServiceoptionsForOrder-UH1
    [Documentation]  Resubmit serviceoptions for cancelled order
    
    clear_customer   ${CUSERNAME33}

    ${resp}=  Consumer Login  ${CUSERNAME33}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${jdconID}   ${resp.json()['id']}
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}
    Set Suite Variable  ${uname}   ${resp.json()['userName']}

    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

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
    Remove Values From List  ${catalognames}   ${NONE}
    Log  ${catalognames}
    ${unique_cnames}=    Remove Duplicates    ${catalognames}
    Log  ${unique_cnames}
    Set Suite Variable   ${unique_cnames}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME87}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}
  
    ${resp}=  Get Order Settings by account id
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableOrder']}==${bool[0]}
        ${resp1}=  Enable Order Settings
        Log  ${resp1.json()}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END
    # ${resp1}=  Run Keyword If  ${resp.json()['enableOrder']}==${bool[0]}   Enable Order Settings   
    # Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    # Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${displayName1}=   FakerLibrary.user name    
    ${price1}=  Evaluate    random.uniform(50.0,300) 
    ${itemName2}=   FakerLibrary.name    
    ${itemCode1}=   FakerLibrary.word 
    ${resp}=  Create Sample Item   ${DisplayName1}   ${itemName2}  ${itemCode1}  ${price1}  ${bool[0]}     
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${item_id1}  ${resp.json()}

    ${resp}=   Get Item By Id    ${item_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Catalog By Criteria
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${c_len}=  Get Length  ${resp.json()}
    @{cnames}=  Create List
    FOR  ${i}  IN RANGE   ${c_len}
        IF   '${resp.json()[${i}]['catalogName']}' in @{unique_cnames} and '${resp.json()[${i}]['orderType']}' == '${OrderTypes[0]}'
            ${CatalogId4}=   Set Variable   ${resp.json()[${i}]['id']}
        ELSE
            Append To List  ${cnames}  ${resp.json()[${i}]['catalogName']}
        END
    END

    ${cat_val}=    Get Variable Value    ${CatalogId4}
    
    IF  '${cat_val}'=='${None}'
        ${cnames_len}=  Get Length  ${unique_cnames}
        FOR  ${i}  IN RANGE   ${cnames_len}
            ${kwstatus} 	${value} = 	Run Keyword And Ignore Error  List Should Contain Value  ${cnames}  ${unique_cnames[${i}]}
            Log Many  ${kwstatus} 	${value}
            Continue For Loop If  '${kwstatus}' == 'PASS'
            &{dict}=  Create Dictionary   ${colnames[6]}=${unique_cnames[${i}]}
            ${ttype}=  getColumnValueByMultipleVals  ${sheet1}  ${colnames[1]}  &{dict}  
            Log  ${ttype}
            ${u_ttype}=    Remove Duplicates    ${ttype}
            Log  ${u_ttype}
            ${CatalogId4}=  Run Keyword If   '${kwstatus}' == 'FAIL' and '${QnrTransactionType[8]}' in @{u_ttype}  Create Sample Catalog  ${unique_cnames[${i}]}   ${tz}    ${item_id1}
   
        END
    END
    Set Suite Variable  ${CatalogId4}

    ${resp}=  Get Order Catalog    ${CatalogId4}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${minNumberItem}  ${resp.json()['catalogItem'][0]['minQuantity']}
    Set Suite Variable  ${maxNumberItem}  ${resp.json()['catalogItem'][0]['maxQuantity']}
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

    ${resp}=  Encrypted Provider Login  ${PUSERNAME87}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
        IF  '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[8]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}'
            ${id}   Set Variable  ${resp.json()[${i}]['id']}
            ${qnrid}   Set Variable  ${resp.json()[${i}]['questionnaireId']}
        END
    #   ${id}  Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[8]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}'  Set Variable  ${resp.json()[${i}]['id']} 
    #   ${qnrid}   Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[8]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}'  Set Variable  ${resp.json()[${i}]['questionnaireId']}
    #   Exit For Loop If   '${id}' != '${None}'
    END
    Set Suite Variable   ${id}
    Set Suite Variable   ${qnrid}

    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings  ${qns.json()['transactionId']}  ${CatalogId4} 

    ${resp1}=  Run Keyword If   '${qns.json()['status']}' == '${status[1]}'  Provider Change Questionnaire Status  ${id}  ${status[0]}  
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200
    
    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings   ${qns.json()['status']}  ${status[0]}
    Set Suite Variable  ${Questionnaireid}  ${qns.json()['questionnaireId']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME33}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME33}  firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${proconid}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${proconid}  ${resp.json()[0]['id']}
    END

    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    ${pin}  ${city}  ${district}  ${state}=  get_pin_loc
    ${first}= 	Split String 	${fname}
    Set Test Variable  ${C_email}  ${first[0]}${CUSERNAME33}.${test_mail}
    ${landMark}=  FakerLibrary.street name 
    ${address}=  Create Dictionary   phoneNumber=${CUSERNAME33}    firstName=${fname}   lastName=${lname}   email=${C_email}    address=${district}   city=${city}   postalCode=${pin}    landMark=${landMark}   countryCode=${countryCodes[0]}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minNumberItem}  max=${maxNumberItem}
    ${orderNote}=  FakerLibrary.Sentence   nb_words=5

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME87}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Create Order By Provider For HomeDelivery    ${cookie}  ${proconid}   ${proconid}   ${CatalogId4}   ${boolean[1]}   ${address}  ${sTime}    ${eTime}   ${DAY1}    ${CUSERNAME23}    ${C_email}  ${orderNote}  ${countryCodes[1]}  ${item_id1}   ${item_quantity1}  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid1}  ${orderid[0]}

    ${resp}=   Get Order by uid    ${orderid1}  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid1}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}            ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}             ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['orderStatus']}             ${orderStatuses[0]}

    ${resp}=    Get Service Options For Order By Catalogueid and Channel  ${CatalogId4}  ${QnrChannel[0]}
    Log     ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}     200

    ${fudata}=  db.fileUploadDT   ${resp.json()}  ${FileAction[0]}  ${Questionnaireid}  ${pdffile}
    Log  ${fudata}
    ${data}=  db.QuestionnaireAnswers   ${resp.json()}   ${jdconID}   &{fudata}
    Log  ${data}
    Set Suite Variable   ${data}
    ${data}=   setPrice  ${resp.json()}  ${data}
    Log  ${data}
    Set Suite Variable   ${data}
    ${resp}=  Provider Validate Questionnaire  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Item By Id    ${item_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  '${resp.json()['promotionalPrice']}' == '${emptylist}'
        Set Suite Variable   ${itmprze}      ${resp.json()['price']}
    ELSE 
        Set Suite Variable   ${itmprze}      ${resp.json()['promotionalPrice']}
    END

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME87}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${qty}          ${resp.json()['orderItem'][0]['quantity']}
    ${itemttl}=     Evaluate    ${itmprze}*${qty}
    Set Suite Variable   ${dlryChrg}     ${resp.json()['deliveryCharge']}
    ${ttl}      Evaluate    ${itemttl}+${dlryChrg}
    ${ttl}=     Convert To Number   ${ttl}   2
    Set Suite Variable   ${Servcost}     ${resp.json()['cartAmount']}
    Should Be Equal As Strings      ${Servcost}     ${ttl} 

    ${resp}=  Imageupload.PSubmitServiceOptionsForOrder   ${cookie}  ${orderid1}   ${data}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Check Answers   ${resp}  ${data}

    ${resp}=  Imageupload.PResubmitServiceOptionsForOrder   ${cookie}  ${orderid1}   ${data}  ${pngfile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Check Answers   ${resp}  ${data}
