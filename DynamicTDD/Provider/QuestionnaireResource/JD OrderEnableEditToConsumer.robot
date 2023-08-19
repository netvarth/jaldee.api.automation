*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Run Keywords  Delete All Sessions
Force Tags        Questionnaire
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library 	      JSONLibrary
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
${pdffile}     /ebs/TDD/sample.pdf
${self}      0
@{emptylist}
${docfile}     /ebs/TDD/docsample.doc
#@{StatusList}    ${orderStatuses[0]}  ${orderStatuses[1]}  ${orderStatuses[2]}  ${orderStatuses[3]}     ${orderStatuses[9]}   ${orderStatuses[11]}   ${orderStatuses[12]}


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
JD-TC-OrderEnableEditToConsumer-1
    [Documentation]  Release Order for Consumer where release status is released
    
    ${resp}=  Consumer Login  ${CUSERNAME8}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}

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
    Set Suite Variable   ${catalognames}
    Remove Values From List  ${catalognames}   ${NONE}
    Log  ${catalognames}
    ${unique_cnames}=    Remove Duplicates    ${catalognames}
    Log  ${unique_cnames}
    Set Suite Variable   ${unique_cnames}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME6}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}

    ${resp}=  Get Order Settings by account id
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp1}=  Run Keyword If  ${resp.json()['enableOrder']}==${bool[0]}   Enable Order Settings   
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

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
        ${catalogid}=  Run Keyword If   '${resp.json()[${i}]['catalogName']}' in @{unique_cnames} and '${resp.json()[${i}]['orderType']}' == '${OrderTypes[0]}'   Set Variable   ${resp.json()[${i}]['id']}
        Append To List  ${cnames}  ${resp.json()[${i}]['catalogName']}
    END

    ${cat_val}=    Get Variable Value    ${catalogid}
    
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
            ${catalogid}=  Run Keyword If   '${kwstatus}' == 'FAIL' and '${QnrTransactionType[8]}' in @{u_ttype}  Create Sample Catalog  ${unique_cnames[${i}]}   ${tz}    ${item_id1}
   
        END
    END

    Set Suite Variable   ${catalogid}

    ${resp}=  Get Order Catalog    ${catalogid}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${minNumberItem}  ${resp.json()['catalogItem'][0]['minQuantity']}
    Set Test Variable  ${maxNumberItem}  ${resp.json()['catalogItem'][0]['maxQuantity']}
    Set Test Variable  ${sTime}  ${resp.json()['catalogSchedule']['timeSlots'][0]['sTime']}
    Set Test Variable  ${eTime}  ${resp.json()['catalogSchedule']['timeSlots'][0]['eTime']}

    ${resp}=  Provider Logout
    Log  ${resp.content}
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

    ${resp}=  Encrypted Provider Login  ${PUSERNAME6}  ${PASSWORD}
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
    Should Be Equal As Strings  ${qns.json()['transactionId']}  ${catalogid}

    ${resp1}=  Run Keyword If   '${qns.json()['status']}' == '${status[1]}'  Provider Change Questionnaire Status  ${id}  ${status[0]}  
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200
    
    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings   ${qns.json()['status']}  ${status[0]}
    Set Suite Variable  ${Questionnaireid}  ${qns.json()['questionnaireId']}

    # sleep  02s

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME8}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME8}  firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${cid20}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${cid20}  ${resp.json()[0]['id']}
    END

    ${DAY1}=   db.get_date_by_timezone  ${tz}
    ${pin}  ${city}  ${district}  ${state}=  get_pin_loc
    ${first}= 	Split String 	${fname}
    Set Test Variable  ${C_email}  ${first[0]}${CUSERNAME8}.ynwtest@netvarth.com
    ${landMark}=  FakerLibrary.street name 
    ${address}=  Create Dictionary   phoneNumber=${CUSERNAME8}    firstName=${fname}   lastName=${lname}   email=${C_email}    address=${district}   city=${city}   postalCode=${pin}    landMark=${landMark}   countryCode=${countryCodes[0]}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minNumberItem}  max=${maxNumberItem-1}
    ${orderNote}=  FakerLibrary.Sentence   nb_words=5

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME8}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=   Create Order For HomeDelivery   ${cookie}   ${account_id}    ${self}    ${catalogid}   ${bool[1]}    ${address}    ${sTime}    ${eTime}   ${DAY1}    ${CUSERNAME8}    ${C_email}  ${countryCodes[1]}  ${EMPTY_List}   ${item_id1}    ${item_quantity1} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid1}  ${orderid[0]}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME6}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order by uid    ${orderid1} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${ordernumber}     ${resp.json()['orderNumber']}   
    Should Be Equal As Strings  ${resp.json()['uid']}   ${orderid1}
    Should Be Equal As Strings  ${resp.json()['homeDelivery']}   ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['storePickup']}    ${bool[0]}

    ${resp}=  Get Consumer Questionnaire By Channel and OrderID    ${catalogid}   ${QnrChannel[0]}   ${cid20}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${resp.json()['id']}   ${id}

    ${fudata}=  db.fileUploadDT   ${resp.json()}  ${FileAction[0]}  ${Questionnaireid}  ${pdffile}
    Log  ${fudata}
    ${data}=  db.QuestionnaireAnswers   ${resp.json()}   ${cid20}   &{fudata}
    Log  ${data}
    Set Suite Variable   ${data}
    ${resp}=  Provider Validate Questionnaire  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME6}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200
    Set Suite Variable    ${cookie}

    ${resp}=  Imageupload.POrderQAnsUpload   ${cookie}  ${orderid1}   ${data}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME6}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Check Answers   ${resp}  ${data}
    Set Suite Variable    ${questId}    ${resp.json()['questionnaire']['questionnaireName']}
    
    ${resp}=    Release Order Qnr For Consumer    ${questId}   ${orderid1}   ${QnrReleaseStatus[1]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${string_resp}= 	Convert JSON To String 	${resp.json()['questionnaire']['questionAnswers'][0]['question']['scopTarget']['target']}
    Should Contain    ${string_resp}   ${apptBy[0]}
    Should Contain    ${string_resp}   ${apptBy[1]}

    ${resp}=    OrderEnableEditToConsumer    ${questId}   ${orderid1}    ${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME8}   ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    
    ${resp}=  Imageupload.COrderResubmitQns   ${cookie}  ${account_id}  ${orderid1}   ${data}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-OrderEnableEditToConsumer-UH1
    [Documentation]  Order Enable Edit To Consumer where release status is unreleased

    ${resp}=  Encrypted Provider Login  ${PUSERNAME6}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Check Answers   ${resp}  ${data}
    Set Suite Variable    ${questId}    ${resp.json()['questionnaire']['questionnaireName']}
    
    ${resp}=    Release Order Qnr For Consumer    ${questId}   ${orderid1}   ${QnrReleaseStatus[2]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${string_resp}= 	Convert JSON To String 	${resp.json()['questionnaire']['questionAnswers'][0]['question']['scopTarget']['target']}
    Should Contain    ${string_resp}   ${apptBy[0]}
    Should Not Contain    ${string_resp}   ${apptBy[1]}

    ${resp}=    OrderEnableEditToConsumer    ${questId}   ${orderid1}    ${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME8}   ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    
    ${resp}=  Imageupload.COrderResubmitQns   ${cookie}  ${account_id}  ${orderid1}   ${data}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    # Should Be Equal As Strings  ${resp.json()}     ${QNR_SAVE_FAILED}
    Should Be Equal As Strings  ${resp.json()}     ${CONSUMER_NOT_ALLOWED}

JD-TC-OrderEnableEditToConsumer-UH2
    [Documentation]  Order Enable Edit To Consumer Where status is false

    ${resp}=  Encrypted Provider Login  ${PUSERNAME6}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Check Answers   ${resp}  ${data}    

    ${resp}=    Release Order Qnr For Consumer    ${questId}   ${orderid1}   ${QnrReleaseStatus[2]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${string_resp}= 	Convert JSON To String 	${resp.json()['questionnaire']['questionAnswers'][0]['question']['scopTarget']['target']}
    Should Contain    ${string_resp}   ${apptBy[0]}
    Should Not Contain    ${string_resp}   ${apptBy[1]}

    ${resp}=    OrderEnableEditToConsumer    ${questId}   ${orderid1}    ${bool[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME8}   ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    
    ${resp}=  Imageupload.COrderResubmitQns   ${cookie}  ${account_id}  ${orderid1}   ${data}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    # Should Be Equal As Strings  ${resp.json()}     ${QNR_SAVE_FAILED}
    Should Be Equal As Strings  ${resp.json()}     ${CONSUMER_NOT_ALLOWED}

JD-TC-OrderEnableEditToConsumer-UH3
    [Documentation]  Resubmiting QNS Without Enables Edit for consumer

    ${resp}=  Encrypted Provider Login  ${PUSERNAME6}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Check Answers   ${resp}  ${data}
    Set Suite Variable    ${questId}    ${resp.json()['questionnaire']['questionnaireName']}
    
    ${resp}=    Release Order Qnr For Consumer    ${questId}   ${orderid1}   ${QnrReleaseStatus[1]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${string_resp}= 	Convert JSON To String 	${resp.json()['questionnaire']['questionAnswers'][0]['question']['scopTarget']['target']}
    Should Contain    ${string_resp}   ${apptBy[0]}
    Should Contain    ${string_resp}   ${apptBy[1]}

    # ${resp}=    OrderEnableEditToConsumer    ${questId}   ${orderid1}    ${bool[1]}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME8}   ${PASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200  
    
    # ${resp}=  Imageupload.CWlResubmitQns   ${cookie}  ${account_id}   ${orderid1}   ${data}  ${pdffile} 
    # Should Be Equal As Strings  ${resp.status_code}  422
    # Should Be Equal As Strings  ${resp.json()}     ${SB_CONTAINER_NOT_ALLOWED}

    ${resp}=    Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME8}   ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    
    ${resp}=  Imageupload.COrderResubmitQns   ${cookie}  ${account_id}  ${orderid1}   ${data}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}     ${SB_CONTAINER_NOT_ALLOWED}
    
JD-TC-OrderEnableEditToConsumer-UH4
    [Documentation]  Order Enable Edit To Consumer With invalid gnr id

    ${resp}=  Encrypted Provider Login  ${PUSERNAME6}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Check Answers   ${resp}  ${data}    

    ${resp}=    Release Order Qnr For Consumer    ${questId}   ${orderid1}   ${QnrReleaseStatus[1]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${string_resp}= 	Convert JSON To String 	${resp.json()['questionnaire']['questionAnswers'][0]['question']['scopTarget']['target']}
    Should Contain    ${string_resp}   ${apptBy[0]}
    Should Contain    ${string_resp}   ${apptBy[1]}

    ${inv_questId}=  Generate Random String  3  [NUMBERS]

    ${resp}=    OrderEnableEditToConsumer    ${inv_questId}   ${orderid1}    ${bool[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-OrderEnableEditToConsumer-UH5
    [Documentation]  Order Enable Edit To Consumer With invalid Order id

    ${resp}=  Encrypted Provider Login  ${PUSERNAME6}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Check Answers   ${resp}  ${data}    

    ${resp}=    Release Order Qnr For Consumer    ${questId}   ${orderid1}   ${QnrReleaseStatus[1]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${string_resp}= 	Convert JSON To String 	${resp.json()['questionnaire']['questionAnswers'][0]['question']['scopTarget']['target']}
    Should Contain    ${string_resp}   ${apptBy[0]}
    Should Contain    ${string_resp}   ${apptBy[1]}

    ${inv_orderid}=  Generate Random String  3  [NUMBERS]

    ${resp}=    OrderEnableEditToConsumer    ${questId}   ${inv_orderid}    ${bool[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  404
    Should Be Equal As Strings  ${resp.json()}    ${INVALID_APPOINTMENT}

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-OrderEnableEditToConsumer-UH6
    [Documentation]  Order Enable Edit To Consumer Without qnr id

    ${resp}=  Encrypted Provider Login  ${PUSERNAME6}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Check Answers   ${resp}  ${data}    

    ${resp}=    Release Order Qnr For Consumer    ${questId}   ${orderid1}   ${QnrReleaseStatus[1]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${string_resp}= 	Convert JSON To String 	${resp.json()['questionnaire']['questionAnswers'][0]['question']['scopTarget']['target']}
    Should Contain    ${string_resp}   ${apptBy[0]}
    Should Contain    ${string_resp}   ${apptBy[1]}

    ${resp}=    OrderEnableEditToConsumer    ${empty}   ${orderid1}    ${bool[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  404

JD-TC-OrderEnableEditToConsumer-UH7
    [Documentation]  Order Enable Edit To Consumer Without Order id

    ${resp}=  Encrypted Provider Login  ${PUSERNAME6}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Check Answers   ${resp}  ${data}    

    ${resp}=    Release Order Qnr For Consumer    ${questId}   ${orderid1}   ${QnrReleaseStatus[1]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order by uid     ${orderid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${string_resp}= 	Convert JSON To String 	${resp.json()['questionnaire']['questionAnswers'][0]['question']['scopTarget']['target']}
    Should Contain    ${string_resp}   ${apptBy[0]}
    Should Contain    ${string_resp}   ${apptBy[1]}

    ${resp}=    OrderEnableEditToConsumer    ${questId}   ${empty}    ${bool[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  404