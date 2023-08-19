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
Resource          /ebs/TDD/Keywords.robot

*** Variables ***

@{emptylist}

${jpgfile}      /ebs/TDD/uploadimage.jpg
${pngfile}      /ebs/TDD/upload.png
${pdffile}      /ebs/TDD/sample.pdf

${order}    0
${fileSize}  0.00458

${phonez}   7024567616

${autoApprovalUptoAmount}    50000
${autoApprovalUptoAmount2}    70000
*** Test Cases ***

JD-TC-RejectLoanApplication-1
                                  
    [Documentation]               Reject loan applicaion after loan creation

    ${resp}=  Consumer Login  ${CUSERNAME14}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   ProviderLogin  ${PUSERNAME30}  ${PASSWORD} 
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

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME14}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME14}  firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid14}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid14}  ${resp.json()[0]['id']}
    END

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME14}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable    ${phone}   ${resp.json()[0]['phoneNo']}
    Set Test Variable    ${cc}   ${resp.json()[0]['countryCode']}
    Set Suite Variable    ${email}  ${fname}${C_Email}.${test_mail}

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

    ${resp}=    Get Loan Application Type
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${typeid}  ${resp.json()[0]['id']}

    ${resp}=    Get Loan Application Status
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${statusid}  ${resp.json()[0]['id']}

    ${resp}=  Get Loan Application Status  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}  Get Length  ${resp.json()}
    FOR   ${i}  IN RANGE   ${len}
        Set Suite Variable  ${status_id${i}}    ${resp.json()[${i}]['id']}
        Set Suite Variable  ${status_name${i}}  ${resp.json()[${i}]['name']}
    END

    ${resp}=    Get Loan Application Product
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${Productid}  ${resp.json()[0]['id']}

    ${resp}=    Get Loan Application Scheme
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${Schemeid}  ${resp.json()[0]['id']}

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

    ${kyc_list1}=           Create Dictionary  isCoApplicant=${bool[0]}  maritalStatus=${maritalStatus[1]}  employmentStatus=${employmentStatus[0]}  monthlyIncome=${monthlyIncome}  aadhaar=${aadhaar}  pan=${pan}  isAadhaarVerified=${bool[1]}  isPanVerified=${bool[1]}  nomineeType=${nomineeType[1]}  nomineeName=${nomineeName}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentPin=${permanentPin}  permanentCity=${permanentCity}  permanentState=${permanentState}  currentAddress1=${currentAddress1}  currentAddress2=${currentAddress2}  currentPin=${currentPin}  currentCity=${currentCity}  currentState=${currentState}    otherAttachments=${otherAttachmentsList}  panAttachments=${panAttachments}  aadhaarAttachments=${aadhaarAttachments}
    Log  ${kyc_list1}
    ${resp}=  Create Loan Application    ${pcid14}  ${fname}  ${lname}  ${phone}  ${cc}  ${email}  ${categoryid}  ${typeid}  ${Productid}  ${locId}  ${place}  ${invoiceAmount}  ${downpaymentAmount}  ${requestedAmount}  ${remarks}  ${LoanAction[0]}  ${pcid14}  ${jpgfile}  ${fileSize}  ${caption1}  ${fileType1}  ${order}  ${kyc_list1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Test Variable  ${loan_uuid}  ${resp.json()['uid']}
    Set Test Variable  ${loan_id}  ${resp.json()['id']}

    ${resp}=  Get Loan Application With Filter
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Test Variable  ${loanApplicationRefNo}  ${resp.json()[0]['referenceNo']}
    Should Be Equal As Strings   ${resp.json()[0]['status']['id']}     ${status_id0}
    
   
    
   
    ${resp}=  Reject Loan Application   ${loan_uuid}  
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

*** comment ***
JD-TC-RejectLoanApplication-2
                                  
    [Documentation]               Reject Loan Application  after update loan application



    ${resp}=  Consumer Login  ${CUSERNAME14}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   ProviderLogin  ${PUSERNAME30}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
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

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME11}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME11}  firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid14}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid14}  ${resp.json()[0]['id']}
    END
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

    ${resp}=  Get Loan Application Status  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}  Get Length  ${resp.json()}
    FOR   ${i}  IN RANGE   ${len}
        Set Suite Variable  ${status_id${i}}    ${resp.json()[${i}]['id']}
        Set Suite Variable  ${status_name${i}}  ${resp.json()[${i}]['name']}
    END

    ${resp}=    Get Loan Application Product
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${Productid}  ${resp.json()[0]['id']}

    ${resp}=    Get Loan Application Scheme
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${Schemeid}  ${resp.json()[0]['id']}

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


    ${kyc_list1}=           Create Dictionary  isCoApplicant=${bool[0]}  maritalStatus=${maritalStatus[1]}   employmentStatus=${employmentStatus[0]}  monthlyIncome=${monthlyIncome}  aadhaar=${aadhaar}  pan=${pan}  isAadhaarVerified=${bool[1]}  isPanVerified=${bool[1]}  nomineeType=${nomineeType[1]}  nomineeName=${nomineeName}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentPin=${permanentPin}  permanentCity=${permanentCity}  permanentState=${permanentState}  currentAddress1=${currentAddress1}  currentAddress2=${currentAddress2}  currentPin=${currentPin}  currentCity=${currentCity}  currentState=${currentState}
    Log  ${kyc_list1}
    ${resp}=  Create Loan Application    ${pcid14}  ${categoryid}  ${typeid}  ${Productid}  ${locId}  ${place}  ${invoiceAmount}  ${downpaymentAmount}  ${requestedAmount}  ${remarks}  ${kyc_list1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Test Variable  ${loan_uuid}  ${resp.json()['uid']}
    Set Test Variable  ${loan_id}  ${resp.json()['id']}

    ${resp}=  Get Loan Application With Filter
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Test Variable  ${loanApplicationRefNo}  ${resp.json()[0]['referenceNo']}
    Should Be Equal As Strings   ${resp.json()[0]['status']['id']}     ${status_id0}
    
   
    
    ${invoiceAmount1}         FakerLibrary.Random Number
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


    ${kyc_list1}=    Create Dictionary    isCoApplicant=${bool[0]}    maritalStatus=${maritalStatus[1]}   employmentStatus=${employmentStatus[0]}    monthlyIncome=${monthlyIncome}  aadhaar=${aadhaar}   pan=${pan}  isAadhaarVerified=${bool[1]}  isPanVerified=${bool[1]}  nomineeType=${nomineeType[1]}   nomineeName=${nomineeName}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentPin=${permanentPin}  permanentCity=${permanentCity}  permanentState=${permanentState}   currentAddress1=${currentAddress1}  currentAddress2=${currentAddress2}  currentPin=${currentPin}  currentCity=${currentCity}  currentState=${currentState}
    Log  ${kyc_list1}
    ${resp}=   Update Loan Application   ${loan_uuid}    ${pcid14}   ${categoryid}   ${typeid}   ${status_id0}   ${Productid}   ${locId}   ${place}   ${invoiceAmount1}  ${downpaymentAmount}  ${requestedAmount}  ${remarks}  ${kyc_list1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    
    ${resp}=  Get Loan Application With Filter
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()[0]['referenceNo']}      ${loanApplicationRefNo}
    Should Be Equal As Strings   ${resp.json()[0]['status']['id']}     ${status_id0}
    
    ${resp}=  Reject Loan Application   ${loan_uuid}  
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    
JD-TC-RejectLoanApplication-3
                                  
    [Documentation]               Reject Loan Application  after change loan application status


    ${resp}=  Consumer Login  ${CUSERNAME14}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   ProviderLogin  ${PUSERNAME51}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
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

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME10}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME10}  firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid14}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid14}  ${resp.json()[0]['id']}
    END
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

    ${resp}=  Get Loan Application Status  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}  Get Length  ${resp.json()}
    FOR   ${i}  IN RANGE   ${len}
        Set Suite Variable  ${status_id${i}}    ${resp.json()[${i}]['id']}
        Set Suite Variable  ${status_name${i}}  ${resp.json()[${i}]['name']}
    END

    ${resp}=    Get Loan Application Product
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${Productid}  ${resp.json()[0]['id']}

    ${resp}=    Get Loan Application Scheme
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${Schemeid}  ${resp.json()[0]['id']}

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


    ${kyc_list1}=           Create Dictionary  isCoApplicant=${bool[0]}  maritalStatus=${maritalStatus[1]}   employmentStatus=${employmentStatus[0]}  monthlyIncome=${monthlyIncome}  aadhaar=${aadhaar}  pan=${pan}  isAadhaarVerified=${bool[1]}  isPanVerified=${bool[1]}  nomineeType=${nomineeType[1]}  nomineeName=${nomineeName}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentPin=${permanentPin}  permanentCity=${permanentCity}  permanentState=${permanentState}  currentAddress1=${currentAddress1}  currentAddress2=${currentAddress2}  currentPin=${currentPin}  currentCity=${currentCity}  currentState=${currentState}
    Log  ${kyc_list1}
    ${resp}=  Create Loan Application    ${pcid14}  ${categoryid}  ${typeid}  ${Productid}  ${locId}  ${place}  ${invoiceAmount}  ${downpaymentAmount}  ${requestedAmount}  ${remarks}  ${kyc_list1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Test Variable  ${loan_uuid}  ${resp.json()['uid']}
    Set Test Variable  ${loan_id}  ${resp.json()['id']}

    ${resp}=  Get Loan Application With Filter
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Test Variable  ${loanApplicationRefNo}  ${resp.json()[0]['referenceNo']}
    Should Be Equal As Strings   ${resp.json()[0]['status']['id']}     ${status_id0}
    
   
    
    ${invoiceAmount1}         FakerLibrary.Random Number
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


    ${kyc_list1}=    Create Dictionary    isCoApplicant=${bool[0]}    maritalStatus=${maritalStatus[1]}   employmentStatus=${employmentStatus[0]}    monthlyIncome=${monthlyIncome}  aadhaar=${aadhaar}   pan=${pan}  isAadhaarVerified=${bool[1]}  isPanVerified=${bool[1]}  nomineeType=${nomineeType[1]}   nomineeName=${nomineeName}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentPin=${permanentPin}  permanentCity=${permanentCity}  permanentState=${permanentState}   currentAddress1=${currentAddress1}  currentAddress2=${currentAddress2}  currentPin=${currentPin}  currentCity=${currentCity}  currentState=${currentState}
    Log  ${kyc_list1}
    ${resp}=   Update Loan Application   ${loan_uuid}    ${pcid14}   ${categoryid}   ${typeid}   ${status_id0}   ${Productid}   ${locId}   ${place}   ${invoiceAmount1}  ${downpaymentAmount}  ${requestedAmount}  ${remarks}  ${kyc_list1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    
    ${resp}=  Get Loan Application With Filter
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()[0]['referenceNo']}      ${loanApplicationRefNo}
    Should Be Equal As Strings   ${resp.json()[0]['status']['id']}     ${status_id0}

    ${resp}=  Change Loan Application Status   ${loan_uuid}   ${status_id0}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    
    ${resp}=  Reject Loan Application   ${loan_uuid}  
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    
JD-TC-RejectLoanApplication-4
                                  
    [Documentation]               Reject Loan Application  after proceed loan application



    ${resp}=  Consumer Login  ${CUSERNAME14}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   ProviderLogin  ${PUSERNAME52}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
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

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME18}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME18}  firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid14}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid14}  ${resp.json()[0]['id']}
    END
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

    ${resp}=  Get Loan Application Status  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}  Get Length  ${resp.json()}
    FOR   ${i}  IN RANGE   ${len}
        Set Suite Variable  ${status_id${i}}    ${resp.json()[${i}]['id']}
        Set Suite Variable  ${status_name${i}}  ${resp.json()[${i}]['name']}
    END

    ${resp}=    Get Loan Application Product
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${Productid}  ${resp.json()[0]['id']}

    ${resp}=    Get Loan Application Scheme
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${Schemeid}  ${resp.json()[0]['id']}

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


    ${kyc_list1}=           Create Dictionary  isCoApplicant=${bool[0]}  maritalStatus=${maritalStatus[1]}   employmentStatus=${employmentStatus[0]}  monthlyIncome=${monthlyIncome}  aadhaar=${aadhaar}  pan=${pan}  isAadhaarVerified=${bool[1]}  isPanVerified=${bool[1]}  nomineeType=${nomineeType[1]}  nomineeName=${nomineeName}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentPin=${permanentPin}  permanentCity=${permanentCity}  permanentState=${permanentState}  currentAddress1=${currentAddress1}  currentAddress2=${currentAddress2}  currentPin=${currentPin}  currentCity=${currentCity}  currentState=${currentState}
    Log  ${kyc_list1}
    ${resp}=  Create Loan Application    ${pcid14}  ${categoryid}  ${typeid}  ${Productid}  ${locId}  ${place}  ${invoiceAmount}  ${downpaymentAmount}  ${requestedAmount}  ${remarks}  ${kyc_list1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${loan_uuid}  ${resp.json()['uid']}
    Set Test Variable  ${loan_id}  ${resp.json()['id']}

    ${resp}=  Get Loan Application With Filter
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Test Variable  ${loanApplicationRefNo}  ${resp.json()[0]['referenceNo']}
    Should Be Equal As Strings   ${resp.json()[0]['status']['id']}     ${status_id0}
    
   
    
    ${invoiceAmount1}         FakerLibrary.Random Number
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


    ${kyc_list1}=    Create Dictionary    isCoApplicant=${bool[0]}    maritalStatus=${maritalStatus[1]}   employmentStatus=${employmentStatus[0]}    monthlyIncome=${monthlyIncome}  aadhaar=${aadhaar}   pan=${pan}  isAadhaarVerified=${bool[1]}  isPanVerified=${bool[1]}  nomineeType=${nomineeType[1]}   nomineeName=${nomineeName}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentPin=${permanentPin}  permanentCity=${permanentCity}  permanentState=${permanentState}   currentAddress1=${currentAddress1}  currentAddress2=${currentAddress2}  currentPin=${currentPin}  currentCity=${currentCity}  currentState=${currentState}
    Log  ${kyc_list1}
    ${resp}=   Update Loan Application   ${loan_uuid}    ${pcid14}   ${categoryid}   ${typeid}   ${status_id0}   ${Productid}   ${locId}   ${place}   ${invoiceAmount1}  ${downpaymentAmount}  ${requestedAmount}  ${remarks}  ${kyc_list1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    
    ${resp}=  Get Loan Application With Filter
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()[0]['referenceNo']}      ${loanApplicationRefNo}
    Should Be Equal As Strings   ${resp.json()[0]['status']['id']}     ${status_id0}

    ${resp}=  Proceed Loan Application   ${loan_uuid}   ${status_id0}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    
    ${resp}=  Reject Loan Application   ${loan_uuid}  
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    

JD-TC-RejectLoanApplication-UH1
                                  
    [Documentation]               Reject Loan Application  invalid uuid



    ${resp}=   ProviderLogin  ${PUSERNAME40}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

     
    ${resp}=  Reject Loan Application   2435   
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200




JD-TC-RejectLoanApplication-UH2
                                  
    [Documentation]               Reject Loan Application consumer login

    ${resp}=  Consumer Login  ${CUSERNAME11}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}

     
    ${resp}=  Reject Loan Application   ${loan_uuid}   
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    401
    Should Be Equal As Strings   ${resp.json()}    ${LOGIN_NO_ACCESS_FOR_URL}


JD-TC-RejectLoanApplication-UH3
                                  
    [Documentation]               Reject Loan Application without login

    ${resp}=  Reject Loan Application    ${loan_uuid}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.json()}   ${SESSION_EXPIRED}
    
   
JD-TC-RejectLoanApplication-UH4
                                  
    [Documentation]               Reject Loan Application another provider login

   
    
    ${resp}=   ProviderLogin  ${PUSERNAME38}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

         
    ${resp}=   Reject Loan Application    ${loan_uuid}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${NO_PERMISSION}
  
   