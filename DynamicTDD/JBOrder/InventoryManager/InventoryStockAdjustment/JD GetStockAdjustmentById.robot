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


*** Test Cases ***

JD-TC-Get Stock Adjustment By Id-1

    [Documentation]  create stock adjustment and get stock adjustment by id.

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME11}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  ${resp.json()['enableInventory']}==${bool[0]}
        ${resp1}=  Enable Disable Inventory  ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

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

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME11}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${accountId}=  get_acc_id  ${HLMUSERNAME11}
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
        Set Suite Variable  ${place}  ${resp.json()[0]['place']}
    ELSE
        Set Suite Variable  ${locId1}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
        Set Suite Variable  ${place}  ${resp.json()[0]['place']}
    END

    ${Name}=    FakerLibrary.last name
    Set Suite Variable  ${Name}

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
    Set Suite Variable  ${quantity}  
    ${data}=  Create Dictionary   invCatalogId=${inventory_catalog_encid}   invCatalogItemId=${inventory_catalog_item_encid}    qty=${quantity}    
    Set Suite Variable  ${data}  
    ${resp}=  Create Stock Adjustment   ${locId1}  ${store_id}   ${inventory_catalog_encid}   ${remarks_encid1}      ${data} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${uid}  ${resp.json()}

    ${resp}=  Get Stock Adjustment By Id  ${uid}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['uid']}    ${uid} 
    Should Be Equal As Strings    ${resp.json()['location']}    ${locId1}     
    Should Be Equal As Strings    ${resp.json()['locationName']}   ${place}
    Should Be Equal As Strings    ${resp.json()['remark']}     ${remarks}
    Should Be Equal As Strings    ${resp.json()['invStatus']}     ${couponStatus[0]}
    Should Be Equal As Strings    ${resp.json()['store']['name']}    ${Name}
    Should Be Equal As Strings    ${resp.json()['store']['encId']}    ${store_id}
    Should Be Equal As Strings    ${resp.json()['catalogDto']['encId']}    ${inventory_catalog_encid}
    Should Be Equal As Strings    ${resp.json()['catalogDto']['status']}    ${InventoryCatalogStatus[0]}
    Should Be Equal As Strings    ${resp.json()['inventoryRemarkDto']['encId']}    ${remarks_encid1}
    Should Be Equal As Strings    ${resp.json()['inventoryRemarkDto']['transactionTypeEnum']}    ${transactionTypeEnum[1]}
    Should Be Equal As Strings    ${resp.json()['inventoryRemarkDto']['remark']}    ${remarks}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['invCatalogId']}    ${inventory_catalog_encid}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['invCatalogItemId']}    ${inventory_catalog_item_encid}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['qty']}    ${quantity}


JD-TC-Get Stock Adjustment By Id-2

    [Documentation]  update stock adjustment by adding more  stockAdjustDetailsDtos then get stock adjustment by id

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME11}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${quantity1}=   Random Int  min=5  max=10
    ${quantity1}=  Convert To Number  ${quantity1}  1
    ${data1}=  Create Dictionary   invCatalogId=${inventory_catalog_encid}   invCatalogItemId=${inventory_catalog_item_encid}    qty=${quantity1}    

    ${quantity2}=   Random Int  min=10  max=15
    ${quantity2}=  Convert To Number  ${quantity2}  1
    ${data2}=  Create Dictionary   invCatalogId=${inventory_catalog_encid}   invCatalogItemId=${inventory_catalog_item_encid}    qty=${quantity2}   

    ${resp}=  Update Stock Adjustment  ${uid}   ${locId1}  ${store_id}   ${inventory_catalog_encid}   ${remarks_encid1}      ${data}   ${data1}   ${data2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${resp}=  Get Stock Adjustment By Id  ${uid}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['uid']}    ${uid} 
    Should Be Equal As Strings    ${resp.json()['location']}    ${locId1}     
    Should Be Equal As Strings    ${resp.json()['locationName']}   ${place}
    Should Be Equal As Strings    ${resp.json()['remark']}     ${remarks}
    Should Be Equal As Strings    ${resp.json()['invStatus']}     ${couponStatus[0]}
    Should Be Equal As Strings    ${resp.json()['store']['name']}    ${Name}
    Should Be Equal As Strings    ${resp.json()['store']['encId']}    ${store_id}
    Should Be Equal As Strings    ${resp.json()['catalogDto']['encId']}    ${inventory_catalog_encid}
    Should Be Equal As Strings    ${resp.json()['catalogDto']['status']}    ${InventoryCatalogStatus[0]}
    Should Be Equal As Strings    ${resp.json()['inventoryRemarkDto']['encId']}    ${remarks_encid1}
    Should Be Equal As Strings    ${resp.json()['inventoryRemarkDto']['transactionTypeEnum']}    ${transactionTypeEnum[1]}
    Should Be Equal As Strings    ${resp.json()['inventoryRemarkDto']['remark']}    ${remarks}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['invCatalogId']}    ${inventory_catalog_encid}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['invCatalogItemId']}    ${inventory_catalog_item_encid}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['qty']}    ${quantity}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][1]['invCatalogId']}    ${inventory_catalog_encid}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][1]['invCatalogItemId']}    ${inventory_catalog_item_encid}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][1]['qty']}    ${quantity1}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][2]['invCatalogId']}    ${inventory_catalog_encid}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][2]['invCatalogItemId']}    ${inventory_catalog_item_encid}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][2]['qty']}    ${quantity2}



JD-TC-Get Stock Adjustment By Id-UH1

    [Documentation]  Get stock adjustment By Id without login

    ${resp}=  Get Stock Adjustment By Id  ${uid}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-Get Stock Adjustment By Id-UH2

    [Documentation]  Get stock adjustment By Id with invalid id.

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME11}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Stock Adjustment By Id  ${locId1}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    # Should Be Equal As Strings   ${resp.json()}   ${INVALID_STORE_ID}
    




