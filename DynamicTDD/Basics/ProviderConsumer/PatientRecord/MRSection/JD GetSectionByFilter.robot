*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Patient Record
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py
Variables         /ebs/TDD/varfiles/hl_musers.py

*** Variables ***

${jpgfile}      /ebs/TDD/uploadimage.jpg
${pngfile}      /ebs/TDD/upload.png
${pdffile}      /ebs/TDD/sample.pdf

${order}    0
${fileSize}  0.00458

${titles}    @sdf@123
${description1}    &^7gsdkqwrrf

*** Test Cases ***

JD-TC-Create Sections-1

    [Documentation]    Create Sections with valid details then filter by caseUid.

    ${iscorp_subdomains}=  get_iscorp_subdomains  1
     Log  ${iscorp_subdomains}
     Set Suite Variable  ${iscorp_subdomains}
     Set Suite Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
     Set Suite Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
     Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
     ${firstname_A}=  FakerLibrary.first_name
     Set Suite Variable  ${firstname_A}
     ${lastname_A}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname_A}
     ${MUSERNAME_E}=  Evaluate  ${MUSERNAME}+97777802
     ${highest_package}=  get_highest_license_pkg
     ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${MUSERNAME_E}    ${highest_package[0]}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Activation  ${MUSERNAME_E}  0
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Set Credential  ${MUSERNAME_E}  ${PASSWORD}  0
     Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login    ${MUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}

    Set Suite Variable  ${pid}  ${decrypted_data['id']}
    Set Suite Variable    ${pdrname}    ${decrypted_data['userName']}
    Set Suite Variable    ${pdrfname}    ${decrypted_data['firstName']}
    Set Suite Variable    ${pdrlname}    ${decrypted_data['lastName']}

     Append To File  ${EXECDIR}/TDD/numbers.txt  ${MUSERNAME_E}${\n}
     Set Suite Variable  ${MUSERNAME_E}
     ${id}=  get_id  ${MUSERNAME_E}
     Set Suite Variable  ${id}
     ${bs}=  FakerLibrary.bs
     Set Suite Variable  ${bs}

     ${resp}=  Toggle Department Enable
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     sleep  2s
     ${resp}=  Get Departments
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}

     ${resp}=  View Waitlist Settings
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${resp}=  Run Keyword If  ${resp.json()['filterByDept']}==${bool[0]}   Toggle Department Enable
     Run Keyword If  '${resp}' != '${None}'   Log   ${resp.json()}
     Run Keyword If  '${resp}' != '${None}'   Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${accountId}        ${resp.json()['id']}
    # Set Suite Variable    ${accountName}      ${resp.json()['businessName']}

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${name}=  FakerLibrary.name
    Set Suite Variable    ${name}
    ${aliasName}=  FakerLibrary.name
    Set Suite Variable    ${aliasName}
    ${DAY1}=  get_date
    Set Suite Variable    ${DAY1}

    ${resp}=    Create Case Category    ${name}  ${aliasName}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${category_id}    ${resp.json()['id']} 

    ${category}=  Create Dictionary  id=${category_id}  
    Set Suite Variable    ${category} 

    ${resp}=    Create Case Type    ${name}  ${aliasName}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${type_id}    ${resp.json()['id']}  

    ${type}=  Create Dictionary  id=${type_id} 
    Set Suite Variable    ${type}  
    ${doctor}=  Create Dictionary  id=${pid} 
    Set Suite Variable    ${doctor} 
    ${title}=  FakerLibrary.name
    Set Suite Variable    ${title}
    ${description}=  FakerLibrary.last_name
    Set Suite Variable    ${description}

    ${firstName}=  FakerLibrary.name
    Set Suite Variable    ${firstName}
    ${lastName}=  FakerLibrary.last_name
    Set Suite Variable    ${lastName}
    ${primaryMobileNo}    Generate random string    10    123456789
    ${primaryMobileNo}    Convert To Integer  ${primaryMobileNo}
    Set Suite Variable    ${primaryMobileNo}
    Set Suite Variable  ${email}  ${lastName}${primaryMobileNo}.${test_mail}

    ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    Customer Logout 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email}    ${primaryMobileNo}     ${accountId}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200    
   
    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings              ${resp.status_code}   200
    Set Suite Variable    ${cid}            ${resp.json()['providerConsumer']}
    Set Suite Variable    ${jconid}         ${resp.json()['id']}
    Set Suite Variable    ${proconfname}    ${resp.json()['firstName']}    
    Set Suite Variable    ${proconlname}    ${resp.json()['lastName']} 
    Set Suite Variable    ${fullname}       ${proconfname}${space}${proconlname}

    

    ${resp}=  Encrypted Provider Login    ${MUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${consumer}=  Create Dictionary  id=${cid} 
    Set Suite Variable    ${consumer} 

     ${resp}=    Create MR Case    ${category}  ${type}  ${doctor}  ${consumer}   ${title}  ${description}  
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200
    Set Suite Variable    ${caseId}        ${resp.json()['id']}
    Set Suite Variable    ${caseUId}    ${resp.json()['uid']}

    ${resp}=    Get MR Case By UID   ${caseUId}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['consumer']['id']}     ${cid} 
    Should Be Equal As Strings    ${resp.json()['consumer']['firstName']}     ${proconfname} 
    Should Be Equal As Strings    ${resp.json()['consumer']['lastName']}     ${proconlname} 
    Should Be Equal As Strings    ${resp.json()['doctor']['id']}     ${pid} 
    Should Be Equal As Strings    ${resp.json()['doctor']['firstName']}     ${pdrfname} 
    Should Be Equal As Strings    ${resp.json()['doctor']['lastName']}     ${pdrlname}
    Should Be Equal As Strings    ${resp.json()['type']['id']}     ${type_id} 
    Should Be Equal As Strings    ${resp.json()['category']['id']}     ${category_id} 
    Should Be Equal As Strings    ${resp.json()['createdDate']}     ${DAY1}


    ${templateName}=  FakerLibrary.name
    Set Suite Variable    ${templateName}
    ${frequency}=  Random Int  min=500   max=1000
    Set Suite Variable    ${frequency}
    ${duration}=  Random Int  min=1   max=100
    Set Suite Variable    ${duration}
    ${instructions}=  FakerLibrary.name
    Set Suite Variable    ${instructions}
    ${dosage}=  Random Int  min=500   max=1000
    Set Suite Variable    ${dosage}
     ${medicineName}=  FakerLibrary.name
    Set Suite Variable    ${medicineName}

    ${prescription}=    Create Dictionary    frequency=${frequency}  duration=${duration}  instructions=${instructions}  dosage=${dosage}   medicineName=${medicineName} 

    ${resp}=    Create MedicalRecordPrescription Template    ${templateName}  ${prescription}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${temId}    ${resp.json()}

    ${med_name}=      FakerLibrary.name
    Set Suite Variable    ${med_name}
    ${frequency}=     FakerLibrary.word
    Set Suite Variable    ${frequency}
    ${duration}=      FakerLibrary.sentence
    Set Suite Variable    ${duration}
    ${instrn}=        FakerLibrary.sentence
    Set Suite Variable    ${instrn}
    ${dosage}=        FakerLibrary.sentence
    Set Suite Variable    ${dosage}
    ${type}=     FakerLibrary.word
    Set Suite Variable    ${type}
    ${clinicalNote}=     FakerLibrary.word
    Set Suite Variable    ${clinicalNote}
    ${clinicalNote1}=        FakerLibrary.sentence
    Set Suite Variable    ${clinicalNote1}
    ${type1}=        FakerLibrary.sentence
    Set Suite Variable    ${type1}


    ${resp}=  db.getType   ${pdffile} 
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${pdffile} 
    Set Suite Variable    ${fileType}
    ${caption}=  Fakerlibrary.Sentence
    Set Suite Variable    ${caption}

    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType1}
    ${caption1}=  Fakerlibrary.Sentence
    Set Suite Variable    ${caption1}

    ${resp}    upload file to temporary location    ${file_action[0]}    ${pid}    ${ownerType[0]}    ${pdrname}    ${jpgfile}    ${fileSize}    ${caption}    ${fileType}    ${EMPTY}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Set Suite Variable    ${driveId}    ${resp.json()[0]['driveId']}

    ${resp}    change status of the uploaded file    ${QnrStatus[1]}    ${driveId}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${attachments}=    Create Dictionary   action=${file_action[0]}  owner=${pid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}    driveId=${driveId}
    Log  ${attachments}
    Set Suite Variable    ${attachments}

    ${voiceAttachments}=    Create Dictionary   action=${file_action[0]}  owner=${pid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}    driveId=${driveId}
    Log  ${voiceAttachments}
    ${voiceAttachments}=  Create List   ${voiceAttachments}
    Set Suite Variable    ${voiceAttachments}

    ${resp}=    Create Section Template    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Section Template   ${caseUId}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Should Be Equal As Strings    ${resp.json()[0]['enumName']}   ${}
    Set Suite Variable    ${temp_id}    ${resp.json()[0]['id']}
    Set Suite Variable    ${enumName}    ${resp.json()[0]['sectionType']}
    # Set Test Variable    ${displayName}    ${resp.json()[0]['displayName']}

    ${CHIEFCOMPLAINT}=  create Dictionary  chiefComplaint=${caption}
    Set Suite Variable    ${CHIEFCOMPLAINT}

    ${resp}=    Create Sections     ${caseUId}    ${pid}    ${temp_id}       ${enumName}    ${CHIEFCOMPLAINT}    ${attachments}   voiceAttachments=${voiceAttachments}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${Sec_Id}    ${resp.json()['id']}
    Set Suite Variable    ${Sec_UId}    ${resp.json()['uid']}

    ${start}=    Get Current Date    result_format=%H:%M:%S
    Set Suite Variable    ${start} 

    ${resp}=    Get Sections Filter   caseUid-eq=${caseUId}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings     ${resp.json()[0]['uid']}    ${Sec_UId}
    Should Be Equal As Strings     ${resp.json()[0]['account']}    ${accountId}
    Should Be Equal As Strings     ${resp.json()[0]['mrCase']['id']}    ${caseId}
    Should Be Equal As Strings     ${resp.json()[0]['mrCase']['uid']}    ${caseUId}
    Should Be Equal As Strings     ${resp.json()[0]['mrCase']['title']}    ${title}
    Should Be Equal As Strings     ${resp.json()[0]['doctor']['id']}    ${pid}
    Should Be Equal As Strings     ${resp.json()[0]['templateDetailId']}    ${temp_id}
    Should Be Equal As Strings     ${resp.json()[0]['sectionType']}    ${enumName}
    Should Be Equal As Strings     ${resp.json()[0]['sectionValue']['chiefComplaint']}    ${caption}
    Should Be Equal As Strings     ${resp.json()[0]['status']}    ${toggle[0]}
    Should Be Equal As Strings     ${resp.json()[0]['createdDate']}    ${DAY1}
    Should Be Equal As Strings     ${resp.json()[0]['createdDateString']}    ${DAY1} ${start}

JD-TC-Create Sections-2

    [Documentation]    Create Sections with valid details then filter by uid.

    ${resp}=  Encrypted Provider Login    ${MUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=    Get Sections Filter   uid-eq=${Sec_UId}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings     ${resp.json()[0]['uid']}    ${Sec_UId}
    Should Be Equal As Strings     ${resp.json()[0]['account']}    ${accountId}
    Should Be Equal As Strings     ${resp.json()[0]['mrCase']['id']}    ${caseId}
    Should Be Equal As Strings     ${resp.json()[0]['mrCase']['uid']}    ${caseUId}
    Should Be Equal As Strings     ${resp.json()[0]['mrCase']['title']}    ${title}
    Should Be Equal As Strings     ${resp.json()[0]['doctor']['id']}    ${pid}
    Should Be Equal As Strings     ${resp.json()[0]['templateDetailId']}    ${temp_id}
    Should Be Equal As Strings     ${resp.json()[0]['sectionType']}    ${enumName}
    Should Be Equal As Strings     ${resp.json()[0]['sectionValue']['chiefComplaint']}    ${caption}
    Should Be Equal As Strings     ${resp.json()[0]['status']}    ${toggle[0]}
    Should Be Equal As Strings     ${resp.json()[0]['createdDate']}    ${DAY1}
    Should Be Equal As Strings     ${resp.json()[0]['createdDateString']}    ${DAY1} ${start}

JD-TC-Create Sections-3

    [Documentation]    Create Sections with valid details then filter by doctorId.

    ${resp}=  Encrypted Provider Login    ${MUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=    Get Sections Filter   doctorId-eq=${pid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings     ${resp.json()[0]['uid']}    ${Sec_UId}
    Should Be Equal As Strings     ${resp.json()[0]['account']}    ${accountId}
    Should Be Equal As Strings     ${resp.json()[0]['mrCase']['id']}    ${caseId}
    Should Be Equal As Strings     ${resp.json()[0]['mrCase']['uid']}    ${caseUId}
    Should Be Equal As Strings     ${resp.json()[0]['mrCase']['title']}    ${title}
    Should Be Equal As Strings     ${resp.json()[0]['doctor']['id']}    ${pid}
    Should Be Equal As Strings     ${resp.json()[0]['templateDetailId']}    ${temp_id}
    Should Be Equal As Strings     ${resp.json()[0]['sectionType']}    ${enumName}
    Should Be Equal As Strings     ${resp.json()[0]['sectionValue']['chiefComplaint']}    ${caption}
    Should Be Equal As Strings     ${resp.json()[0]['status']}    ${toggle[0]}
    Should Be Equal As Strings     ${resp.json()[0]['createdDate']}    ${DAY1}
    Should Be Equal As Strings     ${resp.json()[0]['createdDateString']}    ${DAY1} ${start}

JD-TC-Create Sections-4

    [Documentation]    Create Sections with valid details then filter by doctorFirstName.

    ${resp}=  Encrypted Provider Login    ${MUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=    Get Sections Filter   doctorFirstName-eq=${pdrfname}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings     ${resp.json()[0]['uid']}    ${Sec_UId}
    Should Be Equal As Strings     ${resp.json()[0]['account']}    ${accountId}
    Should Be Equal As Strings     ${resp.json()[0]['mrCase']['id']}    ${caseId}
    Should Be Equal As Strings     ${resp.json()[0]['mrCase']['uid']}    ${caseUId}
    Should Be Equal As Strings     ${resp.json()[0]['mrCase']['title']}    ${title}
    Should Be Equal As Strings     ${resp.json()[0]['doctor']['id']}    ${pid}
    Should Be Equal As Strings     ${resp.json()[0]['doctor']['firstName']}    ${pdrfname}
    Should Be Equal As Strings     ${resp.json()[0]['templateDetailId']}    ${temp_id}
    Should Be Equal As Strings     ${resp.json()[0]['sectionType']}    ${enumName}
    Should Be Equal As Strings     ${resp.json()[0]['sectionValue']['chiefComplaint']}    ${caption}
    Should Be Equal As Strings     ${resp.json()[0]['status']}    ${toggle[0]}
    Should Be Equal As Strings     ${resp.json()[0]['createdDate']}    ${DAY1}
    Should Be Equal As Strings     ${resp.json()[0]['createdDateString']}    ${DAY1} ${start}

JD-TC-Create Sections-5

    [Documentation]    Create Sections with valid details then filter by doctorLastName.

    ${resp}=  Encrypted Provider Login    ${MUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=    Get Sections Filter   doctorLastName-eq=${pdrlname}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings     ${resp.json()[0]['uid']}    ${Sec_UId}
    Should Be Equal As Strings     ${resp.json()[0]['account']}    ${accountId}
    Should Be Equal As Strings     ${resp.json()[0]['mrCase']['id']}    ${caseId}
    Should Be Equal As Strings     ${resp.json()[0]['mrCase']['uid']}    ${caseUId}
    Should Be Equal As Strings     ${resp.json()[0]['mrCase']['title']}    ${title}
    Should Be Equal As Strings     ${resp.json()[0]['doctor']['id']}    ${pid}
    Should Be Equal As Strings     ${resp.json()[0]['doctor']['lastName']}    ${pdrlname}
    Should Be Equal As Strings     ${resp.json()[0]['templateDetailId']}    ${temp_id}
    Should Be Equal As Strings     ${resp.json()[0]['sectionType']}    ${enumName}
    Should Be Equal As Strings     ${resp.json()[0]['sectionValue']['chiefComplaint']}    ${caption}
    Should Be Equal As Strings     ${resp.json()[0]['status']}    ${toggle[0]}
    Should Be Equal As Strings     ${resp.json()[0]['createdDate']}    ${DAY1}
    Should Be Equal As Strings     ${resp.json()[0]['createdDateString']}    ${DAY1} ${start}

JD-TC-Create Sections-6

    [Documentation]    Create Sections with valid details then filter by sectionType.

    ${resp}=  Encrypted Provider Login    ${MUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=    Get Sections Filter   sectionType-eq=${enumName}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings     ${resp.json()[0]['uid']}    ${Sec_UId}
    Should Be Equal As Strings     ${resp.json()[0]['account']}    ${accountId}
    Should Be Equal As Strings     ${resp.json()[0]['mrCase']['id']}    ${caseId}
    Should Be Equal As Strings     ${resp.json()[0]['mrCase']['uid']}    ${caseUId}
    Should Be Equal As Strings     ${resp.json()[0]['mrCase']['title']}    ${title}
    Should Be Equal As Strings     ${resp.json()[0]['doctor']['id']}    ${pid}
    Should Be Equal As Strings     ${resp.json()[0]['doctor']['lastName']}    ${pdrlname}
    Should Be Equal As Strings     ${resp.json()[0]['templateDetailId']}    ${temp_id}
    Should Be Equal As Strings     ${resp.json()[0]['sectionType']}    ${enumName}
    Should Be Equal As Strings     ${resp.json()[0]['sectionValue']['chiefComplaint']}    ${caption}
    Should Be Equal As Strings     ${resp.json()[0]['status']}    ${toggle[0]}
    Should Be Equal As Strings     ${resp.json()[0]['createdDate']}    ${DAY1}
    Should Be Equal As Strings     ${resp.json()[0]['createdDateString']}    ${DAY1} ${start}

JD-TC-Create Sections-7

    [Documentation]    Create Sections with valid details then filter by spInternalStatus.

    ${resp}=  Encrypted Provider Login    ${MUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=    Get Sections Filter   spInternalStatus-eq=${enumName}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings     ${resp.json()[0]['uid']}    ${Sec_UId}
    Should Be Equal As Strings     ${resp.json()[0]['account']}    ${accountId}
    Should Be Equal As Strings     ${resp.json()[0]['mrCase']['id']}    ${caseId}
    Should Be Equal As Strings     ${resp.json()[0]['mrCase']['uid']}    ${caseUId}
    Should Be Equal As Strings     ${resp.json()[0]['mrCase']['title']}    ${title}
    Should Be Equal As Strings     ${resp.json()[0]['doctor']['id']}    ${pid}
    Should Be Equal As Strings     ${resp.json()[0]['doctor']['lastName']}    ${pdrlname}
    Should Be Equal As Strings     ${resp.json()[0]['templateDetailId']}    ${temp_id}
    Should Be Equal As Strings     ${resp.json()[0]['sectionType']}    ${enumName}
    Should Be Equal As Strings     ${resp.json()[0]['sectionValue']['chiefComplaint']}    ${caption}
    Should Be Equal As Strings     ${resp.json()[0]['status']}    ${toggle[0]}
    Should Be Equal As Strings     ${resp.json()[0]['createdDate']}    ${DAY1}
    Should Be Equal As Strings     ${resp.json()[0]['createdDateString']}    ${DAY1} ${start}

JD-TC-Create Sections-8

    [Documentation]    Create Sections with valid details then filter by createdDate.

    ${resp}=  Encrypted Provider Login    ${MUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=    Get Sections Filter   createdDate-eq=${DAY1}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings     ${resp.json()[0]['uid']}    ${Sec_UId}
    Should Be Equal As Strings     ${resp.json()[0]['account']}    ${accountId}
    Should Be Equal As Strings     ${resp.json()[0]['mrCase']['id']}    ${caseId}
    Should Be Equal As Strings     ${resp.json()[0]['mrCase']['uid']}    ${caseUId}
    Should Be Equal As Strings     ${resp.json()[0]['mrCase']['title']}    ${title}
    Should Be Equal As Strings     ${resp.json()[0]['doctor']['id']}    ${pid}
    Should Be Equal As Strings     ${resp.json()[0]['doctor']['lastName']}    ${pdrlname}
    Should Be Equal As Strings     ${resp.json()[0]['templateDetailId']}    ${temp_id}
    Should Be Equal As Strings     ${resp.json()[0]['sectionType']}    ${enumName}
    Should Be Equal As Strings     ${resp.json()[0]['sectionValue']['chiefComplaint']}    ${caption}
    Should Be Equal As Strings     ${resp.json()[0]['status']}    ${toggle[0]}
    Should Be Equal As Strings     ${resp.json()[0]['createdDate']}    ${DAY1}
    Should Be Equal As Strings     ${resp.json()[0]['createdDateString']}    ${DAY1} ${start}

JD-TC-Create Sections-9

    [Documentation]    Create Sections with valid details then filter by updatedDate.

    ${resp}=  Encrypted Provider Login    ${MUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${DAY2}=  add_date  10 

    ${caption11}=  Fakerlibrary.Sentence
    ${CHIEFCOMPLAINT1}=  create Dictionary  chiefComplaint=${caption11}    
    Set Suite Variable    ${CHIEFCOMPLAINT1}

    ${resp}=    Update MR Sections    ${Sec_UId}    ${enumName}     ${CHIEFCOMPLAINT1}    ${attachments}   voiceAttachments=${voiceAttachments}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Sections Filter   updatedDate-eq=${DAY2}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings     ${resp.json()[0]['uid']}    ${Sec_UId}
    Should Be Equal As Strings     ${resp.json()[0]['account']}    ${accountId}
    Should Be Equal As Strings     ${resp.json()[0]['mrCase']['id']}    ${caseId}
    Should Be Equal As Strings     ${resp.json()[0]['mrCase']['uid']}    ${caseUId}
    Should Be Equal As Strings     ${resp.json()[0]['mrCase']['title']}    ${title}
    Should Be Equal As Strings     ${resp.json()[0]['doctor']['id']}    ${pid}
    Should Be Equal As Strings     ${resp.json()[0]['doctor']['lastName']}    ${pdrlname}
    Should Be Equal As Strings     ${resp.json()[0]['templateDetailId']}    ${temp_id}
    Should Be Equal As Strings     ${resp.json()[0]['sectionType']}    ${enumName}
    Should Be Equal As Strings     ${resp.json()[0]['sectionValue']['chiefComplaint']}    ${caption}
    Should Be Equal As Strings     ${resp.json()[0]['status']}    ${toggle[0]}
    Should Be Equal As Strings     ${resp.json()[0]['createdDate']}    ${DAY1}
    Should Be Equal As Strings     ${resp.json()[0]['createdDateString']}    ${DAY1} ${start}