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
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 

*** Variables ***

@{service_names}

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

JD-TC-Update PaymentsOut With Expense--1

    [Documentation]  Create a Payable.


    ${resp}=  Encrypted Provider Login  ${PUSERNAME320}  ${PASSWORD}
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


    ${resp}=  Get Category List Configuration  ${categoryType[2]}    
    Log  ${resp.json()}

    ${name}=   FakerLibrary.word
    ${resp}=  CreateVendorCategory  ${name}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${category_id}   ${resp.json()}

    ${resp}=  Get by encId  ${category_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}          ${name}
    Should Be Equal As Strings  ${resp.json()['status']}        ${toggle[0]}
    
    ${name}=   FakerLibrary.word
    ${resp}=  Create Category   ${name}  ${categoryType[1]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${category_id1}   ${resp.json()}

    ${name1}=   FakerLibrary.word
    Set Suite Variable   ${name1} 
    ${resp}=  Create Category   ${name1}  ${categoryType[2]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${category_id2}   ${resp.json()}

    ${resp}=  Get Category By Id   ${category_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${vender_name}=   FakerLibrary.firstname
    ${contactPersonName}=   FakerLibrary.lastname
    ${owner_name}=   FakerLibrary.lastname
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
    # ${gst_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}

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
    
    ${resp}=  Create Vendor  ${category_id}  ${vendorId}  ${vender_name}   ${contactPersonName}    ${address}    ${state}    ${pin}   ${vendor_phno}   ${email}     bankInfo=${bankInfo}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${vendor_uid1}   ${resp.json()['encId']}
    Set Suite Variable   ${vendor_id1}   ${resp.json()['id']}

    ${resp}=  Get vendor by encId   ${vendor_uid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200



    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${expenseFor}=   FakerLibrary.word
    ${expenseDate}=   db.get_date_by_timezone  ${tz}
    ${amount}=   Random Int  min=5000  max=10000
    ${amount}=     roundoff    ${amount}   1
    Set Suite Variable    ${amount}

    ${employeeName}=   FakerLibrary.name
    ${item}=   FakerLibrary.word
    ${quantity}=   Random Int  min=5  max=10
    ${rate}=   Random Int  min=50  max=1000


    ${deptId}=   Random Int  min=50  max=100
    ${deptName}=  FakerLibrary.word
    ${userName}=    FakerLibrary.name

    ${itemList}=  Create Dictionary  item=${item}   quantity=${quantity}  rate=${rate}    amount=${amount}
    ${itemList}=    Create List    ${itemList}

    ${departmentList}=  Create Dictionary  deptId=${deptId}   deptName=${deptName}  
    ${departmentList}=    Create List    ${departmentList}

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
    
    ${Attachments}=    Create Dictionary   action=${FileAction[0]}  owner=${account_id1}    ownerType=${ownerType[1]}    ownerName=${userName}   fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${Attachments}
    ${uploadedDocuments}=    Create List    ${Attachments}
  
    
    ${resp}=  Create Expense  ${category_id1}  ${amount}  ${expenseDate}   ${expenseFor}   ${vendor_uid1}   ${description}   ${referenceNo}    ${employeeName}      ${itemList}     ${departmentList}    ${uploadedDocuments}    locationId=${lid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${expense_uid}   ${resp.json()['uid']}

    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date_by_timezone  ${tz}



    ${amount1}=  Evaluate  ${amount}-4000
    ${amount1}=     roundoff    ${amount1}   1


    ${resp}=  Create PaymentsOut With Expense   ${amount1}    ${dueDate}   ${payableLabel}   ${finance_payment_modes[0]}   ${bool[1]}    ${expense_uid}   ${lid}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${payable_uid1}   ${resp.json()['uid']}

    ${resp}=  Get PaymentsOut By Id   ${payable_uid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Get Expense By Id   ${expense_uid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${amount2}=  Evaluate  ${amount}-3900
    ${amount2}=     roundoff    ${amount2}   1

    ${resp}=  Update PaymentsOut With Expense   ${payable_uid1}    ${category_id2}   ${name1}    ${amount2}   ${finance_payment_modes[0]}  ${dueDate}    ${lid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${payable_uid1}   ${resp.json()['uid']}


    ${resp}=  Get Expense By Id   ${expense_uid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get PaymentsOut By Id   ${payable_uid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['paymentsOutLabel']}  ${payableLabel}
    Should Be Equal As Strings  ${resp.json()['amount']}  ${amount2}
    Should Be Equal As Strings  ${resp.json()['expenseUuid']}  ${expense_uid}
    Should Be Equal As Strings  ${resp.json()['paidDate']}  ${dueDate}
    Should Be Equal As Strings  ${resp.json()['paymentsOutUid']}  ${payable_uid1}
    Should Be Equal As Strings  ${resp.json()['paymentInfo']['paymentMode']}  ${finance_payment_modes[0]}
    # Should Be Equal As Strings  ${resp.json()['paymentsOutCategoryId']}  ${category_id2}






JD-TC-Update PaymentsOut With Expense--2

    [Documentation]  Create a PaymentOut where payment mode is cc Then update with Cash.


    ${resp}=  Encrypted Provider Login  ${PUSERNAME320}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Expense By Id   ${expense_uid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${due_amount}   ${resp.json()['amountDue']}

    ${due_amount2}=  Evaluate  ${due_amount}-3800
    ${due_amount2}=     roundoff    ${due_amount2}   1

    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date_by_timezone  ${tz}

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date_by_timezone  ${tz}
    ${paymentsOutStatus}=   FakerLibrary.word
    ${paymentStatus}=   FakerLibrary.word
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


    ${resp}=  Create PaymentsOut With Expense   ${due_amount2}    ${dueDate}   ${payableLabel}   ${finance_payment_modes[1]}    ${bool[1]}    ${expense_uid}   ${lid}   merchantId=${merchantId}    merchantKey=${merchantKey}    paymentGateway=${paymentGateway[1]}    orderId=${orderId}    gatewayTxnId=${gatewayTxnId}    upiId=${upiId}      bankaccountNo=${bankaccountNo}   ifscCode=${ifsc}    bankName=${bankName}    branchName=${branchName}    pancardNo=${pancardNo}    gstNumber=${gstNumber}    bankCheckNo=${bankCheckNo}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${payable_uid1}   ${resp.json()['uid']}


    ${resp}=  Get PaymentsOut By Id   ${payable_uid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${due_amount2}=  Evaluate  ${due_amount}-3700
    ${due_amount2}=     roundoff    ${due_amount2}   1

    ${resp}=  Update PaymentsOut With Expense   ${payable_uid1}    ${category_id2}   ${name1}    ${due_amount2}   ${finance_payment_modes[0]}  ${dueDate}   ${lid}    
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${payable_uid1}   ${resp.json()['uid']}

    ${resp}=  Get PaymentsOut By Id   ${payable_uid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['paymentsOutLabel']}  ${payableLabel}
    Should Be Equal As Strings  ${resp.json()['amount']}  ${due_amount2}
    Should Be Equal As Strings  ${resp.json()['expenseUuid']}  ${expense_uid}
    Should Be Equal As Strings  ${resp.json()['paidDate']}  ${dueDate}
    Should Be Equal As Strings  ${resp.json()['paymentsOutUid']}  ${payable_uid1}
    Should Be Equal As Strings  ${resp.json()['paymentInfo']['paymentMode']}  ${finance_payment_modes[0]}
    # Should Be Equal As Strings  ${resp.json()['paymentsOutCategoryId']}  ${category_id2}


JD-TC-Update PaymentsOut With Expense--3

    [Documentation]  Create a PaymentOut where payment mode is dc Then update with Cash.


    ${resp}=  Encrypted Provider Login  ${PUSERNAME320}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date_by_timezone  ${tz}
     ${amount}=   Random Int  min=500  max=2000
    ${amount}=     roundoff    ${amount}   1

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${resp}=  Get Expense By Id   ${expense_uid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${due_amount}   ${resp.json()['amountDue']}

    ${due_amount2}=  Evaluate  ${due_amount}-3600
    ${due_amount2}=     roundoff    ${due_amount2}   1



    ${resp}=  Create PaymentsOut With Expense   ${due_amount2}    ${dueDate}   ${payableLabel}   ${finance_payment_modes[12]}    ${bool[1]}    ${expense_uid}  ${lid}      merchantId=${merchantId}    merchantKey=${merchantKey}    paymentGateway=${paymentGateway[1]}    orderId=${orderId}    gatewayTxnId=${gatewayTxnId}    upiId=${upiId}      bankaccountNo=${bankaccountNo}   ifscCode=${ifsc}    bankName=${bankName}    branchName=${branchName}    pancardNo=${pancardNo}    gstNumber=${gstNumber}    bankCheckNo=${bankCheckNo}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${payable_uid1}   ${resp.json()['uid']}


    ${resp}=  Get PaymentsOut By Id   ${payable_uid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${due_amount2}=  Evaluate  ${due_amount}-3500
    ${due_amount2}=     roundoff    ${due_amount2}   1

    ${resp}=  Update PaymentsOut With Expense   ${payable_uid1}    ${category_id2}   ${name1}    ${due_amount2}   ${finance_payment_modes[0]}  ${dueDate}     ${lid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${payable_uid1}   ${resp.json()['uid']}

    ${resp}=  Get PaymentsOut By Id   ${payable_uid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['paymentsOutLabel']}  ${payableLabel}
    Should Be Equal As Strings  ${resp.json()['amount']}  ${due_amount2}
    Should Be Equal As Strings  ${resp.json()['expenseUuid']}  ${expense_uid}
    Should Be Equal As Strings  ${resp.json()['paidDate']}  ${dueDate}
    Should Be Equal As Strings  ${resp.json()['paymentsOutUid']}  ${payable_uid1}
    Should Be Equal As Strings  ${resp.json()['paymentInfo']['paymentMode']}  ${finance_payment_modes[0]}


JD-TC-Update PaymentsOut With Expense--4

    [Documentation]  Create a PaymentOut where payment mode is NB Then update with Cash.


    ${resp}=  Encrypted Provider Login  ${PUSERNAME320}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date_by_timezone  ${tz}
     ${amount}=   Random Int  min=500  max=2000
    ${amount}=     roundoff    ${amount}   1

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${resp}=  Get Expense By Id   ${expense_uid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${due_amount}   ${resp.json()['amountDue']}

    ${due_amount2}=  Evaluate  ${due_amount}-3400
    ${due_amount2}=     roundoff    ${due_amount2}   1

    ${resp}=  Create PaymentsOut With Expense   ${due_amount2}    ${dueDate}   ${payableLabel}   ${finance_payment_modes[8]}    ${bool[1]}    ${expense_uid}    ${lid}      merchantId=${merchantId}    merchantKey=${merchantKey}    paymentGateway=${paymentGateway[1]}    orderId=${orderId}    gatewayTxnId=${gatewayTxnId}    upiId=${upiId}      bankaccountNo=${bankaccountNo}   ifscCode=${ifsc}    bankName=${bankName}    branchName=${branchName}    pancardNo=${pancardNo}    gstNumber=${gstNumber}    bankCheckNo=${bankCheckNo}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${payable_uid1}   ${resp.json()['uid']}


    ${resp}=  Get PaymentsOut By Id   ${payable_uid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${due_amount2}=  Evaluate  ${due_amount}-3300
    ${due_amount2}=     roundoff    ${due_amount2}   1

    ${resp}=  Update PaymentsOut With Expense   ${payable_uid1}    ${category_id2}   ${name1}    ${due_amount2}   ${finance_payment_modes[0]}  ${dueDate}   ${lid}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${payable_uid1}   ${resp.json()['uid']}

    ${resp}=  Get PaymentsOut By Id   ${payable_uid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['paymentsOutLabel']}  ${payableLabel}
    Should Be Equal As Strings  ${resp.json()['amount']}  ${due_amount2}
    Should Be Equal As Strings  ${resp.json()['expenseUuid']}  ${expense_uid}
    Should Be Equal As Strings  ${resp.json()['paidDate']}  ${dueDate}
    Should Be Equal As Strings  ${resp.json()['paymentsOutUid']}  ${payable_uid1}
    Should Be Equal As Strings  ${resp.json()['paymentInfo']['paymentMode']}  ${finance_payment_modes[0]}


JD-TC-Update PaymentsOut With Expense--5

    [Documentation]  Create a PaymentOut where payment mode is UPI Then update with Cash.


    ${resp}=  Encrypted Provider Login  ${PUSERNAME320}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date_by_timezone  ${tz}
     ${amount}=   Random Int  min=500  max=2000
    ${amount}=     roundoff    ${amount}   1

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${resp}=  Get Expense By Id   ${expense_uid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${due_amount}   ${resp.json()['amountDue']}

    ${due_amount2}=  Evaluate  ${due_amount}-3200
    ${due_amount2}=     roundoff    ${due_amount2}   1

    ${resp}=  Create PaymentsOut With Expense   ${due_amount2}    ${dueDate}   ${payableLabel}   ${finance_payment_modes[6]}    ${bool[1]}    ${expense_uid}   ${lid}      merchantId=${merchantId}    merchantKey=${merchantKey}    paymentGateway=${paymentGateway[1]}    orderId=${orderId}    gatewayTxnId=${gatewayTxnId}    upiId=${upiId}      bankaccountNo=${bankaccountNo}   ifscCode=${ifsc}    bankName=${bankName}    branchName=${branchName}    pancardNo=${pancardNo}    gstNumber=${gstNumber}    bankCheckNo=${bankCheckNo}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${payable_uid1}   ${resp.json()['uid']}


    ${resp}=  Get PaymentsOut By Id   ${payable_uid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${due_amount2}=  Evaluate  ${due_amount}-3100
    ${due_amount2}=     roundoff    ${due_amount2}   1

    ${resp}=  Update PaymentsOut With Expense   ${payable_uid1}    ${category_id2}   ${name1}    ${due_amount2}   ${finance_payment_modes[0]}  ${dueDate}    ${lid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${payable_uid1}   ${resp.json()['uid']}

    ${resp}=  Get PaymentsOut By Id   ${payable_uid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['paymentsOutLabel']}  ${payableLabel}
    Should Be Equal As Strings  ${resp.json()['amount']}  ${due_amount2}
    Should Be Equal As Strings  ${resp.json()['expenseUuid']}  ${expense_uid}
    Should Be Equal As Strings  ${resp.json()['paidDate']}  ${dueDate}
    Should Be Equal As Strings  ${resp.json()['paymentsOutUid']}  ${payable_uid1}
    Should Be Equal As Strings  ${resp.json()['paymentInfo']['paymentMode']}  ${finance_payment_modes[0]}


JD-TC-Update PaymentsOut With Expense--6

    [Documentation]  Create a PaymentOut where payment mode is Other Then update with Cash.


    ${resp}=  Encrypted Provider Login  ${PUSERNAME320}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date_by_timezone  ${tz}
     ${amount}=   Random Int  min=500  max=2000
    ${amount}=     roundoff    ${amount}   1

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}


    ${resp}=  Get Expense By Id   ${expense_uid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${due_amount}   ${resp.json()['amountDue']}

    ${due_amount2}=  Evaluate  ${due_amount}-3000
    ${due_amount2}=     roundoff    ${due_amount2}   1

    ${resp}=  Create PaymentsOut With Expense   ${due_amount2}    ${dueDate}   ${payableLabel}   ${finance_payment_modes[7]}    ${bool[1]}    ${expense_uid}   ${lid}     merchantId=${merchantId}    merchantKey=${merchantKey}    paymentGateway=${paymentGateway[1]}    orderId=${orderId}    gatewayTxnId=${gatewayTxnId}    upiId=${upiId}      bankaccountNo=${bankaccountNo}   ifscCode=${ifsc}    bankName=${bankName}    branchName=${branchName}    pancardNo=${pancardNo}    gstNumber=${gstNumber}    bankCheckNo=${bankCheckNo}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${payable_uid1}   ${resp.json()['uid']}


    ${resp}=  Get PaymentsOut By Id   ${payable_uid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${due_amount2}=  Evaluate  ${due_amount}-2900
    ${due_amount2}=     roundoff    ${due_amount2}   1

    ${resp}=  Update PaymentsOut With Expense   ${payable_uid1}    ${category_id2}   ${name1}    ${due_amount2}   ${finance_payment_modes[0]}  ${dueDate}    ${lid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${payable_uid1}   ${resp.json()['uid']}

    ${resp}=  Get PaymentsOut By Id   ${payable_uid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['paymentsOutLabel']}  ${payableLabel}
    Should Be Equal As Strings  ${resp.json()['amount']}  ${due_amount2}
    Should Be Equal As Strings  ${resp.json()['expenseUuid']}  ${expense_uid}
    Should Be Equal As Strings  ${resp.json()['paidDate']}  ${dueDate}
    Should Be Equal As Strings  ${resp.json()['paymentsOutUid']}  ${payable_uid1}
    Should Be Equal As Strings  ${resp.json()['paymentInfo']['paymentMode']}  ${finance_payment_modes[0]}


JD-TC-Update PaymentsOut With Expense--7

    [Documentation]  Create a PaymentOut where payment mode is store credit Then update with Cash.


    ${resp}=  Encrypted Provider Login  ${PUSERNAME320}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date_by_timezone  ${tz}
     ${amount}=   Random Int  min=500  max=2000
    ${amount}=     roundoff    ${amount}   1

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${resp}=  Get Expense By Id   ${expense_uid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${due_amount}   ${resp.json()['amountDue']}

    ${due_amount2}=  Evaluate  ${due_amount}-2800
    ${due_amount2}=     roundoff    ${due_amount2}   1

    ${resp}=  Create PaymentsOut With Expense   ${due_amount2}    ${dueDate}   ${payableLabel}   ${finance_payment_modes[9]}    ${bool[1]}    ${expense_uid}   ${lid}    merchantId=${merchantId}    merchantKey=${merchantKey}    paymentGateway=${paymentGateway[1]}    orderId=${orderId}    gatewayTxnId=${gatewayTxnId}    upiId=${upiId}      bankaccountNo=${bankaccountNo}   ifscCode=${ifsc}    bankName=${bankName}    branchName=${branchName}    pancardNo=${pancardNo}    gstNumber=${gstNumber}    bankCheckNo=${bankCheckNo}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${payable_uid1}   ${resp.json()['uid']}


    ${resp}=  Get PaymentsOut By Id   ${payable_uid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${due_amount2}=  Evaluate  ${due_amount}-2700
    ${due_amount2}=     roundoff    ${due_amount2}   1

    ${resp}=  Update PaymentsOut With Expense   ${payable_uid1}    ${category_id2}   ${name1}    ${due_amount2}   ${finance_payment_modes[0]}  ${dueDate}   ${lid}    
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${payable_uid1}   ${resp.json()['uid']}

    ${resp}=  Get PaymentsOut By Id   ${payable_uid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['paymentsOutLabel']}  ${payableLabel}
    Should Be Equal As Strings  ${resp.json()['amount']}  ${due_amount2}
    Should Be Equal As Strings  ${resp.json()['expenseUuid']}  ${expense_uid}
    Should Be Equal As Strings  ${resp.json()['paidDate']}  ${dueDate}
    Should Be Equal As Strings  ${resp.json()['paymentsOutUid']}  ${payable_uid1}
    Should Be Equal As Strings  ${resp.json()['paymentInfo']['paymentMode']}  ${finance_payment_modes[0]}


JD-TC-Update PaymentsOut With Expense--8

    [Documentation]  Create a PaymentOut where payment mode is PAYLATER Then update with Cash.


    ${resp}=  Encrypted Provider Login  ${PUSERNAME320}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date_by_timezone  ${tz}
     ${amount}=   Random Int  min=500  max=2000
    ${amount}=     roundoff    ${amount}   1

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${resp}=  Get Expense By Id   ${expense_uid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${due_amount}   ${resp.json()['amountDue']}

    ${due_amount2}=  Evaluate  ${due_amount}-2600
    ${due_amount2}=     roundoff    ${due_amount2}   1

    ${resp}=  Create PaymentsOut With Expense   ${due_amount2}    ${dueDate}   ${payableLabel}   ${finance_payment_modes[4]}    ${bool[1]}    ${expense_uid}   ${lid}    merchantId=${merchantId}    merchantKey=${merchantKey}    paymentGateway=${paymentGateway[1]}    orderId=${orderId}    gatewayTxnId=${gatewayTxnId}    upiId=${upiId}      bankaccountNo=${bankaccountNo}   ifscCode=${ifsc}    bankName=${bankName}    branchName=${branchName}    pancardNo=${pancardNo}    gstNumber=${gstNumber}    bankCheckNo=${bankCheckNo}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${payable_uid1}   ${resp.json()['uid']}


    ${resp}=  Get PaymentsOut By Id   ${payable_uid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${due_amount2}=  Evaluate  ${due_amount}-2500
    ${due_amount2}=     roundoff    ${due_amount2}   1

    ${resp}=  Update PaymentsOut With Expense   ${payable_uid1}    ${category_id2}   ${name1}    ${due_amount2}   ${finance_payment_modes[0]}  ${dueDate}     ${lid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${payable_uid1}   ${resp.json()['uid']}

    ${resp}=  Get PaymentsOut By Id   ${payable_uid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['paymentsOutLabel']}  ${payableLabel}
    Should Be Equal As Strings  ${resp.json()['amount']}  ${due_amount2}
    Should Be Equal As Strings  ${resp.json()['expenseUuid']}  ${expense_uid}
    Should Be Equal As Strings  ${resp.json()['paidDate']}  ${dueDate}
    Should Be Equal As Strings  ${resp.json()['paymentsOutUid']}  ${payable_uid1}
    Should Be Equal As Strings  ${resp.json()['paymentInfo']['paymentMode']}  ${finance_payment_modes[0]}


JD-TC-Update PaymentsOut With Expense--9

    [Documentation]  Create a PaymentOut where payment mode is Offline Then update with Cash.


    ${resp}=  Encrypted Provider Login  ${PUSERNAME320}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date_by_timezone  ${tz}
     ${amount}=   Random Int  min=500  max=2000
    ${amount}=     roundoff    ${amount}   1

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}


    ${resp}=  Get Expense By Id   ${expense_uid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${due_amount}   ${resp.json()['amountDue']}

    ${due_amount2}=  Evaluate  ${due_amount}-2400
    ${due_amount2}=     roundoff    ${due_amount2}   1

    ${resp}=  Create PaymentsOut With Expense   ${due_amount2}    ${dueDate}   ${payableLabel}   ${finance_payment_modes[3]}    ${bool[1]}    ${expense_uid}    ${lid}    merchantId=${merchantId}    merchantKey=${merchantKey}    paymentGateway=${paymentGateway[1]}    orderId=${orderId}    gatewayTxnId=${gatewayTxnId}    upiId=${upiId}      bankaccountNo=${bankaccountNo}   ifscCode=${ifsc}    bankName=${bankName}    branchName=${branchName}    pancardNo=${pancardNo}    gstNumber=${gstNumber}    bankCheckNo=${bankCheckNo}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${payable_uid1}   ${resp.json()['uid']}


    ${resp}=  Get PaymentsOut By Id   ${payable_uid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${due_amount2}=  Evaluate  ${due_amount}-2300
    ${due_amount2}=     roundoff    ${due_amount2}   1

    ${resp}=  Update PaymentsOut With Expense   ${payable_uid1}    ${category_id2}   ${name1}    ${due_amount2}   ${finance_payment_modes[0]}  ${dueDate}   ${lid}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${payable_uid1}   ${resp.json()['uid']}

    ${resp}=  Get PaymentsOut By Id   ${payable_uid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['paymentsOutLabel']}  ${payableLabel}
    Should Be Equal As Strings  ${resp.json()['amount']}  ${due_amount2}
    Should Be Equal As Strings  ${resp.json()['expenseUuid']}  ${expense_uid}
    Should Be Equal As Strings  ${resp.json()['paidDate']}  ${dueDate}
    Should Be Equal As Strings  ${resp.json()['paymentsOutUid']}  ${payable_uid1}
    Should Be Equal As Strings  ${resp.json()['paymentInfo']['paymentMode']}  ${finance_payment_modes[0]}
    # Should Be Equal As Strings  ${resp.json()['paymentsOutCategoryId']}  ${category_id2}
    # Should Be Equal As Strings  ${resp.json()['categoryName']}  ${name1}

JD-TC-Update PaymentsOut With Expense--10

    [Documentation]  Create a PaymentOut where payment mode is Wallet Then update with Cash.


    ${resp}=  Encrypted Provider Login  ${PUSERNAME320}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date_by_timezone  ${tz}
     ${amount}=   Random Int  min=500  max=2000
    ${amount}=     roundoff    ${amount}   1

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${resp}=  Get Expense By Id   ${expense_uid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${due_amount}   ${resp.json()['amountDue']}

    ${due_amount2}=  Evaluate  ${due_amount}-2200
    ${due_amount2}=     roundoff    ${due_amount2}   1

    ${resp}=  Create PaymentsOut With Expense   ${due_amount2}    ${dueDate}   ${payableLabel}   ${finance_payment_modes[10]}    ${bool[1]}    ${expense_uid}   ${lid}    merchantId=${merchantId}    merchantKey=${merchantKey}    paymentGateway=${paymentGateway[1]}    orderId=${orderId}    gatewayTxnId=${gatewayTxnId}    upiId=${upiId}      bankaccountNo=${bankaccountNo}   ifscCode=${ifsc}    bankName=${bankName}    branchName=${branchName}    pancardNo=${pancardNo}    gstNumber=${gstNumber}    bankCheckNo=${bankCheckNo}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${payable_uid1}   ${resp.json()['uid']}


    ${resp}=  Get PaymentsOut By Id   ${payable_uid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${due_amount2}=  Evaluate  ${due_amount}-2100
    ${due_amount2}=     roundoff    ${due_amount2}   1

    ${resp}=  Update PaymentsOut With Expense   ${payable_uid1}    ${category_id2}   ${name1}    ${due_amount2}   ${finance_payment_modes[0]}  ${dueDate}    ${lid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${payable_uid1}   ${resp.json()['uid']}

    ${resp}=  Get PaymentsOut By Id   ${payable_uid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['paymentsOutLabel']}  ${payableLabel}
    Should Be Equal As Strings  ${resp.json()['amount']}  ${due_amount2}
    Should Be Equal As Strings  ${resp.json()['expenseUuid']}  ${expense_uid}
    Should Be Equal As Strings  ${resp.json()['paidDate']}  ${dueDate}
    Should Be Equal As Strings  ${resp.json()['paymentsOutUid']}  ${payable_uid1}
    Should Be Equal As Strings  ${resp.json()['paymentInfo']['paymentMode']}  ${finance_payment_modes[0]}


JD-TC-Update PaymentsOut With Expense--11

    [Documentation]  Create a PaymentOut where payment mode is PayLater Then update with Cash.


    ${resp}=  Encrypted Provider Login  ${PUSERNAME320}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date_by_timezone  ${tz}


    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${resp}=  Get Expense By Id   ${expense_uid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${due_amount}   ${resp.json()['amountDue']}

    ${due_amount2}=  Evaluate  ${due_amount}-2000
    ${due_amount2}=     roundoff    ${due_amount2}   1

    ${resp}=  Create PaymentsOut With Expense   ${due_amount2}    ${dueDate}   ${payableLabel}   ${finance_payment_modes[13]}    ${bool[1]}    ${expense_uid}   ${lid}    merchantId=${merchantId}    merchantKey=${merchantKey}    paymentGateway=${paymentGateway[1]}    orderId=${orderId}    gatewayTxnId=${gatewayTxnId}    upiId=${upiId}      bankaccountNo=${bankaccountNo}   ifscCode=${ifsc}    bankName=${bankName}    branchName=${branchName}    pancardNo=${pancardNo}    gstNumber=${gstNumber}    bankCheckNo=${bankCheckNo}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${payable_uid1}   ${resp.json()['uid']}


    ${resp}=  Get PaymentsOut By Id   ${payable_uid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${due_amount2}=  Evaluate  ${due_amount}-1900
    ${due_amount2}=     roundoff    ${due_amount2}   1

    ${resp}=  Update PaymentsOut With Expense   ${payable_uid1}    ${category_id2}   ${name1}    ${due_amount2}   ${finance_payment_modes[0]}  ${dueDate}   ${lid}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${payable_uid1}   ${resp.json()['uid']}


    ${resp}=  Get PaymentsOut By Id   ${payable_uid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['paymentsOutLabel']}  ${payableLabel}
    Should Be Equal As Strings  ${resp.json()['amount']}  ${due_amount2}
    Should Be Equal As Strings  ${resp.json()['expenseUuid']}  ${expense_uid}
    Should Be Equal As Strings  ${resp.json()['paidDate']}  ${dueDate}
    Should Be Equal As Strings  ${resp.json()['paymentsOutUid']}  ${payable_uid1}
    Should Be Equal As Strings  ${resp.json()['paymentInfo']['paymentMode']}  ${finance_payment_modes[0]}


JD-TC-Update PaymentsOut With Expense--12

    [Documentation]  Create a PaymentOut where payment mode is PAYTM_Postpaid Then update with Cash.


    ${resp}=  Encrypted Provider Login  ${PUSERNAME320}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date_by_timezone  ${tz}
     ${amount}=   Random Int  min=500  max=2000
    ${amount}=     roundoff    ${amount}   1

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${resp}=  Get Expense By Id   ${expense_uid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${due_amount}   ${resp.json()['amountDue']}

    ${due_amount2}=  Evaluate  ${due_amount}-1800
    ${due_amount2}=     roundoff    ${due_amount2}   1

    ${resp}=  Create PaymentsOut With Expense   ${due_amount2}    ${dueDate}   ${payableLabel}   ${finance_payment_modes[14]}    ${bool[1]}    ${expense_uid}   ${lid}   merchantId=${merchantId}    merchantKey=${merchantKey}    paymentGateway=${paymentGateway[1]}    orderId=${orderId}    gatewayTxnId=${gatewayTxnId}    upiId=${upiId}      bankaccountNo=${bankaccountNo}   ifscCode=${ifsc}    bankName=${bankName}    branchName=${branchName}    pancardNo=${pancardNo}    gstNumber=${gstNumber}    bankCheckNo=${bankCheckNo}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${payable_uid1}   ${resp.json()['uid']}


    ${resp}=  Get PaymentsOut By Id   ${payable_uid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${due_amount2}=  Evaluate  ${due_amount}-1700
    ${due_amount2}=     roundoff    ${due_amount2}   1

    ${resp}=  Update PaymentsOut With Expense   ${payable_uid1}    ${category_id2}   ${name1}    ${due_amount2}   ${finance_payment_modes[0]}  ${dueDate}     ${lid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${payable_uid1}   ${resp.json()['uid']}

    ${resp}=  Get PaymentsOut By Id   ${payable_uid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['paymentsOutLabel']}  ${payableLabel}
    Should Be Equal As Strings  ${resp.json()['amount']}  ${due_amount2}
    Should Be Equal As Strings  ${resp.json()['expenseUuid']}  ${expense_uid}
    Should Be Equal As Strings  ${resp.json()['paidDate']}  ${dueDate}
    Should Be Equal As Strings  ${resp.json()['paymentsOutUid']}  ${payable_uid1}
    Should Be Equal As Strings  ${resp.json()['paymentInfo']['paymentMode']}  ${finance_payment_modes[0]}


JD-TC-Update PaymentsOut With Expense--13

    [Documentation]  Create a PaymentOut where payment mode is EMI Then update with Cash.


    ${resp}=  Encrypted Provider Login  ${PUSERNAME320}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date_by_timezone  ${tz}


    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${resp}=  Get Expense By Id   ${expense_uid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${due_amount}   ${resp.json()['amountDue']}

    ${due_amount2}=  Evaluate  ${due_amount}-1600
    ${due_amount2}=     roundoff    ${due_amount2}   1

    ${resp}=  Create PaymentsOut With Expense   ${due_amount2}    ${dueDate}   ${payableLabel}   ${finance_payment_modes[2]}    ${bool[1]}    ${expense_uid}    ${lid}    merchantId=${merchantId}    merchantKey=${merchantKey}    paymentGateway=${paymentGateway[1]}    orderId=${orderId}    gatewayTxnId=${gatewayTxnId}    upiId=${upiId}      bankaccountNo=${bankaccountNo}   ifscCode=${ifsc}    bankName=${bankName}    branchName=${branchName}    pancardNo=${pancardNo}    gstNumber=${gstNumber}    bankCheckNo=${bankCheckNo}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${payable_uid1}   ${resp.json()['uid']}


    ${resp}=  Get PaymentsOut By Id   ${payable_uid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${due_amount2}=  Evaluate  ${due_amount}-1500
    ${due_amount2}=     roundoff    ${due_amount2}   1

    ${resp}=  Update PaymentsOut With Expense   ${payable_uid1}    ${category_id2}   ${name1}    ${due_amount2}   ${finance_payment_modes[0]}  ${dueDate}   ${lid}    
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${payable_uid1}   ${resp.json()['uid']}

    ${resp}=  Get PaymentsOut By Id   ${payable_uid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['paymentsOutLabel']}  ${payableLabel}
    Should Be Equal As Strings  ${resp.json()['amount']}  ${due_amount2}
    Should Be Equal As Strings  ${resp.json()['expenseUuid']}  ${expense_uid}
    Should Be Equal As Strings  ${resp.json()['paidDate']}  ${dueDate}
    Should Be Equal As Strings  ${resp.json()['paymentsOutUid']}  ${payable_uid1}
    Should Be Equal As Strings  ${resp.json()['paymentInfo']['paymentMode']}  ${finance_payment_modes[0]}


JD-TC-Update PaymentsOut With Expense--14

    [Documentation]  Create a PaymentOut where payment mode is Bank_Transfer Then update with Cash.


    ${resp}=  Encrypted Provider Login  ${PUSERNAME320}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date_by_timezone  ${tz}


    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${resp}=  Get Expense By Id   ${expense_uid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${due_amount}   ${resp.json()['amountDue']}

    ${due_amount2}=  Evaluate  ${due_amount}-1400
    ${due_amount2}=     roundoff    ${due_amount2}   1

    ${resp}=  Create PaymentsOut With Expense   ${due_amount2}    ${dueDate}   ${payableLabel}   ${finance_payment_modes[15]}    ${bool[1]}    ${expense_uid}   ${lid}    merchantId=${merchantId}    merchantKey=${merchantKey}    paymentGateway=${paymentGateway[1]}    orderId=${orderId}    gatewayTxnId=${gatewayTxnId}    upiId=${upiId}      bankaccountNo=${bankaccountNo}   ifscCode=${ifsc}    bankName=${bankName}    branchName=${branchName}    pancardNo=${pancardNo}    gstNumber=${gstNumber}    bankCheckNo=${bankCheckNo}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${payable_uid1}   ${resp.json()['uid']}


    ${resp}=  Get PaymentsOut By Id   ${payable_uid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${due_amount2}=  Evaluate  ${due_amount}-1300
    ${due_amount2}=     roundoff    ${due_amount2}   1

    ${resp}=  Update PaymentsOut With Expense   ${payable_uid1}    ${category_id2}   ${name1}    ${due_amount2}   ${finance_payment_modes[0]}  ${dueDate}     ${lid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${payable_uid1}   ${resp.json()['uid']}

    ${resp}=  Get PaymentsOut By Id   ${payable_uid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['paymentsOutLabel']}  ${payableLabel}
    Should Be Equal As Strings  ${resp.json()['amount']}  ${due_amount2}
    Should Be Equal As Strings  ${resp.json()['expenseUuid']}  ${expense_uid}
    Should Be Equal As Strings  ${resp.json()['paidDate']}  ${dueDate}
    Should Be Equal As Strings  ${resp.json()['paymentsOutUid']}  ${payable_uid1}
    Should Be Equal As Strings  ${resp.json()['paymentInfo']['paymentMode']}  ${finance_payment_modes[0]}



JD-TC-Update PaymentsOut With Expense--UH1

    [Documentation]  Create a PaymentOut where paid date is empty.


    ${resp}=  Encrypted Provider Login  ${PUSERNAME320}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date_by_timezone  ${tz}

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${resp}=  Get Expense By Id   ${expense_uid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${due_amount}   ${resp.json()['amountDue']}

    ${due_amount2}=  Evaluate  ${due_amount}-1200
    ${due_amount2}=     roundoff    ${due_amount2}   1


    ${resp}=  Update PaymentsOut With Expense   ${payable_uid1}    ${category_id2}   ${name1}    ${due_amount2}   ${finance_payment_modes[0]}  ${EMPTY}   ${lid}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${PAID_DATE_CANNOT_BE_EMPTY}


JD-TC-Update PaymentsOut With Expense--UH2

    [Documentation]  Create a PaymentOut without login.


    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date_by_timezone  ${tz}
     ${amount}=   Random Int  min=500  max=2000
    ${amount}=     roundoff    ${amount}   1

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}


    ${resp}=  Update PaymentsOut With Expense   ${payable_uid1}    ${category_id2}   ${name1}    ${amount}   ${finance_payment_modes[0]}  ${dueDate}   ${lid}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-Update PaymentsOut With Expense--UH3

    [Documentation]  Create a PaymentOut using consumer login.


    ${resp}=  Encrypted Provider Login  ${PUSERNAME320}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Expense By Id   ${expense_uid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${due_amount1}   ${resp.json()['amountDue']}

    ${due_amount2}=  Evaluate  ${due_amount1}-1100
    ${due_amount2}=     roundoff    ${due_amount2}   1

    #............provider consumer creation..........

    ${PH_Number}=  FakerLibrary.Numerify  %#####
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${PCPHONENO}  555${PH_Number}

    ${fname}=  generate_firstname
    Set Suite Variable  ${fname}
    ${lastname}=  FakerLibrary.last_name
   
    ${resp}=  AddCustomer  ${PCPHONENO}    firstName=${fname}   lastName=${lastname}  countryCode=${countryCodes[1]} 
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${PCPHONENO}    ${account_id1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${PCPHONENO}    ${account_id1}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200


    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date_by_timezone  ${tz}


    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}


    ${resp}=  Update PaymentsOut With Expense   ${payable_uid1}    ${category_id2}   ${name1}    ${due_amount2}   ${finance_payment_modes[0]}  ${dueDate}   ${lid}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   ${resp.json()}   ${LOGIN_NO_ACCESS_FOR_URL}

JD-TC-Update PaymentsOut With Expense--UH4

    [Documentation]  Create a PaymentOut where amount is empty.


    ${resp}=  Encrypted Provider Login  ${PUSERNAME320}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date_by_timezone  ${tz}

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}


    ${resp}=   Update PaymentsOut With Expense   ${payable_uid1}    ${category_id2}   ${name1}    ${EMPTY}   ${finance_payment_modes[0]}  ${dueDate}   ${lid}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${Please_enter_an_amount}



JD-TC-Update PaymentsOut With Expense--UH7

    [Documentation]  Create a PaymentOut where CatagoryName is empty.


    ${resp}=  Encrypted Provider Login  ${PUSERNAME320}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date_by_timezone  ${tz}

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${resp}=  Get Expense By Id   ${expense_uid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${due_amount1}   ${resp.json()['amountDue']}

    ${due_amount2}=  Evaluate  ${due_amount1}-900
    ${due_amount2}=     roundoff    ${due_amount2}   1


    ${resp}=   Update PaymentsOut With Expense   ${payable_uid1}    ${category_id2}   ${EMPTY}    ${due_amount2}   ${finance_payment_modes[0]}  ${dueDate}     ${lid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings   ${resp.json()}   ${Please_enter_an_amount}

    ${resp}=  Get PaymentsOut By Id   ${payable_uid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Update PaymentsOut With Expense--UH8

    [Documentation]  Create a PaymentOut where CatagoryId is empty.


    ${resp}=  Encrypted Provider Login  ${PUSERNAME320}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date_by_timezone  ${tz}

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}


    ${resp}=  Get Expense By Id   ${expense_uid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${due_amount1}   ${resp.json()['amountDue']}

    ${due_amount2}=  Evaluate  ${due_amount1}-800
    ${due_amount2}=     roundoff    ${due_amount2}   1

    ${resp}=   Update PaymentsOut With Expense   ${payable_uid1}    ${category_id1}   ${name1}    ${due_amount2}   ${finance_payment_modes[0]}  ${dueDate}     ${lid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings   ${resp.json()}   ${INVALID_PAYMENTSOUT_CATEGORY_ID}

    ${resp}=  Get PaymentsOut By Id   ${payable_uid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200



*** Comments ***
JD-TC-Update PaymentsOut With Expense--UH5

    [Documentation]  Create a PaymentOut where payment mode is upi but upiId is empty..


    ${resp}=  Encrypted Provider Login  ${PUSERNAME320}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date_by_timezone  ${tz}
     ${amount}=   Random Int  min=500  max=2000
    ${amount}=     roundoff    ${amount}   1

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${resp}=  Update PaymentsOut With Expense   ${payable_uid1}    ${category_id2}   ${name1}    ${amount}   ${finance_payment_modes[6]}  ${dueDate}     ${lid}        paymentGateway=${paymentGateway[1]}    orderId=${orderId}    gatewayTxnId=${gatewayTxnId}         bankaccountNo=${bankaccountNo}   ifscCode=${ifsc}    bankName=${bankName}    branchName=${branchName}    pancardNo=${pancardNo}    gstNumber=${gstNumber}    bankCheckNo=${bankCheckNo}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${UPI_ID_CANNOT_BE_EMPTY}

    # ${resp}=  Get PaymentsOut By Id   ${payable_uid1}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Update PaymentsOut With Expense--UH6

    [Documentation]  Create a PaymentOut where payment mode is cc but details is empty.


    ${resp}=  Encrypted Provider Login  ${PUSERNAME320}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date_by_timezone  ${tz}
     ${amount}=   Random Int  min=500  max=2000
    ${amount}=     roundoff    ${amount}   1


    ${resp}=  Update PaymentsOut With Expense   ${payable_uid1}    ${category_id2}   ${name1}    ${amount}   ${finance_payment_modes[1]}  ${dueDate}    ${lid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${PAYMENT_GATEWAY_CANNOT_BE_EMPTY}