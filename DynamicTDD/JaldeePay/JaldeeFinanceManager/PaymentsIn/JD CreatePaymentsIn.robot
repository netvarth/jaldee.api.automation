*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Finance Manager
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Library           /ebs/TDD/excelfuncs.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 

*** Variables ***

${jpgfile}      /ebs/TDD/uploadimage.jpg
${pngfile}      /ebs/TDD/upload.png
${pdffile}      /ebs/TDD/sample.pdf
${jpgfile2}      /ebs/TDD/small.jpg
${gif}      /ebs/TDD/sample.gif
${xlsx}      /ebs/TDD/qnr.xlsx

${order}    0
${fileSize}  0.00458

@{status}    New     Pending    Assigned     Approved    Rejected
@{New_status}    Proceed     Unassign    Block     Delete    Remove



*** Test Cases ***

JD-TC-Create PaymentsIn-1

    [Documentation]  Create a PaymentIn.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}

    Set Suite Variable  ${pid}  ${decrypted_data['id']}
    Set Suite Variable    ${userName}    ${decrypted_data['userName']}
    Set Suite Variable    ${pdrfname}    ${decrypted_data['firstName']}
    Set Suite Variable    ${pdrlname}    ${decrypted_data['lastName']}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id1}  ${resp.json()['id']}

    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    
    IF  ${resp.json()['enableJaldeeFinance']}==${bool[0]}
        ${resp1}=    Enable Disable Jaldee Finance   ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableJaldeeFinance']}  ${bool[1]}

    ${resp}=  Create Sample Location  
    Set Suite Variable    ${lid}    ${resp}  

    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${name}=   FakerLibrary.word
    ${resp}=  Create Category   ${name}  ${categoryType[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${category_id1}   ${resp.json()}

    ${name1}=   FakerLibrary.word
    Set Suite Variable  ${name1}
    ${resp}=  Create Category   ${name1}  ${categoryType[2]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${category_id2}   ${resp.json()}

    ${resp}=  Get Category By Id   ${category_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}          ${name}
    Should Be Equal As Strings  ${resp.json()['categoryType']}  ${categoryType[0]}
    Should Be Equal As Strings  ${resp.json()['accountId']}     ${account_id1}
    Should Be Equal As Strings  ${resp.json()['status']}        ${toggle[0]}

    ${resp}=  Get default status    ${categoryType[2]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable    ${status_id0}    ${resp.json()['id']}  

    ${vender_name}=   FakerLibrary.firstname
    ${contactPersonName}=   FakerLibrary.lastname
    ${vendorId}=   FakerLibrary.word
    ${PO_Number}    Generate random string    5    123456789
    ${vendor_phno}=  Evaluate  ${PUSERNAME}+${PO_Number}
    ${vendor_phno}=  Create Dictionary  countryCode=${countryCodes[0]}   number=${vendor_phno}
    Set Test Variable  ${email}  ${vender_name}${vendor_phno}.${test_mail}
    ${address}=  FakerLibrary.city
    Set Suite Variable  ${address}
    ${bank_accno}=   db.Generate_random_value  size=11   chars=${digits} 
    ${branch}=   db.get_place
    ${ifsc_code}=   db.Generate_ifsc_code
    ${gst_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    ${pin}  ${city}  ${district}  ${state}=  get_pin_loc

    ${state}=    Evaluate     "${state}".title()
    ${state}=    String.RemoveString  ${state}    ${SPACE}
    Set Suite Variable    ${state}
    Set Suite Variable    ${district}
    Set Suite Variable    ${pin}
    ${vendor_phno}=   Create List  ${vendor_phno}
    Set Suite Variable    ${vendor_phno}
    
    ${email}=   Create List  ${email}
    Set Suite Variable    ${email}

    ${bankIfsc}    Random Number 	digits=5 
    ${bankIfsc}=    Evaluate    f'{${bankIfsc}:0>7d}'
    Log  ${bankIfsc}
    Set Suite Variable  ${bankIfsc}  55555${bankIfsc} 

    ${bankName}     FakerLibrary.name
    Set Suite Variable    ${bankName}

    ${upiId}     FakerLibrary.name
    Set Suite Variable  ${upiId}

    ${pan}    Random Number 	digits=5 
    ${pan}=    Evaluate    f'{${pan}:0>5d}'
    Log  ${pan}
    Set Suite Variable  ${pan}  55555${pan}

    ${branchName}=    FakerLibrary.name
    Set Suite Variable  ${branchName}
    ${gstin}    Random Number 	digits=5 
    ${gstin}=    Evaluate    f'{${gstin}:0>8d}'
    Log  ${gstin}
    Set Suite Variable  ${gstin}  55555${gstin}

    ${preferredPaymentMode}=    Create List    ${jaldeePaymentmode[0]}
    ${bankInfo}=    Create Dictionary     bankaccountNo=${bank_accno}    ifscCode=${bankIfsc}    bankName=${bankName}    upiId=${upiId}     branchName=${branchName}    pancardNo=${pan}    gstNumber=${gstin}    preferredPaymentMode=${preferredPaymentMode}    lastPaymentModeUsed=${jaldeePaymentmode[0]}
    ${bankInfo}=    Create List         ${bankInfo}                
    ${resp}=  Create Vendor  ${category_id1}  ${vendorId}  ${vender_name}   ${contactPersonName}    ${address}    ${state}    ${pin}   ${vendor_phno}   ${email}     bankInfo=${bankInfo}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${vendor_uid1}   ${resp.json()['uid']}
    Set Suite Variable   ${vendor_id1}   ${resp.json()['id']}

    ${resp}=  db.getType   ${pdffile}
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${pdffile}
    Set Suite Variable    ${fileType}
    ${caption}=  Fakerlibrary.Sentence
    Set Suite Variable    ${caption}

    ${Attachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${account_id1}    ownerType=${ownerType[1]}    ownerName=${userName}   fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${Attachments}
    ${uploadedDocuments}=    Create List         ${Attachments}  

    ${payableLabel}=   FakerLibrary.word
    ${receivedDate}=   db.get_date_by_timezone  ${tz}
    ${amount}=   Random Int  min=500  max=2000
    ${amount}=     roundval    ${amount}   1
 
    ${paymentMode}=    Create Dictionary   paymentMode=${finance_payment_modes[0]}
    ${resp}=  Create PaymentsIn   ${amount}  ${category_id2}  ${receivedDate}   ${payableLabel}     ${vendor_uid1}    ${paymentMode}    uploadedDocuments=${uploadedDocuments}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable   ${payable_uid1}   ${resp.json()['uid']}
    Set Suite Variable   ${payable_id1}   ${resp.json()['id']}

    ${resp}=  Get PaymentsIn By Id   ${payable_uid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['paymentsInCategoryId']}  ${category_id2}
    Should Be Equal As Strings  ${resp.json()['categoryName']}  ${name1}
    Should Be Equal As Strings  ${resp.json()['paymentsInLabel']}  ${payableLabel}
    Should Be Equal As Strings  ${resp.json()['amount']}  ${amount}
    Should Be Equal As Strings  ${resp.json()['paymentsInUid']}  ${payable_uid1}
    Should Be Equal As Strings  ${resp.json()['receivedDate']}  ${receivedDate}
    Should Be Equal As Strings  ${resp.json()['uploadedDocuments'][0]['fileName']}  ${pdffile}
    Should Be Equal As Strings  ${resp.json()['uploadedDocuments'][0]['fileSize']}  ${fileSize}
    Should Be Equal As Strings  ${resp.json()['uploadedDocuments'][0]['caption']}  ${caption}
    Should Be Equal As Strings  ${resp.json()['uploadedDocuments'][0]['fileType']}  ${fileType}
    Should Be Equal As Strings  ${resp.json()['paymentInfo']['paymentMode']}  ${finance_payment_modes[0]}





JD-TC-Create PaymentsIn-2

    [Documentation]  Create a PaymentIn with an attchment contain drive id.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${payableLabel}=   FakerLibrary.word
    ${receivedDate}=   db.get_date_by_timezone  ${tz}
    ${amount}=   Random Int  min=500  max=2000
    ${amount}=     roundval    ${amount}   1

     ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType1}
    ${caption1}=  Fakerlibrary.Sentence
    Set Suite Variable    ${caption1}
    ${merchantId}=   FakerLibrary.word
    Set Suite Variable   ${merchantId}
    ${merchantKey}=   FakerLibrary.word
    Set Suite Variable   ${merchantKey}
    ${orderId}=   FakerLibrary.word
    Set Suite Variable   ${orderId}
    ${gatewayTxnId}=   FakerLibrary.word
    Set Suite Variable   ${gatewayTxnId}
    ${upiId}=   FakerLibrary.word
    Set Suite Variable   ${upiId}
    ${bankaccountNo}=  Generate_random_value  size=16  chars=string.digits
    Set Suite Variable   ${bankaccountNo}
    ${ifsc}=  Generate_ifsc_code
    Set Suite Variable   ${ifsc}
    ${bankName}=  FakerLibrary.company
    Set Suite Variable   ${bankName}
    ${branchName}=   FakerLibrary.word
    Set Suite Variable   ${branchName}
    ${gstNumber}  ${pancardNo}=   db.Generate_gst_number   ${Container_id}
    Set Suite Variable   ${gstNumber}
    Set Suite Variable   ${pancardNo}
    ${bankCheckNo}=   FakerLibrary.word
    Set Suite Variable   ${bankCheckNo}


    ${resp}    upload file to temporary location    ${LoanAction[0]}    ${pid}    ${ownerType[0]}    ${userName}    ${jpgfile}    ${fileSize}    ${caption}    ${fileType}    ${EMPTY}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Set Suite Variable    ${driveId}    ${resp.json()[0]['driveId']}

    ${Attachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType1}  order=${order}  driveId=${driveId}
    Log  ${Attachments}
    ${uploadedDocuments}=  Create List   ${Attachments}
    Set Suite Variable    ${uploadedDocuments}

    ${paymentMode}=    Create Dictionary   paymentMode=${finance_payment_modes[1]}    merchantId=${merchantId}    merchantKey=${merchantKey}    paymentGateway=${paymentGateway[1]}    orderId=${orderId}    gatewayTxnId=${gatewayTxnId}    upiId=${upiId}      bankaccountNo=${bankaccountNo}   ifscCode=${ifsc}    bankName=${bankName}    branchName=${branchName}    pancardNo=${pancardNo}    gstNumber=${gstNumber}    bankCheckNo=${bankCheckNo} 

    ${resp}=  Create PaymentsIn   ${amount}  ${category_id2}  ${receivedDate}   ${payableLabel}     ${vendor_uid1}   ${paymentMode}    uploadedDocuments=${uploadedDocuments}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${payable_uid1}   ${resp.json()['uid']}
    Set Suite Variable   ${payable_id1}   ${resp.json()['id']}

    ${resp}=  Get PaymentsIn By Id   ${payable_uid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['paymentsInCategoryId']}  ${category_id2}
    Should Be Equal As Strings  ${resp.json()['categoryName']}  ${name1}
    Should Be Equal As Strings  ${resp.json()['paymentsInLabel']}  ${payableLabel}
    Should Be Equal As Strings  ${resp.json()['amount']}  ${amount}
    Should Be Equal As Strings  ${resp.json()['paymentsInUid']}  ${payable_uid1}
    Should Be Equal As Strings  ${resp.json()['receivedDate']}  ${receivedDate}
    Should Be Equal As Strings  ${resp.json()['uploadedDocuments'][0]['fileName']}  ${pdffile}
    Should Be Equal As Strings  ${resp.json()['uploadedDocuments'][0]['fileSize']}  ${fileSize}
    Should Be Equal As Strings  ${resp.json()['uploadedDocuments'][0]['caption']}  ${caption1}
    Should Be Equal As Strings  ${resp.json()['uploadedDocuments'][0]['fileType']}  ${fileType1}
    Should Be Equal As Strings  ${resp.json()['uploadedDocuments'][0]['driveId']}  ${driveId}
    Should Be Equal As Strings  ${resp.json()['paymentInfo']['merchantId']}  ${merchantId}
    Should Be Equal As Strings  ${resp.json()['paymentInfo']['merchantKey']}  ${merchantKey}
    Should Be Equal As Strings  ${resp.json()['paymentInfo']['paymentGateway']}  ${paymentGateway[1]}
    Should Be Equal As Strings  ${resp.json()['paymentInfo']['paymentMode']}  ${finance_payment_modes[1]}
    Should Be Equal As Strings  ${resp.json()['paymentInfo']['orderId']}  ${orderId}
    Should Be Equal As Strings  ${resp.json()['paymentInfo']['gatewayTxnId']}  ${gatewayTxnId}
    Should Be Equal As Strings  ${resp.json()['paymentInfo']['upiId']}  ${upiId}
    Should Be Equal As Strings  ${resp.json()['paymentInfo']['bankaccountNo']}  ${bankaccountNo}
    Should Be Equal As Strings  ${resp.json()['paymentInfo']['ifscCode']}  ${ifsc}
    Should Be Equal As Strings  ${resp.json()['paymentInfo']['bankName']}  ${bankName}
    Should Be Equal As Strings  ${resp.json()['paymentInfo']['branchName']}  ${branchName}
    Should Be Equal As Strings  ${resp.json()['paymentInfo']['pancardNo']}  ${pancardNo}
    Should Be Equal As Strings  ${resp.json()['paymentInfo']['gstNumber']}  ${gstNumber}
    Should Be Equal As Strings  ${resp.json()['paymentInfo']['bankCheckNo']}  ${bankCheckNo}





JD-TC-Create PaymentsIn-UH1

    [Documentation]  Create a Payable with empty category id..

    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${payableLabel}=   FakerLibrary.word
    ${receivedDate}=   db.get_date_by_timezone  ${tz}
    ${amount}=   Random Int  min=500  max=2000
 
    ${paymentMode}=    Create Dictionary   paymentMode=${finance_payment_modes[0]}
    ${resp}=  Create PaymentsIn   ${amount}  ${EMPTY}  ${receivedDate}   ${payableLabel}     ${vendor_uid1}    ${paymentMode}    uploadedDocuments=${uploadedDocuments}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${INVALID_PAYMENTSIN_CATEGORY}

JD-TC-Create PaymentsIn-UH2

    [Documentation]  Create a Payable with empty received date.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${payableLabel}=   FakerLibrary.word
    ${receivedDate}=   db.get_date_by_timezone  ${tz}
    ${amount}=   Random Int  min=500  max=2000
    ${paymentMode}=    Create Dictionary   paymentMode=${finance_payment_modes[0]}
    ${resp}=  Create PaymentsIn   ${amount}  ${category_id2}  ${EMPTY}   ${payableLabel}     ${vendor_uid1}    ${paymentMode}    uploadedDocuments=${uploadedDocuments}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${RECEIVED_DATE_CANNOT_BE_EMPTY}

JD-TC-Create PaymentsIn-UH3

    [Documentation]   Create PaymentsIn without login

    ${payableLabel}=   FakerLibrary.word
    ${receivedDate}=   db.get_date_by_timezone  ${tz}
    ${amount}=   Random Int  min=500  max=2000

    ${paymentMode}=    Create Dictionary   paymentMode=${finance_payment_modes[0]}
    ${resp}=  Create PaymentsIn   ${amount}  ${category_id2}  ${receivedDate}   ${payableLabel}     ${vendor_uid1}    ${paymentMode}    uploadedDocuments=${uploadedDocuments}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-Create PaymentsIn-UH4

    [Documentation]   Create Category Using Consumer Login

    ${resp}=  ConsumerLogin  ${CUSERNAME1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${payableLabel}=   FakerLibrary.word
    ${receivedDate}=   db.get_date_by_timezone  ${tz}
    ${amount}=   Random Int  min=500  max=2000

    ${paymentMode}=    Create Dictionary   paymentMode=${finance_payment_modes[0]}
    ${resp}=  Create PaymentsIn   ${amount}  ${category_id2}  ${receivedDate}   ${payableLabel}     ${vendor_uid1}    ${paymentMode}    uploadedDocuments=${uploadedDocuments}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   ${resp.json()}   ${LOGIN_NO_ACCESS_FOR_URL}

JD-TC-Create PaymentsIn-UH5

    [Documentation]  Create Paymentout with empty  amount.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${payableLabel}=   FakerLibrary.word
    ${receivedDate}=   db.get_date_by_timezone  ${tz}
    ${amount}=   Random Int  min=500  max=2000

    ${paymentMode}=    Create Dictionary   paymentMode=${finance_payment_modes[0]}
    ${resp}=  Create PaymentsIn   ${EMPTY}  ${category_id2}  ${receivedDate}   ${payableLabel}     ${vendor_uid1}    ${paymentMode}    uploadedDocuments=${uploadedDocuments}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${Please_enter_an_amount}

JD-TC-Create PaymentsIn-UH6

    [Documentation]  Create a Payable with empty vendor id.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${payableLabel}=   FakerLibrary.word
    ${receivedDate}=   db.get_date_by_timezone  ${tz}
    ${amount}=   Random Int  min=500  max=2000
    ${paymentMode}=    Create Dictionary   paymentMode=${finance_payment_modes[0]}
    ${resp}=  Create PaymentsIn   ${amount}  ${category_id2}  ${receivedDate}   ${payableLabel}     ${EMPTY}    ${paymentMode}    uploadedDocuments=${uploadedDocuments}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${INVALID_VENDOR}
