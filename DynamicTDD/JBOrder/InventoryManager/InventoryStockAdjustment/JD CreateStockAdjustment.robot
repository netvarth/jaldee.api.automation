*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        STORE 
Library           Collections
Library           String
Library           json
Library           DateTime
Library           requests
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/hl_musers.py
Resource          /ebs/TDD/SuperAdminKeywords.robot

*** Variables ***
${invalidNum}        1245
${invalidEma}        asd122
${invalidstring}     _ad$.sa_

*** Keywords ***
Create Stock Adjustment

    [Arguments]  ${location}   ${store_encId}  ${catalog_encId}  ${remarks_encId}   @{vargs}
    Check And Create YNW Session
    ${store}=  Create Dictionary   encId=${store_encId}   
    ${catalogDto}=  Create Dictionary   encId=${catalog_encId} 
    ${inventoryRemarkDto}=  Create Dictionary   encId=${remarks_encId} 

    ${len}=  Get Length  ${vargs}
    ${stockAdjustDetailsDtos}=  Create List  

    FOR    ${index}    IN RANGE    ${len}   
        Exit For Loop If  ${len}==0
        Append To List  ${stockAdjustDetailsDtos}  ${vargs[${index}]}

    END
    ${data}=  Create Dictionary   location=${location}  store=${store}    catalogDto=${catalogDto}    inventoryRemarkDto=${inventoryRemarkDto}   stockAdjustDetailsDtos=${stockAdjustDetailsDtos}
    ${data}=    json.dumps    ${data}  
    ${resp}=  POST On Session  ynw  /provider/inventory/stockadjust   data=${data}  expected_status=any
    RETURN  ${resp} 

*** Test Cases ***

JD-TC-Create Stock Adjustment-1

    [Documentation]  Create stock adjustment with valid details.

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Store Type By Filter     
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${TypeName}=    FakerLibrary.name
    Set Suite Variable  ${TypeName}

    ${resp}=  Create Store Type   ${TypeName}    ${storeNature[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${St_Id}    ${resp.json()}
    sleep  02s
    ${TypeName1}=    FakerLibrary.name
    Set Suite Variable  ${TypeName1}

    ${resp}=  Create Store Type   ${TypeName1}    ${storeNature[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${St_Id1}    ${resp.json()}
    sleep  02s
    ${TypeName2}=    FakerLibrary.name
    Set Suite Variable  ${TypeName2}

    ${resp}=  Create Store Type   ${TypeName2}    ${storeNature[2]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${St_Id2}    ${resp.json()}

    ${resp}=  Get Store Type By EncId   ${St_Id}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['name']}    ${TypeName}
    Should Be Equal As Strings    ${resp.json()['storeNature']}    ${storeNature[0]}
    Should Be Equal As Strings    ${resp.json()['encId']}    ${St_Id}

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${accountId}=  get_acc_id  ${HLMUSERNAME1}
    Set Suite Variable    ${accountId} 

    ${resp}=  Provide Get Store Type By EncId     ${St_Id}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['name']}    ${TypeName}
    Should Be Equal As Strings    ${resp.json()['storeNature']}    ${storeNature[0]}
    Should Be Equal As Strings    ${resp.json()['encId']}    ${St_Id}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId1}=  Create Sample Location
        ${resp}=   Get Location ById  ${locId1}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ELSE
        Set Suite Variable  ${locId1}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END

    ${Name}=    FakerLibrary.last name
    ${PhoneNumber}=  Evaluate  ${PUSERNAME}+100187748
    Set Test Variable  ${email_id}  ${Name}${PhoneNumber}.${test_mail}
    ${email}=  Create List  ${email_id}

    ${resp}=  Create Store   ${Name}  ${St_Id}    ${locId1}  ${email}     ${PhoneNumber}  ${countryCodes[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${store_id}  ${resp.json()}


    ${resp}=  Create Inventory Catalog   ${Name}  ${store_id}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${inventory_catalog_encid}  ${resp.json()}

    ${resp}=  Get Inventory Catalog By EncId   ${inventory_catalog_encid}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${displayName}=     FakerLibrary.name

    ${resp}=    Create Item Inventory  ${displayName}    
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${itemEncId1}  ${resp.json()}

    ${categoryName}=    FakerLibrary.name
    Set Suite Variable  ${categoryName}

    ${resp}=  Create Item Category   ${categoryName}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${Ca_Id}    ${resp.json()}

    ${resp}=    Create Item Inventory  ${categoryName}   categoryCode=${Ca_Id} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${itemEncIds}  ${resp.json()}


    ${resp}=   Create Inventory Catalog Item  ${inventory_catalog_encid}   ${itemEncId1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${inventory_catalog_item_encid}  ${resp.json()[0]}

    ${remarks}=    FakerLibrary.name
    Set Suite Variable  ${remarks}

    ${resp}=  Create Item Remarks   ${remarks}  ${transactionTypeEnum[1]}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${remarks_encid1}  ${resp.json()}

    ${quantity}=   Random Int  min=5  max=10
    ${quantity}=  Convert To Number  ${quantity}  1
    ${data}=  Create Dictionary   invCatalogId=${inventory_catalog_encid}   invCatalogItemId=${inventory_catalog_item_encid}    qty=${quantity}    
    Set Suite Variable  ${data}  
    ${resp}=  Create Stock Adjustment   ${locId1}  ${store_id}   ${inventory_catalog_encid}   ${remarks_encid1}      ${data} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Set Suite Variable  ${remarks_encid1}  ${resp.json()}

JD-TC-Create Stock Adjustment-2

    [Documentation]  Create stock adjustment with multiple stockAdjustDetailsDtos.

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${quantity}=   Random Int  min=5  max=10
    ${quantity}=  Convert To Number  ${quantity}  1
    ${data1}=  Create Dictionary   invCatalogId=${inventory_catalog_encid}   invCatalogItemId=${inventory_catalog_item_encid}    qty=${quantity}    

    ${resp}=  Create Stock Adjustment   ${locId1}  ${store_id}   ${inventory_catalog_encid}   ${remarks_encid1}      ${data}   ${data1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Create Stock Adjustment-3

    [Documentation]  Create stock adjustment thats already created.

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  Create Stock Adjustment   ${locId1}  ${store_id}   ${inventory_catalog_encid}   ${remarks_encid1}      ${data}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200



JD-TC-Create Stock Adjustment-UH1

    [Documentation]  Create stock adjustment without login

    ${resp}=  Create Stock Adjustment   ${locId1}  ${store_id}   ${inventory_catalog_encid}   ${remarks_encid1}      ${data}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-Create Stock Adjustment-UH2

    [Documentation]  Create stock adjustment with empty store id.

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  Create Stock Adjustment   ${locId1}  ${EMPTY}   ${inventory_catalog_encid}   ${remarks_encid1}      ${data}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422

JD-TC-Create Stock Adjustment-UH3

    [Documentation]  Create stock adjustment with empty inventory_catalog_encid.

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  Create Stock Adjustment   ${locId1}  ${store_id}   ${EMPTY}   ${remarks_encid1}      ${data}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422

JD-TC-Create Stock Adjustment-UH4

    [Documentation]  Create stock adjustment with empty remarks_encid1.

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  Create Stock Adjustment   ${locId1}  ${store_id}   ${inventory_catalog_encid}   ${EMPTY}      ${data}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422

JD-TC-Create Stock Adjustment-UH5

    [Documentation]  Create stock adjustment with empty quantity.

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${data1}=  Create Dictionary   invCatalogId=${inventory_catalog_encid}   invCatalogItemId=${inventory_catalog_item_encid}    qty=${EMPTY}    

    ${resp}=  Create Stock Adjustment   ${locId1}  ${store_id}   ${inventory_catalog_encid}   ${remarks_encid1}      ${data1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422



