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
${withspl}                          @#!
${jpgfile}      /ebs/TDD/uploadimage.jpg
${pngfile}      /ebs/TDD/upload.png
${pdffile}      /ebs/TDD/sample.pdf

${order}    0
${fileSize}  0.00458
${phone}     5555555555

${autoApprovalUptoAmount}    50000
${autoApprovalUptoAmount2}    70000




*** Test Cases ***

JD-TC-UpdateLoanApplication-1
                                  
    [Documentation]               Create and update Loan Application

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
    Set Suite Variable   ${custid}    ${resp.json()[0]['id']}
    Set Suite Variable   ${firstName}    ${resp.json()[0]['firstName']}
    Set Suite Variable   ${lastName}    ${resp.json()[0]['lastName']}
    Set Suite Variable   ${phoneNo}    ${resp.json()[0]['phoneNo']}

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

    ${resp}=    Generate Loan Application Otp for Phone Number    ${phone}  ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${kyc_list1}=           Create Dictionary  isCoApplicant=${bool[0]}

    ${resp}=  db.getType   ${pdffile} 
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${pdffile} 
    # Set Suite Variable    ${fileType}
    ${caption}=  Fakerlibrary.Sentence

    ${resp}    upload file to temporary location    ${file_action[0]}    ${account_id}    ${ownerType[0]}    ${firstName}    ${pdffile}    ${fileSize}    ${caption}    ${fileType}    ${EMPTY}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Set Test Variable    ${driveId}    ${resp.json()[0]['driveId']}

    ${resp}    change status of the uploaded file    ${QnrStatus[1]}    ${driveId}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${CustomerPhoto}=    Create Dictionary   action=${LoanAction[0]}  owner=${account_id}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}    driveId=${driveId}
    Log  ${CustomerPhoto}
    Set Suite VAriable  ${CustomerPhoto}
    
    # ${resp}=    Verify Phone Otp and Create Loan Application   ${phone}   13   ${custid}    ${firstName}    ${lastName}    ${phoneNo}    ${countryCodes[0]}    ${locId}    ${kyc_list1}
    ${resp}=  Verify Phone and Create Loan Application with customer details  ${phone}  ${OtpPurpose['ConsumerVerifyPhone']}  ${custid}  ${locId}   ${CustomerPhoto}  ${kyc_list1}  firstName=${firstName}  lastName=${lastName}  phoneNo=${phoneNo}  countryCode=${countryCodes[0]}  gender=${gender}  dob=${dob}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Test Variable  ${loan_uuid}  ${resp.json()['uid']}
    Set Test Variable  ${loan_id}  ${resp.json()['id']}

    #  ${kyc_list1}=           Create Dictionary  isCoApplicant=${bool[0]}  maritalStatus=${maritalStatus[1]}  employmentStatus=${employmentStatus[0]}  monthlyIncome=${monthlyIncome}  aadhaar=${aadhaar}  pan=${pan}  isAadhaarVerified=${bool[1]}  isPanVerified=${bool[1]}  nomineeType=${nomineeType[1]}  nomineeName=${nomineeName}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentPin=${permanentPin}  permanentCity=${permanentCity}  permanentState=${permanentState}  currentAddress1=${currentAddress1}  currentAddress2=${currentAddress2}  currentPin=${currentPin}  currentCity=${currentCity}  currentState=${currentState}    otherAttachments=${otherAttachmentsList}  panAttachments=${panAttachments}  aadhaarAttachments=${aadhaarAttachments}
    # Log  ${kyc_list1}
    # ${resp}=  Create Loan Application    ${pcid14}  ${fname}  ${lname}  ${phone}  ${countryCodes[0]}  ${email}  ${categoryid}  ${typeid}  ${Productid}  ${locId}  ${place}  ${invoiceAmount}  ${downpaymentAmount}  ${requestedAmount}  ${remarks}  ${LoanAction[0]}  ${pcid14}  ${jpgfile}  ${fileSize}  ${caption1}  ${fileType1}  ${order}  ${kyc_list1}
    # Log  ${resp.content}

    ${resp}=    Get Loan Application By uid  ${loan_uuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Test Variable  ${loanApplicationRefNo}  ${resp.json()['referenceNo']}
    Should Be Equal As Strings   ${resp.json()['status']['id']}     ${status_id0}
    
   
    
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
    ${caption2}=  Fakerlibrary.Sentence
    Set Suite Variable    ${caption2}

    ${resp}=  db.getType   ${pdffile} 
    Log  ${resp}
    ${fileType3}=  Get From Dictionary       ${resp}    ${pdffile} 
    Set Suite Variable    ${fileType3}
    ${caption3}=  Fakerlibrary.Sentence
    Set Suite Variable    ${caption3}

    ${otherAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${jpgfile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType1}  order=${order}
    ${otherAttachmentsList}=    Create List  ${otherAttachments}

    ${panAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${pngfile}  fileSize=${fileSize}  caption=${caption2}  fileType=${fileType2}  order=${order}
    ${panAttachments}=    Create List  ${panAttachments}

    ${aadhaarAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption3}  fileType=${fileType3}  order=${order}
    ${aadhaarAttachments}=    Create List  ${aadhaarAttachments}

    ${kyc_list1}=    Create Dictionary    isCoApplicant=${bool[0]}    maritalStatus=${maritalStatus[1]}   employmentStatus=${employmentStatus[0]}    monthlyIncome=${monthlyIncome}  aadhaar=${aadhaar}   pan=${pan}  isAadhaarVerified=${bool[1]}  isPanVerified=${bool[1]}  nomineeType=${nomineeType[1]}   nomineeName=${nomineeName}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentPin=${permanentPin}  permanentCity=${permanentCity}  permanentState=${permanentState}   currentAddress1=${currentAddress1}  currentAddress2=${currentAddress2}  currentPin=${currentPin}  currentCity=${currentCity}  currentState=${currentState}     otherAttachments=${otherAttachmentsList}    panAttachments=${panAttachments}  aadhaarAttachments=${aadhaarAttachments}
    Log  ${kyc_list1}
    ${resp}=   Update Loan Application   ${loan_uuid}    ${pcid14}       ${categoryid}   ${typeid}   ${status_id0}   ${Productid}   ${locId}   ${place}   ${invoiceAmount1}  ${downpaymentAmount}  ${requestedAmount}  ${remarks}       ${LoanAction[0]}  ${pcid14}  ${jpgfile}  ${fileSize}  ${caption1}  ${fileType1}  ${order}     ${kyc_list1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    

     #  ${kyc_list1}=           Create Dictionary  isCoApplicant=${bool[0]}  maritalStatus=${maritalStatus[1]}  employmentStatus=${employmentStatus[0]}  monthlyIncome=${monthlyIncome}  aadhaar=${aadhaar}  pan=${pan}  isAadhaarVerified=${bool[1]}  isPanVerified=${bool[1]}  nomineeType=${nomineeType[1]}  nomineeName=${nomineeName}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentPin=${permanentPin}  permanentCity=${permanentCity}  permanentState=${permanentState}  currentAddress1=${currentAddress1}  currentAddress2=${currentAddress2}  currentPin=${currentPin}  currentCity=${currentCity}  currentState=${currentState}    otherAttachments=${otherAttachmentsList}  panAttachments=${panAttachments}  aadhaarAttachments=${aadhaarAttachments}
    # Log  ${kyc_list1}
    # ${resp}=  Create Loan Application    ${pcid14}  ${fname}  ${lname}  ${phone}  ${countryCodes[0]}  ${email}  ${categoryid}  ${typeid}  ${Productid}  ${locId}  ${place}  ${invoiceAmount}  ${downpaymentAmount}  ${requestedAmount}  ${remarks}  ${LoanAction[0]}  ${pcid14}  ${jpgfile}  ${fileSize}  ${caption1}  ${fileType1}  ${order}  ${kyc_list1}
    # Log  ${resp.content}

    ${resp}=    Get Loan Application By uid  ${loan_uuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['referenceNo']}      ${loanApplicationRefNo}
    Should Be Equal As Strings   ${resp.json()['status']['id']}     ${status_id0}
    

JD-TC-UpdateLoanApplication-2
                                  
    [Documentation]               Create and update Loan Application with co-applicant 

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
   
    clear_customer   ${PUSERNAME30}
    
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
    # Set Test Variable    ${countryCodes[0]}   ${resp.json()[0]['countryCode']}
    Set Test Variable    ${email}  ${fname}${C_Email}.ynwtest@netvarth.com


    ${resp}=  categorytype   ${account_id}
    ${resp}=  tasktype       ${account_id}
    ${resp}=  loanStatus     ${account_id}
    ${resp}=  loanProduct    ${account_id}
    ${resp}=  loanScheme     ${account_id}

    ${resp}=    Generate Loan Application Otp for Phone Number    ${phone}  ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${kyc_list1}=           Create Dictionary  isCoApplicant=${bool[0]}
    
    # ${resp}=    Verify Phone Otp and Create Loan Application   ${phone}   13   ${custid}    ${firstName}    ${lastName}    ${phoneNo}    ${countryCodes[0]}    ${locId}    ${kyc_list1}
    ${resp}=  Verify Phone and Create Loan Application with customer details  ${phone}  ${OtpPurpose['ConsumerVerifyPhone']}  ${custid}  ${locId}   ${CustomerPhoto}  ${kyc_list1}  firstName=${firstName}  lastName=${lastName}  phoneNo=${phoneNo}  countryCode=${countryCodes[0]}  gender=${gender}  dob=${dob}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${loan_uuid1}  ${resp.json()['uid']}
    Set Test Variable  ${loan_id1}  ${resp.json()['id']}

    ${resp}=    Get Loan Application By uid  ${loan_uuid1} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Test Variable  ${loanApplicationRefNo}  ${resp.json()['referenceNo']}
    Should Be Equal As Strings   ${resp.json()['status']['id']}     ${status_id0}
    
   
    
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


    ${otherAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${jpgfile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType1}  order=${order}
    ${otherAttachmentsList}=    Create List  ${otherAttachments}

    ${panAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${pngfile}  fileSize=${fileSize}  caption=${caption2}  fileType=${fileType2}  order=${order}
    ${panAttachments}=    Create List  ${panAttachments}

    ${aadhaarAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption3}  fileType=${fileType3}  order=${order}
    ${aadhaarAttachments}=    Create List  ${aadhaarAttachments}

    ${kyc_list1}=    Create Dictionary    isCoApplicant=${bool[0]}    maritalStatus=${maritalStatus[1]}   employmentStatus=${employmentStatus[0]}    monthlyIncome=${monthlyIncome}  aadhaar=${aadhaar}   pan=${pan}  isAadhaarVerified=${bool[1]}  isPanVerified=${bool[1]}  nomineeType=${nomineeType[1]}   nomineeName=${nomineeName}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentPin=${permanentPin}  permanentCity=${permanentCity}  permanentState=${permanentState}   currentAddress1=${currentAddress1}  currentAddress2=${currentAddress2}  currentPin=${currentPin}  currentCity=${currentCity}  currentState=${currentState}     otherAttachments=${otherAttachmentsList}    panAttachments=${panAttachments}  aadhaarAttachments=${aadhaarAttachments}
    Log  ${kyc_list1}
    ${resp}=   Update Loan Application   ${loan_uuid1}    ${pcid14}      ${categoryid}   ${typeid}   ${status_id0}   ${Productid}   ${locId}   ${place}   ${invoiceAmount1}  ${downpaymentAmount}  ${requestedAmount}  ${remarks}       ${LoanAction[0]}  ${pcid14}  ${jpgfile}  ${fileSize}  ${caption1}  ${fileType1}  ${order}     ${kyc_list1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    
    ${resp}=    Get Loan Application By uid  ${loan_uuid1} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['status']['id']}     ${status_id0}
    



JD-TC-UpdateLoanApplication-3
                                  
    [Documentation]               update Loan Application with already updated loan application

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
    
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME10}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable    ${phone}   ${resp.json()[0]['phoneNo']}
    # Set Test Variable    ${countryCodes[0]}   ${resp.json()[0]['countryCode']}
    Set Test Variable    ${email}  ${fname}${C_Email}.ynwtest@netvarth.com

    ${resp}=    Get Loan Application By uid  ${loan_uuid1} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Test Variable  ${loanApplicationRefNo}  ${resp.json()['referenceNo']}
    Should Be Equal As Strings   ${resp.json()['status']['id']}     ${status_id0}

      
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

    ${kyc_list1}=    Create Dictionary    isCoApplicant=${bool[0]}    maritalStatus=${maritalStatus[1]}   employmentStatus=${employmentStatus[0]}    monthlyIncome=${monthlyIncome}  aadhaar=${aadhaar}   pan=${pan}  isAadhaarVerified=${bool[1]}  isPanVerified=${bool[1]}  nomineeType=${nomineeType[1]}   nomineeName=${nomineeName}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentPin=${permanentPin}  permanentCity=${permanentCity}  permanentState=${permanentState}   currentAddress1=${currentAddress1}  currentAddress2=${currentAddress2}  currentPin=${currentPin}  currentCity=${currentCity}  currentState=${currentState}     otherAttachments=${otherAttachmentsList}    panAttachments=${panAttachments}  aadhaarAttachments=${aadhaarAttachments}
    Log  ${kyc_list1}
    ${resp}=   Update Loan Application   ${loan_uuid1}    ${pcid14}        ${categoryid}   ${typeid}   ${status_id0}   ${Productid}   ${locId}   ${place}   ${invoiceAmount1}  ${downpaymentAmount}  ${requestedAmount}  ${remarks}       ${LoanAction[0]}  ${pcid14}  ${jpgfile}  ${fileSize}  ${caption1}  ${fileType1}  ${order}     ${kyc_list1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    
    ${resp}=    Get Loan Application By uid  ${loan_uuid1} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['referenceNo']}      ${loanApplicationRefNo}
    Should Be Equal As Strings   ${resp.json()['status']['id']}     ${status_id0}
    


    

JD-TC-UpdateLoanApplication-4
                                  
    [Documentation]      update Loan Application -   give maritalStatus different in create loan application


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
   
    clear_customer   ${PUSERNAME30}
    
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
    # Set Test Variable    ${countryCodes[0]}   ${resp.json()[0]['countryCode']}
    Set Test Variable    ${email}  ${fname}${C_Email}.ynwtest@netvarth.com


    ${resp}=  categorytype   ${account_id}
    ${resp}=  tasktype       ${account_id}
    ${resp}=  loanStatus     ${account_id}
    ${resp}=  loanProduct    ${account_id}
    ${resp}=  loanScheme     ${account_id}
    ${resp}=    Generate Loan Application Otp for Phone Number    ${phone}  ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${kyc_list1}=           Create Dictionary  isCoApplicant=${bool[0]}
    
    # ${resp}=    Verify Phone Otp and Create Loan Application   ${phone}   13   ${custid}    ${firstName}    ${lastName}    ${phoneNo}    ${countryCodes[0]}    ${locId}    ${kyc_list1}
    ${resp}=  Verify Phone and Create Loan Application with customer details  ${phone}  ${OtpPurpose['ConsumerVerifyPhone']}  ${custid}  ${locId}   ${CustomerPhoto}  ${kyc_list1}  firstName=${firstName}  lastName=${lastName}  phoneNo=${phoneNo}  countryCode=${countryCodes[0]}  gender=${gender}  dob=${dob}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${loan_uuid4}  ${resp.json()['uid']}
    Set Test Variable  ${loan_id4}  ${resp.json()['id']}

    ${resp}=    Get Loan Application By uid  ${loan_uuid4} 
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


    ${otherAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${jpgfile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType1}  order=${order}
    ${otherAttachmentsList}=    Create List  ${otherAttachments}

    ${panAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${pngfile}  fileSize=${fileSize}  caption=${caption2}  fileType=${fileType2}  order=${order}
    ${panAttachments}=    Create List  ${panAttachments}

    ${aadhaarAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption3}  fileType=${fileType3}  order=${order}
    ${aadhaarAttachments}=    Create List  ${aadhaarAttachments}

    ${kyc_list1}=    Create Dictionary    isCoApplicant=${bool[0]}    maritalStatus=${maritalStatus[0]}   employmentStatus=${employmentStatus[0]}    monthlyIncome=${monthlyIncome}  aadhaar=${aadhaar}   pan=${pan}  isAadhaarVerified=${bool[1]}  isPanVerified=${bool[1]}  nomineeType=${nomineeType[1]}   nomineeName=${nomineeName}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentPin=${permanentPin}  permanentCity=${permanentCity}  permanentState=${permanentState}   currentAddress1=${currentAddress1}  currentAddress2=${currentAddress2}  currentPin=${currentPin}  currentCity=${currentCity}  currentState=${currentState}     otherAttachments=${otherAttachmentsList}    panAttachments=${panAttachments}  aadhaarAttachments=${aadhaarAttachments}
    Log  ${kyc_list1}
    ${resp}=   Update Loan Application   ${loan_uuid4}    ${pcid14}       ${categoryid}   ${typeid}   ${status_id0}   ${Productid}   ${locId}   ${place}   ${invoiceAmount1}  ${downpaymentAmount}  ${requestedAmount}  ${remarks}       ${LoanAction[0]}  ${pcid14}  ${jpgfile}  ${fileSize}  ${caption1}  ${fileType1}  ${order}     ${kyc_list1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    
    ${resp}=    Get Loan Application By uid  ${loan_uuid4} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['referenceNo']}      ${loanApplicationRefNo}
    Should Be Equal As Strings   ${resp.json()['status']['id']}     ${status_id0}
    
# JD-TC-UpdateLoanApplication-5
                                  
#     [Documentation]      update Loan Application -  for family member

#     ${gender}                     Random Element    ${Genderlist}                   
#       ${dob}                        FakerLibrary.Date
#       ${fname}                      FakerLibrary. name
#       ${lname}                      FakerLibrary.last_name
#       ${email}                      FakerLibrary.email
#       ${city}                       FakerLibrary.city
#       ${state}                      FakerLibrary.state
#       ${address}                    FakerLibrary.address
#       ${primnum}                    FakerLibrary.Numerify   text=%%%%%%%%%%
#       ${altno}                      FakerLibrary.Numerify   text=%%%%%%%%%%
#       ${numt}                       FakerLibrary.Numerify   text=%%%%%%%%%%
#       ${numw}                       FakerLibrary.Numerify   text=%%%%%%%%%%

#       Set Suite Variable      ${gender}
#       Set Suite Variable      ${dob}
#       Set Suite Variable      ${fname}
#       Set Suite Variable      ${lname}
#       Set Suite Variable      ${email}
#       Set Suite Variable      ${city}
#       Set Suite Variable      ${state}
#       Set Suite Variable      ${address}
#       Set Suite Variable      ${primnum}
#       Set Suite Variable      ${altno}
#       Set Suite Variable      ${numt}
#       Set Suite Variable      ${numw}

#       ${resp}=                      Consumer Login  ${CUSERNAME11}  ${PASSWORD}
#       Log                           ${resp.json()}
#       Should Be Equal As Strings    ${resp.status_code}  200
#       ${resp}=                      Add Family  ${fname}  ${lname}  ${dob}  ${gender}  ${email}  ${city}  ${state}   ${address}  ${primnum}  ${altno}  ${countryCodes[0]}  ${countryCodes[0]}  ${numt}  ${countryCodes[0]}  ${numw}
#       Log                           ${resp.json()}
#       Should Be Equal As Strings    ${resp.status_code}  200

#       ${resp}=                      ListFamilyMember
#       Log                           ${resp.json()}
#       Should Be Equal As Strings    ${resp.status_code}  200
#       Should Be Equal As Strings    ${resp.json()[0]['userProfile']['firstName']}                        ${fname}
#       Should Be Equal As Strings    ${resp.json()[0]['userProfile']['lastName']}                         ${lname}
#       Should Be Equal As Strings    ${resp.json()[0]['userProfile']['address']}                          ${address}
#       Should Be Equal As Strings    ${resp.json()[0]['userProfile']['gender']}                           ${gender}
#       Should Be Equal As Strings    ${resp.json()[0]['userProfile']['email']}                            ${email}
#       Should Be Equal As Strings    ${resp.json()[0]['userProfile']['whatsAppNum']['countryCode']}       ${countryCodes[0]}
#       Should Be Equal As Strings    ${resp.json()[0]['userProfile']['whatsAppNum']['number']}            ${numt}
#       Should Be Equal As Strings    ${resp.json()[0]['userProfile']['telegramNum']['countryCode']}       ${countryCodes[0]}
#       Should Be Equal As Strings    ${resp.json()[0]['userProfile']['telegramNum']['number']}            ${numw}
      


#      ${resp}=   ProviderLogin  ${PUSERNAME30}  ${PASSWORD} 
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
   
#     clear_customer   ${PUSERNAME30}
    
#     ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME14}  
#     Log  ${resp.content}
#     Should Be Equal As Strings      ${resp.status_code}  200
#     IF   '${resp.content}' == '${emptylist}'
#         ${resp1}=  AddCustomer  ${CUSERNAME14}  firstName=${fname}   lastName=${lname}
#         Log  ${resp1.content}
#         Should Be Equal As Strings  ${resp1.status_code}  200
#         Set Test Variable  ${pcid14}   ${resp1.json()}
#     ELSE
#         Set Test Variable  ${pcid14}  ${resp.json()[0]['id']}
#     END

#        ${firstname1}=  FakerLibrary.first_name
#       Set Suite Variable  ${firstname1}
#       ${lastname1}=  FakerLibrary.last_name
#       Set Suite Variable  ${lastname1}
#       ${dob1}=  FakerLibrary.Date
#       Set Suite Variable  ${dob1}
#       ${gender1}=  Random Element    ${Genderlist}
#       Set Suite Variable  ${gender1}
#       ${Familymember_ph}=  Evaluate  ${CUSERNAME14}+300000

#       ${resp}=  AddFamilyMemberByProviderWithPhoneNo  ${provider_id}  ${firstname1}  ${lastname1}  ${dob1}  ${gender1}  ${Familymember_ph}
#       Log  ${resp.json()}
#       Set Suite Variable  ${mem_id0}  ${resp.json()}
#       ${resp}=  ListFamilyMemberByProvider  ${pcid14}
#       Should Be Equal As Strings  ${resp.status_code}  200
#       Log  ${resp.json()}
#       Verify Response List  ${resp}  0  id=${mem_id0}   
#       Should Be Equal As Strings  ${resp.json()[0]['firstName']}  ${firstname1}
#       Should Be Equal As Strings  ${resp.json()[0]['lastName']}  ${lastname1}
#       Should Be Equal As Strings  ${resp.json()[0]['dob']}  ${dob1}
#       Should Be Equal As Strings  ${resp.json()[0]['gender']}  ${gender1}

#       ${resp}=  ListFamilyMemberByProvider  ${pcid14}
#       Should Be Equal As Strings  ${resp.status_code}  200


#     ${resp}=  categorytype   ${account_id}
#     ${resp}=  tasktype       ${account_id}
#     ${resp}=  loanStatus     ${account_id}
#     ${resp}=  loanProduct    ${account_id}
#     ${resp}=  loanScheme     ${account_id}
#     ${invoiceAmount}         FakerLibrary.Random Number
#     ${downpaymentAmount}     FakerLibrary.Random Number
#     ${requestedAmount}       FakerLibrary.Random Number
#     ${remarks}               FakerLibrary.sentence
#     ${monthlyIncome}         FakerLibrary.Random Number
#     ${aadhaar}               FakerLibrary.Random Number
#     ${pan}                   FakerLibrary.Random Number
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


#     ${kyc_list1}=           Create Dictionary   isCoApplicant=${bool[0]}  maritalStatus=${maritalStatus[1]}   employmentStatus=${employmentStatus[0]}  monthlyIncome=${monthlyIncome}  aadhaar=${aadhaar}  pan=${pan}  isAadhaarVerified=${bool[1]}  isPanVerified=${bool[1]}  nomineeType=${nomineeType[1]}  nomineeName=${nomineeName}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentPin=${permanentPin}  permanentCity=${permanentCity}  permanentState=${permanentState}  currentAddress1=${currentAddress1}  currentAddress2=${currentAddress2}  currentPin=${currentPin}  currentCity=${currentCity}  currentState=${currentState}
#     Log  ${kyc_list1}
#     ${resp}=  Create Loan Application    ${pcid14}  ${categoryid}  ${typeid}  ${Productid}  ${locId}  ${place}  ${invoiceAmount}  ${downpaymentAmount}  ${requestedAmount}  ${remarks}  ${kyc_list1}
#     Log  ${resp.content}
#     Should Be Equal As Strings     ${resp.status_code}    200
#     Set Suite Variable  ${loan_uuid5}  ${resp.json()['uid']}
#     Set Test Variable  ${loan_id5}  ${resp.json()['id']}

#     ${resp}=  Get Loan Application With Filter
#     Log  ${resp.content}
#     Should Be Equal As Strings     ${resp.status_code}    200
#     Set Test Variable  ${loanApplicationRefNo}  ${resp.json()[0]['referenceNo']}
#     Should Be Equal As Strings   ${resp.json()[0]['status']['id']}     ${status_id0}
    
   
    
#     ${invoiceAmount1}         FakerLibrary.Random Number
#     ${downpaymentAmount}     FakerLibrary.Random Number
#     ${requestedAmount}       FakerLibrary.Random Number
#     ${remarks}               FakerLibrary.sentence
#     ${monthlyIncome}         FakerLibrary.Random Number
#     ${aadhaar}               FakerLibrary.Random Number
#     ${pan}                   FakerLibrary.Random Number
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


#     ${kyc_list1}=    Create Dictionary    isCoApplicant=${bool[0]}    maritalStatus=${maritalStatus[2]}   employmentStatus=${employmentStatus[0]}    monthlyIncome=${monthlyIncome}  aadhaar=${aadhaar}   pan=${pan}  isAadhaarVerified=${bool[1]}  isPanVerified=${bool[1]}  nomineeType=${nomineeType[1]}   nomineeName=${nomineeName}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentPin=${permanentPin}  permanentCity=${permanentCity}  permanentState=${permanentState}   currentAddress1=${currentAddress1}  currentAddress2=${currentAddress2}  currentPin=${currentPin}  currentCity=${currentCity}  currentState=${currentState}
#     Log  ${kyc_list1}
#     ${resp}=   Update Loan Application   ${loan_uuid4}    ${mem_id0}   ${categoryid}   ${typeid}   ${status_id0}   ${Productid}   ${locId}   ${place}   ${invoiceAmount1}  ${downpaymentAmount}  ${requestedAmount}  ${remarks}  ${kyc_list1}
#     Log  ${resp.content}
#     Should Be Equal As Strings     ${resp.status_code}    200
    
#     ${resp}=  Get Loan Application With Filter  
#     Log  ${resp.content}
#     Should Be Equal As Strings   ${resp.status_code}    200
#     Should Be Equal As Strings   ${resp.json()[0]['referenceNo']}      ${loanApplicationRefNo}
#     Should Be Equal As Strings   ${resp.json()[0]['status']['id']}     ${status_id0}
    

JD-TC-UpdateLoanApplication-5
                                  
    [Documentation]      update Loan Application  where Category is empty


    ${resp}=  Consumer Login  ${CUSERNAME14}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   ProviderLogin  ${PUSERNAME31}  ${PASSWORD} 
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

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME13}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME13}  firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid14}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid14}  ${resp.json()[0]['id']}
    END

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME13}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable   ${custid}    ${resp.json()[0]['id']}
    Set Test Variable   ${firstName}    ${resp.json()[0]['firstName']}
    Set Test Variable   ${lastName}    ${resp.json()[0]['lastName']}
    Set Test Variable   ${phoneNo}    ${resp.json()[0]['phoneNo']}

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

    ${resp}=    Generate Loan Application Otp for Phone Number    ${phone}  ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${kyc_list1}=           Create Dictionary  isCoApplicant=${bool[0]}
    
    # ${resp}=    Verify Phone Otp and Create Loan Application   ${phone}   13   ${custid}    ${firstName}    ${lastName}    ${phoneNo}    ${countryCodes[0]}    ${locId}    ${kyc_list1}
    ${resp}=  Verify Phone and Create Loan Application with customer details  ${phone}  ${OtpPurpose['ConsumerVerifyPhone']}  ${custid}  ${locId}   ${CustomerPhoto}  ${kyc_list1}  firstName=${firstName}  lastName=${lastName}  phoneNo=${phoneNo}  countryCode=${countryCodes[0]}  gender=${gender}  dob=${dob}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Test Variable  ${loan_uuid5}  ${resp.json()['uid']}
    Set Test Variable  ${loan_id5}  ${resp.json()['id']}

    ${resp}=    Get Loan Application By uid  ${loan_uuid5} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Test Variable  ${loanApplicationRefNo}  ${resp.json()['referenceNo']}
    Should Be Equal As Strings   ${resp.json()['status']['id']}     ${status_id0}
    
   
    
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


    ${otherAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${jpgfile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType1}  order=${order}
    ${otherAttachmentsList}=    Create List  ${otherAttachments}

    ${panAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${pngfile}  fileSize=${fileSize}  caption=${caption2}  fileType=${fileType2}  order=${order}
    ${panAttachments}=    Create List  ${panAttachments}

    ${aadhaarAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption3}  fileType=${fileType3}  order=${order}
    ${aadhaarAttachments}=    Create List  ${aadhaarAttachments}

    ${kyc_list1}=    Create Dictionary    isCoApplicant=${bool[0]}    maritalStatus=${maritalStatus[1]}   employmentStatus=${employmentStatus[0]}    monthlyIncome=${monthlyIncome}  aadhaar=${aadhaar}   pan=${pan}  isAadhaarVerified=${bool[1]}  isPanVerified=${bool[1]}  nomineeType=${nomineeType[1]}   nomineeName=${nomineeName}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentPin=${permanentPin}  permanentCity=${permanentCity}  permanentState=${permanentState}   currentAddress1=${currentAddress1}  currentAddress2=${currentAddress2}  currentPin=${currentPin}  currentCity=${currentCity}  currentState=${currentState}     otherAttachments=${otherAttachmentsList}    panAttachments=${panAttachments}  aadhaarAttachments=${aadhaarAttachments}
    Log  ${kyc_list1}
    ${resp}=   Update Loan Application   ${loan_uuid5}    ${pcid14}      ${categoryid}   ${typeid}   ${status_id0}   ${Productid}   ${locId}   ${place}   ${invoiceAmount1}  ${downpaymentAmount}  ${requestedAmount}  ${remarks}       ${LoanAction[0]}  ${pcid14}  ${jpgfile}  ${fileSize}  ${caption1}  ${fileType1}  ${order}     ${kyc_list1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    
    ${resp}=    Get Loan Application By uid  ${loan_uuid5} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()[0]['referenceNo']}      ${loanApplicationRefNo}
    Should Be Equal As Strings   ${resp.json()[0]['status']['id']}     ${status_id0}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()[0]['id']}  ${loan_id5}
    Should Be Equal As Strings   ${resp.json()[0]['uid']}  ${loan_uuid5}
    Should Be Equal As Strings   ${resp.json()[0]['accountId']}  ${account_id}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['id']}  ${pcid14}
    # Should Be Equal As Strings   ${resp.json()[0]['remarks']}  ${remarks}
  #  Should Be Equal As Strings   ${resp.json()[0]['category']['id']}  ${empty}
    Should Be Equal As Strings   ${resp.json()[0]['type']['id']}  ${typeid}
    # Should Be Equal As Strings   ${resp.json()[0]['loanProduct']['id']}  ${Productid}
    # Should Be Equal As Str
    

JD-TC-UpdateLoanApplication-6
                                  
    [Documentation]      update Loan Application - where Type is empty

    ${resp}=  Consumer Login  ${CUSERNAME14}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   ProviderLogin  ${PUSERNAME32}  ${PASSWORD} 
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

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME12}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME12}  firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid14}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid14}  ${resp.json()[0]['id']}
    END

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME12}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable   ${custid}    ${resp.json()[0]['id']}
    Set Test Variable   ${firstName}    ${resp.json()[0]['firstName']}
    Set Test Variable   ${lastName}    ${resp.json()[0]['lastName']}
    Set Test Variable   ${phoneNo}    ${resp.json()[0]['phoneNo']}

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

    ${resp}=    Generate Loan Application Otp for Phone Number    ${phone}  ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${kyc_list1}=           Create Dictionary  isCoApplicant=${bool[0]}
    
    # ${resp}=    Verify Phone Otp and Create Loan Application   ${phone}   13   ${custid}    ${firstName}    ${lastName}    ${phoneNo}    ${countryCodes[0]}    ${locId}    ${kyc_list1}
    ${resp}=  Verify Phone and Create Loan Application with customer details  ${phone}  ${OtpPurpose['ConsumerVerifyPhone']}  ${custid}  ${locId}   ${CustomerPhoto}  ${kyc_list1}  firstName=${firstName}  lastName=${lastName}  phoneNo=${phoneNo}  countryCode=${countryCodes[0]}  gender=${gender}  dob=${dob}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Test Variable  ${loan_uuid6}  ${resp.json()['uid']}
    Set Test Variable  ${loan_id6}  ${resp.json()['id']}

    ${resp}=    Get Loan Application By uid  ${loan_uuid5} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Test Variable  ${loanApplicationRefNo}  ${resp.json()['referenceNo']}
    Should Be Equal As Strings   ${resp.json()['status']['id']}     ${status_id0}
    
   
    
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


    ${otherAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${jpgfile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType1}  order=${order}
    ${otherAttachmentsList}=    Create List  ${otherAttachments}

    ${panAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${pngfile}  fileSize=${fileSize}  caption=${caption2}  fileType=${fileType2}  order=${order}
    ${panAttachments}=    Create List  ${panAttachments}

    ${aadhaarAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption3}  fileType=${fileType3}  order=${order}
    ${aadhaarAttachments}=    Create List  ${aadhaarAttachments}

    ${kyc_list1}=    Create Dictionary    isCoApplicant=${bool[0]}    maritalStatus=${maritalStatus[1]}   employmentStatus=${employmentStatus[0]}    monthlyIncome=${monthlyIncome}  aadhaar=${aadhaar}   pan=${pan}  isAadhaarVerified=${bool[1]}  isPanVerified=${bool[1]}  nomineeType=${nomineeType[1]}   nomineeName=${nomineeName}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentPin=${permanentPin}  permanentCity=${permanentCity}  permanentState=${permanentState}   currentAddress1=${currentAddress1}  currentAddress2=${currentAddress2}  currentPin=${currentPin}  currentCity=${currentCity}  currentState=${currentState}     otherAttachments=${otherAttachmentsList}    panAttachments=${panAttachments}  aadhaarAttachments=${aadhaarAttachments}
    Log  ${kyc_list1}
    ${resp}=   Update Loan Application   ${loan_uuid6}    ${pcid14}       ${categoryid}   ${typeid}   ${status_id0}   ${Productid}   ${locId}   ${place}   ${invoiceAmount1}  ${downpaymentAmount}  ${requestedAmount}  ${remarks}       ${LoanAction[0]}  ${pcid14}  ${jpgfile}  ${fileSize}  ${caption1}  ${fileType1}  ${order}     ${kyc_list1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    
    ${resp}=    Get Loan Application By uid  ${loan_uuid6} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['referenceNo']}      ${loanApplicationRefNo}
    Should Be Equal As Strings   ${resp.json()['status']['id']}     ${status_id0}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['id']}  ${loan_id6}
    Should Be Equal As Strings   ${resp.json()['uid']}  ${loan_uuid6}
    Should Be Equal As Strings   ${resp.json()['accountId']}  ${account_id}
    Should Be Equal As Strings   ${resp.json()['customer']['id']}  ${pcid14}
    Should Be Equal As Strings   ${resp.json()['category']['id']}  ${categoryid}
   # Should Be Equal As Strings   ${resp.json()[0]['type']['id']}  ${empty}
    # Should Be Equal As Strings   ${resp.json()[0]['loanProduct']['id']}  ${Productid}
 
    
JD-TC-UpdateLoanApplication-7
                                  
    [Documentation]      update Loan Application -  where Product is empty


    ${resp}=  Consumer Login  ${CUSERNAME14}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   ProviderLogin  ${PUSERNAME33}  ${PASSWORD} 
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

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME12}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME12}  firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid14}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid14}  ${resp.json()[0]['id']}
    END

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME12}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable    ${phone}   ${resp.json()[0]['phoneNo']}
    # Set Test Variable    ${countryCodes[0]}   ${resp.json()[0]['countryCode']}
    Set Test Variable    ${email}  ${fname}${C_Email}.ynwtest@netvarth.com

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


    ${kyc_list1}=           Create Dictionary  isCoApplicant=${bool[0]}  maritalStatus=${maritalStatus[1]}   employmentStatus=${employmentStatus[0]}  monthlyIncome=${monthlyIncome}  aadhaar=${aadhaar}  pan=${pan}  isAadhaarVerified=${bool[1]}  isPanVerified=${bool[1]}  nomineeType=${nomineeType[1]}  nomineeName=${nomineeName}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentPin=${permanentPin}  permanentCity=${permanentCity}  permanentState=${permanentState}  currentAddress1=${currentAddress1}  currentAddress2=${currentAddress2}  currentPin=${currentPin}  currentCity=${currentCity}  currentState=${currentState}     otherAttachments=${otherAttachmentsList}  panAttachments=${panAttachments}  aadhaarAttachments=${aadhaarAttachments}
    Log  ${kyc_list1}
    ${resp}=  Create Loan Application    ${pcid14}    ${fname}  ${lname}  ${phone}  ${countryCodes[0]}  ${email}    ${categoryid}  ${typeid}  ${Productid}  ${locId}  ${place}  ${invoiceAmount}  ${downpaymentAmount}  ${requestedAmount}  ${remarks}    ${LoanAction[0]}  ${pcid14}  ${jpgfile}  ${fileSize}  ${caption1}  ${fileType1}  ${order}  ${kyc_list1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Test Variable  ${loan_uuid7}  ${resp.json()['uid']}
    Set Test Variable  ${loan_id7}  ${resp.json()['id']}

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

    ${otherAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${jpgfile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType1}  order=${order}
    ${otherAttachmentsList}=    Create List  ${otherAttachments}

    ${panAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${pngfile}  fileSize=${fileSize}  caption=${caption2}  fileType=${fileType2}  order=${order}
    ${panAttachments}=    Create List  ${panAttachments}

    ${aadhaarAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption3}  fileType=${fileType3}  order=${order}
    ${aadhaarAttachments}=    Create List  ${aadhaarAttachments}

    ${kyc_list1}=    Create Dictionary    isCoApplicant=${bool[0]}    maritalStatus=${maritalStatus[1]}   employmentStatus=${employmentStatus[0]}    monthlyIncome=${monthlyIncome}  aadhaar=${aadhaar}   pan=${pan}  isAadhaarVerified=${bool[1]}  isPanVerified=${bool[1]}  nomineeType=${nomineeType[1]}   nomineeName=${nomineeName}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentPin=${permanentPin}  permanentCity=${permanentCity}  permanentState=${permanentState}   currentAddress1=${currentAddress1}  currentAddress2=${currentAddress2}  currentPin=${currentPin}  currentCity=${currentCity}  currentState=${currentState}     otherAttachments=${otherAttachmentsList}    panAttachments=${panAttachments}  aadhaarAttachments=${aadhaarAttachments}
    Log  ${kyc_list1}
    ${resp}=   Update Loan Application   ${loan_uuid7}    ${pcid14}        ${categoryid}   ${typeid}   ${status_id0}   ${Productid}   ${locId}   ${place}   ${invoiceAmount1}  ${downpaymentAmount}  ${requestedAmount}  ${remarks}       ${LoanAction[0]}  ${pcid14}  ${jpgfile}  ${fileSize}  ${caption1}  ${fileType1}  ${order}     ${kyc_list1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    
    ${resp}=  Get Loan Application With Filter
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()[0]['referenceNo']}      ${loanApplicationRefNo}
    Should Be Equal As Strings   ${resp.json()[0]['status']['id']}     ${status_id0}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()[0]['id']}  ${loan_id7}
    Should Be Equal As Strings   ${resp.json()[0]['uid']}  ${loan_uuid7}
    Should Be Equal As Strings   ${resp.json()[0]['accountId']}  ${account_id}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['id']}  ${pcid14}
    Should Be Equal As Strings   ${resp.json()[0]['category']['id']}  ${categoryid}
    Should Be Equal As Strings   ${resp.json()[0]['type']['id']}  ${typeid}
    #Should Be Equal As Strings   ${resp.json()[0]['loanProduct']['id']}  ${empty}
 


JD-TC-UpdateLoanApplication-8
                                  
    [Documentation]      update Loan Application - where invoiceAmount is empty


    ${resp}=  Consumer Login  ${CUSERNAME11}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   ProviderLogin  ${PUSERNAME35}  ${PASSWORD} 
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

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME10}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable    ${phone}   ${resp.json()[0]['phoneNo']}
    # Set Test Variable    ${countryCodes[0]}   ${resp.json()[0]['countryCode']}
    Set Test Variable    ${email}  ${fname}${C_Email}.ynwtest@netvarth.com

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


    ${kyc_list1}=           Create Dictionary  isCoApplicant=${bool[0]}  maritalStatus=${maritalStatus[1]}   employmentStatus=${employmentStatus[0]}  monthlyIncome=${monthlyIncome}  aadhaar=${aadhaar}  pan=${pan}  isAadhaarVerified=${bool[1]}  isPanVerified=${bool[1]}  nomineeType=${nomineeType[1]}  nomineeName=${nomineeName}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentPin=${permanentPin}  permanentCity=${permanentCity}  permanentState=${permanentState}  currentAddress1=${currentAddress1}  currentAddress2=${currentAddress2}  currentPin=${currentPin}  currentCity=${currentCity}  currentState=${currentState}     otherAttachments=${otherAttachmentsList}  panAttachments=${panAttachments}  aadhaarAttachments=${aadhaarAttachments}
    Log  ${kyc_list1}

    ${resp}=  Create Loan Application    ${pcid14}    ${fname}  ${lname}  ${phone}  ${countryCodes[0]}  ${email}    ${categoryid}  ${typeid}  ${Productid}  ${locId}  ${place}  ${invoiceAmount}  ${downpaymentAmount}  ${requestedAmount}  ${remarks}    ${LoanAction[0]}  ${pcid14}  ${jpgfile}  ${fileSize}  ${caption1}  ${fileType1}  ${order}  ${kyc_list1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Test Variable  ${loan_uuid9}  ${resp.json()['uid']}
    Set Test Variable  ${loan_id9}  ${resp.json()['id']}

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


    ${otherAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${jpgfile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType1}  order=${order}
    ${otherAttachmentsList}=    Create List  ${otherAttachments}

    ${panAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${pngfile}  fileSize=${fileSize}  caption=${caption2}  fileType=${fileType2}  order=${order}
    ${panAttachments}=    Create List  ${panAttachments}

    ${aadhaarAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption3}  fileType=${fileType3}  order=${order}
    ${aadhaarAttachments}=    Create List  ${aadhaarAttachments}

    ${kyc_list1}=    Create Dictionary    isCoApplicant=${bool[0]}    maritalStatus=${maritalStatus[1]}   employmentStatus=${employmentStatus[0]}    monthlyIncome=${monthlyIncome}  aadhaar=${aadhaar}   pan=${pan}  isAadhaarVerified=${bool[1]}  isPanVerified=${bool[1]}  nomineeType=${nomineeType[1]}   nomineeName=${nomineeName}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentPin=${permanentPin}  permanentCity=${permanentCity}  permanentState=${permanentState}   currentAddress1=${currentAddress1}  currentAddress2=${currentAddress2}  currentPin=${currentPin}  currentCity=${currentCity}  currentState=${currentState}     otherAttachments=${otherAttachmentsList}    panAttachments=${panAttachments}  aadhaarAttachments=${aadhaarAttachments}
    Log  ${kyc_list1}

    ${resp}=   Update Loan Application   ${loan_uuid9}    ${pcid14}       ${categoryid}   ${typeid}   ${status_id0}   ${Productid}   ${locId}   ${place}   ${invoiceAmount1}  ${downpaymentAmount}  ${requestedAmount}  ${remarks}       ${LoanAction[0]}  ${pcid14}  ${jpgfile}  ${fileSize}  ${caption1}  ${fileType1}  ${order}     ${kyc_list1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    
    ${resp}=  Get Loan Application With Filter
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()[0]['referenceNo']}      ${loanApplicationRefNo}
    Should Be Equal As Strings   ${resp.json()[0]['status']['id']}     ${status_id0}
    Should Be Equal As Strings   ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()[0]['id']}  ${loan_id9}
    Should Be Equal As Strings   ${resp.json()[0]['uid']}  ${loan_uuid9}
    Should Be Equal As Strings   ${resp.json()[0]['accountId']}  ${account_id}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['id']}  ${pcid14}
    Should Be Equal As Strings   ${resp.json()[0]['category']['id']}  ${categoryid}
    Should Be Equal As Strings   ${resp.json()[0]['type']['id']}  ${typeid}


JD-TC-UpdateLoanApplication-9
                                  
    [Documentation]      update Loan Application - where aadhar card empty


    ${resp}=  Consumer Login  ${CUSERNAME11}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   ProviderLogin  ${PUSERNAME64}  ${PASSWORD} 
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

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME9}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME9}  firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid14}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid14}  ${resp.json()[0]['id']}
    END

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME9}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable    ${phone}   ${resp.json()[0]['phoneNo']}
    # Set Test Variable    ${countryCodes[0]}   ${resp.json()[0]['countryCode']}
    Set Test Variable    ${email}  ${fname}${C_Email}.ynwtest@netvarth.com

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


    ${kyc_list1}=           Create Dictionary  isCoApplicant=${bool[0]}  maritalStatus=${maritalStatus[1]}   employmentStatus=${employmentStatus[0]}  monthlyIncome=${monthlyIncome}  aadhaar=${aadhaar}  pan=${pan}  isAadhaarVerified=${bool[1]}  isPanVerified=${bool[1]}  nomineeType=${nomineeType[1]}  nomineeName=${nomineeName}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentPin=${permanentPin}  permanentCity=${permanentCity}  permanentState=${permanentState}  currentAddress1=${currentAddress1}  currentAddress2=${currentAddress2}  currentPin=${currentPin}  currentCity=${currentCity}  currentState=${currentState}     otherAttachments=${otherAttachmentsList}  panAttachments=${panAttachments}  aadhaarAttachments=${aadhaarAttachments}
    Log  ${kyc_list1}
    ${resp}=  Create Loan Application    ${pcid14}    ${fname}  ${lname}  ${phone}  ${countryCodes[0]}  ${email}    ${categoryid}  ${typeid}  ${Productid}  ${locId}  ${place}  ${invoiceAmount}  ${downpaymentAmount}  ${requestedAmount}  ${remarks}    ${LoanAction[0]}  ${pcid14}  ${jpgfile}  ${fileSize}  ${caption1}  ${fileType1}  ${order}  ${kyc_list1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Test Variable  ${loan_uuid9}  ${resp.json()['uid']}
    Set Test Variable  ${loan_id9}  ${resp.json()['id']}

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


    ${otherAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${jpgfile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType1}  order=${order}
    ${otherAttachmentsList}=    Create List  ${otherAttachments}

    ${panAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${pngfile}  fileSize=${fileSize}  caption=${caption2}  fileType=${fileType2}  order=${order}
    ${panAttachments}=    Create List  ${panAttachments}

    ${aadhaarAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption3}  fileType=${fileType3}  order=${order}
    ${aadhaarAttachments}=    Create List  ${aadhaarAttachments}

    ${kyc_list1}=    Create Dictionary    isCoApplicant=${bool[0]}    maritalStatus=${maritalStatus[1]}   employmentStatus=${employmentStatus[0]}    monthlyIncome=${monthlyIncome}  aadhaar=${aadhaar}   pan=${pan}  isAadhaarVerified=${bool[1]}  isPanVerified=${bool[1]}  nomineeType=${nomineeType[1]}   nomineeName=${nomineeName}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentPin=${permanentPin}  permanentCity=${permanentCity}  permanentState=${permanentState}   currentAddress1=${currentAddress1}  currentAddress2=${currentAddress2}  currentPin=${currentPin}  currentCity=${currentCity}  currentState=${currentState}     otherAttachments=${otherAttachmentsList}    panAttachments=${panAttachments}  aadhaarAttachments=${aadhaarAttachments}
    Log  ${kyc_list1}
    ${resp}=   Update Loan Application   ${loan_uuid9}    ${pcid14}       ${categoryid}   ${typeid}   ${status_id0}   ${Productid}   ${locId}   ${place}   ${invoiceAmount1}  ${downpaymentAmount}  ${requestedAmount}  ${remarks}       ${LoanAction[0]}  ${pcid14}  ${jpgfile}  ${fileSize}  ${caption1}  ${fileType1}  ${order}     ${kyc_list1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    
    ${resp}=  Get Loan Application With Filter
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()[0]['referenceNo']}      ${loanApplicationRefNo}
    Should Be Equal As Strings   ${resp.json()[0]['status']['id']}     ${status_id0}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()[0]['id']}  ${loan_id9}
    Should Be Equal As Strings   ${resp.json()[0]['uid']}  ${loan_uuid9}
    Should Be Equal As Strings   ${resp.json()[0]['accountId']}  ${account_id}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['id']}  ${pcid14}
    Should Be Equal As Strings   ${resp.json()[0]['category']['id']}  ${categoryid}
    Should Be Equal As Strings   ${resp.json()[0]['type']['id']}  ${typeid}


JD-TC-UpdateLoanApplication-UH1
                                  
    [Documentation]      update Loan Application -  where status is empty

    ${resp}=  Consumer Login  ${CUSERNAME11}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   ProviderLogin  ${PUSERNAME34}  ${PASSWORD} 
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
        Set Test Variable  ${pcid1}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid1}  ${resp.json()[0]['id']}
    END

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME11}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable    ${phone}   ${resp.json()[0]['phoneNo']}
    # Set Test Variable    ${countryCodes[0]}   ${resp.json()[0]['countryCode']}
    Set Test Variable    ${email}  ${fname}${C_Email}.ynwtest@netvarth.com

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

    
    ${otherAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid1}  fileName=${jpgfile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType1}  order=${order}
    ${otherAttachmentsList}=    Create List  ${otherAttachments}

    ${panAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid1}  fileName=${pngfile}  fileSize=${fileSize}  caption=${caption2}  fileType=${fileType2}  order=${order}
    ${panAttachments}=    Create List  ${panAttachments}

    ${aadhaarAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid1}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption3}  fileType=${fileType3}  order=${order}
    ${aadhaarAttachments}=    Create List  ${aadhaarAttachments}


    ${kyc_list1}=           Create Dictionary  isCoApplicant=${bool[0]}  maritalStatus=${maritalStatus[1]}   employmentStatus=${employmentStatus[0]}  monthlyIncome=${monthlyIncome}  aadhaar=${aadhaar}  pan=${pan}  isAadhaarVerified=${bool[1]}  isPanVerified=${bool[1]}  nomineeType=${nomineeType[1]}  nomineeName=${nomineeName}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentPin=${permanentPin}  permanentCity=${permanentCity}  permanentState=${permanentState}  currentAddress1=${currentAddress1}  currentAddress2=${currentAddress2}  currentPin=${currentPin}  currentCity=${currentCity}  currentState=${currentState}     otherAttachments=${otherAttachmentsList}  panAttachments=${panAttachments}  aadhaarAttachments=${aadhaarAttachments}
    Log  ${kyc_list1}
    ${resp}=  Create Loan Application    ${pcid1}    ${fname}  ${lname}  ${phone}  ${countryCodes[0]}  ${email}    ${categoryid}  ${typeid}  ${Productid}  ${locId}  ${place}  ${invoiceAmount}  ${downpaymentAmount}  ${requestedAmount}  ${remarks}    ${LoanAction[0]}  ${pcid1}  ${jpgfile}  ${fileSize}  ${caption1}  ${fileType1}  ${order}  ${kyc_list1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Test Variable  ${loan_uuid7}  ${resp.json()['uid']}
    Set Test Variable  ${loan_id7}  ${resp.json()['id']}

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


    ${otherAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid1}  fileName=${jpgfile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType1}  order=${order}
    ${otherAttachmentsList}=    Create List  ${otherAttachments}

    ${panAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid1}  fileName=${pngfile}  fileSize=${fileSize}  caption=${caption2}  fileType=${fileType2}  order=${order}
    ${panAttachments}=    Create List  ${panAttachments}

    ${aadhaarAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid1}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption3}  fileType=${fileType3}  order=${order}
    ${aadhaarAttachments}=    Create List  ${aadhaarAttachments}

    ${kyc_list1}=    Create Dictionary    isCoApplicant=${bool[0]}    maritalStatus=${maritalStatus[1]}   employmentStatus=${employmentStatus[0]}    monthlyIncome=${monthlyIncome}  aadhaar=${aadhaar}   pan=${pan}  isAadhaarVerified=${bool[1]}  isPanVerified=${bool[1]}  nomineeType=${nomineeType[1]}   nomineeName=${nomineeName}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentPin=${permanentPin}  permanentCity=${permanentCity}  permanentState=${permanentState}   currentAddress1=${currentAddress1}  currentAddress2=${currentAddress2}  currentPin=${currentPin}  currentCity=${currentCity}  currentState=${currentState}     otherAttachments=${otherAttachmentsList}    panAttachments=${panAttachments}  aadhaarAttachments=${aadhaarAttachments}
    Log  ${kyc_list1}
    ${resp}=   Update Loan Application   ${loan_uuid7}    ${pcid1}       ${categoryid}   ${typeid}   ${empty}   ${Productid}   ${locId}   ${place}   ${invoiceAmount1}  ${downpaymentAmount}  ${requestedAmount}  ${remarks}       ${LoanAction[0]}  ${pcid1}  ${jpgfile}  ${fileSize}  ${caption1}  ${fileType1}  ${order}     ${kyc_list1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}   ${INVALID_STATUS_ID}

    
    ${resp}=  Get Loan Application With Filter
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()[0]['referenceNo']}      ${loanApplicationRefNo}
    Should Be Equal As Strings   ${resp.json()[0]['status']['id']}     ${status_id0}
    Should Be Equal As Strings   ${resp.json()[0]['id']}  ${loan_id7}
    Should Be Equal As Strings   ${resp.json()[0]['uid']}  ${loan_uuid7}
    Should Be Equal As Strings   ${resp.json()[0]['accountId']}  ${account_id}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['id']}  ${pcid1}
    Should Be Equal As Strings   ${resp.json()[0]['category']['id']}  ${categoryid}
    Should Be Equal As Strings   ${resp.json()[0]['type']['id']}  ${typeid}
 

JD-TC-UpdateLoanApplication-UH2
                                  
    [Documentation]      update Loan Application - where not gave currentAddress1 


    ${resp}=  Consumer Login  ${CUSERNAME11}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   ProviderLogin  ${PUSERNAME36}  ${PASSWORD} 
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
        Set Suite Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${place}  ${resp.json()[0]['place']}
    END

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME9}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME9}  firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${pcid1}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${pcid1}  ${resp.json()[0]['id']}
    END

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME9}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable    ${phone}   ${resp.json()[0]['phoneNo']}
    # Set Suite Variable    ${countryCodes[0]}   ${resp.json()[0]['countryCode']}
    Set Suite Variable    ${email}  ${fname}${C_Email}.ynwtest@netvarth.com

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

    
    ${otherAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid1}  fileName=${jpgfile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType1}  order=${order}
    ${otherAttachmentsList}=    Create List  ${otherAttachments}

    ${panAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid1}  fileName=${pngfile}  fileSize=${fileSize}  caption=${caption2}  fileType=${fileType2}  order=${order}
    ${panAttachments}=    Create List  ${panAttachments}

    ${aadhaarAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid1}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption3}  fileType=${fileType3}  order=${order}
    ${aadhaarAttachments}=    Create List  ${aadhaarAttachments}


    ${kyc_list1}=           Create Dictionary  isCoApplicant=${bool[0]}  maritalStatus=${maritalStatus[1]}   employmentStatus=${employmentStatus[0]}  monthlyIncome=${monthlyIncome}  aadhaar=${aadhaar}  pan=${pan}  isAadhaarVerified=${bool[1]}  isPanVerified=${bool[1]}  nomineeType=${nomineeType[1]}  nomineeName=${nomineeName}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentPin=${permanentPin}  permanentCity=${permanentCity}  permanentState=${permanentState}  currentAddress1=${currentAddress1}  currentAddress2=${currentAddress2}  currentPin=${currentPin}  currentCity=${currentCity}  currentState=${currentState}     otherAttachments=${otherAttachmentsList}  panAttachments=${panAttachments}  aadhaarAttachments=${aadhaarAttachments}
    Log  ${kyc_list1}
    ${resp}=  Create Loan Application    ${pcid1}    ${fname}  ${lname}  ${phone}  ${countryCodes[0]}  ${email}    ${categoryid}  ${typeid}  ${Productid}  ${locId}  ${place}  ${invoiceAmount}  ${downpaymentAmount}  ${requestedAmount}  ${remarks}    ${LoanAction[0]}  ${pcid1}  ${jpgfile}  ${fileSize}  ${caption1}  ${fileType1}  ${order}  ${kyc_list1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${loan_uuid9}  ${resp.json()['uid']}
    Set Suite Variable  ${loan_id9}  ${resp.json()['id']}

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


    ${otherAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid1}  fileName=${jpgfile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType1}  order=${order}
    ${otherAttachmentsList}=    Create List  ${otherAttachments}

    ${panAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid1}  fileName=${pngfile}  fileSize=${fileSize}  caption=${caption2}  fileType=${fileType2}  order=${order}
    ${panAttachments}=    Create List  ${panAttachments}

    ${aadhaarAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid1}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption3}  fileType=${fileType3}  order=${order}
    ${aadhaarAttachments}=    Create List  ${aadhaarAttachments}

    ${kyc_list1}=    Create Dictionary    isCoApplicant=${bool[0]}    maritalStatus=${maritalStatus[1]}   employmentStatus=${employmentStatus[0]}    monthlyIncome=${monthlyIncome}  aadhaar=${aadhaar}   pan=${pan}  isAadhaarVerified=${bool[1]}  isPanVerified=${bool[1]}  nomineeType=${nomineeType[1]}   nomineeName=${nomineeName}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentPin=${permanentPin}  permanentCity=${permanentCity}  permanentState=${permanentState}   currentAddress1=${currentAddress1}  currentAddress2=${currentAddress2}  currentPin=${currentPin}  currentCity=${currentCity}  currentState=${currentState}     otherAttachments=${otherAttachmentsList}    panAttachments=${panAttachments}  aadhaarAttachments=${aadhaarAttachments}
    Log  ${kyc_list1}
    ${resp}=   Update Loan Application   ${loan_uuid9}    ${pcid1}       ${categoryid}   ${typeid}   ${status_id0}   ${Productid}   ${locId}   ${place}   ${invoiceAmount1}  ${downpaymentAmount}  ${requestedAmount}  ${remarks}       ${LoanAction[0]}  ${pcid1}  ${jpgfile}  ${fileSize}  ${caption1}  ${fileType1}  ${order}     ${kyc_list1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    
    ${resp}=  Get Loan Application by loanApplicationRefNo   ${loan_uuid9}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['referenceNo']}      ${loanApplicationRefNo}
    Should Be Equal As Strings   ${resp.json()['status']['id']}     ${status_id0}
    Should Be Equal As Strings   ${resp.json()['id']}  ${loan_id9}
    Should Be Equal As Strings   ${resp.json()['uid']}  ${loan_uuid9}
    Should Be Equal As Strings   ${resp.json()['accountId']}  ${account_id}
    Should Be Equal As Strings   ${resp.json()['customer']['id']}  ${pcid1}
  

JD-TC-UpdateLoanApplication-UH3
                                  
    [Documentation]      update Loan Application - with consumer login
    

    ${resp}=  Consumer Login  ${CUSERNAME11}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}

      
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


    ${otherAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid1}  fileName=${jpgfile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType1}  order=${order}
    ${otherAttachmentsList}=    Create List  ${otherAttachments}

    ${panAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid1}  fileName=${pngfile}  fileSize=${fileSize}  caption=${caption2}  fileType=${fileType2}  order=${order}
    ${panAttachments}=    Create List  ${panAttachments}

    ${aadhaarAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid1}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption3}  fileType=${fileType3}  order=${order}
    ${aadhaarAttachments}=    Create List  ${aadhaarAttachments}

    ${kyc_list1}=    Create Dictionary    isCoApplicant=${bool[0]}    maritalStatus=${maritalStatus[1]}   employmentStatus=${employmentStatus[0]}    monthlyIncome=${monthlyIncome}  aadhaar=${aadhaar}   pan=${pan}  isAadhaarVerified=${bool[1]}  isPanVerified=${bool[1]}  nomineeType=${nomineeType[1]}   nomineeName=${nomineeName}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentPin=${permanentPin}  permanentCity=${permanentCity}  permanentState=${permanentState}   currentAddress1=${currentAddress1}  currentAddress2=${currentAddress2}  currentPin=${currentPin}  currentCity=${currentCity}  currentState=${currentState}     otherAttachments=${otherAttachmentsList}    panAttachments=${panAttachments}  aadhaarAttachments=${aadhaarAttachments}
    Log  ${kyc_list1}
    ${resp}=   Update Loan Application   ${loan_uuid9}    ${pcid1}       ${categoryid}   ${typeid}   ${status_id0}   ${Productid}   ${locId}   ${place}   ${invoiceAmount1}  ${downpaymentAmount}  ${requestedAmount}  ${remarks}       ${LoanAction[0]}  ${pcid1}  ${jpgfile}  ${fileSize}  ${caption1}  ${fileType1}  ${order}     ${kyc_list1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    401
    Should Be Equal As Strings   ${resp.json()}    ${LOGIN_NO_ACCESS_FOR_URL}

    


JD-TC-UpdateLoanApplication-UH4
                                  
    [Documentation]      update Loan Application - with anorher provider login
    
    ${resp}=   ProviderLogin  ${PUSERNAME38}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

         
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


    ${otherAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid1}  fileName=${jpgfile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType1}  order=${order}
    ${otherAttachmentsList}=    Create List  ${otherAttachments}

    ${panAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid1}  fileName=${pngfile}  fileSize=${fileSize}  caption=${caption2}  fileType=${fileType2}  order=${order}
    ${panAttachments}=    Create List  ${panAttachments}

    ${aadhaarAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid1}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption3}  fileType=${fileType3}  order=${order}
    ${aadhaarAttachments}=    Create List  ${aadhaarAttachments}

    ${kyc_list1}=    Create Dictionary    isCoApplicant=${bool[0]}    maritalStatus=${maritalStatus[1]}   employmentStatus=${employmentStatus[0]}    monthlyIncome=${monthlyIncome}  aadhaar=${aadhaar}   pan=${pan}  isAadhaarVerified=${bool[1]}  isPanVerified=${bool[1]}  nomineeType=${nomineeType[1]}   nomineeName=${nomineeName}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentPin=${permanentPin}  permanentCity=${permanentCity}  permanentState=${permanentState}   currentAddress1=${currentAddress1}  currentAddress2=${currentAddress2}  currentPin=${currentPin}  currentCity=${currentCity}  currentState=${currentState}     otherAttachments=${otherAttachmentsList}    panAttachments=${panAttachments}  aadhaarAttachments=${aadhaarAttachments}
    Log  ${kyc_list1}
    ${resp}=   Update Loan Application   ${loan_uuid9}    ${pcid1}       ${categoryid}   ${typeid}   ${status_id0}   ${Productid}   ${locId}   ${place}   ${invoiceAmount1}  ${downpaymentAmount}  ${requestedAmount}  ${remarks}       ${LoanAction[0]}  ${pcid1}  ${jpgfile}  ${fileSize}  ${caption1}  ${fileType1}  ${order}     ${kyc_list1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${NO_PERMISSION}
  
JD-TC-UpdateLoanApplication-UH5
                                  
    [Documentation]      without login


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


    ${otherAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid1}  fileName=${jpgfile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType1}  order=${order}
    ${otherAttachmentsList}=    Create List  ${otherAttachments}

    ${panAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid1}  fileName=${pngfile}  fileSize=${fileSize}  caption=${caption2}  fileType=${fileType2}  order=${order}
    ${panAttachments}=    Create List  ${panAttachments}

    ${aadhaarAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid1}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption3}  fileType=${fileType3}  order=${order}
    ${aadhaarAttachments}=    Create List  ${aadhaarAttachments}

    ${kyc_list1}=    Create Dictionary    isCoApplicant=${bool[0]}    maritalStatus=${maritalStatus[1]}   employmentStatus=${employmentStatus[0]}    monthlyIncome=${monthlyIncome}  aadhaar=${aadhaar}   pan=${pan}  isAadhaarVerified=${bool[1]}  isPanVerified=${bool[1]}  nomineeType=${nomineeType[1]}   nomineeName=${nomineeName}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentPin=${permanentPin}  permanentCity=${permanentCity}  permanentState=${permanentState}   currentAddress1=${currentAddress1}  currentAddress2=${currentAddress2}  currentPin=${currentPin}  currentCity=${currentCity}  currentState=${currentState}     otherAttachments=${otherAttachmentsList}    panAttachments=${panAttachments}  aadhaarAttachments=${aadhaarAttachments}
    Log  ${kyc_list1}
    ${resp}=   Update Loan Application   ${loan_uuid9}    ${pcid1}        ${categoryid}   ${typeid}   ${status_id0}   ${Productid}   ${locId}   ${place}   ${invoiceAmount1}  ${downpaymentAmount}  ${requestedAmount}  ${remarks}       ${LoanAction[0]}  ${pcid1}  ${jpgfile}  ${fileSize}  ${caption1}  ${fileType1}  ${order}     ${kyc_list1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.json()}   ${SESSION_EXPIRED}
    
JD-TC-UpdateLoanApplication-UH6
                                  
    [Documentation]      update Loan Application - invalid  loan uuid
    

    ${resp}=   ProviderLogin  ${PUSERNAME36}  ${PASSWORD} 
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
        Set Suite Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${place}  ${resp.json()[0]['place']}
    END

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME7}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME7}  firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${pcid1}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${pcid1}  ${resp.json()[0]['id']}
    END

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME7}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable    ${phone}   ${resp.json()[0]['phoneNo']}
    # Set Test Variable    ${countryCodes[0]}   ${resp.json()[0]['countryCode']}
    Set Test Variable    ${email}  ${fname}${C_Email}.ynwtest@netvarth.com

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

    
    ${otherAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid1}  fileName=${jpgfile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType1}  order=${order}
    ${otherAttachmentsList}=    Create List  ${otherAttachments}

    ${panAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid1}  fileName=${pngfile}  fileSize=${fileSize}  caption=${caption2}  fileType=${fileType2}  order=${order}
    ${panAttachments}=    Create List  ${panAttachments}

    ${aadhaarAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid1}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption3}  fileType=${fileType3}  order=${order}
    ${aadhaarAttachments}=    Create List  ${aadhaarAttachments}


    ${kyc_list1}=           Create Dictionary  isCoApplicant=${bool[0]}  maritalStatus=${maritalStatus[1]}   employmentStatus=${employmentStatus[0]}  monthlyIncome=${monthlyIncome}  aadhaar=${aadhaar}  pan=${pan}  isAadhaarVerified=${bool[1]}  isPanVerified=${bool[1]}  nomineeType=${nomineeType[1]}  nomineeName=${nomineeName}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentPin=${permanentPin}  permanentCity=${permanentCity}  permanentState=${permanentState}  currentAddress1=${currentAddress1}  currentAddress2=${currentAddress2}  currentPin=${currentPin}  currentCity=${currentCity}  currentState=${currentState}     otherAttachments=${otherAttachmentsList}  panAttachments=${panAttachments}  aadhaarAttachments=${aadhaarAttachments}
    Log  ${kyc_list1}
    ${resp}=  Create Loan Application    ${pcid1}    ${fname}  ${lname}  ${phone}  ${countryCodes[0]}  ${email}    ${categoryid}  ${typeid}  ${Productid}  ${locId}  ${place}  ${invoiceAmount}  ${downpaymentAmount}  ${requestedAmount}  ${remarks}    ${LoanAction[0]}  ${pcid1}  ${jpgfile}  ${fileSize}  ${caption1}  ${fileType1}  ${order}  ${kyc_list1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${loan_uuid9}  ${resp.json()['uid']}
    Set Suite Variable  ${loan_id9}  ${resp.json()['id']}

    ${resp}=  Get Loan Application With Filter
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Test Variable  ${loanApplicationRefNo}  ${resp.json()[0]['referenceNo']}
    Should Be Equal As Strings   ${resp.json()[0]['status']['id']}     ${status_id0}
    
    ${INVALID_LEAD_ID}=   Replace String  ${INVALID_LEAD_ID}  {}  Lead
    
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


    ${otherAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid1}  fileName=${jpgfile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType1}  order=${order}
    ${otherAttachmentsList}=    Create List  ${otherAttachments}

    ${panAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid1}  fileName=${pngfile}  fileSize=${fileSize}  caption=${caption2}  fileType=${fileType2}  order=${order}
    ${panAttachments}=    Create List  ${panAttachments}

    ${aadhaarAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid1}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption3}  fileType=${fileType3}  order=${order}
    ${aadhaarAttachments}=    Create List  ${aadhaarAttachments}

    ${kyc_list1}=    Create Dictionary    isCoApplicant=${bool[0]}    maritalStatus=${maritalStatus[1]}   employmentStatus=${employmentStatus[0]}    monthlyIncome=${monthlyIncome}  aadhaar=${aadhaar}   pan=${pan}  isAadhaarVerified=${bool[1]}  isPanVerified=${bool[1]}  nomineeType=${nomineeType[1]}   nomineeName=${nomineeName}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentPin=${permanentPin}  permanentCity=${permanentCity}  permanentState=${permanentState}   currentAddress1=${currentAddress1}  currentAddress2=${currentAddress2}  currentPin=${currentPin}  currentCity=${currentCity}  currentState=${currentState}     otherAttachments=${otherAttachmentsList}    panAttachments=${panAttachments}  aadhaarAttachments=${aadhaarAttachments}
    Log  ${kyc_list1}
    ${resp}=   Update Loan Application   78866    ${pcid1}       ${categoryid}   ${typeid}   ${status_id0}   ${Productid}   ${locId}   ${place}   ${invoiceAmount1}  ${downpaymentAmount}  ${requestedAmount}  ${remarks}       ${LoanAction[0]}  ${pcid1}  ${jpgfile}  ${fileSize}  ${caption1}  ${fileType1}  ${order}     ${kyc_list1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${INVALID_LOAN_APPLICATION_ID}
  

   