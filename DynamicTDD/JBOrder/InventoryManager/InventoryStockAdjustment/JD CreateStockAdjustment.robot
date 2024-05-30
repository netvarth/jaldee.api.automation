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

JD-TC-Create Stock Adjustment-1

    [Documentation]  Create stock adjustment with valid details.

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME6}  ${PASSWORD}
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
    sleep  02s
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

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME6}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${accountId}=  get_acc_id  ${HLMUSERNAME6}
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

    ${resp}=    Create Item Inventory  ${displayName}         isInventoryItem=${bool[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${itemEncId1}  ${resp.json()}

    ${categoryName}=    FakerLibrary.name
    Set Suite Variable  ${categoryName}

    ${resp}=  Create Item Category   ${categoryName}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${Ca_Id}    ${resp.json()}

    ${resp}=    Create Item Inventory  ${categoryName}   categoryCode=${Ca_Id}      isInventoryItem=${bool[1]}
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
    ${invCatalog}=  Create Dictionary   encId=${inventory_catalog_encid} 
    ${invCatalogItem}=  Create Dictionary   encId=${inventory_catalog_item_encid} 
    ${data}=  Create Dictionary   invCatalog=${invCatalog}   invCatalogItem=${invCatalogItem}    qty=${quantity}    
    Set Suite Variable  ${data}  
    ${resp}=  Create Stock Adjustment   ${locId1}  ${store_id}   ${inventory_catalog_encid}   ${remarks_encid1}      ${data} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Set Suite Variable  ${remarks_encid1}  ${resp.json()}

JD-TC-Create Stock Adjustment-2

    [Documentation]  Create stock adjustment with multiple stockAdjustDetailsDtos.

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME6}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${quantity}=   Random Int  min=5  max=10
    ${quantity}=  Convert To Number  ${quantity}  1
    ${invCatalog}=  Create Dictionary   encId=${inventory_catalog_encid} 
    ${invCatalogItem}=  Create Dictionary   encId=${inventory_catalog_item_encid} 
    ${data1}=  Create Dictionary   invCatalog=${invCatalog}   invCatalogItem=${invCatalogItem}    qty=${quantity}       

    ${resp}=  Create Stock Adjustment   ${locId1}  ${store_id}   ${inventory_catalog_encid}   ${remarks_encid1}      ${data}   ${data1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Create Stock Adjustment-3

    [Documentation]  Create stock adjustment thats already created.

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME6}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  Create Stock Adjustment   ${locId1}  ${store_id}   ${inventory_catalog_encid}   ${remarks_encid1}      ${data}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Create Stock Adjustment-4

    [Documentation]  Create stock adjustment with batch enabled item.

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME6}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${displayName}=     FakerLibrary.name

    ${resp}=    Create Item Inventory  ${displayName}       isBatchApplicable=${boolean[1]}    isInventoryItem=${bool[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${itemEncId3}  ${resp.json()}

    ${resp}=    Get Item Inventory  ${itemEncId3}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200
    Set Suite Variable         ${spitem_name}  ${resp.json()['name']}     
    Set Suite Variable         ${spitem_id}  ${resp.json()['id']}     
    Set Suite Variable         ${spitem_itemSourceEnum}  ${resp.json()['itemSourceEnum']}                                  
    Set Suite Variable         ${spitem_isInventoryItem}  ${resp.json()['isInventoryItem']}      
    Set Suite Variable         ${spitem_isBatchApplicable}  ${resp.json()['isBatchApplicable']}                                                                                           
    Set Suite Variable         ${spitem_status}  ${resp.json()['status']} 

    ${resp}=   Create Inventory Catalog Item  ${inventory_catalog_encid}   ${itemEncId3}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${inventory_catalog_item_encid1}  ${resp.json()[0]}

    ${DAY2}=  db.add_timezone_date  ${tz}  10    
    ${batch}=     FakerLibrary.name
    ${resp}=   Create Batch  ${store_id}   ${inventory_catalog_item_encid1}   ${batch}   ${DAY2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${batch_id}  ${resp.json()['id']}


    ${quantity}=   Random Int  min=5  max=10
    ${quantity}=  Convert To Number  ${quantity}  1
    ${invCatalog}=  Create Dictionary   encId=${inventory_catalog_encid} 
    ${invCatalogItem}=  Create Dictionary   encId=${inventory_catalog_item_encid1} 

    ${data}=  Create Dictionary   invCatalog=${invCatalog}   invCatalogItem=${invCatalogItem}   batch=${batch_id}   qty=${quantity}    
    Set Suite Variable  ${data}  
    ${resp}=  Create Stock Adjustment   ${locId1}  ${store_id}   ${inventory_catalog_encid}   ${remarks_encid1}      ${data} 
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
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['invCatalogItem']['encId']}    ${inventory_catalog_item_encid1}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['qty']}    ${quantity}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['batch']}    ${batch_id}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['spItem']['id']}    ${spitem_id}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['spItem']['itemSourceEnum']}    ${spitem_itemSourceEnum}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['spItem']['spCode']}    ${itemEncId3}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['spItem']['name']}    ${spitem_name}
    # Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['spItem']['isInventoryItem']}    ${spitem_isInventoryItem}
    # Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['spItem']['isBatchApplicable']}    ${spitem_isBatchApplicable}
    # Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['spItem']['status']}    ${spitem_status}


JD-TC-Create Stock Adjustment-5

    [Documentation]  Create stock adjustment with multiple batch enabled item.

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME6}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${displayName}=     FakerLibrary.name

    ${resp}=    Create Item Inventory  ${displayName}    isBatchApplicable=${boolean[1]}    isInventoryItem=${bool[1]}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${itemEncId4}  ${resp.json()}

    ${displayName1}=     FakerLibrary.name

    ${resp}=    Create Item Inventory  ${displayName1}    isBatchApplicable=${boolean[1]}    isInventoryItem=${bool[1]}
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
    # Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['spItem']['isBatchApplicable']}    ${spitem_isBatchApplicable4}
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
    # Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][1]['spItem']['isBatchApplicable']}    ${spitem_isBatchApplicable5}
    # Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][1]['spItem']['status']}    ${spitem_status5}


JD-TC-Create Stock Adjustment-6

    [Documentation]  Create stock adjustment with one batch enabled item and one batch disabled item.

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME6}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${displayName}=     FakerLibrary.name

    ${resp}=    Create Item Inventory  ${displayName}        isInventoryItem=${bool[1]} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${itemEncId7}  ${resp.json()}

    ${displayName1}=     FakerLibrary.name

    ${resp}=    Create Item Inventory  ${displayName1}        isInventoryItem=${bool[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${itemEncId8}  ${resp.json()}


    ${resp}=    Get Item Inventory  ${itemEncId7}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200
    Set Suite Variable         ${spitem_name7}  ${resp.json()['name']}     
    Set Suite Variable         ${spitem_id7}  ${resp.json()['id']}     
    Set Suite Variable         ${spitem_itemSourceEnum7}  ${resp.json()['itemSourceEnum']}                                  
    Set Suite Variable         ${spitem_isInventoryItem7}  ${resp.json()['isInventoryItem']}      
    Set Suite Variable         ${spitem_isBatchApplicable7}  ${resp.json()['isBatchApplicable']}                                                                                           
    Set Suite Variable         ${spitem_status7}  ${resp.json()['status']} 


    ${resp}=    Get Item Inventory  ${itemEncId8}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200
    Set Suite Variable         ${spitem_name8}  ${resp.json()['name']}     
    Set Suite Variable         ${spitem_id8}  ${resp.json()['id']}     
    Set Suite Variable         ${spitem_itemSourceEnum8}  ${resp.json()['itemSourceEnum']}                                  
    Set Suite Variable         ${spitem_isInventoryItem8}  ${resp.json()['isInventoryItem']}      
    Set Suite Variable         ${spitem_isBatchApplicable8}  ${resp.json()['isBatchApplicable']}                                                                                           
    Set Suite Variable         ${spitem_status8}  ${resp.json()['status']} 

    ${resp}=   Create Inventory Catalog Item  ${inventory_catalog_encid}   ${itemEncId7}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${inventory_catalog_item_encid7}  ${resp.json()[0]}

    ${resp}=   Create Inventory Catalog Item  ${inventory_catalog_encid}   ${itemEncId8}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${inventory_catalog_item_encid8}  ${resp.json()[0]}


    ${DAY2}=  db.add_timezone_date  ${tz}  10    
    ${batch}=     FakerLibrary.name


    ${resp}=   Create Batch  ${store_id}   ${inventory_catalog_item_encid8}   ${batch}   ${DAY2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${batch_id8}  ${resp.json()['id']}


    ${quantity}=   Random Int  min=5  max=10
    ${quantity}=  Convert To Number  ${quantity}  1
    ${invCatalog}=  Create Dictionary   encId=${inventory_catalog_encid} 
    ${invCatalogItem}=  Create Dictionary   encId=${inventory_catalog_item_encid7} 
    ${invCatalogItem8}=  Create Dictionary   encId=${inventory_catalog_item_encid8} 

    ${data}=  Create Dictionary   invCatalog=${invCatalog}   invCatalogItem=${invCatalogItem}     qty=${quantity}    


    ${data1}=  Create Dictionary   invCatalog=${invCatalog}   invCatalogItem=${invCatalogItem8}   batch=${batch_id8}   qty=${quantity}    

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
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['invCatalogItem']['encId']}    ${inventory_catalog_item_encid7}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['qty']}    ${quantity}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['spItem']['id']}    ${spitem_id7}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['spItem']['itemSourceEnum']}    ${spitem_itemSourceEnum7}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['spItem']['spCode']}    ${itemEncId7}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['spItem']['name']}    ${spitem_name7}
    # Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['spItem']['isInventoryItem']}    ${spitem_isInventoryItem7}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['spItem']['isBatchApplicable']}    ${spitem_isBatchApplicable7}
    # Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][0]['spItem']['status']}    ${spitem_status7}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][1]['invCatalog']['encId']}    ${inventory_catalog_encid}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][1]['invCatalog']['catalogName']}    ${Name}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][1]['invCatalogItem']['encId']}    ${inventory_catalog_item_encid8}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][1]['qty']}    ${quantity}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][1]['batch']}    ${batch_id8}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][1]['spItem']['id']}    ${spitem_id8}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][1]['spItem']['itemSourceEnum']}    ${spitem_itemSourceEnum8}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][1]['spItem']['spCode']}    ${itemEncId8}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][1]['spItem']['name']}    ${spitem_name8}
    # Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][1]['spItem']['isInventoryItem']}    ${spitem_isInventoryItem8}
    Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][1]['spItem']['isBatchApplicable']}    ${spitem_isBatchApplicable8}
    # Should Be Equal As Strings    ${resp.json()['stockAdjustDetailsDtos'][1]['spItem']['status']}    ${spitem_status8}


JD-TC-Create Stock Adjustment-UH1

    [Documentation]  Create stock adjustment without login

    ${resp}=  Create Stock Adjustment   ${locId1}  ${store_id}   ${inventory_catalog_encid}   ${remarks_encid1}      ${data}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-Create Stock Adjustment-UH2

    [Documentation]  Create stock adjustment with empty store id.

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME6}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  Create Stock Adjustment   ${locId1}  ${EMPTY}   ${inventory_catalog_encid}   ${remarks_encid1}      ${data}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}   ${INVALID_STORE_ID}
    

JD-TC-Create Stock Adjustment-UH3

    [Documentation]  Create stock adjustment with empty inventory_catalog_encid.

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME6}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  Create Stock Adjustment   ${locId1}  ${store_id}   ${EMPTY}   ${remarks_encid1}      ${data}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}   ${CAP_Invalid_Catalog_id}
    

JD-TC-Create Stock Adjustment-UH4

    [Documentation]  Create stock adjustment with empty remarks_encid1.

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME6}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  Create Stock Adjustment   ${locId1}  ${store_id}   ${inventory_catalog_encid}   ${EMPTY}      ${data}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}   ${INVALID_REMARKS_ID}

JD-TC-Create Stock Adjustment-UH5

    [Documentation]  Create stock adjustment with empty quantity.

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME6}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${invCatalog}=  Create Dictionary   encId=${inventory_catalog_encid} 
    ${invCatalogItem}=  Create Dictionary   encId=${inventory_catalog_item_encid} 
    ${data1}=  Create Dictionary   invCatalog=${invCatalog}   invCatalogItem=${invCatalogItem}    qty=${EMPTY}        

    ${resp}=  Create Stock Adjustment   ${locId1}  ${store_id}   ${inventory_catalog_encid}   ${remarks_encid1}      ${data1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings   ${resp.json()}   ${INVALID_QUANTITY}

JD-TC-Create Stock Adjustment-UH6

    [Documentation]  Stock Adjustment Dto -invCatalogItemId not added in the invoice catalog id thats we are given.

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME6}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Name1}=    FakerLibrary.last name
    Set Suite Variable  ${Name1}

    ${resp}=  Create Inventory Catalog   ${Name1}  ${store_id}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${inventory_catalog_encid1}  ${resp.json()}


    ${quantity}=   Random Int  min=5  max=10
    ${quantity}=  Convert To Number  ${quantity}  1
    Set Suite Variable  ${quantity}  
    ${invCatalog}=  Create Dictionary   encId=${inventory_catalog_encid1} 
    ${invCatalogItem}=  Create Dictionary   encId=${inventory_catalog_item_encid} 
    ${data3}=  Create Dictionary   invCatalog=${invCatalog}   invCatalogItem=${invCatalogItem}    qty=${quantity}  
    Set Suite Variable  ${data3}  

    ${resp}=  Create Stock Adjustment   ${locId1}  ${store_id}   ${inventory_catalog_encid1}   ${remarks_encid1}    ${data3} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}   ${INVALID_INVENTORY_CATALOG_ITEM_ID}


JD-TC-Create Stock Adjustment-UH7

    [Documentation]  Catalog Dto encid and Stock Adjustment Dto - invoice catalog id is different.

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME6}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Create Stock Adjustment   ${locId1}  ${store_id}   ${inventory_catalog_encid}   ${remarks_encid1}    ${data3} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}   ${CAP_Invalid_inventory_catalog_Id}


JD-TC-Create Stock Adjustment-UH8

    [Documentation]  Create stock adjustment with zero quantity.

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME6}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${invCatalog}=  Create Dictionary   encId=${inventory_catalog_encid} 
    ${invCatalogItem}=  Create Dictionary   encId=${inventory_catalog_item_encid} 
    ${data1}=  Create Dictionary   invCatalog=${invCatalog}   invCatalogItem=${invCatalogItem}    qty=0  

    ${resp}=  Create Stock Adjustment   ${locId1}  ${store_id}   ${inventory_catalog_encid}   ${remarks_encid1}      ${data1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings   ${resp.json()}   ${INVALID_QUANTITY}


JD-TC-Create Stock Adjustment-UH9

    [Documentation]  Create stock adjustment with empty invCatalogItemId.

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME6}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${invCatalog}=  Create Dictionary   encId=${inventory_catalog_encid} 
    ${invCatalogItem}=  Create Dictionary   encId=${EMPTY} 
    ${data1}=  Create Dictionary   invCatalog=${invCatalog}   invCatalogItem=${invCatalogItem}    qty=1

    ${resp}=  Create Stock Adjustment   ${locId1}  ${store_id}   ${inventory_catalog_encid}   ${remarks_encid1}      ${data1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings   ${resp.json()}   ${INVALID_INVENTORY_CATALOG_ITEM_ID}


JD-TC-Create Stock Adjustment-UH10

    [Documentation]  Create stock adjustment with empty stock adjustment dto list.

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME6}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${data1}=  Create Dictionary   
    ${resp}=  Create Stock Adjustment   ${locId1}  ${store_id}   ${inventory_catalog_encid}   ${remarks_encid1}      ${data1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    # Should Be Equal As Strings   ${resp.json()}   ${INVALID_QUANTITY}


JD-TC-Create Stock Adjustment-UH11

    [Documentation]  Item have batch applicable then create stock adjustment without giving batch id.

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME6}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${displayName}=     FakerLibrary.name

    ${resp}=    Create Item Inventory  ${displayName}    isBatchApplicable=${boolean[1]}   isInventoryItem=${bool[1]} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${itemEncId6}  ${resp.json()}

    ${resp}=   Create Inventory Catalog Item  ${inventory_catalog_encid}   ${itemEncId6}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${inventory_catalog_item_encid6}  ${resp.json()[0]}

    ${DAY2}=  db.add_timezone_date  ${tz}  10    
    ${batch}=     FakerLibrary.name
    ${resp}=   Create Batch  ${store_id}   ${inventory_catalog_item_encid6}   ${batch}   ${DAY2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${batch_id6}  ${resp.json()['id']}


    ${quantity}=   Random Int  min=5  max=10
    ${quantity}=  Convert To Number  ${quantity}  1
    ${invCatalog}=  Create Dictionary   encId=${inventory_catalog_encid} 
    ${invCatalogItem}=  Create Dictionary   encId=${inventory_catalog_item_encid6} 
    ${BATCH_REQUIRED}=  Format String  ${BATCH_REQUIRED}    ${displayName}

    ${data}=  Create Dictionary   invCatalog=${invCatalog}   invCatalogItem=${invCatalogItem}      qty=${quantity}    
    ${resp}=  Create Stock Adjustment   ${locId1}  ${store_id}   ${inventory_catalog_encid}   ${remarks_encid1}      ${data} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}   ${BATCH_REQUIRED}

JD-TC-Create Stock Adjustment-UH12

    [Documentation]  Inactive store and then try to Create stock adjustment using that disabled store.

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME6}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Update store status  ${store_id}  ${LoanApplicationStatus[4]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Create Stock Adjustment   ${locId1}  ${store_id}   ${inventory_catalog_encid}   ${remarks_encid1}      ${data}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}   ${INVALID_STORE_ID}
    





