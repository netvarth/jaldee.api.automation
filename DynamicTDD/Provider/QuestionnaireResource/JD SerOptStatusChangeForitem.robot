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
                    Run Keyword And Continue On Failure  Should Be Equal As Strings  '${resp.json()['serviceOption']['questionAnswers'][${i}]['answerLine']['answer']['${QnrDatatypes[8]}'][0]['dataGridListColumn'][${j}]['column']['${QnrDatatypes[5]}'][0]['status']}'   '${QnrStatus[1]}'
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

JD-TC-ProviderStatusChangeForServiceOptionForItem-1
    [Documentation]  change answer status

    clear_customer   ${PUSERNAME50}

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
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

    ${resp}=  Provider Login  ${PUSERNAME50}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}
  
    ${resp}=  Get Order Settings by account id
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp1}=  Run Keyword If  ${resp.json()['enableOrder']}==${bool[0]}   Enable Order Settings   
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${s_len}=  Get Length  ${resp.json()}
    @{snames}=  Create List
    FOR  ${i}  IN RANGE   ${s_len}
        IF  '${resp.json()[${i}]['name']}' in @{unique_cnames} and '${resp.json()[${i}]['serviceType']}' == '${service_type[2]}'
            ${s_id}=  Set Variable   ${resp.json()[${i}]['id']}
        ELSE
            Append To List  ${snames}  ${resp.json()[${i}]['name']}
        END
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
        ${CatalogId1}=  Run Keyword If   '${kwstatus}' == 'FAIL' and '${QnrTransactionType[2]}' in @{u_ttype}  Create Sample Catalog  ${unique_cnames[${i}]}  ${item_id1}  
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

    ${resp}=  ProviderLogin  ${PUSERNAME50}  ${PASSWORD}
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
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings  ${qns.json()['transactionId']}  ${item_id1} 

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

    ${DAY1}=  add_date   12
    ${pin}  ${city}  ${district}  ${state}=  get_pin_loc
    ${first}= 	Split String 	${fname}   max_split=1
    Set Test Variable  ${C_email}  ${first[0]}${CUSERNAME21}.${test_mail}
    ${landMark}=  FakerLibrary.street name 
    ${address}=  Create Dictionary   phoneNumber=${CUSERNAME21}    firstName=${fname}   lastName=${lname}   email=${C_email}    address=${district}   city=${city}   postalCode=${pin}    landMark=${landMark}   countryCode=${countryCodes[0]}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minNumberItem}  max=${maxNumberItem}
    ${orderNote}=  FakerLibrary.Sentence   nb_words=5

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME50}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Create Order By Provider For HomeDelivery    ${cookie}  ${proconid}   ${proconid}   ${CatalogId1}   ${boolean[1]}   ${address}  ${sTime}    ${eTime}   ${DAY1}    ${CUSERNAME21}    ${C_email}  ${orderNote}  ${countryCodes[1]}  ${item_id1}   ${item_quantity1}  
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

    ${resp}=   Get Item By Id    ${item_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200    

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${qty}          ${resp.json()['orderItem'][0]['quantity']}

    sleep  2s

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME50}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Imageupload.PSubmitSerOptForItem       ${cookie}  ${item_id1}  ${orderid1}   ${data}  ${pdffile}
    Log  ${resp.content}
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

    ${resp}=   Change Provider Status Of Service Option Item  ${orderid1}  @{files_data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Check Answers   ${resp}  ${data}

    ${resp}=  Imageupload.PResubmitSerOptForItem       ${cookie}  ${orderid1}   ${data}  ${pdffile}
    Log  ${resp.content}
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

    ${resp}=   Change Provider Status Of Service Option Item  ${orderid1}  @{files_data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Check Answers   ${resp}  ${data}


JD-TC-ProviderServiceOptionForOrder-2
    [Documentation]  Change Answer status with invalid orderid

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME50}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${inv_odr}=  Generate Random String  16  [LETTERS][NUMBERS]

    ${resp}=  Imageupload.PSubmitSerOptForItem       ${cookie}  ${item_id1}  ${orderid1}   ${data}  ${pdffile}
    Log  ${resp.content}
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

    ${resp}=   Change Provider Status Of Service Option Item  ${inv_odr}  @{files_data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.json()}      ${SESSION_EXPIRED}

# JD-TC-ProviderServiceOptionForOrder-3
#     [Documentation]  Get service optionChange Answer status for Item  Where order is started
#     clear_customer   ${PUSERNAME125}
#     clear_Catalog   ${PUSERNAME125}
    

#     ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Consumer Logout
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${wb}=  readWorkbook  ${xlFile}
#     ${sheet1}  GetCurrentSheet   ${wb}
#     Set Suite Variable   ${sheet1}
#     ${colnames}=  getColumnHeaders  ${sheet1}
#     Log List  ${colnames}
#     Log List  ${QnrChannel}
#     Log List  ${QnrTransactionType}
#     Set Suite Variable   ${colnames}
#     ${catalognames1}   getColumnValuesByName  ${sheet1}  ${colnames[6]}
#     Log   ${catalognames1}
#     Remove Values From List  ${catalognames1}   ${NONE}
#     Log  ${catalognames1}
#     ${unique_cnames}=    Remove Duplicates    ${catalognames1}
#     Log  ${unique_cnames}
#     Set Suite Variable   ${unique_cnames}

#     ${resp}=  Provider Login  ${PUSERNAME125}  ${PASSWORD}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=  Get Business Profile
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${account_id}  ${resp.json()['id']}
  
#     ${resp}=  Get Order Settings by account id
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp1}=  Run Keyword If  ${resp.json()['enableOrder']}==${bool[0]}   Enable Order Settings
#     Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
#     Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

#     ${displayName1}=   FakerLibrary.user name    
#     ${price1}=  Evaluate    random.uniform(50.0,300) 
#     ${itemName2}=   FakerLibrary.name    
#     ${itemCode2}=   FakerLibrary.word 
#     ${resp}=  Create Sample Item   ${DisplayName1}   ${itemName2}  ${itemCode2}  ${price1}  ${bool[0]}     
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${item_id2}  ${resp.json()}

#     ${resp}=   Get Item By Id    ${item_id2}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=   Get Catalog By Criteria
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${c_len}=  Get Length  ${resp.json()}
#     @{cnames}=  Create List
#     FOR  ${i}  IN RANGE   ${c_len}
#         Append To List  ${cnames}  ${resp.json()[${i}]['catalogName']}
#     END

    
#     ${cnames_len}=  Get Length  ${unique_cnames}
#     FOR  ${i}  IN RANGE   ${cnames_len}
#         ${kwstatus} 	${value} = 	Run Keyword And Ignore Error  List Should Contain Value  ${cnames}  ${unique_cnames[${i}]}
#         Log Many  ${kwstatus} 	${value}
#         Continue For Loop If  '${kwstatus}' == 'PASS'
#         &{dict}=  Create Dictionary   ${colnames[6]}=${unique_cnames[${i}]}
#         ${ttype}=  getColumnValueByMultipleVals  ${sheet1}  ${colnames[1]}  &{dict}  
#         Log  ${ttype}
#         ${u_ttype}=    Remove Duplicates    ${ttype}
#         Log  ${u_ttype}
#         ${CatalogId1}=  Run Keyword If   '${kwstatus}' == 'FAIL' and '${QnrTransactionType[8]}' in @{u_ttype}  Create Sample Catalog  ${unique_cnames[${i}]}  ${item_id2}  
#     END
#     Set Suite Variable  ${CatalogId1}

#     ${resp}=  Get Order Catalog    ${CatalogId1}  
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Suite Variable  ${minNumberItem}  ${resp.json()['catalogItem'][0]['minQuantity']}
#     Set Suite Variable  ${maxNumberItem}  ${resp.json()['catalogItem'][0]['maxQuantity']}
#     Set Suite Variable  ${sTime}  ${resp.json()['catalogSchedule']['timeSlots'][0]['sTime']}
#     Set Suite Variable  ${eTime}  ${resp.json()['catalogSchedule']['timeSlots'][0]['eTime']}

#     ${resp}=  Provider Logout
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${cookie}  ${resp}=  Imageupload.SALogin    ${SUSERNAME}  ${SPASSWORD}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Imageupload.UploadQuestionnaire   ${cookie}   ${account_id}   ${xlFile}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  ProviderLogin  ${PUSERNAME125}  ${PASSWORD}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Get Questionnaire List By Provider   
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${len}=  Get Length  ${resp.json()}
#     FOR  ${i}  IN RANGE   ${len}
#       ${id}  Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[8]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}'  Set Variable  ${resp.json()[${i}]['id']} 
#       ${qnrid1}   Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[8]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}'  Set Variable  ${resp.json()[${i}]['questionnaireId']}
#       Exit For Loop If   '${id}' != '${None}'
#     END
#     Set Suite Variable   ${id}
#     Set Suite Variable   ${qnrid1}

#     ${qns}   Get Provider Questionnaire By Id   ${id}  
#     Log  ${qns.content}
#     Should Be Equal As Strings  ${qns.status_code}  200
#     Should Be Equal As Strings  ${qns.json()['transactionId']}  ${catalogid1}

#     ${resp1}=  Run Keyword If   '${qns.json()['status']}' == '${status[1]}'  Provider Change Questionnaire Status  ${id}  ${status[0]}  
#     Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
#     Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200
    
#     ${qns}   Get Provider Questionnaire By Id   ${id}  
#     Log  ${qns.content}
#     Should Be Equal As Strings  ${qns.status_code}  200
#     Should Be Equal As Strings   ${qns.json()['status']}  ${status[0]}

#     ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME20}  
#     Log  ${resp.content}
#     Should Be Equal As Strings      ${resp.status_code}  200
#     IF   '${resp.content}' == '${emptylist}'
#         ${resp1}=  AddCustomer  ${CUSERNAME20}  firstName=${fname}   lastName=${lname}
#         Log  ${resp1.content}
#         Should Be Equal As Strings  ${resp1.status_code}  200
#         Set Suite Variable  ${proconid}   ${resp1.json()}
#     ELSE
#         Set Suite Variable  ${proconid}  ${resp.json()[0]['id']}
#     END

#     ${DAY1}=  add_date   12
#     ${pin}  ${city}  ${district}  ${state}=  get_pin_loc
#     ${first}= 	Split String 	${fname}
#     Set Test Variable  ${C_email}  ${first[0]}${CUSERNAME20}.${test_mail}
#     ${landMark}=  FakerLibrary.street name 
#     ${address}=  Create Dictionary   phoneNumber=${CUSERNAME20}    firstName=${fname}   lastName=${lname}   email=${C_email}    address=${district}   city=${city}   postalCode=${pin}    landMark=${landMark}   countryCode=${countryCodes[0]}
#     ${item_quantity2}=  FakerLibrary.Random Int  min=${minNumberItem}  max=${maxNumberItem}
#     ${orderNote}=  FakerLibrary.Sentence   nb_words=5

#     ${resp}=   Get Item By Id    ${item_id2}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${cookie1}  ${resp}=   Imageupload.spLogin  ${PUSERNAME125}  ${PASSWORD}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=   Get Item By Id    ${item_id2}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=   Create Order By Provider For HomeDelivery    ${cookie1}  ${proconid}   ${proconid}   ${CatalogId1}   ${boolean[1]}   ${address}  ${sTime}    ${eTime}   ${DAY1}    ${CUSERNAME20}    ${C_email}  ${orderNote}  ${countryCodes[1]}  ${item_id2}   ${item_quantity2}  
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${orderid}=  Get Dictionary Values  ${resp.json()}
#     Set Suite Variable  ${orderid1}  ${orderid[0]}

#     ${resp}=   Get Order by uid    ${orderid1}  
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Should Be Equal As Strings  ${resp.json()['uid']}                     ${orderid1}
#     Should Be Equal As Strings  ${resp.json()['homeDelivery']}            ${bool[1]} 
#     Should Be Equal As Strings  ${resp.json()['storePickup']}             ${bool[0]}
#     Should Be Equal As Strings  ${resp.json()['orderStatus']}             ${orderStatuses[0]}

