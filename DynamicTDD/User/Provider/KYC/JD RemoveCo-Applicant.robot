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

Remove Co-Applicant

    [Arguments]    ${uuid}    ${applicantId}
    Check And Create YNW Session
    ${resp}=   DELETE On Session   ynw   /provider/KYC/coapplicant/${applicantId}/${uuid}  expected_status=any
    RETURN  ${resp}

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

${customerName}    hisham
${customerName1}    mansoor
${customerName2}    nihal
${customerName3}    thensi
${xlFile}      ${EXECDIR}/TDD/LeadQnr.xlsx  
${task_temp_name1}   Follow Up 1
${task_temp_name2}   Follow Up 2
${en_temp_name}   EnquiryName




*** Test Cases ***
JD-TC-Remove Co-Applicant -1
    [Documentation]  Create Kyc with Co-Applicants then Remove one Co-Applicant.

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


    ${resp}=   Encrypted Provider Login  ${MUSERNAME4}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${provider_id}  ${resp.json()['id']}

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

    ${resp}=  categorytype  ${provider_id}
    ${resp}=  tasktype      ${provider_id}
   
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME14}  
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

    ${resp}=  Create Enquiry  ${locId}  ${pcons_id4}   category=${category} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${en_id}        ${resp.json()['id']}
    Set Suite Variable   ${en_uid}        ${resp.json()['uid']}

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

    ${resp}=  Update and Proceed Enquiry to Status  ${en_uid}  ${status_id0}  ${locId}  ${pcons_id4}  &{resp.json()}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Get Enquiry by Uuid  ${en_uid}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id1}
    Should Be Equal As Strings    ${resp.json()['status']['name']}  ${status_name1}
  
    ${resp}=  Update and Proceed Enquiry to Status  ${en_uid}  ${status_id1}  ${locId}  ${pcons_id4}  &{resp.json()}
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
    ${panNumber}=  Generate_pan_number
    Set Suite Variable    ${panNumber}
    ${validation}=     Create List
    ${PO_Number}=  Generate Random Phone Number
    ${PO_Number}=  Convert To Integer    ${PO_Number}
    Set Suite Variable    ${PO_Number}
    

    ${resp}=  Create KYC        ${en_uid}          ${customerName}    ${dob}        ${relationType[0]}    ${relationName}    ${telephoneType[2]}    ${phoneNo}   ${validation}       ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress}    ${permanentCity}    ${states[0]}   ${permanentPinCode}    ${panNumber}    ${bool[1]}   customer=${pcons_id4}
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
    Set Suite Variable    ${PO_Number1}
    # ${customerName1}=    FakerLibrary.First Name

    
    ${resp}=  Create KYC       ${en_uid}        ${customerName1}    ${dob2}        ${relationType[0]}    ${relationName2}    ${telephoneType[2]}    ${PO_Number1}   ${validation}       ${provider_id}    ${fileName2}    0.0054    ${caption2}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress2}    ${permanentCity2}    ${states[0]}    ${permanentPinCode}    ${panNumber2}    ${bool[0]}   parentid=${pcons_id4}    permanentPhone=${PO_Number1}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${dob3}=    FakerLibrary.Date
    ${relationName3}=    FakerLibrary.First Name
    ${idValue3}=    FakerLibrary.Word
    ${fileName3}=    FakerLibrary.File Name
    ${fileSize}=    FakerLibrary.Binary
    ${caption3}=    FakerLibrary.Text
    ${resp}=  db.getType   ${jpegfile}
    Log  ${resp}
    ${fileType2}=  Get From Dictionary       ${resp}    ${jpegfile}
    Set Suite Variable    ${fileType2}
    ${permanentAddress3}=    FakerLibrary.Address
    ${permanentCity3}=    FakerLibrary.City
    ${permanentState3}=    FakerLibrary.State
    ${panNumber3}=  Generate_pan_number
    ${attachments}=     Create List
    ${PO_Number2}=  Generate Random Phone Number
    ${PO_Number2}=  Convert To Integer    ${PO_Number2}
    Set Suite Variable    ${PO_Number2}


    ${resp}=  Create KYC        ${en_uid}        ${customerName2}    ${dob3}        ${relationType[0]}    ${relationName3}    ${telephoneType[2]}    ${PO_Number2}   ${validation}       ${provider_id}    ${fileName3}    0.0054    ${caption3}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress3}    ${permanentCity3}    ${states[0]}    ${permanentPinCode}    ${panNumber3}    ${bool[0]}   parentid=${pcons_id4}    permanentPhone=${PO_Number2}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=  Create KYC        ${en_uid}        ${customerName3}    ${dob2}        ${relationType[0]}    ${relationName2}    ${telephoneType[2]}    ${PO_Number1}   ${validation}       ${provider_id}    ${fileName2}    0.0054    ${caption2}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress2}    ${permanentCity}    ${states[0]}    ${permanentPinCode}    ${panNumber2}    ${bool[0]}   parentid=${pcons_id4}    permanentPhone=${PO_Number}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=    Get KYC    ${en_uid}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable   ${id}        ${resp.json()[0]['id']}
    Set Suite Variable   ${id1}        ${resp.json()[1]['id']}
    Set Suite Variable   ${id2}        ${resp.json()[2]['id']}
    Set Suite Variable   ${id3}        ${resp.json()[3]['id']}

    Should Be Equal As Strings      ${resp.json()[0]['originFrom']}  ${originFrom[1]}
    Should Be Equal As Strings      ${resp.json()[0]['originUid']}  ${en_uid}
    Should Be Equal As Strings      ${resp.json()[0]['customerName']}  ${customerName}
    Should Be Equal As Strings      ${resp.json()[0]['customer']}  ${pcons_id4}
    Should Be Equal As Strings      ${resp.json()[0]['relationName']}  ${relationName}
    Should Be Equal As Strings      ${resp.json()[0]['permanentAddress']}  ${permanentAddress}
    Should Be Equal As Strings      ${resp.json()[0]['permanentCity']}  ${permanentCity}

    Should Be Equal As Strings      ${resp.json()[1]['originFrom']}  ${originFrom[1]}
    Should Be Equal As Strings      ${resp.json()[1]['originUid']}  ${en_uid}
    Should Be Equal As Strings      ${resp.json()[1]['parentid']['id']}  ${pcons_id4}
    Should Be Equal As Strings      ${resp.json()[1]['permanentPhone']}  ${PO_Number1}
    Should Be Equal As Strings      ${resp.json()[1]['relationName']}  ${relationName2}
    Should Be Equal As Strings      ${resp.json()[1]['permanentAddress']}  ${permanentAddress2}
    Should Be Equal As Strings      ${resp.json()[1]['permanentCity']}  ${permanentCity2}

    Should Be Equal As Strings      ${resp.json()[2]['originFrom']}  ${originFrom[1]}
    Should Be Equal As Strings      ${resp.json()[2]['originUid']}  ${en_uid}
    Should Be Equal As Strings      ${resp.json()[2]['customerName']}  ${customerName2}
    Should Be Equal As Strings      ${resp.json()[2]['parentid']['id']}  ${pcons_id4}
    Should Be Equal As Strings      ${resp.json()[2]['permanentPhone']}  ${PO_Number2}
    Should Be Equal As Strings      ${resp.json()[2]['relationName']}  ${relationName3}
    Should Be Equal As Strings      ${resp.json()[2]['permanentAddress']}  ${permanentAddress3}
    Should Be Equal As Strings      ${resp.json()[2]['permanentCity']}  ${permanentCity3}

    Should Be Equal As Strings      ${resp.json()[3]['originFrom']}  ${originFrom[1]}
    Should Be Equal As Strings      ${resp.json()[3]['originUid']}  ${en_uid}
    Should Be Equal As Strings      ${resp.json()[3]['customerName']}  ${customerName3}
    Should Be Equal As Strings      ${resp.json()[3]['permanentPhone']}  ${PO_Number}
    Should Be Equal As Strings      ${resp.json()[3]['relationName']}  ${relationName2}
    Should Be Equal As Strings      ${resp.json()[3]['permanentAddress']}  ${permanentAddress2}
    Should Be Equal As Strings      ${resp.json()[3]['permanentCity']}  ${permanentCity}



    ${resp}=    Remove Co-Applicant    ${en_uid}    ${id3}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=    Get KYC    ${en_uid}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200

    Should Be Equal As Strings      ${resp.json()[0]['originFrom']}  ${originFrom[1]}
    Should Be Equal As Strings      ${resp.json()[0]['originUid']}  ${en_uid}
    Should Be Equal As Strings      ${resp.json()[0]['customerName']}  ${customerName}
    Should Be Equal As Strings      ${resp.json()[0]['customer']}  ${pcons_id4}
    Should Be Equal As Strings      ${resp.json()[0]['relationName']}  ${relationName}
    Should Be Equal As Strings      ${resp.json()[0]['permanentAddress']}  ${permanentAddress}
    Should Be Equal As Strings      ${resp.json()[0]['permanentCity']}  ${permanentCity}

    Should Be Equal As Strings      ${resp.json()[1]['originFrom']}  ${originFrom[1]}
    Should Be Equal As Strings      ${resp.json()[1]['originUid']}  ${en_uid}
    Should Be Equal As Strings      ${resp.json()[1]['customerName']}  ${customerName1}
    Should Be Equal As Strings      ${resp.json()[1]['parentid']['id']}  ${pcons_id4}
    Should Be Equal As Strings      ${resp.json()[1]['permanentPhone']}  ${PO_Number1}
    Should Be Equal As Strings      ${resp.json()[1]['relationName']}  ${relationName2}
    Should Be Equal As Strings      ${resp.json()[1]['permanentAddress']}  ${permanentAddress2}
    Should Be Equal As Strings      ${resp.json()[1]['permanentCity']}  ${permanentCity2}

    Should Be Equal As Strings      ${resp.json()[2]['originFrom']}  ${originFrom[1]}
    Should Be Equal As Strings      ${resp.json()[2]['originUid']}  ${en_uid}
    Should Be Equal As Strings      ${resp.json()[2]['customerName']}  ${customerName2}
    Should Be Equal As Strings      ${resp.json()[2]['parentid']['id']}  ${pcons_id4}
    Should Be Equal As Strings      ${resp.json()[2]['permanentPhone']}  ${PO_Number2}
    Should Be Equal As Strings      ${resp.json()[2]['relationName']}  ${relationName3}
    Should Be Equal As Strings      ${resp.json()[2]['permanentAddress']}  ${permanentAddress3}
    Should Be Equal As Strings      ${resp.json()[2]['permanentCity']}  ${permanentCity3}
*** comment ***
JD-TC-Remove Co-Applicant -UH1
    [Documentation]  Create Kyc with Co-Applicants then Remove two time one Co-Applicant .

    ${resp}=   Encrypted Provider Login  ${MUSERNAME4}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Remove Co-Applicant    ${en_uid}    ${id2}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=    Get KYC    ${en_uid}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    # ${length}=  Get Length   ${resp}


    ${resp}=    Remove Co-Applicant    ${en_uid}    ${id2}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Should Be Equal As Strings      ${resp.json()}  ${bool[0]}


JD-TC-Remove Co-Applicant -UH2
    [Documentation]  Try to remove Applicant(parant id).

    ${resp}=   Encrypted Provider Login  ${MUSERNAME4}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Remove Co-Applicant    ${en_uid}    ${id}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  401
    Should Be Equal As Strings      ${resp.json()}    ${NO_PERMISSION}

JD-TC-Remove Co-Applicant -UH3
    [Documentation]  Try to pass invalid Id.

    ${resp}=   Encrypted Provider Login  ${MUSERNAME4}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Remove Co-Applicant    ${en_uid}    0000
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Should Be Equal As Strings      ${resp.json()}  ${bool[0]}

JD-TC-Remove Co-Applicant -UH4
    [Documentation]  Try to pass invalid uid.

    ${resp}=   Encrypted Provider Login  ${MUSERNAME4}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Remove Co-Applicant    0000    ${id2}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Should Be Equal As Strings      ${resp.json()}  ${bool[0]}

JD-TC-Remove Co-Applicant -2
    [Documentation]  proceed Kyc after remove co-applicent.

    ${resp}=   Encrypted Provider Login  ${MUSERNAME4}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${provider_id}  ${resp.json()['id']}
    clear_customer   ${HLMUSERNAME4}

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
        Set Suite Variable  ${pcons_id4}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${pcons_id4}  ${resp.json()[0]['id']}
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

    ${resp}=  Create Enquiry  ${locId}  ${pcons_id4}   category=${category}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${en_id2}        ${resp.json()['id']}
    Set Suite Variable   ${en_uid2}        ${resp.json()['uid']}

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
    ${panNumber}=  Generate_pan_number
    Set Suite Variable    ${panNumber}
    ${validation}=     Create List
    ${PO_Number}=  Generate Random Phone Number
    ${PO_Number}=  Convert To Integer    ${PO_Number}
    Set Suite Variable    ${PO_Number}

    ${caption3}=  Fakerlibrary.Sentence
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType5}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType5}
    ${list13}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption3}     fileType=${fileType5}   order=${order}
    ${list}=   Create List      ${list13} 
    ${valida1}=    Create Dictionary    idTypes=${idTypes[3]}     idValue=${idValue}    attachments=${list}
   
    ${caption5}=  Fakerlibrary.Sentence
    ${list1}=  Create Dictionary         owner=${provider_id}   fileName=${jpgfile}    fileSize= 0.00458     caption=${caption5}     fileType=${fileType5}   order=${order}  
    ${list}=   Create List       ${list1}
    ${valida2}=    Create Dictionary    idTypes=${idTypes[4]}     idValue=${idValue}    attachments=${list}
    ${validation}=    Create List    ${valida1}    ${valida2}
    Set Suite Variable    ${validation}
   
    ${resp}=  Create KYC        ${en_uid2}          ${customerName}    ${dob}        ${relationType[0]}    ${relationName}    ${telephoneType[2]}    ${phoneNo}   ${validation}       ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress}    ${permanentCity}    ${states[0]}    ${permanentPinCode}    ${panNumber}    ${bool[1]}   customer=${pcons_id4}
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
    Set Suite Variable    ${PO_Number1}
    # ${customerName1}=    FakerLibrary.First Name

    
    ${resp}=  Create KYC       ${en_uid2}        ${customerName1}    ${dob2}        ${relationType[0]}    ${relationName2}    ${telephoneType[2]}    ${PO_Number1}   ${validation}       ${provider_id}    ${fileName2}    0.0054    ${caption2}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress2}    ${permanentCity2}    ${states[0]}    ${permanentPinCode}    ${panNumber2}    ${bool[0]}   parentid=${pcons_id4}    permanentPhone=${PO_Number1}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${dob3}=    FakerLibrary.Date
    ${relationName3}=    FakerLibrary.First Name
    ${idValue3}=    FakerLibrary.Word
    ${fileName3}=    FakerLibrary.File Name
    ${fileSize}=    FakerLibrary.Binary
    ${caption3}=    FakerLibrary.Text
    ${resp}=  db.getType   ${jpegfile}
    Log  ${resp}
    ${fileType2}=  Get From Dictionary       ${resp}    ${jpegfile}
    Set Suite Variable    ${fileType2}
    ${permanentAddress3}=    FakerLibrary.Address
    ${permanentCity3}=    FakerLibrary.City
    ${permanentState3}=    FakerLibrary.State
    ${panNumber3}=  Generate_pan_number
    ${attachments}=     Create List
    ${PO_Number2}=  Generate Random Phone Number
    ${PO_Number2}=  Convert To Integer    ${PO_Number2}
    Set Suite Variable    ${PO_Number2}


    ${resp}=  Create KYC      ${en_uid2}        ${customerName2}    ${dob3}        ${relationType[0]}    ${relationName3}    ${telephoneType[2]}    ${PO_Number2}   ${validation}       ${provider_id}    ${fileName3}    0.0054    ${caption3}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress3}    ${permanentCity3}    ${states[0]}    ${permanentPinCode}    ${panNumber3}    ${bool[0]}   parentid=${pcons_id4}    permanentPhone=${PO_Number2}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=  Create KYC       ${en_uid2}        ${customerName3}    ${dob2}        ${relationType[0]}    ${relationName2}    ${telephoneType[2]}    ${PO_Number1}   ${validation}       ${provider_id}    ${fileName2}    0.0054    ${caption2}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress2}    ${permanentCity}    ${states[0]}    ${permanentPinCode}    ${panNumber2}    ${bool[0]}   parentid=${pcons_id4}    permanentPhone=${PO_Number}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=    Get KYC    ${en_uid2}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable   ${id}        ${resp.json()[0]['id']}
    Set Suite Variable   ${id1}        ${resp.json()[1]['id']}
    Set Suite Variable   ${id2}        ${resp.json()[2]['id']}
    Set Suite Variable   ${id3}        ${resp.json()[3]['id']}

    Should Be Equal As Strings      ${resp.json()[0]['originFrom']}  ${originFrom[1]}
    Should Be Equal As Strings      ${resp.json()[0]['originUid']}  ${en_uid2}
    Should Be Equal As Strings      ${resp.json()[0]['customerName']}  ${customerName}
    Should Be Equal As Strings      ${resp.json()[0]['customer']}  ${pcons_id4}
    Should Be Equal As Strings      ${resp.json()[0]['relationName']}  ${relationName}
    Should Be Equal As Strings      ${resp.json()[0]['permanentAddress']}  ${permanentAddress}
    Should Be Equal As Strings      ${resp.json()[0]['permanentCity']}  ${permanentCity}

    Should Be Equal As Strings      ${resp.json()[1]['originFrom']}  ${originFrom[1]}
    Should Be Equal As Strings      ${resp.json()[1]['originUid']}  ${en_uid2}
    Should Be Equal As Strings      ${resp.json()[1]['parentid']['id']}  ${pcons_id4}
    Should Be Equal As Strings      ${resp.json()[1]['permanentPhone']}  ${PO_Number1}
    Should Be Equal As Strings      ${resp.json()[1]['relationName']}  ${relationName2}
    Should Be Equal As Strings      ${resp.json()[1]['permanentAddress']}  ${permanentAddress2}
    Should Be Equal As Strings      ${resp.json()[1]['permanentCity']}  ${permanentCity2}

    Should Be Equal As Strings      ${resp.json()[2]['originFrom']}  ${originFrom[1]}
    Should Be Equal As Strings      ${resp.json()[2]['originUid']}  ${en_uid2}
    Should Be Equal As Strings      ${resp.json()[2]['parentid']['id']}  ${pcons_id4}
    Should Be Equal As Strings      ${resp.json()[2]['permanentPhone']}  ${PO_Number2}
    Should Be Equal As Strings      ${resp.json()[2]['relationName']}  ${relationName3}
    Should Be Equal As Strings      ${resp.json()[2]['permanentAddress']}  ${permanentAddress3}
    Should Be Equal As Strings      ${resp.json()[2]['permanentCity']}  ${permanentCity3}

    Should Be Equal As Strings      ${resp.json()[3]['originFrom']}  ${originFrom[1]}
    Should Be Equal As Strings      ${resp.json()[3]['originUid']}  ${en_uid2}
    Should Be Equal As Strings      ${resp.json()[3]['permanentPhone']}  ${PO_Number}
    Should Be Equal As Strings      ${resp.json()[3]['relationName']}  ${relationName2}
    Should Be Equal As Strings      ${resp.json()[3]['permanentAddress']}  ${permanentAddress2}
    Should Be Equal As Strings      ${resp.json()[3]['permanentCity']}  ${permanentCity}

     ${resp}=  Get Enquiry by Uuid  ${en_uid2}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id2}
    Should Be Equal As Strings    ${resp.json()['status']['name']}  ${status_name2}
  

    ${resp}=  Change KYC Status       ${en_uid2}    ${status_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

   
    ${resp}=    Remove Co-Applicant    ${en_uid2}    ${id1}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=    Get KYC    ${en_uid2}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200

JD-TC-Remove Co-Applicant -UH5
    [Documentation]  Remove Co-Applicant without login.

    ${resp}=    Remove Co-Applicant    ${en_uid}    ${id1}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

JD-TC-Remove Co-Applicant -UH6
    [Documentation]  Remove Co-Applicant with consumer login.

    ${resp}=  Consumer Login  ${CUSERNAME17}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Remove Co-Applicant    ${en_uid}    ${id1}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"   "${NoAccess}"