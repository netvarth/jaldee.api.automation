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
Variables         /ebs/TDD/varfiles/hl_providers.py
Resource          /ebs/TDD/SuperAdminKeywords.robot

*** Variables ***
${invalidNum}        1245
${invalidEma}        asd122
${invalidstring}     _ad$.sa_


*** Test Cases ***

JD-TC-Get Stock Adjustment By Id-1

    [Documentation]  create stock adjustment and get stock adjustment by id.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME11}  ${PASSWORD}
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
    sleep  02s
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

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME11}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${accountId}=  get_acc_id  ${HLPUSERNAME11}
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
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
        Set Suite Variable  ${place}  ${resp.json()[0]['place']}
    ELSE
        Set Suite Variable  ${locId1}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
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

    ${resp}=    Create Item Inventory  ${displayName}    isInventoryItem=${bool[1]} 
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

    ${resp}=    Create Item Inventory  ${categoryName}   categoryCode=${Ca_Id}   isInventoryItem=${bool[1]} 
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
    # Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['spItem']['isInventoryItem']}    ${spitem_isInventoryItem}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['spItem']['isBatchApplicable']}    ${spitem_isBatchApplicable}
    # Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['spItem']['status']}    ${spitem_status}



JD-TC-Get Stock Adjustment By Id-2

    [Documentation]  update stock adjustment by adding more  stockAdjustDetailsDtos then get stock adjustment by id

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME11}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${quantity1}=   Random Int  min=5  max=10
    ${quantity1}=  Convert To Number  ${quantity1}  1
    ${invCatalog}=  Create Dictionary   encId=${inventory_catalog_encid} 
    ${invCatalogItem}=  Create Dictionary   encId=${inventory_catalog_item_encid} 
    ${data1}=  Create Dictionary   invCatalog=${invCatalog}   invCatalogItem=${invCatalogItem}    qty=${quantity1}   
  

    ${quantity2}=   Random Int  min=10  max=15
    ${quantity2}=  Convert To Number  ${quantity2}  1
    ${data2}=  Create Dictionary   invCatalog=${invCatalog}   invCatalogItem=${invCatalogItem}    qty=${quantity2}    

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
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['invCatalog']['encId']}    ${inventory_catalog_encid}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['invCatalog']['catalogName']}    ${Name}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['invCatalogItem']['encId']}    ${inventory_catalog_item_encid}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['spItem']['id']}    ${spitem_id}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['spItem']['itemSourceEnum']}    ${spitem_itemSourceEnum}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['spItem']['spCode']}    ${itemEncId1}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['spItem']['name']}    ${spitem_name}
    # Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['spItem']['isInventoryItem']}    ${spitem_isInventoryItem}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['spItem']['isBatchApplicable']}    ${spitem_isBatchApplicable}
    # Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['spItem']['status']}    ${spitem_status}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['qty']}    ${quantity}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][1]['invCatalog']['encId']}    ${inventory_catalog_encid}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][1]['invCatalog']['catalogName']}    ${Name}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][1]['invCatalogItem']['encId']}    ${inventory_catalog_item_encid}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][1]['qty']}    ${quantity1}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][1]['spItem']['id']}    ${spitem_id}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][1]['spItem']['itemSourceEnum']}    ${spitem_itemSourceEnum}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][1]['spItem']['spCode']}    ${itemEncId1}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][1]['spItem']['name']}    ${spitem_name}
    # Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][1]['spItem']['isInventoryItem']}    ${spitem_isInventoryItem}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][1]['spItem']['isBatchApplicable']}    ${spitem_isBatchApplicable}
    # Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][1]['spItem']['status']}    ${spitem_status}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][2]['invCatalog']['encId']}    ${inventory_catalog_encid}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][2]['invCatalog']['catalogName']}    ${Name}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][2]['invCatalogItem']['encId']}    ${inventory_catalog_item_encid}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][2]['qty']}    ${quantity2}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['spItem']['id']}    ${spitem_id}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][2]['spItem']['itemSourceEnum']}    ${spitem_itemSourceEnum}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][2]['spItem']['spCode']}    ${itemEncId1}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][2]['spItem']['name']}    ${spitem_name}
    # Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][2]['spItem']['isInventoryItem']}    ${spitem_isInventoryItem}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][2]['spItem']['isBatchApplicable']}    ${spitem_isBatchApplicable}
    # Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][2]['spItem']['status']}    ${spitem_status}


JD-TC-Get Stock Adjustment By Id-3

    [Documentation]  Create stock adjustment with multiple batch enabled item then get by id.


    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME11}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${displayName}=     FakerLibrary.name

    ${resp}=    Create Item Inventory  ${displayName}    isBatchApplicable=${boolean[0]}   isInventoryItem=${bool[1]} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${itemEncId4}  ${resp.json()}

    ${displayName1}=     FakerLibrary.name

    ${resp}=    Create Item Inventory  ${displayName1}    isBatchApplicable=${boolean[0]}  isInventoryItem=${bool[1]} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${itemEncId5}  ${resp.json()}


    ${resp}=    Get Item Inventory  ${itemEncId4}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200
    Set Suite Variable         ${spitem_name4}  ${resp.json()['name']}     
    Set Suite Variable         ${spitem_id4}  ${resp.json()['id']}     
    Set Suite Variable         ${spitem_itemSourceEnum4}  ${resp.json()['itemSourceEnum']}                                  
    Set Suite Variable         ${spitem_isInventoryItem4}  ${resp.json()['isInventoryItem']}      
    Set Suite Variable         ${spitem_isBatchApplicable4}  ${resp.json()['isBatchApplicable']}                                                                                           
    Set Suite Variable         ${spitem_status4}  ${resp.json()['status']} 


    ${resp}=    Get Item Inventory  ${itemEncId5}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200
    Set Suite Variable         ${spitem_name5}  ${resp.json()['name']}     
    Set Suite Variable         ${spitem_id5}  ${resp.json()['id']}     
    Set Suite Variable         ${spitem_itemSourceEnum5}  ${resp.json()['itemSourceEnum']}                                  
    Set Suite Variable         ${spitem_isInventoryItem5}  ${resp.json()['isInventoryItem']}      
    Set Suite Variable         ${spitem_isBatchApplicable5}  ${resp.json()['isBatchApplicable']}                                                                                           
    Set Suite Variable         ${spitem_status5}  ${resp.json()['status']} 

    ${resp}=   Create Inventory Catalog Item  ${inventory_catalog_encid}   ${itemEncId4}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${inventory_catalog_item_encid4}  ${resp.json()[0]}

    ${resp}=   Create Inventory Catalog Item  ${inventory_catalog_encid}   ${itemEncId5}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${inventory_catalog_item_encid5}  ${resp.json()[0]}


    ${DAY2}=  db.add_timezone_date  ${tz}  10    
    ${batch}=     FakerLibrary.name
    ${resp}=   Create Batch  ${store_id}   ${inventory_catalog_item_encid4}   ${batch}   ${DAY2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${batch_id4}  ${resp.json()['id']}

    ${resp}=   Create Batch  ${store_id}   ${inventory_catalog_item_encid5}   ${batch}   ${DAY2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${batch_id5}  ${resp.json()['id']}


    ${quantity}=   Random Int  min=5  max=10
    ${quantity}=  Convert To Number  ${quantity}  1
    ${invCatalog}=  Create Dictionary   encId=${inventory_catalog_encid} 
    ${invCatalogItem}=  Create Dictionary   encId=${inventory_catalog_item_encid4} 
    ${invCatalogItem5}=  Create Dictionary   encId=${inventory_catalog_item_encid5} 

    ${data}=  Create Dictionary   invCatalog=${invCatalog}   invCatalogItem=${invCatalogItem}   batch=${batch_id4}   qty=${quantity}    


    ${data1}=  Create Dictionary   invCatalog=${invCatalog}   invCatalogItem=${invCatalogItem5}   batch=${batch_id5}   qty=${quantity}    

    ${resp}=  Create Stock Adjustment   ${locId1}  ${store_id}   ${inventory_catalog_encid}   ${remarks_encid1}      ${data}   ${data1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${uid}  ${resp.json()}


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
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['invCatalogItem']['encId']}    ${inventory_catalog_item_encid4}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['qty']}    ${quantity}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['batch']}    ${batch_id4}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['spItem']['id']}    ${spitem_id4}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['spItem']['itemSourceEnum']}    ${spitem_itemSourceEnum4}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['spItem']['spCode']}    ${itemEncId4}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['spItem']['name']}    ${spitem_name4}
    # Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['spItem']['isInventoryItem']}    ${spitem_isInventoryItem4}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['spItem']['isBatchApplicable']}    ${spitem_isBatchApplicable4}
    # Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['spItem']['status']}    ${spitem_status4}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][1]['invCatalog']['encId']}    ${inventory_catalog_encid}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][1]['invCatalog']['catalogName']}    ${Name}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][1]['invCatalogItem']['encId']}    ${inventory_catalog_item_encid5}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][1]['qty']}    ${quantity}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][1]['batch']}    ${batch_id5}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][1]['spItem']['id']}    ${spitem_id5}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][1]['spItem']['itemSourceEnum']}    ${spitem_itemSourceEnum5}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][1]['spItem']['spCode']}    ${itemEncId5}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][1]['spItem']['name']}    ${spitem_name5}
    # Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][1]['spItem']['isInventoryItem']}    ${spitem_isInventoryItem5}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][1]['spItem']['isBatchApplicable']}    ${spitem_isBatchApplicable5}
    # Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][1]['spItem']['status']}    ${spitem_status5}


JD-TC-Get Stock Adjustment By Id-UH1

    [Documentation]  Get stock adjustment By Id without login

    ${resp}=  Get Stock Adjustment By Id  ${uid}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-Get Stock Adjustment By Id-UH2

    [Documentation]  Get stock adjustment By Id with invalid id.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME11}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Stock Adjustment By Id  ${locId1}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    # Should Be Equal As Strings   ${resp.json()}   ${INVALID_STORE_ID}
    




