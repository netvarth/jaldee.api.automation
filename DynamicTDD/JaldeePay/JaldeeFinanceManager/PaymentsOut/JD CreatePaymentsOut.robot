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

JD-TC-Create PaymentsOut-1

    [Documentation]  Create a Payable.

    # ${resp}=  Encrypted Provider Login    ${PUSERNAME47}  ${PASSWORD}
    # Log  ${resp.json()}         
    # Should Be Equal As Strings            ${resp.status_code}    200

    # ${decrypted_data}=  db.decrypt_data   ${resp.content}
    # Log  ${decrypted_data}

    # Set Suite Variable  ${pid}  ${decrypted_data['id']}
    # Set Suite Variable    ${userName}    ${decrypted_data['userName']}
    # Set Suite Variable    ${pdrfname}    ${decrypted_data['firstName']}
    # Set Suite Variable    ${pdrlname}    ${decrypted_data['lastName']}

    ${resp}=  Provider Login  ${PUSERNAME47}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${pid}  ${resp.json()['id']}
    Set Suite Variable  ${userName}  ${resp.json()['userName']}

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

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date
    ${amount}=   Random Int  min=500  max=2000
    ${amount}=     roundval    ${amount}   1
    ${paymentsOutStatus}=   FakerLibrary.word
    ${paymentStatus}=   FakerLibrary.word

    ${resp}=  Create PaymentsOut   ${amount}  ${category_id2}  ${dueDate}   ${payableLabel}    ${description}    ${referenceNo}    ${vendor_uid1}    ${status_id0}    ${Payment_Statuses[0]}    ${finance_payment_modes[0]}    
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${payable_uid1}   ${resp.json()['uid']}

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

JD-TC-Create PaymentsOut-3

    [Documentation]  Create a Payable with empty payableLabel.

    ${resp}=  Provider Login  ${PUSERNAME47}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date
    ${amount}=   Random Int  min=500  max=2000
    ${amount}=     roundval    ${amount}   1
    ${paymentsOutStatus}=   FakerLibrary.word
    ${paymentStatus}=   FakerLibrary.word

    ${resp}=  Create PaymentsOut   ${amount}  ${category_id2}  ${dueDate}   ${EMPTY}    ${description}    ${referenceNo}    ${vendor_uid1}    ${status_id0}    ${Payment_Statuses[0]}    ${finance_payment_modes[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${payable_uid1}   ${resp.json()['uid']}

    ${resp}=  Get PaymentsOut By Id   ${payable_uid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['paymentsOutCategoryId']}  ${category_id2}
    Should Be Equal As Strings  ${resp.json()['categoryName']}  ${name1}
    Should Be Equal As Strings  ${resp.json()['paymentsOutLabel']}  ${EMPTY}
    Should Be Equal As Strings  ${resp.json()['description']}  ${description}
    Should Be Equal As Strings  ${resp.json()['amount']}  ${amount}
    Should Be Equal As Strings  ${resp.json()['referenceNo']}  ${referenceNo}
    Should Be Equal As Strings  ${resp.json()['paidDate']}  ${dueDate}
    Should Be Equal As Strings  ${resp.json()['paymentsOutUid']}  ${payable_uid1}
    Should Be Equal As Strings  ${resp.json()['paymentsOutStatus']}  ${status_id0}
    Should Be Equal As Strings  ${resp.json()['paymentInfo']['paymentMode']}  ${finance_payment_modes[0]}

JD-TC-Create PaymentsOut-4

    [Documentation]  Create a Payable with empty description.

    ${resp}=  Provider Login  ${PUSERNAME47}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date
    ${amount}=   Random Int  min=500  max=2000
    ${paymentsOutStatus}=   FakerLibrary.word
    ${paymentStatus}=   FakerLibrary.word

    ${resp}=  Create PaymentsOut   ${amount}  ${category_id2}  ${dueDate}   ${payableLabel}    ${description}    ${EMPTY}    ${vendor_uid1}    ${status_id0}    ${Payment_Statuses[0]}    ${finance_payment_modes[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200



JD-TC-Create PaymentsOut-6

    [Documentation]  Create a Payable with empty status id.

    ${resp}=  Provider Login  ${PUSERNAME47}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date
    ${amount}=   Random Int  min=500  max=2000
    ${paymentsOutStatus}=   FakerLibrary.word
    ${paymentStatus}=   FakerLibrary.word

    ${resp}=  Create PaymentsOut   ${amount}  ${category_id2}  ${dueDate}   ${payableLabel}    ${description}    ${referenceNo}    ${vendor_uid1}    ${EMPTY}    ${Payment_Statuses[0]}    ${finance_payment_modes[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Create PaymentsOut-7

    [Documentation]  Create a Payable where payment status is success and payment mode is cc.

    ${resp}=  Provider Login  ${PUSERNAME47}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date
    ${amount}=   Random Int  min=500  max=2000
    ${paymentsOutStatus}=   FakerLibrary.word
    ${paymentStatus}=   FakerLibrary.word

    ${resp}=  Create PaymentsOut   ${amount}  ${category_id2}  ${dueDate}   ${payableLabel}    ${description}    ${referenceNo}    ${vendor_uid1}    ${status_id0}    ${Payment_Statuses[0]}    ${finance_payment_modes[1]}    merchantId=dsafgsdgsdg    merchantKey=dsafgsdgsdg    paymentGateway=PAYTM    orderId=dsafgsdgsdg     gatewayTxnId=dsafgsdgsdg    upiId=dsafgsdgsdg      bankaccountNo=kjbgkjsbgds    ifscCode=agfygadsf    bankName=gfadjfa    branchName=asfasgf    pancardNo=afsdfasg    gstNumber=afgagaG    bankCheckNo=adgasdgsgd
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Create PaymentsOut-8

    [Documentation]  Create a Payable where payment status is success and payment mode is DC.

    ${resp}=  Provider Login  ${PUSERNAME47}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date
    ${amount}=   Random Int  min=500  max=2000
    ${paymentsOutStatus}=   FakerLibrary.word
    ${paymentStatus}=   FakerLibrary.word

    ${resp}=  Create PaymentsOut   ${amount}  ${category_id2}  ${dueDate}   ${payableLabel}    ${description}    ${referenceNo}    ${vendor_uid1}    ${status_id0}    ${Payment_Statuses[0]}    ${finance_payment_modes[12]}    merchantId=dsafgsdgsdg    merchantKey=dsafgsdgsdg    paymentGateway=PAYTM    orderId=dsafgsdgsdg     gatewayTxnId=dsafgsdgsdg    upiId=dsafgsdgsdg      bankaccountNo=kjbgkjsbgds    ifscCode=agfygadsf    bankName=gfadjfa    branchName=asfasgf    pancardNo=afsdfasg    gstNumber=afgagaG    bankCheckNo=adgasdgsgd
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Create PaymentsOut-9

    [Documentation]  Create a Payable where payment status is success and payment mode is NB.

    ${resp}=  Provider Login  ${PUSERNAME47}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date
    ${amount}=   Random Int  min=500  max=2000
    ${paymentsOutStatus}=   FakerLibrary.word
    ${paymentStatus}=   FakerLibrary.word

    ${resp}=  Create PaymentsOut   ${amount}  ${category_id2}  ${dueDate}   ${payableLabel}    ${description}    ${referenceNo}    ${vendor_uid1}    ${status_id0}    ${Payment_Statuses[0]}    ${finance_payment_modes[8]}    merchantId=dsafgsdgsdg    merchantKey=dsafgsdgsdg    paymentGateway=PAYTM    orderId=dsafgsdgsdg     gatewayTxnId=dsafgsdgsdg    upiId=dsafgsdgsdg      bankaccountNo=kjbgkjsbgds    ifscCode=agfygadsf    bankName=gfadjfa    branchName=asfasgf    pancardNo=afsdfasg    gstNumber=afgagaG    bankCheckNo=adgasdgsgd
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Create PaymentsOut-10

    [Documentation]  Create a Payable where payment status is success and payment mode is UPI.

    ${resp}=  Provider Login  ${PUSERNAME47}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date
    ${amount}=   Random Int  min=500  max=2000
    ${paymentsOutStatus}=   FakerLibrary.word
    ${paymentStatus}=   FakerLibrary.word

    ${resp}=  Create PaymentsOut   ${amount}  ${category_id2}  ${dueDate}   ${payableLabel}    ${description}    ${referenceNo}    ${vendor_uid1}    ${status_id0}    ${Payment_Statuses[0]}    ${finance_payment_modes[6]}    merchantId=dsafgsdgsdg    merchantKey=dsafgsdgsdg    paymentGateway=PAYTM    orderId=dsafgsdgsdg     gatewayTxnId=dsafgsdgsdg    upiId=dsafgsdgsdg      bankaccountNo=kjbgkjsbgds    ifscCode=agfygadsf    bankName=gfadjfa    branchName=asfasgf    pancardNo=afsdfasg    gstNumber=afgagaG    bankCheckNo=adgasdgsgd
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Create PaymentsOut-11

    [Documentation]  Create a Payable where payment status is success and payment mode is other.

    ${resp}=  Provider Login  ${PUSERNAME47}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date
    ${amount}=   Random Int  min=500  max=2000
    ${paymentsOutStatus}=   FakerLibrary.word
    ${paymentStatus}=   FakerLibrary.word

    ${resp}=  Create PaymentsOut   ${amount}  ${category_id2}  ${dueDate}   ${payableLabel}    ${description}    ${referenceNo}    ${vendor_uid1}    ${status_id0}    ${Payment_Statuses[0]}    ${finance_payment_modes[7]}    merchantId=dsafgsdgsdg    merchantKey=dsafgsdgsdg    paymentGateway=PAYTM    orderId=dsafgsdgsdg     gatewayTxnId=dsafgsdgsdg    upiId=dsafgsdgsdg      bankaccountNo=kjbgkjsbgds    ifscCode=agfygadsf    bankName=gfadjfa    branchName=asfasgf    pancardNo=afsdfasg    gstNumber=afgagaG    bankCheckNo=adgasdgsgd
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Create PaymentsOut-12

    [Documentation]  Create a Payable where payment status is success and payment mode is Store credit.

    ${resp}=  Provider Login  ${PUSERNAME47}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date
    ${amount}=   Random Int  min=500  max=2000
    ${paymentsOutStatus}=   FakerLibrary.word
    ${paymentStatus}=   FakerLibrary.word

    ${resp}=  Create PaymentsOut   ${amount}  ${category_id2}  ${dueDate}   ${payableLabel}    ${description}    ${referenceNo}    ${vendor_uid1}    ${status_id0}    ${Payment_Statuses[0]}    ${finance_payment_modes[9]}    merchantId=dsafgsdgsdg    merchantKey=dsafgsdgsdg    paymentGateway=PAYTM    orderId=dsafgsdgsdg     gatewayTxnId=dsafgsdgsdg    upiId=dsafgsdgsdg      bankaccountNo=kjbgkjsbgds    ifscCode=agfygadsf    bankName=gfadjfa    branchName=asfasgf    pancardNo=afsdfasg    gstNumber=afgagaG    bankCheckNo=adgasdgsgd
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Create PaymentsOut-13

    [Documentation]  Create a Payable where payment status is success and payment mode is PAYLATER.

    ${resp}=  Provider Login  ${PUSERNAME47}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date
    ${amount}=   Random Int  min=500  max=2000
    ${paymentsOutStatus}=   FakerLibrary.word
    ${paymentStatus}=   FakerLibrary.word

    ${resp}=  Create PaymentsOut   ${amount}  ${category_id2}  ${dueDate}   ${payableLabel}    ${description}    ${referenceNo}    ${vendor_uid1}    ${status_id0}    ${Payment_Statuses[0]}    ${finance_payment_modes[4]}    merchantId=dsafgsdgsdg    merchantKey=dsafgsdgsdg    paymentGateway=PAYTM    orderId=dsafgsdgsdg     gatewayTxnId=dsafgsdgsdg    upiId=dsafgsdgsdg      bankaccountNo=kjbgkjsbgds    ifscCode=agfygadsf    bankName=gfadjfa    branchName=asfasgf    pancardNo=afsdfasg    gstNumber=afgagaG    bankCheckNo=adgasdgsgd              
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Create PaymentsOut-14

    [Documentation]  Create a Payable where payment status is success and payment mode is offline.

    ${resp}=  Provider Login  ${PUSERNAME47}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date
    ${amount}=   Random Int  min=500  max=2000
    ${paymentsOutStatus}=   FakerLibrary.word
    ${paymentStatus}=   FakerLibrary.word

    ${resp}=  Create PaymentsOut   ${amount}  ${category_id2}  ${dueDate}   ${payableLabel}    ${description}    ${referenceNo}    ${vendor_uid1}    ${status_id0}    ${Payment_Statuses[0]}    ${finance_payment_modes[3]}    merchantId=dsafgsdgsdg    merchantKey=dsafgsdgsdg    paymentGateway=PAYTM    orderId=dsafgsdgsdg     gatewayTxnId=dsafgsdgsdg    upiId=dsafgsdgsdg      bankaccountNo=kjbgkjsbgds    ifscCode=agfygadsf    bankName=gfadjfa    branchName=asfasgf    pancardNo=afsdfasg    gstNumber=afgagaG    bankCheckNo=adgasdgsgd
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Create PaymentsOut-15

    [Documentation]  Create a Payable where payment status is success and payment mode is Wallet.

    ${resp}=  Provider Login  ${PUSERNAME47}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date
    ${amount}=   Random Int  min=500  max=2000
    ${paymentsOutStatus}=   FakerLibrary.word
    ${paymentStatus}=   FakerLibrary.word

    ${resp}=  Create PaymentsOut   ${amount}  ${category_id2}  ${dueDate}   ${payableLabel}    ${description}    ${referenceNo}    ${vendor_uid1}    ${status_id0}    ${Payment_Statuses[0]}    ${finance_payment_modes[10]}    merchantId=dsafgsdgsdg    merchantKey=dsafgsdgsdg    paymentGateway=PAYTM    orderId=dsafgsdgsdg     gatewayTxnId=dsafgsdgsdg    upiId=dsafgsdgsdg      bankaccountNo=kjbgkjsbgds    ifscCode=agfygadsf    bankName=gfadjfa    branchName=asfasgf    pancardNo=afsdfasg    gstNumber=afgagaG    bankCheckNo=adgasdgsgd
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Create PaymentsOut-16

    [Documentation]  Create a Payable where payment status is success and payment mode is PayLater.

    ${resp}=  Provider Login  ${PUSERNAME47}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date
    ${amount}=   Random Int  min=500  max=2000
    ${paymentsOutStatus}=   FakerLibrary.word
    ${paymentStatus}=   FakerLibrary.word

    ${resp}=  Create PaymentsOut   ${amount}  ${category_id2}  ${dueDate}   ${payableLabel}    ${description}    ${referenceNo}    ${vendor_uid1}    ${status_id0}    ${Payment_Statuses[0]}    ${finance_payment_modes[13]}    merchantId=dsafgsdgsdg    merchantKey=dsafgsdgsdg    paymentGateway=PAYTM    orderId=dsafgsdgsdg     gatewayTxnId=dsafgsdgsdg    upiId=dsafgsdgsdg      bankaccountNo=kjbgkjsbgds    ifscCode=agfygadsf    bankName=gfadjfa    branchName=asfasgf    pancardNo=afsdfasg    gstNumber=afgagaG    bankCheckNo=adgasdgsgd
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
JD-TC-Create PaymentsOut-17

    [Documentation]  Create a Payable where payment status is success and payment mode is PAYTM_PostPaid.

    ${resp}=  Provider Login  ${PUSERNAME47}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date
    ${amount}=   Random Int  min=500  max=2000
    ${paymentsOutStatus}=   FakerLibrary.word
    ${paymentStatus}=   FakerLibrary.word

    ${resp}=  Create PaymentsOut   ${amount}  ${category_id2}  ${dueDate}   ${payableLabel}    ${description}    ${referenceNo}    ${vendor_uid1}    ${status_id0}    ${Payment_Statuses[0]}    ${finance_payment_modes[14]}    merchantId=dsafgsdgsdg    merchantKey=dsafgsdgsdg    paymentGateway=PAYTM    orderId=dsafgsdgsdg     gatewayTxnId=dsafgsdgsdg    upiId=dsafgsdgsdg      bankaccountNo=kjbgkjsbgds    ifscCode=agfygadsf    bankName=gfadjfa    branchName=asfasgf    pancardNo=afsdfasg    gstNumber=afgagaG    bankCheckNo=adgasdgsgd
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-Create PaymentsOut-18

    [Documentation]  Create a Payable where payment status is success and payment mode is EMI.

    ${resp}=  Provider Login  ${PUSERNAME47}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date
    ${amount}=   Random Int  min=500  max=2000
    ${paymentsOutStatus}=   FakerLibrary.word
    ${paymentStatus}=   FakerLibrary.word

    ${resp}=  Create PaymentsOut   ${amount}  ${category_id2}  ${dueDate}   ${payableLabel}    ${description}    ${referenceNo}    ${vendor_uid1}    ${status_id0}    ${Payment_Statuses[0]}    ${finance_payment_modes[2]}    merchantId=dsafgsdgsdg    merchantKey=dsafgsdgsdg    paymentGateway=PAYTM    orderId=dsafgsdgsdg     gatewayTxnId=dsafgsdgsdg    upiId=dsafgsdgsdg      bankaccountNo=kjbgkjsbgds    ifscCode=agfygadsf    bankName=gfadjfa    branchName=asfasgf    pancardNo=afsdfasg    gstNumber=afgagaG    bankCheckNo=adgasdgsgd
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Create PaymentsOut-19

    [Documentation]  Create a Payable where payment status is success and payment mode is Bank_Transfer.

    ${resp}=  Provider Login  ${PUSERNAME47}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date
    ${amount}=   Random Int  min=500  max=2000
    ${paymentsOutStatus}=   FakerLibrary.word
    ${paymentStatus}=   FakerLibrary.word

    ${resp}=  Create PaymentsOut   ${amount}  ${category_id2}  ${dueDate}   ${payableLabel}    ${description}    ${referenceNo}    ${vendor_uid1}    ${status_id0}    ${Payment_Statuses[0]}    ${finance_payment_modes[15]}    merchantId=dsafgsdgsdg    merchantKey=dsafgsdgsdg    paymentGateway=PAYTM    orderId=dsafgsdgsdg     gatewayTxnId=dsafgsdgsdg    upiId=dsafgsdgsdg      bankaccountNo=kjbgkjsbgds    ifscCode=agfygadsf    bankName=gfadjfa    branchName=asfasgf    pancardNo=afsdfasg    gstNumber=afgagaG    bankCheckNo=adgasdgsgd
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-Create PaymentsOut-20

    [Documentation]  Create a Payable with payment status as failed and payment mode is cash.

    ${resp}=  Provider Login  ${PUSERNAME47}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date
    ${amount}=   Random Int  min=500  max=2000
    ${paymentsOutStatus}=   FakerLibrary.word
    ${paymentStatus}=   FakerLibrary.word

    ${resp}=  Create PaymentsOut   ${amount}  ${category_id2}  ${dueDate}   ${payableLabel}    ${description}    ${referenceNo}    ${vendor_uid1}    ${status_id0}    ${Payment_Statuses[1]}    ${finance_payment_modes[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Create PaymentsOut-21

    [Documentation]  Create a Payable where payment status is failed and payment mode is cc.

    ${resp}=  Provider Login  ${PUSERNAME47}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date
    ${amount}=   Random Int  min=500  max=2000
    ${paymentsOutStatus}=   FakerLibrary.word
    ${paymentStatus}=   FakerLibrary.word

    ${resp}=  Create PaymentsOut   ${amount}  ${category_id2}  ${dueDate}   ${payableLabel}    ${description}    ${referenceNo}    ${vendor_uid1}    ${status_id0}    ${Payment_Statuses[1]}    ${finance_payment_modes[1]}    merchantId=dsafgsdgsdg    merchantKey=dsafgsdgsdg    paymentGateway=PAYTM    orderId=dsafgsdgsdg     gatewayTxnId=dsafgsdgsdg    upiId=dsafgsdgsdg      bankaccountNo=kjbgkjsbgds    ifscCode=agfygadsf    bankName=gfadjfa    branchName=asfasgf    pancardNo=afsdfasg    gstNumber=afgagaG    bankCheckNo=adgasdgsgd
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Create PaymentsOut-22

    [Documentation]  Create a Payable where payment status is failed and payment mode is DC.

    ${resp}=  Provider Login  ${PUSERNAME47}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date
    ${amount}=   Random Int  min=500  max=2000
    ${paymentsOutStatus}=   FakerLibrary.word
    ${paymentStatus}=   FakerLibrary.word

    ${resp}=  Create PaymentsOut   ${amount}  ${category_id2}  ${dueDate}   ${payableLabel}    ${description}    ${referenceNo}    ${vendor_uid1}    ${status_id0}    ${Payment_Statuses[1]}    ${finance_payment_modes[12]}    merchantId=dsafgsdgsdg    merchantKey=dsafgsdgsdg    paymentGateway=PAYTM    orderId=dsafgsdgsdg     gatewayTxnId=dsafgsdgsdg    upiId=dsafgsdgsdg      bankaccountNo=kjbgkjsbgds    ifscCode=agfygadsf    bankName=gfadjfa    branchName=asfasgf    pancardNo=afsdfasg    gstNumber=afgagaG    bankCheckNo=adgasdgsgd
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Create PaymentsOut-23

    [Documentation]  Create a Payable where payment status is failed and payment mode is NB.

    ${resp}=  Provider Login  ${PUSERNAME47}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date
    ${amount}=   Random Int  min=500  max=2000
    ${paymentsOutStatus}=   FakerLibrary.word
    ${paymentStatus}=   FakerLibrary.word

    ${resp}=  Create PaymentsOut   ${amount}  ${category_id2}  ${dueDate}   ${payableLabel}    ${description}    ${referenceNo}    ${vendor_uid1}    ${status_id0}    ${Payment_Statuses[1]}    ${finance_payment_modes[8]}    merchantId=dsafgsdgsdg    merchantKey=dsafgsdgsdg    paymentGateway=PAYTM    orderId=dsafgsdgsdg     gatewayTxnId=dsafgsdgsdg    upiId=dsafgsdgsdg      bankaccountNo=kjbgkjsbgds    ifscCode=agfygadsf    bankName=gfadjfa    branchName=asfasgf    pancardNo=afsdfasg    gstNumber=afgagaG    bankCheckNo=adgasdgsgd
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Create PaymentsOut-24

    [Documentation]  Create a Payable where payment status is failed and payment mode is UPI.

    ${resp}=  Provider Login  ${PUSERNAME47}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date
    ${amount}=   Random Int  min=500  max=2000
    ${paymentsOutStatus}=   FakerLibrary.word
    ${paymentStatus}=   FakerLibrary.word

    ${resp}=  Create PaymentsOut   ${amount}  ${category_id2}  ${dueDate}   ${payableLabel}    ${description}    ${referenceNo}    ${vendor_uid1}    ${status_id0}    ${Payment_Statuses[1]}    ${finance_payment_modes[6]}    merchantId=dsafgsdgsdg    merchantKey=dsafgsdgsdg    paymentGateway=PAYTM    orderId=dsafgsdgsdg     gatewayTxnId=dsafgsdgsdg    upiId=dsafgsdgsdg      bankaccountNo=kjbgkjsbgds    ifscCode=agfygadsf    bankName=gfadjfa    branchName=asfasgf    pancardNo=afsdfasg    gstNumber=afgagaG    bankCheckNo=adgasdgsgd
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Create PaymentsOut-25

    [Documentation]  Create a Payable where payment status is failed and payment mode is other.

    ${resp}=  Provider Login  ${PUSERNAME47}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date
    ${amount}=   Random Int  min=500  max=2000
    ${paymentsOutStatus}=   FakerLibrary.word
    ${paymentStatus}=   FakerLibrary.word

    ${resp}=  Create PaymentsOut   ${amount}  ${category_id2}  ${dueDate}   ${payableLabel}    ${description}    ${referenceNo}    ${vendor_uid1}    ${status_id0}    ${Payment_Statuses[1]}    ${finance_payment_modes[7]}    merchantId=dsafgsdgsdg    merchantKey=dsafgsdgsdg    paymentGateway=PAYTM    orderId=dsafgsdgsdg     gatewayTxnId=dsafgsdgsdg    upiId=dsafgsdgsdg      bankaccountNo=kjbgkjsbgds    ifscCode=agfygadsf    bankName=gfadjfa    branchName=asfasgf    pancardNo=afsdfasg    gstNumber=afgagaG    bankCheckNo=adgasdgsgd
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Create PaymentsOut-26

    [Documentation]  Create a Payable where payment status is failed and payment mode is Store credit.

    ${resp}=  Provider Login  ${PUSERNAME47}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date
    ${amount}=   Random Int  min=500  max=2000
    ${paymentsOutStatus}=   FakerLibrary.word
    ${paymentStatus}=   FakerLibrary.word

    ${resp}=  Create PaymentsOut   ${amount}  ${category_id2}  ${dueDate}   ${payableLabel}    ${description}    ${referenceNo}    ${vendor_uid1}    ${status_id0}    ${Payment_Statuses[1]}    ${finance_payment_modes[9]}    merchantId=dsafgsdgsdg    merchantKey=dsafgsdgsdg    paymentGateway=PAYTM    orderId=dsafgsdgsdg     gatewayTxnId=dsafgsdgsdg    upiId=dsafgsdgsdg      bankaccountNo=kjbgkjsbgds    ifscCode=agfygadsf    bankName=gfadjfa    branchName=asfasgf    pancardNo=afsdfasg    gstNumber=afgagaG    bankCheckNo=adgasdgsgd
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Create PaymentsOut-27

    [Documentation]  Create a Payable where payment status is failed and payment mode is PAYLATER.

    ${resp}=  Provider Login  ${PUSERNAME47}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date
    ${amount}=   Random Int  min=500  max=2000
    ${paymentsOutStatus}=   FakerLibrary.word
    ${paymentStatus}=   FakerLibrary.word

    ${resp}=  Create PaymentsOut   ${amount}  ${category_id2}  ${dueDate}   ${payableLabel}    ${description}    ${referenceNo}    ${vendor_uid1}    ${status_id0}    ${Payment_Statuses[1]}    ${finance_payment_modes[4]}    merchantId=dsafgsdgsdg    merchantKey=dsafgsdgsdg    paymentGateway=PAYTM    orderId=dsafgsdgsdg     gatewayTxnId=dsafgsdgsdg    upiId=dsafgsdgsdg      bankaccountNo=kjbgkjsbgds    ifscCode=agfygadsf    bankName=gfadjfa    branchName=asfasgf    pancardNo=afsdfasg    gstNumber=afgagaG    bankCheckNo=adgasdgsgd
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Create PaymentsOut-28

    [Documentation]  Create a Payable where payment status is failed and payment mode is offline.

    ${resp}=  Provider Login  ${PUSERNAME47}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date
    ${amount}=   Random Int  min=500  max=2000
    ${paymentsOutStatus}=   FakerLibrary.word
    ${paymentStatus}=   FakerLibrary.word

    ${resp}=  Create PaymentsOut   ${amount}  ${category_id2}  ${dueDate}   ${payableLabel}    ${description}    ${referenceNo}    ${vendor_uid1}    ${status_id0}    ${Payment_Statuses[1]}    ${finance_payment_modes[3]}    merchantId=dsafgsdgsdg    merchantKey=dsafgsdgsdg    paymentGateway=PAYTM    orderId=dsafgsdgsdg     gatewayTxnId=dsafgsdgsdg    upiId=dsafgsdgsdg      bankaccountNo=kjbgkjsbgds    ifscCode=agfygadsf    bankName=gfadjfa    branchName=asfasgf    pancardNo=afsdfasg    gstNumber=afgagaG    bankCheckNo=adgasdgsgd
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Create PaymentsOut-29

    [Documentation]  Create a Payable where payment status is failed and payment mode is Wallet.

    ${resp}=  Provider Login  ${PUSERNAME47}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date
    ${amount}=   Random Int  min=500  max=2000
    ${paymentsOutStatus}=   FakerLibrary.word
    ${paymentStatus}=   FakerLibrary.word

    ${resp}=  Create PaymentsOut   ${amount}  ${category_id2}  ${dueDate}   ${payableLabel}    ${description}    ${referenceNo}    ${vendor_uid1}    ${status_id0}    ${Payment_Statuses[1]}    ${finance_payment_modes[10]}    merchantId=dsafgsdgsdg    merchantKey=dsafgsdgsdg    paymentGateway=PAYTM    orderId=dsafgsdgsdg     gatewayTxnId=dsafgsdgsdg    upiId=dsafgsdgsdg      bankaccountNo=kjbgkjsbgds    ifscCode=agfygadsf    bankName=gfadjfa    branchName=asfasgf    pancardNo=afsdfasg    gstNumber=afgagaG    bankCheckNo=adgasdgsgd
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Create PaymentsOut-30

    [Documentation]  Create a Payable where payment status is failed and payment mode is PayLater.

    ${resp}=  Provider Login  ${PUSERNAME47}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date
    ${amount}=   Random Int  min=500  max=2000
    ${paymentsOutStatus}=   FakerLibrary.word
    ${paymentStatus}=   FakerLibrary.word

    ${resp}=  Create PaymentsOut   ${amount}  ${category_id2}  ${dueDate}   ${payableLabel}    ${description}    ${referenceNo}    ${vendor_uid1}    ${status_id0}    ${Payment_Statuses[1]}    ${finance_payment_modes[13]}    merchantId=dsafgsdgsdg    merchantKey=dsafgsdgsdg    paymentGateway=PAYTM    orderId=dsafgsdgsdg     gatewayTxnId=dsafgsdgsdg    upiId=dsafgsdgsdg      bankaccountNo=kjbgkjsbgds    ifscCode=agfygadsf    bankName=gfadjfa    branchName=asfasgf    pancardNo=afsdfasg    gstNumber=afgagaG    bankCheckNo=adgasdgsgd
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
JD-TC-Create PaymentsOut-31

    [Documentation]  Create a Payable where payment status is failed and payment mode is PAYTM_PostPaid.

    ${resp}=  Provider Login  ${PUSERNAME47}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date
    ${amount}=   Random Int  min=500  max=2000
    ${paymentsOutStatus}=   FakerLibrary.word
    ${paymentStatus}=   FakerLibrary.word

    ${resp}=  Create PaymentsOut   ${amount}  ${category_id2}  ${dueDate}   ${payableLabel}    ${description}    ${referenceNo}    ${vendor_uid1}    ${status_id0}    ${Payment_Statuses[1]}    ${finance_payment_modes[14]}    merchantId=dsafgsdgsdg    merchantKey=dsafgsdgsdg    paymentGateway=PAYTM    orderId=dsafgsdgsdg     gatewayTxnId=dsafgsdgsdg    upiId=dsafgsdgsdg      bankaccountNo=kjbgkjsbgds    ifscCode=agfygadsf    bankName=gfadjfa    branchName=asfasgf    pancardNo=afsdfasg    gstNumber=afgagaG    bankCheckNo=adgasdgsgd
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-Create PaymentsOut-32

    [Documentation]  Create a Payable where payment status is failed and payment mode is EMI.

    ${resp}=  Provider Login  ${PUSERNAME47}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date
    ${amount}=   Random Int  min=500  max=2000
    ${paymentsOutStatus}=   FakerLibrary.word
    ${paymentStatus}=   FakerLibrary.word

    ${resp}=  Create PaymentsOut   ${amount}  ${category_id2}  ${dueDate}   ${payableLabel}    ${description}    ${referenceNo}    ${vendor_uid1}    ${status_id0}    ${Payment_Statuses[1]}    ${finance_payment_modes[2]}    merchantId=dsafgsdgsdg    merchantKey=dsafgsdgsdg    paymentGateway=PAYTM    orderId=dsafgsdgsdg     gatewayTxnId=dsafgsdgsdg    upiId=dsafgsdgsdg      bankaccountNo=kjbgkjsbgds    ifscCode=agfygadsf    bankName=gfadjfa    branchName=asfasgf    pancardNo=afsdfasg    gstNumber=afgagaG    bankCheckNo=adgasdgsgd
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Create PaymentsOut-33

    [Documentation]  Create a Payable where payment status is failed and payment mode is Bank_Transfer.

    ${resp}=  Provider Login  ${PUSERNAME47}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date
    ${amount}=   Random Int  min=500  max=2000
    ${paymentsOutStatus}=   FakerLibrary.word
    ${paymentStatus}=   FakerLibrary.word

    ${resp}=  Create PaymentsOut   ${amount}  ${category_id2}  ${dueDate}   ${payableLabel}    ${description}    ${referenceNo}    ${vendor_uid1}    ${status_id0}    ${Payment_Statuses[1]}    ${finance_payment_modes[15]}    merchantId=dsafgsdgsdg    merchantKey=dsafgsdgsdg    paymentGateway=PAYTM    orderId=dsafgsdgsdg     gatewayTxnId=dsafgsdgsdg    upiId=dsafgsdgsdg      bankaccountNo=kjbgkjsbgds    ifscCode=agfygadsf    bankName=gfadjfa    branchName=asfasgf    pancardNo=afsdfasg    gstNumber=afgagaG    bankCheckNo=adgasdgsgd
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-Create PaymentsOut-34

    [Documentation]  Create a Payable with payment status as incomplete and payment mode is cash.

    ${resp}=  Provider Login  ${PUSERNAME47}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date
    ${amount}=   Random Int  min=500  max=2000
    ${paymentsOutStatus}=   FakerLibrary.word
    ${paymentStatus}=   FakerLibrary.word

    ${resp}=  Create PaymentsOut   ${amount}  ${category_id2}  ${dueDate}   ${payableLabel}    ${description}    ${referenceNo}    ${vendor_uid1}    ${status_id0}    ${Payment_Statuses[2]}    ${finance_payment_modes[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Create PaymentsOut-35

    [Documentation]  Create a Payable where payment status is incomplete and payment mode is cc.

    ${resp}=  Provider Login  ${PUSERNAME47}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date
    ${amount}=   Random Int  min=500  max=2000
    ${paymentsOutStatus}=   FakerLibrary.word
    ${paymentStatus}=   FakerLibrary.word

    ${resp}=  Create PaymentsOut   ${amount}  ${category_id2}  ${dueDate}   ${payableLabel}    ${description}    ${referenceNo}    ${vendor_uid1}    ${status_id0}    ${Payment_Statuses[2]}    ${finance_payment_modes[1]}    merchantId=dsafgsdgsdg    merchantKey=dsafgsdgsdg    paymentGateway=PAYTM    orderId=dsafgsdgsdg     gatewayTxnId=dsafgsdgsdg    upiId=dsafgsdgsdg      bankaccountNo=kjbgkjsbgds    ifscCode=agfygadsf    bankName=gfadjfa    branchName=asfasgf    pancardNo=afsdfasg    gstNumber=afgagaG    bankCheckNo=adgasdgsgd
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Create PaymentsOut-36

    [Documentation]  Create a Payable where payment status is incomplete and payment mode is DC.

    ${resp}=  Provider Login  ${PUSERNAME47}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date
    ${amount}=   Random Int  min=500  max=2000
    ${paymentsOutStatus}=   FakerLibrary.word
    ${paymentStatus}=   FakerLibrary.word

    ${resp}=  Create PaymentsOut   ${amount}  ${category_id2}  ${dueDate}   ${payableLabel}    ${description}    ${referenceNo}    ${vendor_uid1}    ${status_id0}    ${Payment_Statuses[2]}    ${finance_payment_modes[12]}    merchantId=dsafgsdgsdg    merchantKey=dsafgsdgsdg    paymentGateway=PAYTM    orderId=dsafgsdgsdg     gatewayTxnId=dsafgsdgsdg    upiId=dsafgsdgsdg      bankaccountNo=kjbgkjsbgds    ifscCode=agfygadsf    bankName=gfadjfa    branchName=asfasgf    pancardNo=afsdfasg    gstNumber=afgagaG    bankCheckNo=adgasdgsgd
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Create PaymentsOut-37

    [Documentation]  Create a Payable where payment status is incomplete and payment mode is NB.

    ${resp}=  Provider Login  ${PUSERNAME47}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date
    ${amount}=   Random Int  min=500  max=2000
    ${paymentsOutStatus}=   FakerLibrary.word
    ${paymentStatus}=   FakerLibrary.word

    ${resp}=  Create PaymentsOut   ${amount}  ${category_id2}  ${dueDate}   ${payableLabel}    ${description}    ${referenceNo}    ${vendor_uid1}    ${status_id0}    ${Payment_Statuses[2]}    ${finance_payment_modes[8]}    merchantId=dsafgsdgsdg    merchantKey=dsafgsdgsdg    paymentGateway=PAYTM    orderId=dsafgsdgsdg     gatewayTxnId=dsafgsdgsdg    upiId=dsafgsdgsdg      bankaccountNo=kjbgkjsbgds    ifscCode=agfygadsf    bankName=gfadjfa    branchName=asfasgf    pancardNo=afsdfasg    gstNumber=afgagaG    bankCheckNo=adgasdgsgd
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Create PaymentsOut-38

    [Documentation]  Create a Payable where payment status is incomplete and payment mode is UPI.

    ${resp}=  Provider Login  ${PUSERNAME47}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date
    ${amount}=   Random Int  min=500  max=2000
    ${paymentsOutStatus}=   FakerLibrary.word
    ${paymentStatus}=   FakerLibrary.word

    ${resp}=  Create PaymentsOut   ${amount}  ${category_id2}  ${dueDate}   ${payableLabel}    ${description}    ${referenceNo}    ${vendor_uid1}    ${status_id0}    ${Payment_Statuses[2]}    ${finance_payment_modes[6]}    merchantId=dsafgsdgsdg    merchantKey=dsafgsdgsdg    paymentGateway=PAYTM    orderId=dsafgsdgsdg     gatewayTxnId=dsafgsdgsdg    upiId=dsafgsdgsdg      bankaccountNo=kjbgkjsbgds    ifscCode=agfygadsf    bankName=gfadjfa    branchName=asfasgf    pancardNo=afsdfasg    gstNumber=afgagaG    bankCheckNo=adgasdgsgd
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Create PaymentsOut-39

    [Documentation]  Create a Payable where payment status is incomplete and payment mode is other.

    ${resp}=  Provider Login  ${PUSERNAME47}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date
    ${amount}=   Random Int  min=500  max=2000
    ${paymentsOutStatus}=   FakerLibrary.word
    ${paymentStatus}=   FakerLibrary.word

    ${resp}=  Create PaymentsOut   ${amount}  ${category_id2}  ${dueDate}   ${payableLabel}    ${description}    ${referenceNo}    ${vendor_uid1}    ${status_id0}    ${Payment_Statuses[2]}    ${finance_payment_modes[7]}    merchantId=dsafgsdgsdg    merchantKey=dsafgsdgsdg    paymentGateway=PAYTM    orderId=dsafgsdgsdg     gatewayTxnId=dsafgsdgsdg    upiId=dsafgsdgsdg      bankaccountNo=kjbgkjsbgds    ifscCode=agfygadsf    bankName=gfadjfa    branchName=asfasgf    pancardNo=afsdfasg    gstNumber=afgagaG    bankCheckNo=adgasdgsgd
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Create PaymentsOut-40

    [Documentation]  Create a Payable where payment status is incomplete and payment mode is Store credit.

    ${resp}=  Provider Login  ${PUSERNAME47}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date
    ${amount}=   Random Int  min=500  max=2000
    ${paymentsOutStatus}=   FakerLibrary.word
    ${paymentStatus}=   FakerLibrary.word

    ${resp}=  Create PaymentsOut   ${amount}  ${category_id2}  ${dueDate}   ${payableLabel}    ${description}    ${referenceNo}    ${vendor_uid1}    ${status_id0}    ${Payment_Statuses[2]}    ${finance_payment_modes[9]}    merchantId=dsafgsdgsdg    merchantKey=dsafgsdgsdg    paymentGateway=PAYTM    orderId=dsafgsdgsdg     gatewayTxnId=dsafgsdgsdg    upiId=dsafgsdgsdg      bankaccountNo=kjbgkjsbgds    ifscCode=agfygadsf    bankName=gfadjfa    branchName=asfasgf    pancardNo=afsdfasg    gstNumber=afgagaG    bankCheckNo=adgasdgsgd
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Create PaymentsOut-41

    [Documentation]  Create a Payable where payment status is incomplete and payment mode is PAYLATER.

    ${resp}=  Provider Login  ${PUSERNAME47}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date
    ${amount}=   Random Int  min=500  max=2000
    ${paymentsOutStatus}=   FakerLibrary.word
    ${paymentStatus}=   FakerLibrary.word

    ${resp}=  Create PaymentsOut   ${amount}  ${category_id2}  ${dueDate}   ${payableLabel}    ${description}    ${referenceNo}    ${vendor_uid1}    ${status_id0}    ${Payment_Statuses[2]}    ${finance_payment_modes[4]}    merchantId=dsafgsdgsdg    merchantKey=dsafgsdgsdg    paymentGateway=PAYTM    orderId=dsafgsdgsdg     gatewayTxnId=dsafgsdgsdg    upiId=dsafgsdgsdg      bankaccountNo=kjbgkjsbgds    ifscCode=agfygadsf    bankName=gfadjfa    branchName=asfasgf    pancardNo=afsdfasg    gstNumber=afgagaG    bankCheckNo=adgasdgsgd
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Create PaymentsOut-42

    [Documentation]  Create a Payable where payment status is incomplete and payment mode is offline.

    ${resp}=  Provider Login  ${PUSERNAME47}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date
    ${amount}=   Random Int  min=500  max=2000
    ${paymentsOutStatus}=   FakerLibrary.word
    ${paymentStatus}=   FakerLibrary.word

    ${resp}=  Create PaymentsOut   ${amount}  ${category_id2}  ${dueDate}   ${payableLabel}    ${description}    ${referenceNo}    ${vendor_uid1}    ${status_id0}    ${Payment_Statuses[2]}    ${finance_payment_modes[3]}    merchantId=dsafgsdgsdg    merchantKey=dsafgsdgsdg    paymentGateway=PAYTM    orderId=dsafgsdgsdg     gatewayTxnId=dsafgsdgsdg    upiId=dsafgsdgsdg      bankaccountNo=kjbgkjsbgds    ifscCode=agfygadsf    bankName=gfadjfa    branchName=asfasgf    pancardNo=afsdfasg    gstNumber=afgagaG    bankCheckNo=adgasdgsgd
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Create PaymentsOut-43

    [Documentation]  Create a Payable where payment status is incomplete and payment mode is Wallet.

    ${resp}=  Provider Login  ${PUSERNAME47}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date
    ${amount}=   Random Int  min=500  max=2000
    ${paymentsOutStatus}=   FakerLibrary.word
    ${paymentStatus}=   FakerLibrary.word

    ${resp}=  Create PaymentsOut   ${amount}  ${category_id2}  ${dueDate}   ${payableLabel}    ${description}    ${referenceNo}    ${vendor_uid1}    ${status_id0}    ${Payment_Statuses[2]}    ${finance_payment_modes[10]}    merchantId=dsafgsdgsdg    merchantKey=dsafgsdgsdg    paymentGateway=PAYTM    orderId=dsafgsdgsdg     gatewayTxnId=dsafgsdgsdg    upiId=dsafgsdgsdg      bankaccountNo=kjbgkjsbgds    ifscCode=agfygadsf    bankName=gfadjfa    branchName=asfasgf    pancardNo=afsdfasg    gstNumber=afgagaG    bankCheckNo=adgasdgsgd
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Create PaymentsOut-44

    [Documentation]  Create a Payable where payment status is incomplete and payment mode is PayLater.

    ${resp}=  Provider Login  ${PUSERNAME47}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date
    ${amount}=   Random Int  min=500  max=2000
    ${paymentsOutStatus}=   FakerLibrary.word
    ${paymentStatus}=   FakerLibrary.word

    ${resp}=  Create PaymentsOut   ${amount}  ${category_id2}  ${dueDate}   ${payableLabel}    ${description}    ${referenceNo}    ${vendor_uid1}    ${status_id0}    ${Payment_Statuses[2]}    ${finance_payment_modes[13]}    merchantId=dsafgsdgsdg    merchantKey=dsafgsdgsdg    paymentGateway=PAYTM    orderId=dsafgsdgsdg     gatewayTxnId=dsafgsdgsdg    upiId=dsafgsdgsdg      bankaccountNo=kjbgkjsbgds    ifscCode=agfygadsf    bankName=gfadjfa    branchName=asfasgf    pancardNo=afsdfasg    gstNumber=afgagaG    bankCheckNo=adgasdgsgd
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
JD-TC-Create PaymentsOut-45

    [Documentation]  Create a Payable where payment status is incomplete and payment mode is PAYTM_PostPaid.

    ${resp}=  Provider Login  ${PUSERNAME47}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date
    ${amount}=   Random Int  min=500  max=2000
    ${paymentsOutStatus}=   FakerLibrary.word
    ${paymentStatus}=   FakerLibrary.word

    ${resp}=  Create PaymentsOut   ${amount}  ${category_id2}  ${dueDate}   ${payableLabel}    ${description}    ${referenceNo}    ${vendor_uid1}    ${status_id0}    ${Payment_Statuses[2]}    ${finance_payment_modes[14]}    merchantId=dsafgsdgsdg    merchantKey=dsafgsdgsdg    paymentGateway=PAYTM    orderId=dsafgsdgsdg     gatewayTxnId=dsafgsdgsdg    upiId=dsafgsdgsdg      bankaccountNo=kjbgkjsbgds    ifscCode=agfygadsf    bankName=gfadjfa    branchName=asfasgf    pancardNo=afsdfasg    gstNumber=afgagaG    bankCheckNo=adgasdgsgd
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-Create PaymentsOut-46

    [Documentation]  Create a Payable where payment status is incomplete and payment mode is EMI.

    ${resp}=  Provider Login  ${PUSERNAME47}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date
    ${amount}=   Random Int  min=500  max=2000
    ${paymentsOutStatus}=   FakerLibrary.word
    ${paymentStatus}=   FakerLibrary.word

    ${resp}=  Create PaymentsOut   ${amount}  ${category_id2}  ${dueDate}   ${payableLabel}    ${description}    ${referenceNo}    ${vendor_uid1}    ${status_id0}    ${Payment_Statuses[2]}    ${finance_payment_modes[2]}    merchantId=dsafgsdgsdg    merchantKey=dsafgsdgsdg    paymentGateway=PAYTM    orderId=dsafgsdgsdg     gatewayTxnId=dsafgsdgsdg    upiId=dsafgsdgsdg      bankaccountNo=kjbgkjsbgds    ifscCode=agfygadsf    bankName=gfadjfa    branchName=asfasgf    pancardNo=afsdfasg    gstNumber=afgagaG    bankCheckNo=adgasdgsgd
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Create PaymentsOut-47

    [Documentation]  Create a Payable where payment status is incomplete and payment mode is Bank_Transfer.

    ${resp}=  Provider Login  ${PUSERNAME47}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date
    ${amount}=   Random Int  min=500  max=2000
    ${paymentsOutStatus}=   FakerLibrary.word
    ${paymentStatus}=   FakerLibrary.word

    ${resp}=  Create PaymentsOut   ${amount}  ${category_id2}  ${dueDate}   ${payableLabel}    ${description}    ${referenceNo}    ${vendor_uid1}    ${status_id0}    ${Payment_Statuses[2]}    ${finance_payment_modes[15]}    merchantId=dsafgsdgsdg    merchantKey=dsafgsdgsdg    paymentGateway=PAYTM    orderId=dsafgsdgsdg     gatewayTxnId=dsafgsdgsdg    upiId=dsafgsdgsdg      bankaccountNo=kjbgkjsbgds    ifscCode=agfygadsf    bankName=gfadjfa    branchName=asfasgf    pancardNo=afsdfasg    gstNumber=afgagaG    bankCheckNo=adgasdgsgd
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Create PaymentsOut-48

    [Documentation]  Create a Payable with payment status as VOID and payment mode is cash.

    ${resp}=  Provider Login  ${PUSERNAME47}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date
    ${amount}=   Random Int  min=500  max=2000
    ${paymentsOutStatus}=   FakerLibrary.word
    ${paymentStatus}=   FakerLibrary.word

    ${resp}=  Create PaymentsOut   ${amount}  ${category_id2}  ${dueDate}   ${payableLabel}    ${description}    ${referenceNo}    ${vendor_uid1}    ${status_id0}    ${Payment_Statuses[3]}    ${finance_payment_modes[0]}    merchantId=dsafgsdgsdg    merchantKey=dsafgsdgsdg    paymentGateway=PAYTM    orderId=dsafgsdgsdg     gatewayTxnId=dsafgsdgsdg    upiId=dsafgsdgsdg      bankaccountNo=kjbgkjsbgds    ifscCode=agfygadsf    bankName=gfadjfa    branchName=asfasgf    pancardNo=afsdfasg    gstNumber=afgagaG    bankCheckNo=adgasdgsgd
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Create PaymentsOut-49

    [Documentation]  Create a Payable where payment status is VOID and payment mode is cc.

    ${resp}=  Provider Login  ${PUSERNAME47}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date
    ${amount}=   Random Int  min=500  max=2000
    ${paymentsOutStatus}=   FakerLibrary.word
    ${paymentStatus}=   FakerLibrary.word

    ${resp}=  Create PaymentsOut   ${amount}  ${category_id2}  ${dueDate}   ${payableLabel}    ${description}    ${referenceNo}    ${vendor_uid1}    ${status_id0}    ${Payment_Statuses[3]}    ${finance_payment_modes[1]}    merchantId=dsafgsdgsdg    merchantKey=dsafgsdgsdg    paymentGateway=PAYTM    orderId=dsafgsdgsdg     gatewayTxnId=dsafgsdgsdg    upiId=dsafgsdgsdg      bankaccountNo=kjbgkjsbgds    ifscCode=agfygadsf    bankName=gfadjfa    branchName=asfasgf    pancardNo=afsdfasg    gstNumber=afgagaG    bankCheckNo=adgasdgsgd
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Create PaymentsOut-50

    [Documentation]  Create a Payable where payment status is VOID and payment mode is DC.

    ${resp}=  Provider Login  ${PUSERNAME47}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date
    ${amount}=   Random Int  min=500  max=2000
    ${paymentsOutStatus}=   FakerLibrary.word
    ${paymentStatus}=   FakerLibrary.word

    ${resp}=  Create PaymentsOut   ${amount}  ${category_id2}  ${dueDate}   ${payableLabel}    ${description}    ${referenceNo}    ${vendor_uid1}    ${status_id0}    ${Payment_Statuses[3]}    ${finance_payment_modes[12]}    merchantId=dsafgsdgsdg    merchantKey=dsafgsdgsdg    paymentGateway=PAYTM    orderId=dsafgsdgsdg     gatewayTxnId=dsafgsdgsdg    upiId=dsafgsdgsdg      bankaccountNo=kjbgkjsbgds    ifscCode=agfygadsf    bankName=gfadjfa    branchName=asfasgf    pancardNo=afsdfasg    gstNumber=afgagaG    bankCheckNo=adgasdgsgd
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Create PaymentsOut-51

    [Documentation]  Create a Payable where payment status is VOID and payment mode is NB.

    ${resp}=  Provider Login  ${PUSERNAME47}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date
    ${amount}=   Random Int  min=500  max=2000
    ${paymentsOutStatus}=   FakerLibrary.word
    ${paymentStatus}=   FakerLibrary.word

    ${resp}=  Create PaymentsOut   ${amount}  ${category_id2}  ${dueDate}   ${payableLabel}    ${description}    ${referenceNo}    ${vendor_uid1}    ${status_id0}    ${Payment_Statuses[3]}    ${finance_payment_modes[8]}    merchantId=dsafgsdgsdg    merchantKey=dsafgsdgsdg    paymentGateway=PAYTM    orderId=dsafgsdgsdg     gatewayTxnId=dsafgsdgsdg    upiId=dsafgsdgsdg      bankaccountNo=kjbgkjsbgds    ifscCode=agfygadsf    bankName=gfadjfa    branchName=asfasgf    pancardNo=afsdfasg    gstNumber=afgagaG    bankCheckNo=adgasdgsgd
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Create PaymentsOut-52

    [Documentation]  Create a Payable where payment status is VOID and payment mode is UPI.

    ${resp}=  Provider Login  ${PUSERNAME47}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date
    ${amount}=   Random Int  min=500  max=2000
    ${paymentsOutStatus}=   FakerLibrary.word
    ${paymentStatus}=   FakerLibrary.word

    ${resp}=  Create PaymentsOut   ${amount}  ${category_id2}  ${dueDate}   ${payableLabel}    ${description}    ${referenceNo}    ${vendor_uid1}    ${status_id0}    ${Payment_Statuses[3]}    ${finance_payment_modes[6]}    merchantId=dsafgsdgsdg    merchantKey=dsafgsdgsdg    paymentGateway=PAYTM    orderId=dsafgsdgsdg     gatewayTxnId=dsafgsdgsdg    upiId=dsafgsdgsdg      bankaccountNo=kjbgkjsbgds    ifscCode=agfygadsf    bankName=gfadjfa    branchName=asfasgf    pancardNo=afsdfasg    gstNumber=afgagaG    bankCheckNo=adgasdgsgd
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Create PaymentsOut-53

    [Documentation]  Create a Payable where payment status is VOID and payment mode is other.

    ${resp}=  Provider Login  ${PUSERNAME47}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date
    ${amount}=   Random Int  min=500  max=2000
    ${paymentsOutStatus}=   FakerLibrary.word
    ${paymentStatus}=   FakerLibrary.word

    ${resp}=  Create PaymentsOut   ${amount}  ${category_id2}  ${dueDate}   ${payableLabel}    ${description}    ${referenceNo}    ${vendor_uid1}    ${status_id0}    ${Payment_Statuses[3]}    ${finance_payment_modes[7]}    merchantId=dsafgsdgsdg    merchantKey=dsafgsdgsdg    paymentGateway=PAYTM    orderId=dsafgsdgsdg     gatewayTxnId=dsafgsdgsdg    upiId=dsafgsdgsdg      bankaccountNo=kjbgkjsbgds    ifscCode=agfygadsf    bankName=gfadjfa    branchName=asfasgf    pancardNo=afsdfasg    gstNumber=afgagaG    bankCheckNo=adgasdgsgd
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Create PaymentsOut-54

    [Documentation]  Create a Payable where payment status is VOID and payment mode is Store credit.

    ${resp}=  Provider Login  ${PUSERNAME47}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date
    ${amount}=   Random Int  min=500  max=2000
    ${paymentsOutStatus}=   FakerLibrary.word
    ${paymentStatus}=   FakerLibrary.word

    ${resp}=  Create PaymentsOut   ${amount}  ${category_id2}  ${dueDate}   ${payableLabel}    ${description}    ${referenceNo}    ${vendor_uid1}    ${status_id0}    ${Payment_Statuses[3]}    ${finance_payment_modes[9]}    merchantId=dsafgsdgsdg    merchantKey=dsafgsdgsdg    paymentGateway=PAYTM    orderId=dsafgsdgsdg     gatewayTxnId=dsafgsdgsdg    upiId=dsafgsdgsdg      bankaccountNo=kjbgkjsbgds    ifscCode=agfygadsf    bankName=gfadjfa    branchName=asfasgf    pancardNo=afsdfasg    gstNumber=afgagaG    bankCheckNo=adgasdgsgd
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Create PaymentsOut-55

    [Documentation]  Create a Payable where payment status is VOID and payment mode is PAYLATER.

    ${resp}=  Provider Login  ${PUSERNAME47}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date
    ${amount}=   Random Int  min=500  max=2000
    ${paymentsOutStatus}=   FakerLibrary.word
    ${paymentStatus}=   FakerLibrary.word

    ${resp}=  Create PaymentsOut   ${amount}  ${category_id2}  ${dueDate}   ${payableLabel}    ${description}    ${referenceNo}    ${vendor_uid1}    ${status_id0}    ${Payment_Statuses[3]}    ${finance_payment_modes[4]}    merchantId=dsafgsdgsdg    merchantKey=dsafgsdgsdg    paymentGateway=PAYTM    orderId=dsafgsdgsdg     gatewayTxnId=dsafgsdgsdg    upiId=dsafgsdgsdg      bankaccountNo=kjbgkjsbgds    ifscCode=agfygadsf    bankName=gfadjfa    branchName=asfasgf    pancardNo=afsdfasg    gstNumber=afgagaG    bankCheckNo=adgasdgsgd
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Create PaymentsOut-56

    [Documentation]  Create a Payable where payment status is VOID and payment mode is offline.

    ${resp}=  Provider Login  ${PUSERNAME47}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date
    ${amount}=   Random Int  min=500  max=2000
    ${paymentsOutStatus}=   FakerLibrary.word
    ${paymentStatus}=   FakerLibrary.word

    ${resp}=  Create PaymentsOut   ${amount}  ${category_id2}  ${dueDate}   ${payableLabel}    ${description}    ${referenceNo}    ${vendor_uid1}    ${status_id0}    ${Payment_Statuses[3]}    ${finance_payment_modes[3]}    merchantId=dsafgsdgsdg    merchantKey=dsafgsdgsdg    paymentGateway=PAYTM    orderId=dsafgsdgsdg     gatewayTxnId=dsafgsdgsdg    upiId=dsafgsdgsdg      bankaccountNo=kjbgkjsbgds    ifscCode=agfygadsf    bankName=gfadjfa    branchName=asfasgf    pancardNo=afsdfasg    gstNumber=afgagaG    bankCheckNo=adgasdgsgd
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Create PaymentsOut-57
    [Documentation]  Create a Payable where payment status is VOID and payment mode is Wallet.

    ${resp}=  Provider Login  ${PUSERNAME47}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date
    ${amount}=   Random Int  min=500  max=2000
    ${paymentsOutStatus}=   FakerLibrary.word
    ${paymentStatus}=   FakerLibrary.word

    ${resp}=  Create PaymentsOut   ${amount}  ${category_id2}  ${dueDate}   ${payableLabel}    ${description}    ${referenceNo}    ${vendor_uid1}    ${status_id0}    ${Payment_Statuses[3]}    ${finance_payment_modes[10]}    merchantId=dsafgsdgsdg    merchantKey=dsafgsdgsdg    paymentGateway=PAYTM    orderId=dsafgsdgsdg     gatewayTxnId=dsafgsdgsdg    upiId=dsafgsdgsdg      bankaccountNo=kjbgkjsbgds    ifscCode=agfygadsf    bankName=gfadjfa    branchName=asfasgf    pancardNo=afsdfasg    gstNumber=afgagaG    bankCheckNo=adgasdgsgd
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Create PaymentsOut-58

    [Documentation]  Create a Payable where payment status is VOID and payment mode is PayLater.

    ${resp}=  Provider Login  ${PUSERNAME47}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date
    ${amount}=   Random Int  min=500  max=2000
    ${paymentsOutStatus}=   FakerLibrary.word
    ${paymentStatus}=   FakerLibrary.word

    ${resp}=  Create PaymentsOut   ${amount}  ${category_id2}  ${dueDate}   ${payableLabel}    ${description}    ${referenceNo}    ${vendor_uid1}    ${status_id0}    ${Payment_Statuses[3]}    ${finance_payment_modes[13]}    merchantId=dsafgsdgsdg    merchantKey=dsafgsdgsdg    paymentGateway=PAYTM    orderId=dsafgsdgsdg     gatewayTxnId=dsafgsdgsdg    upiId=dsafgsdgsdg      bankaccountNo=kjbgkjsbgds    ifscCode=agfygadsf    bankName=gfadjfa    branchName=asfasgf    pancardNo=afsdfasg    gstNumber=afgagaG    bankCheckNo=adgasdgsgd
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
JD-TC-Create PaymentsOut-59

    [Documentation]  Create a Payable where payment status is VOID and payment mode is PAYTM_PostPaid.

    ${resp}=  Provider Login  ${PUSERNAME47}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date
    ${amount}=   Random Int  min=500  max=2000
    ${paymentsOutStatus}=   FakerLibrary.word
    ${paymentStatus}=   FakerLibrary.word

    ${resp}=  Create PaymentsOut   ${amount}  ${category_id2}  ${dueDate}   ${payableLabel}    ${description}    ${referenceNo}    ${vendor_uid1}    ${status_id0}    ${Payment_Statuses[3]}    ${finance_payment_modes[14]}    merchantId=dsafgsdgsdg    merchantKey=dsafgsdgsdg    paymentGateway=PAYTM    orderId=dsafgsdgsdg     gatewayTxnId=dsafgsdgsdg    upiId=dsafgsdgsdg      bankaccountNo=kjbgkjsbgds    ifscCode=agfygadsf    bankName=gfadjfa    branchName=asfasgf    pancardNo=afsdfasg    gstNumber=afgagaG    bankCheckNo=adgasdgsgd
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-Create PaymentsOut-60

    [Documentation]  Create a Payable where payment status is VOID and payment mode is EMI.

    ${resp}=  Provider Login  ${PUSERNAME47}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date
    ${amount}=   Random Int  min=500  max=2000
    ${paymentsOutStatus}=   FakerLibrary.word
    ${paymentStatus}=   FakerLibrary.word

    ${resp}=  Create PaymentsOut   ${amount}  ${category_id2}  ${dueDate}   ${payableLabel}    ${description}    ${referenceNo}    ${vendor_uid1}    ${status_id0}    ${Payment_Statuses[3]}    ${finance_payment_modes[2]}    merchantId=dsafgsdgsdg    merchantKey=dsafgsdgsdg    paymentGateway=PAYTM    orderId=dsafgsdgsdg     gatewayTxnId=dsafgsdgsdg    upiId=dsafgsdgsdg      bankaccountNo=kjbgkjsbgds    ifscCode=agfygadsf    bankName=gfadjfa    branchName=asfasgf    pancardNo=afsdfasg    gstNumber=afgagaG    bankCheckNo=adgasdgsgd
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Create PaymentsOut-61

    [Documentation]  Create a Payable where payment status is VOID and payment mode is Bank_Transfer.

    ${resp}=  Provider Login  ${PUSERNAME47}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date
    ${amount}=   Random Int  min=500  max=2000
    ${paymentsOutStatus}=   FakerLibrary.word
    ${paymentStatus}=   FakerLibrary.word

    ${resp}=  Create PaymentsOut   ${amount}  ${category_id2}  ${dueDate}   ${payableLabel}    ${description}    ${referenceNo}    ${vendor_uid1}    ${status_id0}    ${Payment_Statuses[3]}    ${finance_payment_modes[15]}    merchantId=dsafgsdgsdg    merchantKey=dsafgsdgsdg    paymentGateway=PAYTM    orderId=dsafgsdgsdg     gatewayTxnId=dsafgsdgsdg    upiId=dsafgsdgsdg      bankaccountNo=kjbgkjsbgds    ifscCode=agfygadsf    bankName=gfadjfa    branchName=asfasgf    pancardNo=afsdfasg    gstNumber=afgagaG    bankCheckNo=adgasdgsgd
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-Create PaymentsOut-UH1

    [Documentation]  Create a Payable with empty category id..

    ${resp}=  Provider Login  ${PUSERNAME47}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date
    ${amount}=   Random Int  min=500  max=2000
    ${paymentsOutStatus}=   FakerLibrary.word
    ${paymentStatus}=   FakerLibrary.word

    ${resp}=  Create PaymentsOut   ${amount}  ${EMPTY}  ${dueDate}   ${payableLabel}    ${description}    ${referenceNo}    ${vendor_uid1}    ${status_id0}    ${Payment_Statuses[0]}    ${finance_payment_modes[0]}    merchantId=dsafgsdgsdg    merchantKey=dsafgsdgsdg    paymentGateway=PAYTM    orderId=dsafgsdgsdg     gatewayTxnId=dsafgsdgsdg    upiId=dsafgsdgsdg      bankaccountNo=kjbgkjsbgds    ifscCode=agfygadsf    bankName=gfadjfa    branchName=asfasgf    pancardNo=afsdfasg    gstNumber=afgagaG    bankCheckNo=adgasdgsgd
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${INVALID_PAYMENTOUT_CATEGORY}

JD-TC-Create PaymentsOut-UH2

    [Documentation]  Create a Payable with empty due date.

    ${resp}=  Provider Login  ${PUSERNAME47}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date
    ${amount}=   Random Int  min=500  max=2000
    ${paymentsOutStatus}=   FakerLibrary.word
    ${paymentStatus}=   FakerLibrary.word

    ${resp}=  Create PaymentsOut   ${amount}  ${category_id2}  ${EMPTY}   ${payableLabel}    ${description}    ${referenceNo}    ${vendor_uid1}    ${status_id0}    ${Payment_Statuses[0]}    ${finance_payment_modes[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${PAID_DATE_CANNOT_BE_EMPTY}

JD-TC-Create PaymentsOut-UH3

    [Documentation]   Create Paymentsout without login

     ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date
    ${amount}=   Random Int  min=500  max=2000
    ${paymentsOutStatus}=   FakerLibrary.word
    ${paymentStatus}=   FakerLibrary.word

    ${resp}=  Create PaymentsOut   ${amount}  ${category_id2}  ${EMPTY}   ${payableLabel}    ${description}    ${referenceNo}    ${vendor_uid1}    ${status_id0}    ${Payment_Statuses[0]}    ${finance_payment_modes[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-Create PaymentsOut-UH4

    [Documentation]   Create Category Using Consumer Login

    ${resp}=  ConsumerLogin  ${CUSERNAME1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date
    ${amount}=   Random Int  min=500  max=2000
    ${paymentsOutStatus}=   FakerLibrary.word
    ${paymentStatus}=   FakerLibrary.word

    ${resp}=  Create PaymentsOut   ${amount}  ${category_id2}  ${EMPTY}   ${payableLabel}    ${description}    ${referenceNo}    ${vendor_uid1}    ${status_id0}    ${Payment_Statuses[0]}    ${finance_payment_modes[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   ${resp.json()}   ${LOGIN_NO_ACCESS_FOR_URL}

JD-TC-Create PaymentsOut-UH5

    [Documentation]  Create Paymentout with empty  amount.

    ${resp}=  Provider Login  ${PUSERNAME47}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date
    ${amount}=   Random Int  min=500  max=2000
    ${paymentsOutStatus}=   FakerLibrary.word
    ${paymentStatus}=   FakerLibrary.word

    ${resp}=  Create PaymentsOut   ${empty}  ${category_id2}  ${dueDate}   ${payableLabel}    ${description}    ${referenceNo}    ${vendor_uid1}    ${status_id0}    ${Payment_Statuses[0]}    ${finance_payment_modes[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${INVALID_PAYMENTSOUT_AMOUNT}

JD-TC-Create PaymentsOut-UH6

    [Documentation]  Create a Payable with empty vendor id.

    ${resp}=  Provider Login  ${PUSERNAME47}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date
    ${amount}=   Random Int  min=500  max=2000
    ${paymentsOutStatus}=   FakerLibrary.word
    ${paymentStatus}=   FakerLibrary.word

    ${resp}=  Create PaymentsOut   ${amount}  ${category_id2}  ${dueDate}   ${payableLabel}    ${description}    ${referenceNo}    ${EMPTY}    ${status_id0}    ${Payment_Statuses[0]}    ${finance_payment_modes[0]}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${INVALID_VENDOR}

JD-TC-Create PaymentsOut-UH7

    [Documentation]  Create a Payable where payment mode is upi but upiId is empty.

    ${resp}=  Provider Login  ${PUSERNAME47}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date
    ${amount}=   Random Int  min=500  max=2000
    ${paymentsOutStatus}=   FakerLibrary.word
    ${paymentStatus}=   FakerLibrary.word

    ${resp}=  Create PaymentsOut   ${amount}  ${category_id2}  ${dueDate}   ${payableLabel}    ${description}    ${referenceNo}    ${vendor_uid1}    ${status_id0}    ${Payment_Statuses[0]}    ${finance_payment_modes[6]}       paymentGateway=PAYTM    orderId=dsafgsdgsdg     gatewayTxnId=dsafgsdgsdg    
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${UPI_ID_CANNOT_BE_EMPTY}

JD-TC-Create PaymentsOut-UH8

    [Documentation]  Create a Payable where payment mode is cc but details is empty.

    ${resp}=  Provider Login  ${PUSERNAME47}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date
    ${amount}=   Random Int  min=500  max=2000
    ${paymentsOutStatus}=   FakerLibrary.word
    ${paymentStatus}=   FakerLibrary.word

    ${resp}=  Create PaymentsOut   ${amount}  ${category_id2}  ${dueDate}   ${payableLabel}    ${description}    ${referenceNo}    ${vendor_uid1}    ${status_id0}    ${Payment_Statuses[0]}    ${finance_payment_modes[1]}       
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${CANNOT_BE_EMPTY_GATEWAY_TRANSACTION_ID}