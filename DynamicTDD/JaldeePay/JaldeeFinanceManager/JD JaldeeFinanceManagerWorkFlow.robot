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
Variables         /ebs/TDD/varfiles/hl_providers.py

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
${service_duration}     30

@{status1}    New     Pending    Assigned     Approved    Rejected
@{New_status}         status1  Proceed     Unassign    Block     Delete    Remove
${DisplayName1}   item1_DisplayName

*** Test Cases ***
JD-TC-FinanceWorkFlow-1

    [Documentation]  Basic work flow-

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME5}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}

    Set Suite Variable  ${pid}  ${decrypted_data['id']}
    Set Suite Variable    ${userName}    ${decrypted_data['userName']}
    Set Suite Variable    ${pdrfname}    ${decrypted_data['firstName']}
    Set Suite Variable    ${pdrlname}    ${decrypted_data['lastName']}
    
    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}
    Set Suite Variable  ${account_id1}  ${resp.json()['id']}


    ${resp}=  Get Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Enable Disable Department  ${toggle[0]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
    END
    ${resp}=  Get Departments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
     
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
        Set Suite Variable  ${dep_id}  ${resp1.json()}
    ELSE
        Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    END

    ${resp}=  Create Sample Location  
    Set Suite Variable    ${lid}    ${resp}  

    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}

# --------------- Create Catagory ------------------------------

    ${name}=   FakerLibrary.word
    ${resp}=  CreateVendorCategory  ${name}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${category_id}   ${resp.json()}

    ${resp}=  Get by encId  ${category_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['name']}          ${name}
    # Should Be Equal As Strings  ${resp.json()['status']}        ${toggle[0]}

    ${name1}=   FakerLibrary.word
    Set Suite Variable   ${name1}
    ${resp}=  Create Category   ${name1}  ${categoryType[3]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${category_id2}   ${resp.json()}

    ${name2}=   FakerLibrary.word
    Set Suite Variable   ${name2}
    ${resp}=  Create Category   ${name2}  ${categoryType[1]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${category_id3}   ${resp.json()}

    ${name3}=   FakerLibrary.word
    Set Suite Variable   ${name3}
    ${resp}=  Create Category   ${name3}  ${categoryType[2]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${category_id4}   ${resp.json()}

    ${name1}=   FakerLibrary.word
    ${resp}=  Update Category   ${category_id3}  ${name1}  ${categoryType[1]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Category By Id   ${category_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['name']}          ${name1}
    # Should Be Equal As Strings  ${resp.json()['categoryType']}  ${categoryType[1]}
    # Should Be Equal As Strings  ${resp.json()['accountId']}     ${account_id1}
    # Should Be Equal As Strings  ${resp.json()['status']}        ${toggle[0]}

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
    
    ${Attachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${account_id1}    ownerType=${ownerType[1]}    ownerName=${userName}   fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${Attachments}

    ${resp}=  Upload Finance Attachment   ${category_id3}    ${categoryType[1]}    ${Attachments}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Category By Id   ${category_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['name']}          ${name1}
    # Should Be Equal As Strings  ${resp.json()['categoryType']}  ${categoryType[1]}
    # Should Be Equal As Strings  ${resp.json()['accountId']}     ${account_id1}
    # Should Be Equal As Strings  ${resp.json()['status']}        ${toggle[0]}


# -------------------------------------------------------------

# ----------------- Create Vender--------------------------------------------

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
    # Should Be Equal As Strings  ${resp.json()['id']}  ${vendor_id1}
    # Should Be Equal As Strings  ${resp.json()['accountId']}  ${account_id1}

# -------------------------------------------------------------


# ----------------- Create Service--------------------------------------------

    ${resp1}=  AddCustomer  ${CUSERNAME39}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    # Set Suite Variable  ${pcid18}   ${resp1.json()}

    ${resp}=    Send Otp For Login    ${CUSERNAME39}    ${account_id1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${CUSERNAME39}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    # ${resp}=  Consumer Logout   
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME39}    ${account_id1}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Suite Variable    ${pcid18}   ${resp.json()['id']}

    ${resp}=  Consumer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME5}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # clear_service   ${HLPUSERNAME5}

    ${providerConsumerIdList}=  Create List  ${pcid18}
    Set Suite Variable  ${providerConsumerIdList} 

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Set Suite Variable  ${SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${servicecharge}=  Convert To Number  ${servicecharge}  1
    ${precharge}=   Random Int  min=10  max=50


    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${service_duration}    ${bool[1]}     ${servicecharge}  ${bool[0]}   minPrePaymentAmount=${precharge}    department=${dep_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid1}  ${resp.json()} 

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings      ${resp.json()[0]['id']}     ${sid1}
    # Should Be Equal As Strings      ${resp.json()[0]['name']}       ${SERVICE1}
    # Should Be Equal As Strings      ${resp.json()[0]['description']}       ${desc}
    # Should Be Equal As Strings      ${resp.json()[0]['serviceDuration']}       ${service_duration}
    # Should Be Equal As Strings      ${resp.json()[0]['totalAmount']}       ${servicecharge}
    # Should Be Equal As Strings      ${resp.json()[0]['status']}       ${status[0]}
    # Should Be Equal As Strings      ${resp.json()[0]['taxable']}       ${bool[0]}
    # Should Be Equal As Strings      ${resp.json()[0]['department']}       ${dep_id}

# -------------------------------------------------------------

# --------------------- Create Expense ----------------------------------------
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
    
    ${Attachments}=    Create Dictionary   action=${FileAction[0]}  owner=${account_id1}    ownerType=${ownerType[1]}    ownerName=${userName}   fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${Attachments}
    ${uploadedDocuments}=    Create List    ${Attachments}


    ${resp}=  Create Expense  ${category_id3}  ${amount}  ${expenseDate}   ${expenseFor}   ${vendor_uid1}   ${description}   ${referenceNo}    ${employeeName}      ${itemList}     ${departmentList}    ${uploadedDocuments}     locationId=${lid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${expense_uid}   ${resp.json()['uid']}
    Set Suite Variable   ${expense_id}   ${resp.json()['id']}

    ${resp}=  Get Expense By Id   ${expense_uid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['expenseCategoryId']}  ${category_id3}
    # Should Be Equal As Strings  ${resp.json()['expenseDate']}  ${expenseDate}
    # Should Be Equal As Strings  ${resp.json()['expenseFor']}  ${expenseFor}
    # Should Be Equal As Strings  ${resp.json()['description']}  ${description}
    # Should Be Equal As Strings  ${resp.json()['amount']}  ${amount}
    # Should Be Equal As Strings  ${resp.json()['referenceNo']}  ${referenceNo}
    # Should Be Equal As Strings  ${resp.json()['expenseUid']}  ${expense_uid}
    # # Should Be Equal As Strings  ${resp.json()['accountId']}  ${account_id1}
    # Should Be Equal As Strings  ${resp.json()['accountId']}  ${account_id1}

    ${amount1}=   Random Int  min=5  max=10
    ${amount1}=  Convert To Number  ${amount1}  1

    ${Attachments}=    Create Dictionary   action=${FileAction[1]}  owner=${account_id1}    ownerType=${ownerType[1]}    ownerName=${userName}   fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${Attachments}
    ${uploadedDocuments}=    Create List    ${Attachments}


    ${resp}=  Update Expense   ${expense_uid}   ${category_id3}  ${amount1}  ${expenseDate}   ${expenseFor}     ${vendor_uid1}   ${description}   ${referenceNo}    ${employeeName}      ${itemList}     ${departmentList}    ${uploadedDocuments}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Get Expense By Id   ${expense_uid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['expenseCategoryId']}  ${category_id3}
    Should Be Equal As Strings  ${resp.json()['amount']}  ${amount1}

    ${resp}=  db.getType   ${pdffile} 
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${pdffile} 
    Set Suite Variable    ${fileType}
    ${caption}=  Fakerlibrary.name
    Set Suite Variable    ${caption}

    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType1}
    ${caption1}=  Fakerlibrary.name
    Set Suite Variable    ${caption1}
    
    ${Attachments}=    Create Dictionary   action=${FileAction[0]}  owner=${account_id1}    ownerType=${ownerType[1]}    ownerName=${userName}   fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${Attachments}

    ${resp}=  Upload Finance Expense Attachment   ${expense_uid}     ${Attachments}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Expense By Id   ${expense_uid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Expense With Filter    categoryName-eq=${name1}    
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[0]['expenseCategoryId']}  ${category_id3}
    # Should Be Equal As Strings  ${resp.json()[0]['description']}  ${description}
    # Should Be Equal As Strings  ${resp.json()[0]['referenceNo']}  ${referenceNo}
    # Should Be Equal As Strings  ${resp.json()[0]['amount']}  ${amount1}
    # Should Be Equal As Strings  ${resp.json()[0]['expenseDate']}  ${expenseDate}
    # Should Be Equal As Strings  ${resp.json()[0]['expenseFor']}  ${expenseFor}
    # Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['quantity']}  ${quantity}
    # Should Be Equal As Strings  ${resp.json()[0]['departmentList'][0]['deptId']}  ${deptId}
    # Should Be Equal As Strings  ${resp.json()[0]['uploadedDocuments'][0]['fileName']}  ${pdffile}

# ------------------------- Create PaymentIn ----------------------------------

    ${payableLabel}=   FakerLibrary.word
    ${receivedDate}=   db.get_date_by_timezone  ${tz}
    ${time_now}=    db.get_time_by_timezone  ${tz}

    ${amount}=   Random Int  min=500  max=2000
    ${amount}=     roundoff    ${amount}   1
 
    ${paymentMode}=    Create Dictionary   paymentMode=${finance_payment_modes[0]}

    ${Attachments1}=    Create Dictionary   action=${FileAction[0]}  owner=${account_id1}    ownerType=${ownerType[1]}    ownerName=${userName}   fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${Attachments1}
    ${uploadedDocuments1}=    Create List    ${Attachments1}

    ${resp}=  Create PaymentsIn   ${amount}  ${category_id4}  ${receivedDate}   ${payableLabel}     ${vendor_uid1}   ${lid}    ${paymentMode}    uploadedDocuments=${uploadedDocuments1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable   ${payable_uid1}   ${resp.json()['uid']}
    Set Suite Variable   ${payable_id1}   ${resp.json()['id']}

    ${resp}=  Get PaymentsIn By Id   ${payable_uid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['paymentsInCategoryId']}  ${category_id4}
    # Should Be Equal As Strings  ${resp.json()['categoryName']}  ${name3}
    # Should Be Equal As Strings  ${resp.json()['paymentsInLabel']}  ${payableLabel}
    # Should Be Equal As Strings  ${resp.json()['amount']}  ${amount}
    # Should Be Equal As Strings  ${resp.json()['paymentsInUid']}  ${payable_uid1}
    # Should Be Equal As Strings  ${resp.json()['receivedDate']}  ${receivedDate}
    # Should Be Equal As Strings  ${resp.json()['uploadedDocuments'][0]['fileName']}  ${pdffile}
    # Should Be Equal As Strings  ${resp.json()['uploadedDocuments'][0]['fileSize']}  ${fileSize}
    # Should Be Equal As Strings  ${resp.json()['uploadedDocuments'][0]['caption']}  ${caption}
    # Should Be Equal As Strings  ${resp.json()['uploadedDocuments'][0]['fileType']}  ${fileType}                                         
    # Should Be Equal As Strings  ${resp.json()['paymentInfo']['paymentMode']}  ${finance_payment_modes[0]}

    ${amount1}=   Random Int  min=500  max=2000
    ${amount1}=     roundoff    ${amount1}   1

    ${resp}=  Update PaymentsIn   ${payable_uid1}    ${amount1}  ${category_id4}  ${receivedDate}   ${payableLabel}     ${vendor_uid1}        ${paymentMode}    uploadedDocuments=${uploadedDocuments}    
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Get PaymentsIn By Id   ${payable_uid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['paymentsInCategoryId']}  ${category_id4}
    # Should Be Equal As Strings  ${resp.json()['categoryName']}  ${name3}
    # Should Be Equal As Strings  ${resp.json()['paymentsInLabel']}  ${payableLabel}
    # Should Be Equal As Strings  ${resp.json()['amount']}  ${amount1}
    # Should Be Equal As Strings  ${resp.json()['vendorUid']}  ${vendor_uid1}
    # Should Be Equal As Strings  ${resp.json()['paymentsInUid']}  ${payable_uid1}
    # Should Be Equal As Strings  ${resp.json()['receivedDate']}  ${receivedDate}
    # Should Be Equal As Strings  ${resp.json()['uploadedDocuments'][0]['fileName']}  ${pdffile}
    # Should Be Equal As Strings  ${resp.json()['uploadedDocuments'][0]['fileSize']}  ${fileSize}
    # Should Be Equal As Strings  ${resp.json()['uploadedDocuments'][0]['caption']}  ${caption}
    # Should Be Equal As Strings  ${resp.json()['uploadedDocuments'][0]['fileType']}  ${fileType}
    # # Should Be Equal As Strings  ${resp.json()['uploadedDocuments'][0]['driveId']}  ${driveId}
    # Should Be Equal As Strings  ${resp.json()['paymentInfo']['paymentMode']}  ${finance_payment_modes[0]}

    ${resp}=  Upload Finance PaymentsIn Attachment   ${payable_uid1}     ${Attachments}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get PaymentsIn By Id   ${payable_uid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get PaymentsIn With Filter    payInOutUuid-eq=${payable_uid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}  

    ${resp}=  Get PaymentsIn Count With Filter    payInOutUuid-eq=${payable_uid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()}   ${len}

    ${resp}=  Get PaymentsIn Log List UId   ${payable_uid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['account']}  ${account_id1}
    Should Be Equal As Strings  ${resp.json()['paymentsInOutUid']}  ${payable_uid1}
    Should Be Equal As Strings  ${resp.json()['isPaymentsIn']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['payInOutStateList'][0]['date']}  ${receivedDate}
    Should Be Equal As Strings  ${resp.json()['payInOutStateList'][0]['userType']}  ${userType[0]}
    Should Be Equal As Strings  ${resp.json()['payInOutStateList'][0]['localUserId']}  ${pid}
    # Should Be Equal As Strings  ${resp.json()['payInOutStateList'][0]['time']}  ${time_now}