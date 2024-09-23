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

${task_temp_name1}   Follow Up 1
${task_temp_name2}   Follow Up 2
${en_temp_name}   EnquiryName




*** Test Cases ***
JD-TC-GetKyc-1
    [Documentation]  Create a lead and Kyc with valid Details.

  
    ${resp}=   Encrypted Provider Login  ${HLPUSERNAME18}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

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
            IF   not '${user_phone}' == '${HLPUSERNAME18}'
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
    ${resp}=    Get Lead Status
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${status_id}    ${resp.json()[0]['id']}
    Set Suite Variable  ${status_id1}    ${resp.json()[1]['id']}
    Set Suite Variable  ${status_id2}    ${resp.json()[2]['id']}
    Set Suite Variable  ${status_id3}    ${resp.json()[3]['id']}
    Set Suite Variable  ${status_id4}    ${resp.json()[4]['id']}
    Set Suite Variable  ${status_id6}    ${resp.json()[6]['id']}
    Set Suite Variable  ${statusName_id6}    ${resp.json()[6]['name']}

    ${title3}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 
    ${targetPotential}=    FakerLibrary.Building Number
    Set Suite Variable  ${targetPotential}
    

     
    ${resp}=   CrifScore  ${account_id}
    ${resp}=  categorytype   ${account_id}
    ${resp}=  tasktype       ${account_id}
    ${resp}=    Get Lead Category Type
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${cat_len}=  Get Length  ${resp.json()}
    # FOR  ${i}  IN RANGE   ${cat_len}
    #     IF  '${resp.json()[${i}]['name']}'=='${unique_lnames[0]}'
    #         Set Suite Variable  ${category_id1}    ${resp.json()[${i}]['id']}
    #         Set Suite Variable  ${category_name1}  ${resp.json()[${i}]['name']}
    #     END
    # END

  

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
  

    ${dob}=    FakerLibrary.Date
    ${relationName}=    FakerLibrary.First Name
    ${idValue}=    FakerLibrary.Word
    ${idValue12}=    FakerLibrary.Word
    
    ${fileName}=    FakerLibrary.File Name
    ${fileSize}=    FakerLibrary.Binary
    ${caption}=    FakerLibrary.Text
    ${resp}=  db.getType   ${jpegfile}
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${jpegfile}
    Set Suite Variable    ${fileType}
    ${permanentAddress}=    FakerLibrary.Address
    ${permanentCity}=    FakerLibrary.City
  
    ${panNumber}=  Generate_pan_number
    ${attachments}=     Create List

    ${resp}=  Create KYC        ${en_uid}        ${customerName}    ${dob}        ${relationType[1]}    ${relationName}    ${telephoneType[0]}    ${phoneNo}  ${attachments}      ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress}    ${permanentCity}    ${states[0]}    ${permanentPinCode}    ${panNumber}    ${bool[1]}   customer=${pcid18} 
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

JD-TC-GetKyc-2
    [Documentation]  Create Kyc with Co-applicant.

    ${resp}=   Encrypted Provider Login  ${HLPUSERNAME18}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_customer   ${HLPUSERNAME18}

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
    # ${resp}=    Get Lead Status
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${status_id}    ${resp.json()[0]['id']}
    # Set Suite Variable  ${status_id1}    ${resp.json()[1]['id']}
    # Set Suite Variable  ${status_id2}    ${resp.json()[2]['id']}
    # Set Suite Variable  ${status_id3}    ${resp.json()[3]['id']}
    # Set Suite Variable  ${status_id4}    ${resp.json()[4]['id']}
    # Set Suite Variable  ${status_id6}    ${resp.json()[6]['id']}
    # Set Suite Variable  ${statusName_id6}    ${resp.json()[6]['name']}

    ${resp}=  Get Provider Enquiry Status  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}  Get Length  ${resp.json()}
    FOR   ${i}  IN RANGE   ${len}
        Set Test Variable  ${status_id${i}}    ${resp.json()[${i}]['id']}
        Set Test Variable  ${status_name${i}}  ${resp.json()[${i}]['name']}
    END
    ${resp}=   CrifScore  ${account_id}
    ${resp}=  categorytype   ${account_id}
    ${resp}=  tasktype       ${account_id}
    ${resp}=    Get Lead Category Type
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${cat_len}=  Get Length  ${resp.json()}
    # FOR  ${i}  IN RANGE   ${cat_len}
    #     IF  '${resp.json()[${i}]['name']}'=='${unique_lnames[0]}'
    #         Set Suite Variable  ${category_id1}    ${resp.json()[${i}]['id']}
    #         Set Suite Variable  ${category_name1}  ${resp.json()[${i}]['name']}
    #     END
    # END

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
        Set Suite Variable  ${status_id${i}}    ${resp.json()[${i}]['id']}
        Set Suite Variable  ${status_name${i}}  ${resp.json()[${i}]['name']}
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
   
    ${panNumber}=  Generate_pan_number
    ${attachments}=     Create List

    ${resp}=  Create KYC     ${en_uid2}        ${customerName}    ${dob}        ${relationType[1]}    ${relationName}    ${telephoneType[0]}    ${phoneNo}  ${attachments}      ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress}    ${permanentCity}    ${states[0]}    ${permanentPinCode}    ${panNumber}    ${bool[1]}   customer=${pcid18} 
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${dob1}=    FakerLibrary.Date
    ${relationName1}=    FakerLibrary.First Name
    ${idValue1}=    FakerLibrary.Word
    ${fileName1}=    FakerLibrary.File Name
    ${fileSize}=    FakerLibrary.Binary
    ${caption1}=    FakerLibrary.Text
    ${resp}=  db.getType   ${jpegfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${jpegfile}
    Set Suite Variable    ${fileType1}
    ${permanentAddress1}=    FakerLibrary.Address
    ${permanentCity1}=    FakerLibrary.City
    ${permanentState1}=    FakerLibrary.State
    ${panNumber1}=  Generate_pan_number
    ${attachments}=     Create List
    ${PO_Number}=  Generate Random Phone Number
    ${PO_Number}=  Convert To Integer    ${PO_Number}

    ${resp}=  Create KYC        ${en_uid2}        ${customerName}    ${dob1}        ${relationType[1]}    ${relationName1}    ${telephoneType[0]}    ${PO_Number}  ${attachments}     ${provider_id}    ${fileName1}    0.0054    ${caption1}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress1}    ${permanentCity1}    ${permanentState1}    ${permanentPinCode}    ${panNumber1}    ${bool[0]}   parentid=${pcid18}    permanentPhone=${PO_Number}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=    Get KYC    ${en_uid2}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable   ${id}        ${resp.json()[0]['id']}
    Should Be Equal As Strings      ${resp.json()[0]['originFrom']}  ${originFrom[1]}
    Should Be Equal As Strings      ${resp.json()[0]['originUid']}  ${en_uid2}
    Should Be Equal As Strings      ${resp.json()[0]['customerName']}  ${customerName}
    Should Be Equal As Strings      ${resp.json()[0]['customer']}  ${pcid18}
    Should Be Equal As Strings      ${resp.json()[0]['relationName']}  ${relationName}
    Should Be Equal As Strings      ${resp.json()[0]['permanentAddress']}  ${permanentAddress}
    Should Be Equal As Strings      ${resp.json()[0]['permanentCity']}  ${permanentCity}

    Should Be Equal As Strings      ${resp.json()[1]['originFrom']}  ${originFrom[1]}
    Should Be Equal As Strings      ${resp.json()[1]['originUid']}  ${en_uid2}
    Should Be Equal As Strings      ${resp.json()[1]['customerName']}  ${customerName}
    Should Be Equal As Strings      ${resp.json()[1]['parentid']['id']}  ${pcid18}
    Should Be Equal As Strings      ${resp.json()[1]['permanentPhone']}  ${PO_Number}
    Should Be Equal As Strings      ${resp.json()[1]['relationName']}  ${relationName1}
    Should Be Equal As Strings      ${resp.json()[1]['permanentAddress']}  ${permanentAddress1}
    Should Be Equal As Strings      ${resp.json()[1]['permanentCity']}  ${permanentCity1}

JD-TC-GetKyc-3
    [Documentation]  Create Kyc with Two Co-applicant.

    ${resp}=   Encrypted Provider Login  ${HLPUSERNAME18}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    clear_customer   ${HLPUSERNAME18}

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
  
    
    ${dob}=    FakerLibrary.Date
    Set Suite Variable    ${dob}
    ${relationName}=    FakerLibrary.First Name
    Set Suite Variable    ${relationName}
    ${idValue}=    FakerLibrary.Word
    Set Suite Variable    ${idValue}
    ${idValue12}=    FakerLibrary.Word
    Set Suite Variable    ${idValue12}
    
    ${fileName}=    FakerLibrary.File Name
    Set Suite Variable    ${fileName}
    ${fileSize}=    FakerLibrary.Binary
    Set Suite Variable    ${fileSize}
    ${caption}=    FakerLibrary.Text
    Set Suite Variable    ${caption}
    ${resp}=  db.getType   ${jpegfile}
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${jpegfile}
    Set Suite Variable    ${fileType}
    ${permanentAddress}=    FakerLibrary.Address
    Set Suite Variable    ${permanentAddress}
    ${permanentCity}=    FakerLibrary.City
    Set Suite Variable    ${permanentCity}
    ${panNumber}=  Generate_pan_number
    Set Suite Variable    ${panNumber}
    ${attachments}=     Create List
    Set Suite Variable    ${attachments}

    ${resp}=  Create KYC       ${en_uid3}        ${customerName}    ${dob}        ${relationType[1]}    ${relationName}    ${telephoneType[0]}    ${phoneNo}  ${attachments}    ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress}    ${permanentCity}    ${states[0]}    ${permanentPinCode}    ${panNumber}    ${bool[1]}   customer=${pcid18} 
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${dob1}=    FakerLibrary.Date
    ${relationName1}=    FakerLibrary.First Name
    ${idValue1}=    FakerLibrary.Word
    ${fileName1}=    FakerLibrary.File Name
    ${fileSize}=    FakerLibrary.Binary
    ${caption1}=    FakerLibrary.Text
    ${resp}=  db.getType   ${jpegfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${jpegfile}
    Set Suite Variable    ${fileType1}
    ${permanentAddress1}=    FakerLibrary.Address
    ${permanentCity1}=    FakerLibrary.City
    
    ${panNumber1}=  Generate_pan_number
    ${attachments}=     Create List
    ${PO_Number}=  Generate Random Phone Number
    ${PO_Number}=  Convert To Integer    ${PO_Number}
    ${customerName2}=    FakerLibrary.First Name

    ${resp}=  Create KYC        ${en_uid3}        ${customerName2}    ${dob1}        ${relationType[1]}    ${relationName1}    ${telephoneType[0]}    ${PO_Number}  ${attachments}      ${provider_id}    ${fileName1}    0.0054    ${caption1}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress1}    ${permanentCity1}    ${states[0]}    ${permanentPinCode}    ${panNumber1}    ${bool[0]}   parentid=${pcid18}    permanentPhone=${PO_Number}
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
    Set Suite Variable    ${fileType1}
    ${permanentAddress2}=    FakerLibrary.Address
    ${permanentCity2}=    FakerLibrary.City
   
    ${panNumber2}=  Generate_pan_number
    ${attachments}=     Create List
    ${PO_Number1}=  Generate Random Phone Number
    ${PO_Number1}=  Convert To Integer    ${PO_Number1}
    ${customerName1}=    FakerLibrary.First Name
    ${PO_Number4}=  Generate Random Phone Number
    ${PO_Number4}=  Convert To Integer    ${PO_Number4}
    
    ${resp}=  Create KYC        ${en_uid3}        ${customerName1}    ${dob2}        ${relationType[1]}    ${relationName2}    ${telephoneType[0]}    ${PO_Number4}  ${attachments}      ${provider_id}    ${fileName2}    0.0054    ${caption2}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress2}    ${permanentCity2}    ${states[0]}    ${permanentPinCode}    ${panNumber2}    ${bool[0]}   parentid=${pcid18}    permanentPhone=${PO_Number1}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200


    ${resp}=    Get KYC    ${en_uid3}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable   ${id}        ${resp.json()[0]['id']}
    Should Be Equal As Strings      ${resp.json()[0]['originFrom']}  ${originFrom[1]}
    Should Be Equal As Strings      ${resp.json()[0]['originUid']}  ${en_uid3}
    Should Be Equal As Strings      ${resp.json()[0]['customerName']}  ${customerName}
    Should Be Equal As Strings      ${resp.json()[0]['customer']}  ${pcid18}
    Should Be Equal As Strings      ${resp.json()[0]['relationName']}  ${relationName}
    Should Be Equal As Strings      ${resp.json()[0]['permanentAddress']}  ${permanentAddress}
    Should Be Equal As Strings      ${resp.json()[0]['permanentCity']}  ${permanentCity}

    Set Suite Variable   ${id1}        ${resp.json()[1]['id']}
    Should Be Equal As Strings      ${resp.json()[1]['originFrom']}  ${originFrom[1]}
    Should Be Equal As Strings      ${resp.json()[1]['originUid']}  ${en_uid3}
    Should Be Equal As Strings      ${resp.json()[1]['parentid']['id']}  ${pcid18}
    Should Be Equal As Strings      ${resp.json()[1]['relationName']}  ${relationName1}
    Should Be Equal As Strings      ${resp.json()[1]['permanentAddress']}  ${permanentAddress1}
    Should Be Equal As Strings      ${resp.json()[1]['permanentCity']}  ${permanentCity1}

    Set Suite Variable   ${id2}        ${resp.json()[2]['id']}
    Should Be Equal As Strings      ${resp.json()[2]['originFrom']}  ${originFrom[1]}
    Should Be Equal As Strings      ${resp.json()[2]['originUid']}  ${en_uid3}
       # Should Be Equal As Strings      ${resp.json()[2]['panNumber']}  ${panNumber2}
    Should Be Equal As Strings      ${resp.json()[2]['parentid']['id']}  ${pcid18}
    Should Be Equal As Strings      ${resp.json()[2]['permanentPhone']}  ${PO_Number1}
    Should Be Equal As Strings      ${resp.json()[2]['relationName']}  ${relationName2}
    Should Be Equal As Strings      ${resp.json()[2]['permanentAddress']}  ${permanentAddress2}
    Should Be Equal As Strings      ${resp.json()[2]['permanentCity']}  ${permanentCity2}


JD-TC-GetKyc-4
    [Documentation]  Update Kyc And Get KYC.

    ${resp}=   Encrypted Provider Login  ${HLPUSERNAME18}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    clear_customer   ${HLPUSERNAME18}

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

    ${resp}=  Create Enquiry  ${locId}  ${pcid18}  category=${category}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${en_id4}        ${resp.json()['id']}
    Set Suite Variable   ${en_uid4}        ${resp.json()['uid']}

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
    
    ${resp}=  Create KYC        ${en_uid4}        ${customerName}    ${dob}        ${relationType[0]}    ${relationName}    ${telephoneType[0]}    ${phoneNo}     ${validationId}      ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress}    ${permanentCity}   ${states[0]}    ${permanentPinCode}    ${panNumber}    ${bool[1]}   customer=${pcid18} 
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

# ${resp}=  Create KYC        ${en_uid3}        ${customerName1}    ${dob2}        ${relationType[1]}    ${relationName2}    ${telephoneType[0]}    ${PO_Number4}  ${attachments}      ${provider_id}    ${fileName2}    0.0054    ${caption2}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress2}    ${permanentCity2}    ${states[0]}    ${permanentPinCode}    ${panNumber2}    ${bool[0]}   parentid=${pcid18}    permanentPhone=${PO_Number1}
#     Log   ${resp.json()}
#     Should Be Equal As Strings      ${resp.status_code}  200


    ${resp}=    Get KYC    ${en_uid4}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable   ${idkyc}        ${resp.json()[0]['id']}
    Should Be Equal As Strings      ${resp.json()[0]['originFrom']}  ${originFrom[1]}
    Should Be Equal As Strings      ${resp.json()[0]['originUid']}  ${en_uid4}
    Should Be Equal As Strings      ${resp.json()[0]['customerName']}  ${customerName}
    Should Be Equal As Strings      ${resp.json()[0]['customer']}  ${pcid18}
    Should Be Equal As Strings      ${resp.json()[0]['relationName']}  ${relationName}
    Should Be Equal As Strings      ${resp.json()[0]['permanentAddress']}  ${permanentAddress}
    Should Be Equal As Strings      ${resp.json()[0]['permanentCity']}  ${permanentCity}
   
    ${resp}=  Get Enquiry by Uuid  ${en_uid4}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id2}
    Should Be Equal As Strings    ${resp.json()['status']['name']}  ${status_name2}
    Set Suite Variable   ${stauslead1}        ${resp.json()['internalStatus']}


    ${resp}=  Change KYC Status     ${en_uid4}      ${status_id2}          
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=    Get KYC    ${en_uid4}
    Log   ${resp.content}
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
    ${valida2}=    Create Dictionary    idTypes=${idTypes[1]}     idValue=${idValue12}    attachments=${list}
    ${validationId}=    Create List    ${valida1}    ${valida2}
    Set Suite Variable    ${validationId}
   

    ${PO_Number3}=  Generate Random Phone Number
    ${PO_Number3}=  Convert To Integer    ${PO_Number3}
    ${customerName2}=  FakerLibrary.first Name
    ${resp}=  Update KYC    ${idkyc}      ${en_uid4}        ${customerName2}    ${dob}        ${relationType[1]}    ${relationName}    ${telephoneType[0]}    ${PO_Number3}  ${validationId}     ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress}    ${permanentCity}    ${states[0]}    ${permanentPinCode}    ${panNumber}    ${bool[1]}    customer=${pcid18}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=    Get KYC    ${en_uid4}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200  
    Set Suite Variable   ${id}        ${resp.json()[0]['id']}
    Should Be Equal As Strings      ${resp.json()[0]['originFrom']}  ${originFrom[1]}
    Should Be Equal As Strings      ${resp.json()[0]['originUid']}  ${en_uid4}
    Should Be Equal As Strings      ${resp.json()[0]['customerName']}  ${customerName2}
    Should Be Equal As Strings      ${resp.json()[0]['customer']}  ${pcid18}
    Should Be Equal As Strings      ${resp.json()[0]['telephone'][0]['telephoneNumber']}  ${PO_Number3}
    Should Be Equal As Strings      ${resp.json()[0]['permanentAddress']}  ${permanentAddress}
    Should Be Equal As Strings      ${resp.json()[0]['permanentCity']}  ${permanentCity}

JD-TC-GetKyc-5
    [Documentation]  After Procced update KYC and Get KYC.

    ${resp}=   Encrypted Provider Login  ${HLPUSERNAME18}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

      clear_customer   ${HLPUSERNAME18}

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

    ${resp}=  Create Enquiry  ${locId}  ${pcid18}  category=${category}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${en_id5}        ${resp.json()['id']}
    Set Suite Variable   ${en_uid5}        ${resp.json()['uid']}

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
    
    ${resp}=  Create KYC        ${en_uid5}        ${customerName}    ${dob}        ${relationType[0]}    ${relationName}    ${telephoneType[0]}    ${phoneNo}     ${validationId}      ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress}    ${permanentCity}   ${states[0]}    ${permanentPinCode}    ${panNumber}    ${bool[1]}   customer=${pcid18} 
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=    Get KYC    ${en_uid5}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable   ${id4}        ${resp.json()[0]['id']}
    Should Be Equal As Strings      ${resp.json()[0]['originFrom']}  ${originFrom[1]}
    Should Be Equal As Strings      ${resp.json()[0]['originUid']}  ${en_uid5}
    Should Be Equal As Strings      ${resp.json()[0]['customer']}  ${pcid18}
    Should Be Equal As Strings      ${resp.json()[0]['permanentAddress']}  ${permanentAddress}
    Should Be Equal As Strings      ${resp.json()[0]['permanentCity']}  ${permanentCity}

    ${resp}=  Get Enquiry by Uuid  ${en_uid5}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['status']['id']}   ${status_id2}
    Should Be Equal As Strings    ${resp.json()['status']['name']}  ${status_name2}
    Set Suite Variable   ${stauslead1}        ${resp.json()['internalStatus']}

    ${resp}=  Change KYC Status        ${en_uid5}       ${status_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${PO_Number4}=  Generate Random Phone Number
    ${PO_Number4}=  Convert To Integer    ${PO_Number4}
    ${customerName3}=  FakerLibrary.Last Name
    ${resp}=  Update KYC    ${id4}       ${en_uid5}        ${customerName3}    ${dob}        ${relationType[1]}    ${relationName}    ${telephoneType[0]}    ${PO_Number4}  ${validationId}      ${provider_id}    ${fileName}    0.0054    ${caption}    ${QnrfileTypes[1]}    ${order}    ${permanentAddress}    ${permanentCity}    ${states[0]}    ${permanentPinCode}    ${panNumber}    ${bool[1]}    customer=${pcid18}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=    Get KYC    ${en_uid5}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable   ${id}        ${resp.json()[0]['id']}
    Should Be Equal As Strings      ${resp.json()[0]['originFrom']}  ${originFrom[1]}
    Should Be Equal As Strings      ${resp.json()[0]['originUid']}  ${en_uid5}
    Should Be Equal As Strings      ${resp.json()[0]['customerName']}  ${customerName3}
    Should Be Equal As Strings      ${resp.json()[0]['customer']}  ${pcid18}
    Should Be Equal As Strings      ${resp.json()[0]['telephone'][0]['telephoneNumber']}  ${PO_Number4}
    Should Be Equal As Strings      ${resp.json()[0]['permanentAddress']}  ${permanentAddress}
    Should Be Equal As Strings      ${resp.json()[0]['permanentCity']}  ${permanentCity}

JD-TC-CreateKyc-UH1
    [Documentation]  Get Kyc without login.

    ${resp}=    Get KYC    ${en_uid5}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

JD-TC-CreateKyc-UH2
    [Documentation]  Get Kyc with consumer login.

    ${resp}=  Consumer Login  ${CUSERNAME17}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get KYC    ${en_uid5}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"   "${NoAccess}"

