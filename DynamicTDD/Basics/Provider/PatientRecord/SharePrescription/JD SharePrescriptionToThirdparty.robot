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
Variables         /ebs/TDD/varfiles/hl_providers.py
Library           /ebs/TDD/db.py
Library           /ebs/TDD/Imageupload.py



*** Variables ***

${jpgfile}      /ebs/TDD/uploadimage.jpg
${pngfile}      /ebs/TDD/upload.png
${pdffile}      /ebs/TDD/sample.pdf

${order}    0
${fileSize}  0.00458

${titles}    @sdf@123
${description1}    &^7gsdkqwrrf

*** Test Cases ***

JD-TC-Share Prescription To ThirdParty-1

    [Documentation]    Share Prescription To ThirdParty.

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
     ${PUSERNAME_E}=  Evaluate  ${PUSERNAME}+97788121
     ${highest_package}=  get_highest_license_pkg
     ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${PUSERNAME_E}    ${highest_package[0]}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    202
     ${resp}=  Account Activation  ${PUSERNAME_E}  0
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Set Credential  ${PUSERNAME_E}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${PUSERNAME_E}
     Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}

    Set Suite Variable  ${pid}  ${decrypted_data['id']}
    Set Suite Variable    ${pdrname}    ${decrypted_data['userName']}
    Set Suite Variable    ${pdrfname}    ${decrypted_data['firstName']}
    Set Suite Variable    ${pdrlname}    ${decrypted_data['lastName']}

     Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_E}${\n}
    Append To File  ${EXECDIR}/data/TDD_Logs/providernumbers.txt  ${SUITE NAME} - ${TEST NAME} - ${PUSERNAME_E}${\n}
     Set Suite Variable  ${PUSERNAME_E}
     ${id}=  get_id  ${PUSERNAME_E}
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

    # ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    # Log  ${resp.json()}         
    # Should Be Equal As Strings            ${resp.status_code}    200

    # ${decrypted_data}=  db.decrypt_data   ${resp.content}
    # Log  ${decrypted_data}

    # Set Suite Variable  ${pid}  ${decrypted_data['id']}
    # Set Suite Variable    ${pdrname}    ${decrypted_data['userName']}
    # Set Suite Variable    ${pdrfname}    ${decrypted_data['firstName']}
    # Set Suite Variable    ${pdrlname}    ${decrypted_data['lastName']}

    ${lid}=  Create Sample Location

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
    ${DAY1}=  db.get_date_by_timezone  ${tz}
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

    

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
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

    ${toothNo}=   Random Int  min=10   max=99
    ${note1}=  FakerLibrary.word
    ${investigation}=    Create List   ${note1}
    ${toothSurfaces}=    Create List   ${toothSurfaces[0]}

    ${resp}=    Create DentalRecord    ${toothNo}  ${toothType[0]}  ${caseUId}    investigation=${investigation}    toothSurfaces=${toothSurfaces}
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200
    Set Suite Variable      ${id1}           ${resp.json()}

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

     ${resp}    upload file to temporary location    ${LoanAction[0]}    ${pid}    ${ownerType[0]}    ${pdrname}    ${jpgfile}    ${fileSize}    ${caption}    ${fileType}    ${EMPTY}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Set Suite Variable    ${driveId}    ${resp.json()[0]['driveId']}



    ${prescriptionAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}  driveId=${driveId}
    Log  ${prescriptionAttachments}
    ${prescriptionAttachments}=  Create List   ${prescriptionAttachments}
    Set Suite Variable    ${prescriptionAttachments}

    ${mrPrescriptions}=  Create Dictionary  medicineName=${med_name}  frequency=${frequency}  duration=${duration}  instructions=${instrn}  dosage=${dosage}
    Set Suite Variable    ${mrPrescriptions}

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME_E}  ${PASSWORD}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   uploadDigitalSign   ${pid}   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get digital sign   ${pid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Create Prescription    ${cid}    ${pid}    ${caseId}       ${id1}    ${EMPTY}    prescriptionAttachments=${prescriptionAttachments}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${prescription_uid}   ${resp.json()}

     ${resp}=    Get Prescription By Provider consumer Id   ${cid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200 
    Set Suite Variable  ${uid}   ${resp.json()[0]['uid']}
    Set Suite Variable  ${prescriptionStatus}   ${resp.json()[0]['prescriptionStatus']} 
 
    ${resp1}=  Get Prescription By Filter   providerConsumerId-eq=${cid}  uid-eq=${uid}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Should Be Equal As Strings    ${resp.json()[0]['uid']}    ${prescription_uid} 
    Should Be Equal As Strings    ${resp.json()[0]['providerConsumerId']}     ${cid} 
    Should Be Equal As Strings    ${resp.json()[0]['doctorId']}     ${pid} 
    Should Be Equal As Strings    ${resp.json()[0]['caseId']}     ${caseId} 
    Should Be Equal As Strings    ${resp.json()[0]['dentalRecordId']}     ${id1} 
    Should Be Equal As Strings    ${resp.json()[0]['prescriptionAttachments'][0]['fileName']}     ${pdffile} 
    Should Be Equal As Strings    ${resp.json()[0]['prescriptionAttachments'][0]['caption']}     ${caption} 
    Should Be Equal As Strings    ${resp.json()[0]['prescriptionAttachments'][0]['fileSize']}     ${fileSize} 
    Should Be Equal As Strings    ${resp.json()[0]['prescriptionAttachments'][0]['fileType']}     ${fileType} 
    Should Be Equal As Strings    ${resp.json()[0]['prescriptionAttachments'][0]['order']}     ${order} 
    Should Be Equal As Strings    ${resp.json()[0]['prescriptionAttachments'][0]['action']}     ${LoanAction[0]} 
    Should Be Equal As Strings    ${resp.json()[0]['prescriptionCreatedByName']}     ${pdrname} 
    Should Be Equal As Strings    ${resp.json()[0]['prescriptionCreatedBy']}     ${id} 
    Should Be Equal As Strings    ${resp.json()[0]['prescriptionCreatedDate']}     ${DAY1}

    ${message}=  Fakerlibrary.Sentence
    Set Test Variable    ${message}

    ${primaryMobileNo1}    Generate random string    10    9874563211
    ${primaryMobileNo1}    Convert To Integer  ${primaryMobileNo1}
    Set Suite Variable    ${primaryMobileNo1}
    Set Suite Variable  ${email1}  ${lastName}${primaryMobileNo1}.${test_mail}

    ${sms}=  Create Dictionary  countryCode=${${countryCodes[0]}}  number=${primaryMobileNo1}  
    Set Suite Variable    ${sms}

    ${whatsAppNumber}=  Create Dictionary  countryCode=${${countryCodes[0]}}  number=${primaryMobileNo1}  
    Set Suite Variable    ${whatsAppNumber}

    ${telegramNumber}=  Create Dictionary  countryCode=${${countryCodes[0]}}  number=${primaryMobileNo1}  
    Set Suite Variable    ${telegramNumber}

    ${resp}=    Share Prescription To ThirdParty   ${prescription_uid}    ${message}    ${email1}       ${sms}    ${whatsAppNumber}    ${telegramNumber}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}     ${bool[1]}


JD-TC-Share Prescription To ThirdParty-2

    [Documentation]    Create Prescription with Empty dentalRecordId and Share Prescription To third party.

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=    Create Prescription    ${cid}    ${pid}    ${caseId}       ${EMPTY}    ${html}      ${mrPrescriptions}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${prescription_uid1}   ${resp.json()}

    ${resp}=  Get Prescription By Filter   providerConsumerId-eq=${cid}   mrPrescriptionStatus-eq=${prescriptionStatus}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings    ${resp.json()[0]['uid']}     ${prescription_uid1} 
    Should Be Equal As Strings    ${resp.json()[0]['providerConsumerId']}     ${cid} 
    Should Be Equal As Strings    ${resp.json()[0]['doctorId']}     ${pid} 
    Should Be Equal As Strings    ${resp.json()[0]['caseId']}     ${caseId} 
    Should Be Equal As Strings    ${resp.json()[0]['mrPrescriptions'][0]['medicineName']}     ${med_name} 
    Should Be Equal As Strings    ${resp.json()[0]['mrPrescriptions'][0]['frequency']}     ${frequency} 
    Should Be Equal As Strings    ${resp.json()[0]['mrPrescriptions'][0]['duration']}     ${duration} 
    Should Be Equal As Strings    ${resp.json()[0]['mrPrescriptions'][0]['instructions']}     ${instrn} 
    Should Be Equal As Strings    ${resp.json()[0]['mrPrescriptions'][0]['dosage']}     ${dosage} 
    Should Be Equal As Strings    ${resp.json()[0]['prescriptionCreatedByName']}     ${pdrname} 
    Should Be Equal As Strings    ${resp.json()[0]['prescriptionCreatedBy']}     ${id} 
    Should Be Equal As Strings    ${resp.json()[0]['prescriptionCreatedDate']}     ${DAY1}

     ${message}=  Fakerlibrary.Sentence
    Set Test Variable    ${message}

    ${primaryMobileNo2}    Generate random string    10    9874563211
    ${primaryMobileNo2}    Convert To Integer  ${primaryMobileNo2}
    Set Test Variable    ${primaryMobileNo2}
    Set Test Variable  ${email2}  ${lastName}${primaryMobileNo2}.${test_mail}

    ${sms1}=  Create Dictionary  countryCode=${${countryCodes[0]}}  number=${primaryMobileNo1}  
    Set Test Variable    ${sms1}

    ${whatsAppNumber1}=  Create Dictionary  countryCode=${${countryCodes[0]}}  number=${primaryMobileNo1}  
    Set Test Variable    ${whatsAppNumber1}

    ${telegramNumber1}=  Create Dictionary  countryCode=${${countryCodes[0]}}  number=${primaryMobileNo1}  
    Set Test Variable    ${telegramNumber1}

    ${resp}=    Share Prescription To ThirdParty   ${prescription_uid1}    ${message}    ${email2}       ${sms1}    ${whatsAppNumber1}    ${telegramNumber1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}     ${bool[1]}

JD-TC-Share Prescription To ThirdParty-3

    [Documentation]    upload paper Prescription with Empty html and Share Prescription To third party.

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=    Create Prescription    ${cid}    ${pid}    ${caseId}       ${id1}    ${EMPTY}    prescriptionAttachments=${prescriptionAttachments}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${prescription_uid1}   ${resp.json()}


     ${message}=  Fakerlibrary.Sentence
    Set Test Variable    ${message}

    ${primaryMobileNo2}    Generate random string    10    9874563211
    ${primaryMobileNo2}    Convert To Integer  ${primaryMobileNo2}
    Set Test Variable    ${primaryMobileNo2}
    Set Test Variable  ${email2}  ${lastName}${primaryMobileNo2}.${test_mail}

    ${sms1}=  Create Dictionary  countryCode=${${countryCodes[0]}}  number=${primaryMobileNo1}  
    Set Test Variable    ${sms1}

    ${whatsAppNumber1}=  Create Dictionary  countryCode=${${countryCodes[0]}}  number=${primaryMobileNo1}  
    Set Test Variable    ${whatsAppNumber1}

    ${telegramNumber1}=  Create Dictionary  countryCode=${${countryCodes[0]}}  number=${primaryMobileNo1}  
    Set Test Variable    ${telegramNumber1}

    ${resp}=    Share Prescription To ThirdParty   ${prescription_uid1}    ${message}    ${email2}       ${sms1}    ${whatsAppNumber1}    ${telegramNumber1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}     ${bool[1]}

JD-TC-Share Prescription To ThirdParty -4

    [Documentation]    Share multiple  Prescription To third party.

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=    Create Prescription    ${cid}    ${pid}    ${caseId}       ${id1}    ${html}       ${mrPrescriptions}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${prescription_uid1}   ${resp.json()}

    ${resp}=    Create Prescription    ${cid}    ${pid}    ${caseId}       ${id1}    ${html}       ${mrPrescriptions}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
     Set Test Variable    ${prescription_uid2}   ${resp.json()}

    ${message}=  Fakerlibrary.Sentence
    Set Test Variable    ${message}
    
    ${primaryMobileNo2}    Generate random string    10    9874563211
    ${primaryMobileNo2}    Convert To Integer  ${primaryMobileNo2}
    Set Test Variable    ${primaryMobileNo2}
    Set Test Variable  ${email2}  ${lastName}${primaryMobileNo2}.${test_mail}

    ${sms1}=  Create Dictionary  countryCode=${${countryCodes[0]}}  number=${primaryMobileNo1}  
    Set Test Variable    ${sms1}

    ${whatsAppNumber1}=  Create Dictionary  countryCode=${${countryCodes[0]}}  number=${primaryMobileNo1}  
    Set Test Variable    ${whatsAppNumber1}

    ${telegramNumber1}=  Create Dictionary  countryCode=${${countryCodes[0]}}  number=${primaryMobileNo1}  
    Set Test Variable    ${telegramNumber1}

    ${resp}=    Share Prescription To ThirdParty   ${prescription_uid1}    ${message}    ${email2}       ${sms1}    ${whatsAppNumber1}    ${telegramNumber1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}     ${bool[1]}

    ${resp}=    Share Prescription To ThirdParty   ${prescription_uid2}    ${message}    ${email2}       ${sms1}    ${whatsAppNumber1}    ${telegramNumber1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}     ${bool[1]}


JD-TC-Share Prescription To ThirdParty-5

    [Documentation]    Share Prescription To third party with empty whatsapp number.

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${message}=  Fakerlibrary.Sentence
    Set Test Variable    ${message}

    ${resp}=    Share Prescription To ThirdParty   ${prescription_uid}    ${message}    ${email}       ${sms}    ${whatsAppNumber}    ${empty}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}     ${bool[1]}

JD-TC-Share Prescription To ThirdParty-6

    [Documentation]    Share Prescription To third party with empty sms.

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${message}=  Fakerlibrary.Sentence
    Set Test Variable    ${message}

    ${resp}=    Share Prescription To ThirdParty   ${prescription_uid}    ${message}    ${email}     ${SPACE}    ${whatsAppNumber}    ${telegramNumber}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}     ${bool[1]}

JD-TC-Share Prescription To ThirdParty-7

    [Documentation]    Share Prescription To ThirdParty with empty whatsapp number.

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${message}=  Fakerlibrary.Sentence
    Set Test Variable    ${message}

    ${resp}=    Share Prescription To ThirdParty   ${prescription_uid}    ${message}    ${email}     ${sms}    ${empty}    ${telegramNumber}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}     ${bool[1]}

JD-TC-Share Prescription To ThirdParty-8

    [Documentation]    Share Prescription To third party with empty email ,whatsapp and sms.

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${message}=  Fakerlibrary.Sentence
    Set Test Variable    ${message}

    ${resp}=    Share Prescription To ThirdParty   ${prescription_uid}    ${message}    ${SPACE}       ${SPACE}    ${SPACE}    ${telegramNumber}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}     ${bool[1]}


JD-TC-Share Prescription To ThirdParty-UH1

    [Documentation]    Share Prescription To ThirdParty with invalid uid.

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${invalid}=  Random Int  min=500   max=1000
    Set Suite Variable    ${invalid}

     ${message}=  Fakerlibrary.Sentence
    Set Test Variable    ${message}

    ${PRESCRIPTION_NOT_FOUND}=  Format String    ${PRESCRIPTION_NOT_FOUND}    ${invalid}


    ${resp}=    Share Prescription To ThirdParty   ${invalid}   ${message}    ${email}       ${sms}    ${whatsAppNumber}    ${telegramNumber}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}     ${PRESCRIPTION_NOT_FOUND}

JD-TC-Share Prescription To ThirdParty-UH2

    [Documentation]    Share Prescription To ThirdParty with empty message.

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=    Share Prescription To ThirdParty   ${prescription_uid}    ${empty}     ${email}       ${sms}    ${whatsAppNumber}    ${telegramNumber} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}    ${MESSAGE_REQUIRED_TO_SHARE_PRESCRIPTION}


JD-TC-Share Prescription To ThirdParty-UH3

    [Documentation]    Try to remove shared prescription.

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${message}=  Fakerlibrary.Sentence
    Set Test Variable    ${message}

    ${resp}=    Share Prescription To ThirdParty   ${prescription_uid}    ${message}    ${email}       ${sms}    ${whatsAppNumber}    ${telegramNumber} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}     ${bool[1]}

    ${resp}=    Remove Prescription   ${prescription_uid}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}    ${NOT_ALLOWED_TO_SHAREPRESCRIPTION}

JD-TC-Share Prescription To ThirdParty-UH4

    [Documentation]     Share Prescription To ThirdParty where all medium is empty.

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${message}=  Fakerlibrary.Sentence
    Set Test Variable    ${message}

    ${resp}=    Share Prescription To ThirdParty   ${prescription_uid}    ${message}    ${empty}        ${empty}     ${empty}     ${empty}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}     ${INVALID_MEDIUM}

JD-TC-Share Prescription To ThirdParty-UH5

    [Documentation]   Share Prescription To ThirdParty where all medium is given as false.

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${message}=  Fakerlibrary.Sentence
    Set Test Variable    ${message}


    ${sms1}=  Create Dictionary  countryCode=${empty}  number=${empty}  
    Set Test Variable    ${sms1}

    ${whatsAppNumber1}=  Create Dictionary  countryCode=${empty}  number=${empty}   
    Set Test Variable    ${whatsAppNumber1}

    ${telegramNumber1}=  Create Dictionary  countryCode=${empty}  number=${empty}  
    Set Test Variable    ${telegramNumber1}

    ${resp}=    Share Prescription To ThirdParty   ${prescription_uid}    ${message}    ${empty}       ${sms1}    ${whatsAppNumber1}    ${telegramNumber1}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}     ${INVALID_EMAIL_FORMAT}

JD-TC-Share Prescription To ThirdParty-UH6

    [Documentation]    Share Prescription To third party with empty email.

    ${resp}=  Encrypted Provider Login    ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${message}=  Fakerlibrary.Sentence
    Set Test Variable    ${message}

    ${resp}=     Share Prescription To ThirdParty   ${prescription_uid}    ${message}    ${empty}       ${sms}    ${whatsAppNumber}    ${telegramNumber}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}     ${INVALID_EMAIL_FORMAT}

JD-TC-Share Prescription To ThirdParty-UH7

    [Documentation]   Share Prescription To ThirdParty  with another provider login

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME15}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200
    

     ${message}=  Fakerlibrary.Sentence
    Set Test Variable    ${message}

     ${resp}=    Share Prescription To ThirdParty   ${prescription_uid}    ${message}    ${email1}       ${sms}    ${whatsAppNumber}    ${telegramNumber}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}  401
    Should Be Equal As Strings  ${resp.json()}    ${NO_PERMISSION}

JD-TC-Share Prescription To ThirdParty-UH8

    [Documentation]   Share Prescription To ThirdParty  without login

    ${message}=  Fakerlibrary.Sentence
    Set Test Variable    ${message}

   ${resp}=    Share Prescription To ThirdParty   ${prescription_uid}    ${message}    ${email1}       ${sms}    ${whatsAppNumber}    ${telegramNumber}  
    Log   ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}

 
