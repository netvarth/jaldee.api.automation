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
${lname}        hisham
${fname}        hisham

${monthlyIncome}    80000
${emiPaidAmountMonthly}    2000

${autoApprovalUptoAmount}    50000
${autoApprovalUptoAmount2}    70000


*** Test Cases ***

JD-TC-Change Loan Application Scheme-1
                                  
    [Documentation]               Create a loan And try to Change Loan Application Scheme.

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${provider_id1}  ${resp.json()['id']}
    Set Test Variable   ${lic_id}   ${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}

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

    ${resp}=    Create and Update Account level cdl setting    ${bool[1]}    ${autoApprovalUptoAmount2}    ${bool[1]}    ${toggle[0]}    ${bool[1]}    ${empty}   ${bool[1]}    ${bool[1]}  demandPromissoryNoteRequired=${bool[1]}    securityPostDatedChequesRequired=${bool[1]}    loanNature=ConsumerDurableLoan
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get account level cdl setting
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

    clear Customer  ${PUSERNAME87}

    ${fname}=  FakerLibrary.name
    ${lname}=  FakerLibrary.last_name
    Set Suite Variable  ${email2}  ${lname}${C_Email}.ynwtest@netvarth.com
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

    ${so_id1}=  Create Sample User 
    Set Suite Variable  ${so_id1}
    
    ${resp}=  Get User By Id  ${so_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${SOUSERNAME1}  ${resp.json()['mobileNo']}

    ${bch_id1}=  Create Sample User 
    Set Suite Variable  ${bch_id1}

    ${resp}=  Get User By Id  ${bch_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${BCHUSERNAME1}  ${resp.json()['mobileNo']}

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

    ${userids}=  Create List  ${so_id1}   ${bch_id1}    ${provider_id1}

    ${branch1}=  Create Dictionary   id=${branchid1}    isDefault=${bool[1]}
    # ${branch2}=  Create Dictionary   id=${branchid2}    isDefault=${bool[0]}

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

    ${PH_Number}    Random Number 	digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${P_phone}  555${PH_Number}
    ${dealerfname}=  FakerLibrary.name
    ${dealerlname}=  FakerLibrary.last_name
    ${dealerAlName}=  FakerLibrary.Company
    ${dealername}=  FakerLibrary.bs

    ${resp}=  Generate Phone Partner Creation    ${P_phone}    ${countryCodes[0]}  partnerName=${dealername}   partnerUserFirstName=${dealerfname}  partnerUserLastName=${dealerlname}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${branch}=      Create Dictionary   id=${branchid1}

    ${resp}=  Verify Phone Partner Creation  ${P_phone}  ${OtpPurpose['ProviderVerifyPhone']}  ${dealername}  ${dealerAlName}  branch=${branch}  partnerUserFirstName=${dealerfname}  partnerUserLastName=${dealerlname}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${Pid1}  ${resp.json()['id']}
    Set Suite Variable  ${Puid1}  ${resp.json()['uid']} 

    ${resp}=    Get Partner-With Filter
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${bank_ac}=   db.Generate_random_value  size=6   chars=${digits}
    Set Test Variable  ${bankAccountNo}  55555${bank_ac}

    ${ifsc_code}=   db.Generate_ifsc_code
    Set Test Variable  ${bankIfsc}  55555${ifsc_code}  

    ${bank_name}=  FakerLibrary.company

    ${resp}=  db.getType   ${pdffile} 
    Log  ${resp}
    ${fileType3}=  Get From Dictionary  ${resp}  ${pdffile} 
    ${caption3}=  Fakerlibrary.Sentence

    ${resp}    Update Partner Bank  ${bankAccountNo}  ${bankIfsc}  ${bankName}  ${Puid1}  ${LoanAction[0]}  ${Pid1}  ${pdffile}  ${fileSize}  ${caption3}  ${fileType3}  ${order}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${gstin}  ${pan_num}=   db.Generate_gst_number   55555

    ${resp}    Validate Gst    ${Puid1}     ${gstin}    
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}    Get Partner by UID     ${Puid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=   Partner Approval Request    ${Puid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${note}=    FakerLibrary.sentence
    Set Suite Variable    ${note}

    ${resp}=   Partner Approved    ${Puid1}    ${note}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

# ...... Update sales officer and credit officer for dealer1 & activate dealer1 by branch operation head....

    ${Salesofficer}=    Create Dictionary    id=${so_id1}  isDefault=${bool[1]}

    ${resp}=    Update Sales Officer    ${Puid1}    ${Salesofficer}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${Creditofficer}=    Create Dictionary    id=${bch_id1}    isDefault=${bool[1]}

    ${resp}=    Update Credit Officer    ${Puid1}      ${Creditofficer}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Activate Partner    ${Puid1}     ${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get Loan Application Category
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${categoryid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${categoryname}  ${resp.json()[0]['name']}

    ${resp}=    Get Loan Application Type
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${typeid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${typename}  ${resp.json()[0]['name']}

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
    Set Suite Variable  ${productname}  ${resp.json()[0]['productName']}
    Set Suite Variable  ${Productid1}  ${resp.json()[1]['id']}
    Set Suite Variable  ${productname1}  ${resp.json()[1]['productName']}

    ${resp}=    Get Loan Application Scheme
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${Schemeid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${Schemename}  ${resp.json()[0]['schemeName']} 
    Set Suite Variable  ${Schemeid1}  ${resp.json()[1]['id']}
    Set Suite Variable  ${Schemename1}  ${resp.json()[1]['schemeName']} 
    Set Suite Variable  ${Schemeid2}  ${resp.json()[2]['id']}
    Set Suite Variable  ${Schemename2}  ${resp.json()[2]['schemeName']}
    Set Suite Variable  ${Schemeid3}  ${resp.json()[3]['id']}
    Set Suite Variable  ${Schemename3}  ${resp.json()[3]['schemeName']}

    ${resp}=    Generate Loan Application Otp for Phone Number    ${phone}  ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${kyc_list1}=           Create Dictionary  isCoApplicant=${bool[0]}
    
    # ${resp}=    Verify Phone Otp and Create Loan Application   ${phone}   ${OtpPurpose['ConsumerVerifyPhone']}   ${custid}    ${firstName}    ${lastName}    ${phone}    ${countryCodes[0]}    ${locId}    ${kyc_list1}
    ${resp}=  Verify Phone and Create Loan Application with customer details  ${phone}  ${OtpPurpose['ConsumerVerifyPhone']}  ${custid}  ${locId}  ${kyc_list1}  firstName=${firstName}  lastName=${lastName}  phoneNo=${phone}  countryCode=${countryCodes[0]}  gender=${gender}  dob=${dob}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite VAriable  ${loanid}    ${resp.json()['id']}
    Set Suite VAriable  ${loanuid}    ${resp.json()['uid']}

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Test Variable  ${kycid}    ${resp.json()["loanApplicationKycList"][0]["id"]} 
    Set Suite Variable  ${ref_no}  ${resp.json()['referenceNo']}
    
# <----------------------------- KYC Details ------------------------------------------>
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


    ${resp}=    Update loan Application Kyc Details    ${loanid}     ${loanuid}   ${phone}       ${aadhaar}   ${pan}    ${aadhaarAttachments}    panAttachments=${panAttachments}    
    ...  permanentAddress1=velloor    permanentCity=malappuram    permanentPin=679581    permanentState=Kerala
    ...  currentAddress1=velloor    currentCity=malappuram    currentPin=679581    currentState=Kerala
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

# <----------------------------- Loan Details ------------------------------------------>

    ${emiPaidAmountMonthly}    FakerLibrary.Random Number

    ${nomineeName}        FakerLibrary.name

    ${LoanApplicationKycList}=    Create Dictionary   id=${kycid}  employmentStatus=${employmentStatus[0]}  monthlyIncome=${monthlyIncome}  nomineeType=${nomineeType[1]}  nomineeName=${nomineeName}    nomineeDob=20-10-1999   nomineePhone=5555555555
    ...  customerEducation=1    customerEmployement=1    salaryRouting=1    familyDependants=0    noOfYearsAtPresentAddress=1    currentResidenceOwnershipStatus=1    ownedMovableAssets=1  vehicleNo=KER369   goodsFinanced=1   earningMembers=1   existingCustomer=1
    Log  ${LoanApplicationKycList}

    ${category}=       Create Dictionary    id=${categoryid}  name=${categoryname}
    ${type}=           Create Dictionary    id=${typeid}  name=${typename}
    ${loanProducts}=    Create Dictionary    id=${Productid}  categoryId=${categoryid}    typeId=${typeid}
    ${loanProducts}=    Create List    ${loanProducts}
    ${loanScheme}=     Create Dictionary    id=${Schemeid1}  name=${Schemename1}

    ${partner}=  Create Dictionary  id=${Pid1}
    Set Suite Variable    ${partner}

    ${resp}=    Verify loan Bank Details    ${loanid}  ${loanProducts}  ${category}   ${type}    ${loanScheme}    ${invoiceAmount}    ${downpaymentAmount}    ${requestedAmount}    ${monthlyIncome}    ${emiPaidAmountMonthly}    ${LoanApplicationKycList}        uid=${loanuid}   partner=${partner}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Should Be Equal As Strings     ${resp.json()['loanScheme']['id']}    ${Schemeid1}

    ${resp}=    Change Loan Application Scheme  ${loanuid}     ${Schemeid2}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Should Be Equal As Strings     ${resp.json()['loanScheme']['id']}    ${Schemeid2}

JD-TC-Change Loan Application Scheme-2
                                  
    [Documentation]               Create a loan And try to Change Loan Application SUBVENTION Scheme.

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${provider_id1}  ${resp.json()['id']}

    ${resp}=    Change Loan Application Scheme  ${loanuid}     ${Schemeid3}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Should Be Equal As Strings     ${resp.json()['loanScheme']['id']}    ${Schemeid3}


JD-TC-Change Loan Application Scheme-3
                                  
    [Documentation]               After approvel request try to Change Loan Application Scheme.

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


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

    ${bankStatementAttachments2}=    Create Dictionary   action=${LoanAction[0]}  owner=${custid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${bankStatementAttachments2}

    ${resp}=    Update loan Bank Details    4    ${loanuid}    ${loanuid}    ${bankName}    ${bankAccountNo2}    ${bankIfsc}    ${bankAddress1}    ${bankAddress2}    ${bankCity}    ${bankState}   ${bankPin2}    ${bankStatementAttachments2}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Verify loan Bank   ${loanuid}    ${bankAccountNo2}    ${bankIfsc}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get loan Bank Details    ${loanuid}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable    ${kyid}    ${resp.json()['id']}

# <----------------------------- Bank Details ------------------------------------------> 
    ${remark}=    FakerLibrary.sentence
    ${note}=      FakerLibrary.sentence

    ${resp}=    LoanApplication Remark        ${loanuid}    ${remark}
    Log    ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=   Add General Notes    ${loanuid}    ${note}
    Log    ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Loan Application Approval        ${loanuid}    
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Change Loan Application Scheme  ${loanuid}     ${Schemeid}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Should Be Equal As Strings     ${resp.json()['loanScheme']['id']}    ${Schemeid}

JD-TC-Change Loan Application Scheme-4
                                  
    [Documentation]               After credit approved try to Change Loan Application Scheme.

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${loanScheme}=     Create Dictionary    id=${Schemeid1}  
    ${loanProduct}=    Create Dictionary    id=${Productid} 
    ${resp}=    Loan Application Manual Approval        ${loanuid}    ${loanScheme}   ${invoiceAmount}    ${downpaymentAmount}    ${requestedAmount}    ${requestedAmount}    loanProduct=${loanProduct}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['spInternalStatus']}    ${LoanApplicationSpInternalStatus[4]}

    ${resp}=    Change Loan Application Scheme  ${loanuid}     ${Schemeid3}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Should Be Equal As Strings     ${resp.json()['loanScheme']['id']}    ${Schemeid3}

JD-TC-Change Loan Application Scheme-UH1
                                  
    [Documentation]               After approved try to Change Loan Application Scheme.

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Avaliable Tenures    ${loanid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable    ${tenu1}    ${resp.json()[6]['id']}

    ${resp}=  salesofficer Approval    ${loanuid}    ${Schemeid3}    ${tenu1}   2  2 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Otp for Consumer Acceptance Phone    ${phone}  ${email2}   ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Otp for Consumer Loan Acceptance Phone    ${phone}    ${OtpPurpose['Authentication']}    ${loanuid}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Change Loan Application Scheme  ${loanuid}     ${Schemeid2}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Should Be Equal As Strings     ${resp.json()['loanScheme']['id']}    ${Schemeid2}

JD-TC-Change Loan Application Scheme-UH2
                                  
    [Documentation]               Change Loan Application Scheme with invalid loanuid.

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${loanUid}=    Random Int  min=10   max=20

    ${resp}=    Change Loan Application Scheme  ${loanuid}     ${Schemeid2}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}  ${INVALID_LOAN_APPLICATION_ID}

JD-TC-Change Loan Application Scheme-UH3
                                  
    [Documentation]               Change Loan Application Scheme with invalid schemeid.

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Schemeid2}=    Random Int  min=10   max=20

    ${resp}=    Change Loan Application Scheme  ${loanuid}     ${Schemeid2}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}  ${INVALID_LOAN_SCHEME_ID}
