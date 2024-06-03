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
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/hl_providers.py

*** Variables ***

@{emptylist}

${jpgfile}      /ebs/TDD/uploadimage.jpg
${pngfile}      /ebs/TDD/upload.png
${pdffile}      /ebs/TDD/sample.pdf

${order}    0
${fileSize}  0.00458


${aadhaar}   555555555555
${pan}       5555523145
${bankPin}       555553

${invoiceAmount}    100000
${downpaymentAmount}    20000
${requestedAmount}    80000

${monthlyIncome}    80000
${emiPaidAmountMonthly}    2000
${start}   12

${customerEducation1}  1    
${customerEmployement1}   1   
${salaryRouting1}    1
${familyDependants1}    1
${noOfYearsAtPresentAddress1}    1  
${currentResidenceOwnershipStatus1}    1 
${ownedMovableAssets1}    1
${goodsFinanced1}    1
${earningMembers1}    1
${existingCustomer1}    1
${vehicleNo1}    2456

*** Test Cases ***

JD-TC-Partner Verify Loan Application Details-1
                                  
    [Documentation]              Partner Verify Loan Application Details

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
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
    ${firstName}=    FakerLibrary.firstName
    ${lastName}=    FakerLibrary.lastName
    Set Suite Variable  ${email}  ${firstName}${C_Email}.${test_mail}

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

    ${resp}=   Get Location ById  ${locId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pin}  ${resp.json()['pinCode']}

    ${resp}=  Get LocationsByPincode     ${pin}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${district}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Suite Variable  ${state}  ${resp.json()[0]['PostOffice'][0]['State']}  
    ${state}=    Evaluate     "${state}".title()
    ${state}=    String.RemoveString  ${state}    ${SPACE}
    Set Suite Variable    ${state} 
   
    ${resp}=    Create BranchMaster    ${branchCode}    ${branchName}    ${locId}    ${status[0]}    ${district}    ${state}    ${pin}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${branchid1}  ${resp.json()['id']}

    ${resp}=    Change Branch Status    ${branchid1}    ${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${userids}=  Create List  ${so_id1}   ${bch_id1}

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

    ${resp}=  Generate Phone Partner Creation    ${P_phone}    ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${branch}=      Create Dictionary   id=${branchid1}

    ${resp}=  Verify Phone Partner Creation    ${P_phone}    ${OtpPurpose['ProviderVerifyPhone']}    ${firstName}   ${lastName}    branch=${branch}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${Pid1}  ${resp.json()['id']}
    Set Suite Variable  ${Puid1}  ${resp.json()['uid']} 

    ${resp}=    Get Partner-With Filter
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

    ${resp}=    Get Loan Application ProductCategory
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${loanproductcatid}  ${resp.json()[0]['id']}
    
    ${s_len}=  Get Length  ${resp.json()}
    @{loanproductcatid}=  Create List
    FOR  ${i}  IN RANGE   ${s_len}
        Append To List  ${loanproductcatid}  ${resp.json()[${i}]['id']}
    END
    Log  ${loanproductcatid}
    Set Suite Variable    ${loanproductcatid}


    ${resp}=  LoanProductSubCategory    ${account_id}    @{loanproductcatid}

    ${resp}=    Get Loan Application ProductSubCategory   ${loanproductcatid[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${loanproductSubcatid}  ${resp.json()[0]['id']}

    ${resp}=    Get Partner by UID    ${Puid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}=  Provider Logout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Partner Reset Password    ${account_id}  ${P_phone}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    511 
    Should Be Equal As Strings   ${resp.json()}   otp authentication needed
    # Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    Verify Otp For Login Partner  ${P_phone}  ${OtpPurpose['Authentication']}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    Complete Partner Reset Password    ${account_id}  ${P_phone}  ${PASSWORD}  ${token}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}=    Login Partner with Password    ${account_id}  ${P_phone}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${PH_Number}    Random Number 	digits=5  #fix_len=True
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${consnum}  555${PH_Number}

    ${resp}=  Get Partner Loan Application Consumer Details with filter  phoneNo-eq=${consnum}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        Set Suite Variable  ${custid}   0
        ${gender}    Random Element    ${Genderlist}
        ${Custfname}=  FakerLibrary.name
        ${Custlname}=  FakerLibrary.last_name
        ${dob}=  FakerLibrary.Date Of Birth   minimum_age=23   maximum_age=55
        ${dob}=  Convert To String  ${dob}
        # ${dob}=  FakerLibrary.Date
        ${custDetails}=  Create Dictionary  firstName=${Custfname}  lastName=${Custlname}  phoneNo=${consnum}  countryCode=${countryCodes[0]}  gender=${gender}  dob=${dob}
        
    ELSE
        Set Suite Variable  ${custid}  ${resp.json()[0]['id']}
        ${custDetails}=  Create Dictionary
    END   
    
    Set Suite Variable    ${custDetails}

    ${resp}=    Partner Generate Loan Application Otp For Phone Number    ${consnum}  ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${kyc_list1}=  Create Dictionary  isCoApplicant=${bool[0]}
    Set Suite Variable    ${kyc_list1}
    
    ${resp}=  Partner Verify Number and Create Loan Application with customer details  ${consnum}  ${OtpPurpose['ConsumerVerifyPhone']}  ${custid}  ${locId}  ${kyc_list1}  &{custDetails}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${loanid}    ${resp.json()['id']}
    Set Suite Variable  ${loanuid}    ${resp.json()['uid']}
    
    ${resp}=    Partner Otp For Email    ${email}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=   Partner Verify Otp for Email    ${email}    5    ${loanuid}
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
    
    ${aadhaarAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${Pid1}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${aadhaarAttachments}
    Set Suite Variable    ${aadhaarAttachments}

    ${resp}=   Requst For Partner Aadhar Validation    ${Pid1}    ${loanuid}   ${consnum}    ${aadhaar}    ${aadhaarAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${panAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${custid}  fileName=${jpgfile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType1}  order=${order}
    Log  ${panAttachments}
    Set Suite Variable    ${panAttachments}

    ${resp}=    Requst For Partner Pan Validation    ${custid}    ${loanuid}    ${consnum}    ${pan}    ${panAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${bankName1}    FakerLibrary.name
    Set Suite Variable    ${bankName1}
    ${bankAddress1a}   FakerLibrary.Street name
    Set Suite Variable    ${bankAddress1a}
    ${bankAddress2a}   FakerLibrary.Street name
    Set Suite Variable    ${bankAddress2a}
    ${bankCity1}       FakerLibrary.word
    Set Suite Variable    ${bankCity1}
    ${bankState1}      FakerLibrary.state
    Set Suite Variable    ${bankState1}
    ${bankAccountNo1}    Random Number 	digits=10
    Set Suite Variable    ${bankAccountNo1}

    ${bankIfsc1}         Random Number 	digits=6
    Set Suite variable    ${bankIfsc1}
    ${bankIfsc1}    Random Number 	digits=10 
    ${bankIfsc1}=    Evaluate    f'{${bankIfsc1}:0>1d}'
    Log  ${bankIfsc1}
    Set Suite Variable  ${bankIfsc1}  55555${bankIfsc1}

    ${bankStatementAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${Pid1}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${bankStatementAttachments}
    Set Suite Variable    ${bankStatementAttachments}

    ${resp}=    Add Partner loan Bank Details    ${originFrom[2]}    ${loanuid}    ${loanuid}    ${bankName1}    ${bankAccountNo1}    ${bankIfsc1}    ${bankAddress1a}    ${bankAddress2a}    ${bankCity1}    ${bankState1}   ${bankPin}    ${bankStatementAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${bankStatementAttachments2}=    Create Dictionary   action=${LoanAction[0]}  owner=${custid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${bankStatementAttachments2}
    Set Suite Variable    ${bankStatementAttachments2}

    ${bankName}    FakerLibrary.name
    Set Suite Variable    ${bankName}
    
    ${Acc_Number}    Random Number 	digits=10 
    ${Acc_Number}=    Evaluate    f'{${Acc_Number}:0>6d}'
    Log  ${Acc_Number}
    Set Suite Variable  ${AccountNumber}  55555${Acc_Number}

    ${bankAddress1}   FakerLibrary.Street name
    Set Suite Variable    ${bankAddress1}
    ${bankAddress2}   FakerLibrary.Street name
    Set Suite Variable    ${bankAddress2}

    ${resp}=    Update Partner loan Bank Details    ${originFrom[2]}    ${loanuid}    ${loanuid}    ${bankName}    ${AccountNumber}    ${bankIfsc1}    ${bankAddress1}    ${bankAddress2}    ${bankCity1}    ${bankState1}   ${bankPin}    ${bankStatementAttachments2}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get Partner loan Bank Details    ${loanuid}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable    ${kyid}    ${resp.json()['id']}

    ${resp}=    Verify Partner loan Bank   ${loanuid}    ${bankName}    ${AccountNumber}    ${bankIfsc1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    
    ${nomineeName}    FakerLibrary.name
    Set Suite Variable    ${nomineeName}
    ${guarantorName1}    FakerLibrary.name
    Set Suite Variable    ${guarantorName1}
    ${partner}=       Create Dictionary    id=${Pid1} 
    Set Suite Variable    ${partner}
    ${category}=       Create Dictionary    id=${categoryid}  
    Set Suite Variable    ${category}
    ${type}=           Create Dictionary    id=${typeid} 
    Set Suite Variable    ${type}

    ${loanProducts}=    Create Dictionary    id=${Productid}  categoryId=${categoryid}    typeId=${typeid}
    ${loanProducts}=    Create List    ${loanProducts}
    Set Suite Variable    ${loanProducts}

    ${loanScheme}=     Create Dictionary    id=${Schemeid1}  name=${Schemename1}
    ${employeeCode}=    FakerLibrary.Random Number
    Set Suite Variable    ${employeeCode}

    ${montlyIncome}    FakerLibrary.Random Number
    ${nomineedob}=  FakerLibrary.Date
    Set Suite Variable  ${nomineedob}

    ${No_Number}    Random Number 	digits=5  #fix_len=True
    ${No_Number}=    Evaluate    f'{${NO_Number}:0>7d}'
    Log  ${No_Number}
    Set Suite Variable  ${nominum}  555${NO_Number}

    ${LoanApplicationKycList}=    Create Dictionary  nomineeType=${nomineeType[1]}  nomineeName=${nomineeName}  nomineeDob=${nomineedob}  nomineePhone=${nominum}  customerEducation=${customerEducation1}  customerEmployement=${customerEmployement1}  salaryRouting=${salaryRouting1}  familyDependants=${familyDependants1}  earningMembers=${earningMembers1}  existingCustomer=${existingCustomer1}  noOfYearsAtPresentAddress=${noOfYearsAtPresentAddress1}  currentResidenceOwnershipStatus=${currentResidenceOwnershipStatus1}  ownedMovableAssets=${ownedMovableAssets1}  vehicleNo=${vehicleNo1}  goodsFinanced=${goodsFinanced1}  guarantorName=${guarantorName1}  guarantorType=${nomineeType[1]}  id=${kyid}
    Log  ${LoanApplicationKycList}
    Set Suite Variable    ${LoanApplicationKycList}

    ${resp}=    Verify Partner loan Bank Details     ${loanuid}  ${loanProducts}  ${category}  ${type}   ${loanproductcatid[0]}   ${loanproductSubcatid}  ${partner}  ${invoiceAmount}  ${downpaymentAmount}  ${requestedAmount}  ${emiPaidAmountMonthly}  ${bool[1]}  ${employeeCode}  ${loanid}  ${LoanApplicationKycList}      
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


JD-TC-Partner Verify Loan Application Details-2
                                  
    [Documentation]              Partner Verify Loan Application Details where loan category empty

    ${resp}=    Login Partner with Password    ${account_id}  ${P_phone}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    
    ${emptycategory}=       Create Dictionary    id=${empty}  
    Set Suite Variable    ${emptycategory}

    ${resp}=    Verify Partner loan Bank Details     ${loanuid}  ${loanProducts}  ${emptycategory}  ${type}   ${loanproductcatid[0]}   ${loanproductSubcatid}  ${partner}  ${invoiceAmount}  ${downpaymentAmount}  ${requestedAmount}  ${emiPaidAmountMonthly}  ${bool[1]}  ${employeeCode}  ${loanid}  ${LoanApplicationKycList}      
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200




JD-TC-Partner Verify Loan Application Details-3
                                  
    [Documentation]              Partner Verify Loan Application Details where loan type empty

    ${resp}=    Login Partner with Password    ${account_id}  ${P_phone}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    
    ${emptytype}=           Create Dictionary    id=${empty} 
    Set Suite Variable    ${emptytype}

    ${resp}=    Verify Partner loan Bank Details     ${loanuid}  ${loanProducts}  ${category}  ${emptytype}   ${loanproductcatid[0]}   ${loanproductSubcatid}  ${partner}  ${invoiceAmount}  ${downpaymentAmount}  ${requestedAmount}  ${emiPaidAmountMonthly}  ${bool[1]}  ${employeeCode}  ${loanid}  ${LoanApplicationKycList}      
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200



JD-TC-Partner Verify Loan Application Details-4
                                  
    [Documentation]              Partner Verify Loan Application Details where loan product category id empty

    ${resp}=    Login Partner with Password    ${account_id}  ${P_phone}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    
    ${resp}=    Verify Partner loan Bank Details     ${loanuid}  ${loanProducts}  ${category}  ${type}   ${empty}   ${loanproductSubcatid}  ${partner}  ${invoiceAmount}  ${downpaymentAmount}  ${requestedAmount}  ${emiPaidAmountMonthly}  ${bool[1]}  ${employeeCode}  ${loanid}  ${LoanApplicationKycList}      
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200



JD-TC-Partner Verify Loan Application Details-5
                                  
    [Documentation]              Partner Verify Loan Application Details where loan product Subcategory id empty

    ${resp}=    Login Partner with Password    ${account_id}  ${P_phone}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    
    ${resp}=    Verify Partner loan Bank Details     ${loanuid}  ${loanProducts}  ${category}  ${type}   ${loanproductcatid[0]}   ${empty}  ${partner}  ${invoiceAmount}  ${downpaymentAmount}  ${requestedAmount}  ${emiPaidAmountMonthly}  ${bool[1]}  ${employeeCode}  ${loanid}  ${LoanApplicationKycList}      
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200



JD-TC-Partner Verify Loan Application Details-6
                                  
    [Documentation]              Partner Verify Loan Application Details where emi Paid Amount Monthly empty

    ${resp}=    Login Partner with Password    ${account_id}  ${P_phone}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    
    ${resp}=    Verify Partner loan Bank Details     ${loanuid}  ${loanProducts}  ${category}  ${type}   ${loanproductcatid[0]}   ${loanproductSubcatid}  ${partner}  ${invoiceAmount}  ${downpaymentAmount}  ${requestedAmount}  ${empty}  ${bool[1]}  ${employeeCode}  ${loanid}  ${LoanApplicationKycList}      
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


JD-TC-Partner Verify Loan Application Details-7
                                  
    [Documentation]              Partner Verify Loan Application Details where office employee empty

    ${resp}=    Login Partner with Password    ${account_id}  ${P_phone}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    
    ${resp}=    Verify Partner loan Bank Details     ${loanuid}  ${loanProducts}  ${category}  ${type}   ${loanproductcatid[0]}   ${loanproductSubcatid}  ${partner}  ${invoiceAmount}  ${downpaymentAmount}  ${requestedAmount}  ${emiPaidAmountMonthly}  ${empty}  ${employeeCode}  ${loanid}  ${LoanApplicationKycList}      
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200



JD-TC-Partner Verify Loan Application Details-8
                                  
    [Documentation]              Partner Verify Loan Application Details where employee false and employee code empty

    ${resp}=    Login Partner with Password    ${account_id}  ${P_phone}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    
    ${resp}=    Verify Partner loan Bank Details     ${loanuid}  ${loanProducts}  ${category}  ${type}   ${loanproductcatid[0]}   ${loanproductSubcatid}  ${partner}  ${invoiceAmount}  ${downpaymentAmount}  ${requestedAmount}  ${emiPaidAmountMonthly}  ${bool[0]}  ${empty}  ${loanid}  ${LoanApplicationKycList}      
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


JD-TC-Partner Verify Loan Application Details-9
                                  
    [Documentation]              Partner Verify Loan Application Details where employee True and employee code empty

    ${resp}=    Login Partner with Password    ${account_id}  ${P_phone}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    
    ${resp}=    Verify Partner loan Bank Details     ${loanuid}  ${loanProducts}  ${category}  ${type}   ${loanproductcatid[0]}   ${loanproductSubcatid}  ${partner}  ${invoiceAmount}  ${downpaymentAmount}  ${requestedAmount}  ${emiPaidAmountMonthly}  ${bool[1]}  ${empty}  ${loanid}  ${LoanApplicationKycList}      
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


JD-TC-Partner Verify Loan Application Details-10
                                  
    [Documentation]              Partner Verify Loan Application Details where kyc list vehicle No  is empty

    ${resp}=    Login Partner with Password    ${account_id}  ${P_phone}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    
    ${LoanApplicationKycList1}=    Create Dictionary  nomineeType=${nomineeType[1]}  nomineeName=${nomineeName}  nomineeDob=${nomineedob}  nomineePhone=${nominum}  customerEducation=${customerEducation1}  customerEmployement=${customerEmployement1}  salaryRouting=${salaryRouting1}  familyDependants=${familyDependants1}  earningMembers=${earningMembers1}  existingCustomer=${existingCustomer1}  noOfYearsAtPresentAddress=${noOfYearsAtPresentAddress1}  currentResidenceOwnershipStatus=${currentResidenceOwnershipStatus1}  ownedMovableAssets=${ownedMovableAssets1}  vehicleNo=${empty}  goodsFinanced=${goodsFinanced1}  guarantorName=${guarantorName1}  guarantorType=${nomineeType[1]}  id=${kyid}
    Log  ${LoanApplicationKycList1}

    ${resp}=    Verify Partner loan Bank Details     ${loanuid}  ${loanProducts}  ${category}  ${type}   ${loanproductcatid[0]}   ${loanproductSubcatid}  ${partner}  ${invoiceAmount}  ${downpaymentAmount}  ${requestedAmount}  ${emiPaidAmountMonthly}  ${bool[1]}  ${employeeCode}  ${loanid}  ${LoanApplicationKycList1}      
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


JD-TC-Partner Verify Loan Application Details-11
                                  
    [Documentation]              Partner Verify Loan Application Details where kyc list guarantor Name  is empty

    ${resp}=    Login Partner with Password    ${account_id}  ${P_phone}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    
    ${LoanApplicationKycList1}=    Create Dictionary  nomineeType=${nomineeType[1]}  nomineeName=${nomineeName}  nomineeDob=${nomineedob}  nomineePhone=${nominum}  customerEducation=${customerEducation1}  customerEmployement=${customerEmployement1}  salaryRouting=${salaryRouting1}  familyDependants=${familyDependants1}  earningMembers=${earningMembers1}  existingCustomer=${existingCustomer1}  noOfYearsAtPresentAddress=${noOfYearsAtPresentAddress1}  currentResidenceOwnershipStatus=${currentResidenceOwnershipStatus1}  ownedMovableAssets=${ownedMovableAssets1}  vehicleNo=${vehicleNo1}  goodsFinanced=${goodsFinanced1}  guarantorName=${empty}  guarantorType=${nomineeType[1]}  id=${kyid}
    Log  ${LoanApplicationKycList1}

    ${resp}=    Verify Partner loan Bank Details     ${loanuid}  ${loanProducts}  ${category}  ${type}   ${loanproductcatid[0]}   ${loanproductSubcatid}  ${partner}  ${invoiceAmount}  ${downpaymentAmount}  ${requestedAmount}  ${emiPaidAmountMonthly}  ${bool[1]}  ${employeeCode}  ${loanid}  ${LoanApplicationKycList1}      
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


JD-TC-Partner Verify Loan Application Details-12
                                  
    [Documentation]              Partner Verify Loan Application Details where kyc list nominiee type son

    ${resp}=    Login Partner with Password    ${account_id}  ${P_phone}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    
    ${LoanApplicationKycList1}=    Create Dictionary  nomineeType=${nomineeType[3]}  nomineeName=${nomineeName}  nomineeDob=${nomineedob}  nomineePhone=${nominum}  customerEducation=${customerEducation1}  customerEmployement=${customerEmployement1}  salaryRouting=${salaryRouting1}  familyDependants=${familyDependants1}  earningMembers=${earningMembers1}  existingCustomer=${existingCustomer1}  noOfYearsAtPresentAddress=${noOfYearsAtPresentAddress1}  currentResidenceOwnershipStatus=${currentResidenceOwnershipStatus1}  ownedMovableAssets=${ownedMovableAssets1}  vehicleNo=${vehicleNo1}  goodsFinanced=${goodsFinanced1}  guarantorName=${guarantorName1}  guarantorType=${nomineeType[1]}  id=${kyid}
    Log  ${LoanApplicationKycList1}

    ${resp}=    Verify Partner loan Bank Details     ${loanuid}  ${loanProducts}  ${category}  ${type}   ${loanproductcatid[0]}   ${loanproductSubcatid}  ${partner}  ${invoiceAmount}  ${downpaymentAmount}  ${requestedAmount}  ${emiPaidAmountMonthly}  ${bool[1]}  ${employeeCode}  ${loanid}  ${LoanApplicationKycList1}      
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


JD-TC-Partner Verify Loan Application Details-13
                                  
    [Documentation]              Partner Verify Loan Application Details where kyc list guarantor Type  is son

    ${resp}=    Login Partner with Password    ${account_id}  ${P_phone}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    
    ${LoanApplicationKycList1}=    Create Dictionary  nomineeType=${nomineeType[1]}  nomineeName=${nomineeName}  nomineeDob=${nomineedob}  nomineePhone=${nominum}  customerEducation=${customerEducation1}  customerEmployement=${customerEmployement1}  salaryRouting=${salaryRouting1}  familyDependants=${familyDependants1}  earningMembers=${earningMembers1}  existingCustomer=${existingCustomer1}  noOfYearsAtPresentAddress=${noOfYearsAtPresentAddress1}  currentResidenceOwnershipStatus=${currentResidenceOwnershipStatus1}  ownedMovableAssets=${ownedMovableAssets1}  vehicleNo=${vehicleNo1}  goodsFinanced=${goodsFinanced1}  guarantorName=${guarantorName1}  guarantorType=${nomineeType[3]}  id=${kyid}
    Log  ${LoanApplicationKycList1}

    ${resp}=    Verify Partner loan Bank Details     ${loanuid}  ${loanProducts}  ${category}  ${type}   ${loanproductcatid[0]}   ${loanproductSubcatid}  ${partner}  ${invoiceAmount}  ${downpaymentAmount}  ${requestedAmount}  ${emiPaidAmountMonthly}  ${bool[1]}  ${employeeCode}  ${loanid}  ${LoanApplicationKycList1}      
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


JD-TC-Partner Verify Loan Application Details-UH1
                                  
    [Documentation]              Partner Verify Loan Application Details with invalid loan uid

    ${resp}=    Login Partner with Password    ${account_id}  ${P_phone}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${invloan}=    FakerLibrary.Random Number
    
    ${resp}=    Verify Partner loan Bank Details     ${invloan}  ${loanProducts}  ${category}  ${type}   ${loanproductcatid[0]}   ${loanproductSubcatid}  ${partner}  ${invoiceAmount}  ${downpaymentAmount}  ${requestedAmount}  ${emiPaidAmountMonthly}  ${bool[1]}  ${employeeCode}  ${loanid}  ${LoanApplicationKycList}      
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${INVOICE_AMOUNT_REQUIRED}



JD-TC-Partner Verify Loan Application Details-UH2
                                  
    [Documentation]              Partner Verify Loan Application Details where loan products empty

    ${resp}=    Login Partner with Password    ${account_id}  ${P_phone}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    
    ${loanProductsempty}=    Create Dictionary    id=${empty}  categoryId=${empty}    typeId=${empty}
    ${loanProductsempty}=    Create List    ${loanProductsempty}
    Set Suite Variable    ${loanProductsempty}

    ${resp}=    Verify Partner loan Bank Details     ${loanuid}  ${loanProductsempty}  ${category}  ${type}   ${loanproductcatid[0]}   ${loanproductSubcatid}  ${partner}  ${invoiceAmount}  ${downpaymentAmount}  ${requestedAmount}  ${emiPaidAmountMonthly}  ${bool[1]}  ${employeeCode}  ${loanid}  ${LoanApplicationKycList}      
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${LOAN_PRODUCT_REQUIRED}



JD-TC-Partner Verify Loan Application Details-UH3
                                  
    [Documentation]              Partner Verify Loan Application Details where partner empty

    ${resp}=    Login Partner with Password    ${account_id}  ${P_phone}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    
    ${emptypartner}=       Create Dictionary    id=${Pid1} 
    Set Suite Variable    ${emptypartner}

    ${resp}=    Verify Partner loan Bank Details     ${loanuid}  ${loanProducts}  ${category}  ${type}   ${loanproductcatid[0]}   ${loanproductSubcatid}  ${emptypartner}  ${invoiceAmount}  ${downpaymentAmount}  ${requestedAmount}  ${emiPaidAmountMonthly}  ${bool[1]}  ${employeeCode}  ${loanid}  ${LoanApplicationKycList}      
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${INVOICE_AMOUNT_REQUIRED}



JD-TC-Partner Verify Loan Application Details-UH4
                                  
    [Documentation]              Partner Verify Loan Application Details where invoice Amount empty

    ${resp}=    Login Partner with Password    ${account_id}  ${P_phone}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    
    ${resp}=    Verify Partner loan Bank Details     ${loanuid}  ${loanProducts}  ${category}  ${type}   ${loanproductcatid[0]}   ${loanproductSubcatid}  ${partner}  ${empty}  ${downpaymentAmount}  ${requestedAmount}  ${emiPaidAmountMonthly}  ${bool[1]}  ${employeeCode}  ${loanid}  ${LoanApplicationKycList}      
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${INVOICE_AMOUNT_REQUIRED}
    

JD-TC-Partner Verify Loan Application Details-UH5
                                  
    [Documentation]              Partner Verify Loan Application Details where downpayment Amount empty

    ${resp}=    Login Partner with Password    ${account_id}  ${P_phone}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    
    ${resp}=    Verify Partner loan Bank Details     ${loanuid}  ${loanProducts}  ${category}  ${type}   ${loanproductcatid[0]}   ${loanproductSubcatid}  ${partner}  ${invoiceAmount}  ${empty}  ${requestedAmount}  ${emiPaidAmountMonthly}  ${bool[1]}  ${employeeCode}  ${loanid}  ${LoanApplicationKycList}      
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${INVALID_LOAN_REQUESTED_AMOUNT}



JD-TC-Partner Verify Loan Application Details-UH6
                                  
    [Documentation]              Partner Verify Loan Application Details where requested Amount empty

    ${resp}=    Login Partner with Password    ${account_id}  ${P_phone}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    
    ${resp}=    Verify Partner loan Bank Details     ${loanuid}  ${loanProducts}  ${category}  ${type}   ${loanproductcatid[0]}   ${loanproductSubcatid}  ${partner}  ${invoiceAmount}  ${downpaymentAmount}  ${empty}  ${emiPaidAmountMonthly}  ${bool[1]}  ${employeeCode}  ${loanid}  ${LoanApplicationKycList}      
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${REQUESTED_AMOUNT_REQUIRED}



JD-TC-Partner Verify Loan Application Details-UH7
                                  
    [Documentation]              Partner Verify Loan Application Details where loan id empty

    ${resp}=    Login Partner with Password    ${account_id}  ${P_phone}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    
    ${resp}=    Verify Partner loan Bank Details     ${loanuid}  ${loanProducts}  ${category}  ${type}   ${loanproductcatid[0]}   ${loanproductSubcatid}  ${partner}  ${invoiceAmount}  ${downpaymentAmount}  ${requestedAmount}  ${emiPaidAmountMonthly}  ${bool[1]}  ${employeeCode}  ${empty}  ${LoanApplicationKycList}      
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${INV_LOAN_APPLICATION_ID}



JD-TC-Partner Verify Loan Application Details-UH8
                                  
    [Documentation]              Partner Verify Loan Application Details where kyc list nominee name is empty

    ${resp}=    Login Partner with Password    ${account_id}  ${P_phone}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    
    ${LoanApplicationKycList1}=    Create Dictionary  nomineeType=${nomineeType[1]}  nomineeName=${empty}  nomineeDob=${nomineedob}  nomineePhone=${nominum}  customerEducation=${customerEducation1}  customerEmployement=${customerEmployement1}  salaryRouting=${salaryRouting1}  familyDependants=${familyDependants1}  earningMembers=${earningMembers1}  existingCustomer=${existingCustomer1}  noOfYearsAtPresentAddress=${noOfYearsAtPresentAddress1}  currentResidenceOwnershipStatus=${currentResidenceOwnershipStatus1}  ownedMovableAssets=${ownedMovableAssets1}  vehicleNo=${vehicleNo1}  goodsFinanced=${goodsFinanced1}  guarantorName=${guarantorName1}  guarantorType=${nomineeType[1]}  id=${kyid}
    Log  ${LoanApplicationKycList1}

    ${resp}=    Verify Partner loan Bank Details     ${loanuid}  ${loanProducts}  ${category}  ${type}   ${loanproductcatid[0]}   ${loanproductSubcatid}  ${partner}  ${invoiceAmount}  ${downpaymentAmount}  ${requestedAmount}  ${emiPaidAmountMonthly}  ${bool[1]}  ${employeeCode}  ${loanid}  ${LoanApplicationKycList1}      
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${NOMINEE_NAME_REQUIRED}


JD-TC-Partner Verify Loan Application Details-UH9
                                  
    [Documentation]              Partner Verify Loan Application Details where kyc list nominee dob is empty

    ${resp}=    Login Partner with Password    ${account_id}  ${P_phone}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    
    ${LoanApplicationKycList1}=    Create Dictionary  nomineeType=${nomineeType[1]}  nomineeName=${nomineeName}  nomineeDob=${empty}  nomineePhone=${nominum}  customerEducation=${customerEducation1}  customerEmployement=${customerEmployement1}  salaryRouting=${salaryRouting1}  familyDependants=${familyDependants1}  earningMembers=${earningMembers1}  existingCustomer=${existingCustomer1}  noOfYearsAtPresentAddress=${noOfYearsAtPresentAddress1}  currentResidenceOwnershipStatus=${currentResidenceOwnershipStatus1}  ownedMovableAssets=${ownedMovableAssets1}  vehicleNo=${vehicleNo1}  goodsFinanced=${goodsFinanced1}  guarantorName=${guarantorName1}  guarantorType=${nomineeType[1]}  id=${kyid}
    Log  ${LoanApplicationKycList1}

    ${resp}=    Verify Partner loan Bank Details     ${loanuid}  ${loanProducts}  ${category}  ${type}   ${loanproductcatid[0]}   ${loanproductSubcatid}  ${partner}  ${invoiceAmount}  ${downpaymentAmount}  ${requestedAmount}  ${emiPaidAmountMonthly}  ${bool[1]}  ${employeeCode}  ${loanid}  ${LoanApplicationKycList1}      
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${KYC_NOMINEE_DOB_REQUIRED}



JD-TC-Partner Verify Loan Application Details-UH10
                                  
    [Documentation]              Partner Verify Loan Application Details where kyc list nominee phone is empty

    ${resp}=    Login Partner with Password    ${account_id}  ${P_phone}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    
    ${LoanApplicationKycList1}=    Create Dictionary  nomineeType=${nomineeType[1]}  nomineeName=${nomineeName}  nomineeDob=${nomineedob}  nomineePhone=${empty}  customerEducation=${customerEducation1}  customerEmployement=${customerEmployement1}  salaryRouting=${salaryRouting1}  familyDependants=${familyDependants1}  earningMembers=${earningMembers1}  existingCustomer=${existingCustomer1}  noOfYearsAtPresentAddress=${noOfYearsAtPresentAddress1}  currentResidenceOwnershipStatus=${currentResidenceOwnershipStatus1}  ownedMovableAssets=${ownedMovableAssets1}  vehicleNo=${vehicleNo1}  goodsFinanced=${goodsFinanced1}  guarantorName=${guarantorName1}  guarantorType=${nomineeType[1]}  id=${kyid}
    Log  ${LoanApplicationKycList1}

    ${resp}=    Verify Partner loan Bank Details     ${loanuid}  ${loanProducts}  ${category}  ${type}   ${loanproductcatid[0]}   ${loanproductSubcatid}  ${partner}  ${invoiceAmount}  ${downpaymentAmount}  ${requestedAmount}  ${emiPaidAmountMonthly}  ${bool[1]}  ${employeeCode}  ${loanid}  ${LoanApplicationKycList1}      
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${KYC_NOMINEE_PHONE_REQUIRED}


JD-TC-Partner Verify Loan Application Details-UH11
                                  
    [Documentation]              Partner Verify Loan Application Details where kyc list Customer Education is empty

    ${resp}=    Login Partner with Password    ${account_id}  ${P_phone}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    
    ${LoanApplicationKycList1}=    Create Dictionary  nomineeType=${nomineeType[1]}  nomineeName=${nomineeName}  nomineeDob=${nomineedob}  nomineePhone=${nominum}  customerEducation=${empty}  customerEmployement=${customerEmployement1}  salaryRouting=${salaryRouting1}  familyDependants=${familyDependants1}  earningMembers=${earningMembers1}  existingCustomer=${existingCustomer1}  noOfYearsAtPresentAddress=${noOfYearsAtPresentAddress1}  currentResidenceOwnershipStatus=${currentResidenceOwnershipStatus1}  ownedMovableAssets=${ownedMovableAssets1}  vehicleNo=${vehicleNo1}  goodsFinanced=${goodsFinanced1}  guarantorName=${guarantorName1}  guarantorType=${nomineeType[1]}  id=${kyid}
    Log  ${LoanApplicationKycList1}

    ${resp}=    Verify Partner loan Bank Details     ${loanuid}  ${loanProducts}  ${category}  ${type}   ${loanproductcatid[0]}   ${loanproductSubcatid}  ${partner}  ${invoiceAmount}  ${downpaymentAmount}  ${requestedAmount}  ${emiPaidAmountMonthly}  ${bool[1]}  ${employeeCode}  ${loanid}  ${LoanApplicationKycList1}      
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${CUSTOMER_EDUCATION}


JD-TC-Partner Verify Loan Application Details-UH12
                                  
    [Documentation]              Partner Verify Loan Application Details where kyc list customer Employement is empty

    ${resp}=    Login Partner with Password    ${account_id}  ${P_phone}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    
    ${LoanApplicationKycList1}=    Create Dictionary  nomineeType=${nomineeType[1]}  nomineeName=${nomineeName}  nomineeDob=${nomineedob}  nomineePhone=${nominum}  customerEducation=${customerEducation1}  customerEmployement=${empty}  salaryRouting=${salaryRouting1}  familyDependants=${familyDependants1}  earningMembers=${earningMembers1}  existingCustomer=${existingCustomer1}  noOfYearsAtPresentAddress=${noOfYearsAtPresentAddress1}  currentResidenceOwnershipStatus=${currentResidenceOwnershipStatus1}  ownedMovableAssets=${ownedMovableAssets1}  vehicleNo=${vehicleNo1}  goodsFinanced=${goodsFinanced1}  guarantorName=${guarantorName1}  guarantorType=${nomineeType[1]}  id=${kyid}
    Log  ${LoanApplicationKycList1}

    ${resp}=    Verify Partner loan Bank Details     ${loanuid}  ${loanProducts}  ${category}  ${type}   ${loanproductcatid[0]}   ${loanproductSubcatid}  ${partner}  ${invoiceAmount}  ${downpaymentAmount}  ${requestedAmount}  ${emiPaidAmountMonthly}  ${bool[1]}  ${employeeCode}  ${loanid}  ${LoanApplicationKycList1}      
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${CUSTOMER_EMPLOYEMENT}


JD-TC-Partner Verify Loan Application Details-UH13
                                  
    [Documentation]              Partner Verify Loan Application Details where kyc list salary Routing is empty

    ${resp}=    Login Partner with Password    ${account_id}  ${P_phone}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    
    ${LoanApplicationKycList1}=    Create Dictionary  nomineeType=${nomineeType[1]}  nomineeName=${nomineeName}  nomineeDob=${nomineedob}  nomineePhone=${nominum}  customerEducation=${customerEducation1}  customerEmployement=${customerEmployement1}  salaryRouting=${empty}  familyDependants=${familyDependants1}  earningMembers=${earningMembers1}  existingCustomer=${existingCustomer1}  noOfYearsAtPresentAddress=${noOfYearsAtPresentAddress1}  currentResidenceOwnershipStatus=${currentResidenceOwnershipStatus1}  ownedMovableAssets=${ownedMovableAssets1}  vehicleNo=${vehicleNo1}  goodsFinanced=${goodsFinanced1}  guarantorName=${guarantorName1}  guarantorType=${nomineeType[1]}  id=${kyid}
    Log  ${LoanApplicationKycList1}

    ${resp}=    Verify Partner loan Bank Details     ${loanuid}  ${loanProducts}  ${category}  ${type}   ${loanproductcatid[0]}   ${loanproductSubcatid}  ${partner}  ${invoiceAmount}  ${downpaymentAmount}  ${requestedAmount}  ${emiPaidAmountMonthly}  ${bool[1]}  ${employeeCode}  ${loanid}  ${LoanApplicationKycList1}      
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${SALARY_ROUTING}


JD-TC-Partner Verify Loan Application Details-UH14
                                  
    [Documentation]              Partner Verify Loan Application Details where kyc list family Dependants is empty

    ${resp}=    Login Partner with Password    ${account_id}  ${P_phone}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    
    ${LoanApplicationKycList1}=    Create Dictionary  nomineeType=${nomineeType[1]}  nomineeName=${nomineeName}  nomineeDob=${nomineedob}  nomineePhone=${nominum}  customerEducation=${customerEducation1}  customerEmployement=${customerEmployement1}  salaryRouting=${salaryRouting1}  familyDependants=${empty}  earningMembers=${earningMembers1}  existingCustomer=${existingCustomer1}  noOfYearsAtPresentAddress=${noOfYearsAtPresentAddress1}  currentResidenceOwnershipStatus=${currentResidenceOwnershipStatus1}  ownedMovableAssets=${ownedMovableAssets1}  vehicleNo=${vehicleNo1}  goodsFinanced=${goodsFinanced1}  guarantorName=${guarantorName1}  guarantorType=${nomineeType[1]}  id=${kyid}
    Log  ${LoanApplicationKycList1}

    ${resp}=    Verify Partner loan Bank Details     ${loanuid}  ${loanProducts}  ${category}  ${type}   ${loanproductcatid[0]}   ${loanproductSubcatid}  ${partner}  ${invoiceAmount}  ${downpaymentAmount}  ${requestedAmount}  ${emiPaidAmountMonthly}  ${bool[1]}  ${employeeCode}  ${loanid}  ${LoanApplicationKycList1}      
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${FAMILY_DEPENDANTS}


JD-TC-Partner Verify Loan Application Details-UH15
                                  
    [Documentation]              Partner Verify Loan Application Details where kyc list earning Members is empty

    ${resp}=    Login Partner with Password    ${account_id}  ${P_phone}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    
    ${LoanApplicationKycList1}=    Create Dictionary  nomineeType=${nomineeType[1]}  nomineeName=${nomineeName}  nomineeDob=${nomineedob}  nomineePhone=${nominum}  customerEducation=${customerEducation1}  customerEmployement=${customerEmployement1}  salaryRouting=${salaryRouting1}  familyDependants=${familyDependants1}  earningMembers=${empty}  existingCustomer=${existingCustomer1}  noOfYearsAtPresentAddress=${noOfYearsAtPresentAddress1}  currentResidenceOwnershipStatus=${currentResidenceOwnershipStatus1}  ownedMovableAssets=${ownedMovableAssets1}  vehicleNo=${vehicleNo1}  goodsFinanced=${goodsFinanced1}  guarantorName=${guarantorName1}  guarantorType=${nomineeType[1]}  id=${kyid}
    Log  ${LoanApplicationKycList1}

    ${resp}=    Verify Partner loan Bank Details     ${loanuid}  ${loanProducts}  ${category}  ${type}   ${loanproductcatid[0]}   ${loanproductSubcatid}  ${partner}  ${invoiceAmount}  ${downpaymentAmount}  ${requestedAmount}  ${emiPaidAmountMonthly}  ${bool[1]}  ${employeeCode}  ${loanid}  ${LoanApplicationKycList1}      
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${EARNING_MEMBERS}


JD-TC-Partner Verify Loan Application Details-UH16
                                  
    [Documentation]              Partner Verify Loan Application Details where kyc list existing Customer is empty

    ${resp}=    Login Partner with Password    ${account_id}  ${P_phone}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    
    ${LoanApplicationKycList1}=    Create Dictionary  nomineeType=${nomineeType[1]}  nomineeName=${nomineeName}  nomineeDob=${nomineedob}  nomineePhone=${nominum}  customerEducation=${customerEducation1}  customerEmployement=${customerEmployement1}  salaryRouting=${salaryRouting1}  familyDependants=${familyDependants1}  earningMembers=${earningMembers1}  existingCustomer=${empty}  noOfYearsAtPresentAddress=${noOfYearsAtPresentAddress1}  currentResidenceOwnershipStatus=${currentResidenceOwnershipStatus1}  ownedMovableAssets=${ownedMovableAssets1}  vehicleNo=${vehicleNo1}  goodsFinanced=${goodsFinanced1}  guarantorName=${guarantorName1}  guarantorType=${nomineeType[1]}  id=${kyid}
    Log  ${LoanApplicationKycList1}

    ${resp}=    Verify Partner loan Bank Details     ${loanuid}  ${loanProducts}  ${category}  ${type}   ${loanproductcatid[0]}   ${loanproductSubcatid}  ${partner}  ${invoiceAmount}  ${downpaymentAmount}  ${requestedAmount}  ${emiPaidAmountMonthly}  ${bool[1]}  ${employeeCode}  ${loanid}  ${LoanApplicationKycList1}      
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${EXISTING_CUSTOMER}


JD-TC-Partner Verify Loan Application Details-UH17
                                  
    [Documentation]              Partner Verify Loan Application Details where kyc list no Of Years At Present Address  is empty

    ${resp}=    Login Partner with Password    ${account_id}  ${P_phone}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    
    ${LoanApplicationKycList1}=    Create Dictionary  nomineeType=${nomineeType[1]}  nomineeName=${nomineeName}  nomineeDob=${nomineedob}  nomineePhone=${nominum}  customerEducation=${customerEducation1}  customerEmployement=${customerEmployement1}  salaryRouting=${salaryRouting1}  familyDependants=${familyDependants1}  earningMembers=${earningMembers1}  existingCustomer=${existingCustomer1}  noOfYearsAtPresentAddress=${empty}  currentResidenceOwnershipStatus=${currentResidenceOwnershipStatus1}  ownedMovableAssets=${ownedMovableAssets1}  vehicleNo=${vehicleNo1}  goodsFinanced=${goodsFinanced1}  guarantorName=${guarantorName1}  guarantorType=${nomineeType[1]}  id=${kyid}
    Log  ${LoanApplicationKycList1}

    ${resp}=    Verify Partner loan Bank Details     ${loanuid}  ${loanProducts}  ${category}  ${type}   ${loanproductcatid[0]}   ${loanproductSubcatid}  ${partner}  ${invoiceAmount}  ${downpaymentAmount}  ${requestedAmount}  ${emiPaidAmountMonthly}  ${bool[1]}  ${employeeCode}  ${loanid}  ${LoanApplicationKycList1}      
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${NO_OF_YEARS_AT_PRESENT_ADDRESS}


JD-TC-Partner Verify Loan Application Details-UH18
                                  
    [Documentation]              Partner Verify Loan Application Details where kyc list current Residence Ownership Status  is empty

    ${resp}=    Login Partner with Password    ${account_id}  ${P_phone}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    
    ${LoanApplicationKycList1}=    Create Dictionary  nomineeType=${nomineeType[1]}  nomineeName=${nomineeName}  nomineeDob=${nomineedob}  nomineePhone=${nominum}  customerEducation=${customerEducation1}  customerEmployement=${customerEmployement1}  salaryRouting=${salaryRouting1}  familyDependants=${familyDependants1}  earningMembers=${earningMembers1}  existingCustomer=${existingCustomer1}  noOfYearsAtPresentAddress=${noOfYearsAtPresentAddress1}  currentResidenceOwnershipStatus=${empty}  ownedMovableAssets=${ownedMovableAssets1}  vehicleNo=${vehicleNo1}  goodsFinanced=${goodsFinanced1}  guarantorName=${guarantorName1}  guarantorType=${nomineeType[1]}  id=${kyid}
    Log  ${LoanApplicationKycList1}

    ${resp}=    Verify Partner loan Bank Details     ${loanuid}  ${loanProducts}  ${category}  ${type}   ${loanproductcatid[0]}   ${loanproductSubcatid}  ${partner}  ${invoiceAmount}  ${downpaymentAmount}  ${requestedAmount}  ${emiPaidAmountMonthly}  ${bool[1]}  ${employeeCode}  ${loanid}  ${LoanApplicationKycList1}      
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${CURRENT_RESIDENCE_OWNERSHIP_STATUS}


JD-TC-Partner Verify Loan Application Details-UH19
                                  
    [Documentation]              Partner Verify Loan Application Details where kyc list owned Movable Assets  is empty

    ${resp}=    Login Partner with Password    ${account_id}  ${P_phone}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    
    ${LoanApplicationKycList1}=    Create Dictionary  nomineeType=${nomineeType[1]}  nomineeName=${nomineeName}  nomineeDob=${nomineedob}  nomineePhone=${nominum}  customerEducation=${customerEducation1}  customerEmployement=${customerEmployement1}  salaryRouting=${salaryRouting1}  familyDependants=${familyDependants1}  earningMembers=${earningMembers1}  existingCustomer=${existingCustomer1}  noOfYearsAtPresentAddress=${noOfYearsAtPresentAddress1}  currentResidenceOwnershipStatus=${currentResidenceOwnershipStatus1}  ownedMovableAssets=${empty}  vehicleNo=${vehicleNo1}  goodsFinanced=${goodsFinanced1}  guarantorName=${guarantorName1}  guarantorType=${nomineeType[1]}  id=${kyid}
    Log  ${LoanApplicationKycList1}

    ${resp}=    Verify Partner loan Bank Details     ${loanuid}  ${loanProducts}  ${category}  ${type}   ${loanproductcatid[0]}   ${loanproductSubcatid}  ${partner}  ${invoiceAmount}  ${downpaymentAmount}  ${requestedAmount}  ${emiPaidAmountMonthly}  ${bool[1]}  ${employeeCode}  ${loanid}  ${LoanApplicationKycList1}      
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${OWNED_MOVABLE_ASSETS}



JD-TC-Partner Verify Loan Application Details-UH20
                                  
    [Documentation]              Partner Verify Loan Application Details where kyc list goods Financed  is empty

    ${resp}=    Login Partner with Password    ${account_id}  ${P_phone}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    
    ${LoanApplicationKycList1}=    Create Dictionary  nomineeType=${nomineeType[1]}  nomineeName=${nomineeName}  nomineeDob=${nomineedob}  nomineePhone=${nominum}  customerEducation=${customerEducation1}  customerEmployement=${customerEmployement1}  salaryRouting=${salaryRouting1}  familyDependants=${familyDependants1}  earningMembers=${earningMembers1}  existingCustomer=${existingCustomer1}  noOfYearsAtPresentAddress=${noOfYearsAtPresentAddress1}  currentResidenceOwnershipStatus=${currentResidenceOwnershipStatus1}  ownedMovableAssets=${ownedMovableAssets1}  vehicleNo=${vehicleNo1}  goodsFinanced=${empty}  guarantorName=${guarantorName1}  guarantorType=${nomineeType[1]}  id=${kyid}
    Log  ${LoanApplicationKycList1}

    ${resp}=    Verify Partner loan Bank Details     ${loanuid}  ${loanProducts}  ${category}  ${type}   ${loanproductcatid[0]}   ${loanproductSubcatid}  ${partner}  ${invoiceAmount}  ${downpaymentAmount}  ${requestedAmount}  ${emiPaidAmountMonthly}  ${bool[1]}  ${employeeCode}  ${loanid}  ${LoanApplicationKycList1}      
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${GOODS_FINANCED}



JD-TC-Partner Verify Loan Application Details-UH21
                                  
    [Documentation]              Partner Verify Loan Application Details where kyc list Kyc Id  is empty

    ${resp}=    Login Partner with Password    ${account_id}  ${P_phone}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    
    ${LoanApplicationKycList1}=    Create Dictionary  nomineeType=${nomineeType[1]}  nomineeName=${nomineeName}  nomineeDob=${nomineedob}  nomineePhone=${nominum}  customerEducation=${customerEducation1}  customerEmployement=${customerEmployement1}  salaryRouting=${salaryRouting1}  familyDependants=${familyDependants1}  earningMembers=${earningMembers1}  existingCustomer=${existingCustomer1}  noOfYearsAtPresentAddress=${noOfYearsAtPresentAddress1}  currentResidenceOwnershipStatus=${currentResidenceOwnershipStatus1}  ownedMovableAssets=${ownedMovableAssets1}  vehicleNo=${vehicleNo1}  goodsFinanced=${goodsFinanced1}  guarantorName=${guarantorName1}  guarantorType=${nomineeType[1]}  id=${empty}
    Log  ${LoanApplicationKycList1}

    ${resp}=    Verify Partner loan Bank Details     ${loanuid}  ${loanProducts}  ${category}  ${type}   ${loanproductcatid[0]}   ${loanproductSubcatid}  ${partner}  ${invoiceAmount}  ${downpaymentAmount}  ${requestedAmount}  ${emiPaidAmountMonthly}  ${bool[1]}  ${employeeCode}  ${loanid}  ${LoanApplicationKycList1}      
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${INV_LOAN_APPLICATION_ID}








