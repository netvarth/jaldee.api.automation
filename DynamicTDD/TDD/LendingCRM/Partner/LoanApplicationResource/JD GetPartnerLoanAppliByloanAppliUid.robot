*** Settings ***
Suite Teardown    Delete All Sessions 
Test Teardown     Delete All Sessions
Force Tags        LOAN
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py
Resource          /ebs/TDD/ProviderPartnerKeywords.robot


*** Variables ***

@{emptylist}

${jpgfile}      /ebs/TDD/uploadimage.jpg
${pngfile}      /ebs/TDD/upload.png
${pdffile}      /ebs/TDD/sample.pdf

${order}    0
${fileSize}  0.00458

*** Test Cases ***

JD-TC-Get PartnerLoanApplicationbyloanApplicationUid-1
                                  
    [Documentation]               Create Loan Application and Get Loan Application by loanApplicationUid.

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

   ${resp}=   Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

*** Comments ***

    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${provider_id}  ${decrypted_data['id']}

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

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME15}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME15}  firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${pcid14}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${pcid14}  ${resp.json()[0]['id']}
    END

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME15}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable    ${phone}   ${resp.json()[0]['phoneNo']}
    Set Test Variable    ${cc}   ${resp.json()[0]['countryCode']}
    Set Test Variable    ${email}  ${fname}${C_Email}.${test_mail}

    ${resp}=  categorytype   ${account_id}
    ${resp}=  tasktype       ${account_id}
    ${resp}=  loanStatus     ${account_id}
    ${resp}=  loanProduct    ${account_id}
    ${resp}=  loanScheme     ${account_id}

    ${resp}=    Get Partner Loan Application Category
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${categoryid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${categoryname}  ${resp.json()[0]['name']}

    Set Suite Variable  ${categoryid1}  ${resp.json()[1]['id']}
    Set Suite Variable  ${categoryname1}  ${resp.json()[1]['name']}


    ${resp}=    Get Partner Loan Application Type
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${typeid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${typename}  ${resp.json()[0]['name']}

    Set Suite Variable  ${typeid1}  ${resp.json()[1]['id']}
    Set Suite Variable  ${typename1}  ${resp.json()[1]['name']}


    ${resp}=    Get Partner Loan Application Status
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${statusid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${statusname}  ${resp.json()[0]['name']}
    

    ${resp}=   Get Partner Loan Application Product
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${Productid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${Productid1}  ${resp.json()[1]['id']}
    Set Suite Variable  ${Productid2}  ${resp.json()[2]['id']}

    ${resp}=    Get Partner Loan Application Scheme
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${Schemeid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${Schemeid1}  ${resp.json()[1]['id']}
    Set Suite Variable  ${Schemeid2}  ${resp.json()[2]['id']}


    ${invoiceAmount}         FakerLibrary.Random Number
    ${downpaymentAmount}     FakerLibrary.Random Number
    ${requestedAmount}       FakerLibrary.Random Number
    ${remarks}               FakerLibrary.sentence
    
    # ${maritalStatus}         Evaluate  random.choice($MaritalStatus)  random
    # ${employmentStatus}      Evaluate  random.choice($EmploymentStatus)  random
    ${monthlyIncome}         FakerLibrary.Random Number
    ${monthlyIncome}=   Convert To Number   ${monthlyIncome}  1
    Set Suite Variable  ${monthlyIncome}
    ${aadhaar}               FakerLibrary.Random Number
    ${pan}                   FakerLibrary.Random Number
    # ${nomineeType}           Evaluate  random.choice($NomineeType)  random
    ${nomineeName}           FakerLibrary.name
    ${permanentAddress1}     FakerLibrary.Street name
    ${permanentAddress2}     FakerLibrary.Street name
    ${permanentPin}          FakerLibrary.zipcode
    ${permanentCity}         FakerLibrary.word
    ${permanentState}        FakerLibrary.state
    ${currentAddress1}       FakerLibrary.Street name
    ${currentAddress2}       FakerLibrary.Street name
    ${currentPin}            FakerLibrary.zipcode
    ${currentCity}           FakerLibrary.word
    ${currentState}          FakerLibrary.state

    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType1}
    ${caption1}=  Fakerlibrary.Sentence

    ${resp}=  db.getType   ${pngfile}
    Log  ${resp}
    ${fileType2}=  Get From Dictionary       ${resp}    ${pngfile}
    Set Suite Variable    ${fileType2}
    ${caption2}=  Fakerlibrary.Sentence

    ${resp}=  db.getType   ${pdffile} 
    Log  ${resp}
    ${fileType3}=  Get From Dictionary       ${resp}    ${pdffile} 
    Set Suite Variable    ${fileType3}
    ${caption3}=  Fakerlibrary.Sentence

    ${otherAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${jpgfile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType1}  order=${order}
    ${otherAttachmentsList}=    Create List  ${otherAttachments}

    ${panAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${pngfile}  fileSize=${fileSize}  caption=${caption2}  fileType=${fileType2}  order=${order}
    ${panAttachments}=    Create List  ${panAttachments}

    ${aadhaarAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption3}  fileType=${fileType3}  order=${order}
    ${aadhaarAttachments}=    Create List  ${aadhaarAttachments}


    ${kyc_list1}=           Create Dictionary  isCoApplicant=${bool[0]}  maritalStatus=${maritalStatus[1]}  employmentStatus=${employmentStatus[0]}  monthlyIncome=${monthlyIncome}  aadhaar=${aadhaar}  pan=${pan}  isAadhaarVerified=${bool[1]}  
    ...  isPanVerified=${bool[1]}  nomineeType=${nomineeType[1]}  nomineeName=${nomineeName}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentPin=${permanentPin}  permanentCity=${permanentCity} 
    ...  permanentState=${permanentState}  currentAddress1=${currentAddress1}  currentAddress2=${currentAddress2}  currentPin=${currentPin}  currentCity=${currentCity}  currentState=${currentState}    otherAttachments=${otherAttachmentsList}  panAttachments=${panAttachments}  aadhaarAttachments=${aadhaarAttachments}
    Log  ${kyc_list1}
    ${resp}=  Create Partner Loan Application    ${pcid14}    ${fname}  ${lname}  ${phone}  ${cc}  ${email}  ${categoryid}  ${typeid}  ${Productid}  ${locId}  ${place}  ${invoiceAmount}  ${downpaymentAmount}  ${requestedAmount}  ${remarks}    ${LoanAction[0]}  ${pcid14}  ${jpgfile}  ${fileSize}  ${caption1}  ${fileType1}  ${order}  ${kyc_list1}

    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${loanid}   ${resp.json()['id']}
    Set Suite Variable  ${loanUid}   ${resp.json()['uid']}


    # ${resp}=    Get Loan Application With Filter    
    # Log    ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings   ${resp.json()[0]['id']}  ${loanid}
    # Should Be Equal As Strings   ${resp.json()[0]['uid']}  ${loanUid}
    # Set Suite Variable  ${refNo}   ${resp.json()[0]['referenceNo']}


    ${resp}=    Get Partner Loan Application by loanApplicationRefNo    ${loanUid} 
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['id']}  ${loanid}
    Should Be Equal As Strings   ${resp.json()['uid']}  ${loanUid}
    Should Be Equal As Strings   ${resp.json()['accountId']}  ${account_id}
    Should Be Equal As Strings   ${resp.json()['customer']['id']}  ${pcid14}
    Should Be Equal As Strings   ${resp.json()['remarks']}  ${remarks}
    Should Be Equal As Strings   ${resp.json()['category']['id']}  ${categoryid}
    Should Be Equal As Strings   ${resp.json()['type']['id']}  ${typeid}
    Should Be Equal As Strings   ${resp.json()['loanProduct']['id']}  ${Productid}

    Should Be Equal As Strings   ${resp.json()['loanApplicationKycList'][0]['originUid']}  ${loanUid}
    Should Be Equal As Strings   ${resp.json()['loanApplicationKycList'][0]['loanApplicationUid']}  ${loanUid}
    Should Be Equal As Strings   ${resp.json()['loanApplicationKycList'][0]['isCoApplicant']}  ${bool[0]}
    Should Be Equal As Strings   ${resp.json()['loanApplicationKycList'][0]['customerId']}  ${pcid14}
    Should Be Equal As Strings   ${resp.json()['loanApplicationKycList'][0]['maritalStatus']}  ${maritalStatus[1]}
    Should Be Equal As Strings   ${resp.json()['loanApplicationKycList'][0]['employmentStatus']}  ${employmentStatus[0]}
    Should Be Equal As Strings   ${resp.json()['loanApplicationKycList'][0]['monthlyIncome']}  ${monthlyIncome}
    Should Be Equal As Strings   ${resp.json()['loanApplicationKycList'][0]['aadhaar']}  ${aadhaar}
    Should Be Equal As Strings   ${resp.json()['loanApplicationKycList'][0]['pan']}  ${pan}
    Should Be Equal As Strings   ${resp.json()['loanApplicationKycList'][0]['isAadhaarVerified']}  ${bool[1]}
    Should Be Equal As Strings   ${resp.json()['loanApplicationKycList'][0]['isPanVerified']}  ${bool[1]} 
    Should Be Equal As Strings   ${resp.json()['loanApplicationKycList'][0]['nomineeType']}  ${nomineeType[1]}
    Should Be Equal As Strings   ${resp.json()['loanApplicationKycList'][0]['nomineeName']}  ${nomineeName}
    Should Be Equal As Strings   ${resp.json()['loanApplicationKycList'][0]['permanentAddress1']}  ${permanentAddress1}
    Should Be Equal As Strings   ${resp.json()['loanApplicationKycList'][0]['permanentAddress2']}  ${permanentAddress2}
    Should Be Equal As Strings   ${resp.json()['loanApplicationKycList'][0]['permanentCity']}  ${permanentCity}
    Should Be Equal As Strings   ${resp.json()['loanApplicationKycList'][0]['permanentState']}  ${permanentState}
    Should Be Equal As Strings   ${resp.json()['loanApplicationKycList'][0]['permanentPin']}  ${permanentPin}
    Should Be Equal As Strings   ${resp.json()['loanApplicationKycList'][0]['currentAddress1']}  ${currentAddress1}
    Should Be Equal As Strings   ${resp.json()['loanApplicationKycList'][0]['currentAddress2']}  ${currentAddress2}
    Should Be Equal As Strings   ${resp.json()['loanApplicationKycList'][0]['currentCity']}  ${currentCity}
    Should Be Equal As Strings   ${resp.json()['loanApplicationKycList'][0]['currentState']}  ${currentState}
    Should Be Equal As Strings   ${resp.json()['loanApplicationKycList'][0]['currentPin']}  ${currentPin}

    Should Be Equal As Strings   ${resp.json()['loanApplicationKycList'][0]['aadhaarAttachments'][0]['owner']}  ${pcid14}
    Should Be Equal As Strings   ${resp.json()['loanApplicationKycList'][0]['aadhaarAttachments'][0]['fileName']}  ${pdffile}
    Should Be Equal As Strings   ${resp.json()['loanApplicationKycList'][0]['aadhaarAttachments'][0]['fileSize']}  ${fileSize}
    Should Be Equal As Strings   ${resp.json()['loanApplicationKycList'][0]['aadhaarAttachments'][0]['caption']}  ${caption3}
    Should Be Equal As Strings   ${resp.json()['loanApplicationKycList'][0]['aadhaarAttachments'][0]['fileType']}  ${fileType3}
    Should Be Equal As Strings   ${resp.json()['loanApplicationKycList'][0]['aadhaarAttachments'][0]['order']}  ${order}
    Should Be Equal As Strings   ${resp.json()['loanApplicationKycList'][0]['aadhaarAttachments'][0]['action']}  ${LoanAction[0]}

    Should Be Equal As Strings   ${resp.json()['loanApplicationKycList'][0]['panAttachments'][0]['owner']}  ${pcid14}
    Should Be Equal As Strings   ${resp.json()['loanApplicationKycList'][0]['panAttachments'][0]['fileName']}  ${pngfile}
    Should Be Equal As Strings   ${resp.json()['loanApplicationKycList'][0]['panAttachments'][0]['fileSize']}  ${fileSize}
    Should Be Equal As Strings   ${resp.json()['loanApplicationKycList'][0]['panAttachments'][0]['caption']}  ${caption2}
    Should Be Equal As Strings   ${resp.json()['loanApplicationKycList'][0]['panAttachments'][0]['fileType']}  ${fileType2}
    Should Be Equal As Strings   ${resp.json()['loanApplicationKycList'][0]['panAttachments'][0]['order']}  ${order}
    Should Be Equal As Strings   ${resp.json()['loanApplicationKycList'][0]['panAttachments'][0]['action']}  ${LoanAction[0]}

    Should Be Equal As Strings   ${resp.json()['loanApplicationKycList'][0]['otherAttachments'][0]['owner']}  ${pcid14}
    Should Be Equal As Strings   ${resp.json()['loanApplicationKycList'][0]['otherAttachments'][0]['fileName']}  ${jpgfile}
    Should Be Equal As Strings   ${resp.json()['loanApplicationKycList'][0]['otherAttachments'][0]['fileSize']}  ${fileSize}
    Should Be Equal As Strings   ${resp.json()['loanApplicationKycList'][0]['otherAttachments'][0]['caption']}  ${caption1}
    Should Be Equal As Strings   ${resp.json()['loanApplicationKycList'][0]['otherAttachments'][0]['fileType']}  ${fileType1}
    Should Be Equal As Strings   ${resp.json()['loanApplicationKycList'][0]['otherAttachments'][0]['order']}  ${order}
    Should Be Equal As Strings   ${resp.json()['loanApplicationKycList'][0]['otherAttachments'][0]['action']}  ${LoanAction[0]}

    Should Be Equal As Strings   ${resp.json()['consumerPhoto'][0]['owner']}  ${pcid14}
    Should Be Equal As Strings   ${resp.json()['consumerPhoto'][0]['fileName']}  ${jpgfile}
    Should Be Equal As Strings   ${resp.json()['consumerPhoto'][0]['fileSize']}  ${fileSize}
    Should Be Equal As Strings   ${resp.json()['consumerPhoto'][0]['caption']}  ${caption1}
    Should Be Equal As Strings   ${resp.json()['consumerPhoto'][0]['fileType']}  ${fileType1}
    Should Be Equal As Strings   ${resp.json()['consumerPhoto'][0]['order']}  ${order}
    Should Be Equal As Strings   ${resp.json()['consumerPhoto'][0]['action']}  ${LoanAction[0]}

*** Comments ***

JD-TC-GetLoanApplicationbyRefNo-UH1
                                  
    [Documentation]           GGet Loan Application by loanApplicationRefNo with consumer login
    
    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=    Get Loan Application by loanApplicationRefNo     ${loanUid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    401
    Should Be Equal As Strings    ${resp.json()}   ${NoAccess}

JD-TC-GetLoanApplicationbyRefNo-UH2
                                  
    [Documentation]           Get Loan Application by loanApplicationRefNo  without provider login

    ${resp}=    Get Loan Application by loanApplicationRefNo     ${loanUid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-GetLoanApplicationbyRefNo-UH3
                                  
    [Documentation]               Create Loan Application and Get Loan Application by loanApplicationRefNo with empty uid.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${INVALID_LEAD_ID}=   Replace String  ${INVALID_LEAD_ID}  {}  Loan Application

    ${resp}=    Get Loan Application by loanApplicationRefNo     ${SPACE} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}   ${INVALID_LEAD_ID}

JD-TC-GetLoanApplicationbyRefNo-UH4
                                  
    [Documentation]               Create Loan Application and Get Loan Application by Another provider loanid.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME38}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    # ${INVALID_LEAD_ID}=   Replace String  ${INVALID_LEAD_ID}  {}  Lead

    ${resp}=    Get Loan Application by loanApplicationRefNo     ${loanUid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}   ${NO_PERMISSION}