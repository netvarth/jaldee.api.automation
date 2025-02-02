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
Variables         /ebs/TDD/varfiles/hl_providers.py

*** Test Cases ***

JD-TC-Assign User-1

    [Documentation]  Create a invoice then assign the invoice to a user.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME19}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}

    Set Suite Variable  ${pid}  ${decrypted_data['id']}
    Set Suite Variable    ${pdrname}    ${decrypted_data['userName']}
    Set Suite Variable    ${pdrfname}    ${decrypted_data['firstName']}
    Set Suite Variable    ${pdrlname}    ${decrypted_data['lastName']}
    
    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}
    Set Suite Variable  ${account_id1}  ${resp.json()['id']}


    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Run Keyword If  ${resp.json()['filterByDept']}==${bool[0]}   Toggle Department Enable
    Run Keyword If  '${resp}' != '${None}'   Log  ${resp.content}
    Run Keyword If  '${resp}' != '${None}'   Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep  2s
    ${resp}=  Get Departments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
     
    ${ph1}=  Evaluate  ${HLPUSERNAME19}+1000410224
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  get_address
    ${dob}=  FakerLibrary.Date
    ${pin}  ${city}  ${district}  ${state}=  get_pin_loc
    
    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${ph1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${ph1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id}  ${resp.json()}

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

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

    ${name1}=   FakerLibrary.word
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
    Should Be Equal As Strings  ${resp.json()['id']}  ${vendor_id1}
    Should Be Equal As Strings  ${resp.json()['accountId']}  ${account_id1}
    # Should Be Equal As Strings  ${resp.json()['vendorType']}  ${category_id}

    ${resp1}=  AddCustomer  ${CUSERNAME11}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Set Suite Variable  ${pcid18}   ${resp1.json()}

    ${providerConsumerIdList}=  Create List  ${pcid18}
    Set Suite Variable  ${providerConsumerIdList}   

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${invoiceLabel}=   FakerLibrary.word
    ${invoiceDate}=   db.get_date_by_timezone  ${tz}
    ${invoiceId}=   FakerLibrary.word

        ${itemName}=    FakerLibrary.word
    Set Suite Variable  ${itemName}
    ${price}=   Random Int  min=10  max=15
    ${price}=  Convert To Number  ${price}  1

    ${quantity}=   Random Int  min=5  max=10
    ${quantity}=  Convert To Number  ${quantity}  1
    ${adhocItemList}=  Create Dictionary  itemName=${itemName}   quantity=${quantity}   price=${price}
    ${adhocItemList}=    Create List    ${adhocItemList}
    
    ${resp}=  Create Invoice   ${category_id2}    ${invoiceDate}   ${invoiceLabel}   ${address}   ${vendor_uid1}   ${invoiceId}    ${providerConsumerIdList}  adhocItemList=${adhocItemList}   billStatus=${billStatus[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${invoice_uid}   ${resp.json()['uidList'][0]}    

    

    ${resp}=  Assign User   ${invoice_uid}  ${u_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp1}=  Get Invoice With Filter  
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Should Be Equal As Strings  ${resp1.json()[0]['accountId']}  ${account_id1}
    Should Be Equal As Strings  ${resp1.json()[0]['invoiceCategoryId']}  ${category_id2}
    Should Be Equal As Strings  ${resp1.json()[0]['categoryName']}  ${name1}
    Should Be Equal As Strings  ${resp1.json()[0]['invoiceDate']}  ${invoiceDate}
    Should Be Equal As Strings  ${resp1.json()[0]['invoiceLabel']}  ${invoiceLabel}
    Should Be Equal As Strings  ${resp1.json()[0]['billedTo']}  ${address}
    Should Be Equal As Strings  ${resp1.json()[0]['assignedUserId']}  ${u_id}

JD-TC-Assign User-2

    [Documentation]  Assign another user to  created invoice.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME19}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${ph1}=  Evaluate  ${HLPUSERNAME19}+1000410223
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  get_address
    ${dob}=  FakerLibrary.Date
    ${pin}  ${city}  ${district}  ${state}=  get_pin_loc
    
    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[1]}  ${P_Email}${ph1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${ph1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id1}  ${resp.json()}

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Assign User   ${invoice_uid}  ${u_id1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp1}=  Get Invoice With Filter  
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    # Should Be Equal As Strings  ${resp1.json()[0]['accountId']}  ${account_id1}
    # Should Be Equal As Strings  ${resp1.json()[0]['invoiceCategoryId']}  ${category_id2}
    # Should Be Equal As Strings  ${resp1.json()[0]['categoryName']}  ${name1}
    # Should Be Equal As Strings  ${resp1.json()[0]['invoiceDate']}  ${invoiceDate}
    # Should Be Equal As Strings  ${resp1.json()[0]['invoiceLabel']}  ${invoiceLabel}
    # Should Be Equal As Strings  ${resp1.json()[0]['billedTo']}  ${address}
    # Should Be Equal As Strings  ${resp1.json()[0]['assignedUserId']}  ${u_id}


JD-TC-Assign User-UH1

    [Documentation]  Assign User with invalid user id.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME19}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${fakeid}=    Random Int  min=1000   max=9999	
    ${resp}=  Assign User   ${invoice_uid}  ${fakeid}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${INVALID_FM_USER_ID}

JD-TC-Assign User-UH2

    [Documentation]  Assign User with already assigned one.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME19}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  Assign User   ${invoice_uid}  ${u_id1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${ALREADY_ASSIGNED_USER}

JD-TC-Assign User-UH3

    [Documentation]  Assign User without login.

    ${resp}=  Assign User   ${invoice_uid}  ${u_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"      "${SESSION_EXPIRED}"

JD-TC-Assign User-UH4

    [Documentation]  Assign User with another Encrypted Provider Login.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
    Log  ${resp.json()}
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


    ${resp}=  Assign User   ${invoice_uid}  ${u_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${INVALID_FM_INVOICE_ID}


JD-TC-Assign User-UH5

    [Documentation]  Assign User with invalid invoice  id.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME19}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${fakeid}=    Random Int  min=1000   max=9999	
    ${resp}=  Assign User   ${fakeid}  ${u_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${INVALID_FM_INVOICE_ID}

JD-TC-Assign User-UH6

    [Documentation]  update bill status as settled and then try to assign user.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME19}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp1}=  Get Invoice By Id  ${invoice_uid}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Should Be Equal As Strings  ${resp1.json()['billStatus']}  ${billStatus[0]}

    ${billStatusNote}=   FakerLibrary.word

    ${resp}=  Update bill status   ${invoice_uid}    ${billStatus[1]}   ${billStatusNote}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   ${INVOICE_STATUS}=  format String   ${INVOICE_STATUS}   ${billStatus[1]}


    ${resp}=  Assign User   ${invoice_uid}  ${u_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${INVOICE_STATUS}

JD-TC-Assign User-UH7

    [Documentation]  bill status is in draft and then try to assign user.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME19}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${invoiceLabel}=   FakerLibrary.word
    ${invoiceDate}=   db.get_date_by_timezone  ${tz}
    ${invoiceId}=   FakerLibrary.word

        ${itemName}=    FakerLibrary.word
    Set Suite Variable  ${itemName}
    ${price}=   Random Int  min=10  max=15
    ${price}=  Convert To Number  ${price}  1

    ${quantity}=   Random Int  min=5  max=10
    ${quantity}=  Convert To Number  ${quantity}  1
    ${adhocItemList}=  Create Dictionary  itemName=${itemName}   quantity=${quantity}   price=${price}
    ${adhocItemList}=    Create List    ${adhocItemList}
    
    ${resp}=  Create Invoice   ${category_id2}    ${invoiceDate}   ${invoiceLabel}   ${address}   ${vendor_uid1}   ${invoiceId}    ${providerConsumerIdList}  adhocItemList=${adhocItemList}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${invoice_uid2}   ${resp.json()['uidList'][0]}   


    ${resp}=  Assign User   ${invoice_uid2}  ${u_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${Draft_status}


JD-TC-Assign User-UH8

    [Documentation]  update bill status as cancelled and then try to assign user.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME19}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${billStatusNote}=   FakerLibrary.word

    ${resp}=  Update bill status   ${invoice_uid2}    ${billStatus[2]}     ${billStatusNote}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${INVOICE_STATUS}=  format String   ${INVOICE_STATUS}   ${apptStatus[4]}

    ${resp}=  Assign User   ${invoice_uid2}  ${u_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${INVOICE_STATUS}


