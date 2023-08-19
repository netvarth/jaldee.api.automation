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

*** Variables ***

@{emptylist}

${jpgfile}      /ebs/TDD/uploadimage.jpg
${pngfile}      /ebs/TDD/upload.png
${pdffile}      /ebs/TDD/sample.pdf

${order}    0
${fileSize}  0.00458

${autoApprovalUptoAmount}    50000
${autoApprovalUptoAmount2}    70000

*** Test Cases ***
JD-TC-GetLoanApplicationCountwithFilter-1
                                  
    [Documentation]               Create Loan Application and get the loan.

    ${resp}=  Consumer Login  ${CUSERNAME17}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   ProviderLogin  ${PUSERNAME11}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}

    ${resp}=    Create and Update Account level cdl setting    ${bool[1]}    ${autoApprovalUptoAmount2}    ${bool[1]}    ${toggle[0]}    ${bool[1]}    ${empty}   ${bool[1]}    ${bool[1]}  demandPromissoryNoteRequired=${bool[1]}    securityPostDatedChequesRequired=${bool[1]}    loanNature=ConsumerDurableLoan
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get account level cdl setting
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
    ELSE
        Set Test Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${place}  ${resp.json()[0]['place']}
    END

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME17}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME17}  firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${pcid14}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${pcid14}  ${resp.json()[0]['id']}
    END

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME17}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable    ${phone}   ${resp.json()[0]['phoneNo']}
    Set Test Variable    ${cc}   ${resp.json()[0]['countryCode']}
    Set Test Variable    ${email}  ${fname}${C_Email}.${test_mail}

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  ${resp.json()['enableBranchMaster']}==${bool[0]}
        ${resp1}=  Enable Disable Branch    ${status[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
    ELSE
        Set Test Variable  ${locId}  ${resp.json()[0]['id']}
        Set Test Variable  ${place}  ${resp.json()[0]['place']}
    END

    ${branchCode}=    FakerLibrary.Random Number
    ${branchName}=    FakerLibrary.name

    ${pin}  ${city}  ${district}  ${state}=  get_pin_loc

    ${state}=    Evaluate     "${state}".title()
    ${state}=    String.RemoveString  ${state}    ${SPACE}
   
    ${resp}=    Create BranchMaster    ${branchCode}    ${branchName}    ${locId}    ${status[0]}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${branchid2}  ${resp.json()['id']}

    ${resp}=    Change Branch Status    ${branchid2}    ${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    # .....Assigning branches to users

    ${userids}=  Create List  ${provider_id}
    ${branch1}=  Create Dictionary   id=${branchid2}    isDefault=${bool[1]}

    ${resp}=  Assigning Branches to Users   ${userids}   ${branch1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  categorytype   ${account_id}
    ${resp}=  tasktype       ${account_id}
    ${resp}=  loanStatus     ${account_id}
    ${resp}=  loanProduct    ${account_id}
    ${resp}=  loanScheme     ${account_id}

    ${resp}=    Get Loan Application Category
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${categoryid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${categoryname}  ${resp.json()[0]['name']}

    Set Suite Variable  ${categoryid1}  ${resp.json()[1]['id']}
    Set Suite Variable  ${categoryname1}  ${resp.json()[1]['name']}


    ${resp}=    Get Loan Application Type
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${typeid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${typename}  ${resp.json()[0]['name']}

    Set Suite Variable  ${typeid1}  ${resp.json()[1]['id']}
    Set Suite Variable  ${typename1}  ${resp.json()[1]['name']}


    ${resp}=    Get Loan Application Status
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${statusid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${statusname}  ${resp.json()[0]['name']}
    

    ${resp}=    Get Loan Application Product
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${Productid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${Productid1}  ${resp.json()[1]['id']}
    Set Suite Variable  ${Productid2}  ${resp.json()[2]['id']}

    ${resp}=    Get Loan Application Scheme
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${Schemeid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${Schemeid1}  ${resp.json()[1]['id']}
    Set Suite Variable  ${Schemeid2}  ${resp.json()[2]['id']}

    ${invoiceAmount}         FakerLibrary.Random Number
    ${downpaymentAmount}     FakerLibrary.Random Number
    ${requestedAmount}       FakerLibrary.Random Number
    ${remarks}               FakerLibrary.sentence
    ${monthlyIncome}         FakerLibrary.Random Number
    ${aadhaar}               FakerLibrary.Random Number
    ${pan}                   FakerLibrary.Random Number
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


    ${kyc_list1}=           Create Dictionary  isCoApplicant=${bool[0]}  maritalStatus=${maritalStatus[1]}  employmentStatus=${employmentStatus[1]}  monthlyIncome=${monthlyIncome}  aadhaar=${aadhaar}  pan=${pan}
    ...  isAadhaarVerified=${bool[1]}  isPanVerified=${bool[1]}  nomineeType=${nomineeType[1]}  nomineeName=${nomineeName}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentPin=${permanentPin}
    ...  permanentCity=${permanentCity}  permanentState=${permanentState}  currentAddress1=${currentAddress1}  currentAddress2=${currentAddress2}  currentPin=${currentPin}  currentCity=${currentCity}  currentState=${currentState}
    ...  otherAttachments=${otherAttachmentsList}  panAttachments=${panAttachments}  aadhaarAttachments=${aadhaarAttachments}
    Log  ${kyc_list1}
    ${resp}=  Create Loan Application    ${pcid14}    ${fname}  ${lname}  ${phone}  ${cc}  ${email}  ${categoryid}  ${typeid}  ${Productid}  ${locId}  ${place}  ${invoiceAmount}  ${downpaymentAmount}  ${requestedAmount}  ${remarks}    ${LoanAction[0]}  ${pcid14}  ${jpgfile}  ${fileSize}  ${caption1}  ${fileType1}  ${order}  ${kyc_list1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${loanid}   ${resp.json()['id']}
    Set Suite Variable  ${loanUid}   ${resp.json()['uid']}

    ${resp}=  Create Loan Application    ${pcid14}    ${fname}  ${lname}  ${phone}  ${cc}  ${email}  ${categoryid}  ${typeid1}  ${Productid1}  ${locId}  ${place}  ${invoiceAmount}  ${downpaymentAmount}  ${requestedAmount}  ${remarks}    ${LoanAction[0]}  ${pcid14}  ${jpgfile}  ${fileSize}  ${caption1}  ${fileType1}  ${order}  ${kyc_list1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${loanid1}   ${resp.json()['id']}
    Set Suite Variable  ${loanUid1}   ${resp.json()['uid']}

    ${resp}=    Get Loan Application With Filter    
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings   ${resp.json()[0]['id']}  ${loanid}
    

    ${len}=  Get Length  ${resp.json()}  

    ${resp}=    Get Loan Application Count with filter    
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()}   ${len}



JD-TC-GetLoanApplicationCountwithFilter-2
                                  
    [Documentation]               Create Loan Application and get the loan with id filter.

    # clear_location    ${PUSERNAME11}
    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname1}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   ProviderLogin  ${PUSERNAME11}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
    ELSE
        Set Suite Variable  ${locId1}  ${resp.json()[0]['id']}
        Set Suite Variable  ${place1}  ${resp.json()[0]['place']}
    END

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME18}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME18}  firstName=${fname1}   lastName=${lname1}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${pcid16}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${pcid16}  ${resp.json()[0]['id']}
    END

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME18}  
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

    ${resp}=    Get Loan Application Category
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${categoryid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${categoryname}  ${resp.json()[0]['name']}


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
    Set Suite Variable  ${Productid1}  ${resp.json()[2]['id']}

    ${resp}=    Get Loan Application Scheme
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${Schemeid}  ${resp.json()[1]['id']}

    ${invoiceAmount}         FakerLibrary.Random Number
    ${downpaymentAmount}     FakerLibrary.Random Number
    ${requestedAmount}       FakerLibrary.Random Number
    ${remarks}               FakerLibrary.sentence
    ${monthlyIncome}         FakerLibrary.Random Number
    ${aadhaar}               FakerLibrary.Random Number
    ${pan}                   FakerLibrary.Random Number
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


    ${kyc_list1}=           Create Dictionary  isCoApplicant=${bool[0]}  maritalStatus=${maritalStatus[1]}  employmentStatus=${employmentStatus[1]}  monthlyIncome=${monthlyIncome}  aadhaar=${aadhaar}  pan=${pan}
    ...  isAadhaarVerified=${bool[1]}  isPanVerified=${bool[1]}  nomineeType=${nomineeType[1]}  nomineeName=${nomineeName}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentPin=${permanentPin}
    ...  permanentCity=${permanentCity}  permanentState=${permanentState}  currentAddress1=${currentAddress1}  currentAddress2=${currentAddress2}  currentPin=${currentPin}  currentCity=${currentCity}  currentState=${currentState}
    ...  otherAttachments=${otherAttachmentsList}  panAttachments=${panAttachments}  aadhaarAttachments=${aadhaarAttachments}
    Log  ${kyc_list1}
    ${resp}=  Create Loan Application    ${pcid16}    ${fname}  ${lname}  ${phone}  ${cc}  ${email}  ${categoryid}  ${typeid}  ${Productid1}  ${locId1}  ${place}  ${invoiceAmount}  ${downpaymentAmount}  ${requestedAmount}  ${remarks}    ${LoanAction[0]}  ${pcid16}  ${jpgfile}  ${fileSize}  ${caption1}  ${fileType1}  ${order}  ${kyc_list1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${loanid1}   ${resp.json()['id']}
    Set Suite Variable  ${loanUid1}   ${resp.json()['uid']}


    ${resp}=    Get Loan Application With Filter    id-eq=${loanid1}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings   ${resp.json()[0]['id']}  ${loanid1}
    # Should Be Equal As Strings   ${resp.json()[0]['uid']}  ${loanUid1}
    
    ${len}=  Get Length  ${resp.json()}  

    ${resp}=    Get Loan Application Count with filter    id-eq=${loanid1}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()}   ${len}

    
JD-TC-GetLoanApplicationCountwithFilter-3
                                  
    [Documentation]               Create Loan Application and get the loan with uid filter.

    ${resp}=   ProviderLogin  ${PUSERNAME11}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Loan Application With Filter    uid-eq=${loanUid}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings   ${resp.json()[0]['id']}  ${loanid1}
    # Should Be Equal As Strings   ${resp.json()[0]['uid']}  ${loanUid}
    # Should Be Equal As Strings   ${resp.json()[0]['accountId']}  ${account_id}
    # Should Be Equal As Strings   ${resp.json()[0]['customer']['id']}  ${pcid16}
    # # Should Be Equal As Strings   ${resp.json()[0]['remarks']}  ${remarks}
    # Should Be Equal As Strings   ${resp.json()[0]['category']['id']}  ${categoryid}
    # Should Be Equal As Strings   ${resp.json()[0]['type']['id']}  ${typeid}
    # Should Be Equal As Strings   ${resp.json()[0]['loanProduct']['id']}  ${Productid1}

    ${len}=  Get Length  ${resp.json()}  

    ${resp}=    Get Loan Application Count with filter    uid-eq=${loanUid}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()}   ${len}


JD-TC-GetLoanApplicationCountwithFilter-4
                                  
    [Documentation]               Create Loan Application and get the loan with customer filter.

    ${resp}=   ProviderLogin  ${PUSERNAME11}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Loan Application With Filter    customer-eq=${pcid16}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings   ${resp.json()[0]['customer']['id']}  ${pcid16}
    # Should Be Equal As Strings   ${resp.json()[0]['id']}  ${loanid1}
    # Should Be Equal As Strings   ${resp.json()[0]['uid']}  ${loanUid1}
    # Should Be Equal As Strings   ${resp.json()[0]['accountId']}  ${account_id}
    # # Should Be Equal As Strings   ${resp.json()[0]['remarks']}  ${remarks}
    # Should Be Equal As Strings   ${resp.json()[0]['category']['id']}  ${categoryid}
    # Should Be Equal As Strings   ${resp.json()[0]['type']['id']}  ${typeid}
    # Should Be Equal As Strings   ${resp.json()[0]['loanProduct']['id']}  ${Productid1}

    ${len}=  Get Length  ${resp.json()}  

    ${resp}=    Get Loan Application Count with filter    customer-eq=${pcid16}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()}   ${len}

JD-TC-GetLoanApplicationCountwithFilter-5
                                  
    [Documentation]               Create Loan Application and get the loan with customerFirstName filter.

    ${resp}=   ProviderLogin  ${PUSERNAME11}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Loan Application With Filter    customerFirstName-eq=${fname}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings   ${resp.json()[0]['customer']['id']}  ${pcid14}
    # Should Be Equal As Strings   ${resp.json()[0]['id']}  ${loanid}
    # Should Be Equal As Strings   ${resp.json()[0]['uid']}  ${loanUid}
    # Should Be Equal As Strings   ${resp.json()[0]['accountId']}  ${account_id}
    # # Should Be Equal As Strings   ${resp.json()[0]['remarks']}  ${remarks}
    # Should Be Equal As Strings   ${resp.json()[0]['category']['id']}  ${categoryid}
    # Should Be Equal As Strings   ${resp.json()[0]['type']['id']}  ${typeid}
    # Should Be Equal As Strings   ${resp.json()[0]['loanProduct']['id']}  ${Productid}

    ${len}=  Get Length  ${resp.json()}  

    ${resp}=    Get Loan Application Count with filter    customerFirstName-eq=${fname}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()}   ${len}

JD-TC-GetLoanApplicationCountwithFilter-6
                                  
    [Documentation]               Create Loan Application and get the loan with customerLastName filter.

    ${resp}=   ProviderLogin  ${PUSERNAME11}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Loan Application With Filter    customerLastName-eq=${lname1}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings   ${resp.json()[0]['customer']['id']}  ${pcid16}
    # Should Be Equal As Strings   ${resp.json()[0]['id']}  ${loanid1}
    # Should Be Equal As Strings   ${resp.json()[0]['uid']}  ${loanUid1}
    # Should Be Equal As Strings   ${resp.json()[0]['accountId']}  ${account_id}
    # # Should Be Equal As Strings   ${resp.json()[0]['remarks']}  ${remarks}
    # Should Be Equal As Strings   ${resp.json()[0]['category']['id']}  ${categoryid}
    # Should Be Equal As Strings   ${resp.json()[0]['type']['id']}  ${typeid}
    # Should Be Equal As Strings   ${resp.json()[0]['loanProduct']['id']}  ${Productid1}

    ${len}=  Get Length  ${resp.json()}  

    ${resp}=    Get Loan Application Count with filter    customerLastName-eq=${lname1}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()}   ${len}

JD-TC-GetLoanApplicationCountwithFilter-7
                                  
    [Documentation]               Create Loan Application and get the loan with location filter.

    ${resp}=   ProviderLogin  ${PUSERNAME11}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Loan Application With Filter    location-eq=${locId1}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings   ${resp.json()[0]['location']['id']}  ${locId1}
    # Should Be Equal As Strings   ${resp.json()[0]['customer']['id']}  ${pcid16}
    # Should Be Equal As Strings   ${resp.json()[0]['id']}  ${loanid1}
    # Should Be Equal As Strings   ${resp.json()[0]['uid']}  ${loanUid1}
    # Should Be Equal As Strings   ${resp.json()[0]['accountId']}  ${account_id}
    # # Should Be Equal As Strings   ${resp.json()[0]['remarks']}  ${remarks}
    # Should Be Equal As Strings   ${resp.json()[0]['category']['id']}  ${categoryid}
    # Should Be Equal As Strings   ${resp.json()[0]['type']['id']}  ${typeid}
    # Should Be Equal As Strings   ${resp.json()[0]['loanProduct']['id']}  ${Productid1}

    ${len}=  Get Length  ${resp.json()}  

    ${resp}=    Get Loan Application Count with filter    location-eq=${locId1}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()}   ${len}

JD-TC-GetLoanApplicationCountwithFilter-8
                                  
    [Documentation]               Create Loan Application and get the loan with locationName filter.

    ${resp}=   ProviderLogin  ${PUSERNAME11}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Loan Application With Filter    locationName-eq=${place1}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings   ${resp.json()[0]['location']['name']}  ${place1}
    # Should Be Equal As Strings   ${resp.json()[0]['customer']['id']}  ${pcid16}
    # Should Be Equal As Strings   ${resp.json()[0]['id']}  ${loanid1}
    # Should Be Equal As Strings   ${resp.json()[0]['uid']}  ${loanUid1}
    # Should Be Equal As Strings   ${resp.json()[0]['accountId']}  ${account_id}
    # # Should Be Equal As Strings   ${resp.json()[0]['remarks']}  ${remarks}
    # Should Be Equal As Strings   ${resp.json()[0]['category']['id']}  ${categoryid}
    # Should Be Equal As Strings   ${resp.json()[0]['type']['id']}  ${typeid}
    # Should Be Equal As Strings   ${resp.json()[0]['loanProduct']['id']}  ${Productid1}

    ${len}=  Get Length  ${resp.json()}  

    ${resp}=    Get Loan Application Count with filter    locationName-eq=${place1}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()}   ${len}

JD-TC-GetLoanApplicationCountwithFilter-9
                                  
    [Documentation]               Create Loan Application and get the loan with category filter.

    ${resp}=   ProviderLogin  ${PUSERNAME11}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Loan Application With Filter    category-eq=${categoryid}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings   ${resp.json()[0]['category']['id']}  ${categoryid}
    # Should Be Equal As Strings   ${resp.json()[0]['location']['name']}  ${place1}
    # Should Be Equal As Strings   ${resp.json()[0]['customer']['id']}  ${pcid16}
    # Should Be Equal As Strings   ${resp.json()[0]['id']}  ${loanid1}
    # Should Be Equal As Strings   ${resp.json()[0]['uid']}  ${loanUid1}
    # Should Be Equal As Strings   ${resp.json()[0]['accountId']}  ${account_id}
    # # Should Be Equal As Strings   ${resp.json()[0]['remarks']}  ${remarks}
    # Should Be Equal As Strings   ${resp.json()[0]['type']['id']}  ${typeid}
    # Should Be Equal As Strings   ${resp.json()[0]['loanProduct']['id']}  ${Productid1}

   
    # Should Be Equal As Strings   ${resp.json()[1]['category']['id']}  ${categoryid}
    # Should Be Equal As Strings   ${resp.json()[1]['location']['name']}  ${place}
    # Should Be Equal As Strings   ${resp.json()[1]['customer']['id']}  ${pcid14}
    # Should Be Equal As Strings   ${resp.json()[1]['id']}  ${loanid}
    # Should Be Equal As Strings   ${resp.json()[1]['uid']}  ${loanUid}
    # Should Be Equal As Strings   ${resp.json()[1]['accountId']}  ${account_id}
    # # Should Be Equal As Strings   ${resp.json()[1]['remarks']}  ${remarks}
    # Should Be Equal As Strings   ${resp.json()[1]['type']['id']}  ${typeid}
    # Should Be Equal As Strings   ${resp.json()[1]['loanProduct']['id']}  ${Productid}

    ${len}=  Get Length  ${resp.json()}  

    ${resp}=    Get Loan Application Count with filter    category-eq=${categoryid}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()}   ${len}

JD-TC-GetLoanApplicationCountwithFilter-10
                                  
    [Documentation]               Create Loan Application and get the loan with categoryName filter.

    ${resp}=   ProviderLogin  ${PUSERNAME11}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Loan Application With Filter    categoryName-eq=${categoryname}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings   ${resp.json()[0]['category']['id']}  ${categoryid}
    # Should Be Equal As Strings   ${resp.json()[0]['category']['name']}  ${categoryname}
    # Should Be Equal As Strings   ${resp.json()[0]['location']['name']}  ${place1}
    # Should Be Equal As Strings   ${resp.json()[0]['customer']['id']}  ${pcid16}
    # Should Be Equal As Strings   ${resp.json()[0]['id']}  ${loanid1}
    # Should Be Equal As Strings   ${resp.json()[0]['uid']}  ${loanUid1}
    # Should Be Equal As Strings   ${resp.json()[0]['accountId']}  ${account_id}
    # # Should Be Equal As Strings   ${resp.json()[0]['remarks']}  ${remarks}
    # Should Be Equal As Strings   ${resp.json()[0]['type']['id']}  ${typeid}
    # Should Be Equal As Strings   ${resp.json()[0]['loanProduct']['id']}  ${Productid1}

    # Should Be Equal As Strings   ${resp.json()[1]['category']['id']}  ${categoryid}
    # Should Be Equal As Strings   ${resp.json()[1]['location']['name']}  ${place}
    # Should Be Equal As Strings   ${resp.json()[1]['customer']['id']}  ${pcid14}
    # Should Be Equal As Strings   ${resp.json()[1]['id']}  ${loanid}
    # Should Be Equal As Strings   ${resp.json()[1]['uid']}  ${loanUid}
    # Should Be Equal As Strings   ${resp.json()[1]['accountId']}  ${account_id}
    # # Should Be Equal As Strings   ${resp.json()[1]['remarks']}  ${remarks}
    # Should Be Equal As Strings   ${resp.json()[1]['type']['id']}  ${typeid}
    # Should Be Equal As Strings   ${resp.json()[1]['loanProduct']['id']}  ${Productid}

    ${len}=  Get Length  ${resp.json()}  

    ${resp}=    Get Loan Application Count with filter    categoryName-eq=${categoryname}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()}   ${len}

JD-TC-GetLoanApplicationCountwithFilter-11
                                  
    [Documentation]               Create Loan Application and get the loan with type filter.

    ${resp}=   ProviderLogin  ${PUSERNAME11}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Loan Application With Filter    type-eq=${typeid}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    # Should Be Equal As Strings   ${resp.json()[0]['type']['id']}  ${typeid}
    # Should Be Equal As Strings   ${resp.json()[0]['category']['id']}  ${categoryid}
    # Should Be Equal As Strings   ${resp.json()[0]['category']['name']}  ${categoryname}
    # Should Be Equal As Strings   ${resp.json()[0]['location']['name']}  ${place1}
    # Should Be Equal As Strings   ${resp.json()[0]['customer']['id']}  ${pcid16}
    # Should Be Equal As Strings   ${resp.json()[0]['id']}  ${loanid1}
    # Should Be Equal As Strings   ${resp.json()[0]['uid']}  ${loanUid1}
    # Should Be Equal As Strings   ${resp.json()[0]['accountId']}  ${account_id}
    # # Should Be Equal As Strings   ${resp.json()[0]['remarks']}  ${remarks}
    # Should Be Equal As Strings   ${resp.json()[0]['loanProduct']['id']}  ${Productid1}

    # Should Be Equal As Strings   ${resp.json()[1]['type']['id']}  ${typeid}
    # Should Be Equal As Strings   ${resp.json()[1]['category']['id']}  ${categoryid}
    # Should Be Equal As Strings   ${resp.json()[1]['location']['name']}  ${place}
    # Should Be Equal As Strings   ${resp.json()[1]['customer']['id']}  ${pcid14}
    # Should Be Equal As Strings   ${resp.json()[1]['id']}  ${loanid}
    # Should Be Equal As Strings   ${resp.json()[1]['uid']}  ${loanUid}
    # Should Be Equal As Strings   ${resp.json()[1]['accountId']}  ${account_id}
    # # Should Be Equal As Strings   ${resp.json()[1]['remarks']}  ${remarks}
    # Should Be Equal As Strings   ${resp.json()[1]['loanProduct']['id']}  ${Productid}

    ${len}=  Get Length  ${resp.json()}  

    ${resp}=    Get Loan Application Count with filter    type-eq=${typeid}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()}   ${len}

JD-TC-GetLoanApplicationCountwithFilter-12
                                  
    [Documentation]               Create Loan Application and get the loan with typeName filter.

    ${resp}=   ProviderLogin  ${PUSERNAME11}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Loan Application With Filter    typeName-eq=${typename}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    # Should Be Equal As Strings   ${resp.json()[0]['type']['id']}  ${typeid}
    # Should Be Equal As Strings   ${resp.json()[0]['type']['name']}  ${typename}
    # Should Be Equal As Strings   ${resp.json()[0]['category']['id']}  ${categoryid}
    # Should Be Equal As Strings   ${resp.json()[0]['category']['name']}  ${categoryname}
    # Should Be Equal As Strings   ${resp.json()[0]['location']['name']}  ${place1}
    # Should Be Equal As Strings   ${resp.json()[0]['customer']['id']}  ${pcid16}
    # Should Be Equal As Strings   ${resp.json()[0]['id']}  ${loanid1}
    # Should Be Equal As Strings   ${resp.json()[0]['uid']}  ${loanUid1}
    # Should Be Equal As Strings   ${resp.json()[0]['accountId']}  ${account_id}
    # # Should Be Equal As Strings   ${resp.json()[0]['remarks']}  ${remarks}
    # Should Be Equal As Strings   ${resp.json()[0]['loanProduct']['id']}  ${Productid1}

    # Should Be Equal As Strings   ${resp.json()[1]['type']['id']}  ${typeid}
    # Should Be Equal As Strings   ${resp.json()[0]['type']['name']}  ${typename}
    # Should Be Equal As Strings   ${resp.json()[1]['category']['id']}  ${categoryid}
    # Should Be Equal As Strings   ${resp.json()[1]['location']['name']}  ${place}
    # Should Be Equal As Strings   ${resp.json()[1]['customer']['id']}  ${pcid14}
    # Should Be Equal As Strings   ${resp.json()[1]['id']}  ${loanid}
    # Should Be Equal As Strings   ${resp.json()[1]['uid']}  ${loanUid}
    # Should Be Equal As Strings   ${resp.json()[1]['accountId']}  ${account_id}
    # # Should Be Equal As Strings   ${resp.json()[1]['remarks']}  ${remarks}
    # Should Be Equal As Strings   ${resp.json()[1]['loanProduct']['id']}  ${Productid}

    ${len}=  Get Length  ${resp.json()}  

    ${resp}=    Get Loan Application Count with filter    typeName-eq=${typename}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()}   ${len}

JD-TC-GetLoanApplicationCountwithFilter-13
                                  
    [Documentation]               Create Loan Application and get the loan with status filter.

    ${resp}=   ProviderLogin  ${PUSERNAME11}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Loan Application With Filter    status-eq=${statusid}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    # Should Be Equal As Strings   ${resp.json()[0]['status']['id']}  ${statusid}
    # Should Be Equal As Strings   ${resp.json()[0]['status']['name']}  ${statusname}
    # Should Be Equal As Strings   ${resp.json()[0]['type']['id']}  ${typeid}
    # Should Be Equal As Strings   ${resp.json()[0]['type']['name']}  ${typename}
    # Should Be Equal As Strings   ${resp.json()[0]['category']['id']}  ${categoryid}
    # Should Be Equal As Strings   ${resp.json()[0]['category']['name']}  ${categoryname}
    # Should Be Equal As Strings   ${resp.json()[0]['location']['name']}  ${place1}
    # Should Be Equal As Strings   ${resp.json()[0]['customer']['id']}  ${pcid16}
    # Should Be Equal As Strings   ${resp.json()[0]['id']}  ${loanid1}
    # Should Be Equal As Strings   ${resp.json()[0]['uid']}  ${loanUid1}
    # Should Be Equal As Strings   ${resp.json()[0]['accountId']}  ${account_id}
    # # Should Be Equal As Strings   ${resp.json()[0]['remarks']}  ${remarks}
    # Should Be Equal As Strings   ${resp.json()[0]['loanProduct']['id']}  ${Productid1}

    # Should Be Equal As Strings   ${resp.json()[1]['status']['id']}  ${statusid}
    # Should Be Equal As Strings   ${resp.json()[1]['status']['name']}  ${statusname}
    # Should Be Equal As Strings   ${resp.json()[1]['type']['id']}  ${typeid}
    # Should Be Equal As Strings   ${resp.json()[1]['type']['name']}  ${typename}
    # Should Be Equal As Strings   ${resp.json()[1]['category']['id']}  ${categoryid}
    # Should Be Equal As Strings   ${resp.json()[1]['location']['name']}  ${place}
    # Should Be Equal As Strings   ${resp.json()[1]['customer']['id']}  ${pcid14}
    # Should Be Equal As Strings   ${resp.json()[1]['id']}  ${loanid}
    # Should Be Equal As Strings   ${resp.json()[1]['uid']}  ${loanUid}
    # Should Be Equal As Strings   ${resp.json()[1]['accountId']}  ${account_id}
    # # Should Be Equal As Strings   ${resp.json()[1]['remarks']}  ${remarks}
    # Should Be Equal As Strings   ${resp.json()[1]['loanProduct']['id']}  ${Productid}

    ${len}=  Get Length  ${resp.json()}  

    ${resp}=    Get Loan Application Count with filter    status-eq=${statusid}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()}   ${len}

JD-TC-GetLoanApplicationCountwithFilter-14
                                  
    [Documentation]               Create Loan Application and get the loan with statusName filter.

    ${resp}=   ProviderLogin  ${PUSERNAME11}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Loan Application With Filter    statusName-eq=${statusname}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    # Should Be Equal As Strings   ${resp.json()[0]['status']['id']}  ${statusid}
    # Should Be Equal As Strings   ${resp.json()[0]['status']['name']}  ${statusname}
    # Should Be Equal As Strings   ${resp.json()[0]['type']['id']}  ${typeid}
    # Should Be Equal As Strings   ${resp.json()[0]['type']['name']}  ${typename}
    # Should Be Equal As Strings   ${resp.json()[0]['category']['id']}  ${categoryid}
    # Should Be Equal As Strings   ${resp.json()[0]['category']['name']}  ${categoryname}
    # Should Be Equal As Strings   ${resp.json()[0]['location']['name']}  ${place1}
    # Should Be Equal As Strings   ${resp.json()[0]['customer']['id']}  ${pcid16}
    # Should Be Equal As Strings   ${resp.json()[0]['id']}  ${loanid1}
    # Should Be Equal As Strings   ${resp.json()[0]['uid']}  ${loanUid1}
    # Should Be Equal As Strings   ${resp.json()[0]['accountId']}  ${account_id}
    # # Should Be Equal As Strings   ${resp.json()[0]['remarks']}  ${remarks}
    # Should Be Equal As Strings   ${resp.json()[0]['loanProduct']['id']}  ${Productid1}

    # Should Be Equal As Strings   ${resp.json()[0]['status']['id']}  ${statusid}
    # Should Be Equal As Strings   ${resp.json()[0]['status']['name']}  ${statusname}
    # Should Be Equal As Strings   ${resp.json()[1]['type']['id']}  ${typeid}
    # Should Be Equal As Strings   ${resp.json()[0]['type']['name']}  ${typename}
    # Should Be Equal As Strings   ${resp.json()[1]['category']['id']}  ${categoryid}
    # Should Be Equal As Strings   ${resp.json()[1]['location']['name']}  ${place}
    # Should Be Equal As Strings   ${resp.json()[1]['customer']['id']}  ${pcid14}
    # Should Be Equal As Strings   ${resp.json()[1]['id']}  ${loanid}
    # Should Be Equal As Strings   ${resp.json()[1]['uid']}  ${loanUid}
    # Should Be Equal As Strings   ${resp.json()[1]['accountId']}  ${account_id}
    # # Should Be Equal As Strings   ${resp.json()[1]['remarks']}  ${remarks}
    # Should Be Equal As Strings   ${resp.json()[1]['loanProduct']['id']}  ${Productid}

    ${len}=  Get Length  ${resp.json()}  

    ${resp}=    Get Loan Application Count with filter    statusName-eq=${statusname}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()}   ${len}


JD-TC-GetLoanApplicationCountwithFilter-UH1
                                  
    [Documentation]           Get Loan Application filter Count with consumer login
    
    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=    Get Loan Application Count with filter    statusName-eq=${statusname}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    401
    Should Be Equal As Strings    ${resp.json()}   ${NoAccess}

JD-TC-GetLoanApplicationCountwithFilter-UH2
                                  
    [Documentation]           Get Loan Application Count  without provider login

    ${resp}=    Get Loan Application Count with filter    statusName-eq=${statusname}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}   ${SESSION_EXPIRED}
# JD-TC-GetLoanApplicationCountwithFilter-1
                                  
#     [Documentation]               Create Loan Application and get the loan application filter Count.

#     ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD} 
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200 
#     Set Suite Variable  ${fname}   ${resp.json()['firstName']}
#     Set Suite Variable  ${lname}   ${resp.json()['lastName']}

#     ${resp}=  Consumer Logout
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
    
#     ${resp}=   ProviderLogin  ${PUSERNAME29}  ${PASSWORD} 
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
#         Set Suite Variable  ${place}  ${resp.json()[0]['place']}
#     END

#     ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME16}  
#     Log  ${resp.content}
#     Should Be Equal As Strings      ${resp.status_code}  200
#     IF   '${resp.content}' == '${emptylist}'
#         ${resp1}=  AddCustomer  ${CUSERNAME16}  firstName=${fname}   lastName=${lname}
#         Log  ${resp1.content}
#         Should Be Equal As Strings  ${resp1.status_code}  200
#         Set Suite Variable  ${pcid14}   ${resp1.json()}
#     ELSE
#         Set Suite Variable  ${pcid14}  ${resp.json()[0]['id']}
#     END

#     ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME16}  
#     Log  ${resp.content}
#     Should Be Equal As Strings      ${resp.status_code}  200
#     Set Test Variable    ${phone}   ${resp.json()[0]['phoneNo']}
#     Set Test Variable    ${cc}   ${resp.json()[0]['countryCode']}
#     Set Test Variable    ${email}  ${fname}${C_Email}.${test_mail}

#     ${resp}=  categorytype   ${account_id}
#     ${resp}=  tasktype       ${account_id}
#     ${resp}=  loanStatus     ${account_id}
#     ${resp}=  loanProduct    ${account_id}
#     ${resp}=  loanScheme     ${account_id}

#     ${resp}=    Get Loan Application Category
#     Log  ${resp.content}
#     Should Be Equal As Strings     ${resp.status_code}    200
#     Set Suite Variable  ${categoryid}  ${resp.json()[0]['id']}
#     Set Suite Variable  ${categoryname}  ${resp.json()[0]['name']}

#     Set Suite Variable  ${categoryid1}  ${resp.json()[1]['id']}
#     Set Suite Variable  ${categoryname1}  ${resp.json()[1]['name']}


#     ${resp}=    Get Loan Application Type
#     Log  ${resp.content}
#     Should Be Equal As Strings     ${resp.status_code}    200
#     Set Suite Variable  ${typeid}  ${resp.json()[0]['id']}
#     Set Suite Variable  ${typename}  ${resp.json()[0]['name']}

#     Set Suite Variable  ${typeid1}  ${resp.json()[1]['id']}
#     Set Suite Variable  ${typename1}  ${resp.json()[1]['name']}


#     ${resp}=    Get Loan Application Status
#     Log  ${resp.content}
#     Should Be Equal As Strings     ${resp.status_code}    200
#     Set Suite Variable  ${statusid}  ${resp.json()[0]['id']}
#     Set Suite Variable  ${statusname}  ${resp.json()[0]['name']}
    

#     ${resp}=    Get Loan Application Product
#     Log  ${resp.content}
#     Should Be Equal As Strings     ${resp.status_code}    200
#     Set Suite Variable  ${Productid}  ${resp.json()[0]['id']}
#     Set Suite Variable  ${Productid1}  ${resp.json()[1]['id']}
#     Set Suite Variable  ${Productid2}  ${resp.json()[2]['id']}

#     ${resp}=    Get Loan Application Scheme
#     Log  ${resp.content}
#     Should Be Equal As Strings     ${resp.status_code}    200
#     Set Suite Variable  ${Schemeid}  ${resp.json()[0]['id']}
#     Set Suite Variable  ${Schemeid1}  ${resp.json()[1]['id']}
#     Set Suite Variable  ${Schemeid2}  ${resp.json()[2]['id']}


#     ${invoiceAmount}         FakerLibrary.Random Number
#     ${downpaymentAmount}     FakerLibrary.Random Number
#     ${requestedAmount}       FakerLibrary.Random Number
#     ${remarks}               FakerLibrary.sentence
    
#     # ${maritalStatus}         Evaluate  random.choice($MaritalStatus)  random
#     # ${employmentStatus}      Evaluate  random.choice($EmploymentStatus)  random
#     ${monthlyIncome}         FakerLibrary.Random Number
#     ${aadhaar}               FakerLibrary.Random Number
#     ${pan}                   FakerLibrary.Random Number
#     # ${nomineeType}           Evaluate  random.choice($NomineeType)  random
#     ${nomineeName}           FakerLibrary.name
#     ${permanentAddress1}     FakerLibrary.Street name
#     ${permanentAddress2}     FakerLibrary.Street name
#     ${permanentPin}          FakerLibrary.zipcode
#     ${permanentCity}         FakerLibrary.word
#     ${permanentState}        FakerLibrary.state
#     ${currentAddress1}       FakerLibrary.Street name
#     ${currentAddress2}       FakerLibrary.Street name
#     ${currentPin}            FakerLibrary.zipcode
#     ${currentCity}           FakerLibrary.word
#     ${currentState}          FakerLibrary.state

#     ${resp}=  db.getType   ${jpgfile}
#     Log  ${resp}
#     ${fileType1}=  Get From Dictionary       ${resp}    ${jpgfile}
#     Set Suite Variable    ${fileType1}
#     ${caption1}=  Fakerlibrary.Sentence

#     ${resp}=  db.getType   ${pngfile}
#     Log  ${resp}
#     ${fileType2}=  Get From Dictionary       ${resp}    ${pngfile}
#     Set Suite Variable    ${fileType2}
#     ${caption2}=  Fakerlibrary.Sentence

#     ${resp}=  db.getType   ${pdffile} 
#     Log  ${resp}
#     ${fileType3}=  Get From Dictionary       ${resp}    ${pdffile} 
#     Set Suite Variable    ${fileType3}
#     ${caption3}=  Fakerlibrary.Sentence

#     ${otherAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${jpgfile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType1}  order=${order}
#     ${otherAttachmentsList}=    Create List  ${otherAttachments}

#     ${panAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${pngfile}  fileSize=${fileSize}  caption=${caption2}  fileType=${fileType2}  order=${order}
#     ${panAttachments}=    Create List  ${panAttachments}

#     ${aadhaarAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption3}  fileType=${fileType3}  order=${order}
#     ${aadhaarAttachments}=    Create List  ${aadhaarAttachments}


#     ${kyc_list1}=           Create Dictionary  isCoApplicant=${bool[0]}  maritalStatus=${maritalStatus[1]}  employmentStatus=${employmentStatus[0]}  monthlyIncome=${monthlyIncome}  aadhaar=${aadhaar}  pan=${pan}  isAadhaarVerified=${bool[1]}  
#     ...  isPanVerified=${bool[1]}  nomineeType=${nomineeType[1]}  nomineeName=${nomineeName}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentPin=${permanentPin}  permanentCity=${permanentCity} 
#     ...  permanentState=${permanentState}  currentAddress1=${currentAddress1}  currentAddress2=${currentAddress2}  currentPin=${currentPin}  currentCity=${currentCity}  currentState=${currentState}    otherAttachments=${otherAttachmentsList}  panAttachments=${panAttachments}  aadhaarAttachments=${aadhaarAttachments}
#     Log  ${kyc_list1}

#     ${resp}=  Create Loan Application    ${pcid14}    ${fname}  ${lname}  ${phone}  ${cc}  ${email}  ${categoryid}  ${typeid}  ${Productid}  ${locId}  ${place}  ${invoiceAmount}  ${downpaymentAmount}  ${requestedAmount}  ${remarks}    ${LoanAction[0]}  ${pcid14}  ${jpgfile}  ${fileSize}  ${caption1}  ${fileType1}  ${order}  ${kyc_list1}
#     Log  ${resp.content}
#     Should Be Equal As Strings     ${resp.status_code}    200
#     Set Suite Variable  ${loanid}   ${resp.json()['id']}
#     Set Suite Variable  ${loanUid}   ${resp.json()['uid']}

#     ${resp}=  Create Loan Application    ${pcid14}    ${fname}  ${lname}  ${phone}  ${cc}  ${email}  ${categoryid}  ${typeid1}  ${Productid1}  ${locId}  ${place}  ${invoiceAmount}  ${downpaymentAmount}  ${requestedAmount}  ${remarks}    ${LoanAction[0]}  ${pcid14}  ${jpgfile}  ${fileSize}  ${caption1}  ${fileType1}  ${order}  ${kyc_list1}
#     Log  ${resp.content}
#     Should Be Equal As Strings     ${resp.status_code}    200
#     Set Suite Variable  ${loanid1}   ${resp.json()['id']}
#     Set Suite Variable  ${loanUid1}   ${resp.json()['uid']}


#     ${resp}=    Get Loan Application With Filter    
#     Log    ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     # Should Be Equal As Strings   ${resp.json()[0]['id']}  ${loanid}
#     # Should Be Equal As Strings   ${resp.json()[0]['uid']}  ${loanUid}
#     # Should Be Equal As Strings   ${resp.json()[0]['accountId']}  ${account_id}
#     # Should Be Equal As Strings   ${resp.json()[0]['customer']['id']}  ${pcid14}
#     # # Should Be Equal As Strings   ${resp.json()[0]['remarks']}  ${remarks}
#     # Should Be Equal As Strings   ${resp.json()[0]['category']['id']}  ${categoryid}
#     # Should Be Equal As Strings   ${resp.json()[0]['type']['id']}  ${typeid}
#     # Should Be Equal As Strings   ${resp.json()[0]['loanProduct']['id']}  ${Productid}
#     # Should Be Equal As Strings   ${resp.json()[0]['assignee']['id']}  ${Productid}

#     ${len}=  Get Length  ${resp.json()}  

#     ${resp}=    Get Loan Application Count with filter
#     Log    ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Should Be Equal As Strings   ${resp.json()}   ${len}
# JD-TC-GetLoanApplicationCountwithFilter-2
                                  
#     [Documentation]               Create Loan Application and get the loan application filter Count.

#     ${resp}=   ProviderLogin  ${PUSERNAME29}  ${PASSWORD} 
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${resp}=    Get Loan Application With Filter    id-eq=${loanid1}
#     Log    ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200


#     ${resp}=    Get Loan Application Count with filter    id-eq=${loanid1}
#     Log    ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

# JD-TC-GetLoanApplicationCountwithFilter-3
                                  
#     [Documentation]               Login a Provider then call Get Loan Application Count with filter.

#     ${resp}=   ProviderLogin  ${PUSERNAME25}  ${PASSWORD} 
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     # ${resp}=    Get Loan Application With Filter    id-eq=${loanid1}
#     # Log    ${resp.content}
#     # Should Be Equal As Strings    ${resp.status_code}    200
    

#     ${resp}=    Get Loan Application Count with filter
#     Log    ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Should Be Equal As Strings   ${resp.json()}   0