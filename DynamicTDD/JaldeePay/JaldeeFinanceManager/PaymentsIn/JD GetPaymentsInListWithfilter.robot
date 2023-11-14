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


JD-TC-GetPayableWithFilter-1

    [Documentation]  Create a Paymentin then Get PaymentsIn With Filter.

    ${resp}=  Provider Login  ${PUSERNAME23}  ${PASSWORD}
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

    ${resp}=  Get default status    ${categoryType[2]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable    ${status_id0}    ${resp.json()['id']}  

    ${resp}=  Get Category By Id   ${category_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}          ${name}
    Should Be Equal As Strings  ${resp.json()['categoryType']}  ${categoryType[0]}
    Should Be Equal As Strings  ${resp.json()['accountId']}     ${account_id1}
    Should Be Equal As Strings  ${resp.json()['status']}        ${toggle[0]}

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
    Set Suite Variable  ${referenceNo}  
    ${description}=   FakerLibrary.word
    Set Suite Variable  ${description}  

    
    ${payableLabel}=   FakerLibrary.word
    Set Suite Variable  ${payableLabel}   
    ${receivedDate}=   db.get_date
    Set Suite Variable  ${receivedDate}  
    ${amount}=   Random Int  min=500  max=2000
    ${amount}=     roundval    ${amount}   1
    Set Suite Variable  ${amount}  


    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType1}
    ${caption1}=  Fakerlibrary.Sentence
    Set Suite Variable    ${caption1}



    ${resp}    upload file to temporary location    ${LoanAction[0]}    ${pid}    ${ownerType[0]}    ${userName}    ${jpgfile}    ${fileSize}    ${caption1}    ${fileType1}    ${EMPTY}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Set Suite Variable    ${driveId}    ${resp.json()[0]['driveId']}

    ${Attachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType1}  order=${order}  driveId=${driveId}
    Log  ${Attachments}
    ${uploadedDocuments}=  Create List   ${Attachments}
    Set Suite Variable    ${uploadedDocuments}

 

    ${resp}=  Create PaymentsIn   ${amount}  ${category_id2}  ${receivedDate}   ${payableLabel}     ${vendor_uid1}    uploadedDocuments=${uploadedDocuments}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${payable_uid1}   ${resp.json()['uid']}
    Set Suite Variable   ${payable_id1}   ${resp.json()['id']}

    ${resp}=  Get PaymentsIn With Filter    payInOutUuid-eq=${payable_uid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['paymentsInCategoryId']}  ${category_id2}
    Should Be Equal As Strings  ${resp.json()[0]['categoryName']}  ${name1}
    Should Be Equal As Strings  ${resp.json()[0]['paymentsInLabel']}  ${payableLabel}
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  ${amount}
    Should Be Equal As Strings  ${resp.json()[0]['paymentsInUid']}  ${payable_uid1}
    Should Be Equal As Strings  ${resp.json()[0]['receivedDate']}  ${receivedDate}
    Should Be Equal As Strings  ${resp.json()[0]['uploadedDocuments'][0]['fileName']}  ${pdffile}
    Should Be Equal As Strings  ${resp.json()[0]['uploadedDocuments'][0]['fileSize']}  ${fileSize}
    Should Be Equal As Strings  ${resp.json()[0]['uploadedDocuments'][0]['caption']}  ${caption1}
    Should Be Equal As Strings  ${resp.json()[0]['uploadedDocuments'][0]['fileType']}  ${fileType1}
    Should Be Equal As Strings  ${resp.json()[0]['uploadedDocuments'][0]['driveId']}  ${driveId}

JD-TC-GetPayableWithFilter-2

    [Documentation]  Get PaymentsIn With Filter with category id and category name.

    ${resp}=  Provider Login  ${PUSERNAME23}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get PaymentsIn With Filter    paymentsInOutCategory-eq=id::${category_id2}    paymentsInOutCategory-eq=name::${name1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['paymentsInCategoryId']}  ${category_id2}
    Should Be Equal As Strings  ${resp.json()[0]['categoryName']}  ${name1}
    Should Be Equal As Strings  ${resp.json()[0]['paymentsInLabel']}  ${payableLabel}
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  ${amount}
    Should Be Equal As Strings  ${resp.json()[0]['paymentsInUid']}  ${payable_uid1}
    Should Be Equal As Strings  ${resp.json()[0]['receivedDate']}  ${receivedDate}
    Should Be Equal As Strings  ${resp.json()[0]['uploadedDocuments'][0]['fileName']}  ${pdffile}
    Should Be Equal As Strings  ${resp.json()[0]['uploadedDocuments'][0]['fileSize']}  ${fileSize}
    Should Be Equal As Strings  ${resp.json()[0]['uploadedDocuments'][0]['caption']}  ${caption1}
    Should Be Equal As Strings  ${resp.json()[0]['uploadedDocuments'][0]['fileType']}  ${fileType1}
    Should Be Equal As Strings  ${resp.json()[0]['uploadedDocuments'][0]['driveId']}  ${driveId}

JD-TC-GetPayableWithFilter-3

    [Documentation]  Get PaymentsIn With Filter with vendor uid.

    ${resp}=  Provider Login  ${PUSERNAME23}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get PaymentsIn With Filter    vendorUid-eq=${vendor_uid1}    
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['paymentsInCategoryId']}  ${category_id2}
    Should Be Equal As Strings  ${resp.json()[0]['categoryName']}  ${name1}
    Should Be Equal As Strings  ${resp.json()[0]['paymentsInLabel']}  ${payableLabel}
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  ${amount}
    Should Be Equal As Strings  ${resp.json()[0]['paymentsInUid']}  ${payable_uid1}
    Should Be Equal As Strings  ${resp.json()[0]['receivedDate']}  ${receivedDate}
    Should Be Equal As Strings  ${resp.json()[0]['uploadedDocuments'][0]['fileName']}  ${pdffile}
    Should Be Equal As Strings  ${resp.json()[0]['uploadedDocuments'][0]['fileSize']}  ${fileSize}
    Should Be Equal As Strings  ${resp.json()[0]['uploadedDocuments'][0]['caption']}  ${caption1}
    Should Be Equal As Strings  ${resp.json()[0]['uploadedDocuments'][0]['fileType']}  ${fileType1}
    Should Be Equal As Strings  ${resp.json()[0]['uploadedDocuments'][0]['driveId']}  ${driveId}

JD-TC-GetPayableWithFilter-4

    [Documentation]  Get PaymentsIn With Filter with paymentsInOutCategoryId.

    ${resp}=  Provider Login  ${PUSERNAME23}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}
    Set Test Variable  ${referenceNo}  

    ${description}=   FakerLibrary.word
    Set Test Variable  ${description}  
    ${payableLabel}=   FakerLibrary.word
    Set Test Variable  ${payableLabel}  
    ${receivedDate}=   db.get_date
    Set Test Variable  ${receivedDate}  
    ${amount}=   Random Int  min=500  max=2000
    ${amount}=     roundval    ${amount}   1
    Set Test Variable  ${amount}  


   ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType1}
    ${caption1}=  Fakerlibrary.Sentence
    Set Suite Variable    ${caption1}



    ${resp}    upload file to temporary location    ${LoanAction[0]}    ${pid}    ${ownerType[0]}    ${userName}    ${jpgfile}    ${fileSize}    ${caption1}    ${fileType1}    ${EMPTY}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Set Suite Variable    ${driveId}    ${resp.json()[0]['driveId']}

    ${Attachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType1}  order=${order}  driveId=${driveId}
    Log  ${Attachments}
    ${uploadedDocuments}=  Create List   ${Attachments}
    Set Suite Variable    ${uploadedDocuments}

 

    ${resp}=  Create PaymentsIn   ${amount}  ${category_id2}  ${receivedDate}   ${payableLabel}     ${vendor_uid1}    uploadedDocuments=${uploadedDocuments}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${payable_uid1}   ${resp.json()['uid']}
    Set Suite Variable   ${payable_id1}   ${resp.json()['id']}

    ${resp}=  Get PaymentsIn With Filter    paymentsInOutCategory-eq=id::${category_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()[0]['paymentsInCategoryId']}  ${category_id2}
    Should Be Equal As Strings  ${resp.json()[0]['categoryName']}  ${name1}
    Should Be Equal As Strings  ${resp.json()[0]['paymentsInLabel']}  ${payableLabel}
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  ${amount}
    Should Be Equal As Strings  ${resp.json()[0]['paymentsInUid']}  ${payable_uid1}
    Should Be Equal As Strings  ${resp.json()[0]['receivedDate']}  ${receivedDate}
    Should Be Equal As Strings  ${resp.json()[0]['uploadedDocuments'][0]['fileName']}  ${pdffile}
    Should Be Equal As Strings  ${resp.json()[0]['uploadedDocuments'][0]['fileSize']}  ${fileSize}
    Should Be Equal As Strings  ${resp.json()[0]['uploadedDocuments'][0]['caption']}  ${caption1}
    Should Be Equal As Strings  ${resp.json()[0]['uploadedDocuments'][0]['fileType']}  ${fileType1}
    Should Be Equal As Strings  ${resp.json()[0]['uploadedDocuments'][0]['driveId']}  ${driveId}




JD-TC-GetPayableWithFilter-5

    [Documentation]  Get PaymentsIn With Filter  with payInOutUuid and  PaymentsInOutStatus.

    ${resp}=  Provider Login  ${PUSERNAME23}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${pid}  ${resp.json()['id']}
    Set Suite Variable  ${userName}  ${resp.json()['userName']}
    
    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}
    Set Test Variable  ${referenceNo}  

    ${description}=   FakerLibrary.word
    Set Test Variable  ${description}  
    ${payableLabel}=   FakerLibrary.word
    Set Test Variable  ${payableLabel}     
    ${receivedDate}=   db.get_date
    Set Test Variable  ${receivedDate}  
    ${amount}=   Random Int  min=500  max=2000
    ${amount}=     roundval    ${amount}   1
    Set Test Variable  ${amount}  




    ${resp}=  Update PaymentsIn   ${payable_uid1}    ${amount}  ${category_id2}  ${receivedDate}   ${payableLabel}     ${vendor_uid1}    uploadedDocuments=${uploadedDocuments}    
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get PaymentsIn With Filter    payInOutUuid-eq=${payable_uid1}    paymentsInOutStatus-eq=id::${status_id0} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['paymentsInCategoryId']}  ${category_id2}
    Should Be Equal As Strings  ${resp.json()[0]['categoryName']}  ${name1}
    Should Be Equal As Strings  ${resp.json()[0]['paymentsInLabel']}  ${payableLabel}
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  ${amount}
    Should Be Equal As Strings  ${resp.json()[0]['paymentsInUid']}  ${payable_uid1}
    Should Be Equal As Strings  ${resp.json()[0]['receivedDate']}  ${receivedDate}
    Should Be Equal As Strings  ${resp.json()[0]['uploadedDocuments'][0]['fileName']}  ${pdffile}
    Should Be Equal As Strings  ${resp.json()[0]['uploadedDocuments'][0]['fileSize']}  ${fileSize}
    Should Be Equal As Strings  ${resp.json()[0]['uploadedDocuments'][0]['caption']}  ${caption1}
    Should Be Equal As Strings  ${resp.json()[0]['uploadedDocuments'][0]['fileType']}  ${fileType1}
    Should Be Equal As Strings  ${resp.json()[0]['uploadedDocuments'][0]['driveId']}  ${driveId}


JD-TC-GetPayableWithFilter-6

    [Documentation]  Get PaymentsIn With Filter  with receivedDate and  paymentLabel.

    ${resp}=  Provider Login  ${PUSERNAME23}  ${PASSWORD}
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
    Set Test Variable  ${referenceNo}  

    ${description}=   FakerLibrary.word
    Set Test Variable  ${description}  
    ${payableLabel}=   FakerLibrary.word
    Set Test Variable  ${payableLabel}     
    ${receivedDate}=   db.get_date
    Set Test Variable  ${receivedDate}  
    ${amount}=   Random Int  min=500  max=2000
    ${amount}=     roundval    ${amount}   1
    Set Test Variable  ${amount}  



    ${resp}=  Update PaymentsIn   ${payable_uid1}    ${amount}  ${category_id2}  ${receivedDate}   ${payableLabel}     ${vendor_uid1}    uploadedDocuments=${uploadedDocuments}    
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
     ${resp}=  Update PaymentsIn Status    ${payable_uid1}    ${status_id1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get PaymentsIn With Filter     receivedDate-eq=${receivedDate}    paymentLabel-eq=${payableLabel} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['paymentsInCategoryId']}  ${category_id2}
    Should Be Equal As Strings  ${resp.json()[0]['categoryName']}  ${name1}
    Should Be Equal As Strings  ${resp.json()[0]['paymentsInLabel']}  ${payableLabel}
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  ${amount}
    Should Be Equal As Strings  ${resp.json()[0]['paymentsInUid']}  ${payable_uid1}
    Should Be Equal As Strings  ${resp.json()[0]['receivedDate']}  ${receivedDate}
    Should Be Equal As Strings  ${resp.json()[0]['uploadedDocuments'][0]['fileName']}  ${pdffile}
    Should Be Equal As Strings  ${resp.json()[0]['uploadedDocuments'][0]['fileSize']}  ${fileSize}
    Should Be Equal As Strings  ${resp.json()[0]['uploadedDocuments'][0]['caption']}  ${caption1}
    Should Be Equal As Strings  ${resp.json()[0]['uploadedDocuments'][0]['fileType']}  ${fileType1}
    Should Be Equal As Strings  ${resp.json()[0]['uploadedDocuments'][0]['driveId']}  ${driveId}


JD-TC-GetPayableWithFilter-7

    [Documentation]   Get PaymentsIn With Filter with amount .

    ${resp}=  Provider Login  ${PUSERNAME23}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200



    ${payableLabel}=   FakerLibrary.word
    Set Test Variable  ${payableLabel}     
    ${receivedDate}=   db.get_date
    Set Test Variable  ${receivedDate}  
    ${amount}=   Random Int  min=500  max=2000
    ${amount}=     roundval    ${amount}   1
    Set Test Variable  ${amount}  

   ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType1}
    ${caption1}=  Fakerlibrary.Sentence
    Set Suite Variable    ${caption1}



    ${resp}    upload file to temporary location    ${LoanAction[0]}    ${pid}    ${ownerType[0]}    ${userName}    ${jpgfile}    ${fileSize}    ${caption1}    ${fileType1}    ${EMPTY}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Set Suite Variable    ${driveId}    ${resp.json()[0]['driveId']}

    ${Attachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType1}  order=${order}  driveId=${driveId}
    Log  ${Attachments}
    ${uploadedDocuments}=  Create List   ${Attachments}
    Set Suite Variable    ${uploadedDocuments}

 

    ${resp}=  Create PaymentsIn   ${amount}  ${category_id2}  ${receivedDate}   ${payableLabel}     ${vendor_uid1}    uploadedDocuments=${uploadedDocuments}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${payable_uid1}   ${resp.json()['uid']}
    Set Suite Variable   ${payable_id1}   ${resp.json()['id']}

    ${resp}=  Get PaymentsIn With Filter    amount-eq=${amount}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['paymentsInCategoryId']}  ${category_id2}
    Should Be Equal As Strings  ${resp.json()[0]['categoryName']}  ${name1}
    Should Be Equal As Strings  ${resp.json()[0]['paymentsInLabel']}  ${payableLabel}
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  ${amount}
    Should Be Equal As Strings  ${resp.json()[0]['paymentsInUid']}  ${payable_uid1}
    Should Be Equal As Strings  ${resp.json()[0]['receivedDate']}  ${receivedDate}
    Should Be Equal As Strings  ${resp.json()[0]['uploadedDocuments'][0]['fileName']}  ${pdffile}
    Should Be Equal As Strings  ${resp.json()[0]['uploadedDocuments'][0]['fileSize']}  ${fileSize}
    Should Be Equal As Strings  ${resp.json()[0]['uploadedDocuments'][0]['caption']}  ${caption1}
    Should Be Equal As Strings  ${resp.json()[0]['uploadedDocuments'][0]['fileType']}  ${fileType1}
    Should Be Equal As Strings  ${resp.json()[0]['uploadedDocuments'][0]['driveId']}  ${driveId}






JD-TC-GetPayableWithFilter-8

    [Documentation]  Get PaymentsIn With Filter with user id.

    ${resp}=  Provider Login  ${PUSERNAME23}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get PaymentsIn With Filter    provider-eq=${pid}    
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['paymentsInCategoryId']}  ${category_id2}
    Should Be Equal As Strings  ${resp.json()[0]['categoryName']}  ${name1}
    # Should Be Equal As Strings  ${resp.json()['paymentsOutLabel']}  ${EMPTY}
    # Should Be Equal As Strings  ${resp.json()['description']}  ${description}
    # Should Be Equal As Strings  ${resp.json()['amount']}  ${amount}
    # Should Be Equal As Strings  ${resp.json()['referenceNo']}  ${referenceNo}
    # Should Be Equal As Strings  ${resp.json()['paidDate']}  ${receivedDate}
    # Should Be Equal As Strings  ${resp.json()['paymentsOutUid']}  ${payable_uid1}
    # Should Be Equal As Strings  ${resp.json()['paymentsOutStatus']}  ${status_id0}
    # Should Be Equal As Strings  ${resp.json()['paymentInfo']['paymentMode']}  ${finance_payment_modes[0]}


JD-TC-GetPayableWithFilter-UH1

    [Documentation]   Get PaymentsOut By Id  without login.

    ${resp}=  Get PaymentsIn With Filter     payInOutUuid-eq=${payable_uid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-GetPayableWithFilter-UH2

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

    ${fakeid}=   FakerLibrary.Random Number

     ${resp}=  Get PaymentsIn With Filter     payInOutUuid-eq=${payable_uid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()}   []

