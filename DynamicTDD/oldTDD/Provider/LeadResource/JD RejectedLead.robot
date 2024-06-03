*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Kyc
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/hl_providers.py
Library           /ebs/TDD/excelfuncs.py


*** Keywords ***



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


*** Variables ***
${self}     0
${xlFile}      ${EXECDIR}/TDD/LeadQnr.xlsx  
${jpgfile}      /ebs/TDD/uploadimage.jpg
${pngfile}      /ebs/TDD/upload.png
${pdffile}      /ebs/TDD/sample.pdf
${giffile}     /ebs/TDD/sample.gif
${jpegfile}     /ebs/TDD/large.jpeg
${shfile}     /ebs/TDD/example.sh
${docfile}     /ebs/TDD/docsample.doc
${txtfile}     /ebs/TDD/textsample.txt
${mp4file}      /ebs/TDD/MP4file.mp4
${mp3file}      /ebs/TDD/MP3file.mp3
@{emptylist}
${order}    0
${originFrom}    Lead
${telephoneType}    Residence
@{relationType}    Wife    Mother    Father
${idTypes}    Passport
${permanentPinCode}    679581
${customerName}    Hisham
${customerName1}    Sreekanth
${customerName2}    Amal
@{if_dt_list}   ${QnrDatatypes[5]}   ${QnrDatatypes[7]}  ${QnrDatatypes[8]}
&{id_zero}      id=${0}
${xlFilestatus}      ${EXECDIR}/TDD/creditverification.xlsx  
${loansanctionXlfile}     ${EXECDIR}/TDD/LoanSanction.xlsx
${Transaction_Name}       Credit Recommendation
${en_temp_name}   EnquiryName
${task_temp_name1}   Follow Up 1
${task_temp_name2}   Follow Up 2


*** Test Cases ***

JD-TC-RejectLeadStatus-1
    [Documentation]  lead status changed  to rejected with qns

    ${wb}=  readWorkbook  ${xlFile}
    ${sheet1}  GetCurrentSheet   ${wb}
    Set Suite Variable   ${sheet1}
    ${colnames}=  getColumnHeaders  ${sheet1}
    Log List  ${colnames}
    Log List  ${QnrChannel}
    Log List  ${QnrTransactionType}
    Set Suite Variable   ${colnames}
    ${leadnames}   getColumnValuesByName  ${sheet1}  ${colnames[6]}
    Log   ${leadnames}
    Remove Values From List  ${leadnames}   ${NONE}
    Log  ${leadnames}
    ${unique_lnames}=    Remove Duplicates    ${leadnames}
    Log  ${unique_lnames}
    Set Suite Variable   ${unique_lnames}

  
    ${domresp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${domresp.status_code}  200

    ${dlen}=  Get Length  ${domresp.json()}
    FOR  ${pos}  IN RANGE  ${dlen}  
        Set Test Variable  ${domain}  ${domresp.json()[${pos}]['domain']}

        ${subdomain}=  Get Billable Subdomain  ${domain}  ${domresp}  ${pos}  
        Set Test Variable   ${subdomain}
        Exit For Loop IF    '${subdomain}'

    END

    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_Z}=  Evaluate  ${PUSERNAME}+35656          
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_Z}${\n}
    ${pkg_id}=   get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domain}  ${subdomain}  ${PUSERNAME_Z}   ${pkg_id[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_Z}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_Z}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${PUSERNAME_Z}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 
 
    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}

    ${resp}=   CrifScore  ${account_id}

    ${resp}=   Get Active License
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    enquiryStatus  ${account_id}
    ${resp}=  categorytype   ${account_id}
    ${resp}=  tasktype       ${account_id}
    ${resp}=    Get Lead Category Type
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cat_len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${cat_len}
        IF  '${resp.json()[${i}]['name']}'=='${unique_lnames[0]}'
            Set Suite Variable  ${category_id1}    ${resp.json()[${i}]['id']}
            Set Suite Variable  ${category_name1}  ${resp.json()[${i}]['name']}
        END
    END

    ${cookie}  ${resp}=  Imageupload.SALogin    ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Imageupload.UploadQuestionnaire   ${cookie}   ${account_id}   ${xlFile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


   
    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
        IF  '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[9]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}' and '${resp.json()[${i}]['captureTime']}' == '${QnrcaptureTime[0]}'
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
    Should Be Equal As Strings  ${qns.json()['transactionId']}  ${category_id1}
    IF  '${qns.json()['status']}' == '${status[1]}' 
        ${resp1}=   Provider Change Questionnaire Status  ${id}  ${status[0]}  
        Should Be Equal As Strings  ${resp1.status_code}  200
    END
   
    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings   ${qns.json()['status']}  ${status[0]}
    Set Suite Variable  ${Questionnaireid}  ${qns.json()['questionnaireId']}

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
        IF  '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[9]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}' and '${resp.json()[${i}]['captureTime']}' == '${QnrcaptureTime[2]}'
            ${id1}   Set Variable  ${resp.json()[${i}]['id']}
            ${qnrid1}   Set Variable  ${resp.json()[${i}]['questionnaireId']}
            Exit For Loop If   '${id}' != '${None}'
        END
    END
    Set Suite Variable   ${id1}
    Set Suite Variable   ${qnrid1}
    ${qns}   Get Provider Questionnaire By Id   ${id1}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings  ${qns.json()['transactionId']}  ${category_id1}
    IF  '${qns.json()['status']}' == '${status[1]}' 
        ${resp1}=   Provider Change Questionnaire Status  ${id1}  ${status[0]}  
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=   leadStatus  ${account_id}
    ${resp}=    updateLeadStatus  ${account_id}
    ${resp}=    EnquiryStatus  ${account_id}
    ${resp}=    updateEnquiryStatus  ${account_id}
    sleep  01s


    ${cookie}  ${resp}=  Imageupload.SALogin    ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Imageupload.UploadQuestionnaire   ${cookie}   ${account_id}   ${xlFilestatus}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


   
    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
        IF  '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[10]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}' and '${resp.json()[${i}]['captureTime']}' == '${QnrcaptureTime[0]}'
            ${id12}   Set Variable  ${resp.json()[${i}]['id']}
            ${qnrid12}   Set Variable  ${resp.json()[${i}]['questionnaireId']}
            Exit For Loop If   '${id}' != '${None}'
        END
    END
    Set Suite Variable   ${id12}
    Set Suite Variable   ${qnrid12}
    
    ${qns}   Get Provider Questionnaire By Id   ${id12}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    # Should Be Equal As Strings  ${qns.json()['transactionId']}  ${category_id1}
    IF  '${qns.json()['status']}' == '${status[1]}' 
        ${resp1}=   Provider Change Questionnaire Status  ${id12}  ${status[0]}  
        Should Be Equal As Strings  ${resp1.status_code}  200
    END
   

    ${qns}   Get Provider Questionnaire By Id   ${id12}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings   ${qns.json()['status']}  ${status[0]}

# *** Comments ***
     ${cookie}  ${resp}=  Imageupload.SALogin    ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Imageupload.UploadQuestionnaire   ${cookie}   ${account_id}   ${loansanctionXlfile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


   
    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
        IF  '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[10]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}' and '${resp.json()[${i}]['captureTime']}' == '${QnrcaptureTime[0]}' and '${resp.json()[${i}]['questionnaireId']}' == '${Transaction_Name}' 
        # and '${resp.json()[${i}]['name']}' == '${QnrId[0]}'
            ${id33}   Set Variable  ${resp.json()[${i}]['id']}
            ${qnrid33}   Set Variable  ${resp.json()[${i}]['questionnaireId']}
            Exit For Loop If   '${id}' != '${None}'
        END
    END
    Set Suite Variable   ${id33}
    Set Suite Variable   ${qnrid33}
    
    ${qns}   Get Provider Questionnaire By Id   ${id33}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    # Should Be Equal As Strings  ${qns.json()['transactionId']}  ${category_id1}
    IF  '${qns.json()['status']}' == '${status[1]}' 
        ${resp1}=   Provider Change Questionnaire Status  ${id33}  ${status[0]}  
        Should Be Equal As Strings  ${resp1.status_code}  200
    END
   

    ${qns}   Get Provider Questionnaire By Id   ${id33}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings   ${qns.json()['status']}  ${status[0]}
   
    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  View Waitlist Settings
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # IF  ${resp.json()['filterByDept']}==${bool[0]}
    #     ${resp}=  Toggle Department Enable
    #     Log  ${resp.content}
    #     Should Be Equal As Strings  ${resp.status_code}  200

    # END
# *** Comments ***
    
    

    ${resp}=   Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${provider_id}  ${resp.json()['id']}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ELSE
        Set Suite Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME12}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME12}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${pcid18}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${pcid18}  ${resp.json()[0]['id']}
    END
  

    ${resp}=    Get Lead Status
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${status_id}    ${resp.json()[0]['id']}
    Set Suite Variable  ${status_id1}    ${resp.json()[1]['id']}
    Set Suite Variable  ${status_id2}    ${resp.json()[2]['id']}
    Set Suite Variable  ${status_id3}    ${resp.json()[3]['id']}
    Set Suite Variable  ${status_id4}    ${resp.json()[4]['id']}
    Set Suite Variable  ${status_id5}    ${resp.json()[5]['id']}
    Set Suite Variable  ${status_id6}    ${resp.json()[6]['id']}
    Set Suite Variable  ${status_id7}    ${resp.json()[7]['id']}
    Set Suite Variable  ${status_id8}    ${resp.json()[8]['id']}
    # Set Suite Variable  ${status_id9}    ${resp.json()[9]['id']}
    # Set Suite Variable  ${status_id10}    ${resp.json()[10]['id']}
    # Set Suite Variable  ${status_id11}    ${resp.json()[11]['id']}
    # Set Suite Variable  ${status_id12}    ${resp.json()[12]['id']}
    # Set Suite Variable  ${status_id13}    ${resp.json()[13]['id']}
    # Set Suite Variable  ${status_id14}    ${resp.json()[14]['id']}


    Set Suite Variable  ${statusName_id6}    ${resp.json()[5]['name']}
    ${note1}=  FakerLibrary.Sentence
    Set Suite Variable  ${note1}    
   
    
    ${resp}=    updateEnquiryStatus  ${account_id}
    sleep  01s

    ${resp}=  Get Provider Enquiry Category  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_catagories}=  Set Variable  ${resp.json()}
    ${random_catagories}=  Evaluate  random.choice($en_catagories)  random
    ${rand_catagory_id}=  Set Variable  ${random_catagories['id']}
    ${rand_catagory_name}=  Set Variable  ${random_catagories['name']}
    
    ${resp}=  Get Task Category Type  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_catagories}=  Set Variable  ${resp.json()}
    ${random_catagories}=  Evaluate  random.choice($en_catagories)  random
    ${rand_task_catagory_id}=  Set Variable  ${random_catagories['id']}
    ${rand_task_catagory_name}=  Set Variable  ${random_catagories['name']}

    ${resp}=  Get Provider Enquiry Type  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_cat_types}=  Set Variable  ${resp.json()}
    ${random_cat_types}=  Evaluate  random.choice($en_cat_types)  random
    ${rand_cat_type_id}=  Set Variable  ${random_cat_types['id']}
    ${rand_cat_type_name}=  Set Variable  ${random_cat_types['name']}

    ${resp}=    Get Task Type
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${task_cat_types}=  Set Variable  ${resp.json()}
    ${random_cat_types}=  Evaluate  random.choice($task_cat_types)  random
    ${rand_task_cat_type_id}=  Set Variable  ${random_cat_types['id']}
    ${rand_task_cat_type_name}=  Set Variable  ${random_cat_types['name']}

    ${resp}=    Get Task Priority
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${task_prios}=  Set Variable  ${resp.json()}
    ${random_priority}=  Evaluate  random.choice($task_prios)  random
    ${rand_task_priority_id}=  Set Variable  ${random_priority['id']}
    ${rand_task_priority_name}=  Set Variable  ${random_priority['name']}

    ${resp}=    Get Task Status
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}  Get Length  ${resp.json()}
    FOR   ${i}  IN RANGE   ${len}
        IF   '${resp.json()[${i}]['name']}' == 'New'

            Set Test Variable  ${new_status_id}    ${resp.json()[${i}]['id']}
            Set Test Variable  ${new_status_name}  ${resp.json()[${i}]['name']}

        END
    END

    ${resp}=    Get Lead Priority
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${lead_prios}=  Set Variable  ${resp.json()}
    ${random_priority}=  Evaluate  random.choice($lead_prios)  random
    ${rand_lead_priority_id}=  Set Variable  ${random_priority['id']}
    ${rand_lead_priority_name}=  Set Variable  ${random_priority['name']}

    ${resp}=    Get Lead Category Type
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${ld_cat}=  Set Variable  ${resp.json()}
    ${random_cat}=  Evaluate  random.choice($ld_cat)  random
    ${rand_lead_cat_id}=  Set Variable  ${random_cat['id']}
    ${rand_lead_cat_name}=  Set Variable  ${random_cat['name']}

    ${resp}=    Get Lead Type
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${ld_cat_type}=  Set Variable  ${resp.json()}
    ${random_cat_type}=  Evaluate  random.choice($ld_cat_type)  random
    ${rand_lead_cat_type_id}=  Set Variable  ${random_cat_type['id']}
    ${rand_lead_cat_type_name}=  Set Variable  ${random_cat_type['name']}

    ${resp}=    Get Lead Status
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}  Get Length  ${resp.json()}
    FOR   ${i}  IN RANGE   ${len}
        IF   '${resp.json()[${i}]['name']}' == 'New'

            Set Test Variable  ${lead_sts_new_id}    ${resp.json()[${i}]['id']}
            Set Test Variable  ${lead_sts_new_name}  ${resp.json()[${i}]['name']}

        END
    END

    ${lead_template_name}=   FakerLibrary.Domain Word
    leadTemplate   ${account_id}  ${lead_template_name}  ${lead_sts_new_id}  category_id=${rand_lead_cat_id}  type_id=${rand_lead_cat_type_id}  priority_id=${rand_lead_priority_id}  creator_provider_id=${provider_id} 

    ${resp}=    Get Lead Templates    
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${ld_temp_id}  ${resp.json()[0]['id']}

    ${resp}=  Get Provider Enquiry Status  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_statuses}=  Set Variable  ${resp.json()}
    ${random_status}=  Evaluate  random.choice($en_statuses)  random
    ${rand_status_id}=  Set Variable  ${random_status['id']}
    ${rand_status_name}=  Set Variable  ${random_status['name']}

    ${resp}=  Get Provider Enquiry Status  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}  Get Length  ${resp.json()}
    FOR   ${i}  IN RANGE   ${len}
        IF   '${resp.json()[${i}]['name']}' == 'Follow Up 1'

            Set Test Variable  ${enq_sts_new_id}    ${resp.json()[${i}]['id']}
            Set Test Variable  ${enq_sts_new_name}  ${resp.json()[${i}]['name']}

        END
    END



    # enquiryTemplate(account_id,category_id=0,priority_id=5,type_id=0)
    ${resp}=  enquiryTemplate  ${account_id}  ${en_temp_name}  ${enq_sts_new_id}    category_id=${rand_catagory_id}  type_id=${rand_cat_type_id}  creator_provider_id=${provider_id} 

    ${resp}=  Get Enquiry Template
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${en_temp_id}  ${resp.json()[0]['id']}

    taskTemplate  ${account_id}  ${task_temp_name1}  ${new_status_id}  origin_from=3  origin_id=${en_temp_id}  category_id=${rand_task_catagory_id}  type_id=${rand_task_cat_type_id}  priority_id=${rand_task_priority_id}  creator_provider_id=${provider_id} 

    taskTemplate  ${account_id}  ${task_temp_name2}  ${new_status_id}  origin_from=3  origin_id=${en_temp_id}  category_id=${rand_task_catagory_id}  type_id=${rand_task_cat_type_id}  priority_id=${rand_task_priority_id}  creator_provider_id=${provider_id} 

    ${title}=  FakerLibrary.Job
    ${desc}=   FakerLibrary.City
    ${category}=  Create Dictionary   id=${rand_catagory_id}
    ${type}=  Create Dictionary   id=${rand_cat_type_id}
    ${status}=  Create Dictionary   id=${rand_status_id}

    ${resp}=  Create Enquiry  ${locId}  ${pcid18}  title=${title}  description=${desc}  category=${category}  type=${type}  enquireMasterId=${en_temp_id}  leadMasterId=${ld_temp_id}      isLeadAutogenerate=${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${en_id}        ${resp.json()['id']}
    Set Test Variable   ${en_uid}        ${resp.json()['uid']}

    ${resp}=  Get Enquiry by Uuid  ${en_uid}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}   ${en_id}
    Should Be Equal As Strings  ${resp.json()['uid']}   ${en_uid}
    Should Be Equal As Strings  ${resp.json()['accountId']}   ${account_id}

    ${resp}=  Get Provider Enquiry Status  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}  Get Length  ${resp.json()}
    FOR   ${i}  IN RANGE   ${len}
        Set Test Variable  ${status_id${i}}    ${resp.json()[${i}]['id']}
        Set Test Variable  ${status_name${i}}  ${resp.json()[${i}]['name']}
    END

    Log many  ${status_id0}   ${status_id1}  ${status_id2}    ${status_id3}

    ${resp}=  Get Enquiry by Uuid  ${en_uid}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    # Set Test Variable  ${status_id0}    ${resp.json()['status']['id']}

    ${resp}=  Update and Proceed Enquiry to Status  ${en_uid}  ${status_id0}  ${locId}  ${pcid18}  &{resp.json()}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Get Enquiry by Uuid  ${en_uid}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200   
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id1}
    Should Be Equal As Strings    ${resp.json()['status']['name']}  ${status_name1}
  
    ${resp}=  Update and Proceed Enquiry to Status  ${en_uid}  ${status_id1}  ${locId}  ${pcid18}  &{resp.json()}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Get Enquiry by Uuid  ${en_uid}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id2}
    Should Be Equal As Strings    ${resp.json()['status']['name']}  ${status_name2}
  
    ${resp}=    Get Provider Tasks
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${dob}=    FakerLibrary.Date
    ${relationName}=    FakerLibrary.First Name
    ${idValue}=    FakerLibrary.Word
    ${fileName}=    FakerLibrary.File Name
    ${fileSize}=    FakerLibrary.Binary
    ${caption}=    FakerLibrary.Text
    ${resp}=  db.getType   ${jpegfile}
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${jpegfile}
    Set Suite Variable    ${fileType}
    ${permanentAddress}=    FakerLibrary.Word
    ${permanentCity}=    FakerLibrary.City
    ${permanentState}=    FakerLibrary.State
    ${panNumber}=  FakerLibrary.Credit Card Number
    ${caption3}=  Fakerlibrary.Sentence
    
    ${resp}=  db.getType   ${pdffile}
    Log  ${resp}
    ${fileType2}=  Get From Dictionary       ${resp}    ${pdffile}
    Set Suite Variable    ${fileType2}
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType5}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType5}
    ${list13}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption3}     fileType=${fileType5}   order=${order}
    ${list}=   Create List         ${list13}
    ${valida1}=    Create Dictionary    idTypes=${idTypes}     idValue=${idValue}    attachments=${list}
   
    ${caption5}=  Fakerlibrary.Sentence
    ${list1}=  Create Dictionary         owner=${provider_id}   fileName=${pdffile}    fileSize= 0.00458     caption=${caption5}     fileType=${fileType2}   order=${order}  
    ${list}=   Create List       ${list1}
    ${valida2}=    Create Dictionary    idTypes=UID     idValue=${idValue}    attachments=${list}
    ${validationId}=    Create List    ${valida1}    ${valida2}
    Set Suite Variable    ${validationId} 
    
    ${resp}=  Create KYC        ${en_uid}        ${customerName}    ${dob}        ${relationType[0]}    ${relationName}    ${telephoneType}    ${phoneNo}     ${validationId}      ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress}    ${permanentCity}   ${states[0]}    ${permanentPinCode}    ${panNumber}    ${bool[1]}   customer=${pcid18} 
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=    Get KYC    ${en_uid}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable   ${idkyc}        ${resp.json()[0]['id']}
    # Should Be Equal As Strings      ${resp.json()[0]['originFrom']}  ${originFrom}
    Should Be Equal As Strings      ${resp.json()[0]['originUid']}  ${en_uid}
    Should Be Equal As Strings      ${resp.json()[0]['customerName']}  ${customerName}
    Should Be Equal As Strings      ${resp.json()[0]['customer']}  ${pcid18}
    Should Be Equal As Strings      ${resp.json()[0]['relationName']}  ${relationName}
    Should Be Equal As Strings      ${resp.json()[0]['permanentAddress']}  ${permanentAddress}
    Should Be Equal As Strings      ${resp.json()[0]['permanentCity']}  ${permanentCity}
   
    ${resp}=  Get Enquiry by Uuid  ${en_uid}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id2}
    Should Be Equal As Strings    ${resp.json()['status']['name']}  ${status_name2}
    Set Suite Variable   ${stauslead1}        ${resp.json()['internalStatus']}

    ${resp}=  Change KYC Status     ${en_uid}      ${status_id2}          
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    sleep  02s
    ${resp}=    Get Leads With Filter    originUid-eq=${en_uid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${le_id}        ${resp.json()[0]['uid']}

    ${resp}=    Get KYC    ${le_id}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=  Get Enquiry by Uuid  ${en_uid}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id3}
    # Should Be Equal As Strings    ${resp.json()['status']['name']}  ${status_name2}
    Set Suite Variable   ${stauslead1}        ${resp.json()['internalStatus']}
   
    ${dob}=    FakerLibrary.Date
    ${relationName1}=    FakerLibrary.Last Name
    ${idValue}=    FakerLibrary.Name
    ${fileName}=    FakerLibrary.File Name
    ${fileSize}=    FakerLibrary.Binary
    ${caption}=    FakerLibrary.Text
    ${resp}=  db.getType   ${jpegfile}
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${jpegfile}
    Set Suite Variable    ${fileType}
    ${permanentAddress1}=    FakerLibrary.Address
    ${permanentCity1}=    FakerLibrary.City
    ${permanentState1}=    FakerLibrary.State
    ${panNumber1}=  FakerLibrary.Credit Card Number
 
    ${resp}=  Update KYC    ${idkyc}    ${le_id}     ${customerName}    ${dob}        ${relationType[0]}    ${relationName1}    ${telephoneType}    ${phoneNo}   ${validationId}      ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress1}    ${permanentCity1}    ${states[0]}    ${permanentPinCode}    ${panNumber1}    ${bool[1]}    customer=${pcid14}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=    Get KYC    ${le_id}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    # Should Be Equal As Strings      ${resp.json()[0]['originFrom']}  ${originFrom}
    Should Be Equal As Strings      ${resp.json()[0]['originUid']}  ${le_id}
    Should Be Equal As Strings      ${resp.json()[0]['customerName']}  ${customerName}
    Should Be Equal As Strings      ${resp.json()[0]['customer']}  ${pcid18}
    Should Be Equal As Strings      ${resp.json()[0]['permanentAddress']}  ${permanentAddress1}
    Should Be Equal As Strings      ${resp.json()[0]['permanentCity']}  ${permanentCity1}
   
    ${resp}=  Get Enquiry by Uuid  ${en_uid}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=   Get Lead By Id   ${le_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['kycCreated']}  ${bool[1]}
    
    # ${resp}=   Process CRIF Inquiry with kyc   ${le_id}    ${idkyc}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Status change crif   ${le_id}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
 
    
    # ${resp}=   Get CRIF Inquiry with kyc    ${le_id}   ${idkyc}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get States
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=   Get Lead By Id   ${le_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['kycCreated']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id1}
    
   
    ${resp}=  Get Questionnaire By uuid For Lead    ${le_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()[1]['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${resp.json()[1]['id']}   ${id}


    ${fudata}=  db.fileUploadDT   ${resp.json()[1]}  ${FileAction[0]}  ${mp4file}  ${mp3file}
    Log  ${fudata}

    ${data}=  db.QuestionnaireAnswers   ${resp.json()[1]}   ${pcid18}   &{fudata}
    Log  ${data}
    ${resp}=  Provider Validate Questionnaire  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME_Z}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Imageupload.PLeadQAnsUpload   ${cookie}  ${le_id}   ${data}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
     
    ${resp}=   Get Lead By Id  ${le_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id1}
 
  
    Check Answers   ${resp}  ${data}


    ${resp}=    Change Status Lead   ${status_id7}    ${le_id} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
   
    ${resp}=  Get Lead By Id   ${le_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['kycCreated']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id8}
   
   
  
    ${resp}=   Get Qnr for login status   ${le_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200



    ${fudata}=  db.fileUploadDTlead   ${resp.json()}  ${FileAction[0]}  ${mp4file}  
    Log  ${fudata}

    ${data12}=  db.QuestionnaireAnswerslead   ${resp.json()}   ${pcid18}   &{fudata}
    Log  ${data12}


    ${resp}=  Provider Validate Questionnaire  ${data12}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME_Z}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200
   
  

  
    ${resp}=  Imageupload.PLeadQAnsUpload   ${cookie}  ${le_id}   ${data12}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Change Status Lead    ${status_id8}    ${le_id} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  

    ${resp}=   Get Lead By Id  ${le_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['kycCreated']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id10}

    ${resp}=   Redirect lead   ${le_id}   ${status_id10}  ${note1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=   Get Lead By Id  ${le_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['kycCreated']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id8}


    ${resp}=    Change Status Lead    ${status_id8}    ${le_id} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=   Get Lead By Id  ${le_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['kycCreated']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id10}

    ${resp}=    Change Status Lead    ${status_id10}    ${le_id} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=   Get Lead By Id  ${le_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['kycCreated']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id11}

  
  
    ${qns}   Get Provider Questionnaire By Id   ${id12}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings   ${qns.json()['status']}  ${status[0]}

    ${resp}=   Get Qnr for login status   ${le_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200



    ${fudata}=  db.fileUploadDTlead    ${resp.json()}  ${FileAction[0]}  ${mp4file}  ${mp3file}
    Log  ${fudata}

    ${datastatus}=  db.QuestionnaireAnswerslead   ${resp.json()}   ${pcid18}   &{fudata}
    Log  ${datastatus}
    ${resp}=  Provider Validate Questionnaire  ${datastatus}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME_Z}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Imageupload.PLeadStatusQAnsUpload   ${cookie}  ${le_id}   ${datastatus}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
     
    ${resp}=   Get Lead By Id  ${le_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id11}
   
    ${resp}=    Change Status Lead    ${status_id11}    ${le_id} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Lead By Id  ${le_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id12}
  
    ${resp}=   Get Qnr for login status   ${le_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fudata}=  db.fileUploadDTlead    ${resp.json()}   ${FileAction[0]}   ${mp4file}   ${mp3file}
    Log  ${fudata}

    ${datastatusloan}=  db.QuestionnaireAnswerslead   ${resp.json()}   ${pcid18}   &{fudata}
    Log  ${datastatusloan}
    ${resp}=  Provider Validate Questionnaire  ${datastatusloan}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME_Z}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Imageupload.PLeadStatusQAnsUpload   ${cookie}  ${le_id}   ${datastatusloan}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
     
    ${resp}=   Get Lead By Id  ${le_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id12}
   
    ${resp}=    Change Status Lead    ${status_id12}    ${le_id} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Lead By Id  ${le_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id13}

    ${resp}=    Change Status Lead    ${status_id13}    ${le_id} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Lead By Id  ${le_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id14}

  
    ${resp}=    Rejected lead       ${le_id}   ${note1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Lead By Id  ${le_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id3}
  
JD-TC-RejectLeadStatus-2
    [Documentation]  lead status changed kyc updated to rejected with qns

    ${resp}=   Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${provider_id}  ${resp.json()['id']}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ELSE
        Set Suite Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END
  
    ${title3}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 
    ${targetPotential}=    FakerLibrary.Building Number
    Set Suite Variable  ${targetPotential}
    ${category}=    Create Dictionary   id=${category_id1}

    ${resp}=    Create Lead    ${title3}    ${desc}    ${targetPotential}      ${locId}    ${pcid18}   category=${category}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${leid1}        ${resp.json()['id']}
    Set Suite Variable   ${leUidR1}        ${resp.json()['uid']}

    ${resp}=    Get Lead By Id    ${leUidR1}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable   ${phoneNo}        ${resp.json()['customer']['phoneNo']}
    Should Be Equal As Strings      ${resp.json()['status']['id']}  ${status_id}


    ${dob}=    FakerLibrary.Date
    ${relationName}=    FakerLibrary.First Name
    ${idValue}=    FakerLibrary.Word
    ${fileName}=    FakerLibrary.File Name
    ${fileSize}=    FakerLibrary.Binary
    ${caption}=    FakerLibrary.Text
    ${resp}=  db.getType   ${jpegfile}
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${jpegfile}
    Set Suite Variable    ${fileType}
    ${permanentAddress}=    FakerLibrary.Word
    ${permanentCity}=    FakerLibrary.City
    ${permanentState}=    FakerLibrary.State
    # ${permanentPinCode}=    FakerLibrary.Postalcode
    ${panNumber}=  FakerLibrary.Credit Card Number
    ${caption3}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType5}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType5}
    ${list13}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption3}     fileType=${fileType5}   order=${order}
    ${list}=   Create List         ${list13}
    ${valida1}=    Create Dictionary    idTypes=${idTypes}     idValue=${idValue}    attachments=${list}
   
    ${caption5}=  Fakerlibrary.Sentence
    ${list1}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption5}     fileType=${fileType5}   order=${order}  
    ${list}=   Create List       ${list1}
    ${valida2}=    Create Dictionary    idTypes=UID     idValue=${idValue}    attachments=${list}
    ${validationId}=    Create List    ${valida1}    ${valida2}
    Set Suite Variable    ${validationId} 
    
    ${resp}=  Create KYC    ${originFrom}    ${leUidR1}        ${customerName}    ${dob}        ${relationType[0]}    ${relationName}    ${telephoneType}    ${phoneNo}     ${validationId}      ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress}    ${permanentCity}   ${states[0]}    ${permanentPinCode}    ${panNumber}    ${bool[1]}   customer=${pcid18} 
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=    Get KYC    ${leUidR1}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable   ${idkyc}        ${resp.json()[0]['id']}
    Should Be Equal As Strings      ${resp.json()[0]['originFrom']}  ${originFrom}
    Should Be Equal As Strings      ${resp.json()[0]['originUid']}  ${leUidR1}
    Should Be Equal As Strings      ${resp.json()[0]['customerName']}  ${customerName}
  #  Should Be Equal As Strings      ${resp.json()[0]['panNumber']}  ${panNumber}
    Should Be Equal As Strings      ${resp.json()[0]['customer']}  ${pcid18}
    Should Be Equal As Strings      ${resp.json()[0]['relationName']}  ${relationName}
    Should Be Equal As Strings      ${resp.json()[0]['permanentAddress']}  ${permanentAddress}
    Should Be Equal As Strings      ${resp.json()[0]['permanentCity']}  ${permanentCity}

   

    ${dob}=    FakerLibrary.Date
    ${relationName1}=    FakerLibrary.Last Name
    ${idValue}=    FakerLibrary.Name
    ${fileName}=    FakerLibrary.File Name
    ${fileSize}=    FakerLibrary.Binary
    ${caption}=    FakerLibrary.Text
    ${resp}=  db.getType   ${jpegfile}
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${jpegfile}
    Set Suite Variable    ${fileType}
    ${permanentAddress1}=    FakerLibrary.Address
    ${permanentCity1}=    FakerLibrary.City
    ${permanentState1}=    FakerLibrary.State
    # ${permanentPinCode}=    FakerLibrary.Postalcode
    ${panNumber1}=  FakerLibrary.Credit Card Number
   
    ${resp}=  Update KYC    ${idkyc}    ${originFrom}    ${leUidR1}        ${customerName}    ${dob}        ${relationType[0]}    ${relationName1}    ${telephoneType}    ${phoneNo}   ${validationId}      ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress1}    ${permanentCity1}    ${states[0]}    ${permanentPinCode}    ${panNumber1}    ${bool[1]}    customer=${pcid18}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

  
    ${resp}=    Get KYC    ${leUidR1}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Should Be Equal As Strings      ${resp.json()[0]['originFrom']}  ${originFrom}
    Should Be Equal As Strings      ${resp.json()[0]['originUid']}  ${leUidR1}
    Should Be Equal As Strings      ${resp.json()[0]['customerName']}  ${customerName}
    #Should Be Equal As Strings      ${resp.json()[0]['panNumber']}  ${panNumber1}
    Should Be Equal As Strings      ${resp.json()[0]['customer']}  ${pcid18}
    # Should Be Equal As Strings      ${resp.json()[0]['relationName']}  ${relationName1}
    Should Be Equal As Strings      ${resp.json()[0]['permanentAddress']}  ${permanentAddress1}
    Should Be Equal As Strings      ${resp.json()[0]['permanentCity']}  ${permanentCity1}

    # ${resp}=  Change KYC Status    ${originFrom}    ${leUidR1}    ${pcid18}    ${customerName}    ${dob}        ${relationType}    ${relationName1}    ${telephoneType}    ${phoneNo}       ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress1}    ${permanentCity1}    ${permanentState1}    ${permanentPinCode}    ${panNumber1}    ${bool[1]}    
    ${resp}=  Change KYC Status        ${leUidR1}       
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=   Get Lead By Id   ${leUidR1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['kycCreated']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id6}
    
    ${resp}=    Rejected lead       ${leUidR1}   ${note1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Lead By Id  ${leUidR1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id3}
    
JD-TC-RejectLeadStatus-3
    [Documentation]  lead status changed crif score generated to rejected 
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${provider_id}  ${resp.json()['id']}
  
   ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ELSE
        Set Suite Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END
  
    ${title3}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 
    ${targetPotential}=    FakerLibrary.Building Number
    Set Suite Variable  ${targetPotential}
    ${category}=    Create Dictionary   id=${category_id1}

    ${resp}=    Create Lead    ${title3}    ${desc}    ${targetPotential}      ${locId}    ${pcid18}   category=${category}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${leid1}        ${resp.json()['id']}
    Set Suite Variable   ${leUidR2}        ${resp.json()['uid']}

    ${resp}=    Get Lead By Id    ${leUidR2}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable   ${phoneNo}        ${resp.json()['customer']['phoneNo']}
    Should Be Equal As Strings      ${resp.json()['status']['id']}  ${status_id}


    ${dob}=    FakerLibrary.Date
    ${relationName}=    FakerLibrary.First Name
    ${idValue}=    FakerLibrary.Word
    ${fileName}=    FakerLibrary.File Name
    ${fileSize}=    FakerLibrary.Binary
    ${caption}=    FakerLibrary.Text
    ${resp}=  db.getType   ${jpegfile}
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${jpegfile}
    Set Suite Variable    ${fileType}
    ${permanentAddress}=    FakerLibrary.Word
    ${permanentCity}=    FakerLibrary.City
    ${permanentState}=    FakerLibrary.State
    # ${permanentPinCode}=    FakerLibrary.Postalcode
    ${panNumber}=  FakerLibrary.Credit Card Number
    ${caption3}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType5}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType5}
    ${list13}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption3}     fileType=${fileType5}   order=${order}
    ${list}=   Create List         ${list13}
    ${valida1}=    Create Dictionary    idTypes=${idTypes}     idValue=${idValue}    attachments=${list}
   
    ${caption5}=  Fakerlibrary.Sentence
    ${list1}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption5}     fileType=${fileType5}   order=${order}  
    ${list}=   Create List       ${list1}
    ${valida2}=    Create Dictionary    idTypes=UID     idValue=${idValue}    attachments=${list}
    ${validationId}=    Create List    ${valida1}    ${valida2}
    Set Suite Variable    ${validationId} 
    
    ${resp}=  Create KYC    ${originFrom}    ${leUidR2}        ${customerName}    ${dob}        ${relationType[0]}    ${relationName}    ${telephoneType}    ${phoneNo}     ${validationId}      ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress}    ${permanentCity}   ${states[0]}    ${permanentPinCode}    ${panNumber}    ${bool[1]}   customer=${pcid18} 
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=    Get KYC    ${leUidR2}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable   ${idkyc}        ${resp.json()[0]['id']}
    Should Be Equal As Strings      ${resp.json()[0]['originFrom']}  ${originFrom}
    Should Be Equal As Strings      ${resp.json()[0]['originUid']}  ${leUidR2}
    Should Be Equal As Strings      ${resp.json()[0]['customerName']}  ${customerName}
  #  Should Be Equal As Strings      ${resp.json()[0]['panNumber']}  ${panNumber}
    Should Be Equal As Strings      ${resp.json()[0]['customer']}  ${pcid18}
    Should Be Equal As Strings      ${resp.json()[0]['relationName']}  ${relationName}
    Should Be Equal As Strings      ${resp.json()[0]['permanentAddress']}  ${permanentAddress}
    Should Be Equal As Strings      ${resp.json()[0]['permanentCity']}  ${permanentCity}

   

    ${dob}=    FakerLibrary.Date
    ${relationName1}=    FakerLibrary.Last Name
    ${idValue}=    FakerLibrary.Name
    ${fileName}=    FakerLibrary.File Name
    ${fileSize}=    FakerLibrary.Binary
    ${caption}=    FakerLibrary.Text
    ${resp}=  db.getType   ${jpegfile}
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${jpegfile}
    Set Suite Variable    ${fileType}
    ${permanentAddress1}=    FakerLibrary.Address
    ${permanentCity1}=    FakerLibrary.City
    ${permanentState1}=    FakerLibrary.State
    # ${permanentPinCode}=    FakerLibrary.Postalcode
    ${panNumber1}=  FakerLibrary.Credit Card Number
   
    ${resp}=  Update KYC    ${idkyc}    ${originFrom}    ${leUidR2}        ${customerName}    ${dob}        ${relationType[0]}    ${relationName1}    ${telephoneType}    ${phoneNo}   ${validationId}      ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress1}    ${permanentCity1}    ${states[0]}    ${permanentPinCode}    ${panNumber1}    ${bool[1]}    customer=${pcid18}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

  
    ${resp}=    Get KYC    ${leUidR2}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Should Be Equal As Strings      ${resp.json()[0]['originFrom']}  ${originFrom}
    Should Be Equal As Strings      ${resp.json()[0]['originUid']}  ${leUidR2}
    Should Be Equal As Strings      ${resp.json()[0]['customerName']}  ${customerName}
    #Should Be Equal As Strings      ${resp.json()[0]['panNumber']}  ${panNumber1}
    Should Be Equal As Strings      ${resp.json()[0]['customer']}  ${pcid18}
    # Should Be Equal As Strings      ${resp.json()[0]['relationName']}  ${relationName1}
    Should Be Equal As Strings      ${resp.json()[0]['permanentAddress']}  ${permanentAddress1}
    Should Be Equal As Strings      ${resp.json()[0]['permanentCity']}  ${permanentCity1}

    # ${resp}=  Change KYC Status    ${originFrom}    ${leUidR2}    ${pcid18}    ${customerName}    ${dob}        ${relationType}    ${relationName1}    ${telephoneType}    ${phoneNo}       ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress1}    ${permanentCity1}    ${permanentState1}    ${permanentPinCode}    ${panNumber1}    ${bool[1]}    
    ${resp}=  Change KYC Status        ${leUidR2}       
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=   Get Lead By Id   ${leUidR2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['kycCreated']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id6}
    

    ${dob}=    FakerLibrary.Date
    ${relationName1}=    FakerLibrary.Last Name
    ${idValue}=    FakerLibrary.Name
    ${fileName}=    FakerLibrary.File Name
    ${fileSize}=    FakerLibrary.Binary
    ${caption}=    FakerLibrary.Text
    ${resp}=  db.getType   ${jpegfile}
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${jpegfile}
    Set Suite Variable    ${fileType}
    ${permanentAddress1}=    FakerLibrary.Address
    ${permanentCity1}=    FakerLibrary.City
    ${permanentState1}=    FakerLibrary.State
    # ${permanentPinCode}=    FakerLibrary.Postalcode
    ${panNumber1}=  FakerLibrary.Credit Card Number
   
    ${resp}=  Update KYC    ${idkyc}    ${originFrom}    ${leUidR2}        ${customerName}    ${dob}        ${relationType[0]}    ${relationName1}    ${telephoneType}    ${phoneNo}   ${validationId}      ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress1}    ${permanentCity1}    ${states[0]}    ${permanentPinCode}    ${panNumber1}    ${bool[1]}    customer=${pcid18}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

  
    ${resp}=    Get KYC    ${leUidR2}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Should Be Equal As Strings      ${resp.json()[0]['originFrom']}  ${originFrom}
    Should Be Equal As Strings      ${resp.json()[0]['originUid']}  ${leUidR2}
    Should Be Equal As Strings      ${resp.json()[0]['customerName']}  ${customerName}
    #Should Be Equal As Strings      ${resp.json()[0]['panNumber']}  ${panNumber1}
    Should Be Equal As Strings      ${resp.json()[0]['customer']}  ${pcid18}
    # Should Be Equal As Strings      ${resp.json()[0]['relationName']}  ${relationName1}
    Should Be Equal As Strings      ${resp.json()[0]['permanentAddress']}  ${permanentAddress1}
    Should Be Equal As Strings      ${resp.json()[0]['permanentCity']}  ${permanentCity1}

    # ${resp}=  Change KYC Status    ${originFrom}    ${leUidR2}    ${pcid18}    ${customerName}    ${dob}        ${relationType}    ${relationName1}    ${telephoneType}    ${phoneNo}       ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress1}    ${permanentCity1}    ${permanentState1}    ${permanentPinCode}    ${panNumber1}    ${bool[1]}    
    ${resp}=  Change KYC Status        ${leUidR2}       
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=   Get Lead By Id   ${leUidR2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['kycCreated']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id6}
    
    # ${resp}=   Process CRIF Inquiry with kyc   ${leUidR2}    ${idkyc}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Status change crif   ${leUidR2}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
 
    
    # ${resp}=   Get CRIF Inquiry with kyc    ${leUidR2}   ${idkyc}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get States
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=   Get Lead By Id   ${leUidR2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['kycCreated']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id1}
    
   
    ${resp}=    Rejected lead       ${leUidR2}   ${note1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Lead By Id  ${leUidR2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id3}
    
JD-TC-RejectLeadStatus-4
    [Documentation]  lead status changed sales varified to rejected 
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${provider_id}  ${resp.json()['id']}
  
   ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ELSE
        Set Suite Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END
  
    ${title3}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 
    ${targetPotential}=    FakerLibrary.Building Number
    Set Suite Variable  ${targetPotential}
    ${category}=    Create Dictionary   id=${category_id1}

    ${resp}=    Create Lead    ${title3}    ${desc}    ${targetPotential}      ${locId}    ${pcid18}   category=${category}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${leid1}        ${resp.json()['id']}
    Set Suite Variable   ${leUidR3}        ${resp.json()['uid']}

    ${resp}=    Get Lead By Id    ${leUidR3}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable   ${phoneNo}        ${resp.json()['customer']['phoneNo']}
    Should Be Equal As Strings      ${resp.json()['status']['id']}  ${status_id}


    ${dob}=    FakerLibrary.Date
    ${relationName}=    FakerLibrary.First Name
    ${idValue}=    FakerLibrary.Word
    ${fileName}=    FakerLibrary.File Name
    ${fileSize}=    FakerLibrary.Binary
    ${caption}=    FakerLibrary.Text
    ${resp}=  db.getType   ${jpegfile}
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${jpegfile}
    Set Suite Variable    ${fileType}
    ${permanentAddress}=    FakerLibrary.Word
    ${permanentCity}=    FakerLibrary.City
    ${permanentState}=    FakerLibrary.State
    # ${permanentPinCode}=    FakerLibrary.Postalcode
    ${panNumber}=  FakerLibrary.Credit Card Number
    ${caption3}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType5}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType5}
    ${list13}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption3}     fileType=${fileType5}   order=${order}
    ${list}=   Create List         ${list13}
    ${valida1}=    Create Dictionary    idTypes=${idTypes}     idValue=${idValue}    attachments=${list}
   
    ${caption5}=  Fakerlibrary.Sentence
    ${list1}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption5}     fileType=${fileType5}   order=${order}  
    ${list}=   Create List       ${list1}
    ${valida2}=    Create Dictionary    idTypes=UID     idValue=${idValue}    attachments=${list}
    ${validationId}=    Create List    ${valida1}    ${valida2}
    Set Suite Variable    ${validationId} 
    
    ${resp}=  Create KYC    ${originFrom}    ${leUidR3}        ${customerName}    ${dob}        ${relationType[0]}    ${relationName}    ${telephoneType}    ${phoneNo}     ${validationId}      ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress}    ${permanentCity}   ${states[0]}    ${permanentPinCode}    ${panNumber}    ${bool[1]}   customer=${pcid18} 
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=    Get KYC    ${leUidR3}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable   ${idkyc}        ${resp.json()[0]['id']}
    Should Be Equal As Strings      ${resp.json()[0]['originFrom']}  ${originFrom}
    Should Be Equal As Strings      ${resp.json()[0]['originUid']}  ${leUidR3}
    Should Be Equal As Strings      ${resp.json()[0]['customerName']}  ${customerName}
  #  Should Be Equal As Strings      ${resp.json()[0]['panNumber']}  ${panNumber}
    Should Be Equal As Strings      ${resp.json()[0]['customer']}  ${pcid18}
    Should Be Equal As Strings      ${resp.json()[0]['relationName']}  ${relationName}
    Should Be Equal As Strings      ${resp.json()[0]['permanentAddress']}  ${permanentAddress}
    Should Be Equal As Strings      ${resp.json()[0]['permanentCity']}  ${permanentCity}

   

    ${dob}=    FakerLibrary.Date
    ${relationName1}=    FakerLibrary.Last Name
    ${idValue}=    FakerLibrary.Name
    ${fileName}=    FakerLibrary.File Name
    ${fileSize}=    FakerLibrary.Binary
    ${caption}=    FakerLibrary.Text
    ${resp}=  db.getType   ${jpegfile}
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${jpegfile}
    Set Suite Variable    ${fileType}
    ${permanentAddress1}=    FakerLibrary.Address
    ${permanentCity1}=    FakerLibrary.City
    ${permanentState1}=    FakerLibrary.State
    # ${permanentPinCode}=    FakerLibrary.Postalcode
    ${panNumber1}=  FakerLibrary.Credit Card Number
   
    ${resp}=  Update KYC    ${idkyc}    ${originFrom}    ${leUidR3}        ${customerName}    ${dob}        ${relationType[0]}    ${relationName1}    ${telephoneType}    ${phoneNo}   ${validationId}      ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress1}    ${permanentCity1}    ${states[0]}    ${permanentPinCode}    ${panNumber1}    ${bool[1]}    customer=${pcid18}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

  
    ${resp}=    Get KYC    ${leUidR3}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Should Be Equal As Strings      ${resp.json()[0]['originFrom']}  ${originFrom}
    Should Be Equal As Strings      ${resp.json()[0]['originUid']}  ${leUidR3}
    Should Be Equal As Strings      ${resp.json()[0]['customerName']}  ${customerName}
    #Should Be Equal As Strings      ${resp.json()[0]['panNumber']}  ${panNumber1}
    Should Be Equal As Strings      ${resp.json()[0]['customer']}  ${pcid18}
    # Should Be Equal As Strings      ${resp.json()[0]['relationName']}  ${relationName1}
    Should Be Equal As Strings      ${resp.json()[0]['permanentAddress']}  ${permanentAddress1}
    Should Be Equal As Strings      ${resp.json()[0]['permanentCity']}  ${permanentCity1}

    # ${resp}=  Change KYC Status    ${originFrom}    ${leUidR3}    ${pcid18}    ${customerName}    ${dob}        ${relationType}    ${relationName1}    ${telephoneType}    ${phoneNo}       ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress1}    ${permanentCity1}    ${permanentState1}    ${permanentPinCode}    ${panNumber1}    ${bool[1]}    
    ${resp}=  Change KYC Status        ${leUidR3}       
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=   Get Lead By Id   ${leUidR3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['kycCreated']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id6}
    

    ${dob}=    FakerLibrary.Date
    ${relationName1}=    FakerLibrary.Last Name
    ${idValue}=    FakerLibrary.Name
    ${fileName}=    FakerLibrary.File Name
    ${fileSize}=    FakerLibrary.Binary
    ${caption}=    FakerLibrary.Text
    ${resp}=  db.getType   ${jpegfile}
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${jpegfile}
    Set Suite Variable    ${fileType}
    ${permanentAddress1}=    FakerLibrary.Address
    ${permanentCity1}=    FakerLibrary.City
    ${permanentState1}=    FakerLibrary.State
    # ${permanentPinCode}=    FakerLibrary.Postalcode
    ${panNumber1}=  FakerLibrary.Credit Card Number
   
    ${resp}=  Update KYC    ${idkyc}    ${originFrom}    ${leUidR3}        ${customerName}    ${dob}        ${relationType[0]}    ${relationName1}    ${telephoneType}    ${phoneNo}   ${validationId}      ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress1}    ${permanentCity1}    ${states[0]}    ${permanentPinCode}    ${panNumber1}    ${bool[1]}    customer=${pcid18}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

  
    ${resp}=    Get KYC    ${leUidR3}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Should Be Equal As Strings      ${resp.json()[0]['originFrom']}  ${originFrom}
    Should Be Equal As Strings      ${resp.json()[0]['originUid']}  ${leUidR3}
    Should Be Equal As Strings      ${resp.json()[0]['customerName']}  ${customerName}
    #Should Be Equal As Strings      ${resp.json()[0]['panNumber']}  ${panNumber1}
    Should Be Equal As Strings      ${resp.json()[0]['customer']}  ${pcid18}
    # Should Be Equal As Strings      ${resp.json()[0]['relationName']}  ${relationName1}
    Should Be Equal As Strings      ${resp.json()[0]['permanentAddress']}  ${permanentAddress1}
    Should Be Equal As Strings      ${resp.json()[0]['permanentCity']}  ${permanentCity1}

    # ${resp}=  Change KYC Status    ${originFrom}    ${leUidR3}    ${pcid18}    ${customerName}    ${dob}        ${relationType}    ${relationName1}    ${telephoneType}    ${phoneNo}       ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress1}    ${permanentCity1}    ${permanentState1}    ${permanentPinCode}    ${panNumber1}    ${bool[1]}    
    ${resp}=  Change KYC Status        ${leUidR3}       
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=   Get Lead By Id   ${leUidR3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['kycCreated']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id6}
    
    # ${resp}=   Process CRIF Inquiry with kyc   ${leUidR3}    ${idkyc}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Status change crif   ${leUidR3}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
 
    
    # ${resp}=   Get CRIF Inquiry with kyc    ${leUidR3}   ${idkyc}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get States
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=   Get Lead By Id   ${leUidR3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['kycCreated']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id1}
    
    

    ${resp}=    Change Status Lead   ${status_id7}    ${leUidR3} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
   
    ${resp}=  Get Lead By Id   ${leUidR3}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['kycCreated']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id8}
   
    ${resp}=    Rejected lead       ${leUidR3}   ${note1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Lead By Id  ${leUidR3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id3}
    
JD-TC-RejectLeadStatus-5
    [Documentation]  lead status changed login to rejected 
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${provider_id}  ${resp.json()['id']}
  
   ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ELSE
        Set Suite Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END
  
    ${title3}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 
    ${targetPotential}=    FakerLibrary.Building Number
    Set Suite Variable  ${targetPotential}
    ${category}=    Create Dictionary   id=${category_id1}

    ${resp}=    Create Lead    ${title3}    ${desc}    ${targetPotential}      ${locId}    ${pcid18}   category=${category}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${leid1}        ${resp.json()['id']}
    Set Suite Variable   ${leUidR4}        ${resp.json()['uid']}

    ${resp}=    Get Lead By Id    ${leUidR4}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable   ${phoneNo}        ${resp.json()['customer']['phoneNo']}
    Should Be Equal As Strings      ${resp.json()['status']['id']}  ${status_id}


    ${dob}=    FakerLibrary.Date
    ${relationName}=    FakerLibrary.First Name
    ${idValue}=    FakerLibrary.Word
    ${fileName}=    FakerLibrary.File Name
    ${fileSize}=    FakerLibrary.Binary
    ${caption}=    FakerLibrary.Text
    ${resp}=  db.getType   ${jpegfile}
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${jpegfile}
    Set Suite Variable    ${fileType}
    ${permanentAddress}=    FakerLibrary.Word
    ${permanentCity}=    FakerLibrary.City
    ${permanentState}=    FakerLibrary.State
    # ${permanentPinCode}=    FakerLibrary.Postalcode
    ${panNumber}=  FakerLibrary.Credit Card Number
    ${caption3}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType5}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType5}
    ${list13}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption3}     fileType=${fileType5}   order=${order}
    ${list}=   Create List         ${list13}
    ${valida1}=    Create Dictionary    idTypes=${idTypes}     idValue=${idValue}    attachments=${list}
   
    ${caption5}=  Fakerlibrary.Sentence
    ${list1}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption5}     fileType=${fileType5}   order=${order}  
    ${list}=   Create List       ${list1}
    ${valida2}=    Create Dictionary    idTypes=UID     idValue=${idValue}    attachments=${list}
    ${validationId}=    Create List    ${valida1}    ${valida2}
    Set Suite Variable    ${validationId} 
    
    ${resp}=  Create KYC    ${originFrom}    ${leUidR4}        ${customerName}    ${dob}        ${relationType[0]}    ${relationName}    ${telephoneType}    ${phoneNo}     ${validationId}      ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress}    ${permanentCity}   ${states[0]}    ${permanentPinCode}    ${panNumber}    ${bool[1]}   customer=${pcid18} 
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=    Get KYC    ${leUidR4}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable   ${idkyc}        ${resp.json()[0]['id']}
    Should Be Equal As Strings      ${resp.json()[0]['originFrom']}  ${originFrom}
    Should Be Equal As Strings      ${resp.json()[0]['originUid']}  ${leUidR4}
    Should Be Equal As Strings      ${resp.json()[0]['customerName']}  ${customerName}
  #  Should Be Equal As Strings      ${resp.json()[0]['panNumber']}  ${panNumber}
    Should Be Equal As Strings      ${resp.json()[0]['customer']}  ${pcid18}
    Should Be Equal As Strings      ${resp.json()[0]['relationName']}  ${relationName}
    Should Be Equal As Strings      ${resp.json()[0]['permanentAddress']}  ${permanentAddress}
    Should Be Equal As Strings      ${resp.json()[0]['permanentCity']}  ${permanentCity}

   

    ${dob}=    FakerLibrary.Date
    ${relationName1}=    FakerLibrary.Last Name
    ${idValue}=    FakerLibrary.Name
    ${fileName}=    FakerLibrary.File Name
    ${fileSize}=    FakerLibrary.Binary
    ${caption}=    FakerLibrary.Text
    ${resp}=  db.getType   ${jpegfile}
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${jpegfile}
    Set Suite Variable    ${fileType}
    ${permanentAddress1}=    FakerLibrary.Address
    ${permanentCity1}=    FakerLibrary.City
    ${permanentState1}=    FakerLibrary.State
    # ${permanentPinCode}=    FakerLibrary.Postalcode
    ${panNumber1}=  FakerLibrary.Credit Card Number
   
    ${resp}=  Update KYC    ${idkyc}    ${originFrom}    ${leUidR4}        ${customerName}    ${dob}        ${relationType[0]}    ${relationName1}    ${telephoneType}    ${phoneNo}   ${validationId}      ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress1}    ${permanentCity1}    ${states[0]}    ${permanentPinCode}    ${panNumber1}    ${bool[1]}    customer=${pcid18}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

  
    ${resp}=    Get KYC    ${leUidR4}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Should Be Equal As Strings      ${resp.json()[0]['originFrom']}  ${originFrom}
    Should Be Equal As Strings      ${resp.json()[0]['originUid']}  ${leUidR4}
    Should Be Equal As Strings      ${resp.json()[0]['customerName']}  ${customerName}
    #Should Be Equal As Strings      ${resp.json()[0]['panNumber']}  ${panNumber1}
    Should Be Equal As Strings      ${resp.json()[0]['customer']}  ${pcid18}
    # Should Be Equal As Strings      ${resp.json()[0]['relationName']}  ${relationName1}
    Should Be Equal As Strings      ${resp.json()[0]['permanentAddress']}  ${permanentAddress1}
    Should Be Equal As Strings      ${resp.json()[0]['permanentCity']}  ${permanentCity1}

    # ${resp}=  Change KYC Status    ${originFrom}    ${leUidR4}    ${pcid18}    ${customerName}    ${dob}        ${relationType}    ${relationName1}    ${telephoneType}    ${phoneNo}       ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress1}    ${permanentCity1}    ${permanentState1}    ${permanentPinCode}    ${panNumber1}    ${bool[1]}    
    ${resp}=  Change KYC Status        ${leUidR4}       
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=   Get Lead By Id   ${leUidR4}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['kycCreated']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id6}
    

   
    
    # ${resp}=   Process CRIF Inquiry with kyc   ${leUidR4}    ${idkyc}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Status change crif   ${leUidR4}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
 
    
    # ${resp}=   Get CRIF Inquiry with kyc    ${leUidR4}   ${idkyc}
    # Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get States
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=   Get Lead By Id   ${leUidR4}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['kycCreated']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id1}
    
    

    ${resp}=    Change Status Lead   ${status_id7}    ${leUidR4} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
   
    ${resp}=  Get Lead By Id   ${leUidR4}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['kycCreated']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id8}
   
       
    ${resp}=    Change Status Lead   ${status_id8}    ${leUidR4} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
   
    ${resp}=  Get Lead By Id   ${leUidR4}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['kycCreated']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id10}
   
    ${resp}=    Rejected lead       ${leUidR4}   ${note1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Lead By Id  ${leUidR4}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id3}
  
JD-TC-RejectLeadStatus-6
    [Documentation]  lead status changed login  varified to rejected 
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${provider_id}  ${resp.json()['id']}
  
   ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ELSE
        Set Suite Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END
  
    ${title3}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 
    ${targetPotential}=    FakerLibrary.Building Number
    Set Suite Variable  ${targetPotential}
    ${category}=    Create Dictionary   id=${category_id1}

    ${resp}=    Create Lead    ${title3}    ${desc}    ${targetPotential}      ${locId}    ${pcid18}   category=${category}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${leid1}        ${resp.json()['id']}
    Set Suite Variable   ${leuidR5}        ${resp.json()['uid']}

    ${resp}=    Get Lead By Id    ${leuidR5}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable   ${phoneNo}        ${resp.json()['customer']['phoneNo']}
    Should Be Equal As Strings      ${resp.json()['status']['id']}  ${status_id}


    ${dob}=    FakerLibrary.Date
    ${relationName}=    FakerLibrary.First Name
    ${idValue}=    FakerLibrary.Word
    ${fileName}=    FakerLibrary.File Name
    ${fileSize}=    FakerLibrary.Binary
    ${caption}=    FakerLibrary.Text
    ${resp}=  db.getType   ${jpegfile}
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${jpegfile}
    Set Suite Variable    ${fileType}
    ${permanentAddress}=    FakerLibrary.Word
    ${permanentCity}=    FakerLibrary.City
    ${permanentState}=    FakerLibrary.State
    # ${permanentPinCode}=    FakerLibrary.Postalcode
    ${panNumber}=  FakerLibrary.Credit Card Number
    ${caption3}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType5}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType5}
    ${list13}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption3}     fileType=${fileType5}   order=${order}
    ${list}=   Create List         ${list13}
    ${valida1}=    Create Dictionary    idTypes=${idTypes}     idValue=${idValue}    attachments=${list}
   
    ${caption5}=  Fakerlibrary.Sentence
    ${list1}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption5}     fileType=${fileType5}   order=${order}  
    ${list}=   Create List       ${list1}
    ${valida2}=    Create Dictionary    idTypes=UID     idValue=${idValue}    attachments=${list}
    ${validationId}=    Create List    ${valida1}    ${valida2}
    Set Suite Variable    ${validationId} 
    
    ${resp}=  Create KYC    ${originFrom}    ${leuidR5}        ${customerName}    ${dob}        ${relationType[0]}    ${relationName}    ${telephoneType}    ${phoneNo}     ${validationId}      ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress}    ${permanentCity}   ${states[0]}    ${permanentPinCode}    ${panNumber}    ${bool[1]}   customer=${pcid18} 
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=    Get KYC    ${leuidR5}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable   ${idkyc}        ${resp.json()[0]['id']}
    Should Be Equal As Strings      ${resp.json()[0]['originFrom']}  ${originFrom}
    Should Be Equal As Strings      ${resp.json()[0]['originUid']}  ${leuidR5}
    Should Be Equal As Strings      ${resp.json()[0]['customerName']}  ${customerName}
  #  Should Be Equal As Strings      ${resp.json()[0]['panNumber']}  ${panNumber}
    Should Be Equal As Strings      ${resp.json()[0]['customer']}  ${pcid18}
    Should Be Equal As Strings      ${resp.json()[0]['relationName']}  ${relationName}
    Should Be Equal As Strings      ${resp.json()[0]['permanentAddress']}  ${permanentAddress}
    Should Be Equal As Strings      ${resp.json()[0]['permanentCity']}  ${permanentCity}

   

    ${dob}=    FakerLibrary.Date
    ${relationName1}=    FakerLibrary.Last Name
    ${idValue}=    FakerLibrary.Name
    ${fileName}=    FakerLibrary.File Name
    ${fileSize}=    FakerLibrary.Binary
    ${caption}=    FakerLibrary.Text
    ${resp}=  db.getType   ${jpegfile}
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${jpegfile}
    Set Suite Variable    ${fileType}
    ${permanentAddress1}=    FakerLibrary.Address
    ${permanentCity1}=    FakerLibrary.City
    ${permanentState1}=    FakerLibrary.State
    # ${permanentPinCode}=    FakerLibrary.Postalcode
    ${panNumber1}=  FakerLibrary.Credit Card Number
   
    ${resp}=  Update KYC    ${idkyc}    ${originFrom}    ${leuidR5}        ${customerName}    ${dob}        ${relationType[0]}    ${relationName1}    ${telephoneType}    ${phoneNo}   ${validationId}      ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress1}    ${permanentCity1}    ${states[0]}    ${permanentPinCode}    ${panNumber1}    ${bool[1]}    customer=${pcid18}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

  
    ${resp}=    Get KYC    ${leuidR5}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Should Be Equal As Strings      ${resp.json()[0]['originFrom']}  ${originFrom}
    Should Be Equal As Strings      ${resp.json()[0]['originUid']}  ${leuidR5}
    Should Be Equal As Strings      ${resp.json()[0]['customerName']}  ${customerName}
    #Should Be Equal As Strings      ${resp.json()[0]['panNumber']}  ${panNumber1}
    Should Be Equal As Strings      ${resp.json()[0]['customer']}  ${pcid18}
    # Should Be Equal As Strings      ${resp.json()[0]['relationName']}  ${relationName1}
    Should Be Equal As Strings      ${resp.json()[0]['permanentAddress']}  ${permanentAddress1}
    Should Be Equal As Strings      ${resp.json()[0]['permanentCity']}  ${permanentCity1}

    # ${resp}=  Change KYC Status    ${originFrom}    ${leuidR5}    ${pcid18}    ${customerName}    ${dob}        ${relationType}    ${relationName1}    ${telephoneType}    ${phoneNo}       ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress1}    ${permanentCity1}    ${permanentState1}    ${permanentPinCode}    ${panNumber1}    ${bool[1]}    
    ${resp}=  Change KYC Status        ${leuidR5}       
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=   Get Lead By Id   ${leuidR5}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['kycCreated']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id6}
    

    
    # ${resp}=   Process CRIF Inquiry with kyc   ${leuidR5}    ${idkyc}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Status change crif   ${leuidR5}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
 
    
    # ${resp}=   Get CRIF Inquiry with kyc    ${leuidR5}   ${idkyc}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get States
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=   Get Lead By Id   ${leuidR5}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['kycCreated']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id1}
    
    

    ${resp}=    Change Status Lead   ${status_id7}    ${leuidR5} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
   
    ${resp}=  Get Lead By Id   ${leuidR5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['kycCreated']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id8}
   
       
    ${resp}=    Change Status Lead   ${status_id8}    ${leuidR5} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
   
    ${resp}=  Get Lead By Id   ${leuidR5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['kycCreated']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id10}

    ${resp}=    Change Status Lead   ${status_id10}    ${leuidR5} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
   
    ${resp}=  Get Lead By Id   ${leuidR5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['kycCreated']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id11}
   
   
    ${resp}=    Rejected lead       ${leuidR5}   ${note1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Lead By Id  ${leuidR5}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id3}
  
JD-TC-RejectLeadStatus-7
    [Documentation]  lead status changed credit recommendet to rejected 
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${provider_id}  ${resp.json()['id']}
  
    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ELSE
        Set Suite Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END
  
    ${title3}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 
    ${targetPotential}=    FakerLibrary.Building Number
    Set Suite Variable  ${targetPotential}
    ${category}=    Create Dictionary   id=${category_id1}

    ${resp}=    Create Lead    ${title3}    ${desc}    ${targetPotential}      ${locId}    ${pcid18}   category=${category}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${leid1}        ${resp.json()['id']}
    Set Suite Variable   ${leuidR6}        ${resp.json()['uid']}

    ${resp}=    Get Lead By Id    ${leuidR6}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable   ${phoneNo}        ${resp.json()['customer']['phoneNo']}
    Should Be Equal As Strings      ${resp.json()['status']['id']}  ${status_id}


    ${dob}=    FakerLibrary.Date
    ${relationName}=    FakerLibrary.First Name
    ${idValue}=    FakerLibrary.Word
    ${fileName}=    FakerLibrary.File Name
    ${fileSize}=    FakerLibrary.Binary
    ${caption}=    FakerLibrary.Text
    ${resp}=  db.getType   ${jpegfile}
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${jpegfile}
    Set Suite Variable    ${fileType}
    ${permanentAddress}=    FakerLibrary.Word
    ${permanentCity}=    FakerLibrary.City
    ${permanentState}=    FakerLibrary.State
    # ${permanentPinCode}=    FakerLibrary.Postalcode
    ${panNumber}=  FakerLibrary.Credit Card Number
    ${caption3}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType5}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType5}
    ${list13}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption3}     fileType=${fileType5}   order=${order}
    ${list}=   Create List         ${list13}
    ${valida1}=    Create Dictionary    idTypes=${idTypes}     idValue=${idValue}    attachments=${list}
   
    ${caption5}=  Fakerlibrary.Sentence
    ${list1}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption5}     fileType=${fileType5}   order=${order}  
    ${list}=   Create List       ${list1}
    ${valida2}=    Create Dictionary    idTypes=UID     idValue=${idValue}    attachments=${list}
    ${validationId}=    Create List    ${valida1}    ${valida2}
    Set Suite Variable    ${validationId} 
    
    ${resp}=  Create KYC    ${originFrom}    ${leuidR6}        ${customerName}    ${dob}        ${relationType[0]}    ${relationName}    ${telephoneType}    ${phoneNo}     ${validationId}      ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress}    ${permanentCity}   ${states[0]}    ${permanentPinCode}    ${panNumber}    ${bool[1]}   customer=${pcid18} 
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=    Get KYC    ${leuidR6}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable   ${idkyc}        ${resp.json()[0]['id']}
    Should Be Equal As Strings      ${resp.json()[0]['originFrom']}  ${originFrom}
    Should Be Equal As Strings      ${resp.json()[0]['originUid']}  ${leuidR6}
    Should Be Equal As Strings      ${resp.json()[0]['customerName']}  ${customerName}
  #  Should Be Equal As Strings      ${resp.json()[0]['panNumber']}  ${panNumber}
    Should Be Equal As Strings      ${resp.json()[0]['customer']}  ${pcid18}
    Should Be Equal As Strings      ${resp.json()[0]['relationName']}  ${relationName}
    Should Be Equal As Strings      ${resp.json()[0]['permanentAddress']}  ${permanentAddress}
    Should Be Equal As Strings      ${resp.json()[0]['permanentCity']}  ${permanentCity}

   

    ${dob}=    FakerLibrary.Date
    ${relationName1}=    FakerLibrary.Last Name
    ${idValue}=    FakerLibrary.Name
    ${fileName}=    FakerLibrary.File Name
    ${fileSize}=    FakerLibrary.Binary
    ${caption}=    FakerLibrary.Text
    ${resp}=  db.getType   ${jpegfile}
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${jpegfile}
    Set Suite Variable    ${fileType}
    ${permanentAddress1}=    FakerLibrary.Address
    ${permanentCity1}=    FakerLibrary.City
    ${permanentState1}=    FakerLibrary.State
    # ${permanentPinCode}=    FakerLibrary.Postalcode
    ${panNumber1}=  FakerLibrary.Credit Card Number
   
    ${resp}=  Update KYC    ${idkyc}    ${originFrom}    ${leuidR6}        ${customerName}    ${dob}        ${relationType[0]}    ${relationName1}    ${telephoneType}    ${phoneNo}   ${validationId}      ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress1}    ${permanentCity1}    ${states[0]}    ${permanentPinCode}    ${panNumber1}    ${bool[1]}    customer=${pcid18}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

  
    ${resp}=    Get KYC    ${leuidR6}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Should Be Equal As Strings      ${resp.json()[0]['originFrom']}  ${originFrom}
    Should Be Equal As Strings      ${resp.json()[0]['originUid']}  ${leuidR6}
    Should Be Equal As Strings      ${resp.json()[0]['customerName']}  ${customerName}
    #Should Be Equal As Strings      ${resp.json()[0]['panNumber']}  ${panNumber1}
    Should Be Equal As Strings      ${resp.json()[0]['customer']}  ${pcid18}
    # Should Be Equal As Strings      ${resp.json()[0]['relationName']}  ${relationName1}
    Should Be Equal As Strings      ${resp.json()[0]['permanentAddress']}  ${permanentAddress1}
    Should Be Equal As Strings      ${resp.json()[0]['permanentCity']}  ${permanentCity1}

    # ${resp}=  Change KYC Status    ${originFrom}    ${leuidR6}    ${pcid18}    ${customerName}    ${dob}        ${relationType}    ${relationName1}    ${telephoneType}    ${phoneNo}       ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress1}    ${permanentCity1}    ${permanentState1}    ${permanentPinCode}    ${panNumber1}    ${bool[1]}    
    ${resp}=  Change KYC Status        ${leuidR6}       
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=   Get Lead By Id   ${leuidR6}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['kycCreated']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id6}
    

   
    # ${resp}=   Process CRIF Inquiry with kyc   ${leuidR6}    ${idkyc}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Status change crif   ${leuidR6}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
 
    
    # ${resp}=   Get CRIF Inquiry with kyc    ${leuidR6}   ${idkyc}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get States
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=   Get Lead By Id   ${leuidR6}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['kycCreated']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id1}
    
    

    ${resp}=    Change Status Lead   ${status_id7}    ${leuidR6} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
   
    ${resp}=  Get Lead By Id   ${leuidR6}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['kycCreated']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id8}
   
       
    ${resp}=    Change Status Lead   ${status_id8}    ${leuidR6} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
   
    ${resp}=  Get Lead By Id   ${leuidR6}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['kycCreated']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id10}

    ${resp}=    Change Status Lead   ${status_id10}    ${leuidR6} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
   
    ${resp}=  Get Lead By Id   ${leuidR6}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['kycCreated']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id11}
   
   
    ${resp}=    Rejected lead       ${leuidR6}   ${note1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Lead By Id  ${leuidR6}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id3}
  
JD-TC-RejectLeadStatus-8
    [Documentation]  lead status changed credit recommend to rejected 
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${provider_id}  ${resp.json()['id']}
  
   ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ELSE
        Set Suite Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END
  
    ${title3}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 
    ${targetPotential}=    FakerLibrary.Building Number
    Set Suite Variable  ${targetPotential}
    ${category}=    Create Dictionary   id=${category_id1}

    ${resp}=    Create Lead    ${title3}    ${desc}    ${targetPotential}      ${locId}    ${pcid18}   category=${category}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${leid1}        ${resp.json()['id']}
    Set Suite Variable   ${leuidR7}        ${resp.json()['uid']}

    ${resp}=    Get Lead By Id    ${leuidR7}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable   ${phoneNo}        ${resp.json()['customer']['phoneNo']}
    Should Be Equal As Strings      ${resp.json()['status']['id']}  ${status_id}


    ${dob}=    FakerLibrary.Date
    ${relationName}=    FakerLibrary.First Name
    ${idValue}=    FakerLibrary.Word
    ${fileName}=    FakerLibrary.File Name
    ${fileSize}=    FakerLibrary.Binary
    ${caption}=    FakerLibrary.Text
    ${resp}=  db.getType   ${jpegfile}
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${jpegfile}
    Set Suite Variable    ${fileType}
    ${permanentAddress}=    FakerLibrary.Word
    ${permanentCity}=    FakerLibrary.City
    ${permanentState}=    FakerLibrary.State
    # ${permanentPinCode}=    FakerLibrary.Postalcode
    ${panNumber}=  FakerLibrary.Credit Card Number
    ${caption3}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType5}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType5}
    ${list13}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption3}     fileType=${fileType5}   order=${order}
    ${list}=   Create List         ${list13}
    ${valida1}=    Create Dictionary    idTypes=${idTypes}     idValue=${idValue}    attachments=${list}
   
    ${caption5}=  Fakerlibrary.Sentence
    ${list1}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption5}     fileType=${fileType5}   order=${order}  
    ${list}=   Create List       ${list1}
    ${valida2}=    Create Dictionary    idTypes=UID     idValue=${idValue}    attachments=${list}
    ${validationId}=    Create List    ${valida1}    ${valida2}
    Set Suite Variable    ${validationId} 
    
    ${resp}=  Create KYC    ${originFrom}    ${leuidR7}        ${customerName}    ${dob}        ${relationType[0]}    ${relationName}    ${telephoneType}    ${phoneNo}     ${validationId}      ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress}    ${permanentCity}   ${states[0]}    ${permanentPinCode}    ${panNumber}    ${bool[1]}   customer=${pcid18} 
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=    Get KYC    ${leuidR7}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable   ${idkyc}        ${resp.json()[0]['id']}
    Should Be Equal As Strings      ${resp.json()[0]['originFrom']}  ${originFrom}
    Should Be Equal As Strings      ${resp.json()[0]['originUid']}  ${leuidR7}
    Should Be Equal As Strings      ${resp.json()[0]['customerName']}  ${customerName}
  #  Should Be Equal As Strings      ${resp.json()[0]['panNumber']}  ${panNumber}
    Should Be Equal As Strings      ${resp.json()[0]['customer']}  ${pcid18}
    Should Be Equal As Strings      ${resp.json()[0]['relationName']}  ${relationName}
    Should Be Equal As Strings      ${resp.json()[0]['permanentAddress']}  ${permanentAddress}
    Should Be Equal As Strings      ${resp.json()[0]['permanentCity']}  ${permanentCity}

   

    ${dob}=    FakerLibrary.Date
    ${relationName1}=    FakerLibrary.Last Name
    ${idValue}=    FakerLibrary.Name
    ${fileName}=    FakerLibrary.File Name
    ${fileSize}=    FakerLibrary.Binary
    ${caption}=    FakerLibrary.Text
    ${resp}=  db.getType   ${jpegfile}
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${jpegfile}
    Set Suite Variable    ${fileType}
    ${permanentAddress1}=    FakerLibrary.Address
    ${permanentCity1}=    FakerLibrary.City
    ${permanentState1}=    FakerLibrary.State
    # ${permanentPinCode}=    FakerLibrary.Postalcode
    ${panNumber1}=  FakerLibrary.Credit Card Number
   
    ${resp}=  Update KYC    ${idkyc}    ${originFrom}    ${leuidR7}        ${customerName}    ${dob}        ${relationType[0]}    ${relationName1}    ${telephoneType}    ${phoneNo}   ${validationId}      ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress1}    ${permanentCity1}    ${states[0]}    ${permanentPinCode}    ${panNumber1}    ${bool[1]}    customer=${pcid18}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

  
    ${resp}=    Get KYC    ${leuidR7}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Should Be Equal As Strings      ${resp.json()[0]['originFrom']}  ${originFrom}
    Should Be Equal As Strings      ${resp.json()[0]['originUid']}  ${leuidR7}
    Should Be Equal As Strings      ${resp.json()[0]['customerName']}  ${customerName}
    #Should Be Equal As Strings      ${resp.json()[0]['panNumber']}  ${panNumber1}
    Should Be Equal As Strings      ${resp.json()[0]['customer']}  ${pcid18}
    # Should Be Equal As Strings      ${resp.json()[0]['relationName']}  ${relationName1}
    Should Be Equal As Strings      ${resp.json()[0]['permanentAddress']}  ${permanentAddress1}
    Should Be Equal As Strings      ${resp.json()[0]['permanentCity']}  ${permanentCity1}

    # ${resp}=  Change KYC Status    ${originFrom}    ${leuidR7}    ${pcid18}    ${customerName}    ${dob}        ${relationType}    ${relationName1}    ${telephoneType}    ${phoneNo}       ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress1}    ${permanentCity1}    ${permanentState1}    ${permanentPinCode}    ${panNumber1}    ${bool[1]}    
    ${resp}=  Change KYC Status        ${leuidR7}       
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=   Get Lead By Id   ${leuidR7}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['kycCreated']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id6}
    

   
    # ${resp}=   Process CRIF Inquiry with kyc   ${leuidR7}    ${idkyc}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Status change crif   ${leuidR7}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
 
    
    # ${resp}=   Get CRIF Inquiry with kyc    ${leuidR7}   ${idkyc}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get States
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=   Get Lead By Id   ${leuidR7}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['kycCreated']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id1}
    
    

    ${resp}=    Change Status Lead   ${status_id7}    ${leuidR7} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
   
    ${resp}=  Get Lead By Id   ${leuidR7}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['kycCreated']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id8}
   
       
    ${resp}=    Change Status Lead   ${status_id8}    ${leuidR7} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
   
    ${resp}=  Get Lead By Id   ${leuidR7}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['kycCreated']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id10}

    ${resp}=    Change Status Lead   ${status_id10}    ${leuidR7} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
   
    ${resp}=  Get Lead By Id   ${leuidR7}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['kycCreated']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id11}
   
    ${resp}=    Change Status Lead   ${status_id11}    ${leuidR7} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
   
    ${resp}=  Get Lead By Id   ${leuidR7}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['kycCreated']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id12}
   
    ${resp}=    Rejected lead       ${leuidR7}   ${note1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Lead By Id  ${leuidR7}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id3}
  
JD-TC-RejectLeadStatus-9
    [Documentation]  lead status changed Loan Disbursement to rejected 
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${provider_id}  ${resp.json()['id']}
  
   ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ELSE
        Set Suite Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END
  
    ${title3}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 
    ${targetPotential}=    FakerLibrary.Building Number
    Set Suite Variable  ${targetPotential}
    ${category}=    Create Dictionary   id=${category_id1}

    ${resp}=    Create Lead    ${title3}    ${desc}    ${targetPotential}      ${locId}    ${pcid18}   category=${category}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${leid1}        ${resp.json()['id']}
    Set Suite Variable   ${leuidR8}        ${resp.json()['uid']}

    ${resp}=    Get Lead By Id    ${leuidR8}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable   ${phoneNo}        ${resp.json()['customer']['phoneNo']}
    Should Be Equal As Strings      ${resp.json()['status']['id']}  ${status_id}


    ${dob}=    FakerLibrary.Date
    ${relationName}=    FakerLibrary.First Name
    ${idValue}=    FakerLibrary.Word
    ${fileName}=    FakerLibrary.File Name
    ${fileSize}=    FakerLibrary.Binary
    ${caption}=    FakerLibrary.Text
    ${resp}=  db.getType   ${jpegfile}
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${jpegfile}
    Set Suite Variable    ${fileType}
    ${permanentAddress}=    FakerLibrary.Word
    ${permanentCity}=    FakerLibrary.City
    ${permanentState}=    FakerLibrary.State
    # ${permanentPinCode}=    FakerLibrary.Postalcode
    ${panNumber}=  FakerLibrary.Credit Card Number
    ${caption3}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType5}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType5}
    ${list13}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption3}     fileType=${fileType5}   order=${order}
    ${list}=   Create List         ${list13}
    ${valida1}=    Create Dictionary    idTypes=${idTypes}     idValue=${idValue}    attachments=${list}
   
    ${caption5}=  Fakerlibrary.Sentence
    ${list1}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption5}     fileType=${fileType5}   order=${order}  
    ${list}=   Create List       ${list1}
    ${valida2}=    Create Dictionary    idTypes=UID     idValue=${idValue}    attachments=${list}
    ${validationId}=    Create List    ${valida1}    ${valida2}
    Set Suite Variable    ${validationId} 
    
    ${resp}=  Create KYC    ${originFrom}    ${leuidR8}        ${customerName}    ${dob}        ${relationType[0]}    ${relationName}    ${telephoneType}    ${phoneNo}     ${validationId}      ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress}    ${permanentCity}   ${states[0]}    ${permanentPinCode}    ${panNumber}    ${bool[1]}   customer=${pcid18} 
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=    Get KYC    ${leuidR8}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable   ${idkyc}        ${resp.json()[0]['id']}
    Should Be Equal As Strings      ${resp.json()[0]['originFrom']}  ${originFrom}
    Should Be Equal As Strings      ${resp.json()[0]['originUid']}  ${leuidR8}
    Should Be Equal As Strings      ${resp.json()[0]['customerName']}  ${customerName}
  #  Should Be Equal As Strings      ${resp.json()[0]['panNumber']}  ${panNumber}
    Should Be Equal As Strings      ${resp.json()[0]['customer']}  ${pcid18}
    Should Be Equal As Strings      ${resp.json()[0]['relationName']}  ${relationName}
    Should Be Equal As Strings      ${resp.json()[0]['permanentAddress']}  ${permanentAddress}
    Should Be Equal As Strings      ${resp.json()[0]['permanentCity']}  ${permanentCity}

   

    ${dob}=    FakerLibrary.Date
    ${relationName1}=    FakerLibrary.Last Name
    ${idValue}=    FakerLibrary.Name
    ${fileName}=    FakerLibrary.File Name
    ${fileSize}=    FakerLibrary.Binary
    ${caption}=    FakerLibrary.Text
    ${resp}=  db.getType   ${jpegfile}
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${jpegfile}
    Set Suite Variable    ${fileType}
    ${permanentAddress1}=    FakerLibrary.Address
    ${permanentCity1}=    FakerLibrary.City
    ${permanentState1}=    FakerLibrary.State
    # ${permanentPinCode}=    FakerLibrary.Postalcode
    ${panNumber1}=  FakerLibrary.Credit Card Number
   
    ${resp}=  Update KYC    ${idkyc}    ${originFrom}    ${leuidR8}        ${customerName}    ${dob}        ${relationType[0]}    ${relationName1}    ${telephoneType}    ${phoneNo}   ${validationId}      ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress1}    ${permanentCity1}    ${states[0]}    ${permanentPinCode}    ${panNumber1}    ${bool[1]}    customer=${pcid18}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

  
    ${resp}=    Get KYC    ${leuidR8}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Should Be Equal As Strings      ${resp.json()[0]['originFrom']}  ${originFrom}
    Should Be Equal As Strings      ${resp.json()[0]['originUid']}  ${leuidR8}
    Should Be Equal As Strings      ${resp.json()[0]['customerName']}  ${customerName}
    #Should Be Equal As Strings      ${resp.json()[0]['panNumber']}  ${panNumber1}
    Should Be Equal As Strings      ${resp.json()[0]['customer']}  ${pcid18}
    # Should Be Equal As Strings      ${resp.json()[0]['relationName']}  ${relationName1}
    Should Be Equal As Strings      ${resp.json()[0]['permanentAddress']}  ${permanentAddress1}
    Should Be Equal As Strings      ${resp.json()[0]['permanentCity']}  ${permanentCity1}

    # ${resp}=  Change KYC Status    ${originFrom}    ${leuidR8}    ${pcid18}    ${customerName}    ${dob}        ${relationType}    ${relationName1}    ${telephoneType}    ${phoneNo}       ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress1}    ${permanentCity1}    ${permanentState1}    ${permanentPinCode}    ${panNumber1}    ${bool[1]}    
    ${resp}=  Change KYC Status        ${leuidR8}       
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=   Get Lead By Id   ${leuidR8}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['kycCreated']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id6}
    

   
    # ${resp}=   Process CRIF Inquiry with kyc   ${leuidR8}    ${idkyc}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Status change crif   ${leuidR8}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
 
    
    # ${resp}=   Get CRIF Inquiry with kyc    ${leuidR8}   ${idkyc}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get States
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=   Get Lead By Id   ${leuidR8}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['kycCreated']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id1}
    
    

    ${resp}=    Change Status Lead   ${status_id7}    ${leuidR8} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
   
    ${resp}=  Get Lead By Id   ${leuidR8}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['kycCreated']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id8}
   
       
    ${resp}=    Change Status Lead   ${status_id8}    ${leuidR8} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
   
    ${resp}=  Get Lead By Id   ${leuidR8}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['kycCreated']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id10}

    ${resp}=    Change Status Lead   ${status_id10}    ${leuidR8} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
   
    ${resp}=  Get Lead By Id   ${leuidR8}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['kycCreated']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id11}
   
    ${resp}=    Change Status Lead   ${status_id11}    ${leuidR8} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
   
    ${resp}=  Get Lead By Id   ${leuidR8}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['kycCreated']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id12}
   
    ${resp}=    Change Status Lead   ${status_id12}    ${leuidR8} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
   
    ${resp}=  Get Lead By Id   ${leuidR8}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['kycCreated']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id13}
   
    ${resp}=    Change Status Lead   ${status_id13}    ${leuidR8} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
   
    ${resp}=  Get Lead By Id   ${leuidR8}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['kycCreated']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id14}

    ${resp}=    Rejected lead       ${leuidR8}   ${note1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Lead By Id  ${leuidR8}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id3}
  
JD-TC-RejectLeadStatus-UH1
    [Documentation]  lead status changed to rejected  invalid lead id
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${provider_id}  ${resp.json()['id']}
    ${INVALID_LEAD_ID}=   Replace String  ${INVALID_LEAD_ID}  {}  Lead

    ${resp}=    Rejected lead       6556t    ${note1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${INVALID_LEAD_ID}
  

  
JD-TC-RejectLeadStatus-UH2
    [Documentation]  lead status changed to rejected  without login
    
    ${resp}=    Rejected lead       ${leuidR8}   ${note1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.json()}   ${SESSION_EXPIRED}
  
JD-TC-RejectLeadStatus-UH3

    [Documentation]  lead status changed to rejected  consumer login

    ${resp}=  Consumer Login  ${CUSERNAME17}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

  
    ${resp}=    Rejected lead       ${leuidR8}   ${note1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   ${resp.json()}    ${LOGIN_NO_ACCESS_FOR_URL}
