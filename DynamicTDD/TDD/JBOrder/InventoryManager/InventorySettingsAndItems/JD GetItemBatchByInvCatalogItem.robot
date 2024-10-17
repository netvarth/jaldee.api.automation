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
Variables         /ebs/TDD/varfiles/providers.py
Resource          /ebs/TDD/SuperAdminKeywords.robot




*** Test Cases ***

JD-TC-Get Item Batch By InvCatItem-1
    [Documentation]  Get Item Batch By InvCatItem.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME315}  ${PASSWORD}
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


    ${resp}=  Encrypted Provider Login  ${PUSERNAME315}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${accountId}=  get_acc_id  ${PUSERNAME315}
    Set Suite Variable    ${accountId} 

    ${resp}=  Provider Get Store Type By EncId     ${St_Id}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId1}=  Create Sample Location
        ${resp}=   Get Location ById  ${locId1}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Suite Variable  ${locId1}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
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
    Should Be Equal As Strings    ${resp.json()['catalogName']}    ${Name}

    ${displayName}=     FakerLibrary.name
    Set Suite Variable  ${displayName}

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

    ${resp}=  Get Inventoryitem      ${inventory_catalog_item_encid1}         
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${batch_encid}  ${resp.json()[0]['uid']}

    ${resp}=   Get Item Batch By InvCatItem  ${inventory_catalog_item_encid1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['uid']}    ${batch_encid} 
    Should Be Equal As Strings    ${resp.json()[0]['account']}    ${accountId} 
    Should Be Equal As Strings    ${resp.json()[0]['locationId']}    ${locId1}     
    Should Be Equal As Strings    ${resp.json()[0]['store']['name']}   ${Name}
    Should Be Equal As Strings    ${resp.json()[0]['store']['encId']}   ${store_id}
    Should Be Equal As Strings    ${resp.json()[0]['invCatalog']['encId']}     ${inventory_catalog_encid}
    Should Be Equal As Strings    ${resp.json()[0]['invCatalogItem']['encId']}     ${inventory_catalog_item_encid1}
    Should Be Equal As Strings    ${resp.json()[0]['spItem']['id']}    ${spitem_id} 
    Should Be Equal As Strings    ${resp.json()[0]['spItem']['itemSourceEnum']}    ${spitem_itemSourceEnum} 
    Should Be Equal As Strings    ${resp.json()[0]['spItem']['spCode']}    ${itemEncId3} 
    Should Be Equal As Strings    ${resp.json()[0]['spItem']['name']}    ${spitem_name}
    Should Be Equal As Strings    ${resp.json()[0]['batch']}     ${batch}
    Should Be Equal As Strings    ${resp.json()[0]['expiryDate']}     ${DAY2}

