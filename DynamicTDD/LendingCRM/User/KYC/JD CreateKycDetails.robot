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
Library           /ebs/TDD/excelfuncs.py


*** Keywords ***
Multiple Users branches

    ${resp}=   Get File    /ebs/TDD/varfiles/musers.py
    ${len}=   Split to lines  ${resp}
    ${length}=  Get Length   ${len}
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

${jpgfile}      /ebs/TDD/uploadimage.jpg
${pngfile}      /ebs/TDD/upload.png
${pdffile}      /ebs/TDD/sample.pdf
${giffile}     /ebs/TDD/sample.gif
${jpegfile}     /ebs/TDD/large.jpeg
${shfile}     /ebs/TDD/example.sh
${docfile}     /ebs/TDD/docsample.doc
${txtfile}     /ebs/TDD/textsample.txt
${xlFile}      ${EXECDIR}/TDD/LeadQnr.xlsx  

@{emptylist}
${order}    0

@{originFrom}    Lead   Enquire
${permanentPinCode}    679581
${task_temp_name1}   Follow Up 1
${task_temp_name2}   Follow Up 2
${en_temp_name}   EnquiryName



*** Test Cases ***
JD-TC-CreateKyc-1
    [Documentation]  Create a Enquiry and Kyc with valid Details.

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


    ${resp}=  Consumer Login  ${CUSERNAME13}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${customerName}  ${resp.json()['userName']}
    Set Suite Variable  ${telephoneNumber}  ${resp.json()['primaryPhoneNumber']}
    
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    

    ${resp}=   Encrypted Provider Login  ${MUSERNAME2}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${provider_id}  ${decrypted_data['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

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

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME13}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME13}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${pcons_id3}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${pcons_id3}  ${resp.json()[0]['id']}
    END
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME13}  
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

    ${resp}=  Create Enquiry  ${locId}  ${pcons_id3}  category=${category}
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

    ${resp}=  Update and Proceed Enquiry to Status  ${en_uid}  ${status_id0}  ${locId}  ${pcons_id3}  &{resp.json()}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Get Enquiry by Uuid  ${en_uid}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id1}
    Should Be Equal As Strings    ${resp.json()['status']['name']}  ${status_name1}
  
    ${resp}=  Update and Proceed Enquiry to Status  ${en_uid}  ${status_id1}  ${locId}  ${pcons_id3}  &{resp.json()}
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
   
    ${permanentAddress}=    FakerLibrary.Address
    ${permanentCity}=    FakerLibrary.City
    ${permanentState}=    FakerLibrary.State
    ${panNumber}=  Generate_pan_number

    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType3}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType3}
    ${caption3}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${pdffile}
    Log  ${resp}
    ${fileType4}=  Get From Dictionary       ${resp}    ${pdffile}
    Set Suite Variable    ${fileType4}
    ${list13}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption3}     fileType=${fileType3}   order=${order}
    ${caption4}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
   
    ${list14}=  Create Dictionary         owner=${provider_id}   fileName=${pdffile}    fileSize= 0.00458     caption=${caption4}     fileType=${fileType4}   order=${order}
  
    ${list}=   Create List     ${list13}   ${list14} 
    ${valida1}=    Create Dictionary    idTypes=${idTypes[0]}     idValue=${idValue}    attachments=${list}
   
    ${resp}=  db.getType   ${pngfile}
    Log  ${resp}
    ${fileType5}=  Get From Dictionary       ${resp}    ${pngfile}
    Set Suite Variable    ${fileType5}
    ${caption5}=  Fakerlibrary.Sentence
    # ${resp}=  db.getType   ${jpgfile}
    # Log  ${resp}

    ${list13}=  Create Dictionary         owner=${provider_id}   fileName=${pngfile}    fileSize= 0.00458     caption=${caption5}     fileType=${fileType5}   order=${order}
    ${caption6}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${giffile}
    Log  ${resp}
    ${fileType6}=  Get From Dictionary       ${resp}    ${giffile}
    Set Suite Variable    ${fileType6}
    ${list14}=  Create Dictionary         owner=${provider_id}   fileName=${giffile}    fileSize= 0.00458     caption=${caption6}     fileType=${fileType6}   order=${order}
  
    ${list}=   Create List     ${list13}   ${list14} 
    ${valida2}=    Create Dictionary    idTypes=${idTypes[2]}   idValue=${idValue}    attachments=${list}
    ${validationId}=    Create List    ${valida1}    ${valida2}


    ${resp}=  Create KYC        ${en_uid}       ${customerName}    ${dob}        ${relationType[0]}    ${relationName}    ${telephoneType[2]}    ${phoneNo}   ${validationId}       ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress}    ${permanentCity}     ${states[0]}     ${permanentPinCode}    ${panNumber}    ${bool[1]}    customer=${pcons_id3}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

     
   

JD-TC-CreateKyc-2
    [Documentation]  create Kyc with Co-applicent.

    ${resp}=   Encrypted Provider Login  ${MUSERNAME2}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME14}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME14}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${pcons_id4}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${pcons_id4}  ${resp.json()[0]['id']}
    END
   

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME14}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable    ${phoneNo}   ${resp.json()[0]['phoneNo']}


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

    ${resp}=  Create Enquiry  ${locId}  ${pcons_id4}  category=${category}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${en_id1}        ${resp.json()['id']}
    Set Suite Variable   ${en_uid1}        ${resp.json()['uid']}

    ${resp}=  Get Enquiry by Uuid  ${en_uid1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}   ${en_id1}
    Should Be Equal As Strings  ${resp.json()['uid']}   ${en_uid1}
    Should Be Equal As Strings  ${resp.json()['accountId']}   ${account_id}

    ${resp}=  Get Provider Enquiry Status  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}  Get Length  ${resp.json()}
    FOR   ${i}  IN RANGE   ${len}
        Set Test Variable  ${status_id${i}}    ${resp.json()[${i}]['id']}
        Set Test Variable  ${status_name${i}}  ${resp.json()[${i}]['name']}
    END

    ${resp}=  Get Enquiry by Uuid  ${en_uid1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${status_id0}    ${resp.json()['status']['id']}

    ${resp}=  Update and Proceed Enquiry to Status  ${en_uid1}  ${status_id0}  ${locId}  ${pcons_id4}  &{resp.json()}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Get Enquiry by Uuid  ${en_uid1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id1}
    Should Be Equal As Strings    ${resp.json()['status']['name']}  ${status_name1}
  
    ${resp}=  Update and Proceed Enquiry to Status  ${en_uid1}  ${status_id1}  ${locId}  ${pcons_id4}  &{resp.json()}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
  
    ${resp}=  Get Enquiry by Uuid  ${en_uid1}  
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
    ${panNumber}=  Generate_pan_number
    ${attachments}=     Create List

    

    ${resp}=  Create KYC       ${en_uid1}          ${customerName}    ${dob}        ${relationType[0]}    ${relationName}    ${telephoneType[2]}    ${phoneNo}   ${attachments}       ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress}    ${permanentCity}    ${states[0]}    ${permanentPinCode}    ${panNumber}    ${bool[1]}   customer=${pcons_id4}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${dob2}=    FakerLibrary.Date
    ${relationName2}=    FakerLibrary.First Name
    ${idValue2}=    FakerLibrary.Word
    ${fileName2}=    FakerLibrary.File Name
    ${fileSize}=    FakerLibrary.Binary
    ${caption2}=    FakerLibrary.Text
    ${resp}=  db.getType   ${jpegfile}
    Log  ${resp}
    ${fileType2}=  Get From Dictionary       ${resp}    ${jpegfile}
    Set Suite Variable    ${fileType2}
    ${permanentAddress2}=    FakerLibrary.Address
    ${permanentCity2}=    FakerLibrary.City
    ${permanentState2}=    FakerLibrary.State
    ${panNumber2}=  Generate_pan_number
    ${attachments}=     Create List
    ${PO_Number1}=  Generate Random Phone Number
    ${PO_Number1}=  Convert To Integer    ${PO_Number1}
    ${customerName1}=    FakerLibrary.First Name

    ${resp}=  Create KYC        ${en_uid1}        ${customerName1}    ${dob2}        ${relationType[0]}    ${relationName2}    ${telephoneType[2]}    ${PO_Number1}   ${attachments}       ${provider_id}    ${fileName2}    0.0054    ${caption2}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress2}    ${permanentCity2}    ${states[0]}    ${permanentPinCode}    ${panNumber2}    ${bool[0]}   parentid=${pcons_id4}    permanentPhone=${PO_Number1}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=    Get KYC    ${en_uid1}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200


JD-TC-CreateKyc-3
    [Documentation]  create Kyc with Another Provider Enquiry Uuid.

     ${resp}=  Consumer Login  ${CUSERNAME10}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${customerName}  ${resp.json()['userName']}
    Set Suite Variable  ${telephoneNumber}  ${resp.json()['primaryPhoneNumber']}
    
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    

    ${resp}=   Encrypted Provider Login  ${MUSERNAME3}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${provider_id}  ${decrypted_data['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id3}  ${resp.json()['id']}
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

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

     ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME10}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME10}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${pcons_id4}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${pcons_id4}  ${resp.json()[0]['id']}
    END
   

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME10}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable    ${phoneNo13}   ${resp.json()[0]['phoneNo']}

    updateEnquiryStatus  ${account_id3}
    sleep  01s

    ${resp}=  enquiryTemplate  ${account_id3}  ${enq_sts_new_id}  ${en_temp_name}  creator_provider_id=${provider_id} 

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

    ${resp}=  Create Enquiry  ${locId}  ${pcons_id4}  category=${category}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${en_id2}  ${resp.json()['id']}
    Set Test Variable   ${en_uid2}  ${resp.json()['uid']}

    ${resp}=  Get Enquiry by Uuid  ${en_uid2}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}   ${en_id2}
    Should Be Equal As Strings  ${resp.json()['uid']}   ${en_uid2}
    Should Be Equal As Strings  ${resp.json()['accountId']}   ${account_id3}

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

    ${resp}=  Update and Proceed Enquiry to Status  ${en_uid2}  ${status_id0}  ${locId}  ${pcons_id4}  &{resp.json()}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Get Enquiry by Uuid  ${en_uid2}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id1}
    Should Be Equal As Strings    ${resp.json()['status']['name']}  ${status_name1}
  
    ${resp}=  Update and Proceed Enquiry to Status  ${en_uid2}  ${status_id1}  ${locId}  ${pcons_id4}  &{resp.json()}
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
    ${PO_Number10}=  Generate Random Phone Number
    ${PO_Number10}=  Convert To Integer    ${PO_Number10}
    
    ${panNumber}=  Generate_pan_number
    ${attachments}=     Create List

    ${resp}=  Create KYC        ${en_uid2}           ${customerName}     ${dob}        ${relationType[0]}    ${relationName}    ${telephoneType[2]}    ${PO_Number10}    ${attachments}       ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress}    ${permanentCity}    ${states[0]}    ${permanentPinCode}    ${panNumber}    ${bool[1]}    customer= ${pcons_id4}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200




JD-TC-CreateKyc-4
    [Documentation]  User Create Kyc .

  
    ${resp}=   Encrypted Provider Login  ${HLMUSERNAME6}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${provider_id}  ${decrypted_data['id']}
    clear_customer   ${HLMUSERNAME6}
    ${resp}=   Get Active License
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id6}  ${resp.json()['id']}
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
    END
    FOR   ${i}  IN RANGE   0   ${len}
        Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
        IF   not '${user_phone}' == '${HLMUSERNAME6}'
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

    updateEnquiryStatus  ${account_id6}
    sleep  01s

    ${resp}=  enquiryTemplate  ${account_id6}  ${en_temp_name}  ${enq_sts_new_id}  creator_provider_id=${provider_id} 

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
    Should Be Equal As Strings  ${resp.json()['accountId']}   ${account_id6}

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
    ${panNumber}=  Generate_pan_number
    ${attachments}=     Create List

    ${resp}=  Create KYC        ${en_uid6}       ${customerName}    ${dob}        ${relationType[0]}    ${relationName}    ${telephoneType[2]}    ${phoneNo}   ${attachments}       ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress}    ${permanentCity}    ${permanentState}    ${permanentPinCode}    ${panNumber}    ${bool[1]}    customer=${pcid15}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

JD-TC-CreateKyc-5
    [Documentation]  Create Kyc With Incorrect Phone Number.

    ${resp}=   Encrypted Provider Login  ${HLMUSERNAME6}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Set Suite Variable  ${provider_id}  ${resp.json()['id']}
    clear_customer   ${HLMUSERNAME6}
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

    updateEnquiryStatus  ${account_id6}
    sleep  01s

    ${resp}=  enquiryTemplate  ${account_id6}  ${en_temp_name}  ${enq_sts_new_id}  creator_provider_id=${provider_id} 

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
    Should Be Equal As Strings  ${resp.json()['accountId']}   ${account_id6}

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
    ${panNumber}=  Generate_pan_number
    ${attachments}=     Create List
    ${phoneNo1}=    FakerLibrary.Last Name

    ${resp}=  Create KYC        ${en_uid7}       ${customerName}    ${dob}        ${relationType[0]}    ${relationName}    ${telephoneType[2]}    ${phoneNo1}   ${attachments}       ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress}    ${permanentCity}    ${permanentState}    ${permanentPinCode}    ${panNumber}    ${bool[1]}    customer=${pcid15}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  422
    Should Be Equal As Strings      ${resp.json()}    ${GIVE_VALID_PHONE_NUMBER}



JD-TC-CreateKyc-UH1
    [Documentation]  Create Kyc with Invalid Customer Id .

    ${resp}=   Encrypted Provider Login  ${MUSERNAME3}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${provider_id3}  ${decrypted_data['id']}

    ${resp}=   Get Active License
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id3}  ${resp.json()['id']}
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
    ELSE
        Set Suite Variable  ${locId3}  ${resp.json()[0]['id']}
    END

    ${title3}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 
    ${targetPotential}=    FakerLibrary.Building Number
    Set Suite Variable  ${targetPotential}
    

    # ${resp}=   Encrypted Provider Login  ${BUSER_U1}  ${PASSWORD} 
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}   200

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

    updateEnquiryStatus  ${account_id6}
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

    ${resp}=  enquiryTemplate  ${account_id3}  ${en_temp_name}  ${enq_sts_new_id}  creator_provider_id=${provider_id3}  ${enq_sts_new_id}

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

    ${resp}=  Create Enquiry  ${locId3}  ${pcid15}  category=${category}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${en_id8}        ${resp.json()['id']}
    Set Test Variable   ${en_uid8}        ${resp.json()['uid']}

    ${resp}=  Get Enquiry by Uuid  ${en_uid8}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}   ${en_id8}
    Should Be Equal As Strings  ${resp.json()['uid']}   ${en_uid8}
    Should Be Equal As Strings  ${resp.json()['accountId']}   ${account_id3}

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

    ${resp}=  Update and Proceed Enquiry to Status  ${en_uid8}  ${status_id0}  ${locId3}  ${pcid15}  &{resp.json()}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Get Enquiry by Uuid  ${en_uid8}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id1}
    Should Be Equal As Strings    ${resp.json()['status']['name']}  ${status_name1}
  
    ${resp}=  Update and Proceed Enquiry to Status  ${en_uid8}  ${status_id1}  ${locId3}  ${pcid15}  &{resp.json()}
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
    ${panNumber}=  Generate_pan_number
    ${attachments}=     Create List

    ${resp}=  Create KYC        ${en_uid8}         ${customerName}    ${dob}        ${relationType[0]}    ${relationName}    ${telephoneType[2]}    ${phoneNo}  ${attachments}       ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress}    ${permanentCity}    ${permanentState}    ${permanentPinCode}    ${panNumber}    ${bool[1]}    customer=0000
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${INVALID_CONSUMER_ID}



JD-TC-CreateKyc-UH2
    [Documentation]  Create Kyc without login.

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
    ${PO_Number11}=  Generate Random Phone Number
    ${PO_Number11}=  Convert To Integer    ${PO_Number11}
    

    ${attachments}=     Create List

    ${resp}=  Create KYC        ${en_uid1}        ${customerName}    ${dob}        ${relationType[0]}    ${relationName}    ${telephoneType[2]}     ${PO_Number11}   ${attachments}      ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress}    ${permanentCity}    ${permanentState}    ${permanentPinCode}    ${panNumber}    ${bool[1]}    customer=${pcid15}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

JD-TC-CreateKyc-UH3
    [Documentation]  Create Kyc with consumer login.

    ${resp}=  Consumer Login  ${CUSERNAME17}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

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
    ${PO_Number12}=  Generate Random Phone Number
    ${PO_Number12}=  Convert To Integer    ${PO_Number12}
    
    ${attachments}=     Create List

    ${resp}=  Create KYC       ${en_uid1}        ${customerName}    ${dob}        ${relationType[0]}    ${relationName}    ${telephoneType[2]}    ${PO_Number12}  ${attachments}      ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress}    ${permanentCity}    ${permanentState}    ${permanentPinCode}    ${panNumber}    ${bool[1]}   customer=${pcid15}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"   "${NoAccess}"

JD-TC-CreateKyc-UH4
    [Documentation]  Create Kyc With Co-applicant permanentPhone is Empty.

    ${resp}=   Encrypted Provider Login  ${BUSER_U1}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${provider_idu1}  ${decrypted_data['id']}
    clear_customer   ${HLMUSERNAME6}
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

    updateEnquiryStatus  ${account_id6}
    sleep  01s

    ${resp}=  enquiryTemplate  ${account_id6}  ${en_temp_name}  ${enq_sts_new_id}  creator_provider_id=${provider_id} 

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
    Set Test Variable   ${en_id10}        ${resp.json()['id']}
    Set Test Variable   ${en_uid10}        ${resp.json()['uid']}

    ${resp}=  Get Enquiry by Uuid  ${en_uid10}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}   ${en_id10}
    Should Be Equal As Strings  ${resp.json()['uid']}   ${en_uid10}
    Should Be Equal As Strings  ${resp.json()['accountId']}   ${account_id6}

    ${resp}=  Get Provider Enquiry Status  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}  Get Length  ${resp.json()}
    FOR   ${i}  IN RANGE   ${len}
        Set Test Variable  ${status_id${i}}    ${resp.json()[${i}]['id']}
        Set Test Variable  ${status_name${i}}  ${resp.json()[${i}]['name']}
    END

    ${resp}=  Get Enquiry by Uuid  ${en_uid10}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${status_id0}    ${resp.json()['status']['id']}

    ${resp}=  Update and Proceed Enquiry to Status  ${en_uid10}  ${status_id0}  ${locId}  ${pcid15}  &{resp.json()}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Get Enquiry by Uuid  ${en_uid10}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id1}
    Should Be Equal As Strings    ${resp.json()['status']['name']}  ${status_name1}
  
    ${resp}=  Update and Proceed Enquiry to Status  ${en_uid10}  ${status_id1}  ${locId}  ${pcid15}  &{resp.json()}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
  
    ${resp}=  Get Enquiry by Uuid  ${en_uid10}  
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

    ${resp}=  Create KYC        ${en_uid10}       ${customerName}    ${dob}        ${relationType[0]}    ${relationName}    ${telephoneType[2]}    ${phoneNo}  ${attachments}    ${provider_idu1}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress}    ${permanentCity}    ${permanentState}    ${permanentPinCode}    ${panNumber}    ${bool[1]}    customer=${pcid15}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

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
    ${attachments}=     Create List
    ${permanentPhone}=    FakerLibrary.Phone Number
    ${PO_Number}=  Generate Random Phone Number
    ${PO_Number}=  Convert To Integer    ${PO_Number}

    ${resp}=  Create KYC       ${en_uid10}        ${customerName}    ${dob}        ${relationType[0]}    ${relationName1}    ${telephoneType[2]}    ${phoneNo}  ${attachments}    ${provider_idu1}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}        ${permanentAddress1}    ${permanentCity1}    ${permanentState1}    ${permanentPinCode}    ${panNumber1}        ${bool[0]}    parentid=${pcid15}    permanentPhone=${EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${GIVE_VALID_PHONE_NUMBER}

JD-TC-CreateKyc-UH5
    [Documentation]  Create a  Kyc With same idType Attachment  

    ${resp}=   Encrypted Provider Login  ${BUSER_U1}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_customer   ${HLMUSERNAME6}

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

    updateEnquiryStatus  ${account_id6}
    sleep  01s

    ${resp}=  enquiryTemplate  ${account_id6}  ${en_temp_name}  ${enq_sts_new_id}  creator_provider_id=${provider_id} 

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
    Set Test Variable   ${en_id11}        ${resp.json()['id']}
    Set Test Variable   ${en_uid11}        ${resp.json()['uid']}

    ${resp}=  Get Enquiry by Uuid  ${en_uid11}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}   ${en_id11}
    Should Be Equal As Strings  ${resp.json()['uid']}   ${en_uid11}
    Should Be Equal As Strings  ${resp.json()['accountId']}   ${account_id6}

    ${resp}=  Get Provider Enquiry Status  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}  Get Length  ${resp.json()}
    FOR   ${i}  IN RANGE   ${len}
        Set Test Variable  ${status_id${i}}    ${resp.json()[${i}]['id']}
        Set Test Variable  ${status_name${i}}  ${resp.json()[${i}]['name']}
    END

    ${resp}=  Get Enquiry by Uuid  ${en_uid11}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${status_id0}    ${resp.json()['status']['id']}

    ${resp}=  Update and Proceed Enquiry to Status  ${en_uid11}  ${status_id0}  ${locId}  ${pcid15}  &{resp.json()}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Get Enquiry by Uuid  ${en_uid11}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id1}
    Should Be Equal As Strings    ${resp.json()['status']['name']}  ${status_name1}
  
    ${resp}=  Update and Proceed Enquiry to Status  ${en_uid11}  ${status_id1}  ${locId}  ${pcid15}  &{resp.json()}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
  
    ${resp}=  Get Enquiry by Uuid  ${en_uid11}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id2}
    Should Be Equal As Strings    ${resp.json()['status']['name']}  ${status_name2}
   
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
    ${PO_Number11}=  Generate Random Phone Number
    ${PO_Number11}=  Convert To Integer    ${PO_Number11}


    ${caption3}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType5}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType5}
    ${list13}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption3}     fileType=${fileType5}   order=${order}
    ${caption4}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
  
    ${list}=   Create List     ${list13}   
    ${valida1}=    Create Dictionary    idTypes=${idTypes[0]}     idValue=${idValue}    attachments=${list}
   
    ${caption5}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}

    ${list1}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption5}     fileType=${fileType5}   order=${order}
    ${caption6}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}

    ${list}=   Create List     ${list1}   
    ${valida2}=    Create Dictionary    idTypes=${idTypes[0]}     idValue=${idValue}    attachments=${list}
    ${validationId}=    Create List    ${valida1}    ${valida2}
    Set Suite Variable    ${validationId}

    ${resp}=  Create KYC        ${en_uid11}      ${customerName}    ${dob}        ${relationType[0]}    ${relationName}    ${telephoneType[0]}    ${PO_Number11}   ${validationId}       ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress}    ${permanentCity}    ${states[0]}    ${permanentPinCode}    ${panNumber}    ${bool[1]}    customer= ${pcid15}   
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}   422
    Should Be Equal As Strings      ${resp.json()}  ${PROVIDE_DIFFERENT_IDS}
    
  

