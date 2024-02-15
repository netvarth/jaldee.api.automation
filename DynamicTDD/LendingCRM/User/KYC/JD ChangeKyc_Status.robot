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
Variables         /ebs/TDD/varfiles/musers.py
Variables         /ebs/TDD/varfiles/hl_musers.py
Variables         /ebs/TDD/messagesapi.py
Library           /ebs/TDD/excelfuncs.py


*** Keywords ***

Multiple Users branches

    ${resp}=   Get File    /ebs/TDD/varfiles/musers.py
    ${lines}=   Split to lines  ${resp}
    Log   ${lines}
    ${length}=  Get Length   ${lines}
    ${multiuser_list}=  Create List
    &{License_total}=  Create Dictionary
    
    FOR   ${a}  IN RANGE   ${length}   
        ${resp}=  Encrypted Provider Login  ${MUSERNAME${a}}  ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}    200
        
        ${resp1}=   Get Active License
        Log  ${resp1.content}
        Should Be Equal As Strings    ${resp1.status_code}   200
        ${name}=  Set Variable  ${resp1.json()['accountLicense']['displayName']}

        ${resp}=   Get License UsageInfo 
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        IF  ${resp.json()['metricUsageInfo'][8]['total']} > 1 and ${resp.json()['metricUsageInfo'][8]['used']} < ${resp.json()['metricUsageInfo'][8]['total']}
            Append To List  ${multiuser_list}  ${MUSERNAME${a}}
            Set To Dictionary 	${License_total} 	${name}=${resp.json()['metricUsageInfo'][8]['total']}
        END
    END

    RETURN  ${multiuser_list}

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

@{emptylist}
${order}    0

${permanentPinCode}    679581
${customerName}    Hisham
${customerName1}    Sreekanth
${customerName2}    Amal

${task_temp_name1}   Follow Up 1
${task_temp_name2}   Follow Up 2
${en_temp_name}   EnquiryName


*** Test Cases ***

# rrhf

#     ${wb}=  readWorkbook  ${xlFile}
#     ${sheet1}  GetCurrentSheet   ${wb}
#     Set Suite Variable   ${sheet1}
#     ${colnames}=  getColumnHeaders  ${sheet1}
#     Log List  ${colnames}
#     Log List  ${QnrChannel}
#     Log List  ${QnrTransactionType}
#     Set Suite Variable   ${colnames}
#     ${leadnames}   getColumnValuesByName  ${sheet1}  ${colnames[6]}
#     Log   ${leadnames}
#     Remove Values From List  ${leadnames}   ${NONE}
#     Log  ${leadnames}
#     ${unique_lnames}=    Remove Duplicates    ${leadnames}
#     Log  ${unique_lnames}
#     Set Suite Variable   ${unique_lnames}


#     ${resp}=  Consumer Login  ${CUSERNAME14}  ${PASSWORD} 
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200 
#     Set Suite Variable  ${fname}   ${resp.json()['firstName']}
#     Set Suite Variable  ${lname}   ${resp.json()['lastName']}

#     ${resp}=  Consumer Logout
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
    
#     ${resp}=   Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD} 
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

#     ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME14}  
#     Log  ${resp.content}
#     Should Be Equal As Strings      ${resp.status_code}  200
#     IF   '${resp.content}' == '${emptylist}'
#         ${resp1}=  AddCustomer  ${CUSERNAME14}  firstName=${fname}   lastName=${lname}
#         Log  ${resp1.content}
#         Should Be Equal As Strings  ${resp1.status_code}  200
#         Set Test Variable  ${pcid14}   ${resp1.json()}
#     ELSE
#         Set Test Variable  ${pcid14}  ${resp.json()[0]['id']}
        
#     END

#     ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME14}  
#     Log  ${resp.content}
#     Should Be Equal As Strings      ${resp.status_code}  200
#     Set Test Variable    ${phoneNo}   ${resp.json()[0]['phoneNo']}


#     #  ${resp}=    Get Lead Status
#     # Log   ${resp.content}
#     # Should Be Equal As Strings  ${resp.status_code}  200
#     # Set Suite Variable  ${status_Lid}    ${resp.json()[0]['id']}
#     # Set Suite Variable  ${status_Lid1}    ${resp.json()[1]['id']}
#     # Set Suite Variable  ${status_Lid2}    ${resp.json()[2]['id']}
#     # Set Suite Variable  ${status_Lid3}    ${resp.json()[3]['id']}
#     # Set Suite Variable  ${status_Lid4}    ${resp.json()[4]['id']}
#     # Set Suite Variable  ${status_Lid5}    ${resp.json()[5]['id']}
#     # Set Suite Variable  ${status_id6}    ${resp.json()[6]['id']}
#     # Set Suite Variable  ${status_id7}    ${resp.json()[7]['id']}
#     # Set Suite Variable  ${status_id8}    ${resp.json()[8]['id']}
#     # Set Suite Variable  ${status_id9}    ${resp.json()[9]['id']}
#     # Set Suite Variable  ${status_id10}    ${resp.json()[10]['id']}
#     # Set Suite Variable  ${statusName_id6}    ${resp.json()[5]['name']}

#     updateEnquiryStatus  ${account_id}
#     sleep  01s


#     # enquiryTemplate(account_id,category_id=0,priority_id=5,type_id=0)
#     ${resp}=  enquiryTemplate  ${account_id}  ${en_temp_name}  ${enq_sts_new_id}  creator_provider_id=${provider_id}  

#     ${resp}=  Get Enquiry Template
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Create Enquiry  ${locId}  ${pcid14}    
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable   ${en_id}        ${resp.json()['id']}
#     Set Test Variable   ${en_uid}        ${resp.json()['uid']}

#     ${resp}=  Get Enquiry by Uuid  ${en_uid}  
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings  ${resp.json()['id']}   ${en_id}
#     Should Be Equal As Strings  ${resp.json()['uid']}   ${en_uid}
#     Should Be Equal As Strings  ${resp.json()['accountId']}   ${account_id}

#     ${resp}=  Get Provider Enquiry Status  
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${len}  Get Length  ${resp.json()}
#     FOR   ${i}  IN RANGE   ${len}
#         Set Test Variable  ${status_id${i}}    ${resp.json()[${i}]['id']}
#         Set Test Variable  ${status_name${i}}  ${resp.json()[${i}]['name']}
#     END

#     ${resp}=  Get Enquiry by Uuid  ${en_uid}  
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}   200
#     Set Test Variable  ${status_id0}    ${resp.json()['status']['id']}

#     ${resp}=  Update and Proceed Enquiry to Status  ${en_uid}  ${status_id0}  ${locId}  ${pcid14}  &{resp.json()}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}   200

#     ${resp}=  Get Enquiry by Uuid  ${en_uid}  
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}   200
#     Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id1}
#     Should Be Equal As Strings    ${resp.json()['status']['name']}  ${status_name1}
  
#     ${resp}=  Update and Proceed Enquiry to Status  ${en_uid}  ${status_id1}  ${locId}  ${pcid14}  &{resp.json()}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}   200
  
#     ${resp}=  Get Enquiry by Uuid  ${en_uid}  
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}   200
#     Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id2}
#     Should Be Equal As Strings    ${resp.json()['status']['name']}  ${status_name2}
  

#     ${resp}=    Get Provider Tasks
#     Log   ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200


#     ${dob}=    FakerLibrary.Date
#     ${relationName}=    FakerLibrary.First Name
#     ${idValue}=    FakerLibrary.Word
#     ${fileName}=    FakerLibrary.File Name
#     ${fileSize}=    FakerLibrary.Binary
#     ${caption}=    FakerLibrary.Text
#     ${resp}=  db.getType   ${jpegfile}
#     Log  ${resp}
#     ${fileType}=  Get From Dictionary       ${resp}    ${jpegfile}
#     Set Suite Variable    ${fileType}
#     ${permanentAddress}=    FakerLibrary.Word
#     ${permanentCity}=    FakerLibrary.City
#     ${permanentState}=    FakerLibrary.State
#     ${panNumber}=  FakerLibrary.Credit Card Number
#     ${caption3}=  Fakerlibrary.Sentence
    
#     ${resp}=  db.getType   ${pdffile}
#     Log  ${resp}
#     ${fileType2}=  Get From Dictionary       ${resp}    ${pdffile}
#     Set Suite Variable    ${fileType2}
#     ${resp}=  db.getType   ${jpgfile}
#     Log  ${resp}
#     ${fileType5}=  Get From Dictionary       ${resp}    ${jpgfile}
#     Set Suite Variable    ${fileType5}
#     ${list13}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption3}     fileType=${fileType5}   order=${order}
#     ${list}=   Create List         ${list13}
#     ${valida1}=    Create Dictionary    idTypes=${idTypes}     idValue=${idValue}    attachments=${list}
   
#     ${caption5}=  Fakerlibrary.Sentence
#     ${list1}=  Create Dictionary         owner=${provider_id}   fileName=${pdffile}    fileSize= 0.00458     caption=${caption5}     fileType=${fileType2}   order=${order}  
#     ${list}=   Create List       ${list1}
#     ${valida2}=    Create Dictionary    idTypes=UID     idValue=${idValue}    attachments=${list}
#     ${validationId}=    Create List    ${valida1}    ${valida2}
#     Set Suite Variable    ${validationId} 
    
#     ${resp}=  Create KYC        ${en_uid}        ${customerName}    ${dob}        ${relationType[0]}    ${relationName}    ${telephoneType}    ${phoneNo}     ${validationId}      ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress}    ${permanentCity}   ${states[0]}    ${permanentPinCode}    ${panNumber}    ${bool[1]}   customer=${pcid14} 
#     Log   ${resp.json()}
#     Should Be Equal As Strings      ${resp.status_code}  200

#     ${resp}=    Get KYC    ${en_uid}
#     Log   ${resp.content}
#     Should Be Equal As Strings      ${resp.status_code}  200
#     Set Suite Variable   ${idkyc}        ${resp.json()[0]['id']}
#     Should Be Equal As Strings      ${resp.json()[0]['originFrom']}  ${originFrom}
#     Should Be Equal As Strings      ${resp.json()[0]['originUid']}  ${en_uid}
#     Should Be Equal As Strings      ${resp.json()[0]['customerName']}  ${customerName}
#     Should Be Equal As Strings      ${resp.json()[0]['customer']}  ${pcid14}
#     Should Be Equal As Strings      ${resp.json()[0]['relationName']}  ${relationName}
#     Should Be Equal As Strings      ${resp.json()[0]['permanentAddress']}  ${permanentAddress}
#     Should Be Equal As Strings      ${resp.json()[0]['permanentCity']}  ${permanentCity}
   
#     ${resp}=  Get Enquiry by Uuid  ${en_uid}  
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}   200
#     Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id2}
#     Should Be Equal As Strings    ${resp.json()['status']['name']}  ${status_name2}
#     Set Suite Variable   ${stauslead1}        ${resp.json()['internalStatus']}


#     ${resp}=  Change KYC Status     ${en_uid}      ${status_id2}          
#     Log   ${resp.json()}
#     Should Be Equal As Strings      ${resp.status_code}  200

#     ${resp}=    Get KYC    ${en_uid}
#     Log   ${resp.content}
#     Should Be Equal As Strings      ${resp.status_code}  200

#     ${resp}=  Get Enquiry by Uuid  ${en_uid}  
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}   200
#     # Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id2}
#     # Should Be Equal As Strings    ${resp.json()['status']['name']}  ${status_name2}
#     # Set Suite Variable   ${stauslead1}        ${resp.json()['internalStatus']}
   
    
#     ${resp}=    Get Leads With Filter    originUid-eq=${en_uid}
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
    
#     ${resp}=    Get Leads With Filter    
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     # ${resp}=    Get Leads   
#     # Log   ${resp.json()}
#     # Should Be Equal As Strings      ${resp.status_code}  200
#     # Set Suite Variable   ${phoneNo}        ${resp.json()['customer']['phoneNo']}
#     # Should Be Equal As Strings      ${resp.json()['status']['id']}  ${status_id}
   
#     # ${title3}=  FakerLibrary.user name
#     # ${desc}=   FakerLibrary.word 
#     # ${targetPotential}=    FakerLibrary.Building Number
#     # Set Suite Variable  ${targetPotential}
#     # ${category}=    Create Dictionary   id=${category_id1}

#     # ${resp}=    Create Lead    ${title3}    ${desc}    ${targetPotential}      ${locId}    ${pcid14}   category=${category}
#     # Log  ${resp.content}
#     # Should Be Equal As Strings  ${resp.status_code}  200
#     # Set Suite Variable   ${leid1}        ${resp.json()['id']}
#     # Set Suite Variable   ${leUid1}        ${resp.json()['uid']}
   
#     # ${resp}=    Get Lead By Id    ${en_uid}
#     # Log   ${resp.json()}
#     # Should Be Equal As Strings      ${resp.status_code}  200
#     # Set Suite Variable   ${phoneNo}        ${resp.json()['customer']['phoneNo']}
#     # Should Be Equal As Strings      ${resp.json()['status']['id']}  ${status_id}
   

#     ${dob}=    FakerLibrary.Date
#     ${relationName1}=    FakerLibrary.Last Name
#     ${idValue}=    FakerLibrary.Name
#     ${fileName}=    FakerLibrary.File Name
#     ${fileSize}=    FakerLibrary.Binary
#     ${caption}=    FakerLibrary.Text
#     ${resp}=  db.getType   ${jpegfile}
#     Log  ${resp}
#     ${fileType}=  Get From Dictionary       ${resp}    ${jpegfile}
#     Set Suite Variable    ${fileType}
#     ${permanentAddress1}=    FakerLibrary.Address
#     ${permanentCity1}=    FakerLibrary.City
#     ${permanentState1}=    FakerLibrary.State
#     ${panNumber1}=  FakerLibrary.Credit Card Number
 
#     ${resp}=  Update KYC    ${idkyc}        ${en_uid}       ${customerName}    ${dob}        ${relationType[0]}    ${relationName1}    ${telephoneType}    ${phoneNo}   ${validationId}      ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress1}    ${permanentCity1}    ${states[0]}    ${permanentPinCode}    ${panNumber1}    ${bool[1]}    customer=${pcid14}
#     Log   ${resp.json()}
#     Should Be Equal As Strings      ${resp.status_code}  200
   
#     ${resp}=  Get Enquiry by Uuid  ${en_uid}  
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}   200

#     ${resp}=    Get KYC    ${en_uid}
#     Log   ${resp.content}
#     Should Be Equal As Strings      ${resp.status_code}  200
#     Should Be Equal As Strings      ${resp.json()[0]['originFrom']}  ${originFrom}
#     Should Be Equal As Strings      ${resp.json()[0]['originUid']}  ${en_uid}
#     Should Be Equal As Strings      ${resp.json()[0]['customerName']}  ${customerName}
#     Should Be Equal As Strings      ${resp.json()[0]['customer']}  ${pcid14}
#     Should Be Equal As Strings      ${resp.json()[0]['permanentAddress']}  ${permanentAddress1}
#     Should Be Equal As Strings      ${resp.json()[0]['permanentCity']}  ${permanentCity1}


#     ${resp}=    Get Leads With Filter    originUid-eq=${en_uid}
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
    
JD-TC-ChangeKyc_Status-1
    [Documentation]  Create a  Kyc and Change it Status.

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

    ${resp}=   Encrypted Provider Login  ${HLMUSERNAME9}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${provider_id}  ${decrypted_data['id']}
    ${resp}=   Get Active License
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_customer   ${HLMUSERNAME9}

    ${resp}=   Get License UsageInfo 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

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
    END
    FOR   ${i}  IN RANGE   0   ${len}
        Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
        IF   not '${user_phone}' == '${HLMUSERNAME9}'
            clear_users  ${user_phone}
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
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ELSE
        Set Suite Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END

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

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME18}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable    ${phoneNo}   ${resp.json()[0]['phoneNo']}


    # ${resp}=  categorytype  ${provider_id}
    # ${resp}=  tasktype      ${provider_id}
   
    updateEnquiryStatus  ${account_id}
    sleep  01s

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

    ${resp}=  Create Enquiry  ${locId}  ${pcid18}  category=${category}
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
    ${valida1}=    Create Dictionary    idTypes=${idTypes[1]}     idValue=${idValue}    attachments=${list}
   
    ${caption5}=  Fakerlibrary.Sentence
    ${list1}=  Create Dictionary         owner=${provider_id}   fileName=${pdffile}    fileSize= 0.00458     caption=${caption5}     fileType=${fileType2}   order=${order}  
    ${list}=   Create List       ${list1}
    ${valida2}=    Create Dictionary    idTypes=UID     idValue=${idValue}    attachments=${list}
    ${validationId}=    Create List    ${valida1}    ${valida2}
    Set Suite Variable    ${validationId} 
    
    ${resp}=  Create KYC        ${en_uid}        ${customerName}    ${dob}        ${relationType[0]}    ${relationName}    ${telephoneType[0]}    ${phoneNo}     ${validationId}      ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress}    ${permanentCity}   ${states[0]}    ${permanentPinCode}    ${panNumber}    ${bool[1]}   customer=${pcid18} 
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=    Get KYC    ${en_uid}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable   ${id}        ${resp.json()[0]['id']}
    Should Be Equal As Strings      ${resp.json()[0]['originFrom']}  ${originFrom[1]}
    Should Be Equal As Strings      ${resp.json()[0]['originUid']}  ${en_uid}
    Should Be Equal As Strings      ${resp.json()[0]['customerName']}  ${customerName}
    Should Be Equal As Strings      ${resp.json()[0]['customer']}  ${pcid18}
    Should Be Equal As Strings      ${resp.json()[0]['relationName']}  ${relationName}
    Should Be Equal As Strings      ${resp.json()[0]['permanentAddress']}  ${permanentAddress}
    Should Be Equal As Strings      ${resp.json()[0]['permanentCity']}  ${permanentCity}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][0]['attachments'][0]['owner']}      ${provider_id}
   
    ${dob}=    FakerLibrary.Date
    ${relationName1}=    FakerLibrary.Last Name
    ${idValue}=    FakerLibrary.Word
    ${fileName}=    FakerLibrary.File Name
    ${fileSize}=    FakerLibrary.Binary
    ${caption}=    FakerLibrary.Text
    ${resp}=  db.getType   ${jpegfile}
    Log  ${resp}
    # ${fileType}=  Get From Dictionary       ${resp}    ${jpegfile}
    # Set Suite Variable    ${fileType}
    ${permanentAddress1}=    FakerLibrary.Address
    ${permanentCity1}=    FakerLibrary.City
    ${permanentState1}=    FakerLibrary.State
    ${panNumber1}=  FakerLibrary.Credit Card Number

    ${resp}=  Update KYC    ${id}        ${en_uid}        ${customerName}    ${dob}        ${relationType[0]}    ${relationName1}    ${telephoneType[0]}    ${phoneNo}   ${validationId}      ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress1}    ${permanentCity1}    ${states[0]}    ${permanentPinCode}    ${panNumber1}    ${bool[1]}    customer=${pcid18}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200


    ${resp}=    Get KYC    ${en_uid}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Should Be Equal As Strings      ${resp.json()[0]['originFrom']}                                        ${originFrom[1]}
    Should Be Equal As Strings      ${resp.json()[0]['originUid']}                                         ${en_uid}
    Should Be Equal As Strings      ${resp.json()[0]['customerName']}                                      ${customerName}
    Should Be Equal As Strings      ${resp.json()[0]['customer']}                                          ${pcid18}
    Should Be Equal As Strings      ${resp.json()[0]['permanentAddress']}                                  ${permanentAddress1}
    Should Be Equal As Strings      ${resp.json()[0]['permanentCity']}                                     ${permanentCity1}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][0]['attachments'][0]['owner']}      ${provider_id}
   
    ${resp}=  Get Enquiry by Uuid  ${en_uid}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id2}
    Should Be Equal As Strings    ${resp.json()['status']['name']}  ${status_name2}
  
    ${resp}=  Change KYC Status        ${en_uid}  ${status_id2}     
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

JD-TC-ChangeKyc_Status-2
    [Documentation]  Create a  Kyc with Co-Applicant and Change it Status.

    ${resp}=   Encrypted Provider Login  ${HLMUSERNAME9}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_customer   ${HLMUSERNAME9}

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

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME18}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable    ${phoneNo}   ${resp.json()[0]['phoneNo']}


    ${resp}=  categorytype  ${provider_id}
    ${resp}=  tasktype      ${provider_id}
   
    updateEnquiryStatus  ${account_id}
    sleep  01s

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

    ${resp}=  Create Enquiry  ${locId}  ${pcid18}  category=${category}
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

    ${resp}=  Update and Proceed Enquiry to Status  ${en_uid2}  ${status_id0}  ${locId}  ${pcid18}  &{resp.json()}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Get Enquiry by Uuid  ${en_uid2}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id1}
    Should Be Equal As Strings    ${resp.json()['status']['name']}  ${status_name1}
  
    ${resp}=  Update and Proceed Enquiry to Status  ${en_uid2}  ${status_id1}  ${locId}  ${pcid18}  &{resp.json()}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
  
    ${resp}=  Get Enquiry by Uuid  ${en_uid2}  
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
    ${valida1}=    Create Dictionary    idTypes=${idTypes[1]}     idValue=${idValue}    attachments=${list}
   
    ${caption5}=  Fakerlibrary.Sentence
    ${list1}=  Create Dictionary         owner=${provider_id}   fileName=${pdffile}    fileSize= 0.00458     caption=${caption5}     fileType=${fileType2}   order=${order}  
    ${list}=   Create List       ${list1}
    ${valida2}=    Create Dictionary    idTypes=UID     idValue=${idValue}    attachments=${list}
    ${validationId}=    Create List    ${valida1}    ${valida2}
    Set Suite Variable    ${validationId} 
    
    ${resp}=  Create KYC        ${en_uid2}        ${customerName}    ${dob}        ${relationType[0]}    ${relationName}    ${telephoneType[0]}    ${phoneNo}     ${validationId}      ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress}    ${permanentCity}   ${states[0]}    ${permanentPinCode}    ${panNumber}    ${bool[1]}   customer=${pcid18} 
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    
    ${resp}=    Get KYC    ${en_uid2}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable   ${id}        ${resp.json()[0]['id']}
    Should Be Equal As Strings      ${resp.json()[0]['originFrom']}  ${originFrom[1]}
    Should Be Equal As Strings      ${resp.json()[0]['originUid']}  ${en_uid2}
    Should Be Equal As Strings      ${resp.json()[0]['customerName']}  ${customerName}
    Should Be Equal As Strings      ${resp.json()[0]['customer']}  ${pcid18}
    Should Be Equal As Strings      ${resp.json()[0]['relationName']}  ${relationName}
    Should Be Equal As Strings      ${resp.json()[0]['permanentAddress']}  ${permanentAddress}
    Should Be Equal As Strings      ${resp.json()[0]['permanentCity']}  ${permanentCity}
    
    ${resp}=  Get Enquiry by Uuid  ${en_uid2}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id2}
    Should Be Equal As Strings    ${resp.json()['status']['name']}  ${status_name2}
  

    ${resp}=  Change KYC Status      ${en_uid2}   ${status_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

   
JD-TC-ChangeKyc_Status-3
    [Documentation]  Create a  Kyc two times and Change it status.

    ${resp}=   Encrypted Provider Login  ${HLMUSERNAME9}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    clear_customer   ${HLMUSERNAME9}

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

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME18}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable    ${phoneNo}   ${resp.json()[0]['phoneNo']}


    ${resp}=  categorytype  ${provider_id}
    ${resp}=  tasktype      ${provider_id}
   
    updateEnquiryStatus  ${account_id}
    sleep  01s

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

    ${resp}=  Create Enquiry  ${locId}  ${pcid18}  category=${category}
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

    ${resp}=  Update and Proceed Enquiry to Status  ${en_uid3}  ${status_id0}  ${locId}  ${pcid18}  &{resp.json()}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Get Enquiry by Uuid  ${en_uid3}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id1}
    Should Be Equal As Strings    ${resp.json()['status']['name']}  ${status_name1}
  
    ${resp}=  Update and Proceed Enquiry to Status  ${en_uid3}  ${status_id1}  ${locId}  ${pcid18}  &{resp.json()}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
  
    ${resp}=  Get Enquiry by Uuid  ${en_uid3}  
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
    ${valida1}=    Create Dictionary    idTypes=${idTypes[1]}     idValue=${idValue}    attachments=${list}
   
    ${caption5}=  Fakerlibrary.Sentence
    ${list1}=  Create Dictionary         owner=${provider_id}   fileName=${pdffile}    fileSize= 0.00458     caption=${caption5}     fileType=${fileType2}   order=${order}  
    ${list}=   Create List       ${list1}
    ${valida2}=    Create Dictionary    idTypes=UID     idValue=${idValue}    attachments=${list}
    ${validationId}=    Create List    ${valida1}    ${valida2}
    Set Suite Variable    ${validationId} 
    
    ${resp}=  Create KYC        ${en_uid3}        ${customerName}    ${dob}        ${relationType[0]}    ${relationName}    ${telephoneType[0]}    ${phoneNo}     ${validationId}      ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress}    ${permanentCity}   ${states[0]}    ${permanentPinCode}    ${panNumber}    ${bool[1]}   customer=${pcid18} 
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=  Create KYC        ${en_uid3}      ${customerName}    ${dob}        ${relationType[1]}    ${relationName}    ${telephoneType[0]}    ${phoneNo}   ${validationId}       ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress}    ${permanentCity}    ${states[0]}    ${permanentPinCode}    ${panNumber}    ${bool[1]}    customer= ${pcid18} 
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}   200

    ${resp}=    Get KYC    ${en_uid3}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable   ${id}        ${resp.json()[0]['id']}
    Should Be Equal As Strings      ${resp.json()[0]['originFrom']}  ${originFrom[1]}
    Should Be Equal As Strings      ${resp.json()[0]['originUid']}  ${en_uid3}
    Should Be Equal As Strings      ${resp.json()[0]['customerName']}  ${customerName}
    Should Be Equal As Strings      ${resp.json()[0]['customer']}  ${pcid18}
    Should Be Equal As Strings      ${resp.json()[0]['relationName']}  ${relationName}
    Should Be Equal As Strings      ${resp.json()[0]['permanentAddress']}  ${permanentAddress}
    Should Be Equal As Strings      ${resp.json()[0]['permanentCity']}  ${permanentCity}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][0]['attachments'][0]['owner']}      ${provider_id}
    
   
    ${resp}=  Get Enquiry by Uuid  ${en_uid3}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id2}
    Should Be Equal As Strings    ${resp.json()['status']['name']}  ${status_name2}
  
    ${resp}=  Change KYC Status       ${en_uid3}    ${status_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=    Get KYC    ${en_uid3}    
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Should Be Equal As Strings      ${resp.json()[0]['originFrom']}  ${originFrom[1]}
    Should Be Equal As Strings      ${resp.json()[0]['originUid']}  ${en_uid3}

   
JD-TC-ChangeKyc_Status-4
    [Documentation]  Create Kyc With three Attachment then change it's status.

    ${resp}=   Encrypted Provider Login  ${HLMUSERNAME9}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    clear_customer   ${HLMUSERNAME9}

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

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME18}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable    ${phoneNo}   ${resp.json()[0]['phoneNo']}


    ${resp}=  categorytype  ${provider_id}
    ${resp}=  tasktype      ${provider_id}
   
    updateEnquiryStatus  ${account_id}
    sleep  01s

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

    ${resp}=  Create Enquiry  ${locId}  ${pcid18}  category=${category}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${en_id4}        ${resp.json()['id']}
    Set Test Variable   ${en_uid4}        ${resp.json()['uid']}

    ${resp}=  Get Enquiry by Uuid  ${en_uid4}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}   ${en_id4}
    Should Be Equal As Strings  ${resp.json()['uid']}   ${en_uid4}
    Should Be Equal As Strings  ${resp.json()['accountId']}   ${account_id}

    ${resp}=  Get Provider Enquiry Status  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}  Get Length  ${resp.json()}
    FOR   ${i}  IN RANGE   ${len}
        Set Test Variable  ${status_id${i}}    ${resp.json()[${i}]['id']}
        Set Test Variable  ${status_name${i}}  ${resp.json()[${i}]['name']}
    END

    ${resp}=  Get Enquiry by Uuid  ${en_uid4}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${status_id0}    ${resp.json()['status']['id']}

    ${resp}=  Update and Proceed Enquiry to Status  ${en_uid4}  ${status_id0}  ${locId}  ${pcid18}  &{resp.json()}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Get Enquiry by Uuid  ${en_uid4}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id1}
    Should Be Equal As Strings    ${resp.json()['status']['name']}  ${status_name1}
  
    ${resp}=  Update and Proceed Enquiry to Status  ${en_uid4}  ${status_id1}  ${locId}  ${pcid18}  &{resp.json()}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
  
    ${resp}=  Get Enquiry by Uuid  ${en_uid4}  
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
    # ${fileType}=  Get From Dictionary       ${resp}    ${jpegfile}
    # Set Suite Variable    ${fileType}
    ${permanentAddress}=    FakerLibrary.Address
    ${permanentCity}=    FakerLibrary.City
    ${permanentState}=    FakerLibrary.State
    ${panNumber}=  FakerLibrary.Credit Card Number


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

    ${caption7}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}

    ${list15}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption7}     fileType=${fileType5}   order=${order}
  
    ${list}=   Create List       ${list15} 
    ${valida3}=    Create Dictionary    idTypes=${idTypes[4]}     idValue=${idValue}    attachments=${list}

    ${validationId}=    Create List    ${valida1}    ${valida2}    ${valida3}
    Set Suite Variable    ${validationId}

    ${resp}=  Create KYC        ${en_uid4}        ${customerName}    ${dob}        ${relationType[0]}    ${relationName}    ${telephoneType[0]}    ${phoneNo}   ${validationId}       ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress}    ${permanentCity}    ${states[0]}    ${permanentPinCode}    ${panNumber}    ${bool[1]}   customer=${pcid18} 
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=    Get KYC    ${en_uid4}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable   ${id}        ${resp.json()[0]['id']}
    Should Be Equal As Strings      ${resp.json()[0]['originFrom']}  ${originFrom[1]}
    Should Be Equal As Strings      ${resp.json()[0]['originUid']}  ${en_uid4}
    Should Be Equal As Strings      ${resp.json()[0]['customerName']}  ${customerName}
    Should Be Equal As Strings      ${resp.json()[0]['customer']}  ${pcid18}
    Should Be Equal As Strings      ${resp.json()[0]['relationName']}  ${relationName}
    Should Be Equal As Strings      ${resp.json()[0]['permanentAddress']}  ${permanentAddress}
    Should Be Equal As Strings      ${resp.json()[0]['permanentCity']}  ${permanentCity}

    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][0]['idTypes']}                      ${idTypes[0]}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][0]['attachments'][0]['owner']}      ${provider_id}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][0]['attachments'][0]['fileName']}   ${jpgfile}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][0]['attachments'][0]['fileType']}   ${fileType5}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][0]['attachments'][0]['caption']}    ${caption3}
    
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][0]['attachments'][1]['owner']}      ${provider_id}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][0]['attachments'][1]['fileName']}   ${jpgfile}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][0]['attachments'][1]['fileType']}   ${fileType5}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][0]['attachments'][1]['caption']}    ${caption4}
    
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][1]['idTypes']}   ${idTypes[2]}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][1]['attachments'][0]['owner']}     ${provider_id}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][1]['attachments'][0]['fileName']}   ${jpgfile}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][1]['attachments'][0]['fileType']}   ${fileType5}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][1]['attachments'][0]['caption']}    ${caption5}
    
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][1]['attachments'][1]['owner']}      ${provider_id}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][1]['attachments'][1]['fileName']}   ${jpgfile}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][1]['attachments'][1]['fileType']}   ${fileType5}
    Should Be Equal As Strings      ${resp.json()[0]['validationIds'][1]['attachments'][1]['caption']}    ${caption6}
    
    ${resp}=  Get Enquiry by Uuid  ${en_uid4}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id2}
    Should Be Equal As Strings    ${resp.json()['status']['name']}  ${status_name2}
  

    ${resp}=  Change KYC Status       ${en_uid4}    ${status_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    

JD-TC-ChangeKyc_Status-UH1
    [Documentation]  Create a  Kyc With Empty Attachment  and Check it status and Update.

    ${resp}=   Encrypted Provider Login  ${HLMUSERNAME9}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    clear_customer   ${HLMUSERNAME9}

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

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME18}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable    ${phoneNo}   ${resp.json()[0]['phoneNo']}


    ${resp}=  categorytype  ${provider_id}
    ${resp}=  tasktype      ${provider_id}
   
    updateEnquiryStatus  ${account_id}
    sleep  01s

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

    ${resp}=  Create Enquiry  ${locId}  ${pcid18}  category=${category}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${en_id5}        ${resp.json()['id']}
    Set Test Variable   ${en_uid5}        ${resp.json()['uid']}

    ${resp}=  Get Enquiry by Uuid  ${en_uid5}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}   ${en_id5}
    Should Be Equal As Strings  ${resp.json()['uid']}   ${en_uid5}
    Should Be Equal As Strings  ${resp.json()['accountId']}   ${account_id}

    ${resp}=  Get Provider Enquiry Status  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}  Get Length  ${resp.json()}
    FOR   ${i}  IN RANGE   ${len}
        Set Test Variable  ${status_id${i}}    ${resp.json()[${i}]['id']}
        Set Test Variable  ${status_name${i}}  ${resp.json()[${i}]['name']}
    END

    ${resp}=  Get Enquiry by Uuid  ${en_uid5}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${status_id0}    ${resp.json()['status']['id']}

    ${resp}=  Update and Proceed Enquiry to Status  ${en_uid5}  ${status_id0}  ${locId}  ${pcid18}  &{resp.json()}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Get Enquiry by Uuid  ${en_uid5}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id1}
    Should Be Equal As Strings    ${resp.json()['status']['name']}  ${status_name1}
  
    ${resp}=  Update and Proceed Enquiry to Status  ${en_uid5}  ${status_id1}  ${locId}  ${pcid18}  &{resp.json()}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
  
    ${resp}=  Get Enquiry by Uuid  ${en_uid5}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id2}
    Should Be Equal As Strings    ${resp.json()['status']['name']}  ${status_name2}
  

    ${resp}=    Get Provider Tasks
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${dob}=    FakerLibrary.Date
    ${dob1}=    FakerLibrary.Date
    ${relationName}=    FakerLibrary.First Name
    ${relationName1}=    FakerLibrary.First Name
    ${idValue}=    FakerLibrary.Word
    ${idValue1}=    FakerLibrary.Word
    ${fileName}=    FakerLibrary.File Name
    ${fileName1}=    FakerLibrary.File Name
    ${fileSize}=    FakerLibrary.Binary
    ${fileSize1}=    FakerLibrary.Binary
    ${caption}=    FakerLibrary.Text
    ${caption1}=    FakerLibrary.Text
    ${resp}=  db.getType   ${jpegfile}
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${jpegfile}
    Set Suite Variable    ${fileType}
    ${permanentAddress}=    FakerLibrary.Address
    ${permanentCity}=    FakerLibrary.City
    ${panNumber}=  FakerLibrary.Credit Card Number
    ${permanentAddress1}=    FakerLibrary.Address
    ${permanentCity1}=    FakerLibrary.City
    ${panNumber1}=  FakerLibrary.Credit Card Number

    ${caption3}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType5}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType5}
    ${list13}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption3}     fileType=${fileType5}   order=${order}
    ${caption4}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
  
    ${list}=   Create List       
    ${valida1}=    Create Dictionary    idTypes=${idTypes[0]}     idValue=${idValue}    attachments=${list}
   
    ${caption5}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}

    ${list1}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption5}     fileType=${fileType5}   order=${order}
    ${caption6}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}

    ${list}=   Create List       
    ${valida2}=    Create Dictionary    idTypes=${idTypes[4]}     idValue=${idValue}    attachments=${list}
    ${validationId}=    Create List    ${valida1}    ${valida2}
    Set Test Variable    ${validationId}

    ${resp}=  Create KYC       ${en_uid5}      ${customerName}    ${dob}        ${relationType[0]}    ${relationName}    ${telephoneType[0]}    ${phoneNo}   ${validationId}       ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress}    ${permanentCity}    ${states[0]}    ${permanentPinCode}    ${panNumber}    ${bool[1]}    customer= ${pcid18}   
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}   200

    ${resp}=    Get KYC    ${en_uid5}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable   ${id}        ${resp.json()[0]['id']}
    Should Be Equal As Strings      ${resp.json()[0]['originFrom']}  ${originFrom[1]}
    Should Be Equal As Strings      ${resp.json()[0]['originUid']}  ${en_uid5}
    Should Be Equal As Strings      ${resp.json()[0]['customerName']}  ${customerName}
    Should Be Equal As Strings      ${resp.json()[0]['customer']}  ${pcid18}
    Should Be Equal As Strings      ${resp.json()[0]['relationName']}  ${relationName}
    Should Be Equal As Strings      ${resp.json()[0]['permanentAddress']}  ${permanentAddress}
    Should Be Equal As Strings      ${resp.json()[0]['permanentCity']}  ${permanentCity}

    # ${ATTACHMENT_MANDATORY}=   Format String  ${ATTACHMENT_MANDATORY}  {}  ${idTypes[0]}
    ${ATTACHMENT_MANDATORY}=  Format String  ${ATTACHMENT_MANDATORY}  ${idTypes_Name[0]}


    ${resp}=  Get Enquiry by Uuid  ${en_uid5}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id2}
    Should Be Equal As Strings    ${resp.json()['status']['name']}  ${status_name2}
  
    ${resp}=  Change KYC Status       ${en_uid5}    ${status_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  422    
    Should Be Equal As Strings      ${resp.json()}    ${ATTACHMENT_MANDATORY}

    ${caption3}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType5}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType5}
    ${list13}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption3}     fileType=${fileType5}   order=${order}
    ${caption4}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
  
    ${list}=   Create List    ${list13}   
    ${valida1}=    Create Dictionary    idTypes=${idTypes[0]}     idValue=${idValue}    attachments=${list}
   
    ${caption5}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}

    ${list1}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption5}     fileType=${fileType5}   order=${order}
    ${caption6}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}

  
    ${list}=   Create List    ${list1}   
    ${valida2}=    Create Dictionary    idTypes=${idTypes[1]}     idValue=${idValue}    attachments=${list}
    ${validationId}=    Create List    ${valida1}    ${valida2}
    Set Test Variable    ${validationId}

    ${resp}=  Update KYC    ${id}        ${en_uid5}        ${customerName}    ${dob}        ${relationType[0]}    ${relationName}    ${telephoneType[0]}    ${phoneNo}   ${validationId}      ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress}    ${permanentCity}    ${states[0]}    ${permanentPinCode}    ${panNumber}    ${bool[1]}    customer=${pcid18}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=  Get Enquiry by Uuid  ${en_uid5}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id2}
    Should Be Equal As Strings    ${resp.json()['status']['name']}  ${status_name2}
  
    ${resp}=  Change KYC Status       ${en_uid5}    ${status_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['status']['id']}  ${status_id6}

    
JD-TC-ChangeKyc_Status-UH2
    [Documentation]  Create a  Kyc With Co-applicant and Check it status and Update permanentPhone to Empty.

    ${resp}=   Encrypted Provider Login  ${HLMUSERNAME9}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    clear_customer   ${HLMUSERNAME9}

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

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME18}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable    ${phoneNo}   ${resp.json()[0]['phoneNo']}


    ${resp}=  categorytype  ${provider_id}
    ${resp}=  tasktype      ${provider_id}
   
    updateEnquiryStatus  ${account_id}
    sleep  01s

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

    ${resp}=  Create Enquiry  ${locId}  ${pcid18}  category=${category}    
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

    ${resp}=  Update and Proceed Enquiry to Status  ${en_uid6}  ${status_id0}  ${locId}  ${pcid18}  &{resp.json()}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Get Enquiry by Uuid  ${en_uid6}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id1}
    Should Be Equal As Strings    ${resp.json()['status']['name']}  ${status_name1}
  
    ${resp}=  Update and Proceed Enquiry to Status  ${en_uid6}  ${status_id1}  ${locId}  ${pcid18}  &{resp.json()}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
  
    ${resp}=  Get Enquiry by Uuid  ${en_uid6}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id2}
    Should Be Equal As Strings    ${resp.json()['status']['name']}  ${status_name2}
  

    ${resp}=    Get Provider Tasks
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${dob}=    FakerLibrary.Date
    ${dob1}=    FakerLibrary.Date
    ${relationName}=    FakerLibrary.First Name
    ${relationName1}=    FakerLibrary.First Name
    ${idValue}=    FakerLibrary.Word
    ${idValue1}=    FakerLibrary.Word
    ${fileName}=    FakerLibrary.File Name
    ${fileName1}=    FakerLibrary.File Name
    ${fileSize}=    FakerLibrary.Binary
    ${fileSize1}=    FakerLibrary.Binary
    ${caption}=    FakerLibrary.Text
    ${caption1}=    FakerLibrary.Text
    ${resp}=  db.getType   ${jpegfile}
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${jpegfile}
    Set Suite Variable    ${fileType}
    ${permanentAddress}=    FakerLibrary.Address
    ${permanentCity}=    FakerLibrary.City
    ${permanentState}=    FakerLibrary.State
    ${panNumber}=  FakerLibrary.Credit Card Number
    ${permanentAddress1}=    FakerLibrary.Address
    ${permanentCity1}=    FakerLibrary.City
    ${permanentState1}=    FakerLibrary.State
    ${panNumber1}=  FakerLibrary.Credit Card Number
    ${PO_Number}=  Generate Random Phone Number
    ${PO_Number}=  Convert To Integer    ${PO_Number}

    ${caption3}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType5}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType5}
    ${list13}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption3}     fileType=${fileType5}   order=${order}
    ${list}=   Create List   ${list13}    
    ${valida1}=    Create Dictionary    idTypes=${idTypes[2]}     idValue=${idValue}    attachments=${list}
   
    ${caption5}=  Fakerlibrary.Sentence
    ${list1}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption5}     fileType=${fileType5}   order=${order}  
    ${list}=   Create List      ${list1} 
    ${valida2}=    Create Dictionary    idTypes=${idTypes[3]}     idValue=${idValue}    attachments=${list}
    ${validationId3}=    Create List    ${valida1}    ${valida2}
    Set Suite Variable    ${validationId3}

    ${resp}=  Create KYC        ${en_uid6}      ${customerName}    ${dob}        ${relationType[0]}    ${relationName}    ${telephoneType[0]}    ${phoneNo}   ${validationId3}       ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress}    ${permanentCity}    ${states[0]}    ${permanentPinCode}    ${panNumber}    ${bool[1]}    customer= ${pcid18} 
    Should Be Equal As Strings      ${resp.status_code}  200

    ${caption3}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType5}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType5}
    ${list13}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption3}     fileType=${fileType5}   order=${order}
    ${list}=   Create List   ${list13}    
    ${valida1}=    Create Dictionary    idTypes=${idTypes[0]}     idValue=${idValue}    attachments=${list}
   
    ${caption5}=  Fakerlibrary.Sentence
    ${list1}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption5}     fileType=${fileType5}   order=${order}  
    ${list}=   Create List      ${list1} 
    ${valida2}=    Create Dictionary    idTypes=${idTypes[1]}     idValue=${idValue}    attachments=${list}
    ${validationId4}=    Create List    ${valida1}    ${valida2}
    Set Suite Variable    ${validationId4}

    ${PO_Number3}=  Generate Random Phone Number
    ${PO_Number3}=  Convert To Integer    ${PO_Number3}

    ${resp}=  Create KYC        ${en_uid6}        ${customerName2}    ${dob1}        ${relationType[2]}    ${relationName1}    ${telephoneType[0]}    ${PO_Number3}   ${validationId4}       ${provider_id}    ${fileName}    0.0054    ${caption1}    ${QnrfileTypes[1]}    ${order}      ${permanentAddress1}    ${permanentCity1}    ${states[0]}    ${permanentPinCode}    ${panNumber1}       ${bool[0]}    parentid=${pcid18}    permanentPhone=${PO_Number}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    
    
    ${resp}=    Get KYC    ${en_uid6}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable   ${id}        ${resp.json()[0]['id']}
    Should Be Equal As Strings      ${resp.json()[0]['originFrom']}  ${originFrom[1]}
    Should Be Equal As Strings      ${resp.json()[0]['originUid']}  ${en_uid6}
    Should Be Equal As Strings      ${resp.json()[0]['customerName']}  ${customerName}
    Should Be Equal As Strings      ${resp.json()[0]['customer']}  ${pcid18}
    Should Be Equal As Strings      ${resp.json()[0]['relationName']}  ${relationName}
    Should Be Equal As Strings      ${resp.json()[0]['permanentAddress']}  ${permanentAddress}
    Should Be Equal As Strings      ${resp.json()[0]['permanentCity']}  ${permanentCity}

    ${resp}=    Get KYC    ${en_uid6}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable   ${id1}        ${resp.json()[1]['id']}
    Should Be Equal As Strings      ${resp.json()[1]['originFrom']}  ${originFrom}[1]
    Should Be Equal As Strings      ${resp.json()[1]['originUid']}  ${en_uid6}
    Should Be Equal As Strings      ${resp.json()[1]['customerName']}  ${customerName2}
    # Should Be Equal As Strings      ${resp.json()[1]['panNumber']}  ${panNumber1}
    Should Be Equal As Strings      ${resp.json()[1]['parentid']['id']}  ${pcid18}
    Should Be Equal As Strings      ${resp.json()[1]['relationName']}  ${relationName1}
    Should Be Equal As Strings      ${resp.json()[1]['permanentAddress']}  ${permanentAddress1}
    Should Be Equal As Strings      ${resp.json()[1]['permanentCity']}  ${permanentCity1}
    
    ${resp}=  Get Enquiry by Uuid  ${en_uid6}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id2}
    Should Be Equal As Strings    ${resp.json()['status']['name']}  ${status_name2}
  
    ${resp}=  Change KYC Status       ${en_uid6}    ${status_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
  
    ${resp}=  Update KYC    ${id1}       ${en_uid6}        ${customerName2}    ${dob}        ${relationType[3]}    ${relationName1}    ${telephoneType[2]}    ${phoneNo}   ${validationId4}      ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress1}    ${permanentCity1}    ${states[2]}    ${permanentPinCode}    ${panNumber1}    ${bool[0]}    parentid=${pcid18}    permanentPhone=${EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}    ${GIVE_VALID_PHONE_NUMBER}


    # ${resp}=    Get KYC    ${leUid7}
    # Log   ${resp.content}
    # Should Be Equal As Strings      ${resp.status_code}  200
    # Should Be Equal As Strings      ${resp.json()[1]['originFrom']}  ${originFrom}
    # Should Be Equal As Strings      ${resp.json()[1]['originUid']}  ${leUid7}
    # Should Be Equal As Strings      ${resp.json()[1]['customerName']}  ${customerName2}
    # Should Be Equal As Strings      ${resp.json()[1]['panNumber']}  ${panNumber1}
    # Should Be Equal As Strings      ${resp.json()[1]['parentid']['id']}  ${pcid18}
    # Should Be Equal As Strings      ${resp.json()[1]['relationName']}  ${relationName1}
    # Should Be Equal As Strings      ${resp.json()[1]['permanentAddress']}  ${permanentAddress1}
    # Should Be Equal As Strings      ${resp.json()[1]['permanentCity']}  ${permanentCity1}
    # Should Be Equal As Strings      ${resp.json()[1]['permanentPhone']}  ${EMPTY}


    # ${resp}=   Get Lead By Id   ${leUid7}    
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['kycCreated']}  ${bool[1]}
    # Should Be Equal As Strings  ${resp.json()['status']['id']}  ${status_id}

    # ${resp}=  Change KYC Status       ${leUid7}    
    # Log   ${resp.json()}
    # Should Be Equal As Strings      ${resp.status_code}  200

    # ${resp}=   Get Lead By Id   ${leUid7}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['kycCreated']}  ${bool[1]}
    # Should Be Equal As Strings  ${resp.json()['status']['id']}  ${status_id6}

JD-TC-ChangeKyc_Status-UH3
    [Documentation]  Create a  Kyc  and Check it status then Updatekyc with empty attachment .again check status.

    ${resp}=   Encrypted Provider Login  ${HLMUSERNAME9}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_customer   ${HLMUSERNAME9}

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

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME18}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable    ${phoneNo}   ${resp.json()[0]['phoneNo']}


    ${resp}=  categorytype  ${provider_id}
    ${resp}=  tasktype      ${provider_id}
   
    updateEnquiryStatus  ${account_id}
    sleep  01s

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

    ${resp}=  Create Enquiry  ${locId}  ${pcid18}  category=${category}    
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

    ${resp}=  Update and Proceed Enquiry to Status  ${en_uid7}  ${status_id0}  ${locId}  ${pcid18}  &{resp.json()}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Get Enquiry by Uuid  ${en_uid7}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id1}
    Should Be Equal As Strings    ${resp.json()['status']['name']}  ${status_name1}
  
    ${resp}=  Update and Proceed Enquiry to Status  ${en_uid7}  ${status_id1}  ${locId}  ${pcid18}  &{resp.json()}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
  
    ${resp}=  Get Enquiry by Uuid  ${en_uid7}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id2}
    Should Be Equal As Strings    ${resp.json()['status']['name']}  ${status_name2}
  

    ${resp}=    Get Provider Tasks
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${dob}=    FakerLibrary.Date
    ${dob1}=    FakerLibrary.Date
    ${relationName}=    FakerLibrary.First Name
    ${relationName1}=    FakerLibrary.First Name
    ${idValue}=    FakerLibrary.Word
    ${idValue1}=    FakerLibrary.Word
    ${fileName}=    FakerLibrary.File Name
    ${fileName1}=    FakerLibrary.File Name
    ${fileSize}=    FakerLibrary.Binary
    ${fileSize1}=    FakerLibrary.Binary
    ${caption}=    FakerLibrary.Text
    ${caption1}=    FakerLibrary.Text
    ${resp}=  db.getType   ${jpegfile}
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${jpegfile}
    Set Suite Variable    ${fileType}
    ${permanentAddress}=    FakerLibrary.Address
    ${permanentCity}=    FakerLibrary.City
    ${permanentState}=    FakerLibrary.State
    ${panNumber}=  FakerLibrary.Credit Card Number
    ${permanentAddress1}=    FakerLibrary.Address
    ${permanentCity1}=    FakerLibrary.City
    ${permanentState1}=    FakerLibrary.State
    ${panNumber1}=  FakerLibrary.Credit Card Number
    ${PO_Number3}=  Generate Random Phone Number
    ${PO_Number3}=  Convert To Integer    ${PO_Number3}


    ${caption3}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType5}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType5}
    ${list13}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption3}     fileType=${fileType5}   order=${order}
    ${caption4}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
  
    ${list}=   Create List       ${list13}
    ${valida1}=    Create Dictionary    idTypes=${idTypes[0]}     idValue=${idValue}    attachments=${list}
   
    ${caption5}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}

    ${list1}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption5}     fileType=${fileType5}   order=${order}
    ${caption6}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}

    ${list}=   Create List       ${list1}
    ${valida2}=    Create Dictionary    idTypes=${idTypes[1]}     idValue=${idValue}    attachments=${list}
    ${validationId1}=    Create List    ${valida1}    ${valida2}
    Set Test Variable    ${validationId1}

    ${resp}=  Create KYC      ${en_uid7}      ${customerName}    ${dob}        ${relationType[0]}    ${relationName}    ${telephoneType[0]}    ${PO_Number3}   ${validationId1}       ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress}    ${permanentCity}    ${states[0]}    ${permanentPinCode}    ${panNumber}    ${bool[1]}    customer= ${pcid18}   
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}   200

    ${resp}=    Get KYC    ${en_uid7}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable   ${id}        ${resp.json()[0]['id']}
    Should Be Equal As Strings      ${resp.json()[0]['originFrom']}  ${originFrom[1]}
    Should Be Equal As Strings      ${resp.json()[0]['originUid']}  ${en_uid7}
    Should Be Equal As Strings      ${resp.json()[0]['customerName']}  ${customerName}
    Should Be Equal As Strings      ${resp.json()[0]['customer']}  ${pcid18}
    Should Be Equal As Strings      ${resp.json()[0]['relationName']}  ${relationName}
    Should Be Equal As Strings      ${resp.json()[0]['permanentAddress']}  ${permanentAddress}
    Should Be Equal As Strings      ${resp.json()[0]['permanentCity']}  ${permanentCity}

    ${resp}=  Get Enquiry by Uuid  ${en_uid7}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id2}
    Should Be Equal As Strings    ${resp.json()['status']['name']}  ${status_name2}
  

    ${resp}=  Change KYC Status       ${en_uid7}    ${status_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['status']['id']}  ${status_id6}

    

    ${PO_Number1}=  Generate Random Phone Number
    ${PO_Number1}=  Convert To Integer    ${PO_Number1}
    ${PO_Number2}=  Generate Random Phone Number
    ${PO_Number2}=  Convert To Integer    ${PO_Number2}

    ${caption3}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType5}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType5}
    ${list13}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption3}     fileType=${fileType5}   order=${order}
    ${list}=   Create List   ${list13}    
    ${valida1}=    Create Dictionary    idTypes=${idTypes[0]}     idValue=${idValue}    attachments=${list}
   
    ${caption5}=  Fakerlibrary.Sentence
    ${list1}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption5}     fileType=${fileType5}   order=${order}  
    ${list}=   Create List      ${list1} 
    ${valida2}=    Create Dictionary    idTypes=${idTypes[1]}     idValue=${idValue}    attachments=${list}
    ${validationId5}=    Create List    ${valida1}    ${valida2}
    Set Test Variable    ${validationId5}

    ${resp}=  Create KYC       ${en_uid7}        ${customerName1}    ${dob1}        ${relationType[2]}    ${relationName1}    ${telephoneType[0]}    ${PO_Number2}   ${validationId5}       ${provider_id}    ${fileName}    0.0054    ${caption1}    ${QnrfileTypes[1]}    ${order}      ${permanentAddress1}    ${permanentCity1}    ${states[0]}    ${permanentPinCode}    ${panNumber1}       ${bool[0]}    parentid=${pcid18}    permanentPhone=${PO_Number1}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=    Get KYC    ${en_uid7}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable   ${id2}        ${resp.json()[1]['id']}

    ${caption3}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType5}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType5}
    ${list13}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption3}     fileType=${fileType5}   order=${order}
    ${list}=   Create List       
    ${valida1}=    Create Dictionary    idTypes=${idTypes[1]}     idValue=${idValue}    attachments=${list}
   
    ${caption5}=  Fakerlibrary.Sentence
    ${list1}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption5}     fileType=${fileType5}   order=${order}  
    ${list}=   Create List       
    ${valida2}=    Create Dictionary    idTypes=${idTypes[4]}     idValue=${idValue}    attachments=${list}
    ${validationId6}=    Create List    ${valida1}    ${valida2}
    Set Suite Variable    ${validationId6}

    ${resp}=  Update KYC    ${id2}        ${en_uid7}        ${customerName}    ${dob}        ${relationType[3]}    ${relationName}    ${telephoneType[2]}    ${phoneNo}   ${validationId6}      ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress}    ${permanentCity}    ${states[4]}    ${permanentPinCode}    ${panNumber}    ${bool[0]}    parentid=${pcid18}    permanentPhone=${PO_Number1}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=    Get KYC    ${en_uid7}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${ATTACHMENT_MANDATORY}=  Format String  ${ATTACHMENT_MANDATORY}   ${idTypes_Name[1]}
    # ${resp}=  Change KYC Status       ${leUid6}    
    # Log   ${resp.json()}
    # Should Be Equal As Strings      ${resp.status_code}  422    
    # Should Be Equal As Strings      ${resp.json()}    ${ATTACHMENT_MANDATORY}
    
    ${resp}=  Get Enquiry by Uuid  ${en_uid7}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id3}
    Should Be Equal As Strings    ${resp.json()['status']['name']}  ${status_name3}
  

    ${resp}=  Change KYC Status       ${en_uid7}    ${status_id3}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}   422
    Should Be Equal As Strings      ${resp.json()}    ${ATTACHMENT_MANDATORY}

 
   

JD-TC-ChangeKyc_Status-UH4
    [Documentation]  Create a  Kyc  with attachment it's idvalue is empty.

    ${resp}=   Encrypted Provider Login  ${HLMUSERNAME9}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

   clear_customer   ${HLMUSERNAME9}

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

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME18}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable    ${phoneNo}   ${resp.json()[0]['phoneNo']}


    ${resp}=  categorytype  ${provider_id}
    ${resp}=  tasktype      ${provider_id}
   
    updateEnquiryStatus  ${account_id}
    sleep  01s

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

    ${resp}=  Create Enquiry  ${locId}  ${pcid18}  category=${category}    
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

    ${resp}=  Update and Proceed Enquiry to Status  ${en_uid8}  ${status_id0}  ${locId}  ${pcid18}  &{resp.json()}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Get Enquiry by Uuid  ${en_uid8}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id1}
    Should Be Equal As Strings    ${resp.json()['status']['name']}  ${status_name1}
  
    ${resp}=  Update and Proceed Enquiry to Status  ${en_uid8}  ${status_id1}  ${locId}  ${pcid18}  &{resp.json()}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
  
    ${resp}=  Get Enquiry by Uuid  ${en_uid8}  
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
    ${permanentAddress}=    FakerLibrary.Address
    ${permanentCity}=    FakerLibrary.City
    ${permanentState}=    FakerLibrary.State
    ${panNumber}=  FakerLibrary.Credit Card Number


    ${caption3}=  Fakerlibrary.Sentence
    Set Suite Variable   ${caption3}
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType5}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType5}
    ${list13}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption3}     fileType=${fileType5}   order=${order}

    ${caption4}=  Fakerlibrary.Sentence
    ${list14}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption4}     fileType=${fileType5}   order=${order}
    ${list}=   Create List     ${list13}   ${list14} 
    ${valida1}=    Create Dictionary    idTypes=${idTypes[0]}     idValue=${EMPTY}    attachments=${list}
   
    ${caption5}=  Fakerlibrary.Sentence
    ${list13}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption5}     fileType=${fileType5}   order=${order}
    ${caption6}=  Fakerlibrary.Sentence
    ${list14}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption6}     fileType=${fileType5}   order=${order}
    ${list}=   Create List     ${list13}   ${list14} 
    ${valida2}=    Create Dictionary    idTypes=${idTypes[2]}     idValue=${EMPTY}    attachments=${list}

    ${validationId}=    Create List    ${valida1}    ${valida2}    
    Set Suite Variable    ${validationId}

    ${resp}=  Create KYC       ${en_uid8}        ${customerName}    ${dob}        ${relationType[0]}    ${relationName}    ${telephoneType[0]}    ${phoneNo}   ${validationId}       ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress}    ${permanentCity}    ${states[0]}    ${permanentPinCode}    ${panNumber}    ${bool[1]}   customer=${pcid18} 
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    # Should Be Equal As Strings      ${resp.json()}  ${PASSPORT_ID_REQUIRED}
    
    ${resp}=    Get KYC    ${en_uid8}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    # Set Suite Variable   ${id}        ${resp.json()[0]['id']}
    Should Be Equal As Strings      ${resp.json()[0]['originFrom']}  ${originFrom[1]}
    Should Be Equal As Strings      ${resp.json()[0]['originUid']}  ${en_uid8}
    Should Be Equal As Strings      ${resp.json()[0]['customerName']}  ${customerName}
    Should Be Equal As Strings      ${resp.json()[0]['customer']}  ${pcid18}
    Should Be Equal As Strings      ${resp.json()[0]['relationName']}  ${relationName}
    Should Be Equal As Strings      ${resp.json()[0]['permanentAddress']}  ${permanentAddress}
    Should Be Equal As Strings      ${resp.json()[0]['permanentCity']}  ${permanentCity}

    ${PASSPORT_ID_REQUIRED}=   Format String  ${PASSPORT_ID_REQUIRED}  {}  Aadhaar
    
    ${resp}=  Get Enquiry by Uuid  ${en_uid8}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id2}
    Should Be Equal As Strings    ${resp.json()['status']['name']}  ${status_name2}
  
    ${resp}=  Change KYC Status       ${en_uid8}    ${status_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  422
    Should Be Equal As Strings      ${resp.json()}   ${PASSPORT_ID_REQUIRED}


   