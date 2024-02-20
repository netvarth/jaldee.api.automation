*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Run Keywords  Delete All Sessions
Force Tags        item options
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           OperatingSystem
Library           /ebs/TDD/excelfuncs.py
Resource          /ebs/TDD/SuperAdminKeywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

*** Variables ***
# ${xlFile}      ${EXECDIR}/TDD/sampleQnrWOAV.xlsx    # DataSheet
# ${xlFile1}     ${EXECDIR}/TDD/sampleqnr.xlsx    # DataSheet 1
# ${xlFile2}     ${EXECDIR}/TDD/qnr.xlsx    # DataSheet 2
${xlFile}      ${EXECDIR}/TDD/itemoptionsqnrcake.xlsx    # DataSheet
${jpgfile}     /ebs/TDD/uploadimage.jpg
${pngfile}     /ebs/TDD/upload.png
${pdffile}     /ebs/TDD/sample.pdf
${docfile}     /ebs/TDD/docsample.doc 
${mp4file}   /ebs/TDD/MP4file.mp4
${avifile}   /ebs/TDD/AVIfile.avi
${mp3file}   /ebs/TDD/MP3file.mp3
${self}      0
@{emptylist}


*** Keywords ***

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

JD-TC-ServiceOptionPaymentForItem-4
    [Documentation]  service options Item with GST and Coupon

    clear_Item      ${PUSERNAME23}

    ${wb}=  readWorkbook  ${xlFile}
    ${sheet1}  GetCurrentSheet   ${wb}
    Set Suite Variable   ${sheet1}
    ${colnames}=  getColumnHeaders  ${sheet1}
    Log List  ${colnames}
    Log List  ${QnrChannel}
    Log List  ${QnrTransactionType}
    Set Suite Variable   ${colnames}
    ${xl_item_names}   getColumnValuesByName  ${sheet1}  ${colnames[6]}
    Log   ${xl_item_names}
    # Set Suite Variable   ${catalognames}
    Remove Values From List  ${xl_item_names}   ${NONE}
    Log  ${xl_item_names}
    ${unique_itemnames}=    Remove Duplicates    ${xl_item_names}
    Log  ${unique_itemnames}
    Set Suite Variable   ${unique_itemnames}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME23}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${domain}    ${resp.json()['sector']}
    Set Suite Variable   ${subDomain}    ${resp.json()['subSector']}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[0]}'
        ${resp1}=   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${EMPTY}
        Should Be Equal As Strings  ${resp1.status_code}  200
    ELSE IF    '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[1]}'
        ${resp1}=   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    ${resp}=   Get Active License
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${lic1}  ${resp.json()['accountLicense']['licPkgOrAddonId']}

    ${domains}=  Jaldee Coupon Target Domains   ${domain}    
    ${sub_domains}=  Jaldee Coupon Target SubDomains   ${domain}_${subDomain}  
    ${licenses}=  Jaldee Coupon Target License  ${lic1}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10  

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cupn_codeG}=   FakerLibrary.word
    ${cupn_name}=    FakerLibrary.name
    ${cupn_des}=   FakerLibrary.sentence
    ${c_des}=   FakerLibrary.sentence
    ${p_des}=    FakerLibrary.sentence

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
    ${resp}=   Create Jaldee Coupon   ${cupn_codeG}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  90  ${bool[0]}  ${bool[0]}  100  100  1000  10  10  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}   ${domains}   ${sub_domains}   ALL  ${licenses}     targetDate=${targetDate}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Push Jaldee Coupon   ${cupn_codeG}   ${cupn_des}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME23}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_codeG}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_codeG}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}

    ${GST_num}  ${pan_num}=   Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[2]}  ${GST_num}
    Log    ${resp.json()}   
    ${resp}=  Enable Tax
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Account Payment Settings 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    IF   ${resp.json()['onlinePayment']}==${bool[0]}
        ${resp1}=  Enable Disable Online Payment   ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END
    
    ${resp}=   Get Account Payment Settings 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['onlinePayment']}   ${bool[1]}

    ${resp}=  Get Order Settings by account id
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableOrder']}==${bool[0]}
        ${resp1}=  Enable Order Settings
        Log  ${resp1.json()}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get Order Settings by account id
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableOrder']}   ${bool[1]}

    # ${displayName1}=   FakerLibrary.user name   
    # ${item1}=     FakerLibrary.word 
    # ${price1}=  Evaluate    random.uniform(100,300) 
    # ${itemCode1}=   FakerLibrary.word 
    # ${item_id1}=  Create Sample Item   ${displayName1}   ${item1}  ${itemCode1}  ${price1}  ${bool[1]}  

    # ${resp}=   Get Items 
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Item By Criteria  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${item_len}=  Get Length  ${resp.json()}
    @{item_names}=  Create List
    FOR  ${i}  IN RANGE   ${item_len}
        IF  '${resp.json()[${i}]['itemName']}' in @{unique_itemnames}
            ${item_id}=  Set Variable   ${resp.json()[${i}]['itemId']}
        ELSE
            Append To List  ${item_names}  ${resp.json()[${i}]['itemName']}
        END
    END

    Log  ${item_names}
    ${in_val}=    Get Variable Value    ${item_id}

    IF  '${in_val}'=='${None}'
        ${in_len}=  Get Length  ${unique_itemnames}
        FOR  ${i}  IN RANGE   ${in_len}
            ${kwstatus} 	${value} = 	Run Keyword And Ignore Error  List Should Contain Value  ${item_names}  ${unique_itemnames[${i}]}
            Log Many  ${kwstatus} 	${value}
            Continue For Loop If  '${kwstatus}' == 'PASS'
            ${displayName1}=   FakerLibrary.user name   
            # ${item1}=     FakerLibrary.word 
            ${price1}=  Evaluate    random.uniform(100,300) 
            ${itemCode1}=   FakerLibrary.word 
            ${resp}=  Create Sample Item   ${displayName1}   ${unique_itemnames[${i}]}  ${itemCode1}  ${price1}  ${bool[1]}  
            Should Be Equal As Strings  ${resp.status_code}  200
            Set Test Variable  ${item_id1}  ${resp.json()}
            
        END
    END
    # Set Test Variable  ${item_id1}

    Log  ${item_id1}

    ${resp}=   Get Items 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=   Get Item By Criteria  
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${cat_name}=     FakerLibrary.job
    ${CatalogId1}=   Create Sample Catalog  ${cat_name}   ${tz}  ${item_id1}

# <!-- *** Comments *** -->

    ${resp}=  Get Order Catalog    ${catalogid1}  
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

    ${resp}=  Encrypted Provider Login  ${PUSERNAME23}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
      ${id}  Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[2]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[1]}'  Set Variable  ${resp.json()[${i}]['id']} 
      ${qnrid}   Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[2]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[1]}'  Set Variable  ${resp.json()[${i}]['questionnaireId']}
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

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME23}  ${PASSWORD}
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
    ${address}=  Create Dictionary   phoneNumber=${CUSERNAME23}    firstName=${fname}   lastName=${lname}   email=${C_email}    address=${district}   city=${city}   postalCode=${pin}    landMark=${landMark}   countryCode=${countryCodes[0]}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minNumberItem}  max=${maxNumberItem-1}
    ${orderNote}=  FakerLibrary.Sentence   nb_words=5

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME23}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Get service options for an item  ${item_id1}  ${account_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${fudata}=  db.fileUploadDT   ${resp.json()}  ${FileAction[0]}  ${Questionnaireid}  ${pdffile}
    Log  ${fudata}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${data}=  db.QuestionnaireAnswers   ${resp.json()}   ${jdconID}   &{fudata}
    Log  ${data}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${data}=   setPrice  ${resp.json()}  ${data}
    Log  ${data}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${data}

    ${OrderDict}=    Order For Item Consumer   ${account_id}  ${self}  ${catalogid1}  ${bool[1]}  ${address}  ${sTime}  ${eTime}  ${DAY1}  ${CUSERNAME20}  ${C_email}  ${countryCodes[1]}  ${emptylist}  ${item_id1}  ${item_quantity1}
    Log  ${OrderDict}

    ${resp}=  Create Order With Service Options Consumer    ${cookie}    order=${OrderDict}    srvAnswers=${data}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid1}  ${orderid[0]}
    
    # ${resp}=   Create Order For HomeDelivery   ${cookie}  ${account_id}  ${self}  ${catalogid1}  ${bool[1]}  ${address}  ${sTime}  ${eTime}  ${DAY1}  ${CUSERNAME20}  ${C_email}  ${countryCodes[1]}  ${emptylist}  ${item_id1}  ${item_quantity1}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${orderid}=  Get Dictionary Values  ${resp.json()}
    # Set Suite Variable  ${orderid1}  ${orderid[0]}
    # Set Suite Variable      ${cookie}

    ${resp}=   Get Order By Id   ${account_id}   ${orderid1}  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}      ${orderid1}
    Log   ${resp}

    # ${resp}=  Get service options for an item  ${item_id1}  ${account_id}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${fudata}=  db.fileUploadDT   ${resp.json()}  ${FileAction[0]}  ${Questionnaireid}  ${pdffile}
    # Log  ${fudata}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${data}=  db.QuestionnaireAnswers   ${resp.json()}   ${jdconID}   &{fudata}
    # Log  ${data}
    # Should Be Equal As Strings  ${resp.status_code}  200
    
    # ${data}=   setPrice  ${resp.json()}  ${data}
    # Log  ${data}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${data}

    ${resp}=    Get Item By Catalog    ${catalogid1}   ${item_id1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}    200
    IF  '${resp.json()['promotionalPrice']}' == '${emptylist}'
        Set Suite Variable   ${itmprze}      ${resp.json()['price']}
    ELSE 
        Set Suite Variable   ${itmprze}      ${resp.json()['promotionalPrice']}
    END

    ${resp}=   Get Order By Id   ${account_id}   ${orderid1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${qty}          ${resp.json()['orderItem'][0]['quantity']}
    ${itemttl}=     Evaluate    ${itmprze}*${qty}
    Set Suite Variable   ${dlryChrg}     ${resp.json()['deliveryCharge']}
    ${ttl}      Evaluate    ${itemttl}+${dlryChrg}
    ${ttl}=     Convert To Number   ${ttl}   2
    Set Suite Variable   ${cartAmount}     ${resp.json()['cartAmount']}
    
    ${resp}=    Imageupload.CSubmitSerOptForItem   ${cookie}    ${item_id1}   ${orderid1}    ${account_id}   ${data}  ${pdffile}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order By Id   ${account_id}   ${orderid1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Check Answers   ${resp}  ${data}
    Set Suite Variable  ${s1Price}      ${resp.json()['serviceOptions'][0]['questionAnswers'][0]['answerLine']['answer']['dataGridList'][0]['totalPrice']}
    Set Suite Variable  ${s2Price}      ${resp.json()['serviceOptions'][0]['questionAnswers'][1]['answerLine']['answer']['dataGridList'][0]['totalPrice']}
    ${totalz}=    Evaluate    ${s1Price}+${s2Price}+${itemttl}
    ${ActualAmount}=    Evaluate    ${s1Price}+${s2Price}+${ttl}
    ${totalTaxAmount}=  Evaluate  ${totalz} * ${gstpercentage[2]} / 100
    ${ActualAmount}=    Evaluate    ${totalTaxAmount}+${ActualAmount}
    ${ActualAmount}=     Convert To Number   ${ActualAmount}   2
    Set Suite Variable  ${CartAmount}   ${resp.json()['cartAmount']}
    Should Be Equal As Strings      ${CartAmount}   ${ActualAmount}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME23}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Bill By UUId  ${orderid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Apply Jaldee Coupon By Provider  ${cupn_codeG}  ${orderid1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Bill By UUId  ${orderid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME23}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Bill By consumer  ${orderid1}  ${account_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

*** Comments ***

    # ${cnames_len}=  Get Length  ${unique_cnames}
    # FOR  ${i}  IN RANGE   ${cnames_len}
    #     ${kwstatus} 	${value} = 	Run Keyword And Ignore Error  List Should Contain Value   ${snames}   ${unique_cnames[${i}]}
    #     Log Many  ${kwstatus} 	${value}
    #     Continue For Loop If  '${kwstatus}' == 'PASS'
    #     &{dict}=  Create Dictionary   ${colnames[6]}=${unique_cnames[${i}]}
    #     ${ttype}=  getColumnValueByMultipleVals  ${sheet1}  ${colnames[1]}  &{dict}  
    #     Log  ${ttype}
    #     ${u_ttype}=    Remove Duplicates    ${ttype}
    #     Log  ${u_ttype}
    #     ${resp}=  Run Keyword If   '${kwstatus}' == 'FAIL' and '${QnrTransactionType[2]}' in @{u_ttype}  Create Sample Item   ${DisplayName1}   ${unique_cnames[${i}]}  ${itemCode1}  ${price1}  ${bool[1]}  
    # END

    # Set Suite Variable  ${item_id1}     ${resp.json()}


    ${resp}=   Get Catalog By Criteria
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${c_len}=  Get Length  ${resp.json()}
    @{cnames}=  Create List
    FOR  ${i}  IN RANGE   ${c_len}
        IF  '${resp.json()[${i}]['catalogName']}' in @{unique_cnames}
            ${CatalogId1}=  Set Variable   ${resp.json()[${i}]['id']}
        ELSE
            Append To List  ${cnames}  ${resp.json()[${i}]['catalogName']}
        END
    END

    Log  ${cnames}
    ${cat_val}=    Get Variable Value    ${CatalogId1}

    IF  '${srv_val}'=='${None}'
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
            ${CatalogId1}=  Run Keyword If   '${kwstatus}' == 'FAIL' and '${QnrTransactionType[2]}' in @{u_ttype}  Create Sample Catalog  ${unique_cnames[${i}]}   ${tz}  ${item_id1}  
        END
    END
    Set Test Variable  ${CatalogId1}

    ${resp}=   Get Item By Id    ${item_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=   Get Catalog By Criteria
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${c_len}=  Get Length  ${resp.json()}
    # @{cnames}=  Create List
    # FOR  ${i}  IN RANGE   ${c_len}
    #     Append To List  ${cnames}  ${resp.json()[${i}]['catalogName']}
    # END
    
    # FOR  ${i}  IN RANGE   ${cnames_len}
    #     ${kwstatus} 	${value} = 	Run Keyword And Ignore Error  List Should Contain Value  ${cnames}  ${unique_cnames[${i}]}
    #     Log Many  ${kwstatus} 	${value}
    #     Continue For Loop If  '${kwstatus}' == 'PASS'
    #     &{dict}=  Create Dictionary   ${colnames[6]}=${unique_cnames[${i}]}
    #     ${ttype}=  getColumnValueByMultipleVals  ${sheet1}  ${colnames[1]}  &{dict}  
    #     Log  ${ttype}
    #     ${u_ttype}=    Remove Duplicates    ${ttype}
    #     Log  ${u_ttype}
    #     ${CatalogId1}=  Run Keyword If   '${kwstatus}' == 'FAIL' and '${QnrTransactionType[2]}' in @{u_ttype}  Create Sample Catalog  ${unique_cnames[${i}]}   ${tz}  ${item_id1}  
    # END
    # Set Test Variable  ${CatalogId1}

    ${resp}=  Get Order Catalog    ${catalogid1}  
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

    ${resp}=  Encrypted Provider Login  ${PUSERNAME23}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
      ${id}  Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[2]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[1]}'  Set Variable  ${resp.json()[${i}]['id']} 
      ${qnrid}   Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[2]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[1]}'  Set Variable  ${resp.json()[${i}]['questionnaireId']}
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

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME23}  ${PASSWORD}
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
    ${address}=  Create Dictionary   phoneNumber=${CUSERNAME23}    firstName=${fname}   lastName=${lname}   email=${C_email}    address=${district}   city=${city}   postalCode=${pin}    landMark=${landMark}   countryCode=${countryCodes[0]}
    ${item_quantity1}=  FakerLibrary.Random Int  min=${minNumberItem}  max=${maxNumberItem-1}
    ${orderNote}=  FakerLibrary.Sentence   nb_words=5

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME23}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Get service options for an item  ${item_id1}  ${account_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${fudata}=  db.fileUploadDT   ${resp.json()}  ${FileAction[0]}  ${Questionnaireid}  ${pdffile}
    Log  ${fudata}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${data}=  db.QuestionnaireAnswers   ${resp.json()}   ${jdconID}   &{fudata}
    Log  ${data}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${data}=   setPrice  ${resp.json()}  ${data}
    Log  ${data}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${data}

    ${OrderDict}=    Order For Item Consumer   ${account_id}  ${self}  ${catalogid1}  ${bool[1]}  ${address}  ${sTime}  ${eTime}  ${DAY1}  ${CUSERNAME20}  ${C_email}  ${countryCodes[1]}  ${emptylist}  ${item_id1}  ${item_quantity1}
    Log  ${OrderDict}

    ${resp}=  Create Order With Service Options Consumer    ${cookie}    order=${OrderDict}    srvAnswers=${data}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${orderid1}  ${orderid[0]}
    
    # ${resp}=   Create Order For HomeDelivery   ${cookie}  ${account_id}  ${self}  ${catalogid1}  ${bool[1]}  ${address}  ${sTime}  ${eTime}  ${DAY1}  ${CUSERNAME20}  ${C_email}  ${countryCodes[1]}  ${emptylist}  ${item_id1}  ${item_quantity1}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${orderid}=  Get Dictionary Values  ${resp.json()}
    # Set Suite Variable  ${orderid1}  ${orderid[0]}
    # Set Suite Variable      ${cookie}

    ${resp}=   Get Order By Id   ${account_id}   ${orderid1}  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['uid']}      ${orderid1}
    Log   ${resp}

    # ${resp}=  Get service options for an item  ${item_id1}  ${account_id}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${fudata}=  db.fileUploadDT   ${resp.json()}  ${FileAction[0]}  ${Questionnaireid}  ${pdffile}
    # Log  ${fudata}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${data}=  db.QuestionnaireAnswers   ${resp.json()}   ${jdconID}   &{fudata}
    # Log  ${data}
    # Should Be Equal As Strings  ${resp.status_code}  200
    
    # ${data}=   setPrice  ${resp.json()}  ${data}
    # Log  ${data}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${data}

    ${resp}=    Get Item By Catalog    ${catalogid1}   ${item_id1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}    200
    IF  '${resp.json()['promotionalPrice']}' == '${emptylist}'
        Set Suite Variable   ${itmprze}      ${resp.json()['price']}
    ELSE 
        Set Suite Variable   ${itmprze}      ${resp.json()['promotionalPrice']}
    END

    ${resp}=   Get Order By Id   ${account_id}   ${orderid1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${qty}          ${resp.json()['orderItem'][0]['quantity']}
    ${itemttl}=     Evaluate    ${itmprze}*${qty}
    Set Suite Variable   ${dlryChrg}     ${resp.json()['deliveryCharge']}
    ${ttl}      Evaluate    ${itemttl}+${dlryChrg}
    ${ttl}=     Convert To Number   ${ttl}   2
    Set Suite Variable   ${cartAmount}     ${resp.json()['cartAmount']}
    
    ${resp}=    Imageupload.CSubmitSerOptForItem   ${cookie}    ${item_id1}   ${orderid1}    ${account_id}   ${data}  ${pdffile}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order By Id   ${account_id}   ${orderid1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Check Answers   ${resp}  ${data}
    Set Suite Variable  ${s1Price}      ${resp.json()['serviceOptions'][0]['questionAnswers'][0]['answerLine']['answer']['dataGridList'][0]['totalPrice']}
    Set Suite Variable  ${s2Price}      ${resp.json()['serviceOptions'][0]['questionAnswers'][1]['answerLine']['answer']['dataGridList'][0]['totalPrice']}
    ${totalz}=    Evaluate    ${s1Price}+${s2Price}+${itemttl}
    ${ActualAmount}=    Evaluate    ${s1Price}+${s2Price}+${ttl}
    ${totalTaxAmount}=  Evaluate  ${totalz} * ${gstpercentage[2]} / 100
    ${ActualAmount}=    Evaluate    ${totalTaxAmount}+${ActualAmount}
    ${ActualAmount}=     Convert To Number   ${ActualAmount}   2
    Set Suite Variable  ${CartAmount}   ${resp.json()['cartAmount']}
    Should Be Equal As Strings      ${CartAmount}   ${ActualAmount}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME23}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Bill By UUId  ${orderid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Apply Jaldee Coupon By Provider  ${cupn_codeG}  ${orderid1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Bill By UUId  ${orderid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME23}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Bill By consumer  ${orderid1}  ${account_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200