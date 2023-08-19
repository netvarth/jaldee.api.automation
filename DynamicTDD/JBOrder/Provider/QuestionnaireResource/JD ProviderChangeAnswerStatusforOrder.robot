*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Run Keywords  Delete All Sessions
Force Tags        Questionnaire
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           OperatingSystem
Library           /ebs/TDD/excelfuncs.py
Resource          /ebs/TDD/SuperAdminKeywords.robot
Resource          /ebs/TDD/Keywords.robot      
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

*** Variables ***
${xlFile}      ${EXECDIR}/TDD/Order_qnr.xlsx    # DataSheet
${jpgfile}     /ebs/TDD/uploadimage.jpg
${pngfile}     /ebs/TDD/upload.png
${pdffile}     /ebs/TDD/sample.pdf
${mp4file}   /ebs/TDD/MP4file.mp4
${avifile}   /ebs/TDD/AVIfile.avi
${mp3file}   /ebs/TDD/MP3file.mp3
${self}      0
@{emptylist}



*** Keywords ***
Get Order Time
    [Arguments]   ${i}   ${resp}
    @{stimes}=  Create List
    @{etimes}=  Create List
    ${len}=  Get Length  ${resp.json()[${i}]['timeSlots']}
    FOR  ${j}  IN RANGE  0    ${len}
      
        Append To List   ${stimes}   ${resp.json()[${i}]['timeSlots'][${j}]['sTime']}
        Append To List   ${etimes}   ${resp.json()[${i}]['timeSlots'][${j}]['eTime']}
    END
    [Return]    ${stimes}     ${etimes}


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
JD-TC-ChangeAnswerStatusForOrder-1
    [Documentation]  change answer status for order taken from provider side
    
    ${resp}=  Consumer Login  ${CUSERNAME21}  ${PASSWORD}
    Log  ${resp.content}
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

    ${resp}=  Provider Login  ${PUSERNAME138}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Set Suite Variable  ${pid1}  ${resp.json()['id']}

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}

    ${resp}=  Get Order Settings by account id
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableOrder']}==${bool[0]}
        ${resp1}=  Enable Order Settings 
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${displayName1}=   FakerLibrary.user name    
    ${price1}=  Evaluate    random.uniform(50.0,300) 
    ${itemName1}=   FakerLibrary.name    
    ${itemCode1}=   FakerLibrary.word 
    ${resp}=  Create Sample Item   ${displayName1}   ${itemName1}  ${itemCode1}  ${price1}  ${bool[0]}     
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id1}  ${resp.json()}

    ${resp}=   Get Item By Id    ${item_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Catalog By Criteria  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${c_len}=  Get Length  ${resp.json()}
    @{cnames}=  Create List
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
            ${CatalogId1}=  Run Keyword If   '${kwstatus}' == 'FAIL' and '${QnrTransactionType[8]}' in @{u_ttype}  Create Sample Catalog  ${unique_cnames[${i}]}    ${item_id1}
   
        END
    END

    Set Suite Variable   ${CatalogId1}

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

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${sa_resp}=  Get Questionnaire List   ${account_id}  
    Log  ${sa_resp.content}
    Should Be Equal As Strings  ${sa_resp.status_code}  200
    ${len}=  Get Length  ${sa_resp.json()}

    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogin  ${PUSERNAME138}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
      ${id}  Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[8]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}'  Set Variable  ${resp.json()[${i}]['id']} 
      ${qnrid}   Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[8]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}'  Set Variable  ${resp.json()[${i}]['questionnaireId']}
      Exit For Loop If   '${id}' != '${None}'
    END
    Set Suite Variable   ${id}
    Set Suite Variable   ${qnrid}

    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings  ${qns.json()['transactionId']}  ${CatalogId1}
    Set Suite Variable  ${Questionnaireid}  ${qns.json()['questionnaireId']}

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
        Set Suite Variable  ${cid21}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${cid21}  ${resp.json()[0]['id']}
    END

    ${DAY1}=   db.get_date
    ${pin}  ${city}  ${district}  ${state}=  get_pin_loc
    ${first}= 	Split String 	${fname}
    Set Test Variable  ${C_email}  ${first[0]}${CUSERNAME21}.${test_mail}
    ${landMark}=  FakerLibrary.street name 
    ${address}=  Create Dictionary   phoneNumber=${CUSERNAME21}    firstName=${fname}   lastName=${lname}   email=${C_email}    address=${district}   city=${city}   postalCode=${pin}    landMark=${landMark}   countryCode=${countryCodes[0]}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minNumberItem}  max=${maxNumberItem-1}
    ${orderNote}=  FakerLibrary.Sentence   nb_words=5

    # ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME21}   ${PASSWORD}
    # Log  ${resp.content}
    # Should Be Equal As Strings   ${resp.status_code}    200

    # ${resp}=   Create Order For HomeDelivery   ${cookie}   ${account_id}    ${self}    ${CatalogId1}   ${bool[1]}    ${address}    ${sTime}    ${eTime}   ${DAY1}    ${CUSERNAME21}    ${C_email}  ${countryCodes[1]}  ${EMPTY_List}   ${item_id1}    ${item_quantity1} 
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${orderid}=  Get Dictionary Values  ${resp.json()}
    # Set Suite Variable  ${orderid1}  ${orderid[0]}

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME138}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Create Order By Provider For HomeDelivery    ${cookie}  ${cid21}   ${cid21}   ${CatalogId1}   ${boolean[1]}   ${address}  ${sTime}    ${eTime}   ${DAY1}    ${CUSERNAME21}    ${C_email}  ${orderNote}  ${countryCodes[1]}  ${item_id1}   ${item_quantity1}  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid1}  ${orderid[0]}

    ${resp}=   Get Order by uid    ${orderid1} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
       
    Should Be Equal As Strings  ${resp.json()['uid']}   ${orderid1}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}   ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}    ${bool[0]}

    ${resp}=  Get Consumer Questionnaire By Channel and OrderID    ${CatalogId1}   ${QnrChannel[0]}     ${cid21}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${resp.json()['id']}   ${id}

    ${fudata}=  db.fileUploadDT   ${resp.json()}  ${FileAction[0]}  ${Questionnaireid}  ${pdffile}
    Log  ${fudata}
    ${data}=  db.QuestionnaireAnswers   ${resp.json()}   ${cid21}   &{fudata}
    Log  ${data}
    Set Suite Variable   ${data}
    ${resp}=  Provider Validate Questionnaire  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME138}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Imageupload.POrderQAnsUpload   ${cookie}  ${orderid1}   ${data}  ${pdffile}
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

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Check Answers   ${resp}  ${data}  ${QnrStatus[0]}  ${QnrStatus[0]}

    ${resp}=    Provider Change Answer Status for order   ${orderid1}   @{files_data}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Check Answers   ${resp}  ${data}   


JD-TC-ChangeAnswerStatusForOrder-2
    [Documentation]  change answer status for order taken from consumer side
    
    # ${resp}=  Consumer Login  ${CUSERNAME21}  ${PASSWORD}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${jdconID}   ${resp.json()['id']}
    # Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    # Set Suite Variable  ${lname}   ${resp.json()['lastName']}

    # ${resp}=  Consumer Logout
    # Should Be Equal As Strings    ${resp.status_code}    200
    
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

    ${resp}=  Provider Login  ${PUSERNAME138}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Set Suite Variable  ${pid1}  ${resp.json()['id']}

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}

    ${resp}=  Get Order Settings by account id
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableOrder']}==${bool[0]}
        ${resp1}=  Enable Order Settings 
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${displayName1}=   FakerLibrary.user name    
    ${price1}=  Evaluate    random.uniform(50.0,300) 
    ${itemName1}=   FakerLibrary.name    
    ${itemCode1}=   FakerLibrary.word 
    ${resp}=  Create Sample Item   ${displayName1}   ${itemName1}  ${itemCode1}  ${price1}  ${bool[0]}     
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id1}  ${resp.json()}

    ${resp}=   Get Item By Id    ${item_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Catalog By Criteria  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${c_len}=  Get Length  ${resp.json()}
    @{cnames}=  Create List
    FOR  ${i}  IN RANGE   ${c_len}
        IF   '${resp.json()[${i}]['catalogName']}' in @{unique_cnames} and '${resp.json()[${i}]['orderType']}' == '${OrderTypes[0]}'
            ${CatalogId1}=   Set Variable   ${resp.json()[${i}]['id']}
        # ELSE
        #     Append To List  ${cnames}  ${resp.json()[${i}]['catalogName']}
        END
    END

    ${cat_val}=    Get Variable Value    ${CatalogId1}
    
    # IF  '${cat_val}'=='${None}'
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
    #         ${CatalogId1}=  Run Keyword If   '${kwstatus}' == 'FAIL' and '${QnrTransactionType[8]}' in @{u_ttype}  Create Sample Catalog  ${unique_cnames[${i}]}    ${item_id1}
   
    #     END
    # END

    # Set Suite Variable   ${CatalogId1}

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${minNumberItem}  ${resp.json()['catalogItem'][0]['minQuantity']}
    # Set Test Variable  ${maxNumberItem}  ${resp.json()['catalogItem'][0]['maxQuantity']}
    # Set Test Variable  ${sTime}  ${resp.json()['catalogSchedule']['timeSlots'][0]['sTime']}
    # Set Test Variable  ${eTime}  ${resp.json()['catalogSchedule']['timeSlots'][0]['eTime']}
    Set Test Variable  ${old_item_id}  ${resp.json()['catalogItem'][0]['item']['itemId']}

    ${resp}=  Remove Single Item From Catalog    ${CatalogId1}    ${old_item_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${minQ1}=  Random Int  min=1   max=5
    ${maxQ1}=  Random Int  min=${minQ1+2}   max=20
    ${item1_Id}=  Create Dictionary  itemId=${item_id1}
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQ1}   maxQuantity=${maxQ1}    
    ${Items_list}=  Create List   ${catalogItem1}
    ${resp}=  Add Items To Catalog    ${CatalogId1}    ${Items_list}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${minNumberItem}  ${resp.json()['catalogItem'][0]['minQuantity']}
    Set Test Variable  ${maxNumberItem}  ${resp.json()['catalogItem'][0]['maxQuantity']}
    Set Test Variable  ${sTime}  ${resp.json()['catalogSchedule']['timeSlots'][0]['sTime']}
    Set Test Variable  ${eTime}  ${resp.json()['catalogSchedule']['timeSlots'][0]['eTime']}
    
    # ${resp}=  Provider Logout
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${cookie}  ${resp}=  Imageupload.SALogin    ${SUSERNAME}  ${SPASSWORD}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Imageupload.UploadQuestionnaire   ${cookie}   ${account_id}   ${xlFile}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${sa_resp}=  Get Questionnaire List   ${account_id}  
    # Log  ${sa_resp.content}
    # Should Be Equal As Strings  ${sa_resp.status_code}  200
    # ${len}=  Get Length  ${sa_resp.json()}

    # ${resp}=  SuperAdmin Logout 
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  ProviderLogin  ${PUSERNAME138}  ${PASSWORD}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
      ${id}  Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[8]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}'  Set Variable  ${resp.json()[${i}]['id']} 
      ${qnrid}   Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[8]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}'  Set Variable  ${resp.json()[${i}]['questionnaireId']}
      Exit For Loop If   '${id}' != '${None}'
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

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME21}
    # Log  ${resp.content}
    # Should Be Equal As Strings      ${resp.status_code}  200
    # IF   '${resp.content}' == '${emptylist}'
    #     ${resp1}=  AddCustomer  ${CUSERNAME21}  firstName=${fname}   lastName=${lname}
    #     Log  ${resp1.content}
    #     Should Be Equal As Strings  ${resp1.status_code}  200
    #     Set Suite Variable  ${cid21}   ${resp1.json()}
    # ELSE
    #     Set Suite Variable  ${cid21}  ${resp.json()[0]['id']}
    # END

    ${resp}=  Consumer Login  ${CUSERNAME21}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${jdconID}   ${resp.json()['id']}
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}


    ${DAY1}=   db.get_date
    ${pin}  ${city}  ${district}  ${state}=  get_pin_loc
    ${first}= 	Split String 	${fname}
    Set Test Variable  ${C_email}  ${first[0]}${CUSERNAME21}.${test_mail}
    ${landMark}=  FakerLibrary.street name 
    ${address}=  Create Dictionary   phoneNumber=${CUSERNAME21}    firstName=${fname}   lastName=${lname}   email=${C_email}    address=${district}   city=${city}   postalCode=${pin}    landMark=${landMark}   countryCode=${countryCodes[0]}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minNumberItem}  max=${maxNumberItem-1}
    ${orderNote}=  FakerLibrary.Sentence   nb_words=5

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME21}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For HomeDelivery   ${cookie}   ${account_id}    ${self}    ${CatalogId1}   ${bool[1]}    ${address}    ${sTime}    ${eTime}   ${DAY1}    ${CUSERNAME21}    ${C_email}  ${countryCodes[1]}  ${EMPTY_List}   ${item_id1}    ${item_quantity1} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid1}  ${orderid[0]}

    # ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME138}  ${PASSWORD}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=   Create Order By Provider For HomeDelivery    ${cookie}  ${cid21}   ${cid21}   ${CatalogId1}   ${boolean[1]}   ${address}  ${sTime}    ${eTime}   ${DAY1}    ${CUSERNAME21}    ${C_email}  ${orderNote}  ${countryCodes[1]}  ${item_id1}   ${item_quantity1}  
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${orderid}=  Get Dictionary Values  ${resp.json()}
    # Set Suite Variable  ${orderid1}  ${orderid[0]}

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Provider Login  ${PUSERNAME138}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get Order by uid    ${orderid1} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
       
    Should Be Equal As Strings  ${resp.json()['uid']}   ${orderid1}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}   ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}    ${bool[0]}

    ${resp}=  Get Consumer Questionnaire By Channel and OrderID    ${CatalogId1}   ${QnrChannel[0]}     ${cid21}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${resp.json()['id']}   ${id}

    ${fudata}=  db.fileUploadDT   ${resp.json()}  ${FileAction[0]}  ${Questionnaireid}  ${pdffile}
    Log  ${fudata}
    ${data}=  db.QuestionnaireAnswers   ${resp.json()}   ${jdconID}   &{fudata}
    Log  ${data}
    Set Suite Variable   ${data}
    ${resp}=  Provider Validate Questionnaire  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME138}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Imageupload.POrderQAnsUpload   ${cookie}  ${orderid1}   ${data}  ${pdffile}
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

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Check Answers   ${resp}  ${data}  ${QnrStatus[0]}  ${QnrStatus[0]}

    ${resp}=    Provider Change Answer Status for order   ${orderid1}   @{files_data}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Check Answers   ${resp}  ${data}   


JD-TC-ChangeAnswerStatusForOrder-3
    [Documentation]  change answer status after resubmitting answers
    
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

    ${resp}=  Provider Login  ${PUSERNAME138}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}

    ${resp}=  Get Order Settings by account id
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableOrder']}==${bool[0]}
        ${resp1}=  Enable Order Settings 
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${displayName1}=   FakerLibrary.user name    
    ${price1}=  Evaluate    random.uniform(50.0,300) 
    ${itemName1}=   FakerLibrary.name    
    ${itemCode1}=   FakerLibrary.word 
    ${resp}=  Create Sample Item   ${displayName1}   ${itemName1}  ${itemCode1}  ${price1}  ${bool[0]}     
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id1}  ${resp.json()}

    ${resp}=   Get Item By Id    ${item_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Catalog By Criteria  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${c_len}=  Get Length  ${resp.json()}
    @{cnames}=  Create List
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
            ${CatalogId1}=  Run Keyword If   '${kwstatus}' == 'FAIL' and '${QnrTransactionType[8]}' in @{u_ttype}  Create Sample Catalog  ${unique_cnames[${i}]}    ${item_id1}
   
        END
    END

    Set Suite Variable   ${CatalogId1}

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${old_item_id}  ${resp.json()['catalogItem'][0]['item']['itemId']}

    ${resp}=  Remove Single Item From Catalog    ${CatalogId1}    ${old_item_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${minQ1}=  Random Int  min=1   max=5
    ${maxQ1}=  Random Int  min=${minQ1+2}   max=20
    ${item1_Id}=  Create Dictionary  itemId=${item_id1}
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQ1}   maxQuantity=${maxQ1}    
    ${Items_list}=  Create List   ${catalogItem1}
    ${resp}=  Add Items To Catalog    ${CatalogId1}    ${Items_list}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${minNumberItem}  ${resp.json()['catalogItem'][0]['minQuantity']}
    Set Test Variable  ${maxNumberItem}  ${resp.json()['catalogItem'][0]['maxQuantity']}
    Set Test Variable  ${sTime}  ${resp.json()['catalogSchedule']['timeSlots'][0]['sTime']}
    Set Test Variable  ${eTime}  ${resp.json()['catalogSchedule']['timeSlots'][0]['eTime']}

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
      ${id}  Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[8]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}'  Set Variable  ${resp.json()[${i}]['id']} 
      ${qnrid}   Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[8]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}'  Set Variable  ${resp.json()[${i}]['questionnaireId']}
      Exit For Loop If   '${id}' != '${None}'
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

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME21}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME21}  firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${cid21}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${cid21}  ${resp.json()[0]['id']}
    END

    ${DAY1}=   db.get_date
    ${pin}  ${city}  ${district}  ${state}=  get_pin_loc
    ${first}= 	Split String 	${fname}
    Set Test Variable  ${C_email}  ${first[0]}${CUSERNAME21}.${test_mail}
    ${landMark}=  FakerLibrary.street name 
    ${address}=  Create Dictionary   phoneNumber=${CUSERNAME21}    firstName=${fname}   lastName=${lname}   email=${C_email}    address=${district}   city=${city}   postalCode=${pin}    landMark=${landMark}   countryCode=${countryCodes[0]}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minNumberItem}  max=${maxNumberItem-1}
    ${orderNote}=  FakerLibrary.Sentence   nb_words=5

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME138}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Create Order By Provider For HomeDelivery    ${cookie}  ${cid21}   ${cid21}   ${CatalogId1}   ${boolean[1]}   ${address}  ${sTime}    ${eTime}   ${DAY1}    ${CUSERNAME21}    ${C_email}  ${orderNote}  ${countryCodes[1]}  ${item_id1}   ${item_quantity1}  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid1}  ${orderid[0]}
    
    ${resp}=   Get Order by uid    ${orderid1} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
       
    Should Be Equal As Strings  ${resp.json()['uid']}   ${orderid1}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}   ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}    ${bool[0]}

    ${resp}=  Get Consumer Questionnaire By Channel and OrderID    ${CatalogId1}   ${QnrChannel[0]}     ${cid21}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${resp.json()['id']}   ${id}

    ${fudata}=  db.fileUploadDT   ${resp.json()}  ${FileAction[0]}  ${Questionnaireid}  ${pdffile}
    Log  ${fudata}
    ${data}=  db.QuestionnaireAnswers   ${resp.json()}   ${jdconID}   &{fudata}
    Log  ${data}
    Set Suite Variable   ${data}
    ${resp}=  Provider Validate Questionnaire  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME138}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Imageupload.POrderQAnsUpload   ${cookie}  ${orderid1}   ${data}  ${pdffile}
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

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Check Answers   ${resp}  ${data}  ${QnrStatus[0]}  ${QnrStatus[0]}

    ${resp}=    Provider Change Answer Status for order   ${orderid1}   @{files_data}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Check Answers   ${resp}  ${data}   

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME138}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Imageupload.POrderResubmitQns   ${cookie}  ${orderid1}   ${data}  ${pdffile}
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

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Check Answers   ${resp}  ${data}  ${QnrStatus[0]}  ${QnrStatus[0]}

    ${resp}=    Provider Change Answer Status for order   ${orderid1}   @{files_data}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Check Answers   ${resp}  ${data} 


JD-TC-ChangeAnswerStatusForOrder-4
    [Documentation]  change answer status after starting order
    
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

    ${resp}=  Provider Login  ${PUSERNAME138}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}

    ${resp}=  Get Order Settings by account id
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableOrder']}==${bool[0]}
        ${resp1}=  Enable Order Settings 
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${displayName1}=   FakerLibrary.user name    
    ${price1}=  Evaluate    random.uniform(50.0,300) 
    ${itemName1}=   FakerLibrary.name    
    ${itemCode1}=   FakerLibrary.word 
    ${resp}=  Create Sample Item   ${displayName1}   ${itemName1}  ${itemCode1}  ${price1}  ${bool[0]}     
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id1}  ${resp.json()}

    ${resp}=   Get Item By Id    ${item_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Catalog By Criteria  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${c_len}=  Get Length  ${resp.json()}
    @{cnames}=  Create List
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
            ${CatalogId1}=  Run Keyword If   '${kwstatus}' == 'FAIL' and '${QnrTransactionType[8]}' in @{u_ttype}  Create Sample Catalog  ${unique_cnames[${i}]}    ${item_id1}
   
        END
    END

    Set Suite Variable   ${CatalogId1}

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${old_item_id}  ${resp.json()['catalogItem'][0]['item']['itemId']}

    ${resp}=  Remove Single Item From Catalog    ${CatalogId1}    ${old_item_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${minQ1}=  Random Int  min=1   max=5
    ${maxQ1}=  Random Int  min=${minQ1+2}   max=20
    ${item1_Id}=  Create Dictionary  itemId=${item_id1}
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQ1}   maxQuantity=${maxQ1}    
    ${Items_list}=  Create List   ${catalogItem1}
    ${resp}=  Add Items To Catalog    ${CatalogId1}    ${Items_list}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${minNumberItem}  ${resp.json()['catalogItem'][0]['minQuantity']}
    Set Test Variable  ${maxNumberItem}  ${resp.json()['catalogItem'][0]['maxQuantity']}
    Set Test Variable  ${sTime}  ${resp.json()['catalogSchedule']['timeSlots'][0]['sTime']}
    Set Test Variable  ${eTime}  ${resp.json()['catalogSchedule']['timeSlots'][0]['eTime']}

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
      ${id}  Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[8]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}'  Set Variable  ${resp.json()[${i}]['id']} 
      ${qnrid}   Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[8]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}'  Set Variable  ${resp.json()[${i}]['questionnaireId']}
      Exit For Loop If   '${id}' != '${None}'
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

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME21}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME21}  firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${cid21}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${cid21}  ${resp.json()[0]['id']}
    END

    ${DAY1}=   db.get_date
    ${pin}  ${city}  ${district}  ${state}=  get_pin_loc
    ${first}= 	Split String 	${fname}
    Set Test Variable  ${C_email}  ${first[0]}${CUSERNAME21}.${test_mail}
    ${landMark}=  FakerLibrary.street name 
    ${address}=  Create Dictionary   phoneNumber=${CUSERNAME21}    firstName=${fname}   lastName=${lname}   email=${C_email}    address=${district}   city=${city}   postalCode=${pin}    landMark=${landMark}   countryCode=${countryCodes[0]}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minNumberItem}  max=${maxNumberItem-1}
    ${orderNote}=  FakerLibrary.Sentence   nb_words=5

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME138}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Create Order By Provider For HomeDelivery    ${cookie}  ${cid21}   ${cid21}   ${CatalogId1}   ${boolean[1]}   ${address}  ${sTime}    ${eTime}   ${DAY1}    ${CUSERNAME21}    ${C_email}  ${orderNote}  ${countryCodes[1]}  ${item_id1}   ${item_quantity1}  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid1}  ${orderid[0]}
    
    ${resp}=   Get Order by uid    ${orderid1} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
       
    Should Be Equal As Strings  ${resp.json()['uid']}   ${orderid1}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}   ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}    ${bool[0]}

    ${resp}=  Get Consumer Questionnaire By Channel and OrderID    ${CatalogId1}   ${QnrChannel[0]}     ${cid21}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${resp.json()['id']}   ${id}

    ${fudata}=  db.fileUploadDT   ${resp.json()}  ${FileAction[0]}  ${Questionnaireid}  ${pdffile}
    Log  ${fudata}
    ${data}=  db.QuestionnaireAnswers   ${resp.json()}   ${jdconID}   &{fudata}
    Log  ${data}
    Set Suite Variable   ${data}
    ${resp}=  Provider Validate Questionnaire  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME138}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Imageupload.POrderQAnsUpload   ${cookie}  ${orderid1}   ${data}  ${pdffile}
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

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['orderStatus']}   ${orderStatuses[0]}
    Check Answers   ${resp}  ${data}  ${QnrStatus[0]}  ${QnrStatus[0]}

    # ${resp}=    Provider Change Answer Status for order   ${orderid1}   @{files_data}    
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=   Get Order by uid     ${orderid1} 
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings  ${resp.json()['orderStatus']}             ${orderStatuses[0]}
    # Check Answers   ${resp}  ${data}

    ${resp}=  Change Order Status   ${orderid1}   ${orderStatuses[3]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['orderStatus']}  ${orderStatuses[3]}
    # Check Answers   ${resp}  ${data}

    ${resp}=    Provider Change Answer Status for order   ${orderid1}   @{files_data}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['orderStatus']}             ${orderStatuses[3]}
    Check Answers   ${resp}  ${data}


JD-TC-ChangeAnswerStatusForOrder-5
    [Documentation]  complete already completed order

    ${resp}=  Provider Login  ${PUSERNAME138}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Order Settings by account id
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableOrder']}==${bool[0]}
        ${resp1}=  Enable Order Settings 
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${displayName1}=   FakerLibrary.user name    
    ${price1}=  Evaluate    random.uniform(50.0,300) 
    ${itemName1}=   FakerLibrary.name    
    ${itemCode1}=   FakerLibrary.word 
    ${resp}=  Create Sample Item   ${displayName1}   ${itemName1}  ${itemCode1}  ${price1}  ${bool[0]}     
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id1}  ${resp.json()}

    ${resp}=   Get Item By Id    ${item_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Catalog By Criteria  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${c_len}=  Get Length  ${resp.json()}
    @{cnames}=  Create List
    FOR  ${i}  IN RANGE   ${c_len}
        IF   '${resp.json()[${i}]['catalogName']}' in @{unique_cnames} and '${resp.json()[${i}]['orderType']}' == '${OrderTypes[0]}'
            ${CatalogId1}=   Set Variable   ${resp.json()[${i}]['id']}
        # ELSE
        #     Append To List  ${cnames}  ${resp.json()[${i}]['catalogName']}
        END
    END

    # ${cat_val}=    Get Variable Value    ${CatalogId1}
    
    # IF  '${cat_val}'=='${None}'
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
    #         ${CatalogId1}=  Run Keyword If   '${kwstatus}' == 'FAIL' and '${QnrTransactionType[8]}' in @{u_ttype}  Create Sample Catalog  ${unique_cnames[${i}]}    ${item_id1}
   
    #     END
    # END

    Set Suite Variable   ${CatalogId1}

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${old_item_id}  ${resp.json()['catalogItem'][0]['item']['itemId']}

    ${resp}=  Remove Single Item From Catalog    ${CatalogId1}    ${old_item_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${minQ1}=  Random Int  min=1   max=5
    ${maxQ1}=  Random Int  min=${minQ1+2}   max=20
    ${item1_Id}=  Create Dictionary  itemId=${item_id1}
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQ1}   maxQuantity=${maxQ1}    
    ${Items_list}=  Create List   ${catalogItem1}
    ${resp}=  Add Items To Catalog    ${CatalogId1}    ${Items_list}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${minNumberItem}  ${resp.json()['catalogItem'][0]['minQuantity']}
    Set Test Variable  ${maxNumberItem}  ${resp.json()['catalogItem'][0]['maxQuantity']}
    Set Test Variable  ${sTime}  ${resp.json()['catalogSchedule']['timeSlots'][0]['sTime']}
    Set Test Variable  ${eTime}  ${resp.json()['catalogSchedule']['timeSlots'][0]['eTime']}

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
      ${id}  Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[8]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}'  Set Variable  ${resp.json()[${i}]['id']} 
      ${qnrid}   Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[8]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}'  Set Variable  ${resp.json()[${i}]['questionnaireId']}
      Exit For Loop If   '${id}' != '${None}'
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

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME21}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME21}  firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${cid21}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${cid21}  ${resp.json()[0]['id']}
    END

    ${DAY1}=   db.get_date
    ${pin}  ${city}  ${district}  ${state}=  get_pin_loc
    ${first}= 	Split String 	${fname}
    Set Test Variable  ${C_email}  ${first[0]}${CUSERNAME21}.${test_mail}
    ${landMark}=  FakerLibrary.street name 
    ${address}=  Create Dictionary   phoneNumber=${CUSERNAME21}    firstName=${fname}   lastName=${lname}   email=${C_email}    address=${district}   city=${city}   postalCode=${pin}    landMark=${landMark}   countryCode=${countryCodes[0]}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minNumberItem}  max=${maxNumberItem-1}
    ${orderNote}=  FakerLibrary.Sentence   nb_words=5

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME138}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Create Order By Provider For HomeDelivery    ${cookie}  ${cid21}   ${cid21}   ${CatalogId1}   ${boolean[1]}   ${address}  ${sTime}    ${eTime}   ${DAY1}    ${CUSERNAME21}    ${C_email}  ${orderNote}  ${countryCodes[1]}  ${item_id1}   ${item_quantity1}  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid1}  ${orderid[0]}
    
    ${resp}=   Get Order by uid    ${orderid1} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
       
    Should Be Equal As Strings  ${resp.json()['uid']}   ${orderid1}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}   ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}    ${bool[0]}

    ${resp}=  Get Consumer Questionnaire By Channel and OrderID    ${CatalogId1}   ${QnrChannel[0]}     ${cid21}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${resp.json()['id']}   ${id}

    ${fudata}=  db.fileUploadDT   ${resp.json()}  ${FileAction[0]}  ${Questionnaireid}  ${pdffile}
    Log  ${fudata}
    ${data}=  db.QuestionnaireAnswers   ${resp.json()}   ${jdconID}   &{fudata}
    Log  ${data}
    Set Suite Variable   ${data}
    ${resp}=  Provider Validate Questionnaire  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME138}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Imageupload.POrderQAnsUpload   ${cookie}  ${orderid1}   ${data}  ${pdffile}
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

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings  ${resp.json()['orderStatus']}   ${orderStatuses[0]}
    Check Answers   ${resp}  ${data}  ${QnrStatus[0]}  ${QnrStatus[0]}

    ${resp}=    Provider Change Answer Status for order   ${orderid1}   @{files_data}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings  ${resp.json()['orderStatus']}  ${orderStatuses[0]}
    Check Answers   ${resp}  ${data}

    ${resp}=    Provider Change Answer Status for order   ${orderid1}   @{files_data}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings  ${resp.json()['orderStatus']}  ${orderStatuses[0]}
    Check Answers   ${resp}  ${data}


JD-TC-ChangeAnswerStatusForOrder-UH1
    [Documentation]   change answer status to complete, without giving details.

    ${resp}=  Provider Login  ${PUSERNAME138}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Catalog By Criteria  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${c_len}=  Get Length  ${resp.json()}
    @{cnames}=  Create List
    FOR  ${i}  IN RANGE   ${c_len}
        IF   '${resp.json()[${i}]['catalogName']}' in @{unique_cnames} and '${resp.json()[${i}]['orderType']}' == '${OrderTypes[0]}'
            ${CatalogId1}=   Set Variable   ${resp.json()[${i}]['id']}
        END
    END

    Set Suite Variable   ${CatalogId1}

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${minNumberItem}  ${resp.json()['catalogItem'][0]['minQuantity']}
    Set Test Variable  ${maxNumberItem}  ${resp.json()['catalogItem'][0]['maxQuantity']}
    Set Test Variable  ${sTime}  ${resp.json()['catalogSchedule']['timeSlots'][0]['sTime']}
    Set Test Variable  ${eTime}  ${resp.json()['catalogSchedule']['timeSlots'][0]['eTime']}
    Set Test Variable  ${item_id1}  ${resp.json()['catalogItem'][0]['item']['itemId']}

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
        IF  '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[8]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}'
            ${id}  Set Variable  ${resp.json()[${i}]['id']} 
            ${qnrid}   Set Variable  ${resp.json()[${i}]['questionnaireId']}
        END
        Exit For Loop If   '${id}' != '${None}'
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

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME21}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME21}  firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${cid21}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${cid21}  ${resp.json()[0]['id']}
    END

    ${DAY1}=   db.get_date
    ${pin}  ${city}  ${district}  ${state}=  get_pin_loc
    ${first}= 	Split String 	${fname}
    Set Test Variable  ${C_email}  ${first[0]}${CUSERNAME21}.${test_mail}
    ${landMark}=  FakerLibrary.street name 
    ${address}=  Create Dictionary   phoneNumber=${CUSERNAME21}    firstName=${fname}   lastName=${lname}   email=${C_email}    address=${district}   city=${city}   postalCode=${pin}    landMark=${landMark}   countryCode=${countryCodes[0]}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minNumberItem}  max=${maxNumberItem-1}
    ${orderNote}=  FakerLibrary.Sentence   nb_words=5

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME138}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Create Order By Provider For HomeDelivery    ${cookie}  ${cid21}   ${cid21}   ${CatalogId1}   ${boolean[1]}   ${address}  ${sTime}    ${eTime}   ${DAY1}    ${CUSERNAME21}    ${C_email}  ${orderNote}  ${countryCodes[1]}  ${item_id1}   ${item_quantity1}  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid1}  ${orderid[0]}
    
    ${resp}=   Get Order by uid    ${orderid1} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
       
    Should Be Equal As Strings  ${resp.json()['uid']}   ${orderid1}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}   ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}    ${bool[0]}

    ${resp}=  Get Consumer Questionnaire By Channel and OrderID    ${CatalogId1}   ${QnrChannel[0]}     ${cid21}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${resp.json()['id']}   ${id}

    ${fudata}=  db.fileUploadDT   ${resp.json()}  ${FileAction[0]}  ${Questionnaireid}  ${pdffile}
    Log  ${fudata}
    ${data}=  db.QuestionnaireAnswers   ${resp.json()}   ${jdconID}   &{fudata}
    Log  ${data}
    Set Suite Variable   ${data}
    ${resp}=  Provider Validate Questionnaire  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME138}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Imageupload.POrderQAnsUpload   ${cookie}  ${orderid1}   ${data}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${files_data}=  Create List
    # ${len}=  Get Length  ${resp.json()['urls']}
    # FOR  ${i}  IN RANGE   ${len}
    #     Set Test Variable  ${fileid${i}}  ${resp.json()['urls'][${i}]['uid']}
    #     Set Test Variable  ${lblname${i}}  ${resp.json()['urls'][${i}]['labelName']}
    #     IF  'columnId' in ${resp.json()['urls'][${i}]}
    #         Set Test Variable  ${columnId${i}}  ${resp.json()['urls'][${i}]['columnId']}
    #         ${file_data_dict}   Create Dictionary  uid=${fileid${i}}  labelName=${lblname${i}}  columnId=${columnId${i}}
    #     ELSE
    #         ${file_data_dict}   Create Dictionary  uid=${fileid${i}}  labelName=${lblname${i}}
    #     END
    #     Append To List  ${files_data}  ${file_data_dict}
    # END

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings  ${resp.json()['orderStatus']}   ${orderStatuses[0]}
    Check Answers   ${resp}  ${data}  ${QnrStatus[0]}  ${QnrStatus[0]}

    ${resp}=    Provider Change Answer Status for order   ${orderid1}   ${EMPTY}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings  ${resp.json()['orderStatus']}  ${orderStatuses[0]}
    Check Answers   ${resp}  ${data}  ${QnrStatus[0]}  ${QnrStatus[0]}


JD-TC-ChangeAnswerStatusForOrder-UH2
    [Documentation]   change answer status without provider login

    ${resp}=  Provider Login  ${PUSERNAME138}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Catalog By Criteria  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${c_len}=  Get Length  ${resp.json()}
    @{cnames}=  Create List
    FOR  ${i}  IN RANGE   ${c_len}
        IF   '${resp.json()[${i}]['catalogName']}' in @{unique_cnames} and '${resp.json()[${i}]['orderType']}' == '${OrderTypes[0]}'
            ${CatalogId1}=   Set Variable   ${resp.json()[${i}]['id']}
        END
    END

    Set Suite Variable   ${CatalogId1}

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${minNumberItem}  ${resp.json()['catalogItem'][0]['minQuantity']}
    Set Test Variable  ${maxNumberItem}  ${resp.json()['catalogItem'][0]['maxQuantity']}
    Set Test Variable  ${sTime}  ${resp.json()['catalogSchedule']['timeSlots'][0]['sTime']}
    Set Test Variable  ${eTime}  ${resp.json()['catalogSchedule']['timeSlots'][0]['eTime']}
    Set Test Variable  ${item_id1}  ${resp.json()['catalogItem'][0]['item']['itemId']}

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
        IF  '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[8]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}'
            ${id}  Set Variable  ${resp.json()[${i}]['id']} 
            ${qnrid}   Set Variable  ${resp.json()[${i}]['questionnaireId']}
        END
        Exit For Loop If   '${id}' != '${None}'
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

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME21}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME21}  firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${cid21}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${cid21}  ${resp.json()[0]['id']}
    END

    ${DAY1}=   db.get_date
    ${pin}  ${city}  ${district}  ${state}=  get_pin_loc
    ${first}= 	Split String 	${fname}
    Set Test Variable  ${C_email}  ${first[0]}${CUSERNAME21}.${test_mail}
    ${landMark}=  FakerLibrary.street name 
    ${address}=  Create Dictionary   phoneNumber=${CUSERNAME21}    firstName=${fname}   lastName=${lname}   email=${C_email}    address=${district}   city=${city}   postalCode=${pin}    landMark=${landMark}   countryCode=${countryCodes[0]}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minNumberItem}  max=${maxNumberItem-1}
    ${orderNote}=  FakerLibrary.Sentence   nb_words=5

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME138}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Create Order By Provider For HomeDelivery    ${cookie}  ${cid21}   ${cid21}   ${CatalogId1}   ${boolean[1]}   ${address}  ${sTime}    ${eTime}   ${DAY1}    ${CUSERNAME21}    ${C_email}  ${orderNote}  ${countryCodes[1]}  ${item_id1}   ${item_quantity1}  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid1}  ${orderid[0]}
    
    ${resp}=   Get Order by uid    ${orderid1} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
       
    Should Be Equal As Strings  ${resp.json()['uid']}   ${orderid1}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}   ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}    ${bool[0]}

    ${resp}=  Get Consumer Questionnaire By Channel and OrderID    ${CatalogId1}   ${QnrChannel[0]}     ${cid21}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${resp.json()['id']}   ${id}

    ${fudata}=  db.fileUploadDT   ${resp.json()}  ${FileAction[0]}  ${Questionnaireid}  ${pdffile}
    Log  ${fudata}
    ${data}=  db.QuestionnaireAnswers   ${resp.json()}   ${jdconID}   &{fudata}
    Log  ${data}
    Set Suite Variable   ${data}
    ${resp}=  Provider Validate Questionnaire  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME138}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Imageupload.POrderQAnsUpload   ${cookie}  ${orderid1}   ${data}  ${pdffile}
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

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings  ${resp.json()['orderStatus']}   ${orderStatuses[0]}
    Check Answers   ${resp}  ${data}  ${QnrStatus[0]}  ${QnrStatus[0]}

    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Change Answer Status for order   ${orderid1}   @{files_data}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.json()}    ${SESSION_EXPIRED}

    ${resp}=  Provider Login  ${PUSERNAME138}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings  ${resp.json()['orderStatus']}  ${orderStatuses[0]}
    Check Answers   ${resp}  ${data}  ${QnrStatus[0]}  ${QnrStatus[0]}

JD-TC-ChangeAnswerStatusForOrder-UH3
    [Documentation]   change answer status without file uid

    ${resp}=  Provider Login  ${PUSERNAME138}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Catalog By Criteria  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${c_len}=  Get Length  ${resp.json()}
    @{cnames}=  Create List
    FOR  ${i}  IN RANGE   ${c_len}
        IF   '${resp.json()[${i}]['catalogName']}' in @{unique_cnames} and '${resp.json()[${i}]['orderType']}' == '${OrderTypes[0]}'
            ${CatalogId1}=   Set Variable   ${resp.json()[${i}]['id']}
        END
    END

    Set Suite Variable   ${CatalogId1}

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${minNumberItem}  ${resp.json()['catalogItem'][0]['minQuantity']}
    Set Test Variable  ${maxNumberItem}  ${resp.json()['catalogItem'][0]['maxQuantity']}
    Set Test Variable  ${sTime}  ${resp.json()['catalogSchedule']['timeSlots'][0]['sTime']}
    Set Test Variable  ${eTime}  ${resp.json()['catalogSchedule']['timeSlots'][0]['eTime']}
    Set Test Variable  ${item_id1}  ${resp.json()['catalogItem'][0]['item']['itemId']}

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
        IF  '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[8]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}'
            ${id}  Set Variable  ${resp.json()[${i}]['id']} 
            ${qnrid}   Set Variable  ${resp.json()[${i}]['questionnaireId']}
        END
        Exit For Loop If   '${id}' != '${None}'
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

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME21}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME21}  firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${cid21}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${cid21}  ${resp.json()[0]['id']}
    END

    ${DAY1}=   db.get_date
    ${pin}  ${city}  ${district}  ${state}=  get_pin_loc
    ${first}= 	Split String 	${fname}
    Set Test Variable  ${C_email}  ${first[0]}${CUSERNAME21}.${test_mail}
    ${landMark}=  FakerLibrary.street name 
    ${address}=  Create Dictionary   phoneNumber=${CUSERNAME21}    firstName=${fname}   lastName=${lname}   email=${C_email}    address=${district}   city=${city}   postalCode=${pin}    landMark=${landMark}   countryCode=${countryCodes[0]}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minNumberItem}  max=${maxNumberItem-1}
    ${orderNote}=  FakerLibrary.Sentence   nb_words=5

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME138}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Create Order By Provider For HomeDelivery    ${cookie}  ${cid21}   ${cid21}   ${CatalogId1}   ${boolean[1]}   ${address}  ${sTime}    ${eTime}   ${DAY1}    ${CUSERNAME21}    ${C_email}  ${orderNote}  ${countryCodes[1]}  ${item_id1}   ${item_quantity1}  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid1}  ${orderid[0]}
    
    ${resp}=   Get Order by uid    ${orderid1} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
       
    Should Be Equal As Strings  ${resp.json()['uid']}   ${orderid1}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}   ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}    ${bool[0]}

    ${resp}=  Get Consumer Questionnaire By Channel and OrderID    ${CatalogId1}   ${QnrChannel[0]}     ${cid21}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${resp.json()['id']}   ${id}

    ${fudata}=  db.fileUploadDT   ${resp.json()}  ${FileAction[0]}  ${Questionnaireid}  ${pdffile}
    Log  ${fudata}
    ${data}=  db.QuestionnaireAnswers   ${resp.json()}   ${jdconID}   &{fudata}
    Log  ${data}
    Set Suite Variable   ${data}
    ${resp}=  Provider Validate Questionnaire  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME138}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Imageupload.POrderQAnsUpload   ${cookie}  ${orderid1}   ${data}  ${pdffile}
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

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings  ${resp.json()['orderStatus']}   ${orderStatuses[0]}
    Check Answers   ${resp}  ${data}  ${QnrStatus[0]}  ${QnrStatus[0]}

    ${resp}=    Provider Change Answer Status for order   ${orderid1}   @{files_data}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}    ${UPDATE_ERROR}

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings  ${resp.json()['orderStatus']}  ${orderStatuses[0]}
    Check Answers   ${resp}  ${data}  ${QnrStatus[0]}  ${QnrStatus[0]}


JD-TC-ChangeAnswerStatusForOrder-UH4
    [Documentation]   change answer status without labelname

    ${resp}=  Provider Login  ${PUSERNAME138}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Catalog By Criteria  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${c_len}=  Get Length  ${resp.json()}
    @{cnames}=  Create List
    FOR  ${i}  IN RANGE   ${c_len}
        IF   '${resp.json()[${i}]['catalogName']}' in @{unique_cnames} and '${resp.json()[${i}]['orderType']}' == '${OrderTypes[0]}'
            ${CatalogId1}=   Set Variable   ${resp.json()[${i}]['id']}
        END
    END

    Set Suite Variable   ${CatalogId1}

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${minNumberItem}  ${resp.json()['catalogItem'][0]['minQuantity']}
    Set Test Variable  ${maxNumberItem}  ${resp.json()['catalogItem'][0]['maxQuantity']}
    Set Test Variable  ${sTime}  ${resp.json()['catalogSchedule']['timeSlots'][0]['sTime']}
    Set Test Variable  ${eTime}  ${resp.json()['catalogSchedule']['timeSlots'][0]['eTime']}
    Set Test Variable  ${item_id1}  ${resp.json()['catalogItem'][0]['item']['itemId']}

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
        IF  '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[8]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}'
            ${id}  Set Variable  ${resp.json()[${i}]['id']} 
            ${qnrid}   Set Variable  ${resp.json()[${i}]['questionnaireId']}
        END
        Exit For Loop If   '${id}' != '${None}'
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

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME21}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME21}  firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${cid21}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${cid21}  ${resp.json()[0]['id']}
    END

    ${DAY1}=   db.get_date
    ${pin}  ${city}  ${district}  ${state}=  get_pin_loc
    ${first}= 	Split String 	${fname}
    Set Test Variable  ${C_email}  ${first[0]}${CUSERNAME21}.${test_mail}
    ${landMark}=  FakerLibrary.street name 
    ${address}=  Create Dictionary   phoneNumber=${CUSERNAME21}    firstName=${fname}   lastName=${lname}   email=${C_email}    address=${district}   city=${city}   postalCode=${pin}    landMark=${landMark}   countryCode=${countryCodes[0]}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minNumberItem}  max=${maxNumberItem-1}
    ${orderNote}=  FakerLibrary.Sentence   nb_words=5

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME138}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Create Order By Provider For HomeDelivery    ${cookie}  ${cid21}   ${cid21}   ${CatalogId1}   ${boolean[1]}   ${address}  ${sTime}    ${eTime}   ${DAY1}    ${CUSERNAME21}    ${C_email}  ${orderNote}  ${countryCodes[1]}  ${item_id1}   ${item_quantity1}  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid1}  ${orderid[0]}
    
    ${resp}=   Get Order by uid    ${orderid1} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
       
    Should Be Equal As Strings  ${resp.json()['uid']}   ${orderid1}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}   ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}    ${bool[0]}

    ${resp}=  Get Consumer Questionnaire By Channel and OrderID    ${CatalogId1}   ${QnrChannel[0]}     ${cid21}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${resp.json()['id']}   ${id}

    ${fudata}=  db.fileUploadDT   ${resp.json()}  ${FileAction[0]}  ${Questionnaireid}  ${pdffile}
    Log  ${fudata}
    ${data}=  db.QuestionnaireAnswers   ${resp.json()}   ${jdconID}   &{fudata}
    Log  ${data}
    Set Suite Variable   ${data}
    ${resp}=  Provider Validate Questionnaire  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME138}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Imageupload.POrderQAnsUpload   ${cookie}  ${orderid1}   ${data}  ${pdffile}
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

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings  ${resp.json()['orderStatus']}   ${orderStatuses[0]}
    Check Answers   ${resp}  ${data}  ${QnrStatus[0]}  ${QnrStatus[0]}

    ${resp}=    Provider Change Answer Status for order   ${orderid1}   @{files_data}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()}    ${UPDATE_ERROR}

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings  ${resp.json()['orderStatus']}  ${orderStatuses[0]}
    Check Answers   ${resp}  ${data}  ${QnrStatus[0]}  ${QnrStatus[0]}


JD-TC-ChangeAnswerStatusForOrder-UH5
    [Documentation]   change answer status without column id

    ${resp}=  Provider Login  ${PUSERNAME138}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Catalog By Criteria  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${c_len}=  Get Length  ${resp.json()}
    @{cnames}=  Create List
    FOR  ${i}  IN RANGE   ${c_len}
        IF   '${resp.json()[${i}]['catalogName']}' in @{unique_cnames} and '${resp.json()[${i}]['orderType']}' == '${OrderTypes[0]}'
            ${CatalogId1}=   Set Variable   ${resp.json()[${i}]['id']}
        END
    END

    Set Suite Variable   ${CatalogId1}

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${minNumberItem}  ${resp.json()['catalogItem'][0]['minQuantity']}
    Set Test Variable  ${maxNumberItem}  ${resp.json()['catalogItem'][0]['maxQuantity']}
    Set Test Variable  ${sTime}  ${resp.json()['catalogSchedule']['timeSlots'][0]['sTime']}
    Set Test Variable  ${eTime}  ${resp.json()['catalogSchedule']['timeSlots'][0]['eTime']}
    Set Test Variable  ${item_id1}  ${resp.json()['catalogItem'][0]['item']['itemId']}

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
        IF  '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[8]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}'
            ${id}  Set Variable  ${resp.json()[${i}]['id']} 
            ${qnrid}   Set Variable  ${resp.json()[${i}]['questionnaireId']}
        END
        Exit For Loop If   '${id}' != '${None}'
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

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME21}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME21}  firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${cid21}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${cid21}  ${resp.json()[0]['id']}
    END

    ${DAY1}=   db.get_date
    ${pin}  ${city}  ${district}  ${state}=  get_pin_loc
    ${first}= 	Split String 	${fname}
    Set Test Variable  ${C_email}  ${first[0]}${CUSERNAME21}.${test_mail}
    ${landMark}=  FakerLibrary.street name 
    ${address}=  Create Dictionary   phoneNumber=${CUSERNAME21}    firstName=${fname}   lastName=${lname}   email=${C_email}    address=${district}   city=${city}   postalCode=${pin}    landMark=${landMark}   countryCode=${countryCodes[0]}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minNumberItem}  max=${maxNumberItem-1}
    ${orderNote}=  FakerLibrary.Sentence   nb_words=5

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME138}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Create Order By Provider For HomeDelivery    ${cookie}  ${cid21}   ${cid21}   ${CatalogId1}   ${boolean[1]}   ${address}  ${sTime}    ${eTime}   ${DAY1}    ${CUSERNAME21}    ${C_email}  ${orderNote}  ${countryCodes[1]}  ${item_id1}   ${item_quantity1}  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid1}  ${orderid[0]}
    
    ${resp}=   Get Order by uid    ${orderid1} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
       
    Should Be Equal As Strings  ${resp.json()['uid']}   ${orderid1}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}   ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}    ${bool[0]}

    ${resp}=  Get Consumer Questionnaire By Channel and OrderID    ${CatalogId1}   ${QnrChannel[0]}     ${cid21}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${resp.json()['id']}   ${id}

    ${fudata}=  db.fileUploadDT   ${resp.json()}  ${FileAction[0]}  ${Questionnaireid}  ${pdffile}
    Log  ${fudata}
    ${data}=  db.QuestionnaireAnswers   ${resp.json()}   ${jdconID}   &{fudata}
    Log  ${data}
    Set Suite Variable   ${data}
    ${resp}=  Provider Validate Questionnaire  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME138}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Imageupload.POrderQAnsUpload   ${cookie}  ${orderid1}   ${data}  ${pdffile}
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
            ${file_data_dict}   Create Dictionary  uid=${fileid${i}}  labelName=${lblname${i}}
            # ${file_data_dict}   Create Dictionary  uid=${fileid${i}}  labelName=${EMPTY}
        END
        Append To List  ${files_data}  ${file_data_dict}
    END

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings  ${resp.json()['orderStatus']}   ${orderStatuses[0]}
    Check Answers   ${resp}  ${data}  ${QnrStatus[0]}  ${QnrStatus[0]}

    ${resp}=    Provider Change Answer Status for order   ${orderid1}   @{files_data}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}    ${UPDATE_ERROR}

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-ChangeAnswerStatusForOrder-UH6
    [Documentation]   change answer status with invalid order id.

    ${resp}=  Provider Login  ${PUSERNAME138}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Catalog By Criteria  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${c_len}=  Get Length  ${resp.json()}
    @{cnames}=  Create List
    FOR  ${i}  IN RANGE   ${c_len}
        IF   '${resp.json()[${i}]['catalogName']}' in @{unique_cnames} and '${resp.json()[${i}]['orderType']}' == '${OrderTypes[0]}'
            ${CatalogId1}=   Set Variable   ${resp.json()[${i}]['id']}
        END
    END

    Set Suite Variable   ${CatalogId1}

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${minNumberItem}  ${resp.json()['catalogItem'][0]['minQuantity']}
    Set Test Variable  ${maxNumberItem}  ${resp.json()['catalogItem'][0]['maxQuantity']}
    Set Test Variable  ${sTime}  ${resp.json()['catalogSchedule']['timeSlots'][0]['sTime']}
    Set Test Variable  ${eTime}  ${resp.json()['catalogSchedule']['timeSlots'][0]['eTime']}
    Set Test Variable  ${item_id1}  ${resp.json()['catalogItem'][0]['item']['itemId']}

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
        IF  '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[8]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}'
            ${id}  Set Variable  ${resp.json()[${i}]['id']} 
            ${qnrid}   Set Variable  ${resp.json()[${i}]['questionnaireId']}
        END
        Exit For Loop If   '${id}' != '${None}'
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

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME21}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME21}  firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${cid21}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${cid21}  ${resp.json()[0]['id']}
    END

    ${DAY1}=   db.get_date
    ${pin}  ${city}  ${district}  ${state}=  get_pin_loc
    ${first}= 	Split String 	${fname}
    Set Test Variable  ${C_email}  ${first[0]}${CUSERNAME21}.${test_mail}
    ${landMark}=  FakerLibrary.street name 
    ${address}=  Create Dictionary   phoneNumber=${CUSERNAME21}    firstName=${fname}   lastName=${lname}   email=${C_email}    address=${district}   city=${city}   postalCode=${pin}    landMark=${landMark}   countryCode=${countryCodes[0]}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minNumberItem}  max=${maxNumberItem-1}
    ${orderNote}=  FakerLibrary.Sentence   nb_words=5

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME138}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Create Order By Provider For HomeDelivery    ${cookie}  ${cid21}   ${cid21}   ${CatalogId1}   ${boolean[1]}   ${address}  ${sTime}    ${eTime}   ${DAY1}    ${CUSERNAME21}    ${C_email}  ${orderNote}  ${countryCodes[1]}  ${item_id1}   ${item_quantity1}  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid1}  ${orderid[0]}
    
    ${resp}=   Get Order by uid    ${orderid1} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
       
    Should Be Equal As Strings  ${resp.json()['uid']}   ${orderid1}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}   ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}    ${bool[0]}

    ${resp}=  Get Consumer Questionnaire By Channel and OrderID    ${CatalogId1}   ${QnrChannel[0]}     ${cid21}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${resp.json()['id']}   ${id}

    ${fudata}=  db.fileUploadDT   ${resp.json()}  ${FileAction[0]}  ${Questionnaireid}  ${pdffile}
    Log  ${fudata}
    ${data}=  db.QuestionnaireAnswers   ${resp.json()}   ${jdconID}   &{fudata}
    Log  ${data}
    Set Suite Variable   ${data}
    ${resp}=  Provider Validate Questionnaire  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME138}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Imageupload.POrderQAnsUpload   ${cookie}  ${orderid1}   ${data}  ${pdffile}
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

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings  ${resp.json()['orderStatus']}   ${orderStatuses[0]}
    Check Answers   ${resp}  ${data}  ${QnrStatus[0]}  ${QnrStatus[0]}

    ${inv_order_id}=  Generate Random String  16  [LETTERS][NUMBERS]

    ${resp}=    Provider Change Answer Status for order   ${inv_order_id}   @{files_data}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  404
    Should Be Equal As Strings  ${resp.json()}    ${ORDER_NOT_FOUND}

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings  ${resp.json()['orderStatus']}  ${orderStatuses[0]}
    Check Answers   ${resp}  ${data}  ${QnrStatus[0]}  ${QnrStatus[0]}


JD-TC-ChangeAnswerStatusForOrder-UH7
    [Documentation]   change answer status with another provider's order id.

    ${resp}=  Provider Login  ${PUSERNAME139}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Order Settings by account id
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableOrder']}==${bool[0]}
        ${resp1}=  Enable Order Settings 
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${displayName1}=   FakerLibrary.user name    
    ${price1}=  Evaluate    random.uniform(50.0,300) 
    ${itemName1}=   FakerLibrary.name    
    ${itemCode1}=   FakerLibrary.word 
    ${resp}=  Create Sample Item   ${displayName1}   ${itemName1}  ${itemCode1}  ${price1}  ${bool[0]}     
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id1}  ${resp.json()}

    ${resp}=   Get Item By Id    ${item_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Catalog By Criteria  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${c_len}=  Get Length  ${resp.json()}
    @{cnames}=  Create List
    FOR  ${i}  IN RANGE   ${c_len}
        IF   '${resp.json()[${i}]['catalogName']}' in @{unique_cnames} and '${resp.json()[${i}]['orderType']}' == '${OrderTypes[0]}'
            ${CatalogId2}=   Set Variable   ${resp.json()[${i}]['id']}
        # ELSE
        #     Append To List  ${cnames}  ${resp.json()[${i}]['catalogName']}
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
            ${CatalogId2}=  Run Keyword If   '${kwstatus}' == 'FAIL' and '${QnrTransactionType[8]}' in @{u_ttype}  Create Sample Catalog  ${unique_cnames[${i}]}    ${item_id1}
   
        END
    END

    # Set Suite Variable   ${CatalogId1}

    ${resp}=  Get Order Catalog    ${CatalogId2}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${minNumberItem}  ${resp.json()['catalogItem'][0]['minQuantity']}
    Set Test Variable  ${maxNumberItem}  ${resp.json()['catalogItem'][0]['maxQuantity']}
    Set Test Variable  ${sTime}  ${resp.json()['catalogSchedule']['timeSlots'][0]['sTime']}
    Set Test Variable  ${eTime}  ${resp.json()['catalogSchedule']['timeSlots'][0]['eTime']}
    Set Test Variable  ${item_id2}  ${resp.json()['catalogItem'][0]['item']['itemId']}

    # ${resp}=  Get Questionnaire List By Provider   
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${len}=  Get Length  ${resp.json()}
    # FOR  ${i}  IN RANGE   ${len}
    #     IF  '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[8]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}'
    #         ${id}  Set Variable  ${resp.json()[${i}]['id']} 
    #         ${qnrid}   Set Variable  ${resp.json()[${i}]['questionnaireId']}
    #     END
    #     Exit For Loop If   '${id}' != '${None}'
    # END
    # Set Suite Variable   ${id}
    # Set Suite Variable   ${qnrid}

    # ${qns}   Get Provider Questionnaire By Id   ${id}  
    # Log  ${qns.content}
    # 
    # Should Be Equal As Strings  ${qns.status_code}  200
    # Should Be Equal As Strings  ${qns.json()['transactionId']}  ${pid}

    # ${resp1}=  Run Keyword If   '${qns.json()['status']}' == '${status[1]}'  Provider Change Questionnaire Status  ${id}  ${status[0]}  
    # Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    # Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200
    
    # ${qns}   Get Provider Questionnaire By Id   ${id}  
    # Log  ${qns.content}
    # Should Be Equal As Strings  ${qns.status_code}  200
    # Should Be Equal As Strings   ${qns.json()['status']}  ${status[0]}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME21}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME21}  firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${cid21-1}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${cid21-1}  ${resp.json()[0]['id']}
    END

    ${DAY1}=   db.get_date
    ${pin}  ${city}  ${district}  ${state}=  get_pin_loc
    ${first}= 	Split String 	${fname}
    Set Test Variable  ${C_email}  ${first[0]}${CUSERNAME21}.${test_mail}
    ${landMark}=  FakerLibrary.street name 
    ${address}=  Create Dictionary   phoneNumber=${CUSERNAME21}    firstName=${fname}   lastName=${lname}   email=${C_email}    address=${district}   city=${city}   postalCode=${pin}    landMark=${landMark}   countryCode=${countryCodes[0]}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minNumberItem}  max=${maxNumberItem-1}
    ${orderNote}=  FakerLibrary.Sentence   nb_words=5

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME139}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Create Order By Provider For HomeDelivery    ${cookie}  ${cid21-1}   ${cid21-1}   ${CatalogId2}   ${boolean[1]}   ${address}  ${sTime}    ${eTime}   ${DAY1}    ${CUSERNAME21}    ${C_email}  ${orderNote}  ${countryCodes[1]}  ${item_id2}   ${item_quantity1}  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid2}  ${orderid[0]}
    
    ${resp}=   Get Order by uid    ${orderid2} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200   
    Should Be Equal As Strings  ${resp.json()['uid']}   ${orderid2}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}   ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}    ${bool[0]}

    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Provider Login  ${PUSERNAME138}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Consumer Questionnaire By Channel and OrderID    ${CatalogId1}   ${QnrChannel[0]}     ${cid21}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${resp.json()['id']}   ${id}

    ${fudata}=  db.fileUploadDT   ${resp.json()}  ${FileAction[0]}  ${Questionnaireid}  ${pdffile}
    Log  ${fudata}
    ${data}=  db.QuestionnaireAnswers   ${resp.json()}   ${jdconID}   &{fudata}
    Log  ${data}
    Set Suite Variable   ${data}
    ${resp}=  Provider Validate Questionnaire  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME138}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Imageupload.POrderQAnsUpload   ${cookie}  ${orderid1}   ${data}  ${pdffile}
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

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings  ${resp.json()['orderStatus']}   ${orderStatuses[0]}
    Check Answers   ${resp}  ${data}  ${QnrStatus[0]}  ${QnrStatus[0]}

    ${inv_order_id}=  Generate Random String  16  [LETTERS][NUMBERS]

    ${resp}=    Provider Change Answer Status for order   ${inv_order_id}   @{files_data}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  404
    Should Be Equal As Strings  ${resp.json()}    ${ORDER_NOT_FOUND}

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings  ${resp.json()['orderStatus']}  ${orderStatuses[0]}
    Check Answers   ${resp}  ${data}  ${QnrStatus[0]}  ${QnrStatus[0]}


JD-TC-ChangeAnswerStatusForOrder-UH8
    [Documentation]   change answer status with another label name.

    ${resp}=  Provider Login  ${PUSERNAME138}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Catalog By Criteria  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${c_len}=  Get Length  ${resp.json()}
    @{cnames}=  Create List
    FOR  ${i}  IN RANGE   ${c_len}
        IF   '${resp.json()[${i}]['catalogName']}' in @{unique_cnames} and '${resp.json()[${i}]['orderType']}' == '${OrderTypes[0]}'
            ${CatalogId1}=   Set Variable   ${resp.json()[${i}]['id']}
        END
    END

    Set Suite Variable   ${CatalogId1}

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${minNumberItem}  ${resp.json()['catalogItem'][0]['minQuantity']}
    Set Test Variable  ${maxNumberItem}  ${resp.json()['catalogItem'][0]['maxQuantity']}
    Set Test Variable  ${sTime}  ${resp.json()['catalogSchedule']['timeSlots'][0]['sTime']}
    Set Test Variable  ${eTime}  ${resp.json()['catalogSchedule']['timeSlots'][0]['eTime']}
    Set Test Variable  ${item_id1}  ${resp.json()['catalogItem'][0]['item']['itemId']}

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
        IF  '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[8]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}'
            ${id}  Set Variable  ${resp.json()[${i}]['id']} 
            ${qnrid}   Set Variable  ${resp.json()[${i}]['questionnaireId']}
        END
        Exit For Loop If   '${id}' != '${None}'
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

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME21}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME21}  firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${cid21}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${cid21}  ${resp.json()[0]['id']}
    END

    ${DAY1}=   db.get_date
    ${pin}  ${city}  ${district}  ${state}=  get_pin_loc
    ${first}= 	Split String 	${fname}
    Set Test Variable  ${C_email}  ${first[0]}${CUSERNAME21}.${test_mail}
    ${landMark}=  FakerLibrary.street name 
    ${address}=  Create Dictionary   phoneNumber=${CUSERNAME21}    firstName=${fname}   lastName=${lname}   email=${C_email}    address=${district}   city=${city}   postalCode=${pin}    landMark=${landMark}   countryCode=${countryCodes[0]}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minNumberItem}  max=${maxNumberItem-1}
    ${orderNote}=  FakerLibrary.Sentence   nb_words=5

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME138}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Create Order By Provider For HomeDelivery    ${cookie}  ${cid21}   ${cid21}   ${CatalogId1}   ${boolean[1]}   ${address}  ${sTime}    ${eTime}   ${DAY1}    ${CUSERNAME21}    ${C_email}  ${orderNote}  ${countryCodes[1]}  ${item_id1}   ${item_quantity1}  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid1}  ${orderid[0]}
    
    ${resp}=   Get Order by uid    ${orderid1} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
       
    Should Be Equal As Strings  ${resp.json()['uid']}   ${orderid1}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}   ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}    ${bool[0]}

    ${resp}=  Get Consumer Questionnaire By Channel and OrderID    ${CatalogId1}   ${QnrChannel[0]}     ${cid21}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${resp.json()['id']}   ${id}

    ${fudata}=  db.fileUploadDT   ${resp.json()}  ${FileAction[0]}  ${Questionnaireid}  ${pdffile}
    Log  ${fudata}
    ${data}=  db.QuestionnaireAnswers   ${resp.json()}   ${jdconID}   &{fudata}
    Log  ${data}
    Set Suite Variable   ${data}
    ${resp}=  Provider Validate Questionnaire  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME138}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Imageupload.POrderQAnsUpload   ${cookie}  ${orderid1}   ${data}  ${pdffile}
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

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings  ${resp.json()['orderStatus']}   ${orderStatuses[0]}
    Check Answers   ${resp}  ${data}  ${QnrStatus[0]}  ${QnrStatus[0]}

    ${resp}=    Provider Change Answer Status for order   ${orderid1}   @{files_data}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}    ${UPDATE_ERROR}

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings  ${resp.json()['orderStatus']}  ${orderStatuses[0]}
    Check Answers   ${resp}  ${data}  ${QnrStatus[0]}  ${QnrStatus[0]}


JD-TC-ChangeAnswerStatusForOrder-UH9
    [Documentation]   change answer status with non existant label name.

    ${resp}=  Provider Login  ${PUSERNAME138}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Catalog By Criteria  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${c_len}=  Get Length  ${resp.json()}
    @{cnames}=  Create List
    FOR  ${i}  IN RANGE   ${c_len}
        IF   '${resp.json()[${i}]['catalogName']}' in @{unique_cnames} and '${resp.json()[${i}]['orderType']}' == '${OrderTypes[0]}'
            ${CatalogId1}=   Set Variable   ${resp.json()[${i}]['id']}
        END
    END

    Set Suite Variable   ${CatalogId1}

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${minNumberItem}  ${resp.json()['catalogItem'][0]['minQuantity']}
    Set Test Variable  ${maxNumberItem}  ${resp.json()['catalogItem'][0]['maxQuantity']}
    Set Test Variable  ${sTime}  ${resp.json()['catalogSchedule']['timeSlots'][0]['sTime']}
    Set Test Variable  ${eTime}  ${resp.json()['catalogSchedule']['timeSlots'][0]['eTime']}
    Set Test Variable  ${item_id1}  ${resp.json()['catalogItem'][0]['item']['itemId']}

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
        IF  '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[8]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}'
            ${id}  Set Variable  ${resp.json()[${i}]['id']} 
            ${qnrid}   Set Variable  ${resp.json()[${i}]['questionnaireId']}
        END
        Exit For Loop If   '${id}' != '${None}'
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

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME21}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME21}  firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${cid21}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${cid21}  ${resp.json()[0]['id']}
    END

    ${DAY1}=   db.get_date
    ${pin}  ${city}  ${district}  ${state}=  get_pin_loc
    ${first}= 	Split String 	${fname}
    Set Test Variable  ${C_email}  ${first[0]}${CUSERNAME21}.${test_mail}
    ${landMark}=  FakerLibrary.street name 
    ${address}=  Create Dictionary   phoneNumber=${CUSERNAME21}    firstName=${fname}   lastName=${lname}   email=${C_email}    address=${district}   city=${city}   postalCode=${pin}    landMark=${landMark}   countryCode=${countryCodes[0]}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minNumberItem}  max=${maxNumberItem-1}
    ${orderNote}=  FakerLibrary.Sentence   nb_words=5

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME138}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Create Order By Provider For HomeDelivery    ${cookie}  ${cid21}   ${cid21}   ${CatalogId1}   ${boolean[1]}   ${address}  ${sTime}    ${eTime}   ${DAY1}    ${CUSERNAME21}    ${C_email}  ${orderNote}  ${countryCodes[1]}  ${item_id1}   ${item_quantity1}  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid1}  ${orderid[0]}
    
    ${resp}=   Get Order by uid    ${orderid1} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
       
    Should Be Equal As Strings  ${resp.json()['uid']}   ${orderid1}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}   ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}    ${bool[0]}

    ${resp}=  Get Consumer Questionnaire By Channel and OrderID    ${CatalogId1}   ${QnrChannel[0]}     ${cid21}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${resp.json()['id']}   ${id}

    ${fudata}=  db.fileUploadDT   ${resp.json()}  ${FileAction[0]}  ${Questionnaireid}  ${pdffile}
    Log  ${fudata} 
    ${data}=  db.QuestionnaireAnswers   ${resp.json()}   ${jdconID}   &{fudata}
    Log  ${data}
    Set Suite Variable   ${data}
    ${resp}=  Provider Validate Questionnaire  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME138}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Imageupload.POrderQAnsUpload   ${cookie}  ${orderid1}   ${data}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${files_data}=  Create List
    ${len}=  Get Length  ${resp.json()['urls']}
    FOR  ${i}  IN RANGE   ${len}
        Set Test Variable  ${fileid${i}}  ${resp.json()['urls'][${i}]['uid']}
        Set Test Variable  ${lblname${i}}  ${resp.json()['urls'][${i}]['labelName']}
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

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings  ${resp.json()['orderStatus']}   ${orderStatuses[0]}
    Check Answers   ${resp}  ${data}  ${QnrStatus[0]}  ${QnrStatus[0]}

    ${resp}=    Provider Change Answer Status for order   ${orderid1}   @{files_data}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()}    ${UPDATE_ERROR}

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings  ${resp.json()['orderStatus']}  ${orderStatuses[0]}
    Check Answers   ${resp}  ${data}  ${QnrStatus[0]}  ${QnrStatus[0]}


JD-TC-ChangeAnswerStatusForOrder-UH10
    [Documentation]   change answer status with invalid file id.

    ${resp}=  Provider Login  ${PUSERNAME138}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Catalog By Criteria  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${c_len}=  Get Length  ${resp.json()}
    @{cnames}=  Create List
    FOR  ${i}  IN RANGE   ${c_len}
        IF   '${resp.json()[${i}]['catalogName']}' in @{unique_cnames} and '${resp.json()[${i}]['orderType']}' == '${OrderTypes[0]}'
            ${CatalogId1}=   Set Variable   ${resp.json()[${i}]['id']}
        END
    END

    Set Suite Variable   ${CatalogId1}

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${minNumberItem}  ${resp.json()['catalogItem'][0]['minQuantity']}
    Set Test Variable  ${maxNumberItem}  ${resp.json()['catalogItem'][0]['maxQuantity']}
    Set Test Variable  ${sTime}  ${resp.json()['catalogSchedule']['timeSlots'][0]['sTime']}
    Set Test Variable  ${eTime}  ${resp.json()['catalogSchedule']['timeSlots'][0]['eTime']}
    Set Test Variable  ${item_id1}  ${resp.json()['catalogItem'][0]['item']['itemId']}

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
        IF  '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[8]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}'
            ${id}  Set Variable  ${resp.json()[${i}]['id']} 
            ${qnrid}   Set Variable  ${resp.json()[${i}]['questionnaireId']}
        END
        Exit For Loop If   '${id}' != '${None}'
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

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME21}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME21}  firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${cid21}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${cid21}  ${resp.json()[0]['id']}
    END

    ${DAY1}=   db.get_date
    ${pin}  ${city}  ${district}  ${state}=  get_pin_loc
    ${first}= 	Split String 	${fname}
    Set Test Variable  ${C_email}  ${first[0]}${CUSERNAME21}.${test_mail}
    ${landMark}=  FakerLibrary.street name 
    ${address}=  Create Dictionary   phoneNumber=${CUSERNAME21}    firstName=${fname}   lastName=${lname}   email=${C_email}    address=${district}   city=${city}   postalCode=${pin}    landMark=${landMark}   countryCode=${countryCodes[0]}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minNumberItem}  max=${maxNumberItem-1}
    ${orderNote}=  FakerLibrary.Sentence   nb_words=5

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME138}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Create Order By Provider For HomeDelivery    ${cookie}  ${cid21}   ${cid21}   ${CatalogId1}   ${boolean[1]}   ${address}  ${sTime}    ${eTime}   ${DAY1}    ${CUSERNAME21}    ${C_email}  ${orderNote}  ${countryCodes[1]}  ${item_id1}   ${item_quantity1}  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid1}  ${orderid[0]}
    
    ${resp}=   Get Order by uid    ${orderid1} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
       
    Should Be Equal As Strings  ${resp.json()['uid']}   ${orderid1}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}   ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}    ${bool[0]}

    ${resp}=  Get Consumer Questionnaire By Channel and OrderID    ${CatalogId1}   ${QnrChannel[0]}     ${cid21}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${resp.json()['id']}   ${id}

    ${fudata}=  db.fileUploadDT   ${resp.json()}  ${FileAction[0]}  ${Questionnaireid}  ${pdffile}
    Log  ${fudata}
    ${data}=  db.QuestionnaireAnswers   ${resp.json()}   ${jdconID}   &{fudata}
    Log  ${data}
    Set Suite Variable   ${data}
    ${resp}=  Provider Validate Questionnaire  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME138}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Imageupload.POrderQAnsUpload   ${cookie}  ${orderid1}   ${data}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${files_data}=  Create List
    ${len}=  Get Length  ${resp.json()['urls']}
    FOR  ${i}  IN RANGE   ${len}
        Set Test Variable  ${fileid${i}}  ${resp.json()['urls'][${i}]['uid']}
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

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings  ${resp.json()['orderStatus']}   ${orderStatuses[0]}
    Check Answers   ${resp}  ${data}  ${QnrStatus[0]}  ${QnrStatus[0]}

    ${resp}=    Provider Change Answer Status for order   ${orderid1}   @{files_data}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}    ${UPDATE_ERROR}

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings  ${resp.json()['orderStatus']}  ${orderStatuses[0]}
    Check Answers   ${resp}  ${data}  ${QnrStatus[0]}  ${QnrStatus[0]}
