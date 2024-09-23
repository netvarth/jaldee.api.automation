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
Resource          /ebs/TDD/Keywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/hl_providers.py
Library           /ebs/TDD/excelfuncs.py

*** Keywords ***

Multiple Users Accounts

    ${resp}=   Get File    /ebs/TDD/varfiles/providers.py
    ${len}=   Split to lines  ${resp}
    ${length}=  Get Length   ${len}
    ${multiuser_list}=  Create List
    &{License_total}=  Create Dictionary
    
    FOR   ${a}  IN RANGE   ${length}   
        ${resp}=  Encrypted Provider Login  ${PUSERNAME${a}}  ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}    200
        
        ${resp1}=   Get Active License
        Log  ${resp1.content}
        Should Be Equal As Strings    ${resp1.status_code}   200
        ${name}=  Set Variable  ${resp1.json()['accountLicense']['displayName']}

        ${resp}=   Get License UsageInfo 
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        IF  ${resp.json()['metricUsageInfo'][8]['total']} > 1 and ${resp.json()['metricUsageInfo'][8]['used']} < ${resp.json()['metricUsageInfo'][8]['total']}
            Append To List  ${multiuser_list}  ${PUSERNAME${a}}
            Set To Dictionary 	${License_total} 	${name}=${resp.json()['metricUsageInfo'][8]['total']}
        END
    END

    RETURN  ${multiuser_list}

*** Variables ***
${self}     0

${jpgfile}      /ebs/TDD/uploadimage.jpg
${pngfile}      /ebs/TDD/upload.png
${pdffile}      /ebs/TDD/sample.pdf
${giffile}     /ebs/TDD/sample.gif
${jpegfile}     /ebs/TDD/large.jpeg
${shfile}     /ebs/TDD/example.sh
${docfile}     /ebs/TDD/docsample.doc
${txtfile}     /ebs/TDD/textsample.txt

@{emptylist}
${order}    0
${permanentPinCode}    679581
${customerName}    Hisham
${xlFile}      ${EXECDIR}/TDD/LeadQnr.xlsx  

${permanentPinCode}    679581
${task_temp_name1}   Follow Up 1
${task_temp_name2}   Follow Up 2
${en_temp_name}   EnquiryName

*** Test Cases ***

JD-TC-UpdateKyc-1
    [Documentation]  Create a  Kyc and Update.

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

    ${resp}=   Encrypted Provider Login  ${HLPUSERNAME5}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_customer   ${HLPUSERNAME5}

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
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['timezone']}
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END

    ${resp}=  Get Departments
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        {dep_name1}=  FakerLibrary.bs
        ${dep_code1}=   Random Int  min=100   max=999
        ${dep_desc1}=   FakerLibrary.word  
        ${resp1}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${dep_id}  ${resp1.json()}
    ELSE
        Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    END

    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF   not '${resp.content}' == '${emptylist}'
        ${len}=  Get Length  ${resp.json()}
        FOR   ${i}  IN RANGE   0   ${len}
            Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
            IF   not '${user_phone}' == '${HLPUSERNAME5}'
                clear_users  ${user_phone}
            END
        END
    END

    ${u_id}=  Create Sample User
    Set Suite Variable  ${u_id}

    ${resp}=  Get User By Id  ${u_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${BUSER_U1}  ${resp.json()['mobileNo']}

    ${resp}=  SendProviderResetMail   ${BUSER_U1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${BUSER_U1}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=   Encrypted Provider Login  ${BUSER_U1}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${provider_id}  ${decrypted_data['id']}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Suite Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME15}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME15}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${pcid15}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${pcid15}  ${resp.json()[0]['id']}
    END

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME15}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable    ${phoneNo}   ${resp.json()[0]['phoneNo']}

    
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

  

    updateEnquiryStatus  ${account_id}
    sleep  01s

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

    # enquiryTemplate(account_id,category_id=0,priority_id=5,type_id=0)
    ${resp}=  enquiryTemplate  ${account_id}  ${en_temp_name}  ${enq_sts_new_id}  creator_provider_id=${provider_id} 

    ${resp}=  Get Enquiry Template
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Provider Enquiry Category  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_catagories}=  Set Variable  ${resp.json()}
    ${random_catagories}=  Evaluate  random.choice($en_catagories)  random
    ${rand_catagory_id}=  Set Variable  ${random_catagories['id']}
    ${rand_catagory_name}=  Set Variable  ${random_catagories['name']}

    ${category}=  Create Dictionary   id=${rand_catagory_id}         

    ${resp}=  Create Enquiry  ${locId}  ${pcid15}  category=${category}
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

    ${resp}=  Get Enquiry by Uuid  ${en_uid}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${status_id0}    ${resp.json()['status']['id']}

    ${resp}=  Update and Proceed Enquiry to Status  ${en_uid}  ${status_id0}  ${locId}  ${pcid15}  &{resp.json()}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Get Enquiry by Uuid  ${en_uid}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id1}
    Should Be Equal As Strings    ${resp.json()['status']['name']}  ${status_name1}
  
    ${resp}=  Update and Proceed Enquiry to Status  ${en_uid}  ${status_id1}  ${locId}  ${pcid15}  &{resp.json()}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
  
    ${resp}=  Get Enquiry by Uuid  ${en_uid}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id2}
    Should Be Equal As Strings    ${resp.json()['status']['name']}  ${status_name2}
  
   
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
    ${permanentAddress}=    FakerLibrary.Address
    ${permanentCity}=    FakerLibrary.City
    ${permanentState}=    FakerLibrary.State
    ${panNumber}=  FakerLibrary.Credit Card Number
    ${attachments}=     Create List

    ${resp}=  Create KYC      ${en_uid}        ${customerName}    ${dob}        ${relationType[1]}    ${relationName}    ${telephoneType[2]}    ${phoneNo}  ${attachments}      ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress}    ${permanentCity}    ${states[0]}     ${permanentPinCode}    ${panNumber}    ${bool[1]}    customer=${pcid15}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=    Get KYC    ${en_uid}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable   ${id}        ${resp.json()[0]['id']}
    # Set Test Variable        ${id}
    Should Be Equal As Strings      ${resp.json()[0]['originFrom']}  ${originFrom[1]}
    Should Be Equal As Strings      ${resp.json()[0]['originUid']}  ${en_uid}
    Should Be Equal As Strings      ${resp.json()[0]['customerName']}  ${customerName}
    Should Be Equal As Strings      ${resp.json()[0]['customer']}  ${pcid15}
    Should Be Equal As Strings      ${resp.json()[0]['relationName']}  ${relationName}
    Should Be Equal As Strings      ${resp.json()[0]['permanentAddress']}  ${permanentAddress}
    Should Be Equal As Strings      ${resp.json()[0]['permanentCity']}  ${permanentCity}


    ${dob}=    FakerLibrary.Date
    ${relationName1}=    FakerLibrary.Last Name
    ${idValue}=    FakerLibrary.Word
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
    # ${attachments}=     Create List

    # ${resp}=  Create KYC    ${originFrom}    ${leUid1}        ${customerName}    ${dob}        ${relationType[1]}    ${relationName1}    ${telephoneType[2]}    ${phoneNo}    ${idTypes}    ${idValue}    ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress1}    ${permanentCity1}    ${permanentState1}    ${permanentPinCode}    ${panNumber1}    ${bool[1]}    customer=${pcid15}
    # Log   ${resp.json()}
    # Should Be Equal As Strings      ${resp.status_code}  200

    ${caption3}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType5}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType5}
    ${list13}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption3}     fileType=${fileType5}   order=${order}
    ${listm}=   Create List   ${list13}    
    ${valida1}=    Create Dictionary    idTypes=${idTypes[0]}     idValue=${idValue}    attachments=${listm}
   
    ${caption5}=  Fakerlibrary.Sentence
    ${list1}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption5}     fileType=${fileType5}   order=${order}  
    ${listn}=   Create List     ${list1}  
    ${valida2}=    Create Dictionary    idTypes=${idTypes[1]}     idValue=${idValue}    attachments=${listn}
    ${validationId}=    Create List    ${valida1}    ${valida2}
    Set Suite Variable    ${validationId}

    ${resp}=  Update KYC    ${id}        ${en_uid}        ${customerName}    ${dob}        ${relationType[1]}    ${relationName1}    ${telephoneType[2]}    ${phoneNo}   ${validationId}    ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress1}    ${permanentCity1}    ${states[0]}     ${permanentPinCode}    ${panNumber1}    ${bool[1]}    customer=${pcid15}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=    Get KYC    ${en_uid}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Should Be Equal As Strings      ${resp.json()[0]['originFrom']}  ${originFrom[1]}
    Should Be Equal As Strings      ${resp.json()[0]['originUid']}  ${en_uid}
    Should Be Equal As Strings      ${resp.json()[0]['customerName']}  ${customerName}
    Should Be Equal As Strings      ${resp.json()[0]['customer']}  ${pcid15}
    Should Be Equal As Strings      ${resp.json()[0]['permanentAddress']}  ${permanentAddress1}
    Should Be Equal As Strings      ${resp.json()[0]['permanentCity']}  ${permanentCity1}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][0]['idTypes']}                      ${idTypes[0]}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][0]['attachments'][0]['owner']}      ${provider_id}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][0]['attachments'][0]['fileName']}   ${jpgfile}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][0]['attachments'][0]['fileType']}   ${fileType5}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][1]['idTypes']}                      ${idTypes[1]}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][1]['attachments'][0]['owner']}      ${provider_id}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][1]['attachments'][0]['fileName']}   ${jpgfile}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][1]['attachments'][0]['fileType']}   ${fileType5}
  
    ${resp}=  Get Enquiry by Uuid  ${en_uid}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id2}
    Should Be Equal As Strings    ${resp.json()['status']['name']}  ${status_name2}
  
    ${resp}=  Change KYC Status        ${en_uid}  ${status_id2}     
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200


JD-TC-UpdateKyc-2
    [Documentation]  Create a  Kyc with Co-applicant and Update Kyc.

    ${resp}=   Encrypted Provider Login  ${BUSER_U1}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${provider_id}  ${decrypted_data['id']}
    clear_customer   ${HLPUSERNAME5}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME15}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME15}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${pcid15}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${pcid15}  ${resp.json()[0]['id']}
    END

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME15}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable    ${phoneNo}   ${resp.json()[0]['phoneNo']}

    
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

  

    updateEnquiryStatus  ${account_id}
    sleep  01s



    # enquiryTemplate(account_id,category_id=0,priority_id=5,type_id=0)
    ${resp}=  enquiryTemplate  ${account_id}  ${en_temp_name}  ${enq_sts_new_id}  creator_provider_id=${provider_id} 

    ${resp}=  Get Enquiry Template
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Provider Enquiry Category  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_catagories}=  Set Variable  ${resp.json()}
    ${random_catagories}=  Evaluate  random.choice($en_catagories)  random
    ${rand_catagory_id}=  Set Variable  ${random_catagories['id']}
    ${rand_catagory_name}=  Set Variable  ${random_catagories['name']}

    ${category}=  Create Dictionary   id=${rand_catagory_id}         

    ${resp}=  Create Enquiry  ${locId}  ${pcid15}  category=${category}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${en_id2}        ${resp.json()['id']}
    Set Test Variable   ${en_uid2}        ${resp.json()['uid']}

    ${resp}=  Get Enquiry by Uuid  ${en_uid2}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}   ${en_id2}
    Should Be Equal As Strings  ${resp.json()['uid']}   ${en_uid2}
    Should Be Equal As Strings  ${resp.json()['accountId']}   ${account_id}

    ${resp}=  Get Provider Enquiry Status  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}  Get Length  ${resp.json()}
    FOR   ${i}  IN RANGE   ${len}
        Set Test Variable  ${status_id${i}}    ${resp.json()[${i}]['id']}
        Set Test Variable  ${status_name${i}}  ${resp.json()[${i}]['name']}
    END

    ${resp}=  Get Enquiry by Uuid  ${en_uid2}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${status_id0}    ${resp.json()['status']['id']}

    ${resp}=  Update and Proceed Enquiry to Status  ${en_uid2}  ${status_id0}  ${locId}  ${pcid15}  &{resp.json()}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Get Enquiry by Uuid  ${en_uid2}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id1}
    Should Be Equal As Strings    ${resp.json()['status']['name']}  ${status_name1}
  
    ${resp}=  Update and Proceed Enquiry to Status  ${en_uid2}  ${status_id1}  ${locId}  ${pcid15}  &{resp.json()}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
  
    ${resp}=  Get Enquiry by Uuid  ${en_uid2}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id2}
    Should Be Equal As Strings    ${resp.json()['status']['name']}  ${status_name2}
  
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
    ${permanentAddress}=    FakerLibrary.Address
    ${permanentCity}=    FakerLibrary.City
    ${permanentState}=    FakerLibrary.State
    ${panNumber}=  FakerLibrary.Credit Card Number
    ${attachments}=     Create List
    
    ${resp}=  Create KYC        ${en_uid2}        ${customerName}    ${dob}        ${relationType[1]}    ${relationName}    ${telephoneType[2]}    ${phoneNo}   ${attachments}       ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress}    ${permanentCity}    ${states[0]}     ${permanentPinCode}    ${panNumber}    ${bool[1]}    customer=${pcid15}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=    Get KYC    ${en_uid2}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable   ${id}        ${resp.json()[0]['id']}
    # Set Test Variable        ${id}
    Should Be Equal As Strings      ${resp.json()[0]['originFrom']}        ${originFrom[1]}
    Should Be Equal As Strings      ${resp.json()[0]['originUid']}         ${en_uid2}
    Should Be Equal As Strings      ${resp.json()[0]['customerName']}      ${customerName}
    Should Be Equal As Strings      ${resp.json()[0]['customer']}          ${pcid15}
    Should Be Equal As Strings      ${resp.json()[0]['relationName']}      ${relationName}
    Should Be Equal As Strings      ${resp.json()[0]['permanentAddress']}  ${permanentAddress}
    Should Be Equal As Strings      ${resp.json()[0]['permanentCity']}     ${permanentCity}

    ${dob}=    FakerLibrary.Date
    ${relationName1}=    FakerLibrary.Last Name
    ${idValue}=    FakerLibrary.Word
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
    # ${attachments}=     Create List
    ${permanentPhone}=    FakerLibrary.Phone Number
    ${PO_Number}=  Generate Random Phone Number
    ${PO_Number}=  Convert To Integer    ${PO_Number}

    ${resp}=  Create KYC        ${en_uid2}        ${customerName}    ${dob}        ${relationType[1]}    ${relationName1}    ${telephoneType[2]}    ${phoneNo}  ${attachments}      ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}        ${permanentAddress1}    ${permanentCity1}    ${states[0]}     ${permanentPinCode}    ${panNumber1}        ${bool[0]}    parentid=${pcid15}    permanentPhone=${PO_Number}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=    Get KYC    ${en_uid2}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable   ${id2}        ${resp.json()[1]['id']}
    # Set Test Variable        ${id}
    Should Be Equal As Strings      ${resp.json()[1]['originFrom']}  ${originFrom[1]}
    Should Be Equal As Strings      ${resp.json()[1]['originUid']}  ${en_uid2}
    Should Be Equal As Strings      ${resp.json()[1]['customerName']}  ${customerName}
    # Should Be Equal As Strings      ${resp.json()[1]['panNumber']}  ${panNumber1}
    Should Be Equal As Strings      ${resp.json()[1]['parentid']['id']}  ${pcid15}
    Should Be Equal As Strings      ${resp.json()[1]['relationName']}  ${relationName1}
    Should Be Equal As Strings      ${resp.json()[1]['permanentAddress']}  ${permanentAddress1}
    Should Be Equal As Strings      ${resp.json()[1]['permanentCity']}  ${permanentCity1}


    ${customerName1}=    FakerLibrary.Last Name
    ${customerName2}=    FakerLibrary.Last Name

    

    ${resp}=  Update KYC    ${id}       ${en_uid2}        ${customerName1}    ${dob}        ${relationType[1]}    ${relationName1}    ${telephoneType[2]}    ${PO_Number}  ${validationId}     ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress}    ${permanentCity}    ${states[0]}     ${permanentPinCode}    ${panNumber1}    ${bool[1]}    customer=${pcid15}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=  Update KYC    ${id2}        ${en_uid2}        ${customerName2}    ${dob}        ${relationType[1]}    ${relationName}    ${telephoneType[2]}    ${PO_Number}  ${validationId}     ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress}    ${permanentCity}    ${states[0]}     ${permanentPinCode}    ${panNumber}    ${bool[1]}    customer=${pcid15}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=    Get KYC    ${en_uid2}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Should Be Equal As Strings      ${resp.json()[0]['originFrom']}  ${originFrom[1]}
    Should Be Equal As Strings      ${resp.json()[0]['originUid']}  ${en_uid2}
    Should Be Equal As Strings      ${resp.json()[0]['customerName']}  ${customerName1}
    Should Be Equal As Strings      ${resp.json()[0]['customer']}  ${pcid15}
    Should Be Equal As Strings      ${resp.json()[0]['relationName']}  ${relationName1}
    Should Be Equal As Strings      ${resp.json()[0]['permanentAddress']}  ${permanentAddress}
    Should Be Equal As Strings      ${resp.json()[0]['permanentCity']}  ${permanentCity}

    Should Be Equal As Strings      ${resp.json()[1]['originFrom']}  ${originFrom[1]}
    Should Be Equal As Strings      ${resp.json()[1]['originUid']}  ${en_uid2}
    Should Be Equal As Strings      ${resp.json()[1]['customerName']}  ${customerName2}
    Should Be Equal As Strings      ${resp.json()[1]['parentid']['id']}  ${pcid15}
    Should Be Equal As Strings      ${resp.json()[1]['relationName']}  ${relationName}
    Should Be Equal As Strings      ${resp.json()[1]['permanentAddress']}  ${permanentAddress}
    Should Be Equal As Strings      ${resp.json()[1]['permanentCity']}  ${permanentCity}

JD-TC-UpdateKyc-3
    [Documentation]  Create a  Kyc and Update Kyc without customerName.

    ${resp}=   Encrypted Provider Login  ${BUSER_U1}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${provider_id}  ${decrypted_data['id']}

    clear_customer   ${HLPUSERNAME5}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME15}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME15}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${pcid15}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${pcid15}  ${resp.json()[0]['id']}
    END

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME15}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable    ${phoneNo}   ${resp.json()[0]['phoneNo']}

    
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

  

    updateEnquiryStatus  ${account_id}
    sleep  01s



    # enquiryTemplate(account_id,category_id=0,priority_id=5,type_id=0)
    ${resp}=  enquiryTemplate  ${account_id}  ${en_temp_name}  ${enq_sts_new_id}  creator_provider_id=${provider_id} 

    ${resp}=  Get Enquiry Template
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Provider Enquiry Category  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_catagories}=  Set Variable  ${resp.json()}
    ${random_catagories}=  Evaluate  random.choice($en_catagories)  random
    ${rand_catagory_id}=  Set Variable  ${random_catagories['id']}
    ${rand_catagory_name}=  Set Variable  ${random_catagories['name']}

    ${category}=  Create Dictionary   id=${rand_catagory_id}         

    ${resp}=  Create Enquiry  ${locId}  ${pcid15}  category=${category}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${en_id3}        ${resp.json()['id']}
    Set Test Variable   ${en_uid3}        ${resp.json()['uid']}

    ${resp}=  Get Enquiry by Uuid  ${en_uid3}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}   ${en_id3}
    Should Be Equal As Strings  ${resp.json()['uid']}   ${en_uid3}
    Should Be Equal As Strings  ${resp.json()['accountId']}   ${account_id}

    ${resp}=  Get Provider Enquiry Status  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}  Get Length  ${resp.json()}
    FOR   ${i}  IN RANGE   ${len}
        Set Test Variable  ${status_id${i}}    ${resp.json()[${i}]['id']}
        Set Test Variable  ${status_name${i}}  ${resp.json()[${i}]['name']}
    END

    ${resp}=  Get Enquiry by Uuid  ${en_uid3}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${status_id0}    ${resp.json()['status']['id']}

    ${resp}=  Update and Proceed Enquiry to Status  ${en_uid3}  ${status_id0}  ${locId}  ${pcid15}  &{resp.json()}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Get Enquiry by Uuid  ${en_uid3}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id1}
    Should Be Equal As Strings    ${resp.json()['status']['name']}  ${status_name1}
  
    ${resp}=  Update and Proceed Enquiry to Status  ${en_uid3}  ${status_id1}  ${locId}  ${pcid15}  &{resp.json()}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
  
    ${resp}=  Get Enquiry by Uuid  ${en_uid3}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id2}
    Should Be Equal As Strings    ${resp.json()['status']['name']}  ${status_name2}
  

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
    ${permanentAddress}=    FakerLibrary.Address
    ${permanentCity}=    FakerLibrary.City
    ${permanentState}=    FakerLibrary.State
    ${panNumber}=  FakerLibrary.Credit Card Number
    ${attachments}=     Create List

    ${resp}=  Create KYC        ${en_uid3}       ${customerName}    ${dob}        ${relationType[1]}    ${relationName}    ${telephoneType[2]}    ${phoneNo}  ${attachments}      ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress}    ${permanentCity}    ${permanentState}    ${permanentPinCode}    ${panNumber}    ${bool[1]}    customer=${pcid15} 
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=    Get KYC    ${en_uid3}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable   ${id}        ${resp.json()[0]['id']}
    # Set Test Variable        ${id}
    Should Be Equal As Strings      ${resp.json()[0]['originFrom']}  ${originFrom[1]}
    Should Be Equal As Strings      ${resp.json()[0]['originUid']}  ${en_uid3}
    Should Be Equal As Strings      ${resp.json()[0]['customerName']}  ${customerName}
    Should Be Equal As Strings      ${resp.json()[0]['customer']}  ${pcid15}
    Should Be Equal As Strings      ${resp.json()[0]['relationName']}  ${relationName}
    Should Be Equal As Strings      ${resp.json()[0]['permanentAddress']}  ${permanentAddress}
    Should Be Equal As Strings      ${resp.json()[0]['permanentCity']}  ${permanentCity}

    ${resp}=  Update KYC    ${id}       ${en_uid3}        ${EMPTY}    ${dob}        ${relationType[1]}    ${relationName}    ${telephoneType[2]}    ${phoneNo}  ${validationId}      ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress}    ${permanentCity}    ${permanentState}    ${permanentPinCode}    ${panNumber}    ${bool[1]}    customer=${pcid15}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=    Get KYC    ${en_uid3}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Should Be Equal As Strings      ${resp.json()[0]['originFrom']}  ${originFrom[1]}
    Should Be Equal As Strings      ${resp.json()[0]['originUid']}  ${en_uid3}
    Should Be Equal As Strings      ${resp.json()[0]['customerName']}  ${EMPTY}
    Should Be Equal As Strings      ${resp.json()[0]['customer']}  ${pcid15}
    Should Be Equal As Strings      ${resp.json()[0]['relationName']}  ${relationName}
    Should Be Equal As Strings      ${resp.json()[0]['permanentAddress']}  ${permanentAddress}
    Should Be Equal As Strings      ${resp.json()[0]['permanentCity']}  ${permanentCity}


    

JD-TC-UpdateKyc-4
    [Documentation]  Create a  Kyc and Update Kyc with branch Lead id.

    ${resp}=   Encrypted Provider Login  ${HLPUSERNAME5}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Set Suite Variable  ${provider_id}  ${resp.json()['id']}

    clear_customer   ${HLPUSERNAME5}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME15}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME15}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${pcid15}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${pcid15}  ${resp.json()[0]['id']}
    END

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME15}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable    ${phoneNo}   ${resp.json()[0]['phoneNo']}

    
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


    updateEnquiryStatus  ${account_id}
    sleep  01s

    ${resp}=  enquiryTemplate  ${account_id}  ${en_temp_name}  ${enq_sts_new_id}  creator_provider_id=${provider_id} 

    ${resp}=  Get Enquiry Template
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Provider Enquiry Category  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_catagories}=  Set Variable  ${resp.json()}
    ${random_catagories}=  Evaluate  random.choice($en_catagories)  random
    ${rand_catagory_id}=  Set Variable  ${random_catagories['id']}
    ${rand_catagory_name}=  Set Variable  ${random_catagories['name']}

    ${category}=  Create Dictionary   id=${rand_catagory_id}         

    ${resp}=  Create Enquiry  ${locId}  ${pcid15}  category=${category}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${en_id6}        ${resp.json()['id']}
    Set Test Variable   ${en_uid6}        ${resp.json()['uid']}

    ${resp}=  Get Enquiry by Uuid  ${en_uid6}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}   ${en_id6}
    Should Be Equal As Strings  ${resp.json()['uid']}   ${en_uid6}
    Should Be Equal As Strings  ${resp.json()['accountId']}   ${account_id}

    ${resp}=  Get Provider Enquiry Status  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}  Get Length  ${resp.json()}
    FOR   ${i}  IN RANGE   ${len}
        Set Test Variable  ${status_id${i}}    ${resp.json()[${i}]['id']}
        Set Test Variable  ${status_name${i}}  ${resp.json()[${i}]['name']}
    END

    ${resp}=  Get Enquiry by Uuid  ${en_uid6}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${status_id0}    ${resp.json()['status']['id']}

    ${resp}=  Update and Proceed Enquiry to Status  ${en_uid6}  ${status_id0}  ${locId}  ${pcid15}  &{resp.json()}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Get Enquiry by Uuid  ${en_uid6}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id1}
    Should Be Equal As Strings    ${resp.json()['status']['name']}  ${status_name1}
  
    ${resp}=  Update and Proceed Enquiry to Status  ${en_uid6}  ${status_id1}  ${locId}  ${pcid15}  &{resp.json()}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
  
    ${resp}=  Get Enquiry by Uuid  ${en_uid6}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id2}
    Should Be Equal As Strings    ${resp.json()['status']['name']}  ${status_name2}
  

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
    ${permanentAddress}=    FakerLibrary.Address
    ${permanentCity}=    FakerLibrary.City
    ${permanentState}=    FakerLibrary.State
    ${panNumber}=  FakerLibrary.Credit Card Number
    ${attachments}=     Create List

    ${resp}=  Create KYC       ${en_uid6}      ${customerName}    ${dob}        ${relationType[1]}    ${relationName}    ${telephoneType[2]}    ${phoneNo}  ${attachments}      ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress}    ${permanentCity}    ${permanentState}    ${permanentPinCode}    ${panNumber}    ${bool[1]}    customer= ${pcid15} 
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=    Get KYC    ${en_uid6}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable   ${id}        ${resp.json()[0]['id']}
    # Set Test Variable        ${id}
    Should Be Equal As Strings      ${resp.json()[0]['originFrom']}  ${originFrom[1]}
    Should Be Equal As Strings      ${resp.json()[0]['originUid']}  ${en_uid6}
    Should Be Equal As Strings      ${resp.json()[0]['customerName']}  ${customerName}
    Should Be Equal As Strings      ${resp.json()[0]['customer']}  ${pcid15}
    Should Be Equal As Strings      ${resp.json()[0]['relationName']}  ${relationName}
    Should Be Equal As Strings      ${resp.json()[0]['permanentAddress']}  ${permanentAddress}
    Should Be Equal As Strings      ${resp.json()[0]['permanentCity']}  ${permanentCity}


    ${resp}=   Encrypted Provider Login  ${BUSER_U1}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${provider_id}  ${decrypted_data['id']}


    ${resp}=  Update KYC    ${id}        ${en_uid6}        ${EMPTY}    ${dob}        ${relationType[1]}    ${relationName}    ${telephoneType[2]}    ${phoneNo}  ${validationId}      ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress}    ${permanentCity}    ${permanentState}    ${permanentPinCode}    ${panNumber}    ${bool[1]}    customer=${pcid15}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=    Get KYC    ${en_uid6}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Should Be Equal As Strings      ${resp.json()[0]['originFrom']}  ${originFrom[1]}
    Should Be Equal As Strings      ${resp.json()[0]['originUid']}  ${en_uid6}
    Should Be Equal As Strings      ${resp.json()[0]['customerName']}  ${EMPTY}
    Should Be Equal As Strings      ${resp.json()[0]['customer']}  ${pcid15}
    Should Be Equal As Strings      ${resp.json()[0]['relationName']}  ${relationName}
    Should Be Equal As Strings      ${resp.json()[0]['permanentAddress']}  ${permanentAddress}
    Should Be Equal As Strings      ${resp.json()[0]['permanentCity']}  ${permanentCity}


JD-TC-UpdateKyc-5
    [Documentation]  Create a  Kyc and Update Kyc then again update Kyc.

    ${resp}=   Encrypted Provider Login  ${HLPUSERNAME5}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    clear_customer   ${HLPUSERNAME5}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME15}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME15}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${pcid15}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${pcid15}  ${resp.json()[0]['id']}
    END

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME15}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable    ${phoneNo}   ${resp.json()[0]['phoneNo']}

    
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


    updateEnquiryStatus  ${account_id}
    sleep  01s

    ${resp}=  enquiryTemplate  ${account_id}  ${en_temp_name}  ${enq_sts_new_id}  creator_provider_id=${provider_id} 

    ${resp}=  Get Enquiry Template
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Provider Enquiry Category  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_catagories}=  Set Variable  ${resp.json()}
    ${random_catagories}=  Evaluate  random.choice($en_catagories)  random
    ${rand_catagory_id}=  Set Variable  ${random_catagories['id']}
    ${rand_catagory_name}=  Set Variable  ${random_catagories['name']}

    ${category}=  Create Dictionary   id=${rand_catagory_id}         

    ${resp}=  Create Enquiry  ${locId}  ${pcid15}  category=${category}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${en_id7}        ${resp.json()['id']}
    Set Test Variable   ${en_uid7}        ${resp.json()['uid']}

    ${resp}=  Get Enquiry by Uuid  ${en_uid7}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}   ${en_id7}
    Should Be Equal As Strings  ${resp.json()['uid']}   ${en_uid7}
    Should Be Equal As Strings  ${resp.json()['accountId']}   ${account_id}

    ${resp}=  Get Provider Enquiry Status  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}  Get Length  ${resp.json()}
    FOR   ${i}  IN RANGE   ${len}
        Set Test Variable  ${status_id${i}}    ${resp.json()[${i}]['id']}
        Set Test Variable  ${status_name${i}}  ${resp.json()[${i}]['name']}
    END

    ${resp}=  Get Enquiry by Uuid  ${en_uid7}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${status_id0}    ${resp.json()['status']['id']}

    ${resp}=  Update and Proceed Enquiry to Status  ${en_uid7}  ${status_id0}  ${locId}  ${pcid15}  &{resp.json()}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Get Enquiry by Uuid  ${en_uid7}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id1}
    Should Be Equal As Strings    ${resp.json()['status']['name']}  ${status_name1}
  
    ${resp}=  Update and Proceed Enquiry to Status  ${en_uid7}  ${status_id1}  ${locId}  ${pcid15}  &{resp.json()}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
  
    ${resp}=  Get Enquiry by Uuid  ${en_uid7}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id2}
    Should Be Equal As Strings    ${resp.json()['status']['name']}  ${status_name2}
  
   
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
    ${permanentAddress}=    FakerLibrary.Address
    ${permanentCity}=    FakerLibrary.City
    ${permanentState}=    FakerLibrary.State
    ${panNumber}=  FakerLibrary.Credit Card Number
    ${attachments}=     Create List

    ${resp}=  Create KYC        ${en_uid7}      ${customerName}    ${dob}        ${relationType[1]}    ${relationName}    ${telephoneType[2]}    ${phoneNo}  ${attachments}      ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress}    ${permanentCity}    ${permanentState}    ${permanentPinCode}    ${panNumber}    ${bool[1]}    customer= ${pcid15} 
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=    Get KYC    ${en_uid7}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable   ${id}        ${resp.json()[0]['id']}
    # Set Test Variable        ${id}
    Should Be Equal As Strings      ${resp.json()[0]['originFrom']}  ${originFrom[1]}
    Should Be Equal As Strings      ${resp.json()[0]['originUid']}  ${en_uid7}
    Should Be Equal As Strings      ${resp.json()[0]['customerName']}  ${customerName}
    Should Be Equal As Strings      ${resp.json()[0]['customer']}  ${pcid15}
    Should Be Equal As Strings      ${resp.json()[0]['relationName']}  ${relationName}
    Should Be Equal As Strings      ${resp.json()[0]['permanentAddress']}  ${permanentAddress}
    Should Be Equal As Strings      ${resp.json()[0]['permanentCity']}  ${permanentCity}

    ${dob1}=    FakerLibrary.Date
    ${relationName1}=    FakerLibrary.First Name
    ${idValue1}=    FakerLibrary.Word
    ${fileName1}=    FakerLibrary.File Name
    ${fileSize1}=    FakerLibrary.Binary
    ${caption1}=    FakerLibrary.Text
    ${resp}=  db.getType   ${jpegfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${jpegfile}
    Set Suite Variable    ${fileType1}
    ${permanentAddress1}=    FakerLibrary.Address
    ${permanentCity1}=    FakerLibrary.City
    ${permanentState1}=    FakerLibrary.State
    ${panNumber1}=  FakerLibrary.Credit Card Number
    ${attachments1}=     Create List

    ${resp}=  Update KYC    ${id}       ${en_uid7}        ${customerName}    ${dob1}        ${relationType[1]}    ${relationName1}    ${telephoneType[2]}    ${phoneNo}  ${validationId}     ${provider_id}    ${fileName1}    0.0054    ${caption1}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress1}    ${permanentCity1}    ${permanentState1}    ${permanentPinCode}    ${panNumber1}    ${bool[1]}    customer=${pcid15}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=  Update KYC    ${id}        ${en_uid7}        ${customerName}    ${dob1}        ${relationType[1]}    ${relationName1}    ${telephoneType[2]}    ${phoneNo}  ${validationId}      ${provider_id}    ${fileName1}    0.0054    ${caption1}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress1}    ${permanentCity1}    ${permanentState1}    ${permanentPinCode}    ${panNumber1}    ${bool[1]}    customer=${pcid15}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=    Get KYC    ${en_uid7}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable   ${id}        ${resp.json()[0]['id']}
    # Set Test Variable        ${id}
    Should Be Equal As Strings      ${resp.json()[0]['originFrom']}  ${originFrom[1]}
    Should Be Equal As Strings      ${resp.json()[0]['originUid']}  ${en_uid7}
    Should Be Equal As Strings      ${resp.json()[0]['customerName']}  ${customerName}
    Should Be Equal As Strings      ${resp.json()[0]['customer']}  ${pcid15}
    Should Be Equal As Strings      ${resp.json()[0]['relationName']}  ${relationName1}
    Should Be Equal As Strings      ${resp.json()[0]['permanentAddress']}  ${permanentAddress1}
    Should Be Equal As Strings      ${resp.json()[0]['permanentCity']}  ${permanentCity1}


JD-TC-UpdateKyc-6
    [Documentation]  Create a  Kyc and add more attachment in Update Kyc.

    ${resp}=   Encrypted Provider Login  ${HLPUSERNAME5}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Set Suite Variable  ${provider_id1}  ${resp.json()['id']}

   clear_customer   ${HLPUSERNAME5}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME15}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME15}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${pcid15}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${pcid15}  ${resp.json()[0]['id']}
    END

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME15}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable    ${phoneNo}   ${resp.json()[0]['phoneNo']}

    
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


    updateEnquiryStatus  ${account_id}
    sleep  01s

    ${resp}=  enquiryTemplate  ${account_id}  ${en_temp_name}  ${enq_sts_new_id}  creator_provider_id=${provider_id} 

    ${resp}=  Get Enquiry Template
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Provider Enquiry Category  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_catagories}=  Set Variable  ${resp.json()}
    ${random_catagories}=  Evaluate  random.choice($en_catagories)  random
    ${rand_catagory_id}=  Set Variable  ${random_catagories['id']}
    ${rand_catagory_name}=  Set Variable  ${random_catagories['name']}

    ${category}=  Create Dictionary   id=${rand_catagory_id}         

    ${resp}=  Create Enquiry  ${locId}  ${pcid15}  category=${category}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${en_id8}        ${resp.json()['id']}
    Set Test Variable   ${en_uid8}        ${resp.json()['uid']}

    ${resp}=  Get Enquiry by Uuid  ${en_uid8}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}   ${en_id8}
    Should Be Equal As Strings  ${resp.json()['uid']}   ${en_uid8}
    Should Be Equal As Strings  ${resp.json()['accountId']}   ${account_id}

    ${resp}=  Get Provider Enquiry Status  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}  Get Length  ${resp.json()}
    FOR   ${i}  IN RANGE   ${len}
        Set Test Variable  ${status_id${i}}    ${resp.json()[${i}]['id']}
        Set Test Variable  ${status_name${i}}  ${resp.json()[${i}]['name']}
    END

    ${resp}=  Get Enquiry by Uuid  ${en_uid8}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${status_id0}    ${resp.json()['status']['id']}

    ${resp}=  Update and Proceed Enquiry to Status  ${en_uid8}  ${status_id0}  ${locId}  ${pcid15}  &{resp.json()}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Get Enquiry by Uuid  ${en_uid8}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id1}
    Should Be Equal As Strings    ${resp.json()['status']['name']}  ${status_name1}
  
    ${resp}=  Update and Proceed Enquiry to Status  ${en_uid8}  ${status_id1}  ${locId}  ${pcid15}  &{resp.json()}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
  
    ${resp}=  Get Enquiry by Uuid  ${en_uid8}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id2}
    Should Be Equal As Strings    ${resp.json()['status']['name']}  ${status_name2}
  
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
    ${permanentAddress}=    FakerLibrary.Address
    ${permanentCity}=    FakerLibrary.City
    ${permanentState}=    FakerLibrary.State
    ${panNumber}=  FakerLibrary.Credit Card Number
    # ${attachments}=     Create List

    ${caption3}=  Fakerlibrary.Sentence
    Set Suite Variable   ${caption3}
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType5}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType5}
    ${list13}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption3}     fileType=${fileType5}   order=${order}
    ${caption4}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
   
    ${list14}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption4}     fileType=${fileType5}   order=${order}
  
    ${list}=   Create List     ${list13}   ${list14} 
    ${valida1}=    Create Dictionary    idTypes=${idTypes[0]}     idValue=${idValue}    attachments=${list}
   
    ${caption5}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}

    ${list13}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00987     caption=${caption5}     fileType=${fileType5}   order=${order}
    ${caption6}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}

    ${list14}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption6}     fileType=${fileType5}   order=${order}
  
    ${list}=   Create List     ${list13}   ${list14} 
    ${valida2}=    Create Dictionary    idTypes=${idTypes[2]}     idValue=${idValue}    attachments=${list}
    ${validationId}=    Create List    ${valida1}    ${valida2}
    Set Test Variable    ${validationId}

    ${resp}=  Create KYC        ${en_uid8}      ${customerName}    ${dob}        ${relationType[1]}    ${relationName}    ${telephoneType[2]}    ${phoneNo}  ${validationId}      ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress}    ${permanentCity}    ${permanentState}    ${permanentPinCode}    ${panNumber}    ${bool[1]}    customer= ${pcid15} 
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=    Get KYC    ${en_uid8}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable   ${id}        ${resp.json()[0]['id']}
    # Set Test Variable        ${id}
    Should Be Equal As Strings      ${resp.json()[0]['originFrom']}                                       ${originFrom[1]}
    Should Be Equal As Strings      ${resp.json()[0]['originUid']}                                        ${en_uid8}
    Should Be Equal As Strings      ${resp.json()[0]['customerName']}                                     ${customerName}
    Should Be Equal As Strings      ${resp.json()[0]['customer']}                                         ${pcid15}
    Should Be Equal As Strings      ${resp.json()[0]['relationName']}                                     ${relationName}
    Should Be Equal As Strings      ${resp.json()[0]['permanentAddress']}                                 ${permanentAddress}
    Should Be Equal As Strings      ${resp.json()[0]['permanentCity']}                                    ${permanentCity}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][0]['idTypes']}                      ${idTypes[0]}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][0]['attachments'][0]['owner']}      ${provider_id}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][0]['attachments'][0]['fileName']}   ${jpgfile}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][0]['attachments'][0]['fileType']}   ${fileType5}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][0]['attachments'][1]['owner']}      ${provider_id}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][0]['attachments'][1]['fileName']}   ${jpgfile}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][0]['attachments'][1]['fileType']}   ${fileType5}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][1]['idTypes']}   ${idTypes[2]}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][1]['attachments'][0]['owner']}     ${provider_id}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][1]['attachments'][0]['fileName']}   ${jpgfile}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][1]['attachments'][0]['fileType']}   ${fileType5}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][1]['attachments'][1]['owner']}      ${provider_id}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][1]['attachments'][1]['fileName']}   ${jpgfile}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][1]['attachments'][1]['fileType']}   ${fileType5}
    
   
    
    ${dob1}=    FakerLibrary.Date
    ${relationName1}=    FakerLibrary.First Name
    ${idValue1}=    FakerLibrary.Word
    ${fileName1}=    FakerLibrary.File Name
    ${fileSize1}=    FakerLibrary.Binary
    ${caption1}=    FakerLibrary.Text
    ${resp}=  db.getType   ${jpegfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${jpegfile}
    Set Suite Variable    ${fileType1}
    ${permanentAddress1}=    FakerLibrary.Address
    ${permanentCity1}=    FakerLibrary.City
    ${permanentState1}=    FakerLibrary.State
    ${panNumber1}=  FakerLibrary.Credit Card Number
    # ${attachments1}=     Create List

    ${caption6}=  Fakerlibrary.Sentence
    Set Suite Variable   ${caption6}
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType6}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType6}
    ${list13}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.003426     caption=${caption6}     fileType=${fileType6}   order=${order}
    ${caption7}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${caption8}=  Fakerlibrary.Sentence
    ${list14}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00223    caption=${caption7}     fileType=${fileType5}   order=${order}
    ${list15}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00678     caption=${caption8}     fileType=${fileType5}   order=${order}

    ${list}=   Create List     ${list13}   ${list14}   ${list15}
    ${valida123}=    Create Dictionary    idTypes=${idTypes[0]}     idValue=${idValue}    attachments=${list}
   
    ${caption9}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}

    ${list13}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00987    caption=${caption9}     fileType=${fileType5}   order=${order}
    ${caption10}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}

    ${list14}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.008355     caption=${caption10}     fileType=${fileType5}   order=${order}
  
    ${list}=   Create List     ${list13}   ${list14} 
    ${valida234}=    Create Dictionary    idTypes=${idTypes[2]}     idValue=${idValue}    attachments=${list}
    ${abcde}=    Create List    ${valida123}    ${valida234}
    Set Test Variable    ${abcde}

    ${resp}=  Update KYC    ${id}        ${en_uid8}        ${customerName}    ${dob1}        ${relationType[1]}    ${relationName1}    ${telephoneType[2]}    ${phoneNo}  ${abcde}     ${provider_id}    ${fileName1}    0.0054    ${caption1}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress1}    ${permanentCity1}    ${permanentState1}    ${permanentPinCode}    ${panNumber1}    ${bool[1]}    customer=${pcid15}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    # ${resp}=  Update KYC    ${id}    ${originFrom}    ${leUid7}        ${customerName}    ${dob1}        ${relationType[1]}    ${relationName1}    ${telephoneType[2]}    ${phoneNo}  ${validationId}      ${provider_id}    ${fileName1}    0.0054    ${caption1}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress1}    ${permanentCity1}    ${permanentState1}    ${permanentPinCode}    ${panNumber1}    ${bool[1]}    customer=${pcid15}
    # Log   ${resp.json()}
    # Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=    Get KYC    ${en_uid8}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable   ${id}        ${resp.json()[0]['id']}
    # Set Test Variable        ${id}
    Should Be Equal As Strings      ${resp.json()[0]['originFrom']}                                       ${originFrom[1]}
    Should Be Equal As Strings      ${resp.json()[0]['originUid']}                                        ${en_uid8}
    Should Be Equal As Strings      ${resp.json()[0]['customerName']}                                     ${customerName}
    Should Be Equal As Strings      ${resp.json()[0]['customer']}                                         ${pcid15}
    Should Be Equal As Strings      ${resp.json()[0]['relationName']}                                     ${relationName1}
    Should Be Equal As Strings      ${resp.json()[0]['permanentAddress']}                                 ${permanentAddress1}
    Should Be Equal As Strings      ${resp.json()[0]['permanentCity']}                                    ${permanentCity1}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][0]['idTypes']}                      ${idTypes[0]}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][0]['attachments'][0]['owner']}      ${provider_id}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][0]['attachments'][0]['fileName']}   ${jpgfile}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][0]['attachments'][0]['fileType']}   ${fileType6}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][0]['attachments'][0]['caption']}    ${caption6}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][0]['attachments'][1]['owner']}      ${provider_id}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][0]['attachments'][1]['fileName']}   ${jpgfile}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][0]['attachments'][1]['fileType']}   ${fileType5}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][0]['attachments'][1]['caption']}    ${caption7}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][0]['attachments'][2]['owner']}      ${provider_id}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][0]['attachments'][2]['fileName']}   ${jpgfile}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][0]['attachments'][2]['fileType']}   ${fileType5}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][0]['attachments'][2]['caption']}    ${caption8}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][1]['idTypes']}                      ${idTypes[2]}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][1]['attachments'][0]['owner']}      ${provider_id}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][1]['attachments'][0]['fileName']}   ${jpgfile}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][1]['attachments'][0]['fileType']}   ${fileType5}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][1]['attachments'][1]['owner']}      ${provider_id}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][1]['attachments'][1]['fileName']}   ${jpgfile}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][1]['attachments'][1]['fileType']}   ${fileType5}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][1]['attachments'][1]['caption']}    ${caption10}
    
JD-TC-UpdateKyc-7
    [Documentation]  Create a  Kyc and try to remove  attachment in Update Kyc.

    ${resp}=   Encrypted Provider Login  ${HLPUSERNAME5}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    clear_customer   ${HLPUSERNAME5}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME15}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME15}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${pcid15}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${pcid15}  ${resp.json()[0]['id']}
    END

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME15}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable    ${phoneNo}   ${resp.json()[0]['phoneNo']}

    
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


    updateEnquiryStatus  ${account_id}
    sleep  01s

    ${resp}=  enquiryTemplate  ${account_id}  ${en_temp_name}  ${enq_sts_new_id}  creator_provider_id=${provider_id} 

    ${resp}=  Get Enquiry Template
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Provider Enquiry Category  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_catagories}=  Set Variable  ${resp.json()}
    ${random_catagories}=  Evaluate  random.choice($en_catagories)  random
    ${rand_catagory_id}=  Set Variable  ${random_catagories['id']}
    ${rand_catagory_name}=  Set Variable  ${random_catagories['name']}

    ${category}=  Create Dictionary   id=${rand_catagory_id}         

    ${resp}=  Create Enquiry  ${locId}  ${pcid15}  category=${category}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${en_id9}        ${resp.json()['id']}
    Set Test Variable   ${en_uid9}        ${resp.json()['uid']}

    ${resp}=  Get Enquiry by Uuid  ${en_uid9}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}   ${en_id9}
    Should Be Equal As Strings  ${resp.json()['uid']}   ${en_uid9}
    Should Be Equal As Strings  ${resp.json()['accountId']}   ${account_id}

    ${resp}=  Get Provider Enquiry Status  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}  Get Length  ${resp.json()}
    FOR   ${i}  IN RANGE   ${len}
        Set Test Variable  ${status_id${i}}    ${resp.json()[${i}]['id']}
        Set Test Variable  ${status_name${i}}  ${resp.json()[${i}]['name']}
    END

    ${resp}=  Get Enquiry by Uuid  ${en_uid9}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${status_id0}    ${resp.json()['status']['id']}

    ${resp}=  Update and Proceed Enquiry to Status  ${en_uid9}  ${status_id0}  ${locId}  ${pcid15}  &{resp.json()}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Get Enquiry by Uuid  ${en_uid9}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id1}
    Should Be Equal As Strings    ${resp.json()['status']['name']}  ${status_name1}
  
    ${resp}=  Update and Proceed Enquiry to Status  ${en_uid9}  ${status_id1}  ${locId}  ${pcid15}  &{resp.json()}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
  
    ${resp}=  Get Enquiry by Uuid  ${en_uid9}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id2}
    Should Be Equal As Strings    ${resp.json()['status']['name']}  ${status_name2}
  
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
    ${permanentAddress}=    FakerLibrary.Address
    ${permanentCity}=    FakerLibrary.City
    ${permanentState}=    FakerLibrary.State
    ${panNumber}=  FakerLibrary.Credit Card Number
    # ${attachments}=     Create List

    ${caption3}=  Fakerlibrary.Sentence
    Set Suite Variable   ${caption3}
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType5}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType5}
    ${list13}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption3}     fileType=${fileType5}   order=${order}
    ${caption4}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
   
    ${list14}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption4}     fileType=${fileType5}   order=${order}
  
    ${list}=   Create List     ${list13}   ${list14} 
    ${valida1}=    Create Dictionary    idTypes=${idTypes[0]}     idValue=${idValue}    attachments=${list}
   
    ${caption5}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}

    ${list13}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption5}     fileType=${fileType5}   order=${order}
    ${caption6}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}

    ${list14}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption6}     fileType=${fileType5}   order=${order}
  
    ${list}=   Create List     ${list13}   ${list14} 
    ${valida2}=    Create Dictionary    idTypes=${idTypes[2]}     idValue=${idValue}    attachments=${list}
    ${validationId}=    Create List    ${valida1}    ${valida2}
    Set Suite Variable    ${validationId}

    ${resp}=  Create KYC       ${en_uid9}      ${customerName}    ${dob}        ${relationType[1]}    ${relationName}    ${telephoneType[2]}    ${phoneNo}  ${validationId}      ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress}    ${permanentCity}    ${permanentState}    ${permanentPinCode}    ${panNumber}    ${bool[1]}    customer= ${pcid15} 
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=    Get KYC    ${en_uid9}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable   ${id}        ${resp.json()[0]['id']}
    # Set Test Variable        ${id}
    Should Be Equal As Strings      ${resp.json()[0]['originFrom']}  ${originFrom[1]}
    Should Be Equal As Strings      ${resp.json()[0]['originUid']}  ${en_uid9}
    Should Be Equal As Strings      ${resp.json()[0]['customerName']}  ${customerName}
    Should Be Equal As Strings      ${resp.json()[0]['customer']}  ${pcid15}
    Should Be Equal As Strings      ${resp.json()[0]['relationName']}  ${relationName}
    Should Be Equal As Strings      ${resp.json()[0]['permanentAddress']}  ${permanentAddress}
    Should Be Equal As Strings      ${resp.json()[0]['permanentCity']}  ${permanentCity}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][0]['idTypes']}                      ${idTypes[0]}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][0]['attachments'][0]['owner']}      ${provider_id}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][0]['attachments'][0]['fileName']}   ${jpgfile}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][0]['attachments'][0]['fileType']}   ${fileType6}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][0]['attachments'][0]['caption']}    ${caption3}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][0]['attachments'][1]['owner']}      ${provider_id}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][0]['attachments'][1]['fileName']}   ${jpgfile}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][0]['attachments'][1]['fileType']}   ${fileType5}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][0]['attachments'][1]['caption']}    ${caption4}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][1]['idTypes']}                      ${idTypes[2]}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][1]['attachments'][0]['owner']}      ${provider_id}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][1]['attachments'][0]['fileName']}   ${jpgfile}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][1]['attachments'][0]['fileType']}   ${fileType5}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][1]['attachments'][1]['owner']}      ${provider_id}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][1]['attachments'][1]['fileName']}   ${jpgfile}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][1]['attachments'][1]['fileType']}   ${fileType5}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][1]['attachments'][1]['caption']}    ${caption6}
    
    ${dob1}=    FakerLibrary.Date
    ${relationName1}=    FakerLibrary.First Name
    ${idValue1}=    FakerLibrary.Word
    ${fileName1}=    FakerLibrary.File Name
    ${fileSize1}=    FakerLibrary.Binary
    ${caption1}=    FakerLibrary.Text
    ${resp}=  db.getType   ${jpegfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${jpegfile}
    Set Suite Variable    ${fileType1}
    ${permanentAddress1}=    FakerLibrary.Address
    ${permanentCity1}=    FakerLibrary.City
    ${permanentState1}=    FakerLibrary.State
    ${panNumber1}=  FakerLibrary.Credit Card Number
    # ${attachments1}=     Create List

    ${caption11}=  Fakerlibrary.Sentence
    Set Suite Variable   ${caption6}
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType6}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType6}
    ${list13}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption11}     fileType=${fileType6}   order=${order}
    # ${caption4}=  Fakerlibrary.Sentence
    # ${resp}=  db.getType   ${jpgfile}
    # Log  ${resp}
    # ${caption5}=  Fakerlibrary.Sentence
    # ${list14}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00223    caption=${caption4}     fileType=${fileType5}   order=${order}
    # ${list15}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00678     caption=${caption5}     fileType=${fileType5}   order=${order}

    ${list}=   Create List     ${list13}   
    ${valida1}=    Create Dictionary    idTypes=${idTypes[0]}     idValue=${idValue}    attachments=${list}
   
    # ${caption5}=  Fakerlibrary.Sentence
    # ${resp}=  db.getType   ${jpgfile}
    # Log  ${resp}

    ${list17}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption5}     fileType=${fileType5}   order=${order}
    ${caption12}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}

    ${list14}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption12}     fileType=${fileType5}   order=${order}
  
    ${list}=   Create List     ${list17}   ${list14} 
    ${valida2}=    Create Dictionary    idTypes=${idTypes[2]}     idValue=${idValue}    attachments=${list}
    ${validationId1}=    Create List    ${valida1}    ${valida2}
    Set Suite Variable    ${validationId1}

    ${resp}=  Update KYC    ${id}       ${en_uid9}        ${customerName}    ${dob1}        ${relationType[1]}    ${relationName1}    ${telephoneType[2]}    ${phoneNo}  ${validationId1}     ${provider_id}    ${fileName1}    0.0054    ${caption1}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress1}    ${permanentCity1}    ${permanentState1}    ${permanentPinCode}    ${panNumber1}    ${bool[1]}    customer=${pcid15}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    # ${resp}=  Update KYC    ${id}    ${originFrom}    ${leUid7}        ${customerName}    ${dob1}        ${relationType[1]}    ${relationName1}    ${telephoneType[2]}    ${phoneNo}  ${validationId}      ${provider_id}    ${fileName1}    0.0054    ${caption1}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress1}    ${permanentCity1}    ${permanentState1}    ${permanentPinCode}    ${panNumber1}    ${bool[1]}    customer=${pcid15}
    # Log   ${resp.json()}
    # Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=    Get KYC    ${en_uid9}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable   ${id}        ${resp.json()[0]['id']}
    # Set Test Variable        ${id}
    Should Be Equal As Strings      ${resp.json()[0]['originFrom']}  ${originFrom[1]}
    Should Be Equal As Strings      ${resp.json()[0]['originUid']}  ${en_uid9}
    Should Be Equal As Strings      ${resp.json()[0]['customerName']}  ${customerName}
    Should Be Equal As Strings      ${resp.json()[0]['customer']}  ${pcid15}
    Should Be Equal As Strings      ${resp.json()[0]['relationName']}  ${relationName1}
    Should Be Equal As Strings      ${resp.json()[0]['permanentAddress']}  ${permanentAddress1}
    Should Be Equal As Strings      ${resp.json()[0]['permanentCity']}  ${permanentCity1}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][0]['idTypes']}                      ${idTypes[0]}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][0]['attachments'][0]['owner']}      ${provider_id}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][0]['attachments'][0]['fileName']}   ${jpgfile}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][0]['attachments'][0]['fileType']}   ${fileType6}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][0]['attachments'][0]['caption']}    ${caption11}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][1]['idTypes']}                      ${idTypes[2]}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][1]['attachments'][0]['owner']}      ${provider_id}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][1]['attachments'][0]['fileName']}   ${jpgfile}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][1]['attachments'][0]['fileType']}   ${fileType5}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][1]['attachments'][1]['owner']}      ${provider_id}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][1]['attachments'][1]['fileName']}   ${jpgfile}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][1]['attachments'][1]['fileType']}   ${fileType5}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][1]['attachments'][1]['caption']}    ${caption12}
    
JD-TC-UpdateKyc-8
    [Documentation]  Create a  Kyc and Update Kyc with Another Lead id.

    ${resp}=   Encrypted Provider Login  ${BUSER_U1}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${provider_id}  ${decrypted_data['id']}

   clear_customer   ${HLPUSERNAME5}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME15}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME15}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${pcid15}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${pcid15}  ${resp.json()[0]['id']}
    END

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME15}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable    ${phoneNo}   ${resp.json()[0]['phoneNo']}

    
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


    updateEnquiryStatus  ${account_id}
    sleep  01s

    ${resp}=  enquiryTemplate  ${account_id}  ${en_temp_name}  ${enq_sts_new_id}  creator_provider_id=${provider_id} 

    ${resp}=  Get Enquiry Template
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Provider Enquiry Category  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${en_catagories}=  Set Variable  ${resp.json()}
    ${random_catagories}=  Evaluate  random.choice($en_catagories)  random
    ${rand_catagory_id}=  Set Variable  ${random_catagories['id']}
    ${rand_catagory_name}=  Set Variable  ${random_catagories['name']}

    ${category}=  Create Dictionary   id=${rand_catagory_id}         

    ${resp}=  Create Enquiry  ${locId}  ${pcid15}  category=${category}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${en_id9}        ${resp.json()['id']}
    Set Suite Variable   ${en_uid9}        ${resp.json()['uid']}

    ${resp}=  Get Enquiry by Uuid  ${en_uid9}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}   ${en_id9}
    Should Be Equal As Strings  ${resp.json()['uid']}   ${en_uid9}
    Should Be Equal As Strings  ${resp.json()['accountId']}   ${account_id}

    ${resp}=  Get Provider Enquiry Status  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}  Get Length  ${resp.json()}
    FOR   ${i}  IN RANGE   ${len}
        Set Test Variable  ${status_id${i}}    ${resp.json()[${i}]['id']}
        Set Test Variable  ${status_name${i}}  ${resp.json()[${i}]['name']}
    END

    ${resp}=  Get Enquiry by Uuid  ${en_uid9}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${status_id0}    ${resp.json()['status']['id']}

    ${resp}=  Update and Proceed Enquiry to Status  ${en_uid9}  ${status_id0}  ${locId}  ${pcid15}  &{resp.json()}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Get Enquiry by Uuid  ${en_uid9}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id1}
    Should Be Equal As Strings    ${resp.json()['status']['name']}  ${status_name1}
  
    ${resp}=  Update and Proceed Enquiry to Status  ${en_uid9}  ${status_id1}  ${locId}  ${pcid15}  &{resp.json()}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
  
    ${resp}=  Get Enquiry by Uuid  ${en_uid9}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id2}
    Should Be Equal As Strings    ${resp.json()['status']['name']}  ${status_name2}
  
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
    ${permanentAddress}=    FakerLibrary.Address
    ${permanentCity}=    FakerLibrary.City
    ${permanentState}=    FakerLibrary.State
    ${panNumber}=  FakerLibrary.Credit Card Number
    ${attachments}=     Create List

    ${resp}=  Create KYC        ${en_uid9}      ${customerName}    ${dob}        ${relationType[1]}    ${relationName}    ${telephoneType[2]}    ${phoneNo}  ${attachments}      ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress}    ${permanentCity}    ${permanentState}    ${permanentPinCode}    ${panNumber}    ${bool[1]}    customer= ${pcid15} 
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=    Get KYC    ${en_uid9}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable   ${id}        ${resp.json()[0]['id']}
    # Set Test Variable        ${id}
    Should Be Equal As Strings      ${resp.json()[0]['originFrom']}  ${originFrom[1]}
    Should Be Equal As Strings      ${resp.json()[0]['originUid']}  ${en_uid9}
    Should Be Equal As Strings      ${resp.json()[0]['customerName']}  ${customerName}
    Should Be Equal As Strings      ${resp.json()[0]['customer']}  ${pcid15}
    Should Be Equal As Strings      ${resp.json()[0]['relationName']}  ${relationName}
    Should Be Equal As Strings      ${resp.json()[0]['permanentAddress']}  ${permanentAddress}
    Should Be Equal As Strings      ${resp.json()[0]['permanentCity']}  ${permanentCity}

    ${resp}=  Update KYC    ${id}        ${en_uid9}        ${EMPTY}    ${dob}        ${relationType[1]}    ${relationName}    ${telephoneType[2]}    ${phoneNo}  ${validationId}      ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress}    ${permanentCity}    ${permanentState}    ${permanentPinCode}    ${panNumber}    ${bool[1]}    customer=${pcid15}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=    Get KYC    ${en_uid9}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Should Be Equal As Strings      ${resp.json()[0]['originFrom']}  ${originFrom[1]}
    Should Be Equal As Strings      ${resp.json()[0]['originUid']}  ${en_uid9}
    Should Be Equal As Strings      ${resp.json()[0]['customerName']}  ${EMPTY}
    Should Be Equal As Strings      ${resp.json()[0]['customer']}  ${pcid15}
    Should Be Equal As Strings      ${resp.json()[0]['permanentCity']}  ${permanentCity}




JD-TC-UpdateKyc-UH1
    [Documentation]   Update Kyc without login.

    ${dob1}=    FakerLibrary.Date
    ${relationName1}=    FakerLibrary.First Name
    ${idValue1}=    FakerLibrary.Word
    ${fileName1}=    FakerLibrary.File Name
    ${fileSize1}=    FakerLibrary.Binary
    ${caption1}=    FakerLibrary.Text
    ${resp}=  db.getType   ${jpegfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${jpegfile}
    Set Suite Variable    ${fileType1}
    ${permanentAddress1}=    FakerLibrary.Address
    ${permanentCity1}=    FakerLibrary.City
    ${permanentState1}=    FakerLibrary.State
    ${panNumber1}=  FakerLibrary.Credit Card Number
    ${attachments1}=     Create List
    ${PO_Number4}=  Generate Random Phone Number
    ${PO_Number4}=  Convert To Integer    ${PO_Number4}
    ${resp}=  Update KYC    ${id}       ${en_uid9}        ${customerName}    ${dob1}        ${relationType[1]}    ${relationName1}    ${telephoneType[2]}    ${PO_Number4}  ${validationId}     ${provider_id}    ${fileName1}    0.0054    ${caption1}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress1}    ${permanentCity1}    ${permanentState1}    ${permanentPinCode}    ${panNumber1}    ${bool[1]}    customer=${pcid15}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

JD-TC-UpdateKyc-UH2
    [Documentation]   Update Kyc with consumer login.

    ${resp}=  Consumer Login  ${CUSERNAME17}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${PO_Number4}=  Generate Random Phone Number
    ${PO_Number4}=  Convert To Integer    ${PO_Number4}
    ${dob1}=    FakerLibrary.Date
    ${relationName1}=    FakerLibrary.First Name
    ${idValue1}=    FakerLibrary.Word
    ${fileName1}=    FakerLibrary.File Name
    ${fileSize1}=    FakerLibrary.Binary
    ${caption1}=    FakerLibrary.Text
    ${resp}=  db.getType   ${jpegfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${jpegfile}
    Set Suite Variable    ${fileType1}
    ${permanentAddress1}=    FakerLibrary.Address
    ${permanentCity1}=    FakerLibrary.City
    ${permanentState1}=    FakerLibrary.State
    ${panNumber1}=  FakerLibrary.Credit Card Number
    # ${validationId}=     Create List

    ${resp}=  Update KYC    ${id}        ${en_uid9}        ${customerName}    ${dob1}        ${relationType[1]}    ${relationName1}    ${telephoneType[2]}    ${PO_Number4}  ${validationId}     ${provider_id}    ${fileName1}    0.0054    ${caption1}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress1}    ${permanentCity1}    ${permanentState1}    ${permanentPinCode}    ${panNumber1}    ${bool[1]}    customer=${pcid15}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"   "${NoAccess}"
