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
${jpgfile2}      /ebs/TDD/small.jpg
${gif}      /ebs/TDD/sample.gif
${xlsx}      /ebs/TDD/qnr.xlsx

${order}    0
${fileSize}  0.00458

${cc}   +91
${phone}     5555555555
${aadhaar}   555555555555
${pan}       5555523145
${bankAccountNo}    5555534564
${bankIfsc}         5555566
${bankPin}       5555533

${bankAccountNo2}    5555534587
${bankIfsc2}         55555688
${bankPin2}       5555589
${montlyIncome}  50000

${invoiceAmount}    30000
${downpaymentAmount}    10000
${requestedAmount}    20000

${invoiceAmount1}    5000
${downpaymentAmount1}    1000
${requestedAmount1}    4000

${autoApprovalUptoAmount}    50000
${autoApprovalUptoAmount2}    70000

*** Test Cases ***

JD-TC-LoanApplication-1
                                  
    [Documentation]               Create Loan Application  

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME11}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${provider_id1}  ${resp.json()['id']}
    Set Test Variable   ${lic_id}   ${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=    Create and Update Account level cdl setting    ${bool[1]}    ${autoApprovalUptoAmount2}    ${bool[1]}    ${toggle[0]}    ${bool[1]}    ${empty}   ${bool[1]}    ${bool[1]}  demandPromissoryNoteRequired=${bool[1]}    securityPostDatedChequesRequired=${bool[1]}    loanNature=ConsumerDurableLoan
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get account level cdl setting
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

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

    # ${resp}=    Create and Update Account level cdl setting    ${bool[1]}    ${autoApprovalUptoAmount2}    ${bool[1]}    ${toggle[0]}    ${bool[1]}    ${empty}   ${bool[1]}    ${bool[1]}  
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        Set Suite Variable  ${locId}

        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${locname}  ${resp.json()['place']}
        Set Suite Variable  ${address1}  ${resp.json()['address']}
        ${address2}    FakerLibrary.Street name
        Set Suite Variable    ${address2}
        
    ELSE
        Set Suite Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${locname}  ${resp.json()[0]['place']}
        Set Suite Variable  ${address1}  ${resp.json()[0]['address']}
        ${address2}    FakerLibrary.Street name
        Set Suite Variable    ${address2}
    END

    clear Customer  ${PUSERNAME87}

    ${gender}=  Random Element    ${Genderlist}
    ${dob}=  FakerLibrary.Date Of Birth   minimum_age=23   maximum_age=55
    ${dob}=  Convert To String  ${dob}
    ${fname}=    FakerLibrary.firstName
    Set Suite Variable  ${fname}
    ${lname}=    FakerLibrary.lastName
    Set Suite Variable  ${lname}
    Set Suite Variable  ${email2}  ${lname}${C_Email}.${test_mail}

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
    Set Suite Variable    ${state}
    Set Suite Variable    ${district}
    Set Suite Variable    ${pin}
    
    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  ${resp.json()['enableBranchMaster']}==${bool[0]}
        ${resp1}=  Enable Disable Branch    ${status[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END
   
    ${resp}=    Create BranchMaster    ${branchCode}    ${branchName}    ${locId}    ${status[0]}    
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

    ${resp}=    Get Partner Category
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${Pcategoryid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${Pcategoryname}  ${resp.json()[0]['name']}

    ${resp}=    Get Partner Type
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${Ptypeid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${Ptypename}  ${resp.json()[0]['name']}

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

    ${branch}=      Create Dictionary   id=${branchid1}

    ${resp}=  Verify Phone Partner Creation  ${P_phone}  ${OtpPurpose['ProviderVerifyPhone']}  ${dealername}  ${dealerAlName}  branch=${branch}  partnerUserFirstName=${dealerfname}  partnerUserLastName=${dealerlname}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${Pid1}  ${resp.json()['id']}
    Set Suite Variable  ${Puid1}  ${resp.json()['uid']} 

# <<<--------------------update partner ------------------------------------------------------->>>
    ${partnerName}                FakerLibrary.name
    ${partnerAliasName}           FakerLibrary.name
    ${description}                FakerLibrary.sentence

    ${pan}    Random Number 	digits=5 
    ${pan}=    Evaluate    f'{${pan}:0>5d}'
    Log  ${pan}
    Set Suite Variable  ${pan}  55555${pan}
    ${partnerCity}    FakerLibrary.city
    ${gstin}    Random Number 	digits=5 
    ${gstin}=    Evaluate    f'{${gstin}:0>8d}'
    Log  ${gstin}
    Set Suite Variable  ${gstin}  55555${gstin}

    
    Set Test Variable  ${email}  ${P_phone}.${partnerName}.${test_mail}

    ${bankAccountNo}    Random Number 	digits=5 
    ${bankAccountNo}=    Evaluate    f'{${bankAccountNo}:0>7d}'
    Log  ${bankAccountNo}
    Set Suite Variable  ${bankAccountNo}  55555${bankAccountNo}

    ${bankIfsc}    Random Number 	digits=5 
    ${bankIfsc}=    Evaluate    f'{${bankIfsc}:0>7d}'
    Log  ${bankIfsc}
    Set Suite Variable  ${bankIfsc}  55555${bankIfsc}  

    ${bankName}     FakerLibrary.name
    Set Suite Variable    ${bankName}

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

    ${resp}=  db.getType   ${jpgfile2}
    Log  ${resp}
    ${fileType4}=  Get From Dictionary       ${resp}    ${jpgfile2}
    Set Suite Variable    ${fileType4}
    ${caption4}=  Fakerlibrary.Sentence
    Set Suite Variable    ${caption4}

    ${resp}=  db.getType   ${gif}
    Log  ${resp}
    ${fileType5}=  Get From Dictionary       ${resp}    ${gif}
    Set Suite Variable    ${fileType5}
    ${caption5}=  Fakerlibrary.Sentence
    Set Suite Variable    ${caption5}

    ${resp}=  db.getType   ${xlsx}
    Log  ${resp}
    ${fileType6}=  Get From Dictionary       ${resp}    ${xlsx}
    Set Suite Variable    ${fileType6}
    ${caption6}=  Fakerlibrary.Sentence
    Set Suite Variable    ${caption6}

    ${aadhaarAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${Pid1}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption3}  fileType=${fileType3}  order=${order}
    ${aadhaarAttachments}=    Create List  ${aadhaarAttachments}

    ${panAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${Pid1}  fileName=${pngfile}  fileSize=${fileSize}  caption=${caption2}  fileType=${fileType2}  order=${order}
    ${panAttachments}=    Create List  ${panAttachments}

    ${gstAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${Pid1}  fileName=${jpgfile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType1}  order=${order}
    ${gstAttachments}=    Create List  ${gstAttachments}

    ${licenceAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${Pid1}  fileName=${jpgfile2}  fileSize=${fileSize}  caption=${caption4}  fileType=${fileType4}  order=${order}
    ${licenceAttachments}=    Create List  ${licenceAttachments}

    ${partnerAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${Pid1}  fileName=${gif}  fileSize=${fileSize}  caption=${caption5}  fileType=${fileType5}  order=${order}
    ${partnerAttachments}=    Create List  ${partnerAttachments}

    ${storeAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${Pid1}  fileName=${xlsx}  fileSize=${fileSize}  caption=${caption6}  fileType=${fileType6}  order=${order}
    ${storeAttachments}=    Create List  ${storeAttachments}

    ${resp}    Update Partner Aadhar    ${aadhaar}    ${Puid1}    ${LoanAction[0]}    ${Pid1}    ${pdffile}    ${fileSize}    ${caption3}    ${fileType3}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}    Get Partner by UID     ${Puid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    # ${resp}    Aadhaar Status    ${Puid1}
    # Log  ${resp.content}
    # Should Be Equal As Strings     ${resp.status_code}    200

    # ${resp}    Get Partner by UID     ${Puid1}
    # Log  ${resp.content}
    # Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}    Update Partner Pan    ${pan}    ${Puid1}    ${LoanAction[0]}    ${Pid1}    ${pdffile}    ${fileSize}    ${caption3}    ${fileType3}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}    Get Partner by UID     ${Puid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}    Update Partner Bank    ${bankAccountNo}    ${bankIfsc}    ${bankName}    ${Puid1}    ${LoanAction[0]}    ${Pid1}    ${pdffile}    ${fileSize}    ${caption3}    ${fileType3}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}    Get Partner by UID     ${Puid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}    Verify Partner Bank    ${Pid1}    ${Puid1}     ${bankAccountNo}    ${bankIfsc}     bankName=${bankName}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}    Get Partner by UID     ${Puid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}    Validate Gst    ${Puid1}     ${gstin}    
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}    Get Partner by UID     ${Puid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Partner Details    ${Puid1}    ${partnerName}    ${P_phone}    ${email}    ${description}     ${Ptypeid}    ${Pcategoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments}    ${gstAttachments}    ${licenceAttachments}    ${partnerAttachments}    ${storeAttachments}   
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}=    Get Partner by UID    ${Puid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

# <<<--------------------update partner ------------------------------------------------------->>>

    ${resp}=    Get Partner-With Filter
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    # ${bank_ac}=   db.Generate_random_value  size=6   chars=${digits}
    # Set Test Variable  ${bankAccountNo}  55555${bank_ac}

    # ${ifsc_code}=   db.Generate_ifsc_code
    # Set Test Variable  ${bankIfsc}  55555${ifsc_code}  

    # ${bank_name}=  FakerLibrary.company

    # ${resp}=  db.getType   ${pdffile} 
    # Log  ${resp}
    # ${fileType3}=  Get From Dictionary  ${resp}  ${pdffile} 
    # ${caption3}=  Fakerlibrary.Sentence

    # ${resp}    Update Partner Bank  ${bankAccountNo}  ${bankIfsc}  ${bankName}  ${Puid1}  ${LoanAction[0]}  ${Pid1}  ${pdffile}  ${fileSize}  ${caption3}  ${fileType3}  ${order}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${gstin}  ${pan_num}=   db.Generate_gst_number   55555

    # ${resp}    Validate Gst    ${Puid1}     ${gstin}    
    # Log  ${resp.content}
    # Should Be Equal As Strings     ${resp.status_code}    200

    # ${resp}    Get Partner by UID     ${Puid1}
    # Log  ${resp.content}
    # Should Be Equal As Strings     ${resp.status_code}    200

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
    
    # ${resp}=    Verify Phone Otp and Create Loan Application   ${phone}   ${OtpPurpose['ConsumerVerifyPhone']}   ${custid}    ${firstName}    ${lastName}    ${phone}    ${countryCodes[0]}    ${locId}    ${kyc_list1}
    ${resp}=  Verify Phone and Create Loan Application with customer details  ${phone}  ${OtpPurpose['ConsumerVerifyPhone']}  ${custid}  ${locId}   ${CustomerPhoto}  ${kyc_list1}  firstName=${firstName}  lastName=${lastName}  phoneNo=${phone}  countryCode=${countryCodes[0]}  gender=${gender}  dob=${dob}
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

# <----------------------------- Loan Details ------------------------------------------>

    ${emiPaidAmountMonthly}    FakerLibrary.Random Number

    ${nomineeName}        FakerLibrary.name
    ${customerOccupation}        FakerLibrary.word
    ${LoanApplicationKycList}=    Create Dictionary   id=${kycid}  employmentStatus=${employmentStatus[0]}  monthlyIncome=${montlyIncome}  nomineeType=${nomineeType[1]}  nomineeName=${nomineeName}    nomineeDob=20-10-1999   nomineePhone=5555555555
    ...  customerEducation=1    customerEmployement=1    salaryRouting=1    familyDependants=1    noOfYearsAtPresentAddress=1    currentResidenceOwnershipStatus=1    ownedMovableAssets=1  vehicleNo=KER369   goodsFinanced=1   earningMembers=1   existingCustomer=1    customerOccupation=${customerOccupation}
    Log  ${LoanApplicationKycList}

    ${category}=       Create Dictionary    id=${categoryid}  name=${categoryname}
    ${type}=           Create Dictionary    id=${typeid}  name=${typename}
    ${loanProducts}=    Create Dictionary    id=${Productid}  categoryId=${categoryid}    typeId=${typeid}
    ${loanProducts}=    Create List    ${loanProducts}
    ${loanScheme}=     Create Dictionary    id=${Schemeid}  name=${Schemename}

    ${partner}=  Create Dictionary  id=${Pid1}
    Set Suite Variable    ${partner}

    ${resp}=    Verify loan Bank Details    ${loanid}  ${loanProducts}  ${category}   ${type}    ${loanScheme}    ${invoiceAmount}    ${downpaymentAmount}    ${requestedAmount}    ${montlyIncome}    ${emiPaidAmountMonthly}    ${LoanApplicationKycList}        uid=${loanuid}   partner=${partner}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


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

    ${resp}=    Verify loan Bank   ${loanuid}    ${bankAccountNo2}    ${bankIfsc}    bankName=${bankName}
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

    ${loanScheme}=     Create Dictionary    id=${Schemeid}  
    ${loanProduct}=    Create Dictionary    id=${Productid} 
    ${resp}=    Loan Application Manual Approval        ${loanuid}    ${loanScheme}   ${invoiceAmount}    ${downpaymentAmount}    ${requestedAmount}    ${requestedAmount}    loanProduct=${loanProduct}    note=${note}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['spInternalStatus']}    ${LoanApplicationSpInternalStatus[4]}

    ${resp}=    Get Loan Application With Filter    isActionRequired-eq=${bool[0]}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()[0]['id']}  ${loanid}
    Should Be Equal As Strings   ${resp.json()[0]['uid']}  ${loanuid}
    Should Be Equal As Strings   ${resp.json()[0]['accountId']}  ${account_id}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['id']}  ${pcid14}
    Should Be Equal As Strings   ${resp.json()[0]['spInternalStatus']}  ${LoanApplicationSpInternalStatus[4]}
    Should Be Equal As Strings   ${resp.json()[0]['isActionRequired']}  ${bool[0]}

# *** comment ***

JD-TC-GetLoanApplicationwithFilter-2
                                  
    [Documentation]               Create Loan Application and get the loan with id filter.

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME11}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

# <----------------------------- Customer Details ------------------------------------------>
    ${resp}=    Get Loan Application With Filter    id-eq=${loanid}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()[0]['id']}  ${loanid}
    Should Be Equal As Strings   ${resp.json()[0]['uid']}  ${loanuid}
    Should Be Equal As Strings   ${resp.json()[0]['accountId']}  ${account_id}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['id']}  ${pcid14}
    # Should Be Equal As Strings   ${resp.json()[0]['spInternalStatus']}  ${sp_status_name0}
    # Should Be Equal As Strings   ${resp.json()[0]['assignee']['id']}  ${Productid}
    # Should Be Equal As Strings   ${resp.json()[0]['consumerPhoto'][0]['owner']}  ${pcid16}
    # Should Be Equal As Strings   ${resp.json()[0]['consumerPhoto'][0]['fileName']}  ${jpgfile}
    # Should Be Equal As Strings   ${resp.json()[0]['consumerPhoto'][0]['fileSize']}  ${fileSize}
    # Should Be Equal As Strings   ${resp.json()[0]['consumerPhoto'][0]['caption']}  ${caption1}
    # Should Be Equal As Strings   ${resp.json()[0]['consumerPhoto'][0]['fileType']}  ${fileType1}
    # Should Be Equal As Strings   ${resp.json()[0]['consumerPhoto'][0]['order']}  ${order}
    # Should Be Equal As Strings   ${resp.json()[0]['consumerPhoto'][0]['action']}  ${LoanAction[0]}

    
JD-TC-GetLoanApplicationwithFilter-3
                                  
    [Documentation]               Create Loan Application and get the loan with uid filter.

    ${resp}=   Encrypted Provider Login  ${HLMUSERNAME11}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Loan Application With Filter    uid-eq=${loanuid}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()[0]['id']}  ${loanid}
    Should Be Equal As Strings   ${resp.json()[0]['uid']}  ${loanuid}
    Should Be Equal As Strings   ${resp.json()[0]['accountId']}  ${account_id}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['id']}  ${pcid14}


JD-TC-GetLoanApplicationwithFilter-4
                                  
    [Documentation]               Create Loan Application and get the loan with customer filter.

    ${resp}=   Encrypted Provider Login  ${HLMUSERNAME11}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Loan Application With Filter    customer-eq=${pcid14}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()[0]['customer']['id']}  ${pcid14}
    Should Be Equal As Strings   ${resp.json()[0]['id']}  ${loanid}
    Should Be Equal As Strings   ${resp.json()[0]['uid']}  ${loanuid}
    Should Be Equal As Strings   ${resp.json()[0]['accountId']}  ${account_id}


JD-TC-GetLoanApplicationwithFilter-5
                                  
    [Documentation]               Create Loan Application and get the loan with customerFirstName filter.

    ${resp}=   Encrypted Provider Login  ${HLMUSERNAME11}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Loan Application With Filter    customerFirstName-eq=${fname}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()[0]['customer']['id']}  ${pcid14}
    Should Be Equal As Strings   ${resp.json()[0]['id']}  ${loanid}
    Should Be Equal As Strings   ${resp.json()[0]['uid']}  ${loanuid}
    Should Be Equal As Strings   ${resp.json()[0]['accountId']}  ${account_id}


JD-TC-GetLoanApplicationwithFilter-6
                                  
    [Documentation]               Create Loan Application and get the loan with customerLastName filter.

    ${resp}=   Encrypted Provider Login  ${HLMUSERNAME11}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Loan Application With Filter    customerLastName-eq=${lname}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()[0]['customer']['id']}  ${pcid14}
    Should Be Equal As Strings   ${resp.json()[0]['id']}  ${loanid}
    Should Be Equal As Strings   ${resp.json()[0]['uid']}  ${loanuid}
    Should Be Equal As Strings   ${resp.json()[0]['accountId']}  ${account_id}


JD-TC-GetLoanApplicationwithFilter-7
                                  
    [Documentation]               Create Loan Application and get the loan with location filter.

    ${resp}=   Encrypted Provider Login  ${HLMUSERNAME11}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Loan Application With Filter    location-eq=${locId}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()[0]['location']['id']}  ${locId}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['id']}  ${pcid14}
    Should Be Equal As Strings   ${resp.json()[0]['id']}  ${loanid}
    Should Be Equal As Strings   ${resp.json()[0]['uid']}  ${loanuid}
    Should Be Equal As Strings   ${resp.json()[0]['accountId']}  ${account_id}


JD-TC-GetLoanApplicationwithFilter-8
                                  
    [Documentation]               Create Loan Application and get the loan with locationName filter.

    ${resp}=   Encrypted Provider Login  ${HLMUSERNAME11}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Loan Application With Filter    locationName-eq=${locname}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()[0]['location']['name']}  ${locname}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['id']}  ${pcid14}
    Should Be Equal As Strings   ${resp.json()[0]['id']}  ${loanid}
    Should Be Equal As Strings   ${resp.json()[0]['uid']}  ${loanuid}
    Should Be Equal As Strings   ${resp.json()[0]['accountId']}  ${account_id}


JD-TC-GetLoanApplicationwithFilter-9
                                  
    [Documentation]               Create Loan Application and get the loan with category filter.

    ${resp}=   Encrypted Provider Login  ${HLMUSERNAME11}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

   
    ${resp}=    Get Loan Application With Filter    category-eq=${categoryid}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()[0]['category']['id']}  ${categoryid}
    Should Be Equal As Strings   ${resp.json()[0]['location']['name']}  ${locname}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['id']}  ${pcid14}
    Should Be Equal As Strings   ${resp.json()[0]['id']}  ${loanid}
    Should Be Equal As Strings   ${resp.json()[0]['uid']}  ${loanuid}
    Should Be Equal As Strings   ${resp.json()[0]['accountId']}  ${account_id}
   
    # Should Be Equal As Strings   ${resp.json()[1]['category']['id']}  ${categoryid}
    # Should Be Equal As Strings   ${resp.json()[1]['location']['name']}  ${locname}
    # Should Be Equal As Strings   ${resp.json()[1]['customer']['id']}  ${pcid14}
    # Should Be Equal As Strings   ${resp.json()[1]['id']}  ${loanid}
    # Should Be Equal As Strings   ${resp.json()[1]['uid']}  ${loanUid}
    # Should Be Equal As Strings   ${resp.json()[1]['accountId']}  ${account_id}

JD-TC-GetLoanApplicationwithFilter-10
                                  
    [Documentation]               Create Loan Application and get the loan with categoryName filter.

    ${resp}=   Encrypted Provider Login  ${HLMUSERNAME11}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Loan Application With Filter    categoryName-eq=${categoryname}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()[0]['category']['id']}  ${categoryid}
    Should Be Equal As Strings   ${resp.json()[0]['category']['name']}  ${categoryname}
    Should Be Equal As Strings   ${resp.json()[0]['location']['name']}  ${locname}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['id']}  ${pcid14}
    Should Be Equal As Strings   ${resp.json()[0]['id']}  ${loanid}
    Should Be Equal As Strings   ${resp.json()[0]['uid']}  ${loanuid}
    Should Be Equal As Strings   ${resp.json()[0]['accountId']}  ${account_id}
    # Should Be Equal As Strings   ${resp.json()[0]['remarks']}  ${remarks}
    Should Be Equal As Strings   ${resp.json()[0]['type']['id']}  ${typeid}
    # Should Be Equal As Strings   ${resp.json()[0]['loanProducts'][0]['id']}  ${Productid}

    # Should Be Equal As Strings   ${resp.json()[1]['category']['id']}  ${categoryid}
    # Should Be Equal As Strings   ${resp.json()[1]['location']['name']}  ${locname}
    # Should Be Equal As Strings   ${resp.json()[1]['customer']['id']}  ${pcid14}
    # Should Be Equal As Strings   ${resp.json()[1]['id']}  ${loanid}
    # Should Be Equal As Strings   ${resp.json()[1]['uid']}  ${loanUid}
    # Should Be Equal As Strings   ${resp.json()[1]['accountId']}  ${account_id}


JD-TC-GetLoanApplicationwithFilter-11
                                  
    [Documentation]               Create Loan Application and get the loan with type filter.

    ${resp}=   Encrypted Provider Login  ${HLMUSERNAME11}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Loan Application With Filter    type-eq=${typeid}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    Should Be Equal As Strings   ${resp.json()[0]['type']['id']}  ${typeid}
    Should Be Equal As Strings   ${resp.json()[0]['category']['id']}  ${categoryid}
    Should Be Equal As Strings   ${resp.json()[0]['category']['name']}  ${categoryname}
    Should Be Equal As Strings   ${resp.json()[0]['location']['name']}  ${locname}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['id']}  ${pcid14}
    Should Be Equal As Strings   ${resp.json()[0]['id']}  ${loanid}
    Should Be Equal As Strings   ${resp.json()[0]['uid']}  ${loanuid}
    Should Be Equal As Strings   ${resp.json()[0]['accountId']}  ${account_id}
    # Should Be Equal As Strings   ${resp.json()[0]['remarks']}  ${remarks}
    # Should Be Equal As Strings   ${resp.json()[0]['loanProducts'][0]['id']}  ${Productid}

    # Should Be Equal As Strings   ${resp.json()[1]['type']['id']}  ${typeid}
    # Should Be Equal As Strings   ${resp.json()[1]['category']['id']}  ${categoryid}
    # Should Be Equal As Strings   ${resp.json()[1]['location']['name']}  ${locname}
    # Should Be Equal As Strings   ${resp.json()[1]['customer']['id']}  ${pcid14}
    # Should Be Equal As Strings   ${resp.json()[1]['id']}  ${loanid}
    # Should Be Equal As Strings   ${resp.json()[1]['uid']}  ${loanUid}
    # Should Be Equal As Strings   ${resp.json()[1]['accountId']}  ${account_id}
    # # Should Be Equal As Strings   ${resp.json()[1]['remarks']}  ${remarks}
    # Should Be Equal As Strings   ${resp.json()[1]['loanProducts'][0]['id']}  ${Productid}

JD-TC-GetLoanApplicationwithFilter-12
                                  
    [Documentation]               Create Loan Application and get the loan with typeName filter.

    ${resp}=   Encrypted Provider Login  ${HLMUSERNAME11}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Loan Application With Filter    typeName-eq=${typename}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    Should Be Equal As Strings   ${resp.json()[0]['type']['id']}  ${typeid}
    Should Be Equal As Strings   ${resp.json()[0]['type']['name']}  ${typename}
    Should Be Equal As Strings   ${resp.json()[0]['category']['id']}  ${categoryid}
    Should Be Equal As Strings   ${resp.json()[0]['category']['name']}  ${categoryname}
    Should Be Equal As Strings   ${resp.json()[0]['location']['name']}  ${locname}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['id']}  ${pcid14}
    Should Be Equal As Strings   ${resp.json()[0]['id']}  ${loanid}
    Should Be Equal As Strings   ${resp.json()[0]['uid']}  ${loanuid}
    Should Be Equal As Strings   ${resp.json()[0]['accountId']}  ${account_id}
    # Should Be Equal As Strings   ${resp.json()[0]['remarks']}  ${remarks}
    # Should Be Equal As Strings   ${resp.json()[0]['loanProducts'][0]['id']}  ${Productid}

    # Should Be Equal As Strings   ${resp.json()[1]['type']['id']}  ${typeid}
    # Should Be Equal As Strings   ${resp.json()[0]['type']['name']}  ${typename}
    # Should Be Equal As Strings   ${resp.json()[1]['category']['id']}  ${categoryid}
    # Should Be Equal As Strings   ${resp.json()[1]['location']['name']}  ${locname}
    # Should Be Equal As Strings   ${resp.json()[1]['customer']['id']}  ${pcid14}
    # Should Be Equal As Strings   ${resp.json()[1]['id']}  ${loanid}
    # Should Be Equal As Strings   ${resp.json()[1]['uid']}  ${loanUid}
    # Should Be Equal As Strings   ${resp.json()[1]['accountId']}  ${account_id}
    # # Should Be Equal As Strings   ${resp.json()[1]['remarks']}  ${remarks}
    # Should Be Equal As Strings   ${resp.json()[1]['loanProducts'][0]['id']}  ${Productid}

JD-TC-GetLoanApplicationwithFilter-13
                                  
    [Documentation]               Create Loan Application and get the loan with status filter.

    ${resp}=   Encrypted Provider Login  ${HLMUSERNAME11}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Loan Application With Filter    status-eq=${statusid0}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    Should Be Equal As Strings   ${resp.json()[0]['status']['id']}  ${statusid0}
    Should Be Equal As Strings   ${resp.json()[0]['status']['name']}  ${statusname0}
    Should Be Equal As Strings   ${resp.json()[0]['type']['id']}  ${typeid}
    Should Be Equal As Strings   ${resp.json()[0]['type']['name']}  ${typename}
    Should Be Equal As Strings   ${resp.json()[0]['category']['id']}  ${categoryid}
    Should Be Equal As Strings   ${resp.json()[0]['category']['name']}  ${categoryname}
    Should Be Equal As Strings   ${resp.json()[0]['location']['name']}  ${locname}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['id']}  ${pcid14}
    Should Be Equal As Strings   ${resp.json()[0]['id']}  ${loanid}
    Should Be Equal As Strings   ${resp.json()[0]['uid']}  ${loanuid}
    Should Be Equal As Strings   ${resp.json()[0]['accountId']}  ${account_id}
    # Should Be Equal As Strings   ${resp.json()[0]['remarks']}  ${remarks}
    # Should Be Equal As Strings   ${resp.json()[0]['loanProducts'][0]['id']}  ${Productid}

    # Should Be Equal As Strings   ${resp.json()[1]['status']['id']}  ${statusid}
    # Should Be Equal As Strings   ${resp.json()[1]['status']['name']}  ${statusname}
    # Should Be Equal As Strings   ${resp.json()[1]['type']['id']}  ${typeid}
    # Should Be Equal As Strings   ${resp.json()[1]['type']['name']}  ${typename}
    # Should Be Equal As Strings   ${resp.json()[1]['category']['id']}  ${categoryid}
    # Should Be Equal As Strings   ${resp.json()[1]['location']['name']}  ${locname}
    # Should Be Equal As Strings   ${resp.json()[1]['customer']['id']}  ${pcid14}
    # Should Be Equal As Strings   ${resp.json()[1]['id']}  ${loanid}
    # Should Be Equal As Strings   ${resp.json()[1]['uid']}  ${loanUid}
    # Should Be Equal As Strings   ${resp.json()[1]['accountId']}  ${account_id}
    # # Should Be Equal As Strings   ${resp.json()[1]['remarks']}  ${remarks}
    # Should Be Equal As Strings   ${resp.json()[1]['loanProducts'][0]['id']}  ${Productid}

JD-TC-GetLoanApplicationwithFilter-14
                                  
    [Documentation]               Create Loan Application and get the loan with statusName filter.

    ${resp}=   Encrypted Provider Login  ${HLMUSERNAME11}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Loan Application With Filter    statusName-eq=${statusname0}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    Should Be Equal As Strings   ${resp.json()[0]['status']['id']}  ${statusid0}
    Should Be Equal As Strings   ${resp.json()[0]['status']['name']}  ${statusname0}
    Should Be Equal As Strings   ${resp.json()[0]['type']['id']}  ${typeid}
    Should Be Equal As Strings   ${resp.json()[0]['type']['name']}  ${typename}
    Should Be Equal As Strings   ${resp.json()[0]['category']['id']}  ${categoryid}
    Should Be Equal As Strings   ${resp.json()[0]['category']['name']}  ${categoryname}
    Should Be Equal As Strings   ${resp.json()[0]['location']['name']}  ${locname}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['id']}  ${pcid14}
    Should Be Equal As Strings   ${resp.json()[0]['id']}  ${loanid}
    Should Be Equal As Strings   ${resp.json()[0]['uid']}  ${loanuid}
    Should Be Equal As Strings   ${resp.json()[0]['accountId']}  ${account_id}
    # Should Be Equal As Strings   ${resp.json()[0]['remarks']}  ${remarks}
    # Should Be Equal As Strings   ${resp.json()[0]['loanProducts'][0]['id']}  ${Productid}

    # Should Be Equal As Strings   ${resp.json()[0]['status']['id']}  ${statusid}
    # Should Be Equal As Strings   ${resp.json()[0]['status']['name']}  ${statusname}
    # Should Be Equal As Strings   ${resp.json()[1]['type']['id']}  ${typeid}
    # Should Be Equal As Strings   ${resp.json()[0]['type']['name']}  ${typename}
    # Should Be Equal As Strings   ${resp.json()[1]['category']['id']}  ${categoryid}
    # Should Be Equal As Strings   ${resp.json()[1]['location']['name']}  ${locname}
    # Should Be Equal As Strings   ${resp.json()[1]['customer']['id']}  ${pcid14}
    # Should Be Equal As Strings   ${resp.json()[1]['id']}  ${loanid}
    # Should Be Equal As Strings   ${resp.json()[1]['uid']}  ${loanUid}
    # Should Be Equal As Strings   ${resp.json()[1]['accountId']}  ${account_id}
    # # Should Be Equal As Strings   ${resp.json()[1]['remarks']}  ${remarks}
    # Should Be Equal As Strings   ${resp.json()[1]['loanProducts'][0]['id']}  ${Productid}

JD-TC-GetLoanApplicationwithFilter-UH1
                                  
    [Documentation]           Get Loan Application filter with consumer login
    
    ${resp}=  Consumer Login  ${CUSERNAME17}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=    Get Loan Application With Filter    statusName-eq=${statusname0}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    401
    Should Be Equal As Strings    ${resp.json()}   ${NoAccess}

JD-TC-GetLoanApplicationwithFilter-UH2
                                  
    [Documentation]           Get Loan Application filter without provider login

    ${resp}=    Get Loan Application With Filter    statusName-eq=${statusname0}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-GetLoanApplicationwithFilter-15
                                  
    [Documentation]               Create Loan Application and get the loan with isActionRequired-eq filter.

    ${resp}=   Encrypted Provider Login  ${HLMUSERNAME11}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Loan Application With Filter    isActionRequired-eq=${bool[1]}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetLoanApplicationwithFilter-16
                                  
    [Documentation]               Create Loan Application and get the loan with isActionRequired-eq filter.

    ${resp}=   Encrypted Provider Login  ${HLMUSERNAME11}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Loan Application With Filter    isActionRequired-eq=${bool[0]}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetLoanApplicationwithFilter-17
                                  
    [Documentation]               Create Loan Application and get the loan with spInternalStatus-eq filter.

    
    
    ${resp}=   Encrypted Provider Login  ${HLMUSERNAME11}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Loan Application With Filter    spInternalStatus-eq=${LoanApplicationSpInternalStatus[4]}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetLoanApplicationwithFilter-18
                                  
    [Documentation]               Create Loan Application and get the loan with spInternalStatus-eq filter.

    ${resp}=   Encrypted Provider Login  ${HLMUSERNAME11}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  salesofficer Approval    ${loanuid}    ${Schemeid1}    12    2   2
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['spInternalStatus']}    ${LoanApplicationSpInternalStatus[5]}

    ${resp}=    Get Loan Application With Filter    spInternalStatus-eq=${LoanApplicationSpInternalStatus[4]}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Loan Application With Filter    spInternalStatus-eq=${LoanApplicationSpInternalStatus[5]}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-GetLoanApplicationwithFilter-19
                                  
    [Documentation]               Create Loan Application and get the loan with spInternalStatus-eq filter.

    ${resp}=   Encrypted Provider Login  ${HLMUSERNAME11}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${note}=      FakerLibrary.sentence
    Set Suite Variable    ${note}
    
    ${resp}=    Loan Application Branchapproval  ${loanuid}   ${note}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['spInternalStatus']}    ${LoanApplicationSpInternalStatus[6]}

    ${resp}=    Get Loan Application With Filter    spInternalStatus-eq=${LoanApplicationSpInternalStatus[6]}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetLoanApplicationwithFilter-20
                                  
    [Documentation]               Create Loan Application and get the loan with spInternalStatus-eq filter.

    ${resp}=   Encrypted Provider Login  ${HLMUSERNAME11}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Otp for Consumer Acceptance Phone    ${phone}  ${email2}   ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Otp for Consumer Loan Acceptance Phone    ${phone}    ${OtpPurpose['Authentication']}    ${loanuid}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['spInternalStatus']}    ${LoanApplicationSpInternalStatus[7]}

    ${resp}=    Get Loan Application With Filter    spInternalStatus-eq=${LoanApplicationSpInternalStatus[7]}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetLoanApplicationwithFilter-21
                                  
    [Documentation]               Create Loan Application and get the loan with spInternalStatus-eq filter.

    ${resp}=   Encrypted Provider Login  ${HLMUSERNAME11}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Partner Accepted    ${loanuid}    ${so_id1}    ${pdffile}    ${fileSize}   ${caption}  ${fileType}    ${LoanAction[0]}  ${EMPTY}  invoice  ${order}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['spInternalStatus']}    ${LoanApplicationSpInternalStatus[9]}

    ${resp}=    Get Loan Application With Filter    spInternalStatus-eq=${LoanApplicationSpInternalStatus[9]}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetLoanApplicationwithFilter-22
                                  
    [Documentation]               Create Loan Application and get the loan with spInternalStatus-eq filter.

    ${resp}=   Encrypted Provider Login  ${HLMUSERNAME11}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${note}=      FakerLibrary.sentence

    ${resp}=    Loan Application Operational Approval   ${loanuid}   ${note}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['spInternalStatus']}    ${LoanApplicationSpInternalStatus[10]}

    ${resp}=    Get Loan Application With Filter    spInternalStatus-eq=${LoanApplicationSpInternalStatus[10]}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetLoanApplicationwithFilter-23
                                  
    [Documentation]               Create Loan Application and get the loan with spInternalStatus-eq filter.

    ${resp}=   Encrypted Provider Login  ${HLMUSERNAME11}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Loan Application With Filter    spInternalStatus-eq=Rejected
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

*** comment ***
JD-TC-GetLoanApplicationwithFilter-16
                                  
    [Documentation]               Create Loan Application and get the loan with referenceNo filter.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Loan Application With Filter    referenceNo-eq=${referenceNo}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetLoanApplicationwithFilter-17
                                  
    [Documentation]               Create Loan Application and get the loan with title filter.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Loan Application With Filter    title-eq=${title}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetLoanApplicationwithFilter-18
                                  
    [Documentation]               Create Loan Application and get the loan with description filter.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Loan Application With Filter    description-eq=${description}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetLoanApplicationwithFilter-19
                                  
    [Documentation]               Create Loan Application and get the loan with originFrom filter.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Loan Application With Filter    originFrom-eq=${originFrom}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetLoanApplicationwithFilter-20
                                  
    [Documentation]               Create Loan Application and get the loan with originId filter.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Loan Application With Filter    originId-eq=${originId}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetLoanApplicationwithFilter-21
                                  
    [Documentation]               Create Loan Application and get the loan with originUid filter.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Loan Application With Filter    originUid-eq=${originUid}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetLoanApplicationwithFilter-22
                                  
    [Documentation]               Create Loan Application and get the loan with internalStatus filter.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Loan Application With Filter    internalStatus-eq=${internalStatus}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200