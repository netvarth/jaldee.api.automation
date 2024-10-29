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
${pdffile}      /ebs/TDD/sample.pdf


${order}    0
${fileSize}  0.00458

*** Test Cases ***


JD-TC-GetExpenseById-1

    [Documentation]  Create Expense for an SP and Get that Expense By id.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME62}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}

    Set Suite Variable  ${pid}  ${decrypted_data['id']}
    Set Suite Variable    ${pdrname}    ${decrypted_data['userName']}
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

    ${resp}=  Get Category By Id   ${category_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}          ${name}
    Should Be Equal As Strings  ${resp.json()['categoryType']}  ${categoryType[1]}
    Should Be Equal As Strings  ${resp.json()['accountId']}     ${account_id1}
    Should Be Equal As Strings  ${resp.json()['status']}        ${toggle[0]}

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
    Set Suite Variable   ${encId}   ${resp.json()['encId']}
    Set Suite Variable   ${vendor_uid1}   ${resp.json()['encId']}
    Set Suite Variable   ${vendor_id1}   ${resp.json()['id']}

    ${resp}=  Get vendor by encId   ${encId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}  ${vendor_id1}
    Should Be Equal As Strings  ${resp.json()['accountId']}  ${account_id1}
    # Should Be Equal As Strings  ${resp.json()['vendorType']}  ${category_id}


    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${expenseFor}=   FakerLibrary.word
    ${expenseDate}=   db.get_date_by_timezone  ${tz}
    ${amount}=   Random Int  min=500  max=2000
    ${employeeName}=   FakerLibrary.name
    ${item}=   FakerLibrary.word
    ${quantity}=   Random Int  min=5  max=10
    ${rate}=   Random Int  min=50  max=1000
    ${amount}=   Random Int  min=50  max=1000
    ${amount}=     roundoff    ${amount}   1

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
    Set Suite Variable   ${expense_id}   ${resp.json()['id']}

    ${resp}=  Get Expense By Id   ${expense_uid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['expenseCategoryId']}  ${category_id1}
    Should Be Equal As Strings  ${resp.json()['expenseDate']}  ${expenseDate}
    Should Be Equal As Strings  ${resp.json()['expenseFor']}  ${expenseFor}
    Should Be Equal As Strings  ${resp.json()['description']}  ${description}
    Should Be Equal As Strings  ${resp.json()['amount']}  ${amount}
    Should Be Equal As Strings  ${resp.json()['referenceNo']}  ${referenceNo}
    Should Be Equal As Strings  ${resp.json()['expenseUid']}  ${expense_uid}
    # Should Be Equal As Strings  ${resp.json()['accountId']}  ${account_id1}
    Should Be Equal As Strings  ${resp.json()['accountId']}  ${account_id1}

JD-TC-GetExpenseById-2

    [Documentation]   update expense and get expense by id.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME62}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${expenseFor}=   FakerLibrary.word
    ${expenseDate}=   db.get_date_by_timezone  ${tz}
    ${employeeName}=   FakerLibrary.name
    ${item}=   FakerLibrary.word
    ${quantity}=   Random Int  min=5  max=10
    ${quantity}=  Convert To Number  ${quantity}  1
    ${rate}=   Random Int  min=50  max=1000
    ${amount}=   Random Int  min=50  max=1000
    ${amount}=  Convert To Number  ${amount}  1
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
    
    ${Attachments}=    Create Dictionary   action=${FileAction[0]}  owner=${account_id1}    ownerType=${ownerType[1]}    ownerName=${userName}   fileName=${jpgfile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType1}  order=${order}
    Log  ${Attachments}
    ${uploadedDocuments}=    Create List    ${Attachments}

    ${resp}=  Update Expense   ${expense_uid}   ${category_id1}  ${amount}  ${expenseDate}   ${expenseFor}     ${vendor_uid1}   ${description}   ${referenceNo}    ${employeeName}      ${itemList}     ${departmentList}    ${uploadedDocuments}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Get Expense By Id   ${expense_uid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['expenseCategoryId']}  ${category_id1}
    Should Be Equal As Strings  ${resp.json()['description']}  ${description}
    Should Be Equal As Strings  ${resp.json()['referenceNo']}  ${referenceNo}
    Should Be Equal As Strings  ${resp.json()['amount']}  ${amount}
    Should Be Equal As Strings  ${resp.json()['expenseDate']}  ${expenseDate}
    Should Be Equal As Strings  ${resp.json()['expenseFor']}  ${expenseFor}
    Should Be Equal As Strings  ${resp.json()['expenseFor']}  ${expenseFor}
    Should Be Equal As Strings  ${resp.json()['itemList'][0]['quantity']}  ${quantity}
    Should Be Equal As Strings  ${resp.json()['departmentList'][0]['deptId']}  ${deptId}
    Should Be Equal As Strings  ${resp.json()['uploadedDocuments'][1]['fileName']}  ${jpgfile}


JD-TC-GetExpenseById-3
  
  [Documentation]   update expense with empty reference number aet expense by id.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME62}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${expenseFor}=   FakerLibrary.word
    ${expenseDate}=   db.get_date_by_timezone  ${tz}
    ${employeeName}=   FakerLibrary.name
    ${item}=   FakerLibrary.word
    ${quantity}=   Random Int  min=5  max=10
    ${quantity}=  Convert To Number  ${quantity}  1
    ${rate}=   Random Int  min=50  max=1000
    ${amount}=   Random Int  min=50  max=1000
    ${amount}=  Convert To Number  ${amount}  1
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
    
    ${Attachments}=    Create Dictionary   action=${FileAction[0]}  owner=${account_id1}    ownerType=${ownerType[1]}    ownerName=${userName}   fileName=${jpgfile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType1}  order=${order}
    Log  ${Attachments}
    ${uploadedDocuments}=    Create List    ${Attachments}

    ${resp}=  Update Expense   ${expense_uid}   ${category_id1}  ${amount}  ${expenseDate}   ${expenseFor}     ${vendor_uid1}   ${description}   ${EMPTY}    ${employeeName}      ${itemList}     ${departmentList}    ${uploadedDocuments}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Get Expense By Id   ${expense_uid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['expenseCategoryId']}  ${category_id1}
    Should Be Equal As Strings  ${resp.json()['description']}  ${description}
    Should Be Equal As Strings  ${resp.json()['referenceNo']}  ${EMPTY}
    Should Be Equal As Strings  ${resp.json()['amount']}  ${amount}
    Should Be Equal As Strings  ${resp.json()['expenseDate']}  ${expenseDate}
    Should Be Equal As Strings  ${resp.json()['expenseFor']}  ${expenseFor}
    Should Be Equal As Strings  ${resp.json()['expenseFor']}  ${expenseFor}
    Should Be Equal As Strings  ${resp.json()['itemList'][0]['quantity']}  ${quantity}
    Should Be Equal As Strings  ${resp.json()['departmentList'][0]['deptId']}  ${deptId}
    Should Be Equal As Strings  ${resp.json()['uploadedDocuments'][2]['fileName']}  ${jpgfile}

JD-TC-GetExpenseById-4

    [Documentation]  Create Expense for an SP then update the description and  GetExpenseById.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME62}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${expenseFor}=   FakerLibrary.word
    ${expenseDate}=   db.get_date_by_timezone  ${tz}
    ${amount}=   Random Int  min=500  max=2000
    ${employeeName}=   FakerLibrary.name
    ${item}=   FakerLibrary.word
    ${quantity}=   Random Int  min=5  max=10
    ${rate}=   Random Int  min=50  max=1000
    ${amount}=   Random Int  min=50  max=1000
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
    
    ${Attachments}=    Create Dictionary   action=${FileAction[0]}  owner=${account_id1}    ownerType=${ownerType[1]}    ownerName=${userName}   fileName=${jpgfile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType1}  order=${order}
    Log  ${Attachments}
    ${uploadedDocuments}=    Create List    ${Attachments}
    
    ${resp}=  Create Expense  ${category_id1}  ${amount}  ${expenseDate}   ${expenseFor}   ${vendor_uid1}   ${description}   ${referenceNo}    ${employeeName}      ${itemList}     ${departmentList}    ${uploadedDocuments}   locationId=${lid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${expense_uid1}   ${resp.json()['uid']}
    Set Suite Variable   ${expense_id1}   ${resp.json()['id']}

    ${description1}=   FakerLibrary.word    


    ${resp}=  Update Expense   ${expense_uid1}   ${category_id1}  ${amount}  ${expenseDate}   ${expenseFor}     ${vendor_uid1}   ${description1}   ${referenceNo}    ${employeeName}      ${itemList}     ${departmentList}    ${uploadedDocuments}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Get Expense By Id   ${expense_uid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['expenseCategoryId']}  ${category_id1}
    Should Be Equal As Strings  ${resp.json()['description']}  ${description1}

JD-TC-GetExpenseById-UH1
    [Documentation]  GetExpenseById  without login.

     ${resp}=  Get Expense By Id   ${expense_uid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-GetExpenseById-UH2
    [Documentation]  GetExpenseById  with another login.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME128}  ${PASSWORD}
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

     ${resp}=  Get Expense By Id   ${expense_uid1}
    Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}    ${INVALID_FM_EXPENSE_ID}

JD-TC-GetExpenseById-UH3
    [Documentation]  GetExpenseById  with invalid id

    ${resp}=  Encrypted Provider Login  ${PUSERNAME62}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${fakeid}=   FakerLibrary.Random Number

     ${resp}=  Get Expense By Id   ${fakeid}
    Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}    ${INVALID_FM_EXPENSE_ID}