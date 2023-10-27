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

JD-TC-GetPayableCountWithFilter-1

    [Documentation]  Create a Payable then Get PaymentsOut Count With Filter.

    ${resp}=  Provider Login  ${PUSERNAME51}  ${PASSWORD}
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
    Set Suite Variable    ${name1}
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

    ${resp}=  Create PaymentsOut   ${amount}  ${category_id2}  ${dueDate}   ${payableLabel}    ${description}    ${referenceNo}    ${vendor_uid1}     ${status_id0}    ${Payment_Statuses[0]}    ${finance_payment_modes[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${payable_uid1}   ${resp.json()['uid']}
    Set Suite Variable   ${payable_id1}   ${resp.json()['id']}

    ${resp}=  Get PaymentsOut With Filter    payInOutUuid-eq=${payable_uid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}  

    ${resp}=  Get PaymentsOut Count With Filter    payInOutUuid-eq=${payable_uid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()}   ${len}

JD-TC-GetPayableCountWithFilter-2

    [Documentation]  GetPayableCountWithFilter with paymentsInOutCategoryId.

    ${resp}=  Provider Login  ${PUSERNAME51}  ${PASSWORD}
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

    ${resp}=  Create PaymentsOut   ${amount}  ${category_id2}  ${dueDate}   ${payableLabel}    ${description}    ${referenceNo}    ${vendor_uid1}    ${status_id0}    ${Payment_Statuses[0]}    ${finance_payment_modes[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${payable_uid1}   ${resp.json()['uid']}

    ${resp}=  Get PaymentsOut With Filter    paymentsInOutCategory-eq=id::${category_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}  

    ${resp}=  Get PaymentsOut Count With Filter    paymentsInOutCategory-eq=id::${category_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()}   ${len}


JD-TC-GetPayableCountWithFilter-3

    [Documentation]  GetPayableCountWithFilter with payInOutUuid and  PaymentsInOutStatus.

    ${resp}=  Provider Login  ${PUSERNAME51}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${pid}  ${resp.json()['id']}
    Set Suite Variable  ${userName}  ${resp.json()['userName']}
    
    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date
    ${amount}=   Random Int  min=500  max=2000
    ${amount}=     roundval    ${amount}   1



    ${resp}=  Update PaymentsOut   ${payable_uid1}    ${amount}  ${category_id2}  ${dueDate}   ${payableLabel}    ${description}    ${referenceNo}    ${vendor_uid1}    ${SPACE}    ${Payment_Statuses[0]}    ${finance_payment_modes[4]}    
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get PaymentsOut With Filter    payInOutUuid-eq=${payable_uid1}    paymentsInOutStatus-eq=id::${status_id0} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}  

    ${resp}=  Get PaymentsOut Count With Filter    payInOutUuid-eq=${payable_uid1}   paymentsInOutStatus-eq=id::${status_id0} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()}   ${len}


JD-TC-GetPayableCountWithFilter-4

    [Documentation]  GetPayableCountWithFilter with paidDate and  paymentLabel.

    ${resp}=  Provider Login  ${PUSERNAME51}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${pid}  ${resp.json()['id']}
    Set Suite Variable  ${userName}  ${resp.json()['userName']}

    ${resp}=  Create Finance Status   ${New_status[0]}  ${categoryType[2]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${status_id1}   ${resp.json()}

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${payableLabel}=   FakerLibrary.word
    ${dueDate}=   db.get_date
    ${amount}=   Random Int  min=500  max=2000
    ${amount}=     roundval    ${amount}   1



    ${resp}=  Update PaymentsOut   ${payable_uid1}    ${amount}  ${category_id2}  ${dueDate}   ${payableLabel}    ${description}    ${referenceNo}    ${vendor_uid1}    ${SPACE}    ${Payment_Statuses[0]}    ${finance_payment_modes[4]}    
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
     ${resp}=  Update PaymentsOut Status   ${payable_uid1}    ${status_id1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get PaymentsOut With Filter    paidDate-eq=${dueDate}    paymentLabel-eq=${payableLabel} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}  

    ${resp}=  Get PaymentsOut Count With Filter    paidDate-eq=${dueDate}    paymentLabel-eq=${payableLabel} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()}   ${len}


JD-TC-GetPayableCountWithFilter-5

    [Documentation]  GetPayableCountWithFilter with amount and  referenceNo. .

    ${resp}=  Provider Login  ${PUSERNAME51}  ${PASSWORD}
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
    Set Suite Variable   ${payable_uid2}   ${resp.json()['uid']}

    ${resp}=  Get PaymentsOut With Filter    amount-eq=${amount}    referenceNo-eq=${referenceNo} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}  

    ${resp}=  Get PaymentsOut Count With Filter    amount-eq=${amount}    referenceNo-eq=${referenceNo} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()}   ${len}

JD-TC-GetPayableCountWithFilter-6

    [Documentation]  GetPayableCountWithFilter with category id and category name.

    ${resp}=  Provider Login  ${PUSERNAME51}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get PaymentsOut With Filter    paymentsInOutCategory-eq=id::${category_id2}    paymentsInOutCategory-eq=name::${name1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}  

    ${resp}=  Get PaymentsOut Count With Filter    paymentsInOutCategory-eq=id::${category_id2}     paymentsInOutCategory-eq=name::${name1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()}   ${len}

JD-TC-GetPayableCountWithFilter-7

    [Documentation]  GetPayableCountWithFilter with vendor id.

    ${resp}=  Provider Login  ${PUSERNAME51}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get PaymentsOut With Filter    vendorUid-eq=${vendor_uid1}    
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}  

    ${resp}=  Get PaymentsOut Count With Filter    vendorUid-eq=${vendor_uid1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()}   ${len}


JD-TC-GetPayableCountWithFilter-8

    [Documentation]  GetPayableCountWithFilter with user id.

    ${resp}=  Provider Login  ${PUSERNAME51}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get PaymentsOut With Filter    provider-eq=${pid}    
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}  

    ${resp}=  Get PaymentsOut Count With Filter    provider-eq=${pid}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()}   ${len}


JD-TC-GetPayableCountWithFilter-UH1

    [Documentation]   Get PaymentsOut By Id  without login.

    ${resp}=  Get PaymentsOut Count With Filter    payInOutUuid-eq=${payable_uid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-GetPayableCountWithFilter-UH2

    [Documentation]   Get PaymentsOut By Id using another provider login

    ${resp}=  Provider Login  ${PUSERNAME134}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

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

    ${resp}=  Get PaymentsOut With Filter    payInOutUuid-eq=${payable_uid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}  

     ${resp}=  Get PaymentsOut Count With Filter    payInOutUuid-eq=${payable_uid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()}   ${len}




