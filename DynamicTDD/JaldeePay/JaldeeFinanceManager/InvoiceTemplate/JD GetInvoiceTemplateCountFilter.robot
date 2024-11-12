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

JD-TC-Get InvoiceTemplate CountFilter-1

    [Documentation]  create one Invoice Template andGet InvoiceTemplate Count Filter   .


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


    ${resp}=   Get InvoiceTemplate Count Filter
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

JD-TC-Get InvoiceTemplate CountFilter-2

    [Documentation]   Get InvoiceTemplate Count Filter using template name   .

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=   Get InvoiceTemplate Count Filter   templateName-eq=${name1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

JD-TC-Get InvoiceTemplate CountFilter-3

    [Documentation]   Get InvoiceTemplate Count Filter using accountid   .

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=   Get InvoiceTemplate Count Filter    accountId-eq=${account_id}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

JD-TC-Get InvoiceTemplate CountFilter-4

    [Documentation]   Get InvoiceTemplate Count Filter using accountid   .

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=   Get InvoiceTemplate Count Filter    accountId-eq=${account_id}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

JD-TC-Get InvoiceTemplate CountFilter-5

    [Documentation]   Get InvoiceTemplate Count Filter using accountid   .

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=   Get InvoiceTemplate Count Filter    accountId-eq=${account_id}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1
JD-TC-Get InvoiceTemplate CountFilter-6

    [Documentation]   Get InvoiceTemplate Count Filter using accountid   .

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=   Get InvoiceTemplate Count Filter    accountId-eq=${account_id}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1


JD-TC-Get InvoiceTemplate CountFilter-7

    [Documentation]   Get InvoiceTemplate Count Filter using userId   .

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable      ${userId}          ${decrypted_data['id']}
    Set Suite Variable      ${userName}      ${decrypted_data['userName']}


    ${resp}=   Get InvoiceTemplate Count Filter    userId-eq=${userId}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

JD-TC-Get InvoiceTemplate CountFilter-8

    [Documentation]   Get InvoiceTemplate Count Filter using allowToUseOtherUsers   .

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200



    ${resp}=   Get InvoiceTemplate Count Filter    allowToUseOtherUsers-eq=${bool[0]}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

JD-TC-Get InvoiceTemplate CountFilter-9

    [Documentation]   Get InvoiceTemplate Count Filter using userName   .

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200



    ${resp}=   Get InvoiceTemplate Count Filter    userName-eq=${userName}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

JD-TC-Get InvoiceTemplate CountFilter-10

    [Documentation]   Get InvoiceTemplate Count Filter using templateUid   .

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200



    ${resp}=   Get InvoiceTemplate Count Filter    templateUid-eq=${templateUid}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1


JD-TC-Get InvoiceTemplate CountFilter-11

    [Documentation]   Get InvoiceTemplate Count Filter using invoiceCategoryId   .

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200



    ${resp}=   Get InvoiceTemplate Count Filter    invoiceCategoryId-eq=${category_id2}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

JD-TC-Get InvoiceTemplate CountFilter-12

    [Documentation]   Get InvoiceTemplate Count Filter using invoiceStatusId   .

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200



    ${resp}=   Get InvoiceTemplate Count Filter    invoiceStatus-eq=${status_id1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

JD-TC-Get InvoiceTemplate CountFilter-13

    [Documentation]   Get InvoiceTemplate Count Filter using status   .

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200



    ${resp}=   Get InvoiceTemplate Count Filter    status-eq=${toggle[0]}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

JD-TC-Get InvoiceTemplate CountFilter-14

    [Documentation]   Get InvoiceTemplate Count Filter using invoiceLabel   .

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200



    ${resp}=   Get InvoiceTemplate Count Filter    invoiceLabel-eq=${New_status[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

JD-TC-Get InvoiceTemplate CountFilter-15

    [Documentation]   Get InvoiceTemplate Count Filter using locationId   .

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200



    ${resp}=   Get InvoiceTemplate Count Filter    locationId-eq=${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1

JD-TC-Get InvoiceTemplate CountFilter-16

    [Documentation]   Get InvoiceTemplate Count Filter using createdDate   .

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200



    ${resp}=   Get InvoiceTemplate Count Filter    createdDate-eq=${DAY1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1


JD-TC-Get InvoiceTemplate CountFilter-UH1

    [Documentation]   Get InvoiceTemplate Filte without login

    ${resp}=   Get InvoiceTemplate Count Filter
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings    ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-Get InvoiceTemplate CountFilter-17

    [Documentation]   update invoice template and Get InvoiceTemplate Filte


    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=   FakerLibrary.word
    ${resp}=  Update Invoice Template    ${templateUid}  ${name2}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=   Get InvoiceTemplate Count Filter    templateName-eq=${name2}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1
JD-TC-Get InvoiceTemplate CountFilter-UH2

    [Documentation]   Get InvoiceTemplate Count Filter using invalid template name


    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=   Get InvoiceTemplate Count Filter    templateName-eq=${name1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()}  0


