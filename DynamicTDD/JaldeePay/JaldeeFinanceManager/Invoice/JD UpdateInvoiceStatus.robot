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

@{service_names}


@{status}    New     Pending    Assigned     Approved    Rejected



*** Test Cases ***

JD-TC-UpdateInvoiceStatus-1

    [Documentation]  Create a invoice  and update it status.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME46}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
 

    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}

    Set Suite Variable  ${pid}  ${decrypted_data['id']}
    Set Suite Variable    ${userName}    ${decrypted_data['userName']}
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

    ${name1}=   FakerLibrary.word
    ${resp}=  Create Category   ${name1}  ${categoryType[3]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${category_id2}   ${resp.json()}

    ${resp}=  Get Category By Id   ${category_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200




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
    
    ${resp}=  Create Invoice   ${category_id2}    ${invoiceDate}     ${invoiceId}    ${providerConsumerIdList}   ${lid}    adhocItemList=${adhocItemList}    billStatus=${billStatus[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${invoice_uid}   ${resp.json()['uidList'][0]}  

    ${resp1}=  Get Invoice By Id  ${invoice_uid}
    Log  ${resp1.content}

    ${resp}=  Create Finance Status   ${New_status[0]}  ${categoryType[3]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${status_id3}   ${resp.json()}

    ${resp}=  Update Invoice Status   ${invoice_uid}    ${status_id3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp1}=  Get Invoice By Id  ${invoice_uid}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Should Be Equal As Strings  ${resp1.json()['accountId']}  ${account_id1}
    Should Be Equal As Strings  ${resp1.json()['invoiceCategoryId']}  ${category_id2}
    Should Be Equal As Strings  ${resp1.json()['categoryName']}  ${name1}
    Should Be Equal As Strings  ${resp1.json()['invoiceDate']}  ${invoiceDate}
    Should Be Equal As Strings  ${resp1.json()['invoiceStatusName']}  ${New_status[0]}




JD-TC-UpdateInvoiceStatus-UH1

    [Documentation]  UpdateInvoiceStatus with invalid status id.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME46}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${fakeid}=    Random Int  min=1000   max=9999	

    ${resp}=  Update Invoice Status   ${invoice_uid}    ${fakeid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${INVALID_FM_STATUS_ID}

JD-TC-UpdateInvoiceStatus-UH2

    [Documentation]  UpdateInvoiceStatus with invalid invoice id.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME46}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${fakeid}=    Random Int  min=1000   max=9999	

    ${resp}=  Update Invoice Status   ${fakeid}    ${status_id3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${INVALID_FM_INVOICE_ID}

JD-TC-UpdateInvoiceStatus-UH3

    [Documentation]  UpdateInvoiceStatus with with already updated one..

    ${resp}=  Encrypted Provider Login  ${PUSERNAME46}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

   ${ALREADY_IN_GIVEN_STATUS}=  format String   ${ALREADY_IN_GIVEN_STATUS}   ${New_status[0]}

    ${resp}=  Update Invoice Status   ${invoice_uid}    ${status_id3} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${ALREADY_IN_GIVEN_STATUS}




JD-TC-UpdateInvoiceStatus-UH4

    [Documentation]  create invoice with bill status as draft then try to update the invoice status.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME46}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200



    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${invoiceLabel}=   FakerLibrary.word
    ${invoiceDate}=   db.get_date_by_timezone  ${tz}
    ${invoiceId}=   FakerLibrary.word

        ${itemName}=    FakerLibrary.word
    Set Test Variable  ${itemName}
    ${price}=   Random Int  min=10  max=15
    ${price}=  Convert To Number  ${price}  1

    ${quantity}=   Random Int  min=5  max=10
    ${quantity}=  Convert To Number  ${quantity}  1
    ${adhocItemList}=  Create Dictionary  itemName=${itemName}   quantity=${quantity}   price=${price}
    ${adhocItemList}=    Create List    ${adhocItemList}
    
    ${resp}=  Create Invoice   ${category_id2}    ${invoiceDate}     ${invoiceId}    ${providerConsumerIdList}   ${lid}  adhocItemList=${adhocItemList}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${invoice_uid3}   ${resp.json()['uidList'][0]}  

    ${resp1}=  Get Invoice By Id  ${invoice_uid3}
    Log  ${resp1.content}

    ${resp}=  Create Finance Status   ${New_status[1]}  ${categoryType[3]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set suite Variable   ${status_id4}   ${resp.json()}

    ${resp}=  Update Invoice Status   ${invoice_uid3}    ${status_id4}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${Draft_status}

    ${resp1}=  Get Invoice By Id  ${invoice_uid3}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Should Be Equal As Strings  ${resp1.json()['accountId']}  ${account_id1}
    Should Be Equal As Strings  ${resp1.json()['invoiceDate']}  ${invoiceDate}
    Should Be Equal As Strings  ${resp1.json()['invoiceStatusName']}  ${billStatus[0]}

JD-TC-UpdateInvoiceStatus-UH5

    [Documentation]  update bill status as settled then try to update the invoice status.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME46}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${billStatusNote}=   FakerLibrary.word

    ${resp}=  Update bill status   ${invoice_uid3}    ${billStatus[0]}    ${billStatusNote}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Update bill status   ${invoice_uid3}    ${billStatus[1]}      ${billStatusNote}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${INVOICE_STATUS}=  format String   ${INVOICE_STATUS}   ${billStatus[1]}

    ${resp}=  Update Invoice Status   ${invoice_uid3}    ${status_id4}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${INVOICE_STATUS}
