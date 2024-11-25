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
${DisplayName1}   item1_DisplayName


*** Test Cases ***

JD-TC-Get Invoice With Filter -1

    [Documentation]  Get Invoice With Filter .

    ${resp}=  Encrypted Provider Login  ${PUSERNAME323}  ${PASSWORD}
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
    Set Suite Variable   ${name}

    ${resp}=  CreateVendorCategory  ${name}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${category_id}   ${resp.json()}

    ${resp}=  Get by encId  ${category_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

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



    ${address}=  FakerLibrary.city
    Set Suite Variable  ${address}



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
    ${invoiceDate}=   db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${invoiceDate}
    ${amount}=   Random Int  min=500  max=2000
    ${amount}=     roundoff    ${amount}   1
    Set Suite Variable   ${amount}
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
    ${netRate}=  Evaluate  ${promotionalPrice}*${quantity}
    ${netRate}=  Convert To Number  ${netRate}  4

    ${resp}=  Create Finance Status   ${New_status[0]}  ${categoryType[3]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${status_id1}   ${resp.json()}

    
    ${resp}=  Create Invoice   ${category_id2}   ${invoiceDate}      ${invoiceId}    ${providerConsumerIdList}   ${lid}   ${itemList}  invoiceStatus=${status_id1}     invoiceLabel=${invoiceLabel}   billedTo=${address}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${invoice_uid}   ${resp.json()['uidList'][0]}   


    ${resp1}=  Get Invoice With Filter  
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Should Be Equal As Strings  ${resp1.json()[0]['accountId']}  ${account_id1}
    Should Be Equal As Strings  ${resp1.json()[0]['invoiceCategoryId']}  ${category_id2}
    Should Be Equal As Strings  ${resp1.json()[0]['categoryName']}  ${name1}
    Should Be Equal As Strings  ${resp1.json()[0]['invoiceDate']}  ${invoiceDate}
    Should Be Equal As Strings  ${resp1.json()[0]['invoiceLabel']}  ${invoiceLabel}
    Should Be Equal As Strings  ${resp1.json()[0]['billedTo']}  ${address}


    ${resp1}=  Get Invoice With Filter   userId-eq=${pid}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Should Be Equal As Strings  ${resp1.json()[0]['accountId']}  ${account_id1}
    Should Be Equal As Strings  ${resp1.json()[0]['invoiceCategoryId']}  ${category_id2}
    Should Be Equal As Strings  ${resp1.json()[0]['categoryName']}  ${name1}
    Should Be Equal As Strings  ${resp1.json()[0]['invoiceDate']}  ${invoiceDate}
    Should Be Equal As Strings  ${resp1.json()[0]['invoiceLabel']}  ${invoiceLabel}
    Should Be Equal As Strings  ${resp1.json()[0]['billedTo']}  ${address}
    Should Be Equal As Strings  ${resp1.json()[0]['invoiceUid']}  ${invoice_uid}
    Should Be Equal As Strings  ${resp1.json()[0]['providerConsumerId']}  ${pcid18}
    Should Be Equal As Strings  ${resp1.json()[0]['itemList'][0]['itemId']}  ${itemId}
    Should Be Equal As Strings  ${resp1.json()[0]['itemList'][0]['quantity']}  ${quantity}
    Should Be Equal As Strings  ${resp1.json()[0]['itemList'][0]['price']}  ${promotionalPrice}
    Should Be Equal As Strings  ${resp1.json()[0]['itemList'][0]['netRate']}  ${netRate}



JD-TC-Get Invoice With Filter -2

    [Documentation]  Create multiple invoice using multiple provider consumers and GetInvoicewithFilter.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME323}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
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

        ${itemName}=    FakerLibrary.word
    Set Suite Variable  ${itemName}
    ${price}=   Random Int  min=10  max=15
    ${price}=  Convert To Number  ${price}  1

    ${quantity}=   Random Int  min=5  max=10
    ${quantity}=  Convert To Number  ${quantity}  1
    ${adhocItemList}=  Create Dictionary  itemName=${itemName}   quantity=${quantity}   price=${price}
    ${adhocItemList}=    Create List    ${adhocItemList} 

    
    ${resp}=  Create Invoice   ${category_id2}    ${invoiceDate}     ${invoiceId}    ${providerConsumerIdList}   ${lid}  adhocItemList=${adhocItemList}    invoiceLabel=${invoiceLabel}   billedTo=${address}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len1}=  Get Length  ${resp.json()['idList']}
    Set Suite Variable   ${invoice_uid1}   ${resp.json()['uidList'][0]}  
    Set Suite Variable  ${invoice_uid2}   ${resp.json()['uidList'][1]}  

    ${resp1}=  Get Invoice With Filter   
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Should Be Equal As Strings  ${resp1.json()[0]['accountId']}  ${account_id1}
    Should Be Equal As Strings  ${resp1.json()[0]['invoiceCategoryId']}  ${category_id2}
    Should Be Equal As Strings  ${resp1.json()[0]['categoryName']}  ${name1}
    Should Be Equal As Strings  ${resp1.json()[0]['invoiceDate']}  ${invoiceDate}
    Should Be Equal As Strings  ${resp1.json()[0]['invoiceLabel']}  ${invoiceLabel}
    Should Be Equal As Strings  ${resp1.json()[0]['billedTo']}  ${address}
    Should Be Equal As Strings  ${resp1.json()[0]['invoiceUid']}  ${invoice_uid1}
    Should Be Equal As Strings  ${resp1.json()[0]['providerConsumerId']}  ${pcid10}
    Should Be Equal As Strings  ${resp1.json()[1]['accountId']}  ${account_id1}
    Should Be Equal As Strings  ${resp1.json()[1]['invoiceCategoryId']}  ${category_id2}
    Should Be Equal As Strings  ${resp1.json()[1]['categoryName']}  ${name1}
    Should Be Equal As Strings  ${resp1.json()[1]['invoiceDate']}  ${invoiceDate}
    Should Be Equal As Strings  ${resp1.json()[1]['invoiceLabel']}  ${invoiceLabel}
    # Should Be Equal As Strings  ${resp1.json()[0]['billedTo']}  ${address}
    Should Be Equal As Strings  ${resp1.json()[1]['invoiceUid']}  ${invoice_uid1}
    Should Be Equal As Strings  ${resp1.json()[1]['providerConsumerId']}  ${pcid9}
    Should Be Equal As Strings  ${resp1.json()[2]['accountId']}  ${account_id1}
    Should Be Equal As Strings  ${resp1.json()[2]['invoiceCategoryId']}  ${category_id2}
    Should Be Equal As Strings  ${resp1.json()[2]['categoryName']}  ${name1}
    Should Be Equal As Strings  ${resp1.json()[2]['invoiceDate']}  ${invoiceDate}
    Should Be Equal As Strings  ${resp1.json()[2]['invoiceLabel']}  ${invoiceLabel}
    Should Be Equal As Strings  ${resp1.json()[2]['billedTo']}  ${address}
    Should Be Equal As Strings  ${resp1.json()[2]['invoiceUid']}  ${invoice_uid}
    Should Be Equal As Strings  ${resp1.json()[2]['providerConsumerId']}  ${pcid18}


JD-TC-Get Invoice With Filter -3

    [Documentation]   GetInvoiceCountwithFilter using invoiceCategoryId.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME323}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp1}=  Get Invoice With Filter   invoiceCategoryId-eq= ${category_id2}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
     Should Be Equal As Strings  ${resp1.json()[0]['accountId']}  ${account_id1}
    Should Be Equal As Strings  ${resp1.json()[0]['invoiceCategoryId']}  ${category_id2}
    Should Be Equal As Strings  ${resp1.json()[0]['categoryName']}  ${name1}
    Should Be Equal As Strings  ${resp1.json()[0]['invoiceDate']}  ${invoiceDate}
    Should Be Equal As Strings  ${resp1.json()[0]['invoiceLabel']}  ${invoiceLabel}
    # Should Be Equal As Strings  ${resp1.json()[0]['billedTo']}  ${address}
    Should Be Equal As Strings  ${resp1.json()[0]['invoiceUid']}  ${invoice_uid2}
    Should Be Equal As Strings  ${resp1.json()[0]['providerConsumerId']}  ${pcid9}
    Should Be Equal As Strings  ${resp1.json()[1]['accountId']}  ${account_id1}
    Should Be Equal As Strings  ${resp1.json()[1]['invoiceCategoryId']}  ${category_id2}
    Should Be Equal As Strings  ${resp1.json()[1]['categoryName']}  ${name1}
    Should Be Equal As Strings  ${resp1.json()[1]['invoiceDate']}  ${invoiceDate}
    Should Be Equal As Strings  ${resp1.json()[1]['invoiceLabel']}  ${invoiceLabel}
    Should Be Equal As Strings  ${resp1.json()[1]['billedTo']}  ${address}
    Should Be Equal As Strings  ${resp1.json()[1]['invoiceUid']}  ${invoice_uid1}
    Should Be Equal As Strings  ${resp1.json()[1]['providerConsumerId']}  ${pcid10}
    Should Be Equal As Strings  ${resp1.json()[2]['accountId']}  ${account_id1}
    Should Be Equal As Strings  ${resp1.json()[2]['invoiceCategoryId']}  ${category_id2}
    Should Be Equal As Strings  ${resp1.json()[2]['categoryName']}  ${name1}
    Should Be Equal As Strings  ${resp1.json()[2]['invoiceDate']}  ${invoiceDate}
    Should Be Equal As Strings  ${resp1.json()[2]['invoiceLabel']}  ${invoiceLabel}
    Should Be Equal As Strings  ${resp1.json()[2]['billedTo']}  ${address}
    Should Be Equal As Strings  ${resp1.json()[2]['invoiceUid']}  ${invoice_uid}
    Should Be Equal As Strings  ${resp1.json()[2]['providerConsumerId']}  ${pcid18}



JD-TC-Get Invoice With Filter -4

    [Documentation]   GetInvoiceCountwithFilter using categoryName.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME323}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp1}=  Get Invoice With Filter   categoryName-eq= ${name1}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
     Should Be Equal As Strings  ${resp1.json()[0]['accountId']}  ${account_id1}
    Should Be Equal As Strings  ${resp1.json()[0]['invoiceCategoryId']}  ${category_id2}
    Should Be Equal As Strings  ${resp1.json()[0]['categoryName']}  ${name1}
    Should Be Equal As Strings  ${resp1.json()[0]['invoiceDate']}  ${invoiceDate}
    Should Be Equal As Strings  ${resp1.json()[0]['invoiceLabel']}  ${invoiceLabel}
    # Should Be Equal As Strings  ${resp1.json()[0]['billedTo']}  ${address}
    Should Be Equal As Strings  ${resp1.json()[0]['invoiceUid']}  ${invoice_uid2}
    Should Be Equal As Strings  ${resp1.json()[0]['providerConsumerId']}  ${pcid9}
    Should Be Equal As Strings  ${resp1.json()[1]['accountId']}  ${account_id1}
    Should Be Equal As Strings  ${resp1.json()[1]['invoiceCategoryId']}  ${category_id2}
    Should Be Equal As Strings  ${resp1.json()[1]['categoryName']}  ${name1}
    Should Be Equal As Strings  ${resp1.json()[1]['invoiceDate']}  ${invoiceDate}
    Should Be Equal As Strings  ${resp1.json()[1]['invoiceLabel']}  ${invoiceLabel}
    Should Be Equal As Strings  ${resp1.json()[1]['billedTo']}  ${address}
    Should Be Equal As Strings  ${resp1.json()[1]['invoiceUid']}  ${invoice_uid1}
    # Should Be Equal As Strings  ${resp1.json()[1]['invoiceId']}  ${invoice_id}
    Should Be Equal As Strings  ${resp1.json()[1]['providerConsumerId']}  ${pcid10}
        Should Be Equal As Strings  ${resp1.json()[2]['accountId']}  ${account_id1}
    Should Be Equal As Strings  ${resp1.json()[2]['invoiceCategoryId']}  ${category_id2}
    Should Be Equal As Strings  ${resp1.json()[2]['categoryName']}  ${name1}
    Should Be Equal As Strings  ${resp1.json()[2]['invoiceDate']}  ${invoiceDate}
    Should Be Equal As Strings  ${resp1.json()[2]['invoiceLabel']}  ${invoiceLabel}
    Should Be Equal As Strings  ${resp1.json()[2]['billedTo']}  ${address}
    Should Be Equal As Strings  ${resp1.json()[2]['invoiceUid']}  ${invoice_uid}
    # Should Be Equal As Strings  ${resp1.json()[2]['invoiceId']}  ${invoice_id}
    Should Be Equal As Strings  ${resp1.json()[2]['providerConsumerId']}  ${pcid18}


JD-TC-Get Invoice With Filter -5

    [Documentation]   GetInvoiceCountwithFilter using invoiceDate.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME323}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp1}=  Get Invoice With Filter   invoiceDate-eq= ${invoiceDate}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
     Should Be Equal As Strings  ${resp1.json()[0]['accountId']}  ${account_id1}
    Should Be Equal As Strings  ${resp1.json()[0]['invoiceCategoryId']}  ${category_id2}
    Should Be Equal As Strings  ${resp1.json()[0]['categoryName']}  ${name1}
    Should Be Equal As Strings  ${resp1.json()[0]['invoiceDate']}  ${invoiceDate}
    Should Be Equal As Strings  ${resp1.json()[0]['invoiceLabel']}  ${invoiceLabel}
    # Should Be Equal As Strings  ${resp1.json()[0]['billedTo']}  ${address}
    Should Be Equal As Strings  ${resp1.json()[0]['invoiceUid']}  ${invoice_uid2}
    # Should Be Equal As Strings  ${resp1.json()[0]['invoiceId']}  ${invoice_id}
    Should Be Equal As Strings  ${resp1.json()[0]['providerConsumerId']}  ${pcid9}
    Should Be Equal As Strings  ${resp1.json()[1]['accountId']}  ${account_id1}
    Should Be Equal As Strings  ${resp1.json()[1]['invoiceCategoryId']}  ${category_id2}
    Should Be Equal As Strings  ${resp1.json()[1]['categoryName']}  ${name1}
    Should Be Equal As Strings  ${resp1.json()[1]['invoiceDate']}  ${invoiceDate}
    Should Be Equal As Strings  ${resp1.json()[1]['invoiceLabel']}  ${invoiceLabel}
    Should Be Equal As Strings  ${resp1.json()[1]['billedTo']}  ${address}
    Should Be Equal As Strings  ${resp1.json()[1]['invoiceUid']}  ${invoice_uid1}
    # Should Be Equal As Strings  ${resp1.json()[1]['invoiceId']}  ${invoice_id}
    Should Be Equal As Strings  ${resp1.json()[1]['providerConsumerId']}  ${pcid10}
        Should Be Equal As Strings  ${resp1.json()[2]['accountId']}  ${account_id1}
    Should Be Equal As Strings  ${resp1.json()[2]['invoiceCategoryId']}  ${category_id2}
    Should Be Equal As Strings  ${resp1.json()[2]['categoryName']}  ${name1}
    Should Be Equal As Strings  ${resp1.json()[2]['invoiceDate']}  ${invoiceDate}
    Should Be Equal As Strings  ${resp1.json()[2]['invoiceLabel']}  ${invoiceLabel}
    Should Be Equal As Strings  ${resp1.json()[2]['billedTo']}  ${address}
    Should Be Equal As Strings  ${resp1.json()[2]['invoiceUid']}  ${invoice_uid}
    # Should Be Equal As Strings  ${resp1.json()[2]['invoiceId']}  ${invoice_id}
    Should Be Equal As Strings  ${resp1.json()[2]['providerConsumerId']}  ${pcid18}


JD-TC-Get Invoice With Filter -6

    [Documentation]   GetInvoiceCountwithFilter using invoiceLabel.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME323}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp1}=  Get Invoice With Filter   invoiceLabel-eq= ${invoiceLabel}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
     Should Be Equal As Strings  ${resp1.json()[0]['accountId']}  ${account_id1}
    Should Be Equal As Strings  ${resp1.json()[0]['invoiceCategoryId']}  ${category_id2}
    Should Be Equal As Strings  ${resp1.json()[0]['categoryName']}  ${name1}
    Should Be Equal As Strings  ${resp1.json()[0]['invoiceDate']}  ${invoiceDate}
    Should Be Equal As Strings  ${resp1.json()[0]['invoiceLabel']}  ${invoiceLabel}
    # Should Be Equal As Strings  ${resp1.json()[0]['billedTo']}  ${address}
#    Should Be Equal As Strings  ${resp1.json()[0]['vendorUid']}  ${vendor_uid1}
    Should Be Equal As Strings  ${resp1.json()[0]['invoiceUid']}  ${invoice_uid2}
    # Should Be Equal As Strings  ${resp1.json()[0]['invoiceId']}  ${invoice_id}
    Should Be Equal As Strings  ${resp1.json()[0]['providerConsumerId']}  ${pcid9}
    Should Be Equal As Strings  ${resp1.json()[1]['accountId']}  ${account_id1}
    Should Be Equal As Strings  ${resp1.json()[1]['invoiceCategoryId']}  ${category_id2}
    Should Be Equal As Strings  ${resp1.json()[1]['categoryName']}  ${name1}
    Should Be Equal As Strings  ${resp1.json()[1]['invoiceDate']}  ${invoiceDate}
    Should Be Equal As Strings  ${resp1.json()[1]['invoiceLabel']}  ${invoiceLabel}
    Should Be Equal As Strings  ${resp1.json()[1]['billedTo']}  ${address}
#    #        Should Be Equal As Strings  ${resp1.json()[1]['vendorUid']}  ${vendor_uid1}
    Should Be Equal As Strings  ${resp1.json()[1]['invoiceUid']}  ${invoice_uid1}
    # Should Be Equal As Strings  ${resp1.json()[1]['invoiceId']}  ${invoice_id}
    Should Be Equal As Strings  ${resp1.json()[1]['providerConsumerId']}  ${pcid10}
        Should Be Equal As Strings  ${resp1.json()[2]['accountId']}  ${account_id1}
    Should Be Equal As Strings  ${resp1.json()[2]['invoiceCategoryId']}  ${category_id2}
    Should Be Equal As Strings  ${resp1.json()[2]['categoryName']}  ${name1}
    Should Be Equal As Strings  ${resp1.json()[2]['invoiceDate']}  ${invoiceDate}
    Should Be Equal As Strings  ${resp1.json()[2]['invoiceLabel']}  ${invoiceLabel}
    Should Be Equal As Strings  ${resp1.json()[2]['billedTo']}  ${address}
    Should Be Equal As Strings  ${resp1.json()[2]['invoiceUid']}  ${invoice_uid}
    # Should Be Equal As Strings  ${resp1.json()[2]['invoiceId']}  ${invoice_id}
    Should Be Equal As Strings  ${resp1.json()[2]['providerConsumerId']}  ${pcid18}


JD-TC-Get Invoice With Filter -7

    [Documentation]   GetInvoiceCountwithFilter using billedTo.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME323}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp1}=  Get Invoice With Filter   billedTo-eq= ${address}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
     Should Be Equal As Strings  ${resp1.json()[0]['accountId']}  ${account_id1}
    Should Be Equal As Strings  ${resp1.json()[0]['invoiceCategoryId']}  ${category_id2}
    Should Be Equal As Strings  ${resp1.json()[0]['categoryName']}  ${name1}
    Should Be Equal As Strings  ${resp1.json()[0]['invoiceDate']}  ${invoiceDate}
    Should Be Equal As Strings  ${resp1.json()[0]['invoiceLabel']}  ${invoiceLabel}
    # Should Be Equal As Strings  ${resp1.json()[0]['billedTo']}  ${address}
#    Should Be Equal As Strings  ${resp1.json()[0]['vendorUid']}  ${vendor_uid1}
    Should Be Equal As Strings  ${resp1.json()[0]['invoiceUid']}  ${invoice_uid2}
    # Should Be Equal As Strings  ${resp1.json()[0]['invoiceId']}  ${invoice_id}
    Should Be Equal As Strings  ${resp1.json()[0]['providerConsumerId']}  ${pcid9}
    Should Be Equal As Strings  ${resp1.json()[1]['accountId']}  ${account_id1}
    Should Be Equal As Strings  ${resp1.json()[1]['invoiceCategoryId']}  ${category_id2}
    Should Be Equal As Strings  ${resp1.json()[1]['categoryName']}  ${name1}
    Should Be Equal As Strings  ${resp1.json()[1]['invoiceDate']}  ${invoiceDate}
    Should Be Equal As Strings  ${resp1.json()[1]['invoiceLabel']}  ${invoiceLabel}
    Should Be Equal As Strings  ${resp1.json()[1]['billedTo']}  ${address}
#    #        Should Be Equal As Strings  ${resp1.json()[1]['vendorUid']}  ${vendor_uid1}
    Should Be Equal As Strings  ${resp1.json()[1]['invoiceUid']}  ${invoice_uid1}
    # Should Be Equal As Strings  ${resp1.json()[1]['invoiceId']}  ${invoice_id}
    Should Be Equal As Strings  ${resp1.json()[1]['providerConsumerId']}  ${pcid10}
        Should Be Equal As Strings  ${resp1.json()[2]['accountId']}  ${account_id1}
    Should Be Equal As Strings  ${resp1.json()[2]['invoiceCategoryId']}  ${category_id2}
    Should Be Equal As Strings  ${resp1.json()[2]['categoryName']}  ${name1}
    Should Be Equal As Strings  ${resp1.json()[2]['invoiceDate']}  ${invoiceDate}
    Should Be Equal As Strings  ${resp1.json()[2]['invoiceLabel']}  ${invoiceLabel}
    Should Be Equal As Strings  ${resp1.json()[2]['billedTo']}  ${address}
    # Should Be Equal As Strings  ${resp1.json()[2]['vendorUid']}  ${vendor_uid1}
    Should Be Equal As Strings  ${resp1.json()[2]['invoiceUid']}  ${invoice_uid}
    # Should Be Equal As Strings  ${resp1.json()[2]['invoiceId']}  ${invoice_id}
    Should Be Equal As Strings  ${resp1.json()[2]['providerConsumerId']}  ${pcid18}



JD-TC-Get Invoice With Filter -8

    [Documentation]   GetInvoiceCountwithFilter using invoiceUid.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME323}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp1}=  Get Invoice With Filter   invoiceUid-eq= ${invoice_uid1}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
 
    Should Be Equal As Strings  ${resp1.json()[0]['accountId']}  ${account_id1}
    Should Be Equal As Strings  ${resp1.json()[0]['invoiceCategoryId']}  ${category_id2}
    Should Be Equal As Strings  ${resp1.json()[0]['categoryName']}  ${name1}
    Should Be Equal As Strings  ${resp1.json()[0]['invoiceDate']}  ${invoiceDate}
    Should Be Equal As Strings  ${resp1.json()[0]['invoiceLabel']}  ${invoiceLabel}
    Should Be Equal As Strings  ${resp1.json()[0]['billedTo']}  ${address}
#    Should Be Equal As Strings  ${resp1.json()[0]['vendorUid']}  ${vendor_uid1}
    Should Be Equal As Strings  ${resp1.json()[0]['invoiceUid']}  ${invoice_uid1}
    # Should Be Equal As Strings  ${resp1.json()[1]['invoiceId']}  ${invoice_id}
    Should Be Equal As Strings  ${resp1.json()[0]['providerConsumerId']}  ${pcid10}



JD-TC-Get Invoice With Filter -9

    [Documentation]   GetInvoiceCountwithFilter using invoiceStatus.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME323}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp1}=  Get Invoice With Filter   invoiceStatus-eq= ${status_id1}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Should Be Equal As Strings  ${resp1.json()[0]['accountId']}  ${account_id1}
    Should Be Equal As Strings  ${resp1.json()[0]['invoiceCategoryId']}  ${category_id2}
    Should Be Equal As Strings  ${resp1.json()[0]['categoryName']}  ${name1}
    Should Be Equal As Strings  ${resp1.json()[0]['invoiceDate']}  ${invoiceDate}
    Should Be Equal As Strings  ${resp1.json()[0]['invoiceLabel']}  ${invoiceLabel}
    Should Be Equal As Strings  ${resp1.json()[0]['billedTo']}  ${address}
#    Should Be Equal As Strings  ${resp1.json()[0]['vendorUid']}  ${vendor_uid1}
    Should Be Equal As Strings  ${resp1.json()[0]['invoiceUid']}  ${invoice_uid}
    # Should Be Equal As Strings  ${resp1.json()[0]['invoiceId']}  ${invoice_id}
    Should Be Equal As Strings  ${resp1.json()[0]['providerConsumerId']}  ${pcid18}

JD-TC-GetInvoiceCountwithFilter-UH1

    [Documentation]   GetInvoiceCountwithFilter without login.

     ${resp}=  Get Invoice With Filter   invoiceStatus-eq= ${status_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}

    








