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
${originFrom}    Enquire
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

${task_temp_name1}   Follow Up 1
${task_temp_name2}   Follow Up 2
${en_temp_name}   EnquiryName



*** Test Cases ***

JD-TC-ChangeLeadStatusbyuser-1
    [Documentation]  lead status change with  lead status qns
    
    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname1}   ${resp.json()['lastName']}
    Set Suite Variable  ${uname1}   ${resp.json()['userName']}

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
    ${leadnames}   getColumnValuesByName  ${sheet1}  ${colnames[6]}
    Log   ${leadnames}
    Remove Values From List  ${leadnames}   ${NONE}
    Log  ${leadnames}
    ${unique_lnames}=    Remove Duplicates    ${leadnames}
    Log  ${unique_lnames}
    Set Suite Variable   ${unique_lnames}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME42}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Set Test Variable  ${provider_id1}  ${resp.json()['id']}
    # Set Suite Variable  ${prov_fname11}  ${resp.json()['firstName']}
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${provider_id1}  ${decrypted_data['id']}
    Set Test Variable  ${prov_fname11}  ${decrypted_data['firstName']}

    ${highest_package}=  get_highest_license_pkg
    ${resp}=   Change License Package  ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    clear_customer   ${PUSERNAME42}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id1}  ${resp.json()['id']}
    Set Test Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Run Keyword If  ${resp.json()['enableTask']}==${bool[0]}   Enable Disable Task  ${toggle[0]}
    Run Keyword If  '${resp}' != '${None}'   Log  ${resp.content}
    Run Keyword If  '${resp}' != '${None}'   Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId1}=  Create Sample Location
        ${resp}=   Get Location ById  ${locId1}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ELSE
        Set Suite Variable  ${locId1}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END

    ${resp}=   Get Location ById  ${locId1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${loc_name1}  ${resp.json()['place']}

    ${resp}=   enquiryStatus  ${account_id1}
    ${resp}=   leadStatus     ${account_id1}
    ${resp}=   categorytype   ${account_id1}
    ${resp}=   tasktype       ${account_id1}

    ${resp}=    Get Lead Category Type
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cat_len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${cat_len}
        IF  '${resp.json()[${i}]['name']}'=='${unique_lnames[0]}'
            Set Suite Variable  ${lead_cat_id}    ${resp.json()[${i}]['id']}
            Set Suite Variable  ${lead_cat_name}  ${resp.json()[${i}]['name']}
        END
    END


# questionnaire upload

    ${cookie}  ${resp}=  Imageupload.SALogin    ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Imageupload.UploadQuestionnaire   ${cookie}   ${account_id1}   ${xlFile}
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
    Should Be Equal As Strings  ${qns.json()['transactionId']}  ${lead_cat_id}
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
    Should Be Equal As Strings  ${qns.json()['transactionId']}  ${lead_cat_id}
    IF  '${qns.json()['status']}' == '${status[1]}' 
        ${resp1}=   Provider Change Questionnaire Status  ${id1}  ${status[0]}  
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${cookie}  ${resp}=  Imageupload.SALogin    ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Imageupload.UploadQuestionnaire   ${cookie}   ${account_id1}   ${xlFilestatus}
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
    IF  '${qns.json()['status']}' == '${status[1]}' 
        ${resp1}=   Provider Change Questionnaire Status  ${id12}  ${status[0]}  
        Should Be Equal As Strings  ${resp1.status_code}  200
    END
   

    ${qns}   Get Provider Questionnaire By Id   ${id12}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings   ${qns.json()['status']}  ${status[0]}
    
    ${resp}=  Get Lead Status
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}  Get Length  ${resp.json()}
    FOR   ${i}  IN RANGE   ${len}
        Set Suite Variable  ${status_Lid${i}}    ${resp.json()[${i}]['id']}
        Set Suite Variable  ${status_Lname${i}}  ${resp.json()[${i}]['name']}
    END

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

    ${resp}=    updateEnquiryStatus  ${account_id1}
    ${resp}=    updateLeadStatus     ${account_id1}
    sleep  01s

    ${resp}=  Get Provider Enquiry Category  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_catagories}=  Set Variable  ${resp.json()}
    ${random_catagories}=  Evaluate  random.choice($en_catagories)  random
    ${rand_catagory_id}=  Set Variable  ${random_catagories['id']}  
    Set Suite Variable  ${rand_catagory_id}
    ${rand_catagory_name}=  Set Variable  ${random_catagories['name']}

    ${resp}=  Get Provider Enquiry Type  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_cat_types}=  Set Variable  ${resp.json()}
    ${random_cat_types}=  Evaluate  random.choice($en_cat_types)  random
    ${rand_cat_type_id}=  Set Variable  ${random_cat_types['id']}
    Set Suite Variable  ${rand_cat_type_id}
    ${rand_cat_type_name}=  Set Variable  ${random_cat_types['name']}

    ${resp}=  Get Task Category Type  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_catagories}=  Set Variable  ${resp.json()}
    ${random_catagories}=  Evaluate  random.choice($en_catagories)  random
    ${rand_task_catagory_id}=  Set Variable  ${random_catagories['id']}
    Set Suite Variable  ${rand_task_catagory_id}
    ${rand_task_catagory_name}=  Set Variable  ${random_catagories['name']}

    ${resp}=    Get Task Type
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${task_cat_types}=  Set Variable  ${resp.json()}
    ${random_cat_types}=  Evaluate  random.choice($task_cat_types)  random
    ${rand_task_cat_type_id}=  Set Variable  ${random_cat_types['id']}
    Set Suite Variable  ${rand_task_cat_type_id}
    ${rand_task_cat_type_name}=  Set Variable  ${random_cat_types['name']}

    ${resp}=    Get Task Priority
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${task_prios}=  Set Variable  ${resp.json()}
    ${random_priority}=  Evaluate  random.choice($task_prios)  random
    ${rand_task_priority_id}=  Set Variable  ${random_priority['id']}
    ${rand_task_priority_name}=  Set Variable  ${random_priority['name']}

    ${resp}=    Get Lead Priority
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${lead_prios}=  Set Variable  ${resp.json()}
    ${random_priority}=  Evaluate  random.choice($lead_prios)  random
    ${rand_lead_priority_id}=  Set Variable  ${random_priority['id']}
    ${rand_lead_priority_name}=  Set Variable  ${random_priority['name']}

    ${resp}=    Get Lead Type
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${ld_cat_type}=  Set Variable  ${resp.json()}
    ${random_cat_type}=  Evaluate  random.choice($ld_cat_type)  random
    ${rand_lead_cat_type_id}=  Set Variable  ${random_cat_type['id']}
    ${rand_lead_cat_type_name}=  Set Variable  ${random_cat_type['name']}

    ${lead_template_name}=   FakerLibrary.Domain Word
    leadTemplate   ${account_id1}  ${lead_template_name}  ${lead_sts_new_id}  category_id=${lead_cat_id}  type_id=${rand_lead_cat_type_id}  priority_id=${rand_lead_priority_id}  creator_provider_id=${provider_id1}

    ${resp}=    Get Lead Templates    
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${ld_temp_id}  ${resp.json()[0]['id']}

    ${resp}=  Get Provider Enquiry Status  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}  Get Length  ${resp.json()}
    FOR   ${i}  IN RANGE   ${len}
        IF   '${resp.json()[${i}]['name']}' == 'Follow Up 1'

            Set Suite Variable  ${enq_sts_new_id}    ${resp.json()[${i}]['id']}
            Set Test Variable  ${enq_sts_new_name}  ${resp.json()[${i}]['name']}

        END
    END

    ${resp}=  enquiryTemplate  ${account_id1}  ${en_temp_name}    ${enq_sts_new_id}  category_id=${rand_catagory_id}  type_id=${rand_cat_type_id}   creator_provider_id=${provider_id1}  

    ${resp}=  Get Enquiry Template
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${en_temp_id}  ${resp.json()[0]['id']}

    ${resp}=    Get Task Status
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}  Get Length  ${resp.json()}
    FOR   ${i}  IN RANGE   ${len}
        IF   '${resp.json()[${i}]['name']}' == 'New'

            Set Suite Variable  ${new_status_id}    ${resp.json()[${i}]['id']}
            Set Test Variable  ${new_status_name}  ${resp.json()[${i}]['name']}

        END
    END

    taskTemplate  ${account_id1}  ${task_temp_name1}   ${new_status_id}  origin_from=3  origin_id=${en_temp_id}  category_id=${rand_task_catagory_id}  type_id=${rand_task_cat_type_id}  priority_id=${rand_task_priority_id}  creator_provider_id=${provider_id1}
    taskTemplate  ${account_id1}  ${task_temp_name2}   ${new_status_id}  origin_from=3  origin_id=${en_temp_id}  category_id=${rand_task_catagory_id}  type_id=${rand_task_cat_type_id}  priority_id=${rand_task_priority_id}  creator_provider_id=${provider_id1}
 
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME18}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME18}  firstName=${fname1}  lastName=${lname1}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${pcid18}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${pcid18}  ${resp.json()[0]['id']}
    END

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME18}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable    ${phoneNo1}   ${resp.json()[0]['phoneNo']}
    
    ${bs}=  FakerLibrary.bs
    Set Suite Variable  ${bs}
    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    
    sleep  2s
    ${resp}=  Get Departments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}

    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF   not '${resp.content}' == '${emptylist}'
        ${len}=  Get Length  ${resp.json()}
        FOR   ${i}  IN RANGE   0   ${len}
            Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
            IF   not '${user_phone}' == '${PUSERNAME42}'
                clear_users  ${user_phone}
            END
        END
    END

    ${u_id}=  Create Sample User   admin=${bool[1]} 
    Set Suite Variable  ${u_id}

    ${resp}=  Get User By Id  ${u_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${PUSERNAME_U1}  ${resp.json()['mobileNo']}

    ${u_id1}=  Create Sample User   admin=${bool[1]} 
    Set Suite Variable  ${u_id1}

    ${resp}=  Get User By Id  ${u_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${PUSERNAME_U2}  ${resp.json()['mobileNo']}

    ${resp}=  SendProviderResetMail   ${PUSERNAME_U2}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${PUSERNAME_U2}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${first_name1}  ${resp.json()['firstName']}
    Set Suite Variable  ${user_name1}  ${resp.json()['userName']}


#    enquiry create

    ${title}=  FakerLibrary.Job
    ${desc}=   FakerLibrary.City
    ${category}=  Create Dictionary   id=${rand_catagory_id}
    ${type}=  Create Dictionary   id=${rand_cat_type_id}
    ${status}=  Create Dictionary   id=${enq_sts_new_id}

    ${resp}=  Create Enquiry  ${locId1}  ${pcid18}  title=${title}  description=${desc}  category=${category}  type=${type}  enquireMasterId=${en_temp_id}  leadMasterId=${ld_temp_id}      isLeadAutogenerate=${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${en_id1}        ${resp.json()['id']}
    Set Suite Variable   ${en_uid1}        ${resp.json()['uid']}


#    follow up 1

    ${resp}=  Get Provider Enquiry Status  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}  Get Length  ${resp.json()}
    FOR   ${i}  IN RANGE   ${len}
        Set Suite Variable  ${status_id${i}}    ${resp.json()[${i}]['id']}
        Set Suite Variable  ${status_name${i}}  ${resp.json()[${i}]['name']}
    END

    Log many  ${status_id0}   ${status_id1}  ${status_id2}    ${status_id3}

    ${resp}=  Get Enquiry by Uuid  ${en_uid1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update and Proceed Enquiry to Status  ${en_uid1}  ${status_id0}  ${locId1}  ${pcid18}  &{resp.json()}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Get Enquiry by Uuid  ${en_uid1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200  


#    follow up 2

    ${resp}=  Get Enquiry by Uuid  ${en_uid1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200  

    ${resp}=  Update and Proceed Enquiry to Status  ${en_uid1}  ${status_id1}  ${locId1}  ${pcid18}  &{resp.json()}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Get Enquiry by Uuid  ${en_uid1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

#    KYC

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
    ${list13}=  Create Dictionary         owner=${provider_id1}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption3}     fileType=${fileType5}   order=${order}
    ${list}=   Create List         ${list13}
    ${valida1}=    Create Dictionary    idTypes=${idTypes}     idValue=${idValue}    attachments=${list}
   
    ${caption5}=  Fakerlibrary.Sentence
    ${list1}=  Create Dictionary         owner=${provider_id1}   fileName=${pdffile}    fileSize= 0.00458     caption=${caption5}     fileType=${fileType2}   order=${order}  
    ${list}=   Create List       ${list1}
    ${valida2}=    Create Dictionary    idTypes=UID     idValue=${idValue}    attachments=${list}
    ${validationId}=    Create List    ${valida1}    ${valida2}
    Set Suite Variable    ${validationId} 
    
    ${resp}=  Create KYC        ${en_uid1}        ${customerName}    ${dob}        ${relationType[0]}    ${relationName}    ${telephoneType}    ${phoneNo1}     ${validationId}      ${provider_id1}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress}    ${permanentCity}   ${states[0]}    ${permanentPinCode}    ${panNumber}    ${bool[1]}   customer=${pcid18} 
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=    Get KYC    ${en_uid1}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable   ${idkyc}        ${resp.json()[0]['id']}

#    lead generation   
   
    ${resp}=  Change KYC Status     ${en_uid1}      ${status_id2}          
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    sleep  02s
    ${resp}=    Get Leads With Filter    originUid-eq=${en_uid1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${le_id1}        ${resp.json()[0]['id']}
    Set Suite Variable   ${le_uid1}        ${resp.json()[0]['uid']}

    ${resp}=    Get KYC    ${le_uid1}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200

#    crif

    ${resp}=   CrifScore  ${account_id1}

    ${resp}=  Get Enquiry by Uuid  ${en_uid1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
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
 
    ${resp}=  Update KYC    ${idkyc}    ${le_uid1}     ${customerName}    ${dob}      
    ...  ${relationType[0]}    ${relationName1}    ${telephoneType}    ${phoneNo1}  
    ...  ${validationId}      ${provider_id1}    ${fileName}    0.0054    ${caption}    
    ...  ${QnrfileTypes[1]}    ${order}    ${permanentAddress1}    ${permanentCity1}  
    ...  ${states[0]}  ${permanentPinCode}  ${panNumber1}  ${bool[1]}  customer=${pcid18}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=    Get KYC    ${le_uid1}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
   
    ${resp}=  Get Enquiry by Uuid  ${en_uid1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=   Get Lead By Id   ${le_uid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Process CRIF Inquiry with kyc   ${le_uid1}    ${idkyc}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Status change crif   ${le_uid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
 
    ${resp}=   Get CRIF Inquiry with kyc    ${le_uid1}   ${idkyc}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Lead By Id   ${le_uid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


#  Sales Field Verification

    ${resp}=  Get Questionnaire By uuid For Lead    ${le_uid1}
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

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME_U2}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Imageupload.PLeadQAnsUpload   ${cookie}  ${le_uid1}   ${data}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
     
    ${resp}=   Get Lead By Id   ${le_uid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Check Answers   ${resp}  ${data}
    
    ${resp}=    Change Status Lead   ${status_Lid2}    ${le_uid1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Lead By Id   ${le_uid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

#   login

    ${caption7}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType5}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType5}

    ${list1}=  Create Dictionary         owner=${provider_id1}   fileName=${jpgfile}    fileSize= 0.00858     caption=${caption7}     fileType=${fileType5}   order=${order}

    ${list}=   Create List          ${list1}
    ${valida1}=    Create Dictionary    idTypes=${idTypes}     idValue=${idValue}    attachments=${list}
   
    ${caption5}=  Fakerlibrary.Sentence
    ${list1}=  Create Dictionary         owner=${provider_id1}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption5}     fileType=${fileType5}   order=${order}  
    ${list}=   Create List       ${list1}
    ${valida2}=    Create Dictionary    idTypes=UID     idValue=${idValue}    attachments=${list}
    ${validationId2}=    Create List    ${valida1}    ${valida2}
    Set Test Variable    ${validationId2}
   
    ${resp}=  Update KYC    ${idkyc}        ${le_uid1}        ${customerName}    ${dob}        ${relationType[0]}    ${relationName1}    ${telephoneType}    ${phoneNo1}   ${validationId2}      ${provider_id1}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress1}    ${permanentCity1}    ${states[0]}    ${permanentPinCode}    ${panNumber1}    ${bool[1]}    customer=${pcid18}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
   
    ${resp}=    Get KYC    ${le_uid1}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
  
    ${resp}=   Get Qnr for login status   ${le_uid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${fudata}=  db.fileUploadDTlead   ${resp.json()}  ${FileAction[0]}  ${mp4file}  
    Log  ${fudata}

    ${data12}=  db.QuestionnaireAnswerslead   ${resp.json()}   ${pcid18}   &{fudata}
    Log  ${data12}


    ${resp}=  Provider Validate Questionnaire  ${data12}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME_U2}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200
    
    ${resp}=  Imageupload.PLeadQAnsUpload   ${cookie}  ${le_uid1}   ${data12}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Change Status Lead   ${status_Lid3}    ${le_uid1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Lead By Id   ${le_uid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

#   login verification

    ${resp}=    Change Status Lead    ${status_Lid4}    ${le_uid1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=   Get Lead By Id  ${le_uid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

#   Credit Recommandation

    ${qns}   Get Provider Questionnaire By Id   ${id12}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
   
    ${resp}=   Get Qnr for login status   ${le_uid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fudata}=  db.fileUploadDTlead    ${resp.json()}  ${FileAction[0]}  ${mp4file}  ${mp3file}
    Log  ${fudata}

    ${datastatus}=  db.QuestionnaireAnswerslead   ${resp.json()}   ${pcid18}   &{fudata}
    Log  ${datastatus}
    ${resp}=  Provider Validate Questionnaire  ${datastatus}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME_U2}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Imageupload.PLeadStatusQAnsUpload   ${cookie}  ${le_uid1}   ${datastatus}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
     
    ${resp}=   Get Lead By Id  ${le_uid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=    Change Status Lead    ${status_Lid5}    ${le_uid1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Lead By Id  ${le_uid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

#   Loan Sanction

    ${resp}=    Change Status Lead    ${status_Lid6}    ${le_uid1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Lead By Id  ${le_uid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-ChangeLeadStatusbyuser-2

    [Documentation]  lead status change Credit Score Generated to Sales Verified with qns
    
    ${resp}=  SendProviderResetMail   ${PUSERNAME_U1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${PUSERNAME_U1}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=   Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD} 
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


    #    enquiry create

    ${title}=  FakerLibrary.Job
    ${desc}=   FakerLibrary.City
    ${category}=  Create Dictionary   id=${rand_catagory_id}
    ${type}=  Create Dictionary   id=${rand_cat_type_id}
    ${status}=  Create Dictionary   id=${enq_sts_new_id}

    ${resp}=  Create Enquiry  ${locId1}  ${pcid18}  title=${title}  description=${desc}  category=${category}  type=${type}  enquireMasterId=${en_temp_id}  leadMasterId=${ld_temp_id}      isLeadAutogenerate=${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${en_id1}        ${resp.json()['id']}
    Set Suite Variable   ${en_uid1}        ${resp.json()['uid']}


#    follow up 1

    ${resp}=  Get Provider Enquiry Status  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}  Get Length  ${resp.json()}
    FOR   ${i}  IN RANGE   ${len}
        Set Test Variable  ${status_id${i}}    ${resp.json()[${i}]['id']}
        Set Test Variable  ${status_name${i}}  ${resp.json()[${i}]['name']}
    END

    Log many  ${status_id0}   ${status_id1}  ${status_id2}    ${status_id3}

    ${resp}=  Get Enquiry by Uuid  ${en_uid1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update and Proceed Enquiry to Status  ${en_uid1}  ${status_id0}  ${locId1}  ${pcid18}  &{resp.json()}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Get Enquiry by Uuid  ${en_uid1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200  

    ${resp}=    Get Provider Tasks
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    


#    follow up 2

    ${resp}=  Get Enquiry by Uuid  ${en_uid1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200  

    ${resp}=  Update and Proceed Enquiry to Status  ${en_uid1}  ${status_id1}  ${locId1}  ${pcid18}  &{resp.json()}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Get Enquiry by Uuid  ${en_uid1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=    Get Provider Tasks
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


#    KYC

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
    ${list13}=  Create Dictionary         owner=${provider_id1}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption3}     fileType=${fileType5}   order=${order}
    ${list}=   Create List         ${list13}
    ${valida1}=    Create Dictionary    idTypes=${idTypes}     idValue=${idValue}    attachments=${list}
   
    ${caption5}=  Fakerlibrary.Sentence
    ${list1}=  Create Dictionary         owner=${provider_id1}   fileName=${pdffile}    fileSize= 0.00458     caption=${caption5}     fileType=${fileType2}   order=${order}  
    ${list}=   Create List       ${list1}
    ${valida2}=    Create Dictionary    idTypes=UID     idValue=${idValue}    attachments=${list}
    ${validationId}=    Create List    ${valida1}    ${valida2}
    Set Suite Variable    ${validationId} 
    
    ${resp}=  Create KYC        ${en_uid1}        ${customerName}    ${dob}        ${relationType[0]}    ${relationName}    ${telephoneType}    ${phoneNo1}     ${validationId}      ${provider_id1}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress}    ${permanentCity}   ${states[0]}    ${permanentPinCode}    ${panNumber}    ${bool[1]}   customer=${pcid18} 
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=    Get KYC    ${en_uid1}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable   ${idkyc}        ${resp.json()[0]['id']}

#    lead generation   
   
    ${resp}=  Change KYC Status     ${en_uid1}      ${status_id2}          
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    sleep  02s
    ${resp}=    Get Leads With Filter    originUid-eq=${en_uid1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${le_id2}        ${resp.json()[0]['id']}
    Set Suite Variable   ${leUid2}        ${resp.json()[0]['uid']}

    ${resp}=   Get Lead By Id   ${leUid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['kycCreated']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_Lid6}

    ${resp}=    Get KYC    ${leUid2}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200

#    crif

    ${resp}=   CrifScore  ${account_id1}

    ${resp}=  Get Enquiry by Uuid  ${en_uid1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
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
 
    ${resp}=  Update KYC    ${idkyc}    ${leUid2}     ${customerName}    ${dob}      
    ...  ${relationType[0]}    ${relationName1}    ${telephoneType}    ${phoneNo1}  
    ...  ${validationId}      ${provider_id1}    ${fileName}    0.0054    ${caption}    
    ...  ${QnrfileTypes[1]}    ${order}    ${permanentAddress1}    ${permanentCity1}  
    ...  ${states[0]}  ${permanentPinCode}  ${panNumber1}  ${bool[1]}  customer=${pcid18}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=    Get KYC    ${leUid2}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
   
    ${resp}=  Get Enquiry by Uuid  ${en_uid1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=   Get Lead By Id   ${leUid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Process CRIF Inquiry with kyc   ${leUid2}    ${idkyc}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Status change crif   ${leUid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
 
    ${resp}=   Get CRIF Inquiry with kyc    ${leUid2}   ${idkyc}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Lead By Id   ${leUid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['kycCreated']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_Lid7}


    ${resp}=  Get Questionnaire By uuid For Lead    ${leUid2}
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

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME_U1}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Imageupload.PLeadQAnsUpload   ${cookie}  ${leUid2}   ${data}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
     
    ${resp}=   Get Lead By Id  ${leUid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_Lid7}
 
  
    Check Answers   ${resp}  ${data}


    ${resp}=    Change Status Lead   ${status_Lid7}    ${leUid2} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
   
    ${resp}=  Get Lead By Id   ${leUid2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['kycCreated']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_Lid8}
*** Comments ***
JD-TC-ChangeLeadStatusbyuser-3
    [Documentation]  lead status change  Sales Verified  to login with qns
 
    ${resp}=   Encrypted Provider Login  ${PUSERNAME_U2}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${provider_id}  ${resp.json()['id']}
  
    ${resp}=  Get Lead By Id   ${leUid2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['kycCreated']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id8}
   
   
  
    ${resp}=   Get Qnr for login status   ${leUid2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200



    ${fudata}=  db.fileUploadDTlead   ${resp.json()}  ${FileAction[0]}  ${mp4file}  
    Log  ${fudata}

    ${data12}=  db.QuestionnaireAnswerslead   ${resp.json()}   ${pcid18}   &{fudata}
    Log  ${data12}


    ${resp}=  Provider Validate Questionnaire  ${data12}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME_U2}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200
   
  
  
    ${resp}=  Imageupload.PLeadQAnsUpload   ${cookie}  ${leUid2}   ${data12}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Change Status Lead    ${status_id8}    ${leUid2} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  

    ${resp}=   Get Lead By Id  ${leUid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['kycCreated']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id10}

JD-TC-ChangeLeadStatusbyuser-4
    [Documentation]  lead status change   login to login varification  
  
    ${resp}=   Encrypted Provider Login  ${PUSERNAME_U2}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${provider_id}  ${resp.json()['id']}

    ${resp}=    Change Status Lead    ${status_id10}    ${leUid2} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=   Get Lead By Id  ${leUid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['kycCreated']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id11}

JD-TC-ChangeLeadStatusbyuser-5
    [Documentation]  lead status change   login varification  to credit recommendation with qnsans
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME_U2}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${provider_id}  ${resp.json()['id']}
   
    ${resp}=   Get Qnr for login status   ${leUid2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200



    ${fudata}=  db.fileUploadDTlead    ${resp.json()}  ${FileAction[0]}  ${mp4file}  ${mp3file}
    Log  ${fudata}

    ${datastatus}=  db.QuestionnaireAnswerslead   ${resp.json()}   ${pcid18}   &{fudata}
    Log  ${datastatus}
    ${resp}=  Provider Validate Questionnaire  ${datastatus}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME_U2}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Imageupload.PLeadStatusQAnsUpload   ${cookie}  ${leUid2}   ${datastatus}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
     
    ${resp}=   Get Lead By Id  ${leUid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id11}
   
    ${resp}=    Change Status Lead    ${status_id11}    ${leUid2} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Lead By Id  ${leUid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id12}
  

JD-TC-ChangeLeadStatusbyuser-6

    [Documentation]  lead status change    credit recommendation  to loan sanction with qnsans
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME_U2}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${provider_id}  ${resp.json()['id']}
  
    ${resp}=   Get Qnr for login status   ${leUid2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fudata}=  db.fileUploadDTlead    ${resp.json()}   ${FileAction[0]}   ${mp4file}   ${mp3file}
    Log  ${fudata}

    ${datastatusloan}=  db.QuestionnaireAnswerslead   ${resp.json()}   ${pcid18}   &{fudata}
    Log  ${datastatusloan}
    ${resp}=  Provider Validate Questionnaire  ${datastatusloan}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME_U2}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Imageupload.PLeadStatusQAnsUpload   ${cookie}  ${leUid2}   ${datastatusloan}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
     
    ${resp}=   Get Lead By Id  ${leUid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id12}
   
    ${resp}=    Change Status Lead    ${status_id12}    ${leUid2} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Lead By Id  ${leUid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id13}
  
JD-TC-ChangeLeadStatusbyuser-7

    [Documentation]  lead status change  loan sanction to Loan Disbursement

    ${resp}=   Encrypted Provider Login  ${PUSERNAME_U2}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${provider_id}  ${resp.json()['id']}
   
    ${resp}=    Change Status Lead    ${status_id13}    ${leUid2} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Lead By Id  ${leUid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id14}
 
JD-TC-ChangeLeadStatusbyuser-8

    [Documentation]  lead created by user then change status by branch

    ${resp}=   Encrypted Provider Login  ${PUSERNAME_U2}  ${PASSWORD} 
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
    ${category}=    Create Dictionary   id=${lead_cat_id}

    ${resp}=    Create Lead    ${title3}    ${desc}    ${targetPotential}      ${locId}    ${pcid18}   category=${category}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${leid1}        ${resp.json()['id']}
    Set Suite Variable   ${leUid3}        ${resp.json()['uid']}

    ${resp}=    Get Lead By Id    ${leUid3}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable   ${phoneNo}        ${resp.json()['customer']['phoneNo']}
    Should Be Equal As Strings      ${resp.json()['status']['id']}  ${status_Lid0}


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
    
    ${resp}=  Create KYC    ${originFrom}    ${leUid3}        ${customerName}    ${dob}        ${relationType[0]}    ${relationName}    ${telephoneType}    ${phoneNo}     ${validationId}      ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress}    ${permanentCity}   ${states[0]}    ${permanentPinCode}    ${panNumber}    ${bool[1]}   customer=${pcid18} 
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=    Get KYC    ${leUid3}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable   ${idkyc}        ${resp.json()[0]['id']}
    Should Be Equal As Strings      ${resp.json()[0]['originFrom']}  ${originFrom}
    Should Be Equal As Strings      ${resp.json()[0]['originUid']}  ${leUid3}
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
   
    ${resp}=  Update KYC    ${idkyc}    ${originFrom}    ${leUid3}        ${customerName}    ${dob}        ${relationType[0]}    ${relationName1}    ${telephoneType}    ${phoneNo}   ${validationId}      ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress1}    ${permanentCity1}    ${states[0]}    ${permanentPinCode}    ${panNumber1}    ${bool[1]}    customer=${pcid18}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

  
    ${resp}=    Get KYC    ${leUid3}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Should Be Equal As Strings      ${resp.json()[0]['originFrom']}  ${originFrom}
    Should Be Equal As Strings      ${resp.json()[0]['originUid']}  ${leUid3}
    Should Be Equal As Strings      ${resp.json()[0]['customerName']}  ${customerName}
    #Should Be Equal As Strings      ${resp.json()[0]['panNumber']}  ${panNumber1}
    Should Be Equal As Strings      ${resp.json()[0]['customer']}  ${pcid18}
    # Should Be Equal As Strings      ${resp.json()[0]['relationName']}  ${relationName1}
    Should Be Equal As Strings      ${resp.json()[0]['permanentAddress']}  ${permanentAddress1}
    Should Be Equal As Strings      ${resp.json()[0]['permanentCity']}  ${permanentCity1}

    # ${resp}=  Change KYC Status    ${originFrom}    ${leUid3}    ${pcid18}    ${customerName}    ${dob}        ${relationType}    ${relationName1}    ${telephoneType}    ${phoneNo}       ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress1}    ${permanentCity1}    ${permanentState1}    ${permanentPinCode}    ${panNumber1}    ${bool[1]}    
    ${resp}=  Change KYC Status        ${leUid3}       
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=   Get Lead By Id   ${leUid3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['kycCreated']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id6}
    
    ${resp}=   Process CRIF Inquiry with kyc   ${leUid3}    ${idkyc}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Status change crif   ${leUid3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
 
    
    ${resp}=   Get CRIF Inquiry with kyc    ${leUid3}   ${idkyc}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get States
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=   Get Lead By Id   ${leUid3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['kycCreated']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id7}
    
    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

   
    ${resp}=  Get Questionnaire By uuid For Lead    ${leUid3}
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

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME_U2}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Imageupload.PLeadQAnsUpload   ${cookie}  ${leUid3}   ${data}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
     
    ${resp}=   Get Lead By Id  ${leUid3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id7}
 
  
    Check Answers   ${resp}  ${data}


    ${resp}=    Change Status Lead   ${status_id7}    ${leUid3} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
   
    ${resp}=  Get Lead By Id   ${leUid3}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['kycCreated']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id8}
   

JD-TC-ChangeLeadStatusbyuser-9

    [Documentation]  lead created by branch then change status by user

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

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
    ${category}=    Create Dictionary   id=${lead_cat_id}

    ${resp}=    Create Lead    ${title3}    ${desc}    ${targetPotential}      ${locId}    ${pcid18}   category=${category}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${leid1}        ${resp.json()['id']}
    Set Suite Variable   ${leUid4}        ${resp.json()['uid']}

    ${resp}=    Get Lead By Id    ${leUid4}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable   ${phoneNo}        ${resp.json()['customer']['phoneNo']}
    Should Be Equal As Strings      ${resp.json()['status']['id']}  ${status_id0}


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
    
    ${resp}=  Create KYC    ${originFrom}    ${leUid4}        ${customerName}    ${dob}        ${relationType[0]}    ${relationName}    ${telephoneType}    ${phoneNo}     ${validationId}      ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress}    ${permanentCity}   ${states[0]}    ${permanentPinCode}    ${panNumber}    ${bool[1]}   customer=${pcid18} 
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=    Get KYC    ${leUid4}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable   ${idkyc}        ${resp.json()[0]['id']}
    Should Be Equal As Strings      ${resp.json()[0]['originFrom']}  ${originFrom}
    Should Be Equal As Strings      ${resp.json()[0]['originUid']}  ${leUid4}
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
   
    ${resp}=  Update KYC    ${idkyc}    ${originFrom}    ${leUid4}        ${customerName}    ${dob}        ${relationType[0]}    ${relationName1}    ${telephoneType}    ${phoneNo}   ${validationId}      ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress1}    ${permanentCity1}    ${states[0]}    ${permanentPinCode}    ${panNumber1}    ${bool[1]}    customer=${pcid18}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

  
    ${resp}=    Get KYC    ${leUid4}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Should Be Equal As Strings      ${resp.json()[0]['originFrom']}  ${originFrom}
    Should Be Equal As Strings      ${resp.json()[0]['originUid']}  ${leUid4}
    Should Be Equal As Strings      ${resp.json()[0]['customerName']}  ${customerName}
    #Should Be Equal As Strings      ${resp.json()[0]['panNumber']}  ${panNumber1}
    Should Be Equal As Strings      ${resp.json()[0]['customer']}  ${pcid18}
    # Should Be Equal As Strings      ${resp.json()[0]['relationName']}  ${relationName1}
    Should Be Equal As Strings      ${resp.json()[0]['permanentAddress']}  ${permanentAddress1}
    Should Be Equal As Strings      ${resp.json()[0]['permanentCity']}  ${permanentCity1}

    # ${resp}=  Change KYC Status    ${originFrom}    ${leUid4}    ${pcid18}    ${customerName}    ${dob}        ${relationType}    ${relationName1}    ${telephoneType}    ${phoneNo}       ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress1}    ${permanentCity1}    ${permanentState1}    ${permanentPinCode}    ${panNumber1}    ${bool[1]}    
    ${resp}=  Change KYC Status        ${leUid4}       
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=   Get Lead By Id   ${leUid4}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['kycCreated']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id6}
    
    ${resp}=   Process CRIF Inquiry with kyc   ${leUid4}    ${idkyc}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Status change crif   ${leUid4}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
 
    
    ${resp}=   Get CRIF Inquiry with kyc    ${leUid4}   ${idkyc}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get States
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=   Get Lead By Id   ${leUid4}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['kycCreated']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id7}
    
    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

   
    ${resp}=   Encrypted Provider Login  ${PUSERNAME_U2}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${provider_id}  ${resp.json()['id']}
  
   
    ${resp}=  Get Questionnaire By uuid For Lead    ${leUid4}
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

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME_U2}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Imageupload.PLeadQAnsUpload   ${cookie}  ${leUid4}   ${data}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
     
    ${resp}=   Get Lead By Id  ${leUid4}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id7}
 
  
    Check Answers   ${resp}  ${data}


    ${resp}=    Change Status Lead   ${status_id7}    ${leUid4} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
   
    ${resp}=  Get Lead By Id   ${leUid4}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['kycCreated']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id8}
   
JD-TC-ChangeLeadStatusbyuser-10

    [Documentation]  lead created by one  user then change status by another user same branch

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

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
    
      FOR  ${p}  IN RANGE  5
        ${ran int}=    Generate Random String    length=4    chars=[NUMBERS]
        ${ran int}=    Convert To Integer    ${ran int}
        ${ran int}=    Convert To Integer    ${ran int}
        ${ran int}=    Convert To String  ${ran int}
        ${Status}=   Run Keyword And Return Status   Should Match Regexp	${ran int}	\\d{4}
        Exit For Loop IF  ${Status}  
    END
    ${ran int}=    Convert To Integer    ${ran int}
    ${PUSERPH1}=  Evaluate  ${PUSERNAME}+${ran int}
    clear_users  ${PUSERPH1}
    Set Suite Variable  ${PUSERPH1}
    ${firstname1}=  FakerLibrary.name
    ${lastname1}=  FakerLibrary.last_name
    ${address}=  get_address
    ${dob}=  FakerLibrary.Date
    Set Suite Variable  ${dob}
    ${location}=  FakerLibrary.city
    Set Suite Variable  ${location}
    ${state}=  FakerLibrary.state
    Set Suite Variable   ${state}
    FOR    ${i}    IN RANGE    3
        ${pin}=  get_pincode
        ${kwstatus}  ${resp} =  Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
    END
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${city}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Suite Variable  ${state}  ${resp.json()[0]['PostOffice'][0]['State']}      
    Set Suite Variable  ${pin}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    

    


    ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERPH1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERPH1}  ${dep_id}  ${EMPTY}  ${bool[1]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id}  ${resp.json()}

    ${resp}=  Get User By Id  ${u_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['subdomain']}
    # Verify Response  ${resp}  id=${u_id}  firstName=${firstname}  lastName=${lastname}   mobileNo=${PUSERPH1}  dob=${dob}  gender=${Genderlist[0]}  userType=${userType[0]}  status=ACTIVE  email=${P_Email}${PUSERPH1}.${test_mail}  city=${city}  state=${state}  deptId=${dep_id} 

   
    ${resp}=  SendProviderResetMail   ${PUSERPH1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${PUSERPH1}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERPH1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   


    ${resp}=   Encrypted Provider Login  ${PUSERPH1}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${provider_id1}  ${resp.json()['id']}

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
  
    # ${resp}=  Provider Logout
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

   
    # ${resp}=   Encrypted Provider Login  ${PUSERPH1}  ${PASSWORD} 
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}   200
    # Set Suite Variable  ${provider_id}  ${resp.json()['id']}
  
    ${resp}=    Change Status Lead   ${status_id8}    ${leUid3} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
   
    ${resp}=  Get Lead By Id   ${leUid3}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['kycCreated']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id10}
   
JD-TC-ChangeLeadStatusbyuser-UH1

    [Documentation]  lead created by one  user then change status by another provider

    ${resp}=   Encrypted Provider Login  ${PUSERNAME63}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${provider_id}  ${resp.json()['id']}
  
    ${resp}=    Change Status Lead   ${status_id10}    ${leUid3} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    
JD-TC-ChangeLeadStatusbyuser-UH2  

    [Documentation]    consummer login

    ${resp}=  Consumer Login  ${CUSERNAME17}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Change Status Lead   ${status_id8}    ${leUid3} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   ${resp.json()}    ${LOGIN_NO_ACCESS_FOR_URL}

JD-TC-ChangeLeadStatusbyuser-UH3

    [Documentation]  without login

    ${resp}=    Change Status Lead   ${status_id8}    ${leUid3} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.json()}   ${SESSION_EXPIRED}
 