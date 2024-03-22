*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        LOAN
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Library           /ebs/TDD/excelfuncs.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderPartnerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/musers.py
Variables         /ebs/TDD/varfiles/hl_musers.py

*** Variables ***

@{emptylist}

${jpgfile}      /ebs/TDD/uploadimage.jpg
${pngfile}      /ebs/TDD/upload.png
${pdffile}      /ebs/TDD/sample.pdf
${shfile}     /ebs/TDD/example.sh


${order}    0
${fileSize}  0.00458

${cc}   +91
${phone}     5555512345
${aadhaar}   555555555555
${pan}       5555523145
${bankAccountNo}    5555534564
${bankIfsc}         5555566
${bankPin}       5555533

${bankAccountNo2}    5555534587
${bankIfsc2}         55555688
${bankPin2}       5555589

${invoiceAmount}    100000
${downpaymentAmount}    20000
${requestedAmount}    80000

${autoApprovalUptoAmount}    50000
${autoApprovalUptoAmount2}    70000

*** Test Cases ***

JD-TC-AddLoanBankDetails-1
                                  
    [Documentation]               Create Loan Application and add loan bank details.

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME0}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${provider_id1}  ${resp.json()['id']}
    Set Test Variable   ${lic_id}   ${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}
    Set Test Variable   ${name}   ${resp.json()['firstName']}

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

    END

    ${resp}=    Create and Update Account level cdl setting    ${bool[1]}    ${autoApprovalUptoAmount2}    ${bool[1]}    ${toggle[0]}    ${bool[1]}    ${empty}   ${bool[1]}    ${bool[1]}  demandPromissoryNoteRequired=${bool[1]}    securityPostDatedChequesRequired=${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Departments
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${dep_name1}=  FakerLibrary.bs
        ${dep_code1}=   Random Int  min=100   max=999
        ${dep_desc1}=   FakerLibrary.word  
        ${resp1}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${dep_id}  ${resp1.json()}
    ELSE
        Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    END


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
        Set Suite Variable  ${place}  ${resp.json()[0]['place']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END

    ${gender}=  Random Element    ${Genderlist}
    ${dob}=  FakerLibrary.Date Of Birth   minimum_age=23   maximum_age=55
    ${dob}=  Convert To String  ${dob}
    ${fname}=    FakerLibrary.firstName
    ${lname}=    FakerLibrary.lastName
    Set Suite Variable  ${email2}  ${lname}${C_Email}.${test_mail}

    ${resp}=  GetCustomer  phoneNo-eq=${phone} 
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer with email   ${fname}  ${lname}  ${EMPTY}  ${email2}  ${gender}  ${dob}  ${phone}  ${EMPTY}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid14}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid14}  ${resp.json()[0]['id']}
    END
    ${resp}=  GetCustomer  phoneNo-eq=${phone}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable   ${custid}    ${resp.json()[0]['id']}
    Set Suite Variable   ${firstName}    ${resp.json()[0]['firstName']}
    Set Suite Variable   ${lastName}    ${resp.json()[0]['lastName']}

    # .... Create Branch1....

    ${branchCode}=    FakerLibrary.Random Number
    ${branchName}=    FakerLibrary.name
    Set Suite Variable  ${branchName}

    ${pin}  ${city}  ${district}  ${state}=  get_pin_loc

    ${state}=    Evaluate     "${state}".title()
    ${state}=    String.RemoveString  ${state}    ${SPACE}

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  ${resp.json()['enableBranchMaster']}==${bool[0]}
        ${resp1}=  Enable Disable Branch    ${status[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END
   
    ${resp}=    Create BranchMaster    ${branchCode}    ${branchName}    ${locId}    ${status[0]}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${branchid1}  ${resp.json()['id']}

    ${resp}=    Change Branch Status    ${branchid1}    ${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${userids}=  Create List     ${provider_id1}

    ${branch1}=  Create Dictionary   id=${branchid1}    isDefault=${bool[1]}

    ${resp}=  Assigning Branches to Users     ${userids}     ${branch1}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  partnercategorytype   ${account_id}
    ${resp}=  partnertype           ${account_id}
    ${resp}=  categorytype          ${account_id}
    ${resp}=  tasktype              ${account_id}
    ${resp}=  loanStatus            ${account_id}
    ${resp}=  loanProducttype       ${account_id}
    ${resp}=  LoanProductCategory   ${account_id}
    ${resp}=  loanProducts          ${account_id}
    ${resp}=  loanScheme            ${account_id}

#     ${PH_Number}    Random Number 	digits=5 
#     ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
#     Log  ${PH_Number}
#     Set Suite Variable  ${P_phone}  555${PH_Number}

#     ${resp}=  Generate Phone Partner Creation    ${P_phone}    ${countryCodes[0]}
#     Log  ${resp.content}
#     Should Be Equal As Strings     ${resp.status_code}    200 

#     ${branch}=      Create Dictionary   id=${branchid1}

#     ${resp}=  Verify Phone Partner Creation    ${P_phone}    ${OtpPurpose['ProviderVerifyPhone']}    ${firstName}   ${lastName}    branch=${branch}
#     Log  ${resp.content}
#     Should Be Equal As Strings     ${resp.status_code}    200
#     Set Suite Variable  ${Pid1}  ${resp.json()['id']}
#     Set Suite Variable  ${Puid1}  ${resp.json()['uid']} 

#     ${resp}=    Get Partner-With Filter
#     Log  ${resp.content}
#     Should Be Equal As Strings     ${resp.status_code}    200 

#     ${resp}=   Partner Approval Request    ${Puid1}
#     Log  ${resp.content}
#     Should Be Equal As Strings     ${resp.status_code}    200 

#     ${note}=    FakerLibrary.sentence
#     Set Suite Variable    ${note}

#     ${resp}=   Partner Approved    ${Puid1}    ${note}
#     Log  ${resp.content}
#     Should Be Equal As Strings     ${resp.status_code}    200 

# # ...... Update sales officer and credit officer for dealer1 & activate dealer1 by branch operation head....

#     ${Salesofficer}=    Create Dictionary    id=${so_id1}  isDefault=${bool[1]}

#     ${resp}=    Update Sales Officer    ${Puid1}    ${Salesofficer}
#     Log  ${resp.content}
#     Should Be Equal As Strings     ${resp.status_code}    200

#     ${Creditofficer}=    Create Dictionary    id=${bch_id1}    isDefault=${bool[1]}

#     ${resp}=    Update Credit Officer    ${Puid1}      ${Creditofficer}
#     Log  ${resp.content}
#     Should Be Equal As Strings     ${resp.status_code}    200

#     ${resp}=    Activate Partner    ${Puid1}     ${bool[1]}
#     Log  ${resp.content}
#     Should Be Equal As Strings     ${resp.status_code}    200

#     ${resp}=    Get Loan Application Category
#     Log  ${resp.content}
#     Should Be Equal As Strings     ${resp.status_code}    200
#     Set Suite Variable  ${categoryid}  ${resp.json()[0]['id']}
#     Set Suite Variable  ${categoryname}  ${resp.json()[0]['name']}

#     ${resp}=    Get Loan Application Type
#     Log  ${resp.content}
#     Should Be Equal As Strings     ${resp.status_code}    200
#     Set Suite Variable  ${typeid}  ${resp.json()[0]['id']}
#     Set Suite Variable  ${typename}  ${resp.json()[0]['name']}

#     ${resp}=  Get Loan Application Status  
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${len}  Get Length  ${resp.json()}
#     FOR   ${i}  IN RANGE   ${len}
#         Set Suite Variable  ${status_id${i}}    ${resp.json()[${i}]['id']}
#         Set Suite Variable  ${status_name${i}}  ${resp.json()[${i}]['name']}
#     END

#     ${resp}=    Get Loan Application Product
#     Log  ${resp.content}
#     Should Be Equal As Strings     ${resp.status_code}    200
#     Set Suite Variable  ${Productid}  ${resp.json()[0]['id']}
#     Set Suite Variable  ${productname}  ${resp.json()[0]['productName']}
#     Set Suite Variable  ${Productid1}  ${resp.json()[1]['id']}
#     Set Suite Variable  ${productname1}  ${resp.json()[1]['productName']}

#     ${resp}=    Get Loan Application Scheme
#     Log  ${resp.content}
#     Should Be Equal As Strings     ${resp.status_code}    200
#     Set Suite Variable  ${Schemeid}  ${resp.json()[0]['id']}
#     Set Suite Variable  ${Schemename}  ${resp.json()[0]['schemeName']} 
#     Set Suite Variable  ${Schemeid1}  ${resp.json()[1]['id']}
#     Set Suite Variable  ${Schemename1}  ${resp.json()[1]['schemeName']} 
#     Set Suite Variable  ${Schemeid2}  ${resp.json()[2]['id']}
#     Set Suite Variable  ${Schemename2}  ${resp.json()[2]['schemeName']}

    ${resp}=    Generate Loan Application Otp for Phone Number    ${phone}  ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${kyc_list1}=   Create Dictionary  isCoApplicant=${bool[0]}

    ${resp}=  db.getType   ${pdffile} 
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${pdffile} 
    Set Suite Variable    ${fileType}
    ${caption}=  Fakerlibrary.Sentence

    ${resp}    upload file to temporary location    ${file_action[0]}    ${provider_id1}    ${ownerType[0]}    ${name}    ${pdffile}    ${fileSize}    ${caption}    ${fileType}    ${EMPTY}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Set Test Variable    ${driveId}    ${resp.json()[0]['driveId']}

    ${resp}    change status of the uploaded file    ${QnrStatus[1]}    ${driveId}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${CustomerPhoto}=    Create Dictionary   action=${LoanAction[0]}  owner=${provider_id1}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}    driveId=${driveId}
    Log  ${CustomerPhoto}
    Set Suite Variable    ${CustomerPhoto}
    # ${resp}=  Verify Phone Otp and Create Loan Application   ${phone}   ${OtpPurpose['ConsumerVerifyPhone']}   ${custid}    ${firstName}    ${lastName}    ${phone}    ${countryCodes[0]}    ${locId}    ${kyc_list1}
    ${resp}=    Verify Phone and Create Loan Application with customer details  ${phone}  ${OtpPurpose['ConsumerVerifyPhone']}  ${custid}  ${locId}    ${CustomerPhoto}  ${kyc_list1}  firstName=${firstName}  lastName=${lastName}  phoneNo=${phone}  countryCode=${countryCodes[0]}  gender=${gender}  dob=${dob}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${loanid}    ${resp.json()['id']}
    Set Suite Variable  ${loanuid}    ${resp.json()['uid']}

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Test Variable  ${kycid}    ${resp.json()["loanApplicationKycList"][0]["id"]} 
    Set Suite Variable  ${ref_no}  ${resp.json()['referenceNo']}
    
#  <----------------------------- KYC Details ------------------------------------------>
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
    
    ${aadhaarAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${custid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${aadhaarAttachments}

    ${resp}=   Requst For Aadhar Validation    ${kycid}    ${loanuid}    ${phone}    ${aadhaar}    ${aadhaarAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get loan Bank Details Aadhaar    ${kycid}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${panAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${custid}  fileName=${jpgfile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType1}  order=${order}
    Log  ${panAttachments}

    ${resp}=    Requst For Pan Validation    ${kycid}    ${loanuid}    ${phone}    ${pan}    ${panAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${aadhaarAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${custid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${aadhaarAttachments}

    ${panAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${custid}  fileName=${jpgfile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType1}  order=${order}
    Log  ${panAttachments}

    ${panAttachments}=  Create List    ${panAttachments}
    ${permanentAddress1}=    FakerLibrary.Address
    ${permanentCity}=    FakerLibrary.City
    # ${permanentPin}=    FakerLibrary.Postcode
    ${permanentState}=    FakerLibrary.State
    ${currentAddress1}=    FakerLibrary.Street Address
    ${currentCity}=    FakerLibrary.City
    # ${currentPin}=    FakerLibrary.Postcode
    ${currentState}=    FakerLibrary.State


    ${resp}=    Update loan Application Kyc Details    ${loanid}     ${loanuid}   ${phone}       ${aadhaar}   ${pan}    ${aadhaarAttachments}    panAttachments=${panAttachments}    
    ...  permanentAddress1=${permanentAddress1}    permanentCity=${permanentCity}    permanentPin=${pin}    permanentState=${permanentState}
    ...  currentAddress1=${currentAddress1}    currentCity=${currentCity}    currentPin=${pin}    currentState=${currentState}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

# # <----------------------------- Loan Details ------------------------------------------>

#     ${emiPaidAmountMonthly}    FakerLibrary.Random Number

#     ${nomineeName}        FakerLibrary.name

#     ${LoanApplicationKycList}=    Create Dictionary   id=${kycid}  employmentStatus=${employmentStatus[0]}  monthlyIncome=${montlyIncome}  nomineeType=${nomineeType[1]}  nomineeName=${nomineeName}    nomineeDob=20-10-1999   nomineePhone=5555555555
#     ...  customerEducation=1    customerEmployement=1    salaryRouting=1    familyDependants=1    noOfYearsAtPresentAddress=1    currentResidenceOwnershipStatus=1    ownedMovableAssets=1  vehicleNo=KER369   goodsFinanced=1   earningMembers=1   existingCustomer=1
#     Log  ${LoanApplicationKycList}

#     ${category}=       Create Dictionary    id=${categoryid}  name=${categoryname}
#     ${type}=           Create Dictionary    id=${typeid}  name=${typename}
#     ${loanProducts}=    Create Dictionary    id=${Productid}  categoryId=${categoryid}    typeId=${typeid}
#     ${loanProducts}=    Create List    ${loanProducts}
#     ${loanScheme}=     Create Dictionary    id=${Schemeid1}  name=${Schemename1}

#     ${partner}=  Create Dictionary  id=${Pid1}
#     Set Suite Variable    ${partner}

#     ${resp}=    Verify loan Bank Details    ${loanid}  ${loanProducts}  ${category}   ${type}    ${loanScheme}    ${invoiceAmount}    ${downpaymentAmount}    ${requestedAmount}    ${montlyIncome}    ${emiPaidAmountMonthly}    ${LoanApplicationKycList}        uid=${loanuid}   partner=${partner}
#     Log  ${resp.content}
#     Should Be Equal As Strings     ${resp.status_code}    200


# <----------------------------- Bank Details ------------------------------------------>

    ${bankName}       FakerLibrary.name
    ${bankAddress1}   FakerLibrary.Street name
    ${bankAddress2}   FakerLibrary.Street name
    ${bankCity}       FakerLibrary.word
    ${bankState}      FakerLibrary.state

    ${bankStatementAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${custid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${bankStatementAttachments}

    ${resp}=    Add loan Bank Details    4    ${loanuid}    ${loanuid}    ${bankName}    ${bankAccountNo}    ${bankIfsc}    ${bankAddress1}    ${bankAddress2}    ${bankCity}    ${bankState}   ${bankPin}    ${bankStatementAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

JD-TC-AddLoanBankDetails-2
                                  
    [Documentation]               Create Loan Application and add loan bank Details without Requst For Aadhar Validation and pan.

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME0}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${PH_Number}    Random Number 	digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Test Variable  ${consumernumber}  555${PH_Number}
    ${gender}    Random Element    ${Genderlist}
    ${firstName}=  FakerLibrary.name
    ${lastName}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date Of Birth   minimum_age=23   maximum_age=55
    ${dob}=  Convert To String  ${dob}
    ${resp}=  GetCustomer  phoneNo-eq=${consumernumber}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        Set Test Variable  ${custid}   0
    ELSE
        Set Suite Variable  ${custid}      ${resp.json()[0]['id']}
        Set Suite Variable  ${Custfname}  ${resp.json()[0]['firstname']}
        Set Suite Variable  ${Custlname}  ${resp.json()[0]['lastname']}
    END


    ${resp}=    Generate Loan Application Otp for Phone Number    ${consumernumber}  ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${kyc_list1}=           Create Dictionary  isCoApplicant=${bool[0]}
    
    # ${resp}=    Verify Phone Otp and Create Loan Application   ${consumernumber}   ${OtpPurpose['ConsumerVerifyPhone']}   ${custid}    ${firstName}    ${lastName}    ${consumernumber}    ${countryCodes[0]}    ${locId}    ${kyc_list1}
    ${resp}=    Verify Phone and Create Loan Application with customer details  ${consumernumber}  ${OtpPurpose['ConsumerVerifyPhone']}  ${custid}  ${locId}    ${CustomerPhoto}  ${kyc_list1}  firstName=${firstName}  lastName=${lastName}  phoneNo=${consumernumber}  countryCode=${countryCodes[0]}  gender=${gender}  dob=${dob}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${loanid1}    ${resp.json()['id']}
    Set Suite Variable  ${loanuid1}    ${resp.json()['uid']}

    ${resp}=    Get Loan Application By uid  ${loanuid1} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${kycid}     ${resp.json()["loanApplicationKycList"][0]["id"]}

    ${bankName}       FakerLibrary.name
    ${bankAddress1}   FakerLibrary.Street name
    ${bankAddress2}   FakerLibrary.Street name
    ${bankCity}       FakerLibrary.word
    ${bankState}      FakerLibrary.state

    ${bankStatementAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${custid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${bankStatementAttachments}

    ${resp}=    Add loan Bank Details    4    ${loanuid1}    ${loanuid1}    ${bankName}    ${bankAccountNo}    ${bankIfsc}    ${bankAddress1}    ${bankAddress2}    ${bankCity}    ${bankState}   ${bankPin}    ${bankStatementAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get Loan Application By uid  ${loanuid1} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

JD-TC-AddLoanBankDetails-3
                                  
    [Documentation]               Create Loan Application and add loan bank Details invalid orginfrom.

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME0}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${PH_Number}    Random Number 	digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${consumernumber}  555${PH_Number}
    ${gender}    Random Element    ${Genderlist}
    ${firstName}=  FakerLibrary.name
    ${lastName}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date Of Birth   minimum_age=23   maximum_age=55
    ${dob}=  Convert To String  ${dob}

    ${resp}=  GetCustomer  phoneNo-eq=${consumernumber}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        Set Test Variable  ${custid}   0
    ELSE
        Set Suite Variable  ${custid}      ${resp.json()[0]['id']}
        Set Suite Variable  ${Custfname}  ${resp.json()[0]['firstname']}
        Set Suite Variable  ${Custlname}  ${resp.json()[0]['lastname']}
    END

    ${resp}=    Generate Loan Application Otp for Phone Number    ${consumernumber}  ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${kyc_list1}=           Create Dictionary  isCoApplicant=${bool[0]}
    
    # ${resp}=    Verify Phone Otp and Create Loan Application   ${consumernumber}   ${OtpPurpose['ConsumerVerifyPhone']}   ${custid}    ${firstName}    ${lastName}    ${consumernumber}    ${countryCodes[0]}    ${locId}    ${kyc_list1}
    ${resp}=    Verify Phone and Create Loan Application with customer details  ${consumernumber}  ${OtpPurpose['ConsumerVerifyPhone']}  ${custid}  ${locId}    ${CustomerPhoto}  ${kyc_list1}  firstName=${firstName}  lastName=${lastName}  phoneNo=${consumernumber}  countryCode=${countryCodes[0]}  gender=${gender}  dob=${dob}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${loanid2}    ${resp.json()['id']}
    Set Suite Variable  ${loanuid2}    ${resp.json()['uid']}

    ${resp}=    Get Loan Application By uid  ${loanuid2} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${kycid}     ${resp.json()["loanApplicationKycList"][0]["id"]}

    ${bankName}       FakerLibrary.name
    ${bankAddress1}   FakerLibrary.Street name
    ${bankAddress2}   FakerLibrary.Street name
    ${bankCity}       FakerLibrary.word
    ${bankState}      FakerLibrary.state

    ${bankStatementAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${custid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${bankStatementAttachments}

    ${resp}=    Add loan Bank Details    ${bankCity}    ${loanuid2}    ${loanuid2}    ${bankName}    ${bankAccountNo}    ${bankIfsc}    ${bankAddress1}    ${bankAddress2}    ${bankCity}    ${bankState}   ${bankPin}    ${bankStatementAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    500
    Should Be Equal As Strings    ${resp.json()}   ${JALDEE_OUT_OF_REACH_PROBLEM}

    ${resp}=    Get Loan Application By uid  ${loanuid2} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

JD-TC-AddLoanBankDetails-4
                                  
    [Documentation]               Create Loan Application and add loan bank Details with another provider loan id.

    ${resp}=  Consumer Login  ${CUSERNAME35}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME84}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

    ${fname}=  FakerLibrary.name
    ${lname}=  FakerLibrary.last_name
    Set Suite Variable  ${email2}  ${lname}${C_Email}.${test_mail}
    ${gender}=  Random Element    ${Genderlist}
    ${dob}=  FakerLibrary.Date Of Birth   minimum_age=23   maximum_age=55
    ${dob}=  Convert To String  ${dob}

    ${resp}=  GetCustomer  phoneNo-eq=${phone} 
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer with email   ${fname}  ${lname}  ${EMPTY}  ${email2}  ${gender}  ${dob}  ${phone}  ${EMPTY}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${pcid14}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${pcid14}  ${resp.json()[0]['id']}
    END
    ${resp}=  GetCustomer  phoneNo-eq=${phone}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=  db.getType   ${pdffile} 
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${pdffile} 
    Set Suite Variable    ${fileType}
    ${caption}=  Fakerlibrary.Sentence

    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType1}
    ${caption1}=  Fakerlibrary.Sentence

    ${bankName}    FakerLibrary.name
    ${bankAddress1}   FakerLibrary.Street name
    ${bankAddress2}   FakerLibrary.Street name
    ${bankCity}       FakerLibrary.word
    ${bankState}      FakerLibrary.state

    ${bankStatementAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${bankStatementAttachments}

    ${resp}=    Add loan Bank Details   4    ${loanuid1}    ${loanuid1}    ${bankName}    ${bankAccountNo}    ${bankIfsc}    ${bankAddress1}    ${bankAddress2}    ${bankCity}    ${bankState}   ${bankPin}    ${bankStatementAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings     ${resp.json()}    ${NO_PERMISSION}


JD-TC-AddLoanBankDetails-UH1
                                  
    [Documentation]  Create Loan Application and add loan bank Details invalid originUid.

    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME81}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}

    ${resp}=  partnercategorytype   ${account_id}
    ${resp}=  partnertype           ${account_id}
    ${resp}=  categorytype          ${account_id}
    ${resp}=  tasktype              ${account_id}
    ${resp}=  loanStatus            ${account_id}
    ${resp}=  loanProducttype       ${account_id}
    ${resp}=  LoanProductCategory   ${account_id}
    ${resp}=  loanProducts          ${account_id}
    ${resp}=  loanScheme            ${account_id}

    ${resp}=    Create and Update Account level cdl setting    ${bool[1]}    ${autoApprovalUptoAmount2}    ${bool[1]}    ${toggle[0]}    ${bool[1]}    ${empty}   ${bool[1]}    ${bool[1]}  demandPromissoryNoteRequired=${bool[1]}    securityPostDatedChequesRequired=${bool[1]}    loanNature=ConsumerDurableLoan
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get account level cdl setting
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

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

    ${PH_Number}    Random Number 	digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${phone}  555${PH_Number}

    ${resp}=  GetCustomer  phoneNo-eq=${phone}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        Set Suite Variable  ${custid}   0
        ${gender}    Random Element    ${Genderlist}
        ${firstName}=  FakerLibrary.name
        ${lastName}=  FakerLibrary.last_name
        ${dob}=  FakerLibrary.Date Of Birth   minimum_age=23   maximum_age=55
        ${dob}=  Convert To String  ${dob}
        ${custDetails}=  Create Dictionary  firstName=${firstName}  lastName=${lastName}  phoneNo=${phone}  countryCode=${countryCodes[0]}  gender=${gender}  dob=${dob}
    ELSE
        Set Suite Variable  ${custid}  ${resp.json()[0]['id']}
        ${custDetails}=  Create Dictionary
    END

    ${resp}=    Generate Loan Application Otp for Phone Number    ${phone}  ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${kyc_list1}=  Create Dictionary  isCoApplicant=${bool[0]}

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
    Set Suite Variable    ${CustomerPhoto}

    # ${gender}    Random Element    ${Genderlist}
    # # ${firstName}=  FakerLibrary.name
    # # ${lastName}=  FakerLibrary.last_name
    # ${dob}=  FakerLibrary.Date Of Birth   minimum_age=23   maximum_age=55
    # ${dob}=  Convert To String  ${dob}
    
    # ${resp}=    Verify Phone Otp and Create Loan Application   ${phone}   13   ${custid}    ${firstName}    ${lastName}    ${phoneNo}   ${countryCodes[0]}    ${locId}    ${kyc_list1}
    ${resp}=    Verify Phone and Create Loan Application with customer details  ${phone}  ${OtpPurpose['ConsumerVerifyPhone']}  ${custid}  ${locId}    ${CustomerPhoto}  ${kyc_list1}  &{custDetails}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${loanid3}    ${resp.json()['id']}
    Set Suite Variable  ${loanuid3}    ${resp.json()['uid']}

    ${resp}=    Get Loan Application By uid  ${loanuid3} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=  db.getType   ${pdffile} 
    Log  ${resp}
    ${fileType}=  Get From Dictionary   ${resp}    ${pdffile} 
    Set Suite Variable    ${fileType}
    ${caption}=  Fakerlibrary.Sentence

    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary   ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType1}
    ${caption1}=  Fakerlibrary.Sentence

    ${bankName}    FakerLibrary.name
    ${bankAddress1}   FakerLibrary.Street name
    ${bankAddress2}   FakerLibrary.Street name
    ${bankCity}       FakerLibrary.word
    ${bankState}      FakerLibrary.state

    ${bankStatementAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${bankStatementAttachments}

    ${INVALID_ORGIN_UID_Msg}=  Format String   ${INVALID_ORIGIN_UID}    ${bankName}

    ${resp}=    Add loan Bank Details    4    ${bankName}    ${loanuid3}    ${bankName}    ${bankAccountNo}    ${bankIfsc}    ${bankAddress1}    ${bankAddress2}    ${bankCity}    ${bankState}   ${bankPin}    ${bankStatementAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}   422 
    Should Be Equal As Strings  ${resp.json()}   ${INVALID_ORGIN_UID_Msg}


JD-TC-AddLoanBankDetails-5
                                  
    [Documentation]               Create Loan Application and add loan bank Details invalid loanApplicationUid.

    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME81}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

    ${PH_Number}    Random Number 	digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${phone}  555${PH_Number}

    ${resp}=  GetCustomer  phoneNo-eq=${phone}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        Set Suite Variable  ${custid}   0
        ${gender}    Random Element    ${Genderlist}
        ${firstName}=  FakerLibrary.name
        ${lastName}=  FakerLibrary.last_name
        ${dob}=  FakerLibrary.Date Of Birth   minimum_age=23   maximum_age=55
        ${dob}=  Convert To String  ${dob}
        ${custDetails}=  Create Dictionary  firstName=${firstName}  lastName=${lastName}  phoneNo=${phone}  countryCode=${countryCodes[0]}  gender=${gender}  dob=${dob}
    ELSE
        Set Suite Variable  ${custid}  ${resp.json()[0]['id']}
        ${custDetails}=  Create Dictionary
    END

    ${resp}=    Generate Loan Application Otp for Phone Number    ${phone}  ${cc}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${kyc_list1}=           Create Dictionary  isCoApplicant=${bool[0]}
    ${gender}    Random Element    ${Genderlist}
    # ${firstName}=  FakerLibrary.name
    # ${lastName}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date Of Birth   minimum_age=23   maximum_age=55
    ${dob}=  Convert To String  ${dob}
    
    # ${resp}=    Verify Phone Otp and Create Loan Application   ${phone}   13   ${custid}    ${firstName}    ${lastName}    ${phoneNo}    ${cc}    ${locId}    ${kyc_list1}
    ${resp}=    Verify Phone and Create Loan Application with customer details  ${phone}  ${OtpPurpose['ConsumerVerifyPhone']}  ${custid}  ${locId}    ${CustomerPhoto}  ${kyc_list1}  firstName=${firstName}  lastName=${lastName}  phoneNo=${phone}  countryCode=${countryCodes[0]}  gender=${gender}  dob=${dob}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Test Variable  ${loanid3}    ${resp.json()['id']}
    Set Test Variable  ${loanuid1}    ${resp.json()['uid']}

    ${resp}=    Get Loan Application By uid  ${loanuid1} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=  db.getType   ${pdffile} 
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${pdffile} 
    Set Suite Variable    ${fileType}
    ${caption}=  Fakerlibrary.Sentence

    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType1}
    ${caption1}=  Fakerlibrary.Sentence

    ${bankName}    FakerLibrary.name
    ${bankAddress1}   FakerLibrary.Street name
    ${bankAddress2}   FakerLibrary.Street name
    ${bankCity}       FakerLibrary.word
    ${bankState}      FakerLibrary.state

    ${bankStatementAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${bankStatementAttachments}

    ${resp}=    Add loan Bank Details    4    ${loanuid3}    ${bankCity}    ${bankName}    ${bankAccountNo}    ${bankIfsc}    ${bankAddress1}    ${bankAddress2}    ${bankCity}    ${bankState}   ${bankPin}    ${bankStatementAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}   200


JD-TC-AddLoanBankDetails-6
                                  
    [Documentation]               Create Loan Application and add loan bank Details EMPTY loanApplicationUid.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME81}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

    ${resp}=  db.getType   ${pdffile} 
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${pdffile} 
    Set Suite Variable    ${fileType}
    ${caption}=  Fakerlibrary.Sentence

    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType1}
    ${caption1}=  Fakerlibrary.Sentence

    ${bankName}    FakerLibrary.name
    ${bankAddress1}   FakerLibrary.Street name
    ${bankAddress2}   FakerLibrary.Street name
    ${bankCity}       FakerLibrary.word
    ${bankState}      FakerLibrary.state

    ${bankStatementAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${bankStatementAttachments}

    ${resp}=    Add loan Bank Details    4    ${loanuid3}    ${EMPTY}    ${bankName}    ${bankAccountNo}    ${bankIfsc}    ${bankAddress1}    ${bankAddress2}    ${bankCity}    ${bankState}   ${bankPin}    ${bankStatementAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings     ${resp.json()}    ${UPDATE_ERROR}


JD-TC-AddLoanBankDetails-7
                                  
    [Documentation]               Create Loan Application and add loan bank Details EMPTY originUid.

    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME81}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

    ${PH_Number}    Random Number 	digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${phone}  555${PH_Number}

    ${resp}=    Generate Loan Application Otp for Phone Number    ${phone}   ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${kyc_list1}=  Create Dictionary  isCoApplicant=${bool[0]}
    ${gender}    Random Element    ${Genderlist}
    # ${firstName}=  FakerLibrary.name
    # ${lastName}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date Of Birth   minimum_age=23   maximum_age=55
    ${dob}=  Convert To String  ${dob}
    
    # ${resp}=    Verify Phone Otp and Create Loan Application   ${phone}   13   ${custid}    ${firstName}    ${lastName}    ${phoneNo}   ${countryCodes[0]}    ${locId}    ${kyc_list1}
    ${resp}=    Verify Phone and Create Loan Application with customer details  ${phone}  ${OtpPurpose['ConsumerVerifyPhone']}  ${custid}  ${locId}    ${CustomerPhoto}  ${kyc_list1}  firstName=${firstName}  lastName=${lastName}  phoneNo=${phone}  countryCode=${countryCodes[0]}  gender=${gender}  dob=${dob}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Test Variable  ${loanid3}    ${resp.json()['id']}
    Set Test Variable  ${loanuid1}    ${resp.json()['uid']}

    ${resp}=    Get Loan Application By uid  ${loanuid1} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=  db.getType   ${pdffile} 
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${pdffile} 
    Set Suite Variable    ${fileType}
    ${caption}=  Fakerlibrary.Sentence

    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType1}
    ${caption1}=  Fakerlibrary.Sentence

    ${bankName}    FakerLibrary.name
    ${bankAddress1}   FakerLibrary.Street name
    ${bankAddress2}   FakerLibrary.Street name
    ${bankCity}       FakerLibrary.word
    ${bankState}      FakerLibrary.state

    ${bankStatementAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${bankStatementAttachments}

    ${resp}=    Add loan Bank Details    4    ${EMPTY}    ${loanuid1}    ${bankName}    ${bankAccountNo}    ${bankIfsc}    ${bankAddress1}    ${bankAddress2}    ${bankCity}    ${bankState}   ${bankPin}    ${bankStatementAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings     ${resp.json()}    ${ORIGIN_UID_REQUIRED}

JD-TC-AddLoanBankDetails-8
                                  
    [Documentation]               Create Loan Application and add loan bank Details EMPTY bankName.

    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME81}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

    ${PH_Number}    Random Number 	digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${phone}  555${PH_Number}

    ${resp}=    Generate Loan Application Otp for Phone Number    ${phone}   ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${kyc_list1}=           Create Dictionary  isCoApplicant=${bool[0]}
    ${gender}    Random Element    ${Genderlist}
    # ${firstName}=  FakerLibrary.name
    # ${lastName}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date Of Birth   minimum_age=23   maximum_age=55
    ${dob}=  Convert To String  ${dob}
    
    # ${resp}=    Verify Phone Otp and Create Loan Application   ${phone}   13   ${custid}    ${firstName}    ${lastName}    ${phoneNo}   ${countryCodes[0]}    ${locId}    ${kyc_list1}
    ${resp}=    Verify Phone and Create Loan Application with customer details  ${phone}  ${OtpPurpose['ConsumerVerifyPhone']}  ${custid}  ${locId}    ${CustomerPhoto}  ${kyc_list1}  firstName=${firstName}  lastName=${lastName}  phoneNo=${phone}  countryCode=${countryCodes[0]}  gender=${gender}  dob=${dob}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Test Variable  ${loanid3}    ${resp.json()['id']}
    Set Test Variable  ${loanuid1}    ${resp.json()['uid']}

    ${resp}=    Get Loan Application By uid  ${loanuid1} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=  db.getType   ${pdffile} 
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${pdffile} 
    Set Suite Variable    ${fileType}
    ${caption}=  Fakerlibrary.Sentence

    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType1}
    ${caption1}=  Fakerlibrary.Sentence

    ${bankName}    FakerLibrary.name
    ${bankAddress1}   FakerLibrary.Street name
    ${bankAddress2}   FakerLibrary.Street name
    ${bankCity}       FakerLibrary.word
    ${bankState}      FakerLibrary.state

    ${bankStatementAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${bankStatementAttachments}

    ${resp}=    Add loan Bank Details    4    ${loanuid1}    ${loanuid1}    ${EMPTY}    ${bankAccountNo}    ${bankIfsc}    ${bankAddress1}    ${bankAddress2}    ${bankCity}    ${bankState}   ${bankPin}    ${bankStatementAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings     ${resp.json()}    ${NO_BANK_DETAILS_FOUND}

JD-TC-AddLoanBankDetails-9
                                  
    [Documentation]               Create Loan Application and add loan bank Details EMPTY bankAccountNo.

    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME81}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

    ${PH_Number}    Random Number 	digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${phone}  555${PH_Number}

    ${resp}=    Generate Loan Application Otp for Phone Number    ${phone}   ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${kyc_list1}=  Create Dictionary  isCoApplicant=${bool[0]}
    ${gender}    Random Element    ${Genderlist}
    # ${firstName}=  FakerLibrary.name
    # ${lastName}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date Of Birth   minimum_age=23   maximum_age=55
    ${dob}=  Convert To String  ${dob}
    
    # ${resp}=    Verify Phone Otp and Create Loan Application   ${phone}   13   ${custid}    ${firstName}    ${lastName}    ${phoneNo}   ${countryCodes[0]}    ${locId}    ${kyc_list1}
    ${resp}=    Verify Phone and Create Loan Application with customer details  ${phone}  ${OtpPurpose['ConsumerVerifyPhone']}  ${custid}  ${locId}    ${CustomerPhoto}   ${kyc_list1}  firstName=${firstName}  lastName=${lastName}  phoneNo=${phone}  countryCode=${countryCodes[0]}  gender=${gender}  dob=${dob}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Test Variable  ${loanid3}    ${resp.json()['id']}
    Set Test Variable  ${loanuid1}    ${resp.json()['uid']}

    ${resp}=    Get Loan Application By uid  ${loanuid1} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=  db.getType   ${pdffile} 
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${pdffile} 
    Set Suite Variable    ${fileType}
    ${caption}=  Fakerlibrary.Sentence

    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType1}
    ${caption1}=  Fakerlibrary.Sentence

    ${bankName}    FakerLibrary.name
    ${bankAddress1}   FakerLibrary.Street name
    ${bankAddress2}   FakerLibrary.Street name
    ${bankCity}       FakerLibrary.word
    ${bankState}      FakerLibrary.state

    ${bankStatementAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${bankStatementAttachments}

    ${resp}=    Add loan Bank Details    4    ${loanuid1}    ${loanuid1}    ${bankName}    ${EMPTY}    ${bankIfsc}    ${bankAddress1}    ${bankAddress2}    ${bankCity}    ${bankState}   ${bankPin}    ${bankStatementAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings     ${resp.json()}    ${ACCOUNR_NUMBER_REQ}

JD-TC-AddLoanBankDetails-10
                                  
    [Documentation]               Create Loan Application and add loan bank Details EMPTY bankIfsc.

    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME81}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

    ${PH_Number}    Random Number 	digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${phone}  555${PH_Number}

    ${resp}=    Generate Loan Application Otp for Phone Number    ${phone}   ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${kyc_list1}=   Create Dictionary  isCoApplicant=${bool[0]}
    ${gender}    Random Element    ${Genderlist}
    # ${firstName}=  FakerLibrary.name
    # ${lastName}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date Of Birth   minimum_age=23   maximum_age=55
    ${dob}=  Convert To String  ${dob}
    
    # ${resp}=    Verify Phone Otp and Create Loan Application   ${phone}   13   ${custid}    ${firstName}    ${lastName}    ${phoneNo}   ${countryCodes[0]}    ${locId}    ${kyc_list1}
    ${resp}=    Verify Phone and Create Loan Application with customer details  ${phone}  ${OtpPurpose['ConsumerVerifyPhone']}  ${custid}  ${locId}   ${CustomerPhoto}   ${kyc_list1}  firstName=${firstName}  lastName=${lastName}  phoneNo=${phone}  countryCode=${countryCodes[0]}  gender=${gender}  dob=${dob}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Test Variable  ${loanid3}    ${resp.json()['id']}
    Set Test Variable  ${loanuid1}    ${resp.json()['uid']}

    ${resp}=    Get Loan Application By uid  ${loanuid1} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=  db.getType   ${pdffile} 
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${pdffile} 
    Set Suite Variable    ${fileType}
    ${caption}=  Fakerlibrary.Sentence

    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType1}
    ${caption1}=  Fakerlibrary.Sentence

    ${bankName}    FakerLibrary.name
    ${bankAddress1}   FakerLibrary.Street name
    ${bankAddress2}   FakerLibrary.Street name
    ${bankCity}       FakerLibrary.word
    ${bankState}      FakerLibrary.state

    ${bankStatementAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${bankStatementAttachments}

    ${resp}=    Add loan Bank Details    4    ${loanuid1}    ${loanuid1}    ${bankName}    ${bankAccountNo}    ${EMPTY}    ${bankAddress1}    ${bankAddress2}    ${bankCity}    ${bankState}   ${bankPin}    ${bankStatementAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings     ${resp.json()}    ${IFSC_REQ}

JD-TC-AddLoanBankDetails-11
                                  
    [Documentation]               Create Loan Application and add loan bank Details EMPTY bankAddress1.

    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME81}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

    ${PH_Number}    Random Number 	digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${phone}  555${PH_Number}

    ${resp}=    Generate Loan Application Otp for Phone Number    ${phone}   ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${kyc_list1}=  Create Dictionary  isCoApplicant=${bool[0]}
    ${gender}    Random Element    ${Genderlist}
    # ${firstName}=  FakerLibrary.name
    # ${lastName}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date Of Birth   minimum_age=23   maximum_age=55
    ${dob}=  Convert To String  ${dob}
    
    # ${resp}=    Verify Phone Otp and Create Loan Application   ${phone}   13   ${custid}    ${firstName}    ${lastName}    ${phoneNo}   ${countryCodes[0]}    ${locId}    ${kyc_list1}
    ${resp}=    Verify Phone and Create Loan Application with customer details  ${phone}  ${OtpPurpose['ConsumerVerifyPhone']}  ${custid}  ${locId}    ${CustomerPhoto}  ${kyc_list1}  firstName=${firstName}  lastName=${lastName}  phoneNo=${phone}  countryCode=${countryCodes[0]}  gender=${gender}  dob=${dob}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Test Variable  ${loanid3}    ${resp.json()['id']}
    Set Test Variable  ${loanuid1}    ${resp.json()['uid']}

    ${resp}=    Get Loan Application By uid  ${loanuid1} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=  db.getType   ${pdffile} 
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${pdffile} 
    Set Suite Variable    ${fileType}
    ${caption}=  Fakerlibrary.Sentence

    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType1}
    ${caption1}=  Fakerlibrary.Sentence

    ${bankName}    FakerLibrary.name
    ${bankAddress1}   FakerLibrary.Street name
    ${bankAddress2}   FakerLibrary.Street name
    ${bankCity}       FakerLibrary.word
    ${bankState}      FakerLibrary.state

    ${bankStatementAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${bankStatementAttachments}

    ${resp}=    Add loan Bank Details    4    ${loanuid1}    ${loanuid1}    ${bankName}    ${bankAccountNo}    ${bankIfsc}    ${EMPTY}    ${bankAddress2}    ${bankCity}    ${bankState}   ${bankPin}    ${bankStatementAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

JD-TC-AddLoanBankDetails-12
                                  
    [Documentation]               Create Loan Application and add loan bank Details EMPTY bankAddress2.

    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME81}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

    ${PH_Number}    Random Number 	digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${phone}  555${PH_Number}

    ${resp}=    Generate Loan Application Otp for Phone Number    ${phone}   ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${kyc_list1}=   Create Dictionary  isCoApplicant=${bool[0]}
    ${gender}    Random Element    ${Genderlist}
    # ${firstName}=  FakerLibrary.name
    # ${lastName}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date Of Birth   minimum_age=23   maximum_age=55
    ${dob}=  Convert To String  ${dob}
    
    # ${resp}=    Verify Phone Otp and Create Loan Application   ${phone}   13   ${custid}    ${firstName}    ${lastName}    ${phoneNo}   ${countryCodes[0]}    ${locId}    ${kyc_list1}
    ${resp}=    Verify Phone and Create Loan Application with customer details  ${phone}  ${OtpPurpose['ConsumerVerifyPhone']}  ${custid}  ${locId}    ${CustomerPhoto}  ${kyc_list1}  firstName=${firstName}  lastName=${lastName}  phoneNo=${phone}  countryCode=${countryCodes[0]}  gender=${gender}  dob=${dob}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Test Variable  ${loanid3}    ${resp.json()['id']}
    Set Test Variable  ${loanuid1}    ${resp.json()['uid']}

    ${resp}=    Get Loan Application By uid  ${loanuid1} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=  db.getType   ${pdffile} 
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${pdffile} 
    Set Suite Variable    ${fileType}
    ${caption}=  Fakerlibrary.Sentence

    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType1}
    ${caption1}=  Fakerlibrary.Sentence

    ${bankName}    FakerLibrary.name
    ${bankAddress1}   FakerLibrary.Street name
    ${bankAddress2}   FakerLibrary.Street name
    ${bankCity}       FakerLibrary.word
    ${bankState}      FakerLibrary.state

    ${bankStatementAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${bankStatementAttachments}

    ${resp}=    Add loan Bank Details    4    ${loanuid1}    ${loanuid1}    ${bankName}    ${bankAccountNo}    ${bankIfsc}    ${bankAddress1}    ${EMPTY}    ${bankCity}    ${bankState}   ${bankPin}    ${bankStatementAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

JD-TC-AddLoanBankDetails-13
                                  
    [Documentation]               Create Loan Application and add loan bank Details EMPTY bankCity.

    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME81}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

    ${PH_Number}    Random Number 	digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${phone}  555${PH_Number}

    ${resp}=    Generate Loan Application Otp for Phone Number    ${phone}   ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${kyc_list1}=   Create Dictionary  isCoApplicant=${bool[0]}
    ${gender}    Random Element    ${Genderlist}
    # ${firstName}=  FakerLibrary.name
    # ${lastName}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date Of Birth   minimum_age=23   maximum_age=55
    ${dob}=  Convert To String  ${dob}
    
    # ${resp}=    Verify Phone Otp and Create Loan Application   ${phone}   13   ${custid}    ${firstName}    ${lastName}    ${phoneNo}   ${countryCodes[0]}    ${locId}    ${kyc_list1}
    ${resp}=    Verify Phone and Create Loan Application with customer details  ${phone}  ${OtpPurpose['ConsumerVerifyPhone']}  ${custid}  ${locId}    ${CustomerPhoto}  ${kyc_list1}  firstName=${firstName}  lastName=${lastName}  phoneNo=${phone}  countryCode=${countryCodes[0]}  gender=${gender}  dob=${dob}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Test Variable  ${loanid3}    ${resp.json()['id']}
    Set Test Variable  ${loanuid1}    ${resp.json()['uid']}

    ${resp}=    Get Loan Application By uid  ${loanuid1} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=  db.getType   ${pdffile} 
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${pdffile} 
    Set Suite Variable    ${fileType}
    ${caption}=  Fakerlibrary.Sentence

    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType1}
    ${caption1}=  Fakerlibrary.Sentence

    ${bankName}    FakerLibrary.name
    ${bankAddress1}   FakerLibrary.Street name
    ${bankAddress2}   FakerLibrary.Street name
    ${bankCity}       FakerLibrary.word
    ${bankState}      FakerLibrary.state

    ${bankStatementAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${bankStatementAttachments}

    ${resp}=    Add loan Bank Details    4    ${loanuid1}    ${loanuid1}    ${bankName}    ${bankAccountNo}    ${bankIfsc}    ${bankAddress1}    ${bankAddress2}    ${EMPTY}    ${bankState}   ${bankPin}    ${bankStatementAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

JD-TC-AddLoanBankDetails-14
                                  
    [Documentation]               Create Loan Application and add loan bank Details EMPTY bankState.

    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME81}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

    ${PH_Number}    Random Number 	digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${phone}  555${PH_Number}

    ${resp}=    Generate Loan Application Otp for Phone Number    ${phone}   ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${kyc_list1}=  Create Dictionary  isCoApplicant=${bool[0]}
    ${gender}    Random Element    ${Genderlist}
    # ${firstName}=  FakerLibrary.name
    # ${lastName}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date Of Birth   minimum_age=23   maximum_age=55
    ${dob}=  Convert To String  ${dob}
    
    # ${resp}=    Verify Phone Otp and Create Loan Application   ${phone}   13   ${custid}    ${firstName}    ${lastName}    ${phoneNo}   ${countryCodes[0]}    ${locId}    ${kyc_list1}
    ${resp}=    Verify Phone and Create Loan Application with customer details  ${phone}  ${OtpPurpose['ConsumerVerifyPhone']}  ${custid}  ${locId}    ${CustomerPhoto}  ${kyc_list1}  firstName=${firstName}  lastName=${lastName}  phoneNo=${phone}  countryCode=${countryCodes[0]}  gender=${gender}  dob=${dob}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Test Variable  ${loanid3}    ${resp.json()['id']}
    Set Test Variable  ${loanuid1}    ${resp.json()['uid']}

    ${resp}=    Get Loan Application By uid  ${loanuid1} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=  db.getType   ${pdffile} 
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${pdffile} 
    Set Suite Variable    ${fileType}
    ${caption}=  Fakerlibrary.Sentence

    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType1}
    ${caption1}=  Fakerlibrary.Sentence

    ${bankName}    FakerLibrary.name
    ${bankAddress1}   FakerLibrary.Street name
    ${bankAddress2}   FakerLibrary.Street name
    ${bankCity}       FakerLibrary.word
    ${bankState}      FakerLibrary.state

    ${bankStatementAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${bankStatementAttachments}

    ${resp}=    Add loan Bank Details    4    ${loanuid1}    ${loanuid1}    ${bankName}    ${bankAccountNo}    ${bankIfsc}    ${bankAddress1}    ${bankAddress2}    ${bankCity}    ${EMPTY}   ${bankPin}    ${bankStatementAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

JD-TC-AddLoanBankDetails-15
                                  
    [Documentation]               Create Loan Application and add loan bank Details EMPTY bankPin.

    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME81}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

    ${PH_Number}    Random Number 	digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${phone}  555${PH_Number}

    ${resp}=    Generate Loan Application Otp for Phone Number    ${phone}   ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${kyc_list1}=  Create Dictionary  isCoApplicant=${bool[0]}
    ${gender}    Random Element    ${Genderlist}
    # ${firstName}=  FakerLibrary.name
    # ${lastName}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date Of Birth   minimum_age=23   maximum_age=55
    ${dob}=  Convert To String  ${dob}
    
    # ${resp}=    Verify Phone Otp and Create Loan Application   ${phone}   13   ${custid}    ${firstName}    ${lastName}    ${phoneNo}   ${countryCodes[0]}    ${locId}    ${kyc_list1}
    ${resp}=    Verify Phone and Create Loan Application with customer details  ${phone}  ${OtpPurpose['ConsumerVerifyPhone']}  ${custid}  ${locId}    ${CustomerPhoto}  ${kyc_list1}  firstName=${firstName}  lastName=${lastName}  phoneNo=${phone}  countryCode=${countryCodes[0]}  gender=${gender}  dob=${dob}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Test Variable  ${loanid3}    ${resp.json()['id']}
    Set Test Variable  ${loanuid1}    ${resp.json()['uid']}

    ${resp}=    Get Loan Application By uid  ${loanuid1} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=  db.getType   ${pdffile} 
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${pdffile} 
    Set Suite Variable    ${fileType}
    ${caption}=  Fakerlibrary.Sentence

    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType1}
    ${caption1}=  Fakerlibrary.Sentence

    ${bankName}    FakerLibrary.name
    ${bankAddress1}   FakerLibrary.Street name
    ${bankAddress2}   FakerLibrary.Street name
    ${bankCity}       FakerLibrary.word
    ${bankState}      FakerLibrary.state

    ${bankStatementAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${bankStatementAttachments}

    ${resp}=    Add loan Bank Details    4    ${loanuid1}    ${loanuid1}    ${bankName}    ${bankAccountNo}    ${bankIfsc}    ${bankAddress1}    ${bankAddress2}    ${bankCity}    ${bankState}   ${EMPTY}    ${bankStatementAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

JD-TC-AddLoanBankDetails-16
                                  
    [Documentation]               Create Loan Application and add loan bank Details EMPTY bankStatementAttachments.

    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME81}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

    ${PH_Number}    Random Number 	digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${phone}  555${PH_Number}

    ${resp}=    Generate Loan Application Otp for Phone Number    ${phone}   ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${kyc_list1}=   Create Dictionary  isCoApplicant=${bool[0]}
    ${gender}    Random Element    ${Genderlist}
    # ${firstName}=  FakerLibrary.name
    # ${lastName}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date Of Birth   minimum_age=23   maximum_age=55
    ${dob}=  Convert To String  ${dob}
    
    # ${resp}=    Verify Phone Otp and Create Loan Application   ${phone}   13   ${custid}    ${firstName}    ${lastName}    ${phoneNo}   ${countryCodes[0]}    ${locId}    ${kyc_list1}
    ${resp}=    Verify Phone and Create Loan Application with customer details  ${phone}  ${OtpPurpose['ConsumerVerifyPhone']}  ${custid}  ${locId}    ${CustomerPhoto}  ${kyc_list1}  firstName=${firstName}  lastName=${lastName}  phoneNo=${phone}  countryCode=${countryCodes[0]}  gender=${gender}  dob=${dob}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Test Variable  ${loanid3}    ${resp.json()['id']}
    Set Test Variable  ${loanuid1}    ${resp.json()['uid']}

    ${resp}=    Get Loan Application By uid  ${loanuid1} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=  db.getType   ${pdffile} 
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${pdffile} 
    Set Suite Variable    ${fileType}
    ${caption}=  Fakerlibrary.Sentence

    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType1}
    ${caption1}=  Fakerlibrary.Sentence

    ${bankName}    FakerLibrary.name
    ${bankAddress1}   FakerLibrary.Street name
    ${bankAddress2}   FakerLibrary.Street name
    ${bankCity}       FakerLibrary.word
    ${bankState}      FakerLibrary.state

    ${bankStatementAttachments}=    Create Dictionary   action=${EMPTY}  owner=${EMPTY}  fileName=${EMPTY}  fileSize=${EMPTY}  caption=${EMPTY}  fileType=${EMPTY}  order=${EMPTY}
    Log  ${bankStatementAttachments}

    ${resp}=    Add loan Bank Details    4    ${loanuid1}    ${loanuid1}    ${bankName}    ${bankAccountNo}    ${bankIfsc}    ${bankAddress1}    ${bankAddress2}    ${bankCity}    ${bankState}   ${bankPin}    ${bankStatementAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422

JD-TC-AddLoanBankDetails-17
                                  
    [Documentation]               Create Loan Application and add loan bank Details with .sh file bankStatementAttachments.

    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME81}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

    ${PH_Number}    Random Number 	digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${phone}  555${PH_Number}

    ${resp}=    Generate Loan Application Otp for Phone Number    ${phone}   ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${kyc_list1}=   Create Dictionary  isCoApplicant=${bool[0]}
    ${gender}    Random Element    ${Genderlist}
    # ${firstName}=  FakerLibrary.name
    # ${lastName}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date Of Birth   minimum_age=23   maximum_age=55
    ${dob}=  Convert To String  ${dob}
    
    # ${resp}=    Verify Phone Otp and Create Loan Application   ${phone}   13   ${custid}    ${firstName}    ${lastName}    ${phoneNo}   ${countryCodes[0]}    ${locId}    ${kyc_list1}
    ${resp}=    Verify Phone and Create Loan Application with customer details  ${phone}  ${OtpPurpose['ConsumerVerifyPhone']}  ${custid}  ${locId}    ${CustomerPhoto}  ${kyc_list1}  firstName=${firstName}  lastName=${lastName}  phoneNo=${phone}  countryCode=${countryCodes[0]}  gender=${gender}  dob=${dob}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${loanid2}    ${resp.json()['id']}
    Set Suite Variable  ${loanuid2}    ${resp.json()['uid']}

    ${resp}=    Get Loan Application By uid  ${loanuid2} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${kycid}     ${resp.json()["loanApplicationKycList"][0]["id"]}

    ${resp}=  db.getType   ${shfile} 
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${shfile} 
    Set Suite Variable    ${fileType}
    ${caption}=  Fakerlibrary.Sentence

    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType1}
    ${caption1}=  Fakerlibrary.Sentence

    ${bankName}    FakerLibrary.name
    ${bankAddress1}   FakerLibrary.Street name
    ${bankAddress2}   FakerLibrary.Street name
    ${bankCity}       FakerLibrary.word
    ${bankState}      FakerLibrary.state

    ${bankStatementAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${shfile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${bankStatementAttachments}

    ${resp}=    Add loan Bank Details    4    ${loanuid2}    ${loanuid2}    ${bankName}    ${bankAccountNo}    ${bankIfsc}    ${bankAddress1}    ${bankAddress2}    ${bankCity}    ${bankState}   ${bankPin}    ${bankStatementAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings     ${resp.json()}    ${PLEASE_UPLOAD_PDF_FILE}

JD-TC-AddLoanBankDetails-18
                                  
    [Documentation]               Create Loan Application and add loan bank Details two time.

    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME81}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

    ${PH_Number}    Random Number 	digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${phone}  555${PH_Number}

    ${resp}=    Generate Loan Application Otp for Phone Number    ${phone}   ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${kyc_list1}=   Create Dictionary  isCoApplicant=${bool[0]}
    ${gender}    Random Element    ${Genderlist}
    # ${firstName}=  FakerLibrary.name
    # ${lastName}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date Of Birth   minimum_age=23   maximum_age=55
    ${dob}=  Convert To String  ${dob}
    
    # ${resp}=    Verify Phone Otp and Create Loan Application   ${phone}   13   ${custid}    ${firstName}    ${lastName}    ${phoneNo}   ${countryCodes[0]}    ${locId}    ${kyc_list1}
    ${resp}=    Verify Phone and Create Loan Application with customer details  ${phone}  ${OtpPurpose['ConsumerVerifyPhone']}  ${custid}  ${locId}    ${CustomerPhoto}  ${kyc_list1}  firstName=${firstName}  lastName=${lastName}  phoneNo=${phone}  countryCode=${countryCodes[0]}  gender=${gender}  dob=${dob}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${loanid3}    ${resp.json()['id']}
    Set Suite Variable  ${loanuid3}    ${resp.json()['uid']}

    ${resp}=    Get Loan Application By uid  ${loanuid3} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${kycid}     ${resp.json()["loanApplicationKycList"][0]["id"]}

    ${resp}=  db.getType   ${jpgfile} 
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${pdffile} 
    Set Suite Variable    ${fileType}
    ${caption}=  Fakerlibrary.Sentence

    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType1}
    ${caption1}=  Fakerlibrary.Sentence

    ${bankName}    FakerLibrary.name
    ${bankAddress1}   FakerLibrary.Street name
    ${bankAddress2}   FakerLibrary.Street name
    ${bankCity}       FakerLibrary.word
    ${bankState}      FakerLibrary.state

    ${bankStatementAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${bankStatementAttachments}

    ${resp}=    Add loan Bank Details    4    ${loanuid3}    ${loanuid3}    ${bankName}    ${bankAccountNo}    ${bankIfsc}    ${bankAddress1}    ${bankAddress2}    ${bankCity}    ${bankState}   ${bankPin}    ${bankStatementAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Add loan Bank Details    4    ${loanuid3}    ${loanuid3}    ${bankName}    ${bankAccountNo}    ${bankIfsc}    ${bankAddress1}    ${bankAddress2}    ${bankCity}    ${bankState}   ${bankPin}    ${bankStatementAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings     ${resp.json()}    ${BANK_DETAILS_ALREADY_EXIST}
