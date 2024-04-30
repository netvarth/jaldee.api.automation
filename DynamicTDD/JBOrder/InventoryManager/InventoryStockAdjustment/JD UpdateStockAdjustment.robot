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

JD-TC-Update Stock Adjustment-1

    [Documentation]  update stock adjustment with same details.
    comment  NOTE-------------UPDATE STOCK ADJUSTMENT ---WE CAN ONLY UPDATE REMARKS AND STOCK ADJUSTMENT DTO
    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME12}  ${PASSWORD}
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

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME12}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${accountId}=  get_acc_id  ${HLMUSERNAME12}
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

    ${resp}=    Get Item Inventory  ${itemEncId1}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200
    Set Suite Variable         ${spitem_name}  ${resp.json()['name']}     
    Set Suite Variable         ${spitem_id}  ${resp.json()['id']}     
    Set Suite Variable         ${spitem_itemSourceEnum}  ${resp.json()['itemSourceEnum']}                                  
    Set Suite Variable         ${spitem_isInventoryItem}  ${resp.json()['isInventoryItem']}      
    Set Suite Variable         ${spitem_isBatchApplicable}  ${resp.json()['isBatchApplicable']}                                                                                           
    Set Suite Variable         ${spitem_status}  ${resp.json()['status']} 


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
    ${invCatalog}=  Create Dictionary   encId=${inventory_catalog_encid} 
    ${invCatalogItem}=  Create Dictionary   encId=${inventory_catalog_item_encid} 
    ${data}=  Create Dictionary   invCatalog=${invCatalog}   invCatalogItem=${invCatalogItem}    qty=${quantity}    
    Set Suite Variable  ${data}  
    ${resp}=  Create Stock Adjustment   ${locId1}  ${store_id}   ${inventory_catalog_encid}   ${remarks_encid1}      ${data} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${uid}  ${resp.json()}

    ${resp}=  Update Stock Adjustment  ${uid}    ${locId1}  ${store_id}   ${inventory_catalog_encid}   ${remarks_encid1}      ${data} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Stock Adjustment By Id  ${uid}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['uid']}    ${uid} 
    Should Be Equal As Strings    ${resp.json()['location']}    ${locId1}    
    Should Be Equal As Strings    ${resp.json()['locationName']}    ${place}   
    Should Be Equal As Strings    ${resp.json()['remark']}     ${remarks}
    Should Be Equal As Strings    ${resp.json()['invStatus']}     ${couponStatus[0]}
    Should Be Equal As Strings    ${resp.json()['store']['name']}    ${Name}
    Should Be Equal As Strings    ${resp.json()['store']['encId']}    ${store_id}
    Should Be Equal As Strings    ${resp.json()['catalogDto']['encId']}    ${inventory_catalog_encid}
    Should Be Equal As Strings    ${resp.json()['catalogDto']['status']}    ${InventoryCatalogStatus[0]}
    Should Be Equal As Strings    ${resp.json()['inventoryRemarkDto']['encId']}    ${remarks_encid1}
    Should Be Equal As Strings    ${resp.json()['inventoryRemarkDto']['transactionTypeEnum']}    ${transactionTypeEnum[1]}
    Should Be Equal As Strings    ${resp.json()['inventoryRemarkDto']['remark']}    ${remarks}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['invCatalog']['encId']}    ${inventory_catalog_encid}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['invCatalog']['catalogName']}    ${Name}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['invCatalogItem']['encId']}    ${inventory_catalog_item_encid}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['qty']}    ${quantity}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['spItem']['id']}    ${spitem_id}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['spItem']['itemSourceEnum']}    ${spitem_itemSourceEnum}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['spItem']['spCode']}    ${itemEncId1}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['spItem']['name']}    ${spitem_name}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['spItem']['isInventoryItem']}    ${spitem_isInventoryItem}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['spItem']['isBatchApplicable']}    ${spitem_isBatchApplicable}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['spItem']['status']}    ${spitem_status}



JD-TC-Update Stock Adjustment-2

    [Documentation]  Create stock adjustment with multiple stockAdjustDetailsDtos. then update stock adjustment by adding one more  stockAdjustDetailsDtos

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME12}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${quantity2}=   Random Int  min=5  max=10
    ${quantity2}=  Convert To Number  ${quantity}  1
    ${invCatalog}=  Create Dictionary   encId=${inventory_catalog_encid} 
    ${invCatalogItem}=  Create Dictionary   encId=${inventory_catalog_item_encid} 
    ${data1}=  Create Dictionary   invCatalog=${invCatalog}   invCatalogItem=${invCatalogItem}    qty=${quantity2}    
    Set Suite Variable  ${data1}  
   

    ${resp}=  Create Stock Adjustment   ${locId1}  ${store_id}   ${inventory_catalog_encid}   ${remarks_encid1}      ${data}   ${data1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${uid1}  ${resp.json()}

    ${quantity1}=   Random Int  min=10  max=15
    ${quantity1}=  Convert To Number  ${quantity1}  1
    ${invCatalog}=  Create Dictionary   encId=${inventory_catalog_encid} 
    ${invCatalogItem}=  Create Dictionary   encId=${inventory_catalog_item_encid} 
    ${data2}=  Create Dictionary   invCatalog=${invCatalog}   invCatalogItem=${invCatalogItem}    qty=${quantity1}   


    ${resp}=  Update Stock Adjustment  ${uid1}   ${locId1}  ${store_id}   ${inventory_catalog_encid}   ${remarks_encid1}      ${data}   ${data1}   ${data2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200 
    ${resp}=  Get Stock Adjustment By Id  ${uid1}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['uid']}    ${uid1} 
    Should Be Equal As Strings    ${resp.json()['location']}    ${locId1}    
    Should Be Equal As Strings    ${resp.json()['locationName']}    ${place}   
    Should Be Equal As Strings    ${resp.json()['remark']}     ${remarks}
    Should Be Equal As Strings    ${resp.json()['invStatus']}     ${couponStatus[0]}
    Should Be Equal As Strings    ${resp.json()['store']['name']}    ${Name}
    Should Be Equal As Strings    ${resp.json()['store']['encId']}    ${store_id}
    Should Be Equal As Strings    ${resp.json()['catalogDto']['encId']}    ${inventory_catalog_encid}
    Should Be Equal As Strings    ${resp.json()['catalogDto']['status']}    ${InventoryCatalogStatus[0]}
    Should Be Equal As Strings    ${resp.json()['inventoryRemarkDto']['encId']}    ${remarks_encid1}
    Should Be Equal As Strings    ${resp.json()['inventoryRemarkDto']['transactionTypeEnum']}    ${transactionTypeEnum[1]}
    Should Be Equal As Strings    ${resp.json()['inventoryRemarkDto']['remark']}    ${remarks}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['invCatalog']['encId']}    ${inventory_catalog_encid}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['invCatalog']['catalogName']}    ${Name}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['invCatalogItem']['encId']}    ${inventory_catalog_item_encid}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['qty']}    ${quantity}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['spItem']['id']}    ${spitem_id}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['spItem']['itemSourceEnum']}    ${spitem_itemSourceEnum}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['spItem']['spCode']}    ${itemEncId1}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['spItem']['name']}    ${spitem_name}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['spItem']['isInventoryItem']}    ${spitem_isInventoryItem}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['spItem']['isBatchApplicable']}    ${spitem_isBatchApplicable}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['spItem']['status']}    ${spitem_status}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][1]['invCatalog']['encId']}    ${inventory_catalog_encid}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][1]['invCatalog']['catalogName']}    ${Name}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][1]['invCatalogItem']['encId']}    ${inventory_catalog_item_encid}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][1]['spItem']['id']}    ${spitem_id}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][1]['spItem']['itemSourceEnum']}    ${spitem_itemSourceEnum}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][1]['spItem']['spCode']}    ${itemEncId1}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][1]['spItem']['name']}    ${spitem_name}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][1]['spItem']['isInventoryItem']}    ${spitem_isInventoryItem}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][1]['spItem']['isBatchApplicable']}    ${spitem_isBatchApplicable}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][1]['spItem']['status']}    ${spitem_status}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][1]['qty']}    ${quantity2}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][2]['invCatalog']['encId']}    ${inventory_catalog_encid}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][2]['invCatalog']['catalogName']}    ${Name}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][2]['invCatalogItem']['encId']}    ${inventory_catalog_item_encid}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][2]['spItem']['id']}    ${spitem_id}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][2]['spItem']['itemSourceEnum']}    ${spitem_itemSourceEnum}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][2]['spItem']['spCode']}    ${itemEncId1}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][2]['spItem']['name']}    ${spitem_name}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][2]['spItem']['isInventoryItem']}    ${spitem_isInventoryItem}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][2]['spItem']['isBatchApplicable']}    ${spitem_isBatchApplicable}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][2]['spItem']['status']}    ${spitem_status}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][2]['qty']}    ${quantity1}



JD-TC-Update Stock Adjustment-3

    [Documentation]  create one remarks and update stock adjustment

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME12}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${remarks1}=    FakerLibrary.name
    Set Suite Variable  ${remarks1}

    ${resp}=  Create Item Remarks   ${remarks1}  ${transactionTypeEnum[1]}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${remarks_encid2}  ${resp.json()}


    ${resp}=  Update Stock Adjustment  ${uid1}   ${locId1}  ${store_id}   ${inventory_catalog_encid}   ${remarks_encid2}      ${data}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${resp}=  Get Stock Adjustment By Id  ${uid1}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['uid']}    ${uid1} 
    Should Be Equal As Strings    ${resp.json()['location']}    ${locId1}    
    Should Be Equal As Strings    ${resp.json()['locationName']}    ${place}   
    Should Be Equal As Strings    ${resp.json()['remark']}     ${remarks1}
    Should Be Equal As Strings    ${resp.json()['invStatus']}     ${couponStatus[0]}
    Should Be Equal As Strings    ${resp.json()['store']['name']}    ${Name}
    Should Be Equal As Strings    ${resp.json()['store']['encId']}    ${store_id}
    Should Be Equal As Strings    ${resp.json()['catalogDto']['encId']}    ${inventory_catalog_encid}
    Should Be Equal As Strings    ${resp.json()['catalogDto']['status']}    ${InventoryCatalogStatus[0]}
    Should Be Equal As Strings    ${resp.json()['inventoryRemarkDto']['encId']}    ${remarks_encid2}
    Should Be Equal As Strings    ${resp.json()['inventoryRemarkDto']['transactionTypeEnum']}    ${transactionTypeEnum[1]}
    Should Be Equal As Strings    ${resp.json()['inventoryRemarkDto']['remark']}    ${remarks1}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['invCatalog']['encId']}    ${inventory_catalog_encid}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['invCatalog']['catalogName']}    ${Name}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['invCatalogItem']['encId']}    ${inventory_catalog_item_encid}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['qty']}    ${quantity}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['spItem']['id']}    ${spitem_id}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['spItem']['itemSourceEnum']}    ${spitem_itemSourceEnum}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['spItem']['spCode']}    ${itemEncId1}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['spItem']['name']}    ${spitem_name}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['spItem']['isInventoryItem']}    ${spitem_isInventoryItem}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['spItem']['isBatchApplicable']}    ${spitem_isBatchApplicable}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['spItem']['status']}    ${spitem_status}

JD-TC-Update Stock Adjustment-UH1

    [Documentation]  update stock adjustment without login

    ${resp}=  Update Stock Adjustment  ${uid}    ${locId1}  ${store_id}   ${inventory_catalog_encid}   ${remarks_encid1}      ${data} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-Update Stock Adjustment-UH2

    [Documentation]  update stock adjustment with empty store id.

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME12}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  Update Stock Adjustment  ${uid}    ${locId1}  ${EMPTY}   ${inventory_catalog_encid}   ${remarks_encid1}      ${data} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}   ${INVALID_STORE_ID}
    

JD-TC-Update Stock Adjustment-UH3

    [Documentation]  Update stock adjustment with empty inventory_catalog_encid.

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME12}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Update Stock Adjustment  ${uid}    ${locId1}  ${store_id}   ${EMPTY}   ${remarks_encid1}      ${data} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}   ${CAP_Invalid_Catalog_id}
    

JD-TC-Update Stock Adjustment-UH4

    [Documentation]  Update stock adjustment with empty remarks_encid1.

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME12}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  Update Stock Adjustment  ${uid}    ${locId1}  ${store_id}   ${inventory_catalog_encid}   ${EMPTY}      ${data} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}   ${INVALID_REMARKS_ID}

JD-TC-Update Stock Adjustment-UH5

    [Documentation]  update stock adjustment with empty quantity.

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME12}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${invCatalog}=  Create Dictionary   encId=${inventory_catalog_encid} 
    ${invCatalogItem}=  Create Dictionary   encId=${inventory_catalog_item_encid} 
    ${data1}=  Create Dictionary   invCatalog=${invCatalog}   invCatalogItem=${invCatalogItem}    qty=${EMPTY}     

    ${resp}=  Update Stock Adjustment  ${uid}    ${locId1}  ${store_id}   ${inventory_catalog_encid}   ${remarks_encid1}      ${data1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings   ${resp.json()}   ${INVALID_QUANTITY}



