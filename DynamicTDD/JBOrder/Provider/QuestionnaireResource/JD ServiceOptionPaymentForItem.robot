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
${xlFile}      ${EXECDIR}/TDD/ServiceoptionsQnrItem.xlsx    # DataSheet
${self}      0
@{emptylist}
${pdffile}   /ebs/TDD/sample.pdf


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

JD-TC-PaymentForItem-1
    [Documentation]  submit service option payment for item

    Comment    Error is caused due to item options amount calculation not being done from jta side in the variable ttl.

    clear_customer   ${CUSERNAME18}

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
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

    ${resp}=  Encrypted Provider Login  ${PUSERNAME53}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}
    Set Test Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}
  
    ${resp}=  Get Order Settings by account id
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp1}=  Run Keyword If  ${resp.json()['enableOrder']}==${bool[0]}   Enable Order Settings   
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${displayName1}=   FakerLibrary.user name    
    ${price1}=  Evaluate    random.uniform(50.0,300) 
    ${itemCode1}=   FakerLibrary.word 

    ${cnames_len}=  Get Length  ${unique_cnames}
    FOR  ${i}  IN RANGE   ${cnames_len}
        ${kwstatus} 	${value} = 	Run Keyword And Ignore Error  List Should Contain Value   ${snames}   ${unique_cnames[${i}]}
        Log Many  ${kwstatus} 	${value}
        Continue For Loop If  '${kwstatus}' == 'PASS'
        &{dict}=  Create Dictionary   ${colnames[6]}=${unique_cnames[${i}]}
        ${ttype}=  getColumnValueByMultipleVals  ${sheet1}  ${colnames[1]}  &{dict}  
        Log  ${ttype}
        ${u_ttype}=    Remove Duplicates    ${ttype}
        Log  ${u_ttype}
        ${resp}=  Run Keyword If   '${kwstatus}' == 'FAIL' and '${QnrTransactionType[2]}' in @{u_ttype}  Create Sample Item   ${DisplayName1}   ${unique_cnames[${i}]}  ${itemCode1}  ${price1}  ${bool[1]}  
    END

    Set Suite Variable  ${item_id1}     ${resp.json()}

    ${resp}=   Get Item By Id    ${item_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Catalog By Criteria
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${c_len}=  Get Length  ${resp.json()}
    @{cnames}=  Create List
    FOR  ${i}  IN RANGE   ${c_len}
        Append To List  ${cnames}  ${resp.json()[${i}]['catalogName']}
    END
    
    FOR  ${i}  IN RANGE   ${cnames_len}
        ${kwstatus} 	${value} = 	Run Keyword And Ignore Error  List Should Contain Value  ${cnames}  ${unique_cnames[${i}]}
        Log Many  ${kwstatus} 	${value}
        Continue For Loop If  '${kwstatus}' == 'PASS'
        &{dict}=  Create Dictionary   ${colnames[6]}=${unique_cnames[${i}]}
        ${ttype}=  getColumnValueByMultipleVals  ${sheet1}  ${colnames[1]}  &{dict}  
        Log  ${ttype}
        ${u_ttype}=    Remove Duplicates    ${ttype}
        Log  ${u_ttype}
        ${CatalogId1}=  Run Keyword If   '${kwstatus}' == 'FAIL' and '${QnrTransactionType[2]}' in @{u_ttype}  Create Sample Catalog  ${unique_cnames[${i}]}   ${tz}  ${item_id1}  
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

    ${resp}=  Encrypted Provider Login  ${PUSERNAME53}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
      ${id}  Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[2]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}'  Set Variable  ${resp.json()[${i}]['id']} 
      ${qnrid}   Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[2]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}'  Set Variable  ${resp.json()[${i}]['questionnaireId']}
      Exit For Loop If   '${id}' != '${None}'
    END
    Set Suite Variable   ${id}
    Set Suite Variable   ${qnrid}

    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Set Suite Variable  ${pid}  ${qns.json()['transactionId']}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings  ${qns.json()['transactionId']}  ${pid}

    ${resp1}=  Run Keyword If   '${qns.json()['status']}' == '${status[1]}'  Provider Change Questionnaire Status  ${id}  ${status[0]}  
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200
    
    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings   ${qns.json()['status']}  ${status[0]}
    Set Suite Variable  ${Questionnaireid}  ${qns.json()['questionnaireId']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME21}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME21}  firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${proconid}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${proconid}  ${resp.json()[0]['id']}
    END

    ${resp}=     Get Provider service options for an item  ${item_id1}  ${QnrChannel[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    Should Be Equal As Strings   ${resp.json()['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${resp.json()['id']}   ${id}

    ${fudata}=  db.fileUploadDT   ${resp.json()}  ${FileAction[0]}  ${Questionnaireid}  ${pdffile}
    Log  ${fudata}
    ${data}=  db.QuestionnaireAnswers   ${resp.json()}   ${jdconID}   &{fudata}
    Log  ${data}
    ${data}=   setPrice  ${resp.json()}  ${data}
    Log  ${data}
    Set Suite Variable   ${data}
    ${data}=    Evaluate    json.dumps(${data})    json
    Log  ${data}
    # Set Suite Variable  ${item1Price}    ${data(['answerLine'][0]['answer']['dataGridList'][0]['dataGridList'][0]['price'])} 
    # Set Suite Variable  ${s1Price}    ${data(['answerLine'][0]['answer']['dataGridList'][0]['dataGridListColumn'][0]['price'])}
    # x.answerLine[0].answer.dataGridList[0].dataGridListColumn[0].price

    ${resp}=  Provider Validate Questionnaire  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=     Get Provider service options for an item  ${item_id1}  ${QnrChannel[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    ${pin}  ${city}  ${district}  ${state}=  get_pin_loc
    ${first} 	${rest} = 	Split String 	${fname}   max_split=1
    Set Test Variable  ${C_email}  ${first}${CUSERNAME21}.${test_mail}
    ${landMark}=  FakerLibrary.street name 
    ${address}=  Create Dictionary   phoneNumber=${CUSERNAME21}    firstName=${fname}   lastName=${lname}   email=${C_email}    address=${district}   city=${city}   postalCode=${pin}    landMark=${landMark}   countryCode=${countryCodes[0]}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minNumberItem}  max=${maxNumberItem}
    ${orderNote}=  FakerLibrary.Sentence   nb_words=5

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME53}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${OrderDict}=    Order For Item   ${proconid}   ${proconid}   ${CatalogId1}   ${boolean[1]}   ${address}  ${sTime}    ${eTime}   ${DAY1}    ${CUSERNAME21}    ${C_email}  ${orderNote}  ${countryCodes[1]}  ${item_id1}   ${item_quantity1}  
    Log  ${OrderDict}

    ${resp}=  Create Order With Service Options    ${cookie}    order=${OrderDict}    srvAnswers=${data}
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

    ${resp}=   Get Item By Id    ${item_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  '${resp.json()['promotionalPrice']}' == '${emptylist}'
        Set Suite Variable   ${itmprze}      ${resp.json()['price']}
    ELSE 
        Set Suite Variable   ${itmprze}      ${resp.json()['promotionalPrice']}
    END

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${qty}          ${resp.json()['orderItem'][0]['quantity']}
    ${itemttl}=     Evaluate    ${itmprze}*${qty}
    Set Suite Variable   ${dlryChrg}     ${resp.json()['deliveryCharge']}
    ${ttl}      Evaluate    ${itemttl}+${dlryChrg}
    ${ttl}=     Convert To Number   ${ttl}   2
    Set Suite Variable   ${total}     ${resp.json()['orderItem'][0]['totalPrice']}
    Should Be Equal As Strings      ${total}     ${itemttl}


    sleep  2s

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME53}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Imageupload.PSubmitSerOptForItem       ${cookie}  ${item_id1}  ${orderid1}   ${data}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Check Answers   ${resp}  ${data}
    Set Suite Variable  ${s1Price}      ${resp.json()['serviceOptions'][0]['questionAnswers'][0]['answerLine']['answer']['dataGridList'][0]['totalPrice']}
    Set Suite Variable  ${s2Price}      ${resp.json()['serviceOptions'][0]['questionAnswers'][1]['answerLine']['answer']['dataGridList'][0]['totalPrice']}
    ${ActualAmount}=    Evaluate    ${s1Price}+${s2Price}+${ttl}
    ${ActualAmount}=     Convert To Number   ${ActualAmount}   2
    Set Suite Variable  ${CartAmount}   ${resp.json()['cartAmount']}
    Should Be Equal As Strings      ${CartAmount}   ${ActualAmount}



JD-TC-PaymentForItem-2
    [Documentation]  resubmit service option payment for item

    clear_customer   ${PUSERNAME45}

    ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD}
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

    ${resp}=  Encrypted Provider Login  ${PUSERNAME45}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}
    Set Test Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}
  
    ${resp}=  Get Order Settings by account id
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp1}=  Run Keyword If  ${resp.json()['enableOrder']}==${bool[0]}   Enable Order Settings   
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${displayName1}=   FakerLibrary.user name    
    ${price1}=  Evaluate    random.uniform(50.0,300) 
    ${itemCode1}=   FakerLibrary.word 

    ${cnames_len}=  Get Length  ${unique_cnames}
    FOR  ${i}  IN RANGE   ${cnames_len}
        ${kwstatus} 	${value} = 	Run Keyword And Ignore Error  List Should Contain Value   ${snames}   ${unique_cnames[${i}]}
        Log Many  ${kwstatus} 	${value}
        Continue For Loop If  '${kwstatus}' == 'PASS'
        &{dict}=  Create Dictionary   ${colnames[6]}=${unique_cnames[${i}]}
        ${ttype}=  getColumnValueByMultipleVals  ${sheet1}  ${colnames[1]}  &{dict}  
        Log  ${ttype}
        ${u_ttype}=    Remove Duplicates    ${ttype}
        Log  ${u_ttype}
        ${resp}=  Run Keyword If   '${kwstatus}' == 'FAIL' and '${QnrTransactionType[2]}' in @{u_ttype}  Create Sample Item   ${DisplayName1}   ${unique_cnames[${i}]}  ${itemCode1}  ${price1}  ${bool[1]}  
    END

    Set Suite Variable  ${item_id1}     ${resp.json()}

    ${resp}=   Get Item By Id    ${item_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Catalog By Criteria
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${c_len}=  Get Length  ${resp.json()}
    @{cnames}=  Create List
    FOR  ${i}  IN RANGE   ${c_len}
        Append To List  ${cnames}  ${resp.json()[${i}]['catalogName']}
    END
    
    FOR  ${i}  IN RANGE   ${cnames_len}
        ${kwstatus} 	${value} = 	Run Keyword And Ignore Error  List Should Contain Value  ${cnames}  ${unique_cnames[${i}]}
        Log Many  ${kwstatus} 	${value}
        Continue For Loop If  '${kwstatus}' == 'PASS'
        &{dict}=  Create Dictionary   ${colnames[6]}=${unique_cnames[${i}]}
        ${ttype}=  getColumnValueByMultipleVals  ${sheet1}  ${colnames[1]}  &{dict}  
        Log  ${ttype}
        ${u_ttype}=    Remove Duplicates    ${ttype}
        Log  ${u_ttype}
        ${CatalogId1}=  Run Keyword If   '${kwstatus}' == 'FAIL' and '${QnrTransactionType[2]}' in @{u_ttype}  Create Sample Catalog  ${unique_cnames[${i}]}   ${tz}  ${item_id1}  
    END
    Set Suite Variable  ${CatalogId1}

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${minNumberItem}  ${resp.json()['catalogItem'][0]['minQuantity']}
    Set Suite Variable  ${maxNumberItem}  ${resp.json()['catalogItem'][0]['maxQuantity']}
    Set Suite Variable  ${sTime}  ${resp.json()['catalogSchedule']['timeSlots'][0]['sTime']}
    Set Suite Variable  ${eTim￼e}  ${resp.json()['catalogSchedule']['timeSlots'][0]['eTime']}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${cookie}  ${resp}=  Imageupload.SALogin    ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Imageupload.UploadQuestionnaire   ${cookie}   ${account_id}   ${xlFile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME45}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
      ${id}  Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[2]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}'  Set Variable  ${resp.json()[${i}]['id']} 
      ${qnrid}   Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[2]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}'  Set Variable  ${resp.json()[${i}]['questionnaireId']}
      Exit For Loop If   '${id}' != '${None}'
    END
    Set Suite Variable   ${id}
    Set Suite Variable   ${qnrid}

    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Set Suite Variable  ${pid}  ${qns.json()['transactionId']}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings  ${qns.json()['transactionId']}  ${pid}

    ${resp1}=  Run Keyword If   '${qns.json()['status']}' == '${status[1]}'  Provider Change Questionnaire Status  ${id}  ${status[0]}  
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200
    
    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings   ${qns.json()['status']}  ${status[0]}
    Set Suite Variable  ${Questionnaireid}  ${qns.json()['questionnaireId']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME21}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME21}  firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${proconid}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${proconid}  ${resp.json()[0]['id']}
    END

    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    ${pin}  ${city}  ${district}  ${state}=  get_pin_loc
    ${first} 	${rest} = 	Split String 	${fname}   max_split=1
    Set Test Variable  ${C_email}  ${first}${CUSERNAME21}.${test_mail}
    ${landMark}=  FakerLibrary.street name 
    ${address}=  Create Dictionary   phoneNumber=${CUSERNAME21}    firstName=${fname}   lastName=${lname}   email=${C_email}    address=${district}   city=${city}   postalCode=${pin}    landMark=${landMark}   countryCode=${countryCodes[0]}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minNumberItem}  max=${maxNumberItem}
    ${orderNote}=  FakerLibrary.Sentence   nb_words=5

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME45}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=     Get Provider service options for an item  ${item_id1}  ${QnrChannel[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    Should Be Equal As Strings   ${resp.json()['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${resp.json()['id']}   ${id}

    ${fudata}=  db.fileUploadDT   ${resp.json()}  ${FileAction[0]}  ${Questionnaireid}  ${pdffile}
    Log  ${fudata}
    ${data}=  db.QuestionnaireAnswers   ${resp.json()}   ${jdconID}   &{fudata}
    Log  ${data}
    ${data}=   setPrice  ${resp.json()}  ${data}
    Log  ${data}
    Set Suite Variable   ${data}
    ${resp}=  Provider Validate Questionnaire  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=   Create Order By Provider For HomeDelivery    ${cookie}  ${proconid}   ${proconid}   ${CatalogId1}   ${boolean[1]}   ${address}  ${sTime}    ${eTime}   ${DAY1}    ${CUSERNAME21}    ${C_email}  ${orderNote}  ${countryCodes[1]}  ${item_id1}   ${item_quantity1}  
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${orderid}=  Get Dictionary Values  ${resp.json()}
    # Set Suite Variable  ${orderid1}  ${orderid[0]}

    ${OrderDict}=    Order For Item   ${proconid}   ${proconid}   ${CatalogId1}   ${boolean[1]}   ${address}  ${sTime}    ${eTime}   ${DAY1}    ${CUSERNAME21}    ${C_email}  ${orderNote}  ${countryCodes[1]}  ${item_id1}   ${item_quantity1}  
    Log  ${OrderDict}

    ${resp}=  Create Order With Service Options    ${cookie}    order=${OrderDict}    srvAnswers=${data}
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

    # ${resp}=     Get Provider service options for an item  ${item_id1}  ${QnrChannel[0]}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # Should Be Equal As Strings   ${resp.json()['questionnaireId']}  ${qnrid}
    # Should Be Equal As Strings  ${resp.json()['id']}   ${id}

    # ${fudata}=  db.fileUploadDT   ${resp.json()}  ${FileAction[0]}  ${Questionnaireid}  ${pdffile}
    # Log  ${fudata}
    # ${data}=  db.QuestionnaireAnswers   ${resp.json()}   ${jdconID}   &{fudata}
    # Log  ${data}
    # ${data}=   setPrice  ${resp.json()}  ${data}
    # Log  ${data}
    # Set Suite Variable   ${data}
    # ${resp}=  Provider Validate Questionnaire  ${data}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Item By Id    ${item_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  '${resp.json()['promotionalPrice']}' == '${emptylist}'
        Set Suite Variable   ${itmprze}      ${resp.json()['price']}
    ELSE 
        Set Suite Variable   ${itmprze}      ${resp.json()['promotionalPrice']}
    END

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${qty}          ${resp.json()['orderItem'][0]['quantity']}
    ${itemttl}=     Evaluate    ${itmprze}*${qty}
    Set Suite Variable   ${dlryChrg}     ${resp.json()['deliveryCharge']}
    ${ttl}      Evaluate    ${itemttl}+${dlryChrg}
    ${ttl}=     Convert To Number   ${ttl}   2
    Set Suite Variable   ${total}     ${resp.json()['orderItem'][0]['totalPrice']}
    ${total}=     Convert To Number   ${total}   2
    # Should Be Equal As Strings      ${total}     ${itemttl}
    sleep  2s

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME45}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Imageupload.PSubmitSerOptForItem       ${cookie}  ${item_id1}  ${orderid1}   ${data}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Check Answers   ${resp}  ${data}
    Set Suite Variable  ${s1Price}      ${resp.json()['serviceOptions'][0]['questionAnswers'][0]['answerLine']['answer']['dataGridList'][0]['totalPrice']}
    Set Suite Variable  ${s2Price}      ${resp.json()['serviceOptions'][0]['questionAnswers'][1]['answerLine']['answer']['dataGridList'][0]['totalPrice']}
    ${ActualAmount}=    Evaluate    ${s1Price}+${s2Price}+${ttl}
    ${ActualAmount}=     Convert To Number   ${ActualAmount}   2
    Set Suite Variable  ${CartAmount}   ${resp.json()['cartAmount']}
    Should Be Equal As Strings      ${CartAmount}   ${ActualAmount}

    # ${fudata}=  db.fileUploadDT   ${resp.json()}  ${FileAction[0]}  ${Questionnaireid}  ${pdffile}
    # Log  ${fudata}

    ${resp1}=     Get Provider service options for an item  ${item_id1}  ${QnrChannel[0]}
    Log  ${resp1.content}
    Should Be Equal As Strings    ${resp1.status_code}    200

    Should Be Equal As Strings   ${resp1.json()['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${resp1.json()['id']}   ${id}

    ${data1}=  db.QuestionnaireAnswers   ${resp1.json()}   ${jdconID}   &{fudata}
    Log  ${data1}
    ${data1}=   setPrice  ${resp1.json()}  ${data1}
    Log  ${data1}
    Set Suite Variable   ${data1}

    Should Not Be Equal As Strings    ${data1}    ${data}


    ${resp}=   Get Item By Id    ${item_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  '${resp.json()['promotionalPrice']}' == '${emptylist}'
        Set Suite Variable   ${itmprze1}      ${resp.json()['price']}
    ELSE 
        Set Suite Variable   ${itmprze1}      ${resp.json()['promotionalPrice']}
    END

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${qty1}          ${resp.json()['orderItem'][0]['quantity']}
    ${itemttl1}=     Evaluate    ${itmprze1}*${qty1}
    Set Suite Variable   ${dlryChrg1}     ${resp.json()['deliveryCharge']}
    ${ttl1}      Evaluate    ${itemttl1}+${dlryChrg1}
    ${ttl1}=     Convert To Number   ${ttl1}   2

    ${resp}=  Imageupload.PResubmitSerOptForItem       ${cookie}  ${orderid1}   ${data1}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Check Answers   ${resp}  ${data1}
    Set Suite Variable  ${s1bPrice}      ${resp.json()['serviceOptions'][0]['questionAnswers'][0]['answerLine']['answer']['dataGridList'][0]['totalPrice']}
    Set Suite Variable  ${s2bPrice}      ${resp.json()['serviceOptions'][0]['questionAnswers'][1]['answerLine']['answer']['dataGridList'][0]['totalPrice']}
    ${ActualAmount1}=    Evaluate    ${s1bPrice}+${s2bPrice}+${ttl1}
    ${ActualAmount1}=     Convert To Number   ${ActualAmount1}   2
    Set Suite Variable  ${CartAmount1}   ${resp.json()['cartAmount']}
    Should Be Equal As Strings      ${CartAmount1}   ${ActualAmount}

*** comment ***

JD-TC-PaymentForItem-3
    [Documentation]  payment with gst

    ${resp}=  Consumer Login  ${CUSERNAME21}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${jdconID}   ${resp.json()['id']}
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
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
    Set Suite Variable   ${catalognames}
    Remove Values From List  ${catalognames}   ${NONE}
    Log  ${catalognames}
    ${unique_cnames}=    Remove Duplicates    ${catalognames}
    Log  ${unique_cnames}
    Set Suite Variable   ${unique_cnames}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME138}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Set Suite Variable  ${pid1}  ${resp.json()['id']}

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}

    ${resp}=  Get Order Settings by account id
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableOrder']}==${bool[0]}
        ${resp1}=  Enable Order Settings 
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${displayName1}=   FakerLibrary.user name    
    ${price1}=  Evaluate    random.uniform(50.0,300) 
    ${itemCode1}=   FakerLibrary.word 

    ${cnames_len}=  Get Length  ${unique_cnames}
    FOR  ${i}  IN RANGE   ${cnames_len}
        ${kwstatus} 	${value} = 	Run Keyword And Ignore Error  List Should Contain Value   ${snames}   ${unique_cnames[${i}]}
        Log Many  ${kwstatus} 	${value}
        Continue For Loop If  '${kwstatus}' == 'PASS'
        &{dict}=  Create Dictionary   ${colnames[6]}=${unique_cnames[${i}]}
        ${ttype}=  getColumnValueByMultipleVals  ${sheet1}  ${colnames[1]}  &{dict}  
        Log  ${ttype}
        ${u_ttype}=    Remove Duplicates    ${ttype}
        Log  ${u_ttype}
        ${resp}=  Run Keyword If   '${kwstatus}' == 'FAIL' and '${QnrTransactionType[2]}' in @{u_ttype}  Create Sample Item   ${DisplayName1}   ${unique_cnames[${i}]}  ${itemCode1}  ${price1}  ${bool[1]}  
    END

    Set Suite Variable  ${item_id1}     ${resp.json()}

    ${resp}=   Get Item By Id    ${item_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Catalog By Criteria
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${c_len}=  Get Length  ${resp.json()}
    @{cnames}=  Create List
    FOR  ${i}  IN RANGE   ${c_len}
        Append To List  ${cnames}  ${resp.json()[${i}]['catalogName']}
    END
    
    FOR  ${i}  IN RANGE   ${cnames_len}
        ${kwstatus} 	${value} = 	Run Keyword And Ignore Error  List Should Contain Value  ${cnames}  ${unique_cnames[${i}]}
        Log Many  ${kwstatus} 	${value}
        Continue For Loop If  '${kwstatus}' == 'PASS'
        &{dict}=  Create Dictionary   ${colnames[6]}=${unique_cnames[${i}]}
        ${ttype}=  getColumnValueByMultipleVals  ${sheet1}  ${colnames[1]}  &{dict}  
        Log  ${ttype}
        ${u_ttype}=    Remove Duplicates    ${ttype}
        Log  ${u_ttype}
        ${CatalogId1}=  Run Keyword If   '${kwstatus}' == 'FAIL' and '${QnrTransactionType[2]}' in @{u_ttype}  Create Sample Catalog  ${unique_cnames[${i}]}   ${tz}  ${item_id1}  
    END
    Set Suite Variable  ${CatalogId1}

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${minNumberItem}  ${resp.json()['catalogItem'][0]['minQuantity']}
    Set Test Variable  ${maxNumberItem}  ${resp.json()['catalogItem'][0]['maxQuantity']}
    Set Test Variable  ${sTime}  ${resp.json()['catalogSchedule']['timeSlots'][0]['sTime']}
    Set Test Variable  ${eTime}  ${resp.json()['catalogSchedule']['timeSlots'][0]['eTime']}
    
    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${cookie}  ${resp}=  Imageupload.SALogin    ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Imageupload.UploadQuestionnaire   ${cookie}   ${account_id}   ${xlFile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME138}  ${PASSWORD}
    Log  ${resp.content}
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

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
      ${id}  Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[2]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}'  Set Variable  ${resp.json()[${i}]['id']} 
      ${qnrid}   Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[2]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}'  Set Variable  ${resp.json()[${i}]['questionnaireId']}
      Exit For Loop If   '${id}' != '${None}'
    END
    Set Suite Variable   ${id}
    Set Suite Variable   ${qnrid}

    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Set Suite Variable  ${pid}  ${qns.json()['transactionId']}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings  ${qns.json()['transactionId']}  ${pid}

    ${resp1}=  Run Keyword If   '${qns.json()['status']}' == '${status[1]}'  Provider Change Questionnaire Status  ${id}  ${status[0]}  
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200
    
    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings   ${qns.json()['status']}  ${status[0]}
    Set Suite Variable  ${Questionnaireid}  ${qns.json()['questionnaireId']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME21}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME21}  firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${proconid}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${proconid}  ${resp.json()[0]['id']}
    END

    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    ${pin}  ${city}  ${district}  ${state}=  get_pin_loc
    ${first} 	${rest} = 	Split String 	${fname}   max_split=1
    Set Test Variable  ${C_email}  ${first}${CUSERNAME21}.${test_mail}
    ${landMark}=  FakerLibrary.street name 
    ${address}=  Create Dictionary   phoneNumber=${CUSERNAME21}    firstName=${fname}   lastName=${lname}   email=${C_email}    address=${district}   city=${city}   postalCode=${pin}    landMark=${landMark}   countryCode=${countryCodes[0]}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minNumberItem}  max=${maxNumberItem}
    ${orderNote}=  FakerLibrary.Sentence   nb_words=5

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME138}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=     Get Provider service options for an item  ${item_id1}  ${QnrChannel[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    Should Be Equal As Strings   ${resp.json()['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${resp.json()['id']}   ${id}

    ${fudata}=  db.fileUploadDT   ${resp.json()}  ${FileAction[0]}  ${Questionnaireid}  ${pdffile}
    Log  ${fudata}
    ${data}=  db.QuestionnaireAnswers   ${resp.json()}   ${jdconID}   &{fudata}
    Log  ${data}
    ${data}=   setPrice  ${resp.json()}  ${data}
    Log  ${data}
    Set Suite Variable   ${data}
    ${resp}=  Provider Validate Questionnaire  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=   Create Order By Provider For HomeDelivery    ${cookie}  ${proconid}   ${proconid}   ${CatalogId1}   ${boolean[1]}   ${address}  ${sTime}    ${eTime}   ${DAY1}    ${CUSERNAME21}    ${C_email}  ${orderNote}  ${countryCodes[1]}  ${item_id1}   ${item_quantity1}  
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${orderid}=  Get Dictionary Values  ${resp.json()}
    # Set Suite Variable  ${orderid1}  ${orderid[0]}

    ${OrderDict}=    Order For Item   ${proconid}   ${proconid}   ${CatalogId1}   ${boolean[1]}   ${address}  ${sTime}    ${eTime}   ${DAY1}    ${CUSERNAME21}    ${C_email}  ${orderNote}  ${countryCodes[1]}  ${item_id1}   ${item_quantity1}  
    Log  ${OrderDict}

    ${resp}=  Create Order With Service Options    ${cookie}    order=${OrderDict}    srvAnswers=${data}
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

    ${resp}=   Get Item By Id    ${item_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  '${resp.json()['promotionalPrice']}' == '${emptylist}'
        Set Suite Variable   ${itmprze}      ${resp.json()['price']}
    ELSE 
        Set Suite Variable   ${itmprze}      ${resp.json()['promotionalPrice']}
    END

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${qty}          ${resp.json()['orderItem'][0]['quantity']}
    ${itemttl}=     Evaluate    ${itmprze}*${qty}
    Set Suite Variable   ${dlryChrg}     ${resp.json()['deliveryCharge']}
    ${ttl}      Evaluate    ${itemttl}+${dlryChrg}
    # ${ttl}=     Convert To Number   ${ttl}   2
    Set Suite Variable   ${Servcost}     ${resp.json()['cartAmount']}
    # Should Be Equal As Strings      ${Servcost}     ${ttl}

    sleep  2s

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME138}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Imageupload.PSubmitSerOptForItem       ${cookie}  ${item_id1}  ${orderid1}   ${data}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Check Answers   ${resp}  ${data}
    Set Suite Variable  ${s1Price}      ${resp.json()['serviceOptions'][0]['questionAnswers'][0]['answerLine']['answer']['dataGridList'][0]['totalPrice']}
    Set Suite Variable  ${s2Price}      ${resp.json()['serviceOptions'][0]['questionAnswers'][1]['answerLine']['answer']['dataGridList'][0]['totalPrice']}
    ${ActualAmount}=    Evaluate    ${s1Price}+${s2Price}+${Servcost}
    ${ActualAmount}=     Convert To Number   ${ActualAmount}   2
    Set Suite Variable  ${CartAmountAS}   ${resp.json()['cartAmount']}
    Should Be Equal As Strings      ${CartAmountAS}   ${ActualAmount}

    ${resp}=  Get Bill By UUId  ${orderid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-PaymentForItem-4
    [Documentation]  payment with gst and coupon

    ${resp}=  Consumer Login  ${CUSERNAME29}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${jdconID}   ${resp.json()['id']}
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
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
    Set Suite Variable   ${catalognames}
    Remove Values From List  ${catalognames}   ${NONE}
    Log  ${catalognames}
    ${unique_cnames}=    Remove Duplicates    ${catalognames}
    Log  ${unique_cnames}
    Set Suite Variable   ${unique_cnames}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME107}  ${PASSWORD}
    Log  ${resp.content}
    Set Suite Variable   ${domain}    ${resp.json()['sector']}
    Set Suite Variable   ${subDomain}    ${resp.json()['subSector']}
    Should Be Equal As Strings    ${resp.status_code}   200


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
    ${DAY2}=  db.add_timezone_date  ${tz}  15  
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
    ${resp}=   Create Jaldee Coupon   ${cupn_codeG}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  60  ${bool[0]}  ${bool[0]}  100  150  1000  10  10  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}   ${domains}   ${sub_domains}   ALL  ${licenses}     targetDate=${targetDate}
    LOg   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon   ${cupn_codeG}   ${cupn_des}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Order Settings by account id
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableOrder']}==${bool[0]}
        ${resp1}=  Enable Order Settings 
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${displayName1}=   FakerLibrary.user name    
    ${price1}=  Evaluate    random.uniform(250,500)  
    ${itemCode1}=   FakerLibrary.word 

    ${cnames_len}=  Get Length  ${unique_cnames}
    FOR  ${i}  IN RANGE   ${cnames_len}
        ${kwstatus} 	${value} = 	Run Keyword And Ignore Error  List Should Contain Value   ${snames}   ${unique_cnames[${i}]}
        Log Many  ${kwstatus} 	${value}
        Continue For Loop If  '${kwstatus}' == 'PASS'
        &{dict}=  Create Dictionary   ${colnames[6]}=${unique_cnames[${i}]}
        ${ttype}=  getColumnValueByMultipleVals  ${sheet1}  ${colnames[1]}  &{dict}  
        Log  ${ttype}
        ${u_ttype}=    Remove Duplicates    ${ttype}
        Log  ${u_ttype}
        ${resp}=  Run Keyword If   '${kwstatus}' == 'FAIL' and '${QnrTransactionType[2]}' in @{u_ttype}  Create Sample Item   ${DisplayName1}   ${unique_cnames[${i}]}  ${itemCode1}  ${price1}  ${bool[1]}  
    END

    Set Suite Variable  ${item_id1}     ${resp.json()}

    ${resp}=   Get Item By Id    ${item_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Catalog By Criteria
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${c_len}=  Get Length  ${resp.json()}
    @{cnames}=  Create List
    FOR  ${i}  IN RANGE   ${c_len}
        Append To List  ${cnames}  ${resp.json()[${i}]['catalogName']}
    END
    
    FOR  ${i}  IN RANGE   ${cnames_len}
        ${kwstatus} 	${value} = 	Run Keyword And Ignore Error  List Should Contain Value  ${cnames}  ${unique_cnames[${i}]}
        Log Many  ${kwstatus} 	${value}
        Continue For Loop If  '${kwstatus}' == 'PASS'
        &{dict}=  Create Dictionary   ${colnames[6]}=${unique_cnames[${i}]}
        ${ttype}=  getColumnValueByMultipleVals  ${sheet1}  ${colnames[1]}  &{dict}  
        Log  ${ttype}
        ${u_ttype}=    Remove Duplicates    ${ttype}
        Log  ${u_ttype}
        ${CatalogId1}=  Run Keyword If   '${kwstatus}' == 'FAIL' and '${QnrTransactionType[2]}' in @{u_ttype}  Create Sample Catalog  ${unique_cnames[${i}]}   ${tz}  ${item_id1}  
    END
    Set Suite Variable  ${CatalogId1}

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${minNumberItem}  ${resp.json()['catalogItem'][0]['minQuantity']}
    Set Test Variable  ${maxNumberItem}  ${resp.json()['catalogItem'][0]['maxQuantity']}
    Set Test Variable  ${sTime}  ${resp.json()['catalogSchedule']['timeSlots'][0]['sTime']}
    Set Test Variable  ${eTime}  ${resp.json()['catalogSchedule']['timeSlots'][0]['eTime']}
    
    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${cookie}  ${resp}=  Imageupload.SALogin    ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Imageupload.UploadQuestionnaire   ${cookie}   ${account_id}   ${xlFile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME107}  ${PASSWORD}
    Log  ${resp.content}
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

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
      ${id}  Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[2]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}'  Set Variable  ${resp.json()[${i}]['id']} 
      ${qnrid}   Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[2]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}'  Set Variable  ${resp.json()[${i}]['questionnaireId']}
      Exit For Loop If   '${id}' != '${None}'
    END
    Set Suite Variable   ${id}
    Set Suite Variable   ${qnrid}

    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Set Suite Variable  ${pid}  ${qns.json()['transactionId']}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings  ${qns.json()['transactionId']}  ${pid}

    ${resp1}=  Run Keyword If   '${qns.json()['status']}' == '${status[1]}'  Provider Change Questionnaire Status  ${id}  ${status[0]}  
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200
    
    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings   ${qns.json()['status']}  ${status[0]}
    Set Suite Variable  ${Questionnaireid}  ${qns.json()['questionnaireId']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME29}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME29}  firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${proconid}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${proconid}  ${resp.json()[0]['id']}
    END

    ${DAY1}=  db.add_timezone_date  ${tz}   10
    ${pin}  ${city}  ${district}  ${state}=  get_pin_loc
    ${first} 	${rest} = 	Split String 	${fname}   max_split=1
    Set Test Variable  ${C_email}  ${first}${CUSERNAME29}.${test_mail}
    ${landMark}=  FakerLibrary.street name 
    ${address}=  Create Dictionary   phoneNumber=${CUSERNAME29}    firstName=${fname}   lastName=${lname}   email=${C_email}    address=${district}   city=${city}   postalCode=${pin}    landMark=${landMark}   countryCode=${countryCodes[0]}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minNumberItem}  max=${maxNumberItem}
    ${orderNote}=  FakerLibrary.Sentence   nb_words=5

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME107}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=     Get Provider service options for an item  ${item_id1}  ${QnrChannel[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    Should Be Equal As Strings   ${resp.json()['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${resp.json()['id']}   ${id}

    ${fudata}=  db.fileUploadDT   ${resp.json()}  ${FileAction[0]}  ${Questionnaireid}  ${pdffile}
    Log  ${fudata}
    ${data}=  db.QuestionnaireAnswers   ${resp.json()}   ${jdconID}   &{fudata}
    Log  ${data}
    ${data}=   setPrice  ${resp.json()}  ${data}
    Log  ${data}
    Set Suite Variable   ${data}
    ${resp}=  Provider Validate Questionnaire  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


    # ${resp}=   Create Order By Provider For HomeDelivery    ${cookie}  ${proconid}   ${proconid}   ${CatalogId1}   ${boolean[1]}   ${address}  ${sTime}    ${eTime}   ${DAY1}    ${CUSERNAME29}    ${C_email}  ${orderNote}  ${countryCodes[1]}  ${item_id1}   ${item_quantity1}  
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${orderid}=  Get Dictionary Values  ${resp.json()}
    # Set Suite Variable  ${orderid1}  ${orderid[0]}

    ${OrderDict}=    Order For Item   ${proconid}   ${proconid}   ${CatalogId1}   ${boolean[1]}   ${address}  ${sTime}    ${eTime}   ${DAY1}    ${CUSERNAME21}    ${C_email}  ${orderNote}  ${countryCodes[1]}  ${item_id1}   ${item_quantity1}  
    Log  ${OrderDict}

    ${resp}=  Create Order With Service Options    ${cookie}    order=${OrderDict}    srvAnswers=${data}
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

    # ${resp}=     Get Provider service options for an item  ${item_id1}  ${QnrChannel[0]}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # Should Be Equal As Strings   ${resp.json()['questionnaireId']}  ${qnrid}
    # Should Be Equal As Strings  ${resp.json()['id']}   ${id}

    # ${fudata}=  db.fileUploadDT   ${resp.json()}  ${FileAction[0]}  ${Questionnaireid}  ${pdffile}
    # Log  ${fudata}
    # ${data}=  db.QuestionnaireAnswers   ${resp.json()}   ${jdconID}   &{fudata}
    # Log  ${data}
    # ${data}=   setPrice  ${resp.json()}  ${data}
    # Log  ${data}
    # Set Suite Variable   ${data}
    # ${resp}=  Provider Validate Questionnaire  ${data}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Item By Id    ${item_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  '${resp.json()['promotionalPrice']}' == '${emptylist}'
        Set Suite Variable   ${itmprze}      ${resp.json()['price']}
    ELSE 
        Set Suite Variable   ${itmprze}      ${resp.json()['promotionalPrice']}
    END

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${qty}          ${resp.json()['orderItem'][0]['quantity']}
    ${itemttl}=     Evaluate    ${itmprze}*${qty}
    Set Suite Variable   ${dlryChrg}     ${resp.json()['deliveryCharge']}
    ${ttl}      Evaluate    ${itemttl}+${dlryChrg}
    # ${ttl}=     Convert To Number   ${ttl}   2
    Set Suite Variable   ${Servcost}     ${resp.json()['cartAmount']}
    # Should Be Equal As Strings      ${Servcost}     ${ttl}

    sleep  2s

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME107}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Imageupload.PSubmitSerOptForItem       ${cookie}  ${item_id1}  ${orderid1}   ${data}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Check Answers   ${resp}  ${data}
    Set Suite Variable  ${s1Price}      ${resp.json()['serviceOptions'][0]['questionAnswers'][0]['answerLine']['answer']['dataGridList'][0]['totalPrice']}
    Set Suite Variable  ${s2Price}      ${resp.json()['serviceOptions'][0]['questionAnswers'][1]['answerLine']['answer']['dataGridList'][0]['totalPrice']}
    ${ActualAmount}=    Evaluate    ${s1Price}+${s2Price}+${Servcost}
    ${ActualAmount}=     Convert To Number   ${ActualAmount}   2
    Set Suite Variable  ${CartAmountAS}   ${resp.json()['cartAmount']}
    Should Be Equal As Strings      ${CartAmountAS}   ${ActualAmount}

    ${resp}=  Get Bill By UUId  ${orderid1}
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

    ${resp}=  Apply Jaldee Coupon By Provider  ${cupn_codeG}  ${orderid1}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${orderid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-PaymentForItem-5
    [Documentation]  payment with coupon

    ${resp}=  Consumer Login  ${CUSERNAME34}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${jdconID}   ${resp.json()['id']}
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
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
    Set Suite Variable   ${catalognames}
    Remove Values From List  ${catalognames}   ${NONE}
    Log  ${catalognames}
    ${unique_cnames}=    Remove Duplicates    ${catalognames}
    Log  ${unique_cnames}
    Set Suite Variable   ${unique_cnames}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME117}  ${PASSWORD}
    Log  ${resp.content}
    Set Suite Variable   ${domain}    ${resp.json()['sector']}
    Set Suite Variable   ${subDomain}    ${resp.json()['subSector']}
    Should Be Equal As Strings    ${resp.status_code}   200


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
    ${DAY2}=  db.add_timezone_date  ${tz}  15  
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
    ${resp}=   Create Jaldee Coupon   ${cupn_codeG}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  60  ${bool[0]}  ${bool[0]}  50  100  1000  10  10  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}   ${domains}   ${sub_domains}   ALL  ${licenses}     targetDate=${targetDate}
    LOg   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon   ${cupn_codeG}   ${cupn_des}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Order Settings by account id
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableOrder']}==${bool[0]}
        ${resp1}=  Enable Order Settings 
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${displayName1}=   FakerLibrary.user name    
    ${price1}=  Evaluate    random.uniform(250,500) 
    ${itemCode1}=   FakerLibrary.word 

    ${cnames_len}=  Get Length  ${unique_cnames}
    FOR  ${i}  IN RANGE   ${cnames_len}
        ${kwstatus} 	${value} = 	Run Keyword And Ignore Error  List Should Contain Value   ${snames}   ${unique_cnames[${i}]}
        Log Many  ${kwstatus} 	${value}
        Continue For Loop If  '${kwstatus}' == 'PASS'
        &{dict}=  Create Dictionary   ${colnames[6]}=${unique_cnames[${i}]}
        ${ttype}=  getColumnValueByMultipleVals  ${sheet1}  ${colnames[1]}  &{dict}  
        Log  ${ttype}
        ${u_ttype}=    Remove Duplicates    ${ttype}
        Log  ${u_ttype}
        ${resp}=  Run Keyword If   '${kwstatus}' == 'FAIL' and '${QnrTransactionType[2]}' in @{u_ttype}  Create Sample Item   ${DisplayName1}   ${unique_cnames[${i}]}  ${itemCode1}  ${price1}  ${bool[0]}  
    END

    Set Suite Variable  ${item_id1}     ${resp.json()}

    ${resp}=   Get Item By Id    ${item_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Catalog By Criteria
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${c_len}=  Get Length  ${resp.json()}
    @{cnames}=  Create List
    FOR  ${i}  IN RANGE   ${c_len}
        Append To List  ${cnames}  ${resp.json()[${i}]['catalogName']}
    END
    
    FOR  ${i}  IN RANGE   ${cnames_len}
        ${kwstatus} 	${value} = 	Run Keyword And Ignore Error  List Should Contain Value  ${cnames}  ${unique_cnames[${i}]}
        Log Many  ${kwstatus} 	${value}
        Continue For Loop If  '${kwstatus}' == 'PASS'
        &{dict}=  Create Dictionary   ${colnames[6]}=${unique_cnames[${i}]}
        ${ttype}=  getColumnValueByMultipleVals  ${sheet1}  ${colnames[1]}  &{dict}  
        Log  ${ttype}
        ${u_ttype}=    Remove Duplicates    ${ttype}
        Log  ${u_ttype}
        ${CatalogId1}=  Run Keyword If   '${kwstatus}' == 'FAIL' and '${QnrTransactionType[2]}' in @{u_ttype}  Create Sample Catalog  ${unique_cnames[${i}]}   ${tz}  ${item_id1}  
    END
    Set Suite Variable  ${CatalogId1}

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${minNumberItem}  ${resp.json()['catalogItem'][0]['minQuantity']}
    Set Test Variable  ${maxNumberItem}  ${resp.json()['catalogItem'][0]['maxQuantity']}
    Set Test Variable  ${sTime}  ${resp.json()['catalogSchedule']['timeSlots'][0]['sTime']}
    Set Test Variable  ${eTime}  ${resp.json()['catalogSchedule']['timeSlots'][0]['eTime']}
    
    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${cookie}  ${resp}=  Imageupload.SALogin    ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Imageupload.UploadQuestionnaire   ${cookie}   ${account_id}   ${xlFile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME117}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
      ${id}  Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[2]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}'  Set Variable  ${resp.json()[${i}]['id']} 
      ${qnrid}   Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[2]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}'  Set Variable  ${resp.json()[${i}]['questionnaireId']}
      Exit For Loop If   '${id}' != '${None}'
    END
    Set Suite Variable   ${id}
    Set Suite Variable   ${qnrid}

    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Set Suite Variable  ${pid}  ${qns.json()['transactionId']}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings  ${qns.json()['transactionId']}  ${pid}

    ${resp1}=  Run Keyword If   '${qns.json()['status']}' == '${status[1]}'  Provider Change Questionnaire Status  ${id}  ${status[0]}  
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200
    
    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings   ${qns.json()['status']}  ${status[0]}
    Set Suite Variable  ${Questionnaireid}  ${qns.json()['questionnaireId']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME34}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME34}  firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${proconid}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${proconid}  ${resp.json()[0]['id']}
    END

    ${DAY1}=  db.add_timezone_date  ${tz}   10
    ${pin}  ${city}  ${district}  ${state}=  get_pin_loc
    ${first} 	${rest} = 	Split String 	${fname}   max_split=1
    Set Test Variable  ${C_email}  ${first}${CUSERNAME34}.${test_mail}
    ${landMark}=  FakerLibrary.street name 
    ${address}=  Create Dictionary   phoneNumber=${CUSERNAME34}    firstName=${fname}   lastName=${lname}   email=${C_email}    address=${district}   city=${city}   postalCode=${pin}    landMark=${landMark}   countryCode=${countryCodes[0]}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minNumberItem}  max=${maxNumberItem}
    ${orderNote}=  FakerLibrary.Sentence   nb_words=5

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME117}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=     Get Provider service options for an item  ${item_id1}  ${QnrChannel[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    Should Be Equal As Strings   ${resp.json()['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${resp.json()['id']}   ${id}

    ${fudata}=  db.fileUploadDT   ${resp.json()}  ${FileAction[0]}  ${Questionnaireid}  ${pdffile}
    Log  ${fudata}
    ${data}=  db.QuestionnaireAnswers   ${resp.json()}   ${jdconID}   &{fudata}
    Log  ${data}
    ${data}=   setPrice  ${resp.json()}  ${data}
    Log  ${data}
    Set Suite Variable   ${data}
    ${resp}=  Provider Validate Questionnaire  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=   Create Order By Provider For HomeDelivery    ${cookie}  ${proconid}   ${proconid}   ${CatalogId1}   ${boolean[1]}   ${address}  ${sTime}    ${eTime}   ${DAY1}    ${CUSERNAME34}    ${C_email}  ${orderNote}  ${countryCodes[1]}  ${item_id1}   ${item_quantity1}  
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${orderid}=  Get Dictionary Values  ${resp.json()}
    # Set Suite Variable  ${orderid1}  ${orderid[0]}

    ${OrderDict}=    Order For Item   ${proconid}   ${proconid}   ${CatalogId1}   ${boolean[1]}   ${address}  ${sTime}    ${eTime}   ${DAY1}    ${CUSERNAME21}    ${C_email}  ${orderNote}  ${countryCodes[1]}  ${item_id1}   ${item_quantity1}  
    Log  ${OrderDict}

    ${resp}=  Create Order With Service Options    ${cookie}    order=${OrderDict}    srvAnswers=${data}
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

    # ${resp}=     Get Provider service options for an item  ${item_id1}  ${QnrChannel[0]}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # Should Be Equal As Strings   ${resp.json()['questionnaireId']}  ${qnrid}
    # Should Be Equal As Strings  ${resp.json()['id']}   ${id}

    # ${fudata}=  db.fileUploadDT   ${resp.json()}  ${FileAction[0]}  ${Questionnaireid}  ${pdffile}
    # Log  ${fudata}
    # ${data}=  db.QuestionnaireAnswers   ${resp.json()}   ${jdconID}   &{fudata}
    # Log  ${data}
    # ${data}=   setPrice  ${resp.json()}  ${data}
    # Log  ${data}
    # Set Suite Variable   ${data}
    # ${resp}=  Provider Validate Questionnaire  ${data}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Item By Id    ${item_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  '${resp.json()['promotionalPrice']}' == '${emptylist}'
        Set Suite Variable   ${itmprze}      ${resp.json()['price']}
    ELSE 
        Set Suite Variable   ${itmprze}      ${resp.json()['promotionalPrice']}
    END

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${qty}          ${resp.json()['orderItem'][0]['quantity']}
    ${itemttl}=     Evaluate    ${itmprze}*${qty}
    Set Suite Variable   ${dlryChrg}     ${resp.json()['deliveryCharge']}
    ${ttl}      Evaluate    ${itemttl}+${dlryChrg}
    # ${ttl}=     Convert To Number   ${ttl}   2
    Set Suite Variable   ${Servcost}     ${resp.json()['cartAmount']}
    # Should Be Equal As Strings      ${Servcost}     ${ttl}

    sleep  2s

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME117}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Imageupload.PSubmitSerOptForItem       ${cookie}  ${item_id1}  ${orderid1}   ${data}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Check Answers   ${resp}  ${data}
    Set Suite Variable  ${s1Price}      ${resp.json()['serviceOptions'][0]['questionAnswers'][0]['answerLine']['answer']['dataGridList'][0]['totalPrice']}
    Set Suite Variable  ${s2Price}      ${resp.json()['serviceOptions'][0]['questionAnswers'][1]['answerLine']['answer']['dataGridList'][0]['totalPrice']}
    ${ActualAmount}=    Evaluate    ${s1Price}+${s2Price}+${Servcost}
    ${ActualAmount}=     Convert To Number   ${ActualAmount}   2
    Set Suite Variable  ${CartAmountAS}   ${resp.json()['cartAmount']}
    Should Be Equal As Strings      ${CartAmountAS}   ${ActualAmount}

    ${resp}=  Get Bill By UUId  ${orderid1}
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

    ${resp}=  Apply Jaldee Coupon By Provider  ${cupn_codeG}  ${orderid1}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${orderid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200