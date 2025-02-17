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
${service_duration}     30

${DisplayName1}   item1_DisplayName

*** Test Cases ***


JD-TC-UpdateInvoice-1

    [Documentation]  Create a invoice with valid details and update the amount.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME41}  ${PASSWORD}
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
    Set Suite Variable   ${name1}
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
    ${address}=  FakerLibrary.address
    Set Suite Variable  ${address}
    ${invoiceLabel}=   FakerLibrary.word
    ${invoiceDate}=   db.get_date_by_timezone  ${tz}
    ${invoiceId}=   FakerLibrary.word

    ${quantity}=   Random Int  min=5  max=10
    ${quantity}=  Convert To Number  ${quantity}  1

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Set Suite Variable  ${SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500

    ${maxBookingsAllowed}=   Random Int  min=1  max=5
    ${maxBookingsAllowed}=  Convert To Number  ${maxBookingsAllowed}  1
    ${srv_duration}=   Random Int   min=10   max=20
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${srv_duration}  ${bool[0]}  ${servicecharge}  ${bool[0]}   maxBookingsAllowed=${maxBookingsAllowed}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid1}  ${resp.json()}
        ${serviceprice}=   Random Int  min=10  max=15
    ${serviceprice}=  Convert To Number  ${serviceprice}  1

    ${serviceList}=  Create Dictionary  serviceId=${sid1}   quantity=${quantity}  price=${serviceprice}
    ${serviceList}=    Create List    ${serviceList}

    ${itemName}=    FakerLibrary.word
    Set Suite Variable  ${itemName}
    ${price}=   Random Int  min=10  max=15
    ${price}=  Convert To Number  ${price}  1
    ${adhocItemList}=  Create Dictionary  itemName=${itemName}   quantity=${quantity}   price=${price}
    ${adhocItemList}=    Create List    ${adhocItemList}

    ${itemName1}=    FakerLibrary.word
    Set Suite Variable  ${itemName1}
    ${price}=   Random Int  min=10  max=15
    ${price1}=  Convert To Number  ${price}  1
    ${adhocItemList1}=  Create Dictionary  itemName=${itemName1}   quantity=${quantity}   price=${price1}
    ${adhocItemList1}=    Create List    ${adhocItemList1}
    
    ${resp}=  Create Invoice   ${category_id2}    ${invoiceDate}      ${invoiceId}    ${providerConsumerIdList}   ${lid}   serviceList=${serviceList}   adhocItemList=${adhocItemList} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${invoice_uid}   ${resp.json()['uidList'][0]}    


    ${resp1}=  Get Invoice By Id  ${invoice_uid}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200


    ${resp}=  Update Invoice   ${invoice_uid}    ${category_id2}    ${invoiceDate}    adhocItemList=${adhocItemList1}   invoiceLabel=${invoiceLabel}  billedTo=${address}    
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp1}=  Get Invoice By Id  ${invoice_uid}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Should Be Equal As Strings  ${resp1.json()['accountId']}  ${account_id1}
    Should Be Equal As Strings  ${resp1.json()['invoiceCategoryId']}  ${category_id2}
    Should Be Equal As Strings  ${resp1.json()['categoryName']}  ${name1}
    Should Be Equal As Strings  ${resp1.json()['invoiceDate']}  ${invoiceDate}
    Should Be Equal As Strings  ${resp1.json()['billedTo']}  ${address}
    Should Be Equal As Strings  ${resp1.json()['invoiceLabel']}  ${invoiceLabel}
    Should Be Equal As Strings  ${resp1.json()['adhocItemList'][0]['itemName']}  ${itemName1}
    Should Be Equal As Strings  ${resp1.json()['adhocItemList'][0]['quantity']}  ${quantity}
    Should Be Equal As Strings  ${resp1.json()['adhocItemList'][0]['price']}  ${price1}



JD-TC-UpdateInvoice-2

    [Documentation]  Update invoice with empty invoice date.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME41}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

 
    ${invoiceLabel}=   FakerLibrary.word
    ${invoiceDate}=  db.add_timezone_date  ${tz}  10   
    ${invoiceId}=   FakerLibrary.word

    ${amount1}=   Random Int  min=500  max=2000
    ${amount1}=     roundoff    ${amount1}   1



    ${resp}=  Update Invoice   ${invoice_uid}    ${category_id2}    ${invoiceDate}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp1}=  Get Invoice By Id  ${invoice_uid}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Should Be Equal As Strings  ${resp1.json()['accountId']}  ${account_id1}
    Should Be Equal As Strings  ${resp1.json()['invoiceCategoryId']}  ${category_id2}
    Should Be Equal As Strings  ${resp1.json()['categoryName']}  ${name1}
    Should Be Equal As Strings  ${resp1.json()['invoiceDate']}  ${invoiceDate}




JD-TC-UpdateInvoice-4

    [Documentation]  Update invoice with adding waitlist id.***This usecase is not now in dev****

    ${resp}=  Encrypted Provider Login  ${PUSERNAME41}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${invoiceDate}=   db.subtract_timezone_date  ${tz}  20   
    ${description}=   FakerLibrary.word
    
    ${resp}=  Update Invoice   ${invoice_uid}    ${category_id2}    ${invoiceDate}    description=${description}   dueDate=${invoiceDate}  termsConditions=${description}   notesForCustomer=${description}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp1}=  Get Invoice By Id  ${invoice_uid}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Should Be Equal As Strings  ${resp1.json()['accountId']}  ${account_id1}
    Should Be Equal As Strings  ${resp1.json()['invoiceCategoryId']}  ${category_id2}
    Should Be Equal As Strings  ${resp1.json()['categoryName']}  ${name1}
    Should Be Equal As Strings  ${resp1.json()['invoiceDate']}  ${invoiceDate}
    Should Be Equal As Strings  ${resp1.json()['description']}  ${description}
    Should Be Equal As Strings  ${resp1.json()['termsConditions']}  ${description}
    Should Be Equal As Strings  ${resp1.json()['notesForCustomer']}  ${description}



JD-TC-UpdateInvoice-UH1

    [Documentation]  Update invoice with invalid invoice uid.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME41}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

 
    ${invoiceLabel}=   FakerLibrary.word
    ${invoiceDate}=   db.get_date_by_timezone  ${tz}
    ${invoiceId}=   FakerLibrary.word

    ${fakeid}=    Random Int  min=1000   max=9999	

    ${resp}=  Update Invoice   ${fakeid}    ${category_id2}    ${invoiceDate}   invoiceLabel=${invoiceLabel}  billedTo=${address}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${INVALID_FM_INVOICE_ID}

JD-TC-UpdateInvoice-UH2

    [Documentation]  Update invoice with invalid category id.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME41}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

 
    ${invoiceLabel}=   FakerLibrary.word
    ${invoiceDate}=   db.get_date_by_timezone  ${tz}
    ${invoiceId}=   FakerLibrary.word

    ${fakeid}=    Random Int  min=1000   max=9999	

    ${resp}=  Update Invoice   ${invoice_uid}    ${fakeid}    ${invoiceDate}   invoiceLabel=${invoiceLabel}  billedTo=${address}    
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${INVALID_INVOICE_CATEGORY_ID}

# JD-TC-UpdateInvoice-UH3

#     [Documentation]  Update invoice with invalid vendor  uid.

#     ${resp}=  Encrypted Provider Login  ${PUSERNAME41}  ${PASSWORD}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

 
#     ${invoiceLabel}=   FakerLibrary.word
#     ${invoiceDate}=   db.get_date_by_timezone  ${tz}
#     ${invoiceId}=   FakerLibrary.word

#     ${fakeid}=    Random Int  min=1000   max=9999	

#     ${resp}=  Update Invoice   ${invoice_uid}    ${category_id2}    ${invoiceDate}   ${invoiceLabel}   ${address}   ${fakeid}   
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  422
#     Should Be Equal As Strings  ${resp.json()}   ${INVALID_VENDOR}

JD-TC-UpdateInvoice-UH4

    [Documentation]  Update bill status as settled then try to update invoice.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME41}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

 
    ${invoiceLabel}=   FakerLibrary.word
    ${invoiceDate}=   db.Add Date  -70
    ${invoiceId}=   FakerLibrary.word

    ${amount1}=   Random Int  min=500  max=2000
    ${amount1}=     roundoff    ${amount1}   1

    ${billStatusNote}=   FakerLibrary.word

    ${resp}=  Update bill status   ${invoice_uid}    ${billStatus[1]}    ${billStatusNote}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${INVOICE_STATUS}=  format String   ${INVOICE_STATUS}   ${billStatus[1]}

    ${resp}=  Update Invoice   ${invoice_uid}    ${category_id2}    ${invoiceDate}   invoiceLabel=${invoiceLabel}  billedTo=${address}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${INVOICE_STATUS}

*** Comments ***
JD-TC-UpdateInvoice-3

    [Documentation]  Update invoice with adding waitlist id.***This usecase is not now in dev****

    ${resp}=  Encrypted Provider Login  ${PUSERNAME41}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

      ${resp}=  AddCustomer  ${CUSERNAME1}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${cid}  ${resp.json()}

      ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
      Log   ${resp.json()}
      Should Be Equal As Strings      ${resp.status_code}  200


      ${resp}=  Create Sample Location  
      Set Suite Variable    ${loc_id1}    ${resp}  

      ${resp}=   Get Location ById  ${loc_id1}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${tz}  ${resp.json()['timezone']}

      ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
      Set Suite Variable  ${CUR_DAY}
      ${SERVICE2}=    generate_unique_service_name  ${service_names}
      ${resp}=   Create Sample Service  ${SERVICE2} 
      Set Suite Variable    ${ser_id1}    ${resp}
      ${q_name}=    FakerLibrary.name
      Set Suite Variable    ${q_name}
      ${list}=  Create List   1  2  3  4  5  6  7
      Set Suite Variable    ${list}
      ${strt_time}=   db.add_timezone_time     ${tz}  1  00
      Set Suite Variable    ${strt_time}
      ${end_time}=    db.add_timezone_time     ${tz}  3  00 
      Set Suite Variable    ${end_time}   
      ${parallel}=   Random Int  min=1   max=1
      Set Suite Variable   ${parallel}
      ${capacity}=  Random Int   min=10   max=20
      Set Suite Variable   ${capacity}
      ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}  
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${que_id1}   ${resp.json()}
      ${desc}=   FakerLibrary.word
      Set Suite Variable  ${desc}
      ${resp}=  Add To Waitlist  ${cid}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid} 
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${wid}  ${wid[0]}
      ${resp}=  Get Waitlist By Id  ${wid} 
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable   ${fullAmount}  ${resp.json()['fullAmt']}         
    

 
    ${invoiceLabel}=   FakerLibrary.word
    ${invoiceDate}=   db.subtract_timezone_date  ${tz}  20      
    ${invoiceId}=   FakerLibrary.word

    ${amount1}=   Random Int  min=500  max=2000
    ${amount1}=     roundoff    ${amount1}   1



    ${resp}=  Update Invoice   ${invoice_uid}    ${category_id2}    ${invoiceDate}    ynwUuid=${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp1}=  Get Invoice By Id  ${invoice_uid}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Should Be Equal As Strings  ${resp1.json()['accountId']}  ${account_id1}
    Should Be Equal As Strings  ${resp1.json()['invoiceCategoryId']}  ${category_id2}
    Should Be Equal As Strings  ${resp1.json()['categoryName']}  ${name1}
    Should Be Equal As Strings  ${resp1.json()['invoiceDate']}  ${invoiceDate}





