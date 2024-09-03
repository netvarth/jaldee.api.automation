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

JD-TC-Get Item Stock adjust Filter-1

    [Documentation]  Get Item Stock adjust Filter.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME8}  ${PASSWORD}
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

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME8}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${accountId}=  get_acc_id  ${HLPUSERNAME8}
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

    ${resp}=    Get Store ByEncId   ${store_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${id_of_store}  ${resp.json()['id']}

    ${resp}=  Create Inventory Catalog   ${Name}  ${store_id}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${inventory_catalog_encid}  ${resp.json()}

    ${resp}=  Get Inventory Catalog By EncId   ${inventory_catalog_encid}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${id_of_inventory_catalog}  ${resp.json()['id']}

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

    ${resp}=    Create Item Inventory  ${categoryName}   categoryCode=${Ca_Id}  isInventoryItem=${bool[1]} 
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

    ${resp}=  Get Item Remark   ${remarks_encid1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${id}  ${resp.json()['id']}

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

    ${resp}=  Get Item Stock adjust Filter   account-eq=${accountId}     
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['uid']}    ${uid} 
    Should Be Equal As Strings    ${resp.json()[0]['location']}    ${locId1}    
    Should Be Equal As Strings    ${resp.json()[0]['locationName']}    ${place}   
    Should Be Equal As Strings    ${resp.json()[0]['remark']}     ${remarks}
    Should Be Equal As Strings    ${resp.json()[0]['invStatus']}     ${couponStatus[0]}
    Should Be Equal As Strings    ${resp.json()[0]['store']['name']}    ${Name}
    Should Be Equal As Strings    ${resp.json()[0]['store']['encId']}    ${store_id}
    Should Be Equal As Strings    ${resp.json()[0]['catalogDto']['encId']}    ${inventory_catalog_encid}
    Should Be Equal As Strings    ${resp.json()[0]['catalogDto']['status']}    ${InventoryCatalogStatus[0]}
    Should Be Equal As Strings    ${resp.json()[0]['inventoryRemarkDto']['id']}    ${id}


JD-TC-Get Item Stock adjust Filter-2

    [Documentation]  Get Item Stock adjust Filter using location name.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME8}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Stock adjust Filter   locationName-eq=${place}     
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['uid']}    ${uid} 
    Should Be Equal As Strings    ${resp.json()[0]['location']}    ${locId1}     
    Should Be Equal As Strings    ${resp.json()[0]['locationName']}   ${place}
    Should Be Equal As Strings    ${resp.json()[0]['remark']}     ${remarks}
    Should Be Equal As Strings    ${resp.json()[0]['invStatus']}     ${couponStatus[0]}
    Should Be Equal As Strings    ${resp.json()[0]['store']['name']}    ${Name}
    Should Be Equal As Strings    ${resp.json()[0]['store']['encId']}    ${store_id}
    Should Be Equal As Strings    ${resp.json()[0]['catalogDto']['encId']}    ${inventory_catalog_encid}
    Should Be Equal As Strings    ${resp.json()[0]['catalogDto']['status']}    ${InventoryCatalogStatus[0]}
    Should Be Equal As Strings    ${resp.json()[0]['inventoryRemarkDto']['id']}    ${id}

JD-TC-Get Item Stock adjust Filter-3

    [Documentation]  Get Item Stock adjust Filter using storeId.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME8}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Stock adjust Filter   storeId-eq=${id_of_store}     
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['uid']}    ${uid} 
    Should Be Equal As Strings    ${resp.json()[0]['location']}    ${locId1}     
    Should Be Equal As Strings    ${resp.json()[0]['locationName']}   ${place}
    Should Be Equal As Strings    ${resp.json()[0]['remark']}     ${remarks}
    Should Be Equal As Strings    ${resp.json()[0]['invStatus']}     ${couponStatus[0]}
    Should Be Equal As Strings    ${resp.json()[0]['store']['name']}    ${Name}
    Should Be Equal As Strings    ${resp.json()[0]['store']['encId']}    ${store_id}
    Should Be Equal As Strings    ${resp.json()[0]['catalogDto']['encId']}    ${inventory_catalog_encid}
    Should Be Equal As Strings    ${resp.json()[0]['catalogDto']['status']}    ${InventoryCatalogStatus[0]}
    Should Be Equal As Strings    ${resp.json()[0]['inventoryRemarkDto']['id']}    ${id}


JD-TC-Get Item Stock adjust Filter-4

    [Documentation]  Get Item Stock adjust Filter using storeEncId.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME8}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Stock adjust Filter   storeEncId-eq=${store_id}     
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['uid']}    ${uid} 
    Should Be Equal As Strings    ${resp.json()[0]['location']}    ${locId1}     
    Should Be Equal As Strings    ${resp.json()[0]['locationName']}   ${place}
    Should Be Equal As Strings    ${resp.json()[0]['remark']}     ${remarks}
    Should Be Equal As Strings    ${resp.json()[0]['invStatus']}     ${couponStatus[0]}
    Should Be Equal As Strings    ${resp.json()[0]['store']['name']}    ${Name}
    Should Be Equal As Strings    ${resp.json()[0]['store']['encId']}    ${store_id}
    Should Be Equal As Strings    ${resp.json()[0]['catalogDto']['encId']}    ${inventory_catalog_encid}
    Should Be Equal As Strings    ${resp.json()[0]['catalogDto']['status']}    ${InventoryCatalogStatus[0]}
    Should Be Equal As Strings    ${resp.json()[0]['inventoryRemarkDto']['id']}    ${id}

JD-TC-Get Item Stock adjust Filter-5

    [Documentation]  Get Item Stock adjust Filter using storeName.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME8}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Stock adjust Filter   storeName-eq=${Name}     
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['uid']}    ${uid} 
    Should Be Equal As Strings    ${resp.json()[0]['location']}    ${locId1}     
    Should Be Equal As Strings    ${resp.json()[0]['locationName']}   ${place}
    Should Be Equal As Strings    ${resp.json()[0]['remark']}     ${remarks}
    Should Be Equal As Strings    ${resp.json()[0]['invStatus']}     ${couponStatus[0]}
    Should Be Equal As Strings    ${resp.json()[0]['store']['name']}    ${Name}
    Should Be Equal As Strings    ${resp.json()[0]['store']['encId']}    ${store_id}
    Should Be Equal As Strings    ${resp.json()[0]['catalogDto']['encId']}    ${inventory_catalog_encid}
    Should Be Equal As Strings    ${resp.json()[0]['catalogDto']['status']}    ${InventoryCatalogStatus[0]}
    Should Be Equal As Strings    ${resp.json()[0]['inventoryRemarkDto']['id']}    ${id}

JD-TC-Get Item Stock adjust Filter-6

    [Documentation]  Get Item Stock adjust Filter using invCatalogId.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME8}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Stock adjust Filter   invCatalogId-eq=${id_of_inventory_catalog}     
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['uid']}    ${uid} 
    Should Be Equal As Strings    ${resp.json()[0]['location']}    ${locId1}     
    Should Be Equal As Strings    ${resp.json()[0]['locationName']}   ${place}
    Should Be Equal As Strings    ${resp.json()[0]['remark']}     ${remarks}
    Should Be Equal As Strings    ${resp.json()[0]['invStatus']}     ${couponStatus[0]}
    Should Be Equal As Strings    ${resp.json()[0]['store']['name']}    ${Name}
    Should Be Equal As Strings    ${resp.json()[0]['store']['encId']}    ${store_id}
    Should Be Equal As Strings    ${resp.json()[0]['catalogDto']['encId']}    ${inventory_catalog_encid}
    Should Be Equal As Strings    ${resp.json()[0]['catalogDto']['status']}    ${InventoryCatalogStatus[0]}
    Should Be Equal As Strings    ${resp.json()[0]['inventoryRemarkDto']['id']}    ${id}




JD-TC-Get Item Stock adjust Filter-7

    [Documentation]  Get Item Stock adjust Filter using status.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME8}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Stock adjust Filter   status-eq=${couponStatus[0]}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['uid']}    ${uid} 
    Should Be Equal As Strings    ${resp.json()[0]['location']}    ${locId1}     
    Should Be Equal As Strings    ${resp.json()[0]['locationName']}   ${place}
    Should Be Equal As Strings    ${resp.json()[0]['remark']}     ${remarks}
    Should Be Equal As Strings    ${resp.json()[0]['invStatus']}     ${couponStatus[0]}
    Should Be Equal As Strings    ${resp.json()[0]['store']['name']}    ${Name}
    Should Be Equal As Strings    ${resp.json()[0]['store']['encId']}    ${store_id}
    Should Be Equal As Strings    ${resp.json()[0]['catalogDto']['encId']}    ${inventory_catalog_encid}
    Should Be Equal As Strings    ${resp.json()[0]['catalogDto']['status']}    ${InventoryCatalogStatus[0]}
    Should Be Equal As Strings    ${resp.json()[0]['inventoryRemarkDto']['id']}    ${id}

JD-TC-Get Item Stock adjust Filter-8

    [Documentation]  Get Item Stock adjust Filter using location.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME8}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Stock adjust Filter   location-eq=${locId1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['uid']}    ${uid} 
    Should Be Equal As Strings    ${resp.json()[0]['location']}    ${locId1}     
    Should Be Equal As Strings    ${resp.json()[0]['locationName']}   ${place}
    Should Be Equal As Strings    ${resp.json()[0]['remark']}     ${remarks}
    Should Be Equal As Strings    ${resp.json()[0]['invStatus']}     ${couponStatus[0]}
    Should Be Equal As Strings    ${resp.json()[0]['store']['name']}    ${Name}
    Should Be Equal As Strings    ${resp.json()[0]['store']['encId']}    ${store_id}
    Should Be Equal As Strings    ${resp.json()[0]['catalogDto']['encId']}    ${inventory_catalog_encid}
    Should Be Equal As Strings    ${resp.json()[0]['catalogDto']['status']}    ${InventoryCatalogStatus[0]}
    Should Be Equal As Strings    ${resp.json()[0]['inventoryRemarkDto']['id']}    ${id}

JD-TC-Get Item Stock adjust Filter-9

    [Documentation]  Get Item Stock adjust Filter using invCatalogEncId.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME8}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Stock adjust Filter   invCatalogEncId-eq=${inventory_catalog_encid}     
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['uid']}    ${uid} 
    Should Be Equal As Strings    ${resp.json()[0]['location']}    ${locId1}     
    Should Be Equal As Strings    ${resp.json()[0]['locationName']}   ${place}
    Should Be Equal As Strings    ${resp.json()[0]['remark']}     ${remarks}
    Should Be Equal As Strings    ${resp.json()[0]['invStatus']}     ${couponStatus[0]}
    Should Be Equal As Strings    ${resp.json()[0]['store']['name']}    ${Name}
    Should Be Equal As Strings    ${resp.json()[0]['store']['encId']}    ${store_id}
    Should Be Equal As Strings    ${resp.json()[0]['catalogDto']['encId']}    ${inventory_catalog_encid}
    Should Be Equal As Strings    ${resp.json()[0]['catalogDto']['status']}    ${InventoryCatalogStatus[0]}
    Should Be Equal As Strings    ${resp.json()[0]['inventoryRemarkDto']['id']}    ${id}

JD-TC-Get Item Stock adjust Filter-10

    [Documentation]  Get Item Stock adjust Filter using uid.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME8}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Stock adjust Filter   uid-eq=${uid}     
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['uid']}    ${uid} 
    Should Be Equal As Strings    ${resp.json()[0]['location']}    ${locId1}     
    Should Be Equal As Strings    ${resp.json()[0]['locationName']}   ${place}
    Should Be Equal As Strings    ${resp.json()[0]['remark']}     ${remarks}
    Should Be Equal As Strings    ${resp.json()[0]['invStatus']}     ${couponStatus[0]}
    Should Be Equal As Strings    ${resp.json()[0]['store']['name']}    ${Name}
    Should Be Equal As Strings    ${resp.json()[0]['store']['encId']}    ${store_id}
    Should Be Equal As Strings    ${resp.json()[0]['catalogDto']['encId']}    ${inventory_catalog_encid}
    Should Be Equal As Strings    ${resp.json()[0]['catalogDto']['status']}    ${InventoryCatalogStatus[0]}
    Should Be Equal As Strings    ${resp.json()[0]['inventoryRemarkDto']['id']}    ${id}

JD-TC-Get Item Stock adjust Filter-11

    [Documentation]  Get Item Stock adjust Filter using remark.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME8}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Stock adjust Filter   remark-eq=${remarks}     
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['uid']}    ${uid} 
    Should Be Equal As Strings    ${resp.json()[0]['location']}    ${locId1}     
    Should Be Equal As Strings    ${resp.json()[0]['locationName']}   ${place}
    Should Be Equal As Strings    ${resp.json()[0]['remark']}     ${remarks}
    Should Be Equal As Strings    ${resp.json()[0]['invStatus']}     ${couponStatus[0]}
    Should Be Equal As Strings    ${resp.json()[0]['store']['name']}    ${Name}
    Should Be Equal As Strings    ${resp.json()[0]['store']['encId']}    ${store_id}
    Should Be Equal As Strings    ${resp.json()[0]['catalogDto']['encId']}    ${inventory_catalog_encid}
    Should Be Equal As Strings    ${resp.json()[0]['catalogDto']['status']}    ${InventoryCatalogStatus[0]}
    Should Be Equal As Strings    ${resp.json()[0]['inventoryRemarkDto']['id']}    ${id}

JD-TC-Get Item Stock adjust Filter-12

    [Documentation]  Get Item Stock adjust Filter using remark.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME8}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Stock adjust Filter   invRemark-eq=${id}     
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['uid']}    ${uid} 
    Should Be Equal As Strings    ${resp.json()[0]['location']}    ${locId1}     
    Should Be Equal As Strings    ${resp.json()[0]['locationName']}   ${place}
    Should Be Equal As Strings    ${resp.json()[0]['remark']}     ${remarks}
    Should Be Equal As Strings    ${resp.json()[0]['invStatus']}     ${couponStatus[0]}
    Should Be Equal As Strings    ${resp.json()[0]['store']['name']}    ${Name}
    Should Be Equal As Strings    ${resp.json()[0]['store']['encId']}    ${store_id}
    Should Be Equal As Strings    ${resp.json()[0]['catalogDto']['encId']}    ${inventory_catalog_encid}
    Should Be Equal As Strings    ${resp.json()[0]['catalogDto']['status']}    ${InventoryCatalogStatus[0]}
    Should Be Equal As Strings    ${resp.json()[0]['inventoryRemarkDto']['id']}    ${id}

JD-TC-Get Item Stock adjust Filter-13

    [Documentation]  update stock adjustment by adding more  stockAdjustDetailsDtos then get stock adjustment by flter

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME8}  ${PASSWORD}
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

    ${resp}=  Get Item Stock adjust Filter   account-eq=${accountId}     
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['uid']}    ${uid} 
    Should Be Equal As Strings    ${resp.json()[0]['location']}    ${locId1}     
    Should Be Equal As Strings    ${resp.json()[0]['locationName']}   ${place}
    Should Be Equal As Strings    ${resp.json()[0]['remark']}     ${remarks}
    Should Be Equal As Strings    ${resp.json()[0]['invStatus']}     ${couponStatus[0]}
    Should Be Equal As Strings    ${resp.json()[0]['store']['name']}    ${Name}
    Should Be Equal As Strings    ${resp.json()[0]['store']['encId']}    ${store_id}
    Should Be Equal As Strings    ${resp.json()[0]['catalogDto']['encId']}    ${inventory_catalog_encid}
    Should Be Equal As Strings    ${resp.json()[0]['catalogDto']['status']}    ${InventoryCatalogStatus[0]}
    Should Be Equal As Strings    ${resp.json()[0]['inventoryRemarkDto']['id']}    ${id}



JD-TC-Get Item Stock adjust Filter-UH1

    [Documentation]  Get stock adjustment filter without login

    ${resp}=  Get Item Stock adjust Filter   account-eq=${accountId}     
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-Get Item Stock adjust Filter-UH2

    [Documentation]  Get stock adjustment filter with invalid remarks id.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME8}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  Get Item Stock adjust Filter   invRemark-eq=${inventory_catalog_encid}     
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()}   []


JD-TC-Get Item Stock adjust Filter-UH4

    [Documentation]  Get stock adjustment filter with invalid remark id.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME8}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  Get Item Stock adjust Filter   remark-eq=${inventory_catalog_encid}     
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()}   []

JD-TC-Get Item Stock adjust Filter-UH5

    [Documentation]  Get stock adjustment filter with invalid uid.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME8}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  Get Item Stock adjust Filter   uid-eq=${inventory_catalog_encid}     
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()}   []

JD-TC-Get Item Stock adjust Filter-UH6

    [Documentation]  Get stock adjustment filter with invalid location.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME8}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  Get Item Stock adjust Filter   location-eq=${inventory_catalog_encid}     
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()}   []

JD-TC-Get Item Stock adjust Filter-UH7

    [Documentation]  Get stock adjustment filter with invalid status.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME8}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  Get Item Stock adjust Filter   status-eq=${InvStatus[1]}     
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()}   []

JD-TC-Get Item Stock adjust Filter-UH8

    [Documentation]  Get stock adjustment filter with invalid locationName.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME8}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  Get Item Stock adjust Filter   locationName-eq=${inventory_catalog_encid}     
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()}   []

JD-TC-Get Item Stock adjust Filter-UH9

    [Documentation]  Get stock adjustment filter with invalid storeId.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME8}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  Get Item Stock adjust Filter   storeId-eq=${inventory_catalog_encid}     
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()}   []
    
JD-TC-Get Item Stock adjust Filter-UH10

    [Documentation]  Get stock adjustment filter with invalid storeEncId.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME8}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  Get Item Stock adjust Filter   storeEncId-eq=${inventory_catalog_encid}     
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()}   []

JD-TC-Get Item Stock adjust Filter-UH11

    [Documentation]  Get stock adjustment filter with invalid storeName.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME8}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  Get Item Stock adjust Filter   storeName-eq=${inventory_catalog_encid}     
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()}   []
    
    




