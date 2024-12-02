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
${order}    0
${service_duration}     30
@{service_names}
${DisplayName1}   item1_DisplayName

*** Test Cases ***


JD-TC-Invoice pay via link-1

    [Documentation]  Create a invoice with valid details and pay amount via link.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME44}  ${PASSWORD}
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

    ${resp}=  Get Bill Settings 
    Log   ${resp.content}
    ${resp}=  Enable Disable bill  ${bool[1]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get payment profiles  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${Profileid}  ${resp.json()[0]['profileId']}


    # ${resp}=  Create Sample Location  
    # Set Suite Variable    ${lid}    ${resp}  


    ${resp}=   Get Locations 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable    ${lid}    ${resp.json()[0]['id']}  

    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    ${resp}=   Get next invoice Id   ${lid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${invoiceId}   ${resp.json()}

    ${name}=   FakerLibrary.word



    # ${name}=   FakerLibrary.word
    # Set Suite Variable   ${name}
    # ${resp}=  Create Category   ${name}  ${categoryType[0]} 
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${category_id}   ${resp.json()}
    
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


    ${name}     FakerLibrary.word
    Set Test Variable  ${email2}   ${name}.${test_mail}

    ${resp1}=  AddCustomer  ${CUSERNAME15}  
    Log  ${resp1.json()}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Set Suite Variable   ${pcid18}   ${resp1.json()}

    ${resp}=  Update Customer Details  ${pcid18}  email=${email2}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME15}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${providerConsumerIdList}=  Create List  ${pcid18}
    Set Suite Variable  ${providerConsumerIdList}   


    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${invoiceLabel}=   FakerLibrary.word
    ${invoiceDate}=   db.get_date_by_timezone  ${tz}
    # ${invoiceDate}=   Get Current Date    result_format=%Y/%m/%d


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

    ${resp}=  Create Finance Status   ${New_status[2]}  ${categoryType[3]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${status_id1}   ${resp.json()}

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    Set Suite Variable  ${SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${serviceprice}=   Random Int  min=10  max=15
    ${serviceprice}=  Convert To Number  ${serviceprice}  1
    ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${service_duration}     ${bool[1]}    ${servicecharge}  ${bool[0]}     minPrePaymentAmount=${min_pre}
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



    ${resp}=  Create Invoice   ${category_id2}    ${invoiceDate}      ${invoiceId}    ${providerConsumerIdList}  ${lid}    ${itemList}  invoiceStatus=${status_id1}    serviceList=${serviceList}   adhocItemList=${adhocItemList}    billStatus=${billStatus[0]}   
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
    # # Should Be Equal As Strings  ${resp1.json()['invoiceLabel']}  ${invoiceLabel}
    # # Should Be Equal As Strings  ${resp1.json()['billedTo']}  ${address}
    # Should Be Equal As Strings  ${resp1.json()['serviceList'][0]['serviceId']}  ${sid1}
    # Should Be Equal As Strings  ${resp1.json()['serviceList'][0]['quantity']}  ${quantity}
    # Should Be Equal As Strings  ${resp1.json()['adhocItemList'][0]['itemName']}  ${itemName}
    # Should Be Equal As Strings  ${resp1.json()['adhocItemList'][0]['quantity']}  ${quantity}
    # Should Be Equal As Strings  ${resp1.json()['adhocItemList'][0]['price']}  ${price}
    Set Suite Variable  ${amount}  ${resp1.json()['amountDue']}     

    ${resp}=  Share invoice as pdf   ${invoice_uid}   ${boolean[1]}    ${email2}   ${html}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Service payment modes    ${pid}    ${sid1}    ${purpose[6]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[0]['isJaldeeBank']}    ${bool[1]}
    Set Suite Variable    ${proid}  ${resp.json()[0]['profileId']}

    ${fName}=  FakerLibrary.name
    Set Suite Variable    ${fName}
    ${lName}=  FakerLibrary.last_name
    Set Suite Variable    ${lName}
    # ${primaryMobileNo1}    Generate random string    10    55574711478
    # ${primaryMobileNo1}    Convert To Integer  ${primaryMobileNo1}
    # Set Suite Variable    ${primaryMobileNo1}
    Set Suite Variable  ${email1}  ${lName}${CUSERNAME15}.${test_mail}

    ${resp}=    Send Otp For Login    ${CUSERNAME15}    ${account_id1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${CUSERNAME15}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token1}  ${resp.json()['token']}

    ${resp}=    Consumer Logout 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    # ${resp}=    ProviderConsumer SignUp    ${fName}  ${lName}  ${email1}    ${CUSERNAME15}     ${account_id1}
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}   200    
   
    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME15}    ${account_id1}  ${token1} 
    Log   ${resp.content}
    Should Be Equal As Strings              ${resp.status_code}   200
    Set Suite Variable    ${cid1}            ${resp.json()['providerConsumer']}
    Set Suite Variable    ${jconid1}         ${resp.json()['id']}

    ${source}=   FakerLibrary.word

    ${resp1}=  Invoice pay via link  ${invoice_uid}  ${amount}   ${purpose[6]}    ${source}  ${pid}   ${finance_payment_modes[8]}  ${bool[0]}   ${sid1}   ${cid1}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200


JD-TC-Invoice pay via link-2

    [Documentation]  Invoice pay via link-using upi payment mode.

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME15}    ${account_id1}  ${token1} 
    Log   ${resp.content}
    Should Be Equal As Strings              ${resp.status_code}   200

    ${source}=   FakerLibrary.word

    ${resp1}=  Invoice pay via link  ${invoice_uid}  ${amount}   ${purpose[6]}    ${source}  ${pid}   ${finance_payment_modes[6]}  ${bool[0]}   ${sid1}   ${pcid18}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200

JD-TC-Invoice pay via link-3

    [Documentation]  Invoice pay via link-using cc payment mode.

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME15}    ${account_id1}  ${token1} 
    Log   ${resp.content}
    Should Be Equal As Strings              ${resp.status_code}   200

    ${source}=   FakerLibrary.word

    ${resp1}=  Invoice pay via link  ${invoice_uid}  ${amount}   ${purpose[6]}    ${source}  ${pid}   ${finance_payment_modes[1]}  ${bool[0]}   ${sid1}   ${pcid18}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200

JD-TC-Invoice pay via link-4

    [Documentation]  Invoice pay via link-using DC payment mode.

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME15}    ${account_id1}  ${token1} 
    Log   ${resp.content}
    Should Be Equal As Strings              ${resp.status_code}   200

    ${source}=   FakerLibrary.word

    ${resp1}=  Invoice pay via link  ${invoice_uid}  ${amount}   ${purpose[6]}    ${source}  ${pid}   ${finance_payment_modes[12]}  ${bool[0]}   ${sid1}   ${pcid18}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200

JD-TC-Invoice pay via link-5

    [Documentation]  Invoice pay via link-using WALLET payment mode.

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME15}    ${account_id1}  ${token1} 
    Log   ${resp.content}
    Should Be Equal As Strings              ${resp.status_code}   200

    ${source}=   FakerLibrary.word

    ${resp1}=  Invoice pay via link  ${invoice_uid}  ${amount}   ${purpose[6]}    ${source}  ${pid}   ${finance_payment_modes[10]}  ${bool[0]}   ${sid1}   ${pcid18}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200

JD-TC-Invoice pay via link-6

    [Documentation]  Invoice pay via link-using PAYLATER payment mode.

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME15}    ${account_id1}  ${token1} 
    Log   ${resp.content}
    Should Be Equal As Strings              ${resp.status_code}   200

    ${source}=   FakerLibrary.word

    ${resp1}=  Invoice pay via link  ${invoice_uid}  ${amount}   ${purpose[6]}    ${source}  ${pid}   ${finance_payment_modes[4]}  ${bool[0]}   ${sid1}   ${pcid18}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200



JD-TC-Invoice pay via link-UH1

    [Documentation]  Invoice pay via link-with invalid mercahnt id.

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME15}    ${account_id1}  ${token1} 
    Log   ${resp.content}
    Should Be Equal As Strings              ${resp.status_code}   200

    ${source}=   FakerLibrary.word

    ${resp1}=  Invoice pay via link  ${invoice_uid}  ${amount}   ${purpose[6]}    ${source}  ${pid}   ${finance_payment_modes[5]}  ${bool[0]}   ${sid1}   ${pcid18}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  422
    Should Be Equal As Strings  ${resp1.json()}   ${INVALID_MERCHANT_ID}

JD-TC-Invoice pay via link-UH2

    [Documentation]  Invoice pay via link-using another provider login.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME45}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${source}=   FakerLibrary.word
    ${INVALID_Y_ID}=   Replace String  ${INVALID_Y_ID}  {}   invoice
    ${resp1}=  Invoice pay via link  ${invoice_uid}  ${amount}   ${purpose[6]}    ${source}  ${pid}   ${finance_payment_modes[5]}  ${bool[0]}   ${sid1}   ${pcid18}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  422
    Should Be Equal As Strings  ${resp1.json()}   ${INVALID_Y_ID}

JD-TC-Invoice pay via link-UH3

    [Documentation]  Invoice pay via link-without login.

    ${source}=   FakerLibrary.word
    ${INVALID_Y_ID}=   Replace String  ${INVALID_Y_ID}  {}   invoice
    ${resp1}=  Invoice pay via link  ${invoice_uid}  ${amount}   ${purpose[6]}    ${source}  ${pid}   ${finance_payment_modes[5]}  ${bool[0]}   ${sid1}   ${pcid18}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  422
    Should Be Equal As Strings  "${resp1.json()}"     "${INVALID_Y_ID}"

JD-TC-Invoice pay via link-UH4

    [Documentation]  Invoice pay via link-with amount is zero.

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME15}    ${account_id1}  ${token1} 
    Log   ${resp.content}
    Should Be Equal As Strings              ${resp.status_code}   200

    ${source}=   FakerLibrary.word

    ${resp1}=  Invoice pay via link  ${invoice_uid}  ${order}   ${purpose[6]}    ${source}  ${pid}   ${finance_payment_modes[1]}  ${bool[0]}   ${sid1}   ${pcid18}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  422
    Should Be Equal As Strings  "${resp1.json()}"     "${INVALID_AMOUNT}"

JD-TC-Invoice pay via link-UH5

    [Documentation]  Invoice pay via link-where purpose is Billpayment

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME15}    ${account_id1}  ${token1} 
    Log   ${resp.content}
    Should Be Equal As Strings              ${resp.status_code}   200

    ${source}=   FakerLibrary.word

    ${resp1}=  Invoice pay via link  ${invoice_uid}  ${amount}   ${purpose[1]}    ${source}  ${pid}   ${finance_payment_modes[1]}  ${bool[0]}   ${sid1}   ${pcid18}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  422


JD-TC-Invoice pay via link-UH6

    [Documentation]  Invoice pay via link-where customer id is invalid.

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME15}    ${account_id1}  ${token1} 
    Log   ${resp.content}
    Should Be Equal As Strings              ${resp.status_code}   200

    ${invalid}=  Random Int  min=20000   max=40000
    ${source}=   FakerLibrary.word

    ${resp1}=  Invoice pay via link  ${invoice_uid}  ${amount}   ${purpose[6]}    ${source}  ${pid}   ${finance_payment_modes[1]}  ${bool[0]}   ${sid1}   ${invalid}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  422

JD-TC-Invoice pay via link-UH7

    [Documentation]  Invoice pay via link-where purpose is prepayment.

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME15}    ${account_id1}  ${token1} 
    Log   ${resp.content}
    Should Be Equal As Strings              ${resp.status_code}   200

    ${source}=   FakerLibrary.word

    ${resp1}=  Invoice pay via link  ${invoice_uid}  ${amount}   ${purpose[0]}    ${source}  ${pid}   ${finance_payment_modes[1]}  ${bool[0]}   ${sid1}   ${pcid18}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  422


JD-TC-Invoice pay via link-UH8

    [Documentation]  Invoice pay via link-where purpose is donation.

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME15}    ${account_id1}  ${token1} 
    Log   ${resp.content}
    Should Be Equal As Strings              ${resp.status_code}   200

    ${source}=   FakerLibrary.word

    ${resp1}=  Invoice pay via link  ${invoice_uid}  ${amount}   ${purpose[5]}    ${source}  ${pid}   ${finance_payment_modes[1]}  ${bool[0]}   ${sid1}   ${pcid18}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  422

JD-TC-Invoice pay via link-UH9

    [Documentation]  update bill status as settled and then Invoice pay via link-.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME44}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${billStatusNote}=   FakerLibrary.word

    ${resp}=  Update bill status   ${invoice_uid}    ${billStatus[1]}       ${billStatusNote}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${INVOICE_SETTLED}=  format String   ${INVOICE_SETTLED}   ${billStatus[1]}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME15}    ${account_id1}  ${token1} 
    Log   ${resp.content}
    Should Be Equal As Strings              ${resp.status_code}   200
    ${source}=   FakerLibrary.word

    ${resp1}=  Invoice pay via link  ${invoice_uid}  ${amount}   ${purpose[5]}    ${source}  ${pid}   ${finance_payment_modes[1]}  ${bool[0]}   ${sid1}   ${pcid18}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    # Should Be Equal As Strings  ${resp.json()}   ${INVOICE_SETTLED}

JD-TC-Invoice pay via link-UH10

    [Documentation]  bill status is in draft stage and then Invoice pay via link-.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME44}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${invoiceLabel}=   FakerLibrary.word
    ${invoiceDate}=   db.get_date_by_timezone  ${tz}
    # ${invoiceDate}=   Get Current Date    result_format=%Y/%m/%d
    ${resp}=   Get next invoice Id   ${lid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${invoiceId}   ${resp.json()}

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



    ${itemName}=    FakerLibrary.word
    Set Suite Variable  ${itemName}
    ${price}=   Random Int  min=10  max=15
    ${price}=  Convert To Number  ${price}  1
    ${adhocItemList}=  Create Dictionary  itemName=${itemName}   quantity=${quantity}   price=${price}
    ${adhocItemList}=    Create List    ${adhocItemList}

    
    ${resp}=  Create Invoice   ${category_id2}    ${invoiceDate}      ${invoiceId}    ${providerConsumerIdList}    ${lid}    ${itemList}  invoiceStatus=${status_id1}       adhocItemList=${adhocItemList}    locationId=${lid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${invoice_id}   ${resp.json()['idList'][0]}
    Set Suite Variable   ${invoice_uid1}   ${resp.json()['uidList'][0]} 

    ${resp1}=  Get Invoice By Id  ${invoice_uid1}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200

    ${resp}=    Consumer Logout 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME15}    ${account_id1}  ${token1} 
    Log   ${resp.content}
    Should Be Equal As Strings              ${resp.status_code}   200

    ${source}=   FakerLibrary.word

    ${resp1}=  Invoice pay via link  ${invoice_uid1}  ${amount}   ${purpose[5]}    ${source}  ${pid}   ${finance_payment_modes[1]}  ${bool[0]}   ${sid1}   ${pcid18}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    # Should Be Equal As Strings  ${resp.json()}   ${Draft_status}


