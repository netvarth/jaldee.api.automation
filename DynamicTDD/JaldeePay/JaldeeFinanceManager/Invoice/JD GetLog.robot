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


JD-TC-Get Log-1

    [Documentation]  Create a invoice and get log.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME70}  ${PASSWORD}
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

       ${resp}=    Get finance Config
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get default finance category Config
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

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
    ${itemList}=  Create Dictionary  itemId=${itemId}   quantity=${quantity}    price=${promotionalPrice}
    # ${itemList}=    Create List    ${itemList}

    ${resp}=  Create Finance Status   ${New_status[0]}  ${categoryType[3]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${status_id1}   ${resp.json()}

   ${resp}=   Get next invoice Id   ${lid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${invoiceId}   ${resp.json()}


    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable    ${DAY}
    # ${time_now}=    db.get_time_by_timezone  ${tz}
    ${time_now}=    db.get_tz_time_secs  ${tz}
    # ${time_now}=    DateTime.Convert Date    ${time_now}    result_format=%H:%M:%S  
    Set Suite Variable    ${time_now}

    
    ${resp}=  Create Invoice   ${category_id2}    ${invoiceDate}      ${invoiceId}    ${providerConsumerIdList}  ${lid}   ${itemList}  invoiceStatus=${status_id1}   billStatus=${billStatus[0]}   locationId=${lid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${invoice_uid}   ${resp.json()['uidList'][0]}   

    #sleep  02s
 

    ${resp}=  Get Invoice Log List UId   ${invoice_uid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['account']}  ${account_id1}
    Should Be Equal As Strings  ${resp.json()['invoiceId']}  ${invoiceId}
    Should Be Equal As Strings  ${resp.json()['invoiceUid']}  ${invoice_uid}
    Should Be Equal As Strings  ${resp.json()['invoiceStateList'][0]['date']}  ${DAY}
    Should Be Equal As Strings  ${resp.json()['invoiceStateList'][0]['time']}  ${time_now}
    Should Be Equal As Strings  ${resp.json()['invoiceStateList'][0]['userType']}  ${userType[0]}
    Should Be Equal As Strings  ${resp.json()['invoiceStateList'][0]['localUserId']}  ${pid}

JD-TC-Get Log-2

    [Documentation]  Update invoice and get log.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME70}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

   ${invoiceLabel}=   FakerLibrary.word
    ${invoiceDate}=   db.get_date_by_timezone  ${tz}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable    ${DAY}
    ${time_now}=    db.get_tz_time_secs  ${tz}
    # ${time_now}=    DateTime.Convert Time    ${time_now}    
    Set Test Variable    ${time_now}

    ${resp}=  Update Invoice   ${invoice_uid}    ${category_id2}    ${invoiceDate}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    #sleep  02s
 

    ${resp}=  Get Invoice Log List UId   ${invoice_uid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['account']}  ${account_id1}
    Should Be Equal As Strings  ${resp.json()['invoiceUid']}  ${invoice_uid}
    Should Be Equal As Strings  ${resp.json()['invoiceStateList'][0]['date']}  ${DAY}
    Should Be Equal As Strings  ${resp.json()['invoiceStateList'][0]['time']}  ${time_now}
    Should Be Equal As Strings  ${resp.json()['invoiceStateList'][0]['userType']}  ${userType[0]}
    Should Be Equal As Strings  ${resp.json()['invoiceStateList'][0]['localUserId']}  ${pid}

JD-TC-Get Log-3

    [Documentation]   bill status is in draft and try to get log .

    ${resp}=  Encrypted Provider Login  ${PUSERNAME70}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${invoiceLabel}=   FakerLibrary.word
    ${invoiceDate}=   db.get_date_by_timezone  ${tz}
    ${invoiceId}=   FakerLibrary.word

    ${item1}=     FakerLibrary.word
    ${itemCode1}=     FakerLibrary.word
    ${price1}=     Random Int   min=400   max=500
    ${price}=  Convert To Number  ${price1}  1
    Set Test Variable  ${price} 
    ${resp}=  Create Sample Item   ${DisplayName1}   ${item1}  ${itemCode1}  ${price}  ${bool[1]} 
    Log  ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${itemId}  ${resp.json()}

    ${resp}=   Get Item By Id  ${itemId}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${promotionalPrice}   ${resp.json()['promotionalPrice']}


    ${quantity}=   Random Int  min=5  max=10
    ${quantity}=  Convert To Number  ${quantity}  1
    ${itemList}=  Create Dictionary  itemId=${itemId}   quantity=${quantity}    price=${promotionalPrice}
    # ${itemList}=    Create List    ${itemList}

    ${resp}=  Create Finance Status   ${New_status[3]}  ${categoryType[3]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${status_id1}   ${resp.json()}


    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Test Variable    ${DAY}
    ${time_now}=    db.get_tz_time_secs  ${tz}   
    # ${time_now}=    DateTime.Convert Date    ${time_now}    result_format=%H:%M:%S  
    Set Test Variable    ${time_now}

    
    ${resp}=  Create Invoice   ${category_id2}    ${invoiceDate}      ${invoiceId}    ${providerConsumerIdList}   ${lid}   ${itemList}  invoiceStatus=${status_id1}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${invoice_uid1}   ${resp.json()['uidList'][0]}  

    ${resp1}=  Get Invoice Log List UId   ${invoice_uid1}
    Log  ${resp1.json()}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Should Be Equal As Strings  ${resp1.json()['invoiceUid']}  ${invoice_uid1}
    Should Be Equal As Strings  ${resp1.json()['invoiceStateList'][0]['date']}  ${DAY}
    Should Be Equal As Strings  ${resp1.json()['invoiceStateList'][0]['time']}  ${time_now}
    Should Be Equal As Strings  ${resp1.json()['invoiceStateList'][0]['userType']}  ${userType[0]}
    Should Be Equal As Strings  ${resp1.json()['invoiceStateList'][0]['localUserId']}  ${pid}




JD-TC-Get Log-UH1

    [Documentation]   get log with another login.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME71}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Invoice Log List UId   ${invoice_uid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${CAP_JALDEE_FINANCE_DISABLED}

JD-TC-Get Log-UH2

    [Documentation]   get log where invoice id is invalid.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME70}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${invoice}=  FakerLibrary.RandomNumber

    ${resp1}=  Get Invoice Log List UId   ${invoice}
    Log  ${resp1.json()}
    Should Be Equal As Strings  ${resp1.status_code}  422
    Should Be Equal As Strings  ${resp1.json()}   ${INVALID_FM_INVOICE_ID}


