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
${service_duration}     30

@{status1}    New     Pending    Assigned     Approved    Rejected
@{New_status}         status1  Proceed     Unassign    Block     Delete    Remove
${DisplayName1}   item1_DisplayName

*** Test Cases ***
JD-TC-MakePaymentByCash-1

    [Documentation]  provider takes waitlist and accept payment then consumer get details
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME195}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_customer   ${PUSERNAME195}

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

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}

    ${name}=   FakerLibrary.word
    Set Suite Variable   ${name}
    ${resp}=  CreateVendorCategory  ${name}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${category_id}   ${resp.json()}

    ${resp}=  Get by encId  ${category_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['name']}          ${name}
    # Should Be Equal As Strings  ${resp.json()['status']}        ${toggle[0]}
    
    ${name}=   FakerLibrary.word
    # ${resp}=  Create Category   ${name}  ${categoryType[1]} 
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${category_id1}   ${resp.json()}

    ${name1}=   FakerLibrary.word
    Set Suite Variable   ${name1}
    ${resp}=  Create Category   ${name1}  ${categoryType[3]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${category_id2}   ${resp.json()}

    # ${resp}=  Get Category By Id   ${category_id1}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['name']}          ${name}
    # Should Be Equal As Strings  ${resp.json()['categoryType']}  ${categoryType[1]}
    # Should Be Equal As Strings  ${resp.json()['accountId']}     ${account_id1}
    # Should Be Equal As Strings  ${resp.json()['status']}        ${toggle[0]}

    # ${vender_name}=   FakerLibrary.firstname
    # ${contactPersonName}=   FakerLibrary.lastname
    # ${owner_name}=   FakerLibrary.lastname
    # ${vendorId}=   FakerLibrary.word
    # ${PO_Number}    Generate random string    5    123456789
    # ${vendor_phno}=  Evaluate  ${PUSERNAME}+${PO_Number}
    # ${vendor_phno}=  Create Dictionary  countryCode=${countryCodes[0]}   number=${vendor_phno}
    # Set Test Variable  ${email}  ${vender_name}.${test_mail}
    # ${address}=  FakerLibrary.city
    # Set Suite Variable  ${address}
    # ${bank_accno}=   db.Generate_random_value  size=11   chars=${digits} 
    # ${branch}=   db.get_place
    # ${ifsc_code}=   db.Generate_ifsc_code
    # # ${gst_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}

    # ${pin}  ${city}  ${district}  ${state}=  get_pin_loc

    # ${state}=    Evaluate     "${state}".title()
    # ${state}=    String.RemoveString  ${state}    ${SPACE}
    # Set Suite Variable    ${state}
    # Set Suite Variable    ${district}
    # Set Suite Variable    ${pin}
    # ${vendor_phno}=   Create List  ${vendor_phno}
    # Set Suite Variable    ${vendor_phno}
    
    # ${email}=   Create List  ${email}
    # Set Suite Variable    ${email}

    # ${bankIfsc}    Random Number 	digits=5 
    # ${bankIfsc}=    Evaluate    f'{${bankIfsc}:0>7d}'
    # Log  ${bankIfsc}
    # Set Suite Variable  ${bankIfsc}  55555${bankIfsc} 

    # ${bankName}     FakerLibrary.name
    # Set Suite Variable    ${bankName}

    # ${upiId}     FakerLibrary.name
    # Set Suite Variable  ${upiId}

    # ${pan}    Random Number 	digits=5 
    # ${pan}=    Evaluate    f'{${pan}:0>5d}'
    # Log  ${pan}
    # Set Suite Variable  ${pan}  55555${pan}

    # ${branchName}=    FakerLibrary.name
    # Set Suite Variable  ${branchName}
    # ${gstin}    Random Number 	digits=5 
    # ${gstin}=    Evaluate    f'{${gstin}:0>8d}'
    # Log  ${gstin}
    # Set Suite Variable  ${gstin}  55555${gstin}
    
    # ${preferredPaymentMode}=    Create List    ${jaldeePaymentmode[0]}
    # ${bankInfo}=    Create Dictionary     bankaccountNo=${bank_accno}    ifscCode=${bankIfsc}    bankName=${bankName}    upiId=${upiId}     branchName=${branchName}    pancardNo=${pan}    gstNumber=${gstin}    preferredPaymentMode=${preferredPaymentMode}    lastPaymentModeUsed=${jaldeePaymentmode[0]}
    # ${bankInfo}=    Create List         ${bankInfo}
    
    # ${resp}=  Create Vendor  ${category_id}  ${vendorId}  ${vender_name}   ${contactPersonName}    ${address}    ${state}    ${pin}   ${vendor_phno}   ${email}     bankInfo=${bankInfo}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${vendor_uid1}   ${resp.json()['encId']}
    # Set Suite Variable   ${vendor_id1}   ${resp.json()['id']}

    # ${resp}=  Get vendor by encId   ${vendor_uid1}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['id']}  ${vendor_id1}
    # Should Be Equal As Strings  ${resp.json()['accountId']}  ${account_id1}
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
    ${invoiceDate}=   db.get_date
    # ${invoiceDate}=   Get Current Date    result_format=%Y/%m/%d
    ${invoiceId}=   FakerLibrary.word

    ${item1}=     FakerLibrary.word
    ${itemCode1}=     FakerLibrary.word
    ${price1}=     Random Int   min=400   max=500
    ${price}=  Convert To Number  ${price1}  1
    Set Suite Variable  ${price} 
    ${resp}=  Create Sample Item   ${DisplayName1}   ${item1}  ${itemCode1}  ${price}  ${bool[1]} 
    Log  ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${itemId}  ${resp.json()}

    ${resp}=   Get Item By Id  ${itemId}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${promotionalPrice}   ${resp.json()['promotionalPrice']}


    ${quantity}=   Random Int  min=5  max=10
    ${quantity}=  Convert To Number  ${quantity}  1
    ${itemList}=  Create Dictionary  itemId=${itemId}   quantity=${quantity}   price=${promotionalPrice}
    # ${itemList}=    Create List    ${itemList}

    ${resp}=  Create Finance Status   ${New_status[3]}  ${categoryType[3]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${status_id1}   ${resp.json()}

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Set Suite Variable  ${SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${serviceprice}=   Random Int  min=10  max=15
    ${serviceprice}=  Convert To Number  ${serviceprice}  1
    ${srv_duration}=   Random Int   min=10   max=20

    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${srv_duration}  ${bool[0]}  ${servicecharge}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid1}  ${resp.json()}

    ${serviceList}=  Create Dictionary  serviceId=${sid1}   quantity=${quantity}  price=${serviceprice}
    ${serviceList}=    Create List    ${serviceList}


    ${itemName}=    FakerLibrary.word
    Set Suite Variable  ${itemName}
    ${price}=   Random Int  min=10  max=15
    ${price}=  Convert To Number  ${price}  1
    ${adhocItemList}=  Create Dictionary  itemName=${itemName}   quantity=${quantity}   price=${price}
    ${adhocItemList}=    Create List    ${adhocItemList}


    ${resp}=  Create Invoice   ${category_id2}    ${invoiceDate}   ${invoiceId}    ${providerConsumerIdList}   ${lid}    ${itemList}  invoiceStatus=${status_id1}    serviceList=${serviceList}   adhocItemList=${adhocItemList}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${invoice_id}   ${resp.json()['idList'][0]}
    Set Suite Variable   ${invoice_uid}   ${resp.json()['uidList'][0]}    

    ${resp1}=  Get Invoice By Id  ${invoice_uid}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    # Should Be Equal As Strings  ${resp1.json()['accountId']}  ${account_id1}
    # Should Be Equal As Strings  ${resp1.json()['invoiceCategoryId']}  ${category_id2}
    # Should Be Equal As Strings  ${resp1.json()['categoryName']}  ${name1}
    # Should Be Equal As Strings  ${resp1.json()['invoiceDate']}  ${invoiceDate}
    # Should Be Equal As Strings  ${resp1.json()['invoiceLabel']}  ${invoiceLabel}
    # Should Be Equal As Strings  ${resp1.json()['billedTo']}  ${address}
    # Should Be Equal As Strings  ${resp1.json()['serviceList'][0]['serviceId']}  ${sid1}
    # Should Be Equal As Strings  ${resp1.json()['serviceList'][0]['quantity']}  ${quantity}
    # Should Be Equal As Strings  ${resp1.json()['adhocItemList'][0]['itemName']}  ${itemName}
    # Should Be Equal As Strings  ${resp1.json()['adhocItemList'][0]['quantity']}  ${quantity}
    # Should Be Equal As Strings  ${resp1.json()['adhocItemList'][0]['price']}  ${price}

    ${adhoc_amt}=    Evaluate  ${price}*${quantity}
    ${service_amt}=    Evaluate  ${serviceprice}*${quantity}
    ${item_amt}=    Evaluate  ${promotionalPrice}*${quantity}

    ${discAmt}=    Evaluate  ${adhoc_amt}+${service_amt}+${item_amt}

    ${balance}=    evaluate    ${discAmt}-10
    ${balance}=  Convert To Number  ${balance}  2

    ${note}=    FakerLibrary.word
    ${resp}=  Make Payment By Cash For Invoice   ${invoice_uid}  ${payment_modes[0]}  10  ${note}  paymentOndate=${DAY1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp1}=  Get Invoice By Id  ${invoice_uid}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Should Be Equal As Strings  ${resp1.json()['amountDue']}  ${balance}
    Should Be Equal As Strings  ${resp1.json()['amountPaid']}  10.0

JD-TC-MakePaymentByCash-2

    [Documentation]  Make payment by cash with different note.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME195}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${note}=    FakerLibrary.word
    ${resp}=  Make Payment By Cash For Invoice   ${invoice_uid}  ${payment_modes[0]}  10  ${note}    paymentOndate=${DAY1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-MakePaymentByCash-UH1

    [Documentation]  Make payment by cash with invalid invoice id.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME195}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${note}=    FakerLibrary.word
    ${invoice}=    FakerLibrary.word
    ${resp}=  Make Payment By Cash For Invoice   ${invoice}  ${payment_modes[0]}  10  ${note}    paymentOndate=${DAY1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${RECORD_NOT_FOUND}" 



JD-TC-MakePaymentByCash-UH2

    [Documentation]  Make payment by cash without login
    ${note}=    FakerLibrary.word
    ${resp}=  Make Payment By Cash For Invoice   ${invoice_uid}  ${payment_modes[0]}  10  ${note}   paymentOndate=${DAY1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

JD-TC-MakePaymentByCash-UH3

    [Documentation]  Make payment by cash with another provider login

    ${resp}=   Encrypted Provider Login  ${PUSERNAME204}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    
    IF  ${resp.json()['enableJaldeeFinance']}==${bool[0]}
        ${resp1}=    Enable Disable Jaldee Finance   ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END


    ${note}=    FakerLibrary.word
    ${resp}=  Make Payment By Cash For Invoice   ${invoice_uid}  ${payment_modes[0]}  10  ${note}    paymentOndate=${DAY1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}" 

