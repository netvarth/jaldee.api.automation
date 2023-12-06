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


JD-TC-GenerateLinkForInvoice-1

    [Documentation]  Create a invoice with valid details.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
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
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${name}=   FakerLibrary.word
    Set Suite Variable   ${name}
    ${resp}=  Create Category   ${name}  ${categoryType[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${category_id}   ${resp.json()}
    
    ${name}=   FakerLibrary.word
    ${resp}=  Create Category   ${name}  ${categoryType[1]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${category_id1}   ${resp.json()}

    ${name1}=   FakerLibrary.word
    Set Suite Variable   ${name1}
    ${resp}=  Create Category   ${name1}  ${categoryType[3]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${category_id2}   ${resp.json()}

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
    Set Test Variable  ${email}  ${vender_name}${vendor_phno}.${test_mail}
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
    Set Suite Variable   ${vendor_uid1}   ${resp.json()['uid']}
    Set Suite Variable   ${vendor_id1}   ${resp.json()['id']}

    ${resp}=  Get Vendor By Id   ${vendor_uid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}  ${vendor_id1}
    Should Be Equal As Strings  ${resp.json()['accountId']}  ${account_id1}
    # Should Be Equal As Strings  ${resp.json()['vendorType']}  ${category_id}

    ${resp1}=  AddCustomer  ${CUSERNAME11}
    Log  ${resp1.json()}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Set Suite Variable   ${pcid18}   ${resp1.json()}

    ${providerConsumerIdList}=  Create List  ${pcid18}
    Set Suite Variable  ${providerConsumerIdList}   


    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${invoiceLabel}=   FakerLibrary.word
    ${invoiceDate}=   db.get_date_by_timezone  ${tz}
    ${invoiceId}=   FakerLibrary.word

    ${item}=   Random Int  min=5  max=10
    ${quantity}=   Random Int  min=5  max=10
    ${rate}=   Random Int  min=50  max=1000

    ${itemdata}=   FakerLibrary.words    	nb=4

    ${displayName1}=   FakerLibrary.user name    
    ${price1}=  Evaluate    random.uniform(50.0,300) 
    ${itemName1}=   Set Variable     ${itemdata[0]} 
    ${itemCode1}=   Set Variable     ${itemdata[1]}
    ${resp}=  Create Sample Item   ${displayName1}   ${itemName1}  ${itemCode1}  ${price1}  ${bool[0]}     
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id1}  ${resp.json()}


    ${itemList}=  Create Dictionary  itemId=${item_id1}   quantity=${quantity}   price=${price1}  
    # ${itemList}=    Create List    ${itemList}

    ${resp}=  Create Finance Status   ${New_status[0]}  ${categoryType[3]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${status_id1}   ${resp.json()}

    
    ${resp}=  Create Invoice   ${category_id2}   ${invoiceDate}   ${invoiceLabel}   ${address}   ${vendor_uid1}   ${invoiceId}    ${providerConsumerIdList}    ${itemList}  invoiceStatus=${status_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${invoice_id}   ${resp.json()['idList'][0]}
    Set Suite Variable   ${invoice_uid}   ${resp.json()['uidList'][0]}    

    ${resp1}=  Get Invoice By Id  ${invoice_uid}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Should Be Equal As Strings  ${resp1.json()['accountId']}  ${account_id1}
    Should Be Equal As Strings  ${resp1.json()['invoiceCategoryId']}  ${category_id2}
    Should Be Equal As Strings  ${resp1.json()['categoryName']}  ${name1}
    Should Be Equal As Strings  ${resp1.json()['invoiceDate']}  ${invoiceDate}
    Should Be Equal As Strings  ${resp1.json()['invoiceLabel']}  ${invoiceLabel}
    Should Be Equal As Strings  ${resp1.json()['billedTo']}  ${address}


    ${PO_Number}    Generate random string    5    123456789
    ${vendor_phn}=  Evaluate  ${PUSERNAME}+${PO_Number}
    Set Suite Variable  ${vendor_phn} 
    Set Suite Variable  ${email}  ${vender_name}${vendor_phn}.${test_mail}

    ${resp}=  Generate Link For Invoice  ${invoice_uid}   ${vendor_phn}    ${email}    ${boolean[1]}    ${boolean[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-GenerateLinkForInvoice-2

    [Documentation]  Generate Link For Invoice that already shared.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Generate Link For Invoice  ${invoice_uid}   ${vendor_phn}    ${email}    ${boolean[1]}    ${boolean[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp1}=  Get Invoice By Id  ${invoice_uid}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200

JD-TC-GenerateLinkForInvoice-3

    [Documentation]  Generate Link For Invoice where email is only given.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  Generate Link For Invoice  ${invoice_uid}   ${EMPTY}    ${email}    ${boolean[1]}    ${boolean[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-GenerateLinkForInvoice-4

    [Documentation]  Generate Link For where phone number is only given.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  Generate Link For Invoice  ${invoice_uid}   ${vendor_phn}    ${EMPTY}    ${boolean[0]}    ${boolean[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-GenerateLinkForInvoice-UH1

    [Documentation]  Generate Link For Invoice with invalid invoice id.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${vender_name}=   FakerLibrary.firstname
    ${contactPersonName}=   FakerLibrary.lastname
    ${owner_name}=   FakerLibrary.lastname
    ${vendorId}=   FakerLibrary.words
    ${vendor_phn}=  FakerLibrary.RandomNumber
    Set Test Variable  ${email}  ${vender_name}${vendor_phn}.${test_mail}
    ${invoice}=     FakerLibrary.RandomNumber

    ${resp}=  Generate Link For Invoice  ${invoice}   ${vendor_phn}    ${email}    ${boolean[0]}    ${boolean[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422

JD-TC-GenerateLinkForInvoice-UH2

    [Documentation]  Generate Link For Invoice where notifications are off..

    ${resp}=  Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${vender_name}=   FakerLibrary.firstname
    ${contactPersonName}=   FakerLibrary.lastname
    ${owner_name}=   FakerLibrary.lastname
    ${vendorId}=   FakerLibrary.word
    ${PO_Number}    Generate random string    5    123456789
    ${vendor_phn}=  Evaluate  ${PUSERNAME}+${PO_Number}
    Set Test Variable  ${email}  ${vender_name}${vendor_phn}.${test_mail}

    ${resp}=  Generate Link For Invoice  ${invoice_uid}   ${EMPTY}    ${email}    ${boolean[0]}    ${boolean[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}  ${ENTER_EMAIL_OR_PHONE}

JD-TC-GenerateLinkForInvoice-UH3

    [Documentation]  Generate Link For Invoice where phone number is there but sms notification is off.email is empty and email notification is on...

    ${resp}=  Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${vender_name}=   FakerLibrary.firstname
    ${contactPersonName}=   FakerLibrary.lastname
    ${owner_name}=   FakerLibrary.lastname
    ${vendorId}=   FakerLibrary.word
    ${PO_Number}    Generate random string    5    123456789
    ${vendor_phn}=  Evaluate  ${PUSERNAME}+${PO_Number}
    Set Test Variable  ${email}  ${vender_name}${vendor_phn}.${test_mail}

    ${resp}=  Generate Link For Invoice  ${invoice_uid}   ${vendor_phn}    ${EMPTY}    ${boolean[1]}    ${boolean[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}  ${ENTER_EMAIL_OR_PHONE}

JD-TC-GenerateLinkForInvoice-UH4

    [Documentation]  Generate Link For Invoice where sms and email notification is off.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${vender_name}=   FakerLibrary.firstname
    ${contactPersonName}=   FakerLibrary.lastname
    ${owner_name}=   FakerLibrary.lastname
    ${vendorId}=   FakerLibrary.word
    ${PO_Number}    Generate random string    5    123456789
    ${vendor_phn}=  Evaluate  ${PUSERNAME}+${PO_Number}
    Set Test Variable  ${email}  ${vender_name}${vendor_phn}.${test_mail}

    ${resp}=  Generate Link For Invoice  ${invoice_uid}   ${vendor_phn}    ${email}    ${boolean[0]}    ${boolean[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}  ${ENTER_EMAIL_OR_PHONE}

JD-TC-GenerateLinkForInvoice-UH5

    [Documentation]  Generate Link For Invoice where phone number is invalid.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${vender_name}=   FakerLibrary.firstname
    ${contactPersonName}=   FakerLibrary.lastname
    ${owner_name}=   FakerLibrary.lastname
    ${vendorId}=   FakerLibrary.word
    ${vendor_phn}=  FakerLibrary.RandomNumber
    Set Test Variable  ${email}  ${vender_name}${vendor_phn}.${test_mail}

    ${resp}=  Generate Link For Invoice  ${invoice_uid}   ${vendor_phn}    ${email}    ${boolean[0]}    ${boolean[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422

JD-TC-GenerateLinkForInvoice-UH6

    [Documentation]  Generate Link For Invoice where email id is invalid.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${vender_name}=   FakerLibrary.firstname
    ${contactPersonName}=   FakerLibrary.lastname
    ${owner_name}=   FakerLibrary.lastname
    ${vendorId}=   FakerLibrary.word
    ${PO_Number}    Generate random string    5    123456789
    ${vendor_phn}=  Evaluate  ${PUSERNAME}+${PO_Number}
    ${email}=   FakerLibrary.word

    ${resp}=  Generate Link For Invoice  ${invoice_uid}   ${vendor_phn}    ${email}    ${boolean[0]}    ${boolean[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422