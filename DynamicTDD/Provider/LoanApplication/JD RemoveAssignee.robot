*** Settings ***
Suite Teardown    Delete All Sessions 
Test Teardown     Delete All Sessions
Force Tags        LOAN
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py
Variables         /ebs/TDD/varfiles/musers.py
Variables         /ebs/TDD/varfiles/hl_musers.py

*** Variables ***

@{emptylist}

${jpgfile}      /ebs/TDD/uploadimage.jpg
${pngfile}      /ebs/TDD/upload.png
${pdffile}      /ebs/TDD/sample.pdf

${order}    0
${fileSize}  0.00458

${phonez}   7024567616

*** Test Cases ***

JD-TC-RemoveAssignee-1
                                  
    [Documentation]               Remove Assignee for Loan Application
    ${resp}=  Consumer Login  ${CUSERNAME14}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login        ${HLMUSERNAME8}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}    200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
    ELSE
        Set Test Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${place}  ${resp.json()[0]['place']}
    END

    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Suite Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Suite Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}

    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END   

    ${uid}=    Create Sample User
    ${uid}=     Convert To String  ${uid}
    Set Suite Variable      ${uid}

    ${resp}=    Get User By Id      ${uid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    
    Set Suite Variable      ${fname}  ${resp.json()['firstName']}
    Set Suite Variable      ${lname}  ${resp.json()['lastName']}
    Set Suite Variable      ${employeeId}   ${resp.json()['employeeId']}

    ${assigneduser}=  Create Dictionary  id=${uid}
    Set Suite Variable      ${assigneduser}


    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME14}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME14}  firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${pcid14}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${pcid14}  ${resp.json()[0]['id']}
    END
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME14}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable    ${phone}   ${resp.json()[0]['phoneNo']}
    Set Suite Variable    ${cc}   ${resp.json()[0]['countryCode']}
    Set Suite Variable    ${email}  ${fname}${C_Email}.${test_mail}

    ${resp}=  categorytype   ${account_id}
    ${resp}=  tasktype       ${account_id}
    ${resp}=  loanStatus     ${account_id}
    ${resp}=  loanProduct    ${account_id}
    ${resp}=  loanScheme     ${account_id}

    ${resp}=    Get Loan Application Category
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${categoryid}  ${resp.json()[0]['id']}

    ${resp}=    Get Loan Application Type
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${typeid}  ${resp.json()[0]['id']}

    ${resp}=    Get Loan Application Status
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${statusid}  ${resp.json()[0]['id']}

    ${resp}=    Get Loan Application Product
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${Productid}  ${resp.json()[0]['id']}

    ${resp}=    Get Loan Application Scheme
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${Schemeid}  ${resp.json()[0]['id']}

    ${invoiceAmount}         FakerLibrary.Random Number
    Set Suite Variable       ${invoiceAmount}
    ${downpaymentAmount}     FakerLibrary.Random Number
    Set Suite Variable       ${downpaymentAmount}
    ${requestedAmount}       FakerLibrary.Random Number
    Set Suite Variable       ${requestedAmount}
    ${remarks}               FakerLibrary.sentence
    Set Suite Variable       ${remarks}
    ${monthlyIncome}         FakerLibrary.Random Number
    Set Suite Variable       ${monthlyIncome}
    ${aadhaar}               FakerLibrary.Random Number
    Set Suite Variable       ${aadhaar}
    ${pan}                   FakerLibrary.Random Number
    Set Suite Variable       ${pan}
    ${nomineeName}           FakerLibrary.name
    Set Suite Variable       ${nomineeName}
    ${permanentAddress1}     FakerLibrary.Street name
    Set Suite Variable       ${permanentAddress1}
    ${permanentAddress2}     FakerLibrary.Street name
    Set Suite Variable       ${permanentAddress2}
    ${permanentPin}          FakerLibrary.zipcode
    Set Suite Variable       ${permanentPin}
    ${permanentCity}         FakerLibrary.word
    Set Suite Variable       ${permanentCity}
    ${permanentState}        FakerLibrary.state
    Set Suite Variable       ${permanentState}
    ${currentAddress1}       FakerLibrary.Street name
    Set Suite Variable       ${currentAddress1}
    ${currentAddress2}       FakerLibrary.Street name
    Set Suite Variable       ${currentAddress2}
    ${currentPin}            FakerLibrary.zipcode
    Set Suite Variable       ${currentPin}
    ${currentCity}           FakerLibrary.word
    Set Suite Variable       ${currentCity}
    ${currentState}          FakerLibrary.state
    Set Suite Variable       ${currentState}

    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType1}
    ${caption1}=  Fakerlibrary.Sentence
    Set Suite Variable    ${caption1}

    ${resp}=  db.getType   ${pngfile}
    Log  ${resp}
    ${fileType2}=  Get From Dictionary       ${resp}    ${pngfile}
    Set Suite Variable    ${fileType2}

    ${resp}=  db.getType   ${pdffile} 
    Log  ${resp}
    ${fileType3}=  Get From Dictionary       ${resp}    ${pdffile} 
    Set Suite Variable    ${fileType3}
    ${caption1}=  Fakerlibrary.Sentence

    ${otherAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${jpgfile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType1}  order=${order}
    ${otherAttachmentsList}=    Create List  ${otherAttachments}

    ${panAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${pngfile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType2}  order=${order}
    ${panAttachments}=    Create List  ${panAttachments}

    ${aadhaarAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType3}  order=${order}
    ${aadhaarAttachments}=    Create List  ${aadhaarAttachments}

    ${kyc_list1}=           Create Dictionary  isCoApplicant=${bool[0]}  maritalStatus=${maritalStatus[1]}  employmentStatus=${employmentStatus[0]}  monthlyIncome=${monthlyIncome}  aadhaar=${aadhaar}  pan=${pan}  isAadhaarVerified=${bool[1]}  isPanVerified=${bool[1]}  nomineeType=${nomineeType[1]}  nomineeName=${nomineeName}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentPin=${permanentPin}  permanentCity=${permanentCity}  permanentState=${permanentState}  currentAddress1=${currentAddress1}  currentAddress2=${currentAddress2}  currentPin=${currentPin}  currentCity=${currentCity}  currentState=${currentState}    otherAttachments=${otherAttachmentsList}  panAttachments=${panAttachments}  aadhaarAttachments=${aadhaarAttachments}
    Log  ${kyc_list1}
    # ${Assignee}=       Create Dictionary    id=${pcid14}

    ${resp}=  Create Loan Application    ${pcid14}  ${fname}  ${lname}  ${phone}  ${cc}  ${email}  ${categoryid}  ${typeid}  ${Productid}  ${locId}  ${place}  ${invoiceAmount}  ${downpaymentAmount}  ${requestedAmount}  ${remarks}  ${LoanAction[0]}  ${pcid14}  ${jpgfile}  ${fileSize}  ${caption1}  ${fileType1}  ${order}  ${kyc_list1}    
    # Assignee=${Assignee}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Test Variable  ${loanid}  ${resp.json()['id']}
    Set Suite Variable  ${loanUid}  ${resp.json()['uid']} 

    ${resp}=    Get Loan Application With Filter    
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Suite Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Suite Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}

    ${uid}=    Create Sample User
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${uid}=     Convert To String  ${uid}
    Set Suite Variable      ${uid}

    ${resp}=    Get User By Id      ${uid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    
    Set Suite Variable      ${fname}  ${resp.json()['firstName']}
    Set Suite Variable      ${lname}  ${resp.json()['lastName']}
    Set Suite Variable      ${employeeId}   ${resp.json()['employeeId']}

    ${assigneduser}=  Create Dictionary  id=${uid}
    Set Suite Variable      ${assigneduser}

    ${resp}=    Change Loan Assignee        ${loanUid}    ${uid}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Loan Application With Filter    
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()[0]['assignee']['id']}  ${uid}
    Set Suite Variable    ${lid}    ${resp.json()[0]['uid']}

    ${resp}=    Remove Assignee    ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get Loan Application With Filter    
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-RemoveAssignee-UH1
                                  
    [Documentation]               Remove Assignee for Loan Application Which is already removed
    
    ${resp}=  Encrypted Provider Login        ${HLMUSERNAME8}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}    200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
    ELSE
        Set Test Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${place}  ${resp.json()[0]['place']}
    END

    ${otherAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${jpgfile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType1}  order=${order}
    ${otherAttachmentsList}=    Create List  ${otherAttachments}

    ${panAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${pngfile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType2}  order=${order}
    ${panAttachments}=    Create List  ${panAttachments}

    ${aadhaarAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType3}  order=${order}
    ${aadhaarAttachments}=    Create List  ${aadhaarAttachments}

    ${kyc_list1}=           Create Dictionary  isCoApplicant=${bool[0]}  maritalStatus=${maritalStatus[1]}  employmentStatus=${employmentStatus[0]}  monthlyIncome=${monthlyIncome}  aadhaar=${aadhaar}  pan=${pan}  isAadhaarVerified=${bool[1]}  isPanVerified=${bool[1]}  nomineeType=${nomineeType[1]}  nomineeName=${nomineeName}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentPin=${permanentPin}  permanentCity=${permanentCity}  permanentState=${permanentState}  currentAddress1=${currentAddress1}  currentAddress2=${currentAddress2}  currentPin=${currentPin}  currentCity=${currentCity}  currentState=${currentState}    otherAttachments=${otherAttachmentsList}  panAttachments=${panAttachments}  aadhaarAttachments=${aadhaarAttachments}
    Log  ${kyc_list1}


    ${resp}=  Create Loan Application    ${pcid14}  ${fname}  ${lname}  ${phone}  ${cc}  ${email}  ${categoryid}  ${typeid}  ${Productid}  ${locId}  ${place}  ${invoiceAmount}  ${downpaymentAmount}  ${requestedAmount}  ${remarks}  ${LoanAction[0]}  ${pcid14}  ${jpgfile}  ${fileSize}  ${caption1}  ${fileType1}  ${order}  ${kyc_list1}    
    # Assignee=${Assignee}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Test Variable  ${loanid}  ${resp.json()['id']}
    Set Suite Variable  ${loanUid}  ${resp.json()['uid']} 

    ${resp}=    Get Loan Application With Filter    
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Suite Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Suite Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}

    ${uid}=    Create Sample User
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${uid}=     Convert To String  ${uid}
    Set Suite Variable      ${uid}

    ${resp}=    Get User By Id      ${uid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    
    Set Suite Variable      ${fname}  ${resp.json()['firstName']}
    Set Suite Variable      ${lname}  ${resp.json()['lastName']}
    Set Suite Variable      ${employeeId}   ${resp.json()['employeeId']}

    ${assigneduser}=  Create Dictionary  id=${uid}
    Set Suite Variable      ${assigneduser}

    ${resp}=    Change Loan Assignee        ${loanUid}    ${uid}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Loan Application With Filter    
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()[0]['assignee']['id']}  ${uid}
    Set Suite Variable    ${lid}    ${resp.json()[0]['uid']}

    ${resp}=    Remove Assignee    ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Remove Assignee    ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}  ${ASSIGNEE_NOT_FOUND}

JD-TC-RemoveAssignee-UH2
                                  
    [Documentation]               Remove Assignee for Loan Application Without provider login

    ${resp}=    Remove Assignee    ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    419
    Should Be Equal As Strings   ${resp.json()}  ${SESSION_EXPIRED}

JD-TC-RemoveAssignee-UH3
                                  
    [Documentation]               Remove Assignee for Loan Application With invalid loan is
    
    ${resp}=  Encrypted Provider Login        ${HLMUSERNAME8}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}    200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
    ELSE
        Set Test Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${place}  ${resp.json()[0]['place']}
    END

    ${otherAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${jpgfile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType1}  order=${order}
    ${otherAttachmentsList}=    Create List  ${otherAttachments}

    ${panAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${pngfile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType2}  order=${order}
    ${panAttachments}=    Create List  ${panAttachments}

    ${aadhaarAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType3}  order=${order}
    ${aadhaarAttachments}=    Create List  ${aadhaarAttachments}

    ${kyc_list1}=           Create Dictionary  isCoApplicant=${bool[0]}  maritalStatus=${maritalStatus[1]}  employmentStatus=${employmentStatus[0]}  monthlyIncome=${monthlyIncome}  aadhaar=${aadhaar}  pan=${pan}  isAadhaarVerified=${bool[1]}  isPanVerified=${bool[1]}  nomineeType=${nomineeType[1]}  nomineeName=${nomineeName}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentPin=${permanentPin}  permanentCity=${permanentCity}  permanentState=${permanentState}  currentAddress1=${currentAddress1}  currentAddress2=${currentAddress2}  currentPin=${currentPin}  currentCity=${currentCity}  currentState=${currentState}    otherAttachments=${otherAttachmentsList}  panAttachments=${panAttachments}  aadhaarAttachments=${aadhaarAttachments}
    Log  ${kyc_list1}


    ${resp}=  Create Loan Application    ${pcid14}  ${fname}  ${lname}  ${phone}  ${cc}  ${email}  ${categoryid}  ${typeid}  ${Productid}  ${locId}  ${place}  ${invoiceAmount}  ${downpaymentAmount}  ${requestedAmount}  ${remarks}  ${LoanAction[0]}  ${pcid14}  ${jpgfile}  ${fileSize}  ${caption1}  ${fileType1}  ${order}  ${kyc_list1}    
    # Assignee=${Assignee}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Test Variable  ${loanid}  ${resp.json()['id']}
    Set Suite Variable  ${loanUid}  ${resp.json()['uid']} 

    ${resp}=    Get Loan Application With Filter    
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Suite Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Suite Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}

    ${uid}=    Create Sample User
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${uid}=     Convert To String  ${uid}
    Set Suite Variable      ${uid}

    ${resp}=    Get User By Id      ${uid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    
    Set Suite Variable      ${fname}  ${resp.json()['firstName']}
    Set Suite Variable      ${lname}  ${resp.json()['lastName']}
    Set Suite Variable      ${employeeId}   ${resp.json()['employeeId']}

    ${assigneduser}=  Create Dictionary  id=${uid}
    Set Suite Variable      ${assigneduser}

    ${resp}=    Change Loan Assignee        ${loanUid}    ${uid}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Loan Application With Filter    
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()[0]['assignee']['id']}  ${uid}
    Set Suite Variable    ${lid}    ${resp.json()[0]['uid']}

    ${loan_id}=  Generate Random String  3  [NUMBERS]

    ${resp}=    Remove Assignee    ${loan_id}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}  ${INVALID_LOAN_APPLICATION_ID}