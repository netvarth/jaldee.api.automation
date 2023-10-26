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

JD-TC-Get Prescription Count By Filter-1

    [Documentation]   Get Prescription Count By Filter

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
     ${MUSERNAME_E}=  Evaluate  ${MUSERNAME}+9774517
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

    # ${resp}=  Encrypted Provider Login    ${MUSERNAME_E}  ${PASSWORD}
    # Log  ${resp.json()}         
    # Should Be Equal As Strings            ${resp.status_code}    200

    # ${decrypted_data}=  db.decrypt_data   ${resp.content}
    # Log  ${decrypted_data}

    # Set Suite Variable  ${pid}  ${decrypted_data['id']}
    # Set Suite Variable    ${pdrname}    ${decrypted_data['userName']}
    # Set Suite Variable    ${pdrfname}    ${decrypted_data['firstName']}
    # Set Suite Variable    ${pdrlname}    ${decrypted_data['lastName']}

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
    ${note}=  FakerLibrary.Text  max_nb_chars=42 

    ${resp}=    Create Prescription    ${cid}    ${pid}    ${caseId}       ${id1}    ${html}     ${mrPrescriptions}    prescriptionNotes=${note}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${prescription_uid}   ${resp.json()}

    ${resp}=    Get Prescription By Provider consumer Id   ${cid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${referenceId}   ${resp.json()[0]['referenceId']}   
    Set Suite Variable  ${uid}   ${resp.json()[0]['uid']}
    Set Suite Variable  ${prescriptionStatus}   ${resp.json()[0]['prescriptionStatus']}
    

    ${resp1}=  Get Prescription Count By Filter   providerConsumerId-eq=${cid}  uid-eq=${uid}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Should Be Equal As Strings    ${resp.json()[0]['uid']}     ${prescription_uid} 
    Should Be Equal As Strings    ${resp.json()[0]['providerConsumerId']}     ${cid} 
    Should Be Equal As Strings    ${resp.json()[0]['doctorId']}     ${pid} 
    Should Be Equal As Strings    ${resp.json()[0]['caseId']}     ${caseId} 
    Should Be Equal As Strings    ${resp.json()[0]['dentalRecordId']}     ${id1} 
    Should Be Equal As Strings    ${resp.json()[0]['mrPrescriptions'][0]['medicineName']}     ${med_name} 
    Should Be Equal As Strings    ${resp.json()[0]['mrPrescriptions'][0]['frequency']}     ${frequency} 
    Should Be Equal As Strings    ${resp.json()[0]['mrPrescriptions'][0]['duration']}     ${duration} 
    Should Be Equal As Strings    ${resp.json()[0]['mrPrescriptions'][0]['instructions']}     ${instrn} 
    Should Be Equal As Strings    ${resp.json()[0]['mrPrescriptions'][0]['dosage']}     ${dosage} 
    Should Be Equal As Strings    ${resp.json()[0]['prescriptionCreatedByName']}     ${pdrname} 
    Should Be Equal As Strings    ${resp.json()[0]['prescriptionCreatedBy']}     ${id} 
    Should Be Equal As Strings    ${resp.json()[0]['prescriptionCreatedDate']}     ${DAY1}
    Should Be Equal As Strings    ${resp.json()[0]['prescriptionNotes']}     ${note}
 
JD-TC-Get Prescription Count By Filter-2

    [Documentation]    Create Prescription with Empty caseId Get Prescription Count By Filter.

    ${resp}=  Encrypted Provider Login    ${MUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

     ${med_name1}=      FakerLibrary.name
    Set Suite Variable    ${med_name1}
    ${frequency1}=     FakerLibrary.word
     Set Suite Variable     ${frequency1}
    ${duration1}=      FakerLibrary.sentence
     Set Suite Variable     ${duration1}
    ${instrn1}=        FakerLibrary.sentence
     Set Suite Variable    ${instrn1}
    ${dosage1}=        FakerLibrary.sentence
      Set Suite Variable     ${dosage1}

    ${userid2}=   Random Int  min=1000   max=2000

    ${mrPrescriptions1}=  Create Dictionary  medicineName=${med_name1}  frequency=${frequency1}  duration=${duration1}  instructions=${instrn1}  dosage=${dosage1}
    Set Suite Variable    ${mrPrescriptions1}

    ${resp}=    Create Prescription    ${cid}    ${pid}    ${order}       ${id1}    ${html}     ${mrPrescriptions1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${prescription_uid}   ${resp.json()}

    ${resp}=  Get Prescription Count By Filter   providerConsumerId-eq=${cid}   dentalRecordId-eq=${id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-Get Prescription Count By Filter-3

    [Documentation]    Create Prescription with Empty dentalRecordId and Get Prescription Count By Filter .

    ${resp}=  Encrypted Provider Login    ${MUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=    Create Prescription    ${cid}    ${pid}    ${caseId}       ${EMPTY}    ${html}      ${mrPrescriptions}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${prescription_uid1}   ${resp.json()}

    ${resp}=  Get Prescription Count By Filter   providerConsumerId-eq=${cid}   mrPrescriptionStatus-eq=${prescriptionStatus}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-Get Prescription Count By Filter-4

    [Documentation]    Create Prescription with Empty html Get Prescription Count By Filter.

    ${resp}=  Encrypted Provider Login    ${MUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=    Create Prescription    ${cid}    ${pid}    ${caseId}       ${id1}    ${EMPTY}   prescriptionAttachments=${prescriptionAttachments}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${prescription_uid1}  ${resp.json()}
    
    ${resp}=  Get Prescription Count By Filter   providerConsumerId-eq=${cid}   referenceId-eq=${referenceId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-Get Prescription Count By Filter-UH1

    [Documentation]     Get Prescription Count By Filter  using user login.(user is not added in mr case)

    ${resp}=  Encrypted Provider Login    ${MUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${u_id}=  Create Sample User
    Set Suite Variable  ${u_id}

    ${resp}=  Get User By Id      ${u_id}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${PUSERNAME_U1}     ${resp.json()['mobileNo']}
    Set Suite Variable      ${sam_email}     ${resp.json()['email']}

    ${resp}=  SendProviderResetMail   ${sam_email}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${sam_email}  ${PASSWORD}  ${OtpPurpose['ProviderResetPassword']}
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${sam_email}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Prescription By Provider consumer Id   ${cid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Prescription Count By Filter   providerConsumerId-eq=${cid}   referenceId-eq=${referenceId}  mrPrescriptionStatus-eq=${prescriptionStatus}   dentalRecordId-eq=${id1}   uid-eq=${uid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${resp.content}    ${order}
   


JD-TC-Get Prescription Count By Filter-UH2

    [Documentation]   Get Prescription Count By Filter with Empty ProviderConsumer id.

    ${resp}=  Encrypted Provider Login    ${MUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=  Get Prescription Count By Filter      referenceId-eq=${referenceId}  mrPrescriptionStatus-eq=${prescriptionStatus}   dentalRecordId-eq=${id1}   uid-eq=${uid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.content}     "${PROVIDER_CONSUMER_ID_NEEDED_IN_FILTER}"


JD-TC-Get Prescription Count By Filter-UH3

    [Documentation]    Create Prescription with another provider login

    ${resp}=  Encrypted Provider Login    ${HLMUSERNAME4}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200
   

    ${resp}=  Get Prescription Count By Filter   providerConsumerId-eq=${cid}   referenceId-eq=${referenceId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${resp.content}    ${order}

JD-TC-Get Prescription Count By Filter-UH4

    [Documentation]    Get Prescription By Filter with invalid ProviderConsumer id.

    ${resp}=  Encrypted Provider Login    ${MUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${fake_id}=  Random Int  min=500   max=1000

    ${resp}=  Get Prescription Count By Filter   providerConsumerId-eq=${fake_id}   referenceId-eq=${referenceId}  mrPrescriptionStatus-eq=${prescriptionStatus}   dentalRecordId-eq=${id1}   uid-eq=${uid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}  200
    Should Be Equal As Strings    ${resp.content}    ${order}
   