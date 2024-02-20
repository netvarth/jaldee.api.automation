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
Variables         /ebs/TDD/varfiles/musers.py
Variables         /ebs/TDD/varfiles/hl_musers.py
Library           /ebs/TDD/excelfuncs.py


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


${task_temp_name1}   Follow Up 1
${task_temp_name2}   Follow Up 2
${en_temp_name}   EnquiryName


*** Test Cases ***

JD-TC-Create_CrifScore-1
    [Documentation]  Create a  crif score

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


    # # ...............


#     ${resp}=   Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD} 
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200
#     Set Test Variable  ${provider_id}  ${resp.json()['id']}

#     ${resp}=  Get Business Profile
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${account_id}  ${resp.json()['id']}

#     ${resp}=    Get Locations
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     IF   '${resp.content}' == '${emptylist}'
#         ${locId}=  Create Sample Location
#     ELSE
#         Set Test Variable  ${locId}  ${resp.json()[0]['id']}
#     END

#     enquiryStatus  ${account_id}
#     #  updateEnquiryStatus  ${account_id}
#     ${resp}=   CrifScore  ${account_id}
#     ${resp}=  categorytype   ${account_id}
#     ${resp}=  tasktype       ${account_id}
#     ${resp}=    Get Lead Category Type
#     Log   ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${cat_len}=  Get Length  ${resp.json()}
#     FOR  ${i}  IN RANGE   ${cat_len}
#         IF  '${resp.json()[${i}]['name']}'=='${unique_lnames[0]}'
#             Set Suite Variable  ${category_id1}    ${resp.json()[${i}]['id']}
#             Set Suite Variable  ${category_name1}  ${resp.json()[${i}]['name']}
#         END
#     END

#      ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME20}  
#     Log  ${resp.content}
#     Should Be Equal As Strings      ${resp.status_code}  200
#     IF   '${resp.content}' == '${emptylist}'
#         ${resp1}=  AddCustomer  ${CUSERNAME20}
#         Log  ${resp1.content}
#         Should Be Equal As Strings  ${resp1.status_code}  200
#         Set Suite Variable  ${pcid18}   ${resp1.json()}
#     ELSE
#         Set Suite Variable  ${pcid18}  ${resp.json()[0]['id']}
#     END

#     ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME20}  
#     Log  ${resp.content}
#     Should Be Equal As Strings      ${resp.status_code}  200
#     Set Test Variable    ${phoneNo}   ${resp.json()[0]['phoneNo']}

#     ${resp}=    updateLeadStatus  ${account_id}
   

#     ${resp}=  Get Lead Status
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${len}  Get Length  ${resp.json()}
#     FOR   ${i}  IN RANGE   ${len}
#         Set Suite Variable  ${status_Lid${i}}    ${resp.json()[${i}]['id']}
#         Set Suite Variable  ${status_Lname${i}}  ${resp.json()[${i}]['name']}
#     END

#     Log   ${status_Lid1}
#     Log   ${status_Lname1}



#     # ..........................


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
    ${PUSERNAME_Z}=  Evaluate  ${PUSERNAME}+76448          
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERNAME_Z}${\n}
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

*** Comments ***  

     Set Test Variable  ${provider_id}  ${resp.json()['id']}
 
    ${provider_id}=  get_acc_id  ${PUSERNAME_Z}
    Set Suite Variable  ${provider_id}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}
   
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
    enquiryStatus  ${account_id}
#    leadStatus  ${account_id}
    # updateEnquiryStatus  ${account_id}
    ${resp}=   CrifScore  ${account_id}
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

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME20}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME20}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${pcid18}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${pcid18}  ${resp.json()[0]['id']}
    END

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME20}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable    ${phoneNo}   ${resp.json()[0]['phoneNo']}
    
    ${resp}=   leadStatus  ${account_id}

    ${resp}=    updateLeadStatus  ${account_id}

  
    ${resp}=  Get Lead Status
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}  Get Length  ${resp.json()}
    FOR   ${i}  IN RANGE   ${len}
        Set Suite Variable  ${status_Lid${i}}    ${resp.json()[${i}]['id']}
        Set Suite Variable  ${status_Lname${i}}  ${resp.json()[${i}]['name']}
    END

    Log   ${status_Lid1}
    Log   ${status_Lname1}


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
    Should Be Equal As Strings      ${resp.json()[0]['originFrom']}  ${originFrom}
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
 
    ${resp}=  Update KYC    ${idkyc}    ${le_id}     ${customerName}    ${dob}        ${relationType[0]}    ${relationName1}    ${telephoneType}    ${phoneNo}   ${validationId}      ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress1}    ${permanentCity1}    ${states[0]}    ${permanentPinCode}    ${panNumber1}    ${bool[1]}    customer=${pcid18}
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

    # ${resp}=  Change KYC Status        ${le_id}       ${status_id7}
    # Log   ${resp.json()}
    # Should Be Equal As Strings      ${resp.status_code}  200

    # ${resp}=    Get KYC    ${le_id}
    # Log   ${resp.content}
    # Should Be Equal As Strings      ${resp.status_code}  200

    # ${resp}=   Get Lead By Id   ${le_id}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['kycCreated']}  ${bool[1]}
    # Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id7}

    # ${resp}=   Process CRIF Inquiry with kyc   ${le_id}    ${idkyc}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['accountId']}   ${account_id}
    # Should Be Equal As Strings  ${resp.json()['originUid']}   ${le_id}
    # Should Be Equal As Strings  ${resp.json()['leadKycId']}   ${idkyc}
  
    # ${resp}=  Status change crif   ${le_id}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
 
    
    # ${resp}=   Get CRIF Inquiry with kyc    ${le_id}   ${idkyc}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['accountId']}   ${account_id}
    # Should Be Equal As Strings  ${resp.json()['originUid']}   ${le_id}
    # Should Be Equal As Strings  ${resp.json()['leadKycId']}   ${idkyc}
   
   
    ${resp}=   Get Lead By Id   ${le_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['kycCreated']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_Lid1}

JD-TC-Create_CrifScore-2
    [Documentation]   again  generate  crif score  with same  lead id
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${provider_id}  ${resp.json()['id']}

    clear_customer   ${PUSERNAME_Z} 

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME18}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME18}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${pcid18}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${pcid18}  ${resp.json()[0]['id']}
    END

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME18}  
    # Log  ${resp.content}
    # Should Be Equal As Strings      ${resp.status_code}  200

  
    ${resp}=    Get Lead By Id    ${le_id}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable   ${phoneNo}        ${resp.json()['customer']['phoneNo']}
    Should Be Equal As Strings      ${resp.json()['status']['id']}  ${status_Lid1}
   
    # ${dob}=    FakerLibrary.Date
    # ${relationName}=    FakerLibrary.First Name
    # ${idValue}=    FakerLibrary.Word
    # ${fileName}=    FakerLibrary.File Name
    # ${fileSize}=    FakerLibrary.Binary
    # ${caption}=    FakerLibrary.Text
    # ${resp}=  db.getType   ${jpegfile}
    # Log  ${resp}
    # ${fileType}=  Get From Dictionary       ${resp}    ${jpegfile}
    # Set Suite Variable    ${fileType}
    # ${permanentAddress}=    FakerLibrary.Word
    # ${permanentCity}=    FakerLibrary.City
    # ${permanentState123}=    FakerLibrary.State
    # ${panNumber}=  FakerLibrary.Credit Card Number
    # ${caption3}=  Fakerlibrary.Sentence
    # ${resp}=  db.getType   ${jpgfile}
    # Log  ${resp}
    # ${fileType5}=  Get From Dictionary       ${resp}    ${jpgfile}
    # Set Suite Variable    ${fileType5}
    # ${list13}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption3}     fileType=${fileType5}   order=${order}
    # ${list}=   Create List         ${list13}
    # ${valida1}=    Create Dictionary    idTypes=${idTypes}     idValue=${idValue}    attachments=${list}
   
    # ${caption5}=  Fakerlibrary.Sentence
    # ${list1}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption5}     fileType=${fileType5}   order=${order}  
    # ${list}=   Create List       ${list1}
    # ${valida2}=    Create Dictionary    idTypes=UID     idValue=${idValue}    attachments=${list}
    # ${validationId}=    Create List    ${valida1}    ${valida2}
    # Set Suite Variable    ${validationId} 
    
    # ${resp}=  Create KYC    ${originFrom}    ${leUid1}        ${customerName}    ${dob}        ${relationType[0]}    ${relationName}    ${telephoneType}    ${phoneNo}     ${validationId}      ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress}    ${permanentCity}   Andhra Pradesh    ${permanentPinCode}    ${panNumber}    ${bool[1]}   customer=${pcid18} 
    # Log   ${resp.json()}
    # Should Be Equal As Strings      ${resp.status_code}  200

    # ${resp}=    Get KYC    ${leUid1}
    # Log   ${resp.content}
    # Should Be Equal As Strings      ${resp.status_code}  200
    # Set Suite Variable   ${idkyc12}        ${resp.json()[0]['id']}
    # Should Be Equal As Strings      ${resp.json()[0]['originFrom']}  ${originFrom}
    # Should Be Equal As Strings      ${resp.json()[0]['originUid']}  ${leUid1}
    # Should Be Equal As Strings      ${resp.json()[0]['customerName']}  ${customerName}
    
    # Should Be Equal As Strings      ${resp.json()[0]['customer']}  ${pcid18}
    # Should Be Equal As Strings      ${resp.json()[0]['relationName']}  ${relationName}
    # Should Be Equal As Strings      ${resp.json()[0]['permanentAddress']}  ${permanentAddress}
    # Should Be Equal As Strings      ${resp.json()[0]['permanentCity']}  ${permanentCity}
   
    # ${resp}=   Get Lead By Id   ${leUid1}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['kycCreated']}  ${bool[1]}
    # Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id7}
    
   
    # ${dob}=    FakerLibrary.Date
    # ${relationName1}=    FakerLibrary.Last Name
    # ${idValue}=    FakerLibrary.Name
    # ${fileName}=    FakerLibrary.File Name
    # ${fileSize}=    FakerLibrary.Binary
    # ${caption}=    FakerLibrary.Text
    # ${resp}=  db.getType   ${jpegfile}
    # Log  ${resp}
    # ${fileType}=  Get From Dictionary       ${resp}    ${jpegfile}
    # Set Suite Variable    ${fileType}
    # ${permanentAddress1}=    FakerLibrary.Address
    # ${permanentCity1}=    FakerLibrary.City
    # ${permanentState1}=    FakerLibrary.State
    # ${panNumber1}=  FakerLibrary.Credit Card Number
 
    # ${resp}=  Update KYC    ${idkyc12}    ${originFrom}    ${leUid1}        ${customerName}    ${dob}        ${relationType[0]}    ${relationName1}    ${telephoneType}    ${phoneNo}   ${validationId}      ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress1}    ${permanentCity1}    Andhra Pradesh    ${permanentPinCode}    ${panNumber1}    ${bool[1]}    customer=${pcid18}
    # Log   ${resp.json()}
    # Should Be Equal As Strings      ${resp.status_code}  200
   
    # ${resp}=   Get Lead By Id   ${leUid1}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['kycCreated']}  ${bool[1]}
    # Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id7}
   
    # ${resp}=    Get KYC    ${leUid1}
    # Log   ${resp.content}
    # Should Be Equal As Strings      ${resp.status_code}  200
    # Should Be Equal As Strings      ${resp.json()[0]['originFrom']}  ${originFrom}
    # Should Be Equal As Strings      ${resp.json()[0]['originUid']}  ${leUid1}
    # Should Be Equal As Strings      ${resp.json()[0]['customerName']}  ${customerName}
    # Should Be Equal As Strings      ${resp.json()[0]['customer']}  ${pcid18}
    # Should Be Equal As Strings      ${resp.json()[0]['permanentAddress']}  ${permanentAddress1}
    # Should Be Equal As Strings      ${resp.json()[0]['permanentCity']}  ${permanentCity1}

    # ${resp}=  Change KYC Status        ${leUid1}       
    # Log   ${resp.json()}
    # Should Be Equal As Strings      ${resp.status_code}  200

    # ${resp}=   Get Lead By Id   ${leUid1}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['kycCreated']}  ${bool[1]}
    # Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id7}
    
    # ${resp}=   Process CRIF Inquiry with kyc   ${le_id}    ${idkyc}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['accountId']}   ${account_id}
    # Should Be Equal As Strings  ${resp.json()['originUid']}   ${le_id}
    # Should Be Equal As Strings  ${resp.json()['leadKycId']}   ${idkyc}
    
   
    
    # ${resp}=   Get CRIF Inquiry with kyc    ${le_id}   ${idkyc}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['accountId']}   ${account_id}
    # Should Be Equal As Strings  ${resp.json()['originUid']}   ${le_id}
    # Should Be Equal As Strings  ${resp.json()['leadKycId']}   ${idkyc}
   
   
    ${resp}=   Get Lead By Id   ${le_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['kycCreated']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id1}
JD-TC-Create_CrifScore-3
    [Documentation]   more than crif  generated    with same  lead id  and kycid
   
    ${resp}=   Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${provider_id}  ${resp.json()['id']}

    ${resp}=   Process CRIF Inquiry with kyc   ${leUid1}    ${idkyc12}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['accountId']}   ${account_id}
    Should Be Equal As Strings  ${resp.json()['originUid']}   ${leUid1}
    Should Be Equal As Strings  ${resp.json()['leadKycId']}   ${idkyc12}
    
  
    
    ${resp}=   Get CRIF Inquiry with kyc    ${leUid1}   ${idkyc12}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['accountId']}   ${account_id}
    Should Be Equal As Strings  ${resp.json()['originUid']}   ${leUid1}
    Should Be Equal As Strings  ${resp.json()['leadKycId']}   ${idkyc12}
   
   
    ${resp}=   Get Lead By Id   ${leUid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['kycCreated']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id7}
    
    ${resp}=   Process CRIF Inquiry with kyc   ${leUid1}    ${idkyc12}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['accountId']}   ${account_id}
    Should Be Equal As Strings  ${resp.json()['originUid']}   ${leUid1}
    Should Be Equal As Strings  ${resp.json()['leadKycId']}   ${idkyc12}
    
  
    
    ${resp}=   Get CRIF Inquiry with kyc    ${leUid1}   ${idkyc12}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['accountId']}   ${account_id}
    Should Be Equal As Strings  ${resp.json()['originUid']}   ${leUid1}
    Should Be Equal As Strings  ${resp.json()['leadKycId']}   ${idkyc12}
   
   
    ${resp}=   Get Lead By Id   ${leUid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['kycCreated']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id7}
    
  

JD-TC-Create_CrifScore-UH1
    [Documentation]  create crif without kyc status changing


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

    ${resp}=   Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${provider_id}  ${resp.json()['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}
   
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

    ${resp}=   CrifScore  ${account_id}
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

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME11}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME11}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${pcid18}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${pcid18}  ${resp.json()[0]['id']}
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
    Set Suite Variable   ${leUid123}        ${resp.json()['uid']}
   
    ${resp}=    Get Lead By Id    ${leUid123}
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
    
    ${resp}=  Create KYC    ${originFrom}    ${leUid123}        ${customerName}    ${dob}        ${relationType[0]}    ${relationName}    ${telephoneType}    ${phoneNo}     ${validationId}      ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress}    ${permanentCity}   ${states[0]}    ${permanentPinCode}    ${panNumber}    ${bool[1]}   customer=${pcid18} 
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=    Get KYC    ${leUid123}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable   ${idkyc123}        ${resp.json()[0]['id']}
    Should Be Equal As Strings      ${resp.json()[0]['originFrom']}  ${originFrom}
    Should Be Equal As Strings      ${resp.json()[0]['originUid']}  ${leUid123}
    Should Be Equal As Strings      ${resp.json()[0]['customerName']}  ${customerName}
    Should Be Equal As Strings      ${resp.json()[0]['customer']}  ${pcid18}
    Should Be Equal As Strings      ${resp.json()[0]['relationName']}  ${relationName}
    Should Be Equal As Strings      ${resp.json()[0]['permanentAddress']}  ${permanentAddress}
    Should Be Equal As Strings      ${resp.json()[0]['permanentCity']}  ${permanentCity}
   
    ${resp}=   Get Lead By Id   ${leUid123}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['kycCreated']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id}
    
   
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
 
    ${resp}=  Update KYC    ${idkyc123}    ${originFrom}    ${leUid123}        ${customerName}    ${dob}        ${relationType[0]}    ${relationName1}    ${telephoneType}    ${phoneNo}   ${validationId}      ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress1}    ${permanentCity1}    ${states[0]}    ${permanentPinCode}    ${panNumber1}    ${bool[1]}    customer=${pcid18}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
   
    ${resp}=   Get Lead By Id   ${leUid123}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['kycCreated']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id}
   
    ${resp}=    Get KYC    ${leUid123}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Should Be Equal As Strings      ${resp.json()[0]['originFrom']}  ${originFrom}
    Should Be Equal As Strings      ${resp.json()[0]['originUid']}  ${leUid123}
    Should Be Equal As Strings      ${resp.json()[0]['customerName']}  ${customerName}
    Should Be Equal As Strings      ${resp.json()[0]['customer']}  ${pcid18}
    Should Be Equal As Strings      ${resp.json()[0]['permanentAddress']}  ${permanentAddress1}
    Should Be Equal As Strings      ${resp.json()[0]['permanentCity']}  ${permanentCity1}

    ${INVALID_LEAD_SATUS_UNABLE_TO_GENERATE_CRIF}=   Format String   ${INVALID_LEAD_SATUS_UNABLE_TO_GENERATE_CRIF}  Lead  New
    Log   ${INVALID_LEAD_SATUS_UNABLE_TO_GENERATE_CRIF}
    ${resp}=   Process CRIF Inquiry with kyc   ${leUid123}    ${idkyc123}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${INVALID_LEAD_SATUS_UNABLE_TO_GENERATE_CRIF}

    

JD-TC-Create_CrifScore-UH2
    [Documentation]  crif generated invalid lead id
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${provider_id}  ${resp.json()['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}
    ${INVALID_LEAD_UID}=   Replace String  ${INVALID_LEAD_UID}  {}    Lead

    ${resp}=   Process CRIF Inquiry with kyc    123    ${idkyc123}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${INVALID_LEAD_UID}
   
   

JD-TC-Create_CrifScore-UH3
    [Documentation]   create crife score without login

    ${resp}=   Process CRIF Inquiry with kyc    ${leUid123}    ${idkyc123}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-Create_CrifScore-UH4
    [Documentation]  create crif another kyc id

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

    ${resp}=   Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${provider_id}  ${resp.json()['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}
   
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

    ${resp}=   CrifScore  ${account_id}
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

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME19}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME19}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${pcid19}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${pcid19}  ${resp.json()[0]['id']}
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
    Set Suite Variable  ${status_id9}    ${resp.json()[9]['id']}
    Set Suite Variable  ${status_id10}    ${resp.json()[10]['id']}
    Set Suite Variable  ${statusName_id6}    ${resp.json()[5]['name']}
   
    ${title3}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 
    ${targetPotential}=    FakerLibrary.Building Number
    Set Suite Variable  ${targetPotential}
    ${category}=    Create Dictionary   id=${category_id1}

    ${resp}=    Create Lead    ${title3}    ${desc}    ${targetPotential}      ${locId}    ${pcid19}   category=${category}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${leid1}        ${resp.json()['id']}
    Set Suite Variable   ${leUid1}        ${resp.json()['uid']}
   
    ${resp}=    Get Lead By Id    ${leUid1}
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
    
    ${resp}=  Create KYC    ${originFrom}    ${leUid1}        ${customerName}    ${dob}        ${relationType[0]}    ${relationName}    ${telephoneType}    ${phoneNo}     ${validationId}      ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress}    ${permanentCity}   ${states[3]}    ${permanentPinCode}       ${panNumber}    ${bool[1]}   customer=${pcid19} 
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=    Get KYC    ${leUid1}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable   ${idkyc}        ${resp.json()[0]['id']}
    Should Be Equal As Strings      ${resp.json()[0]['originFrom']}  ${originFrom}
    Should Be Equal As Strings      ${resp.json()[0]['originUid']}  ${leUid1}
    Should Be Equal As Strings      ${resp.json()[0]['customerName']}  ${customerName}
    Should Be Equal As Strings      ${resp.json()[0]['customer']}  ${pcid19}
    Should Be Equal As Strings      ${resp.json()[0]['relationName']}  ${relationName}
    Should Be Equal As Strings      ${resp.json()[0]['permanentAddress']}  ${permanentAddress}
    Should Be Equal As Strings      ${resp.json()[0]['permanentCity']}  ${permanentCity}
   
    ${resp}=   Get Lead By Id   ${leUid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['kycCreated']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id}
    
   
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
 
    ${resp}=  Update KYC    ${idkyc}    ${originFrom}    ${leUid1}        ${customerName}    ${dob}        ${relationType[0]}    ${relationName1}    ${telephoneType}    ${phoneNo}   ${validationId}      ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress1}    ${permanentCity1}   ${states[0]}    ${permanentPinCode}    ${panNumber1}    ${bool[1]}    customer=${pcid19}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
   
    ${resp}=   Get Lead By Id   ${leUid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['kycCreated']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id}
   
    ${resp}=    Get KYC    ${leUid1}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Should Be Equal As Strings      ${resp.json()[0]['originFrom']}  ${originFrom}
    Should Be Equal As Strings      ${resp.json()[0]['originUid']}  ${leUid1}
    Should Be Equal As Strings      ${resp.json()[0]['customerName']}  ${customerName}
      Should Be Equal As Strings      ${resp.json()[0]['customer']}  ${pcid19}
    Should Be Equal As Strings      ${resp.json()[0]['permanentAddress']}  ${permanentAddress1}
    Should Be Equal As Strings      ${resp.json()[0]['permanentCity']}  ${permanentCity1}

    ${resp}=  Change KYC Status        ${leUid1}       
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=   Get Lead By Id   ${leUid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['kycCreated']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id6}
    
    ${resp}=   Process CRIF Inquiry with kyc   ${leUid1}    ${idkyc123}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${INVALID_LEAD_OR_KYC_ID}

   
    
JD-TC-Create_CrifScore-UH5

    [Documentation]   another provider login

    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${provider_id}  ${resp.json()['id']}
    ${INVALID_X_ID}=   Replace String  ${INVALID_X_ID}  {}   KYC

    ${resp}=   Process CRIF Inquiry with kyc    ${leUid1}    ${idkyc}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${INVALID_X_ID}




JD-TC-Create_CrifScore-UH6
    [Documentation]    create crife score with consumer login.

    ${resp}=   ConsumerLogin  ${CUSERNAME8}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${cons_id8}  ${resp.json()['id']}


    ${resp}=   Process CRIF Inquiry with kyc    ${leUid123}    ${idkyc123}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   ${resp.json()}    ${LOGIN_NO_ACCESS_FOR_URL}

JD-TC-Create_CrifScore-UH7
    [Documentation]    create crife score invalid kyc id
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${provider_id}  ${resp.json()['id']}
    ${INVALID_X_ID}=   Replace String  ${INVALID_X_ID}  {}   KYC

    ${resp}=   Process CRIF Inquiry with kyc   ${leUid1}   25
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${INVALID_X_ID}

JD-TC-Create_CrifScore-UH8
    [Documentation]    create crife score empty kyc id
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${provider_id}  ${resp.json()['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}

    ${resp}=   Process CRIF Inquiry with kyc   ${leUid123}   ${EMPTY}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${KYC_ID_REQUIRED}

JD-TC-Create_CrifScore-UH9
    [Documentation]    create crife score empty lead id
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${provider_id}  ${resp.json()['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}

    ${resp}=   Process CRIF Inquiry with kyc      ${EMPTY}   ${idkyc123}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${ORIGIN_UID_REQUIRED}

JD-TC-Create_CrifScore-UH10
    [Documentation]    create crife score without passing kyc id
   
    ${resp}=   Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${provider_id}  ${resp.json()['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}

    ${resp}=   Process CRIF Inquiry      ${leUid123}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${KYC_ID_REQUIRED}
