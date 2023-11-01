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


JD-TC-GetInvoiceCountwithFilter-1

    [Documentation]  Create a invoice with valid details.

    ${resp}=  Provider Login  ${PUSERNAME43}  ${PASSWORD}
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

    ${invoiceLabel}=   FakerLibrary.word
    Set Suite Variable  ${invoiceLabel}
    ${invoiceDate}=   db.get_date
    Set Suite Variable  ${invoiceDate}
    ${amount}=   Random Int  min=500  max=2000
    ${amount}=     roundval    ${amount}   1
    ${invoiceId}=   FakerLibrary.word

    ${item}=   FakerLibrary.word
    ${quantity}=   Random Int  min=5  max=10
    ${rate}=   Random Int  min=50  max=1000


    ${itemList}=  Create Dictionary  item=${item}   quantity=${quantity}  rate=${rate}    amount=${amount}
    # ${itemList}=    Create List    ${itemList}

    ${resp}=  Create Finance Status   ${New_status[0]}  ${categoryType[3]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${status_id1}   ${resp.json()}

    
    ${resp}=  Create Invoice   ${category_id2}  ${amount}  ${invoiceDate}   ${invoiceLabel}   ${address}   ${vendor_uid1}   ${invoiceId}    ${providerConsumerIdList}    ${itemList}  invoiceStatus=${status_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()['idList']}
    Set Suite Variable   ${len}
    Set Suite Variable   ${invoice_id}   ${resp.json()['idList'][0]}
    Set Suite Variable   ${invoice_uid}   ${resp.json()['uidList'][0]}   

    ${resp1}=  Get Invoice Count With Filter  
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Should Be Equal As Strings  ${resp1.json()}   ${len}
    # Should Be Equal As Strings  ${resp1.json()[0]['invoiceCategoryId']}  ${category_id2}
    # Should Be Equal As Strings  ${resp1.json()[0]['categoryName']}  ${name1}
    # Should Be Equal As Strings  ${resp1.json()[0]['invoiceDate']}  ${invoiceDate}
    # Should Be Equal As Strings  ${resp1.json()[0]['invoiceLabel']}  ${invoiceLabel}
    # Should Be Equal As Strings  ${resp1.json()[0]['billedTo']}  ${address}
    # Should Be Equal As Strings  ${resp1.json()[0]['amount']}  ${amount}

    ${resp1}=  Get Invoice Count With Filter   userId-eq=${pid}   amount-eq= ${amount}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Should Be Equal As Strings  ${resp1.json()}   ${len}

JD-TC-GetInvoiceCountwithFilter-2

    [Documentation]  Create multiple invoice using multiple provider consumers and GetInvoiceCountwithFilter.

    ${resp}=  Provider Login  ${PUSERNAME43}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${amount}=   Random Int  min=500  max=2000
    ${amount}=     roundval    ${amount}   1
    ${invoiceId}=   FakerLibrary.word

    ${resp1}=  AddCustomer  ${CUSERNAME10}
    Log  ${resp1.json()}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Set Suite Variable   ${pcid10}   ${resp1.json()}

    ${resp1}=  AddCustomer  ${CUSERNAME9}
    Log  ${resp1.json()}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Set Suite Variable   ${pcid9}   ${resp1.json()}

    ${providerConsumerIdList}=  Create List  ${pcid10}  ${pcid9}
    Set Test Variable  ${providerConsumerIdList}   

    
    ${resp}=  Create Invoice   ${category_id2}  ${amount}  ${invoiceDate}   ${invoiceLabel}   ${address}   ${vendor_uid1}   ${invoiceId}    ${providerConsumerIdList}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len1}=  Get Length  ${resp.json()['idList']}
    Set Suite Variable   ${invoice_uid1}   ${resp.json()['uidList'][0]}  
    Set Suite Variable  ${invoice_uid2}   ${resp.json()['uidList'][1]}  

    ${resp1}=  Get Invoice Count With Filter   userId-eq=${pid}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    ${len1}=  Get Length  ${resp.json()}
    Set Suite Variable   ${len1}
    # Should Be Equal As Strings  ${resp1.json()[0]['invoiceCategoryId']}  ${category_id2}
    # Should Be Equal As Strings  ${resp1.json()[0]['categoryName']}  ${name1}
    # Should Be Equal As Strings  ${resp1.json()[0]['invoiceDate']}  ${invoiceDate}
    # Should Be Equal As Strings  ${resp1.json()[0]['invoiceLabel']}  ${invoiceLabel}
    # Should Be Equal As Strings  ${resp1.json()[0]['billedTo']}  ${address}
    # Should Be Equal As Strings  ${resp1.json()[0]['amount']}  ${amount}

    ${resp1}=  Get Invoice Count With Filter   vendorId-eq= ${vendor_uid1}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Should Be Equal As Strings  ${resp1.json()}   ${len1}

JD-TC-GetInvoiceCountwithFilter-3

    [Documentation]   GetInvoiceCountwithFilter using invoiceCategoryId.

    ${resp}=  Provider Login  ${PUSERNAME43}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp1}=  Get Invoice Count With Filter  
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Should Be Equal As Strings  ${resp1.json()}   ${len1}
    # Should Be Equal As Strings  ${resp1.json()[0]['invoiceCategoryId']}  ${category_id2}
    # Should Be Equal As Strings  ${resp1.json()[0]['categoryName']}  ${name1}
    # Should Be Equal As Strings  ${resp1.json()[0]['invoiceDate']}  ${invoiceDate}
    # Should Be Equal As Strings  ${resp1.json()[0]['invoiceLabel']}  ${invoiceLabel}
    # Should Be Equal As Strings  ${resp1.json()[0]['billedTo']}  ${address}
    # Should Be Equal As Strings  ${resp1.json()[0]['amount']}  ${amount}

    ${resp1}=  Get Invoice Count With Filter   invoiceCategoryId-eq= ${category_id2}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Should Be Equal As Strings  ${resp1.json()}   ${len1}


JD-TC-GetInvoiceCountwithFilter-4

    [Documentation]   GetInvoiceCountwithFilter using categoryName.

    ${resp}=  Provider Login  ${PUSERNAME43}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp1}=  Get Invoice Count With Filter  
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Should Be Equal As Strings  ${resp1.json()}   ${len1}
    # Should Be Equal As Strings  ${resp1.json()[0]['invoiceCategoryId']}  ${category_id2}
    # Should Be Equal As Strings  ${resp1.json()[0]['categoryName']}  ${name1}
    # Should Be Equal As Strings  ${resp1.json()[0]['invoiceDate']}  ${invoiceDate}
    # Should Be Equal As Strings  ${resp1.json()[0]['invoiceLabel']}  ${invoiceLabel}
    # Should Be Equal As Strings  ${resp1.json()[0]['billedTo']}  ${address}
    # Should Be Equal As Strings  ${resp1.json()[0]['amount']}  ${amount}

    ${resp1}=  Get Invoice Count With Filter   categoryName-eq= ${name1}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Should Be Equal As Strings  ${resp1.json()}   ${len1}

JD-TC-GetInvoiceCountwithFilter-5

    [Documentation]   GetInvoiceCountwithFilter using invoiceDate.

    ${resp}=  Provider Login  ${PUSERNAME43}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp1}=  Get Invoice Count With Filter  
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Should Be Equal As Strings  ${resp1.json()}   ${len1}
    # Should Be Equal As Strings  ${resp1.json()[0]['invoiceCategoryId']}  ${category_id2}
    # Should Be Equal As Strings  ${resp1.json()[0]['categoryName']}  ${name1}
    # Should Be Equal As Strings  ${resp1.json()[0]['invoiceDate']}  ${invoiceDate}
    # Should Be Equal As Strings  ${resp1.json()[0]['invoiceLabel']}  ${invoiceLabel}
    # Should Be Equal As Strings  ${resp1.json()[0]['billedTo']}  ${address}
    # Should Be Equal As Strings  ${resp1.json()[0]['amount']}  ${amount}

    ${resp1}=  Get Invoice Count With Filter   invoiceDate-eq= ${invoiceDate}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Should Be Equal As Strings  ${resp1.json()}   ${len1}

JD-TC-GetInvoiceCountwithFilter-6

    [Documentation]   GetInvoiceCountwithFilter using invoiceLabel.

    ${resp}=  Provider Login  ${PUSERNAME43}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp1}=  Get Invoice Count With Filter  
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Should Be Equal As Strings  ${resp1.json()}   ${len1}
    # Should Be Equal As Strings  ${resp1.json()[0]['invoiceCategoryId']}  ${category_id2}
    # Should Be Equal As Strings  ${resp1.json()[0]['categoryName']}  ${name1}
    # Should Be Equal As Strings  ${resp1.json()[0]['invoiceDate']}  ${invoiceDate}
    # Should Be Equal As Strings  ${resp1.json()[0]['invoiceLabel']}  ${invoiceLabel}
    # Should Be Equal As Strings  ${resp1.json()[0]['billedTo']}  ${address}
    # Should Be Equal As Strings  ${resp1.json()[0]['amount']}  ${amount}

    ${resp1}=  Get Invoice Count With Filter   invoiceLabel-eq= ${invoiceLabel}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Should Be Equal As Strings  ${resp1.json()}   ${len1}

JD-TC-GetInvoiceCountwithFilter-7

    [Documentation]   GetInvoiceCountwithFilter using billedTo.

    ${resp}=  Provider Login  ${PUSERNAME43}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp1}=  Get Invoice Count With Filter  
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Should Be Equal As Strings  ${resp1.json()}   ${len1}
    # Should Be Equal As Strings  ${resp1.json()[0]['invoiceCategoryId']}  ${category_id2}
    # Should Be Equal As Strings  ${resp1.json()[0]['categoryName']}  ${name1}
    # Should Be Equal As Strings  ${resp1.json()[0]['invoiceDate']}  ${invoiceDate}
    # Should Be Equal As Strings  ${resp1.json()[0]['invoiceLabel']}  ${invoiceLabel}
    # Should Be Equal As Strings  ${resp1.json()[0]['billedTo']}  ${address}
    # Should Be Equal As Strings  ${resp1.json()[0]['amount']}  ${amount}

    ${resp1}=  Get Invoice Count With Filter   billedTo-eq= ${address}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Should Be Equal As Strings  ${resp1.json()}   ${len1}


JD-TC-GetInvoiceCountwithFilter-8

    [Documentation]   GetInvoiceCountwithFilter using invoiceUid.

    ${resp}=  Provider Login  ${PUSERNAME43}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp1}=  Get Invoice Count With Filter   invoiceUid-eq= ${invoice_uid1}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Should Be Equal As Strings  ${resp1.json()}   ${len}

JD-TC-GetInvoiceCountwithFilter-9

    [Documentation]   GetInvoiceCountwithFilter using invoiceStatus.

    ${resp}=  Provider Login  ${PUSERNAME43}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp1}=  Get Invoice Count With Filter   invoiceStatus-eq= ${status_id1}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Should Be Equal As Strings  ${resp1.json()}   ${len}

    






