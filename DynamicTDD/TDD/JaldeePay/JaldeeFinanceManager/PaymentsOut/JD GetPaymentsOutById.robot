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

JD-TC-Get PaymentsOut-1

    [Documentation]  Create a Payable.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME49}  ${PASSWORD}
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
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}

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
    Set Test Variable  ${email}  ${vender_name}.${test_mail}
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
    Set Suite Variable   ${vendor_uid1}   ${resp.json()['encId']}
    Set Suite Variable   ${vendor_id1}   ${resp.json()['id']}

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date_by_timezone  ${tz}
    ${amount}=   Random Int  min=500  max=2000
    ${amount}=     roundoff    ${amount}   1

    ${resp}=  Create PaymentsOut   ${amount}  ${category_id2}  ${dueDate}   ${payableLabel}    ${description}    ${referenceNo}    ${vendor_uid1}     ${status_id0}    ${Payment_Statuses[0]}    ${finance_payment_modes[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${payable_uid1}   ${resp.json()['uid']}
    Set Suite Variable   ${payable_id1}   ${resp.json()['id']}

    ${resp}=  Get PaymentsOut By Id   ${payable_uid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['paymentsOutCategoryId']}  ${category_id2}
    Should Be Equal As Strings  ${resp.json()['categoryName']}  ${name1}
    Should Be Equal As Strings  ${resp.json()['paymentsOutLabel']}  ${payableLabel}
    Should Be Equal As Strings  ${resp.json()['description']}  ${description}
    Should Be Equal As Strings  ${resp.json()['amount']}  ${amount}
    Should Be Equal As Strings  ${resp.json()['referenceNo']}  ${referenceNo}
    Should Be Equal As Strings  ${resp.json()['paidDate']}  ${dueDate}
    Should Be Equal As Strings  ${resp.json()['paymentsOutUid']}  ${payable_uid1}
    Should Be Equal As Strings  ${resp.json()['paymentsOutStatus']}  ${status_id0}
    Should Be Equal As Strings  ${resp.json()['paymentInfo']['paymentMode']}  ${finance_payment_modes[0]}

JD-TC-Get PaymentsOut-2

    [Documentation]  Update PaymentOut and Get PaymentsOut By Id

    ${resp}=  Encrypted Provider Login  ${PUSERNAME49}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}

    Set Suite Variable  ${pid}  ${decrypted_data['id']}
    Set Suite Variable    ${userName}    ${decrypted_data['userName']}
    Set Suite Variable    ${pdrfname}    ${decrypted_data['firstName']}
    Set Suite Variable    ${pdrlname}    ${decrypted_data['lastName']}
    
    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date_by_timezone  ${tz}
    ${amount}=   Random Int  min=500  max=2000
    ${amount}=     roundoff    ${amount}   1
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



    ${resp}=  Update PaymentsOut   ${payable_uid1}    ${amount}  ${category_id2}  ${dueDate}   ${payableLabel}    ${description}    ${referenceNo}    ${vendor_uid1}    ${SPACE}    ${Payment_Statuses[0]}    ${finance_payment_modes[4]}      merchantId=${merchantId}    merchantKey=${merchantKey}    paymentGateway=${paymentGateway[1]}    orderId=${orderId}    gatewayTxnId=${gatewayTxnId}    upiId=${upiId}      bankaccountNo=${bankaccountNo}   ifscCode=${ifsc}    bankName=${bankName}    branchName=${branchName}    pancardNo=${pancardNo}    gstNumber=${gstNumber}    bankCheckNo=${bankCheckNo}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Get PaymentsOut By Id   ${payable_uid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['paymentsOutCategoryId']}  ${category_id2}
    Should Be Equal As Strings  ${resp.json()['categoryName']}  ${name1}
    Should Be Equal As Strings  ${resp.json()['paymentsOutLabel']}  ${payableLabel}
    Should Be Equal As Strings  ${resp.json()['description']}  ${description}
    Should Be Equal As Strings  ${resp.json()['amount']}  ${amount}
    Should Be Equal As Strings  ${resp.json()['referenceNo']}  ${referenceNo}
    Should Be Equal As Strings  ${resp.json()['paidDate']}  ${dueDate}
    Should Be Equal As Strings  ${resp.json()['paymentsOutUid']}  ${payable_uid1}
    Should Be Equal As Strings  ${resp.json()['paymentsOutStatus']}  ${status_id0}
    Should Be Equal As Strings  ${resp.json()['paymentInfo']['paymentMode']}  ${finance_payment_modes[4]}
    Should Be Equal As Strings  ${resp.json()['paymentInfo']['merchantId']}  ${merchantId}
    Should Be Equal As Strings  ${resp.json()['paymentInfo']['merchantKey']}  ${merchantKey}
    Should Be Equal As Strings  ${resp.json()['paymentInfo']['paymentGateway']}  ${paymentGateway[1]}
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

JD-TC-Get PaymentsOut-3

    [Documentation]  Update PaymentsOut Status and Get PaymentsOut By Id

    ${resp}=  Encrypted Provider Login  ${PUSERNAME49}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  Create Finance Status   ${New_status[0]}  ${categoryType[2]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${status_id1}   ${resp.json()}

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date_by_timezone  ${tz}
    ${amount}=   Random Int  min=500  max=2000
    ${amount}=     roundoff    ${amount}   1



    ${resp}=  Update PaymentsOut   ${payable_uid1}    ${amount}  ${category_id2}  ${dueDate}   ${payableLabel}    ${description}    ${referenceNo}    ${vendor_uid1}    ${SPACE}    ${Payment_Statuses[0]}    ${finance_payment_modes[4]}    merchantId=${merchantId}    merchantKey=${merchantKey}    paymentGateway=${paymentGateway[1]}    orderId=${orderId}    gatewayTxnId=${gatewayTxnId}    upiId=${upiId}      bankaccountNo=${bankaccountNo}   ifscCode=${ifsc}    bankName=${bankName}    branchName=${branchName}    pancardNo=${pancardNo}    gstNumber=${gstNumber}    bankCheckNo=${bankCheckNo} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
     ${resp}=  Update PaymentsOut Status   ${payable_uid1}    ${status_id1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get PaymentsOut By Id   ${payable_uid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['paymentsOutCategoryId']}  ${category_id2}
    Should Be Equal As Strings  ${resp.json()['categoryName']}  ${name1}
    Should Be Equal As Strings  ${resp.json()['paymentsOutLabel']}  ${payableLabel}
    Should Be Equal As Strings  ${resp.json()['description']}  ${description}
    Should Be Equal As Strings  ${resp.json()['amount']}  ${amount}
    Should Be Equal As Strings  ${resp.json()['referenceNo']}  ${referenceNo}
    Should Be Equal As Strings  ${resp.json()['paidDate']}  ${dueDate}
    Should Be Equal As Strings  ${resp.json()['paymentsOutUid']}  ${payable_uid1}
    Should Be Equal As Strings  ${resp.json()['paymentsOutStatus']}  ${status_id1}
    Should Be Equal As Strings  ${resp.json()['paymentInfo']['paymentMode']}  ${finance_payment_modes[4]}
    Should Be Equal As Strings  ${resp.json()['paymentInfo']['merchantId']}  ${merchantId}
    Should Be Equal As Strings  ${resp.json()['paymentInfo']['merchantKey']}  ${merchantKey}
    Should Be Equal As Strings  ${resp.json()['paymentInfo']['paymentGateway']}  ${paymentGateway[1]}
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

JD-TC-Get PaymentsOut-4

    [Documentation]  Create a Payable with empty payableLabel and  Get PaymentsOut By Id .

    ${resp}=  Encrypted Provider Login  ${PUSERNAME49}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date_by_timezone  ${tz}
    ${amount}=   Random Int  min=500  max=2000
    ${amount}=     roundoff    ${amount}   1
    ${paymentsOutStatus}=   FakerLibrary.word
    ${paymentStatus}=   FakerLibrary.word

    ${resp}=  Create PaymentsOut   ${amount}  ${category_id2}  ${dueDate}   ${EMPTY}    ${description}    ${referenceNo}    ${vendor_uid1}    ${status_id0}    ${Payment_Statuses[0]}    ${finance_payment_modes[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${payable_uid2}   ${resp.json()['uid']}

    ${resp}=  Get PaymentsOut By Id   ${payable_uid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['paymentsOutCategoryId']}  ${category_id2}
    Should Be Equal As Strings  ${resp.json()['categoryName']}  ${name1}
    Should Be Equal As Strings  ${resp.json()['paymentsOutLabel']}  ${EMPTY}
    Should Be Equal As Strings  ${resp.json()['description']}  ${description}
    Should Be Equal As Strings  ${resp.json()['amount']}  ${amount}
    Should Be Equal As Strings  ${resp.json()['referenceNo']}  ${referenceNo}
    Should Be Equal As Strings  ${resp.json()['paidDate']}  ${dueDate}
    Should Be Equal As Strings  ${resp.json()['paymentsOutUid']}  ${payable_uid2}
    Should Be Equal As Strings  ${resp.json()['paymentsOutStatus']}  ${status_id0}
    Should Be Equal As Strings  ${resp.json()['paymentInfo']['paymentMode']}  ${finance_payment_modes[0]}

JD-TC-Get PaymentsOut-UH1

    [Documentation]   Get PaymentsOut By Id with invalid id.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME49}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${fakeid}=   FakerLibrary.Random Number

    ${resp}=  Get PaymentsOut By Id   ${fakeid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${INVALID_PAYMENTSOUT_ID}

JD-TC-Get PaymentsOut-UH2

    [Documentation]   Get PaymentsOut By Id  without login.

    ${resp}=  Get PaymentsOut By Id   ${payable_uid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-Get PaymentsOut-UH3

    [Documentation]   Get PaymentsOut By Id using another Encrypted Provider Login

    ${resp}=  Encrypted Provider Login  ${PUSERNAME133}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}

    Set Suite Variable  ${pid}  ${decrypted_data['id']}
    Set Suite Variable    ${userName}    ${decrypted_data['userName']}
    Set Suite Variable    ${pdrfname}    ${decrypted_data['firstName']}
    Set Suite Variable    ${pdrlname}    ${decrypted_data['lastName']}

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

    ${fakeid}=   FakerLibrary.Random Number

    ${resp}=  Get PaymentsOut By Id   ${payable_uid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${INVALID_PAYMENTSOUT_ID}
    
