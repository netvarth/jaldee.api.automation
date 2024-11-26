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
Variables         /ebs/TDD/varfiles/hl_providers.py

*** Variables ***

@{service_names}

@{New_status}    Status11   Status21    Status31    Status41    Status51    Status61 
${service_duration}     30
${DisplayName1}   item1_DisplayName


*** Test Cases ***

JD-TC-Get InvoiceTemplate Filter-1

    [Documentation]  create Invoice Template and Get InvoiceTemplate Filter   .


    ${firstname}  ${lastname}  ${PUSERPH0}  ${LoginId}=  Provider Signup
    Set Suite Variable  ${PUSERPH0}


    
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[0]}   

    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}

    ${resp}=  Get Bill Settings 
    Log   ${resp.json}
    IF  ${resp.status_code}!=200
        Log   Status code is not 200: ${resp.status_code}
        ${resp}=  Enable Disable bill  ${bool[1]}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
    ELSE IF  ${resp.json()['enablepos']}==${bool[0]}
        ${resp}=  Enable Disable bill  ${bool[1]}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=  Get Bill Settings 
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['enablepos']}    ${bool[1]}


    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Suite Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 


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


    ${name1}=   FakerLibrary.word
    Set Suite Variable    ${name1}
    ${resp}=  Create Category   ${name1}  ${categoryType[3]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${category_id2}   ${resp.json()}

    ${resp}=  Create Finance Status   ${New_status[0]}  ${categoryType[3]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${status_id1}   ${resp.json()}



    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Set Suite Variable  ${SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500

    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${service_duration}  ${bool[0]}  ${servicecharge}  ${bool[1]}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid1}  ${resp.json()} 


    ${quantity}=   Random Int  min=5  max=10
    ${quantity}=  Convert To Number  ${quantity}  1
    Set Suite Variable  ${quantity}
    ${serviceprice}=   Random Int  min=100  max=500
    ${serviceprice}=  Convert To Number  ${serviceprice}  1
    Set Suite Variable  ${serviceprice}

    ${serviceList}=  Create Dictionary  serviceId=${sid1}   quantity=${quantity}   price=${serviceprice} 
    ${serviceList}=    Create List    ${serviceList}
    ${netRate}=  Evaluate  ${quantity} * ${serviceprice}
    ${netRate}=  Convert To Number  ${netRate}  2
    Set Suite Variable  ${netRate}

    ${itemName}=    FakerLibrary.word
    Set Suite Variable  ${itemName}
    ${price}=   Random Int  min=10  max=15
    ${price}=  Convert To Number  ${price}  1
    Set Suite Variable  ${price}
    ${adhocItemList}=  Create Dictionary  itemName=${itemName}   quantity=${quantity}   price=${price}
    ${adhocItemList}=    Create List    ${adhocItemList}
    ${netRate_adhoc}=  Evaluate  ${quantity} * ${price}
    ${netRate_adhoc}=  Convert To Number  ${netRate_adhoc}  2
    Set Suite Variable  ${netRate_adhoc}

    ${item}=   FakerLibrary.word
    ${itemCode1}=     FakerLibrary.word
    ${resp}=  Create Sample Item   ${DisplayName1}   ${item}  ${itemCode1}  ${price}  ${bool[0]} 
    Log  ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${itemId1}   ${resp.json()} 

    ${resp}=   Get Item By Id  ${itemId1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${promotionalPrice}   ${resp.json()['promotionalPrice']}



    ${itemList}=  Create Dictionary  itemId=${itemId1}    quantity=${quantity}      amount=${promotionalPrice}
    ${itemList}=    Create List    ${itemList}
    ${netTotal}=  Evaluate  ${quantity} * ${promotionalPrice}
    ${netTotal}=  Convert To Number  ${netTotal}  2
    Set Suite Variable   ${netTotal}


    ${resp}=  Create Invoice Template   ${name1}   invoiceLabel=${New_status[0]}   categoryId=${category_id2}   statusId=${status_id1}    serviceList=${serviceList}   adhocItemList=${adhocItemList}   itemList=${itemList}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${templateUid}   ${resp.json()['templateUid']}

    ${resp}=   Get InvoiceTemplate Filter   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${account_id}
    Should Be Equal As Strings  ${resp.json()[0]['templateName']}  ${name1}
    Should Be Equal As Strings  ${resp.json()[0]['categoryId']}  ${category_id2}
    Should Be Equal As Strings  ${resp.json()[0]['categoryName']}  ${name1}
    Should Be Equal As Strings  ${resp.json()[0]['statusId']}  ${status_id1}
    Should Be Equal As Strings  ${resp.json()[0]['statusName']}  ${New_status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['invoiceLabel']}  ${New_status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['itemId']}  ${itemId1}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['displayName']}  ${DisplayName1}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['quantity']}  ${quantity}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['price']}  ${promotionalPrice}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['orignalPrice']}  ${price}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['netRate']}  ${netTotal}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['totalPrice']}  ${netTotal}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceId']}  ${sid1}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceName']}  ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['quantity']}  ${quantity}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['price']}  ${serviceprice}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['netRate']}  ${netRate}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['totalPrice']}  ${netRate}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['itemName']}  ${itemName}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['quantity']}  ${quantity}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['price']}  ${price}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['netRate']}  ${netRate_adhoc}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['totalPrice']}  ${netRate_adhoc}
    Should Be Equal As Strings  ${resp.json()[0]['templateUid']}  ${templateUid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}             ${toggle[0]}

JD-TC-Get InvoiceTemplate Filter-2

    [Documentation]   Get InvoiceTemplate Filter using template name   .

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=   Get InvoiceTemplate Filter    templateName-eq=${name1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${account_id}
    Should Be Equal As Strings  ${resp.json()[0]['templateName']}  ${name1}
    Should Be Equal As Strings  ${resp.json()[0]['categoryId']}  ${category_id2}
    Should Be Equal As Strings  ${resp.json()[0]['categoryName']}  ${name1}
    Should Be Equal As Strings  ${resp.json()[0]['statusId']}  ${status_id1}
    Should Be Equal As Strings  ${resp.json()[0]['statusName']}  ${New_status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['invoiceLabel']}  ${New_status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['itemId']}  ${itemId1}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['displayName']}  ${DisplayName1}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['quantity']}  ${quantity}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['price']}  ${promotionalPrice}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['orignalPrice']}  ${price}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['netRate']}  ${netTotal}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['totalPrice']}  ${netTotal}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceId']}  ${sid1}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceName']}  ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['quantity']}  ${quantity}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['price']}  ${serviceprice}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['netRate']}  ${netRate}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['totalPrice']}  ${netRate}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['itemName']}  ${itemName}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['quantity']}  ${quantity}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['price']}  ${price}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['netRate']}  ${netRate_adhoc}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['totalPrice']}  ${netRate_adhoc}
    Should Be Equal As Strings  ${resp.json()[0]['templateUid']}  ${templateUid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}             ${toggle[0]}

JD-TC-Get InvoiceTemplate Filter-3

    [Documentation]   Get InvoiceTemplate Filter using accountid   .

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=   Get InvoiceTemplate Filter    accountId-eq=${account_id}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${account_id}
    Should Be Equal As Strings  ${resp.json()[0]['templateName']}  ${name1}
    Should Be Equal As Strings  ${resp.json()[0]['categoryId']}  ${category_id2}
    Should Be Equal As Strings  ${resp.json()[0]['categoryName']}  ${name1}
    Should Be Equal As Strings  ${resp.json()[0]['statusId']}  ${status_id1}
    Should Be Equal As Strings  ${resp.json()[0]['statusName']}  ${New_status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['invoiceLabel']}  ${New_status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['itemId']}  ${itemId1}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['displayName']}  ${DisplayName1}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['quantity']}  ${quantity}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['price']}  ${promotionalPrice}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['orignalPrice']}  ${price}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['netRate']}  ${netTotal}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['totalPrice']}  ${netTotal}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceId']}  ${sid1}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceName']}  ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['quantity']}  ${quantity}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['price']}  ${serviceprice}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['netRate']}  ${netRate}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['totalPrice']}  ${netRate}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['itemName']}  ${itemName}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['quantity']}  ${quantity}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['price']}  ${price}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['netRate']}  ${netRate_adhoc}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['totalPrice']}  ${netRate_adhoc}
    Should Be Equal As Strings  ${resp.json()[0]['templateUid']}  ${templateUid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}             ${toggle[0]}

JD-TC-Get InvoiceTemplate Filter-4

    [Documentation]   Get InvoiceTemplate Filter using accountid   .

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=   Get InvoiceTemplate Filter    accountId-eq=${account_id}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${account_id}
    Should Be Equal As Strings  ${resp.json()[0]['templateName']}  ${name1}
    Should Be Equal As Strings  ${resp.json()[0]['categoryId']}  ${category_id2}
    Should Be Equal As Strings  ${resp.json()[0]['categoryName']}  ${name1}
    Should Be Equal As Strings  ${resp.json()[0]['statusId']}  ${status_id1}
    Should Be Equal As Strings  ${resp.json()[0]['statusName']}  ${New_status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['invoiceLabel']}  ${New_status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['itemId']}  ${itemId1}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['displayName']}  ${DisplayName1}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['quantity']}  ${quantity}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['price']}  ${promotionalPrice}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['orignalPrice']}  ${price}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['netRate']}  ${netTotal}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['totalPrice']}  ${netTotal}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceId']}  ${sid1}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceName']}  ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['quantity']}  ${quantity}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['price']}  ${serviceprice}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['netRate']}  ${netRate}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['totalPrice']}  ${netRate}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['itemName']}  ${itemName}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['quantity']}  ${quantity}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['price']}  ${price}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['netRate']}  ${netRate_adhoc}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['totalPrice']}  ${netRate_adhoc}
    Should Be Equal As Strings  ${resp.json()[0]['templateUid']}  ${templateUid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}             ${toggle[0]}

JD-TC-Get InvoiceTemplate Filter-5

    [Documentation]   Get InvoiceTemplate Filter using accountid   .

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=   Get InvoiceTemplate Filter    accountId-eq=${account_id}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${account_id}
    Should Be Equal As Strings  ${resp.json()[0]['templateName']}  ${name1}
    Should Be Equal As Strings  ${resp.json()[0]['categoryId']}  ${category_id2}
    Should Be Equal As Strings  ${resp.json()[0]['categoryName']}  ${name1}
    Should Be Equal As Strings  ${resp.json()[0]['statusId']}  ${status_id1}
    Should Be Equal As Strings  ${resp.json()[0]['statusName']}  ${New_status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['invoiceLabel']}  ${New_status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['itemId']}  ${itemId1}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['displayName']}  ${DisplayName1}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['quantity']}  ${quantity}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['price']}  ${promotionalPrice}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['orignalPrice']}  ${price}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['netRate']}  ${netTotal}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['totalPrice']}  ${netTotal}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceId']}  ${sid1}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceName']}  ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['quantity']}  ${quantity}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['price']}  ${serviceprice}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['netRate']}  ${netRate}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['totalPrice']}  ${netRate}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['itemName']}  ${itemName}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['quantity']}  ${quantity}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['price']}  ${price}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['netRate']}  ${netRate_adhoc}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['totalPrice']}  ${netRate_adhoc}
    Should Be Equal As Strings  ${resp.json()[0]['templateUid']}  ${templateUid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}             ${toggle[0]}
JD-TC-Get InvoiceTemplate Filter-6

    [Documentation]   Get InvoiceTemplate Filter using accountid   .

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=   Get InvoiceTemplate Filter    accountId-eq=${account_id}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${account_id}
    Should Be Equal As Strings  ${resp.json()[0]['templateName']}  ${name1}
    Should Be Equal As Strings  ${resp.json()[0]['categoryId']}  ${category_id2}
    Should Be Equal As Strings  ${resp.json()[0]['categoryName']}  ${name1}
    Should Be Equal As Strings  ${resp.json()[0]['statusId']}  ${status_id1}
    Should Be Equal As Strings  ${resp.json()[0]['statusName']}  ${New_status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['invoiceLabel']}  ${New_status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['itemId']}  ${itemId1}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['displayName']}  ${DisplayName1}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['quantity']}  ${quantity}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['price']}  ${promotionalPrice}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['orignalPrice']}  ${price}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['netRate']}  ${netTotal}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['totalPrice']}  ${netTotal}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceId']}  ${sid1}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceName']}  ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['quantity']}  ${quantity}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['price']}  ${serviceprice}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['netRate']}  ${netRate}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['totalPrice']}  ${netRate}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['itemName']}  ${itemName}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['quantity']}  ${quantity}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['price']}  ${price}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['netRate']}  ${netRate_adhoc}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['totalPrice']}  ${netRate_adhoc}
    Should Be Equal As Strings  ${resp.json()[0]['templateUid']}  ${templateUid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}             ${toggle[0]}


JD-TC-Get InvoiceTemplate Filter-7

    [Documentation]   Get InvoiceTemplate Filter using userId   .

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable      ${userId}          ${decrypted_data['id']}
    Set Suite Variable      ${userName}      ${decrypted_data['userName']}


    ${resp}=   Get InvoiceTemplate Filter    userId-eq=${userId}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${account_id}
    Should Be Equal As Strings  ${resp.json()[0]['templateName']}  ${name1}
    Should Be Equal As Strings  ${resp.json()[0]['categoryId']}  ${category_id2}
    Should Be Equal As Strings  ${resp.json()[0]['categoryName']}  ${name1}
    Should Be Equal As Strings  ${resp.json()[0]['statusId']}  ${status_id1}
    Should Be Equal As Strings  ${resp.json()[0]['statusName']}  ${New_status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['invoiceLabel']}  ${New_status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['itemId']}  ${itemId1}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['displayName']}  ${DisplayName1}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['quantity']}  ${quantity}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['price']}  ${promotionalPrice}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['orignalPrice']}  ${price}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['netRate']}  ${netTotal}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['totalPrice']}  ${netTotal}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceId']}  ${sid1}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceName']}  ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['quantity']}  ${quantity}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['price']}  ${serviceprice}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['netRate']}  ${netRate}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['totalPrice']}  ${netRate}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['itemName']}  ${itemName}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['quantity']}  ${quantity}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['price']}  ${price}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['netRate']}  ${netRate_adhoc}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['totalPrice']}  ${netRate_adhoc}
    Should Be Equal As Strings  ${resp.json()[0]['templateUid']}  ${templateUid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}             ${toggle[0]}

JD-TC-Get InvoiceTemplate Filter-8

    [Documentation]   Get InvoiceTemplate Filter using allowToUseOtherUsers   .

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200



    ${resp}=   Get InvoiceTemplate Filter    allowToUseOtherUsers-eq=${bool[0]}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${account_id}
    Should Be Equal As Strings  ${resp.json()[0]['templateName']}  ${name1}
    Should Be Equal As Strings  ${resp.json()[0]['categoryId']}  ${category_id2}
    Should Be Equal As Strings  ${resp.json()[0]['categoryName']}  ${name1}
    Should Be Equal As Strings  ${resp.json()[0]['statusId']}  ${status_id1}
    Should Be Equal As Strings  ${resp.json()[0]['statusName']}  ${New_status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['invoiceLabel']}  ${New_status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['itemId']}  ${itemId1}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['displayName']}  ${DisplayName1}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['quantity']}  ${quantity}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['price']}  ${promotionalPrice}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['orignalPrice']}  ${price}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['netRate']}  ${netTotal}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['totalPrice']}  ${netTotal}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceId']}  ${sid1}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceName']}  ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['quantity']}  ${quantity}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['price']}  ${serviceprice}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['netRate']}  ${netRate}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['totalPrice']}  ${netRate}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['itemName']}  ${itemName}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['quantity']}  ${quantity}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['price']}  ${price}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['netRate']}  ${netRate_adhoc}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['totalPrice']}  ${netRate_adhoc}
    Should Be Equal As Strings  ${resp.json()[0]['templateUid']}  ${templateUid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}             ${toggle[0]}

JD-TC-Get InvoiceTemplate Filter-9

    [Documentation]   Get InvoiceTemplate Filter using userName   .

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200



    ${resp}=   Get InvoiceTemplate Filter    userName-eq=${userName}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${account_id}
    Should Be Equal As Strings  ${resp.json()[0]['templateName']}  ${name1}
    Should Be Equal As Strings  ${resp.json()[0]['categoryId']}  ${category_id2}
    Should Be Equal As Strings  ${resp.json()[0]['categoryName']}  ${name1}
    Should Be Equal As Strings  ${resp.json()[0]['statusId']}  ${status_id1}
    Should Be Equal As Strings  ${resp.json()[0]['statusName']}  ${New_status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['invoiceLabel']}  ${New_status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['itemId']}  ${itemId1}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['displayName']}  ${DisplayName1}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['quantity']}  ${quantity}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['price']}  ${promotionalPrice}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['orignalPrice']}  ${price}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['netRate']}  ${netTotal}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['totalPrice']}  ${netTotal}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceId']}  ${sid1}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceName']}  ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['quantity']}  ${quantity}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['price']}  ${serviceprice}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['netRate']}  ${netRate}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['totalPrice']}  ${netRate}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['itemName']}  ${itemName}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['quantity']}  ${quantity}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['price']}  ${price}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['netRate']}  ${netRate_adhoc}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['totalPrice']}  ${netRate_adhoc}
    Should Be Equal As Strings  ${resp.json()[0]['templateUid']}  ${templateUid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}             ${toggle[0]}

JD-TC-Get InvoiceTemplate Filter-10

    [Documentation]   Get InvoiceTemplate Filter using templateUid   .

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200



    ${resp}=   Get InvoiceTemplate Filter    templateUid-eq=${templateUid}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${account_id}
    Should Be Equal As Strings  ${resp.json()[0]['templateName']}  ${name1}
    Should Be Equal As Strings  ${resp.json()[0]['categoryId']}  ${category_id2}
    Should Be Equal As Strings  ${resp.json()[0]['categoryName']}  ${name1}
    Should Be Equal As Strings  ${resp.json()[0]['statusId']}  ${status_id1}
    Should Be Equal As Strings  ${resp.json()[0]['statusName']}  ${New_status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['invoiceLabel']}  ${New_status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['itemId']}  ${itemId1}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['displayName']}  ${DisplayName1}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['quantity']}  ${quantity}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['price']}  ${promotionalPrice}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['orignalPrice']}  ${price}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['netRate']}  ${netTotal}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['totalPrice']}  ${netTotal}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceId']}  ${sid1}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceName']}  ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['quantity']}  ${quantity}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['price']}  ${serviceprice}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['netRate']}  ${netRate}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['totalPrice']}  ${netRate}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['itemName']}  ${itemName}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['quantity']}  ${quantity}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['price']}  ${price}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['netRate']}  ${netRate_adhoc}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['totalPrice']}  ${netRate_adhoc}
    Should Be Equal As Strings  ${resp.json()[0]['templateUid']}  ${templateUid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}             ${toggle[0]}


JD-TC-Get InvoiceTemplate Filter-11

    [Documentation]   Get InvoiceTemplate Filter using invoiceCategoryId   .

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200



    ${resp}=   Get InvoiceTemplate Filter    invoiceCategoryId-eq=${category_id2}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${account_id}
    Should Be Equal As Strings  ${resp.json()[0]['templateName']}  ${name1}
    Should Be Equal As Strings  ${resp.json()[0]['categoryId']}  ${category_id2}
    Should Be Equal As Strings  ${resp.json()[0]['categoryName']}  ${name1}
    Should Be Equal As Strings  ${resp.json()[0]['statusId']}  ${status_id1}
    Should Be Equal As Strings  ${resp.json()[0]['statusName']}  ${New_status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['invoiceLabel']}  ${New_status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['itemId']}  ${itemId1}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['displayName']}  ${DisplayName1}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['quantity']}  ${quantity}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['price']}  ${promotionalPrice}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['orignalPrice']}  ${price}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['netRate']}  ${netTotal}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['totalPrice']}  ${netTotal}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceId']}  ${sid1}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceName']}  ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['quantity']}  ${quantity}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['price']}  ${serviceprice}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['netRate']}  ${netRate}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['totalPrice']}  ${netRate}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['itemName']}  ${itemName}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['quantity']}  ${quantity}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['price']}  ${price}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['netRate']}  ${netRate_adhoc}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['totalPrice']}  ${netRate_adhoc}
    Should Be Equal As Strings  ${resp.json()[0]['templateUid']}  ${templateUid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}             ${toggle[0]}

JD-TC-Get InvoiceTemplate Filter-12

    [Documentation]   Get InvoiceTemplate Filter using invoiceStatusId   .

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200



    ${resp}=   Get InvoiceTemplate Filter    invoiceStatus-eq=${status_id1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${account_id}
    Should Be Equal As Strings  ${resp.json()[0]['templateName']}  ${name1}
    Should Be Equal As Strings  ${resp.json()[0]['categoryId']}  ${category_id2}
    Should Be Equal As Strings  ${resp.json()[0]['categoryName']}  ${name1}
    Should Be Equal As Strings  ${resp.json()[0]['statusId']}  ${status_id1}
    Should Be Equal As Strings  ${resp.json()[0]['statusName']}  ${New_status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['invoiceLabel']}  ${New_status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['itemId']}  ${itemId1}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['displayName']}  ${DisplayName1}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['quantity']}  ${quantity}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['price']}  ${promotionalPrice}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['orignalPrice']}  ${price}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['netRate']}  ${netTotal}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['totalPrice']}  ${netTotal}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceId']}  ${sid1}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceName']}  ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['quantity']}  ${quantity}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['price']}  ${serviceprice}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['netRate']}  ${netRate}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['totalPrice']}  ${netRate}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['itemName']}  ${itemName}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['quantity']}  ${quantity}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['price']}  ${price}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['netRate']}  ${netRate_adhoc}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['totalPrice']}  ${netRate_adhoc}
    Should Be Equal As Strings  ${resp.json()[0]['templateUid']}  ${templateUid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}             ${toggle[0]}

JD-TC-Get InvoiceTemplate Filter-13

    [Documentation]   Get InvoiceTemplate Filter using status   .

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200



    ${resp}=   Get InvoiceTemplate Filter    status-eq=${toggle[0]}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${account_id}
    Should Be Equal As Strings  ${resp.json()[0]['templateName']}  ${name1}
    Should Be Equal As Strings  ${resp.json()[0]['categoryId']}  ${category_id2}
    Should Be Equal As Strings  ${resp.json()[0]['categoryName']}  ${name1}
    Should Be Equal As Strings  ${resp.json()[0]['statusId']}  ${status_id1}
    Should Be Equal As Strings  ${resp.json()[0]['statusName']}  ${New_status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['invoiceLabel']}  ${New_status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['itemId']}  ${itemId1}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['displayName']}  ${DisplayName1}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['quantity']}  ${quantity}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['price']}  ${promotionalPrice}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['orignalPrice']}  ${price}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['netRate']}  ${netTotal}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['totalPrice']}  ${netTotal}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceId']}  ${sid1}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceName']}  ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['quantity']}  ${quantity}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['price']}  ${serviceprice}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['netRate']}  ${netRate}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['totalPrice']}  ${netRate}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['itemName']}  ${itemName}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['quantity']}  ${quantity}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['price']}  ${price}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['netRate']}  ${netRate_adhoc}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['totalPrice']}  ${netRate_adhoc}
    Should Be Equal As Strings  ${resp.json()[0]['templateUid']}  ${templateUid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}             ${toggle[0]}

JD-TC-Get InvoiceTemplate Filter-14

    [Documentation]   Get InvoiceTemplate Filter using invoiceLabel   .

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200



    ${resp}=   Get InvoiceTemplate Filter    invoiceLabel-eq=${New_status[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${account_id}
    Should Be Equal As Strings  ${resp.json()[0]['templateName']}  ${name1}
    Should Be Equal As Strings  ${resp.json()[0]['categoryId']}  ${category_id2}
    Should Be Equal As Strings  ${resp.json()[0]['categoryName']}  ${name1}
    Should Be Equal As Strings  ${resp.json()[0]['statusId']}  ${status_id1}
    Should Be Equal As Strings  ${resp.json()[0]['statusName']}  ${New_status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['invoiceLabel']}  ${New_status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['itemId']}  ${itemId1}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['displayName']}  ${DisplayName1}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['quantity']}  ${quantity}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['price']}  ${promotionalPrice}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['orignalPrice']}  ${price}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['netRate']}  ${netTotal}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['totalPrice']}  ${netTotal}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceId']}  ${sid1}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceName']}  ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['quantity']}  ${quantity}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['price']}  ${serviceprice}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['netRate']}  ${netRate}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['totalPrice']}  ${netRate}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['itemName']}  ${itemName}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['quantity']}  ${quantity}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['price']}  ${price}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['netRate']}  ${netRate_adhoc}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['totalPrice']}  ${netRate_adhoc}
    Should Be Equal As Strings  ${resp.json()[0]['templateUid']}  ${templateUid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}             ${toggle[0]}

JD-TC-Get InvoiceTemplate Filter-15

    [Documentation]   Get InvoiceTemplate Filter using locationId   .

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200



    ${resp}=   Get InvoiceTemplate Filter    locationId-eq=${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${account_id}
    Should Be Equal As Strings  ${resp.json()[0]['templateName']}  ${name1}
    Should Be Equal As Strings  ${resp.json()[0]['categoryId']}  ${category_id2}
    Should Be Equal As Strings  ${resp.json()[0]['categoryName']}  ${name1}
    Should Be Equal As Strings  ${resp.json()[0]['statusId']}  ${status_id1}
    Should Be Equal As Strings  ${resp.json()[0]['statusName']}  ${New_status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['invoiceLabel']}  ${New_status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['itemId']}  ${itemId1}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['displayName']}  ${DisplayName1}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['quantity']}  ${quantity}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['price']}  ${promotionalPrice}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['orignalPrice']}  ${price}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['netRate']}  ${netTotal}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['totalPrice']}  ${netTotal}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceId']}  ${sid1}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceName']}  ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['quantity']}  ${quantity}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['price']}  ${serviceprice}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['netRate']}  ${netRate}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['totalPrice']}  ${netRate}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['itemName']}  ${itemName}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['quantity']}  ${quantity}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['price']}  ${price}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['netRate']}  ${netRate_adhoc}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['totalPrice']}  ${netRate_adhoc}
    Should Be Equal As Strings  ${resp.json()[0]['templateUid']}  ${templateUid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}             ${toggle[0]}

JD-TC-Get InvoiceTemplate Filter-16

    [Documentation]   Get InvoiceTemplate Filter using createdDate   .

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200



    ${resp}=   Get InvoiceTemplate Filter    createdDate-eq=${DAY1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${account_id}
    Should Be Equal As Strings  ${resp.json()[0]['templateName']}  ${name1}
    Should Be Equal As Strings  ${resp.json()[0]['categoryId']}  ${category_id2}
    Should Be Equal As Strings  ${resp.json()[0]['categoryName']}  ${name1}
    Should Be Equal As Strings  ${resp.json()[0]['statusId']}  ${status_id1}
    Should Be Equal As Strings  ${resp.json()[0]['statusName']}  ${New_status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['invoiceLabel']}  ${New_status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['itemId']}  ${itemId1}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['displayName']}  ${DisplayName1}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['quantity']}  ${quantity}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['price']}  ${promotionalPrice}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['orignalPrice']}  ${price}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['netRate']}  ${netTotal}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['totalPrice']}  ${netTotal}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceId']}  ${sid1}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceName']}  ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['quantity']}  ${quantity}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['price']}  ${serviceprice}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['netRate']}  ${netRate}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['totalPrice']}  ${netRate}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['itemName']}  ${itemName}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['quantity']}  ${quantity}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['price']}  ${price}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['netRate']}  ${netRate_adhoc}
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList'][0]['totalPrice']}  ${netRate_adhoc}
    Should Be Equal As Strings  ${resp.json()[0]['templateUid']}  ${templateUid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}             ${toggle[0]}




JD-TC-Get InvoiceTemplate Filter-UH1

    [Documentation]   Get InvoiceTemplate Filte without login

    ${resp}=   Get InvoiceTemplate Filter
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings    ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-Get InvoiceTemplate Filter-18

    [Documentation]   update invoice template and Get InvoiceTemplate Filte


    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=   FakerLibrary.word
    ${resp}=  Update Invoice Template    ${templateUid}  ${name2}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=   Get InvoiceTemplate Filter    templateName-eq=${name2}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${account_id}
    Should Be Equal As Strings  ${resp.json()[0]['templateName']}  ${name2}
    Should Be Equal As Strings  ${resp.json()[0]['categoryId']}  ${category_id2}
    Should Be Equal As Strings  ${resp.json()[0]['categoryName']}  ${name1}
    Should Be Equal As Strings  ${resp.json()[0]['statusId']}  ${status_id1}
    Should Be Equal As Strings  ${resp.json()[0]['statusName']}  ${New_status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['invoiceLabel']}  ${New_status[0]}
    Should Be Equal As Strings  ${resp.json()[0]['itemList']}  []
    Should Be Equal As Strings  ${resp.json()[0]['serviceList']}  []
    Should Be Equal As Strings  ${resp.json()[0]['adhocItemList']}  []
    Should Be Equal As Strings  ${resp.json()[0]['templateUid']}  ${templateUid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}             ${toggle[0]}

JD-TC-Get InvoiceTemplate Filter-UH2

    [Documentation]   Get InvoiceTemplate Filter using invalid template name


    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=   Get InvoiceTemplate Filter    templateName-eq=${name1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()}  []


