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
Variables         /ebs/TDD/varfiles/musers.py
Variables         /ebs/TDD/varfiles/hl_musers.py



*** Test Cases ***

JD-TC-Apply Discount-1

    [Documentation]  Create discount and apply discount with different discount value.

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
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
    Set Suite Variable   ${category_id}   ${resp.json()}


    ${name1}=   FakerLibrary.word
    Set Suite Variable   ${name1}
    ${resp}=  Create Category   ${name1}  ${categoryType[3]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${category_id2}   ${resp.json()}

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

    ${quantity}=   Random Int  min=100  max=150
    ${quantity}=  Convert To Number  ${quantity}  1
    ${adhocItemList}=  Create Dictionary  itemName=${itemName}   quantity=${quantity}   price=${price}
    ${adhocItemList}=    Create List    ${adhocItemList}

    
    
    ${resp}=  Create Invoice   ${category_id2}    ${invoiceDate}   ${invoiceLabel}   ${address}   ${vendor_uid1}   ${invoiceId}    ${providerConsumerIdList}  adhocItemList=${adhocItemList}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${invoice_uid}   ${resp.json()['uidList'][0]} 

    ${discount1}=     FakerLibrary.word
    ${desc}=   FakerLibrary.word
    ${discountprice1}=     Random Int   min=50   max=100
    ${discountprice}=  Convert To Number  ${discountprice1}  1
    Set Suite Variable   ${discountprice}
    ${resp}=   Create Discount  ${discount1}   ${desc}    ${discountprice}   ${calctype[1]}  ${disctype[0]}
    Log  ${resp.json()}
    Set Suite Variable   ${discountId}   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Discounts 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word
    ${discountValue1}=     Random Int   min=50   max=100
    ${discountValue1}=  Convert To Number  ${discountValue1}  1

    ${resp}=   Apply Discount   ${invoice_uid}   ${discountId}    ${discountprice}   ${privateNote}  ${displayNote}
    Log  ${resp.json()}
    Set Suite Variable   ${discountId1}   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Invoice By Id  ${invoice_uid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['discounts'][0]['id']}  ${discountId}
    Should Be Equal As Strings  ${resp.json()['discounts'][0]['name']}  ${discount1}
    Should Be Equal As Strings  ${resp.json()['discounts'][0]['discountType']}  ${disctype[0]}
    Should Be Equal As Strings  ${resp.json()['discounts'][0]['discountValue']}  ${discountprice}
    Should Be Equal As Strings  ${resp.json()['discounts'][0]['calculationType']}  ${calctype[1]}
    Should Be Equal As Strings  ${resp.json()['discounts'][0]['privateNote']}  ${privateNote}
    Should Be Equal As Strings  ${resp.json()['discounts'][0]['displayNote']}  ${displayNote}

JD-TC-Apply Discount-2

    [Documentation]   Apply discount with empty private note and display note.


    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${discount1}=     FakerLibrary.word
    ${desc}=   FakerLibrary.word
    ${discountprice1}=     Random Int   min=50   max=100
    ${discountprice}=  Convert To Number  ${discountprice1}  1
    Set Suite Variable   ${discountprice}
    ${resp}=   Create Discount  ${discount1}   ${desc}    ${discountprice}   ${calctype[1]}  ${disctype[0]}
    Log  ${resp.json()}
    Set Test Variable   ${discountId}   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Discounts 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${discountValue1}=     Random Int   min=50   max=100
    ${discountValue1}=  Convert To Number  ${discountValue1}  1

    ${resp}=   Apply Discount   ${invoice_uid}   ${discountId}    ${discountprice}   ${EMPTY}  ${EMPTY}
    Log  ${resp.json()}
    Set Suite Variable   ${discountId1}   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Invoice By Id  ${invoice_uid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['discounts'][1]['id']}  ${discountId}
    Should Be Equal As Strings  ${resp.json()['discounts'][1]['name']}  ${discount1}
    Should Be Equal As Strings  ${resp.json()['discounts'][1]['discountType']}  ${disctype[0]}
    Should Be Equal As Strings  ${resp.json()['discounts'][1]['discountValue']}  ${discountprice}
    Should Be Equal As Strings  ${resp.json()['discounts'][1]['calculationType']}  ${calctype[1]}
    Should Be Equal As Strings  ${resp.json()['discounts'][1]['privateNote']}  ${EMPTY}
    Should Be Equal As Strings  ${resp.json()['discounts'][1]['displayNote']}  ${EMPTY}


JD-TC-Apply Discount-3

    [Documentation]   create discount and remove that then apply discount.


    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=   Get Discounts 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word

    ${resp}=   Remove Discount   ${invoice_uid}   ${discountId}    ${discountprice}   ${privateNote}  ${displayNote}
    Log  ${resp.json()}
    Set Suite Variable   ${rmvid}   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Invoice By Id  ${invoice_uid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['discounts']}  []

    ${resp}=   Get Discounts 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=   Apply Discount   ${invoice_uid}   ${discountId}    ${discountprice}   ${EMPTY}  ${EMPTY}
    Log  ${resp.json()}
    Set Suite Variable   ${discountId1}   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Get Invoice By Id  ${invoice_uid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['discounts'][1]['id']}  ${discountId}

JD-TC-Apply Discount-4

    [Documentation]   create percentage type discount apply discount.


    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Apply Discount-5

    [Documentation]   Apply 2 discount and remove from of them and then get invoice details.


    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Apply Discount-UH1

    [Documentation]   apply already applied discount.


    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word


    ${resp}=   Apply Discount   ${invoice_uid}   ${discountId}    ${discountprice}   ${privateNote}  ${displayNote}
    Log  ${resp.json()}
    Set Test Variable   ${discountId1}   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}    ${DISCOUNT_ALREADY_USED}

JD-TC-Apply Discount-UH2

    [Documentation]   Discount is higher than invoice amount.


    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${discount1}=     FakerLibrary.word
    ${desc}=   FakerLibrary.word
    ${discountprice1}=     Random Int   min=2350   max=3500
    ${discountprice}=  Convert To Number  ${discountprice1}  1
    Set Suite Variable   ${discountprice}
    ${resp}=   Create Discount  ${discount1}   ${desc}    ${discountprice}   ${calctype[1]}  ${disctype[0]}
    Log  ${resp.json()}
    Set Test Variable   ${discountId}   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Discounts 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word
    ${discountValue1}=     Random Int   min=50   max=100
    ${discountValue1}=  Convert To Number  ${discountValue1}  1

    ${resp}=   Apply Discount   ${invoice_uid}   ${discountId}    ${discountprice}   ${privateNote}  ${displayNote}
    Log  ${resp.json()}
    Set Suite Variable   ${discountId1}   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}    ${NEED_BILL_AMOUNT_HIGHER_THAN_DISCOUNT}

JD-TC-Apply Discount-UH3

    [Documentation]   Apply discount with discount price is empty.


    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word


    ${resp}=   Apply Discount   ${invoice_uid}   ${discountId}    ${EMPTY}   ${privateNote}  ${displayNote}
    Log  ${resp.json()}
    Set Test Variable   ${discountId1}   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}    ${DISCOUNT_ALREADY_USED}

JD-TC-Apply Discount-UH4

    [Documentation]   Apply discount where invoice_uid is empty.


    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word
    ${invoice}=   FakerLibrary.word


    ${resp}=   Apply Discount   ${invoice}   ${discountId}    ${discountprice}   ${privateNote}  ${displayNote}
    Log  ${resp.json()}
    Set Test Variable   ${discountId1}   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  422
    # Should Be Equal As Strings  ${resp.json()}    ${DISCOUNT_ALREADY_USED}

JD-TC-Apply Discount-UH5

    [Documentation]   Apply discount where discountid is empty.


    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word


    ${resp}=   Apply Discount   ${invoice_uid}   ${EMPTY}    ${discountprice}   ${privateNote}  ${displayNote}
    Log  ${resp.json()}
    Set Test Variable   ${discountId1}   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}    ${INCORRECT_DISCOUNT_ID}

JD-TC-Apply Discount-UH6

    [Documentation]  create invoice as settiled bill status then try to apply  discount .

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word

    ${resp1}=  AddCustomer  ${CUSERNAME10}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Set Suite Variable  ${pcid10}   ${resp1.json()}


    ${providerConsumerIdList}=  Create List  ${pcid10}
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
    ${price}=   Random Int  min=100  max=1500
    ${price}=  Convert To Number  ${price}  1

    ${quantity}=   Random Int  min=5  max=10
    ${quantity}=  Convert To Number  ${quantity}  1
    ${adhocItemList}=  Create Dictionary  itemName=${itemName}   quantity=${quantity}   price=${price}
    ${adhocItemList}=    Create List    ${adhocItemList}
    
    
    ${resp}=  Create Invoice   ${category_id2}    ${invoiceDate}   ${invoiceLabel}   ${address}   ${vendor_uid1}   ${invoiceId}    ${providerConsumerIdList}  adhocItemList=${adhocItemList}    billStatus=${billStatus[1]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${invoice_uid1}   ${resp.json()['uidList'][0]} 


    ${resp}=   Apply Discount   ${invoice_uid1}   ${discountId}    ${empty}   ${privateNote}  ${displayNote}
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${YOU_CANNOT_UPDATE_FINANCE}
    
JD-TC-Apply Discount-UH7

    [Documentation]  update bill status as cancel then try to apply discount .

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word
        ${invoiceLabel}=   FakerLibrary.word
    ${invoiceDate}=   db.get_date_by_timezone  ${tz}

    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word

    ${resp1}=  AddCustomer  ${CUSERNAME9}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Set Suite Variable  ${pcid9}   ${resp1.json()}


    ${providerConsumerIdList}=  Create List  ${pcid9}
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
    ${price}=   Random Int  min=100  max=1500
    ${price}=  Convert To Number  ${price}  1

    ${quantity}=   Random Int  min=5  max=10
    ${quantity}=  Convert To Number  ${quantity}  1
    ${adhocItemList}=  Create Dictionary  itemName=${itemName}   quantity=${quantity}   price=${price}
    ${adhocItemList}=    Create List    ${adhocItemList}
    
    
    ${resp}=  Create Invoice   ${category_id2}    ${invoiceDate}   ${invoiceLabel}   ${address}   ${vendor_uid1}   ${invoiceId}    ${providerConsumerIdList}  adhocItemList=${adhocItemList}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${invoice_uid2}   ${resp.json()['uidList'][0]} 



    ${resp}=  Update bill status   ${invoice_uid2}    ${billStatus[2]}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=   Apply Discount   ${invoice_uid2}   ${discountId}    ${empty}   ${privateNote}  ${displayNote}
    Log  ${resp.json()}
    Set Suite Variable   ${discountId1}   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${YOU_CANNOT_UPDATE_FINANCE_CANCEL}









