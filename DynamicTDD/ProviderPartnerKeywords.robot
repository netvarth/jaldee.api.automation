*** Settings ***
Library           Collections
Library           String
Library           OperatingSystem
Library           json
Library           DateTime
Library           db.py
Resource          Keywords.robot
Library	          Imageupload.py
Library           FakerLibrary
Library           /ebs/TDD/CustomKeywords.py


*** Keywords ***


Identify Partner

    [Arguments]    ${loginid}  ${accountId}  ${partnerid}  ${countryCode}=91
    ${otp}=    Create Dictionary   countryCode=${countryCode}  loginId=${loginid}  accountId=${accountId}  partnerId=${partnerId}  
    ${log}=    json.dumps    ${otp}
    ${headers2}=     Create Dictionary    Content-Type=application/json    Authorization=browser
    ${resp}=    POST On Session    ynw    /partner/oauth/identify    data=${log}  headers=${headers2}  expected_status=any
    RETURN  ${resp}

Verify Otp For Login Partner
    [Arguments]  ${loginid}  ${purpose}
    Check And Create YNW Session
    ${key}=   verify accnt  ${loginid}  ${purpose}
    ${headers2}=     Create Dictionary    Content-Type=application/json    Authorization=browser
    ${resp}=    POST On Session    ynw    /partner/oauth/otp/${key}/verify  headers=${headers2}  expected_status=any
    RETURN  ${resp}

Partner Login
    [Arguments]    ${loginId}  ${accountId}  ${token}  ${countryCode}=+91
    ${login}=    Create Dictionary    loginId=${loginId}  accountId=${accountId}  countryCode=${countryCode}
    ${log}=    json.dumps    ${login}
    ${headers2}=     Create Dictionary    Content-Type=application/json    Authorization=${token}
    Check And Create YNW Session
    ${resp}=    POST On Session    ynw     /partner/login   headers=${headers2}  data=${log}   expected_status=any 
    RETURN  ${resp}


Partner Logout 

    Check And Create YNW Session
    ${headers2}=     Create Dictionary    Content-Type=application/json  
    ${resp}=    DELETE On Session    ynw    /partner/login       expected_status=any
    RETURN  ${resp}


Login Partner with Password
    [Arguments]    ${accountId}  ${loginId}  ${password}
    ${login}=    Create Dictionary    loginId=${loginId}  password=${password}  accountId=${accountId}
    ${log}=    json.dumps    ${login}
    Check And Create YNW Session
    ${resp}=    POST On Session    ynw     /partner/login   data=${log}   expected_status=any 
    RETURN  ${resp}


Partner Reset Password
    [Arguments]    ${accountId}  ${loginId}
    ${login}=    Create Dictionary    loginId=${loginId}  accountId=${accountId}
    ${log}=    json.dumps    ${login}
    Check And Create YNW Session
    ${resp}=    POST On Session   ynw   /partner/login/reset/password   data=${log}   expected_status=any 
    RETURN  ${resp}



Complete Partner Reset Password
    [Arguments]    ${accountId}  ${loginId}  ${password}  ${token}
    ${login}=    Create Dictionary    loginId=${loginId}  password=${password}  accountId=${accountId}
    ${log}=    json.dumps    ${login}
    ${headers2}=     Create Dictionary    Content-Type=application/json    authorization=${token}
    Check And Create YNW Session
    ${resp}=    POST On Session   ynw   /partner/login/reset/password   headers=${headers2}  data=${log}   expected_status=any 
    RETURN  ${resp}


Get Partner Loan Application Category

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /partner/loanapplication/category    expected_status=any
    RETURN  ${resp}
    

Get Partner Loan Application Type

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /partner/loanapplication/type  expected_status=any
    RETURN  ${resp}

Get Partner Loan Application Status

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /partner/loanapplication/status  expected_status=any
    RETURN  ${resp}

Get Partner Loan Application Sub-Status

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /partner/loanapplication/substatus  expected_status=any
    RETURN  ${resp}

Get Partner Loan Application Product

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /partner/loan/products  expected_status=any
    RETURN  ${resp}

Get Partner Loan Application Scheme

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /partner/loan/schemes  expected_status=any
    RETURN  ${resp}

Get Partner Loan Application SP Internal Status

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /partner/loanapplication/sp/internalstatus  expected_status=any
    RETURN  ${resp}

Create Partner Loan Application

    [Arguments]      ${customer}  ${fname}  ${lname}  ${phone}  ${countrycode}  ${email}  ${category}  ${type}  ${loanProduct}  ${location}  ${locationArea}  ${invoiceAmount}  ${downpaymentAmount}  ${requestedAmount}  ${remarks}  ${action}  ${owner}  ${fileName}  ${fileSize}  ${caption}  ${fileType}  ${order}  @{vargs}    &{kwargs}
    
    ${customer}=       Create Dictionary    id=${customer}  firstName=${fname}  lastName=${lname}  phoneNo=${phone}  countryCode=${countrycode}  email=${email}
    ${category}=       Create Dictionary    id=${category}
    ${type}=           Create Dictionary    id=${type}
    ${loanProduct}=    Create Dictionary    id=${loanProduct}
    ${location}=       Create Dictionary    id=${location}

    ${consumerPhoto}=  Create Dictionary  action=${action}  owner=${owner}  fileName=${fileName}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    ${ConsumerPhotoList}=  Create List  ${consumerPhoto}

    ${len}=  Get Length  ${vargs}
    ${LoanApplicationKycList}=  Create List

    FOR    ${index}    IN RANGE    ${len}   
        Exit For Loop If  ${len}==0
        Append To List  ${LoanApplicationKycList}  ${vargs[${index}]}
    END

    ${loan}=  Create Dictionary  customer=${customer}  category=${category}  type=${type}  loanProduct=${loanProduct}  location=${location}  locationArea=${locationArea}  invoiceAmount=${invoiceAmount}  downpaymentAmount=${downpaymentAmount}  requestedAmount=${requestedAmount}  remarks=${remarks}  consumerPhoto=${ConsumerPhotoList}  loanApplicationKycList=${LoanApplicationKycList}

    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${loan} 	${key}=${value}
    END

    ${loan}=  json.dumps  ${loan}

    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /partner/loanapplication  data=${loan}  expected_status=any
    RETURN  ${resp}

Update Partner Loan Application

    [Arguments]   ${loanApplicationRefNo}   ${customer}     ${category}  ${type}  ${status}   ${loanProduct}    ${location}  ${locationArea}  ${invoiceAmount}  ${downpaymentAmount}  ${requestedAmount}  ${remarks}     ${action}  ${owner}  ${fileName}  ${fileSize}  ${caption}  ${fileType}  ${order}   @{vargs}

    ${category}=       Create Dictionary    id=${category}
    ${type}=           Create Dictionary    id=${type}
    ${loanProduct}=    Create Dictionary    id=${loanProduct}
    ${location}=       Create Dictionary    id=${location}
    ${status}=       Create Dictionary    id=${status}
   
    ${consumerPhoto}=  Create Dictionary  action=${action}  owner=${owner}  fileName=${fileName}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    ${ConsumerPhotoList}=  Create List  ${consumerPhoto}

    ${len}=  Get Length  ${vargs}
    ${LoanApplicationKycList}=  Create List

    FOR    ${index}    IN RANGE    ${len}   
        Exit For Loop If  ${len}==0
        Append To List  ${LoanApplicationKycList}  ${vargs[${index}]}
    END

    ${loan}=  Create Dictionary  customer=${customer}  category=${category}  type=${type}   status=${status}  loanProduct=${loanProduct}    location=${location}  locationArea=${locationArea}  invoiceAmount=${invoiceAmount}  downpaymentAmount=${downpaymentAmount}  requestedAmount=${requestedAmount}  remarks=${remarks}       consumerPhoto=${ConsumerPhotoList}    loanApplicationKycList=${LoanApplicationKycList}
    ${loan}=  json.dumps  ${loan}

    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /partner/loanapplication/${loanApplicationRefNo}  data=${loan}  expected_status=any
    RETURN  ${resp}



Get Partner Loan Application With Filter

    [Arguments]    &{param}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /partner/loanapplication  params=${param}  expected_status=any
    RETURN  ${resp}

Get Partner Loan Application Count with filter

    [Arguments]    &{param}

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /partner/loanapplication/count  params=${param}  expected_status=any
    RETURN  ${resp}

Get Partner Loan Application by loanApplicationUid

    [Arguments]    ${loanApplicationUid}

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /partner/loanapplication/${loanApplicationUid}  expected_status=any
    RETURN  ${resp}

Cancel Partner Loan Application

    [Arguments]    ${loanApplicationUid}

    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /partner/loanapplication/${loanApplicationUid}/cancel    expected_status=any
    RETURN  ${resp}

Redirect Partner Loan Application

    [Arguments]    ${loanApplicationUid}

    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /partner/loanapplication/${loanApplicationUid}/redirect    expected_status=any
    RETURN  ${resp}

    
# Approval Partner Loan Application

#     [Arguments]    ${loanApplicationUid}  

#     Check And Create YNW Session
#     ${resp}=  PUT On Session  ynw   /partner/loanapplication/${loanApplicationUid}/approvalrequest    expected_status=any
#     RETURN  ${resp}
Partner Loan Application Approval

    [Arguments]    ${loanApplicationUid}    ${Schemeid} 

    ${data}=  Create Dictionary  Schemeid=${Schemeid} 
    ${data}=  json.dumps  ${data}
   

    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /partner/loanapplication/${loanApplicationUid}/approvalrequest     data=${data}   expected_status=any
    RETURN  ${resp}


Partner Loan Application Manual Approval

    [Arguments]    ${loanApplicationUid}   ${loanScheme}   ${invoiceAmount}    ${downpaymentAmount}    ${requestedAmount}    ${sanctionedAmount}

    # ${loanScheme}=     Create Dictionary  id=${loanScheme} 
    ${ManualApproval}=     Create Dictionary    loanScheme=${loanScheme}    invoiceAmount=${invoiceAmount}    downpaymentAmount=${downpaymentAmount}    requestedAmount=${requestedAmount}  sanctionedAmount=${sanctionedAmount}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /partner/loanapplication/${loanApplicationUid}/manualapproval  expected_status=any
    RETURN  ${resp}
Reject Partner Loan Application

    [Arguments]    ${loanApplicationUid}

    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /partner/loanapplication/${loanApplicationUid}/reject  expected_status=any
    RETURN  ${resp}

Change Partner Loan Application Status

    [Arguments]    ${loanApplicationUid}  ${statusId}

    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /partner/loanapplication/${loanApplicationUid}/status/${statusId}  expected_status=any
    RETURN  ${resp}

Change Partner Loan Application Sub-Status

    [Arguments]    ${loanApplicationRefNo}  ${substatusId}

    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /partner/loanapplication/${loanApplicationRefNo}/substatus/${substatusId}  expected_status=any
    RETURN  ${resp}

Change Partner Loan Application Status with sp
   
    [Arguments]    ${loanApplicationRefNo} 

    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /partner/loanapplication/${loanApplicationRefNo}/sp/publicnotes  expected_status=any
    RETURN  ${resp}

Remove Partner Loan Assignee

    [Arguments]    ${loanApplicationUid} 

    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /partner/loanapplication/${loanApplicationUid}/assignee/remove  expected_status=any
    RETURN  ${resp}

Change Partner Loan Assignee

    [Arguments]    ${loanApplicationUid}   ${userId}

    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /partner/loanapplication/${loanApplicationUid}/assignee/${userId}  expected_status=any
    RETURN  ${resp}

Partner Generate Loan Application Otp For Phone Number

    [Arguments]    ${number}  ${countryCode}

    ${data}=  Create Dictionary  countryCode=${countryCode}  number=${number}
    ${data}=  json.dumps  ${data}
    # ${headers2}=     Create Dictionary    Content-Type=application/json    Authorization=browser
    Check And Create YNW Session
    ${resp}=    POST On Session    ynw     /partner/loanapplication/generate/phone   data=${data}   expected_status=any 
    RETURN  ${resp}

Partner Verify Otp for phone

    [Arguments]    ${loginId}   ${purpose}  ${id}  ${firstName}  ${lastName}  ${phoneNo}  ${countryCode}   ${locid}     @{vargs}    &{kwargs}

    ${customer}=  Create Dictionary      id=${id}  firstName=${firstName}  lastName=${lastName}  phoneNo=${phoneNo}  countryCode=${countryCode}
    ${location}=  Create Dictionary      id=${locid}
   
    ${otp}=   verify accnt  ${loginId}  ${purpose}

    ${len}=  Get Length  ${vargs}
    ${LoanApplicationKycList}=  Create List

    FOR    ${index}    IN RANGE    ${len}   
        Exit For Loop If  ${len}==0
        Append To List  ${LoanApplicationKycList}  ${vargs[${index}]}
    END

    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${customer} 	${key}=${value}
    END
    ${loan}=  Create Dictionary   customer=${customer}  location=${location}   loanApplicationKycList=${LoanApplicationKycList}
    ${loan}=  json.dumps  ${loan}

    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /partner/loanapplication/verify/${otp}/phone  data=${loan}  expected_status=any
    RETURN  ${resp}


Partner Verify Number and Create Loan Application with customer details

    [Arguments]    ${loginId}   ${purpose}  ${id}  ${locid}    ${CustomerPhoto}  @{vargs}  &{custDetailskwargs}

    # ${customer}=  Create Dictionary      id=${id}  firstName=${firstName}  lastName=${lastName}  phoneNo=${phoneNo}  countryCode=${countryCode}
    ${location}=  Create Dictionary      id=${locid}
   
    ${otp}=   verify accnt  ${loginId}  ${purpose}

    ${len}=  Get Length  ${vargs}
    ${LoanApplicationKycList}=  Create List

    FOR    ${index}    IN RANGE    ${len}   
        Exit For Loop If  ${len}==0
        Append To List  ${LoanApplicationKycList}  ${vargs[${index}]}
    END

    ${customer}=  Create Dictionary      id=${id}

    Log Many  @{custDetailskwargs}
    FOR  ${key}  IN  @{custDetailskwargs}
        # Log  Key is "${key}" and value is "${custDetailskwargs}[${key}]".
        IF  '${key}' in @{custdeets}
            Set to Dictionary  ${customer}  ${key}=${custDetailskwargs}[${key}]
        END
    END

    ${loan}=  Create Dictionary   customer=${customer}  location=${location}   loanApplicationKycList=${LoanApplicationKycList}    consumerPhoto=${CustomerPhoto}
    ${loan}=  json.dumps  ${loan}

    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /partner/loanapplication/verify/${otp}/phone  data=${loan}  expected_status=any
    RETURN  ${resp}


Partner Otp For Email

    [Arguments]    ${email}

    ${data}=  Create Dictionary  email=${email}
    ${data}=  json.dumps  ${data}
    # ${headers2}=     Create Dictionary    Content-Type=application/json    Authorization=browser
    Check And Create YNW Session
    ${resp}=    POST On Session    ynw     /partner/loanapplication/generate/email  data=${data}   expected_status=any 
    RETURN  ${resp}

Partner Verify Otp for Email


    [Arguments]    ${email}   ${purpose}  ${uid}
   
    ${otp}=   verify accnt  ${email}  ${purpose}
    ${loan}=  Create Dictionary   uid=${uid}
    ${data}=  json.dumps  ${loan}

    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /partner/loanapplication/verify/${otp}/phone  data=${data}  expected_status=any
    RETURN  ${resp}

Requst For Partner Aadhar Validation

    [Arguments]      ${id}  ${loanApplicationUid}  ${customerPhone}  ${aadhaar}      @{vargs}
    

    ${len}=  Get Length  ${vargs}
    ${aadhaarAttachmentsList}=  Create List

    FOR    ${index}    IN RANGE    ${len}   
        Exit For Loop If  ${len}==0
        Append To List  ${aadhaarAttachmentsList}  ${vargs[${index}]}
    END

    ${loan}=  Create Dictionary    id=${id}   loanApplicationUid=${loanApplicationUid}  customerPhone=${customerPhone}  aadhaar=${aadhaar}   aadhaarAttachments=${aadhaarAttachmentsList}
    ${loan}=  json.dumps  ${loan}

    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /partner/loanapplication/update/UID  data=${loan}  expected_status=any
    RETURN  ${resp}

Requst For Partner Pan Validation

    [Arguments]      ${id}  ${loanApplicationUid}  ${customerPhone}  ${pan}      @{vargs}
    

    ${len}=  Get Length  ${vargs}
    ${panAttachments}=  Create List

    FOR    ${index}    IN RANGE    ${len}   
        Exit For Loop If  ${len}==0
        Append To List  ${panAttachments}  ${vargs[${index}]}
    END

    ${loan}=  Create Dictionary    id=${id}   loanApplicationUid=${loanApplicationUid}  customerPhone=${customerPhone}  pan=${pan}   panAttachments=${panAttachments}
    ${loan}=  json.dumps  ${loan}

    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /partner/loanapplication/update/Pan  data=${loan}  expected_status=any
    RETURN  ${resp}

Add Partner loan Bank Details

    [Arguments]      ${originFrom}  ${originUid}  ${loanApplicationUid}  ${bankName}  ${bankAccountNo}  ${bankIfsc}  ${bankAddress1}  ${bankAddress2}  ${bankCity}  ${bankState}  ${bankPin}  @{vargs}
    

    ${len}=  Get Length  ${vargs}
    ${bankStatementAttachments}=  Create List

    FOR    ${index}    IN RANGE    ${len}   
        Exit For Loop If  ${len}==0
        Append To List  ${bankStatementAttachments}  ${vargs[${index}]}
    END

    ${loan}=  Create Dictionary   originFrom=${originFrom}  originUid=${originUid}  loanApplicationUid=${loanApplicationUid}  bankName=${bankName}  bankAccountNo=${bankAccountNo}  bankIfsc=${bankIfsc}  bankAddress1=${bankAddress1}  bankAddress2=${bankAddress2}  bankCity=${bankCity}  bankState=${bankState}  bankPin=${bankPin}    bankStatementAttachments=${bankStatementAttachments}
    ${loan}=  json.dumps  ${loan}

    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /partner/loanapplication/bank  data=${loan}  expected_status=any
    RETURN  ${resp}

Update Partner loan Bank Details

    [Arguments]      ${originFrom}  ${originUid}  ${loanApplicationUid}  ${bankName}  ${bankAccountNo}  ${bankIfsc}  ${bankAddress1}  ${bankAddress2}  ${bankCity}  ${bankState}  ${bankPin}  @{vargs}
    

    ${len}=  Get Length  ${vargs}
    ${bankStatementAttachments}=  Create List

    FOR    ${index}    IN RANGE    ${len}   
        Exit For Loop If  ${len}==0
        Append To List  ${bankStatementAttachments}  ${vargs[${index}]}
    END

    ${loan}=  Create Dictionary   originFrom=${originFrom}  originUid=${originUid}  loanApplicationUid=${loanApplicationUid}  bankName=${bankName}  bankAccountNo=${bankAccountNo}  bankIfsc=${bankIfsc}  bankAddress1=${bankAddress1}  bankAddress2=${bankAddress2}  bankCity=${bankCity}  bankState=${bankState}  bankPin=${bankPin}    bankStatementAttachments=${bankStatementAttachments}
    ${loan}=  json.dumps  ${loan}

    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /partner/loanapplication/bank  data=${loan}  expected_status=any
    RETURN  ${resp}

Verify Partner loan Bank

    [Arguments]    ${uid}   ${bankName}  ${bankAccountNo}  ${bankIfsc}

    
   
    ${loan}=  Create Dictionary   originUid=${uid}     bankName=${bankName}   bankAccountNo=${bankAccountNo}   bankIfsc=${bankIfsc}
    ${data}=  json.dumps  ${loan}

    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /partner/loanapplication/verify/bank  data=${data}  expected_status=any
    RETURN  ${resp}

# Verify Partner loan Bank Details

#     [Arguments]      ${uid}  ${loanProduct}  ${category}  ${type}  ${loanScheme}  ${invoiceAmount}  ${downpaymentAmount}  ${requestedAmount}  ${montlyIncome}  ${emiPaidAmountMonthly}   ${id}  @{vargs}
   
#     # ${category}=       Create Dictionary    id=${category}
#     # ${type}=           Create Dictionary    id=${type}
#     # ${loanProduct}=    Create Dictionary    id=${loanProduct}
   
#     # ${loanScheme}=       Create Dictionary    id=${loanScheme}
   
#     ${len}=  Get Length  ${vargs}
#     ${LoanApplicationKycList}=  Create List

#     FOR    ${index}    IN RANGE    ${len}   
#         Exit For Loop If  ${len}==0
#         Append To List  ${LoanApplicationKycList}  ${vargs[${index}]}
#     END

#     ${loan}=  Create Dictionary   uid=${uid}   loanProduct=${loanProduct}  category=${category}  type=${type}   loanScheme=${loanScheme}  invoiceAmount=${invoiceAmount}  downpaymentAmount=${downpaymentAmount}  requestedAmount=${requestedAmount}  montlyIncome=${montlyIncome}  emiPaidAmountMonthly=${emiPaidAmountMonthly}   loanApplicationKycList=${LoanApplicationKycList}
#     ${loan}=  json.dumps  ${loan}

#     Check And Create YNW Session
#     ${resp}=  PUT On Session  ynw  /partner/loanapplication/request  data=${loan}  expected_status=any

Get Partner loan Bank

    [Arguments]    ${id}

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /partner/loanapplication/bank/${id}   expected_status=any
    RETURN  ${resp}

Get Partner loan Bank Details

    [Arguments]    ${loanApplicationUid}

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /partner/loanapplication/${loanApplicationUid}/bankdetails   expected_status=any
    RETURN  ${resp}

Generate Phone Partner Creation

    [Arguments]    ${number}  ${countryCode}    &{kwargs}

    ${data}=  Create Dictionary  countryCode=${countryCode}  partnerMobile=${number}

    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END
    ${data}=  json.dumps  ${data}

    Check And Create YNW Session
    ${resp}=    POST On Session    ynw     /provider/partner/generate/phone   data=${data}   expected_status=any 
    RETURN  ${resp}

Verify Phone Partner Creation

    [Arguments]    ${phoneNo}   ${purpose}   ${partnerName}  ${partnerAliasName}    &{kwargs}
   
    ${otp}=   verify accnt  ${phoneNo}  ${purpose}

    ${data}=  Create Dictionary  partnerName=${partnerName}  partnerAliasName=${partnerAliasName}  partnerMobile=${phoneNo}    

    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END

    ${data}=  json.dumps  ${data}

    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/partner/verify/${otp}/phone  data=${data}  expected_status=any
    RETURN  ${resp}

Otp for Partner Acceptance Phone

    [Arguments]    ${phoneNo}  ${email}  ${countryCode}

    ${data}=  Create Dictionary  countryCode=${countryCode}  email=${email}  phoneNo=${phoneNo}
    ${data}=  json.dumps  ${data}

    Check And Create YNW Session
    ${resp}=    POST On Session    ynw     /partner/generate/acceptance   data=${data}   expected_status=any 
    RETURN  ${resp}

Partner Loan Application Action Completed

    [Arguments]    ${note}  ${loanApplicationUid}

    ${data}=  Create Dictionary  note=${note}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /partner/loanapplication/${loanApplicationUid}/actioncompleted  data=${data}  expected_status=any
    RETURN  ${resp}

Partner Add General Notes

    [Arguments]  ${uid}  ${note}

    ${data}=  Create Dictionary    note=${note}
    ${data}=  json.dumps  ${data}

    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw     /partner/loanapplication/${uid}/note   data=${data}   expected_status=any 
    RETURN  ${resp}

Verify Partner loan Bank Details

    [Arguments]      ${loanuid}  ${loanProduct}  ${category}  ${type}  ${productCategoryId}  ${productSubCategoryId}  ${partner}  ${invoiceAmount}  ${downpaymentAmount}  ${requestedAmount}  ${emiPaidAmountMonthly}  ${employee}  ${employeeCode}  ${loanid}    @{vargs}
   
    ${len}=  Get Length  ${vargs}
    ${LoanApplicationKycList}=  Create List

    FOR    ${index}    IN RANGE    ${len}   
        Exit For Loop If  ${len}==0
        Append To List  ${LoanApplicationKycList}  ${vargs[${index}]}
    END

    ${loan}=  Create Dictionary   uid=${loanuid}  loanProducts=${loanProduct}  category=${category}  type=${type}  productCategoryId=${productCategoryId}  productSubCategoryId=${productSubCategoryId}  partner=${partner}  invoiceAmount=${invoiceAmount}  downpaymentAmount=${downpaymentAmount}  requestedAmount=${requestedAmount}  emiPaidAmountMonthly=${emiPaidAmountMonthly}  employee=${employee}  employeeCode=${employeeCode}  id=${loanid}    loanApplicationKycList=${LoanApplicationKycList}
    ${loan}=  json.dumps  ${loan}

    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /partner/loanapplication/request  data=${loan}  expected_status=any
    RETURN  ${resp}


Generate OTP for partner Email
    [Arguments]    ${email}

    ${data}=  Create Dictionary  email=${email}  
    ${data}=  json.dumps  ${data}

    Check And Create YNW Session
    ${resp}=    POST On Session    ynw     /provider/partner/generate/email   data=${data}   expected_status=any 
    RETURN  ${resp}


Verify OTP for Partner Email
    [Arguments]    ${email}  ${part_id}

    ${otp}=   verify accnt  ${email}  ${OtpPurpose['ProviderVerifyEmail']}

    ${data}=  Create Dictionary  id=${part_id}  
    ${data}=  json.dumps  ${data}

    Check And Create YNW Session
    ${resp}=    POST On Session    ynw     /provider/partner/verify/${otp}/email   data=${data}  expected_status=any 
    RETURN  ${resp}

Get Partner Customers

    [Arguments]    ${partnerId}

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /provider/partner/${partnerId}/customers   expected_status=any
    RETURN  ${resp}

Get Partner Loan Application Consumer Details with filter
    [Arguments]    &{filters}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /partner/loanapplication/consumers/details  params=${filters}  expected_status=any
    RETURN  ${resp}


Get Partner Loan Application by loanApplicationRefNo
    [Arguments]    ${loanApplicationRefNo}

    Check And Create YNW Session
    ${resp}=  GET On Session  ynw   /partner/loanapplication/${loanApplicationRefNo}  expected_status=any
    RETURN  ${resp}


Get Partner Loan Application By uid
    [Arguments]    ${loanApplicationUid}   
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /partner/loanapplication/${loanApplicationUid}    expected_status=any
    RETURN  ${resp}


Update Partner Aadhar

    [Arguments]    ${aadhaar}    ${uid}    ${action}    ${owner}    ${fileName}    ${fileSize}    ${caption}    ${fileType}    ${order}

    ${aadhaarAttachments}=    Create Dictionary    action=${action}    owner=${owner}    fileName=${fileName}    fileSize=${fileSize}    caption=${caption}    fileType=${fileType}    order=${order}
    ${aadhaarAttachments}=    Create List  ${aadhaarAttachments}
    
    ${data}=  Create Dictionary  aadhaar=${aadhaar}    aadhaarAttachments=${aadhaarAttachments}    uid=${uid}
    ${data}=  json.dumps  ${data}

    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw     /provider/partner/update/UID   data=${data}   expected_status=any 
    RETURN  ${resp}


Aadhaar Status

    [Arguments]    ${uid}

    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw     /provider/partner/aadhar/status/${uid}   expected_status=any 
    RETURN  ${resp}


Update Partner Pan

    [Arguments]    ${pan}    ${uid}    ${action}    ${owner}    ${fileName}    ${fileSize}    ${caption}    ${fileType}    ${order}

    ${panAttachments}=    Create Dictionary    action=${action}    owner=${owner}    fileName=${fileName}    fileSize=${fileSize}    caption=${caption}    fileType=${fileType}    order=${order}
    ${panAttachments}=    Create List  ${panAttachments}
    
    ${data}=  Create Dictionary  pan=${pan}    panAttachments=${panAttachments}    uid=${uid}
    ${data}=  json.dumps  ${data}

    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw     /provider/partner/update/Pan   data=${data}   expected_status=any 
    RETURN  ${resp}


Update Partner Bank

    [Arguments]    ${bankAccountNo}    ${bankIfsc}    ${bankName}    ${uid}    ${action}    ${owner}    ${fileName}    ${fileSize}    ${caption}    ${fileType}    ${order}    &{kwargs}

    ${bankAttachments}=    Create Dictionary    action=${action}    owner=${owner}    fileName=${fileName}    fileSize=${fileSize}    caption=${caption}    fileType=${fileType}    order=${order}
    ${bankAttachments}=    Create List  ${bankAttachments}
    
    ${data}=  Create Dictionary  bankAccountNo=${bankAccountNo}    bankIfsc=${bankIfsc}    bankName=${bankName}    bankAttachments=${bankAttachments}    uid=${uid}
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END
    ${data}=  json.dumps  ${data}

    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw     /provider/partner/bank   data=${data}   expected_status=any 
    RETURN  ${resp}


Verify Partner Bank

    [Arguments]    ${id}    ${uid}    ${bankAccountNo}    ${bankIfsc}    &{kwargs}

    ${data}=  Create Dictionary  id=${id}    uid=${uid}   bankAccountNo=${bankAccountNo}    bankIfsc=${bankIfsc}
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END
    ${data}=  json.dumps  ${data}

    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw     /provider/partner/verify/bank   data=${data}   expected_status=any 
    RETURN  ${resp}


Validate Gst 

    [Arguments]    ${uid}    ${gstin}

    ${data}=  Create Dictionary  gstin=${gstin}
    ${data}=  json.dumps  ${data}

    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw     /provider/partner/validate/gst/${uid}   data=${data}   expected_status=any 
    RETURN  ${resp}


Partner Details

    [Arguments]    ${uid}    ${partnerName}    ${partnerMobile}    ${partnerEmail}    ${description}    ${type}    ${category}    ${partnerAddress1}    ${partnerAddress2}    ${partnerPin}    ${partnerCity}    ${partnerDistrict}    ${partnerState}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerUserName}    ${aadhaarAttachments}    ${panAttachments}    ${gstAttachments}    ${licenceAttachments}    ${partnerAttachments}    ${storeAttachments}   &{kwargs}

    ${category}=       Create Dictionary    id=${category}
    ${type}=           Create Dictionary    id=${type}

    ${data}=  Create Dictionary    uid=${uid}    partnerName=${partnerName}    partnerMobile=${partnerMobile}    partnerEmail=${partnerEmail}    description=${description}    type=${type}    category=${category}    partnerAddress1=${partnerAddress1}    partnerAddress2=${partnerAddress2}    partnerPin=${partnerPin}    partnerCity=${partnerCity}    partnerDistrict=${partnerDistrict}    partnerState=${partnerState}    aadhaar=${aadhaar}    pan=${pan}    gstin=${gstin}    branch=${branch}    partnerUserName=${partnerUserName}    aadhaarAttachments=${aadhaarAttachments}    panAttachments=${panAttachments}    gstAttachments=${gstAttachments}    licenceAttachments=${licenceAttachments}    partnerAttachments=${partnerAttachments}    storeAttachments=${storeAttachments}
    FOR    ${key}    ${value}    IN    &{kwargs}
        Set To Dictionary 	${data} 	${key}=${value}
    END
    ${data}=  json.dumps  ${data}

    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw     /provider/partner/${uid}   data=${data}  expected_status=any 
    RETURN  ${resp}


Partner upload file to temporary location

    [Arguments]    ${action}    ${owner}    ${ownerType}    ${ownerName}    ${fileName}    ${fileSize}    ${caption}    ${fileType}    ${uid}    ${order}

    ${file}=  Create Dictionary  action=${action}    owner=${owner}    ownerType=${ownerType}    ownerName=${ownerName}    fileName=${fileName}    fileSize=${fileSize}    caption=${caption}    fileType=${fileType}    uid=${uid}    order=${order}
    ${data}=  Create List  ${file}
    ${data}=    json.dumps    ${data}

    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /partner/fileShare/upload   data=${data}  expected_status=any
    Log  ${resp.content}
    RETURN  ${resp}


Partner change status of the uploaded file

    [Arguments]    ${status}    ${id}

    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /partner/fileShare/upload/${status}/${id}  expected_status=any
    Log  ${resp.content}
    RETURN  ${resp}

