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
Resource          /ebs/TDD/ProviderPartnerKeywords.robot
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


${cc}   +91
${phone}     5555512550
${aadhaar}   555555555555
${pan}       5555523145
${bankAccountNo}    5555534564
${bankIfsc}         5555566
${bankPin}       5555533

${bankAccountNo2}    5555534587
${bankIfsc2}         55555688
${bankPin2}       5555589

${invoiceAmount}    60000
${downpaymentAmount}    2000
${requestedAmount}    58000

${invoiceAmount1}    22001
${downpaymentAmount1}    2000
${requestedAmount1}    20001

${monthlyIncome}    80000
${emiPaidAmountMonthly}    2000
*** Test Cases ***

JD-TC-Loan Approval-1
                                  
    [Documentation]               Create Loan Application and Loan Approval with branch login.

    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Suite Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Suite Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    ${firstname_A}=  FakerLibrary.first_name
    Set Suite Variable  ${firstname_A}
    ${lastname_A}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname_A}
    ${MUSERNAME_E}=  Evaluate  ${MUSERNAME}+551745
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${MUSERNAME_E}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${MUSERNAME_E}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${MUSERNAME_E}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${MUSERNAME_E}${\n}
    Append To File  ${EXECDIR}/TDD/TDD_Logs/providernumbers.txt  ${SUITE NAME} - ${TEST NAME} - ${MUSERNAME_E}${\n}
    Set Suite Variable  ${MUSERNAME_E}
    ${id}=  get_id  ${MUSERNAME_E}
     Set Suite Variable  ${id}
    ${account_id}=  get_acc_id  ${MUSERNAME_E}
    Set Suite Variable  ${account_id}  

    # Set Suite Variable  ${p_id}
    ${bs}=  FakerLibrary.bs
    Set Suite Variable  ${bs}
    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    
    sleep  2s
    ${resp}=  Get Departments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+3366457
    clear_users  ${PUSERNAME_U1}
    Set Suite Variable  ${PUSERNAME_U1}
    ${firstname}=  FakerLibrary.name
    Set Suite Variable  ${firstname}
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname}
    ${dob}=  FakerLibrary.Date Of Birth   minimum_age=23   maximum_age=55
    ${dob}=  Convert To String  ${dob}
    Set Suite Variable  ${dob}
     FOR    ${i}    IN RANGE    3
        ${pin}=  get_pincode
        ${kwstatus}  ${resp} =  Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
     END
     Should Be Equal As Strings    ${resp.status_code}    200 
     Set Suite Variable  ${pin}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${city}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Suite Variable  ${state}  ${resp.json()[0]['PostOffice'][0]['State']}      
    Set Suite Variable  ${pin}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    
    

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
        Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  ${resp.json()['enableBranchMaster']}==${bool[0]}
        ${resp1}=  Enable Disable Branch    ${status[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${branchCode}=    FakerLibrary.Random Number
    ${branchName}=    FakerLibrary.name

    ${pin}  ${city}  ${district}  ${state}=  get_pin_loc

    ${state}=    Evaluate     "${state}".title()
    ${state}=    String.RemoveString  ${state}    ${SPACE}
   
    ${resp}=    Create BranchMaster    ${branchCode}    ${branchName}    ${locId}    ${status[0]}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${branchid1}  ${resp.json()['id']}

    ${resp}=    Change Branch Status    ${branchid1}    ${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Create and Update Account level cdl setting    ${bool[1]}    ${autoApprovalUptoAmount2}    ${bool[1]}    ${toggle[0]}    ${bool[1]}    ${empty}   ${bool[1]}    ${bool[1]}  demandPromissoryNoteRequired=${bool[1]}    securityPostDatedChequesRequired=${bool[1]}    loanNature=ConsumerDurableLoan
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get account level cdl setting
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    
    ${whpnum}=  Evaluate  ${PUSERNAME}+346245
    ${tlgnum}=  Evaluate  ${PUSERNAME}+346345

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[2]}  ${pin}  ${countryCodes[1]}  ${PUSERNAME_U1}  ${dep_id}  ${EMPTY}  ${bool[1]}  ${countryCodes[1]}  ${whpnum}  ${countryCodes[1]}  ${tlgnum}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id}  ${resp.json()}

    ${resp}=  Get User By Id  ${u_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   

    ${resp}=  SendProviderResetMail   ${PUSERNAME_U1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${PUSERNAME_U1}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200


   
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=  Get User By Id  ${u_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

   

    ${PUSERNAME_U3}=  Evaluate  ${PUSERNAME}+3366457
    clear_users  ${PUSERNAME_U3}
    Set Suite Variable  ${PUSERNAME_U3}
   

    ${whpnum}=  Evaluate  ${PUSERNAME}+346973
    ${tlgnum}=  Evaluate  ${PUSERNAME}+346913

  

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U3}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERNAME_U3}  ${dep_id}  ${EMPTY}  ${bool[1]}  ${countryCodes[1]}  ${whpnum}  ${countryCodes[1]}  ${tlgnum}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id3}  ${resp.json()}


    ${resp}=  Get User By Id  ${u_id3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  SendProviderResetMail   ${PUSERNAME_U3}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${PUSERNAME_U3}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U3}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${account_id}  ${resp.json()['id']}


    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME15}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME15}  firstName=${firstname}   lastName=${lastname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${pcid14}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${pcid14}  ${resp.json()[0]['id']}
    END
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME15}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable   ${custid}    ${resp.json()[0]['id']}
    Set Suite Variable   ${phoneNo}    ${resp.json()[0]['phoneNo']}
    Set Suite Variable    ${phone}   ${resp.json()[0]['phoneNo']}
    Set Suite Variable    ${cc}   ${resp.json()[0]['countryCode']}
    Set Suite Variable    ${email}  ${firstname}${C_Email}.${test_mail}

    ${resp}=  partnercategorytype   ${account_id}
    ${resp}=  partnertype       ${account_id}

    ${PH_Number}    Random Number 	digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${P_phone}  555${PH_Number}
    ${dealerfname}=  FakerLibrary.name
    ${dealerlname}=  FakerLibrary.last_name
    ${dealerAlName}=  FakerLibrary.Company
    ${dealername}=  FakerLibrary.bs

    ${resp}=  Generate Phone Partner Creation  ${P_phone}  ${countryCodes[0]}  partnerName=${dealername}   partnerUserFirstName=${dealerfname}  partnerUserLastName=${dealerlname}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${branch}=   Create Dictionary   id=${branchid1}

    ${resp}=  Verify Phone Partner Creation  ${P_phone}  ${OtpPurpose['ProviderVerifyPhone']}  ${dealername}  ${dealerAlName}  branch=${branch}  partnerUserFirstName=${dealerfname}  partnerUserLastName=${dealerlname}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${id1}  ${resp.json()['id']}
    Set Suite Variable  ${uid1}  ${resp.json()['uid']} 

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

    ${resp}    Update Partner Bank  ${bankAccountNo}  ${bankIfsc}  ${bankName}  ${uid1}  ${LoanAction[0]}  ${id1}  ${pdffile}  ${fileSize}  ${caption3}  ${fileType3}  ${order}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${gstin}  ${pan_num}=   db.Generate_gst_number   55555

    ${resp}    Validate Gst    ${uid1}     ${gstin}    
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}    Get Partner by UID     ${uid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=   Partner Approval Request    ${uid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${note}=    FakerLibrary.sentence
    Set Suite Variable    ${note}

    ${resp}=   Partner Approved    ${uid1}    ${note}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}=  categorytype   ${account_id}
    ${resp}=  tasktype       ${account_id}
    ${resp}=  loanStatus     ${account_id}
    ${resp}=  loanProducttype    ${account_id}
    ${resp}=  LoanProductCategory    ${account_id}
    ${resp}=  loanProducts    ${account_id}
    ${resp}=  loanScheme     ${account_id}

    ${resp}=    Get Loan Application Category
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${categoryid}  ${resp.json()[0]['id']}

    ${resp}=    Get Loan Application Type
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${typeid}  ${resp.json()[0]['id']}

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
    Set Suite Variable  ${Schemeid}  ${resp.json()[1]['id']}

    ${resp}=  Get Loan Application SP Internal Status   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}  Get Length  ${resp.json()}
    FOR   ${i}  IN RANGE   ${len}
        Set Suite Variable  ${sp_status_id${i}}    ${resp.json()[${i}]['id']}
        Set Suite Variable  ${sp_status_name${i}}  ${resp.json()[${i}]['name']}
    END

    ${resp}=    Generate Loan Application Otp for Phone Number    ${phone}  ${cc}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${kyc_list1}=           Create Dictionary  isCoApplicant=${bool[0]}
    
    # ${resp}=    Verify Phone Otp and Create Loan Application   ${phone}   13   ${custid}    ${firstName}    ${lastName}    ${phoneNo}    ${cc}    ${locId}    ${kyc_list1}
    ${resp}=  Verify Phone and Create Loan Application with customer details  ${phone}  ${OtpPurpose['ConsumerVerifyPhone']}  ${custid}  ${locId}  ${kyc_list1}  firstName=${firstName}  lastName=${lastName}  phoneNo=${phoneNo}  countryCode=${countryCodes[0]}  gender=${gender}  dob=${dob}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite VAriable  ${loanid}    ${resp.json()['id']}
    Set Suite VAriable  ${loanuid}    ${resp.json()['uid']}

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${kycid}     ${resp.json()["loanApplicationKycList"][0]["id"]}    

    ${resp}=    Generate Loan Application Otp for Email    ${email}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=   Verify Email Otp and Create Loan Application    ${email}    5    ${loanuid}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

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
    
    ${aadhaarAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${aadhaarAttachments}

    ${resp}=   Requst For Aadhar Validation    ${pcid14}    ${loanuid}    ${phoneNo}    ${aadhaar}    ${aadhaarAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get loan Bank Details Aadhaar    ${kycid}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${panAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${jpgfile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType1}  order=${order}
    Log  ${panAttachments}

    ${resp}=    Requst For Pan Validation    ${pcid14}    ${loanuid}    ${phoneNo}    ${pan}    ${panAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${bankName}       FakerLibrary.name
    ${bankAddress1}   FakerLibrary.Street name
    ${bankAddress2}   FakerLibrary.Street name
    ${bankCity}       FakerLibrary.word
    ${bankState}      FakerLibrary.state

    ${bankStatementAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${bankStatementAttachments}

    ${resp}=    Add loan Bank Details    4    ${loanuid}    ${loanuid}    ${bankName}    ${bankAccountNo}    ${bankIfsc}    ${bankAddress1}    ${bankAddress2}    ${bankCity}    ${bankState}   ${bankPin}    ${bankStatementAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${bankStatementAttachments2}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${bankStatementAttachments2}

    ${resp}=    Update loan Bank Details    4    ${loanuid}    ${loanuid}    ${bankName}    ${bankAccountNo2}    ${bankIfsc}    ${bankAddress1}    ${bankAddress2}    ${bankCity}    ${bankState}   ${bankPin2}    ${bankStatementAttachments2}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Verify loan Bank   ${loanuid}   ${bankAccountNo2}    ${bankIfsc} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get loan Bank Details    ${loanuid}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable    ${kyid}    ${resp.json()['id']}
    
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

    ${resp}=    Get Loan Application Status
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${statusid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${statusname}  ${resp.json()[0]['name']}

    ${resp}=    Get Loan Application Product
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${Productid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${productname}  ${resp.json()[0]['productName']}

    ${resp}=    Get Loan Application Scheme
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${Schemeid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${Schemeid1}  ${resp.json()[1]['id']}
    Set Suite Variable  ${Schemeid2}  ${resp.json()[2]['id']}
    Set Suite Variable  ${Schemename}  ${resp.json()[0]['schemeName']}    

    # ${montlyIncome}    FakerLibrary.Random Number
    # ${emiPaidAmountMonthly}    FakerLibrary.Random Number

    # ${monthlyIncome}        FakerLibrary.Random Number
    ${nomineeName}        FakerLibrary.name

    ${LoanApplicationKycList}=    Create Dictionary   id=${kyid}  employmentStatus=${employmentStatus[0]}  monthlyIncome=${monthlyIncome}  nomineeType=${nomineeType[1]}  nomineeName=${nomineeName}
    Log  ${LoanApplicationKycList}

    ${category}=       Create Dictionary    id=${categoryid}  name=${categoryname}
    ${type}=           Create Dictionary    id=${typeid}  name=${typename}
    ${loanProduct}=    Create Dictionary    id=${Productid}  categoryId=${categoryid}    typeId=${typeid}
    ${loanProduct}=    Create List    ${loanProduct}
    ${loanScheme}=     Create Dictionary    id=${Schemeid}  name=${Schemename}
    ${partner}=  Create Dictionary  id=${id1}

    ${resp}=    Verify loan Bank Details    ${loanid}  ${loanProduct}  ${category}   ${type}    ${loanScheme}    ${invoiceAmount}    ${downpaymentAmount}    ${requestedAmount}    ${monthlyIncome}    ${emiPaidAmountMonthly}    ${LoanApplicationKycList}      partner=${partner}     uid=${loanUid}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get loan Bank    ${kyid}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    # ${resp}=    Otp for Consumer Acceptance Phone    ${phoneNo}  ${email}   ${cc}
    # Log  ${resp.content}
    # # Should Be Equal As Strings     ${resp.status_code}    200
    # #ERROR....................................................................................................



    # ${resp}=    Otp for Consumer Loan Acceptance Phone    ${phoneNo}    12    ${loanuid}
    # Log  ${resp.content}
    # # Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get Loan Application With Filter    
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()[0]['id']}  ${loanid}
    Should Be Equal As Strings   ${resp.json()[0]['uid']}  ${loanUid}
    # Should Be Equal As Strings   ${resp.json()[0]['spInternalStatus']}  ${sp_status_name1}


    # ${resp}=    Change Loan Assignee        ${loanUid}    ${uid}
    # Log    ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=    Get Loan Application With Filter    
    # Log    ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings   ${resp.json()[0]['assignee']['id']}  ${uid}

    # ${resp}=  Get Loan Application SP Internal Status
    # Log  ${resp.content}
    # Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Loan Application Approval        ${loanUid}    
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${loanScheme}=     Create Dictionary    id=${Schemeid1}  

    ${resp}=    Loan Application Manual Approval        ${loanUid}    ${loanScheme}   ${invoiceAmount}    ${downpaymentAmount}    ${requestedAmount}    58000
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Loan Application With Filter    
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()[0]['spInternalStatusDisplyName']}  ${sp_status_name5}

    ${resp}=    Loan Approval       ${loanUid}    ${Schemeid2}   
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Loan Application With Filter    
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()[0]['spInternalStatus']}  ${sp_status_name5}

JD-TC-Loan Approval-2
                                  
    [Documentation]               Try to Approved a loan Two times.


    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${UNABLE_TO_CHANGE_INSTERNAL_STATUS}=   Replace String  ${UNABLE_TO_CHANGE_INSTERNAL_STATUS}  {}  ${sp_status_name5}

    ${resp}=    Loan Approval       ${loanUid}    ${Schemeid2}   
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${UNABLE_TO_CHANGE_INSTERNAL_STATUS}


JD-TC-Loan Approval-3
                                  
    [Documentation]               Manual Approval one argunemt is empty then try to approved the loan.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

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
        Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END

    ${resp}=    Generate Loan Application Otp for Phone Number    ${phone}  ${cc}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${kyc_list1}=           Create Dictionary  isCoApplicant=${bool[0]}
    
    # ${resp}=    Verify Phone Otp and Create Loan Application   ${phone}   13   ${custid}    ${firstName}    ${lastName}    ${phoneNo}    ${cc}    ${locId}    ${kyc_list1}
    ${resp}=  Verify Phone and Create Loan Application with customer details  ${phone}  ${OtpPurpose['ConsumerVerifyPhone']}  ${custid}  ${locId}  ${kyc_list1}  firstName=${firstName}  lastName=${lastName}  phoneNo=${phoneNo}  countryCode=${countryCodes[0]}  gender=${gender}  dob=${dob}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite VAriable  ${loanid1}    ${resp.json()['id']}
    Set Suite VAriable  ${loanuid1}    ${resp.json()['uid']}

    ${resp}=    Get Loan Application By uid  ${loanuid1} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${kycid}     ${resp.json()["loanApplicationKycList"][0]["id"]} 

    ${resp}=    Generate Loan Application Otp for Email    ${email}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=   Verify Email Otp and Create Loan Application    ${email}    5    ${loanuid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    
    ${aadhaarAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${aadhaarAttachments}

    ${resp}=   Requst For Aadhar Validation    ${pcid14}    ${loanuid1}    ${phoneNo}    ${aadhaar}    ${aadhaarAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get loan Bank Details Aadhaar    ${kycid}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${panAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${jpgfile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType1}  order=${order}
    Log  ${panAttachments}

    ${resp}=    Requst For Pan Validation    ${pcid14}    ${loanuid1}    ${phoneNo}    ${pan}    ${panAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${bankName}       FakerLibrary.name
    ${bankAddress1}   FakerLibrary.Street name
    ${bankAddress2}   FakerLibrary.Street name
    ${bankCity}       FakerLibrary.word
    ${bankState}      FakerLibrary.state

    ${bankStatementAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${bankStatementAttachments}

    ${resp}=    Add loan Bank Details    4    ${loanuid1}    ${loanuid1}    ${bankName}    ${bankAccountNo}    ${bankIfsc}    ${bankAddress1}    ${bankAddress2}    ${bankCity}    ${bankState}   ${bankPin}    ${bankStatementAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${bankStatementAttachments2}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${bankStatementAttachments2}

    ${resp}=    Update loan Bank Details    4    ${loanuid1}    ${loanuid1}    ${bankName}    ${bankAccountNo2}    ${bankIfsc}    ${bankAddress1}    ${bankAddress2}    ${bankCity}    ${bankState}   ${bankPin2}    ${bankStatementAttachments2}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Verify loan Bank   ${loanuid1}      ${bankAccountNo2}    ${bankIfsc}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get loan Bank Details    ${loanuid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable    ${kyid}    ${resp.json()['id']}
    
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
    Set Suite Variable  ${typename}  ${resp.json()[0]['name']}

    ${resp}=    Get Loan Application Status
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${statusid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${statusname}  ${resp.json()[0]['name']}

    ${resp}=    Get Loan Application Product
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${Productid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${productname}  ${resp.json()[0]['productName']}

    ${resp}=    Get Loan Application Scheme
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${Schemeid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${Schemeid1}  ${resp.json()[1]['id']}
    Set Suite Variable  ${Schemeid2}  ${resp.json()[2]['id']}
    Set Suite Variable  ${Schemename}  ${resp.json()[0]['schemeName']}    

    ${nomineeName}        FakerLibrary.name

    ${LoanApplicationKycList}=    Create Dictionary   id=${kyid}  employmentStatus=${employmentStatus[0]}  monthlyIncome=${monthlyIncome}  nomineeType=${nomineeType[1]}  nomineeName=${nomineeName}
    Log  ${LoanApplicationKycList}

    ${category}=       Create Dictionary    id=${categoryid}  name=${categoryname}
    ${type}=           Create Dictionary    id=${typeid}  name=${typename}
    ${loanProduct}=    Create Dictionary    id=${Productid}  categoryId=${categoryid}    typeId=${typeid}
    ${loanProduct}=    Create List    ${loanProduct}
    ${loanScheme}=     Create Dictionary    id=${Schemeid}  name=${Schemename}
    ${partner}=  Create Dictionary  id=${id1}

    ${resp}=    Verify loan Bank Details    ${loanid1}  ${loanProduct}  ${category}   ${type}    ${loanScheme}    ${invoiceAmount}    ${downpaymentAmount}    ${requestedAmount}    ${monthlyIncome}    ${emiPaidAmountMonthly}    ${LoanApplicationKycList}    partner=${partner}     uid=${loanuid}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get loan Bank    ${kyid}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    # ${resp}=    Otp for Consumer Acceptance Phone    ${phoneNo}  ${email}   ${cc}
    # Log  ${resp.content}
    # Should Be Equal As Strings     ${resp.status_code}    200
    # #ERROR....................................................................................................



    # ${resp}=    Otp for Consumer Loan Acceptance Phone    ${phoneNo}    15    ${loanuid1}
    # Log  ${resp.content}
    # # Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get Loan Application With Filter    
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()[0]['id']}  ${loanid1}
    Should Be Equal As Strings   ${resp.json()[0]['uid']}  ${loanuid1}
    # Should Be Equal As Strings   ${resp.json()[0]['spInternalStatus']}  ${sp_status_name1}

    ${resp}=    Loan Application Approval        ${loanuid1}    
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${loanScheme}=     Create Dictionary    id=${Schemeid1}  

    ${resp}=    Loan Application Manual Approval        ${loanuid1}    ${loanScheme}   ${SPACE}    ${downpaymentAmount}    ${requestedAmount}    58000
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422

    ${UNABLE_TO_CHANGE_INSTERNAL_STATUS}=   Replace String  ${UNABLE_TO_CHANGE_INSTERNAL_STATUS}  {}  ${sp_status_name3}

    ${resp}=    Loan Approval       ${loanuid1}    ${Schemeid2}   
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${UNABLE_TO_CHANGE_INSTERNAL_STATUS}


    ${resp}=    Get Loan Application With Filter    
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()[0]['spInternalStatus']}  ${sp_status_name5}


JD-TC-Loan Approval-4
                                  
    [Documentation]               Create Loan Application and try to approve with empty schemeid.


    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${loanScheme}=     Create Dictionary    id=${Schemeid1}  

    ${resp}=    Loan Application Manual Approval        ${loanuid1}    ${loanScheme}   ${invoiceAmount}    ${downpaymentAmount}    ${requestedAmount}    58000
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Loan Approval       ${loanuid1}    ${SPACE}   
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422  
    Should Be Equal As Strings    ${resp.json()}    ${INVALID_LOAN_SCHEME_ID}

    ${resp}=    Get Loan Application With Filter    
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()[0]['spInternalStatusDisplyName']}  ${sp_status_name4}

JD-TC-Loan Approval-5
                                  
    [Documentation]               Create Loan Application and try to approve with empty loanuid.


    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Loan Approval       ${SPACE}    ${Schemeid2}   
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}  ${INVALID_LOAN_APPLICATION_ID}

JD-TC-Loan Approval-6
                                  
    [Documentation]               Try to Approved a loan with user login.


    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U3}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${UNABLE_TO_CHANGE_INSTERNAL_STATUS}=   Replace String  ${UNABLE_TO_CHANGE_INSTERNAL_STATUS}  {}  ${sp_status_name3}

    ${resp}=    Loan Approval       ${loanuid1}    ${Schemeid2}   
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}  ${INVALID_LOAN_APPLICATION_ID}