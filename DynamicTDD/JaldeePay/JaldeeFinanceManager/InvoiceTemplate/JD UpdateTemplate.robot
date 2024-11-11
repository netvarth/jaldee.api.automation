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

JD-TC-Update Invoice Template-1

    [Documentation]  Update Invoice Template using all data.


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
    ${resp}=  Create Category   ${name1}  ${categoryType[3]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${category_id2}   ${resp.json()}

    ${resp}=  Create Finance Status   ${New_status[0]}  ${categoryType[3]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${status_id1}   ${resp.json()}



    ${SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500

    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${service_duration}  ${bool[0]}  ${servicecharge}  ${bool[1]}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sid1}  ${resp.json()} 


    ${quantity}=   Random Int  min=5  max=10
    ${quantity}=  Convert To Number  ${quantity}  1
    ${serviceprice}=   Random Int  min=100  max=500
    ${serviceprice}=  Convert To Number  ${serviceprice}  1
    ${netRate}=  Evaluate  ${quantity} * ${serviceprice}

    ${serviceList}=  Create Dictionary  serviceId=${sid1}   quantity=${quantity}   price=${serviceprice} 
    ${serviceList}=    Create List    ${serviceList}

    ${itemName}=    FakerLibrary.word
    ${price}=   Random Int  min=10  max=15
    ${price}=  Convert To Number  ${price}  1
    ${adhocItemList}=  Create Dictionary  itemName=${itemName}   quantity=${quantity}   price=${price}
    ${adhocItemList}=    Create List    ${adhocItemList}



    ${item}=   FakerLibrary.word
    ${itemCode1}=     FakerLibrary.word
    ${resp}=  Create Sample Item   ${DisplayName1}   ${item}  ${itemCode1}  ${price}  ${bool[0]} 
    Log  ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${itemId1}   ${resp.json()} 

    ${rate}=   Random Int  min=50  max=1000
    ${amount}=   Random Int  min=50  max=1000
    ${amount}=  Convert To Number  ${amount}  1


    ${itemList}=  Create Dictionary  itemId=${itemId1}   quantity=${quantity}  rate=${rate}    amount=${amount}
    ${itemList}=    Create List    ${itemList}


    ${resp}=  Create Invoice Template   ${name1}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${templateUid}   ${resp.json()['templateUid']}


    ${resp}=  Update Invoice Template    ${templateUid}   ${name1}   invoiceLabel=${New_status[0]}   categoryId=${category_id2}   statusId=${status_id1}    serviceList=${serviceList}   adhocItemList=${adhocItemList}   itemList=${itemList}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get InvoiceTemplate By Uid  ${templateUid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['templateUid']}  ${templateUid}


JD-TC-Update Invoice Template-2

    [Documentation]   Update Invoice Template using template name only


    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name1}=   FakerLibrary.word
    ${resp}=  Update Invoice Template    ${templateUid}  ${name1}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=   Get InvoiceTemplate By Uid  ${templateUid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['templateUid']}  ${templateUid}
    Should Be Equal As Strings  ${resp.json()['templateName']}  ${name1}

JD-TC-Update Invoice Template-UH1

    [Documentation]   Update Invoice Template using invalid status id


    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Create Finance Status   ${New_status[0]}  ${categoryType[1]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${status_id1}   ${resp.json()}

    ${INVALID_FIELD}=  format String   ${INVALID_FIELD}   Invoice Status Id

    ${name1}=   FakerLibrary.word
    ${resp}=  Update Invoice Template    ${templateUid}  ${name1}      statusId=${status_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${INVALID_FIELD}

JD-TC-Update Invoice Template-UH2

    [Documentation]   Update Invoice Template using invalid category id


    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Create Finance Status   ${New_status[1]}  ${categoryType[1]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${status_id1}   ${resp.json()}


    ${name1}=   FakerLibrary.word

    ${resp}=  Create Category   ${name1}  ${categoryType[1]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${category_id2}   ${resp.json()}

    ${INVALID_FIELD}=  format String   ${INVALID_FIELD}   Invoice Category Id

    ${resp}=  Update Invoice Template    ${templateUid}  ${name1}      categoryId=${category_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${INVALID_FIELD}




JD-TC-Update Invoice Template-3

    [Documentation]   Update Invoice Template using invoice label is empty


    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name1}=   FakerLibrary.word
    ${resp}=  Update Invoice Template    ${templateUid}  ${name1}      invoiceLabel=${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get InvoiceTemplate By Uid  ${templateUid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['templateUid']}  ${templateUid}
    Should Be Equal As Strings  ${resp.json()['templateName']}  ${name1}
    Should Be Equal As Strings  ${resp.json()['invoiceLabel']}  ${EMPTY}

JD-TC-Update Invoice Template-4

    [Documentation]   Update Invoice Template using empty service list


    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${serviceList}=    Create List    
    ${name1}=   FakerLibrary.word
    ${resp}=  Update Invoice Template    ${templateUid}  ${name1}    serviceList=${serviceList}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get InvoiceTemplate By Uid  ${templateUid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['serviceList']}  []


JD-TC-Update Invoice Template-5

    [Documentation]   Update Invoice Template using empty adhoc item list


    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${adhocItemList}=    Create List    
    ${name1}=   FakerLibrary.word
    ${resp}=  Update Invoice Template    ${templateUid}  ${name1}    adhocItemList=${adhocItemList}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=   Get InvoiceTemplate By Uid  ${templateUid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['adhocItemList']}  []

JD-TC-Update Invoice Template-6

    [Documentation]   Update Invoice Template using empty item list


    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${itemList}=    Create List    
    ${name1}=   FakerLibrary.word
    ${resp}=  Update Invoice Template    ${templateUid}  ${name1}    itemList=${itemList}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get InvoiceTemplate By Uid  ${templateUid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemList']}  []

JD-TC-Update Invoice Template-UH3

    [Documentation]   Update Invoice Template using invalid template name


    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${INVALID_FIELD}=  format String   ${INVALID_FIELD}   template name
    ${resp}=  Update Invoice Template    ${templateUid}  ${EMPTY}      
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${INVALID_FIELD}




JD-TC-Update Invoice Template-UH4

    [Documentation]   Update Invoice Template using invalid template name


    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${INVALID_FIELD}=  format String   ${INVALID_FIELD}   template name
    ${resp}=  Update Invoice Template    ${templateUid}  ${NULL}      
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${INVALID_FIELD}




