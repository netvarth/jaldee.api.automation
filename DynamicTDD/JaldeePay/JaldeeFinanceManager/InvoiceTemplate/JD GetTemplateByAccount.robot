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

@{New_status}    Status11   Status21    Status31    Status41    Status51    Status61 
${service_duration}     30
${DisplayName1}   item1_DisplayName

*** Test Cases ***

JD-TC-Get Invoice Template Using Account-1

    [Documentation]  Get Invoice Template Using Account.


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
    Log   ${resp.content}
    ${resp}=  Enable Disable bill  ${bool[1]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Create Sample Location  
    Set Suite Variable    ${lid}    ${resp}  

    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}

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



    ${SERVICE1}=    FakerLibrary.word
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

    ${resp}=   Get InvoiceTemplates by account  
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

JD-TC-Get Invoice Template Using Account-2

    [Documentation]   Get Invoice Template Using Account-contain 2 list


    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name}=   FakerLibrary.word
    ${termsAndConditions}=   FakerLibrary.word
    ${notesForCustomer}=   FakerLibrary.word
    ${description}=   FakerLibrary.word
    ${resp}=  Create Invoice Template   ${name}    termsAndConditions=${termsAndConditions}    notesForCustomer=${notesForCustomer}   description=${description}       
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${templateUid7}   ${resp.json()['templateUid']}

    ${resp}=   Get InvoiceTemplates by account  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

     ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  2

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['templateUid']}' == '${templateUid7}'  
            Should Be Equal As Strings  ${resp.json()[${i}]['accountId']}  ${account_id}
            Should Be Equal As Strings  ${resp.json()[${i}]['templateName']}  ${name}
            Should Be Equal As Strings  ${resp.json()[${i}]['termsAndConditions']}  ${termsAndConditions}
            Should Be Equal As Strings  ${resp.json()[${i}]['notesForCustomer']}  ${notesForCustomer}
            Should Be Equal As Strings  ${resp.json()[${i}]['description']}  ${description}
            Should Be Equal As Strings  ${resp.json()[${i}]['itemList']}  []
            Should Be Equal As Strings  ${resp.json()[${i}]['serviceList']}  []
            Should Be Equal As Strings  ${resp.json()[${i}]['adhocItemList']}  []
            Should Be Equal As Strings  ${resp.json()[${i}]['templateUid']}  ${templateUid7}
            Should Be Equal As Strings  ${resp.json()[${i}]['status']}             ${toggle[0]}   

        ELSE IF     '${resp.json()[${i}]['templateUid']}' == '${templateUid}'  
            Should Be Equal As Strings  ${resp.json()[${i}]['accountId']}  ${account_id}
            Should Be Equal As Strings  ${resp.json()[${i}]['templateName']}  ${name1}
            Should Be Equal As Strings  ${resp.json()[${i}]['categoryId']}  ${category_id2}
            Should Be Equal As Strings  ${resp.json()[${i}]['categoryName']}  ${name1}
            Should Be Equal As Strings  ${resp.json()[${i}]['statusId']}  ${status_id1}
            Should Be Equal As Strings  ${resp.json()[${i}]['statusName']}  ${New_status[0]}
            Should Be Equal As Strings  ${resp.json()[${i}]['invoiceLabel']}  ${New_status[0]}
            Should Be Equal As Strings  ${resp.json()[${i}]['itemList'][0]['itemId']}  ${itemId1}
            Should Be Equal As Strings  ${resp.json()[${i}]['itemList'][0]['displayName']}  ${DisplayName1}
            Should Be Equal As Strings  ${resp.json()[${i}]['itemList'][0]['quantity']}  ${quantity}
            Should Be Equal As Strings  ${resp.json()[${i}]['itemList'][0]['price']}  ${promotionalPrice}
            Should Be Equal As Strings  ${resp.json()[${i}]['itemList'][0]['orignalPrice']}  ${price}
            Should Be Equal As Strings  ${resp.json()[${i}]['itemList'][0]['netRate']}  ${netTotal}
            Should Be Equal As Strings  ${resp.json()[${i}]['itemList'][0]['totalPrice']}  ${netTotal}
            Should Be Equal As Strings  ${resp.json()[${i}]['serviceList'][0]['serviceId']}  ${sid1}
            Should Be Equal As Strings  ${resp.json()[${i}]['serviceList'][0]['serviceName']}  ${SERVICE1}
            Should Be Equal As Strings  ${resp.json()[${i}]['serviceList'][0]['quantity']}  ${quantity}
            Should Be Equal As Strings  ${resp.json()[${i}]['serviceList'][0]['price']}  ${serviceprice}
            Should Be Equal As Strings  ${resp.json()[${i}]['serviceList'][0]['netRate']}  ${netRate}
            Should Be Equal As Strings  ${resp.json()[${i}]['serviceList'][0]['totalPrice']}  ${netRate}
            Should Be Equal As Strings  ${resp.json()[${i}]['adhocItemList'][0]['itemName']}  ${itemName}
            Should Be Equal As Strings  ${resp.json()[${i}]['adhocItemList'][0]['quantity']}  ${quantity}
            Should Be Equal As Strings  ${resp.json()[${i}]['adhocItemList'][0]['price']}  ${price}
            Should Be Equal As Strings  ${resp.json()[${i}]['adhocItemList'][0]['netRate']}  ${netRate_adhoc}
            Should Be Equal As Strings  ${resp.json()[${i}]['adhocItemList'][0]['totalPrice']}  ${netRate_adhoc}
            Should Be Equal As Strings  ${resp.json()[${i}]['templateUid']}  ${templateUid}
            Should Be Equal As Strings  ${resp.json()[${i}]['status']}             ${toggle[0]}    
        END
    
    END 

JD-TC-Get Invoice Template Using Account-UH1

    [Documentation]   Get Invoice Template Using Account without login

    ${resp}=   Get InvoiceTemplates by account  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings    ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-Get Invoice Template Using Account-3

    [Documentation]   Remove one invoice template and Get Invoice Template Using Account


    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Remove Invoice Template   ${templateUid7}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get InvoiceTemplates by account  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

     ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1
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

JD-TC-Get Invoice Template Using Account-UH2

    [Documentation]   Remove remaining invoice template and Get Invoice Template Using Account


    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Remove Invoice Template   ${templateUid}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get InvoiceTemplates by account  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  []

